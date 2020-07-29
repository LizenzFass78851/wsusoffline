@echo off
rem *** Author: T. Wittrock, Kiel ***
rem ***   - Community Edition -   ***

verify other 2>nul
setlocal enableextensions
if errorlevel 1 goto NoExtensions

cd /D "%~dp0"

set CSCRIPT_PATH=%SystemRoot%\System32\cscript.exe
if not exist %CSCRIPT_PATH% goto NoCScript
if /i "%PROCESSOR_ARCHITECTURE%"=="AMD64" (set WGET_PATH=..\bin\wget64.exe) else (
  if /i "%PROCESSOR_ARCHITEW6432%"=="AMD64" (set WGET_PATH=..\bin\wget64.exe) else (set WGET_PATH=..\bin\wget.exe)
)
if not exist %WGET_PATH% goto NoWGet

set CheckOUVersion_mode=

:EvalParams
if "%1"=="" goto NoMoreParams
if /i "%1"=="/mode:different" set CheckOUVersion_mode=different
if /i "%1"=="/mode:newer" set CheckOUVersion_mode=newer
if /i "%1"=="/mode=different" set CheckOUVersion_mode=different
if /i "%1"=="/mode=newer" set CheckOUVersion_mode=newer
if /i "%1"=="/quiet" set QUIET_MODE=1
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
if "%CheckOUVersion_mode%"=="" goto MissingArgument
if "%QUIET_MODE%"=="1" goto justCheckForUpdates
title Checking WSUS Offline Update - Community Edition - version...
echo Checking WSUS Offline Update - Community Edition - version...
if exist UpdateOU.new (
  if exist UpdateOU.cmd del UpdateOU.cmd
  ren UpdateOU.new UpdateOU.cmd
)
:justCheckForUpdates
if "%QUIET_MODE%"=="1" (
  %WGET_PATH% -q -N -P ..\static https://gitlab.com/wsusoffline/wsusoffline-sdd/-/raw/esr-11.9/SelfUpdateVersion-recent.txt
) else (
  %WGET_PATH% -N -P ..\static https://gitlab.com/wsusoffline/wsusoffline-sdd/-/raw/esr-11.9/SelfUpdateVersion-recent.txt
)
if errorlevel 1 goto DownloadError
if exist ..\static\SelfUpdateVersion-recent.txt (
  echo n | %SystemRoot%\System32\comp.exe ..\static\SelfUpdateVersion-this.txt ..\static\SelfUpdateVersion-recent.txt /A /L /N=1 /C >nul 2>&1
  if not errorlevel 1 goto Result_OK
) else (
  goto DownloadError
)

rem Now compare the versions
set CheckOUVersion_this=
set CheckOUVersion_recent=
for /f "tokens=1 delims=," %%f in (..\static\SelfUpdateVersion-this.txt) do (set CheckOUVersion_this=%%f)
for /f "tokens=1 delims=," %%f in (..\static\SelfUpdateVersion-recent.txt) do (set CheckOUVersion_recent=%%f)
if "%CheckOUVersion_this%"=="" (goto CompError)
if "%CheckOUVersion_recent%"=="" (goto CompError)

%CSCRIPT_PATH% //Nologo //B //E:vbs .\CompareVersions.vbs %CheckOUVersion_this% %CheckOUVersion_recent%
set CheckOUVersion_result=%errorlevel%
if "%CheckOUVersion_result%"=="0" (
  rem %errorlevel%==0 -> equal
  goto Result_OK
) else if "%CheckOUVersion_result%"=="2" (
  rem %errorlevel%==2 -> this > recent
  if "%CheckOUVersion_mode%"=="different" (goto Result_UpdateAvailable) else (goto Result_OK)
) else if "%CheckOUVersion_result%"=="3" (
  rem %errorlevel%==3 -> this < recent
  goto Result_UpdateAvailable
)
rem %errorlevel%==1 -> Error
goto Error

:NoExtensions
if not "%QUIET_MODE%"=="1" (
  echo.
  echo ERROR: No command extensions available.
  echo.
)
exit

:NoCScript
if not "%QUIET_MODE%"=="1" (
  echo.
  echo ERROR: VBScript interpreter %CSCRIPT_PATH% not found.
  echo.
)
goto Error

:NoWGet
if not "%QUIET_MODE%"=="1" (
  echo.
  echo ERROR: Utility %WGET_PATH% not found.
  echo.
)
goto Error

:MissingArgument
if not "%QUIET_MODE%"=="1" (
  echo.
  echo ERROR: Missing argument "/mode:different" or "/mode:newer".
  echo.
)
goto Error

:DownloadError
if not "%QUIET_MODE%"=="1" (
  echo.
  echo ERROR: Download failure for https://gitlab.com/wsusoffline/wsusoffline-sdd/-/raw/esr-11.9/SelfUpdateVersion-recent.txt.
  echo.
)
goto Error

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

:Result_UpdateAvailable
verify other 2>nul
:Result_OK
:EoF
title %ComSpec%
endlocal
