@echo off
setlocal
cd /d "%~dp0"
echo T25BB v1 - corrected PSpice 19mA versus 280mA SD capacitor-charge fixture
echo T25BA v1 floating-node failure is fixed. No Altium files are modified.
echo Wait for the RESULT ZIP path even if one or more cases fail.
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0T25BB_PSpice_SD_Charge_19_vs_280_v1.ps1"
echo.
echo Open Documents and upload the new Datalogger_T25BB_v1_Result_*.zip
pause
