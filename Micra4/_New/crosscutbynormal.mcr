macroScript crossCutByNormal
	buttonText:"CrossCut by Normal"
	toolTip:"CrossCut by Normal"
	category:"Shortcuts"
(
	fn tryCrossCut obj = if selection.count == 1 and (isKindOf obj Editable_Poly or (isKindOf obj Edit_Poly and isKindOf polyModOp structDef)) do
	(
		local polySwitch = case classOf obj of (Editable_Poly: polyOp; Edit_Poly: polyModOp;)
		local cutVerts = case subObjectLevel of
		(
			1: polySwitch.getVertSelection obj as array
			2: if (local edgeSel = polySwitch.getEdgeSelection obj).numberSet == 2 then
				   for edge in edgeSel collect polySwitch.divideEdge obj edge 0.5
			   else return undefined
			default: return undefined
		)

		if cutVerts.count == 2 do
		(
			local startVertFaces = polySwitch.getFacesUsingVert obj cutVerts[1]
			local endVertFaces = polySwitch.getFacesUsingVert obj cutVerts[2]
			local endPos = polySwitch.getVert obj cutVerts[2]
			local startDir = [0, 0, 0]
			local endDir = [0, 0, 0]

			for face in startVertFaces do startDir += polySwitch.getFaceNormal obj face
			for face in endVertFaces do endDir += polySwitch.getFaceNormal obj face
			
			polySwitch.cutVert obj cutVerts[1] endPos (normalize (normalize startDir + normalize endDir))
			notifyDependents obj partIDmsg:#display
			completeRedraw()
		)
	)

	on execute do tryCrossCut (modPanel.getCurrentObject())
)