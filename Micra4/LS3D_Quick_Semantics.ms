Global ls3dQuickSemantics
if ls3dQuickSemantics != undefined do destroyDialog ls3dQuickSemantics
rollout ls3dQuickSemantics "LS3D Quick Semantics Materials:" width:236 height:728
(
	local semantic_mat
	local drawingColor   = dotNetClass "drawing.color"
	local bgColor   = ((colorMan.getColor #background)*255)as color
	local winColor  = ((colorMan.getColor #window)*255)as color
	local textColor = ((colorMan.getColor #text)*255)as color
	local list_items = #() --backup collection for search bar (edt_filter_names)
	local material_color_types = #(color 220 170 150, color 150 150 150)
	button 'btn_assign' "Assign To Selection" pos:[4,4] width:228 height:20 toolTip:"Select Object(s) or Polygons" align:#left
	GroupBox 'grp2' "Semantic Materials" pos:[4,28] width:228 height:696 align:#left
	dotNetControl 'edt_filter_names' "textbox" pos:[8,48] width:196 height:20 align:#left
	dotNetControl 'lv_mat_data' "listView" pos:[8,72] width:216 height:592 align:#left
	button 'btn_Clear' "<" pos:[208,46] width:20 height:22 align:#left
	button 'btn_sel_simillar' "Select Simillar Faces" pos:[8,696] width:216 height:24 align:#left
	button 'btn_get_sel' "Pick Material" pos:[8,668] width:216 height:24 align:#left
	--functions
	fn isValidObject obj = ( --Uvwmap restricted for secure work
	
		(classOf obj == Editable_Poly or classOf obj == PolyMeshObject) and classOf obj.modifiers[1] != Uvwmap 
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
		if obj.material == undefined or obj.material.name != "semantic_materials" do (

			local cur_lvl = subobjectLevel
			subobjectLevel = 0
			obj.material = semantic_mat
			if cur_lvl != undefined do subobjectLevel = cur_lvl
		)
		obj.showVertexColors = false
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
	
	fn getFacesMaterialIDS obj = (
	
		local ids = #{}
		local mesh_obj = snapshotasmesh obj
		local fsel = getFaceSelection mesh_obj
		for f in fsel do ids[getFaceMatID mesh_obj f] = on
		delete mesh_obj
		ids
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
	
	fn assignMaterial objs = (
		
		if lv_mat_data.selectedItems.count == 0 do return false
		local sel_item = lv_mat_data.selectedItems.item[0]
		--format "sel_item:% id:%\n" sel_item sel_item.tag
		if objs.count == 1 and classOf objs[1] == Editable_Poly then (
			
			if subobjectLevel == undefined or subobjectLevel == 0 do (
			
				if not queryBox "Replace Semantic Material on Whole object?" title:"Replace?" do return OK
			)
			 setMaterialIdToPoly objs[1] sel_item.tag
		
		) else if objs.count > 1 and queryBox "Replace Semantic Material on Whole objects?" title:"Replace?" do (
			
			for o in selection where classOf o == Editable_Poly do setMaterialIdToPoly o sel_item.tag
		)
		completeRedraw()
	)
	fn filterItemsByName list mat_name ignoreCase:true = (
		
					--for itm in list where (getMaterialType  itm.tag.value.id == mat_type) collect itm
		for itm in list where (
			
			local itm_name = if ignoreCase then toLower itm.text else itm.text
			findString itm_name mat_name != undefined
		) collect itm
	)
	fn markItem itm = (
		
		local hc = (dotnetClass "System.Windows.SystemColors").HighlightColor
		itm.BackColor = drawingColor.fromArgb hc.r hc.g hc.b
	)
	
	fn unmarkItem itm = (
		
		local cc= material_color_types[1]
		itm.BackColor = drawingColor.fromArgb cc.r cc.g cc.b
	)
	fn filterListView lv ignoreCase:true = (
			
		if search_str == ""  and lv.items.count == list_items.count do return OK --nothing changed
		local search_str = if ignoreCase then toLower edt_filter_names.text else edt_filter_names.text
		local filtered_list = filterItemsByName list_items search_str
		
		if filtered_list.count == 0 do return false -- no matches found
		lv.items.clear()	
		lv.items.addrange filtered_list --fill list with all  matched items
		lv.items.item[ 0 ].selected = true --select first item
		for i=0 to lv.items.count - 1 do unmarkItem lv.items.item[ i ] --un hilight item
		markItem lv.items.item[ 0 ] --hilight item
	)
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
	fn fillListView lv = (
		
		semantic_mat = currentMaterialLibrary["semantic_materials"]
		if semantic_mat == undefined do  s_mat = meditmaterials["semantic_materials"]
		if semantic_mat == undefined do (
		
			loadMaterialsToLibrary #(LS3DGUP.LS3DGUP.UtilsPath + "semantic_materials.mat")
			semantic_mat = currentMaterialLibrary["semantic_materials"]
		)
		if semantic_mat == undefined do (
			gProgLog.msg ("Unable to inicialize. Semantic Material not found.") ty:"error"
			return false
		)
		lv.BeginUpdate()
		lv.items.Clear()
		local clr = material_color_types[1]
		local all_items = #()
		for i=1 to semantic_mat.count do (
			
			local mat = semantic_mat[i]
			if (mat == undefined or mat.name == "undefined") do continue 
			local diff_clr = mat.DiffuseColor
			local li = dotNetObject "ListViewItem" (mat.name)
			li.UseItemStyleForSubItems = false;
			li.BackColor= drawingColor.fromArgb clr.r clr.g clr.b
			--format "add item name:% id:% sid:% clr:%\n" itm.key itm.id itm.sid clr
			li.tag = i  --DotNet value holding the MAXScript value
			
			li.subitems.add (i as String)
			li.subitems.add ("")
			li.subitems.item[0].name="0"
			li.subitems.item[1].name="1"
			-- change color of the subItems
			li.subItems.Item[1].BackColor = drawingColor.fromArgb clr.r clr.g clr.b
			li.subItems.Item[2].BackColor = drawingColor.fromArgb diff_clr.r diff_clr.g diff_clr.b
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
	)
	--create class ListViewItemComparer
	fn compileListItemSorter = (
        source =  "using System;\n"
        source += "using System.Windows.Forms;\n"
        source += "using System.Collections;\n"
        source += "class ListViewItemComparer : IComparer\n"
        source += "{\n"
        source += "    private int c;\n"
        source += "    private bool num = false;\n"
        source += "    private int dir = 1;\n"
        source += "    public ListViewItemComparer() { c = 0; }\n"
        source += "    public ListViewItemComparer(int column, bool numeric, bool reverse)\n"
        source += "    { c = column; num = numeric; dir = reverse ? -1 : 1; }\n"
        source += "    public int Compare(object x, object y)\n"
        source += "    {\n"
        source += "        if (num) return Convert.ToInt32(((ListViewItem)x).SubItems[c].Text).CompareTo(\n"
        source += "            Convert.ToInt32(((ListViewItem)y).SubItems[c].Text)) * dir;\n"
        source += "        else return String.Compare(((ListViewItem)x).SubItems[c].Text,\n"
        source += "            ((ListViewItem)y).SubItems[c].Text) * dir;\n"
        source += "    }\n"
        source += "}"
 
        local csharpProvider = dotNetObject "Microsoft.CSharp.CSharpCodeProvider"
        local compilerParams = dotNetObject "System.CodeDom.Compiler.CompilerParameters"
        compilerParams.GenerateInMemory = true
        compilerParams.ReferencedAssemblies.Add("System.Windows.Forms.dll")
        compilerResults = csharpProvider.CompileAssemblyFromSource compilerParams #(source)
        compilerResults.CompiledAssembly
    )
	fn init = (
			--Text Box
		edt_filter_names.BackColor = drawingColor.fromArgb winColor.r winColor.g winColor.b
		edt_filter_names.ForeColor = drawingColor.fromArgb textColor.r textColor.g textColor.b
		edt_filter_names.AcceptsTab = false
		edt_filter_names.Multiline = false
		--List View
		local column_names=#("Name", "SID", "RGB")
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
		lv_mat_data.HeaderStyle = lv_mat_data.HeaderStyle.Clickable --Nonclickable
		-- lv_mat_data.headerStyle = lv_mat_data.headerStyle.none --hide the columnheader
		lv_mat_data.BorderStyle = lv_mat_data.BorderStyle.None --no border around the control  
		lv_mat_data.Columns.add column_names[1] 136
		lv_mat_data.Columns.add column_names[2] 30
		lv_mat_data.Columns.add column_names[3] 32
		--
		compileListItemSorter()
		--Fill List View
		fillListView lv_mat_data
		--Focus Text Box
		setFocus edt_filter_names	
	)
	fn clearItemsFilter = (
		
		edt_filter_names.text = ""
		filterListView lv_mat_data
	)
	local lastColumn, reversed = false
	on lv_mat_data columnClick columnHeader do ( --sort items by header click

		--lv_mat_data.ListViewItemSorter = dotnetobject "MXS_dotNet.ListViewItemComparer" columnHeader.column (dotnetclass "System.Windows.Forms.SortOrder").Ascending
		--lv_mat_data.ListViewItemSorter = undefined
		
		local column = columnHeader.Column
        if column == lastColumn then reversed = NOT reversed else reversed = false
        lv_mat_data.ListViewItemSorter = dotNetObject "ListViewItemComparer" column (column == 1) reversed
        lv_mat_data.ListViewItemSorter = undefined
 
        lastColumn = column
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
		--select item from list
		for i = 0 to lv_mat_data.items.count - 1 do (
		
			local itm = lv_mat_data.items.item[i]
			local mat_data_id = itm.tag 
			if mat_data_id == map_id do (
			
				unmarkItem lv_mat_data.selectedItems.item[0] --un hilight item
				itm.selected = true
				--current_top_index = .TopItem.Index -- lv_mat_data.TopItem --alternative
				itm.EnsureVisible() --focus - scroll to selected item
				markItem lv_mat_data.items.item[ i ] --hilight item
				exit
			)
		)
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
	on btn_assign pressed  do undo "Change Semantic Material" on assignMaterial(selection as array)
	on ls3dQuickSemantics open do init()
	on edt_filter_names keyUp arg do (filterListView lv_mat_data)
	on lv_mat_data GotFocus args  do  ( unmarkItem  lv_mat_data.SelectedItems.item[0] )
	on lv_mat_data LostFocus args do ( markItem  lv_mat_data.SelectedItems.item[0] )
	on btn_clear pressed do clearItemsFilter()
	on btn_get_sel pressed do (clearItemsFilter(); pickMaterialFromSelection (selection as Array))
	on btn_sel_simillar pressed  do (undo "Select Simmilar Faces" on selectSimillarFaces (selection as Array))
)
createDialog ls3dQuickSemantics