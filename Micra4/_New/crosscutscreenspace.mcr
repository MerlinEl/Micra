macroScript crossCutScreen
	buttonText:"CrossCut Screen-Space"
	toolTip:"CrossCut Screen-Space"
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
			gw.setTransform $.objectTransform
			local invTM = inverse $.objectTransform
			local endPos = polySwitch.getVert obj cutVerts[2]
			local dirRay = mapScreenToWorldRay (gw.transPoint endPos)
			local invDir = normalize ((dirRay.pos + dirRay.dir) * invTM - dirRay.pos * invTM)

			polySwitch.cutVert obj cutVerts[1] endPos invDir
			notifyDependents obj partIDmsg:#display
			completeRedraw()
		)
	)

	on execute do tryCrossCut (modPanel.getCurrentObject())
)