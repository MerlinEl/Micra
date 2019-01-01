
--Edge Ring Unify
(
	fn straightenEdgeRing obj type:#center =
	(
		if classOf obj != Editable_Poly do return false
		local edge_sel = polyOp.getEdgeSelection obj 
		if edge_sel.numberSet == 0 do return false
		
		local all_edges_len = 0
		struct EDGE_DATA (num, verts, pos, len)
		local ED = #()
		for i in edge_sel do 
		(
			local edge_verts = (polyOp.getVertsUsingEdge obj i) as array
			local p1  = polyOp.getVert obj edge_verts[1]
			local p2  = polyOp.getVert obj edge_verts[2]
			--get all edges length
			local len = distance p1 p2
			--collect edges data
			ED += #(EDGE_DATA i edge_verts #(p1, p2) len)
			all_edges_len += len
		)
		--get edges diameter
		local dia = all_edges_len / edge_sel.numberSet
		--format "edges diameter:%\n" dia
		undo "Straighten Edge Ring" on
		(
			case type of 
			(
				#center:
				(
					for i in ED do 
					(
						local p1 = i.pos[1]
						local p2 = i.pos[2]
						local mid = (p1 + p2)/2
						local v1 = mid - p2
						local v2 = mid - p1
						local new_p1 = ((normalize v1)* (dia/2))+mid
						local new_p2 = ((normalize v2)* (dia/2))+mid
						polyOp.setVert obj i.verts[1] new_p1
						polyOp.setVert obj i.verts[2] new_p2
					)
				)
				#left:()
				#right:()
			)
		)
	)

	--execute
	straightenEdgeRing selection[1]
)


/*
Global mcEdgeScaleDialog
(
	local sel = selection[1]
	if sel != undefined and classOf sel == Editable_Poly do
	(
		if mcEdgeScaleDialog != undefined do destroyDialog mcEdgeScaleDialog
		rollout mcEdgeScaleDialog "" width:188 height:108
		(
			local dMove = false, DmPos
			groupBox grp4 "AlignEdgeScale:" pos:[4,4] width:180 height:100
			radiobuttons rdoWay "" pos:[12,56] width:155 height:16 labels:#("A-B", "B-A") columns:2--, "Center") columns:3
			button btnCancel "Cancel" pos:[12,76] width:80 height:20
			button btnAccept "Accept" pos:[96,76] width:80 height:20
			button btnPick "Get Edge" pos:[12,28] width:80 height:20 toolTip:"Define first edge length"
			spinner spnEdgeLen "len:" pos:[100,30] width:76 height:16 range:[0.0001,10000,0.1] type:#float scale:0.0001
			fn getEdgeLenght =
			(
				local sel = selection [1]
				if sel == undefined or classOf sel != Editable_Poly do return undefined 
				local edges = (modPanel.getCurrentObject()).getSelection #Edge as array
				if edges.count == 0 do return false
				local verts = polyOp.getVertsUsingEdge sel edges[1] as array
				local vPos = #(polyOp.getVert sel verts[1],polyOp.getVert sel verts[2])
				spnEdgeLen.value = distance vPos[1] vPos[2]
				btnPick.text = "edge: "+ edges[1] as string
			)
			fn scaleEdgeIn type =
			(	
				local firstELenght = spnEdgeLen.value
				local edges = (modPanel.getCurrentObject()).getSelection #Edge
				if edges.count < 2 do return false
				for i in edges do 
				(
					local verts = polyOp.getVertsUsingEdge $ i as array
					local vPos = #(polyOp.getVert $ verts[1],polyOp.getVert $ verts[2])
					
					local theVerts = case type of
					(
						#Up:#(verts[1],verts[2])
						#Down:#(verts[2],verts[1])
					)
					local theVPos = case type of
					(
						#Up:#(vPos[1],vPos[2])
						#Down:#(vPos[2],vPos[1])
					)
					
					local nextELenght = distance theVPos[1] theVPos[2]
					local theDifference = (firstELenght / nextELenght)
					
					local theVector = theVPos[2] - theVPos[1]
					local thePos = theVPos[2] + (theVector * (theDifference-1))
					polyOp.setVert $ theVerts[2] thePos 
				)
			)
			on mcEdgeScaleDialog close do(mcFile.saveIniDialog "mcEdgeScaleDialog" "Properties_2")
			on mcEdgeScaleDialog rbuttonup pos do (destroyDialog mcEdgeScaleDialog)
			-->MoveMode
			on mcEdgeScaleDialog lbuttondown pos do (dMove = true; DmPos = pos; if not keyboard.shiftPressed do pushprompt "Pres Shift To Move...")
			on mcEdgeScaleDialog lbuttonup   pos do (dMove = false; pushprompt "")
			on mcEdgeScaleDialog mouseMove   pos do
			(
				if dMove and keyboard.shiftPressed do mcDialog.snapDialog mcEdgeScaleDialog DmPos
			)
			on btnCancel pressed do(destroyDialog mcEdgeScaleDialog)
			on btnPick pressed do (getEdgeLenght())
			on btnAccept pressed do undo "Edge Scale Align" on
			(
				if selection.count != 0 and classOf selection[1] == Editable_Poly do 
				max modify mode
				local theWay = case rdoWay.state of
				(
					1:#Up
					2:#Down
				)
				scaleEdgeIn theWay
			)
		)
		mcCall.createIniDialog "mcEdgeScaleDialog" "Properties_2"
	)
)
*/