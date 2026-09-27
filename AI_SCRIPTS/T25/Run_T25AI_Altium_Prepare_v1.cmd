@echo off
setlocal
title T25AI v1 - Prepare Altium power-path test netlists
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0T25AI_Prepare_Altium_MixedSim_v1.ps1"
if errorlevel 1 echo T25AI preparation FAILED; see PowerShell error above.
echo Press any key to close this preparation window.
pause >nul
