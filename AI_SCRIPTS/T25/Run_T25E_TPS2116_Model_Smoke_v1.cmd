@echo off
setlocal
echo T25E v1 - TPS2116 isolated vendor-model PSpice smoke
echo Process limit: three minutes. Wait for a new T25E v1 result ZIP path.
echo.
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0T25E_TPS2116_Model_Smoke_v1.ps1"
echo.
echo Opening Documents. Upload Datalogger_T25E_v1_Result_*.zip.
powershell.exe -NoProfile -Command "Start-Process explorer.exe -ArgumentList ([Environment]::GetFolderPath('MyDocuments'))"
pause
