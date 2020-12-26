@echo off

setlocal enabledelayedexpansion
rem *** Author: T. Wittrock, Kiel ***
rem *** Hartmut Buhrmester ***

if not exist "%TEMP%\wsusscn2.cab" (
  .\bin\wget.exe -N -i .\static\StaticDownloadLinks-wsus.txt -P "%TEMP%"
)
if exist "%TEMP%\package.cab" del "%TEMP%\package.cab"
if exist "%TEMP%\package.xml" del "%TEMP%\package.xml"
%SystemRoot%\System32\expand.exe "%TEMP%\wsusscn2.cab" -F:package.cab "%TEMP%"
%SystemRoot%\System32\expand.exe "%TEMP%\package.cab" "%TEMP%\package.xml"
del "%TEMP%\package.cab"
goto DoIt

:Determine

for %%j in (glb enu fra esn jpn kor rus ptg ptb deu nld ita chs cht plk hun csy sve trk ell ara heb dan nor fin) do (if /i "%2"=="%%j" goto Lang_%%j)
goto EoF

rem The variable LANG_SHORT was replaced with LOCALE_LONG, consisting of
rem the language and region code, e.g. de-de or en-us.
:Lang_glb
set LOCALE_LONG=x-none
goto DetermineReal
:Lang_enu
set LOCALE_LONG=en-us
goto DetermineReal
:Lang_fra
set LOCALE_LONG=fr-fr
goto DetermineReal
:Lang_esn
set LOCALE_LONG=es-es
goto DetermineReal
:Lang_jpn
set LOCALE_LONG=ja-jp
goto DetermineReal
:Lang_kor
set LOCALE_LONG=ko-kr
goto DetermineReal
:Lang_rus
set LOCALE_LONG=ru-ru
goto DetermineReal
:Lang_ptg
set LOCALE_LONG=pt-pt
goto DetermineReal
:Lang_ptb
set LOCALE_LONG=pt-br
goto DetermineReal
:Lang_deu
set LOCALE_LONG=de-de
goto DetermineReal
:Lang_nld
set LOCALE_LONG=nl-nl
goto DetermineReal
:Lang_ita
set LOCALE_LONG=it-it
goto DetermineReal
:Lang_chs
set LOCALE_LONG=zh-cn
goto DetermineReal
:Lang_cht
set LOCALE_LONG=zh-tw
goto DetermineReal
:Lang_plk
set LOCALE_LONG=pl-pl
goto DetermineReal
:Lang_hun
set LOCALE_LONG=hu-hu
goto DetermineReal
:Lang_csy
set LOCALE_LONG=cs-cz
goto DetermineReal
:Lang_sve
set LOCALE_LONG=sv-se
goto DetermineReal
:Lang_trk
set LOCALE_LONG=tr-tr
goto DetermineReal
:Lang_ell
set LOCALE_LONG=el-gr
goto DetermineReal
:Lang_ara
set LOCALE_LONG=ar-sa
goto DetermineReal
:Lang_heb
set LOCALE_LONG=he-il
goto DetermineReal
:Lang_dan
set LOCALE_LONG=da-dk
goto DetermineReal
:Lang_nor
set LOCALE_LONG=nb-no
goto DetermineReal
:Lang_fin
set LOCALE_LONG=fi-fi
goto DetermineReal

:DetermineReal
rem The file office-update-ids-and-locations.txt lists all Office
rem UpdateIds (in the form of UUIDs) and their locations, before
rem splitting the file into global and localized updates or applying any
rem exclude lists. This file only depends on the WSUS offline scan file
rem wsusscn2.cab. If it already exists, it can be reused again. It will
rem be deleted at the end of the script.
rem
rem TODO: Such tricks work great for the Linux download scripts, but
rem not for the Windows script.

echo %TIME% - Start (%1 %2)

echo Extracting file 1, office-revision-and-update-ids.txt ...
if exist "%TEMP%\office-revision-and-update-ids-unsorted.txt" del "%TEMP%\office-revision-and-update-ids-unsorted.txt"
if exist "%TEMP%\office-revision-and-update-ids.txt" del "%TEMP%\office-revision-and-update-ids.txt"
%SystemRoot%\System32\cscript.exe //Nologo //B //E:vbs .\cmd\XSLT.vbs "%TEMP%\package.xml" .\xslt\extract-office-revision-and-update-ids.xsl "%TEMP%\office-revision-and-update-ids-unsorted.txt"
.\bin\gsort.exe -u -T "%TEMP%" "%TEMP%\office-revision-and-update-ids-unsorted.txt" > "%TEMP%\office-revision-and-update-ids.txt"
rem del "%TEMP%\office-revision-and-update-ids-unsorted.txt"

rem The next two files BundledUpdateRevisionAndFileIds.txt and
rem UpdateCabExeIdsAndLocations.txt are also used for the calculation
rem of superseded updates. If they already exist, they don't need to
rem be recalculated again.
echo Extracting file 2, BundledUpdateRevisionAndFileIds.txt ...
if exist "%TEMP%\BundledUpdateRevisionAndFileIds-unsorted.txt" del "%TEMP%\BundledUpdateRevisionAndFileIds-unsorted.txt"
if exist "%TEMP%\BundledUpdateRevisionAndFileIds.txt" del "%TEMP%\BundledUpdateRevisionAndFileIds.txt"
%SystemRoot%\System32\cscript.exe //Nologo //B //E:vbs .\cmd\XSLT.vbs "%TEMP%\package.xml" .\xslt\extract-update-revision-and-file-ids.xsl "%TEMP%\BundledUpdateRevisionAndFileIds-unsorted.txt"
.\bin\gsort.exe -u -T "%TEMP%" "%TEMP%\BundledUpdateRevisionAndFileIds-unsorted.txt" > "%TEMP%\BundledUpdateRevisionAndFileIds.txt"
rem del "%TEMP%\BundledUpdateRevisionAndFileIds-unsorted.txt"

echo Extracting file 3, UpdateCabExeIdsAndLocations.txt ...
if exist "%TEMP%\UpdateCabExeIdsAndLocations-unsorted.txt" del "%TEMP%\UpdateCabExeIdsAndLocations-unsorted.txt"
if exist "%TEMP%\UpdateCabExeIdsAndLocations.txt" del "%TEMP%\UpdateCabExeIdsAndLocations.txt"
%SystemRoot%\System32\cscript.exe //Nologo //B //E:vbs .\cmd\XSLT.vbs "%TEMP%\package.xml" .\xslt\extract-update-cab-exe-ids-and-locations.xsl "%TEMP%\UpdateCabExeIdsAndLocations-unsorted.txt"
.\bin\gsort.exe -u -T "%TEMP%" "%TEMP%\UpdateCabExeIdsAndLocations-unsorted.txt" > "%TEMP%\UpdateCabExeIdsAndLocations.txt"
rem del "%TEMP%\UpdateCabExeIdsAndLocations-unsorted.txt"

rem Join the first two files to get the FileIds. The UpdateId of the
rem bundle record is copied, because it is needed later for the files
rem UpdateTable-ofc-*.csv.
rem
rem Input file 1: office-revision-and-update-ids.txt
rem - Field 1: RevisionId of the bundle record
rem - Field 2: UpdateId of the bundle record
rem Input file 2: BundledUpdateRevisionAndFileIds.txt
rem - Field 1: RevisionId of the parent bundle record
rem - Field 2: RevisionId of the update record for the PayloadFile
rem - Field 3: FileId of the PayloadFile
rem Output file: office-file-and-update-ids.txt
rem - Field 1: FileId of the PayloadFile
rem - Field 2: UpdateId of the bundle record
echo Creating file 4, office-file-and-update-ids.txt ...
if exist "%TEMP%\office-file-and-update-ids-unsorted.txt" del "%TEMP%\office-file-and-update-ids-unsorted.txt"
if exist "%TEMP%\office-file-and-update-ids.txt" del "%TEMP%\office-file-and-update-ids.txt"
.\bin\join.exe -t "," -o "2.3,1.2" "%TEMP%\office-revision-and-update-ids.txt" "%TEMP%\BundledUpdateRevisionAndFileIds.txt" > "%TEMP%\office-file-and-update-ids-unsorted.txt"
.\bin\gsort.exe -u -T "%TEMP%" "%TEMP%\office-file-and-update-ids-unsorted.txt" > "%TEMP%\office-file-and-update-ids.txt"
rem del "%TEMP%\office-revision-and-update-ids.txt"
rem del "%TEMP%\office-file-and-update-ids-unsorted.txt"

rem Join with third file to get the FileLocations (URLs)
rem
rem Input file 1: office-file-and-update-ids.txt
rem - Field 1: FileId of the PayloadFile
rem - Field 2: UpdateId of the bundle record
rem Input file 2: UpdateCabExeIdsAndLocations.txt
rem - Field 1: FileId of the PayloadFile
rem - Field 2: Location (URL)
rem Output file: office-update-ids-and-locations.txt
rem - Field 1: UpdateId of the bundle record
rem - Field 2: Location (URL)
echo Creating file 5, office-update-ids-and-locations.txt ...
if exist "%TEMP%\office-update-ids-and-locations-unsorted.txt" del "%TEMP%\office-update-ids-and-locations-unsorted.txt"
if exist "%TEMP%\office-update-ids-and-locations.txt" del "%TEMP%\office-update-ids-and-locations.txt"
.\bin\join.exe -t "," -o "1.2,2.2" "%TEMP%\office-file-and-update-ids.txt" "%TEMP%\UpdateCabExeIdsAndLocations.txt" > "%TEMP%\office-update-ids-and-locations-unsorted.txt"
.\bin\gsort.exe -u -T "%TEMP%" "%TEMP%\office-update-ids-and-locations-unsorted.txt" > "%TEMP%\office-update-ids-and-locations.txt"
rem del "%TEMP%\office-file-and-update-ids.txt"
rem del "%TEMP%\office-update-ids-and-locations-unsorted.txt"

rem Separate the updates into global and localized versions
echo Creating file 6, office-update-ids-and-locations-%2.txt ...
if exist "%TEMP%\office-update-ids-and-locations-%2.txt" del "%TEMP%\office-update-ids-and-locations-%2.txt"
if "%2"=="glb" (
  rem Remove all localized files to get the global/multilingual updates
  %SystemRoot%\System32\findstr.exe /L /I /V /G:".\opt\locales.txt" "%TEMP%\office-update-ids-and-locations.txt" > "%TEMP%\office-update-ids-and-locations-%2.txt"
) else (
  rem Extract localized files using search strings like "-en-us_"
  %SystemRoot%\System32\findstr.exe /L /I /C:"-%LOCALE_LONG%_" "%TEMP%\office-update-ids-and-locations.txt" > "%TEMP%\office-update-ids-and-locations-%2.txt"
)

rem Create the files ../client/ofc/UpdateTable-ofc-*.csv, which are
rem needed during the installation of the updates. They link the UpdateIds
rem (in form of UUIDs) to the file names.
echo Creating file 7, UpdateTable-ofc-%2.csv ...
if exist "%TEMP%\UpdateTable-ofc-%2.csv" del "%TEMP%\UpdateTable-ofc-%2.csv"
%SystemRoot%\System32\cscript.exe //Nologo //B //E:vbs .\cmd\ExtractIdsAndFileNames.vbs "%TEMP%\office-update-ids-and-locations-%2.txt" "%TEMP%\UpdateTable-ofc-%2.csv"

rem At this point, the UpdateIds are no longer needed. Only the locations
rem (URLs) are needed to create the initial list of dynamic download
rem links.
echo Creating file 8, DynamicDownloadLinks-ofc-%2.txt ...
if exist "%TEMP%\DynamicDownloadLinks-ofc-%2-unsorted.txt" del "%TEMP%\DynamicDownloadLinks-ofc-%2-unsorted.txt"
if exist "%TEMP%\DynamicDownloadLinks-ofc-%2.txt" del "%TEMP%\DynamicDownloadLinks-ofc-%2.txt"
.\bin\cut.exe -d "," -f "2" "%TEMP%\office-update-ids-and-locations-%2.txt" > "%TEMP%\DynamicDownloadLinks-ofc-%2-unsorted.txt"
.\bin\gsort.exe -u -T "%TEMP%" "%TEMP%\DynamicDownloadLinks-ofc-%2-unsorted.txt" > "%TEMP%\DynamicDownloadLinks-ofc-%2.txt"
rem del "%TEMP%\office-update-ids-and-locations-%2.txt"
rem del "%TEMP%\DynamicDownloadLinks-ofc-%2-unsorted.txt"
goto :EoF

:DoIt
call :Determine ofc enu
echo.
call :Determine ofc deu
echo.
call :Determine ofc glb
echo.
echo %TIME% - Done.

del "%TEMP%\package.xml"
del "%TEMP%\wsusscn2.cab"

:EoF
endlocal
