/*
psfile =(mcPath()+"app/Interop.Photoshop.dll")
--doesFileExist psfile
p = dotnet.loadassembly psfile
mcsystem.show p
print (p.GetTypes())
p.CodeBase
*/

--merge inage layers with transparency in to a psd file and marquee selection.
(
	local psfile =(mcPath()+"app/Photoshop.dll")
	--doesFileExist psfile
	local oPhotoShop = dotnetobject "LoneRobot.Imaging.PhotoshopBot"
	--showmethods oPhotoShop
	local imagepath = "C:/Temp/testimages"
	--doesFileExist imagepath
	local imagearray = #((imagepath + "\bg.jpg"),(imagepath + "\layer1.png"),(imagepath + "\layer2.png"),(imagepath + "\layer3.png"),(imagepath + "\layer4.png"))
	--for i in imagearray do format "exist image:%\n" (doesFileExist i)
	
	local LocationArray = #((DotNetObject "System.Drawing.Point" 0 0),(DotNetObject "System.Drawing.Point" 411 513),(DotNetObject "System.Drawing.Point" 109 531),(DotNetObject "System.Drawing.Point" 193 444),(DotNetObject "System.Drawing.Point" 314 421))
	
	oPhotoShop.Automation_BasicImageCompositor imagearray LocationArray (imagepath +"/testoutput.psd") false true 
	--oPhotoShop.MarqueeSelect 50 46 200 400
	oPhotoShop.Selection_Marquee 50 46 200 400
	
	print "finished"
)


/*
dotnet.loadassembly ((getdir#scripts)+"\LoneRobot\ClassLib\Interop.Photoshop")
dotNetObject:System.Reflection.Assembly

ps = dotnetobject "Photoshop.ApplicationClass"
dotNetObject:Photoshop.ApplicationClass

showproperties ps
.ActiveDocument : <Photoshop.Document>
.Application : <Photoshop.Application>, read-only
.BackgroundColor : <Photoshop.SolidColor>
.ColorSettings : <System.String>, read-only
.DisplayDialogs : <Photoshop.PsDialogModes>
.Documents : <Photoshop.Documents>, read-only
.Fonts : <Photoshop.TextFonts>, read-only
.ForegroundColor : <Photoshop.SolidColor>
.FreeMemory : <System.Double>, read-only
.Locale : <System.String>, read-only
.MacintoshFileTypes : <System.Object>, read-only
.MeasurementLog : <Photoshop.MeasurementLog>, read-only
.Name : <System.String>, read-only
.Notifiers : <Photoshop.Notifiers>, read-only
.NotifiersEnabled : <System.Boolean>
.Path : <System.String>, read-only
.Preferences : <Photoshop.Preferences>, read-only
.PreferencesFolder : <System.String>, read-only
.RecentFiles : <System.Object>, read-only
.ScriptingBuildDate : <System.String>, read-only
.ScriptingVersion : <System.String>, read-only
.Version : <System.String>, read-only
.Visible : <System.Boolean>
.WinColorSettings : <System.String>, read-only
.WindowsFileTypes : <System.Object>, read-only
ps.documents
dotNetObject:System.__ComObject
-- this should be a Photoshop.Documents class??
show ps.documents
false
showmethods ps.documents
.<System.Runtime.Remoting.ObjRef>CreateObjRef <System.Type>requestedType
.<System.Boolean>Equals <System.Object>obj
.[static]<System.Boolean>Equals <System.Object>objA <System.Object>objB
.<System.Int32>GetHashCode()
.<System.Object>GetLifetimeService()
.<System.Type>GetType()
.<System.Object>InitializeLifetimeService()
.[static]<System.Boolean>ReferenceEquals <System.Object>objA <System.Object>objB
.<System.String>ToString()
-- ie showing the methods of the COM object, not the documents class.
*/


/*
Imports Photoshop

Public Class PhotoshopBot

Private PSDapp As Application

Public Sub New()
PSDapp = New Application()
End Sub

Public Sub BasicImageCompositor(ByVal Images() As String, _
ByVal OutputFileName As String, _
ByVal HideApplication As Boolean, _
ByVal OpenOnCompletion As Boolean)

' get a fileinfo object to check the folder validity
Dim OutFile As New IO.FileInfo(OutputFileName)

If OutFile.Directory.Exists Then
' hide the photoshop UI
If HideApplication Then PSDapp.Visible = False
' Suppress the Photoshop dialogs (if any)
PSDapp.DisplayDialogs = 3
'   enum 3 =
'   PsDialogModes.psDisplayNoDialogs()
'load the first image and duplicate it into a new image document

If Images.Length > 0 Then
Dim BackGroundLayer As String = Images(0)
PSDapp.Load(BackGroundLayer)
PSDapp.ActiveDocument = PSDapp.Documents.Item(1)
PSDapp.ActiveDocument.Duplicate(OutFile.Name)
'close the original
'close(1) bypasses the save dialog
PSDapp.Documents.Item(1).Close(1)
'set the active document to the duplicate
PSDapp.ActiveDocument = PSDapp.Documents.Item(1)
'loop through the rest of the array, copying and pasting it into the
'duplicated document
For imageindex = LBound(Images) + 1 To UBound(Images)
PSDapp.Load(Images(imageindex))
PSDapp.ActiveDocument = PSDapp.Documents.Item(2)
PSDapp.ActiveDocument.Selection.SelectAll()
PSDapp.ActiveDocument.ArtLayers(1).Copy()
PSDapp.Documents.Item(2).Close(1)
PSDapp.ActiveDocument = PSDapp.Documents.Item(1)
PSDapp.ActiveDocument.Paste()
Next

'save it
PSDapp.ActiveDocument.SaveAs(OutputFileName)
PSDapp.ActiveDocument.Close(1)
' show the ui and load the image, if desired
If HideApplication Then PSDapp.Visible = True
If OpenOnCompletion Then PSDapp.Load(OutputFileName)
End If
Else
' if the folder doesn't exist it will throw this exception
Throw New IO.DirectoryNotFoundException("Directory does not exist")
End If

End Sub

End Class
*/