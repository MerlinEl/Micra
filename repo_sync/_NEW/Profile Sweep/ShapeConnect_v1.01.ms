


	/************************************************************
	
	Copyright (C) 2018 Martin Geupel (http://www.racoon-artworks.de) , All Rights Reserved
	Permission is hereby granted, free of charge, to any person obtaining a copy of this software (the "Software"), to use, 
	copy, and/or distribute the software, subject to the following conditions:

	- The above copyright notice and this permission notice shall be included in all copies of the Software.
	- You may not misrepresent the name of the Original Author or the name of the Software.
	- You can distribute the Software only free of charge, you may not sell and/or rent the Software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE 
	WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR 
	COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR 
	OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
	
	A huge thanks goes to Vojtech Cada (aka Swordslayer) who has helped me a lot with solving problems and general speed
	improvements in this script.
	
	************************************************************/
	
	
	
	/* TODO 
	Improvements:
	* Closed loop smoothing problems
	* Make sure there is no smoothing ids overflow
	* warning for high shape segment count
	
	- loops: remove variables
	- try scope optim. again: getVertsUsingEdge = polyop.getVertsUsingEdge
	*/
	
	
macroScript ShapeConnect
category: "RacoonScripts"
(	
	global RacoonScriptsShapeConnectRollout
	local shapeConnect_iso_x = getinisetting "$plugcfg\\RacoonScripts.ini" "ShapeConnect" "pos_x" as integer
	local shapeConnect_iso_y = getinisetting "$plugcfg\\RacoonScripts.ini" "ShapeConnect" "pos_y" as integer
	
	
	struct ShapeConnect (
		obj,
		selEdges,
		applyChanges = false,
		firstConnect = true,  -- indicates if it's the first shape connect since opening the dialog
		collectFullEdgeData = true,
		
		-- edge data
		enclosingEdges,
		isClosedRing,
 		sortedRing,
		adjVertsloopA,
		adjVertsloopB,
		enclosingEdgeloopVerts,
		minLength,
		edgeObjects,
		
		-- face data
		faceBuilderObj,
		originalFaces,
		adjacentSmoothingGrps,
		
		-- spline data
		splineObj,
		splineSegmDataSet,
		splineLength,
		splineTransfMatrix,
		
		-- new vertex/face data
		vertIdRows,
		
		-- settings
		version = "1.01",
		smthgAngleThreshold = 45.0,
		useMtlIds = true,
		useSmoothingGroups = true,
		breakSmoothingAtAngle = true,
		invertDirection = false,
		invertUpVector = false,
		weldThreshold = 0.001,
		straightenCorners = true,
		debug = false,
		
		
		-- returns the loops left and right from an edge ring
		fn findEnclosingEdges =(
			local faces = polyop.getFacesUsingEdge this.obj this.selEdges
			
			local filteredFaces = copy faces
			for face in faces do ( if (((polyop.getFaceEdges this.obj face) as bitarray) * this.selEdges).numberSet < 2 do(
				filteredFaces[face] = false 
			))
			local newEdges = polyop.getEdgesUsingFace this.obj filteredFaces
			this.originalFaces = filteredFaces
			(newEdges - this.selEdges)
		),
		
		-- Sorts the edges and builds two arrays of the adjacents edge-loops vertices left and right of the edge ring selection
		fn sortRingSelAndSplitAdjLoops =( -- PRAISE Vojta!
			
			fn addSortedPoints obj prevEdge edges prevFace faces useInsert:false =( -- obj, function, start edge, all edges, 1 adj face, all faces
				while prevFace != undefined AND prevEdge != undefined do ( -- as long as there is a face AND an edge..
					faces[prevFace] = false  -- remove the current face from the search pool
					edges[prevEdge] = false  -- remove the current edge from the search pool
					local edgeFaces = polyop.getEdgeFaces obj prevEdge -- get both edges, left and right from the edge
					local index = findItem edgeFaces prevFace  -- find the current face in the array and store the index of it
					
					local verts = (polyop.getEdgeVerts obj prevEdge) -- get the 2 vertices of the current edge and use the prev. face index to determine which array should hold which vertex
					if useInsert then( 
						insertItem verts[3 - index] adjVertsloopA 1
						insertItem verts[index] adjVertsloopB 1
						insertItem prevEdge sortedRing 1
					)else( 
						append adjVertsloopA verts[index]
						append adjVertsloopB verts[3 - index]
						append sortedRing prevEdge
					)
					
					prevFace = edgeFaces[3 - index] -- set the next face ( == of both adj. faces NOT the current face)
					if isKindOf prevFace Number do  -- if prevFace is NOT undefined
					(
						prevEdge = ((edges * (polyop.getFaceEdges obj prevFace as bitarray)) as array)[1]  -- the new start edge is the opposite face side edge 
						if NOT faces[prevFace] do prevFace = undefined -- if the (next) prevFace is NOT in the search pool, set it undefined and thus quit
					)
				)
			)
			
			this.sortedRing = #()
			this.adjVertsloopA = #()
			this.adjVertsloopB = #()
			
			local edges = copy selEdges
			local faces = polyop.getFacesUsingEdge obj edges -- get all faces used by selected edges
			local startEdge = (edges as array)[1]  -- choose any edge as starting point
			local faceLeft = (polyop.getEdgeFaces obj startEdge)[1]  -- there's two faces per edge, left and right
			local faceRight = (polyop.getEdgeFaces obj startEdge)[2]
			
			local count = 1
			while (faceLeft == undefined OR faceRight == undefined) and count < edges.numberSet do( -- if any of these 2 are undefined then it's a border edge, we need an edge with 2 neighbouring edges
				count += 1
				startEdge = (edges as array)[count] -- and we use a different edge
				faceLeft = (polyop.getEdgeFaces obj startEdge)[1]
				faceRight = (polyop.getEdgeFaces obj startEdge)[2]
			)
			
			addSortedPoints obj startEdge edges faceRight faces useInsert:false -- loop through the right sides faces
			deleteItem adjVertsloopA 1  -- delete the first enties (will be added again below though insertion) 
			deleteItem adjVertsloopB 1
			deleteItem sortedRing 1
			addSortedPoints obj startEdge edges faceLeft (faces + #{faceRight}) useInsert:true  -- then loop through the left sides faces
			
			#(adjVertsloopA as bitarray, adjVertsloopB as bitarray)
		),
		
		fn isRingSelectionClosed =(
			-- if faces and edge count are equal it must be a closed ring
			if originalFaces.numberSet == this.selEdges.numberSet then(
				this.isClosedRing = true
			)else(this.isClosedRing = false)
		),
		
		fn filterFacesForDeletion =(
			-- if the sortedList edge count is lower than the selected edges count we know that more than one continuous edge ring is 
			-- selected. We filter the faces again for just the sorted edge ring
			if sortedRing.count != this.selEdges.numberSet do (
				local sortedEdges = (sortedRing as bitarray)
				local faces = polyop.getFacesUsingEdge this.obj sortedEdges
				
				local filteredFaces = copy faces
				for face in faces do ( if (((polyop.getFaceEdges this.obj face) as bitarray) * sortedEdges).numberSet < 2 do(
					filteredFaces[face] = false 
				))
				this.originalFaces = filteredFaces
			)
		),
		
		-- returns array of:   StartVertexPos, EndVertexPos, SegmentType, SegmentSmoothingGroup, MaterialID
		fn collectSplineDataPerSegment obj =(
			local numSegs = numSegments obj 1
			local knotCount = numKnots obj
			local segments = #()
			
			with redraw off(
				try(
					disableRefMsgs()
					local smoothingID = 1
					
					for segID = 1 to numSegs do(
						local sp = splineShape render_renderable:false render_displayRenderMesh:false \
						optimize:obj.optimize adaptive:obj.adaptive steps:obj.steps -- generates a new spline per segment
						addnewSpline sp
						
						local segType = getSegmentType obj 1 segID
						local mtlID = getMaterialID obj 1 segID
						
						local knTypeA = getKnotType obj 1 segID
						local knPosA = getKnotPoint obj 1 segID
						local kInvVecA = getInVec obj 1 segID
						local kOutVecA = getOutVec obj 1 segID
						
						local knTypeB = getKnotType obj 1 (segID + 1)
						local knPosB = getKnotPoint obj 1 (segID + 1)
						local kInvVecB = getInVec obj 1 (segID + 1)
						local kOutVecB = getOutVec obj 1 (segID + 1)
						
						addknot sp 1 knTypeA segType knPosA kInvVecA kOutVecA  -- segment defining knots
						addknot sp 1 knTypeB segType knPosB kInvVecB kOutVecB
						
						updateShape sp
						local em = editable_mesh()  
						attach em sp -- "convert" spline to mesh without modify panel fuckup
						local numVerts = getNumVerts em
						local vPos = #()
						
						for vID = 1 to numVerts do append vPos (getVert em vID) -- collect interpolated vertices
						delete em
						
						-- StartVertex, EndVertex, SegmentType, SegmentSmoothingGroup, MaterialID
						for vert = 1 to vpos.count - 1 do(
							if segID == 1 and vert == 1 then () else(
								if (knTypeA == #corner OR knTypeA == #bezierCorner) and vert == 1 do(
									if smoothingID == 1 then smoothingID += 1 else smoothingID -= 1
								)
							)
							append segments #(vpos[vert], vpos[vert+1], segType, smoothingID, mtlID)
						)
					)
					enableRefMsgs()
				)catch(enableRefMsgs(); format "*** % ***\n" (getCurrentException()))
			)
			
			segments
		),
		
		-- contains data for each selected edge of the ring
		edgeDataContainer =(
			struct edgeDataContainer (
				obj,
				edgeID,
				owner,
				edgeVertIDs,
				origin,
				end,
				direction,
				totalLength,
				adjFaceIDs,
				normal,
				coordsysMtrx,
				
				fn buildDataSet invertDirection:false =(
					edgeVertIDs = polyop.getEdgeVerts obj edgeID -- edge defining vertices
					local vertA = if invertDirection then edgeVertIDs[2] else edgeVertIDs[1]
					local vertB = if invertDirection then edgeVertIDs[1] else edgeVertIDs[2]
					local enclosingVertLoop = if invertDirection then owner.enclosingEdgeloopVerts[2] else owner.enclosingEdgeloopVerts[1]
					
					if enclosingVertLoop[vertA] then ( -- if vertA is part of the enclosing loop
						origin = polyop.getVert obj (vertA) 
						end = polyop.getVert obj (vertB)
						direction = end - origin
						edgeVertIDs = #(vertA, vertB)
					)else(
						origin = polyop.getVert obj (vertB) 
						end = polyop.getVert obj (vertA)
						direction = end - origin 
						edgeVertIDs = #(vertB, vertA)
					)
					totalLength = length direction
					direction = normalize direction 
					adjFaceIDs = polyop.getFacesUsingEdge obj edgeID as array
					
					normal = if adjFaceIDs.count > 1 then( -- if the edge is shared by two faces
						normalize (((polyop.getFaceNormal obj adjFaceIDs[1]) + (polyop.getFaceNormal obj adjFaceIDs[2]))*0.5) -- average normals
					)else( -- edge is also a border; only 1 face
						polyop.getFaceNormal obj (adjFaceIDs[1])
					)
					local yDir = - cross direction normal
					normal = - cross yDir direction -- make sure the up normal is always perpendicular to the edge
					
					--format "origin: %   end: %   dir: %\n" origin end direction
					coordsysMtrx = matrix3 direction yDir normal origin
					--print coordsysMtrx
					true
				)
			)
		),
		
		
		-- data collection
		fn getAdjacentSmoothingGroups =(
			if this.debug then local start = timeStamp()
			fn getSmoothingIntegerAsBitarray smInt =(
				local sgroup_val = smInt
				local sg_bitarray=#{}
				if sgroup_val < 0 do(
					sg_bitarray[32]=true
					sgroup_val -= 2^31
				)
				for i = 1 to 31 do(
					sg_bitarray[i]= (mod sgroup_val 2 > .5)
					sgroup_val /= 2
				)
				sg_bitarray	
			)
			
			local adjFaces = (polyop.getFacesUsingEdge this.obj enclosingEdges) - originalFaces
			this.adjacentSmoothingGrps = #{}
			for face in adjFaces do(
				join this.adjacentSmoothingGrps (getSmoothingIntegerAsBitarray (polyop.getFaceSmoothGroup obj face))
			)
			if this.debug then( local end = timeStamp(); format "collect adj. SmthgGrps: % s\n" ((end - start) / 1000.0) )
			true
		),
		
		fn collectEdgeDataSet =(
			if this.debug then local start = timeStamp()
			this.enclosingEdges = findEnclosingEdges()
			if this.debug then( local end = timeStamp(); format "enclosingEdges: % s\n" ((end - start) / 1000.0) )
			
			if this.debug then local start = timeStamp()
			getAdjacentSmoothingGroups()
			if this.debug then( local end = timeStamp(); format "collect smoothingGrps: % s\n" ((end - start) / 1000.0) )
			
			if this.debug then local start = timeStamp()
			if ((polyop.getOpenEdges this.obj) * selEdges).numberSet == this.selEdges.numberSet AND this.selEdges.numberSet == 2 then( -- extra rule for 2-edge selections where both edges are borders (like a 1 poly plane)
				this.sortedRing = this.selEdges as array -- since it's only 2 edges, order doesn't matter
				local enclEdgesArr = this.enclosingEdges as array
				this.enclosingEdgeloopVerts = #((polyop.getEdgeVerts this.obj enclEdgesArr[1]) as bitarray, (polyop.getEdgeVerts this.obj enclEdgesArr[2]) as bitarray)
			)else(  -- otherwise just do the usual sorting and splitting
				this.enclosingEdgeloopVerts = sortRingSelAndSplitAdjLoops()
			)
			if this.debug then( local end = timeStamp(); format "ring sort/loop split: % s\n" ((end - start) / 1000.0) )
			
			if this.debug then local start = timeStamp()
			isRingSelectionClosed()
			filterFacesForDeletion()
			if this.sortedRing == undefined do return false
			if this.debug then( local end = timeStamp(); format "filtering faces: % s\n" ((end - start) / 1000.0) )
			
			true
		),
		
		fn assembleEdgeDataContainers =(
			this.edgeObjects = #()
			local lengths = #()
			for edg in this.sortedRing do(
				tempObj = edgeDataContainer obj edg this
				tempObj.buildDataSet invertDirection:this.invertDirection
				append lengths tempObj.totalLength
				append this.edgeObjects tempObj
			)
			this.minLength = amin lengths
			true
		),
		
		fn collectSplineData =(
			if this.debug then local start = timeStamp()
			splineSegmDataSet = collectSplineDataPerSegment splineObj
			
			local vertStartPos = getKnotPoint splineObj 1 1
			local vertEndPos = getKnotPoint splineObj 1 (numKnots splineObj)
			splineLength = length (vertEndPos - vertStartPos)
			local dirX = normalize (vertEndPos - vertStartPos)
			local dirY = - splineObj.transform.row3
			local dirZ = cross dirX dirY
			local dirY = cross dirZ dirX
			
			if this.debug then( local end = timeStamp(); format "build spline data: % s\n" ((end - start) / 1000.0) )
			splineTransfMatrix = matrix3 dirX dirY dirZ vertStartPos
		),
		
		
		-- mesh manipulation
		fn createVertices =( -- create and collect vertexIDs
			
			fn calcNormalAngleFixMult edg vecPrev vecNext =( 
				local tempNormal = normalize -(cross edg.direction vecPrev)
				local vecPrevCorrected = normalize (cross edg.direction tempNormal) 
				tempNormal = normalize -(cross edg.direction vecNext)
				local vecNextCorrected = normalize (cross edg.direction tempNormal)
				(1 + 1 / (tan (acos (amax (dot vecPrevCorrected vecNextCorrected) -1) / 2))^2)^0.5
			)
			
			if this.debug then local start = timeStamp()
			local scaleFactor = minLength / splineLength -- global scalefactor for spline (based on the shortest one)
			faceBuilderObj = Editable_Mesh()
			
			local obj = faceBuilderObj
			local totVertCount = edgeObjects.count * (splineSegmDataSet.count + 1)
			local cnt = 0
			local invertUpDirection = if this.invertUpVector then -1.0 else 1.0
			setNumVerts faceBuilderObj totVertCount false
			
			vertIdRows = #()
			for edgID = 1 to edgeObjects.count do(
				local edg = edgeObjects[edgID]
				cnt += 1
				setVert faceBuilderObj cnt edg.origin
	 			vertRow = #(cnt) -- create origin vertex dublicate
				
				local NormalAngleFixMultiplier = 1.0 -- we want to correct the extrusion depth based on the angle between rings (like straighten corners in Shell mod)
				if this.straightenCorners then(
					if edgID == 1 or edgID == edgeObjects.count then(
						NormalAngleFixMultiplier = 1.0 -- if the edge is a border edge
						if edgID == 1 and this.isClosedRing then( -- first edge of a closed ring
							local vecPrev = normalize (this.edgeObjects[edgeObjects.count].origin - edg.origin) 
							local vecNext = normalize (this.edgeObjects[2].origin - edg.origin)
							NormalAngleFixMultiplier = calcNormalAngleFixMult edg vecPrev vecNext
						)
						if edgID == edgeObjects.count and this.isClosedRing then( -- last edge of a closed ring
							local vecPrev = normalize (this.edgeObjects[edgID-1].origin - edg.origin) 
							local vecNext = normalize (this.edgeObjects[1].origin - edg.origin)
							NormalAngleFixMultiplier = calcNormalAngleFixMult edg vecPrev vecNext
						)
					)else( -- all edges between start and end
						local vecPrev = normalize (this.edgeObjects[edgID+1].origin - edg.origin) 
						local vecNext = normalize (this.edgeObjects[edgID-1].origin - edg.origin)
						NormalAngleFixMultiplier = calcNormalAngleFixMult edg vecPrev vecNext
					)
				)
				
				for i = 1 to splineSegmDataSet.count - 1 do(
					localScaleFactor = edg.totalLength / minLength -- adjusts the data for different edge lengths (based on the shortest one)
					lclPoint = splineSegmDataSet[i][2] * inverse splineTransfMatrix -- transforms the point into local coordsys / removes node transforms
					lclPoint = (scaleFactor * lclPoint) * [localScaleFactor, 1, NormalAngleFixMultiplier*invertUpDirection]
					
					transfPoint = lclPoint * edg.coordsysMtrx -- transform into the new editablepoly edge coordsys
					cnt += 1
					setVert faceBuilderObj cnt transfPoint
					append vertRow cnt
				)
				
				cnt += 1
				setVert faceBuilderObj cnt edg.end
	 			append vertRow cnt  -- create end vertex dublicate
				
				append vertIdRows vertRow
			)
			if this.debug then( local end = timeStamp(); format "create vertices: % s\n" ((end - start) / 1000.0) )
			true
		),
		
		fn createFacesComplexSmoothing =( -- well, creates the new faces
			if this.debug then local start = timeStamp()
			local obj = faceBuilderObj
			local angleBetweenRings = 0.0
			local lastSmoothingGroupFaceIds = #()
			local newFaceID = 0
			local useDefaultSet = true
			local changeSmoothingGroup = false
			
			-- TODO: check the number of smoothing groups to avoid overflow!!!
			local usedIds = copy this.adjacentSmoothingGrps
			local splineSmthIDs = for dSet in splineSegmDataSet collect dSet[4]
			
			local unusedIDs = (#{1..32} - adjacentSmoothingGrps) as array
			local defaultSmoothingGroups = for id in splineSmthIDs collect unusedIDs[id]
			usedIds = usedIds + defaultSmoothingGroups as bitarray
			unusedIDs = (#{1..32} - usedIds) as array
			local alternSmoothingGroups = for id in splineSmthIDs collect unusedIDs[id]
			usedIds = usedIds + alternSmoothingGroups as bitarray
			unusedIDs = (#{1..32} - usedIds) as array
			local fallbackSmoothingGroups = for id in splineSmthIDs collect unusedIDs[id]
			
			
			for rowNum = 1 to vertIdRows.count - 1 do( -- for each segment of the shape
				current = vertIdRows[rowNum]
				next = vertIdRows[rowNum + 1]
				
				if rowNum != 1 then( -- calculates the angle between the current ring edge and neighbouring ones
					local origPos = this.edgeObjects[rowNum].origin
					angleBetweenRings = 180.0 - acos (dot (normalize (this.edgeObjects[rowNum+1].origin - origPos)) (normalize (this.edgeObjects[rowNum-1].origin - origPos)) )
				)
				if angleBetweenRings >= this.smthgAngleThreshold then( -- if the angle is bigger than the threshold
					changeSmoothingGroup = true  -- we must change the smoothing group
					if changeSmoothingGroup then (
						useDefaultSet = not useDefaultSet  -- use the alternative set of smoothing groups
						lastSmoothingGroupFaceIds = #() -- reset the array of the the accumulated faceIDs from the last continuous smoothing group (presumably spanning several ring edges)
					)
				)else(changeSmoothingGroup = false)
				
				
				for vertNum = 1 to (current.count - 1) do(  -- for each segment between two vertices...
					meshop.createPolygon obj #(current[vertNum], current[vertNum + 1], next[vertNum + 1], next[vertNum]) -- first create the face itself
					newFaceID += 2  -- then add 2 to the facecount, since we are creating a quad that is made by 2 triangles/faces
					append lastSmoothingGroupFaceIds newFaceID
					
					if this.useMtlIds then(
						local splSegData = splineSegmDataSet[vertNum]  
						setFaceMatID obj (newFaceID-1) splSegData[5]
						setFaceMatID obj newFaceID splSegData[5]
					)else(
						setFaceMatID obj (newFaceID-1) 1
						setFaceMatID obj newFaceID 1
					)
					local calcSmoothingGrp = if useDefaultSet then 2^(defaultSmoothingGroups[vertNum]-1) else 2^(alternSmoothingGroups[vertNum]-1) -- use either the default or alternative smoothinggroup set
					setFaceSmoothGroup obj (newFaceID-1) calcSmoothingGrp 
					setFaceSmoothGroup obj newFaceID calcSmoothingGrp
					
				)
			)
			
			if this.isClosedRing do (
				local current = vertIdRows[vertIdRows.count]
				local next = vertIdRows[1]
				local useFallbackSmoothingGroup = false
				
				local origPos = this.edgeObjects[vertIdRows.count].origin
				angleBetweenRings = 180.0 - acos (dot (normalize (this.edgeObjects[1].origin - origPos)) (normalize (this.edgeObjects[vertIdRows.count-1].origin - origPos)) )
				
				
				if angleBetweenRings >= this.smthgAngleThreshold then(
					changeSmoothingGroup = true
					if changeSmoothingGroup then useDefaultSet = not useDefaultSet
					-- lastSmoothingGroupFaceIds = #() -- we do NOT want to reset the group here, we will add the new face IDs 
				)else(changeSmoothingGroup = false)
				
				
				for vertNum = 1 to (current.count - 1) do(  -- for each segment between two vertices...
					meshop.createPolygon obj #(current[vertNum], current[vertNum + 1], next[vertNum + 1], next[vertNum])
					newFaceID += 2
					append lastSmoothingGroupFaceIds newFaceID
					
					if this.useMtlIds then(
						local splSegData = splineSegmDataSet[vertNum] -- get the specific segment data from the spline data set array
						setFaceMatID obj (newFaceID-1) splSegData[5]
						setFaceMatID obj newFaceID splSegData[5]
					)else(
						setFaceMatID obj (newFaceID-1) 1
						setFaceMatID obj newFaceID 1
					)
					
					-- following three lines are for calculating the angle info where the ring closes (== first and last edge connect)
					local origPos = this.edgeObjects[1].origin
					local angleOfClosingRing = 180.0 - acos (dot (normalize (this.edgeObjects[2].origin - origPos)) (normalize (this.edgeObjects[vertIdRows.count].origin - origPos)) )
					local mustSplit = angleOfClosingRing >= this.smthgAngleThreshold
					
					local calcSmoothingGrp = if useDefaultSet then 2^(defaultSmoothingGroups[vertNum]-1) else 2^(alternSmoothingGroups[vertNum]-1)
					
					if useDefaultSet == false then ( -- if the last poly ring and the first poly ring have different smoothing groups..
						if mustSplit then(  -- if they must have separate smoothing...
							-- then we are done
						)else(
							calcSmoothingGrp += 2^(defaultSmoothingGroups[vertNum]-1) -- if not we must assign both smoothing groups
						)
					)else( -- if the last and first poly ring smthg groups are the same... 
						if mustSplit then(  -- if they must have separate smoothing...
							useFallbackSmoothingGroup = true -- we will reassign the smoothing group for all faces that are sharing the 
						)else(
							-- if not then we are done
						)
					)
					
					setFaceSmoothGroup obj (newFaceID-1) calcSmoothingGrp 
					setFaceSmoothGroup obj newFaceID calcSmoothingGrp
				)
				
				if useFallbackSmoothingGroup then(
					local cnt = 0
					for facePair in lastSmoothingGroupFaceIds do(
						cnt += 1
						local smoothingID = (mod cnt (current.count - 1)) as integer
						if smoothingID == 0 then smoothingID = current.count - 1
						
						local calcSmoothingGrp = 2^(fallbackSmoothingGroups[smoothingID]-1)
						setFaceSmoothGroup obj (facePair-1) calcSmoothingGrp
						setFaceSmoothGroup obj (facePair) calcSmoothingGrp
					)
				)
			)
			update obj
			if this.debug then( local end = timeStamp(); format "create faces: % s\n" ((end - start) / 1000.0) )
			true
		),
		
		fn createFacesSimple =( -- well, creates the new faces
			if this.debug then local start = timeStamp()
			local newFaceID = 0
			local obj = faceBuilderObj
			
			local usedIds = copy this.adjacentSmoothingGrps
			local splineSmthIDs = for dSet in splineSegmDataSet collect dSet[4]
			local unusedIDs = (#{1..32} - adjacentSmoothingGrps) as array
			local defaultSmoothingGroups = for id in splineSmthIDs collect unusedIDs[id]
			
			
			for rowNum = 1 to vertIdRows.count - 1 do(
				current = vertIdRows[rowNum]
				next = vertIdRows[rowNum + 1]
				
				for vertNum = 1 to (current.count - 1) do(  -- for each segment between two vertices...
					meshop.createPolygon obj #(current[vertNum], current[vertNum + 1], next[vertNum + 1], next[vertNum])
					newFaceID += 2
					
					if this.useMtlIds or this.useSmoothingGroups do local splSegData = splineSegmDataSet[vertNum]  -- get the specific segment data from the spline data set array
					if this.useMtlIds then(
						setFaceMatID obj (newFaceID-1) splSegData[5]
						setFaceMatID obj newFaceID splSegData[5]
					)else(
						setFaceMatID obj (newFaceID-1) 1
						setFaceMatID obj newFaceID 1
					)
					if this.useSmoothingGroups do(
						setFaceSmoothGroup obj (newFaceID-1) (2^(defaultSmoothingGroups[vertNum]-1))
						setFaceSmoothGroup obj newFaceID (2^(defaultSmoothingGroups[vertNum]-1))
					)
				)
			)
			
			if this.isClosedRing do (
				current = vertIdRows[vertIdRows.count]
				next = vertIdRows[1]
				
				for vertNum = 1 to (current.count - 1) do(  -- for each segment between two vertices...
					meshop.createPolygon obj #(current[vertNum], current[vertNum + 1], next[vertNum + 1], next[vertNum])
					newFaceID += 2
					
					if this.useMtlIds or this.useSmoothingGroups do local splSegData = splineSegmDataSet[vertNum]  -- get the specific segment data from the spline data set array
					if this.useMtlIds then(
						setFaceMatID obj (newFaceID-1) splSegData[5]
						setFaceMatID obj newFaceID splSegData[5]
					)else(
						setFaceMatID obj (newFaceID-1) 1
						setFaceMatID obj newFaceID 1
					)
					if this.useSmoothingGroups do(
						setFaceSmoothGroup obj (newFaceID-1) (2^(defaultSmoothingGroups[vertNum]-1)) -- the smoothinggroup bitarray is represented as a 32 bit integer
						setFaceSmoothGroup obj newFaceID (2^(defaultSmoothingGroups[vertNum]-1))
					)
				)
			)
			update obj
			if this.debug then( local end = timeStamp(); format "create faces: % s\n" ((end - start) / 1000.0) )
			true
		),
		
		fn validateFaceBuilderObj =( -- makes sure the new meshs normals are in the right direction
			local origFaceID = (polyop.getEdgeFaces obj sortedRing[1]) as bitarray * (polyop.getEdgeFaces obj sortedRing[2]) as bitarray
			local origFaceVerts = polyop.getFaceVerts obj (origFaceID as array)[1]
			local startID = edgeObjects[1].edgeVertIDs[1]
			local endID = edgeObjects[1].edgeVertIDs[2]
			
			local startPos = findItem origFaceVerts startID
			local endPos = findItem origFaceVerts endID
			if startPos == 4 and endPos == 1 then startPos = 0
			if endPos == 4 and startPos == 1 then endPos = 0
			
			-- if order is the matching they should weld fine, if order is reversed -> flip faces
			if (startPos > endPos) then meshop.flipNormals FaceBuilderObj #{1..FaceBuilderObj.numfaces}
			true
		),
		
		fn attachAndWeld =(
			if this.debug then local start = timeStamp()
			polyop.deleteFaces this.obj originalFaces delIsoVerts:false
			
			local numVerts = polyop.getNumVerts obj
			local segs = this.splineSegmDataSet.count
			polyop.attach obj this.FaceBuilderObj
			
			local origObjVerts = #{}
			local newObjVerts = #{}
			
			for edg in this.edgeObjects do(
				origObjVerts[edg.edgeVertIDs[1]] = true
				origObjVerts[edg.edgeVertIDs[2]] = true
				
				numVerts += 1
				newObjVerts[numVerts] = true
				numVerts += segs
				newObjVerts[numVerts] = true
			)
			local tmpWeldThrs = obj.weldThreshold
			obj.weldThreshold = this.weldThreshold
			polyop.weldVertsByThreshold obj (origObjVerts + newObjVerts)
			obj.weldThreshold = tmpWeldThrs
			if this.debug then( local end = timeStamp(); format "attach + weld: % s\n" ((end - start) / 1000.0) )
			true
		),
		
		
		-- GUI and high level functions
		fn performShapeConnect =(
			local success = false
			try(
				if this.debug then format "-------------------------------\n"
				if this.collectFullEdgeData then(
					success = ( collectEdgeDataSet() and assembleEdgeDataContainers() )  -- at first connect we need to collect a complete data set...
					this.collectFullEdgeData = false
				)else(
					success = assembleEdgeDataContainers()  -- later, for updating direction or options, we only need to rebuild the EdgeData objects
				)
			)catch()--format "EXCEPTION:\n % \n" (getCurrentException()))
			
			if success then (
				with redraw off(
					try(
						collectSplineData()
						disableRefMsgs()
						
						createVertices()
						if this.breakSmoothingAtAngle and this.useSmoothingGroups then(createFacesComplexSmoothing())else(createFacesSimple())
						validateFaceBuilderObj()
						attachAndWeld()
						
						enableRefMsgs()
						notifyDependents obj 
					)catch(enableRefMsgs(); format "EXCEPTION:\n % \n" (getCurrentException()))
				) -- redraw
			)else(messageBox "Invalid Edge Selection. Please select at least 2 continuous ring edges." title:"Error")
		),
		
		fn validateEditablePolySelection =(
			local isValidObject = true
			if selection.count != 1 then(
				isValidObject = "More or less than 1 object selected."
			)else(
				local selectedObj = selection[1]
				if classof selectedObj != Editable_Poly then(
					isValidObject = "Selected object is not an Editable Poly."
				)else(
					local selectedEdges = polyop.getEdgeSelection selectedObj
					if selectedEdges.numberSet < 2 then(
						isValidObject = "Less than 2 edges selected. Please select at least 2 continuous ring edges."
					)else(
						this.obj = selectedObj
						this.selEdges = selectedEdges
					)
				)
			)
			
			isValidObject
		),
		
		fn validateShapeSelection shapeObj =(
			local isValidObject = true
			if numSplines shapeObj != 1 then(
				isValidObject = "More or less than 1 Spline in the Shape object"
			)else(
				if isClosed shapeObj 1 then(
					isValidObject = "Selected Shape is closed"
				)
			)
			
			isValidObject
		),
		
		ShapeConnectRollout = rollout ShapeConnectRollout ("Shape Connect v" + this.version) width:196 (
			local owner = if owner != undefined do owner
			
			fn spline_filt obj = (classof obj == line OR classof obj == SplineShape)
			
			group "Shape" (
				pickbutton btnPickShape "Pick Shape and GO" filter:spline_filt width:170 height:40 align:#left tooltip:"Pick the Shape and perform the shape connect"
				button btnFlipDirection "Flip Shape Start/End" width:170 enabled:false align:#left tooltip:"Flips the direction of the Shape"
				button btnFlipUpVector "Flip Shape Up/Down" width:170 enabled:false align:#left tooltip:"Flips the shape up or down, inwards or outwards"
			)
			group "Settings" (
				checkbox chkMaterialIDs "Use Material IDs from Shape" checked:owner.useMtlIds tooltip:"If checked, Material IDs from the segments of the Shape are assigned; otherwise ID 1 is used"
				checkbox chkStraightenCorners "Straighten corners" checked:owner.straightenCorners tooltip:"If checked, the depth of the shape will be corrected for the angle between ring edges (like in the Shell modifier)"
				checkbox chkSmoothing "Assign Smoothing Groups" checked:owner.useSmoothingGroups tooltip:"No smoothing groups will assigned when unchecked"
				checkbox chkDiscSmoothingAt "Break SmthGrp at   °" checked:owner.breakSmoothingAtAngle tooltip:"Discontinues the smoothing group if the angle between ring edges is bigger than the threshold"
				spinner spnDegrees "" range:[0,180.0,owner.smthgAngleThreshold] fieldwidth:40 pos:(chkDiscSmoothingAt.pos + [118, 0]) tooltip:"Smoothing threshold in degrees"
				button btnUpdateObj "Update Object"  width:170 enabled:false align:#left tooltip:"Updates the MtlIDs/Smoothing Groups of the OBject when settings are changed"
			)
			button btnOK "OK" width:92 height:28 align:#left pos:(btnUpdateObj.pos + [-9, 34])
			button btnCancel "Cancel" width:92 height:28 align:#right pos:(btnOK.pos + [96,0])
			
			
			on btnPickShape picked shapeObj do(
				local polyCheckResult = owner.validateEditablePolySelection()
				local splineCheckResult = owner.validateShapeSelection shapeObj
				
				if polyCheckResult == true and splineCheckResult == true then(
					owner.splineObj = shapeObj
					if owner.firstConnect then (
						if theHold.Holding() then theHold.Accept "Pre-ShapeConnect"
					)else(
						if theHold.Holding() then theHold.Accept "ShapeConnect"
					)
					theHold.Begin()
					owner.collectFullEdgeData = true
					owner.firstConnect = false
					owner.performShapeConnect()
					
					btnFlipDirection.enabled = true
					btnFlipUpVector.enabled = true
					gc light:true
				)else(
					if polyCheckResult != true then messagebox polyCheckResult title:"Error"
					if splineCheckResult != true then messagebox splineCheckResult title:"Error"
				)
			)
			
			on btnFlipDirection pressed do(
				if theHold.Holding() then theHold.Cancel()
				theHold.Begin()
				owner.invertDirection = not owner.invertDirection
				owner.performShapeConnect()
			)
			on btnFlipUpVector pressed do(
				if theHold.Holding() then theHold.Cancel()
				theHold.Begin()
				owner.invertUpVector = not owner.invertUpVector
				owner.performShapeConnect()
			)
			
			on chkMaterialIDs changed state do(
				btnUpdateObj.enabled = true
				owner.useMtlIds = state
			)
			on chkStraightenCorners changed state do(
				btnUpdateObj.enabled = true
				owner.straightenCorners = state
			)
			on chkSmoothing changed state do(
				btnUpdateObj.enabled = true
				owner.useSmoothingGroups = state
			)
			on chkDiscSmoothingAt changed state do(
				btnUpdateObj.enabled = true
				owner.breakSmoothingAtAngle = state
			)
			on spnDegrees changed val do(
				btnUpdateObj.enabled = true
				owner.smthgAngleThreshold = val
			)
			on btnUpdateObj pressed do(
				with redraw off (
					if theHold.Holding() then theHold.Cancel()
					theHold.Begin()
					owner.performShapeConnect()
				)
			)
			
			on btnOK pressed do(
				owner.applyChanges = true
				if theHold.Holding() then theHold.Accept "ShapeConnect"
				destroyDialog RacoonScriptsShapeConnectRollout
			)
			
			on btnCancel pressed do(
				destroyDialog RacoonScriptsShapeConnectRollout
			)
			
			on ShapeConnectRollout close do(
				if not owner.applyChanges do(
					if theHold.Holding() then theHold.Cancel()
					redrawViews()
				)
				gc light:true
				
				setinisetting "$plugcfg\\RacoonScripts.ini" "ShapeConnect" "pos_x" ((GetDialogPos ShapeConnectRollout).x  as string)
				setinisetting "$plugcfg\\RacoonScripts.ini" "ShapeConnect" "pos_y" ((GetDialogPos ShapeConnectRollout).y  as string)
			)
		),
		
		on create do (
			try(destroyDialog RacoonScriptsShapeConnectRollout)catch()
			ShapeConnectRollout.owner = this
			
			RacoonScriptsShapeConnectRollout = ShapeConnectRollout 
			createDialog ShapeConnectRollout pos:[shapeConnect_iso_x, shapeConnect_iso_y]
		)
		
	) -- end of struct
	
	ShapeConnect()
	OK
)



