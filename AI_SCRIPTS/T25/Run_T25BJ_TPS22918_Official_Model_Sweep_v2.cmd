@echo off
setlocal
cd /d "%~dp0"
echo T25BJ v2 - official TI TPS22918 bounded transient sweep
echo No Altium files are modified.
echo Wait for the RESULT ZIP path even if a case fails.
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0T25BJ_TPS22918_Official_Model_Sweep_v2.ps1"
echo.
echo Upload the new Datalogger_T25BJ_Sweep_v2_Result_*.zip
pause
