
Global mcCollisionOptimizeDialog
if mcCollisionOptimizeDialog != undefined do destroyDialog mcCollisionOptimizeDialog
rollout mcCollisionOptimizeDialog "Collisions Optimizer:" width:328 height:144
(
	local units_type = mcSystem.unitsType()
	GroupBox 'grp1' "Optimize Chamfers:" pos:[0,4] width:160 height:68 align:#left
	GroupBox 'grp2' "Optimize Hard Smooths:" pos:[164,4] width:160 height:68 align:#left
	GroupBox 'grp11' "Result:" pos:[0,76] width:324 height:64 align:#left
	label 'lbl1' "Max length:" pos:[12,24] width:60 height:16 align:#left
	label 'lbl_units_01' "cm" pos:[136,24] width:16 height:16 align:#left
	label 'lbl3' "Max distance:" pos:[176,24] width:60 height:16 align:#left
	label 'lbl_units_02' "cm" pos:[304,24] width:16 height:16 align:#left
	label 'lbl21' "Optimized Objects:" pos:[8,96] width:92 height:16 align:#left
	label 'lbl22' "Optimized Edges:" pos:[8,116] width:92 height:16 align:#left
	label 'lbl_result_objects' "0" pos:[104,96] width:212 height:16 align:#left
	label 'lbl_result_edges' "0" pos:[104,116] width:212 height:16 align:#left
	button 'btn_optimize_chamfers' "Optimize Chamfer Edges" pos:[8,44] width:144 height:20 align:#left
	button 'btn_optimize_hard' "Optimize Hard Edges" pos:[172,44] width:144 height:20 align:#left
	spinner 'spn_chamfer_len' "" pos:[72,24]  width:60 height:16 range:[0,1e+06,3] type:#float align:#left
	spinner 'spn_hard_dist' ""   pos:[240,24] width:60 height:16 range:[0,1e+06,3] align:#left
	fn selectEachEdgeInLoop obj skipEach:1 = (
	
		if classOf obj != Editable_Poly do return (mcMsgList.warn "not_poly") 
		local two_edges = polyOp.getEdgeSelection obj
		if two_edges.numberset != 2 do return (mcMsgList.warn "not_esel_2")  
		local eloop = mcPoly.getLoopBetweenTwoEdges obj two_edges
		polyOp.setEdgeSelection obj eloop skipEach:skipEach
		redrawViews()
	)
	fn optimizeChamfers sel = (
		
		if sel.count == 0 do return (mcMsgList.warn "not_sel")
		setCommandPanelTaskMode mode:#create
		local max_len = spn_chamfer_len.value
		local optimized_objects = 0
		local optimized_edges = 0
		for o in selection where classOf o == Editable_Poly do (
		
			local short_edges = for i = 1 to o.edges.count where mcPoly.getEdgeLength o i <= max_len collect i
			if short_edges.count > 0 do (
				
				optimized_objects += 1
				optimized_edges += short_edges.count
				polyOp.setEdgeSelection o short_edges
				o.weldThreshold = 0.001
				polyOp.weldVertsByThreshold o o.verts
				o.EditablePoly.collapse #Edge
				o.EditablePoly.deleteIsoVerts ()
				o.EditablePoly.DeleteIsoMapVerts ()
			)
			lbl_result_objects.text = optimized_objects as String
			lbl_result_edges.text = optimized_edges as String
		)
	)
	fn optimizeHardSurfaces sel = (
		
		if sel.count == 0 do return (mcMsgList.warn "not_sel")
		
	)
	fn init = (
	
		lbl_units_01.text = lbl_units_02.text = units_type
	
	)
	on mcCollisionOptimizeDialog open do init()
	on btn_optimize_chamfers pressed  do undo label:"Optimize Chamfers" on (optimizeChamfers (selection as array))
	on btn_optimize_hard pressed  do undo label:"Optimize Hard Surfaces" on (optimizeHardSurfaces (selection as array))
)
createDialog mcCollisionOptimizeDialog