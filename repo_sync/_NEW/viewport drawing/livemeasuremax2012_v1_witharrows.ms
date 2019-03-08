--******************************************************************************************************
-- Created: 		22-09-2011
-- Last Updated:	28-12-2011
-- Version:			1.1
--
-- Author :  Kostadin Kotev / miau_u@yahoo.com /
-- Version:  3ds max 2012 (work in older versions too!)
--
-- Discription: Script idea by @harumscarum 
--	Measure and show edges length, segments length and faces area in real time. Work with Spline, Editable_Poly and 
--	Editable_mesh objects and Edit_Poly modifier.
--		In Polygon/Element sub-object level will show the selected faces area in generic units only.
--		In Edge/Border sub-object level will show the length of selected edges in user defined units.
--		In vertex sub-object level, when vertex is move will show the length of edges that is common for the selected vertex.
--		If top sub-object level is active will show the dimension of the selected object.
-- The edge/segment length and face area will update when the edges/segments/faces are scaled or when the vertex is moved.
-- In top left corner of the viewport will be shown the total face area or total edge length.

-- Usage: Assign to a hotkey and run it. The script work as a toggle - press the hotkey to start, press again to stop the script.
--
--	Thanks to @kilad for his help.
--******************************************************************************************************
-- MODIFY THIS AT YOUR OWN RISK

macroscript LiveMeasureMAX2012
category:"miauu"
tooltip:"Live Measure for max2012"
buttonText:"Live Measure for max2012"
(
	global DrawTextOnViewports
	global rol_TextColor
	unRegisterRedrawViewsCallback DrawTextOnViewports
	
	local drawFaceArea = false
	local selSpline = undefined
	local edgeLengthArr = #()
	local textColor = green
	local overAll = "Nothing to display ! Go to Edge or Polygon sub-object level !"
	local objLength = undefined
	local objHeight = undefined
	local objWidth = undefined
	local backLeftBottom = undefined
	local frontLeftBottom = undefined
	local backLeftTop = undefined
	local backRightBottom = undefined
	local lineArr = #(undefined,undefined,undefined)
	local linePoints = #([0,0,0], [0,0,0])
	
	local moGetFaceArea = meshop.getFaceArea
	local moGetNumFaces = meshOp.getNumFaces
	local moGetFaceCenter = meshop.getFaceCenter
	local meshGetFaceSel = getFaceSelection
	local moGetVertsUsingEdge = meshop.getVertsUsingEdge
	local moGetVert = meshop.getVert
	local moGetFacesUEdge = meshop.getFacesUsingEdge
	local meshGetEdgeSel = getEdgeSelection
	local moGetEdgesUVert = meshop.getEdgesUsingVert
	
	local poGetNumFaces = polyOp.getNumFaces
	local poGetFaceCenter = polyop.getFaceCenter
	local poGetFaceSel = polyOp.getFaceSelection
	local poGtEdgeVerts = polyOp.getEdgeVerts
	local poGetVertSel = polyOp.getVertSelection
	local poGetEdgeSel = polyOp.getEdgeSelection
	local poGetVert = polyOp.getVert
	local poGetFaceArea = polyOp.getFaceArea
	local poGetFacesUEdge = polyop.getFacesUsingEdge
	local poGetEdgesUVert = polyop.getEdgesUsingVert
	
	function ClearViewports =
	(
		edgeLengthArr = undefined
		selSpline = undefined
		overAll = undefined
		objLength = undefined
		objHeight = undefined
		objWidth = undefined
		lineArr = #(undefined,undefined,undefined)
		linePoints = #([0,0,0], [0,0,0])
		unRegisterRedrawViewsCallback DrawTextOnViewports
		forceCompleteRedraw()
	)
	
	function RemoveArrows =
	(
		if isValidNode $ArrowY do delete $ArrowY
		if isValidNode $ArrowZ do delete $ArrowZ
		if isValidNode $ArrowX do delete $ArrowX
		if isValidNode $ArrowY1 do delete $ArrowY1
		if isValidNode $ArrowZ1 do delete $ArrowZ1
		if isValidNode $ArrowX1 do delete $ArrowX1
	)
	function PaintArrows clr =
	(
		if isValidNode $ArrowY do $ArrowY.wirecolor = clr
		if isValidNode $ArrowZ do $ArrowZ.wirecolor = clr
		if isValidNode $ArrowX do $ArrowX.wirecolor = clr
		if isValidNode $ArrowY1 do $ArrowY1.wirecolor = clr
		if isValidNode $ArrowZ1 do $ArrowZ1.wirecolor = clr
		if isValidNode $ArrowX1 do $ArrowX1.wirecolor = clr
	)
	
	function VertSelMiddleCenter vertSel curObj sN type =
	(
		local posX = 0
		local posY =0
		local posZ = 0
		local cnt = 0
		case type of
		(
			1:	--	editable_poly
			(
				for i in vertSel do
				(
					posX = posX + (in coordsys world (poGetVert curObj i).x)
					posY = posY + (in coordsys world (poGetVert curObj i).y)
					posZ = posZ + (in coordsys world (poGetVert curObj i).z)
					cnt = cnt + 1	
				)
			)
			2:	--	edit_poly
			(
				for i in vertSel do
				(
					posX = posX + (in coordsys world (curObj.GetVertex i).x)
					posY = posY + (in coordsys world (curObj.GetVertex i).y)
					posZ = posZ + (in coordsys world (curObj.GetVertex i).z)
					cnt = cnt + 1	
				)
			)
			3:	--	editable_mesh
			(
				for i in vertSel do
				(
					posX = posX + (in coordsys world (moGetVert curObj i).x)
					posY = posY + (in coordsys world (moGetVert curObj i).y)
					posZ = posZ + (in coordsys world (moGetVert curObj i).z)
					cnt = cnt + 1	
				)
			)
			4:	--	editable_spline
			(
				for i in vertSel do
				(
					posX = posX + (in coordsys world (getKnotPoint curObj sN i).x)
					posY = posY + (in coordsys world (getKnotPoint curObj sN i).y)
					posZ = posZ + (in coordsys world (getKnotPoint curObj sN i).z)
					cnt = cnt + 1	
				)
			)
		)
		middleX = posX / cnt
		middleY = posY / cnt
		middleZ = posZ / cnt
		
		point3 middleX middleY middleZ 
	)
	
	function GetEdgeUsingVertsEPM curSel edges =
	(
		local edgeVerts = #()
		for i in edges do
		(
			edgeVerts[1] = curSel.GetEdgeVertex i 1 node:$
			edgeVerts[2] = curSel.GetEdgeVertex i 2 node:$
		)
		edgeVerts
	)
	function GetEdgeLength curSel edgeIdx mode =
	(
		local vertPos = undefined
		case mode of
		(
			1:
			(
				local edgeVerts = poGtEdgeVerts curSel edgeIdx
				vertPos = for iVert in edgeVerts collect poGetVert curSel iVert						
			)
			2:
			(
				local edgeVerts = GetEdgeUsingVertsEPM curSel #(edgeIdx)
				vertPos = for iVert in edgeVerts collect curSel.GetVertex iVert
			)
			3:
			(
				local edgeVerts = moGetVertsUsingEdge curSel edgeIdx
				vertPos = for iVert in edgeVerts collect moGetVert curSel iVert 						
			)
		)		
		distance vertPos[1] vertPos[2]
	)
	function GetEdgesLengthEP selEdges =
	(
		local curO = selection[1]		
		edgeLengthArr = #()
		local fullLength = 0
		for i = 1 to selEdges.count do
		(
			curLength = GetEdgeLength curO selEdges[i] 1
			fullLength += curLength
			edgeVerts = poGtEdgeVerts curO selEdges[i]
			append edgeLengthArr #(curLength,(VertSelMiddleCenter edgeVerts curO 0 1))
		)
		overAll = "Total length: "+(units.formatValue fullLength) as string
	)
	function GetEdgesLengthEPM curObj selEdges =
	(
		edgeLengthArr = #()	
		local fullLength = 0
		for i = 1 to selEdges.count do
		(
			edgeVerts = GetEdgeUsingVertsEPM curObj #(selEdges[i])
			curLength = GetEdgeLength curObj selEdges[i] 2
			fullLength += curLength
			append edgeLengthArr #(curLength,(VertSelMiddleCenter edgeVerts curObj 0 2))
		)
		overAll = "Total length: "+(units.formatValue fullLength) as string
	)
	function GetEdgesLengthEM selEdges =
	(
		local curO = selection[1]		
		edgeLengthArr = #()
		local fullLength = 0
		for i = 1 to selEdges.count do
		(
			edgeVerts = moGetVertsUsingEdge curO selEdges[i]
			curLength = GetEdgeLength curO selEdges[i] 3
			fullLength += curLength
			append edgeLengthArr #(curLength,(VertSelMiddleCenter edgeVerts curO 0 3))
		)	
		overAll = "Total length: "+(units.formatValue fullLength) as string	
	)
	
	function DrawTextOnViewports =
	(
		gw.setTransform(Matrix3 1)
		
		if edgeLengthArr.count < 10 do
		(--	show the length/area only if the count of selected edges/segments/faces is less then 10
			for i = 1 to edgeLengthArr.count do
			(
				posInScreen = gw.TransPoint (edgeLengthArr[i][2])
				if drawFaceArea then	--	show face area in only generic units
					lengthTXT = (edgeLengthArr[i][1] as string)
				else	--	show length in user defined units
					lengthTXT = units.formatValue ((edgeLengthArr[i][1])as float) 	
				gw.wText posInScreen lengthTXT color:textColor	
			)			
		)
		--	draw the overall length/area in top left corner of the viewport
		gw.wText [4,32,0] overAll color:textColor
		--	draw objects length-width-height cage
		if objLength != undefined and objHeight != undefined and objWidth != undefined do
		(
			for i = 1 to lineArr.count do
			(
				linePoints[1]= gw.wTransPoint lineArr[i][1]
				linePoints[2]= gw.wTransPoint lineArr[i][2]
				gw.setColor #line textColor
				gw.wPolyline linePoints false
				gw.wMarker linePoints[1] #plusSign color:[255,0,0]
				gw.wMarker linePoints[2] #plusSign color:[255,0,0]
			)
		)
		gw.enlargeUpdateRect #whole
		gw.updateScreen()
	)
	
	registerRedrawViewsCallback DrawTextOnViewports
	function StartDrawing =
	(
		DrawTextOnViewports()
		-- use Cone primitive as arrows
		if objLength != undefined and objHeight != undefined and objWidth != undefined do
		(
			RemoveArrows()
			Cone name:"ArrowY" heightsegs:1 capsegs:1 sides:4 height:2 radius1:1 radius2:0 pos:(lineArr[1][2]) wirecolor:green
			in coordsys world (rotate $ArrowY (eulerAngles 90.0 0.0 0.0))				
			Cone name:"ArrowZ" heightsegs:1 capsegs:1 sides:4 height:2 radius1:1 radius2:0 pos:(lineArr[2][2]) wirecolor:green			
			Cone name:"ArrowX" heightsegs:1 capsegs:1 sides:4 height:2 radius1:1 radius2:0 pos:(lineArr[3][2]) wirecolor:green
			in coordsys world (rotate $ArrowX (eulerAngles 0.0 90.0 0.0))
			-- cones that points to the 0 of the cage
			Cone name:"ArrowY1" heightsegs:1 capsegs:1 sides:4 height:2 radius1:0 radius2:1 pos:(lineArr[1][1]) wirecolor:green
			in coordsys world (rotate $ArrowY1 (eulerAngles 90.0 0.0 0.0))				
			Cone name:"ArrowZ1" heightsegs:1 capsegs:1 sides:4 height:2 radius1:0 radius2:1 pos:(lineArr[2][1]) wirecolor:green			
			Cone name:"ArrowX1" heightsegs:1 capsegs:1 sides:4 height:2 radius1:0 radius2:1 pos:(lineArr[3][1]) wirecolor:green
			in coordsys world (rotate $ArrowX1 (eulerAngles 0.0 90.0 0.0))
		)
		forceCompleteRedraw()
	)
	
	function GetSegmentLength selSpline =
	(
		local splineNum = numSplines selSpline
		local totalLenght = 0
		edgeLengthArr = #()		
		if splineNum != 0 then
		(
			for s=1 to splineNum do
			(	
				selSegm01 = getSegSelection selSpline s									
				for i in selSegm01 do
				(
					local lengthArray = #()
					local segmentArray = #()
					local segmentArray = getSegLengths selSpline s
					local segNum = numSegments selSpline s
					--	get the length for all segments
					for j = (segNum+1) to (segmentArray.count-1) do
					(
						append lengthArray segmentArray[j]
					)					
					--	get curent segment length
					curSegmLength = lengthArray[i]
					--	calculate the total lenght					
					totalLenght += curSegmLength
					--	get curent segment knots
					local curSegmKnots = undefined
					if (isClosed selSpline s) == true then
					(--	if spline is closed
						if i == segNum then--	text in the center	  / 	text in second knot of segment
							curSegmKnots = #(i,1)							--	#(1)
						else
							curSegmKnots = #(i,i+1)							--	#(i)
					)
					else
						curSegmKnots = #(i,i+1)								--	#(i)
					append edgeLengthArr #(curSegmLength,(VertSelMiddleCenter curSegmKnots selSpline s 4))
				)
				overAll = "Total length: "+(units.formatValue totalLenght) as string
			)
		)
		StartDrawing()
	)
	
	function ShowInViewport =
	(
		if selection.count == 1 do
		(	
			if getCommandPanelTaskMode() != #modify do setCommandPanelTaskMode #modify
			local curObj = modPanel.getCurrentObject()
			if (classOf curObj) == Editable_Poly do
			(
				local selEdges = poGetEdgeSel curObj as array
				GetEdgesLengthEP selEdges
				StartDrawing()					
			)
			if (classOf curObj) == Edit_Poly do
			(
				local vertEdges = (selection[1].modifiers[#Edit_Poly].getSelection #Edge) as array
				GetEdgesLengthEPM (selection[1].modifiers[#Edit_Poly]) vertEdges
				StartDrawing()
			)
			if (classOf curObj) == Editable_Mesh do
			(
				local selEdges = for i in selection[1].selectedEdges collect i.index
				GetEdgesLengthEM selEdges	
				StartDrawing()
			)
			if (classOf curObj) == PolyMeshObject do
			(
				tmpMesh = snapshotAsMesh curObj
				local selEdges = for i in tmpMesh.selectedEdges collect i.index
				GetEdgesLengthEM selEdges	
				delete tmpMesh
				StartDrawing()
			)
			if (superClassOf curObj) == Shape do
			(
				if (classOf curObj) == SplineShape or (classOf curObj) == Line  then
				(
					selSpline = selection[1]
					GetSegmentLength selSpline					
				)
				else
				(
					with redraw off
					(
						local selSplineOrig = selection[1]						
						selSpline = copy selSplineOrig
						convertToSplineShape selSpline
						select selSpline						
						subobjectlevel = 2
						max select all							
						GetSegmentLength selSpline											
						delete selSpline
						select selSplineOrig
					)
					redrawViews()
				)
			)				
		)
	)
	
	function GetFaceArea =
	(		
		local curObj = selection[1]
		case (classOf curObj) of
		(
			Editable_Poly:
			(
				local selFaces = poGetFaceSel curObj
				local faceArea = 0
				edgeLengthArr = #()
				for f in selFaces do
				(
					fa = (poGetFaceArea curObj f)
					faceArea += fa
					append edgeLengthArr #((fa),(poGetFaceCenter curObj f))
				)
				overAll = "Total face area: "+(faceArea as string)
				if edgeLengthArr.count < 50 do StartDrawing()				
			)
			Editable_Mesh:
			(
				local selFaces = meshGetFaceSel curObj
				local faceArea = 0
				edgeLengthArr = #()
				for f in selFaces do
				(
					fa = (moGetFaceArea curObj f)
					faceArea += fa
					append edgeLengthArr #((fa),(moGetFaceCenter curObj f))
				)
				overAll = "Total face area: "+(faceArea as string)
				if edgeLengthArr.count < 50 do StartDrawing()
			)
			Edit_Poly:
			(
				local selFaces = (selection[1].modifiers[#Edit_Poly].getSelection #Face) as array
				local faceArea = 0
				edgeLengthArr = #()
				for f in selFaces do
				(
					fa = selection[1].modifiers[#Edit_Poly].getFaceArea f
					faceArea += fa
					append edgeLengthArr #((fa),(selection[1].modifiers[#Edit_Poly].getFaceCenter f))
				)
				overAll = "Total face area: "+(faceArea as string)
				if edgeLengthArr.count < 50 do StartDrawing()
			)
			PolyMeshObject:
			(
				tmpMesh = snapShotAsMesh curObj
				local selFaces = meshGetFaceSel tmpMesh
				local faceArea = 0
				edgeLengthArr = #()
				for f in selFaces do
				(
					fa = (moGetFaceArea tmpMesh f)
					faceArea += fa
					append edgeLengthArr #((fa),(moGetFaceCenter tmpMesh f))
				)
				delete tmpMesh
				overAll = "Total face area: "+(faceArea as string)
				if edgeLengthArr.count < 50 do StartDrawing()
			)
		)		
	)
	
	function GetObjDimension02 curObj getVertPos =
	(
		edgeLengthArr = #()
		local theMaxX = -2147483648
		local theMaxY = -2147483648
		local theMaxZ = -2147483648
		local theMinX = 2147483648
		local theMinY = 2147483648
		local theMinZ = 2147483648
		
		for v = 1 to curObj.numverts do
		(
			thePos = ( if (classOf curObj) == PolyMeshObject then (getVertPos v) else (getVertPos curObj v) )
			if thePos.x > theMaxX then theMaxX = thePos.x			
			if thePos.y > theMaxY then theMaxY = thePos.y		
			if thePos.z > theMaxZ then theMaxZ = thePos.z
			
			if thePos.x < theMinX then theMinX = thePos.x			
			if thePos.y < theMinY then theMinY = thePos.y		
			if thePos.z < theMinZ then theMinZ = thePos.z
		)
		
		theWidth = (theMaxX) - (theMinX)
		theLength = (theMaxY) - (theMinY)
		theHeight = (theMaxZ) - (theMinZ)
		
		backLeftTop = [theMinX, theMaxY, theMaxZ]
		backLeftBottom = [theMinX, theMaxY, theMinZ]
		frontLeftBottom = [theMinX, theMinY, theMinZ]				
		backRightBottom = [theMaxX, theMaxY, theMinZ]
		--	place text i the center of the lines
		frontLeftMiddle = [theMinX, (theMaxY+theMinY)/2, theMinZ]
		backLeftMiddle = [theMinX, theMaxY, (theMaxZ+theMinZ)/2]
		backRightMiddle = [(theMaxX+theMinX)/2, theMaxY, theMinZ]
		
		objLength = distance backLeftBottom frontLeftBottom
		objHeight = distance backLeftBottom backLeftTop
		objWidth = distance backLeftBottom backRightBottom
		
		lineArr = #(#(backLeftBottom,frontLeftBottom),#(backLeftBottom,backLeftTop),#(backLeftBottom,backRightBottom))
		edgeLengthArr = #(#(objLength,frontLeftMiddle),#(objHeight,backLeftMiddle),#(objWidth,backRightMiddle))
		overAll = "Object dimension"
		StartDrawing()
	)	
	function GetObjDimension01 =
	(
		local curObj = selection[1]
		case (classOf curObj) of
		(
			Editable_Poly: (GetObjDimension02 curObj poGetVert)
			Editable_Mesh: (GetObjDimension02 curObj moGetVert)
			Edit_Poly: (GetObjDimension02 curObj (selection[1].modifiers[#Edit_Poly].GetVertex))
			default:	--	for primitives
			(
				theMesh = snapshotasmesh curObj	
				GetObjDimension02 theMesh getVert				
				delete theMesh
			)
		)	
	)
	
	function StartMainFN =
	(
		if selection.count == 1 do
		(
			if getCommandPanelTaskMode() == #modify do
			(
				if subobjectlevel == 2 or subobjectlevel == 3 do
				(
					drawFaceArea = false
					ShowInViewport()
				)
				if subobjectlevel == 4 or subobjectlevel == 5 do
				(
					drawFaceArea = true
					GetFaceArea()
				)
				if subobjectlevel == 0 do
				(
					drawFaceArea = false
					GetObjDimension01()
				)
			)
			if getCommandPanelTaskMode() == #create do
			(
				drawFaceArea = false
				GetObjDimension01()
			)
		)
	)	
	
	on isChecked return ::drawInViewportEnabled
		
	on execute do
	(
		if ::drawInViewportEnabled != true and ::drawInViewportEnabled != false do ::drawInViewportEnabled = false
		::drawInViewportEnabled = not ::drawInViewportEnabled
		if ::drawInViewportEnabled then
		(
			unRegisterRedrawViewsCallback DrawTextOnViewports
			registerRedrawViewsCallback DrawTextOnViewports
			StartMainFN()
			forceCompleteRedraw()
			if selection.count == 1 do
			(
				if (classOf (modPanel.getCurrentObject())) == Edit_Poly then
				(
					when select (modPanel.getCurrentObject()) changes id:#SubObj_selectionChange do
					(
						StartMainFN()
					)
					when geometry (modPanel.getCurrentObject()) changes id:#FaceScaleChange do
					(
						if subobjectlevel == 4 or subobjectlevel == 5 do
						( 
							local selFaces = (selection[1].modifiers[#Edit_Poly].getSelection #Face) as array
							local faceArea = 0
							edgeLengthArr = #()
							for f in selFaces do
							(
								fa = selection[1].modifiers[#Edit_Poly].getFaceArea f
								faceArea += fa
								append edgeLengthArr #((fa),(selection[1].modifiers[#Edit_Poly].getFaceCenter f))
							)
							overAll = ("Total face area: "+(faceArea as string))
						)
						if subobjectlevel == 2 or subobjectlevel == 3 do
						(
							local vertEdges = (selection[1].modifiers[#Edit_Poly].getSelection #Edge) as array
							GetEdgesLengthEPM (selection[1].modifiers[#Edit_Poly]) vertEdges
						)
						if subobjectlevel == 1 do
						(
							selection[1].modifiers[#Edit_Poly].ConvertSelection #Vertex #Edge					
							local vertEdges = (selection[1].modifiers[#Edit_Poly].getSelection #Edge) as array
							GetEdgesLengthEPM (selection[1].modifiers[#Edit_Poly]) vertEdges					
						)
					)
				)
				else
				(
					when select selection[1] changes id:#SubObj_SelectionChange do
					(
						StartMainFN()
					)
					when geometry selection[1] changes id:#FaceScaleChange do
					(
						curObj = selection[1]
						if subobjectlevel == 4 or subobjectlevel == 5 do
						( 
							local curObj = selection[1]
							case (classOf curObj) of
							(
								Editable_Poly:
								(
									local selFaces = poGetFaceSel curObj
									local faceArea = 0
									edgeLengthArr = #()
									for f in selFaces do
									(
										fa = (poGetFaceArea curObj f)
										faceArea += fa
										append edgeLengthArr #((fa),(poGetFaceCenter curObj f))
									)
									overAll = ("Total face area: "+(faceArea as string))
								)
								Editable_Mesh:
								(
									local selFaces = meshGetFaceSel curObj
									local faceArea = 0
									edgeLengthArr = #()
									for f in selFaces do
									(
										fa = (moGetFaceArea curObj f)
										faceArea += fa
										append edgeLengthArr #((fa),(moGetFaceCenter curObj f))
									)
									overAll = ("Total face area: "+(faceArea as string))
								)
								PolyMeshObject:
								(
									tmpMesh = snapShotAsMesh curObj
									local selFaces = meshGetFaceSel tmpMesh
									local faceArea = 0
									edgeLengthArr = #()
									for f in selFaces do
									(
										fa = (moGetFaceArea tmpMesh f)
										faceArea += fa
										append edgeLengthArr #((fa),(moGetFaceCenter tmpMesh f))
									)
									delete tmpMesh
									overAll = ("Total face area: "+(faceArea as string))
								)
							)
						)
						if subobjectlevel == 2 or subobjectlevel == 3 do
						(
							local curObj = selection[1]
							case (classOf curObj) of
							(
								Editable_Poly:
								(
									local selEdges = poGetEdgeSel curObj as array
									GetEdgesLengthEP selEdges
								)
								Editable_Mesh:
								(
									local selEdges = for i in curObj.selectedEdges collect i.index
									GetEdgesLengthEM selEdges
								)
								PolyMeshObject:
								(
									tmpMesh = snapShotAsMesh curObj
									local selEdges = for i in tmpMesh.selectedEdges collect i.index
									GetEdgesLengthEM selEdges
									delete tmpMesh
								)
							)
						)
						if subobjectlevel == 1 do
						(
							case (classOf curObj) of
							(
								Editable_Poly:
								(
									local selVert = poGetVertSel curObj
									local vertEdges = poGetEdgesUVert curObj selVert as array
									GetEdgesLengthEP vertEdges
								)
		-- 						Editable_Mesh:	(--	not worked)						
							)
						)
					)
				)
				
				if classOf selection[1] == SplineShape or classOf selection[1] == Line do
				(
					when geometry selection[1] changes id:#SplineKnotMove do
					(
						if subobjectlevel == 1 do
						(
							local splineNum = numSplines selection[1]
							local totalLenght = 0
							edgeLengthArr = #()		
							if splineNum != 0 do
							(
								for s=1 to splineNum do
								(
									selKnot = getKnotSelection selection[1] s
									if selKnot.count == 1 then
									(
										local selSegm = undefined
										case selKnot[1] of
										(
											1: (selSegm = #(1))	--	the first knot is selected work with first segment
											(numKnots selection[1] s): (selSegm = #((numKnots selection[1] s)-1))	--	if the last knot is selected work with last segment
											default: (selSegm = #((selKnot[1]-1),selKnot[1]))	--	otherwise work with the previous and the next segments
										)							
										for i in selSegm do
										(
											local lengthArray = #()
											local segmentArray = #()
											local segmentArray = getSegLengths selection[1] s
											local segNum = numSegments selection[1] s
											
											for j = (segNum+1) to (segmentArray.count-1) do
											(
												append lengthArray segmentArray[j]
											)								
											curSegmLength = lengthArray[i]				
											totalLenght += curSegmLength
											local curSegmKnots = undefined
											if (isClosed selection[1] s) == true then
											(--	if spline is closed
												if i == segNum then--	text in the center	  / 	text in second knot of segment
													curSegmKnots = #(i,1)							--	#(1)
												else
													curSegmKnots = #(i,i+1)							--	#(i)
											)
											else
												curSegmKnots = #(i,i+1)								--	#(i)
											append edgeLengthArr #(curSegmLength,(VertSelMiddleCenter curSegmKnots selection[1] s 4))							
										)
										overAll = "Total length: "+(units.formatValue totalLenght) as string
									)
									else
									(
										messagebox "Only one vertex must be selected" title:"miauu Script Error!!!"
									)
								)
							)
							StartDrawing()
						)
						if subobjectlevel == 2 do
						(
							GetSegmentLength selection[1]
						)
					)
				)
				try(destroyDialog rol_TextColor)catch()
				rollout rol_TextColor ""
				(
					ImgTag it_green bitmap:(bitmap 2 2 color:green) pos:[0,0]  width:10 height:10
					ImgTag it_red bitmap:(bitmap 2 2 color:red) pos:[10,0]  width:10 height:10
					ImgTag it_blue bitmap:(bitmap 2 2 color:blue) pos:[20,0]  width:10 height:10
					ImgTag it_yellow bitmap:(bitmap 2 2 color:yellow) pos:[30,0]  width:10 height:10
					on it_green lbuttondown do
					(
						textColor = green
						PaintArrows green
						StartDrawing()
					)
					on it_red lbuttondown do
					(
						textColor = red
						PaintArrows red
						StartDrawing()
					)
					on it_blue lbuttondown do
					(
						textColor = blue
						PaintArrows blue
						StartDrawing()
					)
					on it_yellow lbuttondown do
					(
						textColor = yellow
						PaintArrows yellow
						StartDrawing()
					)
				)
				createdialog rol_TextColor 40 10 8 215 style:#()
			)
		)
		else
		(
			destroyDialog rol_TextColor
			deleteAllChangeHandlers id:#SubObj_SelectionChange
			deleteAllChangeHandlers id:#SplineKnotMove
			deleteAllChangeHandlers id:#FaceScaleChange
			RemoveArrows()
			ClearViewports()
		)
		forceCompleteRedraw()
	)	
)