VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "BitMapResourceDecoder"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
'The MIT License (MIT)
'Copyright (c) 2019 Kelly Ethridge
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
' Module: BitmapResourceDecoder
'

''
' Decodes bitmap byte data from a byte array and produces a StdPicture.
' Usually the byte array comes from a .RES file file.
'
' @see ResourceReader
' @see WinResourceReader
'
Option Explicit
Implements IResourceDecoder

Private Const SIZEOF_BITMAPFILEHEADER As Long = 14

Private mKey    As ResourceKey
Private mBitmap As StdPicture


''
' Attempts to decode a set of bytes into a Bitmap.
'
' @param Key The identifier for the set of bytes.
' @param Bytes The byte data to be decoded into a bitmap.
' @return The number of resources decoded from the byte data. Returns 1 on success.
' @remarks The key must be of a resource type bitmap (ResourceTypes.BitmapResource).
' @see ResourceTypes
' @see ResourceKey
'
Public Function Decode(ByVal Key As ResourceKey, Bytes() As Byte) As Long
    If Key Is Nothing Then _
        Error.ArgumentNull "Key"
    If CorArray.IsNull(Bytes) Then _
        Error.ArgumentNull "Bytes", ArgumentNull_Array
    If Key.ResourceType <> ResourceTypes.BitmapResource Then _
        Error.Argument Argument_InvalidResourceKeyType, "Key"
    
    Set mBitmap = CreatePicture(Bytes)
    
    If Not mBitmap Is Nothing Then
        Set mKey = Key
        Decode = 1
    End If
End Function

''
' Returns the of resource this decoder can decode.
'
' @return Returns either a number or string representing the resource type.
' @see ResourceTypes
'
Public Function GetDecodeType() As Variant
    GetDecodeType = ResourceTypes.BitmapResource
End Function

''
' Returns the next decoded resource available in the decoder.
'
' @param ReturnKey This is set to the resource key of the next available resource.
' @param ReturnValue This is set to the resource value of the next available resource.
' @return Returns True if a return resource was available and set, False otherwise.
' @remarks For this resource type only 1 resource is ever returned. Once it is
' returned, the function will return False and the resource cannot be retrieved again.
' @see ResourceKey
'
Public Function GetResource(ByRef ReturnKey As ResourceKey, ByRef ReturnValue As Variant) As Boolean
    If mKey Is Nothing Then
        Exit Function
    End If
    
    Set ReturnKey = mKey
    Set ReturnValue = mBitmap
    
    ' Set these to nothing because we only return them once.
    Set mKey = Nothing
    Set mBitmap = Nothing
    
    GetResource = True
End Function


'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'   Helpers
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Private Function CreatePicture(ByRef Bytes() As Byte) As StdPicture
    Dim ByteIndex       As Long
    Dim ByteCountOffset As Long
    
    ByteIndex = LBound(Bytes)
    
    ' Create a Stream to write the data to, so we can read
    ' from it creating a bitmap picture.
    Dim Stream As IStream
    CreateStreamOnHGlobal 0, BOOL_TRUE, Stream
    
    ' We need to insert a BITMAPFILEHEADER so that
    ' the OleLoadPicture will work correctly, only
    ' if the BITMAPFILEHEADER isn't already there.
    '
    ' The first 2 bytes of the header spell BM.
    If Bytes(ByteIndex) <> &H42 Or Bytes(ByteIndex + 1) <> &H4D Then
        ' The bitmap data begins immediatley after the
        ' BITMAPFILEHEADER, BITMAPINFOHEADER and any
        ' RGBQUAD structures. There are no RGBQUAD
        ' structures for 24bit pictures.
        Dim DataStartOffset As Long
        
        ' All offsets include the BITMAPFILEHEADER(14) and BITMAPINFOHEADER(40)
        ' so start the offset with that.
        DataStartOffset = 54
        
        Const BITCOUNT_OFFSET   As Long = 14
        Const COLORSUSED_OFFSET As Long = 32
        
        Dim ColorsUsed As Long
        ColorsUsed = AsLong(Bytes(ByteIndex + COLORSUSED_OFFSET))
        
        ' If ColorsUsed is 0 then the maximum number
        ' of colors is used based on the bits-per-pixel.
        If ColorsUsed = 0 Then
            Dim BitCount As Long
            BitCount = AsWord(Bytes(ByteIndex + BITCOUNT_OFFSET))
            ColorsUsed = Powers(BitCount)
        End If
        
        ' Add the RGBQUAD structure offset.
        DataStartOffset = DataStartOffset + ColorsUsed * 4
        
        ' The BITMAPFILEHEADER gets aligned within
        ' the datatypes which misaligns the datatypes
        ' with what the Stream expects. So, we build
        ' the header by hand.
        Dim BmpHeader(SIZEOF_BITMAPFILEHEADER - 1) As Byte
        
        ' Spell "BM"
        BmpHeader(0) = vbUpperBChar
        BmpHeader(1) = vbUpperMChar
        
        ' Bytes 3-6 contain the size of the file in bytes.
        AsLong(BmpHeader(2)) = CorArray.Length(Bytes) + SIZEOF_BITMAPFILEHEADER
        
        ' Bytes 11-14 contain the offset to the data bytes.
        AsLong(BmpHeader(10)) = DataStartOffset
        
        ' Shove our header onto the Stream before we shove the data.
        Stream.Write BmpHeader(0), SIZEOF_BITMAPFILEHEADER, 0&
        
        ' We need to count an additional 14 bytes if we have
        ' inserted our own header information.
        ByteCountOffset = SIZEOF_BITMAPFILEHEADER
    End If
    
    ' Shove the data onto the stream.
    Stream.Write Bytes(ByteIndex), CorArray.Length(Bytes), 0&
    
    ' Move back to the start of the stream for reading.
    Stream.Seek 0, STREAM_SEEK_SET, 0&
    
    ' We setup a guid to match the interface we want the
    ' OleLoadPicture to create for the return picture object.
    Dim UnkIID As VBGUID
    With UnkIID
        .Data4(0) = &HC0
        .Data4(7) = &H46
    End With
    
    ' Load the picture from the stream, creating an IPicture object. We simply
    ' assign it to an IUnknown object for ease.
    Dim Unk As IUnknown
    OleLoadPicture Stream, 0, BOOL_TRUE, UnkIID, Unk
    
    ' Return it, casting to a StdPicture object.
    Set CreatePicture = Unk
End Function


'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'   IResourceDecoder
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Private Function IResourceDecoder_Decode(ByVal Key As ResourceKey, Bytes() As Byte) As Long
    IResourceDecoder_Decode = Decode(Key, Bytes)
End Function

Private Function IResourceDecoder_GetDecodeType() As Variant
    IResourceDecoder_GetDecodeType = GetDecodeType
End Function

Private Function IResourceDecoder_GetResource(ReturnKey As ResourceKey, ReturnValue As Variant) As Boolean
    IResourceDecoder_GetResource = GetResource(ReturnKey, ReturnValue)
End Function
