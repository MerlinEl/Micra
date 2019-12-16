Global mcModelingToolsDialog
if mcModelingToolsDialog != undefined do destroyDialog mcModelingToolsDialog
rollout mcModelingToolsDialog "Modeling Tools" width:484 height:264
(
	GroupBox 'grp1' "Select:" pos:[4,4] width:156 height:256 align:#left
	GroupBox 'grp2' "Cut:" pos:[164,4] width:156 height:256 align:#left
	GroupBox 'grp3' "Build:" pos:[324,4] width:156 height:256 align:#left
	
	label 'lbl5' "each:" pos:[80,28] width:28 height:16 align:#left
	button 'btn_loop_by' "Edge loop" pos:[12,24] width:64 height:24 align:#left
	spinner 'spn_lop_each' "" pos:[108,28] width:40 height:16 range:[0,99,1] type:#integer align:#left
	button 'btn_split_face' "Face Slice Fan" pos:[168,24] width:144 height:24 align:#left
	
	fn multiSliceFaces = (

		tool SplitEdgePoints (
		
			local p, start_point, split_points = #(), mark_points = #()
			on mousePoint click do coordsys grid (
			
				if click == 1 then (
				
					start_point = gridPoint
					p = point pos:gridPoint wirecolor:green centermarker:off axistripod:off cross:on box:off constantscreensize:on drawontop:on
					append mark_points p
					
				) else if click > 2 do (
				
					append split_points gridPoint
					p = point pos:gridPoint wirecolor:green centermarker:off axistripod:off cross:on box:off constantscreensize:on drawontop:on
					append mark_points p
				)
			)
			on stop do (
			
				--format "start_point:% split_points:%\n" start_point split_points
				delete mark_points
				
				local obj = selection[1]
				if classOf obj != Editable_Poly do return (mcMsgList.warn "not_poly")
				local fsel = polyOp.getFaceSelection obj
				if fsel.numberset == 0 do return (mcMsgList.warn "not_fsel")
				mcPoly.sliceFacesBy2Points obj fsel start_point split_points
			)
		)
		starttool SplitEdgePoints
	)
	fn selectEachEdgeInLoop obj skip_each = (
	
		if classOf obj != Editable_Poly do return (mcMsgList.warn "not_poly") 
		local two_edges = polyOp.getEdgeSelection obj
		if two_edges.numberset != 2 do return (mcMsgList.warn "not_esel_2")  
		local eloop = mcPoly.getLoopBetweenTwoEdges obj two_edges skipEach:skip_each
		polyOp.setEdgeSelection obj eloop
		redrawViews()
	)
	
	on btn_split_face pressed do undo label:"Mulit Slice Face" on (multiSliceFaces())
	on btn_loop_by pressed  do undo label:"Optimize Loop By 2" on (selectEachEdgeInLoop (selection as array)[1] spn_lop_each.value)
)
createDialog mcModelingToolsDialog