Global mcCityManDialog
if ::mcCityManDialog != undefined do try(destroyDialog mcCityManDialog)catch()
rollout mcCityManDialog "" width:500 height:988
(
	local form_title = "City Manager v1.07"
	local force_load_structures = true
	--Interface components
	GroupBox 'grp1' "..." pos:[4,20] width:492 height:588 align:#left
	GroupBox 'grp2' "Wire Color:" pos:[4,688] width:88 height:72 align:#left
	GroupBox 'grp3' "Selection:" pos:[96,688] width:400 height:72 align:#left
	GroupBox 'grp5' "Nodes:" pos:[4,612] width:88 height:72 align:#left
	GroupBox 'grp6' "Objects:" pos:[96,612] width:400 height:72 align:#left
	label 'lbl_nodes' "()" pos:[72,36] width:60 height:14 align:#left
	label 'lbl_objects' "()" pos:[336,36] width:60 height:14 align:#left
	multiListBox 'cbx_node_list' "Nodes List:" pos:[10,36] width:236 height:42 align:#left
	multiListBox 'cbx_children_list' "Linked Objects:" pos:[254,36] width:236 height:42 align:#left
	checkbox 'chk_auto_trace_node' "Auto Select" pos:[128,32] width:70 height:20 align:#left
	dropdownList 'ddl_display_filter' "Display Filter:" pos:[256,636] width:128 height:40 items:#("Children", "AllRoads", "All") align:#left
	button 'btn_select_linked' "Select Linked" pos:[104,632] width:70 height:20 toolTip:"Select Object(s)" align:#left
	button 'btn_select_visible' "Select Visible" pos:[104,656] width:70 height:20 toolTip:"Select Visible Object(s)" align:#left
	button 'btn_select_nodes' "Select Node(s)" pos:[10,632] width:76 height:20 toolTip:"Select Node(s)" align:#left
	button 'btn_get_nodes' "Get Node(s)" pos:[10,656] width:76 height:20 toolTip:"Get Nodes From Selected Objects" align:#left
	button 'btn_link_selection' "Link Selected" pos:[404,632] width:84 height:20 align:#left
	button 'btn_unlink_selection' "Unlink Selected" pos:[404,656] width:84 height:20 align:#left
	button 'btn_clr_copy' "Copy" pos:[12,708] width:70 height:20 align:#left
	button 'btn_clr_paste' "Paste" pos:[12,732] width:70 height:20 align:#left
	button 'btn_save_sel' "Store" pos:[104,708] width:70 height:20 toolTip:"Remember current selection" align:#left
	button 'btn_load_sel' "Restore" pos:[104,732] width:70 height:20 toolTip:"Reselect stored selection" align:#left
	button 'btn_hide_children' "Hide" pos:[180,656] width:70 height:20 align:#left
	button 'btn_show_children' "Show" pos:[180,632] width:70 height:20 align:#left
	button 'btn_export_selection' "EXPORT" pos:[384,708] width:106 height:40 align:#left
	button 'btn_zoom_selected' "Focus" pos:[180,708] width:70 height:20 toolTip:"Zoom to Selection" align:#left
	button 'btn_update' "UPDATE" pos:[4,4] width:492 height:16 toolTip:"Get scene data..." align:#left
	GroupBox 'grp7' "Actions:" pos:[4,764] width:240 height:152 align:#left
	button 'btn_move_colls_to_layers' "Distribute Collisions" pos:[252,888] width:108 height:20 toolTip:"Move Selected Collision in to separate Layer" align:#left
	button 'btn_sel_colls' "Select Collisions" pos:[252,804] width:112 height:20 toolTip:"Select All Collisions" align:#left
	button 'btn_select_visible_nodes' "Select Visible Nodes" pos:[12,804] width:112 height:20 toolTip:"Select All visible nodes" align:#left
	button 'btn_select_empty_objects' "Select Empty Objects" pos:[128,804] width:112 height:20 toolTip:"Select All Editable_Poly objects without geometry" align:#left
	button 'btn_filter_visible_nodes' "Filter Visible Nodes" pos:[12,826] width:112 height:20 toolTip:"Filter visible nodes from selection" align:#left
	button 'btn_unique_check' "Unique Names Check" pos:[12,780] width:112 height:20 toolTip:"Check Scene For Duple Names" align:#left
	button 'btn_unique_fix' "Unique Names Fix" pos:[128,780] width:112 height:20 toolTip:"Fix Duple Names In Scene" align:#left
	button 'btn_inspect_nodes' "Inpect Nodes Paths" pos:[128,826] width:112 height:20 toolTip:"Select Collision" align:#left
	checkbox 'chk_sel_coll_roads' "roads" pos:[312,784] width:52 height:16 checked:true align:#left
	checkbox 'chk_sel_coll_terrain' "terrain" pos:[252,784] width:52 height:16 checked:true align:#left
	button 'btn_hide_sel' "Hide Selected" pos:[12,848] width:112 height:20 toolTip:"Hide Selected Objects" align:#left
	button 'btn_unhide_sel' "Unhide Selected" pos:[128,848] width:112 height:20 toolTip:"Unhide Selected Objects" align:#left
	GroupBox 'grp13' "Collisions:" pos:[248,764] width:120 height:152 align:#left
	button 'btn_generate_coll' "Gen Simple Collisions" pos:[148,920] width:112 height:40 toolTip:"Genarate simple collisions from selection, ID:1, " align:#left
	button 'btn_generate_terrain_coll' "Gen Terrain Collisions" pos:[264,920] width:112 height:40 enabled:true toolTip:"Genarate terrain collisions from selection, ID:Auto, " align:#left
	button 'btn_generate_roads_coll' "Gen Road Collisions" pos:[380,920] width:112 height:40 toolTip:"Genarate roads collisions from selection, ID:Auto, " align:#left
	label 'lbl_sh' "Show - Hide objects which contains a Word:" pos:[12,872] width:220 height:14 align:#left
	button 'btn_show_objs' "Show" pos:[13,892] width:56 height:17 toolTip:"Unhide Objects By Name" across:3 align:#left
	button 'btn_hide_objs' "Hide" pos:[72,892] width:56 height:17 toolTip:"Hide Objects By Name" align:#left
	edittext 'edt_sh_name' "" pos:[132,892] width:104 height:16 align:#left
	button 'btn_sel_geo_nodes' "G" pos:[204,32] width:20 height:20 toolTip:"Select Geometry Nodes" align:#left
	button 'btn_sel_coll_nodes' "C" pos:[224,32] width:20 height:20 toolTip:"Select Collision Nodes" align:#left
	dropdownList 'ddl_collision_type' "Collision Type:" pos:[8,920] width:136 height:40 items:#("Two Nodes", "Single Node") align:#left
	button 'btn_sel_vis_colls' "Select Visible Collisions" pos:[252,828] width:112 height:20 toolTip:"Select Visible Collisions" align:#left
	button 'btn_sel_geo' "Select Geometry" pos:[376,804] width:112 height:20 toolTip:"Select All Geometry" align:#left
	checkbox 'chk_sel_geo_roads' "roads" pos:[436,784] width:52 height:16 checked:true align:#left
	checkbox 'chk_sel_geo_terrain' "terrain" pos:[376,784] width:52 height:16 checked:true align:#left
	GroupBox 'grp8' "Geometry:" pos:[372,764] width:120 height:152 align:#left
	button 'btn_sel_vis_geo' "Select Visible Geometry" pos:[376,828] width:112 height:20 toolTip:"Select Visible Geometry" align:#left
	button 'btn_move_geo_to_layers' "Distribute Geometry" pos:[376,888] width:108 height:20 toolTip:"Move Selected Objects in to separate Layer" align:#left
	button 'btn_run_fn' "GO" pos:[456,964] width:36 height:20 align:#left
	dropDownList 'ddl_fn_list' "" pos:[148,964] width:304 height:21 items:#(
	
		"Generate Player and Car Collisions",
		"Select Visible Lodes 2" ,
		"Add Terrain Lodes 2 and Fix Pivot",
		"Add Lodes Custom",
		"Destroy Lods in Selection",
		"Curb Crumple",
		"Collision Optimizer" 
	) 
	label 'lbl_advanced_tools' "Advanced Tools:" pos:[12,964] width:132 height:20 align:#left
	--Local variables
	local autosel = on
	local last_wire_color = yellow
	local last_selection = #()
	local callbacks_id = #micra_callbacks_cityman	
	local collision_wirecolor = color 176 26 26
	local CALLBACKS_ENABLED = true
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
	--select list nodes by type
	fn selectNodesByType type = (
	
		local key = case type of (
		
			"coll": "_coll"
			"geo": "_geometry"
		)
		local index_arr = for i = 1 to cbx_node_list.items.count where (
		
			findString cbx_node_list.items[i] key != undefined
			
		) collect i
		cbx_node_list.selection = index_arr
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
	
	fn initializeInterface = (
		
		local node_names = fillNodesList()
		if node_names.count == 0 do return false
		fillChildrenList node_names[1]	
		updateSelection()
	)
	
	fn updateScene = (
		
		initializeInterface()
		if chk_auto_trace_node.checked do (
			
			autosel = on
			updateSelection()	
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
	
	--distribute geometry in to layers
	fn moveGeometryInToSeparateLayer = (
		
		for o in selection do (

			if o.parent == undefined do (

				format "Error > Unable move geometry [ % ] which is not linked\n" o.name
			)
			local layer_name = substring o.parent.name 1 (findString o.parent.name "_geometry")
			layer_name += "terrain"
			local layer = layerManager.getLayerFromName layer_name
			if layer == undefined do (

				format "Error > Unable move geometry [ % ] in to layer [ % ] which not exists\n" o.name layer_name
				continue
			)
			
			format "Move geometry [ % ] in to layer [ % ]\n" o.name layer_name
			layer.addNode o
		)
	)
	
	fn generateSimpleCollisions = (
		
		mcFile.initStruct gTerrainGeneratorCollision "LS3D_Terrain_Collisions_Generator" force:force_load_structures
		if ::gTerrainGeneratorCollision != undefined and queryBox "Do you want to generate Simple Collisions?" title:"Warning:" do (
		
			gTerrainGeneratorCollision.generateSimpleCollisions()
		)
		updateScene()
	)
	fn generateTerrainCollisions = (

		mcFile.initStruct gTerrainGeneratorCollision "LS3D_Terrain_Collisions_Generator" force:force_load_structures
		if ::gTerrainGeneratorCollision != undefined and queryBox "Do you want to generate Terrain Collisions?" title:"Warning:" do (
		
			gTerrainGeneratorCollision.generateTerrainCollisions()
		)
		updateScene()
	)
	fn generateRoadsCollisions = (
	
		mcFile.initStruct gRoadGeneratorCollision "LS3D_Road_Collisions_Generator" force:force_load_structures
		if ::gRoadGeneratorCollision != undefined and queryBox "Do you want to generate Road Collisions?" title:"Warning:" do (
		
			::gRoadGeneratorCollision.generateRoadCollisions()
		)
		updateScene()
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
		if not CALLBACKS_ENABLED do return false
		--btn_update
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
		if not CALLBACKS_ENABLED do return false
		if cbx_children_list.items.count == 0 do return false
		local data = callbacks.notificationParam()	
		local new_name = data[1]
		local sel_index = (cbx_children_list.selection as array)[1]
		if sel_index != undefined do (
			
			cbx_children_list.items[sel_index] = new_name
			cbx_children_list.items = cbx_children_list.items --refresh list
		)
	)

	fn isCollision obj = ( --at start or end is _coll_
		
		findString obj.name "coll_" != undefined or findString obj.name "_coll"	!= undefined 
	)
	fn isRoadCollision obj = (
	
		local crossForuCheck 		= matchPattern obj.name pattern:"coll_generator_crossroad_4*"
		local crossThreeCheck		= matchPattern obj.name pattern:"coll_generator_crossroad_3*"
		local roadCheck					= matchPattern obj.name pattern:"coll_generator_connect_road*"
		local customRoadCheck	= matchPattern obj.name pattern:"coll_custom_road*"
		if  crossForuCheck or crossThreeCheck or roadCheck or customRoadCheck then true else false
	)
	
	fn isRoadGeometry obj = (
		
		local crossForuCheck		= matchPattern obj.name pattern:"generator_crossroad_4*"
		local crossThreeCheck		= matchPattern obj.name pattern:"generator_crossroad_3*"
		local roadCheck					= matchPattern obj.name pattern:"generator_connect_road*"
		local customRoadCheck	= matchPattern obj.name pattern:"custom_road*"	
		if  crossForuCheck or crossThreeCheck or roadCheck or customRoadCheck then true else false
	)
	
	fn selectCollisionsByType onlyVisisble:false = (
		
		local objs = #()
		if onlyVisisble then (
			
			objs = for o in objects where not o.isHidden collect o
				
		) else (
		
			objs = objects	
		)
-- 		local colls = for o in objects where findString o.name "coll_"	!= undefined collect o
		if not chk_sel_coll_terrain.checked and not chk_sel_coll_roads.checked do (
			
				subobjectlevel=0
				max select none
				return OK
		)
		local colls = #()
		for o in objs do ( --filter collisions by type
			
			if not (isCollision o) do continue
			if chk_sel_coll_roads.checked and ( isRoadCollision o ) do  (
				
				append colls o
				continue
			)	
			
			if chk_sel_coll_terrain.checked and not ( isRoadCollision o ) do  (
				
				append colls o
				continue
			)	
			
-- 			if findString o.name "coll_"	== undefined do continue
-- 			if not chk_sel_coll_terrain.checked and findString o.name "generator_" == undefined do continue
-- 			if not chk_sel_coll_roads.checked and findString o.name "generator_" != undefined do continue
-- 			append colls o
		)
		select colls
	)
	
	fn selectGeometryByType  onlyVisisble:false = (
		
		local objs = #()
		if onlyVisisble then (
			
			objs = for o in objects where not o.isHidden collect o
				
		) else (
		
			objs = objects	
		)
--TODO
--filter only geometry --maybe some users have splines as geometry
-- objs  = for o in objs where superClassOf o == GeometryClass collect o
		
		if not chk_sel_geo_terrain.checked and not chk_sel_geo_roads.checked do (
			
				subobjectlevel=0
				max select none
				return OK
		)
		local geo = #()
		for o in objs do ( --filter collisions by type
			
			if (isCollision o) do continue
			if chk_sel_geo_roads.checked and ( isRoadGeometry o ) do  (
				
				append geo o
				continue
			)	
			
			if chk_sel_geo_terrain.checked and not ( isRoadGeometry o ) do  (
				
				append geo o
				continue
			)	
		)
		select geo
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
	fn inspectNodesPath = (
	
		for o in selection where classOf o == LS3DModel do format "Export Path:%\n" o.OutputPath
	)
	fn checkForDupplicatedNamesInScene = (

		local OD = struct OBJECT_DATA (obj, dupes)
		local database = #()
		for o in objects do (

			local found = false
			for d in database where d.obj.name == o.name do (append d.dupes o; found = true)
			if not found do append database (OD o #(o))
		)
		local dupplicate_objs = #()
		for d in database where d.dupes.count  > 1 do join dupplicate_objs d.dupes
		format "Dulicated Objects List:\n"
		for o in dupplicate_objs do format "\t%\n" o.name
		messageBox ("Found ( "+dupplicate_objs.count as string+" )  duplicated objects.\nPress Unique names Fix roe Repair.") title:"Dupple Inspector"
		select dupplicate_objs
	)
	fn hideUnhideSelection = (
	
		local sel = selection as Array
		if sel.count == 0 do return false
		local is_hidden= sel[1].isHidden
		for o in sel do o.isHidden = not is_hidden
	)
	fn showObjectsByNamePart obj_array name_part state = (
		
		for o in obj_array where findString o.name name_part != undefined do o.isHidden = not state
	)
	fn fixDupplicetedNamesInSelection = (
		
		needUpdate()
		for o in selection do o.name = uniqueName o.name
		messageBox "Dupplicated names has been fixed on selection" title:form_title
	)
	
	fn runCommandByName cmd_name = (
		
		format "RUN CMD:%\n" cmd_name
		case cmd_name of (
			
			"Generate Player and Car Collisions" : if queryBox "Generate Player and Car Collisions?" title:"Organize:" do (
				
				undo "Create Car and Player Collision" on ::gCityManager.createCarAndPlayerCollisions()
			)
			"Select Visible Lodes 2"  : (
				
				undo "Create Car and Player Collision" on ::gCityManager.selectVisibleNodesByName "lod2"
			)
			"Add Terrain Lodes 2 and Fix Pivot"  : if queryBox "Add Terrain Lodes 2 and Fix Pivot in Selection?" title:"Organize:" do (
				
				undo off ::gCityManager.addTerrainLodes2AndFixPivot (selection as array)
			)
			"Add Lodes Custom"  : (
				---TODO
				--mcFile.initStruct ls3dLodManagerDialog "LS3D_LOD_Manager" force:force_load_structures
				fileIn (micra.RootDir + "LS3D_LOD_Manager.ms")
			)
			"Destroy Lods in Selection" : (

				undo off ::gCityManager.destroyLodsInSelection()
			)
			"Curb Crumple" : (

				fileIn (micra.RootDir + "LS3D_Curb_Crumple.ms")
			)			
				"Collision Optimizer" : (

				fileIn (micra.RootDir + "LS3D_Collisions_Optimizer_v0.02.ms")
			)
		)
	)
	
	fn init = (
		
		--load advanced actions
		mcFile.initStruct gCityManager "City_Manager_Struct" force:force_load_structures
		edt_sh_name.text = "building" 
		mcCityManDialog.title = form_title
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
	
	--load node children
	on cbx_node_list selected sel do
	(
	
		local sel_items = cbx_node_list.selection as array
		if sel_items.count > 1 then (
		
			format "MULTI  > sel:%\n" sel_items.count
			cbx_children_list.items = #()	
			lbl_objects.text = "()"
		
		) else if sel_items.count == 1 do (
		
			local node_name = cbx_node_list.items[sel_items[1]]
			fillChildrenList node_name
			format "SINGLE  > sel:%\n" node_name
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
		CALLBACKS_ENABLED = false
        --get selecten nodes fom list
        local sel_names = getSelectedItems cbx_node_list
        if sel_names.count == 0 do return false
        --backup selection
        local old_sublevel = if subObjectLevel == undefined then -1 else subObjectLevel
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
        if old_sublevel > -1 do (
        
            max modify mode
            subObjectLevel = old_sublevel
        )
		CALLBACKS_ENABLED = true
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
	on btn_update pressed do (updateScene())
	on mcCityManDialog open do (init())
	on mcCityManDialog close do 
	(
		callbacks.removescripts id:#micra_callbacks_cityman		
	)
	on btn_move_colls_to_layers pressed do (if queryBox "Distribute Collisions in to separate layers?" title:"Organize:" do moveCollisionsInToSeparateLayer() )
	on btn_move_geo_to_layers pressed do (if queryBox "Distribute Geometry in to separate layers?" title:"Organize:" do moveGeometryInToSeparateLayer() )
	on btn_select_visible_nodes pressed do ( select(for o in objects where not o.ishidden collect o) )
	on btn_filter_visible_nodes pressed do ( select(for o in selection where not o.ishidden collect o) )
	on btn_generate_coll pressed do generateSimpleCollisions()
	on btn_sel_colls pressed do selectCollisionsByType()
	on btn_sel_vis_colls pressed do selectCollisionsByType onlyVisisble:true
	on btn_sel_geo pressed do selectGeometryByType()
	on btn_sel_vis_geo pressed do selectGeometryByType onlyVisisble:true
	on btn_select_empty_objects pressed do selectObjectsWithoutGeometry()
	on btn_inspect_nodes pressed do inspectNodesPath()
	on btn_unique_check pressed do checkForDupplicatedNamesInScene()
	on btn_unique_fix pressed do undo "Hide Selected" on fixDupplicetedNamesInSelection()
	on btn_hide_sel pressed do undo "Unhide Selected" on (for o in selection do o.isHidden = true)
	on btn_unhide_sel pressed do (for o in selection do o.isHidden = false)
	on btn_generate_terrain_coll pressed do generateTerrainCollisions()
	on btn_generate_roads_coll pressed do generateRoadsCollisions()
	on btn_show_objs pressed do ( showObjectsByNamePart objects edt_sh_name.text true	)
	on btn_hide_objs pressed do ( showObjectsByNamePart objects edt_sh_name.text false	)
	on btn_sel_geo_nodes pressed do ( selectNodesByType "geo"	)
	on btn_sel_coll_nodes pressed do ( selectNodesByType "coll")
	on btn_run_fn pressed do (runCommandByName ddl_fn_list.selected )
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