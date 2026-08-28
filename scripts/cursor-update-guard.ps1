param()

$watchdog = Join-Path $PSScriptRoot 'cursor-update-watchdog.ps1'
& $watchdog -Once
if (-not $?) {
    exit 1
}
exit 0
