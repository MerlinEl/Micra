/*
Asset Name
//lh_08_family_house_a_v1_test
Max
//Scotch/dev/resources/graphics/city/lost_heaven/districts/lh_08_oakwood/static_objects/lh_08_family_house_c_v1.max
//Scotch/dev/resources/graphics/city/lost_heaven/districts/lh_08_oakwood/static_objects/lh_08_family_house_c_v1.xml
Photoshop
//Scotch/dev/resources/graphics/city/lost_heaven/districts/lh_08_oakwood/static_objects/maps/lh_08_family_house_c_v1.psd
Fusion
//Scotch/dev/edit/maps/city/lost_heaven/districts/lh_08_oakwood/lh_08_family_house_c_v1---d.dds
//Scotch/dev/edit/blueprints/city/lost_heaven/districts/lh_08_oakwood/lh_08_family_house_c_v1_bv01.ires
//Scotch/dev/edit/materials/city/lost_heaven/districts/lh_08_oakwood/lh_08_family_house_c_v1.xml
//Scotch/dev/edit/models/city/lost_heaven/districts/lh_08_oakwood/lh_08_family_house_c_v1.ires
//Scotch/dev/edit/models/city/lost_heaven/districts/lh_08_oakwood/lh_08_family_house_c_v1.xds
*/


Global mcAssetGeneratorDialog
if mcAssetGeneratorDialog != undefined do destroyDialog mcAssetGeneratorDialog
rollout mcAssetGeneratorDialog "Asset Builder:" width:712 height:352
(
	local SettingsINI = Micra.UserDir + "LS3D_Asset_Generator.xml"
	local utils_path	= toLower (LS3DGUP.LS3DGUP.UtilsPath)
	local edt_path	= toLower (LS3DGUP.LS3DGUP.EnginePath )
	local res_path	= toLower (LS3DGUP.LS3DGUP.ResourcesPath)
	local max_path	= toLower (maxFilePath + maxFileName)
	local temp_edt_path	= "models\\city\\lost_heaven\\districts\lh_08_oakwood\\"
	local temp_res_path	= "city\\lost_heaven\districts\\lh_08_oakwood\\static_objects\\"
	local temp_asset_name= "lh_08_family_house_a_v1_test" --"lh_"
	
	local source_template_file_material = "template_general.xml"
	local source_template_files_models = #("template_model.ires", "template_model.xds")
	local source_template_file_psd = "template_texture.psd"
	local fussion_mats	= #(
		"base/general", 
		"base/terrain", 
		"base/terrain_2blend", 
		"base/terrain_3blend", 
		"base/facade_colored"
	)
	GroupBox 'grp1' "3DsMax:" pos:[4,204] width:156 height:144 align:#left
	label 'lbl1' "Create Material:" pos:[12,242] width:116 height:16 align:#left
	label 'lbl2' "Create Material:" pos:[408,230] width:84 height:16 align:#left
	checkbox 'chk_create_fussion_mat' "" pos:[492,228] width:23 height:20 enabled:true checked:true align:#left
	label 'lbl3' "Create PSD:" pos:[176,226] width:84 height:16 align:#left
	checkbox 'chk_create_psd' "" pos:[265,224] width:23 height:20 enabled:true checked:true align:#left
	label 'lbl4' "width:" pos:[176,254] width:36 height:16 align:#left
	spinner 'spn_psd_h' "" pos:[325,252] width:59 height:16 range:[0,10000,2048] type:#integer scale:1 align:#left
	label 'lbl5' "height:" pos:[284,252] width:36 height:16 align:#left
	spinner 'spn_psd_w' "" pos:[217,252] width:59 height:16 range:[0,10000,1024] type:#integer scale:1 align:#left
	label 'lbl_r' "Max Path:" pos:[12,144] width:72 height:16 align:#left
	label 'lbl_e' "Models Path:" pos:[12,48] width:72 height:16 toolTip:"IRES Path" align:#left
	edittext 'edt_edt_path' "" pos:[88,48] width:584 height:16 align:#left
	edittext 'edt_res_path' "" pos:[88,144] width:584 height:16 align:#left
	label 'lbl7' "Create Geometry Node:" pos:[12,282] width:116 height:16 align:#left
	button 'btn_browse_edt_path' "..." pos:[676,48] width:20 height:16 align:#left
	GroupBox 'grp2' "Photoshop:" pos:[168,204] width:224 height:144 align:#left
	checkbox 'chk_export_psd_diffuse' "" pos:[264,300] width:23 height:20 checked:true align:#left
	label 'lbl10' "Export Diffuse:" pos:[176,302] width:84 height:16 align:#left
	checkbox 'chk_generate_psd_layers' "" pos:[264,276] width:23 height:20 checked:true align:#left
	label 'lbl11' "Generate Layers:" pos:[176,278] width:84 height:16 align:#left
	GroupBox 'grp3' "Fussion:" pos:[400,204] width:308 height:76 align:#left
	label 'lbl12' "Assign Diffuse:" pos:[408,254] width:84 height:16 align:#left
	checkbox 'chk7' "" pos:[492,252] width:23 height:20 enabled:true checked:true align:#left
	button 'btn_gen_asset' "GENERATE" pos:[400,284] width:308 height:64 align:#left
	-- GroupBox 'grp19' "Global:" pos:[4,4] width:824 height:216 align:#left
	button 'btn_browse_res_path' "..." pos:[676,144] width:20 height:16 align:#left
	label 'lbl74' "Asset Name:" pos:[8,6] width:72 height:16 align:#left
	edittext 'edt_asset_name' "" pos:[88,6] width:308 height:16 align:#left
	checkbox 'chk_create_max_mat' "" pos:[128,240] width:23 height:20 enabled:true checked:true align:#left
	checkbox 'chk_create_geo_node' "" pos:[128,280] width:23 height:20 enabled:true checked:true align:#left
	label 'lbl_psd_path' "PSD Path:" pos:[12,168] width:684 height:16 enabled:false align:#left
	label 'lbl_dds_path' "DDS Path:" pos:[12,72] width:684 height:16 enabled:false align:#left
	label 'lbl_mat_path' "Materials Path:" pos:[12,92] width:684 height:16 enabled:false align:#left
	-- label 'lbl_ires_path' "IRES Path:" pos:[12,172] width:804 height:16 align:#left
	dropdownList 'ddl1' "" pos:[520,228] width:180 height:21 items:#("base/general", "base/terrain", "base/terrain_2blend", "base/terrain_3blend", "base/facade_colored") align:#left
	-- label 'lbl61' "MAX Path:" pos:[12,88] width:84 height:16 align:#left
	-- edittext 'edt_max_path' "" pos:[96,88] width:696 height:16 align:#left
	-- button 'btn_browse_max_path' "..." pos:[796,88] width:20 height:16 align:#left
	label 'lbl96' "Create Max File:" pos:[12,222] width:116 height:16 align:#left
	checkbox 'chk_create_max_file' "" pos:[128,220] width:23 height:20 enabled:true checked:true align:#left
	label 'lbl17' "Create Placeholder:" pos:[12,322] width:116 height:16 align:#left
	checkbox 'chk_create_max_mesh' "" pos:[128,320] width:23 height:20 enabled:true checked:true align:#left
	GroupBox 'grp25' "EDIT:" pos:[4,28] width:704 height:88 align:#left
	GroupBox 'grp26' "RESOURCES:" pos:[4,124] width:704 height:68 align:#left
	label 'lbl154' "Create Collision Node:" pos:[12,302] width:116 height:16 align:#left
	checkbox 'chk_create_coll_node' "" pos:[128,300] width:23 height:20 enabled:true checked:true align:#left
	label 'lbl19' "Create Layers:" pos:[12,262] width:116 height:16 align:#left
	checkbox 'chk_create_max_layers' "" pos:[128,260] width:23 height:20 enabled:true checked:true align:#left
	dropdownList 'ddl_asset_type' "" pos:[564,4] width:144 height:21 items:#("House", "Crash Object") align:#left
	label 'lbl39' "Asset type:" pos:[496,6] width:64 height:16 align:#left
	fn showLog msg = (
	
		actionMan.executeAction 0 "40472"
		print (msg + "\n--------------------")
	)
	--file system
	fn isValidPath path = (
	
		path[2] == ":"
	)
	fn generatePathsFromEdit e_path = (
	
		if not isValidPath e_path do return false
		if (not doesFileExist res_path) then messagebox "Your exporter doesn't have correctly set paths. Please check: menu LS3D/Client Settings if all paths there are set correctly to existing folders."
		if (findString res_path @"d:\") == undefined then (			
			res_path = substituteString res_path "d:" @"d:\"
		)
		local relative_path = substituteString e_path edt_path ""
		relative_path = substituteString relative_path "models\\" ""
		edt_res_path.text = res_path + relative_path + "\\"
		--d:\!2k_games\scotch_dev\edit\models\city\lost_heaven\districts\lh_08_oakwood\
		edt_edt_path.text = e_path  + "\\"
		--//Scotch/dev/resources/graphics/city/lost_heaven/districts/lh_08_oakwood/static_objects/maps/lh_08_family_house_c_v1.psd
		lbl_psd_path.text = "PSD Path:             "	+ res_path	+ relative_path + "\\maps\\"
		lbl_dds_path.text = "DDS Path:            "	+ edt_path	+ "maps\\" + relative_path + "\\"
		lbl_mat_path.text = "Materials Path:    "	+ edt_path	+ "materials\\" + relative_path  + "\\"
	)
	fn generatePathsFromResources r_path = (
	
		if not isValidPath r_path do return false
		edt_res_path.text = r_path
		lbl_psd_path.text = "PSD Path:             "		+ r_path + "\\maps\\"
	)
	--material id example > 0x7d50757b, 0x55000dd1
	fn generateMaterialGuid seed_number = ( --for i=1 to 10 do GenerateMaterialGuid i

		local lt = GetLocalTime()
		seed ((seed_number + lt[8]) * (lt[7] + lt[6]) * lt[8])
		local result = "0x"
		for i = 1 to 8 do (
			local num = random 0 15
			result += ((bit.intAsHex num) as string)
		)
		result += ", 0x"
		for i = 1 to 8 do (
			local num = random 0 15
			result += ((bit.intAsHex num) as string)
		)
		return result
	)
	fn MatXML_ModifyGUID path newGUID = (
	
		local result = false
		try (
			local xDoc = XMLDocument()										--Create an XMLDcoument
			xDoc.LoadXML path												--Load XML from file
			local rNode = xDoc.GetRootNode()									--Get the Root Node THIS MUST BE CALLED!		
			
			local guidNode = rNode.GetChild 0
			if (guidNode.GetTag() != "guid") then (
				print ("Unable to find <guid> in material xml. Invalid format. Skipping. -> " + path as string)
			) else (
				guidNode.SetText newGUID
				xDoc.SaveXML()
				result = true
			)
		) catch (
			print ("Unknown error while reading material XML. Invalid format. Skipping. -> " + path as string + ", new material GUID: " + newGUID as string)
		)		
		return result
	)
	fn generateLayers type = (
	
		case type of (
		
			"House": gLS3DLayerUtils.CleanFile "house"
			"Crash Object": gLS3DLayerUtils.CleanFile "CO"
		)
		"Generated layers type:" + type
	)
	fn loadSemanticMaterial = (

		macros.run "Medit Tools" "clear_medit_slots"
		local fpath = LS3DGUP.LS3DGUP.UtilsPath + "semantic_materials.mat"
		if not doesFileExist fpath do return false
		local mat_lib = loadTempMaterialLibrary fpath
		meditMaterials[2] = mat_lib[1]
		-- loadMaterialLibrary LS3DGUP.LS3DGUP.UtilsPath + "semantic_materials.mat"
		-- newMat = currentMaterialLibrary["semantic_materials"]
	)
	fn createMaterial mat_name &new_mat &new_guid = (
	
		if mat_name == "" do return undefined
		new_guid = generateMaterialGuid (random 1 100)
		local new_mat = ls3dMaterial()
		new_mat.matguid = new_guid
		new_mat.name = mat_name
		meditMaterials[1] = new_mat
	)
	fn createExportNode obj asset_name output_path = (
	 
		if obj == undefined or asset_name == "" or output_path == "" do return false
		--create node and set asset name
		local ls3d_node  = LS3DModel pos:[0,0,0] isSelected:off
		ls3d_node.name = asset_name
		obj.parent = ls3d_node
		--move ls3d_node to default layer [00__NODES__00]
		local node_layer = LayerManager.getLayerFromName "00__NODES__00"
		if node_layer == undefined do ( --create layer if not exists
		
			node_layer = LayerManager.newLayer()
			node_layer.setname "00__NODES__00"
		)
		node_layer.addnode ls3d_node --add node in to layer
		ls3d_node.OutputPath = output_path --set node output path
	)
	fn saveMaxFileAs output_dir file_name &max_file = (
	
		if not (doesDirectoryExist output_dir) do return "Error:: Unable Save Max File.\n\tDirectory: [ "+output_dir+" ] does not exists."
		local fpath = output_dir + file_name + ".max"
		if doesFileExist fpath do return "Error:: Unable Override Max File.\n\tFile: [ "+fpath+" ] already exists."
		saveMaxFile fpath quiet:true
		max_file = fpath
		return "Max File Saved.\n\tPath:[ "+fpath+" ]"
	)
	fn generateNewAsset = (
	
		local output_log = "\n--------------------\nASSET BUILDER LOG:\n--------------------",max_file = "", new_mat, new_obj, new_guid, export_node
		if chk_create_max_file.checked then ( --create max file
		
			local output = saveMaxFileAs edt_res_path.text edt_asset_name.text &max_file 
			output_log += "\n\t" + output
			
		) else ( --get current max file
		
			max_file = maxFilePath + maxFileName
		)
		if max_file == "" do (
		
			messageBox ("Unable Create Max File. See trace log for details.") title:"Aborted:"
			showLog output_log
			return false
		)
		if chk_create_max_layers.checked do (
	
			local output = generateLayers ddl_asset_type.selected 
			output_log += "\n\t" + output
		)
		
		-- if chk_create_max_mat.checked do (
		
			-- loadSemanticMaterial()
			-- createMaterial edt_asset_name.text &new_mat &new_guid
		-- )
		
		showLog output_log
		/*
		
	
		if chk_create_geo_node.checked do (
		
			new_obj = box size:100 pos:[0, 0, 0]
			new_obj.name = "lod0"
			new_obj.material = new_mat
		)
		if chk_create_geo_node.checked and new_obj != undefined do (
			
			export_node = createExportNode new_obj edt_asset_name.text edt_edt_path.text
		)
		max tool zoomextents all*/
	)
	fn saveSettings = (

		if isValidPath edt_edt_path.text do setINISetting SettingsINI "Settings" "Edit_Path" (trimRight edt_edt_path.text @"\")
		if isValidPath edt_res_path.text do setINISetting SettingsINI "Settings" "Resource_Path" (trimRight edt_res_path.text @"\")
		if edt_asset_name.text != "" do setINISetting SettingsINI "Settings" "Asset_Name" edt_asset_name.text
	)
	fn loadSettings = (
		
		local edit_path = resources_path = "...", asset_name = ""
		if doesFileExist SettingsINI do (
		
			edit_path		= getINISetting SettingsINI "Settings" "Edit_Path"
			resources_path	= getINISetting SettingsINI "Settings" "Resource_Path"
			asset_name		= getINISetting SettingsINI "Settings" "Asset_Name"
		) 
		edt_edt_path.text	= if isValidPath edit_path then  edit_path else "..."
		edt_res_path.text	= if isValidPath resources_path then  resources_path else "..."
		edt_asset_name.text	= if asset_name != "" then  asset_name else "lh_"
		if isValidPath edit_path do generatePathsFromEdit (toLower edit_path)
		generatePathsFromResources (toLower resources_path)
	)
	fn init = (
	
		loadSettings()
		/*local sel = selection as array
		local obj = sel[1]
		edt_asset_name.text	= if classOf obj == LS3DModel then (
			
			chk_create_max_node.checked = false
			obj.name
		) else temp_asset_name
		if max_path != "" do (
		
			chk_create_max_file.checked = false
			edt_max_path.text = max_path
			lbl_psd_path.text = "PSD Path:               " + maxFilePath + @"maps\"
		)*/
	)
	fn fin = (
	
		saveSettings()
	)
	on btn_browse_edt_path pressed do (
	
		local newPath = getSavePath caption:"Browse for Edit path..." initialDir:(edt_path + @"models\")
		if newPath != undefined do generatePathsFromEdit (toLower newPath)
	)
	on btn_browse_res_path pressed do (
	
		local newPath = getSavePath caption:"Browse for Resources path..." initialDir:(res_path + @"models\")
		if newPath != undefined do generatePathsFromResources (toLower newPath)
	)
	on btn_gen_asset pressed do generateNewAsset()
	on edt_edt_path entered text do generatePathsFromEdit (toLower edt_edt_path.text)
	on edt_res_path entered text do generatePathsFromResources (toLower edt_res_path.text)
	on mcAssetGeneratorDialog open do init()
	on mcAssetGeneratorDialog close do fin()

)
createDialog mcAssetGeneratorDialog


	-- fn convertToEditPath path type = (
	
		-- local result = edt_path
		-- if (not doesFileExist res_path) then messagebox "Your exporter doesn't have correctly set paths. Please check: menu LS3D/Client Settings if all paths there are set correctly to existing folders."
		-- if (findString res_path @"d:\") == undefined then (			
			-- res_path = substituteString res_path "d:" @"d:\"
		-- )
		-- local relativePath = substituteString path res_path ""
		-- relativePath = substituteString relativePath @"models\" ""

		-- case type of
		-- (
			-- #model:(
				-- result = @"models\"
				-- result += relativePath
			-- ) 
			-- #material:(
				-- result += @"materials\"
				-- result += relativePath
			-- ) 
			-- #maps:(
				-- result += @"maps\"
				-- result += relativePath
			-- ) 
			-- #psd:(
				-- result = path + @"maps\"
			-- )
		-- )
		-- local staticObjString = @"static_objects\" 
		-- if matchpattern result pattern:(@"*" + staticObjString + @"*") then (
			-- result = substituteString result staticObjString @""
		-- )		
		-- return result
	-- )
	
	
	/*
"00__NODES__00"
"lh_08_family_house_a_v1__BBox"
"lh_08_family_house_a_v1__TARGET"
"lh_08_family_house_a_v1__hp_lp"
"lh_08_family_house_a_v1__LOD0"
"lh_08_family_house_a_v1__LOD1"
"lh_08_family_house_a_v1__LOD2"
"lh_08_family_house_a_v1__LODs___not_attached"
"z___Surrounding"
"z___HELP"
"LOD0"
"Layer001"
"Layer002"
	*/
	
	
	/*
	fn createDDSImage dir file_name size bg_color = (

	local newBM = bitmap size.x size.y color:bg_color
	newBM.fileName = dir + file_name + ".dds"
	local success = save newBM
	format "fpath:% saved:%\n" newBM.fileName success
	close newBM
)
createDDSImage "c:\\temp\\" "test.dds" [320, 240] gray
	*/