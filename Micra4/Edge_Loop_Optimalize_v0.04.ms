------------------------------
------------------------------
--                          --
--   Edge Loop Optimalize   --
--                          --
------------------------------
------------------------------
----------------------------------------------------------------------------
if mcELOpDialog != undefined then destroyDialog mcELOpDialog
----------------------------------------------------------------------------

----------------------------------------------------------------------------

rollout mcELOpDialog "Untitled" width:220 height:60
(
	--Locals:----------------------------------------
	local dMove = false, DmPos
	spinner spn_num "" pos:[80,24] width:56 height:16 enabled:true range:[2,100,2] type:#integer scale:1
	groupBox grp2 "Loop Optimize" pos:[4,4] width:212 height:52
	label lbl1 "select each:" pos:[12,24] width:68 height:16
	button btn_accept "Accept" pos:[144,20] width:60 height:24
	button btn_close "*" pos:[204,4] width:12 height:12
	
	fn compare_edge_verts obj e1 e2 =
	(
		--format "e1:%\te2:%\n" e1 e2
		if e1 == undefined or e2 == undefined do return false
		
		local e1_Verts = polyOp.getEdgeVerts obj e1
		local e2_Verts = polyOp.getEdgeVerts obj e2
		--format "e1_Verts:%\te2_Verts:%\n" e1_Verts	e2_Verts	
		if e1_Verts[2] == e2_Verts[1] then return true 
		else 
		if e1_Verts[2] == e2_Verts[2] then return true 
		else 
		if e1_Verts[1] == e2_Verts[1] then return true 
		else 
		if e1_Verts[1] == e2_Verts[2] then return true 
		return false
	)
	--
	fn optimize_loop num:2 =
	(
		--error filter
		local obj = selection[1]
		if obj == undefined or classOf obj != Editable_Poly do return false
		local all_edges = polyOp.getEdgeSelection obj as array
		if all_edges.count < 2 do return false
		
		--variables
		local current_edge = all_edges[1]
		local sorted_edges = #(current_edge)
		local first_edge_vert2 = (polyOp.getEdgeVerts obj current_edge)[1]
		
		deleteitem all_edges 1
		
		while current_edge != undefined and not keyboard.escPressed do
		(
			--print "while next round"
			for idx = 1 to all_edges.count do
			(
				local second_edge = all_edges[idx]
				local found = compare_edge_verts obj current_edge second_edge
				--format "found:%\n" found
				if found then
				(
					current_edge = second_edge
					sorted_edges += #(current_edge)
					deleteitem all_edges idx
					--format "sorted_edges in loop end:%\n" sorted_edges
					exit
				)
				else if idx == all_edges.count do
				(
					current_edge = undefined
				)
			)
			if all_edges.count == 0 do current_edge = undefined
		)
		--print "while exit" 
		--format "sorted_edges:%\n" sorted_edges
		--filtering edges by num
		local my_edges = (for i=1 to sorted_edges.count by num collect sorted_edges[i])
		undo "Loop Optimize" on (polyOp.setEdgeSelection obj my_edges)
		completeRedraw()
	)

	-->DialogProp --------------------------------------------------------------------
	on mcELOpDialog close do 
	( 
		mcCall.saveIniDialog "mcELOpDialog" "Properties_2"
	)
	on mcELOpDialog rbuttonup pos do (destroyDialog mcELOpDialog)
	-->MoveMode
	on mcELOpDialog lbuttondown pos do (dMove = true; DmPos = pos; if not keyboard.shiftPressed do pushprompt "Pres Shift To Move...")
	on mcELOpDialog lbuttonup   pos do (dMove = false; pushprompt "")
	on mcELOpDialog mouseMove   pos do
	(
		if dMove and keyboard.shiftPressed do 
		(
			if mcDialogSnappingEnabled 
			then mcDialogSnap mcELOpDialog DmPos
			else setDialogPos mcELOpDialog (mouse.screenpos - DmPos)
		)
	)
	
	on btn_accept pressed  do
	(
		optimize_loop num:spn_num.value
	)
	on btn_close pressed  do
	(
		destroyDialog mcELOpDialog
	)
)
mcCall.createIniDialog "mcELOpDialog" "Properties_2"
