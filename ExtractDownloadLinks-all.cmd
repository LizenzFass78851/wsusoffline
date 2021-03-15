@echo off
rem *** Author: aker ***

if not exist "%TEMP%\wsusscn2.cab" (
  .\bin\wget.exe -N -i .\static\StaticDownloadLinks-wsus.txt -P "%TEMP%"
)
if exist "%TEMP%\package.cab" del "%TEMP%\package.cab"
if exist "%TEMP%\package.xml" del "%TEMP%\package.xml"
%SystemRoot%\System32\expand.exe "%TEMP%\wsusscn2.cab" -F:package.cab "%TEMP%"
%SystemRoot%\System32\expand.exe "%TEMP%\package.cab" "%TEMP%\package.xml"
rem del "%TEMP%\package.cab"

echo Extracting file 1, revision-and-update-ids.txt ...
%SystemRoot%\System32\cscript.exe //Nologo //B //E:vbs .\cmd\XSLT.vbs "%TEMP%\package.xml" .\xslt\extract-revision-and-update-ids.xsl "%TEMP%\revision-and-update-ids-unsorted.txt"
.\bin\gsort.exe -u -T "%TEMP%" "%TEMP%\revision-and-update-ids-unsorted.txt" > "%TEMP%\revision-and-update-ids.txt"
rem del "%TEMP%\revision-and-update-ids-unsorted.txt"

echo Extracting file 2, BundledUpdateRevisionAndFileIds.txt ...
%SystemRoot%\System32\cscript.exe //Nologo //B //E:vbs .\cmd\XSLT.vbs "%TEMP%\package.xml" .\xslt\extract-update-revision-and-file-ids.xsl "%TEMP%\BundledUpdateRevisionAndFileIds-unsorted.txt"
.\bin\gsort.exe -u -T "%TEMP%" "%TEMP%\BundledUpdateRevisionAndFileIds-unsorted.txt" > "%TEMP%\BundledUpdateRevisionAndFileIds.txt"
rem del "%TEMP%\BundledUpdateRevisionAndFileIds-unsorted.txt"

echo Extracting file 3, UpdateCabExeIdsAndLocations.txt ...
%SystemRoot%\System32\cscript.exe //Nologo //B //E:vbs .\cmd\XSLT.vbs "%TEMP%\package.xml" .\xslt\extract-update-cab-exe-ids-and-locations.xsl "%TEMP%\UpdateCabExeIdsAndLocations-unsorted.txt"
.\bin\gsort.exe -u -T "%TEMP%" "%TEMP%\UpdateCabExeIdsAndLocations-unsorted.txt" > "%TEMP%\UpdateCabExeIdsAndLocations.txt"
rem del "%TEMP%\UpdateCabExeIdsAndLocations-unsorted.txt"

echo Creating file 4, file-and-update-ids.txt ...
.\bin\join.exe -t "," -o "2.3,1.2" "%TEMP%\revision-and-update-ids.txt" "%TEMP%\BundledUpdateRevisionAndFileIds.txt" > "%TEMP%\file-and-update-ids-unsorted.txt"
.\bin\gsort.exe -u -T "%TEMP%" "%TEMP%\file-and-update-ids-unsorted.txt" > "%TEMP%\file-and-update-ids.txt"
rem del "%TEMP%\revision-and-update-ids.txt"
rem del "%TEMP%\file-and-update-ids-unsorted.txt"

echo Creating file 5, update-ids-and-locations.txt ...
.\bin\join.exe -t "," -o "1.2,2.2" "%TEMP%\file-and-update-ids.txt" "%TEMP%\UpdateCabExeIdsAndLocations.txt" > "%TEMP%\update-ids-and-locations-unsorted.txt"
.\bin\gsort.exe -u -T "%TEMP%" "%TEMP%\update-ids-and-locations-unsorted.txt" > "%TEMP%\update-ids-and-locations.txt"
rem del "%TEMP%\file-and-update-ids.txt"
rem del "%TEMP%\update-ids-and-locations-unsorted.txt"

echo Creating file 6, update-ids-and-locations-all.txt ...
type "%TEMP%\update-ids-and-locations.txt" > "%TEMP%\update-ids-and-locations-all.txt"

echo Creating file 7, UpdateTable-all.csv ...
%SystemRoot%\System32\cscript.exe //Nologo //B //E:vbs .\cmd\ExtractIdsAndFileNames.vbs "%TEMP%\update-ids-and-locations-all.txt" "%TEMP%\UpdateTable-all.csv"

echo Creating file 8, DynamicDownloadLinks-all.txt ...
.\bin\cut.exe -d "," -f "2" "%TEMP%\update-ids-and-locations-all.txt" > "%TEMP%\DynamicDownloadLinks-all-unsorted.txt"
.\bin\gsort.exe -u -T "%TEMP%" "%TEMP%\DynamicDownloadLinks-all-unsorted.txt" > "%TEMP%\DynamicDownloadLinks-all.txt"
rem del "%TEMP%\update-ids-and-locations-all.txt"
rem del "%TEMP%\DynamicDownloadLinks-all-unsorted.txt"

echo Creating file 9, DownloadLinks-all.txt ...
move /Y "%TEMP%\DynamicDownloadLinks-all.txt" "%TEMP%\DownloadLinks-all.txt" >nul

del "%TEMP%\package.xml"
del "%TEMP%\wsusscn2.cab"

:EoF
