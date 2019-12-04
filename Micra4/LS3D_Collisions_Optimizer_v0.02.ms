
Global mcCollisionOptimizeDialog
if mcCollisionOptimizeDialog != undefined do destroyDialog mcCollisionOptimizeDialog
rollout mcCollisionOptimizeDialog "Collisions Optimizer:" width:328 height:248
(
	local units_type = mcSystem.unitsType()
	GroupBox 'grp1' "Optimize Chamfers:" pos:[0,4] width:160 height:68 align:#left
	GroupBox 'grp2' "Optimize Hard Smooths:" pos:[164,4] width:160 height:68 align:#left
	GroupBox 'grp11' "Automatic Multiple Obj:" pos:[0,76] width:324 height:84 align:#left
	GroupBox 'grp7' "Manual Single Obj:" pos:[0,164] width:324 height:80 align:#left

	label 'lbl5' "Select loop by:" pos:[8,188] width:76 height:16 align:#left
	label 'lbl1' "Max length:" pos:[12,24] width:60 height:16 align:#left
	label 'lbl_units_01' "cm" pos:[136,24] width:16 height:16 align:#left
	label 'lbl3' "Max distance:" pos:[176,24] width:60 height:16 align:#left
	label 'lbl_units_02' "cm" pos:[304,24] width:16 height:16 align:#left
	
	button 'btn_optimize_chamfers' "Optimize Chamfer Edges" pos:[8,44] width:144 height:24 align:#left
	button 'btn_optimize_hard' "Optimize Hard Edges" pos:[172,44] width:144 height:24 align:#left	
	button 'btn_unchamfer_edges' "Unchamfer Edges Ring" pos:[8,212] width:144 height:24 align:#left
	button 'btn_opt_curb_and_fences' "Optimize Curbs and Fences" pos:[8,96] width:144 height:24 align:#left
	button 'btn_opt_loop_by_n' "GO" pos:[124,184] width:28 height:24 align:#left
	
	spinner 'spn_chamfer_len' "" pos:[72,24] width:60 height:16 range:[0,1e+06,3] type:#float align:#left
	spinner 'spn_hard_dist' "" pos:[240,24] width:60 height:16 range:[0,1e+06,3] align:#left
	spinner 'spn_lop_each' "" pos:[84,188] width:34 height:16 range:[0,99,1] type:#integer align:#left
	
	fn unchamferEdges obj  = (
		--http://www.scriptspot.com/3ds-max/scripts/maxunchamfer
obj = $
		if classOf obj != Editable_Poly do return (mcMsgList.warn "not_poly") 
		local edges_ring = polyOp.getEdgeSelection obj
		if edges_ring.numberset == 0 do return (mcMsgList.warn "not_esel")
obj.setLoopShift 1 false true
obj.setLoopShift -1 false true
	)
	fn selectEachEdgeInLoop obj skip_each = (
	
		if classOf obj != Editable_Poly do return (mcMsgList.warn "not_poly") 
		local two_edges = polyOp.getEdgeSelection obj
		if two_edges.numberset != 2 do return (mcMsgList.warn "not_esel_2")  
		local eloop = mcPoly.getLoopBetweenTwoEdges obj two_edges skipEach:skip_each
		polyOp.setEdgeSelection obj eloop
		redrawViews()
	)
	fn optimizeEdges obj faces max_len = (
	
		obj.weldThreshold = 0.001
		polyOp.weldVertsByThreshold obj obj.verts
		local short_edges = for ei in faces where mcPoly.getEdgeLength obj ei <= max_len collect ei
		if short_edges.count > 0 do (
			
			polyOp.setEdgeSelection obj short_edges
			obj.EditablePoly.collapse #Edge
			obj.EditablePoly.deleteIsoVerts ()
			obj.EditablePoly.DeleteIsoMapVerts ()
		)
	)
	fn optimizeCurbsAndFences sel = (
	
		if sel.count == 0 do return (mcMsgList.warn "not_sel")
		local id_list = #(30, 56)
		local max_len = spn_chamfer_len.value
		if sel.count == 1 do subobjectlevel = 0
		setCommandPanelTaskMode mode:#create
		for o in selection where classOf o == Editable_Poly do (
		
			local faces = mcPoly.getFacesByIDs o id_list
			if faces.count == 0 do continue
			local fedges = polyOp.getEdgesUsingFace o faces
			optimizeEdges o fedges max_len
		)
		setCommandPanelTaskMode mode:#modify
		if sel.count == 1 do subobjectlevel = 4
	)
	fn optimizeChamfers obj = (
		
		if classOf obj != Editable_Poly do return (mcMsgList.warn "not_poly")
		local sel_faces = polyOp.getFaceSelection obj
		if sel_faces.numberset == 0 do return (mcMsgList.warn "not_fsel")
		local max_len = spn_chamfer_len.value
		local fedges = polyOp.getEdgesUsingFace obj sel_faces
		subobjectlevel = 0
		setCommandPanelTaskMode mode:#create
		optimizeEdges obj fedges max_len
		setCommandPanelTaskMode mode:#modify
		subobjectlevel = 4
	)
	fn optimizeHardSurfaces sel = (
		
		if sel.count == 0 do return (mcMsgList.warn "not_sel")
		
	)
	fn init = (
	
		lbl_units_01.text = lbl_units_02.text = units_type
	
	)
	on mcCollisionOptimizeDialog open do init()
	on btn_optimize_chamfers pressed  do undo label:"Optimize Chamfers" on (optimizeChamfers (selection as array)[1])
	on btn_optimize_hard pressed  do undo label:"Optimize Hard Surfaces" on (optimizeHardSurfaces (selection as array)[1])
	on btn_opt_curb_and_fences pressed  do undo label:"Optimize Curbs And Fences" on (optimizeCurbsAndFences (selection as array))
	on btn_opt_loop_by_n pressed  do undo label:"Optimize Loop By 2" on (selectEachEdgeInLoop (selection as array)[1] spn_lop_each.value)
	on btn_unchamfer_edges pressed  do undo label:"Unchamfer Edges " on (unchamferEdges (selection as array)[1])
)
createDialog mcCollisionOptimizeDialog