# Fix Screensaver Script
# Uses SystemParametersInfo (same API as the Settings dialog) to re-arm
# winlogon.exe's screensaver countdown after games disable it.

Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;

public class WinAPI {
    [DllImport("user32.dll", SetLastError = true)]
    public static extern bool SystemParametersInfo(uint uiAction, uint uiParam, ref uint pvParam, uint fWinIni);

    [DllImport("user32.dll", SetLastError = true)]
    public static extern bool SystemParametersInfo(uint uiAction, uint uiParam, IntPtr pvParam, uint fWinIni);
}
"@

# Win32 constants
$SPI_GETSCREENSAVETIMEOUT = 14
$SPI_SETSCREENSAVETIMEOUT = 15
$SPI_SETSCREENSAVEACTIVE  = 17
$SPIF_UPDATEINIFILE_SENDCHANGE = 3   # SPIF_UPDATEINIFILE | SPIF_SENDCHANGE

$regPath = "HKCU:\Control Panel\Desktop"

Write-Host "Fixing screensaver settings..." -ForegroundColor Cyan

# --- Informational: show current registry values ---
$regActive  = (Get-ItemProperty -Path $regPath -Name "ScreenSaveActive"  -ErrorAction SilentlyContinue).ScreenSaveActive
$regTimeout = (Get-ItemProperty -Path $regPath -Name "ScreenSaveTimeOut" -ErrorAction SilentlyContinue).ScreenSaveTimeOut
Write-Host "Registry  ScreenSaveActive : $regActive"  -ForegroundColor Yellow
Write-Host "Registry  ScreenSaveTimeOut: $regTimeout seconds" -ForegroundColor Yellow

# --- Step 1: Force registry ScreenSaveActive = 1 ---
Set-ItemProperty -Path $regPath -Name "ScreenSaveActive" -Value "1"

# --- Step 2: Tell winlogon the screensaver is enabled via API ---
$ok = [WinAPI]::SystemParametersInfo($SPI_SETSCREENSAVEACTIVE, 1, [IntPtr]::Zero, $SPIF_UPDATEINIFILE_SENDCHANGE)
if (-not $ok) {
    $err = [System.Runtime.InteropServices.Marshal]::GetLastWin32Error()
    Write-Host "ERROR: SPI_SETSCREENSAVEACTIVE failed (Win32 error $err)" -ForegroundColor Red
    exit 1
}
Write-Host "Screensaver enabled via API." -ForegroundColor Yellow

# --- Step 3: Read the current in-memory timeout ---
[uint32]$currentTimeout = 0
$ok = [WinAPI]::SystemParametersInfo($SPI_GETSCREENSAVETIMEOUT, 0, [ref]$currentTimeout, 0)
if (-not $ok) {
    $err = [System.Runtime.InteropServices.Marshal]::GetLastWin32Error()
    Write-Host "ERROR: SPI_GETSCREENSAVETIMEOUT failed (Win32 error $err)" -ForegroundColor Red
    exit 1
}
Write-Host "In-memory timeout         : $currentTimeout seconds" -ForegroundColor Yellow

# --- Step 4: Toggle timeout +60s then restore to force countdown re-arm ---
$tempTimeout = $currentTimeout + 60
Write-Host "Setting temporary timeout : $tempTimeout seconds..." -ForegroundColor Yellow
$ok = [WinAPI]::SystemParametersInfo($SPI_SETSCREENSAVETIMEOUT, $tempTimeout, [IntPtr]::Zero, $SPIF_UPDATEINIFILE_SENDCHANGE)
if (-not $ok) {
    $err = [System.Runtime.InteropServices.Marshal]::GetLastWin32Error()
    Write-Host "ERROR: SPI_SETSCREENSAVETIMEOUT (+60) failed (Win32 error $err)" -ForegroundColor Red
    exit 1
}

Start-Sleep -Milliseconds 500

Write-Host "Restoring original timeout: $currentTimeout seconds..." -ForegroundColor Yellow
$ok = [WinAPI]::SystemParametersInfo($SPI_SETSCREENSAVETIMEOUT, $currentTimeout, [IntPtr]::Zero, $SPIF_UPDATEINIFILE_SENDCHANGE)
if (-not $ok) {
    $err = [System.Runtime.InteropServices.Marshal]::GetLastWin32Error()
    Write-Host "ERROR: SPI_SETSCREENSAVETIMEOUT (restore) failed (Win32 error $err)" -ForegroundColor Red
    exit 1
}

# --- Step 5: Verify ---
[uint32]$finalTimeout = 0
[WinAPI]::SystemParametersInfo($SPI_GETSCREENSAVETIMEOUT, 0, [ref]$finalTimeout, 0) | Out-Null
Write-Host "Final in-memory timeout   : $finalTimeout seconds" -ForegroundColor Yellow

Write-Host "`nScreensaver settings have been refreshed!" -ForegroundColor Green
Write-Host "Your screensaver should now activate after $finalTimeout seconds of inactivity." -ForegroundColor Green
