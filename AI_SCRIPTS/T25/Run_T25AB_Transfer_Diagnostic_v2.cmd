@echo off
setlocal
echo T25AB v2 - diagnostic TI TPS2116 model matrix; bounded runtime.
echo Use this version for the new run. Do not rerun T25AA v1.
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0T25AB_TPS2116_Transfer_Diagnostic_v2.ps1"
echo.
echo Find Datalogger_T25AB_v2_Result_*.zip in Documents and upload it.
pause
