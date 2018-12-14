Global mcCityManDialog
if ::mcCityManDialog != undefined do try(destroyDialog mcCityManDialog)catch()
rollout mcCityManDialog "City Manager v1.04" width:500 height:812
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
	
	multiListBox 'cbx_node_list' "Nodes List:" pos:[14,36] width:236 height:45 align:#left
	multiListBox 'cbx_children_list' "Linked Objects:" pos:[258,36] width:236 height:45 align:#left
	checkbox 'chk_auto_trace_node' "Auto Select" pos:[132,32] width:116 height:20 align:#left
	dropdownList 'ddl_display_filter' "Display Filter:" pos:[260,676] width:128 height:40 items:#("Children", "AllRoads") align:#left
	
	button 'btn_select_linked' "Select Linked" pos:[108,672] width:70 height:20 toolTip:"Select Object(s)" align:#left
	button 'btn_select_visible' "Select Visible" pos:[108,696] width:70 height:20 toolTip:"Select Visible Object(s)" align:#left 
	button 'btn_select_nodes' "Select Node(s)" pos:[14,672] width:76 height:20 toolTip:"Select Node(s)" align:#left
	button 'btn_get_nodes' "Get Node(s)" pos:[14,696] width:76 height:20 toolTip:"Get Nodes From Selected Objects" align:#left
	button 'btn_link_selection' "Link Selected" pos:[400,672] width:84 height:20 align:#left
	button 'btn_unlink_selection' "Unlink Selected" pos:[400,696] width:84 height:20 align:#left
	button 'btn_clr_copy' "Copy" pos:[12,752] width:70 height:20 align:#left
	button 'btn_clr_paste' "Paste" pos:[12,776] width:70 height:20 align:#left
	button 'btn_save_sel' "Store" pos:[112,752] width:70 height:20 align:#left
	button 'btn_load_sel' "Restore" pos:[112,776] width:70 height:20 align:#left
	button 'btn_hide_children' "Hide" pos:[184,696] width:70 height:20 align:#left
	button 'btn_show_children' "Show" pos:[184,672] width:70 height:20 align:#left
	button 'btn_export_selection' "EXPORT" pos:[288,748] width:200 height:44 align:#left
	button 'btn_zoom_selected' "FOCUS" pos:[204,748] width:80 height:44 toolTip:"Zoom to Location" align:#left
	button 'btn_init' "UPDATE" pos:[4,4] width:492 height:16 toolTip:"Zoom to Location" align:#left
	
	--Local variables
	local autosel = on
	local last_wire_color = yellow
	local last_selection = #()
	local callbacks_id = #micra_callbacks_cityman	
	--Functions
	fn clearList list =
	(
		list.items = #()
		if list.name == "Nodes List:" then lbl_nodes.text = "(0)" else lbl_objects.text = "(0)" 
	)
	fn deselectList list =
	(
		list.selection = 0
	)
	--get names from list selection
	fn getSelectedItems list =
	(
		if list.items.count == 0 do return #()
		local sel_items = #()
		local sel_indexes = list.selection as array
		if sel_indexes.count == 0 do return #()
		sel_items = for i in sel_indexes collect list.items[i]
		return sel_items
	)
	--get node names from object selection 
	fn getNodesFromSelection =
	(
		if selection.count == 0 do return false
		local node_names = #()
		for o in selection do
		(		
			if classOf o.parent != LS3DModel do continue
			local n = o.parent.name
			--prevent to get duplicate names
			if findItem node_names n == 0 do  node_names = append node_names n
		)
		--format "node_names:%\n" node_names
		return node_names
	)
	--select list item by name
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
	--select list items by name
	fn selectItemsByName list obj_names = 
	(

		local index_arr = #()
		for n in obj_names do
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
	fn fillNodesList = 
	(
		local node_names = for o in objects where classOf o == LS3DModel collect o.name 	
		if node_names.count == 0 do return #()
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
		if selection.count == 0 do 
		(
			deselectList cbx_node_list
			deselectList cbx_children_list
			return false
		)
		local node_names = getNodesFromSelection()
		if node_names.count == 0 then (
			
			deselectList cbx_children_list
			return false
			
		) else if node_names.count == 1 then (
			
			selectItemByName cbx_node_list node_names[1]
			fillChildrenList node_names[1]
			selectItemsByName cbx_children_list (for o in selection collect o.name)
		) else (
			
			selectItemsByName cbx_node_list node_names
			clearList cbx_children_list
		)	
	)
	--select nodes childrens
	fn selectListNodesChildren visible_only =
	(
		local sel_node_names = getSelectedItems cbx_node_list
		if sel_node_names.count == 0 do return false
		local all_children = #()
		for n in sel_node_names do 
		(
			local the_node = getNodeByName n
			if the_node == undefined do continue
			local node_children = the_node.children
			all_children = join all_children node_children
		)
		if visible_only do 
		(
			local visible_objects = for o in all_children where not o.isHidden collect o
			all_children = visible_objects
		) 
		autosel = off
		--undo "CityMan Slelect Objects" off 
		select all_children
		autosel = on
		--max zoomext sel
		if sel_node_names.count == 1 do updateSelection()
	)
	--Select objects by list selection
	--selected = select only selected items in list, else select all in list
	--visible_only = select only visible objects
	fn selectObjects list selected visible_only =
	(
		if list.items.count == 0 do return false
		--get selected only or all
		local sel_names = if selected then getSelectedItems list else sel_names = list.items
		--format "selecting objects from list:% sel:%\n" list.name sel_names
		local objs = #()
		for n in sel_names do 
		(
			local o = getNodeByName n
			if o != undefined do 
			(
				if visible_only then 
				(
					if not o.isHidden do objs = append objs o
				) else (
					
					objs = append objs o
				)
			)
		)
		--format "objs:%\n" objs
		autosel = off
		--undo "CityMan Slelect Objects" off 
		select objs
		autosel = on
	)
	fn zoomToNode node_name= (
		
		local first_node = getNodeByName node_name
		if first_node == undefined do return false
		select first_node	
		max zoomext sel
	)
	fn linkSelectionToNode  = 
	(
		if (cbx_node_list.selection as array).count != 1 do
		(
			messageBox "Select Single Node To Link" title:"Micra:"
			return false
		)
			if cbx_node_list.items.count == 0 do return false --validate
		--get first selected node
		local node_name = (getSelectedItems cbx_node_list)[1]
		local the_node = getNodeByName node_name
			if  the_node == undefined do return false --validate
		--undo "CityMan - Link" off 
		for o in selection do o.parent = the_node
		fillChildrenList node_name
		updateSelection()
	)
	fn unlinkSelectionFromNode = 
	(
		if (cbx_node_list.selection as array).count != 1 do
		(
			messageBox "Select Single Node To Unlink" title:"Micra:"
			return false
		)
			if cbx_children_list.items.count == 0 do return false --validate
		local sel_names = for i in cbx_children_list.selection collect cbx_children_list.items[i]
		--unlink selected items
		--undo "CityMan - Unlink" off 
		for n in sel_names do 
		(
			local obj = getNodeByName n
			if obj != undefined do obj.parent = undefined --validate	
		)
		--reload node items
		local node_name = (getSelectedItems cbx_node_list)[1]
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
		clearList cbx_children_list
		clearList cbx_node_list
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
		if node_names.count == 0 do return false
		fillChildrenList node_names[1]	
		updateSelection()
	)
	--load node children
	on cbx_node_list selected sel do
	(
		local node_name = cbx_node_list.items[sel]
		local sel_items = cbx_node_list.selection as array
		--format "selected items:% sel:% name:%\n"  sel_items.count sel node_name
		if sel_items.count == 1 then 
		(
			fillChildrenList node_name
		) else (
			cbx_children_list.items = #()	
			lbl_objects.text = "()"
		)
	)
	--focus node children
	on cbx_node_list doubleClicked sel do (selectListNodesChildren false)
	
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
	on btn_select_linked pressed do (selectListNodesChildren false)
		
	on btn_select_visible pressed do (selectListNodesChildren true)
	
	--select nodes from list
	on btn_select_nodes pressed do selectObjects cbx_node_list true false
	
	
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
		local filter_type = ddl_display_filter.items[ddl_display_filter.selection]
		case filter_type of
		(
			"Children":
			(
					local sel_node_names = getSelectedItems cbx_node_list
					if sel_node_names.count == 0 do return false
					local all_children = #()
					for n in sel_node_names do 
					(
						local the_node = getNodeByName n
						if the_node == undefined do continue
						local node_children = the_node.children
						all_children = join all_children node_children
					)
					autosel = off
					--undo "CityMan - Hide" on 
					all_children.isHidden = true
					autosel = on
					--max zoomext sel
					if sel_node_names.count == 1 do updateSelection()
			)
			"AllRoads": 
			(
				local target_layer = LayerManager.getLayerFromName "lh_00_roads"
				if target_layer == undefined do return false
				local layer_nodes = #()
				target_layer.nodes &thenodes
				--undo "CityMan - Hide" on 
				thenodes.isHidden = true
				return OK
			)
		)
	)
	
	on btn_show_children pressed  do
	(		
		local filter_type = ddl_display_filter.items[ddl_display_filter.selection]
		case filter_type of
		(
			"Children": 
			(
					local sel_node_names = getSelectedItems cbx_node_list
					if sel_node_names.count == 0 do return false
					local all_children = #()
					for n in sel_node_names do 
					(
						local the_node = getNodeByName n
						if the_node == undefined do continue
						local node_children = the_node.children
						all_children = join all_children node_children
					)
					autosel = off
					--undo "CityMan - Unhide" on 
					all_children.isHidden = false
					autosel = on
					--max zoomext sel
					if sel_node_names.count == 1 do updateSelection()
			)
			"AllRoads": 
			(
				local target_layer = LayerManager.getLayerFromName "lh_00_roads"
				if target_layer == undefined do return false
				local layer_nodes = #()
				target_layer.nodes &thenodes
				--undo "CityMan - Unhide" on 
				thenodes.isHidden = false
				return OK
			)
		)
	)
	
	on btn_zoom_selected pressed do (if selection.count > 0 do max zoomext sel)
	
	on btn_export_selection pressed  do
	(
		--get selecten nodes fom list
		local sel_names = getSelectedItems cbx_node_list
		if sel_names.count == 0 do return false
		--backup selection
		max create mode
		local old_selection = selection as array
		clearSelection()
		--select nodes
		local export_nodes = #()
		for n in sel_names do 
		(
			--format " select node:%\n" n
			local the_node = getNodeByName n 
			if classOf the_node != LS3DModel do continue
			export_nodes = append export_nodes the_node
		)
		if export_nodes.count == 0 do return false
		select export_nodes
		format "exporting(%) nodes:%\n" export_nodes.count export_nodes
		--gLS3DSmartExport.exportScene()
		macros.run "LS3D Engine" "LS3DSelExport"
		select old_selection
	)
	--get node from selection
	on btn_get_nodes pressed do
	(
		local node_names = getNodesFromSelection()
		if node_names.count == 0 do return false
		if node_names.count == 1 then
		(
			selectItemByName cbx_node_list node_names[1]
			fillChildrenList node_names[1]
		) else (
			
			selectItemsByName cbx_node_list node_names
			cbx_children_list.items = #()
		)	
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