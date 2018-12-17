--------------------------------------------------------------------------
		/*MORPH COLLECTOR MANAGER*/
					    /*2012*/
--------------------------------------------------------------------------


Global mcMorphCollectorDialog
Global morphCollectorMarkers =#()
Global drawMorphCollectorMarkers
Global morphCollectorRingData
Global MorphCollector



(
if mcMorphCollectorDialog != undefined do destroyDialog mcMorphCollectorDialog
rollout mcMorphCollectorDialog "Morph Collector Manager:" width:228 height:480
(
	local morph_obj , current_edge
	local clr_ring= color 0 128 131, clr_ring_active = color 255 82 0, clr_edge = color 233 45 233, clr_edge_active = green--color 72 108 245
	fn isMeshOrPoly obj=(classOf obj.baseobject == Editable_Mesh or classOf obj.baseobject == Editable_Poly)
	fn isMorphTagger obj = 
	(
		(classOf obj == MorphTagger or classOf obj == Dummy or classOf obj == MorphDummy) and \
		findItem mcMorphCollectorDialog.lbx_rings.items obj.name == 0
	)
	struct MORPH_DATA(ring, tags=#(), points=#())
	GroupBox grp1 "Collect Control Meshes:" pos:[4,4] width:220 height:472
	button btn_create_morphs "Create Morph From Selection" pos:[8,356] width:212 height:24
	pickbutton btn_add_morph "Add New Control Object" pos:[8,384] width:212 height:24 filter:isMeshOrPoly
	button btn_transfer_points "Transfer Ring Points" pos:[8,412] width:212 height:24 enabled:false
	listbox lbx_ctrl_obj "Control Objects:" pos:[8,68] width:212 height:18
	dropdownList ddl_morph_obj "Morpher:" pos:[8,24] width:212 height:40
	GroupBox grp_rings "Rings:" pos:[228,4] width:220 height:472
	GroupBox grp_edges "Edges:" pos:[452,4] width:220 height:472
	listbox lbx_edges "" pos:[456,24] width:212 height:32
	button btn_add_edge "Add" pos:[456,448] width:68 height:24
	button btn_remove_edge "Remove" pos:[528,448] width:68 height:24
	button btn_commit "Commit" pos:[600,448] width:68 height:24
	pickbutton btn_ring_add "Add" pos:[232,420] width:68 height:24 filter:isMorphTagger
	checkbutton chk_add_edges "Manage Edges >>" pos:[232,448] width:212 height:24
	checkbutton chk_add_rings "Manage Points >>" pos:[8,448] width:212 height:24
	listbox lbx_rings "" pos:[232,24] width:212 height:28
	button btn_ring_remove "Remove" pos:[304,420] width:68 height:24
	button btn_ring_rename "Rename" pos:[376,420] width:68 height:24
	edittext edt_ring_rename "" pos:[228,396] width:216 height:20
	button btn_copy_pose "Copy Pose" pos:[8,328] width:68 height:24
	button btn_paste_pose " Paste Pose" pos:[80,328] width:68 height:24
	button btn_save_pose "Save Pose" pos:[152,328] width:68 height:24
	fn drawMorphCollectorMarkers = 
	(	
		gw.setTransform(Matrix3 1)
		for d in morphCollectorMarkers do for p in d.points do 
		(
			local p = gw.hTransPoint p
			gw.hMarker p #hollowBox color:orange
			gw.hMarker p #asterisk color:yellow
		)
		gw.enlargeUpdateRect #whole
		gw.updateScreen()
	)
	fn drawMorphEdgeManagerEdges = 
	(	
		gw.setTransform(Matrix3 1)
		fn drawLine col str=
		(
			local flt=filterString str ", "
			local obj_1 = getNodeByName flt[1]
			local obj_2 = getNodeByName flt[2]
			if not isValidNode obj_1 or not isValidNode obj_2 do return false 
			local p1 = gw.hTransPoint obj_1.pos
			local p2 = gw.hTransPoint obj_2.pos
			gw.hPolyline #(p1, p2) false rgb:#(col, col) 
		)
		for i in lbx_edges.items do drawLine clr_edge i --177 148 27
		local sel_edge = lbx_edges.selected
		if sel_edge != undefined do drawLine clr_edge_active sel_edge --yellow
		gw.enlargeUpdateRect #whole
		gw.updateScreen()
	)
	fn updateUI=
	(
		btn_add_morph.enabled = morph_obj != undefined and MorphObj_GetNTargets morph_obj != 0
		btn_create_morphs.enabled =  lbx_ctrl_obj.items.count == 0
		chk_add_rings.enabled =  lbx_ctrl_obj.items.count != 0
		chk_add_edges.enabled = lbx_rings.items.count != 0
		btn_copy_pose.enabled = btn_paste_pose.enabled = btn_save_pose.enabled =  lbx_ctrl_obj.items.count != 0
		if morph_obj != undefined do btn_transfer_points.enabled = (MorphObj_GetNPoints morph_obj) != 0
	)
	fn getGedgeByString str=
	(
		local flt=filterString str ", "
		local obj_1 = getNodeByName flt[1]
		local obj_2 = getNodeByName flt[2]
		if not isValidNode obj_1 or not isValidNode obj_2 do return #()
		#(gw.hTransPoint obj_2.pos, gw.hTransPoint obj_1.pos)
	)
	fn getHierarchyData =
	(
		if classOf morph_obj != MorphObj2 do return false
		local nEdges = MorphObj_GetNEdges morph_obj
		local edges_array = #()
		for ed = 0 to (nEdges-1) do 
		(
			local p0 = (MorphObj_GetEdgePoint0 morph_obj ed) ;
			local p1 = (MorphObj_GetEdgePoint1 morph_obj ed) ;
			edges_array += #(MorphObj_GetPointName morph_obj p0+", "+MorphObj_GetPointName morph_obj p1)	
		)
		lbx_edges.items = edges_array 
	)
	fn openCloseEdgeDialog state=
	(
		case state of 
		(
			true : --open 
			(
				for e = 450 to 676 by 5 do (mcMorphCollectorDialog.width = e; sleep 0.002)
				chk_add_edges.text = "<< Manage Edges" 
				getHierarchyData()
				unregisterRedrawViewsCallback drawMorphEdgeManagerEdges
				registerRedrawViewsCallback drawMorphEdgeManagerEdges
			)
			false : --close
			(
				for f = 676 to 450 by -5 do (sleep 0.002; mcMorphCollectorDialog.width = f)
				chk_add_edges.text = "Manage Edges >>" 
				unregisterRedrawViewsCallback drawMorphEdgeManagerEdges
			)
		)
		completeRedraw()
	)
	fn openCloseRingDialog state=
	(
		case state of 
		(
			true : --open 
			(
				for e = 228 to 450 by 5 do (mcMorphCollectorDialog.width = e; sleep 0.002)
				chk_add_rings.text = "<< Manage Points" 
				--rene
				unregisterRedrawViewsCallback drawMorphCollectorMarkers
				registerRedrawViewsCallback drawMorphCollectorMarkers
			)
			false : --close
			(
				for f = 450 to 228 by -5 do (sleep 0.002; mcMorphCollectorDialog.width = f)
				chk_add_rings.text = "Manage Points >>" 
				chk_add_edges.text = "Manage Edges >>" 
				chk_add_edges.checked = false
				unregisterRedrawViewsCallback drawMorphCollectorMarkers
				unregisterRedrawViewsCallback drawMorphEdgeManagerEdges
			)
		)
	)
	fn pickNodeByName n=(if n != undefined and (local obj=getNodeByName n) != undefined then return obj else return #())
	fn fillMorphObjects=(ddl_morph_obj.items=for o in objects where not o.isHidden and classOf o == MorphObj2 collect o.name)
	fn getPointByName obj  tag_name =
	(
		for i=0 to (MorphObj_GetNPoints obj)-1 where MorphObj_GetPointName obj i == tag_name do return i
		return undefined
	)
	fn fillMorphObjData obj=
	(
		if lbx_edges.items.count == 0 do return false
		--add new point names
		for n in lbx_rings.items where (local ring = getNodeByName n) != undefined do for t in ring.tag_names do 
		(
			MorphObj_AddPoint obj t
		)
		--add edges definition
		for i=0 to lbx_edges.items.count-1 do
		(
			local flt=filterString lbx_edges.items[i+1] ", "
			local index_a = getPointByName obj  flt[1]
			local index_b = getPointByName obj  flt[2]
			--format "index:%\tpoints:%\ta:%\tb:%\n" i flt index_a index_b
			MorphObj_AddEdge obj index_a index_b
		)
		chk_add_rings.checked = false
		openCloseRingDialog false
	)
	fn getMorphCollectorModifierByName n =
	(
		struct OBJ_DATA (obj, mdf)
		local o = getNodeByName n
		if o == undefined do return undefined
		local m = o.modifiers[#MorphCollector]
		if classOf m != MorphCollector do return undefined
		OBJ_DATA o m
	)
	fn getMorphCollectorModifiers =
	(
		if lbx_ctrl_obj.items.count == 0 do return #()
		for n in lbx_ctrl_obj.items where (local d = getMorphCollectorModifierByName n)  != undefined collect d
	)
	fn addMorphCollectorsData ring_names =
	(
		if ring_names.count == 0 do return false
		local all_collector_modifiers = getMorphCollectorModifiers()
		if all_collector_modifiers.count == 0 do return false
		local pos=#()
		local rot=#()
		local rad=#()
		for n in ring_names do
		(
			local ring = getNodeByName n
			if ring != undefined do
			(
				append pos ring.pos
				append rot  [ring.rotation.x_rotation, ring.rotation.y_rotation, ring.rotation.z_rotation]
				append rad ring.circle_radius
			)
		)
		for s in all_collector_modifiers do
		(
			s.mdf.ring_names = ring_names
			s.mdf.ring_positions = pos
			s.mdf.ring_rotations = rot
			s.mdf.ring_radius  = rad
		)	
	)	
	fn insertMorphCollectorsData ring_name =
	(
		local all_collector_modifiers = getMorphCollectorModifiers()
		if all_collector_modifiers.count == 0 do return false
		local ring = getNodeByName ring_name
		for s in all_collector_modifiers do
		(
			append s.mdf.ring_names ring_name
			append s.mdf.ring_positions ring.pos
			append s.mdf.ring_rotations [ring.rotation.x_rotation, ring.rotation.y_rotation, ring.rotation.z_rotation]
			append s.mdf.ring_radius ring.circle_radius
		)
	)
	fn removeMorphCollectorsData index=
	(
		local all_collector_modifiers = getMorphCollectorModifiers()
		if all_collector_modifiers.count == 0 do return false
		for s in all_collector_modifiers do
		(
			deleteItem s.mdf.ring_names index
			deleteItem s.mdf.ring_positions index
			deleteItem s.mdf.ring_rotations index
			deleteItem s.mdf.ring_radius index
		)
	)
	fn renameMorphCollectorsData index new_name=
	(
		local all_collector_modifiers = getMorphCollectorModifiers()
		if all_collector_modifiers.count == 0 do return false
		for s in all_collector_modifiers do
		(
			s.mdf.ring_names[index] = new_name
		)
	)
	fn getRings=
	(
		local cm = (getMorphCollectorModifiers())[1]
		if cm == undefined do return false
		--select cm.obj
		--select (refs.dependentNodes cm)
		lbx_rings.items = cm.mdf.ring_names as array
		grp_rings.text =("Rings: " +lbx_rings.items.count as string)
	)
	fn fillControllObjects=
	(
		if ddl_morph_obj.items.count == 0 do return #()
		morph_obj = getNodeByName ddl_morph_obj.selected
		if classOf morph_obj != MorphObj2 do return #()
		local co=for i=0 to (MorphObj_GetNTargets morph_obj)-1 collect (MorphObj_GetTargetControlMesh morph_obj i).name
		lbx_ctrl_obj.items=co
		--if lbx_ctrl_obj.items.count != 0 do select (pickNodeByName lbx_ctrl_obj.selected)
		lbx_ctrl_obj.text = ("Objects: " +lbx_ctrl_obj.items.count as string)
		lbx_ctrl_obj.selection = 0 
	)
	fn getVertPosByHit p1 p2 mesh_obj =
	(
		if classOf mesh_obj != Editable_Mesh do return undefined
		local the_ray = ray p1 (normalize (p2 - p1) ) 
		local hit_array = intersectRayEx mesh_obj the_ray
		if hit_array == undefined do return undefined
		local hit_pos=(hit_array[1]).pos
		local hit_face=(hit_array[2])
		if hit_face == undefined  do return undefined
		local face_verts =  (meshop.getVertsUsingFace mesh_obj hit_face) as array
		/*format "face_verts:%|n"  face_verts*/
		local dist = (for v in face_verts collect distance (meshOp.getVert mesh_obj v) hit_pos)
		local min_dist  = (amin dist)
		local the_vert = face_verts[ findItem dist min_dist ]
		return (meshOp.getVert mesh_obj the_vert)
	)
	fn getProjectedPoints =
	(
		local sel_control_mesh = lbx_ctrl_obj.selection
		if sel_control_mesh == 0 do return false
		local cm = (getMorphCollectorModifiers() )[sel_control_mesh]
		if cm == undefined do return false --if not control mesh with collector modifier
		local this_node = cm.obj
		/*format "this node:%\n" this_node*/
		morphCollectorMarkers  = #()
		local rings = for n in lbx_rings.items where (local obj = getNodeByName n) != undefined collect obj
		for o in rings do
		(
			append morphCollectorMarkers (MORPH_DATA ring:o.name) --add new data list to  array
			for n in o.tag_names where (local obj = getNodeByName n) != undefined do 
			(
				local tag_pos = obj.pos
				local ring_pos = o.pos
				local vert_pos = getVertPosByHit tag_pos ring_pos this_node
				if vert_pos != undefined do --fill data list
				(	
					morphCollectorMarkers[morphCollectorMarkers.count].tags += #(n)
					morphCollectorMarkers[morphCollectorMarkers.count].points += #(vert_pos)
				)
			)
		)
	)
	fn inicializeInterface=
	(
		fillMorphObjects()
		fillControllObjects()
		getRings()
		getProjectedPoints()
		updateUI()
	)
	fn addControllMesh obj=
	(
		MorphObj_AddTarget morph_obj obj
		fillControllObjects()
		try (addModifier (getNodeByName lbx_ctrl_obj.items[ lbx_ctrl_obj.items.count]) (MorphCollector())) catch()	
		lbx_ctrl_obj.selection = 0
	)
	fn createMorphObjCollectionFromSelection=
	(
		if lbx_ctrl_obj.items.count != 0 do return false
		morph_obj = MorphObjCreate()
		local objects_to_add=for o in selection where isMeshOrPoly o collect o
		for o in objects_to_add do
		(
			format "adding % \n" o to:listener							
			MorphObj_AddTarget morph_obj o
		)
		ddl_morph_obj.items +=#(morph_obj.name)
		fillControllObjects()
		for n in lbx_ctrl_obj.items do try (addModifier (getNodeByName n) (MorphCollector())) catch()
		lbx_ctrl_obj.selection = 0	
		select morph_obj
		btn_create_morphs.enabled=false
	)
	fn addRings obj =
	(
		if classOf obj == MorphTagger
		then
		(
			lbx_rings.items+=#(obj.name)
			insertMorphCollectorsData obj.name
		)
		else
		(
			if obj.children.count == 0 do return false
			lbx_rings.items =for o in obj.children where classOf o == MorphTagger collect o.name
			addMorphCollectorsData lbx_rings.items
		)
		chk_add_edges.enabled = lbx_rings.items.count != 0
	)
	fn removeRing=
	(
		local sel = lbx_rings.selection
		if sel == 0 do return false
		removeMorphCollectorsData sel
		lbx_rings.items=deleteItem lbx_rings.items sel
		chk_add_edges.enabled = lbx_rings.items.count != 0
	)
	fn renameRing=
	(
		if lbx_rings.selection == 0 do return false
		local obj = (getNodeByName lbx_rings.items[lbx_rings.selection])
		local new_name = edt_ring_rename.text
		if findItem lbx_rings.items new_name != 0 do 
		(
			messageBox ("Name: [ "+ new_name +" ] is used. Try something else." ) title:"Dupplicate Found!"
			return false
		)
		renameMorphCollectorsData lbx_rings.selection new_name
		obj.name= lbx_rings.selected = new_name
	)
	fn markActiveRing sel =
	(
		if lbx_rings.items.count == 0 do return false
		local obj = (getNodeByName lbx_rings.items[sel])
		if obj == undefined do return false
		for n in lbx_rings.items do 
		(
			local o =  getNodeByName n
			if o != undefined do (o.wirecolor = clr_ring)
		)
		obj.wirecolor = clr_ring_active
	)
	fn selectNextMorpher n=
	(
		local obj = getNodeByName n
		if classOf obj != MorphObj2 do return false
		select obj
		morph_obj = obj
		fillControllObjects()
	)
	fn clearMorphObjData obj=
	(
		--delete old point names
		while (MorphObj_GetNPoints obj) > 0 do MorphObj_DelPoint obj 0
		--clear edge definition
		while (MorphObj_GetNEdges obj ) > 0 do MorphObj_DelEdge obj 0
	)
	fn transferMorphHierarchy =
	(
		if classOf morph_obj != MorphObj2 do return false
		clearMorphObjData(morph_obj)
		fillMorphObjData(morph_obj)
		updateUI()
		completeRedraw()
	)
	fn isHierarchyCountMatch =
	(
		if morph_obj == undefined or morphCollectorMarkers.count  == 0 do return false
		local collector_tags_count = 0
		for s in morphCollectorMarkers do collector_tags_count += s.tags.count
		local morphobj_tags_count = MorphObj_GetNPoints morph_obj
		format "collector_tags_count:%\t morphobj_tags_count:%\n" collector_tags_count  morphobj_tags_count
		collector_tags_count == morphobj_tags_count
	)
	fn transferMorphPoints=
	(
		if not  isHierarchyCountMatch() do (messageBox "Hierarchy Not Match, Please Adjust Rings Positions." title:"Morph Collector:" ; return false)
		if morph_obj == undefined or lbx_ctrl_obj.selected == undefined do return false
		local this_node = getNodeByName lbx_ctrl_obj.selected
		if this_node == undefined do return false
		fn getMorphObjectIndex this_node morph_obj =
		(
			for i=0 to (MorphObj_GetNTargets morph_obj as Integer)-1 where 
			(
				MorphObj_GetTargetControlMesh morph_obj i == this_node	
			) do return i
			return undefined
		)
		local this_node_index = getMorphObjectIndex this_node morph_obj
		local this_node_inv_tm = Inverse this_node.transform

		fn findPosByName tname =
		(
			for s in morphCollectorMarkers do for i=1 to s.tags.count where s.tags[i] == tname do return s.points[i]
			undefined
		)
		local tags_count = (MorphObj_GetNPoints morph_obj)
		for i=1 to tags_count do
		(
			local tag_name = MorphObj_GetPointName morph_obj (i-1)
			local tag_pos = findPosByName  tag_name
			if tag_pos != undefined do
			(
				local local_pos =  tag_pos * this_node_inv_tm
				MorphObj_SetPointPos morph_obj this_node_index (i-1) local_pos
			)
		)
	)
	fn isTags obj_array = (for o in obj_array where classOf o != Sphere do return false; return true )
	fn addEdges=
	(
		local sel = selection as array
		if sel.count == 2 and isTags sel --if two tags is selected
		then
		(
			local new_itm = sel[1].name+", "+sel[2].name
			lbx_edges.items += #(new_itm)
		)
		else  --if rings is selected 
		(
			for o in sel where classOf o == MorphTagger do --collect Ring Tags
			(
				local t_names = o.tag_names
				if t_names.count > 1 do
				(
					local tg_a = t_names[1]
					for i=2 to t_names.count do
					(
						local tg_b = t_names[i]
						local new_itm = tg_a+", "+tg_b
						lbx_edges.items += #(new_itm)
						tg_a = tg_b
					)
				)
				if t_names.count > 2 do 
				(
					local new_itm = t_names[t_names.count]+", "+t_names[1] --connect last and first
					lbx_edges.items += #(new_itm)
				)
			)
		)
		grp_edges.text =("Edges: " +lbx_edges.items.count as string)
	)
	fn delEdges=
	(
		if keyboard.shiftPressed then --clear list
		(
			lbx_edges.items = #()
		)
		else --remove selection
		(
			local sel =  lbx_edges.selection
			if sel !=0 do lbx_edges.items = deleteItem lbx_edges.items sel
			grp_edges.text =("Edges: " +lbx_edges.items.count as string)
		)
	)
	fn deleteCollectorModifiersData num=
	(
		local all_collector_modifiers = getMorphCollectorModifiers()
		if all_collector_modifiers.count == 0 do return false
		for s in all_collector_modifiers do
		(
			deleteItem s.mdf.ring_names num
			deleteItem s.mdf.ring_positions num
			deleteItem s.mdf.ring_rotations num
			deleteItem s.mdf.ring_radius num
		)
	)
	fn deletedUpdate=
	(
		local obj = callbacks.notificationParam()
		if obj == undefined do return false
		--if ring
		if classOf obj==MorphTagger do 
		(
			--delete all tags behind
			for n in obj.tag_names do
			(
				local o=getNodeByName n
				if o != undefined do delete o
			)
			--find if ring was assinged to Morph Collector modifier and remove property
			local ring_item = findItem lbx_rings.items old_name 
			if ring_item != 0 do
			(
				deleteCollectorModifiersData ring_item
				deleteItem lbx_rings.items ring_item 
				lbx_rings.items = lbx_rings.items
			)
		)
	)
	fn renameUpdate=
	(
		
		local obj_data = callbacks.notificationParam()
		if obj_data == undefined do return false
		local old_name = obj_data[1] --before renamed
		local new_name = obj_data[2] --after renamed
		--if morph obj
		local morph_item =  findItem ddl_morph_obj.items old_name 
		if morph_item != 0 do 
		(
			ddl_morph_obj.items[morph_item] = new_name
			ddl_morph_obj.items = ddl_morph_obj.items
		)
		-- restricted to rename control mesh 
		local ctrl_item = findItem lbx_ctrl_obj.items old_name
		if ctrl_item != 0 do
		(
			local obj = getNodeByName new_name
			if obj != undefined do 
			(
				obj.name = old_name
				messageBox "Controll Mesh Rename Is Restricted!" title:"Morph Edge Manager:"
				return false
			)
		)
		--if ring
		local ring_item = findItem lbx_rings.items old_name 
		if ring_item != 0 do
		(
			lbx_rings.items[ring_item] = new_name
			lbx_rings.items = lbx_rings.items
		)
	)
	fn correctRingMorphCollectorTag obj =
	(
		for n in lbx_rings.items do
		(
			local ring = getNodeByName n
			if classOf ring == MorphTagger do
			(
				ring.morph_collector = obj.name
			)
		)
	)
	fn loadRingPose sel=
	(
		local obj_data=getMorphCollectorModifierByName lbx_ctrl_obj.items[sel]
		if obj_data == undefined do return false
		local mdf = obj_data.mdf
		if mdf.ring_positions.count == 0 do return false
		for i=1 to lbx_rings.items.count do
		(
			local ring = getNodeByName lbx_rings.items[i]
			if ring != undefined do
			(
				ring.pos = mdf.ring_positions[i]
				ring.circle_radius = mdf.ring_radius[i]; ring.delegate.radius=mdf.ring_radius[i]
				ring.rotation.x_rotation = mdf.ring_rotations[i].x
				ring.rotation.y_rotation = mdf.ring_rotations[i].y
				ring.rotation.z_rotation = mdf.ring_rotations[i].z
			)
		)
	)
	fn saveRingPose sel=
	(
		if sel == 0 do return false
		local obj_data=getMorphCollectorModifierByName lbx_ctrl_obj.items[sel]
		if obj_data == undefined do return false
		local mdf = obj_data.mdf
		--get rings data and fill param tabs
		local pos=#()
		local rot=#()
		local rad=#()
		for n in lbx_rings.items do
		(
			local ring = getNodeByName n
			if ring != undefined do
			(
				append pos ring.pos
				append rot  [ring.rotation.x_rotation, ring.rotation.y_rotation, ring.rotation.z_rotation]
				append rad ring.circle_radius
			)
		)
		mdf.ring_positions = pos
		mdf.ring_rotations = rot
		mdf.ring_radius  = rad
	)
	fn copyRingsPose=
	(
		struct RING_DATA (nam,pos,rot,rad)
		local RD = #()
		for n in lbx_rings.items do
		(
			local ring = getNodeByName n
			if ring != undefined do
			(
				local nam=ring.name
				local pos=ring.pos
				local rot = [ring.rotation.x_rotation, ring.rotation.y_rotation, ring.rotation.z_rotation]
				local rad=ring.circle_radius
				RD += #(RING_DATA nam pos rot rad)
			)
		)
		morphCollectorRingData=RD
	)
	fn pasteRingsPose =
	(
		if morphCollectorRingData == undefined do return false
		local nam=#()
		local pos=#()
		local rot=#()
		local rad=#()
		for d in morphCollectorRingData do
		(
			local ring = getNodeByName (d.nam as string)
			if ring != undefined do
			(
				ring.pos = d.pos; ring.circle_radius = d.rad; ring.delegate.radius=d.rad;
				ring.rotation.x_rotation = d.rot.x
				ring.rotation.y_rotation = d.rot.y
				ring.rotation.z_rotation = d.rot.z
			)
		)
	)
	fn updateContorlls sel=
	(
		if sel == 0 do return false
		local obj = pickNodeByName lbx_ctrl_obj.items[sel]
		if obj == undefined do return false
		select obj
		correctRingMorphCollectorTag obj
		loadRingPose sel
		getProjectedPoints()
	)
	fn clearCallbacks=
	(
		callbacks.removeScripts id:#morphCollectorManagerCallback
		unregisterRedrawViewsCallback drawMorphCollectorMarkers
		unregisterRedrawViewsCallback drawMorphEdgeManagerEdges
		destroyDialog mcMorphCollectorDialog
		CompleteRedraw()
	)
	fn setupCallbacks=
	(
		callbacks.removeScripts id:#morphCollectorManagerCallback
		callbacks.addScript #systemPostNew "mcMorphCollectorDialog.clearCallbacks()" id:#morphCollectorManagerCallback
		callbacks.addScript #systemPostReset "mcMorphCollectorDialog.clearCallbacks()" id:#morphCollectorManagerCallback
		callbacks.addScript #filePostOpen "mcMorphCollectorDialog.clearCallbacks()" id:#morphCollectorManagerCallback
		callbacks.addScript #nodePreDelete "mcMorphCollectorDialog.deletedUpdate()" id:#morphCollectorManagerCallback
		callbacks.addScript #sceneUndo "mcMorphCollectorDialog.inicializeInterface()" id:#morphCollectorManagerCallback
		callbacks.addScript #sceneRedo "mcMorphCollectorDialog.inicializeInterface()" id:#morphCollectorManagerCallback
		callbacks.addScript #nodeRenamed "mcMorphCollectorDialog.renameUpdate()" id:#morphCollectorManagerCallback
		callbacks.addScript #selectionSetChanged "mcMorphCollectorDialog.updateUI()" id:#morphCollectorManagerCallback
	)
	on mcMorphCollectorDialog open  do (inicializeInterface(); setupCallbacks())
	on mcMorphCollectorDialog close  do (clearCallbacks())
	
	on lbx_ctrl_obj selected sel do (updateContorlls sel)
	on lbx_rings selected sel do (markActiveRing sel)
	on ddl_morph_obj selected sel do (selectNextMorpher ddl_morph_obj.items[sel]; updateUI())	
		
	on lbx_rings doubleClicked sel do (edt_ring_rename.text = lbx_rings.items[sel])	
	on lbx_ctrl_obj doubleClicked sel do (max tool zoomextents all)	
	
	on btn_ring_add picked obj do (addRings obj)
	on btn_add_morph picked obj do (addControllMesh obj)	
		
	on btn_create_morphs pressed  do (createMorphObjCollectionFromSelection())
	on btn_ring_remove pressed do (removeRing())
	on btn_ring_rename pressed do (renameRing())
	on btn_add_edge pressed  do (addEdges())
	on btn_remove_edge pressed do (delEdges())
	on btn_commit pressed do (transferMorphHierarchy())
	on btn_copy_pose pressed do (copyRingsPose())
	on btn_paste_pose pressed do (pasteRingsPose())
	on btn_save_pose pressed do (saveRingPose lbx_ctrl_obj.selection)
	on btn_transfer_points pressed do (transferMorphPoints())
	on chk_add_edges changed state do (openCloseEdgeDialog state)
	on chk_add_rings changed state do (openCloseRingDialog state)
)
local p=getMAXWindowPos()
local s=getMAXWindowSize()
p = p+s/4 --40% of window X
CreateDialog mcMorphCollectorDialog  pos:p
)



--------------------------------------------------------------------------
/*CALLBACKS >>*/
--------------------------------------------------------------------------
--------------------------------------------------------------------------
/*<< CALLBACKS*/
--------------------------------------------------------------------------