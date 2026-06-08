# Migração: Documents\Cursor -> ~/.cursor
# Manual:  powershell -ExecutionPolicy Bypass -File "$env:USERPROFILE\Documents\Cursor\scripts\migrate-from-documents.ps1"
# Agendado: Task Scheduler \Febracis-Cursor-SyncDaily

param(
    [switch]$Quiet
)

$ErrorActionPreference = "Stop"
$src = Join-Path $env:USERPROFILE "Documents\Cursor"
$dst = Join-Path $env:USERPROFILE ".cursor"
$logDir = Join-Path $env:LOCALAPPDATA "febracis-logs"
$logPath = Join-Path $logDir "cursor-sync.log"

$dirs = @(
    "skills",
    "commands",
    "rules",
    "hooks",
    "profiles",
    "cybersecurity-skills",
    "scientific-skills",
    "data"
)

function Write-SyncLog {
    param([string]$Message, [string]$Color = "White")
    $line = "{0} {1}" -f (Get-Date -Format "yyyy-MM-dd HH:mm:ss"), $Message
    if (-not (Test-Path -LiteralPath $logDir)) {
        New-Item -ItemType Directory -Path $logDir -Force | Out-Null
    }
    Add-Content -LiteralPath $logPath -Value $line -Encoding UTF8
    if (-not $Quiet) {
        Write-Host $Message -ForegroundColor $Color
    }
}

try {
    Write-SyncLog "--- sync start ---" "Cyan"

    foreach ($d in $dirs) {
        $s = Join-Path $src $d
        $t = Join-Path $dst $d
        if (-not (Test-Path $s)) {
            Write-SyncLog "[$d] origem ausente: $s" "Yellow"
            continue
        }

        New-Item -ItemType Directory -Force -Path $t | Out-Null

        $robocopyArgs = @($s, $t, "/E", "/NFL", "/NDL", "/NJH", "/NJS", "/nc", "/ns", "/np")
        if ($d -eq "hooks") {
            $robocopyArgs += "/XD", ".omc"
        }

        & robocopy @robocopyArgs | Out-Null
        $exit = $LASTEXITCODE
        if ($exit -ge 8) { throw "robocopy falhou para $d (exit $exit)" }
        Write-SyncLog "[$d] OK (robocopy exit $exit)" "Green"
    }

    Copy-Item -Force (Join-Path $src "HARNESS.md") (Join-Path $dst "HARNESS.md")
    Write-SyncLog "[HARNESS.md] OK" "Green"

    $hooksJsonSrc = Join-Path $src "hooks\hooks.json"
    $hooksJsonDst = Join-Path $dst "hooks.json"
    if (Test-Path $hooksJsonSrc) {
        Copy-Item -Force $hooksJsonSrc $hooksJsonDst
        Write-SyncLog "[hooks.json] OK" "Green"
    } else {
        Write-SyncLog "[hooks.json] origem ausente" "Yellow"
    }

    $configPath = Join-Path $dst "config.json"
    if (-not (Test-Path $configPath)) {
        Copy-Item -Force (Join-Path $src "config.json") $configPath
    }

    $config = Get-Content $configPath -Raw | ConvertFrom-Json
    $config.data_dir = ".cursor/data"
    $config.skill_ecosystems.custom = ".cursor/skills/"
    $config.skill_ecosystems.cybersecurity = ".cursor/cybersecurity-skills/skills/"
    $config.skill_ecosystems.scientific = ".cursor/scientific-skills/skills/"
    $config.skill_ecosystems.commands = ".cursor/commands/"
    $config | Add-Member -NotePropertyName "paths" -NotePropertyValue ([pscustomobject]@{
        rules    = ".cursor/rules/"
        hooks    = ".cursor/hooks/"
        profiles = ".cursor/profiles/"
    }) -Force
    $config | ConvertTo-Json -Depth 10 | Set-Content $configPath -Encoding UTF8
    Write-SyncLog "[config.json] OK" "Green"

    Write-SyncLog "--- verificacao ---" "Cyan"
    foreach ($d in $dirs) {
        $t = Join-Path $dst $d
        if (Test-Path $t) {
            $c = (Get-ChildItem $t -Recurse -File | Measure-Object).Count
            Write-SyncLog "$d : $c arquivos"
        }
    }

    $skillCount = @(Get-ChildItem (Join-Path $dst "skills") -Directory -ErrorAction SilentlyContinue).Count
    Write-SyncLog "skills (pastas): $skillCount"
    Write-SyncLog "config.json: $(Test-Path $configPath)"
    Write-SyncLog "hooks.json: $(Test-Path $hooksJsonDst)"
    Write-SyncLog "HARNESS.md: $(Test-Path (Join-Path $dst 'HARNESS.md'))"
    Write-SyncLog "sync concluido" "Green"
}
catch {
    Write-SyncLog "ERRO: $($_.Exception.Message)" "Red"
    throw
}
