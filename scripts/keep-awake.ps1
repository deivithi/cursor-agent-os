# Keep-Awake: Prevent system sleep during long-running Claude Code tasks
# Usage: powershell -ExecutionPolicy Bypass -File keep-awake.ps1
# Restore: powershell -ExecutionPolicy Bypass -File restore-sleep.ps1

Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
public class SleepPrevention {
    [DllImport("kernel32.dll", CharSet = CharSet.Auto, SetLastError = true)]
    public static extern uint SetThreadExecutionState(uint esFlags);

    public const uint ES_CONTINUOUS = 0x80000000;
    public const uint ES_SYSTEM_REQUIRED = 0x00000001;
    public const uint ES_DISPLAY_REQUIRED = 0x00000002;
}
"@

$result = [SleepPrevention]::SetThreadExecutionState(
    [SleepPrevention]::ES_CONTINUOUS -bor
    [SleepPrevention]::ES_SYSTEM_REQUIRED -bor
    [SleepPrevention]::ES_DISPLAY_REQUIRED
)

if ($result -ne 0) {
    Write-Host "Sleep prevention ACTIVE - system will stay awake"
} else {
    Write-Host "ERROR: Failed to set execution state" -ForegroundColor Red
    exit 1
}
