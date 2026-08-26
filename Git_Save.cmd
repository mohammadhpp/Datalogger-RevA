@echo off
title Datalogger Git AutoSave v2.3
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Git_Save.ps1"
set "RC=%ERRORLEVEL%"

if not "%RC%"=="0" (
  echo.
  echo AutoSave FAILED. Review the message above.
  echo.
  pause
  exit /b %RC%
)

echo.
echo Closing automatically in 2 seconds...
timeout /t 2 /nobreak >nul
exit /b 0
