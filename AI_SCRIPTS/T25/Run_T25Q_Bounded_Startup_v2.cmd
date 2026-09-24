@echo off
setlocal
echo T25Q v2 - TPS631000 bounded full-startup feasibility gate
echo No Altium design files will be modified. Wait for the result ZIP path.
echo.
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0T25Q_Bounded_Startup_v2.ps1"
echo.
echo Open Documents to find Datalogger_T25Q_v2_Result_*.zip
powershell.exe -NoProfile -Command "Start-Process explorer.exe -ArgumentList ([Environment]::GetFolderPath('MyDocuments'))"
pause
