param(
    [switch]$OpenAfterUpdate
)

$ErrorActionPreference = "Stop"

function Write-Step {
    param([string]$Message)
    Write-Host "[Cursor Update] $Message"
}

function Stop-CursorProcesses {
    $processes = Get-Process -ErrorAction SilentlyContinue | Where-Object {
        $_.ProcessName -match "^(Cursor|cursor|inno_updater)$" -or
        ($_.Path -and $_.Path -match "\\cursor\\")
    }

    if (-not $processes) {
        Write-Step "Nenhum processo do Cursor em execucao."
        return
    }

    foreach ($process in $processes) {
        Write-Step "Encerrando $($process.ProcessName) PID $($process.Id)"
        Stop-Process -Id $process.Id -Force -ErrorAction SilentlyContinue
    }

    Start-Sleep -Seconds 3
}

function Test-UserInstall {
    $cursorExe = Join-Path $env:LOCALAPPDATA "Programs\cursor\Cursor.exe"
    if (-not (Test-Path -LiteralPath $cursorExe)) {
        throw "Instalacao por usuario nao encontrada em $cursorExe"
    }

    $version = (Get-Item -LiteralPath $cursorExe).VersionInfo.ProductVersion
    Write-Step "Cursor por usuario validado: $cursorExe (versao $version)"
    return $cursorExe
}

function Update-UserPath {
    $userBin = Join-Path $env:LOCALAPPDATA "Programs\cursor\resources\app\bin"
    $userPath = [Environment]::GetEnvironmentVariable("Path", "User")
    $entries = @($userPath -split ";" | Where-Object { $_ })

    if ($entries -notcontains $userBin) {
        $entries += $userBin
        [Environment]::SetEnvironmentVariable("Path", ($entries -join ";"), "User")
        Write-Step "PATH de usuario atualizado com $userBin"
    }
    else {
        Write-Step "PATH de usuario ja aponta para o binario correto."
    }

    $machinePath = [Environment]::GetEnvironmentVariable("Path", "Machine")
    if ($machinePath -match [regex]::Escape("C:\Program Files\cursor\resources\app\bin")) {
        Write-Warning "O PATH de maquina ainda contem a instalacao antiga em Program Files. Remova com PowerShell como Administrador: setx /M PATH ""<PATH sem C:\Program Files\cursor\resources\app\bin>"""
    }
}

Write-Step "Fechando processos que podem travar arquivos antigos."
Stop-CursorProcesses

Write-Step "Atualizando Cursor pelo winget no escopo do usuario."
winget upgrade --id Anysphere.Cursor --scope user --silent --accept-package-agreements --accept-source-agreements
if ($LASTEXITCODE -ne 0) {
    Write-Step "Nenhuma atualizacao encontrada ou winget retornou codigo $LASTEXITCODE. Tentando reparar/instalar no escopo do usuario."
    winget install --id Anysphere.Cursor --scope user --force --silent --accept-package-agreements --accept-source-agreements
    if ($LASTEXITCODE -ne 0) {
        throw "winget nao conseguiu atualizar/reparar o Cursor."
    }
}

$cursorExe = Test-UserInstall
Update-UserPath

if ($OpenAfterUpdate) {
    Write-Step "Abrindo Cursor."
    Start-Process -FilePath $cursorExe
}

Write-Step "Finalizado com validacao local."
