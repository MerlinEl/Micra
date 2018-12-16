Global mcSelVertsInXDialog
if mcSelVertsInXDialog != undefined do destroyDialog mcSelVertsInXDialog

rollout mcSelVertsInXDialog "Untitled" width:144 height:104
(
	local dMove = false, DmPos
	GroupBox grp1 "Fuse Vertices to Center:" pos:[4,4] width:136 height:96
	button btnConect "FUSE" pos:[52,72] width:80 height:20
	radiobuttons rdo_axis "Axis:" pos:[12,32] width:30 height:62 labels:#("X", "Y", "Z") default:1 columns:1
	checkbox chk_grid "" pos:[116,30] width:16 height:20
	label lbl2 "Snap to grid:" pos:[52,32] width:64 height:16
	-- Functions
	fn FuseVertsInLine =
	(
		local axis   = rdo_axis.state 
		local togrid = chk_grid.checked
		
		local obj = selection[1]
		if classOf obj != Editable_Poly do return false
		local edge_sel, vert_sel = #{}
		
		if subobjectLevel == 2
		then
		(
			edge_sel = polyOp.getEdgeSelection obj
			for i in edge_sel do vert_sel += polyOp.getVertsUsingEdge obj i
		)
		else if subobjectLevel == 1
		then
		(
			vert_sel = polyOp.getVertSelection obj
		)
		else return false
		
		if vert_sel.count == 0 do return false
		local mid = 0
		if not togrid do
		(
			local mi
			local ma
			for v in vert_sel do
			(
				local vert_pos = polyop.getvert obj v 
				local vert_axis = case axis of
				(
					1:(vert_pos.x) --X
					2:(vert_pos.y) --Y
					3:(vert_pos.z) --Z
				)
				if mi != undefined 
				then 
				(
					mi = amin #(vert_axis, mi)
					ma = amax #(vert_axis, ma)
				)
				else mi = ma = vert_axis
			)
			mid = (mi + ma)/2
		)
		
		for v in vert_sel do
		(
			local vert_pos = polyop.getvert obj v 
			local new_pos  =	case axis of
			(
				1:([mid, vert_pos.y, vert_pos.z]) --X
				2:([vert_pos.x, mid, vert_pos.z]) --Y
				3:([vert_pos.x, vert_pos.y, mid]) --Z
			)
			polyOp.setVert obj v new_pos
		)
		
		local oldTreshold = obj.weldThreshold
		obj.weldThreshold = 0.001
		obj.EditablePoly.weldFlaggedVertices ()
		obj.weldThreshold = oldTreshold
	)
	--> MoveMode
	on mcSelVertsInXDialog rbuttonup pos   do (destroyDialog mcSelVertsInXDialog)
	on mcSelVertsInXDialog lbuttondown pos do (dMove = true; DmPos = pos; if not keyboard.shiftPressed do pushprompt "Pres Shift To Move...")
	on mcSelVertsInXDialog lbuttonup pos   do (dMove = false; pushprompt "")
	on mcSelVertsInXDialog mouseMove pos   do
	(
		if dMove and keyboard.shiftPressed do mcDialogSnap mcSelVertsInXDialog DmPos
	)
	--> Actions
	on btnConect pressed do undo "Fuse Verts In Line" on (FuseVertsInLine())
)	
createDialog mcSelVertsInXDialog style:#(#style_border)
