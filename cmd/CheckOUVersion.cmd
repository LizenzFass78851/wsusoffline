@echo off
rem *** Author: T. Wittrock, Kiel ***
rem ***   - Community Edition -   ***

verify other 2>nul
setlocal enableextensions
if errorlevel 1 goto NoExtensions

cd /D "%~dp0"

if /i "%PROCESSOR_ARCHITECTURE%"=="AMD64" (set WGET_PATH=..\bin\wget64.exe) else (
  if /i "%PROCESSOR_ARCHITEW6432%"=="AMD64" (set WGET_PATH=..\bin\wget64.exe) else (set WGET_PATH=..\bin\wget.exe)
)
if not exist %WGET_PATH% goto NoWGet

:EvalParams
if "%1"=="" goto NoMoreParams
if /i "%1"=="/quiet" set QUIET_MODE=1
if /i "%1"=="/exitonerror" set EXIT_ERR=1
if /i "%1"=="/proxy" (
  set http_proxy=%2
  set https_proxy=%2
  shift /1
)
shift /1
goto EvalParams

:NoMoreParams
rem *** Check WSUS Offline Update - Community Edition - version ***
if "%QUIET_MODE%"=="1" goto justCheckForUpdates
title Checking WSUS Offline Update - Community Edition - version...
echo Checking WSUS Offline Update - Community Edition - version...
if exist UpdateOU.new (
  if exist UpdateOU.cmd del UpdateOU.cmd
  ren UpdateOU.new UpdateOU.cmd
)
:justCheckForUpdates
if "%QUIET_MODE%"=="1" (
  %WGET_PATH% -q -N -P ..\static --no-check-certificate https://gitlab.com/wsusoffline/wsusoffline-sdd/-/raw/master/SelfUpdateVersion-recent.txt
) else (
  %WGET_PATH% -N -P ..\static --no-check-certificate https://gitlab.com/wsusoffline/wsusoffline-sdd/-/raw/master/SelfUpdateVersion-recent.txt
)
if errorlevel 1 goto DownloadError
if exist ..\static\SelfUpdateVersion-recent.txt (
  echo n | %SystemRoot%\System32\comp.exe ..\static\SelfUpdateVersion-this.txt ..\static\SelfUpdateVersion-recent.txt /A /L /N=1 /C >nul 2>&1
  if errorlevel 1 goto CompError
)
goto EoF

:NoExtensions
if not "%QUIET_MODE%"=="1" (
  echo.
  echo ERROR: No command extensions available.
  echo.
)
exit

:NoWGet
if not "%QUIET_MODE%"=="1" (
  echo.
  echo ERROR: Utility %WGET_PATH% not found.
  echo.
)
goto EoF

:DownloadError
if not "%QUIET_MODE%"=="1" (
  echo.
  echo ERROR: Download failure for https://gitlab.com/wsusoffline/wsusoffline-sdd/-/raw/master/SelfUpdateVersion-recent.txt.
  echo.
)
goto EoF

:CompError
if not "%QUIET_MODE%"=="1" (
  echo.
  echo Warning: File ..\static\SelfUpdateVersion-this.txt differs from file ..\static\SelfUpdateVersion-recent.txt.
  echo.
)
goto Error

:Error
if "%EXIT_ERR%"=="1" (
  endlocal
  verify other 2>nul
  exit
) else (
  title %ComSpec%
  endlocal
  verify other 2>nul
  goto :eof
)

:EoF
title %ComSpec%
endlocal
