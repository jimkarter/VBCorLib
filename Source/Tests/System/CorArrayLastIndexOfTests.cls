VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "CorArrayLastIndexOfTests"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
'
' CorArrayLastIndexOfTests
'
Option Explicit
Implements ITestCaseSource
Implements ICategorizable

Private Sub ICategorizable_Categorize(ByVal Cat As SimplyVBComp.CategoryCollector)
    Cat.ForFixture "System"
End Sub

Private Sub ITestCaseSource_GetTestCases(ByVal Test As SimplyVBComp.TestCaseCollector)
    Select Case Test.MethodName
        Case "LastIndexOf_WithValues_ReturnsExpected"
            Test.Use NewBytes(4, 2, 3, 4, 5, 6), 4, 3
            Test.Use NewLongs(1, 2, 3, 4, 5, 6), 7, -1
            Test.Use NewIntegers(4, 2, 3, 4, 5, 6), 4, 3
            Test.Use NewLongs(4, 2, 3, 4, 5, 6), 4, 3
            Test.Use NewDoubles(4, 2, 3, 4, 5, 6), 4, 3
            Test.Use NewSingles(4, 2, 3, 4, 5, 6), 4, 3
            Test.Use NewCurrencies(4, 2, 3, 4, 5, 6), 4, 3
            Test.Use NewStrings("4", "2", "3", "4", "5", "6"), "4", 3
            Test.Use NewDates(#4/1/2001#, #2/1/2001#, #3/1/2001#, #4/1/2001#, #5/1/2001#, #6/1/2001#), #4/1/2001#, 3
            Test.Use NewVariants("4", "2", "3", "4", "5", "6"), "4", 3
            
            Dim Arr(2) As Int32
            Set Arr(0) = NewInt32(1)
            Set Arr(1) = NewInt32(2)
            Set Arr(2) = Arr(0)
            Test.Use Arr, Arr(2), 2
            Test.Use Arr, New Int32, -1
            
            Set Arr(0) = Nothing
            Set Arr(2) = Nothing
            Test.Use Arr, Nothing, 2
            
            Dim ArrLongs(1 To 3) As Long
            Test.Use ArrLongs, 1, 0
            
    End Select
End Sub

Public Sub LastIndexOf_WithValues_ReturnsExpected(ByRef Arr As Variant, ByRef Value As Variant, ByVal Expected As Long)
    Dim Actual As Long
    
    Actual = CorArray.LastIndexOf(Arr, Value)
    
    Assert.That Actual, Iz.EqualTo(Expected)
End Sub

Public Sub LastIndexOf_WithNullArray_Throws()
    Dim Arr() As Long

    On Error Resume Next
    CorArray.LastIndexOf Arr, 1

    AssertArgumentNullException Err, "Arr"
End Sub

Public Sub LastIndexOf_WithMuliDimensionArray_Throws()
    Dim Arr(0, 0) As Long

    On Error Resume Next
    CorArray.LastIndexOf Arr, 0

    AssertRankException Err
End Sub

Public Sub LastIndexOf_WithStartIndexLessThanLBound_Throws()
    Dim Arr(0) As Long

    On Error Resume Next
    CorArray.LastIndexOf Arr, 0, -1

    AssertArgumentOutOfRangeException Err, "StartIndex"
End Sub

Public Sub LastIndexOf_WithStartIndexGreaterThanUBound_Throws()
    Dim Arr(0) As Long

    On Error Resume Next
    CorArray.LastIndexOf Arr, 0, 1

    AssertArgumentOutOfRangeException Err, "StartIndex"
End Sub

Public Sub LastIndexOf_WithCountLessThanZero_Throws()
    Dim Arr(0) As Long

    On Error Resume Next
    CorArray.LastIndexOf Arr, 0, 0, -1

    AssertArgumentOutOfRangeException Err, "Count"
End Sub

Public Sub LastIndexOf_WithStartIndexAndCountGreaterThanUBound_Throws()
    Dim Arr(0) As Long
    
    On Error Resume Next
    CorArray.LastIndexOf Arr, 0, 0, 2
    
    AssertArgumentOutOfRangeException Err
End Sub

