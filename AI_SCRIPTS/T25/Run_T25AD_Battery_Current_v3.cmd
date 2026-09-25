@echo off
setlocal
echo T25AD v3 - TI TPS2116 VIN2 current and collapse-slope probe.
echo This is the next version. Do not rerun the T25AB v2 matrix.
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0T25AD_TPS2116_Battery_Current_Probe_v3.ps1"
echo.
echo Find Datalogger_T25AD_v3_Result_*.zip in Documents and upload it.
pause
