Global mcPaintSelectionSettings

(

	struct struct_mcPaintSelectionSettings (brushSize, pos)
	local paintSelectBrush
	local resizeBrushStartPos
--------------------------------------------------------------------
-- Functions to get the vertex paint of poly objects
-- this function returns a face close to the intersectin point of the object and the cursor.
	fn getPolyFaceByPos obj pos r = 
	(
		for i = 1 to polyop.getNumFaces obj where (distance (polyop.getFaceCenter obj i) pos <= r) do
			return i
		undefined
	)
-----------------------------------------------------------------------------		
-- the next 2 functions check the subobject level and perform the appropriate
-- operation for poly objects
	fn getPolySubObjSelection obj = 
	(
		case subObjectLevel of 
		(
			1: polyop.getVertSelection obj
			2: polyop.getEdgeSelection obj
			3: polyop.getFaceSelection obj
			4: polyop.getFaceSelection obj
			default: #{}
		)
	)
	
	fn setPolySubObjSelection obj sel keep:false = 
	(
		if modPanel.getCurrentObject()==obj.baseObject 
		then 
		(
			case subObjectLevel of 
			(
				1: polyop.setVertSelection obj sel
				2: polyop.setEdgeSelection obj sel
				3: polyop.setFaceSelection obj sel
				4: polyop.setFaceSelection obj sel
			)
			update obj
		) 
		else 
		(
			case subObjectLevel of 
			(
				1: setVertSelection obj (modPanel.getCurrentObject()) sel keep:keep
				2: setEdgeSelection obj (modPanel.getCurrentObject()) sel keep:keep
				3: setFaceSelection obj (modPanel.getCurrentObject()) sel keep:keep
				4: setFaceSelection obj (modPanel.getCurrentObject()) sel keep:keep
			)
		)
	)
------------------------------------------------------------------
-- the main pain function.
-- this function is called from the mouseTrack function.
	fn paintSelect msg ir obj faceNum shift ctrl alt = 
	(
		disableSceneRedraw()
		local brush = paintSelectBrush
		local resizeBrushMode = (shift AND ctrl)
		
		if NOT resizeBrushMode then 
		(
			try (brush.pos = ir.pos) catch()
			try (brush.dir = ir.dir) catch()
			resizeBrushStartPos = undefined
		)
		brush.scale = [1,1,1]*((getScreenScaleFactor brush.pos)/100.)
	
		pushprompt "Paint Selection : LMB=Add / Alt+LMB=Substract / RMB=Exit"
		
		if (msg == #mouseMove OR msg == #mousePoint) AND NOT (shift AND ctrl) then 
		(
			local r = brush.radius * brush.scale.x
			local curSel = #{}
			local newSel = #{}
			local keep = false
			
			if classOf obj == Editable_poly OR classOf obj == PolyMeshObject then 
			(
				curSel = getPolySubObjSelection obj
 				newSel = #{}
				if ir!=undefined then 
				(
					faceNum = getPolyFaceByPos obj ir.pos r
					if faceNum != undefined then newSel = #{faceNum}
				) 
				if alt 
				then newSel = curSel - newSel
				else
				--if ctrl then 
				(
					newSel = curSel + newSel
					keep = true
				)
				setPolySubObjSelection obj newSel keep:keep
			)
		)

		if resizeBrushMode AND (msg == #mouseMove OR msg == #mousePoint) then 
		(
			if resizeBrushStartPos == undefined then
				resizeBrushStartPos = mouse.pos
			local r = length ((mouse.pos-resizeBrushStartPos)/(getViewSize()*0.01))
			r = abs (r as integer)
			if r <= 1 then r = 1
			if r >= 50 then r = 50
			brush.radius = r
			if mcPaintSelectionSettings!=undefined then mcPaintSelectionSettings.brushSize = r
		)

		enableSceneRedraw()
		if msg != #mouseAbort then #continue
	)
	
	fn isEnabled = 
	(
		local c = classOf selection[1]
		selection.count == 1 and subobjectlevel != undefined and subObjectLevel > 0 and (c==Editable_mesh or c==Editable_poly or c==PolyMeshObject)
	)

	-------------
	-- EXECUTE --
	-------------
	if isEnabled() do
	(
		
		if mcPaintSelectionSettings == undefined then mcPaintSelectionSettings = struct_mcPaintSelectionSettings 5.0 [10,100]
		local r = mcPaintSelectionSettings.brushSize
		paintSelectBrush = circle name:"paintSelectBrush" radius:r wireColor:(color 230 230 0) displayRenderMesh:false
		local obj = selection[1]
		mouseTrack on:obj prompt:"" trackCallback:paintSelect
		delete paintSelectBrush
		paintSelectBrush = undefined
		pushprompt ""
		enableSceneRedraw()
	)
	
)

/*

Global mcPolygonPaint

(
	struct mcMousePaint
	(	
		fn getFace meshObj polyObj =
		(
			--getVertsFrom meshObj
			local RayEx = (intersectRayEx meshObj (mapScreentoWorldRay mouse.pos))
			if RayEx == undefined do return undefined
			local verts = (meshop.getVertsUsingFace meshObj RayEx[2])
			--find face in polyObj from verts
			local faces = polyOp.getFacesUsingVert polyObj verts
			for f in faces do
			(
				local fVerts = polyOp.getVertsUsingFace polyObj f
				if (fVerts * verts).numberset >= 3 do return f
			)		
		),
		fn sortVerts polyObj f =
		(
			local edges = polyOp.getEdgesUsingFace polyObj f as array
			local eVerts = for i in edges collect polyOp.getVertsUsingEdge polyObj i as array
			local eCount = edges.count
			local sortedVerts = #(eVerts[1][2])
			deleteItem eVerts 1
			while eVerts.count != 0 do
			(
				local sCount = sortedVerts.count
				local pos = 0
				for i in eVerts do
				(
					pos+=1
					local a = i[1] == sortedVerts[sCount] 
					local b = i[2] == sortedVerts[sCount] 
					
					if a then (sortedVerts += #(i[2]) ; deleteItem eVerts pos )
					else
					if b then (sortedVerts += #(i[1]) ; deleteItem eVerts pos )	
				)
			)
			return sortedVerts
		),
		fn getFaceBorders polyObj f =
		(
			local vPos = #()
			local eVerts = mcMousePaint.sortVerts polyObj f
			for v in eVerts do vPos += #(polyOp.getVert polyObj v)
			return vPos
		) ,
		fn highlightFaceBorders2 polyObj f fCenter col =
		(
			gw.setTransform (Matrix3(1))
			gw.setColor #line col
			
			gw.polyline (mcMousePaint.getFaceBorders polyObj f) true
			gw.hMarker (gw.hTransPoint fCenter) #triangle color:col
			gw.enlargeUpdateRect #whole
			gw.updateScreen()
		)
	)
	
	if mcPoly.isInPoly() do
	(
		tool mcPolygonPaint
		(
			local enabled = true
			local fSel
			local meshObj
			local polyObj=(selection as array)[1] 
			
			on start do if polyObj != undefined do
			(
				meshObj = snapshot polyObj name:(uniquename "mcTempModel_")
				hide meshObj
				try (max modify mode; subObjectLevel = 4) catch()
				flagForeground polyObj true
			)
			on mousePoint clickno do
			(
				enabled = not enabled
			)
		
			on mouseMove clickno do if enabled then
			(
				if mcPoly.isInPoly() do
				(
					local f  = mcMousePaint.getFace meshObj polyObj
					if fSel == undefined do fSel = polyOp.getFaceSelection polyObj
							
					if f != undefined do
					(
						local exist = findItem fSel f
						local fCenter = polyOp.getFaceCenter polyObj f
						
						if keyboard.altPressed 
						then if exist != 0 do
						(
							mcMousePaint.highlightFaceBorders2 polyObj f fCenter white --polyObj.wirecolor
							deleteItem fSel exist
						)
						else if exist == 0 do
						(
							mcMousePaint.highlightFaceBorders2 polyObj f fCenter red
							append fSel f
						)
					)
				)
			)
			on stop do if polyObj != undefined  do 
			(
				if fSel != undefined do polyOp.setFaceSelection polyObj fSel
				flagForeground polyObj false
				if isValidNode meshObj  do delete meshObj
			)
		)
	)
	starttool mcPolygonPaint
)
*/

/*
 	with redraw off 
	local tm = Matrix3(1)
	tm.row3 = -(Inverse(viewport.getTM())).row3
	--disableSceneRedraw()
	--suspendEditing()
	--enableSceneRedraw()
	--resumeEditing()
	fn drawMark pos col =
	(
		gw.setTransform (Matrix3(1))
		gw.Marker pos #triangle color:col
		gw.enlargeUpdateRect #whole
		gw.updateScreen()
	),
	fn highlightFaceBorders polyObj f col =
	(
		local verts = polyOp.getVertsUsingFace polyObj f as array
		gw.setColor #line col
		local pos = (for v=1 to verts.count collect polyOp.getVert polyObj verts[v])
		
		if verts.count == 4 
		then gw.polyline #(pos[1], pos[2], pos[4], pos[3]) true
		else gw.polyline #(pos[1], pos[2], pos[3]) true
	
		gw.enlargeUpdateRect #whole
		gw.updateScreen()
	),
*/