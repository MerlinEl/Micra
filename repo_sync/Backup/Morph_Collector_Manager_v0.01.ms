Global mcMorphCollectorDialog
Global morphCollectorMarkers =#()
Global drawMorphCollectorMarkers
Global MorphCollector



(
unregisterRedrawViewsCallback drawMorphCollectorMarkers	
if mcMorphCollectorDialog != undefined do destroyDialog mcMorphCollectorDialog
rollout mcMorphCollectorDialog "Morph Collector Manager:" width:450 height:480
(
	local morph_obj 
	fn isMeshOrPoly obj=(classOf obj.baseobject == Editable_Mesh or classOf obj.baseobject == Editable_Poly)
	fn isMorphTagger obj = 
	(
		(classOf obj == MorphTagger or classOf obj == Dummy or classOf obj == MorphDummy) and \
		findItem mcMorphCollectorDialog.lbx_rings.items obj.name == 0
	)
	struct MORPH_DATA(ring, tags=#(), points=#())
	GroupBox grp1 "Collect Control Meshes:" pos:[4,4] width:220 height:472
	button btn_create_morphs "Create Morph From Selection" pos:[8,212] width:212 height:24
	pickbutton btn_add_morph "Add New Control Object" pos:[8,240] width:212 height:24 filter:isMeshOrPoly
	listbox lbx_ctrl_obj "Control Objects:" pos:[8,68] width:212 height:9
	dropdownList ddl_morph_obj "Morpher:" pos:[8,24] width:212 height:40
	GroupBox grp_rings "Rings:" pos:[228,4] width:220 height:472
	GroupBox grp_edges "Edges:" pos:[452,4] width:220 height:472
	listbox lbx_edges "" pos:[456,24] width:212 height:32
	button btn_add_edge "Add" pos:[456,448] width:68 height:24
	button btn_remove_edge "Remove" pos:[528,448] width:68 height:24
	button btn_commit "Commit" pos:[600,448] width:68 height:24
	pickbutton btn_ring_add "Add" pos:[232,420] width:68 height:24 filter:isMorphTagger
	checkbutton chk_add_edges "Manage Edges >>" pos:[232,448] width:212 height:24
	listbox lbx_rings "" pos:[232,24] width:212 height:28
	button btn_ring_remove "Remove" pos:[304,420] width:68 height:24
	button btn_ring_rename "Rename" pos:[376,420] width:68 height:24
	editText edt_ring_rename "" pos:[228,396] width:216 height:20
	--listBox lbx_points "Points:" pos:[8,276] width:212 height:13
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
		for i in lbx_edges.items do drawLine (color 177 148 27) i
		local sel_edge = lbx_edges.selected
		if sel_edge != undefined do drawLine yellow sel_edge
		gw.enlargeUpdateRect #whole
		gw.updateScreen()
	)
	fn pickNodeByName n=(if (local obj=getNodeByName n) != undefined then return obj else return #())
	fn fillMorphObjects=(ddl_morph_obj.items=for o in objects where not o.isHidden and classOf o == MorphObj2 collect o.name)
	fn getMorphCollectorModifier obj:undefined =
	(
		if obj == undefined do
		(
			if lbx_ctrl_obj.items.count == 0 do return undefined
			obj = getNodeByName lbx_ctrl_obj.selected
		)
		if obj == undefined do return undefined
		local gco = obj.modifiers[#MorphCollector]	
		if classOf gco != MorphCollector then undefined else gco
	)
	fn updateMorphCollectorPoints=
	(
		local gco=getMorphCollectorModifier()
		if gco != undefined do gco.ring_names=lbx_rings.items
	)
	fn getRings=
	(
		local gco = getMorphCollectorModifier()
		if classOf gco == undefined do return false
		select (refs.dependentNodes gco)
		lbx_rings.items = gco.ring_names as array
		grp_rings.text =("Rings: " +lbx_rings.items.count as string)
	)
	fn fillControllObjects=
	(
		if ddl_morph_obj.items.count == 0 do return #()
		morph_obj = getNodeByName ddl_morph_obj.selected
		if classOf morph_obj != MorphObj2 do return #()
		local co=for i=0 to (MorphObj_GetNTargets morph_obj)-1 collect (MorphObj_GetTargetControlMesh morph_obj i).name
		lbx_ctrl_obj.items=co
		if lbx_ctrl_obj.items.count != 0 do select (pickNodeByName lbx_ctrl_obj.selected)
		print lbx_ctrl_obj.items.count
		lbx_ctrl_obj.text = ("Objects: " +lbx_ctrl_obj.items.count as string)
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
		local this_node = selection[1]
		if getMorphCollectorModifier obj:this_node == undefined do return false --if not control mesh with collector modifier
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
	)
	fn addControllMesh obj=
	(
		MorphObj_AddTarget morph_obj obj
		fillControllObjects()
	)
	fn createMorphObjCollectionFromSelection=
	(
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
	)
	fn addRings obj =
	(
		if classOf obj == MorphTagger
		then
		(
			lbx_rings.items+=#(obj.name)
		)
		else
		(
			if obj.children.count == 0 do return false
			lbx_rings.items =for o in obj.children where classOf o == MorphTagger collect o.name
		)
		updateMorphCollectorPoints()
	)
	fn removeRing=
	(
		local sel = lbx_rings.selection
		if sel == 0 do return false
		lbx_rings.items=deleteItem lbx_rings.items sel
		updateMorphCollectorPoints()
	)
	fn renameRing=
	(
		if lbx_rings.selection == 0 do return false
		local obj = (getNodeByName lbx_rings.items[lbx_rings.selection])
		local new_name = edt_ring_rename.text
		if findItem lbx_rings.items new_name != 0 do 
		(
			messageBox ("Name: [ "+ new_name +" ] is used. Try something else." ) title:"Dupplicate Found!"
		)
		obj.name= lbx_rings.selected = new_name
		updateMorphCollectorPoints()
	)
	fn markActiveRing sel =
	(
		if lbx_rings.items.count == 0 do return false
		local obj = (getNodeByName lbx_rings.items[sel])
		if obj == undefined do return false
		for n in lbx_rings.items do 
		(
			local o =  getNodeByName n
			if o != undefined do (o.wirecolor = color 27 120 27)
		)
		obj.wirecolor = green
	)
	fn selectNextMorpher n=
	(
		local obj = getNodeByName n
		if classOf obj != MorphObj2 do return false
		--select obj
		morph_obj = obj
		fillControllObjects()
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
	fn clearMorphObjData obj=
	(
		--delete old point names
		while (MorphObj_GetNPoints obj) > 0 do MorphObj_DelPoint obj 0
		--clear edge definition
		while (MorphObj_GetNEdges obj ) > 0 do MorphObj_DelEdge obj 0
	)
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
		destroyDialog morphEdgeDialog
	)
	fn openCloseEdgeSialog state=
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
	fn transferMorphHierarchy =
	(
		if classOf morph_obj != MorphObj2 do return false
		clearMorphObjData(morph_obj)
		fillMorphObjData(morph_obj)
		completeRedraw()
	)
	fn isNotTags obj_array = (for o in obj_array where classOf o != Sphere do return true; return false )
	fn addEdges=
	(
		local sel = selection as array
		print sel
		if sel.count == 1 and classOf sel[1] == MorphTagger  --if rings is selected collect his childs
		then 
		(
			--collectRingTags
			local t_names = sel[1].tag_names
			if t_names.count < 2 do return false
			local tg_a = t_names[1]
			for i=2 to t_names.count do
			(
				tg_b = t_names[i]
				local new_itm = tg_a+", "+tg_b
				lbx_edges.items += #(new_itm)
				tg_a = tg_b
			)
			if t_names.count > 2 do 
			(
				local new_itm = t_names[t_names.count]+", "+t_names[1] --connect last and first
				lbx_edges.items += #(new_itm)
			)
		)
		else --if two tags is selected
		(
			if sel.count != 2 or isNotTags sel do (messageBox "Select two Morpher Tags." title:"Morph Edge Manager:"; return false)
			local new_itm = sel[1].name+", "+sel[2].name
			lbx_edges.items += #(new_itm)
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
	--Open - Close Dialog
	fn clearCallbacks=
	(
		callbacks.removeScripts id:#morphCollectorManagerCallback
		unregisterRedrawViewsCallback drawMorphCollectorMarkers
		unregisterRedrawViewsCallback drawMorphEdgeManagerEdges
		destroyDialog mcMorphCollectorDialog
	)
	fn renameUpdate=
	(
		local obj_data = callbacks.notificationParam()
		if obj_data == undefined do return false
		local old_name = obj_data[1] --before renamed
		--if found in morph obj list or control obj list
		if findItem ddl_morph_obj.items old_name != 0 or findItem lbx_ctrl_obj.items old_name != 0 do inicializeInterface()
	)
	fn setupCallbacks=
	(
		callbacks.removeScripts id:#morphCollectorManagerCallback
		callbacks.addScript #systemPostNew "mcMorphCollectorDialog.clearCallbacks()" id:#morphCollectorManagerCallback
		callbacks.addScript #systemPostReset "mcMorphCollectorDialog.clearCallbacks()" id:#morphCollectorManagerCallback
		callbacks.addScript #filePostOpen "mcMorphCollectorDialog.clearCallbacks()" id:#morphCollectorManagerCallback
		callbacks.addScript #nodePostDelete "mcMorphCollectorDialog.inicializeInterface()" id:#morphCollectorManagerCallback
		callbacks.addScript #sceneUndo "mcMorphCollectorDialog.inicializeInterface()" id:#morphCollectorManagerCallback
		callbacks.addScript #sceneRedo "mcMorphCollectorDialog.inicializeInterface()" id:#morphCollectorManagerCallback
		callbacks.addScript #nodeRenamed "mcMorphCollectorDialog.renameUpdate()" id:#morphCollectorManagerCallback
		--callbacks.addScript #selectionSetChanged "getProjectedPoints()" id:#morphCollectorManagerCallback
		registerRedrawViewsCallback drawMorphCollectorMarkers
	)
	on mcMorphCollectorDialog open  do (inicializeInterface(); setupCallbacks())
	on mcMorphCollectorDialog close  do (clearCallbacks())
	
	on lbx_ctrl_obj selected sel do (getRings(); getProjectedPoints())
	on lbx_rings selected sel do (markActiveRing sel)
	on ddl_morph_obj selected sel do (selectNextMorpher ddl_morph_obj.items[sel])	
		
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
	
	on chk_add_edges changed state do openCloseEdgeSialog state
)
local p=getMAXWindowPos()
local s=getMAXWindowSize()
p = p+s/4 --40% of window X
CreateDialog mcMorphCollectorDialog  pos:p
)

