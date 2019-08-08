

filein "AssetBulider_DDS_Manager.ms"
filein "AssetBulider_PSD_Manager.ms"
filein "AssetBulider_P4V_Manager.ms"
filein "AssetBulider_MAT_Manager.ms"
/*
append p4FileList (newPSDPath + newPSDFileName)


*/


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
Global mcAssetGeneratorLayersDialog
Global mcAssetGeneratorDDSDialog
if mcAssetGeneratorDialog != undefined do destroyDialog mcAssetGeneratorDialog
rollout mcAssetGeneratorDialog "Asset Builder:" width:712 height:332
(
	local script_dir = getFilenamePath (getSourceFileName())
	local SettingsINI = script_dir + "LS3D_Asset_Generator.ini"
	local utils_path	= toLower (LS3DGUP.LS3DGUP.UtilsPath)
	local edt_path	= toLower (LS3DGUP.LS3DGUP.EnginePath )
	local res_path	= toLower (LS3DGUP.LS3DGUP.ResourcesPath)
	local max_path	= toLower (maxFilePath + maxFileName)
	local temp_edt_path	= "models\\city\\lost_heaven\\districts\lh_08_oakwood\\"
	local temp_res_path	= "city\\lost_heaven\districts\\lh_08_oakwood\\static_objects\\"
	local temp_asset_name= "lh_08_family_house_a_v1_test" --"lh_"
	local node_geo, node_coll 
	local source_template_file_material = "template_general.xml"
	local source_template_files_models = #("template_model.ires", "template_model.xds")
	local source_template_file_psd = "template_texture.psd"
	local psd_man = PSD_MANAGER(SettingsINI)
	local dds_man = DDS_MANAGER(SettingsINI)
	local mat_man = MAT_MANAGER(SettingsINI)
	local P4V_COMPOMENTS = #()
-- 	local psd_folder_names = #(
-- 		
-- 		"diffuse", 
-- 		"alpha", 
-- 		"glossiness", 
-- 		"roughness", 
-- 		"metalness", 
-- 		"emissive", 
-- 		"emissive mask", 
-- 		"normal", 
-- 		"detail mask", 
-- 		"blend mask"
-- 	)
	local fussion_mats	= #(
	
		"base/general", 
		"base/general_2uv", 
		"base/terrain", 
		"base/terrain_2blend", 
		"base/terrain_3blend", 
		"base/facade_colored",
		"base/facade_basic",
		"base/facade_blend",
		"base/facade_colored_2uv",
		"base/roads",
		"base/terrain_shore"
	)
	local texture_sizes		= #("8", "16", "32", "64", "128", "256", "512", "1024", "2048", "4096")
	local maps_types			= #("---d.dds", "---dm.dds", "---e.dds", "---g.dds", "---n.dds")
	local tamplates_maps		= @"asset_management\maps\" --"T000_DiffuseTexture", "T027_DetailNormalMaskTexture", "T011_EmissiveTexture", "T002_GlossinessMetalTexture", "T001_NormalTexture"
	local tamplates_materials = @"asset_management\materials\" --"template_general.xml"
	local tamplates_models	= @"asset_management\models\" --"template_model.ires", "template_model.xds"
	local tamplates_psd		= @"asset_management\psd\" --template_texture.psd
	GroupBox 'grp1' "3DsMax:" pos:[4,204] width:156 height:124 align:#left
	label 'lbl2' "Create Material:" pos:[408,230] width:84 height:16 align:#left
	checkbox 'chk_create_fussion_mat' "" pos:[492,228] width:23 height:20 enabled:true checked:true align:#left
	label 'lbl3' "Create PSD:" pos:[176,226] width:84 height:16 align:#left
	checkbox 'chk_create_psd' "" pos:[265,224] width:23 height:20 enabled:true checked:true align:#left
	label 'lbl4' "width:" pos:[176,254] width:36 height:16 align:#left
	dropdownList 'ddl_psd_w' "" pos:[217,250] width:59 height:21 items:texture_sizes selection:1 align:#left
	label 'lbl5' "height:" pos:[284,254] width:36 height:16 align:#left
	dropdownList 'ddl_psd_h' "" pos:[325,250] width:59 height:21 items:texture_sizes selection:1 align:#left
	label 'lbl_r' "Max Path:" pos:[12,144] width:72 height:16 align:#left
	label 'lbl_e' "Models Path:" pos:[12,48] width:72 height:16 toolTip:"IRES Path" align:#left
	edittext 'edt_edt_path' "" pos:[88,48] width:584 height:16 align:#left
	edittext 'edt_res_path' "" pos:[88,144] width:584 height:16 align:#left
	label 'lbl7' "Create Node:" pos:[12,262] width:116 height:16 align:#left
	checkbox 'chk_create_node' "" pos:[128,260] width:23 height:20 enabled:true checked:true align:#left
	button 'btn_browse_edt_path' "..." pos:[676,48] width:20 height:16 align:#left
	GroupBox 'grp2' "Photoshop:" pos:[168,204] width:224 height:124 align:#left
		label 'lbl11' "Generate Folders:" pos:[176,278] width:88 height:16 align:#left
		button 'btn_psd_folders_settings' "[ ... ]" pos:[264,274] width:40 height:20 checked:true align:#left
		GroupBox 'grp3' "Fusion:" pos:[400,204] width:308 height:76 align:#left
		label 'lbl12' "Assign DDS:" pos:[408,254] width:60 height:16 align:#left
		button 'btn_fussion_dds_list' "[ ... ]" pos:[468,250] width:40 height:20 checked:true align:#left
	button 'btn_gen_asset' "GENERATE" pos:[400,284] width:308 height:44 align:#left
	button 'btn_browse_res_path' "..." pos:[676,144] width:20 height:16 align:#left
	label 'lbl74' "Asset Name:" pos:[8,6] width:72 height:16 align:#left
	edittext 'edt_asset_name' "" pos:[88,6] width:308 height:16 align:#left
	label 'lbl1' "Create Material:" pos:[12,302] width:116 height:16 align:#left
	checkbox 'chk_create_max_mat' "" pos:[128,300] width:23 height:20 enabled:true checked:true align:#left
	label 'lbl_psd_path' "PSD Path:" pos:[12,168] width:684 height:16 enabled:false align:#left
	label 'lbl_dds_path' "DDS Path:" pos:[12,72] width:684 height:16 enabled:false align:#left
	label 'lbl_mat_path' "Materials Path:" pos:[12,92] width:684 height:16 enabled:false align:#left
	dropdownList 'ddl1' "" pos:[520,228] width:180 height:21 items:fussion_mats align:#left
	label 'lbl96' "Create Max File:" pos:[12,222] width:116 height:16 align:#left
	checkbox 'chk_create_max_file' "" pos:[128,220] width:23 height:20 enabled:true checked:true align:#left
	label 'lbl17' "Create Placeholder:" pos:[12,282] width:116 height:16 align:#left
	checkbox 'chk_create_max_mesh' "" pos:[128,280] width:23 height:20 enabled:true checked:true align:#left
	GroupBox 'grp25' "EDIT:" pos:[4,28] width:704 height:88 align:#left
	GroupBox 'grp26' "RESOURCES:" pos:[4,124] width:704 height:68 align:#left
	label 'lbl19' "Create Layers:" pos:[12,242] width:116 height:16 align:#left
	checkbox 'chk_create_max_layers' "" pos:[128,240] width:23 height:20 enabled:true checked:true align:#left
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
	fn generateLayers asset_type = (
	
		case asset_type of (
		
			"House": gLS3DLayerUtils.CleanFile "house"
			"Crash Object": gLS3DLayerUtils.CleanFile "CO"
		)
		"Generated layers type:" + asset_type
	)
	fn saveMaxFileAs output_dir file_name &max_file = (
	
		if not (doesDirectoryExist output_dir) do return "Error:: Unable Save Max File.\n\tDirectory: [ "+output_dir+" ] does not exists."
		local fpath = output_dir + file_name + ".max"
		if doesFileExist fpath do return "Error:: Unable Override Max File.\n\tFile: [ "+fpath+" ] already exists."
		saveMaxFile fpath quiet:true
		max_file = fpath
		return "Max File Saved.\n\tPath:[ "+fpath+" ]"
	)
	fn createNodes output_path asset_name asset_type = (
		
		case asset_type of (
			
			"House" : (
				output_path = subString output_path ((findString output_path @"\models") + 1) -1
-- 				output_path = subString output_path ((findString output_path @"\missions") + 1) -1
				node_geo = LS3DModel pos:[0, 0, 0] isSelected:off wirecolor: (color 225 88 199)
				node_coll = LS3DModel pos:[0, 0, 0] isSelected:off wirecolor: (color 87 225 198)
				node_coll.size = 27
				node_geo.size = 50
				node_coll.pos.y += 5000
				node_geo.name = asset_name + "_geometry"
				node_coll.name = asset_name + "_coll"
			)
			"Crash Object" : (
				
				output_path = subString output_path ((findString output_path @"\models") + 1) -1
				node_geo = LS3DModel pos:[0, 0, 0] isSelected:off wirecolor: (color 225 88 199)
				node_geo.name = asset_name
			)
		)
		local node_layer = LayerManager.getLayerFromName "00__NODES__00"
		if node_layer == undefined do ( --create layer if not exists
		
			node_layer = LayerManager.newLayer()
			node_layer.setname "00__NODES__00"
			node_layer.addnode node_geo	--geometry node
			node_geo.OutputPath = output_path --set node output pat
			if node_coll != undefined do (	--add collision node
				
				node_layer.addnode node_coll
				node_coll.OutputPath = output_path --set node output pat
			)
		)
		"Created node(s) type:" + asset_type
	)
	fn createPlaceholder asset_name asset_type new_mat = (
		
		local new_obj = box width:1000 height:1000 length:1000 pos:[0, 0, 0]
		new_obj.name = "lod0"
		new_obj.material = new_mat
		if node_geo != undefined do new_obj.parent = node_geo
		local lod0_layer_name = case asset_type of (
			
			"House" : asset_name + "__LOD0" --"static_objects" +
			"Crash Object" : "LOD0"
		)
		local node_layer = LayerManager.getLayerFromName lod0_layer_name
		if node_layer == undefined do ( --create layer if not exists
			
			node_layer = LayerManager.newLayer()
			node_layer.setname lod0_layer_name
			node_layer.addnode new_obj	--geometry node
		)
		"Created Placeholder type:" + asset_type
	)
	fn isValidFormFill &output_log = (
		
		if edt_asset_name.text == "" do (
			
			output_log += " \n\tMissing Asseat Name."
			return false	
		)
		doesDirectoryExist
		if not doesDirectoryExist edt_edt_path.text or findString edt_edt_path.text @"\models" == undefined do (
			
			output_log += " \n\tMissing or Invalid Models Path."
			return false	
		)
		if not doesDirectoryExist edt_res_path.text or findString edt_res_path.text @"\graphics" == undefined  do (
			
			output_log += " \n\tMissing or Invalid Resources Path."
			return false	
		)
		return true
	)
--Main FN
	fn generateNewAsset = (
	

		local output_log = "\n--------------------\nASSET BUILDER LOG:\n--------------------",max_file = "", new_mat, new_obj, new_guid, export_node
		if not isValidFormFill  &output_log do (
			
			messageBox ("Unable Create Asset. See trace log for details.") title:"Aborted:"
			showLog output_log
			return false
		)
		
--CREATE MAX FILE
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
--CREATE LAYERS
		if chk_create_max_layers.checked do (
	
			local output = generateLayers ddl_asset_type.selected 
			output_log += "\n\t" + output
		)		
--CREATE NODES
		if chk_create_node.checked do (
			
			output = createNodes edt_edt_path.text edt_asset_name.text ddl_asset_type.selected
			output_log += "\n\t" + output
		)
--CREATE PLACEHOLDER
		if chk_create_max_mesh.checked do (
			
			local new_mat = Standardmaterial() --TEMP
			output = createPlaceholder edt_asset_name.text ddl_asset_type.selected new_mat
			output_log += "\n\t" + output	
		) 
		print "xvxcxc"
--CREATE FUSION MATERIAL BASED ON SELECTED TEMPLATE AND RETURN NEW UID
		if chk_create_fussion_mat.checked do (
		
			-- load semantic material at MaterialEditor slot 2
			mat_man.loadMaxSemanticMaterial() 
			local dds_checked = dds_man.getCheckedList() --#("diffuse", "glossiness", "normal")
			format "asign dds in fusion material:%\n" dds_checked
			local fusion_mat = mat_man.createFusionMaterial utils_path edt_edt_path.text edt_asset_name.text dds_checked
--format "fusion material:%\n" fusion_mat
-- 			local mat_guid =  mat_man.createFusionMaterial edt_asset_name.text edt_path
-- 			if chk_create_max_mat.checked do  mat_man.createMaxMaterial edt_asset_name.text mat_guid
		)

		showLog output_log
		max tool zoomextents all
	)
--UI
	fn saveSettings = (

		if isValidPath edt_edt_path.text do setINISetting SettingsINI "Settings" "Edit_Path" (trimRight edt_edt_path.text @"\")
		if isValidPath edt_res_path.text do setINISetting SettingsINI "Settings" "Resource_Path" (trimRight edt_res_path.text @"\")
		if edt_asset_name.text != "" do setINISetting SettingsINI "Settings" "Asset_Name" edt_asset_name.text
		setINISetting SettingsINI "PSD_Size" "width_index" (ddl_psd_w.selection as string)
		setINISetting SettingsINI "PSD_Size" "height_index" (ddl_psd_h.selection as string)
	)
	fn loadSettings = (
		
		local edit_path = resources_path = "...", asset_name = "", width_index = "8", height_index = "9"
		if doesFileExist SettingsINI do (
		
			edit_path		= getINISetting SettingsINI "Settings" "Edit_Path"
			resources_path	= getINISetting SettingsINI "Settings" "Resource_Path"
			asset_name		= getINISetting SettingsINI "Settings" "Asset_Name"
			width_index		= getINISetting SettingsINI "PSD_Size" "width_index"
			height_index		= getINISetting SettingsINI "PSD_Size" "height_index"
		) 
		edt_edt_path.text	= if isValidPath edit_path then  edit_path else "..."
		edt_res_path.text	= if isValidPath resources_path then  resources_path else "..."
		edt_asset_name.text	= if asset_name != "" then  asset_name else "lh_"
		ddl_psd_w.selection = execute width_index
		ddl_psd_h.selection = execute height_index
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
		if mcAssetGeneratorLayersDialog != undefined do DestroyDialog mcAssetGeneratorLayersDialog
		if mcAssetGeneratorDDSDialog != undefined do DestroyDialog mcAssetGeneratorDDSDialog
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
	on btn_psd_folders_settings pressed do (psd_man.setupPsdFoldersList ())
	on btn_fussion_dds_list pressed do (dds_man.setupPsdDdsList ())
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
	