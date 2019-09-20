
Global rMaterialDataManager
Global gMaterialDataManager
struct sMaterialDataManager (

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
			"uni_color_grey_medium.xml"
		)
			m == undefined or
				classOf m == Missing_Mtl or
					classOf m == Standardmaterial or 
						classOf m == LS3DMaterial and findItem restricted_names (getMaterialXML m) != 0 or
							classOf m == DirectX_9_Shader and classOf m.renderMaterial == Missing_Mtl or 
								findItem restricted_names (getMaterialXML m) != 0 or
									m.name == "none"
	), 
	
	fn replaceMaterial multi_mat new_mat &tabs:"\t" &cnt:0 = ( 
	
		local tab_str = tabs + "\t" --next level
		local mat_name = if multi_mat != undefined then multi_mat.name else "undefined"
		if classOf multi_mat == MultiMaterial then ( --multi material

			format ("%MULTIMATERIAL:% CLASS:%\n") tab_str multi_mat.name (classOf multi_mat)
			for i = 1 to multi_mat.count do (
				
				local mat = multi_mat[i]
				local m_name = if mat != undefined then mat.name else "undefined"
				if classOf mat == MultiMaterial then (
				
					cnt+= 1
					replaceMaterial mat tabs:tab_str cnt:&cnt
					
				) else if isNotAllowedMaterial mat do (
				
					format "%\tREPLACE ID:% MAT:%  CLASS:%\n" tab_str i m_name (classOf mat) 
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
	
	fn listMaterialsOnObjects objs = (
	
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
	)
)
gMaterialDataManager = sMaterialDataManager()

if rMaterialDataManager != undefined do destroyDialog rMaterialDataManager
rollout rMaterialDataManager "Material Data Manager:" width:564 height:780
(
	struct MAT_ITEM (key, id, sid, tile_u, tile_v, mat)
	local drawingColor   = dotNetClass "drawing.color"
	local bgColor   = ((colorMan.getColor #background)*255)as color
	local winColor  = ((colorMan.getColor #window)*255)as color
	local textColor = ((colorMan.getColor #text)*255)as color
	local terrain_mat = undefined
	local picked_mat = undefined
	local mat_items = #()
	local materials_for_save = #()
	local material_color_types = #(color 90 200 200, color 255 136 213, color 173 136 255)
	local terrain_mat_lib_path = (LS3DGUP.LS3DGUP.UtilsPath + @"ground_material\bc_terrain.mat")
	local xml_materials_table = (LS3DGUP.LS3DGUP.UtilsPath + "coll_bourbon_table.xml")
	dotNetControl 'lv_mat_data' "listView" pos:[240,28] width:316 height:680 align:#left
	dotNetControl 'lv_new_mats' "listView" pos:[8,428] width:228 height:244 align:#left
	bitmap 'bmp_preview' "Bitmap" pos:[12,28] width:224 height:224 align:#left
	button 'btn_add_mat' "ADD >" pos:[188,678] width:48 height:28 align:#left
	GroupBox 'grp1' "Setup:" pos:[4,4] width:556 height:712 align:#left
	button 'btn_load_mat_lib' "Load XML" pos:[12,300] width:68 height:28 align:#left
	dropdownList 'ddl_mat_lib' "Mat lib" pos:[12,256] width:224 height:40 align:#left
	button 'btn_save_all' "Save ALL" pos:[168,300] width:68 height:28 align:#left
	button 'btn_get_mat' "Get Material From Selection" pos:[12,396] width:224 height:28 align:#left
	button 'btn_convert_sel' "Convert Selection To New MatLib" pos:[12,364] width:224 height:28 align:#left
	button 'btn_compare_xml_lib' "Compare XML and LIBRARY" pos:[12,332] width:224 height:28 align:#left
	label 'lbl1' "ID:" pos:[8,684] width:20 height:16 align:#left
	label 'lbl9' "SID:" pos:[100,684] width:20 height:16 align:#left
	spinner 'spn_target_id' "" pos:[32,684] width:60 height:16 range:[1,10000,1] type:#integer scale:1 align:#left
	spinner 'spn_target_sid' "" pos:[124,684] width:60 height:16 range:[1,10000,1] type:#integer scale:1 align:#left
	groupBox 'grp2' "Advanced Tools:" pos:[4,720] width:556 height:52 align:#left
	dropDownList 'ddl_fn_list' "" pos:[12,742] width:472 height:21 items:#("Replace Unwanted Materials", "List Materials on Selection") align:#left
	button 'btn_run_fn' "RUN" pos:[488,740] width:64 height:24 align:#left
	--button 'btn_save_mat' "Save Material" pos:[84,300] width:80 height:28 align:#left
	/**
	*@Usage add more material libraries in to Temporary Library
	*@Example
			--load
			semantic_lib_path = (LS3DGUP.LS3DGUP.UtilsPath + "semantic_materials.mat")
			terrain_lib_path = (LS3DGUP.LS3DGUP.UtilsPath + @"ground_material\bc_terrain.mat")
			success = loadMaterialLibraryPlus semantic_lib_path
			success = loadMaterialLibraryPlus terrain_lib_path
			--read
			currentMaterialLibrary.count
			currentMaterialLibrary[1].name
			currentMaterialLibrary[2].name
			--get
			semantic_mat = currentMaterialLibrary["semantic_materials"]
			terrain_mat = currentMaterialLibrary["bc_terrain_main"]
			--save all in one
			all_lib_path = (LS3DGUP.LS3DGUP.UtilsPath + @"ground_material\mat_all.mat")
			saveTempMaterialLibrary currentMaterialLibrary all_lib_path
			loadMaterialLibraryPlus all_lib_path
			--save separate library
			terrain_lib = materialLibrary(currentMaterialLibrary["bc_terrain_main"])
			saveTempMaterialLibrary terrain_lib terrain_lib_path
	*/
	fn loadMaterialLibraryPlus lib_path = ( --

		if not (doesFileExist lib_path) do return false
		local library_materials = for m in currentMaterialLibrary collect m
		local success = loadMaterialLibrary lib_path
		if not success do return false
		local new_lib = currentMaterialLibrary[1]
		for m in library_materials where m.name != new_lib.name do append currentMaterialLibrary m
		true
	)
	
	fn loadMateriaLibraries = (
	
		local semantic_lib_path = (LS3DGUP.LS3DGUP.UtilsPath + "semantic_materials.mat")
		local terrain_lib_path = (LS3DGUP.LS3DGUP.UtilsPath + @"ground_material\bc_terrain.mat")
		local success_s = loadMaterialLibraryPlus semantic_lib_path
		local success_t = loadMaterialLibraryPlus terrain_lib_path
		if success_s do semantic_mat = currentMaterialLibrary["semantic_materials"]
		if success_t do terrain_mat = currentMaterialLibrary["bc_terrain_main"]
		/*
		--terrain_mat = currentMaterialLibrary["bc_terrain_main"] --always get actual version
		if terrain_mat == undefined and doesFileExist terrain_mat_lib_path do (
			
			local result = loadMaterialLibrary terrain_mat_lib_path
			if result do  (
				
				terrain_mat = currentMaterialLibrary["bc_terrain_main"]
				ddl_mat_lib.items = #(terrain_mat.name)	
			)
		)*/
	)
	
	fn getMaterialType visual_id = (
		
		if  visual_id - 400 > 0 then "havok"
			else if visual_id - 200 > 0 then "noground"
				else "basic"
	)
	
	fn getMaterialXML mat = (
	
		case classOf mat of (
		
			DirectX_9_Shader : if mat.renderMaterial != undefined then getMaterialXML mat.renderMaterial else "uni_color_grey.xml"
			LS3DMaterial : filenameFromPath (mat.GetName())
			default : "uni_color_grey.xml"
		)	
	)
	
	fn stretchBitmapTo bm w h = (
		
		local bb= bitmap w h color:black 
		local tx = bitmaptexture bitmap:bm
		rendermap tx into:bb size:[bb.width,bb.height] filter:on display:off	
		bb
	)
	fn getBitmapFrom dm = (

		try (dm.bitmap) catch ( --Runtime error: Error opening bitmap: 
			
			format "getBitmapFrom % failed:%\n" dm  (getCurrentException())
			undefined
		)
	)
	fn previewMaterial mat mat_id = (
		
		if mat == undefined do return false
		local mat = mat[mat_id]
		local bm = case classOf mat of (

			DirectX_9_Shader: (
				
				local m = mat.renderMaterial
				local dm = if classOf m == LS3DMaterial then m.diffuseMap else undefined
				if dm != undefined then getBitmapFrom dm else undefined
			)
			LS3DMaterial: (

				local dm = mat.diffuseMap
				if dm != undefined then dm.bitmap else undefined
			)
			default: undefined
		)
		if classOf bm == BitMap do bmp_preview.bitmap = stretchBitmapTo bm bmp_preview.width bmp_preview.height
	)


	
	fn getMaterialsFromSelection = ( --only single object or single face
		
		local sel = selection as array
		if sel.count > 1 do (
			
			local used_materials = #()
			for o in sel where o.material != undefined do appendIfUnique  used_materials o.material
			return used_materials
		)
		local obj = sel[1]
-- 		format "getMaterialFromSelection > obj:%\n" obj
		if subobjectLevel == 4 or subObjectLevel == 5 then (
			
			if superClassOf obj != GeometryClass do return undefined
			local face_index = (polyop.getFaceSelection obj as Array)[1]
			if face_index == undefined do return undefined
			local mat_id = polyop.getFaceMatID obj face_index
			#(obj.material[mat_id])
			
		) else (
			
			if classOf obj.material == Multimaterial then obj.material else #(obj.material)
		)
	)
	
	fn loadMaterialsFromSelection lv = (
	
		picked_mat = getMaterialsFromSelection()
		local clr = gray
		format "pm:%\n" picked_mats
		
		if picked_mat.count == 0 do return false
			
		lv.BeginUpdate()
		lv.items.Clear()
		
		local all_items = #()
		for i= 1 to picked_mat.count do (
			
			local m = picked_mat[i]
			local xml_name = getMaterialXML m
			format "xml name:%\n" xml_name
			local li = dotNetObject "ListViewItem" xml_name
			li.BackColor= drawingColor.fromArgb clr.r clr.g clr.b
			local itm = m
			li.tag = dotnetMxsValue  itm  --DotNet value holding the MAXScript value*/
			
			li.subitems.add (i as String)
			li.subitems.item[0].name="0"
			append all_items li 
		)
		
		lv.Items.AddRange all_items
		lv.items.item[ 0 ].selected = true --select first item
		lv.EndUpdate()
		lv.Refresh()
		lv.Update()
		lv.focus()
	)

	fn getItemColor mat_id = (
		
		local mat_type = getMaterialType mat_id
		case mat_type of (
			
			"basic": (
			
				clr =	material_color_types[1] 
			)
			
			"noground":  (
				
				clr =	material_color_types[2] 
			)
			
			"havok" : (
				
				clr = material_color_types[3]
			)
		)
	)
	
	fn sortMatDataList = (
		
		local lv = lv_mat_data
		local all_items = for i= 0 to lv.items.count - 1 collect lv.items.item[i]
		fn compareFN a b = (

			local id_a = execute  (a.subitems.item[1].text)
			local id_b = execute  (b.subitems.item[1].text)
			case of (
				(id_a < id_b ): -1
				(id_a > id_b ): 1
				default: 0
			)
		)
		qsort all_items compareFN
		lv.BeginUpdate()
		lv.items.Clear()
		lv.Items.AddRange all_items
		lv.items.item[ 0 ].selected = true --select first item
		lv.EndUpdate()
		lv.Refresh()
		lv.Update()
		lv.focus()
	)
	
	/*fn selectMatDataListItemByID mat_id = (
		
		local lv = lv_mat_data
		if  lv.items.count  == 0 do return false
		local item_index = for i= 0 to lv.items.count - 1 where (
			
			local itm = lv.items.item[i]	
			local id = execute  (itm.subitems.item[1].text)
			format "compare ids a:% b:%\n" id  mat_id
			id == mat_id
		) do exit with i
		format "itm index:%\n" item_index
	)*/
	
	fn alreadyTeakenID mat_id = (
		
		local lv = lv_mat_data
		if  lv.items.count  == 0 do return false
		local item_index = for i= 0 to lv.items.count - 1 where (
			
			local itm = lv.items.item[i]	
			local id = execute  (itm.subitems.item[1].text)
			id == mat_id
		) do return true
		false
	)
	
	fn fillListView lv items = (
		
		if items == undefined do return false
		lv.BeginUpdate()
		lv.items.Clear()
		local all_items = #()
		for itm in items do (
			
			local clr = getItemColor itm.id
			local li = dotNetObject "ListViewItem" itm.key
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
		lv.focus()
		list_items = all_items --copy array all_items --for i = 0 to lv.Items.count-1 collect lv.Items.item[ i ] --recolect list items
	)
	
	fn parseXmlTable xml_file = (
		
		if not (doesFileExist xml_materials_table) do return false
		local xDoc = XMLDocument()			--Create an XMLDcoument
		xDoc.LoadXML xml_materials_table		--Load XML from file
		local rNode = xDoc.GetRootNode()		--Get the Root Node THIS MUST BE CALLED!
		local reindex_items = (rNode.GetChildren())[1].GetChildren() --Get All Reindex Keys
		mat_items = for itm in reindex_items collect (
			
			local mat_name = itm.GetAttribute "Comment"
			local mat_id = execute (itm.GetAttribute "VisualMatIndex")
			local mat_sid = execute (itm.GetAttribute "SemanticMatIndex")
			local mat_tile_u = execute (itm.GetAttribute "Tile_U")
			local mat_tile_v = execute (itm.GetAttribute "Tile_V")
			MAT_ITEM key:mat_name			id:mat_id		sid:mat_sid		tile_u:mat_tile_u		tile_v:mat_tile_v
		)
		format "Aviable XML materials:%\n"  mat_items.count
		--print mat_items
		--item.GetAllAttributes()
	)
	
	fn compareXmlLib = (
		
		--format "MatLib\n"
		local mat_data = #()
		for i = 1 to terrain_mat.materialList.count do (
			
			if terrain_mat.materialList[i] == undefined do continue
			local mat =  terrain_mat.materialList[i]
			local xml_name = getMaterialXML mat
			local mat_id = terrain_mat.materialIDList [i]  as String
			--format "% %\n" mat_id  xml_name
			append mat_data (mat_id+" "+ xml_name)
		)
		--format "List\n"
		local xml_data = #()
		for i= 0 to lv_mat_data.items.count - 1 do (
			
			local itm = lv_mat_data.items.item[i]
			local xml_name = itm.text
			local mat_id = itm.tag.value.id  as String
			--format "% %\n" mat_id  xml_name 
			append xml_data (mat_id +" "+ xml_name)
		)
		format "XML ( % ) MAT ( % )\n" xml_data.count mat_data.count
		for i = 1 to xml_data.count do (
			
			local xml_itm = xml_data[i]
			local mat_itm = mat_data[i]
			local status = if xml_itm == mat_itm then "OK" else ("FAILED compare xml:" + xml_itm)
			format "Check:% 	MAT: %\n" status mat_itm 
		)
	)
	
	fn addNewMaterial = (
		
		if lv_mat_data.items.count == 0 or  lv_new_mats.items.count == 0 do return false
		--colect selected item data
		local selected_items = lv_new_mats.SelectedItems
		if selected_items.count == 0 do return false
		local first_item = selected_items.item[ 0 ]
		local mat = first_item.tag.value
		local xml_name = first_item.text
		local target_id = spn_target_id.value
		local target_sid = spn_target_sid.value
		--check if id is empty
		if alreadyTeakenID target_id do (
			
			messageBox ("This ID [ "+target_id as string+" ] is already teaken. Try different one.") title:"Aborted"
			return false
		)
		format "addNewMaterial > xml:% TO > id:% sid:%\n" xml_name target_id  target_sid
		--remove selected item
		first_item.remove()
		--rename material 
		mat.name = xml_name
		--add item to lv_mat_data
		local clr = getItemColor target_id
		local li = dotNetObject "ListViewItem" xml_name
		li.UseItemStyleForSubItems=true
		li.BackColor= drawingColor.fromArgb clr.r clr.g clr.b
		--format "add item name:% id:% sid:% clr:%\n" itm.key itm.id itm.sid clr
		local itm = MAT_ITEM key:xml_name id:target_id sid:target_sid tile_u:1  tile_v:1
		li.tag = dotnetMxsValue  itm  --DotNet value holding the MAXScript value
		li.subitems.add (target_id as String)
		li.subitems.add (target_sid as String)
		li.subitems.item[0].name="0"
		li.subitems.item[1].name="1"
		
		lv_mat_data.BeginUpdate()
		lv_mat_data.Items.Add li
		lv_mat_data.EndUpdate()
		lv_mat_data.Refresh()
		lv_mat_data.Update()
		lv_mat_data.focus()
		sortMatDataList()
		
		li.selected = true
		--store material and id for later save
	
		append materials_for_save (MAT_ITEM key:xml_name id:target_id sid:target_sid tile_u:1 tile_v:1 mat:mat)
		--for m in materials_for_save do format "new materials:%\n" m.key
		--picked_mat
	)
	
	-- Function AddRowToXML adds new row with item values to xml
	fn AddRowToXML xDoc nodeParent actChildIndex item newNodeInsertMethod:#FIRST_NODE = 
	(
		newChild = xDoc.GetNewNode "Reindex"
		newChild.AddAttribute "VisualMatIndex" item.id as string
		newChild.AddAttribute "SemanticMatIndex" item.sid as string
		newChild.AddAttribute "Comment" item.key
		newChild.AddAttribute "Tile_U" item.tile_u as string
		newChild.AddAttribute "Tile_V" item.tile_v as string
		
		format "-------------------\n UVTILE: %, %\n--------------------------\n" item.tile_u item.tile_v
		
		if newNodeInsertMethod == #FIRST_NODE then 
		(
			nodeParent.DotNetNode.AppendChild newChild.DotNetNode				
		)
		
		if newNodeInsertMethod == #INSERT_BEFORE then 
		(
			nodeParent.DotNetNode.InsertBefore newChild.DotNetNode actChildIndex.DotNetNode		
		)
		
		if newNodeInsertMethod == #INSERT_AFTER then 
		(
			nodeParent.DotNetNode.InsertAfter newChild.DotNetNode actChildIndex.DotNetNode
		)
	)

	
	fn removeNewItemFromXML itm = (
		
		local xDoc = XMLDocument()
		xDoc.LoadXML xml_materials_table
		local rNode = xDoc.GetRootNode()
		local nMaterials = rNode.GetChild 0	
		local nMatChildren = nMaterials.GetChildren()
		local childrenCount = nMatChildren.Count
		
		if childrenCount > 0 then	(
			
			for childIndex = 1 to childrenCount do (
				
				local activeChild = nMatChildren[childIndex]
				local visualMatIndex = activeChild.GetAttribute "VisualMatIndex" as Integer
				
				if itm.id == visualMatIndex do (
							
					--format "remove id:% node:%\n" itm.id activeChild
					nMaterials.DotNetNode.RemoveChild activeChild.DotNetNode
					exit			
				)
			)
		)
		format "Node: % removed ID: % \n ------------------------------- \n" itm.key itm.id
		xDoc.SaveXML()
		true
	)
	
	fn addNewItemToXML itm = (
		
		local xDoc = XMLDocument()
		xDoc.LoadXML xml_materials_table
		local rNode = xDoc.GetRootNode()
		
		local nMaterials = rNode.GetChild 0	
		local nMatChildren = nMaterials.GetChildren()
		local childrenCount = nMatChildren.Count
		
		local activeChild = undefined
		local insertMethod = #NOT_INSERT
		
		if childrenCount > 0 then	(
			
			for childIndex = 1 to childrenCount do
			(
				activeChild = nMatChildren[childIndex]
				local visualMatIndex = activeChild.GetAttribute "VisualMatIndex" as Integer
				
				if itm.id == visualMatIndex do (
					format "Skip... item :% with id :%. Already exists.\n" itm.key itm.id
					return false				
				)
				
				-- Material node wasnt found and this index is higher  -> add before this node
				if itm.id < visualMatIndex then
				(
					insertMethod = #INSERT_BEFORE
					exit
				)
				
				-- Material node not found in all children, will append to end
				if childIndex == childrenCount then insertMethod = #INSERT_AFTER
			)
		)
		else	-- no children in XML, add children on first position
		(
			insertMethod = #FIRST_NODE
		)
		
		AddRowToXML xDoc nMaterials activeChild itm newNodeInsertMethod:insertMethod
		
		format "Node % inserted: % \n ------------------------------- \n" itm.key insertMethod

		xDoc.SaveXML()
		true
	)

	fn saveMatLib = (saveMaterialLibrary terrain_mat_lib_path; format "Mat Lib [ % ] are Saved.\n" terrain_mat_lib_path)
	fn saveMaterialAndXML = (
		
		if materials_for_save.count == 0 do (
			
			messageBox "Nothing to save." title:"Aborted"
			return false
		)
		--add new materials to LIBRARY and xml items to XML
		for item in materials_for_save do (
			
			terrain_mat[item.id] = item.mat	
			addNewItemToXML item
		)
		--save mat lib
		saveMaterialLibrary terrain_mat_lib_path
		--clear variable
		materials_for_save = #()
	)
	
	fn deleteSelectedMaterialAndXML s a = (
		
				
		local first_item = s.SelectedItems.item[0]
		if first_item == undefined do return false
		local item_data = first_item.tag.value
		if not (queryBox ("You are sure to delete Material \n[ "+ first_item.text +" ] ?") title:"Delete:") do return false
		local mat = terrain_mat[item_data.id]
		format "remove item:% id:% mat:%\n" first_item.text item_data.id mat
		terrain_mat[item_data.id] = undefined
		removeNewItemFromXML item_data
		saveMaterialLibrary terrain_mat_lib_path
	)
	
	fn runCommandByName cmd_name = (
		
		format "RUN CMD:%\n" cmd_name
		case cmd_name of (
			
			"Replace Unwanted Materials" : gMaterialDataManager.replaceMaterialsOnObjects selection
			"List Materials on Selection" : gMaterialDataManager.listMaterialsOnObjects selection
		)
	)
	
	fn init = (
		
		--load materials in to list
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
		--lv_mat_data.sorting = lv_mat_data.sorting.ascending
		lv_mat_data.allowDrop = false
		lv_mat_data.view = lv_mat_data.view.Details
		lv_mat_data.HeaderStyle = lv_mat_data.HeaderStyle.Nonclickable
		lv_mat_data.Columns.add column_names[1] 212
		lv_mat_data.Columns.add column_names[2] 50
		lv_mat_data.Columns.add column_names[3] 50
		
		--picked materials
		column_names=#("Name", "ID")
		lv_new_mats.BackColor = drawingColor.fromArgb winColor.r winColor.g winColor.b
		lv_new_mats.ForeColor = drawingColor.fromArgb textColor.r textColor.g textColor.b
		lv_new_mats.MultiSelect = false --Allow for multiple selections.
		lv_new_mats.GridLines=true			--Show lines between the items.
		lv_new_mats.CheckBoxes=false
		lv_new_mats.HideSelection=true
		lv_new_mats.FullRowSelect=true		--Set so full width of listView is selected and not just first column.
		lv_new_mats.LabelEdit = false
		lv_new_mats.LabelWrap = false
		--lv_new_mats.sorting = lv_new_mats.sorting.ascending
		lv_new_mats.allowDrop = false
		lv_new_mats.view = lv_new_mats.view.Details
		lv_new_mats.HeaderStyle = lv_new_mats.HeaderStyle.Nonclickable
		lv_new_mats.Columns.add column_names[1] 173
		lv_new_mats.Columns.add column_names[2] 50
	)
	on btn_add_mat pressed do (addNewMaterial())
	on btn_load_mat_lib pressed do (
		
		--load material library
		loadMateriaLibraries()	
		--materials table from xml
		parseXmlTable xml_materials_table
		fillListView lv_mat_data mat_items
	)
	on ddl_mat_lib selected sel do
	(
		
	)
	on btn_save_all pressed do (saveMaterialAndXML())
	--on btn_delete_mat pressed do (deleteSelectedMaterialAndXML())
	on btn_get_mat pressed do (loadMaterialsFromSelection lv_new_mats)
	on btn_convert_sel pressed do
	(
		
	)
	on lv_mat_data ItemSelectionChanged arg do (
		
		local a = lv_mat_data.SelectedItems
		if a.count > 0 do (
			
			local item = a.item[0]
			format "selected item:% id:% sid:%\n" item.text item.tag.value.id item.tag.value.sid
			local mat_id = execute  (item.subitems.item[1].text)
			previewMaterial terrain_mat mat_id
		)
	)
	
	on lv_mat_data DoubleClick s a do (deleteSelectedMaterialAndXML s a)
	
	on lv_new_mats DoubleClick s a do (

		if s.items.count == 0 do return false
		local first_item = s.SelectedItems.item[0]
		if first_item != undefined do (
			first_item.remove()
			if s.items.count > 0 do  s.items.item[0].selected = true
		)
	)
	
	on lv_new_mats ItemSelectionChanged arg do (
		
		local a = lv_new_mats.SelectedItems
		if a.count > 0 do (
			
			local mat_id = execute  (a.item[0].subitems.item[1].text)
			previewMaterial picked_mat mat_id
		)
	)
	on btn_compare_xml_lib pressed do (compareXmlLib())
	on btn_save_mat pressed do (saveMatLib())
	on rMaterialDataManager open do init()
	on btn_run_fn pressed do (runCommandByName ddl_fn_list.selected )
)
if classOf LS3DGUP == GlobalUtilityPlugin then (

	createDialog rMaterialDataManager
	
) else (
	
	messageBox "LS3DGUP Plugin is not Initialized" title:"aborted"
	
)


/*
loadMaterialLibrary <filename_string> 
saveMaterialLibrary <filename_string> 
getMatLibFileName() 
for mat in sceneMaterials do (

	local matlib = materialLibrary mat
	local filepath = @"C:\matlibs" + "\\" + mat.name + ".mat"
	saveTempMaterialLibrary matlib filepath
)

fn getMaterialFromSelection obj =(

)

fn addMateialToMatLib mat_lib 
*/