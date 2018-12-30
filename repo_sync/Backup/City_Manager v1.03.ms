Global mcCityManDialog
if ::mcCityManDialog != undefined do try(destroyDialog mcCityManDialog)catch()
rollout mcCityManDialog "City Manager v1.03" width:500 height:812
(
	--Interface components
	GroupBox 'grp1' "..." pos:[4,20] width:492 height:628 align:#left
	GroupBox 'grp2' "Wire Color:" pos:[4,732] width:88 height:72 align:#left
	GroupBox 'grp3' "Selection:" pos:[104,732] width:88 height:72 align:#left
	GroupBox 'grp4' "..." pos:[196,732] width:300 height:72 align:#left
	GroupBox 'grp5' "Node:" pos:[8,652] width:88 height:72 align:#left
	GroupBox 'grp6' "Linked:" pos:[100,652] width:396 height:72 align:#left
	
	label 'lbl_nodes' "()" pos:[72,36] width:60 height:14 align:#left
	label 'lbl_objects' "()" pos:[336,36] width:60 height:14 align:#left
	
	combobox 'cbx_node_list' "Nodes List:" pos:[14,36] width:236 height:45 align:#left
	multiListBox 'cbx_children_list' "Linked Objects:" pos:[258,36] width:236 height:46 align:#left
	checkbox 'chk_auto_trace_node' "Auto Select" pos:[132,32] width:116 height:20 align:#left
	dropdownList 'ddl_display_filter' "Display Filter:" pos:[260,676] width:128 height:40 items:#("Children", "AllRoads") align:#left
	
	button 'btn_select_linken' "Select Linked" pos:[108,672] width:70 height:20 toolTip:"Select Objects" align:#left
	button 'btn_select_visible' "Select Visible" pos:[108,696] width:70 height:20 toolTip:"Zoom to Location" align:#left 
	button 'btn_select_node' "Select Node" pos:[16,672] width:70 height:20 toolTip:"Select Node" align:#left
	button 'btn_get_node' "Get Node" pos:[16,696] width:70 height:20 toolTip:"Zoom to Node" align:#left
	button 'btn_link_selection' "Link Selected" pos:[400,672] width:84 height:20 align:#left
	button 'btn_unlink_selection' "Unlink Selected" pos:[400,696] width:84 height:20 align:#left
	button 'btn_clr_copy' "Copy" pos:[12,752] width:70 height:20 align:#left
	button 'btn_clr_paste' "Paste" pos:[12,776] width:70 height:20 align:#left
	button 'btn_save_sel' "Store" pos:[112,752] width:70 height:20 align:#left
	button 'btn_load_sel' "Restore" pos:[112,776] width:70 height:20 align:#left
	button 'btn_hide_children' "Hide" pos:[184,696] width:70 height:20 align:#left
	button 'btn_show_children' "Show" pos:[184,672] width:70 height:20 align:#left
	button 'btn_export_location' "EXPORT" pos:[288,748] width:200 height:44 align:#left
	button 'btn_zoom_selected' "FOCUS" pos:[204,748] width:80 height:44 toolTip:"Zoom to Location" align:#left
	button 'btn_init' "UPDATE" pos:[4,4] width:492 height:16 toolTip:"Zoom to Location" align:#left
	
	--Local variables
	local autosel = on
	local last_wire_color = yellow
	local last_selection = #()
	local callbacks_id = #micra_callbacks_cityman	
	--Functions
	fn selectItemByName list node_name =
	(
		--format "selectItemByName list:% node_name:%\n" list node_name
		for i = 1 to list.items.count do
		(
			if list.items[i] != node_name do continue
			list.selection  = i
			exit
		)
	)
	fn selectItemsByName list node_names = 
	(

		local index_arr = #()
		for n in node_names do
		(
			for i = 1 to list.items.count do --collect items indexes
			(
				if list.items[i] != n do continue
				index_arr = append index_arr i
				exit
			)
		)
		list.selection = index_arr
	)
	--selected = select only selected items in list
	fn selectObjects list selected visible =
	(
		if list.items.count == 0 do return false
		local sel_names = #()
		if selected then 
		(
			sel_names = for i in list.selection collect list.items[i]	
		) else (
			sel_names = list.items
		)
		--local objs = for n in sel_names where (local o = getNodeByName n) != undefined do collect o
		
		local objs = #()
		for n in sel_names do 
		(
			local o = getNodeByName n
			if o != undefined do 
			(
				if visible then 
				(
					if not o.isHidden do objs += o
				) else (
					
					objs += o
				)
			)
		)
		autosel = off
		undo "CityMan Slelect Objects" on select objs
		autosel = on
	)
	fn fillNodesList = 
	(
		local node_names = for o in objects where classOf o == LS3DModel collect o.name 	
		if node_names.count == 0 do return false
		cbx_node_list.items = sort node_names
		lbl_nodes.text = "("+cbx_node_list.items.count as string+")"
		return node_names
	)
	fn fillChildrenList node_name= 
	(
		local first_node = getNodeByName node_name
		if first_node == undefined do return false
		cbx_children_list.items = sort ( for o in first_node.children collect o.name )		
		--cbx_children_list.name = "Linked Objects:("+cbx_children_list.items.count as string+")"
		lbl_objects.text = "("+cbx_children_list.items.count as string+")"
	)
	fn updateSelection = 
	(
		if not autosel or not chk_auto_trace_node.checked do return false
		local obj = selection[1]
		if obj == undefined do 
		(
			cbx_children_list.selection = 0
			return false
		)
		--format "selected object:%\n" obj.name
		if classOf obj == LS3DModel do 
		(
			selectItemByName cbx_node_list obj.name
			return false
		)
		if classOf obj.parent != LS3DModel do return false
		
		local node_name =  obj.parent.name
		selectItemByName cbx_node_list node_name
		fillChildrenList node_name
		selectItemsByName cbx_children_list (for o in selection collect o.name)
	)
	fn zoomToNode node_name= (
		
		local first_node = getNodeByName node_name
		if first_node == undefined do return false
		select first_node	
		max zoomext sel
	)
	fn linkSelectionToNode  = 
	(
			if selection.count == 0  or cbx_node_list.items.count == 0 do return false --validate
		local node_name = cbx_node_list.selected
		local the_node = getNodeByName node_name
			if  the_node == undefined do return false --validate
		undo "CityMan - Link" on for o in selection do o.parent = the_node
		fillChildrenList node_name
		updateSelection()
	)
	fn unlinkSelectionFromNode = 
	(
			if cbx_children_list.items.count == 0 do return false --validate
		local sel_names = for i in cbx_children_list.selection collect cbx_children_list.items[i]
		--unlink selected items
		undo "CityMan - Unlink" on for n in sel_names do 
		(
			local obj = getNodeByName n
			if obj != undefined do obj.parent = undefined --validate	
		)
		--reload node items
		local node_name = cbx_node_list.selected
		local the_node = getNodeByName node_name
			if  the_node == undefined do return false --validate
		autosel = off --keep unlinked objects selected
		fillChildrenList node_name 
		cbx_children_list.selection = 0 --select none
		autosel = on
	)
	fn closeDialog = 
	(
		destroyDialog mcCityManDialog
	)
	fn restartDialog =
	(
		local dia_pos =getDialogPos mcCityManDialog
		destroyDialog mcCityManDialog
		createDialog mcCityManDialog
		setDialogPos mcCityManDialog dia_pos
	)
	fn needUpdate =
	(
		--btn_init
		autosel = off --keep unlinked objects selected
		cbx_children_list.items = #()
		cbx_node_list.items = #()
		lbl_nodes.text = "()"
		lbl_objects.text = "()"
	)
	fn objectAdded =
	(
		/*local sel = callbacks.notificationParam()	
		for o in sel do 
		(
			if classOf o == LS3DModel then 
			(
				--add node name from list 
				local item_index = findItem objects_list o.name
				if item_index == 0 do continue
				DeleteItem cbx_node_list.items item_index
				--fill list again
				cbx_node_list.items = cbx_node_list.items
				--select node in list
				if selected_node_name == o.name then --select first node or nothing
				(
					if cbx_node_list.items.count > 0 do cbx_node_list.selection = 1
				) else ( --reselect last selection
					
					selectItemByName cbx_node_list o.name
				)
				
			) else (
				--check if object is linked to selected node
				if o.parent == undefined or  o.parent.name != node_name do continue
				--remove object from list
				local objects_list = cbx_children_list.items
				local item_index = findItem objects_list o.name
				if item_index == 0 do continue
				DeleteItem objects_list item_index
				cbx_children_list.items = objects_list
			)
		)*/
	)
	fn objectWillBeDeleted = 
	(
		/*--if list is empty return false
		if cbx_node_list.items.count == 0 do return false
		local node_name = cbx_node_list.selected 
		local the_node = getNodeByName node_name
		if the_node == undefined do return false
		--get objects which will be deleted
		local sel = callbacks.notificationParam()	
		for o in sel do 
		(
			if classOf o == LS3DModel then 
			(
				--mem selected node in list
				local selected_node_name = cbx_node_list.selected
				--remove node name from list 
				local item_index = findItem objects_list o.name
				if item_index == 0 do continue
				DeleteItem cbx_node_list.items item_index
				--fill list again
				cbx_node_list.items = cbx_node_list.items
				--select node in list
				if selected_node_name == o.name then --select first node or nothing
				(
					if cbx_node_list.items.count > 0 do cbx_node_list.selection = 1
				) else ( --reselect last selection
					
					selectItemByName cbx_node_list o.name
				)
				
			) else (
				--check if object is linked to selected node
				if o.parent == undefined or  o.parent.name != node_name do continue
				--remove object from list
				local objects_list = cbx_children_list.items
				local item_index = findItem objects_list o.name
				if item_index == 0 do continue
				DeleteItem objects_list item_index
				cbx_children_list.items = objects_list
			)
		)*/
	)
	fn nodeRenamed =
	(
		if cbx_node_list.items.count == 0 do return false
		local data = callbacks.notificationParam()	
		local new_name = data[1]
		cbx_node_list.selected = new_name
	)
	fn initializeInterface =
	(
		local node_names = fillNodesList()
		fillChildrenList node_names[1]	
		updateSelection()
	)
	--load node children
	on cbx_node_list selected sel do
	(
		local node_name = cbx_node_list.items[sel]
		--format "selected:% sel:% name:%\n" selected sel node_name
		fillChildrenList node_name
	)
	--focus node children
	on cbx_node_list doubleClicked sel do 
	(
		selectObjects cbx_children_list false false
		--max zoomext sel
		updateSelection()
	)
	--Select object by name
	on cbx_children_list selected sel do (selectObjects cbx_children_list true false)
	--Zoom selected object
	on cbx_children_list doubleClicked sel do
	(
		local obj_name = cbx_children_list.items[sel]
		local obj = getNodeByName obj_name
		if obj != undefined do select obj; max zoomext sel
	)
	--select all node children
	on btn_select_linken pressed do 
	(
		selectObjects cbx_children_list false false
		updateSelection()
	)	
	on btn_select_visible pressed do
	(
		selectObjects cbx_children_list false true
		updateSelection()
	)
	--select active node
	on btn_select_node pressed do 
	(
		if cbx_node_list.items.count == 0 do return false
		local node_name = cbx_node_list.selected
		local the_node = getNodeByName node_name
		if the_node != undefined do select the_node
	)
	
	on btn_link_selection pressed  do linkSelectionToNode()
	on btn_unlink_selection pressed do unlinkSelectionFromNode()
	
	on btn_clr_copy pressed  do
	(
		if selection.count == 0 do return false
		last_wire_color = $selection[1].wirecolor
	)
	on btn_clr_paste pressed  do
	(
		if selection.count == 0 do return false
		$.wirecolor = last_wire_color
	)
	on btn_save_sel pressed  do
	(
		last_selection = $selection as array
	)
	on btn_load_sel pressed  do
	(
		select last_selection
	)
	
	on chk_auto_trace_node changed state do (autosel = state)
	
	on btn_hide_children pressed  do
	(
		if cbx_children_list.items.count == 0 do return false
		local filter_type = ddl_display_filter.items[ddl_display_filter.selection]	
		local obj_array = #()
		for n in cbx_children_list.items do 
		(
			local obj = getNodeByName n
			if obj == undefined do continue
			local is_valid = case filter_type of
			(
				"Children": true
				--"Buildings": findString n "building" != undefined
				"AllRoads": 
				(
					local target_layer = LayerManager.getLayerFromName "lh_00_roads"
					if target_layer == undefined do return false
					local layer_nodes = #()
					target_layer.nodes &thenodes
					undo "CityMan - Hide" on thenodes.isHidden = true
					--undo "CityMan - Hide" on target_layer.on = false
					--findString n "road" != undefined
					return OK
				)
			)
			if is_valid do obj_array += obj
		)
		undo "CityMan - Show" on obj_array.isHidden = true
	)
	
	on btn_show_children pressed  do
	(
		if cbx_children_list.items.count == 0 do return false
		local filter_type = ddl_display_filter.items[ddl_display_filter.selection]
		local obj_array = #()
		for n in cbx_children_list.items do 
		(
			local is_valid = case filter_type of
			(
				"Children": true
				--"Buildings": findString n "building" != undefined
				"AllRoads": 
				(
					local target_layer = LayerManager.getLayerFromName "lh_00_roads"
					if target_layer == undefined do return false
					local layer_nodes = #()
					target_layer.nodes &thenodes
					undo "CityMan - Hide" on thenodes.isHidden = false
					--undo "CityMan - Hide" on target_layer.on=true
					return OK
					--findString n "road" != undefined
				)
			)
			if not is_valid do continue --depend on filter choice
			local obj = getNodeByName n
			if obj == undefined do continue
			obj_array += obj
		)
		undo "CityMan - Show" on obj_array.isHidden = false
	)
	
	on btn_zoom_selected pressed do (if selection.count > 0 do max zoomext sel)
	
	on btn_export_location pressed  do
	(
		if cbx_node_list.items.count == 0 do return false
		local old_selection = selection as array
		local nod_name = cbx_node_list.selected
		local export_node = getNodeByName nod_name
		if classOf export_node != LS3DModel do return false
		select export_node
		--gLS3DSmartExport.exportScene()
		max create mode
		macros.run "LS3D Engine" "LS3DSelExport"
		select old_selection
	)
	--get node from selection
	on btn_get_node pressed do
	(
		local obj = selection[1]
		if obj == undefined or obj.parent == undefined do return false
		selectItemByName cbx_node_list obj.parent.name
		fillChildrenList obj.parent.name
	)
	on btn_init pressed do 
	(
		initializeInterface()
		if chk_auto_trace_node.checked do autosel = on
	)
	on mcCityManDialog open do
	(
		--fill first list with nodes
		initializeInterface()
		--add callbacks
		if autosel do 
		(
			chk_auto_trace_node.checked = true
			callbacks.addScript #selectionSetChanged		"mcCityManDialog.updateSelection()"	id:#callbacks_id
		)
		callbacks.addScript #filePreOpenProcess			"mcCityManDialog.closeDialog()"					id:callbacks_id
		callbacks.addScript #systemPreReset				"mcCityManDialog.closeDialog()"					id:callbacks_id
		callbacks.addScript #systemPreNew				"mcCityManDialog.closeDialog()"					id:callbacks_id
		callbacks.addScript #selectedNodesPreDelete	"mcCityManDialog.needUpdate()"					id:callbacks_id
		callbacks.addScript #nodeCreated					"mcCityManDialog.needUpdate()"					id:callbacks_id
		callbacks.addScript #nodeCloned					"mcCityManDialog.needUpdate()"					id:callbacks_id
		callbacks.addScript #sceneNodeAdded				"mcCityManDialog.needUpdate()"					id:callbacks_id
		callbacks.addScript #nodeRenamed					"mcCityManDialog.nodeRenamed()"				id:callbacks_id
		--select node in list
		updateSelection()
	)
	on mcCityManDialog close do 
	(
		callbacks.removescripts id:#micra_callbacks_cityman		
	)
)
createDialog mcCityManDialog

/*
<dropdownlist>.items = append <dropdownlist>.items item

coll_roads = for o in selection where (findString o.name "coll_hoboken_road") != undefined collect o
coll_rails = for o in selection where (findString o.name "coll_hoboken_rail") != undefined collect o
coll_roads = join coll_roads coll_rails
select coll_roads

*/