Global MAT_MANAGER

struct MAT_MANAGER (

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
	fn createMaxMaterial mat_name mat_guid slot_index:1 = (
	
		if mat_name == "" do return undefined
		local new_mat = ls3dMaterial()
		new_mat.matguid = mat_guid
		new_mat.name = mat_name
		meditMaterials[slot_index] = new_mat
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
	fn createFusionMaterial asset_name edit_path = (
	
	
	)
)



/*
new_guid = generateMaterialGuid (random 1 100)

mm = MAT_MANAGER()
mm.loadMaxSemanticMaterial()
*/
