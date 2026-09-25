@echo off
setlocal
echo T25AA v1 - actual TI TPS2116 model, controlled USB hard-unplug fixture.
echo Read the generated ZIP path before closing this window.
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0T25AA_TPS2116_Battery_Transfer_v1.ps1"
echo.
echo Look in Documents for Datalogger_T25AA_v1_Result_*.zip
pause
