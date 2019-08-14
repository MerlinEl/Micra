Global MAT_MANAGER

struct MAT_MANAGER (

	SettingsINI = "",
	maps_templates_path = @"asset_management\maps\",
	material_templates_path = @"asset_management\materials\",
	--new_guid = generateMaterialGuid (random 1 100)
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
	),
	fn loadMaxSemanticMaterial slot_index:2 = (

		macros.run "Medit Tools" "clear_medit_slots"
		local fpath = LS3DGUP.LS3DGUP.UtilsPath + "semantic_materials.mat"
		if not doesFileExist fpath do return false
		local mat_lib = loadTempMaterialLibrary fpath
		meditMaterials[slot_index] = mat_lib[1]
		-- loadMaterialLibrary LS3DGUP.LS3DGUP.UtilsPath + "semantic_materials.mat"
		-- newMat = currentMaterialLibrary["semantic_materials"]
	),
	fn createMaxMaterial asset_name mat_guid &output_log slot_index:1 = (
	
		local new_mat = LS3DMaterial()
		if mat_guid != undefined do new_mat.matguid = mat_guid
		new_mat.name = asset_name
		meditMaterials[slot_index] = new_mat
		output_log += "\n\tCreated Max Material:" + asset_name
		new_mat
	),
	fn modifyGuid path newGUID =
	(
		local result = false
		try (
			local xDoc = XMLDocument()										--Create an XMLDcoument
			xDoc.LoadXML path												--Load XML from file
			local rNode = xDoc.GetRootNode()									--Get the Root Node THIS MUST BE CALLED!		
			
			local guidNode = rNode.GetChild 0
			if (guidNode.GetTag() != "guid") then (
				LogM ("Unable to find <guid> in material xml. Invalid format. Skipping. -> " + path as string) level:3
			) else (
				guidNode.SetText newGUID
				xDoc.SaveXML()
				result = true
			)
		) catch (
			LogM ("Unknown error while reading material XML. Invalid format. Skipping. -> " + path as string + ", new material GUID: " + newGUID as string) level:3
		)		
		return result
	),
	fn getGuid path =
	(
		local result = undefined
		try (
			local xDoc = XMLDocument()										--Create an XMLDcoument
			xDoc.LoadXML path												--Load XML from file
			local rNode = xDoc.GetRootNode()									--Get the Root Node THIS MUST BE CALLED!		
			
			local guidNode = rNode.GetChild 0
			if (guidNode.GetTag() != "guid") then (
				LogM ("Unable to find <guid> in material xml. Invalid format. Skipping. -> " + path as string) level:3
			) else (
				result = guidNode.GetText()
			)
		) catch (
			LogM ("Unknown error while reading material XML. Invalid format. Skipping. -> " + path as string) level:3
		)		
		return result
	),
	--dds_suffix = #("---d.dds", "---dm.dds", "---e.dds", "---g.dds", "---n.dds")
	fn getDdsSuiffixByName dds_name = (
	
		local pattern_names = getINISetting SettingsINI "DDS_Textures_Pattern"
		for n in pattern_names where n == dds_name do return (
		
			getINISetting SettingsINI "DDS_Textures_Pattern" n
		)
	),
	--clone templates to generete desired textures
	fn generateDDSTextures utils_path edit_maps_path asset_name dds_names_list = (
	
		local sourcePath = utils_path + maps_templates_path
		struct FILE_DATA (fname, fpath)
		local new_textures = #()
		for dds_name in dds_names_list do (
		
			local dds_sufix = getDdsSuiffixByName dds_name
			local source_file = sourcePath + "template" + dds_sufix
			local new_file_name = asset_name + dds_sufix
			local target_file = edit_maps_path + new_file_name
format "MAT_MANAGER > generateDDSTextures >: file:%\n" target_file			
--disable for test
--local result = CopyFile source_file target_file
--if doesFileExist target_file do 
			append new_textures (FILE_DATA new_file_name target_file)
		)
		new_textures
	),
	fn createFusionMaterial utils_path edit_maps_path asset_name dds_names_list mat_guid = (
	
		if gLS3DDXSupport == undefined or not gLS3DDXSupport.ShaderUpdateScriptInit() then (
			
			return undefined
		)
		local new_textures = generateDDSTextures utils_path edit_maps_path asset_name dds_names_list
		local new_mat_name = asset_name + ".xml"
		local new_mat_path = edit_maps_path + new_mat_name
		local mat_and_dds_paths = join #( new_mat_path ) new_textures
		format "MAT_MANAGER > createFusionMaterial > :% with (%) textures.\n" new_mat_name new_textures.count 
		
		/*
		
		GenerateLS3DMaterial newMaterialPath newMaterialFileName randomSeed newTextureNames conversionTable
	
		*/
		
		output_log += "\n\tCreated DDS Textures:" + new_textures
		output_log += "\n\tCreated Fusion Material:" + new_mat_name
		mat_and_dds_paths
	)
)



/*
mat_man = MAT_MANAGER()
mat_man.loadMaxSemanticMaterial()
*/
