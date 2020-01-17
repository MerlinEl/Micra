Global mcCurbCrumpleDialog

if mcCurbCrumpleDialog != undefined do destroyDialog mcCurbCrumpleDialog
rollout mcCurbCrumpleDialog "Curb Crumple:" width:400 height:140
(
	GroupBox 'grp1' "Actions:" pos:[4,4] width:392 height:132 align:#left

	label 'lbl1' "distance:" pos:[112,52] width:56 height:16 align:#left
	label 'lbl2' "cm" pos:[236,52] width:20 height:16 align:#left
	label 'lbl3' "min:" pos:[112,80] width:24 height:16 align:#left
	label 'lbl5' "min:" pos:[112,108] width:24 height:16 align:#left
	label 'lbl22' "offset:" pos:[112,28] width:56 height:16 align:#left
	label 'lbl23' "cm" pos:[236,28] width:20 height:16 align:#left

	spinner 'spn_extend_bottom_edge' "" pos:[168,28] width:64 height:16 enabled:false range:[0,100000,10] type:#float scale:0.1 align:#left
	spinner 'spn_connect_edges' "" pos:[168,52] width:64 height:16 range:[0,100000,600] type:#integer scale:1 align:#left
	spinner 'spn_noise_to_side_min' "" pos:[136,80] width:64 height:16 range:[-100000,100000,-4] type:#float scale:0.1 align:#left
	spinner 'spn_up_down_min' "" pos:[136,108] width:64 height:16 range:[-100000,100000,-2] type:#float scale:0.1 align:#left
	
	button 'btn_connect_edges' "Connect Edges" pos:[8,48] width:100 height:24 align:#left
	button 'btn_noise_to_side' "Noise To Side" pos:[8,76] width:100 height:24 align:#left
	button 'noise_up_down' "Noise Up Down" pos:[8,104] width:100 height:24 align:#left
	button 'btn_extend_bottom_edge' "Extend Curb" pos:[8,20] width:100 height:24 enabled:false align:#left
	checkbox 'chk_freeze_bottom' "freeze bottom" pos:[304,108] width:84 height:16 checked:true align:#left
	label 'lbl7' "max:" pos:[208,80] width:24 height:16 align:#left
	label 'lbl8' "max:" pos:[208,108] width:24 height:16 align:#left
	spinner 'spn_noise_to_side_max' "" pos:[232,80] width:64 height:16 range:[0,100000,4] type:#float scale:0.1 align:#left
	spinner 'spn_up_down_max' "" pos:[232,108] width:64 height:16 range:[0,100000,1] type:#float scale:0.1 align:#left
	radioButtons 'rdo_connect_edges' "" pos:[260,52] width:141 height:16 labels:#("600", "400", "200") columns:3 align:#left
	
	fn extendEdgeToBottom obj offset_val = (
		
		if classOf obj != Editable_Poly do return false
		esel = polyOp.getEdgeSelection obj
		if esel.numberset != 1 do return false
		eface = polyOp.getFacesUsingEdge obj esel
		polyOp.detachFaces obj eface --delete:false asNode:false
		everts = polyOp.getVertsUsingEdge obj esel
		for v in everts do (
			
			local v_pos = polyOp.getVert obj v
			v_pos.z -= offset_val
			polyOp.setVert obj v v_pos
		)
	)
	
	fn conectEdgesByDistance obj dist_val = (

		if classOf obj != Editable_Poly do return false
		esel_ring = polyop.getEdgeSelection obj
		edge_index = (esel_ring as array)[1]
		len = mcPoly.getEdgeLength obj edge_index
		segs = int(len / dist_val)
		obj.connectEdgeSegments = segs
		obj.connectEdgePinch = 0
		obj.connectEdgeSlide = 0
		obj.EditablePoly.ConnectEdges ()
	)
	
		
	fn distributeEdgesInToLoopGroups obj edges = (

		local max_try = edges.numberset
		local edges_loops = #()
		while edges.numberset > 0 and max_try > 0 do (

			local edge_index = (edges as array)[1]
			local edge_loop = (mcPoly.getEdgeLoop obj edge_index) as BitArray --get current edge loop
			edge_loop = edge_loop * edges --keep only edges from selection
			max_try -= edge_loop.numberset
			edges -= edge_loop
			append edges_loops edge_loop
		)
		edges_loops
	)
	
	fn getDirFromLongestEdge obj edges = (

		local longest_edge = mcPoly.getLongestEdge obj edges
		local everts = polyOp.getVertsUsingEdge obj longest_edge
		local verts_pos = for v in everts collect polyop.getvert obj v
		local p1 = (verts_pos as array)[1]
		local p2 = (verts_pos as array)[2]
		normalize (p1 - p2)
	)

	fn offsetLoopInLocal obj el val = (

		local dir = getDirFromLongestEdge obj el
		--format "dir%\n" dir
		local el_verts = polyop.getVertsUsingEdge obj el
		for v in el_verts do (
		
			local vpos = polyOp.getVert obj v
			local new_pos = vpos + (dir * val)
			polyOp.setVert obj v new_pos
		)
	)
	
	fn offsetLoopInWorld obj el offset_xyz = (
	
		local el_verts = polyop.getVertsUsingEdge obj el
		for v in el_verts do (
		
			local vpos = polyOp.getVert obj v
			vpos += offset_xyz
			polyOp.setVert obj v vpos
		)
	)
	
	fn noiseUpDown obj offset_val freezeBottom:false= (

		if classOf obj != Editable_Poly do return false
		format "noise side obj:% offset:% axis:%\n" obj.name offset_val axis_str
		if obj.constrainType != 0 do obj.constrainType = 0 --disable contains first		
		if obj.preserveUVs do obj.preserveUVs = off --disable preserve uvs
		--split edge selection to loop grpups
		local esel = polyop.getEdgeSelection obj
		if esel.numberset == 0 do return false
		local esel_loops = distributeEdgesInToLoopGroups obj esel 
		--store position of bottom vertices
		local bottom_vertices = for el in esel_loops collect (
			
			local el_verts = polyop.getVertsUsingEdge obj el
			local lover_vert = (el_verts as Array)[1]
			local lower_pos = polyop.getVert obj lover_vert
			for v in el_verts do (
				
				local vpos = polyop.getVert obj v
				if vpos.z < lower_pos.z do (
				
					lover_vert = v
					lower_pos = vpos
				)
			)
			#(lover_vert, lower_pos)
		)
		for el in esel_loops do (
			
			local random_val = random offset_val[1] offset_val[2]
			local offset =  [0, 0, random_val]
			offsetLoopInWorld obj el offset
		)
		--restore position of bottom vertices
		if freezeBottom do for bv in bottom_vertices do polyOp.setVert obj bv[1] bv[2]
	)
	
	/*
		obj = $
		edges = polyop.getEdgeSelection obj
		elo = distributeEdgesInToLoopGroups obj edges
		elo[2].selectLoop()
		elo[2].offsetBy [0,20,0]
	*/
	fn noiseToSide obj offset_val = (

		if classOf obj != Editable_Poly do return false
		format "noise side obj:% offset:%\n" obj.name offset_val 
		if obj.constrainType != 0 do obj.constrainType = 0 --disable contains first
		if obj.preserveUVs do obj.preserveUVs = off --disable preserve uvs
		--split edge selection to loop grpups
		local esel = polyop.getEdgeSelection obj
		if esel.numberset == 0 do return false
		local esel_loops = distributeEdgesInToLoopGroups obj esel 
		for el in esel_loops do (
			
			local random_val = random offset_val[1] offset_val[2]
			offsetLoopInLocal obj el random_val
		)
	)

	on btn_connect_edges pressed do
	(

		undo label:"Connect Edges By Distance" on conectEdgesByDistance $ spn_connect_edges.value
	)
	on btn_noise_to_side pressed do
	(
			
		undo label:"Noise To Side" on noiseToSide $ [spn_noise_to_side_min.value, spn_noise_to_side_max.value]
	)
		
	on noise_up_down pressed do
	(
			
		undo label:"Noise Up Down" on noiseUpDown $ [spn_up_down_min.value, spn_up_down_max.value] freezeBottom:chk_freeze_bottom.state
	)	
	on btn_extend_bottom_edge pressed do
	(
			
		undo label:"Extend Edge To Bottom" on extendEdgeToBottom $ spn_extend_bottom_edge.value
	)
	on rdo_connect_edges changed state do (
	
		spn_connect_edges.value = case state of (1 : 600; 2 : 400; 3 : 200)
	)
)
createDialog mcCurbCrumpleDialog

/*

fn distributeEdgesInToLoopGroups obj edges = (

	local process_edges = copy edges
	local max_try = edges.numberset
	local edges_loops = #()
	while process_edges.numberset > 0 and max_try > 0 do (

		local edge_index = (process_edges as array)[1]
		polyOp.setEdgeSelection obj edge_index
		obj.SelectEdgeLoop()
		local edge_loop = polyOp.getEdgeSelection obj --get current edge loop
		edge_loop = edge_loop * process_edges --keep only edges from selection
		max_try -= edge_loop.numberset
		process_edges -= edge_loop
		append edges_loops edge_loop
	)
	polyOp.setEdgeSelection obj edges --return back selection
	edges_loops
)


fn crumpleCurb obj = ( --x_val y_val z_val 

		if classOf obj != Editable_Poly do return false
		noise_mod = Noisemodifier()
		noise_mod.seed = 95
		noise_mod.scale = 500
		noise_mod.fractal = on
		noise_mod.iterations = 5
		noise_mod.strength = [0,20,4]
		modPanel.addModToSelection noise_mod
	)
*/
-------------------------------------------------------------