@echo off
setlocal
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0T25D_PSpice_Converter_Smoke_v1.ps1"
echo.
echo Upload the resulting Datalogger_T25D_Result_*.zip from Documents.
pause
