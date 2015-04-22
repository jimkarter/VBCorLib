VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "PathTests"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
'
' TestPath
'
Option Explicit
Implements ITestCaseSource

Private Declare Function GetLongPathNameA Lib "kernel32.dll" (ByVal lpszShortPath As String, ByVal lpszLongPath As String, ByVal cchBuffer As Long) As Long

Private mOriginalDir As String

Private Sub ITestCaseSource_GetTestCases(ByVal Test As SimplyVBComp.TestCaseCollector)
    Select Case Test.MethodName
        Case "ChangeExtension_WithValue_ReturnsExpected"
            Test.Use "Filename.txt", "rec", "Filename.rec"
            Test.Use "c.:hello", "", "c.:hello."
            Test.Use "hello.txt", "", "hello."
            Test.Use "hello", "d.d", "hello.d.d"
            Test.Use "h.ello", "d.d", "h.d.d"
            Test.Use "hello", ".txt", "hello.txt"
            Test.Use "hello", "txt", "hello.txt"
            Test.Use "", "", ""
            Test.Use "hello.", ".txt", "hello.txt"
            Test.Use "hello\", "txt", "hello\.txt"
            Test.Use "c:\hello", "txt", "c:\hello.txt"
            Test.Use ".txt", "def", ".def"
            
        Case "IsPathRooted_WithValue_ReturnsExpected"
            Test.Use "c:\", True
            Test.Use "\folder", True
            Test.Use "\\share", True
            Test.Use "//share", True
            Test.Use "Abc\file", False
            Test.Use ":\folder", False
            Test.Use "", False
            
        Case "HasExtension_WithValue_ReturnsExpected"
            Test.Use "file.txt", True
            Test.Use ".a", True
            Test.Use ".", False
            Test.Use ".\file", False
            Test.Use "file.", False
            Test.Use "file", False
            
        Case "Combine_WithValues_ReturnsExpected"
            Test.Use "a", "\b", "\b"
            Test.Use "a/", "b", "a/b"
            Test.Use "a", "b", "a\b"
            Test.Use "a:", "b", "a:b"
            Test.Use "c:\", "*.txt", "c:\*.txt"
            Test.Use "", "*.txt", "*.txt"
            Test.Use "", "", ""
            Test.Use "a", "", "a"
            Test.Use "", "b", "b"
            
        Case "GetDirectoryName_WithValue_ReturnsExpected"
            Test.Use "c:\abc", "c:\"
            Test.Use "c:\abc\", "c:\abc"
            Test.Use "c:\", ""
            Test.Use "abc", ""
            Test.Use "abc\", "abc"
            Test.Use "\\server\share", ""
            Test.Use "\\server\share\", "\\server\share"
            Test.Use "\\\\server\\share\\", "\\server\share"
            Test.Use "C:\Documents and Settings\Kelly\Local Settings\Temp\tmpC24.tmp", "C:\Documents and Settings\Kelly\Local Settings\Temp"
            Test.Use "c:\....\abc", "c:\.."
            Test.Use "c:\....\abc\", "c:\..\abc"
            
        Case "GetExtension_WithValue_ReturnsExpected"
            Test.Use "file.txt", ".txt"
            Test.Use "file", ""
            Test.Use ".", ""
            Test.Use "..", ""
            Test.Use "c.:txt", ""
            Test.Use "", ""
            Test.Use "c:\abc.txt\ab", ""
            
        Case "GetFileName_WithValue_ReturnsExpected"
            Test.Use "file.txt", "file.txt"
            Test.Use "c:\file.txt", "file.txt"
            Test.Use "c:\", ""
            Test.Use ":file.txt", "file.txt"
            Test.Use ".txt", ".txt"
            
        Case "GetFileNameWithoutExtension_WithValue_ReturnsExpected"
            Test.Use "file.txt", "file"
            Test.Use "c:\file.txt", "file"
            Test.Use "c:\", ""
            Test.Use "c:file.txt", "file"
            Test.Use "file", "file"
            Test.Use "c:file", "file"
            Test.Use "c:.file", ""
            Test.Use "", ""
            Test.Use "c:\file.txt.txt", "file.txt"
            Test.Use "file.txt.txt", "file.txt"
            Test.Use "file.txt\", ""
            Test.Use ".txt", ""

        Case "GetFullPath_WithValue_ReturnsExpected"
            Test.Use "file.txt", "c:\windows\file.txt"
            Test.Use "\file.txt", "c:\file.txt"
            Test.Use "\\server\share", "\\server\share"
            Test.Use "\\server\share\", "\\server\share\"
            Test.Use "c:\abc.txt", "c:\abc.txt"
            Test.Use "c\abc.txt", "c:\windows\c\abc.txt"
            Test.Use "a\b...\a", "c:\windows\a\b\a"
            Test.Use "a\...b\a", "c:\windows\a\...b\a"
            Test.Use "c:\", "c:\"
            Test.Use "c:\\\", "c:\"
            Test.Use "\\\\server\\\share", "\\server\share"
            Test.Use "\\\\server\\\share\\\", "\\server\share\"
            Test.Use "c:\abc\def\ghi\..\..\jkl", "c:\abc\jkl"
            Test.Use "..\jkl", "c:\jkl"
            Test.Use "//server/share/file.txt", "\\server\share\file.txt"
            
        Case "GetFullPath_WithInvalidPath_ThrowsArgumentException"
            Test.Use "\\server"
            Test.Use "\\server\"
            Test.Use ""
            Test.Use " "
            
        Case "GetPathRoot_WithValue_ReturnsExpected"
            Test.Use "\mydir\", "\"
            Test.Use "c:", "c:"
            Test.Use "file.txt", ""
            Test.Use "c:\file.txt", "c:\"
            Test.Use "\\server", "\\server"
            Test.Use "\\server\", "\\server\"
            Test.Use "\\server\share", "\\server\share"
            Test.Use "\\server\share\dir", "\\server\share"
            Test.Use "\\", "\\"
            Test.Use "\\\", "\\"
            Test.Use "\\.\", "\\.\"
            Test.Use "\\\a", "\\a"
    End Select
End Sub

Public Sub Setup()
    mOriginalDir = CurDir
    ChDir "c:\windows"
End Sub

Public Sub Teardown()
    ChDir mOriginalDir
End Sub

Public Sub GetInvalidPathChars_WhenCalled_ReturnsArrayOfChars()
    Dim Actual() As Integer
    
    Actual = Path.GetInvalidPathChars
    
    Dim Expected() As Integer
    Expected = NewIntegers(34, Asc("<"), Asc(">"), Asc("|"), 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31)
    Assert.That Actual, Iz.EquivalentTo(Expected)
End Sub

Public Sub ChangeExtension_WithValue_ReturnsExpected(ByVal PathToChange As String, ByVal NewExtension As String, ByVal Expected As String)
    Dim Actual As String
    
    Actual = Path.ChangeExtension(PathToChange, NewExtension)
    
    Assert.That Actual, Iz.EqualTo(Expected)
End Sub

Public Sub ChangeExtension_WithNullString_RemovesExtension()
    Dim Actual As String
    
    Actual = Path.ChangeExtension("hello.txt", vbNullString)
    
    Assert.That Actual, Iz.EqualTo("hello")
End Sub

Public Sub IsPathRooted_WithValue_ReturnsExpected(ByVal PathToCheck As String, ByVal Expected As Boolean)
    Dim Actual As Boolean
    
    Actual = Path.IsPathRooted(PathToCheck)
    
    Assert.That Actual, Iz.EqualTo(Expected)
End Sub

Public Sub HasExtension_WithValue_ReturnsExpected(ByVal PathToCheck As String, ByVal Expected As Boolean)
    Dim Actual As Boolean
    
    Actual = Path.HasExtension(PathToCheck)
    
    Assert.That Actual, Iz.EqualTo(Expected)
End Sub

Public Sub Combine_WithValues_ReturnsExpected(ByVal Path1 As String, ByVal Path2 As String, ByVal Expected As String)
    Dim Actual As String
    
    Actual = Path.Combine(Path1, Path2)
    
    Assert.That Actual, Iz.EqualTo(Expected)
End Sub

Public Sub GetDirectoryName_WithValue_ReturnsExpected(ByVal PathToUse As String, ByVal Expected As String)
    Dim Actual As String
    
    Actual = Path.GetDirectoryName(PathToUse)
    
    Assert.That Actual, Iz.EqualTo(Expected)
End Sub

Public Sub GetExtension_WithValue_ReturnsExpected(ByVal PathToUse As String, ByVal Expected As String)
    Dim Actual As String
    
    Actual = Path.GetExtension(PathToUse)
    
    Assert.That Actual, Iz.EqualTo(Expected)
End Sub

Public Sub GetFileName_WithValue_ReturnsExpected(ByVal PathToUse As String, ByVal Expected As String)
    Dim Actual As String
    
    Actual = Path.GetFileName(PathToUse)
    
    Assert.That Actual, Iz.EqualTo(Expected)
End Sub

Public Sub GetFileNameWithoutExtension_WithValue_ReturnsExpected(ByVal PathToUse As String, ByVal Expected As String)
    Dim Actual As String
    
    Actual = Path.GetFileNameWithoutExtension(PathToUse)
    
    Assert.That Actual, Iz.EqualTo(Expected)
End Sub

Public Sub GetFullPath_WithValue_ReturnsExpected(ByVal PathToUse As String, ByVal Expected As String)
    Dim Actual As String
    
    Actual = Path.GetFullPath(PathToUse)
    
    Assert.That Actual, Iz.EqualTo(Expected).IgnoreCase
End Sub

Public Sub GetFullPath_WithInvalidPath_ThrowsArgumentException(ByVal InvalidPath As String)
    On Error GoTo errTrap
    
    Path.GetFullPath InvalidPath
    
errTrap:
    AssertArgumentException Err
End Sub

Public Sub GetFullPath_WithMultipleColons_ThrowsNotSupportedException()
    On Error GoTo errTrap
    
    Path.GetFullPath "c:\a:"
    
errTrap:
    AssertNotSupportedException Err
End Sub

Public Sub GetPathRoot_WithValue_ReturnsExpected(ByVal PathToUse As String, ByVal Expected As String)
    Dim Actual As String
    
    Actual = Path.GetPathRoot(PathToUse)
    
    Assert.That Actual, Iz.EqualTo(Expected)
End Sub

Public Sub GetTempFileName_WhenCalled_ReturnsNewlyCreatedTempFile()
    On Error GoTo errTrap
    Dim TempFileName As String
    
    TempFileName = Path.GetTempFileName
    
    Assert.That TempFileName, Iz.Not.Empty
    Assert.That FileLen(TempFileName), Iz.EqualTo(0)
    
errTrap:
    If Len(Dir(TempFileName)) > 0 Then
        Kill TempFileName
    End If
    
    If Err.Number <> 0 Then
        Err.Raise Err.Number, , Err.Description
    End If
End Sub

Public Sub GetTempPath_WhenCalled_NewTempPath()
    Dim TempPath As String
    
    TempPath = Path.GetTempPath
    
    Assert.That TempPath, Iz.Not.Empty
    Assert.That Path.IsPathRooted(TempPath), Iz.True
    Assert.That Right$(TempPath, 1), Iz.EqualTo(Path.DirectorySeparatorString)
End Sub


