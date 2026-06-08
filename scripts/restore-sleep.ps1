# Restore normal sleep behavior after long-running task completes
# Usage: powershell -ExecutionPolicy Bypass -File restore-sleep.ps1

Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
public class SleepRestore {
    [DllImport("kernel32.dll", CharSet = CharSet.Auto, SetLastError = true)]
    public static extern uint SetThreadExecutionState(uint esFlags);
    public const uint ES_CONTINUOUS = 0x80000000;
}
"@

[SleepRestore]::SetThreadExecutionState([SleepRestore]::ES_CONTINUOUS) | Out-Null
Write-Host "Sleep prevention DISABLED - normal power policy restored"
