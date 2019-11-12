Global mcQuickMaterialsDialog
if mcQuickMaterialsDialog != undefined do destroyDialog mcQuickMaterialsDialog
rollout mcQuickMaterialsDialog "Quick Materials:" width:556 height:456
(
	--variables and structures
	struct MAT_ITEM (key, id, sid, tile_u, tile_v)
-- hotfix > restricted_textures > 
-- prevent 2blend materials displayed as 3blend	(
-- lh_plaster_a_v3_N, ID: 305, d:\!2k_games\scotch_dev\edit\materials\city\lost_heaven\terrain\ground\lh_grass_mud_gravel_a_v1.xml
-- lh_02_wall_bricks_v1_N, ID: 302, d:\!2k_games\scotch_dev\edit\materials\city\lost_heaven\districts\lh_02_little_italy\lh_02_wall_bricks_v1.xml
-- )
	local restricted_textures = #("t033_diffusetexture3")	--always use lowercase
	local xml_materials_table = (LS3DGUP.LS3DGUP.UtilsPath + "coll_bourbon_table.xml")	
	local terrain_mat_lib_path = (LS3DGUP.LS3DGUP.UtilsPath + @"ground_material\bc_terrain.mat")
	local material_color_types = #(color 173 136 255, color 90 200 200, color 255 136 213)
	local mat_items = #( --temp table for test only
		
		MAT_ITEM key:"grass"				id:140		sid:81		tile_u:0.4		tile_v:0.4,
		MAT_ITEM key:"pavement1"			id:53		sid:53		tile_u:0.16		tile_v:0.32,
		MAT_ITEM key:"pavement2"			id:58		sid:53		tile_u:0.25		tile_v:0.25,
		MAT_ITEM key:"pavement3"			id:50		sid:53		tile_u:0.12		tile_v:0.25, 
		MAT_ITEM key:"bricks1"			id:54		sid:27		tile_u:0.4		tile_v:0.4, 
		MAT_ITEM key:"bricks2"			id:59		sid:27		tile_u:0.4		tile_v:0.4,  
		MAT_ITEM key:"bricks3"			id:51		sid:27		tile_u:0.9		tile_v:0.9, 
		MAT_ITEM key:"dirt"				id:103		sid:7		tile_u:0.4		tile_v:0.4,
		MAT_ITEM key:"asphalt"			id:3		sid:81		tile_u:0.4		tile_v:0.4
	)
	local drawingColor   = dotNetClass "drawing.color"
	local bgColor   = ((colorMan.getColor #background)*255)as color
	local winColor  = ((colorMan.getColor #window)*255)as color
	local textColor = ((colorMan.getColor #text)*255)as color
	local current_mat_id = 140
	local list_items = #() --backup collection for search bar (edt_filter_names)
	local terrain_mat = undefined
	local semantic_mat = undefined
	local terrain_mat_name = "bc_terrain_main"
	--UI
	GroupBox 'grp1' "Preview:" pos:[4,4] width:280 height:228 align:#left
	GroupBox 'grp4' "Materials:" pos:[288,4] width:264 height:448 align:#left
	GroupBox 'grp5' "Show Material Type:" pos:[4,236] width:136 height:76 align:#left
	GroupBox 'grp10' "Set - Up:" pos:[4,316] width:136 height:104 align:#left
	
	button 'btn_clear_text' "<" pos:[526,24] width:18 height:20 toolTip:"Clear Text" align:#left
	button 'btn_apply_mat' "Assign Material" pos:[148,236] width:136 height:24 toolTip:"Aply material to selected faces" align:#left
	button 'btn_apply_id' "Change Material ID" pos:[148,288] width:136 height:24 toolTip:"Change material ID on selected faces" align:#left
	button 'btn_get_sel' "Pick Material" pos:[148,372] width:136 height:24 toolTip:"Pick Material From Face" checked:false align:#left
	button 'btn_sel_simillar' "Select Simillar Faces" pos:[148,316] width:136 height:24 align:#left
	button 'btn_sel_grow' "Grow Simillar" pos:[148,344] width:136 height:24 align:#left
	button 'btn_unwrap' "Unwrap UVW" pos:[148,400] width:136 height:24 align:#left

	checkbox 'chk_collapse' "Collapse Modifier" pos:[12,332] width:100 height:16 checked:true align:#left
	checkbox 'chk_autoorient' "Orientation Auto" pos:[12,352] width:100 height:16 checked:false align:#left
	-- 	checkbox 'chk_preserve_uv' "Preserve UVs" pos:[12,372] width:100 height:16 checked:true align:#left
	--  checkbox 'chk_clear_selection' "Clear Selection" pos:[12,372] width:100 height:16 checked:true align:#left --REMOVED(dont really need this)

	bitmap 'bmp_preview' "Bitmap" pos:[12,24] width:264 height:200 align:#left
	bitmap 'bmp_mat_type_1' "Bitmap" pos:[92,256] width:40 height:16 align:#left
	bitmap 'bmp_mat_type_2' "Bitmap" pos:[92,272] width:40 height:16 align:#left
	bitmap 'bmp_mat_type_3' "Bitmap" pos:[92,288] width:40 height:16 align:#left
	
	dotNetControl 'edt_filter_names' "textbox" pos:[320,24] width:204 height:20 align:#left
	dotNetControl 'lv_mat_data' "listView" pos:[292,48] width:252 height:396 align:#left
	
	label 'lbl7' "filter:" pos:[292,28] width:28 height:12 align:#left

	radiobuttons 'rdo_mat_type' "" pos:[8,256] width:81 height:48 labels:#("Spawn NPC", "No Spawn", "No Entry") columns:1 align:#left
	spinner 'spn_mapping_angle' "" pos:[228,264] width:60 height:16 range:[-360,360,0] type:#float scale:0.1 align:#left
	label 'lbl2' "Mapping Angle:" pos:[152,265] width:72 height:16 align:#left
	radiobuttons 'rdo_mappig_type' "Mapping:" pos:[10,380] width:114 height:30 labels:#("Planar", "Box") columns:2 toolTip:"Experimental Mode. Is not Finished yet." align:#left
	button 'btn_run_fn' "GO" pos:[256,428] width:24 height:20 align:#left
	dropDownList 'ddl_fn_list' "" pos:[4,428] width:248 height:21 items:#("Create Curb Custom", "Create Curb From Edges", "Create Curb From Spline", "Redraw Spline At Zero") align:#left

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
	)
	
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

	fn loadMateriaLibraries = (
	
		--get materials
		semantic_mat = currentMaterialLibrary["semantic_materials"]
		terrain_mat = currentMaterialLibrary["bc_terrain_main"]
	
		if semantic_mat == undefined or terrain_mat == undefined do ( --if materials not found reload them
	
			--load latest materials
			local semantic_lib_path = (LS3DGUP.LS3DGUP.UtilsPath + "semantic_materials.mat")
			local terrain_lib_path = (LS3DGUP.LS3DGUP.UtilsPath + @"ground_material\bc_terrain.mat")
			loadMaterialsToLibrary #(semantic_lib_path, terrain_lib_path)
			--define variables
			semantic_mat = currentMaterialLibrary["semantic_materials"]
			terrain_mat = currentMaterialLibrary["bc_terrain_main"]
		
		)
		
		--replace materials in Material Editor
		meditMaterials[1] = terrain_mat
		meditMaterials[2] = semantic_mat
	)
	
	fn UVWMapFit theObj theMap useSel:#none = (
		--RESET THE GIZMO SCALE FIRST:
		--Multiply the gizmo's transformation with the inverse of a matrix created from its scale factor
		theMap.gizmo.transform *= inverse (scaleMatrix theMap.gizmo.transform.scalepart)
		--RESULT: the gizmo scaling will be reset to [1,1,1]
		--GET THE MESH IN OBJECT SPACE BEFORE PRS AND WSM
		--NOTE that this will get the mesh from TOP of the modifier stack just before PRS transforms.
		--This means that the script SHOULD be applied to the UVW_Mapping modifier only when it is
		--the TOP modifier on the stack, otherwise the geometry used might not be the geometry
		--that the modifier is really applied to.
		theMesh = theObj.mesh
		--TRANSFORM ALL VERTICES IN GIZMO SPACE AND FIND MIN. AND MAX. OF GIZMO BBOX
		minX = minY = minZ = 100000000 --initialize  min.values to very large numbers
		maxX = maxY = maxZ = -100000000 --initialize max.values to very low numbers
		theTM = theMap.gizmo.transform --store the transformation matrix of the UVW gizmo in a variable
		theTMInv = inverse theTM --calculate the inverse of the gizmo TM and store in another variable
		--DEPENDING ON THE OPTIONAL 3RD ARGUMENT, GET THE VERTICES TO OPERATE ON:
		theVerts = case useSel of
		(
		--If no selection is defined, use a bitarray containing ALL vertices.
		#none: #{1..theMesh.numverts}
		--If vertex selection is requested, get the selection from the mesh
		#verts: (getVertSelection theMesh)
		--if edge selection is requested, convert the edge selection to vertex list:
		#edges: (meshop.getVertsUsingEdge theMesh (getEdgeSelection theMesh))
		--if face selection is requested, convert the face selection to vertex list:
		#faces: (meshop.getVertsUsingFace theMesh (getFaceSelection theMesh))
		)
		for v in theVerts do --loop through all vertices in the bitarray defined above
		(
		  theVert = (getVert theMesh v) * theTMInv --get the vertex position in gizmo space
		--Record min. and max. values for X, Y and Z:
		  if theVert.x > maxX do maxX = theVert.x
		  if theVert.y > maxY do maxY = theVert.y
		  if theVert.z > maxZ do maxZ = theVert.z
		  if theVert.x < minX do minX = theVert.x
		  if theVert.y < minY do minY = theVert.y
		  if theVert.z < minZ do minZ = theVert.z
		)--end v loop
		delete theMesh --delete the TriMesh value from memory
		--CALCULATE THE GIZMO-ALIGNED BOX SIZE
		case theMap.axis of --take into account axis orientation
		(
		  0: (
			X = maxZ - minZ  --gizmo's Z axis is aligned to the object's local X axis
			Y = maxY - minY
			Z =maxX - minX
		  )
		  1: (
			X = maxX - minX
			Y = maxZ - minZ --gizmo's Z axis is aligned to the object's local Y axis
			Z =maxY - minY
		  )
		  2: (
			X = maxX - minX
			Y = maxY - minY
			Z = maxZ - minZ --gizmo's Z axis is aligned to the object's local Z axis
		  )
		)--end case
		if theVerts.numberset == 0 then --if no vertices processed, set all sizes to 10
		  X = Y = Z = 10
		else --if any vertices are processed, add 0.1 % padding
		(
		  X += 0.001*X
		  Y += 0.001*Y
		  Z += 0.001*Z
		)
		--Set the values for length, width and height in the general case
		theMap.length = Y
		theMap.width = X
		theMap.height= Z
		case theMap.maptype of --now take into account the mapping type
		(
		  default: theMap.width = theMap.length = amax #(X,Y) --get the bigger of the two values for width and length
		  0: () --do nothing for planar mode - will use the above general case
		  1: (
			case theMap.axis of --special axis handling for cylinder!
			(
			  0: (theMap.width = theMap.length = amax #(X,Z); theMap.height = Y)
			  1: (theMap.width = theMap.length = amax #(Y,Z); theMap.height = X)
			  2: (theMap.width = theMap.length = amax #(X,Y); theMap.height = Z)
			)--end axis case
		  )
		  2: theMap.width = theMap.length = theMap.height = amax #(X,Y,Z) --radius from the largest of the 3 values
		  3: theMap.width = theMap.length = theMap.height = amax #(X,Y,Z) --radius from the largest of the 3 values
		  4: () --do nothing for box mode - will use the above general case
		)--end maptype case
		--CALCULATE THE CENTER IN GIZMO SPACE - IT IS THE MIDDLE OF THE BOX'S DIAGONAL
		theCenter = ([maxX,maxY,maxZ] + [minX,minY,minZ])/2.0
		--CONVERT THE CENTER INTO OBJECT SPACE BY MULTIPLYING WITH THE GIZMO TM
		theCenter *= theTM
		--THEN CENTER THE GIZMO
		theTM.row4 = theCenter --set the translation part of the matrix to the new center
		theMap.gizmo.transform = theTM --and assign the matrix back to the gizmo transformation
	)--end function
	
	fn alignUVGizmoToSelectedFaces obj mod_uvw = (
		
		local fsel = polyop.getFaceSelection obj as Array
		if (fsel.count == 0) do return false
		/*local faces_normals = in coordsys obj (polyop.getFaceNormal obj fsel[1]) --get first normal
		for f=2 to fsel.count do faces_normals +=  in coordsys obj (polyop.getFaceNormal obj f) --get rest normals
		local faceNormal = faces_normals / fsel.count*/
		local faceNormal =  in coordsys obj (polyop.getFaceNormal obj fsel[1]) --get first normal
		local worldUpVector = [0,0,1]
		local rightVector	= normalize (cross worldUpVector faceNormal)
		local upVector	= normalize ( cross rightVector faceNormal )
		local theMatrix	= matrix3 rightVector upVector faceNormal [0,0,0]
		modPanel.addModToSelection mod_uvw ui: on -- Add UVW Map Modifier to selection 
		mod_uvw.gizmo.transform = theMatrix
		UVWMapFit obj mod_uvw useSel:#none
	) 
	
	fn getObjectMaterialIDS obj = (
	
		local ids = #{}
		local mesh_obj = snapshotasmesh obj
		for f=1 to mesh_obj.numfaces do ids[getFaceMatID mesh_obj f] = on
		delete mesh_obj
		ids
	)
	
	fn getFacesMaterialIDS obj = (
	
		local ids = #{}
		local mesh_obj = snapshotasmesh obj
		local fsel = getFaceSelection mesh_obj
		for f in fsel do ids[getFaceMatID mesh_obj f] = on
		delete mesh_obj
		ids
	)
	
	fn getMaterialIdFromPoly obj = (
	
		local face_id = undefined
		if subobjectLevel == undefined or subobjectLevel == 0  then ( --whole object
				
			face_id = try (polyop.getFaceMatID obj 1) catch undefined --undefined if index is out of range
		
		) else if subobjectLevel == 4 or subobjectLevel == 5 do ( --selected faces only
		
			local face_index = (polyOp.getFaceSelection obj as Array)[1]	
			if face_index != undefined do face_id = try (polyop.getFaceMatID obj face_index) catch undefined --undefined if index is out of range
		)
		face_id --output
	)
	
	fn setMaterialIdToPoly obj mat_id = (
	
		if subobjectLevel == undefined or subobjectLevel == 0  then ( --whole object
				
			--format "Set Material ID:% to Object:%\n" mat_id obj.name
			local fcount = obj.faces.count
			if fcount != 0 do polyop.setFaceMatID obj #{1..fcount} mat_id
		
		) else if subobjectLevel == 4 or subobjectLevel == 5 do ( --selected faces only
		
			local fsel = polyOp.getFaceSelection obj
			--format "Set Material ID:% to Faces:%\n" mat_id fsel
			polyop.setFaceMatID obj fsel mat_id	
		)
	)
	
	fn getMaterialIdFromSelection objs = (
	
		local mat_id = undefined
		local gco = modPanel.getCurrentObject()
		if classOf gco == Editable_Poly then (
		
			mat_id = getMaterialIdFromPoly objs[1]
			--format "Get Material ID:% from Editable_Poly:%\n" mat_id objs[1].name
			
		) else if classOf gco == Edit_Poly do ( --oi is one or more objects with Edit_Poly modifier
		
			local face_index = (gco.GetSelection #Face as Array)[1]
			if face_index != undefined do mat_id = gco.EditPolyMod.GetFaceMaterial face_index
			--format "Get Material ID:% to Edit_Poly:%\n" mat_id objs.count
		)
		mat_id --output
	)
	
	fn setMaterialIdToSelection objs mat_id = (
	
		local gco = modPanel.getCurrentObject()
		local result = false
		if classOf gco == Editable_Poly then (
		
			setMaterialIdToPoly objs[1] mat_id
			result = true
			
		) else if subobjectLevel == undefined or subobjectLevel == 0  then ( --change material id in whole obj
		
			local mat_mod = Materialmodifier ()
			modPanel.addModToSelection mat_mod ui:on
			mat_mod.materialID = mat_id
			for o in objs do maxOps.CollapseNodeTo o 1 true
			result = true

		) else if classOf gco == Edit_Poly do ( --one or more objects with Edit_Poly modifier
		
			gco.SetOperation #SetMaterial
			gco.MaterialIDtoSet = (mat_id - 1)
			gco.Commit ()
			result = true
		)
		result --output
	)
	
	fn selectFacesByMatID obj mat_ids clearSelection:true = (
	
		local gco = modPanel.getCurrentObject()
		local result = false
		--if clearSelection do mat_ids = #((mat_ids as array)[1]) --REMOVED(dont really need this)
		if classOf gco == Editable_Poly then (
		
			local faces_with_id = #{}
			for id in mat_ids do (
			
				for f = 1 to obj.numfaces where polyop.getFaceMatID obj f == id do faces_with_id += #{f}
			)
			polyop.setFaceSelection obj faces_with_id --set the selection when the loop is done!
			result = true
			
		) else if classOf gco == Edit_Poly do ( --one object with Edit_Poly modifier
	
			local fcount = getnumfaces obj	--             obj.Edit_Poly.GetFaceMaterial f
			local faces_with_id = #{}
			for id in mat_ids do (
			
				for f = 1 to fcount where gco.EditPolyMod.GetFaceMaterial f == id do faces_with_id += #{f}
			)
			gco.EditPolyMod.select #Face (faces_with_id as BitArray)
			result = true
		)
		result --output
	)
	
	fn isValidObject obj = ( --Uvwmap restricted for secure work
	
		(classOf obj == Editable_Poly or classOf obj == PolyMeshObject) and classOf obj.modifiers[1] != Uvwmap 
	)
	
	fn getMaterialType visual_id = (
		
		if  visual_id - 400 > 0 then "havok"
			else if visual_id - 200 > 0 then "noground"
				else "basic"
	)
	
	fn getMaterialTypeIndex visual_id = (
		
		if  visual_id - 400 > 0 then 1
			else if visual_id - 200 > 0 then 3
				else 2
	)
	
	fn getCurrentMaterialType = (

		#("havok", "basic", "noground")[rdo_mat_type.state]
	)
	
	fn getXmlItemByID mat_id = (
	
		local mat_data = for itm in mat_items where itm.id == mat_id do exit with itm 
		if mat_data != undefined then mat_data else mat_data
	)
	
	fn filterItemsByType list mat_type = (
		
		for itm in list where (getMaterialType  itm.tag.value.id == mat_type) collect itm
	)
	
	fn filterItemsByName list mat_name ignoreCase:true = (
		
		--local pat = mat_name + "*"
		for itm in list where (
			
			local itm_name = if ignoreCase then toLower itm.text else itm.text
			findString itm_name mat_name != undefined
			--matchPattern itm_name pattern:pat
		) collect itm
	)
	
	fn markItem itm = (
		
		local hc = (dotnetClass "System.Windows.SystemColors").HighlightColor
		itm.BackColor = drawingColor.fromArgb hc.r hc.g hc.b
	)
	
	fn unmarkItem itm = (
		
		local cc= material_color_types[rdo_mat_type.state]
		itm.BackColor = drawingColor.fromArgb cc.r cc.g cc.b
	)

	fn filterListView lv ignoreCase:true = (
			
		if search_str == ""  and lv.items.count == list_items.count do return OK --nothing changed
		local current_mat_type = getCurrentMaterialType()
		local items_by_type = filterItemsByType list_items current_mat_type
		lv.items.clear()
		if search_str == ""  and lv.items.count < list_items.count do ( --cleared search text
			
			lv.items.addrange items_by_type
			return OK
		)
		local search_str = if ignoreCase then toLower edt_filter_names.text else edt_filter_names.text
		local filtered_list = filterItemsByName items_by_type search_str
		
		if filtered_list.count == 0 do return false -- no matches found
		lv.items.addrange filtered_list --fill list with all  matched items
		lv.items.item[ 0 ].selected = true --select first item
		for i=0 to lv.items.count - 1 do unmarkItem lv.items.item[ i ] --un hilight item
		markItem lv.items.item[ 0 ] --hilight item
	)
	
	fn pickMaterialFromSelection objs = (
	
		if lv_mat_data.items.count == 0 do return false		
		--collect valid objects only
		local valid_objects = for o in objs where (isValidObject o) collect o 	
		if valid_objects.count == 0 do (
			
			messageBox "Object(s) must be Editable Poly or Edit Poly." title:"Aborted:"
			return false
		)
		--pick first face id
		local map_id = getMaterialIdFromSelection valid_objects
		if map_id == undefined do (
		
			messageBox "No faces Selected" title:"Warning"
			return false
		)
		--get item category
		local switch_index = getMaterialTypeIndex map_id
		--switch to category
		rdo_mat_type.state = switch_index
		--fiter data items type
		filterListView lv_mat_data
		--select item from list
		for i = 0 to lv_mat_data.items.count - 1 do (
		
			local itm = lv_mat_data.items.item[i]
			local mat_data = itm.tag.value 
			if mat_data.id == map_id do (
			
				unmarkItem lv_mat_data.selectedItems.item[0] --un hilight item
				itm.selected = true
				markItem lv_mat_data.items.item[ i ] --hilight item
				exit
			)
		)
	)

	fn assignMaterial objs applyMapping:true = (
	
		format "assign material:%\n" objs
		local valid_objects = for o in objs where (isValidObject o) collect o 	
		if valid_objects.count == 0 do (
			
			messageBox "Object(s) must be Editable Poly or Edit Poly." title:"Aborted:"
			return false
		)
		--check for override material on an object which have more than one material.
		if subobjectlevel == undefined or subobjectlevel == 0 do (
		
			local secure_question_override_materials = false
			for obj in valid_objects do (
			
				local material_ids = getObjectMaterialIDS obj --as bitarray
				if material_ids.numberset > 1 then (
				
					secure_question_override_materials = true
					exit
				)
			)
			if secure_question_override_materials do (
			
				if not (QueryBox "Selected Object(s) have more than one Material applied.\nYou are sure to override it? " title:"Overide ?") do return false
			)
		)
		--switch between assing materail from selected item or from clone form first face
		local mat_data = undefined
		-- if chk_assign_clone.checked then (
		
			-- local map_id = getMaterialIdFromSelection selection
			-- if map_id == undefined do (
			
				-- messageBox "No faces Selected" title:"Warning"
				-- return false
			-- )
			-- mat_data = getXmlItemByID map_id
			
		-- ) else (
	
			if lv_mat_data.selectedItems.count == 0 do return false
			local sel_item = lv_mat_data.selectedItems.item[0]	
			mat_data = sel_item.tag.value 
		-- )
		
		local gco = modPanel.getCurrentObject()
		local sublevel = subobjectLevel
		max modify mode
		--set object or faces material ID
		--if not correct terrain material assigned add it to selection
		for obj in valid_objects do (
		
			format "Assign Material:% ID:% SID:% to TILE U:% V:% Objects:%\n" mat_data.key mat_data.id mat_data.sid mat_data.tile_u mat_data.tile_v obj.name 
			if obj.material == undefined or obj.material.name != terrain_mat_name do ( 
				
				if terrain_mat == undefined do (
						
					messageBox "Terrain Material Not Found" title:"Aborted"
					return false
				)
				format "Reassign Material:%  to Obj:%\n" terrain_mat.name obj.name
				--assign terrain material at subobjectLevel 0 (if subobject is not zero material will be instanced with new name)
				local sol = subobjectLevel --first get out of editing mode
				subobjectLevel = 0
				obj.material = terrain_mat
				subobjectLevel = sol --return back to editing mode
			)
		)
		
		setMaterialIdToSelection valid_objects mat_data.id
		
		
		if applyMapping do (
		
			--continute to add mapping
			local map_type = case rdo_mappig_type.state of (1 : 0; 2 : 4)
			local mod_uvw = uvwMap axis:2 maptype:map_type mapChannel:1 realWorldMapSize:false --name:sel_item.key
			if (chk_autoorient.checked and sublevel == 4) then (
				
				if valid_objects.count > 1 or classOf valid_objects[1] != Editable_Poly then (
				
					messageBox "For now Auto Orientation works only in Editable_Poly single Object"
				
				) else (
				
					alignUVGizmoToSelectedFaces valid_objects[1] mod_uvw
				)
				
			)  else (
				
				modPanel.addModToSelection mod_uvw ui: on -- Add UVW Map Modifier to selection 	
			)
			--format "mo w:% h:% name:%\n" mod_uvw.width mod_uvw.length sel_item
			local u_tile = mod_uvw.width *  (mat_data.tile_u / 1000) --default mod_uvw.width * 0.0016
			local v_tile = mod_uvw.length * (mat_data.tile_v / 1000) --default mod_uvw.length * 0.0032
			format "sel tile u:% v:%\n" u_tile v_tile
			mod_uvw.utile = u_tile	--length is in generic units
			mod_uvw.vtile = v_tile	--width is in generic units
--Experimental box mapping
			--local w_tile = mod_uvw.height * (mat_data.tile_v / 1000)
			--if rdo_mappig_type.state == 2 do mod_uvw.wtile = w_tile --if box mapping is applied
			if rdo_mappig_type.state == 2 do mod_uvw.height = if mod_uvw.width > mod_uvw.length then mod_uvw.width else mod_uvw.length --if box mapping is applied
			if spn_mapping_angle.value != 0 do mod_uvw.Gizmo.Rotation = eulerAngles 0 0 spn_mapping_angle.value
			if chk_collapse.checked do (
			
				for o in valid_objects do maxOps.CollapseNodeTo o 1 true
			)
		)
		--if was before with Edit_Poly modifier and now is without, Add it tback.
		if chk_collapse.checked do ( --else is in uvwMap modifier
            
			if classOf gco == Edit_Poly and classOf (modPanel.getCurrentObject()) != Edit_Poly do (
		
				modPanel.addModToSelection (Edit_Poly ()) ui:on
			)
            if sublevel != undefined then subobjectLevel = sublevel else max create mode
        )
	)

--those two maybe replace in future (read direct from material xml?)
	fn getDiffuseMapFromMaterial mat = (

		case (classOf mat) of (

			DirectX_9_Shader 	: if mat.renderMaterial != undefined then mat.renderMaterial.diffuseMap else undefined
			LS3DMaterial		: mat.diffuseMap
			Default				: undefined
		)
	)
	
	fn getBitmapFromDiffuseMap dm = (

		try (dm.bitmap) catch ( --Runtime error: Error opening bitmap: 
			
			format "getBitmapFromDiffuseMap % failed:%.\nPlease go to LS3D/MED/ and Reload Database.\n" dm  (getCurrentException())
			undefined
		)
	)
	
--------------------------------------------------------------------------------------------------------------------------------	
--> PREVIEW MATERIAL
--------------------------------------------------------------------------------------------------------------------------------	
	fn correctPath str = (

		str = substituteString str "\n" "\\n"
		str = substituteString str "\t" "\\t"
		str = substituteString str "/" "\\"
		str = substituteString str "\\\\" "\\"
	) 
	
	/**
	*@Example > 
		node_name >
			D686_DiffuseTextureScale	<-- skip
			T000_DiffuseTexture			<-- OK
			T015_DiffuseTexture1		<-- OK
			T033_DiffuseTexture3		<-- OK
		tex_type > 
			DiffuseTexture
	*/
	fn isNodeType node_name tex_type = (
	
		if findItem restricted_textures node_name != 0 do return false --hotfix(textures which will not be in preview)
		local key_str = (filterString node_name "_")[2] --cut prefix ex: T015_
		--cut last integer
		local num_str = "0123456789"
		if findString num_str key_str[key_str.count] != undefined do (

			key_str = substring key_str 1 (key_str.count-1)
		)
		(toLower key_str) == (toLower tex_type)
	)

	fn isTextureType file_name tex_type = (

		local type = case tex_type of (
		
			"DiffuseTexture"	: "d"
			"NormalTexture"	: "n"
			"Glossiness"		: "g"
		)
		local file_name = getFilenameFile file_name
		local last_letter = file_name[file_name.count]
		--format "isTextureType > file_name:% last_letter:% type:%\n" file_name last_letter type
		toLower last_letter == type
	)

	fn getTexturesFromMaterial mat_xml tex_type = (

		local result = #()
		if not (doesFileExist mat_xml) do (
		
			format "Unable to found XML File:%\n" mat_xml
			return #()
		)
		try (
			local xDoc = XMLDocument()										--Create an XMLDcoument
			xDoc.LoadXML mat_xml												--Load XML from file
			local rNode = xDoc.GetRootNode()									--Get the Root Node THIS MUST BE CALLED!		
			local nParam = rNode.GetChild 3
			
			if (toLower(nParam.GetTag()) != "parameters") do (				--invalid Shader XML (node parameters not found)
			
				format "Node 'parameters' not found. Invalid format. Skipping:% , texture type:%\n" mat_xml tex_type
				return #()
			) 
			
			local nParamChildren = nParam.GetChildren()
			for child in nParamChildren do (
			
				local nName = child.GetChild 0
				if (toLower(nName.GetTag()) != "name") do ( --missing node name , skip
				
					format "Unable to found node 'name'. Invalid Format.Skipping:% , texture type:%\n" mat_xml tex_type
					continue
				)
				local node_name = toLower(nName.GetText())
				--format "Search str:% in NODE:%  found:%\n" tex_type node_name (findString node_name tex_type == undefined)
				if (not (isNodeType node_name tex_type)) do continue
			
				local nValue = child.GetChild 1
				local sValue = toLower (nValue.GetTag())
				local file_name = nValue.GetText()
				
				--format "check fname:%\n" file_name
				
				if (not (isTextureType file_name tex_type)) do continue
				
				if (sValue == "value") do append result file_name
				-- format "Found DIFFUSE:% at NODE:% XML PATH:%\n" (nValue.GetText()) node_name mat_xml	
			)
			
		) catch (
		
			format "Unknown error while reading material XML. Invalid format. Skipping:% , texture type: % Exception:%\n " mat_xml tex_type (getcurrentException())
		)
		result
	)

	fn getTexturesFullPath mat = (

		local ls3d_mat = case (classOf mat) of (
		
			DirectX_9_Shader	: mat.renderMaterial
			LS3DMaterial		: mat
			Default				: undefined
		)
		--format "getTexturesFullPath > mat:%\n" ls3d_mat
		if ls3d_mat == undefined do return #()
		local edit_path = LS3DGUP.LS3DGUP.EnginePath
		local mat_xml = correctPath (edit_path + @"materials\" + ls3d_mat.GetName())
		used_diffuse_textures = getTexturesFromMaterial mat_xml "DiffuseTexture"
		--format "getTexturesFullPath > textures:%\n" used_diffuse_textures
		for n in used_diffuse_textures collect (

			local fpath = ""
			LS3DGUP.LS3DGUP.GetFileVFSFullPath n &fpath
			fpath = correctPath( edit_path + fpath + n )
			if not (doesFileExist fpath) do (
			
				format "Unable found Texture:%\n" fpath
				continue
			)
			-- format "Texture Full Path:%\n" fpath
			fpath
		)
	)

	fn projectTextureToCanvas canvas w h fpath = ( 

		local bt = Bitmaptexture fileName:fpath --get Bitmaptexture from file
		local bb = bitmap w h color:black --create new bitmap
		rendermap bt into:bb size:[bb.width,bb.height] filter:on display:off --render texture resized	
	)

	fn ReverseArray arr = (

		for i=arr.count to 1 by -1 collect arr[i]
	)

	fn previewMaterial mat_id = (
		
		if terrain_mat == undefined do (
					
			messageBox "Terrain Material Not Found" title:"Aborted"
			return false
		)
		local mat = terrain_mat[mat_id]
		local material_textures = getTexturesFullPath mat
		--format "previewMaterial > get textures:%\n" material_textures

		local canvas_w = bmp_preview.width
		local canvas_h = bmp_preview.height
		local combined_bitmap = Bitmap canvas_w canvas_h color:green 	
		
		if material_textures.count == 0 then (
		
			bmp_preview.bitmap = Bitmap canvas_w canvas_h color:green
		
		) else if material_textures.count == 1 then (

			bmp_preview.bitmap = projectTextureToCanvas combined_bitmap canvas_w canvas_h material_textures[1]
			
		) else (

			material_textures = reverseArray material_textures --revetse textures order
			local shift_y = canvas_h / material_textures.count
			current_y = 0
			for fpath in material_textures do (

				local bb = projectTextureToCanvas combined_bitmap canvas_w canvas_h fpath
				pasteBitmap bb combined_bitmap [0,current_y] [0,0] --add bitmap to combined_bitmap
				current_y += shift_y
			)
			--draw break lines between textures
			current_y = 0
			local line_colors = for i = 1 to canvas_w collect yellow
			for i=1 to material_textures.count-1 do (
			
				current_y += shift_y
				setPixels combined_bitmap [0 , current_y] line_colors
			)
			bmp_preview.bitmap = combined_bitmap
		)
	)
	
	fn selectTextureInUnwrap mod_uvw multi_mat mat_id = (

		if mod_uvw == undefined or classOf multi_mat != Multimaterial do return false
		local mat = multi_mat[mat_id]
		local dif_map = getDiffuseMapFromMaterial mat
		if dif_map == undefined do (

			format "Material:% at ID:% Has no DifuseMap.\n" mat.name mat_id
			return false
		)
		local src_bmp = getBitmapFromDiffuseMap dif_map
		if src_bmp == undefined do (

			format "Material:% at ID:% Has no Bitmap.\n" mat.name mat_id
			return false
		)
		local list_index = 0
		for i=1 to mod_uvw.texMapList.count do (

			local trgt_bmp = mod_uvw.texMapList[i]
			if classOf trgt_bmp != Bitmaptexture do continue
			--format "search:% found:%\n" src_bmp.filename trgt_bmp.filename
			if src_bmp.filename == trgt_bmp.filename do (
			
				--format "search:% found:%\n" src_bmp.filename trgt_bmp.filename

				list_index = i
				exit
			)
		)
		--format "list_index:%\n" list_index
		if list_index > 0 do mod_uvw.setCurrentMap (list_index+1)
		--mod_uvw.updateMap() 
	)
	
	fn applyUnwrapUVW = (
		
		--get material ID from Selected Faces
		local map_id = getMaterialIdFromSelection selection
		--else getmaterial Id from Selected Item
		if map_id == undefined do (
		
			if lv_mat_data.selectedItems.count == 0 do return false
			local sel_item = lv_mat_data.selectedItems.item[0]
			local mat_data = sel_item.tag.value
			map_id = mat_data.id
		)
		
		--mod_uvw = $.modifiers[#unwrap_uvw]
		local mod_uvw  = modPanel.getCurrentObject()
		if classOf mod_uvw == Unwrap_UVW then ( -- reopen existing unwrap
		
			mod_uvw.edit()

		) else ( -- add new unwrap
		
			mod_uvw = Unwrap_UVW () 
			modPanel.addModToSelection mod_uvw ui:on
			mod_uvw.edit()	
			selectTextureInUnwrap mod_uvw selection[1].material map_id
		)
	)
	
	fn rotateMappingGizmo angle_val = (
	
		local mod_uvw  = modPanel.getCurrentObject()
		if classOf mod_uvw != Uvwmap do return false
		mod_uvw.Gizmo.Rotation = eulerAngles 0 0 angle_val
	)
	
	
	fn fillListView lv items = (
		
		lv.BeginUpdate()
		lv.items.Clear()
		local all_items = #()
		for itm in items do (
			
			local mat_type = getMaterialType itm.id
			local clr, suffix
			case mat_type of (
				
				"basic": (
				
					clr =	material_color_types[1] 
					suffix = "_B"
				)
				
				"noground":  (
					
					clr =	material_color_types[2] 
					suffix = "_N"
				)
				
				"havok" : (
					
					clr = material_color_types[3]
					suffix = "_H"
				)
			)
			local li = dotNetObject "ListViewItem" (itm.key+suffix)
			li.UseItemStyleForSubItems=true
			li.BackColor= drawingColor.fromArgb clr.r clr.g clr.b
			--format "add item name:% id:% sid:% clr:%\n" itm.key itm.id itm.sid clr
			li.tag = dotnetMxsValue  itm  --DotNet value holding the MAXScript value
			
			li.subitems.add (itm.id as String)
            li.subitems.add (itm.sid as String)
			li.subitems.item[0].name="0"
			li.subitems.item[1].name="1"
			
			append all_items li 
		)
		--format "lv:% items:% all_items:%\n" lv items.count all_items.count
		lv.Items.AddRange all_items
		lv.items.item[ 0 ].selected = true --select first item
		lv.EndUpdate()
		lv.Refresh()
		lv.Update()
		--lv.focus()
		list_items = all_items --copy array all_items --for i = 0 to lv.Items.count-1 collect lv.Items.item[ i ] --recolect list items
		filterListView lv
  	)

	fn  selectSimillarFaces objs = (
		
		format "selectSimillarFaces > :%\n" objs
		if subobjectLevel != 4 and subobjectLevel != 5 do return false
		if objs.count > 1 do (
				
			messageBox "Only One Object can be Selected." title:"Aborted:"
			return false
		)
		local obj = objs[1]	
		if not (isValidObject obj) do (
			
			messageBox "Object(s) must be Editable Poly or Edit Poly." title:"Aborted:"
			return false
		)
		local mat_ids = getFacesMaterialIDS obj
		if mat_ids.numberset == 0 do (
		
			messageBox "No faces Selected" title:"Warning"
			return false
		)
		selectFacesByMatID obj mat_ids --clearSelection:chk_clear_selection.checked --REMOVED(dont really need this)
		completeRedraw()
	)
	
	fn selectFacesGrowByID objs = ( --maybe double click method
		
		-- format "selectFacesGrowByID > :%\n" objs
		if subobjectLevel != 4 and subobjectLevel != 5 do return false
		if objs.count > 1 do (
				
			messageBox "Only One Object can be Selected." title:"Aborted:"
			return false
		)
		local obj = objs[1]	
		-- if not (isValidObject obj) do (
		if classOf obj != Editable_Poly do (
			
			-- messageBox "Object(s) must be Editable Poly or Edit Poly." title:"Aborted:"
			messageBox "Object(s) must be Editable Poly ." title:"Aborted:"
			return false
		)
		local sel_faces = polyOp.getFaceSelection obj
		if sel_faces.numberset == 0 do (
		
			messageBox "No faces Selected" title:"Warning"
			return false
		)
		local face_id = polyOp.getFaceMatID obj (sel_faces as array)[1]
		obj.buttonOp #GrowSelection 
		local grow_faces = polyOp.getFaceSelection obj
		for f in grow_faces where polyOp.getFaceMatID obj f == face_id do appendIfUnique sel_faces f
		polyOp.setFaceSelection obj sel_faces
		--TODO maybe is better collect faces in MESH and then select in Editable_Poly or Edit_Poly
		--getFaceMatID <mesh> <face_index_integer>
		--$.selectByMaterial 421
	)
	
	--MAT_ITEM key:"grass"				id:140		sid:81		tile_u:0.4		tile_v:0.4,
	fn parseXmlTable xml_file = (
		
		if not (doesFileExist xml_file) do return false
		local xDoc = XMLDocument()			--Create an XMLDcoument
		xDoc.LoadXML xml_file		--Load XML from file
		local rNode = xDoc.GetRootNode()		--Get the Root Node THIS MUST BE CALLED!
		local reindex_items = (rNode.GetChildren())[1].GetChildren() --Get All Reindex Keys
		mat_items = for itm in reindex_items collect (
			
			local mat_name = trimRight (itm.GetAttribute "Comment") ".xml"
			local mat_id =  (itm.GetAttribute "VisualMatIndex") as Integer
			local mat_sid =  (itm.GetAttribute "SemanticMatIndex") as Integer
			local mat_tile_u =  (itm.GetAttribute "Tile_U") as Float
			local mat_tile_v =  (itm.GetAttribute "Tile_V") as Float
			MAT_ITEM key:mat_name			id:mat_id		sid:mat_sid		tile_u:mat_tile_u		tile_v:mat_tile_v
		)
		format "Aviable materials:%\n"  mat_items.count
		--print mat_items
		--item.GetAllAttributes()
	)
	
	fn clearItemsFilter = (
		
		edt_filter_names.text = ""
		filterListView lv_mat_data
	)
	
	fn runCommandByName cmd_name = (
		
		format "RUN CMD:%\n" cmd_name
		case cmd_name of (
			
			"Create Curb Custom" : (
			
				if lv_mat_data.selectedItems.count == 0 do return false
				local sel_item = lv_mat_data.selectedItems.item[0]	
				::gLs3dQuickMaterials.createCustomCurb() --sel_item.tag.value.id
			)
			"Create Curb From Edges" : ::gLs3dQuickMaterials.createCurb selection[1] 442 collapsed:true
			"Create Curb From Spline" : ::gLs3dQuickMaterials.createCurb selection[1] 442 customSpline:true
			"Redraw Spline At Zero" : if (queryBox "Redraw Spline?" title:"Warning") do (
			
				 undo "Redraw Spline" on ::gLs3dQuickMaterials.redrawSplineAtZero selection[1]
			)
		)
	)

	fn init = (
		
		--load advanced actions
		if superClassOf gLs3dQuickMaterials != StructDef do fileIn (micra.RootDir + "LS3D_Quick_Materials_Struct.ms")
		--load material library
		loadMateriaLibraries()	
		--materials table from xml
		parseXmlTable xml_materials_table
		--Info materials 
		bmp_mat_type_1.bitmap = bitmap bmp_mat_type_1.width bmp_mat_type_1.height color:material_color_types[1] 
		bmp_mat_type_2.bitmap = bitmap bmp_mat_type_1.width bmp_mat_type_1.height color:material_color_types[2] 
		bmp_mat_type_3.bitmap = bitmap bmp_mat_type_1.width bmp_mat_type_1.height color:material_color_types[3] 
		--Text Box
		edt_filter_names.BackColor = drawingColor.fromArgb winColor.r winColor.g winColor.b
		edt_filter_names.ForeColor = drawingColor.fromArgb textColor.r textColor.g textColor.b
		edt_filter_names.AcceptsTab = false
		edt_filter_names.Multiline = false
		--List View
		local column_names=#("Name", "ID", "SID")
		lv_mat_data.BackColor = drawingColor.fromArgb winColor.r winColor.g winColor.b
		--dot net controls work with the system in-focus and out-focus color schemes.
		-- using of the system menu color as listview backcolor instead of default (or custom).
		--lv_mat_data.BackColor = (dotnetclass "System.Drawing.SystemColors").Menu
		lv_mat_data.ForeColor = drawingColor.fromArgb textColor.r textColor.g textColor.b
		lv_mat_data.MultiSelect = false --Allow for multiple selections.
		lv_mat_data.GridLines=true			--Show lines between the items.
		lv_mat_data.CheckBoxes=false
		lv_mat_data.HideSelection=true
		lv_mat_data.FullRowSelect=true		--Set so full width of listView is selected and not just first column.
		lv_mat_data.LabelEdit = false
		lv_mat_data.LabelWrap = false
		lv_mat_data.sorting = lv_mat_data.sorting.ascending
		lv_mat_data.allowDrop = false
		lv_mat_data.view = lv_mat_data.view.Details
		lv_mat_data.HeaderStyle = lv_mat_data.HeaderStyle.Nonclickable
		lv_mat_data.Columns.add column_names[1] 147
		lv_mat_data.Columns.add column_names[2] 50
		lv_mat_data.Columns.add column_names[3] 50
		--Fill List View
		fillListView lv_mat_data mat_items
		--Focus Text Box
		setFocus edt_filter_names
	)
	
	fn fin = (
	
		::gLs3dQuickMaterials.closeAllComponents()
	
	)
	on mcQuickMaterialsDialog open do init()
	on mcQuickMaterialsDialog close do fin()
	on lv_mat_data ItemSelectionChanged arg do (
		
		local a = lv_mat_data.SelectedItems
		if a.count > 0 do (
			
			--format "sel items:%\n" a.item[0].tag
			--local mat_name = execute  (a.item[0].subitems.item[0].text)
			local mat_id = execute  (a.item[0].subitems.item[1].text)
			--local mat_sid = execute  (a.item[0].subitems.item[2].text)
			previewMaterial mat_id
		)
	)
	on btn_apply_mat pressed do (undo "Assign Material" on  assignMaterial (selection as Array) applyMapping:true)
	on btn_apply_id pressed do (undo "Change Material ID" on  assignMaterial (selection as Array) applyMapping:false)
	on btn_get_sel pressed do (clearItemsFilter(); pickMaterialFromSelection (selection as Array))
	on btn_unwrap pressed do (applyUnwrapUVW())
	on edt_filter_names keyUp arg do (filterListView lv_mat_data)
	on btn_clear_text pressed do (clearItemsFilter())
	on btn_sel_simillar pressed  do (undo "Select Simmilar Faces" on selectSimillarFaces (selection as Array))
	on btn_sel_grow pressed  do (undo "Select Floof Faces" on selectFacesGrowByID (selection as Array))
	on rdo_mat_type changed state do (filterListView lv_mat_data)
	--add event to fix decolor selecrtion on lost focus
	on lv_mat_data GotFocus args  do  ( unmarkItem  lv_mat_data.SelectedItems.item[0] )
	on lv_mat_data LostFocus args do ( markItem  lv_mat_data.SelectedItems.item[0] )
	on spn_mapping_angle changed val do (rotateMappingGizmo val)
	on btn_run_fn pressed do (runCommandByName ddl_fn_list.selected )
)
createDialog mcQuickMaterialsDialog


/*
   private void listView1_MouseClick(object sender, MouseEventArgs e)
    {
        ListView list = sender as ListView;

        for (int i = 0; i < list.Items.Count; i++)
        {
            if (list.Items[i].Bounds.Contains(e.Location) == true)
            {
                list.Items[i].BackColor = Color.Blue; // highlighted item
            }
            else
            {
                list.Items[i].BackColor = SystemColors.Window; // normal item
            }
        }
    }
*/


		/*local guid_Array = #()
		local materialPath = ""
		local edit_path = LS3DGUP.LS3DGUP.EnginePath
		LS3D_GUIDToNumberArray ls3d_mat.materialGUID &guid_Array
		LS3DGUP.LS3DGUP.GetMaterialVFSFullPath guid_Array[1] guid_Array[2] &materialPath
		correctPath (edit_path + materialPath)*/
		
		/*
			local faces_with_id = #{}
			for f = 1 to obj.numfaces where polyop.getFaceMatID obj f == mat_id do append faces_with_id f
			if not clearSelection do = faces_with_id + (polyop.getFaceSelection obj)
			--obj.selectByMaterial faces_with_id clearCurrentSelection:clearSelection
		*/