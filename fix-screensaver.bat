@echo off
REM Fix Screensaver - Batch Wrapper
powershell.exe -ExecutionPolicy Bypass -File "%~dp0fix-screensaver.ps1"
timeout /t 10
