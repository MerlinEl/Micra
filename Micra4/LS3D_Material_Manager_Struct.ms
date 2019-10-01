--------------------------------------------------------------------------------
/* mcLS3DMaterialManager by Orien 2019 */
--------------------------------------------------------------------------------
Global mcLS3DMaterialManagerStruct
Global mcLS3DMaterialManagerRun
/*
*@Used Structures
	mcStructMan
*
*@Used Objects
	undefined
*
*@Usage
	undefined
*
*@Example	
	undefined
*
*/
struct LS3D_MATERIAL_MANAGER_STRUCT (
	
	--variables
	c_P4Desc_editMatLibrary  	= "MOD: Terrain Material Library",
	xml_materials_table = (LS3DGUP.LS3DGUP.UtilsPath + "coll_bourbon_table.xml")	,
	terrain_mat_lib_path = (LS3DGUP.LS3DGUP.UtilsPath + @"ground_material\bc_terrain.mat"),
	--functions
	fn getSource = getSourceFileName(), --get path of this script
	/**
	*@Usage add file in to pending list 
	*/
	fn checkoutFileInPerforce file_path plist_description = (
	
		local fileStatus = gP4.P4_CheckFileStatus file_path
		if (fileStatus != 4) then (
			local changelist = gP4.P4_CreateChangelist plist_description --"MOD: Terrain Material Library"
			format "Creating changelist: %\n" changelist
			if (changelist == -1) then (
			
				format "Unable to create changelist for material library. I'll try to use default changelist.\n"
			)
			format "P4 Checkout of material library :%\n" file_path
			gP4.P4_Checkout #(file_path) changelist
		)
	),
	fn openFilesForEdit = (
	
		checkoutFileInPerforce xml_materials_table c_P4Desc_editMatLibrary
		checkoutFileInPerforce terrain_mat_lib_path c_P4Desc_editMatLibrary
	),
	/**
	*@Usage add one or more material libraries in to Temporary Library
	*@Example
			--load
			semantic_lib_path = (LS3DGUP.LS3DGUP.UtilsPath + "semantic_materials.mat")
			terrain_lib_path = (LS3DGUP.LS3DGUP.UtilsPath + @"ground_material\bc_terrain.mat")
			loadMaterialsToLibrary #(semantic_lib_path, terrain_lib_path)
			--read
			currentMaterialLibrary.count
			currentMaterialLibrary[1].name
			currentMaterialLibrary[2].name
			semantic_mat = currentMaterialLibrary["semantic_materials"]
			terrain_mat = currentMaterialLibrary["bc_terrain_main"]
	*/
	fn loadMaterialsToLibrary libs_path_arr getLatest:true = (

		--clean current library
		while currentmateriallibrary.count > 0 do deleteitem currentmateriallibrary 1 
		--load libraries from disk
		local mats = #()
		for lib_path in libs_path_arr where doesFileExist lib_path do (
		
			if getLatest do gP4.P4_GetLatest #(lib_path) --fetch latest revision of file
			local success = loadMaterialLibrary lib_path
			if not success do (
			
				format "Unable to load terrain material library:%\n " lib_path
				continue
			)
			append mats currentMaterialLibrary[1]
		)
		--clean current library again
		while currentmateriallibrary.count > 0 do deleteitem currentmateriallibrary 1 
		--apend materials in to library
		for m in mats do append currentMaterialLibrary m
	),
	
	/**
	@Usage save single material library to file ( check in perforce switch )
	*@Example
		--save all libraries in one
		all_lib_path = (LS3DGUP.LS3DGUP.UtilsPath + @"ground_material\mat_all.mat")
		saveMaterialFromLibrary all_lib_path "" allInOne:true 
	
		--save single library
		terrain_lib_path = (LS3DGUP.LS3DGUP.UtilsPath + @"ground_material\bc_terrain.mat")
		saveMaterialFromLibrary terrain_lib_path "bc_terrain_main"
	*/
	fn saveMaterialFromLibrary lib_path lib_name checkInPerforce:true allInOne:false = (
	
		if checkInPerforce do (
		
			local fileStatus = gP4.P4_CheckFileStatus lib_path
			if (fileStatus != 4) then (
				local changelist = gP4.P4_CreateChangelist "MOD: Terrain Material Library"
				format "Creating changelist:%\n " changelist
				if (changelist == -1) then (
					format ("Unable to create changelist for material library. I'll try to use default changelist.\n")
				)
				format "P4 Checkout of material library :%\n" lib_path
				gP4.P4_Checkout #(lib_path) changelist
			)
		)
		format "Mat Lib [ % ] are Saved.\n" lib_path
		if allInOne then (
		
			saveTempMaterialLibrary currentMaterialLibrary lib_path
			
		) else (
				
			local mat = currentMaterialLibrary[lib_name] --get material from library
			if mat == undefined do return false
			local mat_lib = materialLibrary(mat) --instance material library
			saveTempMaterialLibrary mat_lib lib_path
		)
	)
	/*<end>*/
)	
 --create instance


--runCommandByName
struct LS3D_MATERIAL_MANAGER_RUN (

	fn getMaterialXML mat = (
	
		case classOf mat of (
		
			DirectX_9_Shader : if mat.renderMaterial != undefined then getMaterialXML mat.renderMaterial else "uni_color_grey.xml"
			LS3DMaterial : filenameFromPath (mat.GetName())
			default : "uni_color_grey.xml"
		)	
	),

	fn getStandardMaterial = (
		
		local new_mat = StandardMaterial()
		new_mat.name = "uni_color_green"
		new_mat.diffuse  = green
		new_mat
	),
	
	fn getDefaultLs3DMaterial = (
		
		local new_mat = LS3DMaterial()
		new_mat.name = "uni_color_gray"
		local uni_color_gray_id = "0x088a7f58, 0x1e01037d"
		new_mat.SetGUID uni_color_gray_id
		new_mat.ls3d.Synchronize()
		new_mat
	),
	
	fn isNotAllowedMaterial m = (
		--conditions
		local restricted_names = #(
		
			"uni_metrics_grid_light_grey.xml", 
			"uni_metrics_grid_dark_grey.xml",
			"uni_color_grey_medium.xml",
			"uni_metrics_grid_blue.xml",
			"uni_color_grey_dark.xml",
			"dark_gray.xml",
			"gray.xml"
		)
			m == undefined or
				classOf m == Missing_Mtl or
					classOf m == Standardmaterial or 
						classOf m == LS3DMaterial and findItem restricted_names (getMaterialXML m) != 0 or
							classOf m == DirectX_9_Shader and classOf m.renderMaterial == Missing_Mtl or 
								findItem restricted_names (getMaterialXML m) != 0 or
									m.name == "none" or 
										m.name == "uni_color_gray"
	), 
	
	fn replaceMaterial multi_mat new_mat &tabs:"\t" &cnt:0 = ( 
	
		local tab_str = tabs + "\t" --next level
		local mat_name = if multi_mat != undefined then multi_mat.name else "undefined"
		if classOf multi_mat == MultiMaterial then ( --multi material

			format ("%MULTIMATERIAL:% CLASS:%\n") tab_str multi_mat.name (classOf multi_mat)
			for i = 1 to multi_mat.count do (
				
				local mat = multi_mat[i]
				if classOf mat == MultiMaterial then (
				
					cnt+= 1
					replaceMaterial mat new_mat tabs:tab_str cnt:&cnt
					
				) else if isNotAllowedMaterial mat do (
				
					local m_name = if mat != undefined then mat.name else "undefined"
					format "%\tREPLACE ID:% MAT:%  CLASS:% IN MULTIMAT:%\n" tab_str i m_name (classOf mat) multi_mat.name
					multi_mat[i] = new_mat
				)
			)
		)
	),

	fn replaceMaterialsOnObjects objs = (

		local new_mat = getDefaultLs3DMaterial()
		local unique_materials = #()
		local cnt = 0
		for o in objs do (
			
			local mat = o.material
			local mat_name = if mat != undefined then mat.name else "undefined"
			format "\tOBJ:% CLASS:% MAT:% \n" o.name (classOf o) mat_name
			if classOf mat != MultiMaterial then (
			
				if isNotAllowedMaterial mat do (
				
					cnt += 1
					format "\t\tREPLACE ID:% MAT:%  CLASS:%\n" 0 i m_name (classOf mat) 
					o.material = new_mat
				)

			) else (
			
				if findItem unique_materials mat != 0  and mat != undefined do continue
				append unique_materials mat
				replaceMaterial mat	new_mat cnt:&cnt
			)
		)
		format "MultiMaterials Collected:% Total Replaced:%\n" unique_materials.count cnt
	),
	
	fn listMaterial mat &tabs:"\t" = (
	
		local tab_str = tabs + "\t" --next level
		local mat_name = if mat != undefined then mat.name else "undefined"
		local mat_xml = getMaterialXML mat
		if classOf mat == MultiMaterial then ( --multi material

			format ("%MULTIMATERIAL:% CLASS:%\n") tab_str mat.name (classOf mat)
			for i = 1 to mat.count do (
				
				local m = mat[i]
				local m_name = if m != undefined then m.name else "undefined"
				if classOf m == MultiMaterial then (
				
					listMaterial m tabs:tab_str
					
				) else (
				
					mat_xml = getMaterialXML m
					format "%\tID:% MAT:%  XML:% CLASS:%\n" tab_str i m_name mat_xml (classOf m) 
				)
			)
			
		) else ( --single material
		
			format "\t\tSINGLEMATERIAL:%  XML:% CLASS:%\n" mat_name mat_xml (classOf mat)
			
		)
	),
	
	fn listMaterialsFromObjects objs = (
	
		local unique_materials = #()
		for o in objs do (
			
			local mat = o.material
			local mat_name = if mat != undefined then mat.name else "undefined"
			local mat_xml = getMaterialXML mat
			format "\tOBJ:% CLASS:% MAT:% XML:% \n" o.name (classOf o) mat_name mat_xml
			if findItem unique_materials mat != 0  and mat != undefined do continue
			append unique_materials mat
			listMaterial mat	
		)
		format "Materials Collected:%\n" unique_materials.count
	),
	
	fn printUsedMaterials sel = (

		local used_materials = #()
		local undefined_materials = 0
		for o in sel do (
			
			if o.material == undefined do (undefined_materials += 1; continue) 
			appendIfUnique used_materials o.material.name
		)
		format "Materials Used : % Undefined: %\n" used_materials.count undefined_materials
		print used_materials
	),
	
	fn usingBcMaterial obj = (
		
		local mat = obj.material
		if mat == undefined do return false
		local bc_materials = #(
		
			"bc_02_unique_water_lock_v1.xml", 
			"bc_concrete_wall_02.xml", 
			"bc_sidewalk_c.xml",
			"bc_road_industrial.xml", 
			"bc_concrete_wall_01.xml", 
			"bc_curb_c.xml", 
			"bc_02_unique_grain_silos_alpha_v1.xml"
		)
		if classOf mat == Multimaterial then (

			--format "multi:%\n" mat.name
			for m in mat do (

				local mat_xml = getMaterialXML m
				if (findItem bc_materials mat_xml != 0) do return true
			) 

		) else (
		
			local mat_xml = getMaterialXML mat
			--format "single:% xml:%\n" mat.name mat_xml
			findItem bc_materials mat_xml != 0
			
		)
		false
	),
	
	fn selectObjectsWithBcMaterial sel = (

		local bc_objects = for o in sel where (usingBcMaterial o) collect o
		format "( % ) Objects using BC Materials Found.\n" bc_objects.count
		if bc_objects.count > 0 do select bc_objects

	),
	
	fn openSementicMaterialTable = (
	
		ShellLaunch  "https://hub.gametools.dev/pages/viewpage.action?spaceKey=whsky&title=Mafia+III+Collision+layers+and+Semantic+Materials" ""
	)
)

--instance structures
mcLS3DMaterialManagerRun = LS3D_MATERIAL_MANAGER_RUN()
mcLS3DMaterialManagerStruct = LS3D_MATERIAL_MANAGER_STRUCT()