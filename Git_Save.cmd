@echo off
setlocal
title Datalogger Git AutoSave v2.5.1 - One Click Sync

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Git_Save.ps1"
set "RC=%ERRORLEVEL%"

if not "%RC%"=="0" (
  echo.
  echo AutoSave FAILED. Review the message above.
  echo The project was stopped rather than risk an unsafe Git merge.
  echo.
  pause
  exit /b %RC%
)

echo.
echo One-click sync completed. Closing automatically in 2 seconds...
timeout /t 2 /nobreak >nul
exit /b 0
