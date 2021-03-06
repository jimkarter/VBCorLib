VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "SBCSCodePageEncodingTests"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
'
' SBCSCodePageEncodingTests
'
Option Explicit
Implements ICategorizable
Implements ITestCaseSource

Private Sub ICategorizable_Categorize(ByVal Cat As SimplyVBComp.CategoryCollector)
    Cat.ForFixture "System.Text"
End Sub

Private Sub ITestCaseSource_GetTestCases(ByVal Test As SimplyVBComp.TestCaseCollector)
    Select Case Test.MethodName
        Case "GetCharCount_WithValues_ReturnsExpected"
            Test.Use NewBytes(), 0
            Test.Use NewBytes(&H41), 1
            Test.Use NewBytes(&H41, &H42), 2
            
        Case "GetChars_WithValues_ReturnsExpected"
            Test.Use NewBytes(), NewChars()
            Test.Use NewBytes(&H41), NewChars("A")
            Test.Use NewBytes(&H41, &H42), NewChars("A", "B")
        
        Case "GetCharsEx_WithValues_ReturnsExpected"
            Test.Use NewBytes(), NewChars()
            Test.Use NewBytes(&H41), NewChars("A")
            Test.Use NewBytes(&H41, &H42), NewChars("A", "B")
        
        Case "GetString_WithValues_ReturnsExpected"
            Test.Use NewBytes(), ""
            Test.Use NewBytes(&H41), "A"
            Test.Use NewBytes(&H41, &H42), "AB"
        
        Case "GetByteCount_WithValues_ReturnsExpected"
            Test.Use NewChars(), 0
            Test.Use NewChars("A"), 1
            Test.Use NewChars("A", "B"), 2
        
        Case "GetBytes_WithValues_ReturnsExpected"
            Test.Use NewChars(), NewBytes()
            Test.Use NewChars("A"), NewBytes(&H41)
            Test.Use NewChars("A", "B"), NewBytes(&H41, &H42)
        
        Case "GetBytesEx_WithValues_ReturnsExpected"
            Test.Use NewChars(), NewBytes()
            Test.Use NewChars("A"), NewBytes(&H41)
            Test.Use NewChars("A", "B"), NewBytes(&H41, &H42)
        
    End Select
End Sub

Public Sub GetCharCount_WithValues_ReturnsExpected(ByRef Bytes() As Byte, ByVal Expected As Long)
    Dim En As Encoding
    Set En = MakeEncoding
    
    Dim Actual As Long
    Actual = En.GetCharCount(Bytes)
    
    Assert.That Actual, Iz.EqualTo(Expected)
End Sub

Public Sub GetChars_WithValues_ReturnsExpected(ByRef Bytes() As Byte, ByRef Expected() As Integer)
    Dim En As Encoding
    Set En = MakeEncoding
    
    Dim Actual() As Integer
    Actual = En.GetChars(Bytes)
    
    Assert.That Actual, Iz.EqualTo(Expected)
End Sub

Public Sub GetCharsEx_WithValues_ReturnsExpected(ByRef Bytes() As Byte, ByRef Expected() As Integer)
    Dim En As Encoding
    Set En = MakeEncoding
    
    Dim Actual() As Integer
    Dim ActualLength As Long
    Actual = CorArray.CreateInstance(vbInteger, CorArray.Length(Expected))
    ActualLength = En.GetCharsEx(Bytes, 0, CorArray.Length(Bytes), Actual, 0)
    
    Assert.That ActualLength, Iz.EqualTo(CorArray.Length(Expected))
    Assert.That Actual, Iz.EqualTo(Expected)
End Sub

Public Sub GetString_WithValues_ReturnsExpected(ByRef Bytes() As Byte, ByVal Expected As String)
    Dim En As Encoding
    Set En = MakeEncoding
    
    Dim Actual As String
    Actual = En.GetString(Bytes)
    
    Assert.That Actual, Iz.EqualTo(Expected)
End Sub

Public Sub GetByteCount_WithValues_ReturnsExpected(ByRef Chars() As Integer, ByVal Expected As Long)
    Dim En As Encoding
    Set En = MakeEncoding
    
    Dim Actual As Long
    Actual = En.GetByteCount(Chars)
    
    Assert.That Actual, Iz.EqualTo(Expected)
End Sub

Public Sub GetBytes_WithValues_ReturnsExpected(ByRef Chars() As Integer, ByRef Expected() As Byte)
    Dim En As Encoding
    Set En = MakeEncoding
    
    Dim Actual() As Byte
    Actual = En.GetBytes(Chars)
    
    Assert.That Actual, Iz.EqualTo(Expected)
End Sub

Public Sub GetBytesEx_WithValues_ReturnsExpected(ByRef Chars() As Integer, ByRef Expected() As Byte)
    Dim En As Encoding
    Set En = MakeEncoding
    
    Dim Actual()        As Byte
    Dim ActualLength    As Long
    Actual = CorArray.CreateInstance(vbByte, CorArray.Length(Expected))
    ActualLength = En.GetBytesEx(Chars, 0, CorArray.Length(Chars), Actual, 0)
    
    Assert.That Actual, Iz.EqualTo(Expected)
End Sub

Public Sub GetBytes_WithUntranslatableCharacter_ThrowsEncoderFallbackException()
    Dim En As Encoding
    Set En = Encoding.GetEncoding(437, EncoderFallback.ExceptionFallback)
    
    On Error Resume Next
    En.GetBytes NewChars("A", "b", "C", &H2232)
    
    AssertEncoderFallbackException Err
End Sub

Private Function MakeEncoding() As Encoding
    Const PC_DOS As Long = 437
    Set MakeEncoding = Encoding.GetEncoding(PC_DOS)
End Function
