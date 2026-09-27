@echo off
setlocal
cd /d "%~dp0"
echo T25R v1 - official TDK capacitor model audit
echo Wait for RESULT ZIP path; upload that ZIP for exact model review.
echo This does not edit Altium files or run PSpice.
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0T25R_TDK_Capacitor_Model_Audit_v1.ps1"
echo.
pause
