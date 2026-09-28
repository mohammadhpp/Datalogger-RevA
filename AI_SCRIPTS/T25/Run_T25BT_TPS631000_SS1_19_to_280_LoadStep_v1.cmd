@echo off
setlocal
cd /d "%~dp0"
echo T25BT - official TPS631000 SS=1 / 19mA to total 280mA
echo Put official TI SLVMDV2.ZIP in Downloads if it is not already there.
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0T25BT_TPS631000_SS1_19_to_280_LoadStep_v1.ps1"
echo.
echo Upload Datalogger_T25BT_v1_Result_*.zip
pause
