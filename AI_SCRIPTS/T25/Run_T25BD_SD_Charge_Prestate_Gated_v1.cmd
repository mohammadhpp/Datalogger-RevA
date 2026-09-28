@echo off
setlocal
cd /d "%~dp0"
echo T25BD v1 - PSpice SD charge rerun with explicit precharge and prestate gate
echo No Altium files are modified. Wait for the RESULT ZIP path.
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0T25BD_PSpice_SD_Charge_Prestate_Gated_v1.ps1"
echo.
echo Open Documents and upload the new Datalogger_T25BD_v1_Result_*.zip
pause
