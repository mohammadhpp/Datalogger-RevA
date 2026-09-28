@echo off
setlocal
cd /d "%~dp0"
echo T25BJ v1 - official TI TPS22918 model-package preflight
echo No PSpice simulation and no Altium files are modified.
echo The script downloads SLVMBI6 from TI unless it already exists in Downloads.
echo Wait for the RESULT ZIP path.
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0T25BJ_TPS22918_Model_Preflight_v1.ps1"
echo.
echo Upload the new Datalogger_T25BJ_Model_Preflight_v1_Result_*.zip
pause
