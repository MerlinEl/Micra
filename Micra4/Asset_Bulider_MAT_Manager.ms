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
	fn setTextureToXML path param texture_fname = (
	
		local result = false
		try (
			local xDoc = XMLDocument()										--Create an XMLDcoument
			xDoc.LoadXML path												--Load XML from file
			local rNode = xDoc.GetRootNode()									--Get the Root Node THIS MUST BE CALLED!	
			local nParam = rNode.GetChild 3
			if (nParam.GetTag() != "parameters") then (
			
				mcPprogbUI.msg ("Node 'parameters' not found. Invalid format. Skipping -> -> [ " + path + " ] , texture: " + texture_fname) ti:"Failed!" ty:"error"
				
			) else (
			
				local nParamChildren = nParam.GetChildren()
				local notFound = true	
				for child in nParamChildren while notFound do (
				
					local nName = child.GetChild 0
					if (nName.GetTag() == "name") then (
						if (nName.GetText() == param) then (
							local nValue = child.GetChild 1
							if (nValue.GetTag() == "value") then (
								nValue.SetText texture_fname
								notFound = false
							) else (
							
								mcPprogbUI.msg  ("Unable to found node 'value'. Invalid Format. Skipping. -> " + path + ", texture type: " + param + ", new texture name: " + texture_fname) ti:"Failed!" ty:"error"
							)
						)						
					) else (
					
						mcPprogbUI.msg  ("Unable to found node 'name'. Invalid Format. Skipping. -> " + path + ", texture type: " + param + ", new texture name: " + texture_fname) ti:"Failed!" ty:"error"
					)
				)
				xDoc.SaveXML()		
				result = true
			)
		) catch (
		
			mcPprogbUI.msg ("Unknown error while reading material XML. Invalid format. Skipping. -> [ " + path + " ] , texture: " + texture_fname) ti:"Failed!" ty:"error"
		)
		result
	),
	fn setXMLGuid path newGUID =
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
		--LS3DGUP.ReloadMaterialDatabase()
		local new_mat = LS3DMaterial()
		if new_guid == undefined do new_guid = getXMLGuid xds_mterial
		if mat_guid != undefined do new_mat.matguid = mat_guid
		new_mat.name = asset_name
		meditMaterials[slot_index] = new_mat
		new_mat.guessbindings()
		new_mat.synchronize()
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
	
		for target_file in dds_textures do (
		
			local ext = (filterString target_file "---")[2]
			local source_file = utils_path + maps_templates_path + "template---" + ext
			if not (doesFileExist source_file) do (
		
				mcPprogbUI.msg ("Pick  DDS Template [ "+ source_file + " ] ...Failed" ) ty:"error"
				continue
			)
			mcPprogbUI.msg ("Pick  DDS Template: [ "+ source_file + " ] ...OK") ty:"proc"
			mcPprogbUI.msg ("Create DDS Texture: "+ target_file) ty:"proc"
			CopyFile source_file target_file
		)
	),
	/**
		names from ini file, head:[Materials_Templates]
		params from ini file, head:[DDS_Textures_List] > diffuse, normal, glossiness, emissive
		templates location d:\!2k_games\scotch_dev\resources\utilities\3dsmax\asset_management\materials\...
	*/
	fn getTemplateParameters shader_name = (

		case shader_name of (
		
			"facade_basic" : #(
			
				"T000_DiffuseTexture", "T001_NormalTexture", "T002_GlossinessMetalTexture", "T011_EmissiveTexture"
			)
			"facade_blend" : #(
		
				"T000_DiffuseTexture", "T001_NormalTexture", "T002_GlossinessMetalTexture", "none"
			)
			"facade_colored" : #(
		
				"T000_DiffuseTexture", "T001_NormalTexture", "T002_GlossinessMetalTexture", "none"
			)
			"facade_colored_2uv": #(
			
				"T000_DiffuseTexture", "T001_NormalTexture", "T002_GlossinessMetalTexture", "T011_EmissiveTexture"
			)
			"general":#(

				"T000_DiffuseTexture", "T001_NormalTexture", "T002_GlossinessMetalTexture", "none"
			)
			"general_roughness" : #(
			
				"T000_DiffuseTexture", "T001_NormalTexture", "T002_GlossinessMetalTexture", "T011_EmissiveTexture"
			)
			"roads" : #(
			 
				"T000_DiffuseTexture", "T001_NormalTexture", "T002_GlossinessMetalTexture", "none"
			)
			"terrain_3blend" : #(

				"T000_DiffuseTexture", "T001_NormalTexture", "T002_GlossinessMetalTexture", "none"
			)
			"terrain_shore" : #(

				"T000_DiffuseTexture", "T001_NormalTexture", "T002_GlossinessMetalTexture", "none"
			)
			default : #("none", "none", "none", "none")			
		)
	),
	--lh_08_family_house_a_v1_test---d
	fn getParamByFname texture_fname params = (
	
		local last_char = texture_fname[texture_fname.count]
		case last_char of (
		
			"d" : params[1]
			"n" : params[2]
			"g" : params[3]
			"e" : params[4]
			default : undefined
		)
	),
	fn createFusionMaterial utils_path xds_mterial mat_type dds_textures = (
	
		mcPprogbUI.msg "Creating Fusion Material" ti:"Fusion..." ty:"task_open"
		if gLS3DDXSupport == undefined or not gLS3DDXSupport.ShaderUpdateScriptInit() then (
			
			mcPprogbUI.msg ("gLS3DDXSupport structure is Missing...") ti:"Aborted!" ty:"error"
			return ""
		)
		generateDDSTextures utils_path dds_textures
		local new_guid = generateMaterialGuid (random 1 100)
		mcPprogbUI.msg ("Generate New GUID: [ "+ new_guid + " ]") ty:"proc"
		local source_file = utils_path + @"asset_management\materials\template_" + mat_type + ".xml"
		if not (doesFileExist source_file) do (
		
			mcPprogbUI.msg ("Pick  Material Template: [ "+ source_file + " ] ...Failed" ) ti:"Aborted!" ty:"error"
			return ""
		)
		mcPprogbUI.msg ("Pick  Material Template: [ "+ source_file + " ] ...OK") ty:"proc"
		local params = getTemplateParameters mat_type
		mcPprogbUI.msg ("Template [ "+ mat_type+" ] params : [ "+ params as String + " ]") ty:"proc"
		
		--copy template to target location --
		copyFile source_file xds_mterial
		setFileAttribute xds_mterial #readOnly false 
		--assign new GUID
		mcPprogbUI.msg ("Assign Material [ "+ mat_type +" ] new  GUID : [ "+ new_guid + " ] ") ty:"proc"
		setXMLGuid xds_mterial new_guid
		--assign each texture to XML parameter slot
		for tpath in dds_textures do (
				 
			local texture_fname = (getFilenameFile tpath) + (getFilenameType tpath)
			local param = getParamByFname (getFilenameFile tpath) params
			if param == undefined do (
			
				mcPprogbUI.msg ("Material [ "+mat_type+" ] are not Supporting texture: [ "+texture_fname+" ]") ti:"Failed!" ty:"error"
				continue
			)
			mcPprogbUI.msg ("Assign texture [ "+ texture_fname+" ] to Material : [ "+ mat_type + " ] param: [ " + param + " ]") ty:"proc"
			--assign texture in to xml material slot
			setTextureToXML xds_mterial param texture_fname
		)	
		mcPprogbUI.msg ("Created XDS Material:"+ xds_mterial) ty:"task_close"
		new_guid
	)
)

/*
mat_man = MAT_MANAGER()
mat_man.loadMaxSemanticMaterial()
*/
