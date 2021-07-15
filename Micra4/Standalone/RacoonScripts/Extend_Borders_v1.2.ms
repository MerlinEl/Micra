

/* 
	Copyright (C) 2019 Martin Geupel (http://www.racoon-artworks.de) , All Rights Reserved
	Permission is hereby granted, free of charge, to any person obtaining a copy of this software (the "Software"), to use, 
	copy, and/or distribute the software, subject to the following conditions:

	- The above copyright notice and this permission notice shall be included in all copies of the Software.
	- You may not misrepresent the name of the Original Author or the name of the Software.
	- You can distribute the Software only free of charge, you may not sell and/or rent the Software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE 
	WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR 
	COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR 
	OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

	================== changelog ==================
	
	v1.2 - 2019/11/25
	- added compatibility for max 2020 (some random thing changed for some reason, hooray!)
	
	v1.1 - 2019/04/27
	- materialIDs are ported to new faces
	- fixed the updating issues in max 2017 and up
	- removed encryption, have fun reading but keep in mind that this spaghetti code is OLD (and awful)!
	
	v1.0 - 2014/05/31
	- initial release
*/


-- macroScript ExtendBorders
-- category: "RacoonScripts"
-- autoUndoEnabled:false
(	
	if theHold.Holding() then theHold.Accept "Pre Extrude Borders"
	theHold.Begin()
	try(
		version = 1.1
		global ExtendBordersDepthAmnt
		global ExtendBordersAngleAmnt
		global ExtendBordersInheritSM
		global ExtendBordersStraightenCrn
		global ExtendBordersRespectSelEnd
		try(destroyDialog ::ExtendBordersRoll)catch()
		ExtendBorders_iso_x = getinisetting "$plugcfg\\RacoonScripts.ini" "ExtendBorders" "pos_x" as integer
		ExtendBorders_iso_y = getinisetting "$plugcfg\\RacoonScripts.ini" "ExtendBorders" "pos_y" as integer
		if ExtendBorders_iso_x == 0 then ExtendBorders_iso_x = 500; ExtendBorders_iso_y = 300

		myObj = $
		bufferArray = #()  -- array where the temporary vertex information class instances will be stored
		if ExtendBordersDepthAmnt == undefined then ExtendBordersDepthAmnt = 5.0 -- default extrusion depth, in worldunits
		if ExtendBordersAngleAmnt == undefined then ExtendBordersAngleAmnt = 0.0
		if ExtendBordersInheritSM == undefined then ExtendBordersInheritSM = true
		if ExtendBordersStraightenCrn == undefined then ExtendBordersStraightenCrn = true
		if ExtendBordersRespectSelEnd == undefined then ExtendBordersRespectSelEnd = true
		edgeSel -- the selected edges, only borders
		selVerts -- the verts used by the selected edges
		origSel -- original edge selection
		newFacesSmGrp = #()
		createdFaces = #()
		undoStack = #()
		DEBUG_ON = false
		
		----------------------------------------------------------------------------
		-- debug
		-- the debug function is somehow broken and freezes max, you can use it if you don't use the spinners afterwards, just set it the way you want, close the tool, active debug, start the tool
		struct DEBUG (
			pos,
			len,
			dir,
			radius = 0.05,
			boxList = #(),
			count = 0,
			
			fn clearAll =(
				delete $DEBUG*
			),
			
			fn vec pos dir len clr:red =(
				count += 1
				if boxList[count] == undefined then(
					obj = (box lengthsegs:1 widthsegs:1 heightsegs:1 pos:pos width:radius length:radius height:len prefix:"DEBUG_" wirecolor:clr)
					obj.dir = dir
					append boxList obj
				)else(
					obj = boxList[count] 
					obj.pos = pos
					obj.dir = dir
					obj.height = len
				)
			),
			
			fn resetCounter =(
				count = 0
			)
		)
		
		if DEBUG_ON then(
			DBG = DEBUG()
			DBG.clearAll()
		)
		---------------------------------------------------------------------
		
		
		fn RotateVectorAroundVector vec1 vec2 a =(
			x = vec1.x; y = vec1.y; z = vec1.z
			u = vec2.x; v = vec2.y; w = vec2.z
			ux=u*x; uy=u*y; uz=u*z
			vx=v*x; vy=v*y; vz=v*z
			wx=w*x; wy=w*y; wz=w*z
			sa=sin a
			ca=cos a
			x=u*(ux+vy+wz)+(x*(v*v+w*w)-u*(vy+wz))*ca+(-wy+vz)*sa
			y=v*(ux+vy+wz)+(y*(u*u+w*w)-v*(ux+wz))*ca+(wx-uz)*sa
			z=w*(ux+vy+wz)+(z*(u*u+v*v)-w*(ux+vy))*ca+(-vx+uy)*sa
			normalize [x,y,z]
		)
		
		struct VertBufffer ( -- vertex information class
			newVertID,  -- the newly create vertex ID
			originVertID,  -- the vertex ID from which the new one was generated
			direction,  -- the extrusion vector
			origPos,  -- the new vertex' position (same as originVertID's position)
			facenormalAvg,  -- the average normal of adjacent faces
			facenormalAvgRespEnds, -- the face normal of the one polygon sharing the selected (end) edge
			straightenCornerEdges,  -- the 2 (or 1 if end) selected edges shared by the originVertID vertex
			
			fn extendVert depth angleDeg useSM respectEnds straightenCorners =(  -- moves the verts about the supplied distance (always from the origPos)
				rotationVec = normalize (cross direction (if respectEnds then facenormalAvgRespEnds else facenormalAvg)) -- the vector which is used to rotate the extrusion
				rotatedVector = normalize (RotateVectorAroundVector direction rotationVec angleDeg) -- the rotated direction for extrusions
				
				
				if straightenCornerEdges.count == 1 or not straightenCorners then(  -- if it's a selection end or straighten corners is deactivated do...
					polyop.setVert myObj newVertID (origPos + (rotatedVector*depth))  -- set the vertex to the new position
				)
				else(
					vertA = polyop.getVert myObj originVertID  -- get the position of the original vertex
					
					polyop.setVert myObj newVertID (origPos + (rotatedVector*depth)) -- FIXES UPDATING ISSUES IN MAX 2017+ , should not be necessary
					
					edgeDirections = #()  -- will hold the directions of the 1 or 2 adjacent selected edges
					reds = #()  -- holds the two vectors that are defining the new extrusion direction, activate DEBUG_ON to see how it works!
					
					for edg in straightenCornerEdges do(  -- for each adjacent selected edge
						vertB = polyop.getVert myObj (((polyop.getVertsUsingEdge myObj edg) - #{originVertID}) as array)[1]  -- get the other vertex position
						edgeDir = normalize (VertA - VertB) -- build a vector (always from originVertID to the other one defining selected edge)
						append edgeDirections edgeDir  
						
						tempFnorm= (normalize (cross direction edgeDir))  -- get the crossproduct (third orientation vector) from the orig. direction and the edgeDir
						sign = if (dot tempFnorm facenormalAvg) < 0 then 1 else -1  -- if the dotproduct of fnorm and facenormal (~ angle) is not negative then the fnorm is facing in the wrong direction
						correctedFaceNormal = normalize (cross (edgeDir*sign) direction) -- calculate the face normal and flip it if it's facing in the wrong direction
						--if DEBUG_ON then DBG.vec vertA correctedFaceNormal 6.0 clr:orange -- DEBUG FUNCTION	
						--if DEBUG_ON then DBG.vec vertA tempFnorm 6.0 clr:orange -- DEBUG FUNCTION	
						if DEBUG_ON then DBG.vec vertA direction 6.0 clr:yellow -- DEBUG FUNCTION	
							
-- 						if originVertID == 6 then(
-- 							print sign
-- 						)
						
						edgeNormal = (normalize (cross correctedFaceNormal edgeDir)) * sign  -- the corrected extrusion direction perpendicular to the facenormal and more importantly to the selected edge
-- 						if DEBUG_ON then DBG.vec vertA edgeDir 5.0 clr:green	
						if DEBUG_ON then DBG.vec vertA correctedFaceNormal 6.0 clr:orange -- DEBUG FUNCTION	
						
						rotatedVector = normalize (RotateVectorAroundVector edgeNormal (edgeDir*sign) angleDeg)  -- take the extrusion vector, and rotate it around the selected edge
						append reds rotatedVector  -- append this vector to reds
						if DEBUG_ON then DBG.vec vertA rotatedVector depth clr:red -- DEBUG FUNCTION
					)
					
					if edgeDirections[2] == undefined then(  -- if there's only one valid direction..
						polyop.setVert myObj newVertID (origPos + (rotatedVector*depth))  -- set the vertex's position
					)else(
						angleAlpha = 90.0 - (acos (dot reds[1] edgeDirections[2])) -- if not, take one of the reds and calculate the angle between it and the neighboring selected adjacent edge, subtract it from 90°
						-- this gives us the angle between the red and the straighten corner direction we need
						len = depth * sin angleAlpha / sin 90.0  -- we know the extrusion depth so, calculating the lengths and angles of an triangle we get: blue length (see debug)
						-- till now we haven't considered the other red vector
						redAtoRedBvec = (reds[2] * depth) - (reds[1] * depth) -- we calculate the vector from one red to the other red
						redAtoRedBlen = length redAtoRedBvec  -- and the length of this vecotor
						redAtoRedBvec = normalize redAtoRedBvec  -- now normalize it to a unit vector
						blueVec = normalize edgeDirections[1]  -- the blue vector has the direction of one of the selected edges (1 because we also used red 1)
						dotprod = (dot blueVec redAtoRedBvec) -- the dotproduct between the redAtoRedB vector and the blue vector, note: we are building a triangle between the reds and the blue vector
						angleBetw = acos dotprod -- the angle between blue and one red
						
						anglesharpness = abs (90 - angleBetw)  -- the following the 3 lines will fix the situation where the blue and the red angle are close to 90 degrees (= the straighten corner edge would be of infinite length)
						thrs = 10.0  -- if it is this far from 90° 
						if anglesharpness < thrs  then factor = pow (anglesharpness / thrs) 2 else factor = 1.0  -- this will return a factor between 1 and 0, will be 0 if it reaches 90°
						
						newLen = ((redAtoRedBlen/2) * sin 90 / sin (180 - 90 - angleBetw) ) * factor  -- the new length of the blue vector (== orange vector)
						-- length of red A to B by half is one length of the triangle, 180-90-angleBetw is the second angle, the third angle is 90°
						
-- 						if DEBUG_ON then DBG.vec (vertA + (reds[1] * depth)) (blueVec) len clr:blue
-- 						if DEBUG_ON then DBG.vec (vertA + (reds[1] * depth)) (redAtoRedBvec) redAtoRedBlen clr:yellow
-- 						if DEBUG_ON then DBG.vec (vertA + (reds[1] * depth)) (blueVec) newLen clr:orange
						
						if newLen as string == "-1.#IND" or newLen as string == "1.#INF" or newLen as string == "-nan(ind).0" then(  -- if the two red angles are overlapping it will give #INF values, in these cases just return 1 red * extrusion depth
							polyop.setVert myObj newVertID (vertA + (reds[1] * depth))
						)else(
							polyop.setVert myObj newVertID ( (vertA + (reds[1] * depth)) + (blueVec * newLen) )  -- if not, the new vert position is the originalVert positon + (one red * extrusion depth) + (blue vec * corrected length)
							
						)
					)
					
				)
			)
		)
		
		fn SetSmGrp useSM =(  -- sets smoothing group id (and material ID) to either adjacent grp or none
			try(
				for dataSet in newFacesSmGrp do(
					if useSM then(
						polyop.setFaceSmoothGroup myObj dataSet[1] dataSet[2]
					)else(
						polyop.setFaceSmoothGroup myObj dataSet[1] 0
					)
					polyop.setFaceMatID myObj dataSet[1] dataSet[3] -- also set materialID, shouldn't be in this function but who cares at this point :)
				)
			)catch()
		)
		
		fn CalcDirection vert edgeArray =(  -- helper function to calculate the direction taken from 1 or more edges
			vectors = #()  
			
			for edg in edgeArray do(  -- for each considered edge...
				dirVerts = (polyop.getVertsUsingEdge myObj edg) as array -- get both vertices that are shared by the edge
				partner = if dirVerts[1] == vert then dirVerts[2] else dirVerts[1] -- if the first found vertex is the original vertex use this one, else it must be the other (to get the right order, thus the right vector direction)
				append vectors (normalize (direction = (polyop.getVert myObj vert) - (polyop.getVert myObj partner))) -- calculate the new direction vector from both vertices' positions and append it to the vectors list
			)
			
			if vectors.count > 1 then(  -- if there are more than 1 vectors in the list
				direction = vectors[1]  
				for vec = 2 to vectors.count do(  -- add all other vectors to the first one (== averaging)
					direction += vectors[vec]
				)
				normalize direction  -- than normalize the result and return it
			)
			else(  -- if not, just return the vector
				vectors[1]
			)
		)
		
		fn getAdjFaceNormal vert respectEnds =(  -- returns the average face normal of all adjacent faces
			if respectEnds then(
				faces = polyop.getFacesUsingEdge myObj ((polyop.getEdgesUsingVert myObj vert) * edgeSel)
			)
			else(
				faces = polyop.getFacesUsingVert myObj vert
			)
			dir = [0,0,0]
			for fID in faces do( dir += polyop.getFaceNormal myObj fID)
			(normalize dir)
			
		)
		
		fn getExtendDirection vert =(  -- returns the direction in which the new vertex will be moved later)
			foundEdges = (polyop.getEdgesUsingVert myObj vert) as array  -- return all edges that are shared by the supplied vertex (is an original vertex)
			nonSelected = (for edg in foundEdges where finditem edgeSel edg == 0 collect edg) -- collects all adjacent edges that are not selected
			nonBorders = (for edg in foundEdges where ((polyop.getFacesUsingEdge myObj edg) as array).count > 1 collect edg) -- collects all adjacent edges that aren't borders (1 edge shares 2 faces)
			
			if foundEdges.count == 2 then( -- if there are only 2 edges shared by the vertex (example: a corner vertex of a plane primitve)
				if nonSelected.count == 1 then(  -- if only 1 of these both edges is selected...
					CalcDirection vert nonSelected  -- return the other edge as direction
				)else(
					CalcDirection vert foundEdges -- of both are selected, return the average of both edge directions
				)
			)else( -- all other edges, count > 2
				if nonSelected.count == 1 and nonBorders.count == 1 then( -- the default case: 2 border edges and one (or more) edge(s) perpendicular to the 2 border edges
					CalcDirection vert nonSelected 
				)else( -- if the edge is one end of a selected loop (== not the whole border is selected), means 1 of the bordering edges is selected, the other is not + an arbitrary number of other edges that are not borders
					CalcDirection vert (for edg in foundEdges where ((polyop.getFacesUsingEdge myObj edg) as array).count > 1  collect edg) -- collect and use all adjacent edges that aren't borders 
				)
			)
		)
		
		fn initExtrusion=(  -- first function called in the script, everything starts here
			newEdgeSelection = #()
			origEdgeSel = edgeSel
			createdFaces = #()
			
			for vert in selVerts do(  -- for each vertex in the vertices (collected from selected edges) ...
				newVertID = polyop.createVert myObj (polyop.getVert myObj vert)  -- a new vertex is created at the position of the original
				definingSelectedEdges = (polyop.getEdgesUsingVert myObj vert) * edgeSel
				newBuffer = VertBufffer newVertID vert (getExtendDirection vert) (polyop.getVert myObj vert) (getAdjFaceNormal vert false) (getAdjFaceNormal vert true)  definingSelectedEdges -- a new class instance of the vertex data holder is created (getExtendDirection function is called for the vertex!)
				append bufferArray newBuffer  -- class instance is appended to a list
			)
			
			for edg in edgeSel do(  -- for each selected edge...
				originVerts = (polyop.getVertsUsingEdge myObj edg) as array  -- collect the 2 vertices that are used by the edge
				vertList = #() 
				
				for item in bufferArray where item.originVertID == originVerts[1] do append vertList item.newVertID -- search for the vertex data class instance that holds the first of the 2 original vertices (is always just 1), then append the created vertex ID to the list
				append vertList originVerts[1] -- append the searching original vertex ID
				append vertList originVerts[2] -- append the other searching original vertex ID
				for item in bufferArray where item.originVertID == originVerts[2] do append vertList item.newVertID -- search for the vertex data class instance that holds the second of the 2 original vertices, then append the created vertex ID to the list
				
				adjacentFace = (polyop.getFacesUsingEdge myObj edg) as array -- get the adjacent face of the edge
				newFaceID = polyop.createPolygon myObj vertList -- create a new polygon connected all the vertices, order is important (example: left-up, left-down, right-down, right-up)
				append createdFaces newFaceID
				newSmoothingGrp = (polyop.getFaceSmoothGroup myobj adjacentFace[1]) -- get the adjacent face smoothing group
				newMtlId = (polyop.getFaceMatID myobj adjacentFace[1]) -- get the adjacent face smoothing group
				append newFacesSmGrp [newFaceID, newSmoothingGrp, newMtlId] -- append an point2 with the newly created face id and the calc. smoothing group to the array
				faceEdges = polyop.getFaceEdges myObj newFaceID  -- get all edges that define the new polygon
				for fEdg in faceEdges do(  -- for each edge...
					vertPair = sort ((polyop.getVertsUsingEdge myObj fEdg) as array)  -- .. get the current edge's vertex pair
					vertPairNew= sort (#(vertList[1], vertList[4]))  -- ... get the pair of newly created vertices 
					if vertPair[1] == vertPairNew[1] AND vertPair[2] == vertPairNew[2] then append newEdgeSelection fEdg  -- of both pairs are equal we've found the new border edge
				)
			)
			polyop.setEdgeSelection myObj newEdgeSelection  -- set the edge selection to the new border edge
			
			append undoStack #(createdFaces, origEdgeSel)
		)
		
		rollout aboutRoll "About" width:180 (
			label lblvers ""
			label lblinfo "Written by Martin Geupel"
			hyperlink lnk "www.racoon-artworks.de" address:"http://www.racoon-artworks.de" color:(color 100 160 250) align:#center
			
			on aboutRoll open do lblvers.text = "version " + version as string
		)
		
		rollout ExtendBordersRoll "Extend Borders" width:260
		(
			label lblExtend "Extension Depth:" width:100 align:#left pos:[8,8]
			spinner spnExtend "" width:70 align:#left pos:[14,28] range:[-1000000,1000000,ExtendBordersDepthAmnt] type:#worldunits across:2
			label lblAngle "Angle:" width:100 align:#right pos:[108,8]
			spinner spnAngle "" width:56 align:#right pos:[108,28] range:[-180.0,180.0,ExtendBordersAngleAmnt] type:#float
			label lblSmGrp "Smoothing:" width:100 align:#right pos:[178,8]
			checkbox chkInheritSM "Inherit" align:#center checked:ExtendBordersInheritSM pos:[180,28]
			
			checkbox chkStraightenCrn "Straighten corners" align:#center checked:ExtendBordersStraightenCrn across:2 --pos:[20,48]
			checkbox chkRespEnds "Respect loop ends" align:#center checked:ExtendBordersRespectSelEnd  --pos:[20,48] 
			
			button btnApply "Apply" across:3 width:70 align:#center offset:[0,6] height:24
			button btnOK "OK" width:70 align:#center offset:[0,6] height:24
			button btnCancel "Cancel" width:70 offset:[0,6] height:24
			
			button btnabout "?" pos:[244,0] width:18 height:18
			
			fn updateExtr =(
				if DEBUG_ON then DBG.resetCounter()
				try(
					for item in bufferArray do(
						item.extendVert spnExtend.value spnAngle.value chkInheritSM.checked chkRespEnds.checked chkStraightenCrn.checked -- positions are set for all vertices at default extrusion amount
					)
				)catch()
			)
			
			on btnApply pressed do(
				bufferArray = #()  
				newFacesSmGrp = #()
				origSel = polyop.getEdgeSelection myObj -- the selected edges
				edgeSel = copy origSel -- the selected edges
				edgeSel = edgeSel - ((for edg in edgeSel where ((polyop.getFacesUsingEdge myObj edg) as array).count > 1 collect edg) as bitarray)
				selVerts = polyop.getVertsUsingEdge myObj edgeSel  -- the verts used by the selected edges
				
				initExtrusion()  
				SetSmGrp chkInheritSM.checked
				if keyboard.altpressed then(
					spnAngle.value = - spnAngle.value
				)
-- 				if keyboard.controlPressed then(
-- 					spnAngle.value = spnAngle.value * 1.2
-- 				)
				updateExtr()
			)
			
			on btnOK pressed do(
				destroyDialog ExtendBordersRoll
			)
			
			on btnCancel pressed do(  -- if the operation is cancelled 
				if keyboard.altpressed then(
					try(
						for i = 1 to 2 do(
							if undoStack.count > 0 then(
								polyop.deleteFaces myObj (undoStack[undoStack.count][1])
								polyop.setEdgeSelection myObj (undoStack[undoStack.count][2])
								deleteItem undoStack undoStack.count
							)
						)
						bufferArray = #()  
						newFacesSmGrp = #()
						origSel = polyop.getEdgeSelection myObj -- the selected edges
						edgeSel = copy origSel -- the selected edges
						edgeSel = edgeSel - ((for edg in edgeSel where ((polyop.getFacesUsingEdge myObj edg) as array).count > 1 collect edg) as bitarray)
						selVerts = polyop.getVertsUsingEdge myObj edgeSel  -- the verts used by the selected edges
						
						initExtrusion() 
						SetSmGrp chkInheritSM.checked
						updateExtr()
						redrawViews()
					)catch()
				)
				else(
					cnt = undostack.count 
					for i =1 to cnt do(
						try(
							polyop.deleteFaces myObj (undoStack[undoStack.count][1])
							polyop.setEdgeSelection myObj (undoStack[undoStack.count][2])
							deleteItem undoStack undoStack.count
						)catch()
					)
					redrawViews()
					destroyDialog ExtendBordersRoll 
				)
			)
			
			on ExtendBordersRoll open do(
				initExtrusion()  -- everything starts here, first thing done in the script
				SetSmGrp chkInheritSM.checked
				updateExtr()
			)
			
			on spnExtend changed val do(  -- if the spinner is changed...
				updateExtr()
			)
			
			on spnAngle changed val do(  -- if the spinner is changed...
				updateExtr()
			)
			
			on chkInheritSM changed state do(
				SetSmGrp state
			)
			
			on chkRespEnds changed state do(
				updateExtr()
			)
			
			on chkStraightenCrn changed state do(
				updateExtr()
			)
			
			on btnAbout pressed do( try(destroyDialog aboutroll)catch(); createDialog aboutRoll)
			
			on ExtendBordersRoll close do(
				if theHold.Holding() then theHold.Accept "Extrude Borders"
				setinisetting "$plugcfg\\RacoonScripts.ini" "ExtendBorders" "pos_x" ((GetDialogPos ExtendBordersRoll).x  as string)
				setinisetting "$plugcfg\\RacoonScripts.ini" "ExtendBorders" "pos_y" ((GetDialogPos ExtendBordersRoll).y  as string)
				ExtendBordersDepthAmnt = spnExtend.value
				ExtendBordersAngleAmnt = spnAngle.value
				ExtendBordersInheritSM = chkInheritSM.checked
				ExtendBordersStraightenCrn = chkStraightenCrn.checked
				ExtendBordersRespectSelEnd = chkRespEnds.checked
			)
		) -- rollout end
		
		
		if selection.count == 1 and classof myObj == Editable_Poly then(
			origSel = polyop.getEdgeSelection myObj -- the selected edges
			edgeSel = copy origSel -- the selected edges
			edgeSel = edgeSel - ((for edg in edgeSel where ((polyop.getFacesUsingEdge myObj edg) as array).count > 1 collect edg) as bitarray)
			selVerts = polyop.getVertsUsingEdge myObj edgeSel  -- the verts used by the selected edges
			if (edgeSel as array).count != 0 then(	-- if selected edges are not ALL borders, don't do anything!
				if ExtendBorders_iso_x == 0 then createDialog ExtendBordersRoll else createDialog ExtendBordersRoll pos:[ExtendBorders_iso_x, ExtendBorders_iso_y]
			)
		)else(
			if theHold.Holding() then theHold.Accept "Extrude Borders"
			messagebox "Please select exactly 1 object, which must be an editable poly with at least one edge selected!" title:"Extend Borders"
		)
	)
	catch(print (getCurrentException()) ; if theHold.Holding() then theHold.Accept "Extrude Borders")
	
	
) -- macro end



