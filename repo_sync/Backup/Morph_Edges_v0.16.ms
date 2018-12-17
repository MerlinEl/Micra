
--------------------------------------------------------------------------
					/*MORPH EDGES*/
						/*2012*/
--------------------------------------------------------------------------

Global morphEdgeDialog
Global drawMorphEdgeManagerEdges

if morphEdgeDialog != undefined do destroyDialog morphEdgeDialog
rollout morphEdgeDialog "Morph Edge Manager:" width:364 height:640
(
	local morph_collector, morph_obj, ring_names
	GroupBox grp_man "Manage: 0" pos:[4,4] width:356 height:632
	listbox lbx_edges "Edges Definition:" pos:[12,24] width:340 height:43
	button btn_add "Add Edge" pos:[12,608] width:82 height:24 tooltip:"Add two selected tags as edge."
	button btn_del "Del Edge" pos:[94,608] width:82 height:24 tooltip:"Delete selected edge from list (+Shift delete all)"
	--button btn_get "Get Edges" pos:[176,608] width:82 height:24 tooltip:"Retrive edgelist from Morph Object."
	button btn_com "Commit" pos:[270,608] width:82 height:24 tooltip:"Save edge list in modifier Morph Collector."
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
	fn fillItems list = ( lbx_edges.items =  list ;  grp_man.text =("Manage: " +lbx_edges.items.count as string))
	fn isNotTags obj_array = (for o in obj_array where findString o.name "tg_" == undefined do return true; return false )
	fn isDupplicated new_itm = (for i in lbx_edges.items where i == new_itm do return true; return false)
	fn addEdges=
	(
		local sel = selection as array
		if sel.count == 1 and classOf sel[1] == MorphTagger 
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
				if not isDupplicated new_itm do lbx_edges.items += #(new_itm)
				tg_a = tg_b
			)
			if t_names.count > 2 do 
			(
				local new_itm = t_names[t_names.count]+", "+t_names[1] --connect last and first
				if not isDupplicated new_itm do lbx_edges.items += #(new_itm)
			)
		)
		else
		(
			if sel.count != 2 or isNotTags sel do (messageBox "Select two Morpher Tags." title:"Morph Edge Manager:"; return false)
			local new_itm = sel[1].name+", "+sel[2].name
			if isDupplicated new_itm do (messageBox "This Edge is allready defined." title:"Morph Edge Manager:"; return false)
			lbx_edges.items += #(new_itm)
		)
		grp_man.text =("Manage: " +lbx_edges.items.count as string)
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
			if sel !=0 do deleteItem lbx_edges.items sel
			lbx_edges.items = lbx_edges.items
			grp_man.text =("Manage: " +lbx_edges.items.count as string)
		)
	)
	fn focusEdgePoins sel=
	(
		local flt=filterString lbx_edges.items[sel] ", "
		local obj_1 = getNodeByName flt[1]
		local obj_2 = getNodeByName flt[2]
		if not isValidNode obj_1 or not isValidNode obj_2 do return false 
		select #(obj_1, obj_2)
	)
	fn getPointByName morph_obj  tag_name =
	(
		for i=0 to (MorphObj_GetNPoints morph_obj)-1 where MorphObj_GetPointName morph_obj i == tag_name do return i
		return undefined
	)
	fn clearMorphObjData morph_obj=
	(
		--delete old point names
		while (MorphObj_GetNPoints morph_obj) > 0 do MorphObj_DelPoint morph_obj 0
		--clear edge definition
		while (MorphObj_GetNEdges morph_obj ) > 0 do MorphObj_DelEdge morph_obj 0
	)
	fn fillMorphObjData morph_obj=
	(
		if lbx_edges.items.count == 0 do return false
			print lbx_edges.items
		--add new point names
		for n in ring_names where (local ring = getNodeByName n) != undefined do for t in ring.tag_names do 
		(
			MorphObj_AddPoint morph_obj t
		)
		--add edges definition
		for i=0 to lbx_edges.items.count-1 do
		(
			local flt=filterString lbx_edges.items[i+1] ", "
			local index_a = getPointByName morph_obj  flt[1]
			local index_b = getPointByName morph_obj  flt[2]
			--format "index:%\tpoints:%\ta:%\tb:%\n" i flt index_a index_b
			MorphObj_AddEdge morph_obj index_a index_b
		)
		destroyDialog morphEdgeDialog
	)
	fn transferMorphHierarchy =
	(
		if classOf morph_obj != MorphObj2 do return false
		clearMorphObjData(morph_obj)
		fillMorphObjData(morph_obj)
		completeRedraw()
	)
	fn getHierarchyData mname rnames=
	(
		ring_names = rnames
		morph_obj = getNodeByName mname
		format "morphObj:%\n" morph_obj
		if morph_obj == undefined do return false
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
	fn isMorphObject obj = (classOf obj == MorphObj2)
	on morphEdgeDialog open  do
	(
		morph_collector = selection[1]
		unregisterRedrawViewsCallback drawMorphEdgeManagerEdges
		registerRedrawViewsCallback drawMorphEdgeManagerEdges
	)
	on morphEdgeDialog close  do
	(
		unregisterRedrawViewsCallback drawMorphEdgeManagerEdges
	)
	--on lbx_edges selected sel do (focusEdgePoins sel)
	on btn_add pressed  do (addEdges())
	on btn_del pressed  do (delEdges())
	on btn_com pressed do (transferMorphHierarchy())
)
(
	local p=getMAXWindowPos()
	local s=getMAXWindowSize()
	p = p+s/4 --40% of window X
	createDialog morphEdgeDialog pos:p
)
