@echo off
rem *** Author: T. Wittrock, Kiel ***

verify other 2>nul
setlocal enableextensions enabledelayedexpansion
if errorlevel 1 goto NoExtensions

if "%DIRCMD%" NEQ "" set DIRCMD=

cd /D "%~dp0"

set DOWNLOAD_LOGFILE=..\log\download.log
if exist %DOWNLOAD_LOGFILE% (
  echo.>>%DOWNLOAD_LOGFILE%
  echo -------------------------------------------------------------------------------->>%DOWNLOAD_LOGFILE%
  echo.>>%DOWNLOAD_LOGFILE%
)
echo %DATE% %TIME% - Info: Starting WSUS Offline Update - Community Edition - self update>>%DOWNLOAD_LOGFILE%

if /i "%PROCESSOR_ARCHITECTURE%"=="AMD64" (set WGET_PATH=..\bin\wget64.exe) else (
  if /i "%PROCESSOR_ARCHITEW6432%"=="AMD64" (set WGET_PATH=..\bin\wget64.exe) else (set WGET_PATH=..\bin\wget.exe)
)
if not exist %WGET_PATH% goto NoWGet
if not exist ..\bin\unzip.exe goto NoUnZip
if /i "%PROCESSOR_ARCHITECTURE%"=="AMD64" (set HASHDEEP_EXE=hashdeep64.exe) else (
  if /i "%PROCESSOR_ARCHITEW6432%"=="AMD64" (set HASHDEEP_EXE=hashdeep64.exe) else (set HASHDEEP_EXE=hashdeep.exe)
)
if not exist ..\client\bin\%HASHDEEP_EXE% goto NoHashDeep

:EvalParams
if "%1"=="" goto NoMoreParams
if /i "%1"=="/restartgenerator" set RESTART_GENERATOR=1
if /i "%1"=="/proxy" (
  set http_proxy=%2
  set https_proxy=%2
  shift /1
)
shift /1
goto EvalParams

:NoMoreParams
rem *** Update WSUS Offline Update - Community Edition ***
title Updating WSUS Offline Update - Community Edition...
call CheckOUVersion.cmd /mode:newer
if not errorlevel 1 goto NoNewVersion
if not exist ..\static\SelfUpdateVersion-recent.txt goto DownloadError
echo Downloading most recent released version of WSUS Offline Update - Community Edition...
%WGET_PATH% -N -P ..\static --no-check-certificate https://gitlab.com/wsusoffline/wsusoffline-sdd/-/raw/master/StaticDownloadLink-recent.txt
if errorlevel 1 goto DownloadError
if not exist ..\static\StaticDownloadLink-recent.txt goto DownloadError
%WGET_PATH% -N -P .. --no-check-certificate -i ..\static\StaticDownloadLink-recent.txt
if errorlevel 1 goto DownloadError
if not exist ..\static\StaticDownloadLink-recent.txt goto DownloadError
echo %DATE% %TIME% - Info: Downloaded most recent released version of WSUS Offline Update - Community Edition>>%DOWNLOAD_LOGFILE%
set FILENAME_ZIP=empty
set FILENAME_HASH=empty
for /F "tokens=2,3 delims=," %%a in (..\static\SelfUpdateVersion-recent.txt) do (
  if not "%%a"=="" (
    if not "%%b"=="" (
      set FILENAME_ZIP=%%a
      set FILENAME_HASH=%%b
    )
  )
)
if "%FILENAME_ZIP%"=="empty" goto DownloadError
if "%FILENAME_HASH%"=="empty" goto DownloadError
%WGET_PATH% -N -P .. --no-check-certificate -i ..\static\StaticDownloadLink-recent.txt
echo %DATE% %TIME% - Info: Downloaded most recent released version of WSUS Offline Update - Community Edition>>%DOWNLOAD_LOGFILE%
pushd ..
echo Verifying integrity of %FILENAME_ZIP%...
.\client\bin\%HASHDEEP_EXE% -a -l -vv -k %FILENAME_HASH% %FILENAME_ZIP%
if errorlevel 1 (
  popd
  goto IntegrityError
)
popd
echo %DATE% %TIME% - Info: Verified integrity of %FILENAME_ZIP%>>%DOWNLOAD_LOGFILE%
echo Unpacking %FILENAME_ZIP%...
if exist ..\wsusoffline\nul rd /S /Q ..\wsusoffline
..\bin\unzip.exe -uq ..\%FILENAME_ZIP% -d ..
echo %DATE% %TIME% - Info: Unpacked %FILENAME_ZIP%>>%DOWNLOAD_LOGFILE%
del ..\%FILENAME_ZIP%
echo %DATE% %TIME% - Info: Deleted %FILENAME_ZIP%>>%DOWNLOAD_LOGFILE%
del ..\%FILENAME_HASH%
echo %DATE% %TIME% - Info: Deleted %FILENAME_HASH%>>%DOWNLOAD_LOGFILE%
echo Preserving custom language and architecture additions and removals...
set REMOVE_CMD=
%SystemRoot%\System32\find.exe /I "-deu." ..\static\StaticDownloadLinks-dotnet.txt >nul 2>&1
if errorlevel 1 (
  set REMOVE_CMD=RemoveGermanLanguageSupport.cmd !REMOVE_CMD!
)
set CUST_LANG=
if exist ..\static\custom\StaticDownloadLinks-dotnet.txt (
  for %%i in (fra esn jpn kor rus ptg ptb nld ita chs cht plk hun csy sve trk ell ara heb dan nor fin) do (
    %SystemRoot%\System32\find.exe /I "%%i" ..\static\custom\StaticDownloadLinks-dotnet.txt >nul 2>&1
    if not errorlevel 1 (
      set CUST_LANG=%%i !CUST_LANG!
      call RemoveCustomLanguageSupport.cmd %%i /quiet
    )
  )
)
set OX64_LANG=
for %%i in (enu fra esn jpn kor rus ptg ptb deu nld ita chs cht plk hun csy sve trk ell ara heb dan nor fin) do (
  if exist ..\static\custom\StaticDownloadLinks-o2k13-%%i.txt (
    set OX64_LANG=%%i !OX64_LANG!
    call RemoveOffice2010x64Support.cmd %%i /quiet
  )
)
echo %DATE% %TIME% - Info: Preserved custom language and architecture additions and removals>>%DOWNLOAD_LOGFILE%
echo Updating WSUS Offline Update - Community Edition...
%SystemRoot%\System32\xcopy.exe ..\wsusoffline .. /S /Q /Y
rd /S /Q ..\wsusoffline
echo %DATE% %TIME% - Info: Updated WSUS Offline Update - Community Edition>>%DOWNLOAD_LOGFILE%
echo Restoring custom language and architecture additions and removals...
if "%REMOVE_CMD%" NEQ "" (
  for %%i in (%REMOVE_CMD%) do call %%i /quiet
)
if "%CUST_LANG%" NEQ "" (
  for %%i in (%CUST_LANG%) do call AddCustomLanguageSupport.cmd %%i /quiet
)
if "%OX64_LANG%" NEQ "" (
  for %%i in (%OX64_LANG%) do call AddOffice2010x64Support.cmd %%i /quiet
)
echo %DATE% %TIME% - Info: Restored custom language and architecture additions and removals>>%DOWNLOAD_LOGFILE%
if exist ..\exclude\ExcludeList-superseded.txt (
  del ..\exclude\ExcludeList-superseded.txt
  echo %DATE% %TIME% - Info: Deleted deprecated list of superseded updates>>%DOWNLOAD_LOGFILE%
)
if exist ..\static\sdd\StaticDownloadFiles-modified.txt (
  del ..\static\sdd\StaticDownloadFiles-modified.txt
)
if exist ..\static\sdd\ExcludeDownloadFiles-modified.txt (
  del ..\static\sdd\ExcludeDownloadFiles-modified.txt
)
if exist ..\static\sdd\StaticUpdateFiles-modified.txt (
  del ..\static\sdd\StaticUpdateFiles-modified.txt
)
echo %DATE% %TIME% - Info: Ending WSUS Offline Update - Community Edition - self update>>%DOWNLOAD_LOGFILE%
if "%RESTART_GENERATOR%"=="1" (
  cd ..
  start UpdateGenerator.exe
  exit
)
goto EoF

:NoExtensions
echo.
echo ERROR: No command extensions available.
echo.
exit

:NoWGet
echo.
echo ERROR: Download utility %WGET_PATH% not found.
echo %DATE% %TIME% - Error: Download utility %WGET_PATH% not found>>%DOWNLOAD_LOGFILE%
echo.
goto EoF

:NoUnZip
echo.
echo ERROR: Utility ..\bin\unzip.exe not found.
echo %DATE% %TIME% - Error: Utility ..\bin\unzip.exe not found>>%DOWNLOAD_LOGFILE%
echo.
goto EoF

:NoHashDeep
echo.
echo ERROR: Hash computing/auditing utility ..\client\bin\%HASHDEEP_EXE% not found.
echo %DATE% %TIME% - Error: Hash computing/auditing utility ..\client\bin\%HASHDEEP_EXE% not found>>%DOWNLOAD_LOGFILE%
echo.
goto EoF

:NoNewVersion
echo.
echo Info: No new version of WSUS Offline Update - Community Edition - found.
echo %DATE% %TIME% - Info: No new version of WSUS Offline Update - Community Edition - found>>%DOWNLOAD_LOGFILE%
echo.
goto EoF

:DownloadError
echo.
echo ERROR: Download of most recent released version of WSUS Offline Update - Community Edition - failed.
echo %DATE% %TIME% - Error: Download of most recent released version of WSUS Offline Update - Community Edition - failed>>%DOWNLOAD_LOGFILE%
echo.
goto EoF

:IntegrityError
echo.
echo ERROR: File integrity verification of most recent released version of WSUS Offline Update - Community Edition - failed.
echo %DATE% %TIME% - Error: File integrity verification of most recent released version of WSUS Offline Update - Community Edition - failed>>%DOWNLOAD_LOGFILE%
echo.
goto EoF

:EoF
title %ComSpec%
endlocal
