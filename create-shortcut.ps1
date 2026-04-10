# Creates a desktop shortcut for fix-screensaver.bat with a monitor icon

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$batPath   = Join-Path $scriptDir "fix-screensaver.bat"
$desktop   = [Environment]::GetFolderPath("Desktop")
$lnkPath   = Join-Path $desktop "Fix Screensaver.lnk"

$shell    = New-Object -ComObject WScript.Shell
$shortcut = $shell.CreateShortcut($lnkPath)
$shortcut.TargetPath       = $batPath
$shortcut.WorkingDirectory = $scriptDir
$shortcut.IconLocation     = "imageres.dll,139"   # monitor/display icon
$shortcut.Description      = "Re-arm Windows screensaver after games disable it"
$shortcut.Save()

Write-Host "Shortcut created: $lnkPath" -ForegroundColor Green
