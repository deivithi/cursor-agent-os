param(
  [switch]$VerboseLog
)

$ErrorActionPreference = "Stop"

$cursorProgramRoot = Join-Path $env:LOCALAPPDATA "Programs\cursor"
$cursorResourcesRoots = @(
  (Join-Path $cursorProgramRoot "resources"),
  (Join-Path $cursorProgramRoot "_\resources")
)
$logDir = Join-Path $env:LOCALAPPDATA "febracis-logs"
$logPath = Join-Path $logDir "cursor-update-guard.log"

if (-not (Test-Path -LiteralPath $logDir)) {
  New-Item -ItemType Directory -Path $logDir -Force | Out-Null
}

function Write-GuardLog {
  param([string]$Message)
  $line = "{0} {1}" -f (Get-Date -Format "yyyy-MM-dd HH:mm:ss"), $Message
  Add-Content -LiteralPath $logPath -Value $line -Encoding UTF8
}

function Test-IsCursorWindowRunning {
  $cursorProcesses = Get-CimInstance Win32_Process |
    Where-Object {
      $_.Name -ieq "Cursor.exe"
    }

  return [bool]$cursorProcesses
}

function Get-CursorResourceProcesses {
  Get-CimInstance Win32_Process | Where-Object {
    $process = $_
    foreach ($root in $cursorResourcesRoots) {
      if (
        ($process.ExecutablePath -and $process.ExecutablePath -like "$root*") -or
        ($process.CommandLine -and $process.CommandLine -like "*$root*")
      ) {
        return $true
      }
    }
    return $false
  }
}

if (-not (Test-Path -LiteralPath $cursorProgramRoot)) {
  if ($VerboseLog) { Write-GuardLog "Cursor program root not found: $cursorProgramRoot" }
  exit 0
}

if (Test-IsCursorWindowRunning) {
  if ($VerboseLog) { Write-GuardLog "Cursor.exe is running; guard skipped." }
  exit 0
}

$orphaned = @(Get-CursorResourceProcesses)

if ($orphaned.Count -eq 0) {
  if ($VerboseLog) { Write-GuardLog "No orphaned Cursor resource processes found." }
  exit 0
}

foreach ($process in $orphaned) {
  try {
    Stop-Process -Id $process.ProcessId -Force
    Write-GuardLog ("Stopped orphaned process PID={0} Name={1} Path={2}" -f $process.ProcessId, $process.Name, $process.ExecutablePath)
  } catch {
    Write-GuardLog ("FAILED to stop PID={0} Name={1}: {2}" -f $process.ProcessId, $process.Name, $_.Exception.Message)
  }
}
