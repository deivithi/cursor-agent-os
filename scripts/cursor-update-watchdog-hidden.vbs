Set shell = CreateObject("WScript.Shell")
scriptPath = "C:\Users\deivithi.lopes\Documents\Cursor\scripts\cursor-update-watchdog.ps1"
command = "powershell.exe -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File """ & scriptPath & """ -IntervalSeconds 5"
shell.Run command, 0, False
