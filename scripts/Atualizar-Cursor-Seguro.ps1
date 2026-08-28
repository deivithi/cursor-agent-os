param(
    [switch]$ValidateOnly,
    [switch]$RepairUserInstall,
    [switch]$OpenAfterUpdate
)

$ErrorActionPreference = "Stop"

$userRoot = Join-Path $env:LOCALAPPDATA "Programs\cursor"
$userExe = Join-Path $userRoot "Cursor.exe"
$userBin = Join-Path $userRoot "resources\app\bin"
$userCmd = Join-Path $userBin "cursor.cmd"
$userProduct = Join-Path $userRoot "resources\app\product.json"
$userStaging = Join-Path $userRoot "_"
$systemRoot = Join-Path $env:ProgramFiles "cursor"
$systemBin = Join-Path $systemRoot "resources\app\bin"
$watchdogTaskName = "Febracis-Cursor-UpdateWatchdog"
$watchdogScript = Join-Path $PSScriptRoot "cursor-update-watchdog.ps1"
$watchdogInstaller = Join-Path $PSScriptRoot "install-cursor-update-watchdog.ps1"
$logDir = Join-Path $env:LOCALAPPDATA "febracis-logs"
$logPath = Join-Path $logDir ("cursor-user-update-{0}.log" -f (Get-Date -Format "yyyyMMdd-HHmmss"))

if (-not (Test-Path -LiteralPath $logDir)) {
    New-Item -ItemType Directory -Path $logDir -Force | Out-Null
}

function Write-UpdateLog {
    param(
        [string]$Message,
        [ValidateSet("INFO", "WARN", "ERROR")]
        [string]$Level = "INFO"
    )

    $line = "{0} {1} {2}" -f (Get-Date -Format "yyyy-MM-dd HH:mm:ss"), $Level, $Message
    Add-Content -LiteralPath $logPath -Value $line -Encoding UTF8
    Write-Host "[Cursor User Update][$Level] $Message"
}

function Get-CursorUninstallEntries {
    $roots = @(
        "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*",
        "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*",
        "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
    )

    foreach ($root in $roots) {
        Get-ItemProperty $root -ErrorAction SilentlyContinue |
            Where-Object {
                $_.DisplayName -match "^Cursor( \(User\))?$" -or
                ($_.InstallLocation -and $_.InstallLocation.TrimEnd("\") -match "\\cursor$")
            }
    }
}

function Get-CursorManagedProcesses {
    Get-Process -ErrorAction SilentlyContinue | Where-Object {
        $_.Path -and
        $_.Path -notmatch "Codex|OpenCode" -and
        (
            $_.Path.StartsWith($userRoot, [System.StringComparison]::OrdinalIgnoreCase) -or
            $_.Path.StartsWith($systemRoot, [System.StringComparison]::OrdinalIgnoreCase) -or
            $_.Path -match "CodeSetup-stable|inno_updater|\\cursor-agent\\"
        )
    }
}

function Stop-CursorManagedProcesses {
    $processes = @(Get-CursorManagedProcesses)
    foreach ($process in $processes) {
        Write-UpdateLog "Encerrando $($process.ProcessName) PID $($process.Id) PATH $($process.Path)"
        Stop-Process -Id $process.Id -Force -ErrorAction SilentlyContinue
    }

    Start-Sleep -Seconds 3
    $remaining = @(Get-CursorManagedProcesses)
    if ($remaining.Count -gt 0) {
        $details = ($remaining | ForEach-Object { "$($_.ProcessName)#$($_.Id)" }) -join ", "
        throw "Processos do Cursor ainda ativos: $details"
    }
}

function Invoke-SystemInstallRemoval {
    if (-not (Test-Path -LiteralPath $systemRoot)) {
        return
    }

    $systemUninstaller = Join-Path $systemRoot "unins000.exe"
    if (Test-Path -LiteralPath $systemUninstaller) {
        Write-UpdateLog "Removendo instalacao System pelo uninstaller: $systemUninstaller"
        $process = Start-Process -FilePath $systemUninstaller -ArgumentList "/VERYSILENT", "/SUPPRESSMSGBOXES", "/NORESTART" -Wait -PassThru -WindowStyle Hidden
        if ($process.ExitCode -ne 0) {
            throw "Uninstaller System retornou codigo $($process.ExitCode). Execute o reparo com elevacao."
        }
    }

    if (Test-Path -LiteralPath $systemRoot) {
        try {
            Remove-Item -LiteralPath $systemRoot -Recurse -Force
        } catch {
            throw "Resquicio System em $systemRoot nao pode ser removido sem elevacao: $($_.Exception.Message)"
        }
    }
}

function Get-ProductVersion {
    if (-not (Test-Path -LiteralPath $userProduct)) {
        return $null
    }

    $product = Get-Content -LiteralPath $userProduct -Raw | ConvertFrom-Json
    return $product.version
}

function Get-PathEntries {
    param([ValidateSet("User", "Machine")] [string]$Target)

    $path = [Environment]::GetEnvironmentVariable("Path", $Target)
    return @($path -split ";" | Where-Object { $_ })
}

function Set-UserPathCanonical {
    $userEntries = @(Get-PathEntries -Target "User" | Where-Object {
        $_.TrimEnd("\") -ine $systemBin.TrimEnd("\")
    })

    if (@($userEntries | Where-Object { $_.TrimEnd("\") -ieq $userBin.TrimEnd("\") }).Count -eq 0) {
        $userEntries += $userBin
        Write-UpdateLog "Adicionando PATH de usuario canonico: $userBin"
    }

    [Environment]::SetEnvironmentVariable("Path", ($userEntries -join ";"), "User")
    $machineEntries = @(Get-PathEntries -Target "Machine")
    $env:Path = (($machineEntries + $userEntries) -join ";")
}

function Test-CursorUserPolicy {
    param([switch]$StrictProcesses)

    $errors = New-Object System.Collections.Generic.List[string]
    $warnings = New-Object System.Collections.Generic.List[string]
    $entries = @(Get-CursorUninstallEntries)
    $userEntries = @($entries | Where-Object {
        $_.InstallLocation -and $_.InstallLocation.TrimEnd("\") -ieq $userRoot.TrimEnd("\")
    })
    $systemEntries = @($entries | Where-Object {
        $_.InstallLocation -and $_.InstallLocation.TrimEnd("\") -ieq $systemRoot.TrimEnd("\")
    })
    $processes = @(Get-CursorManagedProcesses)
    $machineCursorPath = @(Get-PathEntries -Target "Machine" | Where-Object { $_ -match "cursor" })
    $userCursorPath = @(Get-PathEntries -Target "User" | Where-Object { $_ -match "cursor" })
    $productVersion = Get-ProductVersion
    $watchdogTask = Get-ScheduledTask -TaskName $watchdogTaskName -ErrorAction SilentlyContinue
    $watchdogProcesses = @(Get-CimInstance Win32_Process -ErrorAction SilentlyContinue | Where-Object {
        $_.Name -ieq "powershell.exe" -and
        $_.CommandLine -like "*-File*cursor-update-watchdog.ps1*"
    })

    if ($userEntries.Count -ne 1) {
        $errors.Add("Esperada exatamente 1 instalacao Cursor (User) em $userRoot; encontrado $($userEntries.Count).")
    }

    if ($systemEntries.Count -gt 0 -or (Test-Path -LiteralPath $systemRoot)) {
        $errors.Add("Instalacao System detectada em $systemRoot. Remova antes de atualizar.")
    }

    if (-not (Test-Path -LiteralPath $userExe)) {
        $errors.Add("Cursor.exe nao encontrado em $userExe.")
    }

    if (-not (Test-Path -LiteralPath $userCmd)) {
        $errors.Add("cursor.cmd nao encontrado em $userCmd.")
    }

    if (Test-Path -LiteralPath $userStaging) {
        $errors.Add("Staging pendente detectado em $userStaging. Repare a instalacao antes de atualizar.")
    }

    if (-not $watchdogTask) {
        $errors.Add("Tarefa preventiva $watchdogTaskName nao encontrada.")
    } elseif ($watchdogTask.State -ne "Running") {
        $errors.Add("Tarefa preventiva $watchdogTaskName nao esta Running; estado=$($watchdogTask.State).")
    }

    if (-not (Test-Path -LiteralPath $watchdogScript)) {
        $errors.Add("Script preventivo nao encontrado em $watchdogScript.")
    }

    if ($watchdogProcesses.Count -ne 1) {
        $errors.Add("Esperado exatamente 1 processo watchdog ativo; encontrado $($watchdogProcesses.Count).")
    }

    if (@($machineCursorPath | Where-Object { $_.TrimEnd("\") -ieq $systemBin.TrimEnd("\") }).Count -gt 0) {
        $errors.Add("PATH de maquina ainda aponta para $systemBin.")
    }

    if (@($userCursorPath | Where-Object { $_.TrimEnd("\") -ieq $userBin.TrimEnd("\") }).Count -eq 0) {
        $errors.Add("PATH de usuario nao contem $userBin.")
    }

    if ($StrictProcesses -and $processes.Count -gt 0) {
        $errors.Add("Processos do Cursor ativos durante reparo: $(($processes | ForEach-Object { "$($_.ProcessName)#$($_.Id)" }) -join ', ').")
    } elseif ($processes.Count -gt 0) {
        $warnings.Add("Processos do Cursor ativos: $(($processes | ForEach-Object { "$($_.ProcessName)#$($_.Id)" }) -join ', ').")
    }

    $registryVersion = if ($userEntries.Count -eq 1) { $userEntries[0].DisplayVersion } else { $null }
    if ($productVersion -and $registryVersion -and $productVersion -ne $registryVersion) {
        $errors.Add("Versao divergente: product.json=$productVersion registry=$registryVersion.")
    }

    if (Test-Path -LiteralPath $userCmd) {
        $cliVersion = @(& $userCmd --version 2>$null)
        if ($LASTEXITCODE -ne 0 -or -not $cliVersion) {
            $errors.Add("cursor --version falhou.")
        } else {
            Write-UpdateLog "cursor --version: $($cliVersion -join ' | ')"
        }
    }

    [pscustomobject]@{
        Errors = @($errors)
        Warnings = @($warnings)
        ProductVersion = $productVersion
        RegistryVersion = $registryVersion
        UserInstall = $userRoot
        UserPathCursorEntries = $userCursorPath
        MachinePathCursorEntries = $machineCursorPath
    }
}

try {
    Write-UpdateLog "Inicio. ValidateOnly=$ValidateOnly RepairUserInstall=$RepairUserInstall OpenAfterUpdate=$OpenAfterUpdate Log=$logPath"
    Write-UpdateLog "Politica: Cursor User em $userRoot; updater nativo protegido por watchdog invisivel; sem System install em Program Files."

    if ($RepairUserInstall) {
        Stop-CursorManagedProcesses
        Invoke-SystemInstallRemoval
        Set-UserPathCanonical
        if (-not (Test-Path -LiteralPath $watchdogInstaller)) {
            throw "Instalador do watchdog nao encontrado: $watchdogInstaller"
        }
        Write-UpdateLog "Reinstalando tarefa preventiva $watchdogTaskName."
        & $watchdogInstaller | ForEach-Object { Write-UpdateLog ($_ | Out-String).Trim() }
    }

    $health = Test-CursorUserPolicy -StrictProcesses:$RepairUserInstall

    foreach ($warning in $health.Warnings) {
        Write-UpdateLog $warning "WARN"
    }

    if ($health.Errors.Count -gt 0) {
        foreach ($errorMessage in $health.Errors) {
            Write-UpdateLog $errorMessage "ERROR"
        }
        throw "Politica do Cursor User nao aprovada."
    }

    if ($OpenAfterUpdate) {
        Write-UpdateLog "Abrindo Cursor User."
        Start-Process -FilePath $userExe
    }

    Write-UpdateLog "Sucesso. Cursor User validado na versao $($health.ProductVersion)."
    exit 0
}
catch {
    Write-UpdateLog $_.Exception.Message "ERROR"
    exit 1
}
