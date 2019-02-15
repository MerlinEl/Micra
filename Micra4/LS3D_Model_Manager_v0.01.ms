--If you specify the height of the edittext to be 18 pixels or more, the on entered event handler will not be called since the edittext will be in multi-line mode!

Global LS3DModelManagerDialog
if LS3DModelManagerDialog != undefined do destroyDialog LS3DModelManagerDialog
rollout LS3DModelManagerDialog "LS3D Model Manager v1.0" width:764 height:284 (
	
	GroupBox 'grp1' "FBX" pos:[4,156] width:756 height:84 align:#left
	GroupBox 'grp2' "MAX" pos:[4,4] width:756 height:148 align:#left
	
	edittext 'edt_asset_name' "" pos:[108,24] width:450 height:17 align:#left
	edittext 'edt_import' "" pos:[108,179] width:544 height:17 align:#left
	edittext 'edt_export' "" pos:[108,208] width:544 height:17 align:#left
	
	dropdownList 'ddl_perforce_path' "Perforce Path:" pos:[8,48] width:672 height:40 align:#left
	
	button 'btn_export_fbx' "Export" pos:[656,205] width:68 height:22 align:#left
	button 'btn_import_fbx' "Import" pos:[656,176] width:68 height:22 align:#left
	button 'btn_save_as' "Save Max As" pos:[636,125] width:88 height:20 align:#left
	button 'btn_export_sel' "Export Selected" pos:[636,97] width:88 height:20 align:#left
	button 'btn_replace' "REPLACE MODEL" pos:[340,248] width:148 height:32 align:#left
	button 'btn_add_node' "ADD NODE" pos:[4,248] width:92 height:32 align:#left
	button 'ntn_new_scene' "NEW SCENE" pos:[104,248] width:100 height:32 align:#left
	button 'btn_open_import_dir' "O" pos:[728,176] width:24 height:22 align:#left
	button 'btn_open_export_dir' "O" pos:[728,204] width:24 height:22 align:#left
	button 'btn_add_perforce_dir' "+" pos:[688,68] width:28 height:18 align:#left
	button 'btn_del_perforce_dir' "-" pos:[720,68] width:28 height:18 align:#left
	button 'btn_open_edit_dir' "O" pos:[728,96] width:24 height:22 align:#left
	button 'btn_open_res_dir' "O" pos:[728,124] width:24 height:22 align:#left
	button 'btn_clean_co' "Clean - CrashObject" pos:[212,248] width:124 height:32 align:#left
	button 'btn_get_node_data' "Get From Node" pos:[564,23] width:88 height:20 align:#left
	
	label 'lbl17' "FBX Import Path:" pos:[12,180] width:96 height:17 align:#left
	label 'lbl18' "FBX Export Path:" pos:[12,209] width:96 height:17 align:#left
	label 'lbl_edit' "Edit:" pos:[12,99] width:620 height:17 align:#left
	label 'lbl_res' "Res:" pos:[12,125] width:620 height:17 align:#left
	label 'lbl3' "Asset Name:" pos:[8,24] width:96 height:17 align:#left
	button 'btn_load_semat' "Load Semantic Materials" pos:[636,248] width:124 height:32 align:#left

	local root_edit_dir, root_resources_dir
	local SettingsINI = Micra.UserDir + "LS3D_ReplaceModel.xml"
	/*fn fixPath str = (
		local arr = #()
		for i=1 to str.count do (
			
			if str[i] == "\\" then (
				append arr "/"
			) else (
				append arr str[i]
			)
		)
		newString = ""
		for j=1 to arr.count do (
			
			newString += arr[j]
		)
		return newString
	)*/
	fn getLS3DNode sel = (
		
		for o in sel where (classOf o == LS3DModel) do return o
		return undefined
	)
	
	fn getINIDirs head = (
	
		local keys = mcFile.readSettings SettingsINI head type:"keys"
		local paths = for k in keys collect mcFile.readSettings SettingsINI (head+"/"+k)
		return paths	
	)
	
	fn updatePerforcePaths asset_name = (
		
		lbl_edit.text = "Edit:" + "\t" + root_edit_dir + "\\" + ddl_perforce_path.text + "\\" + asset_name + ".ires"
		lbl_res.text  = "Res:" + "\t" + root_resources_dir + "\\" + ddl_perforce_path.text + "\\" + asset_name + ".max"
	)
	
	fn  addOrSelectPath output_path = (
		
		local index = undefined
		local cnt = 1
		for str in ddl_perforce_path.items do (
			
			if  str == output_path do index = cnt
			cnt+=1
		)
		if index != undefined then ( --select existing
			
			ddl_perforce_path.selection = index	
		) else ( --add and select
		
			ddl_perforce_path.items = append ddl_perforce_path.items (output_path)
			ddl_perforce_path.selection = ddl_perforce_path.items.count	
		)
	)
	on LS3DModelManagerDialog open do (
		
		root_edit_dir = mcFile.readSettings SettingsINI "ROOT/edit"
		root_resources_dir = mcFile.readSettings SettingsINI "ROOT/res"
		edt_import.text = mcFile.readSettings SettingsINI "FBX/import"
		edt_export.text = mcFile.readSettings SettingsINI "FBX/export"
		
		ddl_perforce_path.items = getINIDirs "PERFORCE"
		ddl_perforce_path.selection = execute(mcFile.readSettings SettingsINI "SELECTION/perforce_path")
		updatePerforcePaths "undefined"
		setFocus edt_asset_name
	)
	
	on LS3DModelManagerDialog close do (
		
		mcFile.saveSettings SettingsINI "FBX/import" edt_import.text
		mcFile.saveSettings SettingsINI "FBX/export" edt_export.text
		mcFile.saveSettings SettingsINI "SELECTION/perforce_path" (ddl_perforce_path.selection as string)
		mcFile.delSettings SettingsINI "PERFORCE" type:"keys" --remove all sub items
		local cnt = 0
		for i in ddl_perforce_path.items do mcFile.saveSettings SettingsINI ("PERFORCE/loc_"+((cnt+=1) as string)) i
	)
	
	on btn_import_fbx pressed do (
		
		local asset_name = edt_asset_name.text
		if (asset_name.count == 0) do ((format "Undefined Asset Name! [Micra] \n"); return false)
		local import_path = edt_import.text
		if (import_path.count == 0) do ((format "Undefined Import Path! [Micra] \n"); return false)
		format "import file:%\n" ((import_path+"\\"+asset_name+".FBX"))littleitaly_street_01
		importfile (import_path+"\\"+asset_name+".FBX") #noPrompt using:FBXIMP
	)
	
	on btn_add_node pressed  do (
	
		--get model
		local model = $selection[1] 
		if (model == undefined) do ((format "Model Are Not Selected! [Micra] \n"); return false)
		model.name = "base"
		--create node and set asset name
		local asset_name = edt_asset_name.text
		if (asset_name.count == 0) do ((format "Undefined Asset Name! [Micra] \n"); return false)
		local ls3d_node  = LS3DModel pos:[0,0,0] isSelected:on
		ls3d_node.name = asset_name
		model.parent = ls3d_node
		--move ls3d_node to default layer [00__NODES__00]
		local node_layer = LayerManager.getLayerFromName "00__NODES__00"
		if node_layer == undefined do (
			node_layer = LayerManager.newLayer()
			node_layer.setname "00__NODES__00"
		)
		node_layer.addnode ls3d_node
		--set node output path
		ls3d_node.OutputPath = ddl_perforce_path.text
		--select node and model
		select #(ls3d_node, model)
	)
	
	on btn_export_fbx pressed  do (
		
		local ls3d_node  = getLS3DNode($selection as Array)
		if (ls3d_node == undefined) do ((format "Select LS3D Node! [Micra] \n"); return false)
		local asset_name = ls3d_node.name
		local export_path = edt_export.text
		if (export_path.count == 0) do ((format "Undefined Export Path! [Micra] \n"); return false)
		print ("export to:" + export_path+"\\"+asset_name+".FBX")
		exportFile (export_path+"\\"+asset_name+".FBX") #noPrompt selectedOnly:true using:FBXEXP
		print "FBX EXPORTED"
	)
	
	on btn_replace pressed  do (
	
	)	
	
	on ntn_new_scene pressed  do actionMan.executeAction 0 "16" --new file
	on edt_asset_name changed str  do updatePerforcePaths edt_asset_name.text
	on ddl_perforce_path selected sel do updatePerforcePaths edt_asset_name.text
	on btn_open_import_dir pressed do shellLaunch "explorer" edt_import.text
	on btn_open_export_dir pressed do shellLaunch "explorer" edt_export.text
	on btn_open_edit_dir pressed  do shellLaunch "explorer" (root_edit_dir + "\\" + ddl_perforce_path.text)
	on btn_open_res_dir pressed  do shellLaunch "explorer" (root_resources_dir + "\\" + ddl_perforce_path.text)
	on btn_clean_co pressed do gLS3DLayerUtils.CleanFile "CO"
	on btn_get_node_data pressed  do (
		
		local ls3d_node  = getLS3DNode($selection as Array)
		if (ls3d_node == undefined) do ((format "Select LS3D Node! [Micra] \n"); return false)
		--get node perforce path
		addOrSelectPath ls3d_node.OutputPath
		--get node name
		edt_asset_name.text = ls3d_node.name
		updatePerforcePaths edt_asset_name.text
	)
	on btn_add_perforce_dir pressed do(
		
		local dir = getSavePath caption:"Add Perforce Edit Path:" initialDir:"D:\\!2k_games\\scotch\\edit"
		if (dir == undefined) do return OK
		local edit_pos = findString dir "edit"
		dir = substring dir (edit_pos+5) -1
		ddl_perforce_path.items = append ddl_perforce_path.items (dir)
		ddl_perforce_path.selection = ddl_perforce_path.items.count
	)
	on btn_del_perforce_dir pressed do
	(
		if ddl_perforce_path.items.count > 0 and ddl_perforce_path.selection > 0 do(
			
			ddl_perforce_path.items = deleteItem ddl_perforce_path.items ddl_perforce_path.selection
			if ddl_perforce_path.items.count > 0 do ddl_perforce_path.selection = 1
		)
	)
	on btn_export_sel pressed  do
	(
		gLS3DSmartExport.exportScene()
		/*local outputdir = "D:\\"
		local oldSelection = selection as array
		local newSelection = LS3DCollectTopModels oldSelection
		select newSelection
		
		if selection.count != 0 then
		(
			local currentProfile = LS3DGUP.XDSExporter.GetSelectedProfile()
			local objectsToExport = selection as array
			for obj in objectsToExport do
			(		
				if (classof obj == LS3DModel) then
				(	
					try ( if (gLS3DSmartExport == undefined) then gLS3DSmartExport = sXDSExport() ) catch ()
					local exportProfile = gLS3DSmartExport.getModelProfileFromProps obj.name
					if (exportProfile < 0) then exportProfile = currentProfile					
					
					format("Exporting object: %, profile: %\n") obj.name exportProfile
					select obj		
					LS3DGUP.XDSExporter.SelectProfile exportProfile
					LS3DGUP.XDSExporter.Path = outputdir
					LS3DGUP.XDSExporter.ExportSelected = true
					LS3DGUP.XDSExporter.SupressPrompts = true

					try (
						LS3DGUP.XDSExporter.Export()
					)
					catch (						
						print("Export failed! Error message: " + getCurrentException() as string)
						messagebox ("Export failed. Max may crash, hang or it will be unstable. Search trace log for hint about the issue.") title:"Micra > LS3D Manager:"
					)
				)
				else print("You must select LS3D node.")
			)
		)
		else messagebox("You should select something.") title:"Micra > LS3D Manager:"
		select oldSelection*/
	)
	
	on btn_save_as pressed do (
	
		local save_dir = root_resources_dir + "\\" + ddl_perforce_path.text
		format "save max dir:%\n" save_dir
		--savemaxfile "D:/!2k_games/scotch/edit/blueprints/cine/generic/" + new_name + ".max"	
	)
	on btn_load_semat pressed do (
	
		local fpath = "D:/!2k_games\scotch_dev/resources/utilities/3dsmax/semantic_materials.mat"
		if not doesFileExist fpath do (
		
			MessageBox ("Semantic material not found at path:\n"+fpath)	title:"Micra > LS3D Manager:"
			return false
		)
		local mat_lib = loadTempMaterialLibrary fpath
		meditMaterials[1] = mat_lib[1]
		print "Semantic material loaded succesfuly!"
	)
)
createDialog LS3DModelManagerDialog

/*
cine_0500_newspaper_a_v1
*/
