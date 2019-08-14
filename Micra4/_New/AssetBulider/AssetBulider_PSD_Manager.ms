Global PSD_MANAGER
Global PHOTOSHOP_ELEMENT_PLACEMENT

struct PHOTOSHOP_ELEMENT_PLACEMENT (
	
-- 	INSIDE = ?,
-- 	PLACEATBEGINNING = ?,
	PLACEATEND = 3,
	PLACEBEFORE = 2,
	PLACEAFTER = 1
)
struct PSD_MANAGER (

	SettingsINI = "",
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
	fn quit = (
		
		/*local process =  dotnetClass "System.Diagnostics.Process"
		app_arr = process.GetProcessesByName("Photoshop")
		if app_arr.count == 0 do return true
		local app = app_arr[1]
		app.Kill()*/
		app.quit()
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
		if not was_open	do quit()
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
	),
	fn getCheckedList = (
			
		local folder_names = getINISetting SettingsINI "PSD_Folders_List"
		local checked_list = #()
		for item_name in folder_names do (
				
			local is_checked = (getINISetting SettingsINI "PSD_Folders_List" item_name) == "true"
			if is_checked do append checked_list item_name
		)
		checked_list	
	),
	fn setupPsdFoldersList = (
		
		if mcAssetGeneratorLayersDialog != undefined do DestroyDialog mcAssetGeneratorLayersDialog
		rollout mcAssetGeneratorLayersDialog "PSD Folders Setup:" width:172 height:252
		(
			local SettingsINI = ""
			button 'btn_accept' "Accept" pos:[108,220] width:49 height:21 align:#left
			button 'btn_cancel' "Cancel" pos:[12,220] width:48 height:21 align:#left
			dotNetControl 'clb_mods' "CheckedListBox" pos:[12,24] width:144 height:191 align:#left 
			groupBox 'grp6' "Active List:" pos:[4,4] width:164 height:244 align:#left
			fn loadPsdFoldersSettings = (
				
				if clb_mods.Items.count != 0 do clb_mods.Items.Clear()
				local folder_names = getINISetting SettingsINI "PSD_Folders_List"
				for item_name in folder_names do (
					
					local is_checked = (getINISetting SettingsINI "PSD_Folders_List" item_name) == "true"
					clb_mods.Items.Add item_name is_checked
				) 
			)
			fn savePsdFoldersSettings = (

				for i=0 to clb_mods.Items.count-1 do (
					
					local is_checked = (clb_mods.GetItemChecked i) as string
					local item_name = clb_mods.items.item[ i ]
					setINISetting SettingsINI "PSD_Folders_List" item_name is_checked
				)
				DestroyDialog  mcAssetGeneratorLayersDialog
			)
			on mcAssetGeneratorLayersDialog open do (
				
				clb_mods.BackColor = (dotNetClass "System.Drawing.Color").FromArgb 40 40 40
				clb_mods.ForeColor = (dotNetClass "System.Drawing.Color").FromArgb 200 200 200
				clb_mods.BorderStyle = (dotNetClass "BorderStyle").FixedSingle
				clb_mods.HorizontalScrollbar = clb_mods.MultiColumn = false ; clb_mods.CheckOnClick = true
			)
			on btn_accept pressed do savePsdFoldersSettings()
			on btn_cancel pressed do DestroyDialog  mcAssetGeneratorLayersDialog
		)
		CreateDialog mcAssetGeneratorLayersDialog  pos:[mouse.screenpos.x, mouse.screenpos.y - 252 / 2]
		mcAssetGeneratorLayersDialog.SettingsINI = SettingsINI
		mcAssetGeneratorLayersDialog.loadPsdFoldersSettings()
	)
)



/*
psd_man = PSD_MANAGER()
psd_man.createPSDFile @"c:\temp\" "psd_test_10" 128 512 black
folder_names =	#("diffuse", "alpha", "glossiness", "metalness", "emissive", "emissive mask", "normal", "detail mask", "blend mask")
layers_names =	for i=1 to folder_names.count collect "layer_1"
layers_colors = for i=1 to folder_names.count collect gray
psd_man.addFoldersWithLayers folder_names layers_names layers_colors
psd_man.savePSDFile()
psd_man.focus()

action_fpath = @"C:\Program Files\Adobe\adobe photoshop cc 2014\presets\scripts\ls3d_generate_layers.jsx"
psd_man.runScript action_fpath


psd_man.addFolder "test"
psd_man.addFolders #("a", "b", "c")
psd_man.addLayer "bg" green
psd_man.addFolderWithLayer "new_folder_01" "new_layer_01" blue
*/
