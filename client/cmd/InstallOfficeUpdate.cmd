@echo off
rem *** Author: T. Wittrock, Kiel ***
rem ***   - Community Edition -   ***

verify other 2>nul
setlocal enableextensions enabledelayedexpansion
if errorlevel 1 goto NoExtensions

rem clear vars storing parameters
set SELECT_OPTIONS=
set VERIFY_FILES=
set ERRORS_AS_WARNINGS=
set IGNORE_ERRORS=

if "%DIRCMD%" NEQ "" set DIRCMD=
if "%UPDATE_LOGFILE%"=="" set UPDATE_LOGFILE=%SystemRoot%\wsusofflineupdate.log
if "%HASHDEEP_PATH%"=="" (
  if /i "%OS_ARCH%"=="x64" (set HASHDEEP_PATH=..\bin\hashdeep64.exe) else (set HASHDEEP_PATH=..\bin\hashdeep.exe)
)

if '%1'=='' goto NoParam

set FILE_NAME=%1
set "FILE_NAME=!FILE_NAME:"=!"

set SpaceCounter=0
:RemoveSpaces
if "%FILE_NAME:~-1%"==" " (
  set FILE_NAME=%FILE_NAME:~0,-1%
  set /a SpaceCounter+=1
  goto RemoveSpaces
)

set SpaceHelper=
for /l %%i in (1,1,%SpaceCounter%) do (
  set SpaceHelper=%SpaceHelper% 
)

rem DO NOT CHANGE THE ORDER OF THE CHECKS
if '"%FILE_NAME%"'=='%1' goto FileNameParsed
if '"%FILE_NAME%%SpaceHelper%"'=='%1' goto FileNameParsed
if '%FILE_NAME%'=='%1' goto FileNameParsed
if '%FILE_NAME%%SpaceHelper%'=='%1' goto FileNameParsed
goto InvalidParam
:FileNameParsed
if not exist "%FILE_NAME%" goto ParamFileNotFound

if "%TEMP%"=="" goto NoTemp
pushd "%TEMP%"
if errorlevel 1 goto NoTempDir
popd

:EvalParams
if "%2"=="" goto NoMoreParams
if /i "%2"=="/selectoptions" (
  set SELECT_OPTIONS=1
  shift /2
  goto EvalParams
)
if /i "%2"=="/verify" (
  set VERIFY_FILES=1
  shift /2
  goto EvalParams
)
if /i "%2"=="/errorsaswarnings" (
  set ERRORS_AS_WARNINGS=1
  shift /2
  goto EvalParams
)
if /i "%2"=="/ignoreerrors" (
  set IGNORE_ERRORS=1
  shift /2
  goto EvalParams
)

:NoMoreParams
if "%VERIFY_FILES%" NEQ "1" goto SkipVerification
if not exist %HASHDEEP_PATH% (
  echo Warning: Hash computing/auditing utility %HASHDEEP_PATH% not found.
  echo %DATE% %TIME% - Warning: Hash computing/auditing utility %HASHDEEP_PATH% not found>>%UPDATE_LOGFILE%
  goto SkipVerification
)
echo Verifying integrity of %FILE_NAME%...
for /F "tokens=2,3,4 delims=\" %%i in ("%FILE_NAME%") do (
  if exist ..\md\hashes-%%i-%%j.txt (
    %SystemRoot%\System32\findstr.exe /L /I /C:%% /C:## /C:%%k ..\md\hashes-%%i-%%j.txt >"%TEMP%\hash-%%i-%%j.txt"
    %HASHDEEP_PATH% -a -b -k "%TEMP%\hash-%%i-%%j.txt" "%FILE_NAME%"
    if errorlevel 1 (
      if exist "%TEMP%\hash-%%i-%%j.txt" del "%TEMP%\hash-%%i-%%j.txt"
      goto IntegrityError
    )
    if exist "%TEMP%\hash-%%i-%%j.txt" del "%TEMP%\hash-%%i-%%j.txt"
    goto SkipVerification
  )
  echo Warning: Hash file ..\md\hashes-%%i-%%j.txt not found.
  echo %DATE% %TIME% - Warning: Hash file ..\md\hashes-%%i-%%j.txt not found>>%UPDATE_LOGFILE%
)
:SkipVerification
if "%FILE_NAME:~-4%"==".exe" goto InstExe
if "%FILE_NAME:~-4%"==".cab" goto InstCab
if "%FILE_NAME:~-4%"==".msp" goto InstMsp
goto UnsupType

:InstExe
rem *** Check proper Office version ***
for %%i in (o2k13 o2k16) do (
  echo %FILE_NAME% | %SystemRoot%\System32\find.exe /I "\%%i\" >nul 2>&1
  if not errorlevel 1 goto %%i
)
goto UnsupVersion

:o2k13
:o2k16
echo Installing %FILE_NAME%...
echo %FILE_NAME% | %SystemRoot%\System32\find.exe /I "sp" >nul 2>&1
if errorlevel 1 ("%FILE_NAME%" /quiet /norestart) else ("%FILE_NAME%" /passive /norestart)
set ERR_LEVEL=%errorlevel%
if "%IGNORE_ERRORS%"=="1" goto InstSuccess
for %%i in (0 1641 3010 3011) do if %ERR_LEVEL% EQU %%i goto InstSuccess
goto InstFailure

:InstCab
echo Installing %FILE_NAME%...
set ERR_LEVEL=0
for /F "tokens=3 delims=\." %%i in ("%FILE_NAME%") do (
  call SafeRmDir.cmd "%TEMP%\%%i"
  md "%TEMP%\%%i"
  %SystemRoot%\System32\expand.exe -R "%FILE_NAME%" -F:* "%TEMP%\%%i" >nul
  for /F %%j in ('dir /A:-D /B "%TEMP%\%%i\*.msp"') do %SystemRoot%\System32\msiexec.exe /qn /norestart /update "%TEMP%\%%i\%%j"
  set ERR_LEVEL=%errorlevel%
  call SafeRmDir.cmd "%TEMP%\%%i"
)
if "%IGNORE_ERRORS%"=="1" goto InstSuccess
for %%i in (0 1641 3010 3011) do if %ERR_LEVEL% EQU %%i goto InstSuccess
goto InstFailure

:InstMsp
echo Installing %FILE_NAME%...
set ERR_LEVEL=0
%SystemRoot%\System32\msiexec.exe /qn /norestart /update "%FILE_NAME%"
set ERR_LEVEL=%errorlevel%
if "%IGNORE_ERRORS%"=="1" goto InstSuccess
for %%i in (0 1641 3010 3011) do if %ERR_LEVEL% EQU %%i goto InstSuccess
goto InstFailure

:NoExtensions
echo ERROR: No command extensions available.
goto Error

:NoParam
echo ERROR: Invalid parameter. Usage: %~n0 ^<filename^> [/selectoptions] [/verify] [/errorsaswarnings] [/ignoreerrors]
echo %DATE% %TIME% - Error: Invalid parameter. Usage: %~n0 ^<filename^> [/selectoptions] [/verify] [/errorsaswarnings] [/ignoreerrors]>>%UPDATE_LOGFILE%
goto Error

:InvalidParam
echo ERROR: Invalid file %FILE_NAME%
echo %DATE% %TIME% - Error: Invalid file %FILE_NAME%>>%UPDATE_LOGFILE%
goto Error

:ParamFileNotFound
echo ERROR: File %FILE_NAME% not found.
echo %DATE% %TIME% - Error: File %FILE_NAME% not found>>%UPDATE_LOGFILE%
goto Error

:NoTemp
echo ERROR: Environment variable TEMP not set.
echo %DATE% %TIME% - Error: Environment variable TEMP not set>>%UPDATE_LOGFILE%
goto Error

:NoTempDir
echo ERROR: Directory "%TEMP%" not found.
echo %DATE% %TIME% - Error: Directory "%TEMP%" not found>>%UPDATE_LOGFILE%
goto Error

:UnsupVersion
echo ERROR: Unsupported Office version.
echo %DATE% %TIME% - Error: Unsupported Office version>>%UPDATE_LOGFILE%
goto Error

:UnsupType
echo ERROR: Unsupported file type (file: %FILE_NAME%).
echo %DATE% %TIME% - Error: Unsupported file type (file: %FILE_NAME%)>>%UPDATE_LOGFILE%
goto InstFailure

:IntegrityError
echo ERROR: File hash does not match stored value (file: %FILE_NAME%).
echo %DATE% %TIME% - Error: File hash does not match stored value (file: %FILE_NAME%)>>%UPDATE_LOGFILE%
goto InstFailure

:InstSuccess
echo %DATE% %TIME% - Info: Installed %FILE_NAME%>>%UPDATE_LOGFILE%
goto EoF

:InstFailure
if "%ERRORS_AS_WARNINGS%"=="1" (goto InstWarning) else (goto InstError)

:InstWarning
echo Warning: Installation of %FILE_NAME% failed (errorlevel: %ERR_LEVEL%).
echo %DATE% %TIME% - Warning: Installation of %FILE_NAME% failed (errorlevel: %ERR_LEVEL%)>>%UPDATE_LOGFILE%
goto EoF

:InstError
echo ERROR: Installation of %FILE_NAME% failed (errorlevel: %ERR_LEVEL%).
echo %DATE% %TIME% - Error: Installation of %FILE_NAME% failed (errorlevel: %ERR_LEVEL%)>>%UPDATE_LOGFILE%
goto Error

:Error
endlocal
exit /b 1

:EoF
endlocal
exit /b 0
