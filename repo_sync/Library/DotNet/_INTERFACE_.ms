/*
It isn't documented but you can use reflection to ferret out what you need. 

I typically rely on the Object Browser that comes with 
Visual Studio to pull in assembly files and snoop around for 
things that look interesting, but you can discover a lot with 3dsmax alone.

The following snippet will dump all the exported types found 
in the assemblies located in your max root folder
*/

for dllname in getfiles ((getdir #maxroot)+"*.dll") do
(
	try (
		asm = dotnet.LoadAssembly dllname
		format "\n-------------------------------------------\n"
		format "[%] exports:\n" dllname
		for etype in (asm.GetExportedTypes()) do
		(
			format "%\n" etype.FullName
		)
	)
	catch ()
)

/*
The "Autodesk" namespace contains code that looks to be shared 
with (or derived from) the stuff that is in AutoCAD. 
Perhaps you can look there for enlightenment? link
I tried poking around adding buttons to the quick access bar & such, 
but it seemed kind of klunky.
.biddle
*/

dotNetClass "System.Windows.Forms.Clipboard"
dotNetclass "System.Windows.Forms.DragDropEffects"
fn netColor clr  = (dotNetClass "System.drawing.color").fromArgb clr.r clr.g clr.b
dotNetClass "Drawing.Graphics"
dotNetClass "Drawing.Image"
dotNetClass "System.Windows.Forms.ListViewItem"
dotNetClass "System.Windows.Forms.TreeNode"
dotNetClass "System.Windows.Forms.Cursors"
dotNetClass "System.Windows.Forms.Cursor"
dotnetclass "System.Windows.Forms.Orientation"

fn mc2DNo_DrawingBitmap size    = dotNetObject "Drawing.Bitmap" size.x size.y
fn mc2DNo_DrawingPoint pos      = dotnetObject "Drawing.Point" pos.x pos.y
fn mc2DNo_DrawingRect pos size  = dotnetObject "Drawing.rectangle" pos.x pos.y size.x size.y
fn mc2DNo_DrawingSize  size     = dotNetObject "Drawing.Size" size.x size.y

form.Region = (dotnetObject "Drawing.Region").MakeEmpty()

dotNetObject "ImageList"
dotNetObject "TableLayoutPanel"
dotNetObject "FlowLayoutPanel"
dotNetObject "Tabcontrol"
dotnetobject "System.Single" 50

dotNetControl cb "combobox" pos:[100,20] width:264 height:396
dotNetControl tv "treeView" pos:[8,68] width:132 height:388
dotNetControl tb "textbox"  pos:[140,68] width:200 height:20
dotNetControl lv "listView" pos:[140,88] width:220 height:368


/*
Global mc2DNc, mc2DNo

(
	struct DOTNET_CLASS
	(
		fn clipboard  = (dotNetClass "System.Windows.Forms.Clipboard"),
		fn color clr: = 
		(
			if clr == unsupplied
			then (dotNetClass "System.drawing.color")
			else (dotNetClass "System.drawing.color").fromArgb clr.r clr.g clr.b
		),
		fn dragEffect = (dotNetclass "System.Windows.Forms.DragDropEffects"),
		fn drawingGraphic path: = 
		(
			if path == unsupplied
			then (dotNetClass "Drawing.Graphics")
			else (dotNetClass "Drawing.Graphics").fromImage path
			
		),
		fn drawingImage path: = 
		(
			if path == unsupplied
			then (dotNetClass "Drawing.Image")
			else (dotNetClass "Drawing.Image").FromFile path
		),
		fn listNode = (dotNetClass "System.Windows.Forms.ListViewItem"),
		fn treeNode = (dotNetClass "System.Windows.Forms.TreeNode")
	)
	struct DOTNET_OBJECT
	(
		fn drawingBitmap size = (dotNetObject "Drawing.Bitmap" size.x size.y),
		fn drawingRect pos size = (dotnetObject "Drawing.rectangle" pos.x pos.y size.x  size.y),
		fn drawingSize size = (dotNetObject "Drawing.Size" size.x size.y),
		fn imgList = (dotNetObject "ImageList")
		
	)
	mc2DNo = DOTNET_OBJECT
	mc2DNc = DOTNET_CLASS
)
*/
