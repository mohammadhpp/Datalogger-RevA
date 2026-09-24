@echo off
setlocal
echo T25G v1 - isolated TPS2116 priority-mode fixture
echo The source ramp and small resistor are test fixtures, not board measurements.
echo Wait for the new T25G v1 ZIP path. The PSpice child has a three-minute limit.
echo.
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0T25G_TPS2116_Priority_Fixture_v1.ps1"
echo.
echo Opening Documents. Upload the newest Datalogger_T25G_v1_Result_*.zip.
powershell.exe -NoProfile -Command "Start-Process explorer.exe -ArgumentList ([Environment]::GetFolderPath('MyDocuments'))"
pause
