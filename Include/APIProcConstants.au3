#include-once

; #INDEX# =======================================================================================================================
; Title .........: WinAPIProc Constants UDF Library for AutoIt3
; AutoIt Version : 3.3.16.1
; Language ......: English
; Description ...: Constants that can be used with UDF library
; Author(s) .....: Yashied, Jpm
; ===============================================================================================================================

; #CONSTANTS# ===================================================================================================================

; _WinAPI_CreateProcess(), _WinAPI_CreateProcessWithToken()
Global Const $CREATE_BREAKAWAY_FROM_JOB = 0x01000000
Global Const $CREATE_DEFAULT_ERROR_MODE = 0x04000000
Global Const $CREATE_NEW_CONSOLE = 0x00000010
Global Const $CREATE_NEW_PROCESS_GROUP = 0x00000200
Global Const $CREATE_NO_WINDOW = 0x08000000
Global Const $CREATE_PROTECTED_PROCESS = 0x00040000
Global Const $CREATE_PRESERVE_CODE_AUTHZ_LEVEL = 0x02000000
Global Const $CREATE_SEPARATE_WOW_VDM = 0x00000800
Global Const $CREATE_SHARED_WOW_VDM = 0x00001000
Global Const $CREATE_SUSPENDED = 0x00000004
Global Const $CREATE_UNICODE_ENVIRONMENT = 0x00000400

; move in SecurityConstants.au3
; Global Const $LOGON_WITH_PROFILE = 0x01
; Global Const $LOGON_NETCREDENTIALS_ONLY = 0x02

; _WinAPI_EnumProcessModules()
Global Const $LIST_MODULES_32BIT = 1
Global Const $LIST_MODULES_64BIT = 2
Global Const $LIST_MODULES_ALL = 3
Global Const $LIST_MODULES_DEFAULT = 0

; _WinAPI_GetPriorityClass(), _WinAPI_SetPriorityClass()
Global Const $ABOVE_NORMAL_PRIORITY_CLASS = 0x00008000
Global Const $BELOW_NORMAL_PRIORITY_CLASS = 0x00004000
Global Const $HIGH_PRIORITY_CLASS = 0x00000080
Global Const $IDLE_PRIORITY_CLASS = 0x00000040
Global Const $NORMAL_PRIORITY_CLASS = 0x00000020
Global Const $REALTIME_PRIORITY_CLASS = 0x00000100

Global Const $PROCESS_MODE_BACKGROUND_BEGIN = 0x00100000
Global Const $PROCESS_MODE_BACKGROUND_END = 0x00200000

; _WinAPI_OpenMutex()
Global Const $MUTEX_MODIFY_STATE = 0x0001
Global Const $MUTEX_ALL_ACCESS = 0x001F0001 ; BitOR($STANDARD_RIGHTS_ALL, $MUTEX_MODIFY_STATE)

; _WinAPI_OpenJobObject(), _WinAPI_QueryInformationJobObject(), _WinAPI_SetInformationJobObject()
Global Const $JOB_OBJECT_ASSIGN_PROCESS = 0x0001
Global Const $JOB_OBJECT_QUERY = 0x0004
Global Const $JOB_OBJECT_SET_ATTRIBUTES = 0x0002
Global Const $JOB_OBJECT_SET_SECURITY_ATTRIBUTES = 0x0010
Global Const $JOB_OBJECT_TERMINATE = 0x0008
Global Const $JOB_OBJECT_ALL_ACCESS = 0x001F001F ; BitOR($STANDARD_RIGHTS_ALL, $JOB_OBJECT_ASSIGN_PROCESS, $JOB_OBJECT_QUERY, $JOB_OBJECT_SET_ATTRIBUTES, $JOB_OBJECT_SET_SECURITY_ATTRIBUTES, $JOB_OBJECT_TERMINATE)

Global Const $JOB_OBJECT_LIMIT_ACTIVE_PROCESS = 0x00000008
Global Const $JOB_OBJECT_LIMIT_AFFINITY = 0x00000010
Global Const $JOB_OBJECT_LIMIT_BREAKAWAY_OK = 0x00000800
Global Const $JOB_OBJECT_LIMIT_DIE_ON_UNHANDLED_EXCEPTION = 0x00000400
Global Const $JOB_OBJECT_LIMIT_JOB_MEMORY = 0x00000200
Global Const $JOB_OBJECT_LIMIT_JOB_TIME = 0x00000004
Global Const $JOB_OBJECT_LIMIT_KILL_ON_JOB_CLOSE = 0x00002000
Global Const $JOB_OBJECT_LIMIT_PRESERVE_JOB_TIME = 0x00000040
Global Const $JOB_OBJECT_LIMIT_PRIORITY_CLASS = 0x00000020
Global Const $JOB_OBJECT_LIMIT_PROCESS_MEMORY = 0x00000100
Global Const $JOB_OBJECT_LIMIT_PROCESS_TIME = 0x00000002
Global Const $JOB_OBJECT_LIMIT_SCHEDULING_CLASS = 0x00000080
Global Const $JOB_OBJECT_LIMIT_SILENT_BREAKAWAY_OK = 0x00001000
Global Const $JOB_OBJECT_LIMIT_WORKINGSET = 0x00000001

Global Const $JOB_OBJECT_UILIMIT_DESKTOP = 0x00000040
Global Const $JOB_OBJECT_UILIMIT_DISPLAYSETTINGS = 0x00000010
Global Const $JOB_OBJECT_UILIMIT_EXITWINDOWS = 0x00000080
Global Const $JOB_OBJECT_UILIMIT_GLOBALATOMS = 0x00000020
Global Const $JOB_OBJECT_UILIMIT_HANDLES = 0x00000001
Global Const $JOB_OBJECT_UILIMIT_READCLIPBOARD = 0x00000002
Global Const $JOB_OBJECT_UILIMIT_SYSTEMPARAMETERS = 0x00000008
Global Const $JOB_OBJECT_UILIMIT_WRITECLIPBOARD = 0x00000004

Global Const $JOB_OBJECT_SECURITY_FILTER_TOKENS = 0x00000008
Global Const $JOB_OBJECT_SECURITY_NO_ADMIN = 0x00000001
Global Const $JOB_OBJECT_SECURITY_ONLY_TOKEN = 0x00000004
Global Const $JOB_OBJECT_SECURITY_RESTRICTED_TOKEN = 0x00000002

Global Const $JOB_OBJECT_TERMINATE_AT_END_OF_JOB = 0
Global Const $JOB_OBJECT_POST_AT_END_OF_JOB = 1

; _WinAPI_OpenSemaphore()
Global Const $SEMAPHORE_MODIFY_STATE = 0x0002
Global Const $SEMAPHORE_QUERY_STATE = 0x0001
Global Const $SEMAPHORE_ALL_ACCESS = 0x001F0003 ; BitOR($STANDARD_RIGHTS_ALL, $SEMAPHORE_MODIFY_STATE, $SEMAPHORE_QUERY_STATE)

; _WinAPI_SetThreadExecutionState()
Global Const $ES_AWAYMODE_REQUIRED = 0x00000040
Global Const $ES_CONTINUOUS = 0x80000000
Global Const $ES_DISPLAY_REQUIRED = 0x00000002
Global Const $ES_SYSTEM_REQUIRED = 0x00000001
Global Const $ES_USER_PRESENT = 0x00000004
; ===============================================================================================================================
