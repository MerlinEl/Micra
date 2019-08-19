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
	/*fn modifyXMLTexture path textureType newTexture = (
		local result = false
		try (
			local xDoc = XMLDocument()										--Create an XMLDcoument
			xDoc.LoadXML path														--Load XML from file
			local rNode = xDoc.GetRootNode()									--Get the Root Node THIS MUST BE CALLED!		
			
			local nParam = rNode.GetChild 3
			if (nParam.GetTag() != "parameters") then (
				LogM ("Node 'parameters' not found. Invalid format. Skipping -> " + path + ", texture type: " + textureType as string + ", new texture name: " + newTexture as string) level:3
			) else (
				local nParamChildren = nParam.GetChildren()
				local notFound = true
				for child in nParamChildren while notFound do (
					local nName = child.GetChild 0
					if (nName.GetTag() == "name") then (
						if (nName.GetText() == textureType) then (
							local nValue = child.GetChild 1
							if (nValue.GetTag() == "value") then (
								nValue.SetText newTexture
								notFound = false
							) else (
								LogM ("Unable to found node 'value'. Invalid Format. Skipping. -> " + path + ", texture type: " + textureType as string + ", new texture name: " + newTexture as string) level:3
							)
						)						
					) else (
						LogM ("Unable to found node 'name'. Invalid Format. Skipping. -> " + path + ", texture type: " + textureType as string + ", new texture name: " + newTexture as string) level:3
					)
				)
				xDoc.SaveXML()		
				result = true
			)
		) catch (
			LogM ("Unknown error while reading material XML. Invalid format. Skipping. -> " + path + ", texture type: " + textureType as string + ", new texture name: " + newTexture as string) level:3
		)
		return result
	),*/
	fn modifyXMLGuid path newGUID =
	(
		local result = false
		try (
			local xDoc = XMLDocument()										--Create an XMLDcoument
			xDoc.LoadXML path												--Load XML from file
			local rNode = xDoc.GetRootNode()									--Get the Root Node THIS MUST BE CALLED!		
			
			local guidNode = rNode.GetChild 0
			if (guidNode.GetTag() != "guid") then (
				mcPprogbUI.msg ("Unable to find <guid> in material xml. Invalid format. Skipping. -> " + path as string) ty:"error" ti:"Aborted!"
			) else (
				guidNode.SetText newGUID
				xDoc.SaveXML()
				result = true
			)
		) catch (
			mcPprogbUI.msg ("Unknown error while reading material XML. Invalid format. Skipping. -> " + path as string + ", new material GUID: " + newGUID as string) ty:"error" ti:"Aborted!"
		)		
		return result
	),
	fn getXMLGuid path =
	(
		local result = undefined
		try (
			local xDoc = XMLDocument()										--Create an XMLDcoument
			xDoc.LoadXML path												--Load XML from file
			local rNode = xDoc.GetRootNode()									--Get the Root Node THIS MUST BE CALLED!		
			
			local guidNode = rNode.GetChild 0
			if (guidNode.GetTag() != "guid") then (
				mcPprogbUI.msg ("Unable to find <guid> in material xml. Invalid format. Skipping. -> " + path as string) ty:"error" ti:"Aborted!"
			) else (
				result = guidNode.GetText()
			)
		) catch (
			mcPprogbUI.msg ("Unknown error while reading material XML. Invalid format. Skipping. -> " + path as string) ty:"error" ti:"Aborted!"
		)		
		return result
	),
	fn createMaxMaterial asset_name mat_guid xds_mterial slot_index:1 = (
	
		mcPprogbUI.msg "Creating Max Material" ti:"3DsMax..." ty:"task_open"
		local new_mat = LS3DMaterial()
		if new_guid == undefined do new_guid = getXMLGuid xds_mterial
		if mat_guid != undefined do new_mat.matguid = mat_guid
		new_mat.name = asset_name
		meditMaterials[slot_index] = new_mat
		output_log += "\n\tCreated Max Material:" + asset_name
		mcPprogbUI.msg "Max Material are created" ti:"3DsMax..." ty:"task_close"
		new_mat
	),
	--dds_suffix = #("---d.dds", "---dm.dds", "---e.dds", "---g.dds", "---n.dds")
	fn getDdsSuiffixByName dds_name = (
	
		local pattern_names = getINISetting SettingsINI "DDS_Textures_Pattern"
		for n in pattern_names where n == dds_name do return (
		
			getINISetting SettingsINI "DDS_Textures_Pattern" n
		)
	),
	--clone templates to generete desired textures
	fn generateDDSTextures utils_path dds_textures = (
	
		local sourcePath = utils_path + maps_templates_path
		for target_file in dds_textures do (
		
			mcPprogbUI.msg ("Create DDS Texture: "+ target_file) ty:"proc"			
--disable for test
			--CopyFile source_file target_file
		)
	),
	fn createFusionMaterial utils_path xds_mterial dds_textures = (
	
		mcPprogbUI.msg "Creating Fusion Material" ti:"Fusion..." ty:"task_open"
		if gLS3DDXSupport == undefined or not gLS3DDXSupport.ShaderUpdateScriptInit() then (
			
			mcPprogbUI.msg ("gLS3DDXSupport structure is Missing...") ti:"Aborted!" ty:"error"
			return ""
		)
		generateDDSTextures utils_path dds_textures
		local new_guid = mat_man.generateMaterialGuid (random 1 100)
		mcPprogbUI.msg ("Generate New GUID: [ "+ new_guid + " ]") ty:"proc"
	/*
	local sourceFile = 
	copyFile sourceFile xds_mterial
	modifyXMLGuid xds_mterial new_guid
	
	for i = 1 to textureNames.count do (
			local texName = textureNames[i]
			if (texName != "") then (
				local texType = sourceTemplateMapTypes[i]
				if (not(modifyXMLTexture targetFullPath texType texName)) then return undefined
			)
		)
	*/	
		
		
	/*
	local conversionTable = gShaderUpdateScript.GetConversionTableByIndex 1)
	local shaderName = conversionTable.GetName()
	materialTemplateName = GetTemplateNameFromShaderName shaderName
	GenerateLS3DMaterial xds_mterial new_guid dds_textures shaderName
	
	*/
		mcPprogbUI.msg ("Created XDS Material:"+ xds_mterial) ty:"proc"
		new_guid
	)
)



/*
mat_man = MAT_MANAGER()
mat_man.loadMaxSemanticMaterial()
*/
