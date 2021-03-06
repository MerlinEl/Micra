struct PHOTOSHOP_ELEMENT_PLACEMENT (
	
-- 	INSIDE = ?,
-- 	PLACEATBEGINNING = ?,
	PLACEATEND = 3,
	PLACEBEFORE = 2,
	PLACEAFTER = 1
)
struct PSD_MANAGER (

	psd_fpath,
	app,
	was_open,
	ElementPlacement = PHOTOSHOP_ELEMENT_PLACEMENT(),
	fn isPhotoshopRunning = (
		
		local process =  dotnetClass "System.Diagnostics.Process"
		app_arr = process.GetProcessesByName("Photoshop")
		if app_arr.count == 0 do return false
		local app = app_arr[1]
-- 		app.ProcessName
		not app.HasExited
	),
	fn focus = (if app != undefined do app.bringToFront()),
	fn psColor clr = (
		
		local clr_ps = CreateOLEObject "Photoshop.SolidColor"
		clr_ps.rgb.red = clr.r
		clr_ps.rgb.green = clr.g
		clr_ps.rgb.blue = clr.b
		clr_ps
	),
	fn init = (
		
		was_open = isPhotoshopRunning()
		app = CreateOLEObject "Photoshop.Application"
-- 		app.DisplayDialogs = 3 --Suppress the Photoshop dialogs (if any)
		app.Visible=false
-- 		releaseOLEObject app
	),
	fn createPSDFile save_dir file_name size_w size_h bg_clr = (
		
		init()
		local bmp_fpath = save_dir + file_name + ".bmp"
		psd_fpath = save_dir + file_name + ".psd"
		local bm = bitmap size_w size_h color:bg_clr filename:bmp_fpath
		save bm; close bm
		if not doesFileExist bmp_fpath do return false
		app.open bmp_fpath
		deleteFile bmp_fpath
	),
	fn isFolderExists folder_name = (
		
		local doc = app.activeDocument
		for i=1 to doc.layers.count where (doc.layers i).name == folder_name do return true
		false
	),
	fn addFolder  folder_name = (

		if isFolderExists folder_name do return undefined
		local folder = app.activeDocument.layerSets.add()
		folder.name = folder_name
		folder
	),
	fn addFolders folders_arr = (
		
		for n in folders_arr do addFolder n
	),
	fn addLayer layer_name fill_color = (
		
		local doc = app.activeDocument
		local layer = doc.artLayers.add()
		layer.name = layer_name
		doc.selection.fill (psColor fill_color)
		layer
	),
	fn addFolderWithLayer folder_name layer_name fill_color = (
		
		local doc = app.activeDocument
		local folder = addFolder folder_name
		if folder == undefined do retuen false
		local layer  = addLayer layer_name fill_color
		layer.move folder ElementPlacement.PLACEAFTER
	),
	fn addFoldersWithLayers folder_names layer_names fill_colors = (
		
		for i=1 to folder_names.count do addFolderWithLayer folder_names[i] layer_names[i] fill_colors[i]
	),
	fn savePSDFile  = ( --fpath = Path + "/" + Name + ".psd"
		
-- 		local fpath = app.activeDocument.path + "\\" + app.activeDocument.name  + ".psd"
		format "savePSDFile > as:%\n" psd_fpath
		local psdSaveOptions =  CreateOLEObject "Photoshop.PhotoshopSaveOptions"
		psdSaveOptions.layers = true
		psdSaveOptions.embedColorProfile = true
		psdSaveOptions.annotations = true
		psdSaveOptions.alphaChannels = true
		app.activeDocument.saveAs psd_fpath psdSaveOptions false  --false = without prompt,  --Extension.LOWERCASE
		
		app.Visible=true
		if not was_open	do app.quit()
	),
	fn runAction action_name action_set = (
		
		app.doaction  action_name action_set
	),
	fn runScript fpath = (
		
		app.DoJavaScriptFile fpath --"D: \\Scripts\\MosaicTiles.js"
-- 		app.open fpath
	),
	fn selectRegion = (
-- 		app.activeDocument.selection.deselect()
-- 		app.activeDocument.selection.select(selRegion, SelectionType.EXTEND)
	)
)
ps = PSD_MANAGER()


/*
ps.createPSDFile @"c:\temp\" "psd_test_10" 128 512 black
folder_names =	#("diffuse", "alpha", "glossiness", "metalness", "emissive", "emissive mask", "normal", "detail mask", "blend mask")
layers_names =	for i=1 to folder_names.count collect "layer_1"
layers_colors = for i=1 to folder_names.count collect gray
ps.addFoldersWithLayers folder_names layers_names layers_colors
ps.savePSDFile()
ps.focus()

action_fpath = @"C:\Program Files\Adobe\adobe photoshop cc 2014\presets\scripts\ls3d_generate_layers.jsx"
ps.runScript action_fpath


ps.addFolder "test"
ps.addFolders #("a", "b", "c")
ps.addLayer "bg" green
ps.addFolderWithLayer "new_folder_01" "new_layer_01" blue
*/

/*
	fn exitPhotoshop = (
		
		local process =  dotnetClass "System.Diagnostics.Process"
		app_arr = process.GetProcessesByName("Photoshop")
		if app_arr.count == 0 do return true
		local app = app_arr[1]
		app.Kill()
	)
*/


/*
Interop.Photoshop.dll 
Interop.PhotoshopTypeLibrary.dll

http://lonerobot.net/?p=374
dotnet.loadassembly ((getdir#scripts)+"LoneRobotClassLibInterop.Photoshop")

dotnet.loadassembly @"d:\ReneBaca\3DsMax\Micra\Micra4\App\Interop.Photoshop.dll"
dotnet.loadassembly @"d:\ReneBaca\3DsMax\Micra\Micra4\App\Interop.PhotoshopTypeLibrary.dll"
ps = dotnetobject "Photoshop.ApplicationClass"




assembly = dotNetClass "System.Reflection.Assembly"
assembly.UnsafeLoadFrom @"d:\ReneBaca\3DsMax\Micra\Micra4\App\Interop.Photoshop.dll"
assembly.UnsafeLoadFrom @"d:\ReneBaca\3DsMax\Micra\Micra4\App\Interop.PhotoshopTypeLibrary.dll"

dotnet.loadassembly "C:\\Program Files\\Adobe\\Adobe Photoshop CC 2018\\Photoshop.dll"
dotnet.loadassembly "C:\\temp\\Photoshop.dll"




Adobe ExtendScript language
ExtendScript 

The fixes are to, either:

1 enable the loadFromRemoteSources switch
2 manually unblock the file
3 Use Assembly.UnsafeLoadfrom

>> dotNET runtime error | 3ds Max
https://www.sigershop.eu/doc-troubleshooting/
The following example shows how to grant full trust to applications from remote sources.

C:\Program Files\Autodesk\3ds Max 2018\3dsmax.exe.config
<configuration>
   <runtime>
      <loadFromRemoteSources enabled="true"/>
   </runtime>
</configuration>
  
  win + x >  Run > gpedit.msc
  Open the Local Group Policy Editor and expand --> User Configuration --> Administrative Templates --> Windows Components --> Attachment Manager.
  inright panel > Hide mechanism to remove zone information > Double-click to open and select Enabled. Press OK
*/