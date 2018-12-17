PSDapp=CreateOLEObject"Photoshop.Application"

PSDapp.open
PSDapp.ActiveDocument.Height 
PSDapp.ActiveDocument.Width 
PSDapp.ActiveDocument.selection
PSDapp.ActiveDocument.Selection.SelectAll()
PSDapp.ActiveDocument.Selection.Copy()
PSDapp.Load(Images(imageindex))
PSDapp.ActiveDocument.flatten
PSDapp.ActiveDocument = PSDapp.Documents.Item(1)
PSDapp.ActiveDocument = PSDapp.Documents.Item(2)
PSDapp.Documents.Item(2).Close(1)
PSDapp.ActiveDocument.Paste()
PSDapp.ActiveDocument.SaveAs(OutputFileName)
PSDapp.ActiveDocument.Close(1)
PSDapp.RotateCanvas 90 --' rotate to the right
PSDapp.RotateCanvas -90 --' rotate to the left 
psp.ActiveDocument.selection.fill psp.foregroundcolor
--- not tested
PSDapp.PlayAction"flatten"
--Run action “Shadow canvas” from “fotobatch” group
objApp.DoAction "fotobatch", "Shadow canvas "
---not tested
PSDapp.ActiveDocument.Selection Array(
Array((Math.round(0.829229*x)), (Math.round(0.688201*y))),
Array((Math.round(0.869916*x)), (Math.round(0.72984*y))),
Array((Math.round(0.92826*x)), (Math.round(0.730013*y))),
Array((Math.round(0.970169*x)), (Math.round(0.689375*y))),
Array((Math.round(0.969751*x)), (Math.round(0.63115*y))),
Array((Math.round(0.929018*x)), (Math.round(0.589868*y))),
Array((Math.round(0.871029*x)), (Math.round(0.589683*y))),
Array((Math.round(0.829177*x)), (Math.round(0.630011*y))))

var = [0,0]
var.x = PSDapp.activeDocument.width
var.y = PSDapp.activeDocument.height

PSDapp.ActiveDocument.Selection((round(0.829229*x)))


    ActiveDocument.Select

    Selection.Copy

    Documents.Add

    Selection.Paste

-----

oPhotoShop = dotnetobject "LoneRobot.Imaging.PhotoshopBot"

imagepath = @"C:\LoneRobot Script Development\PhotoShopInterop\testimages"
imagearray = #((imagepath + "\bg.jpg"),(imagepath + "\layer1.png"),(imagepath + "\layer2.png"),(imagepath + "\layer3.png"),(imagepath + "\layer4.png"))
LocationArray = #((DotNetObject "System.Drawing.Point" 0 0),(DotNetObject "System.Drawing.Point" 411 513),(DotNetObject "System.Drawing.Point" 109 531),(DotNetObject "System.Drawing.Point" 193 444),(DotNetObject "System.Drawing.Point" 314 421))

oPhotoShop.BasicImageCompositor imagearray LocationArray (imagepath +@"\testoutput.psd") false true



psp.ExecuteAction (1  flatten )
objApp.ExecuteAction( idOpn, desc1, dialogMode )



 Open a file
	

Dim objFile As object
Set objFile = objApp.Open("C:\My Pictures\picture.jpg")

Save as PSD file
	

Dim psdSaveOptions As object
Set psdSaveOptions = CreateObject("Photoshop.PhotoshopSaveOptions")
objFile.SaveAs "photo.psd", psdSaveOptions, False

Save as TIF file
	

Public Const psNoTIFFCompression = 1
Dim tifSaveOptions As object
Set tifSaveOptions = CreateObject("Photoshop.TiffSaveOptions")
tifSaveOptions.ImageCompression = psNoTIFFCompression
objFile.SaveAs "C:\My Pictures\picture.tif", tifSaveOptions, True

Save as JPG file
	

Public Const psDocument8Bits = 8
Dim jpgSaveOptions As object
objFile.BitsPerChannel = psDocument8Bits
Set jpgSaveOptions = CreateObject("Photoshop.JPEGSaveOptions")
jpgSaveOptions.Quality = 8
objFile.SaveAs "C:\My Pictures\picture.jpg", jpgSaveOptions, True

Export JPG
for WEB
	

Public Const psJPEGSave = 6
Public Const psSaveForWeb = 2
Public Const psDocument8Bits = 8
Dim objExportForWeb As Object
objFile.BitsPerChannel = psDocument8Bits
Set objExportForWeb = CreateObject("Photoshop.ExportOptionsSaveForWeb")
objExportForWeb.Format = psJPEGSave
objExportForWeb.Quality = 60
objFile.Export "C:\My Pictures\picture.jpg", psSaveForWeb, objExportForWeb

Close file
without saving
	

Public psDoNotSaveChanges = 2
objFile.Close (psDoNotSaveChanges) 


 	
FOTOBATCH

Home | Exemples | Download | Automation | Puzzle | Contact

fotobatch français

References to the librairies
Exemples of code
And if JavaScript was added  ?
Advanced functions

There is little documentation on Photoshop checks with external languages and among the documents that exist, Visual BASIC is perhaps the worst. And do not expect too much from the forums (see the links) for information because people mostly discus JavaScript. To avoid feeling less alone in the adventure of Visual Basic and COM (Component Object Model), I propose you a tutorial on the implementation of the Photoshop library.
References to the librairies

There are two ways of declaring an object when you program with an external library :

    * by referring to the library

Dim objApp as Photoshop.application
Set objApp = CreateObject("Photoshop.Application")

    * without referring to the library

Dim objApp as object
Set objApp = CreateObject("Photoshop.Application")

In the 1st case, the link with the library will be solved during compilation because the declaration of the reference is mandatory.

In the 2nd case, the link with the library will be solved during execution.

If you program with references to libray, an error will occur if the versions of the libraries evolve. For example, if you program with Photoshop CS1 installed, your program refers to the library Photoshop 8. If you run the same program with Photoshop CS2, you will have an error indicating an unknown reference because it's the library version 9 which is installed.

With the 2nd method, you do not have a version of libraries to manage since the reference is solved during the execution. But this choice has two disadvantages  :

   1. you do not have Intellissense which show for an object the methods and properties available.
   2. you cannot refer to a constant which is defined in the library but you obtain the same result by including them in the program :

Public Const psPoints = 5
Public Const psPixels = 1

objet.Preferences.TypeUnits = psPoints
objet.Preferences.RulerUnits = psPixels
Exemples of code

In the folder 'C:\Program Files\Adobe\Adobe Photoshop CS2\Scripting Guide', you will find the handbooks as well as many examples of codes necessary to the maitrise of programming with Photoshop.
Manage Photoshop execution

Launch
Photoshop
	

Dim objApp As Object
Set objApp = CreateObject("Photoshop.Application")

Hide Photoshop
windows
	

objApp.Visible = false

Quit Photoshop
	

objApp.Quit
Set objApp = Nothing
Manage a file

Open a file
	

Dim objFile As object
Set objFile = objApp.Open("C:\My Pictures\picture.jpg")

Save as PSD file
	

Dim psdSaveOptions As object
Set psdSaveOptions = CreateObject("Photoshop.PhotoshopSaveOptions")
objFile.SaveAs "photo.psd", psdSaveOptions, False

Save as TIF file
	

Public Const psNoTIFFCompression = 1
Dim tifSaveOptions As object
Set tifSaveOptions = CreateObject("Photoshop.TiffSaveOptions")
tifSaveOptions.ImageCompression = psNoTIFFCompression
objFile.SaveAs "C:\My Pictures\picture.tif", tifSaveOptions, True

Save as JPG file
	

Public Const psDocument8Bits = 8
Dim jpgSaveOptions As object
objFile.BitsPerChannel = psDocument8Bits
Set jpgSaveOptions = CreateObject("Photoshop.JPEGSaveOptions")
jpgSaveOptions.Quality = 8
objFile.SaveAs "C:\My Pictures\picture.jpg", jpgSaveOptions, True

Export JPG
for WEB
	

Public Const psJPEGSave = 6
Public Const psSaveForWeb = 2
Public Const psDocument8Bits = 8
Dim objExportForWeb As Object
objFile.BitsPerChannel = psDocument8Bits
Set objExportForWeb = CreateObject("Photoshop.ExportOptionsSaveForWeb")
objExportForWeb.Format = psJPEGSave
objExportForWeb.Quality = 60
objFile.Export "C:\My Pictures\picture.jpg", psSaveForWeb, objExportForWeb

Close file
without saving
	

Public psDoNotSaveChanges = 2
objFile.Close (psDoNotSaveChanges)
Flatten an image

objFile.Flatten
Auto levels

objFile.ActiveLayer.AutoLevels
Auto Contrast

objFile.ActiveLayer.AutoContrast
Rotate

objFile.RotateCanvas 90 ' rotate to the right

objFile.RotateCanvas -90 ' rotate to the left
Convert profile to sRVB

Public Const psPerceptual = 1

objFile.ConvertProfile DestinationProfile:="sRGB IEC61966-2.1",
Intent: = psPerceptual, blackPointCompensation:=True, Dither:=False
Unsharp mask

Dim Amount as Double
Dim Radius as Double
Dim Threshold as Long

objFile.ActiveLayer.ApplyUnSharpMask Amount, Radius, Threshold
Run a Photoshop action

' Run action “Shadow canvas” from “fotobatch” group
objApp.DoAction "fotobatch", "Shadow canvas "
Create a text

A resizing without changing size fixes the resolution at 72 DPI. This resolution is necessary to express the sizes of fonts in points:

Public Const psNoResampling = 1

objFile.ResizeImage, 72, psNoResampling
Color of the text

Dim objColor As object
Set objColor = CreateObject("Photoshop.SolidColor")

With objColor
   RGB.Red = 128
   RGB.Green = 128
   RGB.Blue = 128
End With
Style of text

ObjLayer Dim As object
Public psTextLayer = 2
Public Const psNoAntialias = 1

ObjLayer set = objFile.ArtLayers.Add

ObjLayer With
   Kind = psTextLayer
   Name = "Signature"
   With TextItem
      Contents = "LaboNumerique Studio"
      Size = 12
      Font = "Arial"
      'see paragraph Color of the text for the dermination of the color object
      Color = objColor
      AntiAliasMethod = psNoAntialias
      Position = Array(10, 20) ' Coordinates of the origin in pixel
   End With
End With
Apply a layer style

ObjLayer.ApplyStyle " MyStyle "
To extract data EXIF

Dim objApp As Object
Dim objFile As object
Dim objInfo As Object
Dim aEXIF As Variant
Dim aInfo As Variant
Dim I As Integer
Dim J As Integer
Dim K As Long
Dim aEXIFInfo() As String

K = -1

ReDim Preserve aEXIFInfo(0)

Set objApp = CreateObject("Photoshop.Application")
Set objFile = objApp.Open(' C:\My Pictures\picture.jpg')
Set objInfo = objFile.Info

aEXIF = objInfo.EXIF

If (Not IsNull(aEXIF)) And (Not IsEmpty(aEXIF)) Then
   For I = 0 To UBound(aEXIF) - 1
      aInfo = aEXIF(i)
      ' Each cell of aEXIF contains a table
      ' with two cells (Data/Value)
      For J = 0 To UBound(aInfo) - 1
         K = K + 1
         ReDim Preserve aEXIFInfo(k)
         aEXIFInfo(k) = Trim(aInfo(j)) & ";" & Trim(aInfo(j + 1))
         Next
      Next
   Erase aInfo
   Erase aEXIF
End If

Data EXIF are available in table aEXIFInfo.

The following code write to a file the table aEXIFInfo :

Dim Data As String
Dim Value As String
Dim i As Integer
Dim j As Integer

Open "C:\My Pictures\exif.txt" For Output As #1
For i = 0 To UBound(aEXIFInfo())
   Data = Left(aEXIFInfo(i), InStr(aEXIFInfo(i), ";") - 1)
   Value = Mid(aEXIFInfo(i), InStr(aEXIFInfo(i), ";") + 1)
   j = i + 1
   Yew J > 9 Then
      Print # 1, J & ". "& Data & Space(30 - Len(Data)) &" = "& Value
   Else
      Print # 1, 0 & J & ". "& Data & Space(30 - Len(Data)) &" = "& Value
   End If
Next
Close #1
Insert a file

The insertion of a file is usually done by the command File>Place. This command is not available in the library Photoshop and it should be replaced by copy/paste :

Dim objFile As object
Dim oImport As Object
Dim HorizontalShift As Double
Dim VerticalShift As Double

Set objFile = objApp.Open("C:\My Pictures\picture.jpg")
'Open the file to import
Set oImport = objApp.Open( "C:\My Pictures \ logo.psd")
'Select all
oImport.Selection.SelectAll
'Copy to the clipboard
oImport.Selection.Copy
'Close the file
oImport.Close
'Paste in the main file
objFile.Paste
'Positioning the imported file
HorizontalShift = 20
VerticalShift = 5
objFile.ActiveLayer.Translate HorizontalShift, VerticalShift
