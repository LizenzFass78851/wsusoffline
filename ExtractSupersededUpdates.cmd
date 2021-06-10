@echo off
rem *** Author: H. Buhrmester & aker ***

setlocal enabledelayedexpansion

if /i "%PROCESSOR_ARCHITECTURE%"=="AMD64" (set WGET_PATH=.\bin\wget64.exe) else (
  if /i "%PROCESSOR_ARCHITEW6432%"=="AMD64" (set WGET_PATH=.\bin\wget64.exe) else (set WGET_PATH=.\bin\wget.exe)
)
if not exist %WGET_PATH% goto EoF

if not exist "%TEMP%\package.xml" (
  set PREEXISTING_PACKAGE_XML=0
  if not exist "%TEMP%\wsusscn2.cab" (
    %WGET_PATH% -N -i .\static\StaticDownloadLinks-wsus.txt -P "%TEMP%"
  )
  if exist "%TEMP%\package.cab" del "%TEMP%\package.cab"
  %SystemRoot%\System32\expand.exe "%TEMP%\wsusscn2.cab" -F:package.cab "%TEMP%"
  %SystemRoot%\System32\expand.exe "%TEMP%\package.cab" "%TEMP%\package.xml"
  del "%TEMP%\package.cab"
) else (
  set PREEXISTING_PACKAGE_XML=1
)

rem *** Determine superseded updates ***
echo %TIME% - Determining superseded updates...

rem *** Revised part for determination of superseded updates starts here ***

rem ** Preparation ***
echo Extracting revision-and-update-ids.txt...
%SystemRoot%\System32\cscript.exe //Nologo //B //E:vbs .\cmd\XSLT.vbs "%TEMP%\package.xml" .\xslt\extract-revision-and-update-ids.xsl "%TEMP%\revision-and-update-ids-unsorted.txt"
.\bin\gsort.exe -u -T "%TEMP%" "%TEMP%\revision-and-update-ids-unsorted.txt" > "%TEMP%\revision-and-update-ids.txt"
rem del "%TEMP%\revision-and-update-ids-unsorted.txt"
echo Extracting BundledUpdateRevisionAndFileIds.txt...
%SystemRoot%\System32\cscript.exe //Nologo //B //E:vbs .\cmd\XSLT.vbs "%TEMP%\package.xml" .\xslt\extract-update-revision-and-file-ids.xsl "%TEMP%\BundledUpdateRevisionAndFileIds-unsorted.txt"
.\bin\gsort.exe -u -T "%TEMP%" "%TEMP%\BundledUpdateRevisionAndFileIds-unsorted.txt" > "%TEMP%\BundledUpdateRevisionAndFileIds.txt"
rem del "%TEMP%\BundledUpdateRevisionAndFileIds-unsorted.txt"
echo Extracting UpdateCabExeIdsAndLocations.txt...
%SystemRoot%\System32\cscript.exe //Nologo //B //E:vbs .\cmd\XSLT.vbs "%TEMP%\package.xml" .\xslt\extract-update-cab-exe-ids-and-locations.xsl "%TEMP%\UpdateCabExeIdsAndLocations-unsorted.txt"
.\bin\gsort.exe -u -T "%TEMP%" "%TEMP%\UpdateCabExeIdsAndLocations-unsorted.txt" > "%TEMP%\UpdateCabExeIdsAndLocations.txt"
rem del "%TEMP%\UpdateCabExeIdsAndLocations-unsorted.txt"
echo Creating file-and-update-ids.txt...
.\bin\join.exe -t "," -o "2.3,1.2" "%TEMP%\revision-and-update-ids.txt" "%TEMP%\BundledUpdateRevisionAndFileIds.txt" > "%TEMP%\file-and-update-ids-unsorted.txt"
.\bin\gsort.exe -u -T "%TEMP%" "%TEMP%\file-and-update-ids-unsorted.txt" > "%TEMP%\file-and-update-ids.txt"
rem del "%TEMP%\revision-and-update-ids.txt"
rem del "%TEMP%\file-and-update-ids-unsorted.txt"
echo Creating update-ids-and-locations.txt...
.\bin\join.exe -t "," -o "1.2,2.2" "%TEMP%\file-and-update-ids.txt" "%TEMP%\UpdateCabExeIdsAndLocations.txt" > "%TEMP%\update-ids-and-locations-unsorted.txt"
.\bin\gsort.exe -u -T "%TEMP%" "%TEMP%\update-ids-and-locations-unsorted.txt" > "%TEMP%\update-ids-and-locations.txt"
rem del "%TEMP%\file-and-update-ids.txt"
rem del "%TEMP%\update-ids-and-locations-unsorted.txt"
echo Creating UpdateTable-all.csv...
%SystemRoot%\System32\cscript.exe //Nologo //B //E:vbs .\cmd\ExtractIdsAndFileNames.vbs "%TEMP%\update-ids-and-locations.txt" "%TEMP%\UpdateTable-all.csv"
rem del "%TEMP%\update-ids-and-locations.txt"

rem *** First step ***
echo Extracting existing-bundle-revision-ids.txt...
%SystemRoot%\System32\cscript.exe //Nologo //B //E:vbs .\cmd\XSLT.vbs "%TEMP%\package.xml" .\xslt\extract-existing-bundle-revision-ids.xsl "%TEMP%\existing-bundle-revision-ids-unsorted.txt"
.\bin\gsort.exe -u -T "%TEMP%" "%TEMP%\existing-bundle-revision-ids-unsorted.txt" >"%TEMP%\existing-bundle-revision-ids.txt"
rem del "%TEMP%\existing-bundle-revision-ids-unsorted.txt"
echo Extracting superseding-and-superseded-revision-ids.txt...
%SystemRoot%\System32\cscript.exe //Nologo //B //E:vbs .\cmd\XSLT.vbs "%TEMP%\package.xml" .\xslt\extract-superseding-and-superseded-revision-ids.xsl "%TEMP%\superseding-and-superseded-revision-ids-unsorted.txt"
.\bin\gsort.exe -u -T "%TEMP%" "%TEMP%\superseding-and-superseded-revision-ids-unsorted.txt" >"%TEMP%\superseding-and-superseded-revision-ids.txt"
rem del "%TEMP%\superseding-and-superseded-revision-ids-unsorted.txt"
echo Joining existing-bundle-revision-ids.txt and superseding-and-superseded-revision-ids.txt to ValidSupersededRevisionIds.txt...
.\bin\join.exe -t "," -o "2.2" "%TEMP%\existing-bundle-revision-ids.txt" "%TEMP%\superseding-and-superseded-revision-ids.txt" >"%TEMP%\ValidSupersededRevisionIds-unsorted.txt"
.\bin\gsort.exe -u -T "%TEMP%" "%TEMP%\ValidSupersededRevisionIds-unsorted.txt" >"%TEMP%\ValidSupersededRevisionIds.txt"
rem del "%TEMP%\superseding-and-superseded-revision-ids.txt"
rem del "%TEMP%\ValidSupersededRevisionIds-unsorted.txt"

rem *** Second step ***
rem echo Extracting BundledUpdateRevisionAndFileIds.txt...
rem %SystemRoot%\System32\cscript.exe //Nologo //B //E:vbs .\cmd\XSLT.vbs "%TEMP%\package.xml" .\xslt\extract-update-revision-and-file-ids.xsl "%TEMP%\BundledUpdateRevisionAndFileIds-unsorted.txt"
rem .\bin\gsort.exe -u -T "%TEMP%" "%TEMP%\BundledUpdateRevisionAndFileIds-unsorted.txt" >"%TEMP%\BundledUpdateRevisionAndFileIds.txt"
rem rem del "%TEMP%\BundledUpdateRevisionAndFileIds-unsorted.txt"
echo Joining ValidSupersededRevisionIds.txt and BundledUpdateRevisionAndFileIds.txt to SupersededFileIds.txt...
.\bin\join.exe -t "," -o "2.3" "%TEMP%\ValidSupersededRevisionIds.txt" "%TEMP%\BundledUpdateRevisionAndFileIds.txt" >"%TEMP%\SupersededFileIds-unsorted.txt"
.\bin\gsort.exe -u -T "%TEMP%" "%TEMP%\SupersededFileIds-unsorted.txt" >"%TEMP%\SupersededFileIds.txt"
rem del "%TEMP%\SupersededFileIds-unsorted.txt"
echo Creating ValidNonSupersededRevisionIds.txt...
%SystemRoot%\System32\findstr.exe /L /I /V /G:"%TEMP%\ValidSupersededRevisionIds.txt" "%TEMP%\existing-bundle-revision-ids.txt" > "%TEMP%\ValidNonSupersededRevisionIds-unsorted.txt"
.\bin\gsort.exe -u -T "%TEMP%" "%TEMP%\ValidNonSupersededRevisionIds-unsorted.txt" >"%TEMP%\ValidNonSupersededRevisionIds.txt"
rem del "%TEMP%\existing-bundle-revision-ids.txt"
rem del "%TEMP%\ValidSupersededRevisionIds.txt"
rem del "%TEMP%\ValidNonSupersededRevisionIds-unsorted.txt"
echo Joining ValidNonSupersededRevisionIds.txt and BundledUpdateRevisionAndFileIds.txt to NonSupersededFileIds.txt...
.\bin\join.exe -t "," -o "2.3" "%TEMP%\ValidNonSupersededRevisionIds.txt" "%TEMP%\BundledUpdateRevisionAndFileIds.txt" >"%TEMP%\NonSupersededFileIds-unsorted.txt"
.\bin\gsort.exe -u -T "%TEMP%" "%TEMP%\NonSupersededFileIds-unsorted.txt" >"%TEMP%\NonSupersededFileIds.txt"
rem del "%TEMP%\BundledUpdateRevisionAndFileIds.txt"
rem del "%TEMP%\ValidNonSupersededRevisionIds.txt"
rem del "%TEMP%\NonSupersededFileIds-unsorted.txt"
echo Creating OnlySupersededFileIds.txt...
%SystemRoot%\System32\findstr.exe /L /I /V /G:"%TEMP%\NonSupersededFileIds.txt" "%TEMP%\SupersededFileIds.txt" >"%TEMP%\OnlySupersededFileIds-unsorted.txt"
.\bin\gsort.exe -u -T "%TEMP%" "%TEMP%\OnlySupersededFileIds-unsorted.txt" >"%TEMP%\OnlySupersededFileIds.txt"
rem del "%TEMP%\NonSupersededFileIds.txt"
rem del "%TEMP%\SupersededFileIds.txt"
rem del "%TEMP%\OnlySupersededFileIds-unsorted.txt"

rem *** Third step ***
rem echo Extracting UpdateCabExeIdsAndLocations.txt...
rem %SystemRoot%\System32\cscript.exe //Nologo //B //E:vbs .\cmd\XSLT.vbs "%TEMP%\package.xml" .\xslt\extract-update-cab-exe-ids-and-locations.xsl "%TEMP%\UpdateCabExeIdsAndLocations-unsorted.txt"
rem .\bin\gsort.exe -u -T "%TEMP%" "%TEMP%\UpdateCabExeIdsAndLocations-unsorted.txt" >"%TEMP%\UpdateCabExeIdsAndLocations.txt"
rem rem del "%TEMP%\UpdateCabExeIdsAndLocations-unsorted.txt"
echo Joining OnlySupersededFileIds.txt and UpdateCabExeIdsAndLocations.txt to ExcludeList-superseded-all.txt...
.\bin\join.exe -t "," -o "2.2" "%TEMP%\OnlySupersededFileIds.txt" "%TEMP%\UpdateCabExeIdsAndLocations.txt" >"%TEMP%\ExcludeList-superseded-all-unsorted.txt"
.\bin\gsort.exe -u -T "%TEMP%" "%TEMP%\ExcludeList-superseded-all-unsorted.txt" >"%TEMP%\ExcludeList-superseded-all.txt"
rem del "%TEMP%\OnlySupersededFileIds.txt"
rem del "%TEMP%\UpdateCabExeIdsAndLocations.txt"
rem del "%TEMP%\ExcludeList-superseded-all-unsorted.txt"

rem del "%TEMP%\UpdateTable-all.csv"

rem *** Apply ExcludeList-superseded-exclude.txt ***
if exist .\exclude\ExcludeList-superseded-exclude.txt copy /Y .\exclude\ExcludeList-superseded-exclude.txt "%TEMP%\ExcludeList-superseded-exclude.txt" >nul
if exist .\exclude\custom\ExcludeList-superseded-exclude.txt (
  type .\exclude\custom\ExcludeList-superseded-exclude.txt >>"%TEMP%\ExcludeList-superseded-exclude.txt"
)
for %%i in (upd1 upd2) do (
  for /F %%j in ('type .\client\static\StaticUpdateIds-w63-%%i.txt ^| find /i "kb"') do (
    echo windows8.1-%%j>>"%TEMP%\ExcludeList-superseded-exclude.txt"
  )
)
for %%i in ("%TEMP%\ExcludeList-superseded-exclude.txt") do if %%~zi==0 del %%i
if exist "%TEMP%\ExcludeList-superseded-exclude.txt" (
  %SystemRoot%\System32\findstr.exe /L /I /V /G:"%TEMP%\ExcludeList-superseded-exclude.txt" "%TEMP%\ExcludeList-superseded-all.txt" >"%TEMP%\ExcludeList-superseded.txt"
) else (
  copy /Y "%TEMP%\ExcludeList-superseded-all.txt" "%TEMP%\ExcludeList-superseded.txt" >nul
)
if exist .\exclude\ExcludeList-superseded-exclude-seconly.txt (
  type .\exclude\ExcludeList-superseded-exclude-seconly.txt >>"%TEMP%\ExcludeList-superseded-exclude.txt"
)
if exist .\exclude\custom\ExcludeList-superseded-exclude-seconly.txt (
  type .\exclude\custom\ExcludeList-superseded-exclude-seconly.txt >>"%TEMP%\ExcludeList-superseded-exclude.txt"
)
for %%i in (w62 w63) do (
  for /F %%j in ('dir /B .\client\static\StaticUpdateIds-%%i*-seconly.txt 2^>nul') do (
    for /F "tokens=1* delims=,;" %%k in (.\client\static\%%j) do (
      echo %%k>>"%TEMP%\ExcludeList-superseded-exclude.txt"
    )
  )
  for /F %%j in ('dir /B .\client\static\custom\StaticUpdateIds-%%i*-seconly.txt 2^>nul') do (
    for /F "tokens=1* delims=,;" %%k in (.\client\static\custom\%%j) do (
      echo %%k>>"%TEMP%\ExcludeList-superseded-exclude.txt"
    )
  )
)
for %%i in ("%TEMP%\ExcludeList-superseded-exclude.txt") do if %%~zi==0 del %%i
if exist "%TEMP%\ExcludeList-superseded-exclude.txt" (
  %SystemRoot%\System32\findstr.exe /L /I /V /G:"%TEMP%\ExcludeList-superseded-exclude.txt" "%TEMP%\ExcludeList-superseded-all.txt" >"%TEMP%\ExcludeList-superseded-seconly.txt"
  rem del "%TEMP%\ExcludeList-superseded-all.txt"
  rem del "%TEMP%\ExcludeList-superseded-exclude.txt"
) else (
  move /Y "%TEMP%\ExcludeList-superseded-all.txt" "%TEMP%\ExcludeList-superseded-seconly.txt" >nul
)
echo %TIME% - Done.
if "%PREEXISTING_PACKAGE_XML%"=="0" del "%TEMP%\package.xml"
goto EoF

del "%TEMP%\wsusscn2.cab"
:EoF
endlocal
