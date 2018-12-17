(dotnetclass "System.AppDomain").CurrentDomain.GetAssemblies()


assemblyFileName = "E:\\Micra2\\App\\test\\MaxCustomControls.dll"
-- Load the class library created 
a= dotnet.LoadAssembly assemblyFileName 
--get info
mc2system.show a
print (a.GetTypes())

a.CodeBase
a.FullName

a.Evidence
a.HostContext
a.GlobalAssemblyCache 
a.ManifestModule 

--use
rollout unnamedRollout "Untitled" width:162 height:300
(
	dotNetControl btn1 "AcceleratedIdeas.AIButton" pos:[19,19] width:61 height:52
	on unnamedRollout open do mc2system.show btn1
)
createdialog unnamedRollout








AnimControl.dll by Kenzor

http://www.designimage.co.uk/Max/files/MouseControl/AnimControl.dll


 fn MyPos a b =
 (
  	 format "pos: %, %\n" b.x b.y
 )
  
  assemblyFileName = (Mc2Path()+"App\\" + "AnimControl.dll")
  
  -- Load the class library created 
  dotnet.LoadAssembly assemblyFileName 
  
  hForm = dotNetObject  "AnimControl.MouseWindow"
  
  dotNet.addEventHandler hForm "PosEvent" MyPos 
   
  hForm.show()
  	
 hform.ctrl.SetX 0 0 --sets the x position of the cross in the window
 hform.ctrl.SetY 0 0 --sets the y position of the cross in the window




rollout mc2GifPlayerDialog3 "Untitled" width:288 height:188
(
		
	local image_class = dotNetClass "System.Drawing.Image"
	local blank_filename = Mc2Path() + "Help\\blank.gif" --blank
	local frame_dimension = (dotNetClass "System.Drawing.Imaging.FrameDimension") --time resolution page
	dotNetControl win_form "System.Windows.Forms.Control" pos:[4,4] width:280 height:180 --"flowlayoutpanel"
		
	on mc2GifPlayerDialog3 open do
	(
		gall = dotnet.LoadAssembly "C:\Temp\grab\dotnetgallery\Web\bin\DotnetGallery.dll"
		--dotNetObject "System.Windows.Forms.PictureBox"
		--gall_obj = dotNetClass "System.Reflection.Assembly"
		win_form.controls.add gall
		--mc2System.show gall
		--mc2System.show gall
	)
	
)
createdialog mc2GifPlayerDialog3



--Here's how you can get the available "types" of any loaded assembly:
a = dotNet.loadAssembly @"C:\TabControlEX.dll"
dotNetObject:System.Reflection.Assembly
for t in a.GetTypes() do print t
...
...
dotNetObject:System.RuntimeType[Dotnetrix.Controls.TabControlEX]
...
...
OK
c = a.CreateInstance "Dotnetrix.Controls.TabControlEX"
dotNetObject:Dotnetrix.Controls.TabControlEX
--The @ character marks the string as verbatim meaning that any escape sequences are ignored. So by prefixing the string with @ you can safely type (for example) @"C:\render". Without the @ the \r would convert to a carriage return character.


--the following verbatim string remains unchanged after evaluation:

thePath = @"g:\temp\newfolder\render"



"g:\temp\newfolder\render"

--while the following results in a

--scrambled string with tabs and new lines:

thePath = "g:\temp\newfolder\render"

"g: emp

ewfolder

ender"