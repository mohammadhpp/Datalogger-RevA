@echo off
setlocal
echo T25D v4 - bounded 10 us TPS631000 PSpice engine smoke
echo The script stops PSpice after at most three minutes and makes a v4 result ZIP.
echo.
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0T25D_PSpice_Converter_Smoke_v4.ps1"
echo.
echo Opening Documents. Upload the newest Datalogger_T25D_v4_Result_*.zip.
powershell.exe -NoProfile -Command "Start-Process explorer.exe -ArgumentList ([Environment]::GetFolderPath('MyDocuments'))"
pause
