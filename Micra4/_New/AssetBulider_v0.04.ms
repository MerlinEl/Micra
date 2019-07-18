/*
Asset Name
//lh_08_family_house_a_v1
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
rollout mcAssetGeneratorDialog "Asset Builder:" width:832 height:332
(
	local utils_path	= toLower (LS3DGUP.LS3DGUP.UtilsPath)
	local edt_path	= toLower (LS3DGUP.LS3DGUP.EnginePath )
	local res_path	= toLower (LS3DGUP.LS3DGUP.ResourcesPath)
	local max_path	= toLower (maxFilePath + maxFileName)
	local temp_edt_path	= "models\\city\\lost_heaven\\districts\lh_08_oakwood\\"
	local temp_res_path	= "city\\lost_heaven\districts\\lh_08_oakwood\\static_objects\\"
	local temp_asset_name= "lh_08_family_house_a_v1"
	GroupBox 'grp1' "3DsMax:" pos:[4,180] width:144 height:100 align:#left
	label 'lbl1' "Create Material:" pos:[12,218] width:100 height:16 align:#left
	label 'lbl2' "Create Material:" pos:[436,206] width:84 height:16 align:#left
	checkbox 'chk_create_fussion_mat' "" pos:[520,204] width:23 height:20 enabled:true checked:true align:#left
	label 'lbl3' "Create PSD:" pos:[164,202] width:84 height:16 align:#left
	checkbox 'chk_create_psd' "" pos:[253,200] width:23 height:20 enabled:true checked:true align:#left
	label 'lbl4' "width:" pos:[164,230] width:36 height:16 align:#left
	spinner 'spn_psd_h' "" pos:[205,252] width:72 height:16 range:[0,10000,2048] type:#integer scale:1 align:#left
	label 'lbl5' "height:" pos:[164,252] width:36 height:16 align:#left
	spinner 'spn_psd_w' "" pos:[205,228] width:72 height:16 range:[0,10000,1024] type:#integer scale:1 align:#left
	label 'lbl_r' "Max Path ( Resource ):" pos:[12,120] width:110 height:16 align:#left
	label 'lbl_e' "Models Path ( Edit ):" pos:[12,52] width:110 height:16 toolTip:"IRES Path" align:#left
	edittext 'edt_edt_path' "" pos:[120,52] width:676 height:16 align:#left
	edittext 'edt_res_path' "" pos:[120,120] width:676 height:16 align:#left
	label 'lbl7' "Create Node:" pos:[12,238] width:100 height:16 align:#left
	button 'btn_browse_edt_path' "..." pos:[800,52] width:20 height:16 align:#left
	GroupBox 'grp2' "Photoshop:" pos:[156,180] width:264 height:100 align:#left
	checkbox 'chk_export_psd_diffuse' "" pos:[388,220] width:23 height:20 checked:true align:#left
	label 'lbl10' "Export Diffuse:" pos:[300,222] width:84 height:16 align:#left
	checkbox 'chk_generate_psd_layers' "" pos:[388,196] width:23 height:20 checked:true align:#left
	label 'lbl11' "Generate Layers:" pos:[300,198] width:84 height:16 align:#left
	GroupBox 'grp3' "Fussion:" pos:[428,184] width:400 height:96 align:#left
	label 'lbl12' "Assign Diffuse:" pos:[436,230] width:84 height:16 align:#left
	checkbox 'chk7' "" pos:[520,228] width:23 height:20 enabled:true checked:true align:#left
	button 'btn2' "GENERATE ASSET" pos:[4,288] width:824 height:40 align:#left
	GroupBox 'grp19' "Global:" pos:[4,4] width:824 height:168 align:#left
	button 'btn_browse_res_path' "..." pos:[800,120] width:20 height:16 align:#left
	label 'lbl74' "Asset Name:" pos:[12,26] width:110 height:16 align:#left
	edittext 'edt_asset_name' "" pos:[120,24] width:280 height:16 align:#left
	checkbox 'chk_create_max_mat' "" pos:[116,216] width:23 height:20 enabled:true checked:true align:#left
	checkbox 'chk_create_max_node' "" pos:[116,236] width:23 height:20 enabled:true checked:true align:#left
	label 'lbl_psd_path' "PSD Path:" pos:[12,144] width:784 height:16 enabled:false align:#left
	label 'lbl_dds_path' "DDS Path:" pos:[12,76] width:784 height:16 enabled:false align:#left
	label 'lbl_mat_path' "Materials Path:" pos:[12,96] width:784 height:16 enabled:false align:#left
	-- label 'lbl_ires_path' "IRES Path:" pos:[12,172] width:804 height:16 align:#left
	dropdownList 'ddl1' "" pos:[548,204] width:268 height:21 items:#("base/general", "base/facade_colored") align:#left
	-- label 'lbl61' "MAX Path:" pos:[12,88] width:84 height:16 align:#left
	-- edittext 'edt_max_path' "" pos:[96,88] width:696 height:16 align:#left
	-- button 'btn_browse_max_path' "..." pos:[796,88] width:20 height:16 align:#left
	label 'lbl96' "Create Max File:" pos:[12,198] width:100 height:16 align:#left
	checkbox 'chk_create_max_file' "" pos:[116,196] width:23 height:20 enabled:true checked:true align:#left
	label 'lbl17' "Create Placeholder:" pos:[12,258] width:100 height:16 align:#left
	checkbox 'chk_create_max_mesh' "" pos:[116,256] width:23 height:20 enabled:true checked:true align:#left

	fn generatePathsFromEdit e_path = (
	
		if (not doesFileExist res_path) then messagebox "Your exporter doesn't have correctly set paths. Please check: menu LS3D/Client Settings if all paths there are set correctly to existing folders."
		if (findString res_path @"d:\") == undefined then (			
			res_path = substituteString res_path "d:" @"d:\"
		)

		local relative_path = substituteString e_path edt_path ""
format "A relative path:%\n" relative_path
		relative_path = substituteString relative_path "models\\" ""
format "B relative path:%\n" relative_path
		edt_res_path.text = res_path + relative_path + "\\"
		
		--d:\!2k_games\scotch_dev\edit\models\city\lost_heaven\districts\lh_08_oakwood\
		edt_edt_path.text = e_path  + "\\"
		-- e_path = substituteString e_path "\\models" ""
		
		--//Scotch/dev/resources/graphics/city/lost_heaven/districts/lh_08_oakwood/static_objects/maps/lh_08_family_house_c_v1.psd
		lbl_psd_path.text = "PSD Path:                       "		+ res_path	+ relative_path + "\\maps\\"
		lbl_dds_path.text = "DDS Path:                       "		+ edt_path	+ "maps\\" + relative_path + "\\"
		lbl_mat_path.text = "Materials Path:               "	+ edt_path	+ "materials\\" + relative_path  + "\\"
	)
	fn generatePathsFromResources r_path = (
	
		edt_res_path.text = r_path
	
	)
	on mcAssetGeneratorDialog open do 
	(
		local sel = selection as array
		local obj = sel[1]
		edt_asset_name.text		= if classOf obj == LS3DModel then (
			
			chk_create_max_node.checked = false
			obj.name
		) else "lh_" --temp_asset_name
		edt_edt_path.text		= "..." --edt_path + temp_edt_path
		edt_res_path.text		= "..." --res_path + temp_res_path
		/*if max_path != "" do (
		
			chk_create_max_file.checked = false
			edt_max_path.text = max_path
			lbl_psd_path.text = "PSD Path:               " + maxFilePath + @"maps\"
		)*/
		
	)
	on btn_browse_edt_path pressed do (
	
		local initPath = LS3DGUP.LS3DGUP.EnginePath + @"models\"
		local newPath = getSavePath caption:"Browse for Edit path..." initialDir:initPath
		if newPath != undefined do generatePathsFromEdit (toLower newPath)
	)
	on btn_browse_res_path pressed do (
	
		local initPath = LS3DGUP.LS3DGUP.ResourcesPath + @"models\"
		local newPath = getSavePath caption:"Browse for Resources path..." initialDir:initPath
		if newPath != undefined do generatePathsFromResources (toLower newPath)
	)
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