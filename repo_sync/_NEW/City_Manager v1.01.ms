Global mcCityManDialog
if ::mcCityManDialog != undefined do try(destroyDialog mcCityManDialog)catch()
rollout mcCityManDialog "City Manager v1.01" width:500 height:780
(
	--Interface components
	GroupBox 'grp1' "..." pos:[4,4] width:492 height:692 align:#left
	GroupBox 'grp5' "Wire Color:" pos:[4,704] width:88 height:72 align:#left
	GroupBox 'grp3' "Selection:" pos:[104,704] width:88 height:72 align:#left
	GroupBox 'grp4' "..." pos:[196,704] width:300 height:72 align:#left
	
	combobox 'cbx_node_list' "Nodes List:" pos:[14,20] width:236 height:45 align:#left
	multiListBox 'cbx_children_list' "Children List:" pos:[258,20] width:236 height:46 align:#left
	
	button 'btn_get_node' "Node from Selection" pos:[16,644] width:116 height:20 align:#left
	button 'btn_focus_node' "Focus" pos:[136,644] width:52 height:20 align:#left
	button 'btn_focus_children' "Focus" pos:[428,644] width:56 height:20 align:#left
	button 'btn_link_selection' "Link Selected" pos:[340,644] width:84 height:20 align:#left
	button 'btn_clr_copy' "Copy" pos:[12,724] width:70 height:20 align:#left
	button 'btn_clr_paste' "Paste" pos:[12,748] width:70 height:20 align:#left
	button 'btn_save_sel' "Store" pos:[112,724] width:70 height:20 align:#left
	button 'btn_load_sel' "Restore" pos:[112,748] width:70 height:20 align:#left
	button 'btn_hide_children' "Hide Children" pos:[256,644] width:80 height:20 align:#left
	button 'btn_show_children' "Show Children" pos:[256,668] width:80 height:20 align:#left
	
	checkbox 'chk_auto_trace_node' "Auto Select" pos:[132,16] width:116 height:20 align:#left
	button 'btn21' "Unlink Selected" pos:[340,668] width:84 height:20 align:#left
	--Local variables
	local last_wire_color = yellow
	local last_selection = #()
	--Functions
	fn selectItemByName list node_name =
	(
		for i = 1 to list.items.count do
		(
			if list.items[i] != node_name do continue
			list.selection  = i
			exit
		)
	)
	fn getNodeChildrens node_name= 
	(
		local first_node = getNodeByName node_name
		if first_node == undefined do return false
		cbx_children_list.items =  for o in first_node.children collect o.name 		
	)
	fn updateSelection = 
	(
		local obj = selection[1]
		if obj == undefined do return false
		--format "selected object:%\n" obj.name
		if classOf obj.parent != LS3DModel do return false
		local node_name =  obj.parent.name
		selectItemByName cbx_node_list node_name
		getNodeChildrens node_name
		selectItemByName cbx_children_list obj.name
	)
	fn zoomToNode node_name= (
		
		local first_node = getNodeByName node_name
		if first_node == undefined do return false
		select first_node	
		max zoomext sel
	)
	fn linkSelectionToNode sel node_name = 
	(
		
		local the_node = getNodeByName node_name
		if the_node == undefined or sel.count == 0 do return false
		for o in sel do o.parent = the_node
		getNodeChildrens node_name
	)
	fn focusChildren node_name focus = 
	(
		--format "focusChildren node_name:%\n" node_name
		local the_node = getNodeByName node_name
		--format "focusChildren node:%\n" the_node
		if the_node == undefined do return false
		if the_node.children.count == 0 do return false 
		select the_node.children
		if focus do max zoomext sel
	)
	on cbx_node_list selected sel do
	(
		local node_name = cbx_node_list.items[sel]
		--format "selected:% sel:% name:%\n" selected sel node_name
		getNodeChildrens node_name
	)
	on cbx_node_list doubleClicked sel do
	(
		focusChildren cbx_node_list.selected false
	)
	on cbx_children_list doubleClicked sel do
	(
		local obj = getNodeByName cbx_children_list.selected
		if obj != undefined do select obj
	)
	on btn_get_node pressed  do
	(
		local obj = selection[1]
		if obj == undefined or obj.parent == undefined do return false
		selectItemByName cbx_node_list obj.parent.name
	)
	on btn_focus_node pressed  do
	(
		if cbx_node_list.items.count == 0 do return false
		zoomToNode cbx_node_list.selected
	)
	on btn_focus_children pressed  do
	(
		if cbx_node_list.items.count == 0 do return false
		focusChildren cbx_node_list.selected true
	)
	on btn_link_selection pressed  do
	(
		if cbx_node_list.items.count == 0 do return false
		linkSelectionToNode (selection as array) cbx_node_list.selected
	)
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
	on chk_auto_trace_node changed state do
	(
		if state then (
			
			callbacks.addScript #selectionSetChanged "mcCityManDialog.updateSelection()" id:#micra_node_list_update
		) else (
			
			callbacks.RemoveScripts #selectionSetChanged id:#micra_node_list_update
		)
	)
	on btn_hide_children pressed  do
	(
		if cbx_children_list.items.count == 0 do return false
		for n in cbx_children_list.items do 
		(
			local obj = getNodeByName n
			if obj == undefined do continue
			obj.isHidden = true
		)
	)
	on btn_show_children pressed  do
	(
		if cbx_children_list.items.count == 0 do return false
		for n in cbx_children_list.items do 
		(
			local obj = getNodeByName n
			if obj == undefined do continue
			obj.isHidden = false
		)
	)
	fn closeDialog = 
	(
		destroyDialog mcCityManDialog
	)
	on mcCityManDialog open do
	(
		--fill first list with nodes
		local node_names = for o in objects where classOf o == LS3DModel collect o.name 	
		if node_names.count == 0 do return false
		cbx_node_list.items = node_names
		getNodeChildrens node_names[1]
		--add callbacks
		chk_auto_trace_node.checked = true
		callbacks.addScript #selectionSetChanged		"mcCityManDialog.updateSelection()"	id:#micra_callbacks_cityman
		callbacks.addScript #filePreOpenProcess			"mcCityManDialog.closeDialog()"			id:#micra_callbacks_cityman
		callbacks.addScript #systemPreReset				"mcCityManDialog.closeDialog()"			id:#micra_callbacks_cityman
		callbacks.addScript #systemPreNew				"mcCityManDialog.closeDialog()"			id:#micra_callbacks_cityman
		callbacks.addScript #selectedNodesPostDelete	"mcCityManDialog.closeDialog()"			id:#micra_callbacks_cityman
		--select node in list
		updateSelection()
	)
	on mcCityManDialog close do 
	(
		callbacks.removescripts id:#micra_callbacks_cityman		
	)
)
createDialog mcCityManDialog