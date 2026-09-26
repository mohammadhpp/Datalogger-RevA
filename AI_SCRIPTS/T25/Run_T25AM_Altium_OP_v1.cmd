@echo off
setlocal
echo T25AM v1 - TPS2116 Altium operating-point isolation
echo This prepares two short netlists; it does not change CAD or run Altium.
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0T25AM_Altium_OP_Isolation_v1.ps1"
if errorlevel 1 (
    echo T25AM PREPARATION FAILED. Copy the PowerShell error before closing.
) else (
    echo Open the new folder in Documents. Run file 06 first in Altium.
    echo Only if 06 fails, run 07. Share Messages and waveform result.
)
pause
endlocal
