Global mcCityManDialog
Global mcCityManDialogMenu
rcmenu mcCityManDialogMenu (
	subMenu "Visibility" (
		menuItem m2_2 "Show All Objects"
		menuItem m2_1 "Hide All  Objects"
		separator m2_sep_1
		menuItem m2_4 "Show Selection"
		menuItem m2_3 "Hide Selection"
	)
	subMenu "Lods"(
		menuItem m1_0 "Select All Lods 1 - 2  "
		separator m1_sep_0
		menuItem m1_1 "Select All Lods 0 "
		menuItem m1_2 "Select All Lods 1"
		menuItem m1_3 "Select All Lods 2"
		separator m1_sep_1
		menuItem m1_4 "Select Visible Lods 0"
		menuItem m1_5 "Select Visible Lods 1"
		menuItem m1_6 "Select Visible Lods 2"
		separator m1_sep_2
		menuItem m1_7 "Select Lode 1 from Object"
		menuItem m1_8 "Select Lode 2 from Object"
		separator m1_sep_3
		menuItem m1_9 "Select Lods 1 for whole Block"
		menuItem m1_10 "Select Lods 2 for whole Block"
		separator m1_sep_4
		menuItem m1_11 "Generate Lods Custom"
		menuItem m1_12 "Destroy Lods in Selection" 
	)
	subMenu "Occ Planes"(
		menuItem m3_1 "Select All Occ "
		menuItem m3_2 "Select Visible Occ"
		separator m3_sep_1
		menuItem m3_3 "Generate Occ Custom"
		menuItem m3_4 "Setup Occ Data Manager"
	)
	subMenu "Collisions"(
		menuItem m4_1 "Select All Collisions "
		menuItem m4_2 "Select Visible Collisions"
		separator m4_sep_1
		menuItem m4_3 "Generate Player and Stairs Collisions ( Link to Node )" tooltip:"Two Nodes" --checked:true checked = Two Nodes  else Single Node
		menuItem m4_4 "Generate Player and Stairs Collisions ( Link to Object )" tooltip:"Single Node"
		separator m4_sep_2
		menuItem m4_5 "Quick Semantic Materials"
		separator m4_sep_3
		menuItem m4_6 "Link Collision(s) to closest Object and Fix Name"
		menuItem m4_7 "Instance Collision to Selected Models"
	)
	subMenu "Modify" (
	
		menuItem m5_1 "Geometry Optimizer" 
		menuItem m5_2 "Curb Crumple"
	)
	subMenu "Find" (
	
		menuItem m6_0 "Find Unlinked Objects"
		menuItem m6_3 "Find Objects Without Lods"
		menuItem m6_4 "Find Duplicated Objects"
		menuItem m6_1 "Find Instances Unique"
		menuItem m6_2 "Find Instances and Objects Unique"
		menuItem m6_5 "Find Lod 0"
	)
	subMenu "Advanced"(
	
		menuItem m9_1 "Select All Objects By Material"
		menuItem m9_2 "Select All Objects By Material ID"
		separator m9_sep_1
		menuItem m9_3 "Select Visible Objects By Material"
		menuItem m9_4 "Select Visible Objects By Material ID"
		separator m9_sep_2
		menuItem m9_5 "Fix Names Suffix"
		separator m9_sep_3
		menuItem m9_6 "Reset Material Editor And Load Materials From Selection"
	)
	fn getLodByName obj lod_index = (
	
		local lod_name = mcString.replaceEnd obj.name "lod0" ("lod"+ lod_index as string) ignoreCase:true
		local lod_obj = getNodeByName lod_name
		if lod_obj == undefined do format "Missing LOD% on:%\n" lod_index obj.name
		lod_obj
	)
	fn selectLodByIndex lod_index = (
	
		local obj = selection[1]
		if obj == undefined do return false
		local lod_node = getLodByName obj lod_index
		if lod_node != undefined then select lod_node else max select none
	)
	fn selectLodesByNode lod_index = (
	
		local obj = selection[1]
		if obj == undefined do return false
		max select none
		local obj_node = obj.parent
		if classOf obj_node != LS3DModel do return false
		local lodes = #()
		for o in obj_node.children do (
			if findString (
					local name_arr = filterString o.name "_"
					toUpper name_arr[name_arr.count]
			) "LOD0" == undefined do continue
			local lod_node = getLodByName o lod_index
			if lod_node != undefined do appendIfUnique lodes lod_node
		) 
		select lodes
	)
	fn selectLods suffix_arr visibleOnly:false = (
	
		select(for o in objects where (
			findString (toUpper o.name) suffix_arr[1] != undefined or findString (toUpper o.name) suffix_arr[2]  != undefined
		) collect o)
	)
	--Cutom Attributes D:\!2k_games\scotch_dev\code\srcTools\modules\ToolMAX\3dsmax\scripts\LS3DData\Shadows.ms
	fn addAttributeShadowTo objs state = (
		gProgLog.msg "@" --clear log
		gProgLog.progSub 0 0
		gProgLog.msg "OCC Data Manager Setup:" ti:"Initialize...." ty:"new_task"
		gProgLog.msg "Proces Start" ti:"3DsMax..." ty:"task_open"
		for i=1 to objs.count do (
			
			local obj = objs[i]
			if superClassOf obj != GeometryClass or findString (toUpper obj.name) "OCC" == undefined do continue 
			if (getCustomAttributeByName obj "Shadows") == undefined do (
			
				AddCustomAttributeByName obj "Shadows"
			) 
			obj.'~Cast Shadows' = state
			gProgLog.progSub i objs.count
			gProgLog.msg ("progress obj:"+obj.name) ty:"proc"
		)
		gProgLog.progSub objs.count objs.count
		gProgLog.msg "All Done" ty:"task_close"
	)
	fn linkCollisionsByClosestObjectAndFixName = (

		local visible_objs = for o in objects where not o.isHidden collect o
		local cols = selection as array
		for c in cols do (

			local closest_obj = undefined
			local closest_dist = 9999999
			for o in visible_objs where (
			
				findString (toUpper o.name) "LOD0" != undefined and
				findString (toUpper o.name) "COLL" == undefined and
				c.name != o.name
			
			) do (
			
				local dist = distance c.pos o.pos
				if dist < closest_dist do (

					closest_obj = o
					closest_dist = dist
				)
			)
			if closest_obj != undefined then  (
			
				local base_name = mcString.cutRight closest_obj.name trimChars:"_lod0" ignoreCase:true
				c.name = base_name + "_coll"
				c.parent = closest_obj
				
			) else (
			
				format "Skiped collision obj:% dist:%\n" closest_obj.name closest_dist
			)
		)
	)
	fn distributeInstancesInToSelection = (
	
			Global mcCollisionInsancerDialog
			if mcCollisionInsancerDialog != undefined do destroyDialog mcCollisionInsancerDialog
			rollout mcCollisionInsancerDialog "Collision Instancer:" width:516 height:84 (
			groupBox 'grp1' "Actions:" pos:[4,4] width:508 height:76 align:#left
			button 'btn_get_coll' "Get Collision Prototype" pos:[8,20] width:128 height:24 align:#left
			button 'btn_distribute_cols' "Instance Collision to Selected Models" pos:[8,48] width:496 height:24 align:#left
			label 'lbl_coll' "undefined" pos:[140,24] width:364 height:20 align:#left
			local coll_obj = undefined
			fn getCollision = (
				local sel_obj = selection[1]
				if sel_obj != undefined and superClassOf sel_obj == GeometryClass and 
				sel_obj.material.name == "semantic_materials"  then (
					
					coll_obj = sel_obj
					lbl_coll.text = "Collision: " + sel_obj.name	
				) else (
					messageBox "Invalid Object or Object without Semantic Material" title:"Warning"
				)
			)
			fn distributeCollisionsOnSelection = (
				if coll_obj == undefined do return false
				for o in selection do (
					
					local new_coll_obj = instance coll_obj
					local base_name = mcString.cutRight o.name trimChars:"_lod0" ignoreCase:true
					new_coll_obj.name = base_name + "_coll"
					new_coll_obj.pos = o.pos
					mcTransform.setRotation new_coll_obj (mcTransform.getRotation o)
					new_coll_obj.parent = o
				)	
			)
			on btn_get_coll pressed do getCollision()
			on btn_distribute_cols pressed do undo "Instance Collisions" on distributeCollisionsOnSelection()
		)
		createDialog mcCollisionInsancerDialog
	)
	fn fixNamesSuffix undo_lbl = (
	
		Global suffixNameFixerDialog
		if suffixNameFixerDialog != undefined do destroyDialog suffixNameFixerDialog
		rollout suffixNameFixerDialog "Suffix Name Fixer" width:248 height:56
		(
			groupBox 'grp2' "Actions:" pos:[4,4] width:240 height:48 align:#left
			dropDownList 'ddl_suffix' "" pos:[52,22] width:100 height:21 items:#("lod0", "lod1", "lod2", "lod3", "coll", "occ") align:#left
			label 'lbl2' "suffix:" pos:[12,25] width:36 height:20 align:#left
			button 'btn_fix_names' "Fix" pos:[160,20] width:76 height:24 align:#left
			local undo_lbl
			fn fixNames  = (
				if not (queryBox "Fix Names Suffix" title:"Warning:") do return false
				mcCityManDialog.CALLBACKS_ENABLED = false
				undo label:undo_lbl on with redraw off(
					local suff = toLower ddl_suffix.selected
					for o in selection do (
					
						local name_arr = filterString o.name "_" --break name in to lelements
						if name_arr.count > 1 then ( --remove elements contains pattern(ddl_suffix.items)
							local filtered_name = mcArray.filterWords name_arr ddl_suffix.items ignoreCase:true
							local new_name = mcArray.joinToString filtered_name "_" --condense array in to string
							o.name = uniqueName new_name
							
						) else (
							o.name = uniqueName o.name
						)
					)
				)
				--must be new loop else names result is not unique
				for o in selection do o.name += "_"+ suff --add desired suffix 
				mcCityManDialog.CALLBACKS_ENABLED = true
				completeRedraw()
			)
			on btn_fix_names pressed  do fixNames()
		)
		createDialog suffixNameFixerDialog
		suffixNameFixerDialog.undo_lbl = undo_lbl
	)
	fn resetMaterialEditorAndLoadMaterialsFromSelection = (
	
		local sel = selection as array
		if sel.count == 0 do return false
		mcMax.deselectAll()
		local matedit_state = MatEditor.isOpen()
		if matedit_state do MatEditor.Close()
		for i = 1 to 24 do (											
			--getMeditMaterial i					
			setMeditMaterial i (standard())
			mEditMaterials [i].name = i as string + " - Default"
		)
		local mats = #()
		for o in sel where o.material != undefined do appendIfUnique mats o.material
		for i = 1 to mats.count do setMeditMaterial i mats[i]
		MatEditor.Open()
		select sel
	)
	--m1------------------------------------------------------------------------------------------------
	on m1_0 picked do undo label:(m1_0.Text) on selectLods(#("LOD1", "LOD2"))
	on m1_1 picked do undo label:(m1_1.Text) on mcMax.selectObjectsByName "LOD0" visibleOnly:false exclude:#("coll", "occ")
	on m1_2 picked do undo label:(m1_2.Text) on mcMax.selectObjectsByName "LOD1" visibleOnly:false exclude:#("coll", "occ")
	on m1_3 picked do undo label:(m1_3.Text) on mcMax.selectObjectsByName "LOD2" visibleOnly:false exclude:#("coll", "occ")
	--sep1
	on m1_4 picked do undo label:(m1_4.Text) on mcMax.selectObjectsByName "LOD0"  exclude:#("coll", "occ")
	on m1_5 picked do undo label:(m1_5.Text) on mcMax.selectObjectsByName "LOD1"  exclude:#("coll", "occ")
	on m1_6 picked do undo label:(m1_6.Text) on mcMax.selectObjectsByName "LOD2"  exclude:#("coll", "occ")
	--sep2
	on m1_7 picked do undo label:(m1_7.Text) on selectLodByIndex 1
	on m1_8 picked do undo label:(m1_8.Text) on selectLodByIndex 2 --::gCityManager.selectVisibleNodesByName "lod2"
	--sep3
	on m1_9 picked do undo label:(m1_9.Text) on selectLodesByNode 1
	on m1_10 picked do undo label:(m1_10.Text) on selectLodesByNode 2
	--sep4
	on m1_11 picked do fileIn (micra.RootDir + "LS3D_LOD_Manager.ms")
	on m1_12 picked do if (queryBox "Destroy Lodes on Selection?" title:"Warning:") do undo off ::gCityManager.destroyLodsInSelection()
	--m2------------------------------------------------------------------------------------------------
	on m2_1 picked do undo label:(m2_1.Text) on mcMax.hideAll()
	on m2_2 picked do undo label:(m2_2.Text) on mcMax.unhideAll()
	--sep2
	on m2_3 picked do undo label:(m2_3.Text) on mcMax.hideSelected()
	on m2_4 picked do undo label:(m2_4.Text) on mcMax.unhideSelected()
	--m3------------------------------------------------------------------------------------------------
	on m3_1 picked do undo label:(m3_1.Text) on mcMax.selectObjectsByName "OCC" visibleOnly:false
	on m3_2 picked do undo label:(m3_2.Text) on mcMax.selectObjectsByName "OCC"
	on m3_3 picked do  mcFile.fileInVersion "Geometry_Projector2D"
	on m3_4 picked do if (queryBox "Setup OCC Data Manager?" title:"Warning:") do undo off addAttributeShadowTo (selection as array) false
	--m4------------------------------------------------------------------------------------------------
	on m4_1 picked do undo label:(m4_1.Text) on mcMax.selectObjectsByName "COLL" visibleOnly:false
	on m4_2 picked do undo label:(m4_2.Text) on mcMax.selectObjectsByName "COLL"
	--sep1
	on m4_3 picked do if queryBox "Generate Stairs Collisions?" title:"Create:" do undo label:(m4_3.Text) on ::gCityManager.createCarAndPlayerCollisions twoNodes:true
	on m4_4 picked do if queryBox "Generate Stairs Collisions?" title:"Create:" do undo label:(m4_4.Text) on ::gCityManager.createCarAndPlayerCollisions twoNodes:false
	--sep2
	on m4_5 picked do fileIn (micra.RootDir + "LS3D_Quick_Semantics.ms")
	--sep3
	on m4_6 picked do if (queryBox "Link Selected Collision(s) to closest LOD0 and Rename?" title:"Warning:") do undo label:(m4_6.Text) on linkCollisionsByClosestObjectAndFixName()
	on m4_7 picked do distributeInstancesInToSelection()
	--m5------------------------------------------------------------------------------------------------
	on m5_1 picked do fileIn (micra.RootDir + "LS3D_Geometry_Optimizer_v0.03.ms")
	on m5_2 picked do fileIn (micra.RootDir + "LS3D_Curb_Crumple.ms") 
	--m6------------------------------------------------------------------------------------------------
	on m6_0 picked do undo label:(m6_0.Text) on (
		local unlinked_objs = for o in selection where o.parent == undefined collect o
		if unlinked_objs.count > 0 then select unlinked_objs else max select none
	)
	on m6_1 picked do undo label:(m6_1.Text) on mcMax.selectUniqueInstances selection
	on m6_2 picked do undo label:(m6_2.Text) on mcMax.selectUniqueInstances selection appendSingles:true
	on m6_5 picked do undo label:(m6_5.Text) on (
	
		local obj = selection[1]
		if obj != undefined do (
		
			local base_name = mcString.cutRight obj.name trimChars:"_lod1" ignoreCase:true
			local lod0_obj = getNodeByName(base_name + "_lod0")
			if lod0_obj != undefined do select lod0_obj
		)
	)
	on m6_3 picked do undo label:(m6_3.Text) on (
		local sel = selection as array
		local no_lod_objs =  (for o in sel where (
			select o
			LS3DGUP.LODU.GetNumLODs() == 0 
		) collect o)
		if no_lod_objs.count > 0 then select no_lod_objs else max select none
	)
	on m6_4 picked do undo label:(m6_4.Text) on (
	
		local sel = selection as array
		local dupe_objs = #()
		for a in sel do (
			local objs = for b in sel where (
			
				a.pos == b.pos and mcPoly.getObjectArea a == mcPoly.getObjectArea b 
			) collect b
			if objs.count > 1 do (
				deleteItem objs 1
				join dupe_objs objs
			)
		)
		if dupe_objs.count > 0 then select dupe_objs else max select none
	)
	--m9------------------------------------------------------------------------------------------------
	on m9_1 picked do undo label:(m9_1.Text) on mcMax.selectObjectsByMaterial visibleOnly:false
	on m9_2 picked do undo label:(m9_2.Text) on mcMax.selectObjectsByMaterialID visibleOnly:false --pick first id if not face selected
	--sep1
	on m9_3 picked do undo label:(m9_3.Text) on mcMax.selectObjectsByMaterial()
	on m9_4 picked do undo label:(m9_4.Text) on mcMax.selectObjectsByMaterialID() --pick first id if not face selected
	--sep2
	on m9_5 picked do fixNamesSuffix m9_5.Text
	--sep3
	on m9_6 picked do undo label:(m9_6.Text) on resetMaterialEditorAndLoadMaterialsFromSelection()
)

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
	
		"Add Terrain Lodes 2 and Fix Pivot",
		"All was moved in to Top Menu"
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
		
			::gTerrainGeneratorCollision.generateSimpleCollisions(ddl_collision_type.selection == 1)
		)
		updateScene()
	)
	fn generateTerrainCollisions = (

		mcFile.initStruct gTerrainGeneratorCollision "LS3D_Terrain_Collisions_Generator" force:force_load_structures
		if ::gTerrainGeneratorCollision != undefined and queryBox "Do you want to generate Terrain Collisions?" title:"Warning:" do (
		
			::gTerrainGeneratorCollision.generateTerrainCollisions(ddl_collision_type.selection == 1)
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
		local hint = if dupplicate_objs.count > 0 then "\nPress Unique names Fix or Repair." else ""
		messageBox ("Found ( "+dupplicate_objs.count as string+" )  duplicated objects." + hint) title:"Dupple Inspector:"
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
			
			"Add Terrain Lodes 2 and Fix Pivot"  : if queryBox "Add Terrain Lodes 2 and Fix Pivot in Selection?" title:"Organize:" do (
				
				undo off ::gCityManager.addTerrainLodes2AndFixPivot (selection as array)
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
		callbacks.addScript #selectedNodesPreDelete		"mcCityManDialog.needUpdate()"					id:callbacks_id
		callbacks.addScript #nodeCreated				"mcCityManDialog.needUpdate()"					id:callbacks_id
		callbacks.addScript #nodeCloned					"mcCityManDialog.needUpdate()"					id:callbacks_id
		callbacks.addScript #sceneNodeAdded				"mcCityManDialog.needUpdate()"					id:callbacks_id
		callbacks.addScript #nodeRenamed				"mcCityManDialog.nodeRenamed()"					id:callbacks_id
		--select node in list
		updateSelection()	
	)
	
	fn fin = (
	
		callbacks.removescripts id:#micra_callbacks_cityman		
		mcFile.saveDialogSettings "mcCityManDialog" "Properties_2" --save form position after close
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
	on mcCityManDialog close do (fin())

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

--Open dialog at pos
(
	local form_settings = mcFile.readDialogSettings "mcCityManDialog" "Properties_2" --get saved pos and size
	if form_settings != undefined then (

		createDialog mcCityManDialog pos:(execute (form_settings.get "pos")) menu:mcCityManDialogMenu
		
	) else (
	
		createDialog mcCityManDialog menu:mcCityManDialogMenu
	)
)

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


/*
fn fixNames  = (
				if not (queryBox "Fix Names Suffix" title:"Warning:") do return false
				mcCityManDialog.CALLBACKS_ENABLED = false
				undo label:undo_lbl on with redraw off(
					local suff = toLower ddl_suffix.selected
					for o in selection do (
					
						local new_name = o.name + "_"
						local name_arr = filterString new_name "_" --break name in to lelements
						if name_arr.count > 1 do ( --check each element for suffix exists
						
							new_name = ""
							for str in name_arr where (
							
								local match_count = 0
								for su in ddl_suffix.items where ( --check all suffixes
								
									(mcString.indexOf str su ignoreCase:true) != undefined
									
								) do match_count+=1
								
								match_count == 0
								
							) do new_name += str + "_"
						)
						o.name = new_name + suff --add desired suffix
					)
				)
				mcCityManDialog.CALLBACKS_ENABLED = true
				completeRedraw()
			)
*/

/*
if name_arr.count > 1 then (

	local filtered_name = for s in name_arr where (
		
		local found_count = 0
		for f in ddl_suffix.items do (
			
			if findString s f != undefined do found_count +=1
		)
		found_count == 0
		-- not (mcArray.isAnyArrayItemInString ddl_suffix.items s ignoreCase:true)
	) collect s
	--format "name:% filtered_name:%\n" o.name filtered_name
	local new_name = mcArray.joinToString filtered_name "_"
	o.name = new_name +"_"+ suff --add desired suffix
) else (

	o.name = o.name +"_"+ suff --add desired suffix
)
*/