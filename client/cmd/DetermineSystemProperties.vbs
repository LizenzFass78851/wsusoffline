' *** Author: T. Wittrock, Kiel ***
' ***   - Community Edition -   ***

Option Explicit

Private Const strRegKeyWindowsVersion         = "HKLM\Software\Microsoft\Windows NT\CurrentVersion\"
Private Const strRegKeySHA2Support            = "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Servicing\Codesigning\SHA2\"
Private Const strRegKeyIE                     = "HKLM\Software\Microsoft\Internet Explorer\"
Private Const strRegKeyMSSL_x86               = "HKLM\Software\Microsoft\Silverlight\"
Private Const strRegKeyMSSL_x64               = "HKLM\Software\Wow6432Node\Microsoft\Silverlight\"
Private Const strRegKeyDotNet35               = "HKLM\Software\Microsoft\NET Framework Setup\NDP\v3.5\"
Private Const strRegKeyDotNet4                = "HKLM\Software\Microsoft\NET Framework Setup\NDP\v4\Full\"
Private Const strRegKeyPowerShell             = "HKLM\Software\Microsoft\PowerShell\1\PowerShellEngine\"
Private Const strRegKeyManagementFramework    = "HKLM\Software\Microsoft\PowerShell\3\PowerShellEngine\"
Private Const strRegKeyMSSE                   = "HKLM\Software\Microsoft\Microsoft Security Client\"
Private Const strRegKeyMSSEUninstall          = "HKLM\Software\Microsoft\Windows\CurrentVersion\Uninstall\Microsoft Security Client\"
Private Const strRegKeyMSSEDefs               = "HKLM\Software\Microsoft\Microsoft Antimalware\Signature Updates\"
Private Const strRegKeyWD                     = "HKLM\Software\Microsoft\Windows Defender\"
Private Const strRegKeyWDPolicy               = "HKLM\Software\Policies\Microsoft\Windows Defender\"
Private Const strRegKeyWDDefs                 = "HKLM\Software\Microsoft\Windows Defender\Signature Updates\"
Private Const strRegKeyQualityCompat          = "HKLM\Software\Microsoft\Windows\CurrentVersion\QualityCompat\cadca5fe-87d3-4b96-b7fb-a231484277cc"
Private Const strRegKeyPowerCfg               = "HKCU\Control Panel\PowerCfg\"

Private Const strRegValVersion                = "Version"
Private Const strRegValRelease                = "Release"
Private Const strRegValDisplayVersion         = "DisplayVersion"
Private Const strRegValUBR                    = "UBR"
Private Const strRegValBuildLabEx             = "BuildLabEx"
Private Const strRegValSHA2Support            = "SHA2-Codesigning-Support"
Private Const strRegValSHA2Support2           = "SHA2-Core-Codesigning-Support"
Private Const strRegValInstallationType       = "InstallationType"
Private Const strRegValPShVersion             = "PowerShellVersion"
Private Const strRegValAVSVersion             = "AVSignatureVersion"
Private Const strRegValNISSVersion            = "NISSignatureVersion"
Private Const strRegValASSVersion             = "ASSignatureVersion"
Private Const strRegValDisableAntiSpyware     = "DisableAntiSpyware"
Private Const strRegValCurrentPowerPolicy     = "CurrentPowerPolicy"
Private Const strRegKeyOfficePrefix_Mx86      = "HKLM\Software\Microsoft\Office\"
Private Const strRegKeyOfficePrefix_Mx64      = "HKLM\Software\Wow6432Node\Microsoft\Office\"
Private Const strRegKeyOfficePrefix_User      = "HKCU\Software\Microsoft\Office\"
Private Const strRegKeyOfficeInfixes_Version  = "15.0,16.0"
Private Const strRegKeyOfficeSuffix_InstRoot  = "\Common\InstallRoot\"
Private Const strRegKeyOfficeSuffix_Language  = "\Common\LanguageResources\"
Private Const strRegKeyOfficeSuffix_Outlook   = "\Outlook\"
Private Const strRegValOfficePath             = "Path"
Private Const strRegValOfficeLanguage_Inst    = "SKULanguage"
Private Const strRegValOfficeLanguage_User    = "InstallLanguage"
Private Const strRegValOfficeVersion          = "LastProduct"
Private Const strRegValOfficeArchitecture     = "Bitness"
Private Const strVersionSuffixes              = "MAJOR,MINOR,BUILD,REVIS"
Private Const strOfficeNames                  = "o2k13,o2k16"
Private Const strOfficeAppNames               = "Word,Excel,Outlook,Powerpoint,Access,FrontPage"
Private Const strOfficeExeNames               = "WINWORD.EXE,EXCEL.EXE,OUTLOOK.EXE,POWERPNT.EXE,MSACCESS.EXE,FRONTPG.EXE"
Private Const strBuildNumbers_o2k13           = "4420,4420,4420,4420,4420,4420;4569,4569,4569,4454,4569,4569"
Private Const strBuildNumbers_o2k16           = "4266,4266,4266,4266,4266,4266"
Private Const idxBuild                        = 2

Dim wshShell, objFileSystem, objStaticFile, objCmdFile, objWMIService, objQueryItem, objFolder, objInstaller, arrayOfficeNames, arrayOfficeVersions, arrayOfficeAppNames, arrayOfficeExeNames
Dim strSystemFolder, strTempFolder, strProfileFolder, strWUAFileName, strMSIFileName, strWSHFileName, strTSCFileName, strCmdFileName
Dim strOSArchitecture, strUBR, strBuildLabEx, strInstallationType, strOfficeInstallPath, strOfficeExeVersion, strProduct, strPatch, languageCode, i, j
Dim ServicingStack_Major, ServicingStack_Minor, ServicingStack_Build, ServicingStack_Revis, ServicingStack_OSVer_Major, ServicingStack_OSVer_Minor, ServicingStack_OSVer_Build
Dim cpp2005_x86_old_ids, cpp2005_x86_new_ids, cpp2005_x64_old_ids, cpp2005_x64_new_ids
Dim cpp2008_x86_old_ids, cpp2008_x86_new_ids, cpp2008_x64_old_ids, cpp2008_x64_new_ids
'Dim cpp2010_x86_old_ids, cpp2010_x86_new_ids, cpp2010_x64_old_ids, cpp2010_x64_new_ids
Dim cpp2012_x86_old_ids, cpp2012_x86_new_ids, cpp2012_x64_old_ids, cpp2012_x64_new_ids
Dim cpp2013_x86_old_ids, cpp2013_x86_new_ids, cpp2013_x64_old_ids, cpp2013_x64_new_ids
Dim cpp2015_x86_old_ids, cpp2015_x86_new_ids, cpp2015_x64_old_ids, cpp2015_x64_new_ids
Dim cpp2005_x86_old, cpp2005_x86_new, cpp2005_x64_old, cpp2005_x64_new
Dim cpp2008_x86_old, cpp2008_x86_new, cpp2008_x64_old, cpp2008_x64_new
Dim cpp2010_x86_old, cpp2010_x86_new, cpp2010_x64_old, cpp2010_x64_new
Dim cpp2012_x86_old, cpp2012_x86_new, cpp2012_x64_old, cpp2012_x64_new
Dim cpp2013_x86_old, cpp2013_x86_new, cpp2013_x64_old, cpp2013_x64_new
Dim cpp2015_x86_old, cpp2015_x86_new, cpp2015_x64_old, cpp2015_x64_new

Private Function RegExists(objShell, strName)
Dim dummy
  On Error Resume Next
  dummy = objShell.RegRead(strName)
  RegExists = (Err >= 0)
  Err.Clear
End Function

Private Function RegRead(objShell, strName)
  On Error Resume Next
  RegRead = objShell.RegRead(strName)
  If Err <> 0 Then
    RegRead = ""
    Err.Clear
  End If
End Function

Private Function GetFileVersion(objFS, strName)
  On Error Resume Next
  GetFileVersion = objFS.GetFileVersion(strName)
  If Err <> 0 Then
    WScript.Quit(1)
  End If
End Function

Private Sub WriteLanguageToFile(cmdFile, varName, langCode, writeShortLang, writeExtLang)
  Select Case langCode
' supported languages
    Case &H0009, &H0409, &H0809, &H0C09, &H1009, &H1409, &H1809, &H1C09, &H2009, &H2409, &H2809, &H2C09, &H3009, &H3409, &H4009, &H4409, &H4809
      cmdFile.WriteLine("set " & varName & "=enu")
      If writeShortLang Then cmdFile.WriteLine("set " & varName & "_SHORT=en")
      If writeExtLang Then cmdFile.WriteLine("set " & varName & "_EXT=en-us")
    Case &H000C, &H040C, &H080C, &H0C0C, &H100C, &H140C, &H180C
      cmdFile.WriteLine("set " & varName & "=fra")
      If writeShortLang Then cmdFile.WriteLine("set " & varName & "_SHORT=fr")
      If writeExtLang Then cmdFile.WriteLine("set " & varName & "_EXT=fr-fr")
    Case &H000A, &H080A, &H0C0A, &H100A, &H140A, &H180A, &H1C0A, &H200A, &H240A, &H280A, &H2C0A, &H300A, &H340A, &H380A, &H3C0A, &H400A, &H440A, &H480A, &H4C0A, &H500A, &H540A
      cmdFile.WriteLine("set " & varName & "=esn")
      If writeShortLang Then cmdFile.WriteLine("set " & varName & "_SHORT=es")
      If writeExtLang Then cmdFile.WriteLine("set " & varName & "_EXT=es-es")
    Case &H0019, &H0419
      cmdFile.WriteLine("set " & varName & "=rus")
      If writeShortLang Then cmdFile.WriteLine("set " & varName & "_SHORT=ru")
      If writeExtLang Then cmdFile.WriteLine("set " & varName & "_EXT=ru-ru")
    Case &H0816
      cmdFile.WriteLine("set " & varName & "=ptg")
      If writeShortLang Then cmdFile.WriteLine("set " & varName & "_SHORT=pt")
      If writeExtLang Then cmdFile.WriteLine("set " & varName & "_EXT=pt-pt")
    Case &H0416
      cmdFile.WriteLine("set " & varName & "=ptb")
      If writeShortLang Then cmdFile.WriteLine("set " & varName & "_SHORT=pt")
      If writeExtLang Then cmdFile.WriteLine("set " & varName & "_EXT=pt-br")
    Case &H0007, &H0407, &H0807, &H0C07, &H1007, &H1407
      cmdFile.WriteLine("set " & varName & "=deu")
      If writeShortLang Then cmdFile.WriteLine("set " & varName & "_SHORT=de")
      If writeExtLang Then cmdFile.WriteLine("set " & varName & "_EXT=de-de")
    Case &H0013, &H0413, &H0813
      cmdFile.WriteLine("set " & varName & "=nld")
      If writeShortLang Then cmdFile.WriteLine("set " & varName & "_SHORT=nl")
      If writeExtLang Then cmdFile.WriteLine("set " & varName & "_EXT=nl-nl")
    Case &H0010, &H0410, &H0810
      cmdFile.WriteLine("set " & varName & "=ita")
      If writeShortLang Then cmdFile.WriteLine("set " & varName & "_SHORT=it")
      If writeExtLang Then cmdFile.WriteLine("set " & varName & "_EXT=it-it")
    Case &H0015, &H0415
      cmdFile.WriteLine("set " & varName & "=plk")
      If writeShortLang Then cmdFile.WriteLine("set " & varName & "_SHORT=pl")
      If writeExtLang Then cmdFile.WriteLine("set " & varName & "_EXT=pl-pl")
    Case &H000E, &H040E
      cmdFile.WriteLine("set " & varName & "=hun")
      If writeShortLang Then cmdFile.WriteLine("set " & varName & "_SHORT=hu")
      If writeExtLang Then cmdFile.WriteLine("set " & varName & "_EXT=hu-hu")
    Case &H0005, &H0405
      cmdFile.WriteLine("set " & varName & "=csy")
      If writeShortLang Then cmdFile.WriteLine("set " & varName & "_SHORT=cs")
      If writeExtLang Then cmdFile.WriteLine("set " & varName & "_EXT=cs-cz")
    Case &H001D, &H041D, &H081D
      cmdFile.WriteLine("set " & varName & "=sve")
      If writeShortLang Then cmdFile.WriteLine("set " & varName & "_SHORT=sv")
      If writeExtLang Then cmdFile.WriteLine("set " & varName & "_EXT=sv-se")
    Case &H001F, &H041F
      cmdFile.WriteLine("set " & varName & "=trk")
      If writeShortLang Then cmdFile.WriteLine("set " & varName & "_SHORT=tr")
      If writeExtLang Then cmdFile.WriteLine("set " & varName & "_EXT=tr-tr")
    Case &H0008, &H0408
      cmdFile.WriteLine("set " & varName & "=ell")
      If writeShortLang Then cmdFile.WriteLine("set " & varName & "_SHORT=el")
      If writeExtLang Then cmdFile.WriteLine("set " & varName & "_EXT=el-gr")
    Case &H0006, &H0406
      cmdFile.WriteLine("set " & varName & "=dan")
      If writeShortLang Then cmdFile.WriteLine("set " & varName & "_SHORT=da")
      If writeExtLang Then cmdFile.WriteLine("set " & varName & "_EXT=da-dk")
    Case &H0014, &H0414, &H7C14, &H0814, &H7814
      cmdFile.WriteLine("set " & varName & "=nor")
      If writeShortLang Then cmdFile.WriteLine("set " & varName & "_SHORT=no")
      If writeExtLang Then cmdFile.WriteLine("set " & varName & "_EXT=nb-no")
    Case &H000B, &H040B
      cmdFile.WriteLine("set " & varName & "=fin")
      If writeShortLang Then cmdFile.WriteLine("set " & varName & "_SHORT=fi")
      If writeExtLang Then cmdFile.WriteLine("set " & varName & "_EXT=fi-fi")
    Case &H0004, &H0804, &H1004, &H7804
      cmdFile.WriteLine("set " & varName & "=chs")
      If writeShortLang Then cmdFile.WriteLine("set " & varName & "_SHORT=zh")
      If writeExtLang Then cmdFile.WriteLine("set " & varName & "_EXT=zh-cn")
    Case &H0404, &H0C04, &H1404, &H7C04
      cmdFile.WriteLine("set " & varName & "=cht")
      If writeShortLang Then cmdFile.WriteLine("set " & varName & "_SHORT=zh")
      If writeExtLang Then cmdFile.WriteLine("set " & varName & "_EXT=zh-tw")
    Case &H0011, &H0411
      cmdFile.WriteLine("set " & varName & "=jpn")
      If writeShortLang Then cmdFile.WriteLine("set " & varName & "_SHORT=ja")
      If writeExtLang Then cmdFile.WriteLine("set " & varName & "_EXT=ja-jp")
    Case &H0012, &H0412
      cmdFile.WriteLine("set " & varName & "=kor")
      If writeShortLang Then cmdFile.WriteLine("set " & varName & "_SHORT=ko")
      If writeExtLang Then cmdFile.WriteLine("set " & varName & "_EXT=ko-kr")
    Case &H0001, &H0401, &H0801, &H0C01, &H1001, &H1401, &H1801, &H1C01, &H2001, &H2401, &H2801, &H2C01, &H3001, &H3401, &H3801, &H3C01, &H4001
      cmdFile.WriteLine("set " & varName & "=ara")
      If writeShortLang Then cmdFile.WriteLine("set " & varName & "_SHORT=ar")
      If writeExtLang Then cmdFile.WriteLine("set " & varName & "_EXT=ar-sa")
    Case &H000D, &H040D
      cmdFile.WriteLine("set " & varName & "=heb")
      If writeShortLang Then cmdFile.WriteLine("set " & varName & "_SHORT=he")
      If writeExtLang Then cmdFile.WriteLine("set " & varName & "_EXT=he-il")

' unsupported languages, detection only
    Case &H002B, &H042B
      cmdFile.WriteLine("set " & varName & "=hye")
      If writeExtLang Then cmdFile.WriteLine("set " & varName & "_EXT=hy-am")
    Case &H002D, &H042D
      cmdFile.WriteLine("set " & varName & "=euq")
      If writeExtLang Then cmdFile.WriteLine("set " & varName & "_EXT=eu-es")
    Case &H0023, &H0423
      cmdFile.WriteLine("set " & varName & "=bel")
      If writeExtLang Then cmdFile.WriteLine("set " & varName & "_EXT=be-by")
    Case &H007E, &H047E
      cmdFile.WriteLine("set " & varName & "=bre")
      If writeExtLang Then cmdFile.WriteLine("set " & varName & "_EXT=br-fr")
    Case &H0002, &H0402
      cmdFile.WriteLine("set " & varName & "=bgr")
      If writeExtLang Then cmdFile.WriteLine("set " & varName & "_EXT=bg-bg")
    Case &H0003, &H0403
      cmdFile.WriteLine("set " & varName & "=cat")
      If writeExtLang Then cmdFile.WriteLine("set " & varName & "_EXT=ca-es")
    Case &H0083, &H0483
      cmdFile.WriteLine("set " & varName & "=cos")
      If writeExtLang Then cmdFile.WriteLine("set " & varName & "_EXT=co-fr")
    Case &H001A, &H041A, &H101A
      cmdFile.WriteLine("set " & varName & "=hrv")
      If writeExtLang Then cmdFile.WriteLine("set " & varName & "_EXT=hr-hr")
    Case &H0025, &H0425
      cmdFile.WriteLine("set " & varName & "=eti")
      If writeExtLang Then cmdFile.WriteLine("set " & varName & "_EXT=et-ee")
    Case &H0038, &H0438
      cmdFile.WriteLine("set " & varName & "=fos")
      If writeExtLang Then cmdFile.WriteLine("set " & varName & "_EXT=fo-fo")
    Case &H0062, &H0462
      cmdFile.WriteLine("set " & varName & "=fyn")
      If writeExtLang Then cmdFile.WriteLine("set " & varName & "_EXT=fy-nl")
    Case &H0056, &H0456
      cmdFile.WriteLine("set " & varName & "=glc")
      If writeExtLang Then cmdFile.WriteLine("set " & varName & "_EXT=gl-es")
    Case &H0037, &H0437
      cmdFile.WriteLine("set " & varName & "=kat")
      If writeExtLang Then cmdFile.WriteLine("set " & varName & "_EXT=ka-ge")
    Case &H006F, &H046F
      cmdFile.WriteLine("set " & varName & "=kal")
      If writeExtLang Then cmdFile.WriteLine("set " & varName & "_EXT=kl-gl")
    Case &H0039, &H0439
      cmdFile.WriteLine("set " & varName & "=hin")
      If writeExtLang Then cmdFile.WriteLine("set " & varName & "_EXT=hi-in")
    Case &H000F, &H040F
      cmdFile.WriteLine("set " & varName & "=isl")
      If writeExtLang Then cmdFile.WriteLine("set " & varName & "_EXT=is-is")
    Case &H003C, &H083C
      cmdFile.WriteLine("set " & varName & "=ire")
      If writeExtLang Then cmdFile.WriteLine("set " & varName & "_EXT=ga-ie")
    Case &H0026, &H0426
      cmdFile.WriteLine("set " & varName & "=lvi")
      If writeExtLang Then cmdFile.WriteLine("set " & varName & "_EXT=lv-lv")
    Case &H0027, &H0427
      cmdFile.WriteLine("set " & varName & "=lth")
      If writeExtLang Then cmdFile.WriteLine("set " & varName & "_EXT=lt-lt")
    Case &H0029, &H0429
      cmdFile.WriteLine("set " & varName & "=far")
      If writeExtLang Then cmdFile.WriteLine("set " & varName & "_EXT=fa-ir")
    Case &H0046, &H0446
      cmdFile.WriteLine("set " & varName & "=pan")
      If writeExtLang Then cmdFile.WriteLine("set " & varName & "_EXT=pa-in")
    Case &H0018, &H0418
      cmdFile.WriteLine("set " & varName & "=rom")
      If writeExtLang Then cmdFile.WriteLine("set " & varName & "_EXT=ro-ro")
    Case &H004F, &H044F
      cmdFile.WriteLine("set " & varName & "=san")
      If writeExtLang Then cmdFile.WriteLine("set " & varName & "_EXT=sa-in")
    Case &H001B, &H041B
      cmdFile.WriteLine("set " & varName & "=sky")
      If writeExtLang Then cmdFile.WriteLine("set " & varName & "_EXT=sk-sk")
    Case &H0024, &H0424
      cmdFile.WriteLine("set " & varName & "=slv")
      If writeExtLang Then cmdFile.WriteLine("set " & varName & "_EXT=sl-si")
    Case &H001E, &H041E
      cmdFile.WriteLine("set " & varName & "=tha")
      If writeExtLang Then cmdFile.WriteLine("set " & varName & "_EXT=th-th")
    Case &H0022, &H0422
      cmdFile.WriteLine("set " & varName & "=ukr")
      If writeExtLang Then cmdFile.WriteLine("set " & varName & "_EXT=uk-ua")
    Case &H002A, &H042A
      cmdFile.WriteLine("set " & varName & "=vit")
      If writeExtLang Then cmdFile.WriteLine("set " & varName & "_EXT=vi-vn")
    Case &H0052, &H0452
      cmdFile.WriteLine("set " & varName & "=cym")
      If writeExtLang Then cmdFile.WriteLine("set " & varName & "_EXT=cy-gb")
  End Select
End Sub

Private Sub WriteVersionToFile(cmdFile, strPrefix, strVersion)
Dim arraySuffixes, arrayVersion, i

  arraySuffixes = Split(strVersionSuffixes, ",")
  If Len(strVersion) > 0 Then
    arrayVersion = Split(strVersion, ".")
  Else
    arrayVersion = Split("0", ".")
  End If
  For i = 0 To UBound(arraySuffixes)
    If i > UBound(arrayVersion) Then
      cmdFile.WriteLine("set " & strPrefix & "_" & arraySuffixes(i) & "=0")
    Else
      cmdFile.WriteLine("set " & strPrefix & "_" & arraySuffixes(i) & "=" & arrayVersion(i))
    End If
  Next
End Sub

Private Function OfficeInstallPath(objShell, strVersionInfix)
Dim strRegVal

  OfficeInstallPath = ""
  strRegVal = RegRead(objShell, strRegKeyOfficePrefix_Mx86 & strVersionInfix & strRegKeyOfficeSuffix_InstRoot & strRegValOfficePath)
  If strRegVal <> "" Then
    OfficeInstallPath = strRegVal
    Exit Function
  End If
  strRegVal = RegRead(objShell, strRegKeyOfficePrefix_Mx64 & strVersionInfix & strRegKeyOfficeSuffix_InstRoot & strRegValOfficePath)
  If strRegVal <> "" Then
    OfficeInstallPath = strRegVal
    Exit Function
  End If
End Function

Private Function OfficeLanguageCode(objShell, strVersionInfix)
Dim strRegVal

  OfficeLanguageCode = 0
  strRegVal = RegRead(objShell, strRegKeyOfficePrefix_Mx86 & strVersionInfix & strRegKeyOfficeSuffix_Language & strRegValOfficeLanguage_Inst)
  If strRegVal <> "" Then
    OfficeLanguageCode = CInt(strRegVal)
    Exit Function
  End If
  strRegVal = RegRead(objShell, strRegKeyOfficePrefix_Mx64 & strVersionInfix & strRegKeyOfficeSuffix_Language & strRegValOfficeLanguage_Inst)
  If strRegVal <> "" Then
    OfficeLanguageCode = CInt(strRegVal)
    Exit Function
  End If
  strRegVal = RegRead(objShell, strRegKeyOfficePrefix_User & strVersionInfix & strRegKeyOfficeSuffix_Language & strRegValOfficeLanguage_User)
  If strRegVal <> "" Then
    OfficeLanguageCode = CInt(strRegVal)
    Exit Function
  End If
End Function

Private Function OfficeArchitecture(objShell, strOSArch, strVersionInfix, strOfficeInstPath)
Dim strRegVal

  OfficeArchitecture = strOSArch
  If strOSArch = "x86" Then
    Exit Function
  End If
  strRegVal = RegRead(objShell, strRegKeyOfficePrefix_Mx86 & strVersionInfix & strRegKeyOfficeSuffix_Outlook & strRegValOfficeArchitecture)
  If strRegVal <> "" Then
    OfficeArchitecture = strRegVal
    Exit Function
  End If
  If InStr(strOfficeInstPath, "x86") > 0 Then
    OfficeArchitecture = "x86"
    Exit Function
  End If
End Function

Private Function OfficeSPVersion(strExeVersion, idxApp)
Dim arrayVersion, arraySPs, arrayBuilds, i

  OfficeSPVersion = 0
  arrayVersion = Split(strExeVersion, ".")
  Select Case CInt(arrayVersion(0))
    Case 15
      arraySPs = Split(strBuildNumbers_o2k13, ";")
    Case 16
      arraySPs = Split(strBuildNumbers_o2k16, ";")
    Case Else
      arraySPs = Split("0,0,0,0,0,0", ";")
  End Select
  If UBound(arrayVersion) < idxBuild Then
    Exit Function
  End If
  For i = 0 To UBound(arraySPs)
    arrayBuilds = Split(arraySPs(i), ",")
    If UBound(arrayBuilds) < idxApp Then
      Exit Function
    End If
    If CInt(arrayVersion(idxBuild)) >= CInt(arrayBuilds(idxApp)) Then
      OfficeSPVersion = i
    End If
  Next
End Function

' Main
Set wshShell = WScript.CreateObject("WScript.Shell")
strSystemFolder = wshShell.ExpandEnvironmentStrings("%SystemRoot%") & "\system32"
strTempFolder = wshShell.ExpandEnvironmentStrings("%TEMP%")
strProfileFolder = wshShell.ExpandEnvironmentStrings("%USERPROFILE%")
strWUAFileName = strSystemFolder & "\wuaueng.dll"
strMSIFileName = strSystemFolder & "\msi.dll"
strWSHFileName = strSystemFolder & "\vbscript.dll"
strTSCFileName = strSystemFolder & "\mstsc.exe"
If WScript.Arguments.Count = 0 Then
  strCmdFileName = strProfileFolder & "\Desktop\WOUSystemProperties.txt"
Else
  If LCase(WScript.Arguments(0)) = "/nodebug" Then
    strCmdFileName = strTempFolder & "\SetSystemEnvVars.cmd"
  Else
    strCmdFileName = strProfileFolder & "\Desktop\WOUSystemProperties.txt"
  End If
End If
Set objFileSystem = CreateObject("Scripting.FileSystemObject")
Set objCmdFile = objFileSystem.CreateTextFile(strCmdFileName, True)

' Determine basic system properties
Set objWMIService = GetObject("winmgmts:" & "{impersonationLevel=impersonate}!\\.\root\cimv2")
' Documentation: http://msdn.microsoft.com/en-us/library/aa394239(VS.85).aspx
For Each objQueryItem in objWMIService.ExecQuery("Select * from Win32_OperatingSystem")
  If RegExists(wshShell, strRegKeyWindowsVersion & strRegValUBR) Then
    strUBR = RegRead(wshShell, strRegKeyWindowsVersion & strRegValUBR)
    WriteVersionToFile objCmdFile, "OS_VER", objQueryItem.Version & "." & strUBR
  Else
    strBuildLabEx = RegRead(wshShell, strRegKeyWindowsVersion & strRegValBuildLabEx)
    If strBuildLabEx = "" Then
      WriteVersionToFile objCmdFile, "OS_VER", objQueryItem.Version
    Else
      WriteVersionToFile objCmdFile, "OS_VER", objQueryItem.Version & Mid(strBuildLabEx, InStr(strBuildLabEx, "."), InStr(InStr(strBuildLabEx, ".") + 1, strBuildLabEx, ".") - InStr(strBuildLabEx, "."))
    End If
  End If
  ServicingStack_OSVer_Major = CInt(Split(objQueryItem.Version, ".")(0))
  ServicingStack_OSVer_Minor = CInt(Split(objQueryItem.Version, ".")(1))
  ServicingStack_OSVer_Build = CInt(Split(objQueryItem.Version, ".")(2))
  objCmdFile.WriteLine("set OS_SP_VER_MAJOR=" & objQueryItem.ServicePackMajorVersion)
  objCmdFile.WriteLine("set OS_SP_VER_MINOR=" & objQueryItem.ServicePackMinorVersion)
  objCmdFile.WriteLine("set OS_LANG_CODE=0x" & Hex(objQueryItem.OSLanguage))
  WriteLanguageToFile objCmdFile, "OS_LANG", objQueryItem.OSLanguage, True, True
  strInstallationType = RegRead(wshShell, strRegKeyWindowsVersion & strRegValInstallationType)
  If InStr(1, strInstallationType, "Core", vbTextCompare) > 0 Then
    objCmdFile.WriteLine("set OS_SRV_CORE=1")
  End If
  If CInt(Split(objQueryItem.Version, ".")(0)) < 6 Then
    ' Windows 2000, Windows XP, Windows Server 2003 never got SHA2-support
    objCmdFile.WriteLine("set OS_SHA2_SUPPORT=0")
  ElseIf CInt(Split(objQueryItem.Version, ".")(0)) = 6 Then
    If CInt(Split(objQueryItem.Version, ".")(1)) = 0 Then
      ' Windows Vista never got SHA2-support
      ' Windows Server 2008 needs an update for SHA2-support
      If RegExists(wshShell, strRegKeySHA2Support & strRegValSHA2Support) And RegExists(wshShell, strRegKeySHA2Support & strRegValSHA2Support2) Then
        If (CInt(RegRead(wshShell, strRegKeySHA2Support & strRegValSHA2Support)) > 0) And (CInt(RegRead(wshShell, strRegKeySHA2Support & strRegValSHA2Support2)) > 0) Then
          objCmdFile.WriteLine("set OS_SHA2_SUPPORT=1")
        Else
          objCmdFile.WriteLine("set OS_SHA2_SUPPORT=0")
        End If
	  Else
        objCmdFile.WriteLine("set OS_SHA2_SUPPORT=0")
	  End If
    ElseIf CInt(Split(objQueryItem.Version, ".")(1)) = 1 Then
      ' Windows 7 / Windows Server 2008 R2 needs an update for SHA2-support
      If RegExists(wshShell, strRegKeySHA2Support & strRegValSHA2Support) And RegExists(wshShell, strRegKeySHA2Support & strRegValSHA2Support2) Then
        If (CInt(RegRead(wshShell, strRegKeySHA2Support & strRegValSHA2Support)) > 0) And (CInt(RegRead(wshShell, strRegKeySHA2Support & strRegValSHA2Support2)) > 0) Then
          objCmdFile.WriteLine("set OS_SHA2_SUPPORT=1")
        Else
          objCmdFile.WriteLine("set OS_SHA2_SUPPORT=0")
        End If
	  Else
        objCmdFile.WriteLine("set OS_SHA2_SUPPORT=0")
	  End If
    ElseIf CInt(Split(objQueryItem.Version, ".")(1)) >= 2 Then
      ' Windows 8 / Windows Server 2012, Windows 8.1 / Windows Server 2012 R2 have native SHA2-support
      objCmdFile.WriteLine("set OS_SHA2_SUPPORT=1")
	End If
  ElseIf CInt(Split(objQueryItem.Version, ".")(0)) > 6 Then
    ' Windows 10 / Windows Server 2016 / Windows Server 2019 have native SHA2-support
    objCmdFile.WriteLine("set OS_SHA2_SUPPORT=1")
  End If
  objCmdFile.WriteLine("set SystemDirectory=" & objQueryItem.SystemDirectory)
Next
' Documentation: http://msdn.microsoft.com/en-us/library/aa394102(VS.85).aspx
For Each objQueryItem in objWMIService.ExecQuery("Select * from Win32_ComputerSystem")
  strOSArchitecture = LCase(Left(objQueryItem.SystemType, 3))
  objCmdFile.WriteLine("set OS_ARCH=" & strOSArchitecture)
  objCmdFile.WriteLine("set OS_DOMAIN_ROLE=" & objQueryItem.DomainRole)
  objCmdFile.WriteLine("set OS_RAM_GB=" & CInt(CDbl(objQueryItem.TotalPhysicalMemory) / 1073741824))
Next
' Documentation: https://msdn.microsoft.com/en-us/library/aa394418(v=vs.85).aspx
For Each objQueryItem in objWMIService.ExecQuery("Select * from Win32_Service Where Name = 'wuauserv'")
  objCmdFile.WriteLine("set WU_START_MODE=" & objQueryItem.StartMode)
Next
' Documentation: http://msdn.microsoft.com/en-us/library/hww8txat(v=VS.85).aspx
objCmdFile.WriteLine("set FS_TYPE=" & objFileSystem.GetDrive(objFileSystem.GetDriveName(wshShell.CurrentDirectory)).FileSystem)

' Determine Servicing Stack version
If ServicingStack_OSVer_Major >= 6 Then
  ServicingStack_Major = 0
  ServicingStack_Minor = 0
  ServicingStack_Build = 0
  ServicingStack_Revis = 0
  For Each objFolder In objFileSystem.GetFolder(wshShell.ExpandEnvironmentStrings("%SystemRoot%") & "\servicing\Version").SubFolders
    If (CInt(Split(objFolder.Name, ".")(0)) = ServicingStack_OSVer_Major) And (CInt(Split(objFolder.Name, ".")(1)) = ServicingStack_OSVer_Minor) And ((ServicingStack_OSVer_Major = 6) Or (CInt(Split(objFolder.Name, ".")(2)) = ServicingStack_OSVer_Build)) Then
      If CInt(Split(objFolder.Name, ".")(0)) > ServicingStack_Major Then
        ServicingStack_Major = CInt(Split(objFolder.Name, ".")(0))
        ServicingStack_Minor = CInt(Split(objFolder.Name, ".")(1))
        ServicingStack_Build = CInt(Split(objFolder.Name, ".")(2))
        ServicingStack_Revis = CInt(Split(objFolder.Name, ".")(3))
      ElseIf (CInt(Split(objFolder.Name, ".")(0)) = ServicingStack_Major) And (CInt(Split(objFolder.Name, ".")(1)) > ServicingStack_Minor) Then
        ServicingStack_Major = CInt(Split(objFolder.Name, ".")(0))
        ServicingStack_Minor = CInt(Split(objFolder.Name, ".")(1))
        ServicingStack_Build = CInt(Split(objFolder.Name, ".")(2))
        ServicingStack_Revis = CInt(Split(objFolder.Name, ".")(3))
      ElseIf (CInt(Split(objFolder.Name, ".")(0)) = ServicingStack_Major) And (CInt(Split(objFolder.Name, ".")(1)) = ServicingStack_Minor) And (CInt(Split(objFolder.Name, ".")(2)) > ServicingStack_Build) Then
        ServicingStack_Major = CInt(Split(objFolder.Name, ".")(0))
        ServicingStack_Minor = CInt(Split(objFolder.Name, ".")(1))
        ServicingStack_Build = CInt(Split(objFolder.Name, ".")(2))
        ServicingStack_Revis = CInt(Split(objFolder.Name, ".")(3))
      ElseIf (CInt(Split(objFolder.Name, ".")(0)) = ServicingStack_Major) And (CInt(Split(objFolder.Name, ".")(1)) = ServicingStack_Minor) And (CInt(Split(objFolder.Name, ".")(2)) = ServicingStack_Build) And (CInt(Split(objFolder.Name, ".")(3)) > ServicingStack_Revis) Then
        ServicingStack_Major = CInt(Split(objFolder.Name, ".")(0))
        ServicingStack_Minor = CInt(Split(objFolder.Name, ".")(1))
        ServicingStack_Build = CInt(Split(objFolder.Name, ".")(2))
        ServicingStack_Revis = CInt(Split(objFolder.Name, ".")(3))
      End If
    End If
  Next
  objCmdFile.WriteLine("set SERVICING_VER_MAJOR=" & ServicingStack_Major)
  objCmdFile.WriteLine("set SERVICING_VER_MINOR=" & ServicingStack_Minor)
  objCmdFile.WriteLine("set SERVICING_VER_BUILD=" & ServicingStack_Build)
  objCmdFile.WriteLine("set SERVICING_VER_REVIS=" & ServicingStack_Revis)
End If

' Determine Windows Update Agent version
If objFileSystem.FileExists(strWUAFileName) Then
  WriteVersionToFile objCmdFile, "WUA_VER", GetFileVersion(objFileSystem, strWUAFileName)
Else
  WriteVersionToFile objCmdFile, "WUA_VER", ""
End If

' Determine Microsoft Installer version
If objFileSystem.FileExists(strMSIFileName) Then
  WriteVersionToFile objCmdFile, "MSI_VER", GetFileVersion(objFileSystem, strMSIFileName)
Else
  WriteVersionToFile objCmdFile, "MSI_VER", ""
End If

' Determine Windows Script Host version
If objFileSystem.FileExists(strWSHFileName) Then
  WriteVersionToFile objCmdFile, "WSH_VER", GetFileVersion(objFileSystem, strWSHFileName)
Else
  WriteVersionToFile objCmdFile, "WSH_VER", ""
End If

' Determine Internet Explorer version
WriteVersionToFile objCmdFile, "IE_VER", RegRead(wshShell, strRegKeyIE & strRegValVersion)

' Determine Microsoft Silverlight version
If RegExists(wshShell, strRegKeyMSSL_x64) Then
  WriteVersionToFile objCmdFile, "MSSL_VER", RegRead(wshShell, strRegKeyMSSL_x64 & strRegValVersion)
Else
  WriteVersionToFile objCmdFile, "MSSL_VER", RegRead(wshShell, strRegKeyMSSL_x86 & strRegValVersion)
End If

' Determine Microsoft .NET Framework 3.5 SP1 installation state
WriteVersionToFile objCmdFile, "DOTNET35_VER", RegRead(wshShell, strRegKeyDotNet35 & strRegValVersion)
WriteVersionToFile objCmdFile, "DOTNET4_VER", RegRead(wshShell, strRegKeyDotNet4 & strRegValVersion)
objCmdFile.WriteLine("set DOTNET4_RELEASE=" & RegRead(wshShell, strRegKeyDotNet4 & strRegValRelease))

' Determine Windows PowerShell version
WriteVersionToFile objCmdFile, "PSH_VER", RegRead(wshShell, strRegKeyPowerShell & strRegValPShVersion)

' Determine Windows Management Framework version
WriteVersionToFile objCmdFile, "WMF_VER", RegRead(wshShell, strRegKeyManagementFramework & strRegValPShVersion)

' Determine Microsoft Security Essentials installation state
If RegExists(wshShell, strRegKeyMSSE) Then
  objCmdFile.WriteLine("set MSSE_INSTALLED=1")
Else
  objCmdFile.WriteLine("set MSSE_INSTALLED=0")
End If

' Determine Microsoft Security Essentials' version
WriteVersionToFile objCmdFile, "MSSE_VER", RegRead(wshShell, strRegKeyMSSEUninstall & strRegValDisplayVersion)

' Determine Microsoft Antimalware signatures' version
WriteVersionToFile objCmdFile, "MSSEDEFS_VER", RegRead(wshShell, strRegKeyMSSEDefs & strRegValAVSVersion)

' Determine Network Inspection System definitions' version
WriteVersionToFile objCmdFile, "NISDEFS_VER", RegRead(wshShell, strRegKeyMSSEDefs & strRegValNISSVersion)

' Determine Windows Defender installation state
If RegExists(wshShell, strRegKeyWD) Then
  objCmdFile.WriteLine("set WD_INSTALLED=1")
Else
  objCmdFile.WriteLine("set WD_INSTALLED=0")
End If

' Determine Windows Defender state
If ( (RegRead(wshShell, strRegKeyWD & strRegValDisableAntiSpyware) = "1") _
  Or (RegRead(wshShell, strRegKeyWDPolicy & strRegValDisableAntiSpyware) = "1") ) Then
  objCmdFile.WriteLine("set WD_DISABLED=1")
Else
  objCmdFile.WriteLine("set WD_DISABLED=0")
End If

' Determine Microsoft Antispyware signatures' version
WriteVersionToFile objCmdFile, "WDDEFS_VER", RegRead(wshShell, strRegKeyWDDefs & strRegValASSVersion)

' Determine Remote Desktop Connection (Terminal Services Client) version
If objFileSystem.FileExists(strTSCFileName) Then
  WriteVersionToFile objCmdFile, "TSC_VER", GetFileVersion(objFileSystem, strTSCFileName)
Else
  WriteVersionToFile objCmdFile, "TSC_VER", ""
End If

' Check quality compatibility registry value
If RegExists(wshShell, strRegKeyQualityCompat) Then
  objCmdFile.WriteLine("set QC_SET=1")
Else
  objCmdFile.WriteLine("set QC_SET=0")
End If

' Determine Office version
arrayOfficeNames = Split(strOfficeNames, ",")
arrayOfficeVersions = Split(strRegKeyOfficeInfixes_Version, ",")
arrayOfficeAppNames = Split(strOfficeAppNames, ",")
arrayOfficeExeNames = Split(strOfficeExeNames, ",")
For i = 0 To UBound(arrayOfficeNames)
  strOfficeInstallPath = OfficeInstallPath(wshShell, arrayOfficeVersions(i))
  If strOfficeInstallPath <> "" Then
    For j = 0 To UBound(arrayOfficeExeNames)
      If objFileSystem.FileExists(strOfficeInstallPath & arrayOfficeExeNames(j)) Then
        objCmdFile.WriteLine("set " & UCase(arrayOfficeNames(i)) & "_VER_APP=" & arrayOfficeAppNames(j))
        strOfficeExeVersion = GetFileVersion(objFileSystem, strOfficeInstallPath & arrayOfficeExeNames(j))
        WriteVersionToFile objCmdFile, UCase(arrayOfficeNames(i)) & "_VER", strOfficeExeVersion
        objCmdFile.WriteLine("set " & UCase(arrayOfficeNames(i)) & "_SP_VER=" & OfficeSPVersion(strOfficeExeVersion, j))
        objCmdFile.WriteLine("set " & UCase(arrayOfficeNames(i)) & "_ARCH=" & OfficeArchitecture(wshShell, strOSArchitecture, arrayOfficeVersions(i), strOfficeInstallPath))
        languageCode = OfficeLanguageCode(wshShell, arrayOfficeVersions(i))
        objCmdFile.WriteLine("set " & UCase(arrayOfficeNames(i)) & "_LANG_CODE=0x" & Hex(languageCode))
        If languageCode = 0 Then
          objCmdFile.WriteLine("set " & UCase(arrayOfficeNames(i)) & "_LANG=%OS_LANG%")
        Else
          WriteLanguageToFile objCmdFile, UCase(arrayOfficeNames(i)) & "_LANG", languageCode, False, False
        End If
        Exit For
      End If
    Next
  End If
Next

' Determine installed products (for C++)
cpp2005_x86_old = False
cpp2005_x86_new = False
cpp2005_x64_old = False
cpp2005_x64_new = False
cpp2008_x86_old = False
cpp2008_x86_new = False
cpp2008_x64_old = False
cpp2008_x64_new = False
cpp2010_x86_old = False
cpp2010_x86_new = False
cpp2010_x64_old = False
cpp2010_x64_new = False
cpp2012_x86_old = False
cpp2012_x86_new = False
cpp2012_x64_old = False
cpp2012_x64_new = False
cpp2013_x86_old = False
cpp2013_x86_new = False
cpp2013_x64_old = False
cpp2013_x64_new = False
cpp2019_x86_old = False
cpp2019_x86_new = False
cpp2019_x64_old = False
cpp2019_x64_new = False

If objFileSystem.FileExists("..\static\StaticUpdateIds-cpp2005_x86_old.txt") Then
  Set objStaticFile = objFileSystem.OpenTextFile("..\static\StaticUpdateIds-cpp2005_x86_old.txt")
  cpp2005_x86_old_ids = Split(objStaticFile.ReadAll)
  objStaticFile.Close
Else
  cpp2005_x86_old_ids = Split("")
End If
If objFileSystem.FileExists("..\static\StaticUpdateIds-cpp2005_x86_new.txt") Then
  Set objStaticFile = objFileSystem.OpenTextFile("..\static\StaticUpdateIds-cpp2005_x86_new.txt")
  cpp2005_x86_new_ids = Split(objStaticFile.ReadAll)
  objStaticFile.Close
Else
  cpp2005_x86_new_ids = Split("")
End If
If objFileSystem.FileExists("..\static\StaticUpdateIds-cpp2005_x64_old.txt") Then
  Set objStaticFile = objFileSystem.OpenTextFile("..\static\StaticUpdateIds-cpp2005_x64_old.txt")
  cpp2005_x64_old_ids = Split(objStaticFile.ReadAll)
  objStaticFile.Close
Else
  cpp2005_x64_old_ids = Split("")
End If
If objFileSystem.FileExists("..\static\StaticUpdateIds-cpp2005_x64_new.txt") Then
  Set objStaticFile = objFileSystem.OpenTextFile("..\static\StaticUpdateIds-cpp2005_x64_new.txt")
  cpp2005_x64_new_ids = Split(objStaticFile.ReadAll)
  objStaticFile.Close
Else
  cpp2005_x64_new_ids = Split("")
End If
If objFileSystem.FileExists("..\static\StaticUpdateIds-cpp2008_x86_old.txt") Then
  Set objStaticFile = objFileSystem.OpenTextFile("..\static\StaticUpdateIds-cpp2008_x86_old.txt")
  cpp2008_x86_old_ids = Split(objStaticFile.ReadAll)
  objStaticFile.Close
Else
  cpp2008_x86_old_ids = Split("")
End If
If objFileSystem.FileExists("..\static\StaticUpdateIds-cpp2008_x86_new.txt") Then
  Set objStaticFile = objFileSystem.OpenTextFile("..\static\StaticUpdateIds-cpp2008_x86_new.txt")
  cpp2008_x86_new_ids = Split(objStaticFile.ReadAll)
  objStaticFile.Close
Else
  cpp2008_x86_new_ids = Split("")
End If
If objFileSystem.FileExists("..\static\StaticUpdateIds-cpp2008_x64_old.txt") Then
  Set objStaticFile = objFileSystem.OpenTextFile("..\static\StaticUpdateIds-cpp2008_x64_old.txt")
  cpp2008_x64_old_ids = Split(objStaticFile.ReadAll)
  objStaticFile.Close
Else
  cpp2008_x64_old_ids = Split("")
End If
If objFileSystem.FileExists("..\static\StaticUpdateIds-cpp2008_x64_new.txt") Then
  Set objStaticFile = objFileSystem.OpenTextFile("..\static\StaticUpdateIds-cpp2008_x64_new.txt")
  cpp2008_x64_new_ids = Split(objStaticFile.ReadAll)
  objStaticFile.Close
Else
  cpp2008_x64_new_ids = Split("")
End If
'If objFileSystem.FileExists("..\static\StaticUpdateIds-cpp2010_x86_old.txt") Then
'  Set objStaticFile = objFileSystem.OpenTextFile("..\static\StaticUpdateIds-cpp2010_x86_old.txt")
'  cpp2010_x86_old_ids = Split(objStaticFile.ReadAll)
'  objStaticFile.Close
'Else
'  cpp2010_x86_old_ids = Split("")
'End If
'If objFileSystem.FileExists("..\static\StaticUpdateIds-cpp2010_x86_new.txt") Then
'  Set objStaticFile = objFileSystem.OpenTextFile("..\static\StaticUpdateIds-cpp2010_x86_new.txt")
'  cpp2010_x86_new_ids = Split(objStaticFile.ReadAll)
'  objStaticFile.Close
'Else
'  cpp2010_x86_new_ids = Split("")
'End If
'If objFileSystem.FileExists("..\static\StaticUpdateIds-cpp2010_x64_old.txt") Then
'  Set objStaticFile = objFileSystem.OpenTextFile("..\static\StaticUpdateIds-cpp2010_x64_old.txt")
'  cpp2010_x64_old_ids = Split(objStaticFile.ReadAll)
'  objStaticFile.Close
'Else
'  cpp2010_x64_old_ids = Split("")
'End If
'If objFileSystem.FileExists("..\static\StaticUpdateIds-cpp2010_x64_new.txt") Then
'  Set objStaticFile = objFileSystem.OpenTextFile("..\static\StaticUpdateIds-cpp2010_x64_new.txt")
'  cpp2010_x64_new_ids = Split(objStaticFile.ReadAll)
'  objStaticFile.Close
'Else
'  cpp2010_x64_new_ids = Split("")
'End If
If objFileSystem.FileExists("..\static\StaticUpdateIds-cpp2012_x86_old.txt") Then
  Set objStaticFile = objFileSystem.OpenTextFile("..\static\StaticUpdateIds-cpp2012_x86_old.txt")
  cpp2012_x86_old_ids = Split(objStaticFile.ReadAll)
  objStaticFile.Close
Else
  cpp2012_x86_old_ids = Split("")
End If
If objFileSystem.FileExists("..\static\StaticUpdateIds-cpp2012_x86_new.txt") Then
  Set objStaticFile = objFileSystem.OpenTextFile("..\static\StaticUpdateIds-cpp2012_x86_new.txt")
  cpp2012_x86_new_ids = Split(objStaticFile.ReadAll)
  objStaticFile.Close
Else
  cpp2012_x86_new_ids = Split("")
End If
If objFileSystem.FileExists("..\static\StaticUpdateIds-cpp2012_x64_old.txt") Then
  Set objStaticFile = objFileSystem.OpenTextFile("..\static\StaticUpdateIds-cpp2012_x64_old.txt")
  cpp2012_x64_old_ids = Split(objStaticFile.ReadAll)
  objStaticFile.Close
Else
  cpp2012_x64_old_ids = Split("")
End If
If objFileSystem.FileExists("..\static\StaticUpdateIds-cpp2012_x64_new.txt") Then
  Set objStaticFile = objFileSystem.OpenTextFile("..\static\StaticUpdateIds-cpp2012_x64_new.txt")
  cpp2012_x64_new_ids = Split(objStaticFile.ReadAll)
  objStaticFile.Close
Else
  cpp2012_x64_new_ids = Split("")
End If
If objFileSystem.FileExists("..\static\StaticUpdateIds-cpp2013_x86_old.txt") Then
  Set objStaticFile = objFileSystem.OpenTextFile("..\static\StaticUpdateIds-cpp2013_x86_old.txt")
  cpp2013_x86_old_ids = Split(objStaticFile.ReadAll)
  objStaticFile.Close
Else
  cpp2013_x86_old_ids = Split("")
End If
If objFileSystem.FileExists("..\static\StaticUpdateIds-cpp2013_x86_new.txt") Then
  Set objStaticFile = objFileSystem.OpenTextFile("..\static\StaticUpdateIds-cpp2013_x86_new.txt")
  cpp2013_x86_new_ids = Split(objStaticFile.ReadAll)
  objStaticFile.Close
Else
  cpp2013_x86_new_ids = Split("")
End If
If objFileSystem.FileExists("..\static\StaticUpdateIds-cpp2013_x64_old.txt") Then
  Set objStaticFile = objFileSystem.OpenTextFile("..\static\StaticUpdateIds-cpp2013_x64_old.txt")
  cpp2013_x64_old_ids = Split(objStaticFile.ReadAll)
  objStaticFile.Close
Else
  cpp2013_x64_old_ids = Split("")
End If
If objFileSystem.FileExists("..\static\StaticUpdateIds-cpp2013_x64_new.txt") Then
  Set objStaticFile = objFileSystem.OpenTextFile("..\static\StaticUpdateIds-cpp2013_x64_new.txt")
  cpp2013_x64_new_ids = Split(objStaticFile.ReadAll)
  objStaticFile.Close
Else
  cpp2013_x64_new_ids = Split("")
End If
If objFileSystem.FileExists("..\static\StaticUpdateIds-cpp2015_x86_old.txt") Then
  Set objStaticFile = objFileSystem.OpenTextFile("..\static\StaticUpdateIds-cpp2015_x86_old.txt")
  cpp2015_x86_old_ids = Split(objStaticFile.ReadAll)
  objStaticFile.Close
Else
  cpp2015_x86_old_ids = Split("")
End If
If objFileSystem.FileExists("..\static\StaticUpdateIds-cpp2015_x86_new.txt") Then
  Set objStaticFile = objFileSystem.OpenTextFile("..\static\StaticUpdateIds-cpp2015_x86_new.txt")
  cpp2015_x86_new_ids = Split(objStaticFile.ReadAll)
  objStaticFile.Close
Else
  cpp2015_x86_new_ids = Split("")
End If
If objFileSystem.FileExists("..\static\StaticUpdateIds-cpp2015_x64_old.txt") Then
  Set objStaticFile = objFileSystem.OpenTextFile("..\static\StaticUpdateIds-cpp2015_x64_old.txt")
  cpp2015_x64_old_ids = Split(objStaticFile.ReadAll)
  objStaticFile.Close
Else
  cpp2015_x64_old_ids = Split("")
End If
If objFileSystem.FileExists("..\static\StaticUpdateIds-cpp2015_x64_new.txt") Then
  Set objStaticFile = objFileSystem.OpenTextFile("..\static\StaticUpdateIds-cpp2015_x64_new.txt")
  cpp2015_x64_new_ids = Split(objStaticFile.ReadAll)
  objStaticFile.Close
Else
  cpp2015_x64_new_ids = Split("")
End If

Set objInstaller = CreateObject("WindowsInstaller.Installer")
For Each strProduct In objInstaller.Products

  ' Documentation: http://blogs.msdn.com/b/astebner/archive/2007/01/16/mailbag-how-to-detect-the-presence-of-the-vc-8-0-runtime-redistributable-package.aspx
  ' C++ 2005 (x86)
  For i = 0 To UBound(cpp2005_x86_old_ids)
    If UCase(strProduct) = UCase(cpp2005_x86_old_ids(i)) Then
      cpp2005_x86_old = True
    End If
  Next
  For i = 0 To UBound(cpp2005_x86_new_ids)
    If UCase(strProduct) = UCase(cpp2005_x86_new_ids(i)) Then
      cpp2005_x86_new = True
    End If
  Next
  ' C++ 2005 (x64)
  For i = 0 To UBound(cpp2005_x64_old_ids)
    If UCase(strProduct) = UCase(cpp2005_x64_old_ids(i)) Then
      cpp2005_x64_old = True
    End If
  Next
  For i = 0 To UBound(cpp2005_x64_new_ids)
    If UCase(strProduct) = UCase(cpp2005_x64_new_ids(i)) Then
      cpp2005_x64_new = True
    End If
  Next

  ' Documentation: http://blogs.msdn.com/b/astebner/archive/2009/01/29/9384143.aspx
  ' C++ 2008 (x86)
  For i = 0 To UBound(cpp2008_x86_old_ids)
    If UCase(strProduct) = UCase(cpp2008_x86_old_ids(i)) Then
      cpp2008_x86_old = True
    End If
  Next
  For i = 0 To UBound(cpp2008_x86_new_ids)
    If UCase(strProduct) = UCase(cpp2008_x86_new_ids(i)) Then
      cpp2008_x86_new = True
    End If
  Next
  ' C++ 2008 (x64)
  For i = 0 To UBound(cpp2008_x64_old_ids)
    If UCase(strProduct) = UCase(cpp2008_x64_old_ids(i)) Then
      cpp2008_x64_old = True
    End If
  Next
  For i = 0 To UBound(cpp2008_x64_new_ids)
    If UCase(strProduct) = UCase(cpp2008_x64_new_ids(i)) Then
      cpp2008_x64_new = True
    End If
  Next

  ' C++ 2010 nach altem Mechanismus
  ' Documentation: http://blogs.msdn.com/b/astebner/archive/2010/05/05/10008146.aspx
  Select Case UCase(strProduct)
    Case "{196BB40D-1578-3D01-B289-BEFC77A11A1E}", "{F0C3E5D1-1ADE-321E-8167-68EF0DE699A5}"
      cpp2010_x86_old = True
      For Each strPatch In objInstaller.Patches(strProduct)
        If UCase(strPatch) = "{F11DB03E-9EFF-3E33-8D0D-827AB22DAB1B}" Then cpp2010_x86_new = True
      Next
    Case "{DA5E371C-6333-3D8A-93A4-6FD5B20BCC6E}", "{1D8E6291-B0D5-35EC-8441-6616F567A0F7}"
      cpp2010_x64_old = True
      For Each strPatch In objInstaller.Patches(strProduct)
        If UCase(strPatch) = "{45C1B2E6-FE51-3FDA-81C6-5C8602F9B025}" Then cpp2010_x64_new = True
      Next
  End Select

  ' C++ 2012 (x86)
  For i = 0 To UBound(cpp2012_x86_old_ids)
    If UCase(strProduct) = UCase(cpp2012_x86_old_ids(i)) Then
      cpp2012_x86_old = True
    End If
  Next
  For i = 0 To UBound(cpp2012_x86_new_ids)
    If UCase(strProduct) = UCase(cpp2012_x86_new_ids(i)) Then
      cpp2012_x86_new = True
    End If
  Next
  ' C++ 2012 (x64)
  For i = 0 To UBound(cpp2012_x64_old_ids)
    If UCase(strProduct) = UCase(cpp2012_x64_old_ids(i)) Then
      cpp2012_x64_old = True
    End If
  Next
  For i = 0 To UBound(cpp2012_x64_new_ids)
    If UCase(strProduct) = UCase(cpp2012_x64_new_ids(i)) Then
      cpp2012_x64_new = True
    End If
  Next

  ' C++ 2013 (x86)
  For i = 0 To UBound(cpp2013_x86_old_ids)
    If UCase(strProduct) = UCase(cpp2013_x86_old_ids(i)) Then
      cpp2013_x86_old = True
    End If
  Next
  For i = 0 To UBound(cpp2013_x86_new_ids)
    If UCase(strProduct) = UCase(cpp2013_x86_new_ids(i)) Then
      cpp2013_x86_new = True
    End If
  Next
  ' C++ 2013 (x64)
  For i = 0 To UBound(cpp2013_x64_old_ids)
    If UCase(strProduct) = UCase(cpp2013_x64_old_ids(i)) Then
      cpp2013_x64_old = True
    End If
  Next
  For i = 0 To UBound(cpp2013_x64_new_ids)
    If UCase(strProduct) = UCase(cpp2013_x64_new_ids(i)) Then
      cpp2013_x64_new = True
    End If
  Next

  ' C++ 2015-2019 (x86)
  For i = 0 To UBound(cpp2015_x86_old_ids)
    If UCase(strProduct) = UCase(cpp2015_x86_old_ids(i)) Then
      cpp2015_x86_old = True
    End If
  Next
  For i = 0 To UBound(cpp2015_x86_new_ids)
    If UCase(strProduct) = UCase(cpp2015_x86_new_ids(i)) Then
      cpp2015_x86_new = True
    End If
  Next
  ' C++ 2015-2019 (x64)
  For i = 0 To UBound(cpp2015_x64_old_ids)
    If UCase(strProduct) = UCase(cpp2015_x64_old_ids(i)) Then
      cpp2015_x64_old = True
    End If
  Next
  For i = 0 To UBound(cpp2015_x64_new_ids)
    If UCase(strProduct) = UCase(cpp2015_x64_new_ids(i)) Then
      cpp2015_x64_new = True
    End If
  Next
Next

If (cpp2005_x86_old) And (Not cpp2005_x86_new) Then objCmdFile.WriteLine("set CPP_2005_x86=1")
If (cpp2005_x64_old) And (Not cpp2005_x64_new) Then objCmdFile.WriteLine("set CPP_2005_x64=1")
If (cpp2008_x86_old) And (Not cpp2008_x86_new) Then objCmdFile.WriteLine("set CPP_2008_x86=1")
If (cpp2008_x64_old) And (Not cpp2008_x64_new) Then objCmdFile.WriteLine("set CPP_2008_x64=1")
If (cpp2010_x86_old) And (Not cpp2010_x86_new) Then objCmdFile.WriteLine("set CPP_2010_x86=1")
If (cpp2010_x64_old) And (Not cpp2010_x64_new) Then objCmdFile.WriteLine("set CPP_2010_x64=1")
If (cpp2012_x86_old) And (Not cpp2012_x86_new) Then objCmdFile.WriteLine("set CPP_2012_x86=1")
If (cpp2012_x64_old) And (Not cpp2012_x64_new) Then objCmdFile.WriteLine("set CPP_2012_x64=1")
If (cpp2013_x86_old) And (Not cpp2013_x86_new) Then objCmdFile.WriteLine("set CPP_2013_x86=1")
If (cpp2013_x64_old) And (Not cpp2013_x64_new) Then objCmdFile.WriteLine("set CPP_2013_x64=1")
If (cpp2015_x86_old) And (Not cpp2015_x86_new) Then objCmdFile.WriteLine("set CPP_2015_x86=1")
If (cpp2015_x64_old) And (Not cpp2015_x64_new) Then objCmdFile.WriteLine("set CPP_2015_x64=1")

objCmdFile.Close
WScript.Quit(0)
