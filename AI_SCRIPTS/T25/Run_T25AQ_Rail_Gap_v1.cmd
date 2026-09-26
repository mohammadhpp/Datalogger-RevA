@echo off
setlocal
echo T25AQ v1 - bounded PSpice 3V3 / SD / OLED rail-gap scenarios.
echo Run this after Git_Save.cmd has fetched the new files.
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0T25AQ_Rail_Gap_PSpice_v1.ps1"
echo.
echo Upload the Datalogger_T25AQ_v1_Result_*.zip from Documents.
pause
