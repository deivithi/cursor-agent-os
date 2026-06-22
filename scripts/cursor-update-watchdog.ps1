param(
  [int]$IntervalSeconds = 5
)

$ErrorActionPreference = "Stop"

$logDir = Join-Path $env:LOCALAPPDATA "febracis-logs"
$logPath = Join-Path $logDir "cursor-update-watchdog.log"
$cursorExe = Join-Path $env:LOCALAPPDATA "Programs\cursor\Cursor.exe"

if (-not (Test-Path -LiteralPath $logDir)) {
  New-Item -ItemType Directory -Path $logDir -Force | Out-Null
}

$line = "{0} DISABLED: Cursor UpdateWatchdog is no-op. Cursor updates are managed by the native User updater. Expected install: {1}" -f (Get-Date -Format "yyyy-MM-dd HH:mm:ss"), $cursorExe
Add-Content -LiteralPath $logPath -Value $line -Encoding UTF8

exit 0
