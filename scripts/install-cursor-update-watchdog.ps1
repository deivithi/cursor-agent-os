param()

$ErrorActionPreference = 'Stop'

$taskName = 'Febracis-Cursor-UpdateWatchdog'
$legacyTaskNames = @('Cursor-Update-Guard', 'Febracis-Cursor-UpdateGuard', $taskName)
$launcher = Join-Path $PSScriptRoot 'cursor-update-watchdog-hidden.vbs'
$watchdog = Join-Path $PSScriptRoot 'cursor-update-watchdog.ps1'

foreach ($path in @($launcher, $watchdog)) {
    if (-not (Test-Path -LiteralPath $path)) {
        throw "Arquivo obrigatório não encontrado: $path"
    }
}

foreach ($legacyTaskName in $legacyTaskNames) {
    if (Get-ScheduledTask -TaskName $legacyTaskName -ErrorAction SilentlyContinue) {
        Stop-ScheduledTask -TaskName $legacyTaskName -ErrorAction SilentlyContinue
    }
}

$existingWatchdogs = @(Get-CimInstance Win32_Process -ErrorAction SilentlyContinue | Where-Object {
    $_.Name -ieq 'powershell.exe' -and $_.CommandLine -like '*-File*cursor-update-watchdog.ps1*'
})
foreach ($existingWatchdog in $existingWatchdogs) {
    Stop-Process -Id $existingWatchdog.ProcessId -Force -ErrorAction SilentlyContinue
}
if ($existingWatchdogs.Count -gt 0) {
    Start-Sleep -Seconds 2
}

foreach ($legacyTaskName in $legacyTaskNames) {
    if (Get-ScheduledTask -TaskName $legacyTaskName -ErrorAction SilentlyContinue) {
        Unregister-ScheduledTask -TaskName $legacyTaskName -Confirm:$false
    }
}

$action = New-ScheduledTaskAction -Execute "$env:WINDIR\System32\wscript.exe" -Argument "//B //Nologo `"$launcher`""
$trigger = New-ScheduledTaskTrigger -AtLogOn -User $env:USERNAME
$settings = New-ScheduledTaskSettingsSet `
    -AllowStartIfOnBatteries `
    -DontStopIfGoingOnBatteries `
    -StartWhenAvailable `
    -MultipleInstances IgnoreNew `
    -ExecutionTimeLimit ([TimeSpan]::Zero) `
    -RestartCount 999 `
    -RestartInterval (New-TimeSpan -Minutes 1)
$principal = New-ScheduledTaskPrincipal -UserId "$env:USERDOMAIN\$env:USERNAME" -LogonType Interactive -RunLevel Limited

Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Settings $settings -Principal $principal -Description 'Watchdog invisível do Cursor: remove helper node.exe órfão e conclui swap assinado após update abortado.' -Force | Out-Null
Start-ScheduledTask -TaskName $taskName
Start-Sleep -Seconds 3

$task = Get-ScheduledTask -TaskName $taskName
$info = Get-ScheduledTaskInfo -TaskName $taskName
$process = Get-CimInstance Win32_Process | Where-Object {
    $_.Name -ieq 'powershell.exe' -and $_.CommandLine -like '*cursor-update-watchdog.ps1*'
}

if ($task.State -ne 'Running' -or -not $process) {
    throw "Watchdog não permaneceu ativo. State=$($task.State); ProcessCount=$(@($process).Count); LastTaskResult=$($info.LastTaskResult)"
}

[pscustomobject]@{
    TaskName = $taskName
    State = $task.State
    LastTaskResult = $info.LastTaskResult
    WatchdogPid = @($process.ProcessId) -join ','
    Launcher = $launcher
}
