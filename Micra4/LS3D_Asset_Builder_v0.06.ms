
------------------------------------------------------------------------------
-- STRUCTURE
------------------------------------------------------------------------------
Global gAssetBuilder	= undefined
Global gAssetBuilderDialog

fn fileInOnce struct_name file_path = (

	if (execute struct_name) == undefined do fileIn file_path
)

fileInOnce "sPsdManager" "LS3D_DDS_Manager.ms"
fileInOnce "sDdsManager" "LS3D_PSD_Manager.ms"
fileInOnce "sMatManager" "LS3D_P4V_Manager.ms"
fileInOnce "sP4vManager" "LS3D_MAT_Manager.ms"

struct sAssetBuilder (

	fn getSource = getSourceFileName(), --get path of this script
	fn init = (
		
		if gAssetBuilderDialog != undefined do destroyDialog gAssetBuilderDialog
		rollout gAssetBuilderDialog "Asset Builder:" width:712 height:332
		(
			local script_dir	= getFilenamePath (getSourceFileName())
			local SettingsINI	= script_dir + "LS3D_Asset_Builder.ini"
			-- local SettingsINI = (LS3DGUP.LS3DGUP.UtilsPath + "\\LS3D_Asset_Builder.ini")
			local utils_path, edt_path, res_path
			local max_path	= toLower (maxFilePath + maxFileName)
			local temp_edt_path	= "models\\city\\lost_heaven\\districts\lh_08_oakwood\\"
			local temp_res_path	= "city\\lost_heaven\districts\\lh_08_oakwood\\static_objects\\"
			local temp_asset_name= "lh_08_family_house_a_v1_test" --"lh_"
			local source_template_files_models = #("template_model.ires", "template_model.xds")
			local psd_man = sPsdManager()
			local dds_man = sDdsManager()
			local mat_man = sMatManager()
			local p4v_man = sP4vManager()
			local fussion_materials 	= getIniSetting SettingsINI "Materials_Templates"
			local texture_sizes		= getIniSetting SettingsINI "Texture_Sizes"
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
			button 'btn_generate_asset' "GENERATE" pos:[400,284] width:100 height:44 align:#left
			button 'btn_revert_asset' "REVERT" pos:[504,284] width:100 height:44 align:#left enabled:false
			button 'btn_delete_asset' "DELETE" pos:[608,284] width:100 height:44 align:#left enabled:false
			button 'btn_browse_res_path' "..." pos:[676,144] width:20 height:16 align:#left
			label 'lbl74' "Asset Name:" pos:[8,6] width:72 height:16 align:#left
			edittext 'edt_asset_name' "" pos:[88,6] width:308 height:16 align:#left
			label 'lbl1' "Create Material:" pos:[12,302] width:116 height:16 align:#left
			checkbox 'chk_create_max_mat' "" pos:[128,300] width:23 height:20 enabled:true checked:true align:#left
			label 'lbl_psd_path' "..." pos:[92,168] width:604 height:16 enabled:false align:#left
			label 'lbl_dds_path' "..." pos:[92,72] width:604 height:16 enabled:false align:#left
			label 'lbl_mat_path' "..." pos:[92,92] width:604 height:16 enabled:false align:#left
			dropdownList 'ddl1_fusion_mats' "" pos:[520,228] width:180 height:21 align:#left
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
			label 'lbl_dds_title' "DDS Path:" pos:[12,72] width:72 height:16 toolTip:"IRES Path" align:#left enabled:false
			label 'lbl_mat_title' "Materials Path:" pos:[12,92] width:72 height:16 toolTip:"IRES Path" align:#left enabled:false
			label 'lbl_psd_title' "PSD Path:" pos:[12,168] width:72 height:16 toolTip:"IRES Path" align:#left enabled:false
			-- file system
			fn isValidPath path = (
			
				path[2] == ":"
			)
			fn fileInOnce struct_name file_path = (

				if (execute struct_name) == undefined do (
					
					format "init structure:%\n" struct_name
					fileIn file_path
				)
			)
			fn mergeArrays orig_arr new_arr = (
			
				join orig_arr new_arr 
			)
			fn generatePathsFromEdit e_path = (
			
				if (not isValidPath e_path or not doesFileExist res_path) then (
				
					mcProgLog.msg "ASSET BUILDER LOG:" ti:"Initialize...." ty:"new_task"
					mcProgLog.msg "Your exporter doesn't have correctly set paths. Please check: menu LS3D/Client Settings if all paths there are set correctly to existing folders." ti:"Aborted!" ty:"error"
					return false
				)
				if (findString res_path @"d:\") == undefined then ( --force path location to drive D:\ 			
					res_path = substituteString res_path "d:" @"d:\"
				)
				local relative_path = substituteString e_path edt_path ""
				relative_path = substituteString relative_path "models" ""
				edt_res_path.text = res_path + relative_path
				-- d:\!2k_games\scotch_dev\edit\models\city\lost_heaven\districts\lh_08_oakwood\
				edt_edt_path.text = e_path
				-- //Scotch/dev/resources/graphics/city/lost_heaven/districts/lh_08_oakwood/static_objects/maps/lh_08_family_house_c_v1.psd
				lbl_psd_path.text = res_path	+ relative_path + "maps"
				lbl_dds_path.text = edt_path	+ "maps" + relative_path 
				lbl_mat_path.text = edt_path	+ "materials" + relative_path
			)
			fn generatePathsFromResources r_path = (
			
				if not isValidPath r_path do return false
				edt_res_path.text = r_path
				lbl_psd_path.text = r_path + "\\maps"
			)
			fn generateLayers asset_name asset_type = (
			
				mcProgLog.msg "Creating Max Layers" ti:"3DsMax..." ty:"task_open"
				case asset_type of (
				
					"House": gLS3DLayerUtils.CleanFile "house"
					"Crash Object": gLS3DLayerUtils.CleanFile "CO"
				)
				LayerManager.newLayerFromName(asset_name + "__COLL") --manualy add collision layer
				local model_layer = LayerManager.getLayerFromName (asset_name + "__LOD0")
				if model_layer != undefined do model_layer.current = true
				mcProgLog.msg ("Generated layers type:" + asset_type) ty:"task_close"
			)
			fn saveMaxFileAs fpath = (
			
				mcProgLog.msg "Creating Max File" ti:"3DsMax..." ty:"task_open"
				if not (saveMaxFile fpath quiet:true) do (
				
					mcProgLog.msg ("Failed Save Max File. Insufficient rights.\n\tPath:[ "+fpath+" ]") ty:"error"
					return false
				)
				mcProgLog.msg ("File was Created at:\n\tPath: [ "+fpath+" ]") ty:"task_close"
				true
			)
			fn isMaxFileOpen fpath = (
			
				mcProgLog.msg "Get Current Max File" ti:"3DsMax..." ty:"task_open"
				if not (doesFileExist fpath) or fpath != maxFilePath + maxFileName do (
					
					mcProgLog.msg ("Failed Max File check. Max File is not open or not saved.\n\tPath:[ "+fpath+" ]") ty:"error"
					return false
				)
				mcProgLog.msg ("Max File is OK.\n\tPath: [ "+fpath+" ]") ty:"task_close"
				true
			)
			/**
			*short_path	> 	models\env_location\_lh\lh_loc_bank\
			*short_path > 	missions\lh_10_countryside_west\
			*/
			fn createNodes output_path asset_name asset_type &node_geo &node_coll = (
			
				mcProgLog.msg "Creating Max Node(s)" ti:"3DsMax..." ty:"task_open"
				local short_path = substituteString output_path edt_path ""
				
				node_geo = LS3DModel pos:[0, 0, 0] isSelected:off wirecolor: (color 225 88 199)
				node_geo.name = asset_name
				node_geo.size = 50
				mcProgLog.msg ("Create geometry Node: [ "+node_geo.name+" ]. Output File: [ " + short_path + " ]") ty:"proc"
				local node_layer = LayerManager.getLayerFromName "00__NODES__00"
				
				if node_layer == undefined do ( --create layer if not exists
				
					node_layer = LayerManager.newLayer()
					node_layer.setname "00__NODES__00"
					node_layer.addnode node_geo	--geometry node
					node_geo.OutputPath = short_path --set node output pat
				)
				mcProgLog.msg ("Max Node(s) are created type:" + asset_type) ty:"task_close"
			)
			/*fn createNodes output_path asset_name asset_type &node_geo &node_coll = (
			
				mcProgLog.msg "Creating Max Node(s)" ti:"3DsMax..." ty:"task_open"
				local short_path = substituteString output_path edt_path ""
				case asset_type of (
					
					"House" : (

						node_geo = LS3DModel pos:[0, 0, 0] isSelected:off wirecolor: (color 225 88 199)
						node_coll = LS3DModel pos:[0, 0, 0] isSelected:off wirecolor: (color 87 225 198)
						node_coll.size = 27
						node_geo.size = 50
						node_coll.pos.y += 5000
						node_geo.name = asset_name + "_geometry"
						node_coll.name = asset_name + "_coll"
						mcProgLog.msg ("Create geometry Node: [ "+node_geo.name+" ]. Output File: [ " + short_path + " ]") ty:"proc"
						mcProgLog.msg ("Create collision Node: [ "+node_coll.name+" ]. Output File: [ " + short_path + " ]") ty:"proc"
					)
					"Crash Object" : (

						node_geo = LS3DModel pos:[0, 0, 0] isSelected:off wirecolor: (color 225 88 199)
						node_geo.name = asset_name
						mcProgLog.msg ("Create geometry Node: [ "+node_geo.name+" ]. Output File: [ " + short_path + " ]") ty:"proc"
					)
				)
				local node_layer = LayerManager.getLayerFromName "00__NODES__00"
				if node_layer == undefined do ( --create layer if not exists
				
					node_layer = LayerManager.newLayer()
					node_layer.setname "00__NODES__00"
					node_layer.addnode node_geo	--geometry node
					node_geo.OutputPath = short_path --set node output pat
					if node_coll != undefined do (	--add collision node
						
						node_layer.addnode node_coll
						node_coll.OutputPath = short_path --set node output pat
					)
				)
				mcProgLog.msg ("Max Node(s) are created type:" + asset_type) ty:"task_close"
			)*/
			fn createPlaceholder asset_name asset_type node_geo new_mat = (
				
				mcProgLog.msg "Creating Max Placeholder" ti:"3DsMax..." ty:"task_open"
				local new_obj = box width:1000 height:1000 length:1000 pos:[0, 0, 0]
				new_obj.name = asset_name + "_lod0"
				if classOf new_mat != LS3DMaterial do new_obj.material = new_mat
				new_obj.parent = node_geo --node || undefined
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
				mcProgLog.msg ("Created Placeholder type:" + asset_type) ty:"task_close"
				new_obj
			)
			fn isValidFormInput asset_name models_path max_path = (
				
				mcProgLog.msg "Check Paths and Names" ti:"Input Check..." ty:"task_open"
				local error_msg = "", success_msg = ""
				if asset_name == "" then (
					
					error_msg += "\n\t" + "Asset Name: [ "+asset_name+" ] ... Failed"
			
				) else (
				
					success_msg += "\n\t" + "Asset Name: [ "+asset_name+" ] ... OK"
				)
				
				if not doesDirectoryExist models_path or findString models_path @"\models" == undefined then (
					
					error_msg += "\n\t" + "Models Path: [ "+models_path+" ] ... Failed"
			
				) else (
				
					success_msg += "\n\t" + "Models Path: [ "+models_path+" ] ... OK"
				)
				
				if not doesDirectoryExist max_path or findString max_path @"\graphics" == undefined then (
					
					error_msg += "\n\t" + "Max Path: [ "+max_path+" ] ... Failed"
			
				) else (
				
					success_msg += "\n\t" + "Max Path: [ "+max_path+" ] ... OK"
				)
				
				if error_msg.count != 0 do (
				
					-- local new_line = if success_msg.count == 0 then true else false --remove last enter
					mcProgLog.msg ("Missing or Invalid Path(s):" + error_msg) ti:"Aborted!" ty:"error" --nl:new_line
					return false
				)
				mcProgLog.msg success_msg ty:"task_close"
				true
			)
			fn getDdsSuiffixByName dds_name = (
			
				local pattern_names = getINISetting SettingsINI "DDS_Textures_Pattern"
				for n in pattern_names where n == dds_name do return (
				
					getINISetting SettingsINI "DDS_Textures_Pattern" n
				)
			)
			fn collectDdsTextures edit_maps_path asset_name = (
			
				local dds_names_list = dds_man.getCheckedList() --#("diffuse", "glossiness", "normal")
				if dds_names_list.count == 0 do return #()
				for dds_name in dds_names_list collect (
				
					local dds_sufix = getDdsSuiffixByName dds_name
					local new_file_name = asset_name + dds_sufix
					edit_maps_path + new_file_name
				)
			)
			fn isFilesUnique max_file psd_file xds_mterial dds_textures = (
			
				mcProgLog.msg "Check Files" ti:"Files..." ty:"task_open"
				local error_msg = "", success_msg = ""
				if chk_create_max_file.checked do (
				
					if doesFileExist max_file then  (
					
						error_msg += "\n\t" + "3DsMax File: [ "+max_file+" ] ... Failed"
						
					) else (
					
						success_msg += "\n\t" + "3DsMax File: [ "+max_file+" ] ... OK"	
					)
				)
				if chk_create_psd.checked do (
				
					if doesFileExist psd_file then  (
					
						error_msg += "\n\t" + "PSD File: [ "+psd_file+" ] ... Failed"
						
					) else (
					
						success_msg += "\n\t" + "PSD File: [ "+psd_file+" ]  ... OK"	
					)
				)
				if chk_create_fussion_mat.checked do (
				
					if doesFileExist xds_mterial then  (
					
						error_msg += "\n\t" + "Fussion Material: [ "+xds_mterial+" ] ... Failed"
						
					) else (
					
						success_msg += "\n\t" + "Fussion Material: [ "+xds_mterial+" ] ... OK"	
					)

					for t in dds_textures do (
					
						if doesFileExist t then (
						
							error_msg += "\n\t" + "DDS Texture: [ "+t+" ] ... Failed"
						)
						else (
						
							success_msg += "\n\t" + "DDS Texture: [ "+t+" ] ... OK"	
						)
					)
				)
				if error_msg.count != 0 do (
				
					-- local new_line = if success_msg.count == 0 then true else false --remove last enter
					mcProgLog.msg ("Unable override existsing File(s):" + error_msg) ti:"Aborted!" ty:"error" --nl:new_line
					return false
				)
				mcProgLog.msg success_msg ty:"task_close"
				true
			)
			fn addFilesToPerforce p4v_compoments asset_name = (
			
				mcProgLog.msg "Add files to PERFORCE:" ti:"P4V...." ty:"task_open"
				local change_list = p4v_man.createChangelist ("ADD new Asset:" + asset_name)
				p4v_man.addFiles p4v_compoments change_list
				for c in p4v_compoments do mcProgLog.msg c ty:"proc"
				mcProgLog.msg "Done!" ty:"task_close"
			)
			fn createPSDFile fpath = (
			
				mcProgLog.msg "Creating PSD File" ti:"Photoshop..." ty:"task_open"
				mcProgLog.msg "Initializing Photoshop. Please Wait...." ty:"proc"
				local w = execute ddl_psd_w.selected
				local h = execute ddl_psd_h.selected
				if not (psd_man.createPSDFile fpath w h clr:gray) then (
				
					mcProgLog.msg ("Failed Save PSD File. Insufficient rights.\n\tPath:[ "+fpath+" ]") ty:"error"
					return false
				)
				local folders_checked = psd_man.getCheckedList() --#("diffuse", "alpha", "glossiness", ...)
				local layers_names =	for i=1 to folders_checked.count collect "layer_1"
				local layers_colors = for i=1 to folders_checked.count collect gray
				for f in folders_checked do mcProgLog.msg ("Add Folder: [ " + f + " ]") ty:"proc"
				psd_man.addFoldersWithLayers folders_checked layers_names layers_colors
				psd_man.savePSDFile()
				mcProgLog.msg ("File was Created at:\n\tPath: [ "+fpath+" ] ... OK") ty:"task_close"
				mcProgLog.focus scrollDown:true -- focus back to console
			)
			fn parseMaterialsToType mat_list = (
			
				local new_list = #()
				for mat_name in mat_list do (
					
					local mat_type = (getIniSetting SettingsINI "Materials_Templates" mat_name)
					append new_list (mat_type + "/" + mat_name) 
				)
				new_list
			)
		-----------------------------------------
		-----------------------------------------
						  -- RUN                   --
		-----------------------------------------
		-----------------------------------------
			fn generateNewAsset = (
			
				mcProgLog.msg "ASSET BUILDER LOG:" ti:"Initialize...." ty:"new_task"
				
		-- CHECK PATHS AND NAMES
				local asset_name = edt_asset_name.text
				local asset_type = ddl_asset_type.selected
				local models_path = edt_edt_path.text + @"\"
				local dds_path = lbl_dds_path.text + @"\"
				local mat_path = lbl_mat_path.text + @"\"
				local max_path = edt_res_path.text + @"\"
				local psd_path = lbl_psd_path.text + @"\"

				if not (isValidFormInput asset_name models_path max_path) do return false --check typed paths and asset name
				
		-- CHECK FOR OVERRIDE FILES
				local max_file = max_path + asset_name + ".max"
				local psd_file = psd_path + asset_name + ".psd"
				local xds_mterial = mat_path + asset_name + ".xml"
				local dds_textures = collectDdsTextures dds_path asset_name
				local new_mat, new_obj, new_guid, node_geo, node_coll
				
				if not (isFilesUnique max_file psd_file xds_mterial dds_textures) do return false --check for dupe files
				
				local P4V_COMPOMENTS = #()
				
		-- CREATE MAX FILE
				if chk_create_max_file.checked then ( --create max file
				
					if not (saveMaxFileAs max_file) do return false
					local max_xml = substituteString max_file ".max" ".xml"
					append P4V_COMPOMENTS max_file --add new max file to perforce list
					append P4V_COMPOMENTS max_xml --add new xm file to perforce list
					
				) else ( --get current max file
				
					if not (isMaxFileOpen max_file) do return false
				)
				if max_file == "" do return false
			
		-- CREATE PSD FILE
				if chk_create_psd.checked do ( 
				
					createPSDFile psd_file
					append P4V_COMPOMENTS psd_file
				)
				
		-- CREATE LAYERS
				if chk_create_max_layers.checked do (
			
					generateLayers asset_name asset_type
				)	
				
		-- CREATE NODES
				if chk_create_node.checked do (
					
					createNodes models_path asset_name asset_type &node_geo &node_coll
				)
				
		-- CREATE FUSION MATERIAL BASED ON SELECTED TEMPLATE AND RETURN NEW UID
				if chk_create_fussion_mat.checked do (
				
					-- load semantic material at MaterialEditor slot 2
					mat_man.loadMaxSemanticMaterial()
					
					local mat_type = fussion_materials[ddl1_fusion_mats.selection]
					new_guid = mat_man.createFusionMaterial utils_path xds_mterial mat_type dds_textures
					append P4V_COMPOMENTS xds_mterial
					mergeArrays P4V_COMPOMENTS dds_textures
				)
					
		-- CREATE MAX MATERIAL AND ASSIGN GIUD
				if chk_create_max_mat.checked then  (
					
					new_mat = mat_man.createMaxMaterial asset_name new_guid xds_mterial slot_index:1
					
				) else ( --pick one from meditMaterials slot 1
				
					new_mat = meditMaterials[1]
				)
		-- CREATE PLACEHOLDER
				if chk_create_max_mesh.checked do (

					createPlaceholder asset_name ddl_asset_type.selected node_geo new_mat
				) 
		-- ADD FILES TO PERFORCE
				addFilesToPerforce P4V_COMPOMENTS asset_name
				mcProgLog.msg "ASSET BUILDER DONE:" ti:"Initialize...." ty:"new_task"
				mcProgLog.msg "Reload Material Database For Shader Update." ty:"proc"
				mcProgLog.focus scrollDown:true -- focus back to console
				max tool zoomextents all
				completeRedraw()
			)
			fn revertNewAsset = (
				
				if queryBox ("You are Sure to Revetr Asset: "+ edt_asset_name.text) title:"Asset Bulider:" do (
					
					-- collect files [model.max,  mode.xml, dds textures, material, ]
				)
			)
			fn deleteNewAsset = (
				
				
			)
		-----------------------------------------
		-----------------------------------------
						  -- UI                    --
		-----------------------------------------
		-----------------------------------------
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
				if LS3DGUP != undefined then (
				
					utils_path	= toLower (LS3DGUP.LS3DGUP.UtilsPath	)
					edt_path	= toLower (LS3DGUP.LS3DGUP.EnginePath 	)
					res_path	= toLower (LS3DGUP.LS3DGUP.ResourcesPath)
					
				) else utils_path = edt_path = res_path = ""
				
				ddl1_fusion_mats.items = parseMaterialsToType fussion_materials
				
				loadSettings()
			)
			fn fin = (
			
				saveSettings()
				if gAssetGeneratorLayersDialog != undefined do DestroyDialog gAssetGeneratorLayersDialog
				if gAssetGeneratorDDSDialog != undefined do DestroyDialog gAssetGeneratorDDSDialog
			)
			on btn_browse_edt_path pressed do (
			
				local newPath = getSavePath caption:"Browse for Edit path..." initialDir:(edt_path + @"models\")
				if newPath != undefined do generatePathsFromEdit (toLower newPath)
			)
			on btn_browse_res_path pressed do (
			
				local newPath = getSavePath caption:"Browse for Resources path..." initialDir:(res_path + @"models\")
				if newPath != undefined do generatePathsFromResources (toLower newPath)
			)
			on btn_generate_asset pressed do generateNewAsset()
			on btn_revert_asset pressed do  revertNewAsset()
			on btn_delete_asset pressed do  deleteNewAsset()
			on edt_edt_path entered text do generatePathsFromEdit (toLower edt_edt_path.text)
			on edt_res_path entered text do generatePathsFromResources (toLower edt_res_path.text)
			on btn_psd_folders_settings pressed do (psd_man.setupPsdFoldersList ())
			on btn_fussion_dds_list pressed do (dds_man.setupPsdDdsList ())
			on gAssetBuilderDialog open do init()
			on gAssetBuilderDialog close do fin()
		)
	),
	fn openDialog = (
	
		if gAssetBuilderDialog != undefined do destroyDialog gAssetBuilderDialog
		createDialog gAssetBuilderDialog
	)
)

if (gAssetBuilder == undefined) do (
	gAssetBuilder = sAssetBuilder()
	gAssetBuilder.init()
)

gAssetBuilder.openDialog()



/*
Max Layers (House)

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
	