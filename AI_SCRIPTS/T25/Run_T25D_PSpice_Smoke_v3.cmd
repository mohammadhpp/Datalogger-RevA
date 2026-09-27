@echo off
setlocal
echo T25D v3 - TPS631000 isolated PSpice smoke test
echo Wait until this window prints the new Datalogger_T25D_v3_Result_*.zip path.
echo.
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0T25D_PSpice_Converter_Smoke_v3.ps1"
echo.
echo Opening your Documents folder. Upload the newest Datalogger_T25D_v3_Result_*.zip.
powershell.exe -NoProfile -Command "Start-Process explorer.exe -ArgumentList ([Environment]::GetFolderPath('MyDocuments'))"
pause
