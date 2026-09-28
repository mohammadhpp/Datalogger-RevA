@echo off
setlocal
cd /d "%~dp0"
echo T25BF v1 - official TI TPS631000 precharged short-window load-step
echo Two cases, up to 240 seconds each. No Altium files are modified.
echo Wait for the RESULT ZIP path even if a case is incomplete.
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0T25BF_TPS631000_Precharged_LoadStep_v1.ps1"
echo.
echo Open Documents and upload the new Datalogger_T25BF_v1_Result_*.zip
pause
