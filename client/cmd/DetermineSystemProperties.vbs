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

Dim wshShell, objFileSystem, objCmdFile, objWMIService, objQueryItem, objFolder, objInstaller, arrayOfficeNames, arrayOfficeVersions, arrayOfficeAppNames, arrayOfficeExeNames
Dim strSystemFolder, strTempFolder, strProfileFolder, strWUAFileName, strMSIFileName, strWSHFileName, strTSCFileName, strCmdFileName
Dim strOSArchitecture, strUBR, strBuildLabEx, strInstallationType, strOfficeInstallPath, strOfficeExeVersion, strProduct, strPatch, languageCode, i, j
Dim ServicingStack_Major, ServicingStack_Minor, ServicingStack_Build, ServicingStack_Revis, ServicingStack_OSVer_Major, ServicingStack_OSVer_Minor, ServicingStack_OSVer_Build
Dim cpp2005_x86_old, cpp2005_x86_new, cpp2005_x64_old, cpp2005_x64_new
Dim cpp2008_x86_old, cpp2008_x86_new, cpp2008_x64_old, cpp2008_x64_new
Dim cpp2010_x86_old, cpp2010_x86_new, cpp2010_x64_old, cpp2010_x64_new
Dim cpp2012_x86_old, cpp2012_x86_new, cpp2012_x64_old, cpp2012_x64_new
Dim cpp2013_x86_old, cpp2013_x86_new, cpp2013_x64_old, cpp2013_x64_new
Dim cpp2019_x86_old, cpp2019_x86_new, cpp2019_x64_old, cpp2019_x64_new

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

' Determine installed products
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
Set objInstaller = CreateObject("WindowsInstaller.Installer")
For Each strProduct In objInstaller.Products
  Select Case UCase(strProduct)
    Case "{6EECB283-E65F-40EF-86D3-D51BF02A8D43}"
      objCmdFile.WriteLine("set OFC_CONV_PACK=1")
    Case "{90120000-0020-0407-0000-0000000FF1CE}"
      objCmdFile.WriteLine("set OFC_COMP_PACK=1")
    Case "{90140000-2005-0000-0000-0000000FF1CE}"
      objCmdFile.WriteLine("set OFC_FILE_VALID=1")
    ' Documentation: http://blogs.msdn.com/b/astebner/archive/2007/01/16/mailbag-how-to-detect-the-presence-of-the-vc-8-0-runtime-redistributable-package.aspx
    Case "{A49F249F-0C91-497F-86DF-B2585E8E76B7}", "{7299052B-02A4-4627-81F2-1818DA5D550D}", "{837B34E3-7C30-493C-8F6A-2B0F04E2912C}"
      cpp2005_x86_old = True
    Case "{710F4C1C-CC18-4C49-8CBF-51240C89A1A2}"
      cpp2005_x86_new = True
    Case "{6E8E85E8-CE4B-4FF5-91F7-04999C9FAE6A}", "{071C9B48-7C32-4621-A0AC-3F809523288F}", "{6CE5BAE9-D3CA-4B99-891A-1DC6C118A5FC}"
      cpp2005_x64_old = True
    Case "{AD8A2FA1-06E7-4B0D-927D-6E54B3D31028}"
      cpp2005_x64_new = True
    ' Documentation: http://blogs.msdn.com/b/astebner/archive/2009/01/29/9384143.aspx
    Case "{09298F26-A95C-31E2-9D95-2C60F586F075}", "{09C0A8D5-EEC1-369D-8C7A-2E2DD17DCA5E}", "{31B44A9A-7CFE-3039-AEAE-A664F3C5F7BD}", "{402ED4A1-8F5B-387A-8688-997ABF58B8F2}", _
         "{527BBE2F-1FED-3D8B-91CB-4DB0F838E69E}", "{57660847-B1F7-35BD-9118-F62EB863A598}", "{6AFCA4E1-9B78-3640-8F72-A7BF33448200}", "{820B6609-4C97-3A2B-B644-573B06A0F0CC}", _
         "{86CE1746-9EFF-3C9C-8755-81EA8903AC34}", "{887868A2-D6DE-3255-AA92-AA0B5A59B874}", "{9A25302D-30C0-39D9-BD6F-21E6EC160475}", "{9B775AA1-7B10-379A-9B16-7E373790568C}", _
         "{A09D5493-0D9F-3211-B3BF-DD7ABBB318C1}", "{CA8A885F-E95B-3FC6-BB91-F4D9377C7686}", "{CC1DB186-550F-3CFE-A2A9-EBA5E5A34BC1}", "{DCB46B42-723F-350E-B18A-449BC6C21636}", _
         "{F03CB3EF-DC16-35CE-B3C1-C68EA09E5E97}", "{F2E0402D-AA60-32E3-8480-39AD5CE79DF2}", "{FF66E9F6-83E7-3A3E-AF14-8DE9A809A6A4}", "{1F1C2DFC-2D24-3E06-BCB8-725134ADF989}"
      cpp2008_x86_old = True
    Case "{9BE518E6-ECC6-35A9-88E4-87755C07200F}"
      cpp2008_x86_new = True
    Case "{02A39130-2CF3-30CA-8623-30F6071A4221}", "{092EE08C-60DE-3FE6-B113-90076EC06D0D}", "{0A157668-EDB7-34C8-8C51-6A914CAC1EA6}", "{14297226-E0A0-3781-8911-E9D529552663}", _
         "{2DFD8316-9EF1-3210-908C-4CB61961C1AC}", "{32A08044-0CFA-3758-902C-5D97746BA9A9}", "{350AA351-21FA-3270-8B7A-835434E766AD}", "{484D36AC-327E-390E-85C8-9F2B176BA2B6}", _
         "{56F27690-F6EA-3356-980A-02BA379506EE}", "{6F29F195-B11C-3EAD-B883-997BB29DFA17}", "{8220EEFE-38CD-377E-8595-13398D740ACE}", "{92B8FD1F-C1AE-3750-8577-631B0AA85DF5}", _
         "{9B3F0A88-790D-3AD9-9F96-B19CF2746452}", "{9EDBA064-0381-3D1F-9096-CD1710366647}", "{A96702F7-EFC8-3EED-BE46-22C809D4EBE5}", "{D04659D1-EB2D-3DE5-A833-837A623CCCF7}", _
         "{D285FC5F-3021-32E9-9C59-24CA325BDC5C}", "{E34002C7-8CE7-3F76-B36C-09FA973BC4F6}", "{F1685080-A18F-39F7-87CC-1FC1C5357364}", "{4B6C7001-C7D6-3710-913E-5BC23FCE91E6}"
      cpp2008_x64_old = True
    Case "{5FCE6D76-F5DC-37AB-B2B8-22AB8CEDB1D4}"
      cpp2008_x64_new = True
    ' Documentation: http://blogs.msdn.com/b/astebner/archive/2010/05/05/10008146.aspx
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
    Case "{2F73A7B2-E50E-39A6-9ABC-EF89E4C62E36}", "{FDB30193-FDA0-3DAA-ACCA-A75EEFE53607}", _
         "{E824E81C-80A4-3DFF-B5F9-4842A9FF5F7F}", "{6C772996-BFF3-3C8C-860B-B3D48FF05D65}", _
         "{E7D4E834-93EB-351F-B8FB-82CDAE623003}", "{3D6AD258-61EA-35F5-812C-B7A02152996E}"
      cpp2012_x86_old = True
    Case "{BD95A8CD-1D9F-35AD-981A-3E7925026EBB}", "{B175520C-86A2-35A7-8619-86DC379688B9}"
      cpp2012_x86_new = True
    Case "{A2CB1ACB-94A2-32BA-A15E-7D80319F7589}", "{AC53FC8B-EE18-3F9C-9B59-60937D0B182C}", _
         "{5AF4E09F-5C9B-3AAF-B731-544D3DC821DD}", "{3C28BFD4-90C7-3138-87EF-418DC16E9598}", _
         "{2EDC2FA3-1F34-34E5-9085-588C9EFD1CC6}", "{764384C5-BCA9-307C-9AAC-FD443662686A}"
      cpp2012_x64_old = True
    Case "{CF2BEA3C-26EA-32F8-AA9B-331F7E34BA97}", "{37B8F9C7-03FB-3253-8781-2517C99D7C00}"
      cpp2012_x64_new = True
    Case "{13A4EE12-23EA-3371-91EE-EFB36DDFFF3E}", "{F8CFEB22-A2E7-3971-9EDA-4B11EDEFC185}", _
         "{DEA7F8E3-B7B9-3C3C-945B-7F8CE9041748}", "{A8589745-51BC-3963-B4E9-201CF8693538}", _
         "{E30D8B21-D82D-3211-82CC-0F0A5D1495E8}", "{7DAD0258-515C-3DD4-8964-BD714199E0F7}"
      cpp2013_x86_old = True
    Case "{8122DAB1-ED4D-3676-BB0A-CA368196543E}", "{D401961D-3A20-3AC7-943B-6139D5BD490A}"
      cpp2013_x86_new = True
    Case "{A749D8E6-B613-3BE3-8F5F-045C84EBA29B}", "{929FBD26-9020-399B-9A7A-751D61F0B942}", _
         "{ABB19BB4-838D-3082-BDA4-87C6604181A2}", "{20C1086D-C843-36B1-B678-990089D1BD44}", _
         "{CB0836EC-B072-368D-82B2-D3470BF95707}", "{5740BD44-B58D-321A-AFC0-6D3D4556DD6C}"
      cpp2013_x64_old = True
    Case "{53CF6934-A98D-3D84-9146-FC4EDF3D5641}", "{010792BA-551A-3AC0-A7EF-0FAB4156C382}"
      cpp2013_x64_new = True
    Case "{A2563E55-3BEC-3828-8D67-E5E8B9E8B675}", "{BE960C1C-7BAD-3DE6-8B1A-2616FE532845}", "{74d0e5db-b326-4dae-a6b2-445b9de1836e}", _
         "{65AD78AD-D23D-3A1E-9305-3AE65CD522C2}", "{1045AB6F-6151-3634-8C2C-EE308AA1A6A7}", "{23daf363-3020-4059-b3ae-dc4ad39fed19}", _
         "{B5FC62F5-A367-37A5-9FD2-A6E137C0096F}", "{BD9CFD69-EB91-354E-9C98-D439E6091932}", _
         "{8FD71E98-EE44-3844-9DAD-9CB0BBBC603C}", "{D8C8656B-0BD8-39C3-B741-F889B7C144E5}", _
         "{37B55901-995A-3650-80B1-BBFD047E2911}", "{844ECB74-9B63-3D5C-958C-30BD23F19EE4}", _
         "{BBF2AC74-720C-3CB3-8291-5E34039232FA}", "{69BCE4AC-9572-3271-A2FB-9423BDA36A43}", _
         "{C6CDA568-CD91-3CA0-9EDE-DAD98A13D6E1}", "{E6222D59-608C-3018-B86B-69BD241ACDE5}", _
         "{029DA848-1A80-34D3-BFC1-A6447BFC8E7F}", "{568CD07E-0824-3EEB-AEC1-8FD51F3C85CF}", _
         "{828952EB-5572-3666-8CA9-000B6CE79350}", "{7FED75A1-600C-394B-8376-712E2A8861F2}", _
         "{8F271F6C-6E7B-3D0A-951B-6E7B694D78BD}", "{895D5198-C5DB-375E-86AB-133F4DAA9FE2}", "{5C045B7F-E561-4794-91F8-C6CDA0893107}", _
         "{644544A0-318A-344C-964C-4DBE2FB5F864}", "{2BCACFA1-2BE1-373C-9051-76A9661D9FC4}", _
         "{7753EC39-3039-3629-98BE-447C5D869C09}", "{6F0267F3-7467-350D-A8C8-33B72E3658D8}", "{2019B6A0-8533-4A04-AC0E-B2C10BDB9841}", _
         "{39E15475-23F2-345D-8977-B5DC47A94E26}", "{2757496A-3E74-320A-B007-36120A9F126D}", _
         "{7B77DE7F-5219-435E-9CE1-FC77F1D4CCAD}", "{DD6BC8D7-4582-4677-BAAC-4AB933E6C315}", _
         "{5EEFCEFB-E5F7-4C82-99A5-813F04AA4FBD}", "{7258184A-EC44-4B1A-A7D3-68D85A35BFD0}", _
         "{B96F6FA1-530F-42F1-9F71-33C583716340}", "{C9DE51F8-7846-4621-815D-E8AFD3E3C0FF}", _
         "{19F7E289-17B8-44EC-A099-927507B6F739}", "{213668DB-2263-4E2D-ABB8-487FD539130E}", _
         "{1E6FC929-567E-4D22-9206-C5B83F0A21B9}", "{3BDE80F7-7EC9-448E-8160-4ADA0CDA8879}", _
         "{00AC3934-26B4-406E-807C-1692AC7329EC}", "{86BE78D9-65A1-4E69-86F8-C1F5281F8553}", _
         "{2E72FA1F-BADB-4337-B8AE-F7C17EC57D1D}", "{EAC73207-74BD-4B13-AACF-8C0E751FA4E8}", _
         "{2BC3BD4D-FABA-4394-93C7-9AC82A263FE2}", "{0FA68574-690B-4B00-89AA-B28946231449}", _
         "{2F69FB2B-2C48-491C-B249-22C1BDCE1117}", "{31C9EB3A-5F0C-49E7-8E6C-D404E48F433D}", _
         "{5CD4E357-9ED6-42AC-B654-F1FC21DD60C9}", "{E2C131AD-D30F-4D67-ACE9-B3D485E84DA8}", _
         "{42163859-095F-469B-A0B0-7748500570D1}", "{526B224D-6B70-4A2A-9D03-CE304B5125D6}"
      cpp2019_x86_old = True
    Case "{0D3E9E15-DE7A-300B-96F1-B4AF12B96488}", "{BC958BD2-5DAC-3862-BB1A-C1BE0790438D}", "{e46eca4f-393b-40df-9f49-076faf788d83}", _
         "{A1C31BA5-5438-3A07-9EEE-A5FB2D0FDE36}", "{B0B194F8-E0CE-33FE-AA11-636428A4B73D}", "{3ee5e5bb-b7cc-4556-8861-a00a82977d6c}", _
         "{7B50D081-E670-3B43-A460-0E2CDB5CE984}", "{DFFEB619-5455-3697-B145-243D936DB95B}", _
         "{C0B2C673-ECAA-372D-94E5-E89440D087AD}", "{95265B86-188E-3F62-9CDB-60FCE59EC721}", _
         "{FAAD7243-0141-3987-AA2F-E56B20F80E41}", "{F20396E5-D84E-3505-A7A8-7358F0155F6C}", _
         "{50A2BC33-C9CD-3BF1-A8FF-53C10A0B183C}", "{EF1EC6A9-17DE-3DA9-B040-686A1E8A8B04}", _
         "{8D50D8C6-1E3D-3BAB-B2B7-A5399EA1EBD1}", "{C668F044-4825-330D-8F9F-3CBFC9F2AB89}", _
         "{B0037450-526D-3448-A370-CACBD87769A0}", "{B13B3E11-1555-353F-A63A-8933EE104FBD}", _
         "{C99E2ADC-0347-336E-A603-F1992B09D582}", "{2CD849A7-86A1-34A6-B8F9-D72F5B21A9AE}", _
         "{221D6DB4-46E2-333C-B09B-5F49351D0980}", "{C5ECDB9A-D9B0-3107-BA85-1269998A5B3E}", "{7474CD6E-76CC-4257-837E-5B9261E526AF}", _
         "{BCA8F863-9BAB-3398-B8E4-E1D0959D0943}", "{A2999714-5C2C-3729-A911-4AE198B7B2FD}", _
         "{03EBF679-E886-38AD-8E70-28658449F7F9}", "{B12F584A-DE7A-3EE3-8EC4-8A64DBC0F2A7}", "{80586C77-DB42-44BB-BFC8-7AEBBB220C00}", _
         "{C77195A4-CEB8-38EE-BDD6-C46CB459EF6E}", "{F106B700-BFF8-3065-B305-14D36AD40539}", _
         "{3ECD99CB-EDAF-45DA-AD9C-2C4875F375FB}", "{DF5B1280-A057-4536-9D03-3BCAA0D4C6F0}", _
         "{F1B0FB3A-E0EA-47A6-9383-3650655403B0}", "{9D29FC96-9EEE-4253-943F-96B3BBFDD0B6}", _
         "{F3241984-5A0E-4632-9025-AA16E0780A4B}", "{4931385B-094D-4DC5-BD6A-5188FE9C51DF}", _
         "{F7CAC7DF-3524-4C2D-A7DB-E16140A3D5E6}", "{12578975-C765-4BDF-8DDC-3284BC0E855F}", _
         "{0093C20C-273D-4397-B623-515CB8616CB9}", "{6E2C7A8E-B17A-4637-9CE9-F0B1157CF378}", _
         "{A94EC1B2-932B-49D7-8AF2-4FBD29FF314B}", "{9CA7111B-263D-45DE-B898-61FAD30B3237}", _
         "{7DC387B8-E6A2-480C-8EF9-A6E51AE81C19}", "{8678BA04-D161-45BE-ACA4-CC5D13073F35}", _
         "{EEA66967-97E2-4561-A999-5C22E3CDE428}", "{7D0B74C2-C3F8-4AF1-940F-CD79AB4B2DCE}", _
         "{CB4A0FDE-1126-4AE2-97C6-A243692C3D95}", "{DD1EC0FD-3F0A-4740-A05E-1DCD14A6B0D1}", _
         "{E493B8F4-E300-43EC-95D0-BDF3711297EA}", "{F07B1E25-5670-4556-9C7F-5A1966C83269}", _
         "{37BB1766-C587-49AE-B2DB-618FBDEAB88C}", "{1B4EDD59-90CE-4BDE-8520-630981088165}"
      cpp2019_x64_old = True
    Case "{EE2E15BB-54C8-4DB0-B1F3-026E3C166991}", "{B40FC85D-2B12-46E0-B950-E5B27E348793}"
      cpp2019_x86_new = True
    Case "{26AF0C35-55EC-4025-8D83-349E8FB1419F}", "{7D0362D5-C699-4403-BC09-0C1DAD1D93AB}"
      cpp2019_x64_new = True
  End Select
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
If (cpp2019_x86_old) And (Not cpp2019_x86_new) Then objCmdFile.WriteLine("set CPP_2019_x86=1")
If (cpp2019_x64_old) And (Not cpp2019_x64_new) Then objCmdFile.WriteLine("set CPP_2019_x64=1")

objCmdFile.Close
WScript.Quit(0)
