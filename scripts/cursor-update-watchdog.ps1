param(
    [ValidateRange(1, 60)]
    [int]$IntervalSeconds = 2,
    [switch]$Once
)

$ErrorActionPreference = 'Stop'

$root = Join-Path $env:LOCALAPPDATA 'Programs\cursor'
$mainExe = Join-Path $root 'Cursor.exe'
$stagedRoot = Join-Path $root '_'
$stagedExe = Join-Path $stagedRoot 'Cursor.exe'
$helperNodeSuffix = '\resources\app\resources\helpers\node.exe'
$logDir = Join-Path $env:LOCALAPPDATA 'febracis-logs'
$logPath = Join-Path $logDir 'cursor-update-watchdog.log'
$mutexName = 'Local\FebracisCursorUpdateWatchdog'

if (-not (Test-Path -LiteralPath $logDir)) {
    New-Item -ItemType Directory -Path $logDir -Force | Out-Null
}

function Write-WatchdogLog {
    param([string]$Message, [ValidateSet('INFO', 'WARN', 'ERROR')] [string]$Level = 'INFO')

    if ((Test-Path -LiteralPath $logPath) -and (Get-Item -LiteralPath $logPath).Length -gt 2MB) {
        Get-Content -LiteralPath $logPath -Tail 500 | Set-Content -LiteralPath $logPath -Encoding UTF8
    }

    Add-Content -LiteralPath $logPath -Value ("{0} {1} {2}" -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), $Level, $Message) -Encoding UTF8
}

function Get-ProcessSnapshot {
    @(Get-CimInstance Win32_Process -ErrorAction SilentlyContinue)
}

function Test-CursorMainRunning {
    param([object[]]$Processes)

    $escapedMainExe = [regex]::Escape($mainExe)
    @($Processes | Where-Object {
        $_.Name -ieq 'Cursor.exe' -and
        $_.ExecutablePath -and
        $_.ExecutablePath -ieq $mainExe -and
        $_.CommandLine -match "^`"?$escapedMainExe`"?\s*$"
    }).Count -gt 0
}

function Get-OrphanedHelperNodes {
    param([object[]]$Processes)

    @($Processes | Where-Object {
        $_.Name -ieq 'node.exe' -and
        $_.ExecutablePath -and
        $_.ExecutablePath.EndsWith($helperNodeSuffix, [System.StringComparison]::OrdinalIgnoreCase) -and
        $_.ExecutablePath.StartsWith($root, [System.StringComparison]::OrdinalIgnoreCase)
    })
}

function Test-CursorUpdaterRunning {
    param([object[]]$Processes)

    @($Processes | Where-Object {
        $name = $_.Name
        $identity = "{0} {1}" -f $_.ExecutablePath, $_.CommandLine
        $name -match '(?i)^inno_updater\.exe$' -or
        ($name -match '(?i)^(CursorSetup.*|Update|setup)\.exe$' -and $identity -match '(?i)cursor')
    }).Count -gt 0
}

function Test-StagedCursorTrusted {
    if (-not (Test-Path -LiteralPath $stagedExe)) {
        return $false
    }

    $signature = Get-AuthenticodeSignature -LiteralPath $stagedExe
    $signer = if ($signature.SignerCertificate) { $signature.SignerCertificate.Subject } else { '' }
    return $signature.Status -eq 'Valid' -and $signer -match 'Anysphere, Inc\.'
}

function Stop-OrphanedHelperNodes {
    param([object[]]$Processes)

    $orphans = @(Get-OrphanedHelperNodes -Processes $Processes)
    foreach ($process in $orphans) {
        Write-WatchdogLog "Encerrando helper orfao PID=$($process.ProcessId) PATH=$($process.ExecutablePath) CMD=$($process.CommandLine)"
        Stop-Process -Id $process.ProcessId -Force -ErrorAction SilentlyContinue
    }

    if ($orphans.Count -gt 0) {
        Start-Sleep -Milliseconds 750
    }

    return $orphans.Count
}

function Repair-AbortedSwap {
    param([object[]]$Processes)

    if ((Test-Path -LiteralPath $mainExe) -or -not (Test-Path -LiteralPath $stagedExe)) {
        return $false
    }

    if (Test-CursorUpdaterRunning -Processes $Processes) {
        return $false
    }

    if (-not (Test-StagedCursorTrusted)) {
        Write-WatchdogLog "Staging recusado: assinatura Authenticode invalida ou signer diferente de Anysphere em $stagedExe" 'ERROR'
        return $false
    }

    Write-WatchdogLog "Swap abortado detectado. Restaurando staging assinado de $stagedRoot para $root."

    foreach ($directory in 'resources', 'locales', 'policies') {
        $path = Join-Path $root $directory
        if (Test-Path -LiteralPath $path) {
            Remove-Item -LiteralPath $path -Recurse -Force
        }
    }

    Get-ChildItem -LiteralPath $stagedRoot -Force | Move-Item -Destination $root -Force
    Remove-Item -LiteralPath $stagedRoot -Force

    if (-not (Test-Path -LiteralPath $mainExe)) {
        throw "Auto-reparo terminou sem restaurar $mainExe"
    }

    $signature = Get-AuthenticodeSignature -LiteralPath $mainExe
    if ($signature.Status -ne 'Valid') {
        throw "Cursor.exe restaurado, mas a assinatura final nao e valida: $($signature.Status)"
    }

    $version = (Get-Item -LiteralPath $mainExe).VersionInfo.ProductVersion
    Write-WatchdogLog "Auto-reparo concluído. Cursor $version restaurado e staging removido."
    return $true
}

function Invoke-WatchdogCycle {
    try {
        if (-not (Test-Path -LiteralPath $root)) {
            return
        }

        $processes = Get-ProcessSnapshot
        if (Test-CursorMainRunning -Processes $processes) {
            return
        }

        [void](Stop-OrphanedHelperNodes -Processes $processes)
        $afterCleanup = Get-ProcessSnapshot
        [void](Repair-AbortedSwap -Processes $afterCleanup)
    }
    catch {
        Write-WatchdogLog $_.Exception.Message 'ERROR'
    }
}

$mutex = $null
$ownsMutex = $false

try {
    if (-not $Once) {
        $mutex = [System.Threading.Mutex]::new($false, $mutexName)
        $ownsMutex = $mutex.WaitOne(0)
        if (-not $ownsMutex) {
            exit 0
        }

        Write-WatchdogLog "Watchdog iniciado. Intervalo=${IntervalSeconds}s; raiz=$root"
    }

    do {
        Invoke-WatchdogCycle
        if (-not $Once) {
            Start-Sleep -Seconds $IntervalSeconds
        }
    } while (-not $Once)
}
finally {
    if ($ownsMutex -and $mutex) {
        $mutex.ReleaseMutex()
    }
    if ($mutex) {
        $mutex.Dispose()
    }
}
