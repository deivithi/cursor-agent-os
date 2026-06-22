param(
  [switch]$VerboseLog
)

$ErrorActionPreference = "Stop"

$logDir = Join-Path $env:LOCALAPPDATA "febracis-logs"
$logPath = Join-Path $logDir "cursor-update-guard.log"
$cursorExe = Join-Path $env:LOCALAPPDATA "Programs\cursor\Cursor.exe"

if (-not (Test-Path -LiteralPath $logDir)) {
  New-Item -ItemType Directory -Path $logDir -Force | Out-Null
}

function Write-GuardLog {
  param([string]$Message)
  $line = "{0} {1}" -f (Get-Date -Format "yyyy-MM-dd HH:mm:ss"), $Message
  Add-Content -LiteralPath $logPath -Value $line -Encoding UTF8
}

if ($VerboseLog) {
  Write-GuardLog "DISABLED: Cursor UpdateGuard is no-op. Cursor updates are managed by the native User updater. Expected install: $cursorExe"
}

exit 0
