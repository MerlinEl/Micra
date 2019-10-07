
Global rMaterialDataManager
Global mcLS3DMaterialManagerStruct
Global mcLS3DMaterialManagerRun

if rMaterialDataManager != undefined do destroyDialog rMaterialDataManager
rollout rMaterialDataManager "LS3D Material Manager: ( No Spawn: 1 - 200 | No Entry: 201 - 400 | Spawn NPC: 401 - 600 )" width:700 height:780
(
	struct MAT_ITEM (key, id, sid, tile_u, tile_v, mat, opt_id) --, fn clone = ()
	local script_dir = getfileNamePath (getSourceFileName())
	local drawingColor   = dotNetClass "drawing.color"
	local bgColor   = ((colorMan.getColor #background)*255)as color
	local winColor  = ((colorMan.getColor #window)*255)as color
	local textColor = ((colorMan.getColor #text)*255)as color
	local terrain_mat = undefined
	local semantic_mat = undefined
	local picked_mat = undefined
	local mat_items = #()
	local materials_for_save = #()
	local material_color_types = #(color 90 200 200, color 255 136 213, color 173 136 255)
	local terrain_mat_lib_path = (LS3DGUP.LS3DGUP.UtilsPath + @"ground_material\bc_terrain.mat")
	local xml_materials_table = (LS3DGUP.LS3DGUP.UtilsPath + "coll_bourbon_table.xml")
	local rcmenu_xml = dotNetObject "System.Windows.Forms.ContextMenuStrip"
	dotNetControl 'lv_xml_data' "listView" pos:[240,28] width:448 height:680 align:#left
	dotNetControl 'lv_new_mats' "listView" pos:[8,428] width:228 height:244 align:#left
	bitmap 'bmp_preview' "Bitmap" pos:[12,28] width:224 height:224 align:#left
	button 'btn_add_mat' "ADD >" pos:[188,678] width:48 height:28 align:#left
	GroupBox 'grp1' "Setup:" pos:[4,4] width:692 height:712 align:#left
	button 'btn_load_mat_lib' "Load XML" pos:[12,300] width:68 height:28 align:#left toolTip:"Load ( XML ) materials data."
	dropdownList 'ddl_mat_lib' "Mat lib" pos:[12,256] width:224 height:40 items:#("bc_terrain.mat") align:#left
	button 'btn_save_all' "Save ALL" pos:[168,300] width:68 height:28 align:#left toolTip:"Save ( XML & LIB ) Only new added Materials."
	button 'btn_get_mat' "Get Material From Selection" pos:[12,396] width:224 height:28 align:#left
	-- button 'btn_convert_sel' "Convert Selection To New MatLib" pos:[12,364] width:224 height:28 align:#left
	button 'btn_compare_xml_lib' "Compare XML and LIBRARY" pos:[12,332] width:224 height:28 align:#left
	label 'lbl1' "ID:" pos:[8,684] width:20 height:16 align:#left
	label 'lbl9' "SID:" pos:[100,684] width:20 height:16 align:#left
	spinner 'spn_target_id' "" pos:[32,684] width:60 height:16 range:[1,10000,1] type:#integer scale:1 align:#left
	spinner 'spn_target_sid' "" pos:[124,684] width:60 height:16 range:[1,10000,1] type:#integer scale:1 align:#left
	GroupBox 'grp2' "Advanced Tools:" pos:[4,720] width:692 height:52 align:#left
	button 'btn_run_fn' "RUN" pos:[624,740] width:64 height:24 align:#left
	-- button 'btn_save_mat' "Save Material" pos:[84,300] width:80 height:28 align:#left
	dropdownList 'ddl_fn_list' "" pos:[12,742] width:608 height:21 items:#(
		
		"Semantic Materials Table",
		"Replace Unwanted Materials", 
		"List Materials on Selection", 
		"Print Used Materials", 	
		"Select Objects With Bc Material"
	)
	
	
	fn loadMateriaLibraries = (
	
		--get materials
		semantic_mat = currentMaterialLibrary["semantic_materials"]
		terrain_mat = currentMaterialLibrary["bc_terrain_main"]
	
		if semantic_mat == undefined or terrain_mat == undefined do ( --if materials not found reload them
	
			--load latest materials
			local semantic_lib_path = (LS3DGUP.LS3DGUP.UtilsPath + "semantic_materials.mat")
			local terrain_lib_path = (LS3DGUP.LS3DGUP.UtilsPath + @"ground_material\bc_terrain.mat")
			::mcLS3DMaterialManagerStruct.loadMaterialsToLibrary #(semantic_lib_path, terrain_lib_path)
			--define variables
			semantic_mat = currentMaterialLibrary["semantic_materials"]
			terrain_mat = currentMaterialLibrary["bc_terrain_main"]
		
		)
		
		--replace materials in Material Editor
		meditMaterials[1] = terrain_mat
		meditMaterials[2] = semantic_mat
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
		if classOf bm == BitMap then (
		
			bmp_preview.bitmap = stretchBitmapTo bm bmp_preview.width bmp_preview.height
			
		) else ( --if bitmap not found show green color in preview
		
			bmp_preview.bitmap = Bitmap bmp_preview.width bmp_preview.height color:green
		)
	)


	
	fn getMaterialsFromSelection = ( --only single object or single face
		
		local sel = selection as array
		if sel.count > 1 do ( --multi selection
			
			local used_materials = #()
			for o in sel where o.material != undefined do appendIfUnique used_materials o.material
			local all_mats = #()
			for mat in used_materials do (
				
				if classOf mat == MultimaTerial then (
				
					for m in mat do append all_mats m
				) else (
				
					append all_mats mat
				)
			)
			return all_mats
		)
		local obj = sel[1]
-- 		format "getMaterialFromSelection > obj:%\n" obj
		if subobjectLevel == 4 or subObjectLevel == 5 then (
			
			if superClassOf obj != GeometryClass do return undefined
			local face_index = (polyop.getFaceSelection obj as Array)[1]
			if face_index == undefined do return undefined
			local mat_id = polyop.getFaceMatID obj face_index
			#(obj.material[mat_id])
			
		) else ( --single selection
			
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
		local unique_names = #()
		for i= 1 to picked_mat.count do (
			
			local m = picked_mat[i]
			local xml_name = getMaterialXML m
			if xml_name == "uni_color_grey.xml" do continue --skip default material
			format "xml name:%\n" xml_name
			
			if findItem unique_names xml_name != 0 do continue --add only unique materials
			append unique_names xml_name
			
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
		
		local mat_type = mcLS3DMaterialManagerStruct.getMaterialType mat_id
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
		
		local lv = lv_xml_data
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
		
		local lv = lv_xml_data
		if  lv.items.count  == 0 do return false
		local item_index = for i= 0 to lv.items.count - 1 where (
			
			local itm = lv.items.item[i]	
			local id = execute  (itm.subitems.item[1].text)
			format "compare ids a:% b:%\n" id  mat_id
			id == mat_id
		) do exit with i
		format "itm index:%\n" item_index
	)*/
	fn getRservedSlotsFromID visual_id = (
	
		if  visual_id - 400 > 0 then (
		
			#(visual_id - 200, visual_id - 400 , visual_id)
			
		) else if visual_id - 200 > 0 then (
		
			#(visual_id - 200, visual_id, visual_id + 200)
			
		) else (
				
			#(visual_id, visual_id + 200, visual_id + 400)
		)
	)
	
	fn alreadyTeakenID mat_id = (
		
		local lv = lv_xml_data
		if  lv.items.count  == 0 do return false
		local mat_id_set = getRservedSlotsFromID mat_id
		local item_index = for i= 0 to lv.items.count - 1 where (
			
			local itm = lv.items.item[i]	
			local id = execute  (itm.subitems.item[1].text)
			findItem mat_id_set id != 0
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
			
			local reserved_slots = getRservedSlotsFromID itm.id
			itm.opt_id = reserved_slots
			li.tag = dotnetMxsValue itm  --DotNet value holding the MAXScript value
			
			li.subitems.add (itm.id as String)
            li.subitems.add (itm.sid as String)
			
			-- format "Add Item:% id:% sid:% reserved:%\n" itm.key itm.id itm.sid reserved_slots
			li.subitems.add (reserved_slots as String)
			li.subitems.item[0].name="0"
			li.subitems.item[1].name="1"
			li.subitems.item[2].name="2"
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
		for i= 0 to lv_xml_data.items.count - 1 do (
			
			local itm = lv_xml_data.items.item[i]
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
		
		if lv_xml_data.items.count == 0 or  lv_new_mats.items.count == 0 do return false
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
		--add item to lv_xml_data
		local clr = getItemColor target_id
		local li = dotNetObject "ListViewItem" xml_name
		li.UseItemStyleForSubItems=true
		li.BackColor= drawingColor.fromArgb clr.r clr.g clr.b
		--format "add item name:% id:% sid:% clr:%\n" itm.key itm.id itm.sid clr
		local reserved_slots = getRservedSlotsFromID target_id
		local itm = MAT_ITEM key:xml_name id:target_id sid:target_sid tile_u:1 tile_v:1 opt_id:reserved_slots
		li.tag = dotnetMxsValue itm  --DotNet value holding the MAXScript value
		li.subitems.add (target_id as String)
		li.subitems.add (target_sid as String)
		li.subitems.add (reserved_slots as String)
		li.subitems.item[0].name="0"
		li.subitems.item[1].name="1"
		li.subitems.item[2].name="2"
		
		lv_xml_data.BeginUpdate()
		lv_xml_data.Items.Add li
		lv_xml_data.EndUpdate()
		lv_xml_data.Refresh()
		lv_xml_data.Update()
		lv_xml_data.focus()
		sortMatDataList()
		
		li.selected = true
		--store ID and MATERIAL for later save
		append materials_for_save (MAT_ITEM key:xml_name id:target_id sid:target_sid tile_u:1 tile_v:1 mat:mat)
		--for m in materials_for_save do format "new materials:%\n" m.key
		--picked_mat
	)
	

	fn saveMatLib = (
		
		::mcLS3DMaterialManagerStruct.saveMaterialFromLibrary terrain_mat_lib_path "bc_terrain_main" 
	)

	fn saveMaterialAndXML = (
		
		if materials_for_save.count == 0 do (
			
			messageBox "Nothing to save." title:"Aborted"
			return false
		)
		--open files for edit
		::mcLS3DMaterialManagerStruct.openFilesForEdit()
		
		--add new materials to LIBRARY and xml items to XML
		for item in materials_for_save do (
			
			terrain_mat[item.id] = item.mat	
			mcLS3DMaterialManagerStruct.addNewItemToXML item
		)
		--save mat lib
		saveMatLib()
		--clear variable
		materials_for_save = #()
	)
	
	fn deleteSelectedItemsFromXmlAndLib = (
			
		local del_count = lv_xml_data.SelectedItems.count
		if del_count == 0 do return false
		if not (queryBox ("You are sure to delete (  " + del_count as String + " ) Materials?") title:"Delete?") do return false
		for i = 0 to del_count - 1 do (
		
			local next_item = lv_xml_data.SelectedItems.item[i] 
			local item_data = next_item.tag.value
			local mat = terrain_mat[item_data.id]
			format "Removed item:% id:% mat:%\n" next_item.text item_data.id mat.name
			terrain_mat[item_data.id] = undefined
			mcLS3DMaterialManagerStruct.removeNewItemFromXML item_data
			saveMaterialLibrary terrain_mat_lib_path
		)
		format "Deleted ( % ) items from ( XML & LIB )\n" del_count
	)
	
	fn editSelectedItemXML = (
	
		local sel_items = lv_xml_data.SelectedItems
		if sel_items.count != 1 do return false
		local item_name = sel_items.item[0].text
		local item_rect = sel_items.item[0].bounds
		-- local list_rect = lv_xml_data.bounds --pos:[240,28] --not works
		local dia_pos = getDialogPos rMaterialDataManager
		local cursor_pos = [dia_pos.x + 250 + item_rect.x, dia_pos.y + 80 + item_rect.y]
		mcLS3DMaterialManagerStruct.editMaterialItem item_name cursor_pos
	)

	fn runCommandByName cmd_name = (
		
		format "RUN CMD:%\n" cmd_name
		case cmd_name of (
			
			"Replace Unwanted Materials" : mcLS3DMaterialManagerRun.replaceMaterialsOnObjects selection
			"List Materials on Selection" : mcLS3DMaterialManagerRun.listMaterialsFromObjects selection
			"Print Used Materials" : mcLS3DMaterialManagerRun.printUsedMaterials selection
			"Select Objects With Bc Material" : mcLS3DMaterialManagerRun.selectObjectsWithBcMaterial selection
			"Semantic Materials Table" : mcLS3DMaterialManagerRun.openSementicMaterialTable()
		)
	)
	
	fn copySelectedItemsNames = (
	
		local sel_items = lv_xml_data.SelectedItems
		local selected_items_names = ""
		for i = 0 to sel_items.count - 1 do selected_items_names += sel_items.item[i].text  + "\n"
		setclipboardText selected_items_names
	)
	
	fn copySelectedItemsToCategory = (
	
		local sel_items = lv_xml_data.SelectedItems
		if sel_items.count == 0 do return false
		format "sel items:%\n" sel_items.count
		local items_data = for i = 0 to sel_items.count - 1 collect sel_items.item[i].tag.value
		--check if all selected items is in same set
		local current_set = mcLS3DMaterialManagerStruct.getMaterialType items_data[1].id
		local incorrect_items = for item in items_data where (
		
			mcLS3DMaterialManagerStruct.getMaterialType item.id != current_set 
			
		) collect 1
	
		if incorrect_items.count != 0 do (
		
			messageBox "Selected items must be in same category." title:"Aborted:"
			return false
		)
		--copy items in to new id set
		mcLS3DMaterialManagerStruct.copyMaterialItemsTo current_set items_data mat_items
	)
	
	fn rcMenuXmlHandler s a = (
    
        format "lbxMatLib rcMenuHandler > s:%  cmd:%\n" s  s.text
        case s.text of (
        
            "Edit": editSelectedItemXML()
            "Delete": deleteSelectedItemsFromXmlAndLib()
            "Copy Name(s)" : copySelectedItemsNames()
			"Copy To": copySelectedItemsToCategory()
        )
    )
	
	fn showXmlMenu s a = (
	
		if a.button == a.button.right do(
		
			local cursor = dotnetclass "System.Windows.Forms.Cursor"
			local mPt = cursor.Position
			rcmenu_xml.Show mPt.x (mPt.y+5)
		)
	)
	
	fn initXmlMenu = (     

		local itemsArr = #("Edit", "Delete", "Copy To", "Copy Name(s)") --, "Convert or Expand to others mat types"
		for i = 1 to itemsArr.count do (
		
			local itm = dotNetObject "System.Windows.Forms.ToolStripMenuItem" itemsArr[i]
			rcmenu_xml.Items.Add(itm)
			dotnet.addEventHandler rcmenu_xml.Items.item[i-1] "Click" rcMenuXmlHandler
			dotNet.setLifetimeControl itm #dotnet; -- stop gc() deleting the event handlers	
		)
	)
	
	fn init = (
		
		--load structures
		if superClassOf ::mcLS3DMaterialManagerStruct != StructDef do fileIn (script_dir + "LS3D_Material_Manager_Struct.ms")
		--load material library
		loadMateriaLibraries()		
		--load materials in to list
		local column_names=#("Material Name", "ID", "SID", "RESERVED SLOTS")
		lv_xml_data.BackColor = drawingColor.fromArgb winColor.r winColor.g winColor.b
		--dot net controls work with the system in-focus and out-focus color schemes.
		-- using of the system menu color as listview backcolor instead of default (or custom).
		--lv_xml_data.BackColor = (dotnetclass "System.Drawing.SystemColors").Menu
		lv_xml_data.ForeColor = drawingColor.fromArgb textColor.r textColor.g textColor.b
		lv_xml_data.MultiSelect = true
		lv_xml_data.GridLines=true			--Show lines between the items.
		lv_xml_data.CheckBoxes=false
		lv_xml_data.HideSelection=true
		lv_xml_data.FullRowSelect=true		--Set so full width of listView is selected and not just first column.
		lv_xml_data.LabelEdit = false
		lv_xml_data.LabelWrap = false
		--lv_xml_data.sorting = lv_xml_data.sorting.ascending
		lv_xml_data.allowDrop = false
		lv_xml_data.view = lv_xml_data.view.Details
		lv_xml_data.HeaderStyle = lv_xml_data.HeaderStyle.Nonclickable
		lv_xml_data.Columns.add column_names[1] 232
		lv_xml_data.Columns.add column_names[2] 50
		lv_xml_data.Columns.add column_names[3] 50
		lv_xml_data.Columns.add column_names[4] 100
		
		--picked materials
		column_names=#("Name", "ID")
		lv_new_mats.BackColor = drawingColor.fromArgb winColor.r winColor.g winColor.b
		lv_new_mats.ForeColor = drawingColor.fromArgb textColor.r textColor.g textColor.b
		lv_new_mats.MultiSelect = false 
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
		--xml rc menu
		initXmlMenu()
	)
	fn fin = (
	
		mcLS3DMaterialManagerStruct.closeChildrenDialogs()
	)
	on btn_add_mat pressed do (addNewMaterial())
	on btn_load_mat_lib pressed do (
		
		materials_for_save = #() --clear new added materials
		--materials table from xml
		parseXmlTable xml_materials_table
		fillListView lv_xml_data mat_items
	)
	on ddl_mat_lib selected sel do
	(
		
	)
	on btn_save_all pressed do (saveMaterialAndXML())
	on btn_get_mat pressed do (loadMaterialsFromSelection lv_new_mats)
	on btn_convert_sel pressed do
	(
		
	)
	--s:dotNetControl:lv_xml_data:System.Windows.Forms.ListView 
	--a:dotNetObject:System.Windows.Forms.ListViewItemSelectionChangedEventa
	on lv_xml_data ItemSelectionChanged s a do (

		local a = lv_xml_data.SelectedItems
		if a.count == 1 then (
			
			local item = a.item[0]
			format "selected item:% id:% sid:%\n" item.text item.tag.value.id item.tag.value.sid
			local mat_id = execute  (item.subitems.item[1].text)
			previewMaterial terrain_mat mat_id
			
		) else ( --if multiselection show gray color in preview
		
			bmp_preview.bitmap = Bitmap bmp_preview.width bmp_preview.height color:gray
		)
	)
	on lv_xml_data DoubleClick s a do (editSelectedMaterialXML())
	on lv_xml_data mouseclick s a do (showXmlMenu s a)
	
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
	on rMaterialDataManager open do init()
	on rMaterialDataManager close do fin()
	on btn_save_mat pressed do (saveMatLib())
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