@echo off
setlocal
title T25AK v1 - Altium model diagnostic
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0T25AK_Altium_Model_Diagnostic_v1.ps1"
if errorlevel 1 echo T25AK preparation FAILED; see PowerShell error above.
echo Press any key to close this preparation window.
pause >nul
