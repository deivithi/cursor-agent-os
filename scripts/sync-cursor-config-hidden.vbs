Set shell = CreateObject("WScript.Shell")
scriptPath = CreateObject("Scripting.FileSystemObject").BuildPath(CreateObject("WScript.Shell").ExpandEnvironmentStrings("%USERPROFILE%"), "Documents\Cursor\scripts\migrate-from-documents.ps1")
command = "powershell.exe -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File """ & scriptPath & """ -Quiet"
shell.Run command, 0, False
