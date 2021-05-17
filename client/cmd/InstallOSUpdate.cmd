@echo off
rem *** Author: T. Wittrock, Kiel ***
rem ***   - Community Edition -   ***

verify other 2>nul
setlocal enableextensions enabledelayedexpansion
if errorlevel 1 goto NoExtensions

rem clear vars storing parameters
set SELECT_OPTIONS=
set VERIFY_FILES=
set DISM_PROGRESS=
set ERRORS_AS_WARNINGS=
set IGNORE_ERRORS=

set RECALL_REQUIRED=
set REBOOT_REQUIRED=

if "%DIRCMD%" NEQ "" set DIRCMD=
if "%UPDATE_LOGFILE%"=="" set UPDATE_LOGFILE=%SystemRoot%\wsusofflineupdate.log
if "%HASHDEEP_PATH%"=="" (
  if /i "%OS_ARCH%"=="x64" (set HASHDEEP_PATH=..\bin\hashdeep64.exe) else (set HASHDEEP_PATH=..\bin\hashdeep.exe)
)

if '%1'=='' goto NoParam

set FILE_NAME=%1
set "FILE_NAME=!FILE_NAME:"=!"

set SpaceHelper=
:RemoveSpaces
if "%FILE_NAME:~-1%"==" " (
  set FILE_NAME=%FILE_NAME:~0,-1%
  set SpaceHelper=%SpaceHelper% 
  goto RemoveSpaces
)

rem DO NOT CHANGE THE ORDER OF THE CHECKS
if '"%FILE_NAME%"'=='%1' goto FileNameParsed
if not "%SpaceHelper%"=="" if '"%FILE_NAME%%SpaceHelper%"'=='%1' goto FileNameParsed
if '%FILE_NAME%'=='%1' goto FileNameParsed
if not "%SpaceHelper%"=="" if '%FILE_NAME%%SpaceHelper%'=='%1' goto FileNameParsed
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
if /i "%2"=="/showdismprogress" (
  set DISM_PROGRESS=1
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
  if exist ..\md\hashes-%%i.txt (
    %SystemRoot%\System32\findstr.exe /L /I /C:%% /C:## /C:%%j ..\md\hashes-%%i.txt >"%TEMP%\hash-%%i.txt"
    %HASHDEEP_PATH% -a -b -k "%TEMP%\hash-%%i.txt" "%FILE_NAME%"
    if errorlevel 1 (
      if exist "%TEMP%\hash-%%i.txt" del "%TEMP%\hash-%%i.txt"
      goto IntegrityError
    )
    if exist "%TEMP%\hash-%%i.txt" del "%TEMP%\hash-%%i.txt"
    goto SkipVerification
  )
  echo Warning: Hash files ..\md\hashes-%%i-%%j.txt and ..\md\hashes-%%i.txt not found.
  echo %DATE% %TIME% - Warning: Hash files ..\md\hashes-%%i-%%j.txt and ..\md\hashes-%%i.txt not found>>%UPDATE_LOGFILE%
)
:SkipVerification
if "%FILE_NAME:~-4%"==".exe" goto InstExe
if "%FILE_NAME:~-4%"==".msi" goto InstMsi
if "%FILE_NAME:~-4%"==".msu" goto InstMsu
if "%FILE_NAME:~-4%"==".zip" goto InstZip
if "%FILE_NAME:~-4%"==".cab" goto InstCab
goto UnsupType

:InstExe
if "%SELECT_OPTIONS%" NEQ "1" set INSTALL_SWITCHES=%2 %3 %4 %5 %6 %7 %8 %9
if "%INSTALL_SWITCHES%"=="" (
  for /F %%i in (..\opt\OptionList-qn.txt) do (
    echo %FILE_NAME% | %SystemRoot%\System32\find.exe /I "%%i" >nul 2>&1
    if not errorlevel 1 set INSTALL_SWITCHES=/q /norestart
  )
)
if "%INSTALL_SWITCHES%"=="" (
  set INSTALL_SWITCHES=/q /z
)
echo Installing %FILE_NAME%...
"%FILE_NAME%" %INSTALL_SWITCHES%
set ERR_LEVEL=%errorlevel%
rem echo InstallOSUpdate: ERR_LEVEL=%ERR_LEVEL%
if "%ERR_LEVEL%"=="0" (
  goto InstSuccess
) else if "%ERR_LEVEL%"=="1641" (
  set REBOOT_REQUIRED=1
  goto InstSuccess
) else if "%ERR_LEVEL%"=="3010" (
  set REBOOT_REQUIRED=1
  goto InstSuccess
) else if "%ERR_LEVEL%"=="3011" (
  set RECALL_REQUIRED=1
  goto InstSuccess
)
if "%IGNORE_ERRORS%"=="1" goto InstSuccess
goto InstFailure

:InstMsi
echo Installing %FILE_NAME%...
pushd %~dp1
%SystemRoot%\System32\msiexec.exe /i "%FILE_NAME%" /qn /norestart
set ERR_LEVEL=%errorlevel%
rem echo InstallOSUpdate: ERR_LEVEL=%ERR_LEVEL%
popd
if "%ERR_LEVEL%"=="0" (
  goto InstSuccess
) else if "%ERR_LEVEL%"=="1641" (
  set REBOOT_REQUIRED=1
  goto InstSuccess
) else if "%ERR_LEVEL%"=="3010" (
  set REBOOT_REQUIRED=1
  goto InstSuccess
) else if "%ERR_LEVEL%"=="3011" (
  set RECALL_REQUIRED=1
  goto InstSuccess
)
if "%IGNORE_ERRORS%"=="1" goto InstSuccess
goto InstFailure

:InstMsu
echo Installing %FILE_NAME%...
%SystemRoot%\System32\wusa.exe "%FILE_NAME%" /quiet /norestart
set ERR_LEVEL=%errorlevel%
rem echo InstallOSUpdate: ERR_LEVEL=%ERR_LEVEL%
if "%ERR_LEVEL%"=="0" (
  goto InstSuccess
) else if "%ERR_LEVEL%"=="1641" (
  set REBOOT_REQUIRED=1
  goto InstSuccess
) else if "%ERR_LEVEL%"=="3010" (
  set REBOOT_REQUIRED=1
  goto InstSuccess
) else if "%ERR_LEVEL%"=="3011" (
  set RECALL_REQUIRED=1
  goto InstSuccess
) else if "%ERR_LEVEL%"=="2359301" (
  set REBOOT_REQUIRED=1
  goto InstSuccess
) else if "%ERR_LEVEL%"=="2359302" (
  rem "already installed"
  goto InstSuccess
)
if "%IGNORE_ERRORS%"=="1" goto InstSuccess
goto InstFailure

:InstZip
if not exist ..\bin\unzip.exe goto NoUnZip
set FILE_NAME_ONLY=
for /f "tokens=4 delims=\" %%i in ('echo %FILE_NAME%') do (
  if not "%%i"=="" (
    set FILE_NAME_ONLY=%%~ni
  )
)
if "%FILE_NAME_ONLY%"=="" (
  echo ERROR: Extraction of %FILE_NAME% failed
  echo %DATE% %TIME% - Error: Extraction of %FILE_NAME% failed>>%UPDATE_LOGFILE%
  goto InstFailure
)
echo Unpacking %FILE_NAME% to "%TEMP%\%FILE_NAME_ONLY%.msu"...
..\bin\unzip.exe -o -d "%TEMP%" "%FILE_NAME%" "%FILE_NAME_ONLY%.msu"
if not exist "%TEMP%\%FILE_NAME_ONLY%.msu" (
  echo ERROR: Installation file "%TEMP%\%FILE_NAME_ONLY%.msu" not found.
  echo %DATE% %TIME% - Error: Installation file "%TEMP%\%FILE_NAME_ONLY%.msu" not found>>%UPDATE_LOGFILE%
  goto InstFailure
)
echo Installing "%TEMP%\%FILE_NAME_ONLY%.msu"...
%SystemRoot%\System32\wusa.exe "%TEMP%\%FILE_NAME_ONLY%.msu" /quiet /norestart
set ERR_LEVEL=%errorlevel%
rem echo InstallOSUpdate: ERR_LEVEL=%ERR_LEVEL%
del "%TEMP%\%FILE_NAME_ONLY%.msu"
if "%ERR_LEVEL%"=="0" (
  goto InstSuccess
) else if "%ERR_LEVEL%"=="1641" (
  set REBOOT_REQUIRED=1
  goto InstSuccess
) else if "%ERR_LEVEL%"=="3010" (
  set REBOOT_REQUIRED=1
  goto InstSuccess
) else if "%ERR_LEVEL%"=="3011" (
  set RECALL_REQUIRED=1
  goto InstSuccess
)
if "%IGNORE_ERRORS%"=="1" goto InstSuccess
goto InstFailure

:InstCab
if exist %SystemRoot%\Sysnative\Dism.exe goto InstDism
if exist %SystemRoot%\System32\Dism.exe goto InstDism
echo Installing %FILE_NAME%...
set ERR_LEVEL=0
if "%OS_ARCH%"=="x64" (set TOKEN_KB=3) else (set TOKEN_KB=2)
for /F "tokens=%TOKEN_KB% delims=-" %%i in ("%FILE_NAME%") do (
  call SafeRmDir.cmd "%TEMP%\%%i"
  md "%TEMP%\%%i"
  %SystemRoot%\System32\expand.exe "%FILE_NAME%" -F:* "%TEMP%\%%i" >nul
  %SystemRoot%\System32\PkgMgr.exe /ip /m:"%TEMP%\%%i" /quiet /norestart
  set ERR_LEVEL=%errorlevel%
  call SafeRmDir.cmd "%TEMP%\%%i"
)
rem echo InstallOSUpdate: ERR_LEVEL=%ERR_LEVEL%
if "%ERR_LEVEL%"=="0" (
  goto InstSuccess
) else if "%ERR_LEVEL%"=="1641" (
  set REBOOT_REQUIRED=1
  goto InstSuccess
) else if "%ERR_LEVEL%"=="3010" (
  set REBOOT_REQUIRED=1
  goto InstSuccess
) else if "%ERR_LEVEL%"=="3011" (
  set RECALL_REQUIRED=1
  goto InstSuccess
)
if "%IGNORE_ERRORS%"=="1" goto InstSuccess
goto InstFailure

:InstDism
if "%DISM_PROGRESS%" NEQ "1" set DISM_QPARAM=/Quiet
if "%OS_NAME%"=="w100" (
  if exist %SystemRoot%\Sysnative\Dism.exe (
    for /F "tokens=3" %%i in ('%SystemRoot%\Sysnative\Dism.exe /Online /Get-PackageInfo /PackagePath:"%FILE_NAME%" /English ^| %SystemRoot%\System32\find.exe /I "Applicable"') do (
      if /i "%%i"=="No" goto InstSkipped
    )
  ) else (
    for /F "tokens=3" %%i in ('%SystemRoot%\System32\Dism.exe /Online /Get-PackageInfo /PackagePath:"%FILE_NAME%" /English ^| %SystemRoot%\System32\find.exe /I "Applicable"') do (
      if /i "%%i"=="No" goto InstSkipped
    )
  )
)
echo Installing %FILE_NAME%...
if exist %SystemRoot%\Sysnative\Dism.exe (
  %SystemRoot%\Sysnative\Dism.exe /Online %DISM_QPARAM% /NoRestart /Add-Package /PackagePath:"%FILE_NAME%" /IgnoreCheck
) else (
  %SystemRoot%\System32\Dism.exe /Online %DISM_QPARAM% /NoRestart /Add-Package /PackagePath:"%FILE_NAME%" /IgnoreCheck
)
set ERR_LEVEL=%errorlevel%
rem echo InstallOSUpdate: ERR_LEVEL=%ERR_LEVEL%
if "%ERR_LEVEL%"=="0" (
  goto InstSuccess
) else if "%ERR_LEVEL%"=="1641" (
  set REBOOT_REQUIRED=1
  goto InstSuccess
) else if "%ERR_LEVEL%"=="3010" (
  set REBOOT_REQUIRED=1
  goto InstSuccess
) else if "%ERR_LEVEL%"=="3011" (
  set RECALL_REQUIRED=1
  goto InstSuccess
)
if "%IGNORE_ERRORS%"=="1" goto InstSuccess
goto InstFailure

:NoExtensions
echo ERROR: No command extensions available.
goto Error

:NoParam
echo ERROR: Invalid parameter. Usage: %~n0 ^<filename^> [/selectoptions] [/verify] [/errorsaswarnings] [/ignoreerrors] [switches]
echo %DATE% %TIME% - Error: Invalid parameter. Usage: %~n0 ^<filename^> [/selectoptions] [/verify] [/errorsaswarnings] [/ignoreerrors] [switches]>>%UPDATE_LOGFILE%
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

:UnsupType
echo ERROR: Unsupported file type (%FILE_NAME%).
echo %DATE% %TIME% - Error: Unsupported file type (%FILE_NAME%)>>%UPDATE_LOGFILE%
goto InstFailure

:NoUnZip
echo ERROR: Utility ..\bin\unzip.exe not found.
echo %DATE% %TIME% - Error: Utility ..\bin\unzip.exe not found>>%UPDATE_LOGFILE%
goto InstFailure

:IntegrityError
echo ERROR: File hash does not match stored value (%FILE_NAME%).
echo %DATE% %TIME% - Error: File hash does not match stored value (%FILE_NAME%)>>%UPDATE_LOGFILE%
goto InstFailure

:InstSkipped
echo Skipped inapplicable %FILE_NAME%.
echo %DATE% %TIME% - Info: Skipped inapplicable %FILE_NAME%>>%UPDATE_LOGFILE%
goto EoF

:InstSuccess
echo %DATE% %TIME% - Info: Installed %FILE_NAME%>>%UPDATE_LOGFILE%
goto EoF

:InstFailure
if "%IGNORE_ERRORS%"=="1" goto EoF
if "%ERRORS_AS_WARNINGS%"=="1" (goto InstWarning) else (goto InstError)

:InstWarning
echo Warning: Installation of %FILE_NAME% failed (errorlevel: %ERR_LEVEL%).
echo %DATE% %TIME% - Warning: Installation of %FILE_NAME% %INSTALL_SWITCHES% failed (errorlevel: %ERR_LEVEL%)>>%UPDATE_LOGFILE%
goto EoF

:InstError
echo ERROR: Installation of %FILE_NAME% failed (errorlevel: %ERR_LEVEL%).
echo %DATE% %TIME% - Error: Installation of %FILE_NAME% %INSTALL_SWITCHES% failed (errorlevel: %ERR_LEVEL%)>>%UPDATE_LOGFILE%
goto Error

:Error
endlocal
exit /b 1

:EoF
if "%RECALL_REQUIRED%"=="1" (
  endlocal
  exit /b 3011
) else if "%REBOOT_REQUIRED%"=="1" (
  endlocal
  exit /b 3010
) else (
  endlocal
  exit /b 0
)
