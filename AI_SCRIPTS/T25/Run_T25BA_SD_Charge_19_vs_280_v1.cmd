@echo off
setlocal
cd /d "%~dp0"
echo T25BA v1 - PSpice 19mA versus 280mA SD capacitor-charge fixture
echo No Altium files are modified. Wait for the RESULT ZIP path.
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0T25BA_PSpice_SD_Charge_19_vs_280_v1.ps1"
echo.
echo Open Documents and upload the new Datalogger_T25BA_v1_Result_*.zip
pause
