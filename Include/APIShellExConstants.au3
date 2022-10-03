#include-once

; #INDEX# =======================================================================================================================
; Title .........: WinAPIShellEx Constants UDF Library for AutoIt3
; AutoIt Version : 3.3.16.1
; Language ......: English
; Description ...: Constants that can be used with UDF library
; Author(s) .....: Yashied, Jpm
; ===============================================================================================================================

; #CONSTANTS# ===================================================================================================================

; _WinAPI_DllGetVersion()
Global Const $DLLVER_PLATFORM_WINDOWS = 0x01
Global Const $DLLVER_PLATFORM_NT = 0x02

; _WinAPI_ShellChangeNotify()
Global Const $SHCNE_ALLEVENTS = 0x7FFFFFFF
Global Const $SHCNE_ASSOCCHANGED = 0x8000000
Global Const $SHCNE_ATTRIBUTES = 0x00000800
Global Const $SHCNE_CREATE = 0x00000002
Global Const $SHCNE_DELETE = 0x00000004
Global Const $SHCNE_DRIVEADD = 0x00000100
Global Const $SHCNE_DRIVEADDGUI = 0x00010000
Global Const $SHCNE_DRIVEREMOVED = 0x00000080
Global Const $SHCNE_EXTENDED_EVENT = 0x04000000
Global Const $SHCNE_FREESPACE = 0x00040000
Global Const $SHCNE_MEDIAINSERTED = 0x00000020
Global Const $SHCNE_MEDIAREMOVED = 0x00000040
Global Const $SHCNE_MKDIR = 0x00000008
Global Const $SHCNE_NETSHARE = 0x00000200
Global Const $SHCNE_NETUNSHARE = 0x00000400
Global Const $SHCNE_RENAMEFOLDER = 0x00020000
Global Const $SHCNE_RENAMEITEM = 0x00000001
Global Const $SHCNE_RMDIR = 0x00000010
Global Const $SHCNE_SERVERDISCONNECT = 0x00004000
Global Const $SHCNE_UPDATEDIR = 0x00001000
Global Const $SHCNE_UPDATEIMAGE = 0x00008000
Global Const $SHCNE_UPDATEITEM = 0x00002000
Global Const $SHCNE_DISKEVENTS = 0x0002381F
Global Const $SHCNE_GLOBALEVENTS = 0x0C0581E0
Global Const $SHCNE_INTERRUPT = 0x80000000

Global Const $SHCNF_DWORD = 0x00000003
Global Const $SHCNF_IDLIST = 0x00000000
Global Const $SHCNF_PATH = 0x00000001
Global Const $SHCNF_PRINTER = 0x00000002
Global Const $SHCNF_FLUSH = 0x00001000
Global Const $SHCNF_FLUSHNOWAIT = 0x00002000
Global Const $SHCNF_NOTIFYRECURSIVE = 0x00010000

; _WinAPI_ShellChangeNotifyRegister()
Global Const $SHCNRF_INTERRUPTLEVEL = 0x0001
Global Const $SHCNRF_SHELLLEVEL = 0x0002
Global Const $SHCNRF_RECURSIVEINTERRUPT = 0x1000
Global Const $SHCNRF_NEWDELIVERY = 0x8000

; _WinAPI_ShellEmptyRecycleBin()
Global Const $SHERB_NOCONFIRMATION = 0x01
Global Const $SHERB_NOPROGRESSUI = 0x02
Global Const $SHERB_NOSOUND = 0x04
Global Const $SHERB_NO_UI = BitOR($SHERB_NOCONFIRMATION, $SHERB_NOPROGRESSUI, $SHERB_NOSOUND)

; _WinAPI_ShellExecute(), _WinAPI_ShellExecuteEx()
Global Const $SEE_MASK_DEFAULT = 0x00000000
Global Const $SEE_MASK_CLASSNAME = 0x00000001
Global Const $SEE_MASK_CLASSKEY = 0x00000003
Global Const $SEE_MASK_IDLIST = 0x00000004
Global Const $SEE_MASK_INVOKEIDLIST = 0x0000000C
Global Const $SEE_MASK_ICON = 0x00000010
Global Const $SEE_MASK_HOTKEY = 0x00000020
Global Const $SEE_MASK_NOCLOSEPROCESS = 0x00000040
Global Const $SEE_MASK_CONNECTNETDRV = 0x00000080
Global Const $SEE_MASK_NOASYNC = 0x00000100
Global Const $SEE_MASK_FLAG_DDEWAIT = $SEE_MASK_NOASYNC
Global Const $SEE_MASK_DOENVSUBST = 0x00000200
Global Const $SEE_MASK_FLAG_NO_UI = 0x00000400
Global Const $SEE_MASK_UNICODE = 0x00004000
Global Const $SEE_MASK_NO_CONSOLE = 0x00008000
Global Const $SEE_MASK_ASYNCOK = 0x00100000
Global Const $SEE_MASK_NOQUERYCLASSSTORE = 0x01000000
Global Const $SEE_MASK_HMONITOR = 0x00200000
Global Const $SEE_MASK_NOZONECHECKS = 0x00800000
Global Const $SEE_MASK_WAITFORINPUTIDLE = 0x02000000
Global Const $SEE_MASK_FLAG_LOG_USAGE = 0x04000000

Global Const $SE_ERR_ACCESSDENIED = 5
Global Const $SE_ERR_ASSOCINCOMPLETE = 27
Global Const $SE_ERR_DDEBUSY = 30
Global Const $SE_ERR_DDEFAIL = 29
Global Const $SE_ERR_DDETIMEOUT = 28
Global Const $SE_ERR_DLLNOTFOUND = 32
Global Const $SE_ERR_FNF = 2
Global Const $SE_ERR_NOASSOC = 31
Global Const $SE_ERR_OOM = 8
Global Const $SE_ERR_PNF = 3
Global Const $SE_ERR_SHARE = 26

; _WinAPI_ShellFileOperation()
Global Const $FO_COPY = 2
Global Const $FO_DELETE = 3
Global Const $FO_MOVE = 1
Global Const $FO_RENAME = 4

Global Const $FOF_ALLOWUNDO = 0x0040
Global Const $FOF_CONFIRMMOUSE = 0x0002
Global Const $FOF_FILESONLY = 0x0080
Global Const $FOF_MULTIDESTFILES = 0x0001
Global Const $FOF_NOCONFIRMATION = 0x0010
Global Const $FOF_NOCONFIRMMKDIR = 0x0200
Global Const $FOF_NO_CONNECTED_ELEMENTS = 0x2000
Global Const $FOF_NOCOPYSECURITYATTRIBS = 0x0800
Global Const $FOF_NOERRORUI = 0x0400
Global Const $FOF_NORECURSEREPARSE = 0x8000
Global Const $FOF_NORECURSION = 0x1000
Global Const $FOF_RENAMEONCOLLISION = 0x0008
Global Const $FOF_SILENT = 0x0004
Global Const $FOF_SIMPLEPROGRESS = 0x0100
Global Const $FOF_WANTMAPPINGHANDLE = 0x0020
Global Const $FOF_WANTNUKEWARNING = 0x4000
Global Const $FOF_NO_UI = BitOR($FOF_NOCONFIRMATION, $FOF_NOCONFIRMMKDIR, $FOF_NOERRORUI, $FOF_SILENT)

; _WinAPI_ShellGetFileInfo()
Global Const $SHGFI_ADDOVERLAYS = 0x00000020
Global Const $SHGFI_ATTR_SPECIFIED = 0x00020000
Global Const $SHGFI_ATTRIBUTES = 0x00000800
Global Const $SHGFI_DISPLAYNAME = 0x00000200
Global Const $SHGFI_EXETYPE = 0x00002000
Global Const $SHGFI_ICON = 0x00000100
Global Const $SHGFI_ICONLOCATION = 0x00001000
Global Const $SHGFI_LARGEICON = 0x00000000
Global Const $SHGFI_LINKOVERLAY = 0x00008000
Global Const $SHGFI_OPENICON = 0x00000002
Global Const $SHGFI_OVERLAYINDEX = 0x00000040
Global Const $SHGFI_PIDL = 0x00000008
Global Const $SHGFI_SELECTED = 0x00010000
Global Const $SHGFI_SHELLICONSIZE = 0x00000004
Global Const $SHGFI_SMALLICON = 0x00000001
Global Const $SHGFI_SYSICONINDEX = 0x00004000
Global Const $SHGFI_TYPENAME = 0x00000400
Global Const $SHGFI_USEFILEATTRIBUTES = 0x00000010

Global Const $SFGAO_CANCOPY = 0x00000001
Global Const $SFGAO_CANMOVE = 0x00000002
Global Const $SFGAO_CANLINK = 0x00000004
Global Const $SFGAO_STORAGE = 0x00000008
Global Const $SFGAO_CANRENAME = 0x00000010
Global Const $SFGAO_CANDELETE = 0x00000020
Global Const $SFGAO_HASPROPSHEET = 0x00000040
Global Const $SFGAO_DROPTARGET = 0x00000100
Global Const $SFGAO_CAPABILITYMASK = BitOR($SFGAO_CANCOPY, $SFGAO_CANMOVE, $SFGAO_CANLINK, $SFGAO_CANRENAME, $SFGAO_CANDELETE, $SFGAO_HASPROPSHEET, $SFGAO_DROPTARGET)
Global Const $SFGAO_SYSTEM = 0x00001000
Global Const $SFGAO_ENCRYPTED = 0x00002000
Global Const $SFGAO_ISSLOW = 0x00004000
Global Const $SFGAO_GHOSTED = 0x00008000
Global Const $SFGAO_LINK = 0x00010000
Global Const $SFGAO_SHARE = 0x00020000
Global Const $SFGAO_READONLY = 0x00040000
Global Const $SFGAO_HIDDEN = 0x00080000
Global Const $SFGAO_DISPLAYATTRMASK = BitOR($SFGAO_ISSLOW, $SFGAO_GHOSTED, $SFGAO_LINK, $SFGAO_SHARE, $SFGAO_READONLY, $SFGAO_HIDDEN)
Global Const $SFGAO_NONENUMERATED = 0x00100000
Global Const $SFGAO_NEWCONTENT = 0x00200000
Global Const $SFGAO_STREAM = 0x00400000
Global Const $SFGAO_STORAGEANCESTOR = 0x00800000
Global Const $SFGAO_VALIDATE = 0x01000000
Global Const $SFGAO_REMOVABLE = 0x02000000
Global Const $SFGAO_COMPRESSED = 0x04000000
Global Const $SFGAO_BROWSABLE = 0x08000000
Global Const $SFGAO_FILESYSANCESTOR = 0x10000000
Global Const $SFGAO_FOLDER = 0x20000000
Global Const $SFGAO_FILESYSTEM = 0x40000000
Global Const $SFGAO_STORAGECAPMASK = BitOR($SFGAO_STORAGE, $SFGAO_LINK, $SFGAO_READONLY, $SFGAO_STREAM, $SFGAO_STORAGEANCESTOR, $SFGAO_FILESYSANCESTOR, $SFGAO_FOLDER, $SFGAO_FILESYSTEM)
Global Const $SFGAO_HASSUBFOLDER = 0x80000000
Global Const $SFGAO_CONTENTSMASK = $SFGAO_HASSUBFOLDER
Global Const $SFGAO_PKEYSFGAOMASK = BitOR($SFGAO_ISSLOW, $SFGAO_READONLY, $SFGAO_HASSUBFOLDER, $SFGAO_VALIDATE)

; _WinAPI_ShellGetIconOverlayIndex()
Global Const $IDO_SHGIOI_DEFAULT = 0x0FFFFFFC
Global Const $IDO_SHGIOI_LINK = 0x0FFFFFFE
Global Const $IDO_SHGIOI_SHARE = 0x0FFFFFFF
Global Const $IDO_SHGIOI_SLOWFILE = 0x0FFFFFFD

; _WinAPI_ShellGetSetFolderCustomSettings()
Global Const $FCSM_VIEWID = 0x0001
Global Const $FCSM_WEBVIEWTEMPLATE = 0x0002
Global Const $FCSM_INFOTIP = 0x0004
Global Const $FCSM_CLSID = 0x0008
Global Const $FCSM_ICONFILE = 0x0010
Global Const $FCSM_LOGO = 0x0020
Global Const $FCSM_FLAGS = 0x0040

Global Const $FCS_READ = 0x0001
Global Const $FCS_FORCEWRITE = 0x0002
Global Const $FCS_WRITE = BitOR($FCS_READ, $FCS_FORCEWRITE)

; _WinAPI_ShellGetSettings(), _WinAPI_ShellSetSettings()
Global Const $SSF_AUTOCHECKSELECT = 0x00800000
Global Const $SSF_DESKTOPHTML = 0x00000200
Global Const $SSF_DONTPRETTYPATH = 0x00000800
Global Const $SSF_DOUBLECLICKINWEBVIEW = 0x00000080
Global Const $SSF_HIDEICONS = 0x00004000
Global Const $SSF_ICONSONLY = 0x01000000
Global Const $SSF_MAPNETDRVBUTTON = 0x00001000
Global Const $SSF_NOCONFIRMRECYCLE = 0x00008000
Global Const $SSF_NONETCRAWLING = 0x00100000
Global Const $SSF_SEPPROCESS = 0x00080000
Global Const $SSF_SHOWALLOBJECTS = 0x00000001
Global Const $SSF_SHOWCOMPCOLOR = 0x00000008
Global Const $SSF_SHOWEXTENSIONS = 0x00000002
Global Const $SSF_SHOWINFOTIP = 0x00002000
Global Const $SSF_SHOWSUPERHIDDEN = 0x00040000
Global Const $SSF_SHOWSYSFILES = 0x00000020
Global Const $SSF_SHOWTYPEOVERLAY = 0x02000000
Global Const $SSF_STARTPANELON = 0x00200000
Global Const $SSF_WIN95CLASSIC = 0x00000400
Global Const $SSF_WEBVIEW = 0x00020000

; _WinAPI_ShellGetSpecialFolderPath()
Global Const $CSIDL_ADMINTOOLS = 0x0030
Global Const $CSIDL_ALTSTARTUP = 0x001D
Global Const $CSIDL_APPDATA = 0x001A
Global Const $CSIDL_BITBUCKET = 0x000A
Global Const $CSIDL_CDBURN_AREA = 0x003B
Global Const $CSIDL_COMMON_ADMINTOOLS = 0x002F
Global Const $CSIDL_COMMON_ALTSTARTUP = 0x001E
Global Const $CSIDL_COMMON_APPDATA = 0x0023
Global Const $CSIDL_COMMON_DESKTOPDIRECTORY = 0x0019
Global Const $CSIDL_COMMON_DOCUMENTS = 0x002E
Global Const $CSIDL_COMMON_FAVORITES = 0x001F
Global Const $CSIDL_COMMON_MUSIC = 0x0035
Global Const $CSIDL_COMMON_PICTURES = 0x0036
Global Const $CSIDL_COMMON_PROGRAMS = 0x0017
Global Const $CSIDL_COMMON_STARTMENU = 0x0016
Global Const $CSIDL_COMMON_STARTUP = 0x0018
Global Const $CSIDL_COMMON_TEMPLATES = 0x002D
Global Const $CSIDL_COMMON_VIDEO = 0x0037
Global Const $CSIDL_COMPUTERSNEARME = 0x003D
Global Const $CSIDL_CONNECTIONS = 0x0031
Global Const $CSIDL_CONTROLS = 0x0003
Global Const $CSIDL_COOKIES = 0x0021
Global Const $CSIDL_DESKTOP = 0x0000
Global Const $CSIDL_DESKTOPDIRECTORY = 0x0010
Global Const $CSIDL_DRIVES = 0x0011
Global Const $CSIDL_FAVORITES = 0x0006
Global Const $CSIDL_FONTS = 0x0014
Global Const $CSIDL_INTERNET_CACHE = 0x0020
Global Const $CSIDL_HISTORY = 0x0022
Global Const $CSIDL_LOCAL_APPDATA = 0x001C
Global Const $CSIDL_MYMUSIC = 0x000D
Global Const $CSIDL_MYPICTURES = 0x0027
Global Const $CSIDL_MYVIDEO = 0x000E
Global Const $CSIDL_NETHOOD = 0x0013
Global Const $CSIDL_PERSONAL = 0x0005
Global Const $CSIDL_PRINTERS = 0x0004
Global Const $CSIDL_PRINTHOOD = 0x001B
Global Const $CSIDL_PROFILE = 0x0028
Global Const $CSIDL_PROGRAM_FILES = 0x0026
Global Const $CSIDL_PROGRAM_FILES_COMMON = 0x002B
Global Const $CSIDL_PROGRAM_FILES_COMMONX86 = 0x002C
Global Const $CSIDL_PROGRAM_FILESX86 = 0x002A
Global Const $CSIDL_PROGRAMS = 0x0002
Global Const $CSIDL_RECENT = 0x0008
Global Const $CSIDL_SENDTO = 0x0009
Global Const $CSIDL_STARTMENU = 0x000B
Global Const $CSIDL_STARTUP = 0x0007
Global Const $CSIDL_SYSTEM = 0x0025
Global Const $CSIDL_SYSTEMX86 = 0x0029
Global Const $CSIDL_TEMPLATES = 0x0015
Global Const $CSIDL_WINDOWS = 0x0024

; _WinAPI_ShellGetStockIconInfo()
Global Const $SIID_DOCNOASSOC = 0
Global Const $SIID_DOCASSOC = 1
Global Const $SIID_APPLICATION = 2
Global Const $SIID_FOLDER = 3
Global Const $SIID_FOLDEROPEN = 4
Global Const $SIID_DRIVE525 = 5
Global Const $SIID_DRIVE35 = 6
Global Const $SIID_DRIVEREMOVE = 7
Global Const $SIID_DRIVEFIXED = 8
Global Const $SIID_DRIVENET = 9
Global Const $SIID_DRIVENETDISABLED = 10
Global Const $SIID_DRIVECD = 11
Global Const $SIID_DRIVERAM = 12
Global Const $SIID_WORLD = 13
Global Const $SIID_SERVER = 15
Global Const $SIID_PRINTER = 16
Global Const $SIID_MYNETWORK = 17
Global Const $SIID_FIND = 22
Global Const $SIID_HELP = 23
Global Const $SIID_SHARE = 28
Global Const $SIID_LINK = 29
Global Const $SIID_SLOWFILE = 30
Global Const $SIID_RECYCLER = 31
Global Const $SIID_RECYCLERFULL = 32
Global Const $SIID_MEDIACDAUDIO = 40
Global Const $SIID_LOCK = 47
Global Const $SIID_AUTOLIST = 49
Global Const $SIID_PRINTERNET = 50
Global Const $SIID_SERVERSHARE = 51
Global Const $SIID_PRINTERFAX = 52
Global Const $SIID_PRINTERFAXNET = 53
Global Const $SIID_PRINTERFILE = 54
Global Const $SIID_STACK = 55
Global Const $SIID_MEDIASVCD = 56
Global Const $SIID_STUFFEDFOLDER = 57
Global Const $SIID_DRIVEUNKNOWN = 58
Global Const $SIID_DRIVEDVD = 59
Global Const $SIID_MEDIADVD = 60
Global Const $SIID_MEDIADVDRAM = 61
Global Const $SIID_MEDIADVDRW = 62
Global Const $SIID_MEDIADVDR = 63
Global Const $SIID_MEDIADVDROM = 64
Global Const $SIID_MEDIACDAUDIOPLUS = 65
Global Const $SIID_MEDIACDRW = 66
Global Const $SIID_MEDIACDR = 67
Global Const $SIID_MEDIACDBURN = 68
Global Const $SIID_MEDIABLANKCD = 69
Global Const $SIID_MEDIACDROM = 70
Global Const $SIID_AUDIOFILES = 71
Global Const $SIID_IMAGEFILES = 72
Global Const $SIID_VIDEOFILES = 73
Global Const $SIID_MIXEDFILES = 74
Global Const $SIID_FOLDERBACK = 75
Global Const $SIID_FOLDERFRONT = 76
Global Const $SIID_SHIELD = 77
Global Const $SIID_WARNING = 78
Global Const $SIID_INFO = 79
Global Const $SIID_ERROR = 80
Global Const $SIID_KEY = 81
Global Const $SIID_SOFTWARE = 82
Global Const $SIID_RENAME = 83
Global Const $SIID_DELETE = 84
Global Const $SIID_MEDIAAUDIODVD = 85
Global Const $SIID_MEDIAMOVIEDVD = 86
Global Const $SIID_MEDIAENHANCEDCD = 87
Global Const $SIID_MEDIAENHANCEDDVD = 88
Global Const $SIID_MEDIAHDDVD = 89
Global Const $SIID_MEDIABLURAY = 90
Global Const $SIID_MEDIAVCD = 91
Global Const $SIID_MEDIADVDPLUSR = 92
Global Const $SIID_MEDIADVDPLUSRW = 93
Global Const $SIID_DESKTOPPC = 94
Global Const $SIID_MOBILEPC = 95
Global Const $SIID_USERS = 96
Global Const $SIID_MEDIASMARTMEDIA = 97
Global Const $SIID_MEDIACOMPACTFLASH = 98
Global Const $SIID_DEVICECELLPHONE = 99
Global Const $SIID_DEVICECAMERA = 100
Global Const $SIID_DEVICEVIDEOCAMERA = 101
Global Const $SIID_DEVICEAUDIOPLAYER = 102
Global Const $SIID_NETWORKCONNECT = 103
Global Const $SIID_INTERNET = 104
Global Const $SIID_ZIPFILE = 105
Global Const $SIID_SETTINGS = 106
Global Const $SIID_DRIVEHDDVD = 132
Global Const $SIID_DRIVEBD = 133
Global Const $SIID_MEDIAHDDVDROM = 134
Global Const $SIID_MEDIAHDDVDR = 135
Global Const $SIID_MEDIAHDDVDRAM = 136
Global Const $SIID_MEDIABDROM = 137
Global Const $SIID_MEDIABDR = 138
Global Const $SIID_MEDIABDRE = 139
Global Const $SIID_CLUSTEREDDRIVE = 140
Global Const $SIID_MAX_ICONS = 174

Global Const $SHGSI_ICONLOCATION = 0
Global Const $SHGSI_ICON = $SHGFI_ICON
Global Const $SHGSI_SYSICONINDEX = $SHGFI_SYSICONINDEX
Global Const $SHGSI_LINKOVERLAY = $SHGFI_LINKOVERLAY
Global Const $SHGSI_SELECTED = $SHGFI_SELECTED
Global Const $SHGSI_LARGEICON = $SHGFI_LARGEICON
Global Const $SHGSI_SMALLICON = $SHGFI_SMALLICON
Global Const $SHGSI_SHELLICONSIZE = $SHGFI_SHELLICONSIZE

; _WinAPI_ShellNotifyIcon()
Global Const $NIM_ADD = 0x00
Global Const $NIM_MODIFY = 0x01
Global Const $NIM_DELETE = 0x02
Global Const $NIM_SETFOCUS = 0x03
Global Const $NIM_SETVERSION = 0x04

Global Const $NIF_MESSAGE = 0x01
Global Const $NIF_ICON = 0x02
Global Const $NIF_TIP = 0x04
Global Const $NIF_STATE = 0x08
Global Const $NIF_INFO = 0x10
Global Const $NIF_GUID = 0x20
Global Const $NIF_REALTIME = 0x40
Global Const $NIF_SHOWTIP = 0x80

Global Const $NIS_HIDDEN = 0x01
Global Const $NIS_SHAREDICON = 0x02

Global Const $NIIF_NONE = 0x00
Global Const $NIIF_INFO = 0x01
Global Const $NIIF_WARNING = 0x02
Global Const $NIIF_ERROR = 0x03
Global Const $NIIF_USER = 0x04
Global Const $NIIF_NOSOUND = 0x10
Global Const $NIIF_LARGE_ICON = 0x10
Global Const $NIIF_RESPECT_QUIET_TIME = 0x80
Global Const $NIIF_ICON_MASK = 0x0F

; _WinAPI_ShellObjectProperties()
Global Const $SHOP_PRINTERNAME = 1
Global Const $SHOP_FILEPATH = 2
Global Const $SHOP_VOLUMEGUID = 4

; _WinAPI_ShellOpenFolderAndSelectItems()
Global Const $OFASI_EDIT = 0x01
Global Const $OFASI_OPENDESKTOP = 0x02

; _WinAPI_ShellQueryUserNotificationState()
Global Const $QUNS_NOT_PRESENT = 1
Global Const $QUNS_BUSY = 2
Global Const $QUNS_RUNNING_D3D_FULL_SCREEN = 3
Global Const $QUNS_PRESENTATION_MODE = 4
Global Const $QUNS_ACCEPTS_NOTIFICATIONS = 5
Global Const $QUNS_QUIET_TIME = 6

; _WinAPI_ShellRestricted()
Global Const $REST_NORUN = 1
Global Const $REST_NOCLOSE = 2
Global Const $REST_NOSAVESET = 3
Global Const $REST_NOFILEMENU = 4
Global Const $REST_NOSETFOLDERS = 5
Global Const $REST_NOSETTASKBAR = 6
Global Const $REST_NODESKTOP = 7
Global Const $REST_NOFIND = 8
Global Const $REST_NODRIVES = 9
Global Const $REST_NODRIVEAUTORUN = 10
Global Const $REST_NODRIVETYPEAUTORUN = 11
Global Const $REST_NONETHOOD = 12
Global Const $REST_STARTBANNER = 13
Global Const $REST_RESTRICTRUN = 14
Global Const $REST_NOPRINTERTABS = 15
Global Const $REST_NOPRINTERDELETE = 16
Global Const $REST_NOPRINTERADD = 17
Global Const $REST_NOSTARTMENUSUBFOLDERS = 18
Global Const $REST_MYDOCSONNET = 19
Global Const $REST_NOEXITTODOS = 20
Global Const $REST_ENFORCESHELLEXTSECURITY = 21
Global Const $REST_LINKRESOLVEIGNORELINKINFO = 22
Global Const $REST_NOCOMMONGROUPS = 23
Global Const $REST_SEPARATEDESKTOPPROCESS = 24
Global Const $REST_NOWEB = 25
Global Const $REST_NOTRAYCONTEXTMENU = 26
Global Const $REST_NOVIEWCONTEXTMENU = 27
Global Const $REST_NONETCONNECTDISCONNECT = 28
Global Const $REST_STARTMENULOGOFF = 29
Global Const $REST_NOSETTINGSASSIST = 30
Global Const $REST_NOINTERNETICON = 31
Global Const $REST_NORECENTDOCSHISTORY = 32
Global Const $REST_NORECENTDOCSMENU = 33
Global Const $REST_NOACTIVEDESKTOP = 34
Global Const $REST_NOACTIVEDESKTOPCHANGES = 35
Global Const $REST_NOFAVORITESMENU = 36
Global Const $REST_CLEARRECENTDOCSONEXIT = 37
Global Const $REST_CLASSICSHELL = 38
Global Const $REST_NOCUSTOMIZEWEBVIEW = 39
Global Const $REST_NOHTMLWALLPAPER = 40
Global Const $REST_NOCHANGINGWALLPAPER = 41
Global Const $REST_NODESKCOMP = 42
Global Const $REST_NOADDDESKCOMP = 43
Global Const $REST_NODELDESKCOMP = 44
Global Const $REST_NOCLOSEDESKCOMP = 45
Global Const $REST_NOCLOSE_DRAGDROPBAND = 46
Global Const $REST_NOMOVINGBAND = 47
Global Const $REST_NOEDITDESKCOMP = 48
Global Const $REST_NORESOLVESEARCH = 49
Global Const $REST_NORESOLVETRACK = 50
Global Const $REST_FORCECOPYACLWITHFILE = 51
Global Const $REST_NOLOGO3CHANNELNOTIFY = 52
Global Const $REST_NOFORGETSOFTWAREUPDATE = 53
Global Const $REST_NOSETACTIVEDESKTOP = 54
Global Const $REST_NOUPDATEWINDOWS = 55
Global Const $REST_NOCHANGESTARMENU = 56
Global Const $REST_NOFOLDEROPTIONS = 57
Global Const $REST_HASFINDCOMPUTERS = 58
Global Const $REST_INTELLIMENUS = 59
Global Const $REST_RUNDLGMEMCHECKBOX = 60
Global Const $REST_ARP_ShowPostSetup = 61
Global Const $REST_NOCSC = 62
Global Const $REST_NOCONTROLPANEL = 63
Global Const $REST_ENUMWORKGROUP = 64
Global Const $REST_ARP_NOARP = 65
Global Const $REST_ARP_NOREMOVEPAGE = 66
Global Const $REST_ARP_NOADDPAGE = 67
Global Const $REST_ARP_NOWINSETUPPAGE = 68
Global Const $REST_GREYMSIADS = 69
Global Const $REST_NOCHANGEMAPPEDDRIVELABEL = 70
Global Const $REST_NOCHANGEMAPPEDDRIVECOMMENT = 71
Global Const $REST_MAXRECENTDOCS = 72
Global Const $REST_NONETWORKCONNECTIONS = 73
Global Const $REST_FORCESTARTMENULOGOFF = 74
Global Const $REST_NOWEBVIEW = 75
Global Const $REST_NOCUSTOMIZETHISFOLDER = 76
Global Const $REST_NOENCRYPTION = 77
Global Const $REST_DONTSHOWSUPERHIDDEN = 78
Global Const $REST_NOSHELLSEARCHBUTTON = 79
Global Const $REST_NOHARDWARETAB = 80
Global Const $REST_NORUNASINSTALLPROMPT = 81
Global Const $REST_PROMPTRUNASINSTALLNETPATH = 82
Global Const $REST_NOMANAGEMYCOMPUTERVERB = 83
Global Const $REST_NORECENTDOCSNETHOOD = 84
Global Const $REST_DISALLOWRUN = 85
Global Const $REST_NOWELCOMESCREEN = 86
Global Const $REST_RESTRICTCPL = 87
Global Const $REST_DISALLOWCPL = 88
Global Const $REST_NOSMBALLOONTIP = 89
Global Const $REST_NOSMHELP = 90
Global Const $REST_NOWINKEYS = 91
Global Const $REST_NOENCRYPTONMOVE = 92
Global Const $REST_NOLOCALMACHINERUN = 93
Global Const $REST_NOCURRENTUSERRUN = 94
Global Const $REST_NOLOCALMACHINERUNONCE = 95
Global Const $REST_NOCURRENTUSERRUNONCE = 96
Global Const $REST_FORCEACTIVEDESKTOPON = 97
Global Const $REST_NOCOMPUTERSNEARME = 98
Global Const $REST_NOVIEWONDRIVE = 99
Global Const $REST_NONETCRAWL = 100
Global Const $REST_NOSHAREDDOCUMENTS = 101
Global Const $REST_NOSMMYDOCS = 102
Global Const $REST_NOSMMYPICS = 103
Global Const $REST_ALLOWBITBUCKDRIVES = 104
Global Const $REST_NONLEGACYSHELLMODE = 105
Global Const $REST_NOCONTROLPANELBARRICADE = 106
Global Const $REST_NOSTARTPAGE = 107
Global Const $REST_NOAUTOTRAYNOTIFY = 108
Global Const $REST_NOTASKGROUPING = 109
Global Const $REST_NOCDBURNING = 110
Global Const $REST_MYCOMPNOPROP = 111
Global Const $REST_MYDOCSNOPROP = 112
Global Const $REST_NOSTARTPANEL = 113
Global Const $REST_NODISPLAYAPPEARANCEPAGE = 114
Global Const $REST_NOTHEMESTAB = 115
Global Const $REST_NOVISUALSTYLECHOICE = 116
Global Const $REST_NOSIZECHOICE = 117
Global Const $REST_NOCOLORCHOICE = 118
Global Const $REST_SETVISUALSTYLE = 119
Global Const $REST_STARTRUNNOHOMEPATH = 120
Global Const $REST_NOUSERNAMEINSTARTPANEL = 121
Global Const $REST_NOMYCOMPUTERICON = 122
Global Const $REST_NOSMNETWORKPLACES = 123
Global Const $REST_NOSMPINNEDLIST = 124
Global Const $REST_NOSMMYMUSIC = 125
Global Const $REST_NOSMEJECTPC = 126
Global Const $REST_NOSMMOREPROGRAMS = 127
Global Const $REST_NOSMMFUPROGRAMS = 128
Global Const $REST_NOTRAYITEMSDISPLAY = 129
Global Const $REST_NOTOOLBARSONTASKBAR = 130
Global Const $REST_NOSMCONFIGUREPROGRAMS = 131
Global Const $REST_HIDECLOCK = 132
Global Const $REST_NOLOWDISKSPACECHECKS = 133
Global Const $REST_NOENTIRENETWORK = 134
Global Const $REST_NODESKTOPCLEANUP = 135
Global Const $REST_BITBUCKNUKEONDELETE = 136
Global Const $REST_BITBUCKCONFIRMDELETE = 137
Global Const $REST_BITBUCKNOPROP = 138
Global Const $REST_NODISPBACKGROUND = 139
Global Const $REST_NODISPSCREENSAVEPG = 140
Global Const $REST_NODISPSETTINGSPG = 141
Global Const $REST_NODISPSCREENSAVEPREVIEW = 142
Global Const $REST_NODISPLAYCPL = 143
Global Const $REST_HIDERUNASVERB = 144
Global Const $REST_NOTHUMBNAILCACHE = 145
Global Const $REST_NOSTRCMPLOGICAL = 146
Global Const $REST_NOPUBLISHWIZARD = 147
Global Const $REST_NOONLINEPRINTSWIZARD = 148
Global Const $REST_NOWEBSERVICES = 149
Global Const $REST_ALLOWUNHASHEDWEBVIEW = 150
Global Const $REST_ALLOWLEGACYWEBVIEW = 151
Global Const $REST_REVERTWEBVIEWSECURITY = 152
Global Const $REST_INHERITCONSOLEHANDLES = 153
Global Const $REST_SORTMAXITEMCOUNT = 154
Global Const $REST_NOREMOTERECURSIVEEVENTS = 155
Global Const $REST_NOREMOTECHANGENOTIFY = 156
Global Const $REST_NOSIMPLENETIDLIST = 157
Global Const $REST_NOENUMENTIRENETWORK = 158
Global Const $REST_NODETAILSTHUMBNAILONNETWORK = 159
Global Const $REST_NOINTERNETOPENWITH = 160
Global Const $REST_ALLOWLEGACYLMZBEHAVIOR = 161
Global Const $REST_DONTRETRYBADNETNAME = 162
Global Const $REST_ALLOWFILECLSIDJUNCTIONS = 163
Global Const $REST_NOUPNPINSTALL = 164
Global Const $REST_ARP_DONTGROUPPATCHES = 165
Global Const $REST_ARP_NOCHOOSEPROGRAMSPAGE = 166
Global Const $REST_NODISCONNECT = 167
Global Const $REST_NOSECURITY = 168
Global Const $REST_NOFILEASSOCIATE = 169
Global Const $REST_ALLOWCOMMENTTOGGLE = 170
Global Const $REST_USEDESKTOPINICACHE = 171

; _WinAPI_ShellUpdateImage()
Global Const $GIL_DONTCACHE = 0x0010
Global Const $GIL_NOTFILENAME = 0x0008
Global Const $GIL_PERCLASS = 0x0004
Global Const $GIL_PERINSTANCE = 0x0002
Global Const $GIL_SIMULATEDOC = 0x0001
Global Const $GIL_SHIELD = 0x0200
Global Const $GIL_FORCENOSHIELD = 0x0400

; _WinAPI_Shell*KnownFolder*()
Global Const $FOLDERID_AddNewPrograms = '{DE61D971-5EBC-4F02-A3A9-6C82895E5C04}'
Global Const $FOLDERID_AdminTools = '{724EF170-A42D-4FEF-9F26-B60E846FBA4F}'
Global Const $FOLDERID_AppUpdates = '{A305CE99-F527-492B-8B1A-7E76FA98D6E4}'
Global Const $FOLDERID_CDBurning = '{9E52AB10-F80D-49DF-ACB8-4330F5687855}'
Global Const $FOLDERID_ChangeRemovePrograms = '{DF7266AC-9274-4867-8D55-3BD661DE872D}'
Global Const $FOLDERID_CommonAdminTools = '{D0384E7D-BAC3-4797-8F14-CBA229B392B5}'
Global Const $FOLDERID_CommonOEMLinks = '{C1BAE2D0-10DF-4334-BEDD-7AA20B227A9D}'
Global Const $FOLDERID_CommonPrograms = '{0139D44E-6AFE-49F2-8690-3DAFCAE6FFB8}'
Global Const $FOLDERID_CommonStartMenu = '{A4115719-D62E-491D-AA7C-E74B8BE3B067}'
Global Const $FOLDERID_CommonStartup = '{82A5EA35-D9CD-47C5-9629-E15D2F714E6E}'
Global Const $FOLDERID_CommonTemplates = '{B94237E7-57AC-4347-9151-B08C6C32D1F7}'
Global Const $FOLDERID_ComputerFolder = '{0AC0837C-BBF8-452A-850D-79D08E667CA7}'
Global Const $FOLDERID_ConflictFolder = '{4BFEFB45-347D-4006-A5BE-AC0CB0567192}'
Global Const $FOLDERID_ConnectionsFolder = '{6F0CD92B-2E97-45D1-88FF-B0D186B8DEDD}'
Global Const $FOLDERID_Contacts = '{56784854-C6CB-462B-8169-88E350ACB882}'
Global Const $FOLDERID_ControlPanelFolder = '{82A74AEB-AEB4-465C-A014-D097EE346D63}'
Global Const $FOLDERID_Cookies = '{2B0F765D-C0E9-4171-908E-08A611B84FF6}'
Global Const $FOLDERID_Desktop = '{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}'
Global Const $FOLDERID_DeviceMetadataStore = '{5CE4A5E9-E4EB-479D-B89F-130C02886155}'
Global Const $FOLDERID_DocumentsLibrary = '{7B0DB17D-9CD2-4A93-9733-46CC89022E7C}'
Global Const $FOLDERID_Downloads = '{374DE290-123F-4565-9164-39C4925E467B}'
Global Const $FOLDERID_Favorites = '{1777F761-68AD-4D8A-87BD-30B759FA33DD}'
Global Const $FOLDERID_Fonts = '{FD228CB7-AE11-4AE3-864C-16F3910AB8FE}'
Global Const $FOLDERID_Games = '{CAC52C1A-B53D-4EDC-92D7-6B2E8AC19434}'
Global Const $FOLDERID_GameTasks = '{054FAE61-4DD8-4787-80B6-090220C4B700}'
Global Const $FOLDERID_History = '{D9DC8A3B-B784-432E-A781-5A1130A75963}'
Global Const $FOLDERID_HomeGroup = '{52528A6B-B9E3-4ADD-B60D-588C2DBA842D}'
Global Const $FOLDERID_ImplicitAppShortcuts = '{BCB5256F-79F6-4CEE-B725-DC34E402FD46}'
Global Const $FOLDERID_InternetCache = '{352481E8-33BE-4251-BA85-6007CAEDCF9D}'
Global Const $FOLDERID_InternetFolder = '{4D9F7874-4E0C-4904-967B-40B0D20C3E4B}'
Global Const $FOLDERID_Libraries = '{1B3EA5DC-B587-4786-B4EF-BD1DC332AEAE}'
Global Const $FOLDERID_Links = '{BFB9D5E0-C6A9-404C-B2B2-AE6DB6AF4968}'
Global Const $FOLDERID_LocalAppData = '{F1B32785-6FBA-4FCF-9D55-7B8E7F157091}'
Global Const $FOLDERID_LocalAppDataLow = '{A520A1A4-1780-4FF6-BD18-167343C5AF16}'
Global Const $FOLDERID_LocalizedResourcesDir = '{2A00375E-224C-49DE-B8D1-440DF7EF3DDC}'
Global Const $FOLDERID_Music = '{4BD8D571-6D19-48D3-BE97-422220080E43}'
Global Const $FOLDERID_MusicLibrary = '{2112AB0A-C86A-4FFE-A368-0DE96E47012E}'
Global Const $FOLDERID_NetHood = '{C5ABBF53-E17F-4121-8900-86626FC2C973}'
Global Const $FOLDERID_NetworkFolder = '{D20BEEC4-5CA8-4905-AE3B-BF251EA09B53}'
Global Const $FOLDERID_OriginalImages = '{2C36C0AA-5812-4B87-BFD0-4CD0DFB19B39}'
Global Const $FOLDERID_PhotoAlbums = '{69D2CF90-FC33-4FB7-9A0C-EBB0F0FCB43C}'
Global Const $FOLDERID_PicturesLibrary = '{A990AE9F-A03B-4E80-94BC-9912D7504104}'
Global Const $FOLDERID_Pictures = '{33E28130-4E1E-4676-835A-98395C3BC3BB}'
Global Const $FOLDERID_Playlists = '{DE92C1C7-837F-4F69-A3BB-86E631204A23}'
Global Const $FOLDERID_PrintersFolder = '{76FC4E2D-D6AD-4519-A663-37BD56068185}'
Global Const $FOLDERID_PrintHood = '{9274BD8D-CFD1-41C3-B35E-B13F55A758F4}'
Global Const $FOLDERID_Profile = '{5E6C858F-0E22-4760-9AFE-EA3317B67173}'
Global Const $FOLDERID_ProgramData = '{62AB5D82-FDC1-4DC3-A9DD-070D1D495D97}'
Global Const $FOLDERID_ProgramFiles = '{905E63B6-C1BF-494E-B29C-65B732D3D21A}'
Global Const $FOLDERID_ProgramFilesX64 = '{6D809377-6AF0-444B-8957-A3773F02200E}'
Global Const $FOLDERID_ProgramFilesX86 = '{7C5A40EF-A0FB-4BFC-874A-C0F2E0B9FA8E}'
Global Const $FOLDERID_ProgramFilesCommon = '{F7F1ED05-9F6D-47A2-AAAE-29D317C6F066}'
Global Const $FOLDERID_ProgramFilesCommonX64 = '{6365D5A7-0F0D-45E5-87F6-0DA56B6A4F7D}'
Global Const $FOLDERID_ProgramFilesCommonX86 = '{DE974D24-D9C6-4D3E-BF91-F4455120B917}'
Global Const $FOLDERID_Programs = '{A77F5D77-2E2B-44C3-A6A2-ABA601054A51}'
Global Const $FOLDERID_Public = '{DFDF76A2-C82A-4D63-906A-5644AC457385}'
Global Const $FOLDERID_PublicDesktop = '{C4AA340D-F20F-4863-AFEF-F87EF2E6BA25}'
Global Const $FOLDERID_PublicDocuments = '{ED4824AF-DCE4-45A8-81E2-FC7965083634}'
Global Const $FOLDERID_PublicDownloads = '{3D644C9B-1FB8-4F30-9B45-F670235F79C0}'
Global Const $FOLDERID_PublicGameTasks = '{DEBF2536-E1A8-4C59-B6A2-414586476AEA}'
Global Const $FOLDERID_PublicLibraries = '{48DAF80B-E6CF-4F4E-B800-0E69D84EE384}'
Global Const $FOLDERID_PublicMusic = '{3214FAB5-9757-4298-BB61-92A9DEAA44FF}'
Global Const $FOLDERID_PublicPictures = '{B6EBFB86-6907-413C-9AF7-4FC2ABF07CC5}'
Global Const $FOLDERID_PublicRingtones = '{E555AB60-153B-4D17-9F04-A5FE99FC15EC}'
Global Const $FOLDERID_PublicVideos = '{2400183A-6185-49FB-A2D8-4A392A602BA3}'
Global Const $FOLDERID_QuickLaunch = '{52A4F021-7B75-48A9-9F6B-4B87A210BC8F}'
Global Const $FOLDERID_Recent = '{AE50C081-EBD2-438A-8655-8A092E34987A}'
Global Const $FOLDERID_RecordedTVLibrary = '{1A6FDBA2-F42D-4358-A798-B74D745926C5}'
Global Const $FOLDERID_RecycleBinFolder = '{B7534046-3ECB-4C18-BE4E-64CD4CB7D6AC}'
Global Const $FOLDERID_ResourceDir = '{8AD10C31-2ADB-4296-A8F7-E4701232C972}'
Global Const $FOLDERID_Ringtones = '{C870044B-F49E-4126-A9C3-B52A1FF411E8}'
Global Const $FOLDERID_RoamingAppData = '{3EB685DB-65F9-4CF6-A03A-E3EF65729F3D}'
Global Const $FOLDERID_SampleMusic = '{B250C668-F57D-4EE1-A63C-290EE7D1AA1F}'
Global Const $FOLDERID_SamplePictures = '{C4900540-2379-4C75-844B-64E6FAF8716B}'
Global Const $FOLDERID_SamplePlaylists = '{15CA69B3-30EE-49C1-ACE1-6B5EC372AFB5}'
Global Const $FOLDERID_SampleVideos = '{859EAD94-2E85-48AD-A71A-0969CB56A6CD}'
Global Const $FOLDERID_SavedGames = '{4C5C32FF-BB9D-43B0-B5B4-2D72E54EAAA4}'
Global Const $FOLDERID_SavedSearches = '{7D1D3A04-DEBB-4115-95CF-2F29DA2920DA}'
Global Const $FOLDERID_SEARCH_CSC = '{EE32E446-31CA-4ABA-814F-A5EBD2FD6D5E}'
Global Const $FOLDERID_SEARCH_MAPI = '{98EC0E18-2098-4D44-8644-66979315A281}'
Global Const $FOLDERID_SearchHome = '{190337D1-B8CA-4121-A639-6D472D16972A}'
Global Const $FOLDERID_SendTo = '{8983036C-27C0-404B-8F08-102D10DCFD74}'
Global Const $FOLDERID_SidebarDefaultParts = '{7B396E54-9EC5-4300-BE0A-2482EBAE1A26}'
Global Const $FOLDERID_SidebarParts = '{A75D362E-50FC-4FB7-AC2C-A8BEAA314493}'
Global Const $FOLDERID_StartMenu = '{625B53C3-AB48-4EC1-BA1F-A1EF4146FC19}'
Global Const $FOLDERID_Startup = '{B97D20BB-F46A-4C97-BA10-5E3608430854}'
Global Const $FOLDERID_SyncManagerFolder = '{43668BF8-C14E-49B2-97C9-747784D784B7}'
Global Const $FOLDERID_SyncResultsFolder = '{289A9A43-BE44-4057-A41B-587A76D7E7F9}'
Global Const $FOLDERID_SyncSetupFolder = '{0F214138-B1D3-4A90-BBA9-27CBC0C5389A}'
Global Const $FOLDERID_System = '{1AC14E77-02E7-4E5D-B744-2EB1AE5198B7}'
Global Const $FOLDERID_SystemX86 = '{D65231B0-B2F1-4857-A4CE-A8E7C6EA7D27}'
Global Const $FOLDERID_Templates = '{A63293E8-664E-48DB-A079-DF759E0509F7}'
Global Const $FOLDERID_UserPinned = '{9E3995AB-1F9C-4F13-B827-48B24B6C7174}'
Global Const $FOLDERID_UserProfiles = '{0762D272-C50A-4BB0-A382-697DCD729B80}'
Global Const $FOLDERID_UserProgramFiles = '{5CD7AEE2-2219-4A67-B85D-6C9CE15660CB}'
Global Const $FOLDERID_UserProgramFilesCommon = '{BCBD3057-CA5C-4622-B42D-BC56DB0AE516}'
Global Const $FOLDERID_UsersFiles = '{F3CE0F7C-4901-4ACC-8648-D5D44B04EF8F}'
Global Const $FOLDERID_UsersLibraries = '{A302545D-DEFF-464B-ABE8-61C8648D939B}'
Global Const $FOLDERID_Videos = '{18989B1D-99B5-455B-841C-AB7C74E4DDFC}'
Global Const $FOLDERID_VideosLibrary = '{491E922F-5643-4AF4-A7EB-4E7A138D8174}'
Global Const $FOLDERID_Windows = '{F38BF404-1D43-42F2-9305-67DE0B28FC23}'

Global Const $KF_FLAG_ALIAS_ONLY = 0x80000000
Global Const $KF_FLAG_CREATE = 0x00008000
Global Const $KF_FLAG_DONT_VERIFY = 0x00004000
Global Const $KF_FLAG_DONT_UNEXPAND = 0x00002000
Global Const $KF_FLAG_NO_ALIAS = 0x00001000
Global Const $KF_FLAG_INIT = 0x00000800
Global Const $KF_FLAG_DEFAULT_PATH = 0x00000400
Global Const $KF_FLAG_NO_APPCONTAINER_REDIRECTION = 0x00010000
Global Const $KF_FLAG_NOT_PARENT_RELATIVE = 0x00000200
Global Const $KF_FLAG_SIMPLE_IDLIST = 0x00000100
; ===============================================================================================================================
