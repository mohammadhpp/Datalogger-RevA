@echo off
setlocal
cd /d "%~dp0"
echo T25BQ v1 - official TI TPS54202 model package preflight
echo No PSpice run. No Altium/BOM changes.
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0T25BQ_TPS54202_Model_Preflight_v1.ps1"
echo.
echo Upload Datalogger_T25BQ_Model_Preflight_v1_Result_*.zip
pause
