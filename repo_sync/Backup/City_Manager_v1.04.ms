Global mcCityManDialog
if ::mcCityManDialog != undefined do try(destroyDialog mcCityManDialog)catch()
rollout mcCityManDialog "City Manager v1.04" width:500 height:896
(
	--Interface components
	GroupBox 'grp1' "..." pos:[4,20] width:492 height:628 align:#left
	GroupBox 'grp2' "Wire Color:" pos:[4,732] width:88 height:72 align:#left
	GroupBox 'grp3' "Selection:" pos:[104,732] width:388 height:72 align:#left
	GroupBox 'grp5' "Node:" pos:[8,652] width:88 height:72 align:#left
	GroupBox 'grp6' "Linked:" pos:[100,652] width:396 height:72 align:#left
	
	label 'lbl_nodes' "()" pos:[72,36] width:60 height:14 align:#left
	label 'lbl_objects' "()" pos:[336,36] width:60 height:14 align:#left
	
	multiListBox 'cbx_node_list' "Nodes List:" pos:[14,36] width:236 height:45 align:#left
	multiListBox 'cbx_children_list' "Linked Objects:" pos:[258,36] width:236 height:45 align:#left
	checkbox 'chk_auto_trace_node' "Auto Select" pos:[132,32] width:116 height:20 align:#left
	dropdownList 'ddl_display_filter' "Display Filter:" pos:[260,676] width:128 height:40 items:#("Children", "AllRoads", "All") align:#left
	
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
	button 'btn_export_selection' "EXPORT" pos:[412,748] width:70 height:48 align:#left
	button 'btn_zoom_selected' "Focus" pos:[188,752] width:70 height:20 toolTip:"Zoom to Location" align:#left
	button 'btn_init' "UPDATE" pos:[4,4] width:492 height:16 toolTip:"Zoom to Location" align:#left
	GroupBox 'grp7' "Actions:" pos:[4,808] width:492 height:84 align:#left
	button 'btn_move_colls_to_layers' "Distribute Collisions" pos:[12,826] width:112 height:20 toolTip:"Move each Collision in to separate Layer" align:#left
	button 'btn_sel_colls' "Select Collisions" pos:[128,826] width:112 height:20 toolTip:"Select All Collision" align:#left
	button 'btn_select_visible_nodes' "Select Visible Nodes" pos:[12,848] width:112 height:20 toolTip:"Select All visible nodes" align:#left
	button 'btn_select_empty_objects' "Select Empty Objects" pos:[128,848] width:112 height:20 toolTip:"Select All Editable_Poly objects without geometry" align:#left
	button 'btn_filter_visible_nodes' "Filter Visible Nodes" pos:[12,870] width:112 height:20 toolTip:"Filter visible nodes from selection" align:#left
	button 'btn_generate_coll' "Gen Simple Collisions" pos:[126,870] width:112 height:20 toolTip:"Genarate collisions from selection, ID:1, " align:#left
	--Local variables
	local autosel = on
	local last_wire_color = yellow
	local last_selection = #()
	local callbacks_id = #micra_callbacks_cityman	
	local collision_wirecolor = color 176 26 26
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
	--------------------------------------------------------------------------------------------------------------------------------------------------
	-- Generic Fn
	--------------------------------------------------------------------------------------------------------------------------------------------------
	--distribute collisions in to layers
	fn moveCollisionsInToSeparateLayer = (
		
		for o in selection do (

			if o.parent == undefined do (

				format "Error > Unable move collision [ % ] which is not linked\n" o.name
			)
			local layer_name = substring o.parent.name 1 (findString o.parent.name "_coll")
			layer_name += "terrain_coll"
			local layer = layerManager.getLayerFromName layer_name
			if layer == undefined do (

				format "Error > Unable move collision [ % ] in to layer [ % ] which not exists\n" o.name layer_name
				continue
			)
			
			format "Move collision [ % ] in to layer [ % ]\n" o.name layer_name
			layer.addNode o
		)
	)
	fn cloneObject obj prefix = (
		
		local new_o = copy obj
		new_o.name = uniqueName (prefix+"_"+ obj.name)
		--for c in new_o.children do c.parent = undefined --dont need (a clone have no children)
		 --delete all custom attributes
		for i = custAttributes.count new_o to 1 by -1 do custAttributes.delete new_o i
		--select new_o; custAttributes.count new_o
		new_o
	)
	fn getCollisionLayer obj = (
	
		local layer_name = obj.layer.name + "_coll"
		local collision_layer = LayerManager.getLayerFromName layer_name --pick layer by name
		if collision_layer == undefined do collision_layer = LayerManager.newLayerFromName layer_name --create layer if not exists
		collision_layer
	)
	fn getCollisionNode obj = (
	
		local node_name
		if obj.parent != undefined do (
		
			local geometry_node_name = obj.parent.name
			local suffix_geometry_index = findString geometry_node_name "_geometry"
			if suffix_geometry_index != undefined do (
			
				node_name = (subString geometry_node_name 1 suffix_geometry_index) + "coll" 	
			)
		)
		if node_name != undefined  then getNodeByName node_name else undefined
	)
	fn generateSimpleCollisions = (
		
		local s_mat = meditmaterials["semantic_materials"]
		for o in selection where superClassOf o == GeometryClass do (
			
			local coll_layer = getCollisionLayer o
			local coll_export_node = getCollisionNode o
			if coll_export_node == undefined do (
				
				format "Unable to create collision from [ % ]. Export node not found.\n" o.name
				continue
			)
			--clone object
			local o_instance = cloneObject o "coll" 
			convertToPoly o_instance --collapse all modifiers
			coll_layer.addNode o_instance --ad to coll laer
			o_instance.parent = coll_export_node -- link to coll node
			--assign semantic material
			o_instance.wirecolor = collision_wirecolor
			o_instance.material = s_mat
			--change material id to 1 (uni hard)
			for f=1 to o_instance.numFaces do ( polyop.setFaceMatID o_instance f 1 )
			---set obj clone as collision node
			AddCustomAttributeByName o_instance "CollisionMesh"
			o_instance.'~layer' = -1
		)
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
	fn selectAllCollisions = (
		
-- 		local visible_objects = for o in objects where not o.isHidden collect o
		local colls = for o in objects where findString o.name "coll_"	!= undefined collect o
		select colls
	)
	fn selectObjectsWithoutGeometry = (

	local empty_geometry = #()
	local msg = ""
	for o in geometry where classOf o == Editable_poly do (

			if o.numVerts == 0 do (
				
				o.isHidden = false
				msg += o.name + "\n"
				append empty_geometry o	
			)
		)
		select empty_geometry
		messageBox ("Selected Empty Geometry("+empty_geometry.count as String+")\n"+msg) title:"Search Geometry:"
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
						join all_children node_children
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
			"All": (
			
				undo "Hide All" on ( hide objects )
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
						join all_children node_children
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
			"All": (
			
				undo "Show All" on ( unhide objects )
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
	on btn_move_colls_to_layers pressed do ( moveCollisionsInToSeparateLayer() )
	on btn_select_visible_nodes pressed do ( select(for o in objects where not o.ishidden collect o) )
	on btn_filter_visible_nodes pressed do ( select(for o in selection where not o.ishidden collect o) )
	on btn_generate_coll pressed do generateSimpleCollisions()
	on btn_sel_colls pressed do selectAllCollisions()
	on btn_select_empty_objects pressed do selectObjectsWithoutGeometry()
)
createDialog mcCityManDialog

/*
<dropdownlist>.items = append <dropdownlist>.items item

coll_roads = for o in selection where (findString o.name "coll_hoboken_road") != undefined collect o
coll_rails = for o in selection where (findString o.name "coll_hoboken_rail") != undefined collect o
join coll_roads coll_rails
select coll_roads

*/

/*
--link each collision mesh to collision node
missess = #()
for o in selection do (

	if o.parent == undefined do (
	append missess o
	format "node:% was not parented.\n" o.name
	continue
)
	local geo_node_name = o.parent.name
	local coll_node = subString geo_node_name 1 (findString geo_node_name "_geometry") 
	o.parent = getNodeByName (coll_node + "coll")
)
select missess
$.parent

*/