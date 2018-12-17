
--------------------------------------------------------------------------
					/*MORPH EDGES*/
						/*2012*/
--------------------------------------------------------------------------

Global morphEdgeDialog
Global drawMorphEdgeManagerEdges

if morphEdgeDialog != undefined do destroyDialog morphEdgeDialog
rollout morphEdgeDialog "Morph Edge Manager:" width:364 height:640
(
	local morph_collector
	GroupBox grp_man "Manage: 0" pos:[4,4] width:356 height:632
	listbox lbx_edges "Edges Definition:" pos:[12,24] width:340 height:43
	button btn_add "Add Edge" pos:[12,608] width:92 height:24
	button btn_del "Del Edge" pos:[108,608] width:92 height:24
	button btn_com "Commit" pos:[260,608] width:92 height:24
	fn drawMorphEdgeManagerEdges = 
	(	
		gw.setTransform(Matrix3 1)
		for i in lbx_edges.items do 
		(
			local flt=filterString i ", "
			local obj_1 = getNodeByName flt[1]
			local obj_2 = getNodeByName flt[2]
			if not isValidNode obj_1 or not isValidNode obj_2 do return false 
			local p1 = gw.hTransPoint obj_1.pos
			local p2 = gw.hTransPoint obj_2.pos
			local col = yellow
			gw.hPolyline #(p1, p2) false rgb:#(col, col) 

		)
		format "sel:%\n" lbx_edges.selected
		/*
		if lbx_edges.selection != 0 do 
		(
			local sel_edge = lbx_edges.selected
		)
		*/
		gw.enlargeUpdateRect #whole
		gw.updateScreen()
	)
	fn fillItems list = ( lbx_edges.items =  list ;  grp_man.text =("Manage: " +lbx_edges.items.count as string))
	fn isNotTags obj_array = (for o in obj_array where findString o.name "mt_" == undefined do return true; return false )
	fn isDupplicated new_itm = (for i in lbx_edges.items where i == new_itm do return true; return false)
	fn addEdges=
	(
		local sel = selection as array
		if sel.count != 2 or isNotTags sel do (messageBox "Select two Morpher Tags." title:"Morph Edge Manager:"; return false)
		local new_itm = sel[1].name+", "+sel[2].name
		if isDupplicated new_itm do (messageBox "This Edge is allready defined." title:"Morph Edge Manager:"; return false)
		lbx_edges.items += #(new_itm)
		grp_man.text =("Manage: " +lbx_edges.items.count as string)
	)
	fn delEdges=
	(
		local sel =  lbx_edges.selection
		if sel !=0 do deleteItem lbx_edges.items sel
		grp_man.text =("Manage: " +lbx_edges.items.count as string)
	)
	fn focusEdgePoins sel=
	(
		local flt=filterString lbx_edges.items[sel] ", "
		local obj_1 = getNodeByName flt[1]
		local obj_2 = getNodeByName flt[2]
		if not isValidNode obj_1 or not isValidNode obj_2 do return false 
		select #(obj_1, obj_2)
	)
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
	on lbx_edges selected sel do (focusEdgePoins sel)
	on btn_add pressed  do (addEdges())
	on btn_del pressed  do (delEdges())
	on btn_com pressed do 
	(
		if isValidNode morph_collector do 
		(
			local m=morph_collector.modifiers[#MorphCollector] 
			if m!=undefined do m.edge_list = lbx_edges.items
			destroyDialog morphEdgeDialog
		)
	)
)
(
	local p=getMAXWindowPos()
	local s=getMAXWindowSize()
	p = p+s/10 --10% of max window
	createDialog morphEdgeDialog pos:p
)
