# ScreenSavior-AfterPlay

Re-enables the Windows screensaver after games (e.g. Battlefield 6, Battlefield 2042) disable it and do not properly re-enable it.

## How It Works

Some games disable the Windows screensaver while running but fail to re-enable it when you quit. This tool uses the same Windows API as the Settings dialog (`SystemParametersInfo`) to re-arm the screensaver countdown.

## Setup

1. Download or clone this repository to a folder on your PC.
2. Open PowerShell and run the following command from the repository folder to create a desktop shortcut:
   ```powershell
   powershell -ExecutionPolicy Bypass -File create-shortcut.ps1
   ```
3. A **"Fix Screensaver"** shortcut with a monitor icon will appear on your desktop.

## Usage

After closing a game that has broken your screensaver, double-click the **Fix Screensaver** shortcut on your desktop. The script will:

1. Force the screensaver back to **enabled** in the registry and via the Windows API.
2. Toggle the screensaver timeout to force Windows to re-arm its internal countdown.
3. Display the results and automatically close after **10 seconds**.

You can also run the batch file directly:

```
fix-screensaver.bat
```

Or run the PowerShell script directly:

```powershell
powershell -ExecutionPolicy Bypass -File fix-screensaver.ps1
```

## Files

| File | Description |
|---|---|
| `fix-screensaver.ps1` | Main PowerShell script that re-enables the screensaver |
| `fix-screensaver.bat` | Batch wrapper that runs the PowerShell script (auto-closes after 10 seconds) |
| `create-shortcut.ps1` | Creates a desktop shortcut with a monitor icon |
