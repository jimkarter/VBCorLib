VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "Environment"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
'The MIT License (MIT)
'Copyright (c) 2012 Kelly Ethridge
'
'Permission is hereby granted, free of charge, to any person obtaining a copy
'of this software and associated documentation files (the "Software"), to deal
'in the Software without restriction, including without limitation the rights to
'use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
'the Software, and to permit persons to whom the Software is furnished to do so,
'subject to the following conditions:
'
'The above copyright notice and this permission notice shall be included in all
'copies or substantial portions of the Software.
'
'THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
'INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
'PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
'FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
'OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
'DEALINGS IN THE SOFTWARE.
'
'
' Module: Environment
'

''
' The Environment class provides functions for retrieving information about the local machine
'
' @remarks This class cannot be directly instantiated. In order to access the methods, use
' the class name directly.
' <pre>
' Debug.Print Environment.MachineName
' Debug.Print Environment.UserName
' </pre>
'
Option Explicit
Private Declare Function IsWow64Process Lib "kernel32.dll" (ByVal Handle As Long, ByRef IsWow64 As Long) As Long
Private Declare Function GetCurrentProcess Lib "kernel32.dll" () As Long

Private Const ERR_PATHNOTFOUND              As Long = 76
Private Const MAX_COMPUTERNAME_LENGTH       As Long = 31
Private Const UNLEN                         As Long = 256
Private Const UOI_FLAGS                     As Long = 1
Private Const WSF_VISIBLE                   As Long = 1
Private Const WM_SETTINGCHANGE              As Long = &H1A
Private Const HWND_BROADCAST                As Long = &HFFFF&
Private Const SMTO_NORMAL                   As Long = &H0
Private Const ERROR_ENVVAR_NOT_FOUND        As Long = 203&


''
' This enum represents a list of folders accessible using <i>GetFolderPath</i>.
' These definitions are from the Microsoft Dot NET 1.1 MSDN Library.
'
' @param AdminTools The file system directory that is used to store administrative tools for an individual user. The Microsoft Management Console (MMC) will save customized consoles to this directory, and it will roam with the user.
' @param ApplicationData The directory that serves as a common repository for application-specific data for the current roaming user.
' A roaming user works on more than one computer on a network. A roaming user's profile is kept on a server on the network and is loaded onto a system when the user logs on.
' @param CDBurning The file system directory that acts as a staging area for files waiting to be written to a CD.
' @param CommonAdminTools The file system directory that contains administrative tools for all users of the computer.
' @param CommonApplicationData The directory that serves as a common repository for application-specific data that is used by all users.
' @param CommonDesktopDirectory The file system directory that contains files and folders that appear on the desktop for all users. This special folder is valid only for Windows NT systems.
' @param CommonDocuments The file system directory that contains documents that are common to all users. This special folder is valid for Windows NT systems, Windows 95, and Windows 98 systems with Shfolder.dll installed.
' @param CommonMusic The file system directory that serves as a repository for music files common to all users.
' @param CommonOemLinks This value is recognized in Windows Vista for backward compatibility, but the special folder itself is no longer used.
' @param CommonPictures The file system directory that serves as a repository for image files common to all users.
' @param CommonPrograms A folder for components that are shared across applications. This special folder is valid only for Windows NT, Windows 2000, and Windows XP systems.
' @param CommonProgramFiles The directory for components that are shared across applications. To get the x86 common program files directory on a non-x86 system, use the ProgramFilesX86 member.
' @param CommonProgramFilesX86 The <b>Program Files</b> folder.
' @param CommonStartMenu The file system directory that contains the programs and folders that appear on the Start menu for all users. This special folder is valid only for Windows NT systems.
' @param CommonStartup The file system directory that contains the programs that appear in the Startup folder for all users. This special folder is valid only for Windows NT systems.
' @param CommonTemplates The file system directory that contains the templates that are available to all users. This special folder is valid only for Windows NT systems.
' @param CommonVideos The file system directory that serves as a repository for video files common to all users.
' @param Cookies The directory that serves as a common repository for Internet cookies.
' @param Desktop The logical Desktop rather than the physical file system location.
' @param DesktopDirectory The directory used to physically store file objects on the desktop.
' Do not confuse this directory with the desktop folder itself, which is a virtual folder.
' @param Favorites The directory that serves as a common repository for the user's favorite items.
' @param Fonts A virtual folder that contains fonts.
' @param History The directory that serves as a common repository for Internet history items.
' @param InternetCache The directory that serves as a common repository for temporary Internet files.
' @param LocalApplicationData The directory that serves as a common repository for application-specific data that is used by the current, non-roaming user.
' @param LocalizedResources The file system directory that contains localized resource data.
' @param MyComputer The <b>My Computer</b> folder.
' @param MyDocuments The <b>My Documents</b> folder. This member is equivalent to <b>Personal</b>.
' @param MyMusic The <b>My Music</b> folder.
' @param MyPictures The <b>My Pictures</b> folder.
' @param MyVideos The file system directory that serves as a repository for videos that belong to a user.
' @param NetworkShortcuts A file system directory that contains the link objects that may exist in the <b>My Network Places</b> virtual folder.
' @param Personal The directory that serves as a common repository for documents (My Documents).
' @param PrinterShortcuts The file system directory that contains the link objects that can exist in the Printers virtual folder.
' @param ProgramFiles The program files folder.
' @param ProgramFilexX86 The <b>Program Files</b> folder. On an x86 system, passing the <b>ProgramFilesX86</b> member to the <a href="Environment.GetFolderPath.html">Environment.GetFolderPath</b> method returns an empty string; use the <b>ProgramFiles</b> member instead. You can determine whether Windows is a 32-bit operating system by calling the Environment.Is64BitOperatingSystem property.
' @param Programs The directory that contains the user's program groups.
' @param Recent The directory that contains the user's most recently used documents.
' @param Resources The file system directory that contains resource data.
' @param SendTo The directory that contains the Send To menu items.
' @param StartMenu The directory that contains the Start menu items.
' @param Startup The directory that corresponds to the user's Startup program group.
' The system starts these programs whenever a user logs on or starts Windows NT or later, or starts Windows 98.
' @param SystemDir The system directory.
' @param SystemX86 The Windows <b>System</b> folder.
' @param Templates The directory that serves as a common repository for document templates.
' @param UserProfile The user's profile folder. Applications should not create files or folders at this level; they should put their data under the locations referred to by <b>ApplicationData</b>.
' @param Windows The windows directory.
'
Public Enum SpecialFolder
    AdminTools = Win32Native.CSIDL_ADMINTOOLS
    ApplicationData = Win32Native.CSIDL_APPDATA
    CDBurning = Win32Native.CSIDL_CDBURN_AREA
    CommonAdminTools = Win32Native.CSIDL_COMMON_ADMINTOOLS
    CommonApplicationData = Win32Native.CSIDL_COMMON_APPDATA
    CommonDesktopDirectory = Win32Native.CSIDL_COMMON_DESKTOPDIRECTORY
    CommonDocuments = Win32Native.CSIDL_COMMON_DOCUMENTS
    CommonMusic = Win32Native.CSIDL_COMMON_MUSIC
    CommonOemLinks = Win32Native.CSIDL_COMMON_OEM_LINKS
    CommonPictures = Win32Native.CSIDL_COMMON_PICTURES
    CommonPrograms = Win32Native.CSIDL_COMMON_PROGRAMS
    CommonProgramFiles = Win32Native.CSIDL_PROGRAM_FILES_COMMON
    CommonProgramFilesX86 = Win32Native.CSIDL_PROGRAM_FILES_COMMONX86
    CommonStartMenu = Win32Native.CSIDL_COMMON_STARTMENU
    CommonStartup = Win32Native.CSIDL_COMMON_STARTUP
    CommonTemplates = Win32Native.CSIDL_COMMON_TEMPLATES
    CommonVideos = Win32Native.CSIDL_COMMON_VIDEO
    Cookies = Win32Native.CSIDL_COOKIES
    Desktop = Win32Native.CSIDL_DESKTOP
    DesktopDirectory = Win32Native.CSIDL_DESKTOPDIRECTORY
    Fonts = Win32Native.CSIDL_FONTS
    Favorites = Win32Native.CSIDL_FAVORITES
    History = Win32Native.CSIDL_HISTORY
    InternetCache = Win32Native.CSIDL_INTERNET_CACHE
    LocalApplicationData = Win32Native.CSIDL_LOCAL_APPDATA
    LocalizedResources = Win32Native.CSIDL_RESOURCES_LOCALIZED
    MyComputer = Win32Native.CSIDL_DRIVES
    MyDocuments = Win32Native.CSIDL_PERSONAL
    MyMusic = Win32Native.CSIDL_MYMUSIC
    MyPictures = Win32Native.CSIDL_MYPICTURES
    MyVideos = Win32Native.CSIDL_MYVIDEO
    NetworkShortcuts = Win32Native.CSIDL_NETHOOD
    Personal = Win32Native.CSIDL_PERSONAL
    PrinterShortcuts = Win32Native.CSIDL_PRINTHOOD
    ProgramFiles = Win32Native.CSIDL_PROGRAM_FILES
    ProgramFilesX86 = Win32Native.CSIDL_PROGRAM_FILESX86
    Programs = Win32Native.CSIDL_PROGRAMS
    Recent = Win32Native.CSIDL_RECENT
    Resources = Win32Native.CSIDL_RESOURCES
    SendTo = Win32Native.CSIDL_SENDTO
    StartMenu = Win32Native.CSIDL_STARTMENU
    Startup = Win32Native.CSIDL_STARTUP
    SystemDir = Win32Native.CSIDL_SYSTEM
    SystemX86 = Win32Native.CSIDL_SYSTEMX86
    Templates = Win32Native.CSIDL_TEMPLATES
    UserProfile = Win32Native.CSIDL_PROFILE
    Windows = Win32Native.CSIDL_WINDOWS
End Enum

''
' Used to indicate the source or destination of the
' environment variables when read from or written to the system.
'
' @param Machine The source of the variable is machine wide. These
' are variables that are defined for the system and all users.
' @param Process The source of the variable is for the current process.
' This combines both machine and user level variables, giving priority
' to the user level variables.
' @param User The source of the variable is of the current user.
' @remarks <b>Machine</b> and <b>User</b> are not supported on Windows 95, 98 or ME.
'
Public Enum EnvironmentVariableTarget
    Machine = 0
    Process = 1
    User = 2
End Enum

Private mOSVersion As OperatingSystem


''
' Determines whether the current operating system is a 64-bit operating system.
'
' @return <b>True</b> if the operating system is 64-bit; otherwise, <b>False</b>.
Public Property Get Is64BitOperatingSystem() As Boolean
    Dim Result As Long
    
    If IsWow64Process(GetCurrentProcess, Result) = BOOL_FALSE Then
        Error.Win32Error Err.LastDllError
    End If
    
    Is64BitOperatingSystem = CBool(Result)
End Property

''
' Returns the command specified when executing the current application,
' including any arguments typed after the application name.
'
' @return The command line typed in at a command prompt.
'
Public Property Get CommandLine() As String
    CommandLine = SysAllocString(GetCommandLineW)
End Property

''
' Returns the current directy of the executing application.
'
' @return The current directory.
'
Public Property Get CurrentDirectory() As String
    CurrentDirectory = Directory.GetCurrentDirectory
End Property

''
' Sets the current directory for the executing application.
'
' @param RHS The new directory to change to.
'
Public Property Let CurrentDirectory(ByVal Value As String)
    Directory.SetCurrentDirectory Value
End Property

''
' Returns the name of the local computer.
'
' @return The name of the local computer.
'
Public Property Get MachineName() As String
    Dim Size    As Long
    Dim Buffer  As String
    
    Size = MAX_COMPUTERNAME_LENGTH + 1
    Buffer = String$(Size, 0)
    
    If GetComputerNameW(Buffer, Size) = BOOL_FALSE Then _
        Throw Cor.NewInvalidOperationException(GetMessage(Err.LastDllError))
        
    MachineName = Left$(Buffer, Size)
End Property

''
' Returns string of a newline character for the local computer.
'
' @return The newline characters.
' @remarks Being this always going to be in VB, the return is just vbCrLf.
'
Public Property Get NewLine() As String
    NewLine = vbCrLf
End Property

''
' Returns an object representing the current operating system.
'
' @return The OperatingSystem object that represents the current OS.
'
Public Property Get OSVersion() As OperatingSystem
    Dim Info        As OSVERSIONINFOW
    Dim InfoEx      As OSVERSIONINFOEXW
    Dim ServicePack As String
    Dim Version     As Version

    If mOSVersion Is Nothing Then
        Info.dwOSVersionInfoSize = Len(Info)
        
        If GetVersionExW(Info) = BOOL_FALSE Then _
            Error.InvalidOperation InvalidOperation_GetVersion
        
        ' We are on an NT platform so we can get extra information
        If Info.dwPlatformId = PlatformID.Win32NT Then
            InfoEx.dwOSVersionInfoSize = Len(InfoEx)
            
            If GetVersionExW(InfoEx) = BOOL_FALSE Then _
                Error.InvalidOperation InvalidOperation_GetVersion
            
            ServicePack = SysAllocString(VarPtr(InfoEx.szCSDVersion(0)))
        End If
        
        Set Version = Cor.NewVersion(Info.dwMajorVersion, Info.dwMinorVersion, Info.dwBuildNumber, Helper.ShiftLeft(InfoEx.wServicePackMajor, 16) Or InfoEx.wServicePackMinor)
        Set mOSVersion = Cor.NewOperatingSystem(Info.dwPlatformId, Version, ServicePack)
    End If
    
    Set OSVersion = mOSVersion
End Property

''
' Returns the System directory for the current OS.
'
' @return The system directory.
' @remarks Generally this will be C:\Windows\System32 or C:\Winnt\System32 for NT4 system.
'
Public Property Get SystemDirectory() As String
    Dim Path As String
    Dim Size As Long
    
    Path = String$(MAX_PATH + 1, 0)
    Size = GetSystemDirectoryW(Path, Len(Path))
    
    If Size > 0 Then
        SystemDirectory = Left$(Path, Size)
    End If
End Property

''
' Returns the number of milliseconds the system has been running since it started.
'
' @return Number of milliseconds since the system booted up.
' @remarks Once the maximum value is reached, it will wrap around to be negative,
' at which point negative values will be returned until 0 is reached.
' Wrapping to negative will take place in approximatively 24.85 days.
'
Public Property Get TickCount() As Long
    TickCount = timeGetTime
End Property

''
' Returns the name of the local machine within a domain
'
' @return The computer name within a domain.
' @remarks Typically the domain name is the name of the machine, but
' can change depending on the application being deployed.<br><br>
' <b>UserDomainName</b> is not supported on Windows 95, 98, ME platforms
' and will throw a <b>PlatformNotSupportedException</b> exception.
'
Public Property Get UserDomainName() As String
    Dim Size        As Long
    Dim DomainName  As String
    Dim Sid         As String
    
    Size = 1024
    DomainName = String$(Size, 0)
    
    If GetUserNameExW(NameSamCompatible, DomainName, Size) Then
        Dim i As Long
        i = InStr(DomainName, "\")

        If i > 0 Then
            UserDomainName = Left$(DomainName, i - 1)
            Exit Property
        End If
    End If
    
    Size = 1024
    Sid = String$(Size, 0)
    
    If LookupAccountNameW(vbNullString, UserName, Sid, Size, DomainName, Size, 0) = BOOL_FALSE Then
        IOError.WinIOError Err.LastDllError
    End If
    
    UserDomainName = Left$(DomainName, Size)
End Property

''
' Determines if the current application is allowed to have user interaction.
'
' @return Indication if user interaction is allowed.
' @remarks This is used primarily for when the application is a service. It can
' be used to supress message dialogs and user entry when not allowed.
'
Public Property Get UserInteractive() As Boolean
    Dim hObj As Long
    Dim Info As USEROBJECTFLAGS
    
    If OSVersion.Platform = Win32NT Then
        hObj = GetProcessWindowStation
        
        If GetUserObjectInformationW(hObj, UOI_FLAGS, VarPtr(Info), LenB(Info), 0&) Then
            UserInteractive = (Info.dwFlags And WSF_VISIBLE)
        End If
    Else
        UserInteractive = True
    End If
End Property

''
' Returns the name of the currently logged in user of the local computer.
'
' @return The currently logged in user's name.
'
Public Property Get UserName() As String
    Dim Name As String
    Dim Size As Long
    
    Size = UNLEN + 1
    Name = String$(Size, 0)
    
    If GetUserNameW(Name, Size) Then
        UserName = Left$(Name, Size - 1)
    End If
End Property

''
' Returns the amount of physical memory the current application is allocated.
'
' @return The amount of memory allocated to the application.
' @remarks This method only works for NT installations. 95, 98, and ME will
' receive a 0 when this method is called.
'
Public Property Get WorkingSet() As Currency
    Dim Counters As PROCESS_MEMORY_COUNTERS
    
    Counters.cb = LenB(Counters)
    
    If GetProcessMemoryInfo(GetCurrentProcess, Counters, Counters.cb) Then
        WorkingSet = Counters.WorkingSetSize
    End If
End Property

''
' Replaces environment tags within a string with the actual values.
'
' @param Name A string containing environment variable tags to be replaced.
' @return A string containing actual environment variable values in place of tags.
' @remarks The environment variables are tagged using %.
' A string such as 'My OS is %OS%.' would become 'My OS is Windows_NT.' for NT machines.
'
Public Function ExpandEnvironmentVariables(ByRef Name As String) As String
    Const DEF_SIZE As Long = 1024
    Dim Buffer  As String
    Dim Size    As Long
    
    If Len(Name) = 0 Then
        Exit Function
    End If
    
    Buffer = String$(DEF_SIZE, 0)
    Size = ExpandEnvironmentStringsW(Name, Buffer, DEF_SIZE)
    
    If Size > DEF_SIZE Then
        Buffer = SysAllocStringLen(0, Size)
        Size = ExpandEnvironmentStringsW(Name, Buffer, Size)
    End If
    
    ExpandEnvironmentVariables = Left$(Buffer, Size - 1)
End Function

''
' Returns an array of parsed Arguments from the command line.
'
' @return An array of command line Arguments, including the application name.
' @remarks The application is the first Argument in the array. Arguments are
' separated by spaces. If spaces are embedded in an Arguments and should not
' be used to separate the Arguments, then the Arguments must be surrounded in quotes.
'
Public Function GetCommandLineArgs() As String()
    GetCommandLineArgs = ParseCommandLineArgs(CommandLine)
End Function

''
' Provides a mechanism to parse arguments from a command line string.
'
' @param Line The string to parse the arguments from.
' @return An array of arguments.
'
Public Function ParseCommandLineArgs(ByRef Line As String) As String()
    Dim Length      As Long
    Dim Arguments   As New ArrayList
    Dim Chars()     As Integer
    Dim ArgBuffer() As Integer
    Dim ArgIndex    As Long
    Dim Escaped     As Boolean
    Dim Quoted      As Boolean
    Dim Index       As Long

    Line = Trim$(Line)
    Length = Len(Line)

    If Length = 0 Then
        ParseCommandLineArgs = Cor.NewStrings
        Exit Function
    End If

    Chars = CorString.ToCharArray(Line)
    ReDim ArgBuffer(0 To Length - 1)

    Do While Index < Length
        Select Case Chars(Index)
            Case vbBackslashChar
                If Escaped Then
                    ' We have two back slashes in a row,
                    ' so we actually need to include them
                    ' as part of the argument.
                    ArgBuffer(ArgIndex) = vbBackslashChar
                    ArgBuffer(ArgIndex + 1) = vbBackslashChar
                    ArgIndex = ArgIndex + 2
                    Escaped = False
                Else
                    ' Begin the potential escape sequence.
                    ' We only support escaping double quotes.
                    Escaped = True
                End If

            Case vbQuoteChar
                If Escaped Then
                    ' We are escaping a quote, so it is to
                    ' be included in the argument, but not
                    ' the backslash.
                    ArgBuffer(ArgIndex) = vbQuoteChar
                    ArgIndex = ArgIndex + 1
                    Escaped = False

                    ' We don't end a quoted argument with
                    ' an escaped quote, so let the Quoted
                    ' flag remain as is.

                ElseIf Quoted Then
                    ' We are already in quotes, and so we need
                    ' to determine if we have two quotes in a row.
                    ' If so, then one double quote will be added
                    ' to the argument as if it were escaped.

                    ' Do we have enough character left?
                    If Index + 1 < Length Then
                        ' We have enough, so check for 2nd quote.
                        If Chars(Index + 1) = vbQuoteChar Then
                            ' We have two quotes, so escape it.
                            ArgBuffer(ArgIndex) = vbQuoteChar
                            ArgIndex = ArgIndex + 1
                        End If
                    End If

                    Quoted = False
                Else
                    ' We are starting a quoted section
                    Quoted = True
                End If

            Case vbSpaceChar
                If Escaped Then
                    ArgBuffer(ArgIndex) = vbBackslashChar
                    ArgIndex = ArgIndex + 1
                    Escaped = False
                End If

                If Quoted Then
                    ' Being quoted, so include spaces in the argument.
                    ArgBuffer(ArgIndex) = vbSpaceChar
                    ArgIndex = ArgIndex + 1
                Else
                    Arguments.Add CorString.FromCharArray(ArgBuffer, 0, ArgIndex)
                    ArgIndex = 0
                End If

            Case Else
                ' If we were escaped, but didn't make use of it
                ' then we need to include that backslash in the ouput.
                If Escaped Then
                    ArgBuffer(ArgIndex) = vbBackslashChar
                    ArgIndex = ArgIndex + 1
                    Escaped = False
                End If

                ArgBuffer(ArgIndex) = Chars(Index)
                ArgIndex = ArgIndex + 1
        End Select

        Index = Index + 1
    Loop

    ' If a backslash was the last character in the line, then
    ' it was escaped, but now we need to include it since there
    ' are no more characters.
    If Escaped Then
        ArgBuffer(ArgIndex) = vbBackslashChar
        ArgIndex = ArgIndex + 1
    End If

    If ArgIndex > 0 Then
        Arguments.Add CorString.FromCharArray(ArgBuffer, 0, ArgIndex)
    End If

    ParseCommandLineArgs = Arguments.ToArray(vbString)
End Function

''
' Returns an environment variable value.
'
' @param Name The name of the environment variable to return.
' @param Target The system region to retrieve the variable from.
' @return The value of the environment variable.
' @remarks If the variable does not exist, then an empty string is returned.
' <p>A Target of Process will retrieve the variable from the current process. Other
' targets will retrieve the variable value from the registry.</p>
'
Public Function GetEnvironmentVariable(ByRef Name As String, Optional ByVal Target As EnvironmentVariableTarget = EnvironmentVariableTarget.Process) As String
    Dim Key     As RegistryKey
    Dim Size    As Long
    Dim Buf     As String
    Dim Result  As Long
    
    Select Case Target
        Case EnvironmentVariableTarget.Process
            ' use the GetEnvironmentVariable api to allow for realtime
            ' updating of the environment variables for the current
            ' process. VB's Environ does not reflect variable changes.
            Size = 128
            Do
                Buf = String$(Size, 0)
                Size = GetEnvironmentVariableW(Name, Buf, Size)
                
                If Size = 0 Then
                    Result = Err.LastDllError
                    
                    If Result = ERROR_ENVVAR_NOT_FOUND Or Result = 0 Then
                        Exit Function
                    End If
                    
                    Error.Win32Error Result
                End If
            Loop While Size > Len(Buf)
            
            GetEnvironmentVariable = Left$(Buf, Size)
        Case EnvironmentVariableTarget.Machine
            Set Key = Registry.LocalMachine.OpenSubKey("System\CurrentControlSet\Control\Session Manager\Environment")

            If Not Key Is Nothing Then
                GetEnvironmentVariable = Key.GetValue(Name, vbNullString)
            End If
        Case EnvironmentVariableTarget.User
            Set Key = Registry.CurrentUser.OpenSubKey("Environment")
            
            If Not Key Is Nothing Then
                GetEnvironmentVariable = Key.GetValue(Name, vbNullString)
            End If
        Case Else
            Error.ArgumentOutOfRange "Target", ArgumentOutOfRange_Enum
    End Select
End Function

''
' Returns an IDictionary object containing all environment variables as name/value pairs.
'
' @param Target The system region to retrieve the environment variable from.
' @return A dictionary containing the name/value pairs.
' @remarks The hidden environment variables are not included in the dictionary.
' <p>A Target of Process will retrieve the variable from the current process. Other
' targets will retrieve the variable value from the registry.</p>
'
Public Function GetEnvironmentVariables(Optional ByVal Target As EnvironmentVariableTarget = Process) As IDictionary
    Dim Ret As New Hashtable
    Dim rk  As RegistryKey
    
    If Target = EnvironmentVariableTarget.Process Then
        ' use the GetEnvironmentStrings api to allow for realtime
        ' updating of the environment variables for the current
        ' process. VB's Environ does not reflect variable changes.
        Set Ret = GetEnvironmentVariablesForProcess
    Else
        Select Case Target
            Case EnvironmentVariableTarget.Machine
                Set rk = Registry.LocalMachine.OpenSubKey("system\currentcontrolset\control\session manager\environment")
            Case EnvironmentVariableTarget.User
                Set rk = Registry.CurrentUser.OpenSubKey("environment")
            Case Else
                Throw Cor.NewArgumentException("Invalid Target value.", "Target")
        End Select
        
        Dim Names() As String
        Names = rk.GetValueNames
        
        Dim i As Long
        For i = 0 To UBound(Names)
            Dim Key     As String
            Dim Value   As String
            
            Key = Names(i)
            Value = rk.GetValue(Key)
            Ret.Add Key, Value
        Next i
    End If
    
    Set GetEnvironmentVariables = Ret
End Function

''
' Returns the path for a specified folder type.
'
' @param Folder The folder to return the path of.
' @return The path for the specified folder.
'
Public Function GetFolderPath(ByVal Folder As SpecialFolder) As String
    Dim Buf As String
    
    Buf = String$(MAX_PATH, 0)
    SHGetFolderPath 0, Folder, 0, 0, Buf
    GetFolderPath = SysAllocString(StrPtr(Buf))
End Function

''
' Returns the logical drives installed on the local machine.
'
' @return An array containing all of the logical drives installed.
'
Public Function GetLogicalDrives() As String()
    GetLogicalDrives = Directory.GetLogicalDrives
End Function

''
' Sets, creates, or deletes an environment variable in the specified region.
'
' @param Variable The name of the variable to set the value for.
' @param Value The value of the variable.
' @param Target The region the variable is located in the system.
' @remarks Setting the variable in the Process region only affects the current
' process that is setting the variable. Setting a variable in a User or Machine
' region will set the values in the registry.
' <p>by setting the value to an empty string, the variable will be deleted.</p>
'
Public Sub SetEnvironmentVariable(ByRef Variable As String, ByRef Value As String, Optional ByVal Target As EnvironmentVariableTarget = Process)
    If Len(Variable) = 0 Then _
        Error.Argument Argument_StringZeroLength, "Variable"
    If InStr(Variable, "=") > 0 Then _
        Throw Cor.NewArgumentException("Variable name cannot contain an equal '=' sign.", "Variable")
    If Len(Variable) > 255 Then _
        Throw Cor.NewArgumentException("Variable name cannot exceed 255 characters.", "Variable")
    If Len(Value) > 32767 Then _
        Throw Cor.NewArgumentException("Value cannot exceed a length of 32767 characters including the terminating null.", "Value")
    
    Select Case Target
        Case EnvironmentVariableTarget.Process
            If SetEnvironmentVariableW(Variable, Value) = BOOL_FALSE Then _
                Throw Cor.NewArgumentException(GetMessage(Err.LastDllError), "Value")
                
        Case EnvironmentVariableTarget.Machine, EnvironmentVariableTarget.User
            Dim rk As RegistryKey
            
            If Target = EnvironmentVariableTarget.Machine Then
                Set rk = Registry.LocalMachine.OpenSubKey("system\currentcontrolset\control\session manager\environment", True)
            Else
                Set rk = Registry.CurrentUser.OpenSubKey("environment", True)
            End If
            
            If Len(Value) > 0 Then
                rk.SetValue Variable, Value
            Else
                rk.DeleteValue Variable, False
            End If
            
            SendMessageTimeout HWND_BROADCAST, WM_SETTINGCHANGE, 0, StrPtr("Environment"), SMTO_NORMAL, 1000, 0
        Case Else
            Throw Cor.NewArgumentException("Invalid target specified.", "Target")
    End Select
End Sub

''
' Returns the number of processors on the current machine.
'
' @return The processor count.
'
Public Property Get ProcessorCount() As Long
    Dim Info As SYSTEM_INFO
    
    GetSystemInfo Info
    ProcessorCount = Info.dwNumberOfProcessors
End Property

Friend Function GetResourceString(ByVal Key As ResourceStringKey, ParamArray Args() As Variant) As String
    Dim Text As String
    Text = LoadResString(Key)

    If UBound(Args) >= 0 Then
        Dim Arguments() As Variant
        Helper.Swap4 ByVal ArrPtr(Arguments), ByVal Helper.DerefEBP(16)
        GetResourceString = CorString.FormatArray(Text, Arguments)
    Else
        GetResourceString = Text
    End If
End Function

Friend Function GetParameterName(ByVal Key As ParameterName) As String
    GetParameterName = LoadResString(Key)
End Function

Friend Sub VerifyNTMachine()
    If Not IsNT Then
        Throw Cor.NewNotSupportedException("This operation is only supported on Windows NT platforms.")
    End If
End Sub

Friend Function IsNT() As Boolean
    IsNT = (OSVersion.Platform = Win32NT)
End Function


'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'   Helpers
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

' we need to use the GetEnvironmentStrings API method instead of
' iterating through the variables using Environ because Environ
' does not reflect changes to the variables after the application starts.
Private Function GetEnvironmentVariablesForProcess() As Hashtable
    Dim Variables               As New Hashtable
    Dim EnvironmentStringsPtr   As Long

    EnvironmentStringsPtr = GetEnvironmentStringsW
    
    If EnvironmentStringsPtr = vbNullPtr Then _
        Throw New OutOfMemoryException
        
    Dim s       As String
    Dim Ptr     As Long
    Dim Parts() As String
    
    Ptr = EnvironmentStringsPtr
    
    Do
        s = SysAllocString(Ptr)

        If Len(s) = 0 Then
            Exit Do
        ElseIf AscW(s) <> vbEqualChar Then
            Parts = Split(s, "=", 2)
            Variables.Add Parts(0), Parts(1)
        End If
    
        Ptr = Ptr + LenB(s) + vbSizeOfChar
    Loop

    FreeEnvironmentStringsW EnvironmentStringsPtr
    Set GetEnvironmentVariablesForProcess = Variables
End Function


