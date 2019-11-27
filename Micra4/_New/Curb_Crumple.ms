Global mcCurbCrumpleDialog

if mcCurbCrumpleDialog != undefined do destroyDialog mcCurbCrumpleDialog
rollout mcCurbCrumpleDialog "Curb Crumple:" width:332 height:140
(
	GroupBox 'grp1' "Actions:" pos:[4,4] width:324 height:132 align:#left

	label 'lbl1' "distance:" pos:[112,52] width:56 height:16 align:#left
	label 'lbl2' "cm" pos:[236,52] width:20 height:16 align:#left
	label 'lbl3' "pow:" pos:[112,80] width:56 height:16 align:#left
	label 'lbl5' "pow:" pos:[112,108] width:56 height:16 align:#left
	label 'lbl22' "offset:" pos:[112,28] width:56 height:16 align:#left
	label 'lbl23' "cm" pos:[236,28] width:20 height:16 align:#left

	spinner 'spn_extend_bottom_edge' "" pos:[168,28] width:64 height:16 enabled:false range:[0,100000,10] type:#float scale:0.1 align:#left
	spinner 'spn_connect_edges' "" pos:[168,52] width:64 height:16 range:[0,100000,600] type:#integer scale:1 align:#left
	spinner 'spn_noise_to_side' "" pos:[168,80] width:64 height:16 range:[0,100000,4] type:#float scale:0.1 align:#left
	spinner 'spn_up_down' "" pos:[168,108] width:64 height:16 range:[0,100000,2] type:#float scale:0.1 align:#left
	
	button 'btn_connect_edges' "Connect Edges" pos:[8,48] width:100 height:24 align:#left
	button 'btn_noise_to_side' "Noise To Side" pos:[8,76] width:100 height:24 align:#left
	button 'noise_up_down' "Noise Up Down" pos:[8,104] width:100 height:24 align:#left
	button 'btn_extend_bottom_edge' "Extend Curb" pos:[8,20] width:100 height:24 enabled:false align:#left
	radioButtons 'rdo_noise_side_axis' "" pos:[236,80] width:65 height:16 labels:#("X", "Y") default:1 columns:2 align:#left
	checkbox 'chk_freeze_bottom' "freeze bottom" pos:[236,108] width:84 height:16 align:#left checked:true
	
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
	
	fn noiseUpDown obj offset_val freezeBottom:false= (

		if classOf obj != Editable_Poly do return false
		format "noise side obj:% offset:% axis:%\n" obj.name offset_val axis_str 
		--split edge selection to loop grpups
		local esel = polyop.getEdgeSelection obj
		if esel.numberset == 0 do return false
		local esel_loops = mcPoly.getLoopsFromEdges obj esel 
		--store position of bottom vertices
		local bottom_vertices = for el in esel_loops collect (
			
			local lover_vert = (el.verts as Array)[1]
			local lower_pos = polyop.getVert obj lover_vert
			for v in el.verts do (
				
				local vpos = polyop.getVert obj v
				if vpos.z < lower_pos.z do (
				
					lover_vert = v
					lower_pos = vpos
				)
			)
			#(lover_vert, lower_pos)
		)
		for el in esel_loops do (
			
			local random_val = random -offset_val offset_val
			local offset =  [0, 0, random_val]
			el.offsetBy offset
		)
		--restore position of bottom vertices
		if freezeBottom do for bv in bottom_vertices do polyOp.setVert obj bv[1] bv[2]
	)
	/*
		obj = $
		edges = polyop.getEdgeSelection obj
		elo = mcPoly.getLoopsFromEdges obj edges
		elo[2].selectLoop()
		elo[2].offsetBy [0,20,0]
	*/
	fn noiseToSide obj offset_val axis_str = (

		if classOf obj != Editable_Poly do return false
		format "noise side obj:% offset:% axis:%\n" obj.name offset_val axis_str 
		--split edge selection to loop grpups
		local esel = polyop.getEdgeSelection obj
		if esel.numberset == 0 do return false
		local esel_loops = mcPoly.getLoopsFromEdges obj esel 
		for el in esel_loops do (
			
			local random_val = random -offset_val offset_val
			local offset = if axis_str == "x" then [random_val, 0, 0] else [0, random_val, 0] 
			el.offsetBy offset
		)
	)

	on btn_connect_edges pressed do
	(

			undo label:"Connect Edges By Distance" on conectEdgesByDistance $ spn_connect_edges.value
		)
	on btn_noise_to_side pressed do
	(
			
			undo label:"Noise To Side" on noiseToSide $ spn_noise_to_side.value (#("x", "y")[rdo_noise_side_axis.state])
		)
		
		on noise_up_down pressed do
	(
			
			undo label:"Noise Up Down" on noiseUpDown $ spn_up_down.value freezeBottom:chk_freeze_bottom.state
		)	
	on btn_extend_bottom_edge pressed do
	(
			
			undo label:"Extend Edge To Bottom" on extendEdgeToBottom $ spn_extend_bottom_edge.value
		)
)
createDialog mcCurbCrumpleDialog

/*
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