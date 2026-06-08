Set shell = CreateObject("WScript.Shell")
scriptPath = "C:\Users\deivithi.lopes\Documents\Cursor\scripts\cursor-update-guard.ps1"
command = "powershell.exe -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File """ & scriptPath & """"
shell.Run command, 0, False
