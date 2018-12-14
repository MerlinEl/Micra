/*
--------------------------------------------------------------------------------

Author: Enrico Gullotti
Website: http://www.illusioncatalyst.com

Name: IC.PolySplitRing
Category: IllusionCatalyst Tools
Version: 0.3 - 2009.02.10

Additional requirement for 3ds Max release 9 only:
AVGuard MAXScript Extension Package 9.0.0 by Larry Minton
Currently available at ScriptSpot:
http://www.scriptspot.com/3ds-max/plugins/avguard-maxscript-extension-package

PolySplitRing is the name of a Maya tool that inserts an edge loop by selecting
a single edge of a poly object. It gives a preview of the loop and can be
adjusted along the starting edge before applying the actual cut.

This 3ds Max version is based on the same principles: once active, shows a
visual preview of the loop starting edge. It is in green if the current edge
supports an edge loop, or in red if it does not. The first left mouse button
click selects the current edge and shows the visual preview of the complete edge
loop. It can be adjusted along the edge. The second left mouse button click
applies the cut and creates the edge loop geometry. In every step a right mouse
button click brings the system one step back, from edge loop preview to starting
edge preview, and from starting edge preview to quitting the PolySplitRing.

By keeping CTRL keyboard button pressed, the cut is constrained to the middle
of the edges.

By keeping SHIFT keyboard button pressed, the cut distance from the nearest edge
ring side is kept constant.

Thanks to Zbuffer for support and ideas.

--------------------------------------------------------------------------------
*/



--macroScript IC_PolySplitRing
--category:"IllusionCatalyst Tools"
--buttonText:"PolySplitRing"
--tooltip:"IC PolySplitRing"
(

--xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx--
-- GLOBAL AND LOCAL VARIABLES
--xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx--

	local PolyObj = undefined -- Single editable poly object selected
	local MeshObj = undefined -- Snapshot mesh from editable poly object

	local iCurrPoly = 0 -- Polygon index derived from mesh face index
	local iCurrEdge = 0 -- Closest edge to current mouse hit point

	local p3LastMousePos = [0,0,0] -- Last mouse position projected on editable poly
	local iClickNumber = 0 -- Stores current mouse click number

	local aaaEdgeRings = #() -- Array containing sorted ring edges data

	local iEdgeHalf = 0 -- Stores the side of the selected edge

	local ap3EdgePrevData = #() -- Stores data for edge preview
	local aap3LoopPrevData = #(#(),#()) -- Stores data for loop preview

	local bEdgePrevActive = false -- Edge preview status
	local bOnDrag = false -- Mouse drag status
	local bScriptRunning = false -- Script running status

---------------------------------------

	local p3CameraWorldPos = [0,0,0] -- ViewCamera position in World space
	local p3CameraWorldDir = [0,0,0] -- ViewCamera direction in World space

	local p2MouseScreenPos = [0,0] -- Mouse position in Screen space
	local p3MouseWorldPos = [0,0,0] -- Mouse position in World space

	local fViewDepth = 0.0 -- ViewPlane Z axis value
	local fViewAngle = 0.0 -- Test element to view axis angle value

--xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx--
-- ACCESSORY FUNCTIONS
--xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx--

-- memKeep function helps expanding the memory heap if needed and forces some
-- cleanup. It helps avoiding run-time errors.

	function memKeep chunk =
	(
		if (heapFree < 2000000) then
		(
			gc light:true

			if (heapFree < 2000000) then
			(
				heapSize += chunk
			)
		)
	)

--------------------------------------------------------------------------------

-- modOff and modOn manage modifiers visibility to allow the editable poly
-- baseObject snapshot.

	local baModViewStatus = #{}

	function modViewOff =
	(
		baModViewStatus = #{}
		with redraw off
		(
	 		if (isValidNode PolyObj) then
			(
				for i = 1 to PolyObj.modifiers.count do
				(
					if ( (PolyObj.modifiers[i].enabled == true) and (PolyObj.modifiers[i].enabledInViews == true) ) then
					(
						baModViewStatus[i] = true
						PolyObj.modifiers[i].enabledInViews = false
					)
				)
			)
		)
	)

	function modViewOn =
	(
		with redraw off
		(
	 		if (isValidNode PolyObj) then
			(
				for i = 1 to PolyObj.modifiers.count do
				(
					if ( (PolyObj.modifiers[i].enabled == true) and (baModViewStatus[i] == true) ) then
					(
						PolyObj.modifiers[i].enabledInViews = true
					)
				)
			)
		)
		baModViewStatus = #{}
	)

--xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx--
-- FUNCTIONS
--xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx--

-- initData initializes the variables and arrays local to the macroscript.

	function initData =
	(
		gc light:true

		iCurrPoly = 0
		iCurrEdge = 0

		p3LastMousePos = [0,0,0]
		iClickNumber = 0

		iEdgeHalf = 0

		aaaEdgeRings = #()

		ap3EdgePrevData = #()
		aap3LoopPrevData = #(#(),#())

		bEdgePrevActive = false
		bOnDrag = false
		bScriptRunning = false

		p3CameraWorldPos = [0,0,0]
		p3CameraWorldDir = [0,0,0]

		p2MouseScreenPos = [0,0]
		p3MouseWorldPos = [0,0,0]

		fViewDepth = 0.0
		fViewAngle = 0.0

		PolyObj = selection[1]

		if (isValidNode MeshObj) then
			delete MeshObj

		modViewOff()
		MeshObj = snapShot PolyObj
		hide MeshObj
--		modViewOn()
	)

-- deleteData sets all variables to undefined to be cleaned by the garbage
-- collector

	function deleteData =
	(
		iCurrPoly = undefined
		iCurrEdge = undefined

		p3LastMousePos = undefined
		iClickNumber = undefined

		iEdgeHalf = undefined

		aaaEdgeRings = undefined

		ap3EdgePrevData = undefined
		aap3LoopPrevData = undefined

		bEdgePrevActive = undefined
		bOnDrag = undefined
		bScriptRunning = undefined

		p3CameraWorldPos = undefined
		p3CameraWorldDir = undefined

		p2MouseScreenPos = undefined
		p3MouseWorldPos = undefined

		fViewDepth = undefined
		fViewAngle = undefined

		PolyObj = undefined
		if ((MeshObj != undefined) and (isValidNode MeshObj)) then
		(
			delete MeshObj
			MeshObj = undefined
		)

--		gc light:true
	)

--------------------------------------------------------------------------------

-- getPolyFromMeshFace returns the poly face index from a given mesh face index

	function getPolyFromMeshFace &iMeshFace =
	(
		if ((iMeshFace == 0) or (iMeshFace == undefined)) then
			return 0

		local aiMeshVert = (meshOp.getVertsUsingFace MeshObj iMeshFace) as Array
		local aiPolyFromVert = #()

		for iVert in aiMeshVert do
			append aiPolyFromVert (polyOp.getFacesUsingVert PolyObj iVert)

		local baPoly = aiPolyFromVert[1] * aiPolyFromVert[2] * aiPolyFromVert[3]

		if (baPoly.numberSet == 1) then
		(
			return (baPoly as Array)[1]
		)
		else
		(
			local baMeshFaceInPoly = meshOp.getPolysUsingFace MeshObj iMeshFace ignoreVisEdges:false threshhold:90
			local baMeshFaceVert = meshOp.getVertsUsingFace MeshObj baMeshFaceInPoly

			for iPoly in baPoly do
			(
				local baPolyVert = polyOp.getVertsUsingFace PolyObj iPoly

				if (((baPolyVert - baMeshFaceVert).isEmpty == true) and ((baMeshFaceVert - baPolyVert).isEmpty == true)) then
				(
					return iPoly
				)
			)
		)
	)

--------------------------------------------------------------------------------

-- getHitProjAndProp gets an edge and a point and returns an assembled array
-- containing:
-- [1] the Point3 position of the first edge vertex
-- [2] the Point3 position of the second edge vertex
-- [3] the Point3 position of the projection of a point on the edge
-- [4] the Point3 position of the projection of a point on the edge limited to edge
-- [5] the Float proportion of the position of the projection on the edge

	function getHitProjAndProp &iEdge &p3HitPoint =
	(
		local aiVertFromEdge = polyOp.getEdgeVerts PolyObj iEdge

		local p3PosVert01 = polyOp.getVert PolyObj aiVertFromEdge[1]
		local p3PosVert02 = polyOp.getVert PolyObj aiVertFromEdge[2]
		local p3EdgeNorm = normalize(p3PosVert02 - p3PosVert01)

		local p3HitProj = p3PosVert01 + (p3EdgeNorm * (dot (p3HitPoint - p3PosVert01) p3EdgeNorm))
		local p3HitProjLim = p3HitProj

		local fEdgeLength = distance p3PosVert01 p3PosVert02
		local fDist01 = distance p3PosVert01 p3HitProj
		local fDist02 = distance p3PosVert02 p3HitProj

		local fHitProp = 0.5

		if ((fDist01 > fEdgeLength) and (fDist01 > fDist02)) then
		(
			fHitProp = 1
			p3HitProjLim = p3PosVert02
		)
		else if (fDist02 > fEdgeLength and (fDist02 > fDist01)) then
		(
			fHitProp = 0
			p3HitProjLim = p3PosVert01
		)
		else
		(
			fHitProp = (fDist01 / (fDist01 + fDist02))
		)

		if (keyboard.controlPressed == true) then
		(
			fHitProp = 0.5
			p3HitProjLim = ((p3PosVert01 + p3PosVert02) / 2)
		)

		return #(p3PosVert01, p3PosVert02, p3HitProj, p3HitProjLim, fHitProp)
	)

--------------------------------------------------------------------------------

-- getClosestEdge returns the edge closest to a point for a given poly

	function getClosestEdge &p3HitPoint =
	(
		local aEdgeData = #()

		local aiClosestEdge = #()
		local iClosestEdge = 0

		local fThreshold = 0.0001

		local fClosestDist = 100000
		local fDist = 0.0

		local fWidestAngle = 0
		local fAngle = 0.0

		local fEdgeLength = 0.0
		local fDist01 = 0.0
		local fDist02 = 0.0

		local baEdges = polyOp.getEdgesUsingFace PolyObj iCurrPoly

		for iEdge in baEdges do
		(
			aEdgeData = getHitProjAndProp &iEdge &p3HitPoint

			fEdgeLength = distance aEdgeData[1] aEdgeData[2]
			fDist01 = distance aEdgeData[1] aEdgeData[3]
			fDist02 = distance aEdgeData[2] aEdgeData[3]

			if ((fDist01 > fEdgeLength) and (fDist01 > fDist02)) then
				fDist = distance p3HitPoint aEdgeData[2]
			else if (fDist02 > fEdgeLength and (fDist02 > fDist01)) then
				fDist = distance p3HitPoint aEdgeData[1]
			else
				fDist = distance p3HitPoint aEdgeData[3]

			if (fDist < fClosestDist - fThreshold) then
			(
				fClosestDist = fDist
				aiClosestEdge = #(iEdge)
			)
			else if (((fClosestDist - fThreshold) < fDist) and (fDist < (fClosestDist + fThreshold))) then
			(
				append aiClosestEdge iEdge
			)
		)

		if (aiClosestEdge.count > 1) then
		(
			for iEdge in aiClosestEdge do
			(
				aEdgeData = getHitProjAndProp &iEdge &p3HitPoint

				fAngle = (acos(dot (normalize(aEdgeData[1] - p3HitPoint)) (normalize(aEdgeData[2] - p3HitPoint))))

				if (fAngle > fWidestAngle) then
				(
					fWidestAngle = fAngle
					iClosestEdge = iEdge
				)
			)
			return iClosestEdge
		)
		else
		(
			return aiClosestEdge[1]
		)
	)

-- getPolyFromMeshFace and getClosestEdge are always called together and set
-- variables local to macroscript, so it's more comfortable to have them packed
-- in a single function.

	function setPolyAndEdge &iMeshFace &p3HitPoint =
	(
		iCurrPoly = getPolyFromMeshFace &iMeshFace
		iCurrEdge = getClosestEdge &p3HitPoint
	)

--------------------------------------------------------------------------------

-- arrayCurse is a hack function to simulate a recursion without incurring in
-- stack overflow issues. It populates aaEdgeRing arrays with arrays containing:
-- [1] Edge Index
-- [2] Edge Sign
--	   0 -> same direction
--	   1 -> opposite direction
-- [3] Vertex0 Position
-- [4] Vertex1 Position
-- [5] Edge Length
-- [6] Side Loop Normal

	function arrayCurse aaEdgeRing &fEdgeProp iFaceBlock: =
	(
		local iLastElem = 1
		local baFaceFromEdge = #{}
		local baEdgeFromFace = #{}
		local aiVertFromEdge = #()
		local baEdgeFromVert01 = #{}
		local baEdgeFromVert02 = #{}
		local iNewEdge = 0
		local aiVertFormNewEdge = #()
		local p3PosVert01 = [0,0,0]
		local p3PosVert02 = [0,0,0]
		local baVertSet01 = #{}
		local aEdgeRing = #()
		local bClosedLoop = false

		for aItem in aaEdgeRing do
		(
			iLastElem = aaEdgeRing.count
			baFaceFromEdge = polyOp.getFacesUsingEdge PolyObj aItem[1]

			for iFace in baFaceFromEdge do
				if (polyOp.getFaceDeg PolyObj iFace != 4) then
					baFaceFromEdge[iFace] = false

			if (iFaceBlock != unsupplied) then
				baFaceFromEdge[iFaceBlock] = false

			if (baFaceFromEdge.isEmpty == false) then
			(
				baEdgeFromFace = polyOp.getEdgesUsingFace PolyObj baFaceFromEdge
				aiVertFromEdge = polyOp.getEdgeVerts PolyObj aItem[1]

				baEdgeFromVert01 = polyOp.getEdgesUsingVert PolyObj aiVertFromEdge[1]
				baEdgeFromVert02 = polyOp.getEdgesUsingVert PolyObj aiVertFromEdge[2]

				iNewEdge = ((baEdgeFromFace - baEdgeFromVert01 - baEdgeFromVert02) as Array)[1]

				if (aaEdgeRing[iLastElem][2] == 0) then
					baVertSet01 = polyOp.getVertsUsingEdge PolyObj baEdgeFromVert01
				else
					baVertSet01 = polyOp.getVertsUsingEdge PolyObj baEdgeFromVert02

				aiVertFormNewEdge = polyOp.getEdgeVerts PolyObj iNewEdge
				p3PosVert01 = polyOp.getVert PolyObj aiVertFormNewEdge[1]
				p3PosVert02 = polyOp.getVert PolyObj aiVertFormNewEdge[2]

				if (baVertSet01[aiVertFormNewEdge[1]] == true) then
					aEdgeRing = #(iNewEdge, 0, p3PosVert01, p3PosVert02, (distance p3PosVert01 p3PosVert02) )
				else
					aEdgeRing = #(iNewEdge, 1, p3PosVert02, p3PosVert01, (distance p3PosVert01 p3PosVert02) )

				if (fEdgeProp < 0.5) then
				(
					append aaEdgeRing[iLastElem] (normalize(aEdgeRing[3] - aaEdgeRing[iLastElem][3]))
					iEdgeHalf = 0
				)
				else
				(
					append aaEdgeRing[iLastElem] (normalize(aEdgeRing[4] - aaEdgeRing[iLastElem][4]))
					iEdgeHalf = 1
				)

				memKeep 1000000

				if (iNewEdge != iCurrEdge) then
				(
					append aaEdgeRing aEdgeRing
					iFaceBlock = ((baFaceFromEdge) as Array)[1]
--					bClosedLoop = false
				)
				else
				(
					bClosedLoop = true
				)
			)
		)

		if (bClosedLoop == true) then
		(
			if (fEdgeProp < 0.5) then
				append aaEdgeRing[iLastElem] (normalize(aaEdgeRing[iLastElem][3] - aaEdgeRing[1][3]))
			else
				append aaEdgeRing[iLastElem] (normalize(aaEdgeRing[iLastElem][4] - aaEdgeRing[1][4]))

			append aaEdgeRing aaEdgeRing[1]
		)
		else
		(
			append aaEdgeRing[iLastElem] aaEdgeRing[iLastElem-1][6]
		)
	)

---------------------------------------

-- startArrayCurse establishes conditions for arrayCurse to run depending on the
-- edge picked. It populates aaaEdgeRings with two arrays which summed represent
-- the full edge ring available.

	function startArrayCurse &fEdgeProp =
	(
		local baFaceFromEdge = polyOp.getFacesUsingEdge PolyObj iCurrEdge

		for iFace in baFaceFromEdge do
			if (polyOp.getFaceDeg PolyObj iFace != 4) then
				baFaceFromEdge[iFace] = false

		local aiVertFormStartEdge = polyOp.getEdgeVerts PolyObj iCurrEdge
		local p3PosVert01 = polyOp.getVert PolyObj aiVertFormStartEdge[1]
		local p3PosVert02 = polyOp.getVert PolyObj aiVertFormStartEdge[2]
		local fEdgeLength = distance p3PosVert01 p3PosVert02

		local aaEdgeRing01 = #( #(iCurrEdge, 0, p3PosVert01, p3PosVert02, fEdgeLength) )
		local aaEdgeRing02 = #( #(iCurrEdge, 0, p3PosVert01, p3PosVert02, fEdgeLength) )

		if (baFaceFromEdge.numberSet == 1) then
		(
			arrayCurse aaEdgeRing01 &fEdgeProp
			aaEdgeRing02[1][6] = aaEdgeRing01[1][6] * (quat 180 (p3PosVert02 - p3PosVert01)) -- mirrored normal
		)
		else if (baFaceFromEdge.numberSet == 2) then
		(
			local aiFaceFromEdge = baFaceFromEdge as Array
			arrayCurse aaEdgeRing01 &fEdgeProp iFaceBlock:aiFaceFromEdge[1]

			if (aaEdgeRing01[1] != aaEdgeRing01[aaEdgeRing01.count]) then
				arrayCurse aaEdgeRing02 &fEdgeProp iFaceBlock:aiFaceFromEdge[2]
			else
				aaEdgeRing02[1][6] = aaEdgeRing01[1][6] * (quat 180 (p3PosVert02 - p3PosVert01)) -- mirrored normal
		)

		aaaEdgeRings = #(aaEdgeRing01, aaEdgeRing02)
	)

--------------------------------------------------------------------------------

/*
	Function credited to Chris Johnson

	Calculate the line segment PaPb that is the shortest route between
	two lines P1P2 and P3P4. Calculate also the values of mua and mub where
		Pa = P1 + mua (P2 - P1)
		Pb = P3 + mub (P4 - P3)
	Return FALSE if no solution exists.

	p1 thru p4 and pa and pb are of type Point3

---------------------------------------

	Modified version returns the mid point of the shortest segment connecting
	two skew lines
*/

	-- function LineLineIntersect p1 p2 p3 p4 &pa &pb = -- modified
	function LineLineIntersect p1 p2 p3 p4 = -- modified
	(
		local EPS = 2e-4;

		local p13 = Point3 0 0 0
		local p43 = Point3 0 0 0
		local p21 = Point3 0 0 0

		local d1343,d4321,d1321,d4343,d2121;
		local numer,denom;

		p13.x = p1.x - p3.x;
		p13.y = p1.y - p3.y;
		p13.z = p1.z - p3.z;
		p43.x = p4.x - p3.x;
		p43.y = p4.y - p3.y;
		p43.z = p4.z - p3.z;

		if ( (abs(p43.x) < EPS) and (abs(p43.y) < EPS) and (abs(p43.z) < EPS) ) do ( return false )

		p21.x = p2.x - p1.x;
		p21.y = p2.y - p1.y;
		p21.z = p2.z - p1.z;

		if ( (abs(p21.x) < EPS) and (abs(p21.y) < EPS) and (abs(p21.z) < EPS) ) do ( return false )

		d1343 = p13.x * p43.x + p13.y * p43.y + p13.z * p43.z;
		d4321 = p43.x * p21.x + p43.y * p21.y + p43.z * p21.z;
		d1321 = p13.x * p21.x + p13.y * p21.y + p13.z * p21.z;
		d4343 = p43.x * p43.x + p43.y * p43.y + p43.z * p43.z;
		d2121 = p21.x * p21.x + p21.y * p21.y + p21.z * p21.z;

		denom = d2121 * d4343 - d4321 * d4321;

		if (abs(denom) < EPS) do ( return false )

		numer = d1343 * d4321 - d1321 * d4343;

		local mua = numer / denom;
		local mub = (d1343 + d4321 * (mua)) / d4343;

		local pa = [0,0,0] -- added
		local pb = [0,0,0] -- added

		pa.x = p1.x + (mua * p21.x);
		pa.y = p1.y + (mua * p21.y);
		pa.z = p1.z + (mua * p21.z);
		pb.x = p3.x + (mub * p43.x);
		pb.y = p3.y + (mub * p43.y);
		pb.z = p3.z + (mub * p43.z);

	--	return true; -- removed
		return ((pa + pb)/2) -- added
	)

--------------------------------------------------------------------------------

-- getPosAlongEdges is feeded with a sorted array of edges forming a ring and
-- populates aap3LoopPrevData with point3 positions along those edges based on
-- their direction and the proportion value provided.

	function getPosAlongEdges &aaaEdgeRings &fEdgeProp =
	(
		aap3LoopPrevData = #(#(),#())

		if ( (keyboard.shiftPressed == false) or (aaaEdgeRings[1].count == 1) ) then
		(
			local p3NewPointPos = [0,0,0]
			for k = 1 to 2 do
			(
				for aItem in aaaEdgeRings[k] do
				(
					p3NewPointPos = (aItem[3] + ((aItem[4] - aItem[3]) * fEdgeProp))
					append aap3LoopPrevData[k] p3NewPointPos
				)
			)
		)
		else
		(
			if (p3MouseWorldPos != [0,0,0]) then
				local p3PointPos = p3MouseWorldPos
			else
				local p3PointPos = p3LastMousePos

			if (length(aaaEdgeRings[1][1][6] + aaaEdgeRings[2][1][6]) < 2e-6) then
				local p3Bisect = undefined
			else
				local p3Bisect = normalize(aaaEdgeRings[1][1][6] + aaaEdgeRings[2][1][6])

			local aap3FirstOffEdges = #()
			local p3FirstOffEdgeInt = [0,0,0]
			local iNumEdges01 = 0

			local bClosedLoop = false

---------------------------------------

			for k = 1 to 2 do
			(
				local aaEdgeRing = aaaEdgeRings[k]
				local iNumEdges = aaEdgeRing.count

				if (iEdgeHalf == 0) then
				(
					local fFirstEdge = aaEdgeRing[1][4] - aaEdgeRing[1][3]
					local p3PointVector = p3PointPos - aaEdgeRing[1][3]
				)
				else
				(
					local fFirstEdge = aaEdgeRing[1][3] - aaEdgeRing[1][4]
					local p3PointVector = p3PointPos - aaEdgeRing[1][4]
				)

				local fRefLength = dot p3PointVector (normalize(fFirstEdge))

				if (fRefLength < 0) then
					fRefLength = 0
				else if (fRefLength > length(fFirstEdge)) then
					fRefLength = length(fFirstEdge)

---------------------------------------

				local p3CurrEdgeOnRingNorm = [0,0,0]
				local p3NextEdgeOnRingNorm = [0,0,0]

				local fAngle01 = 0.0
				local fAngle02 = 0.0

				local fCutLen01 = 0.0
				local fCutLen02 = 0.0

				local fCutProp01 = 0.0
				local fCutProp02 = 0.0

				local ap3CurrOffEdge = #()
				local ap3PrevOffEdge = #()

				local p3OffEdgeInt = [0,0,0]

---------------------------------------

				if (iNumEdges > 1) then
				(
					for i = 1 to (iNumEdges-1) do
					(
						ap3PrevOffEdge = ap3CurrOffEdge

						p3CurrEdgeOnRingNorm = normalize(aaEdgeRing[i][4] - aaEdgeRing[i][3])
						fAngle01 = 90 - acos(abs(dot aaEdgeRing[i][6] p3CurrEdgeOnRingNorm))

						if (fAngle01 >= 90 - 2e-4) then
							fCutLen01 = fRefLength
						else
							fCutLen01 = sqrt((pow (fRefLength) 2) + (pow (abs(fRefLength * tan(fAngle01))) 2))

						fCutProp01 = fCutLen01 / aaEdgeRing[i][5]

						p3NextEdgeOnRingNorm = normalize(aaEdgeRing[i+1][4] - aaEdgeRing[i+1][3])
						fAngle02 = 90 - acos(abs(dot aaEdgeRing[i][6] p3NextEdgeOnRingNorm))

						if (fAngle02 >= 90 - 2e-4) then
							fCutLen02 = fRefLength
						else
							fCutLen02 = sqrt((pow (fRefLength) 2) + (pow (abs(fRefLength * tan(fAngle02))) 2))

						fCutProp02 = fCutLen02 / aaEdgeRing[i+1][5]

						if (iEdgeHalf == 0) then
							ap3CurrOffEdge = #(aaEdgeRing[i][3] + (aaEdgeRing[i][4] - aaEdgeRing[i][3]) * fCutProp01, aaEdgeRing[i+1][3] + (aaEdgeRing[i+1][4] - aaEdgeRing[i+1][3]) * fCutProp02)
						else
							ap3CurrOffEdge = #(aaEdgeRing[i][4] + (aaEdgeRing[i][3] - aaEdgeRing[i][4]) * fCutProp01, aaEdgeRing[i+1][4] + (aaEdgeRing[i+1][3] - aaEdgeRing[i+1][4]) * fCutProp02)

						if (i == 1) then
						(
							p3OffEdgeInt = ap3CurrOffEdge[1]
							append aap3FirstOffEdges ap3CurrOffEdge
						)
						else
						(
							if (length(normalize(ap3PrevOffEdge[1] - ap3PrevOffEdge[2]) - normalize(ap3CurrOffEdge[1] - ap3CurrOffEdge[2])) < 2e-4) then
							(
								p3OffEdgeInt = (ap3PrevOffEdge[2] + ap3CurrOffEdge[1]) /2
							)
							else
							(
								p3OffEdgeInt = (LineLineIntersect ap3PrevOffEdge[1] ap3PrevOffEdge[2] ap3CurrOffEdge[1] ap3CurrOffEdge[2])

								if (p3OffEdgeInt == false) then
									p3OffEdgeInt = (ap3PrevOffEdge[2] + ap3CurrOffEdge[1]) /2
							)
						)

						append aap3LoopPrevData[k] p3OffEdgeInt

					) -- end i loop

---------------------------------------

					-- Manage Last Element [iNumEdges]
					if (aaEdgeRing[1][1] != aaEdgeRing[iNumEdges][1]) then
						bClosedLoop = false
					else if (iNumEdges > 1) then
						bClosedLoop = true

					append aap3LoopPrevData[k] ap3CurrOffEdge[2]

				) -- end if iNumEdges > 1

			) -- end k loop

---------------------------------------

			-- Manage First Element [1]
			if (aap3FirstOffEdges.count == 2) then
			(
				-- Two sides loop
				p3FirstOffEdgeInt = (LineLineIntersect aap3LoopPrevData[1][1] aap3LoopPrevData[1][2] aap3LoopPrevData[2][1] aap3LoopPrevData[2][2])

				if (p3FirstOffEdgeInt == false) then
					p3FirstOffEdgeInt = (aap3LoopPrevData[1][1] + aap3LoopPrevData[2][1]) /2

				aap3LoopPrevData[1][1] = aap3LoopPrevData[2][1] = p3FirstOffEdgeInt
			)
			else if (aap3FirstOffEdges.count == 1) then
			(
				-- One side loop (and closed)
				if (bClosedLoop == true) then
				(
					iNumEdges01 = aap3LoopPrevData[1].count
					p3FirstOffEdgeInt = (LineLineIntersect aap3LoopPrevData[1][iNumEdges01-1] aap3LoopPrevData[1][iNumEdges01] aap3LoopPrevData[1][1] aap3LoopPrevData[1][2] )

					if (p3FirstOffEdgeInt == false) then
						p3FirstOffEdgeInt = (aap3LoopPrevData[1][iNumEdges01] + aap3LoopPrevData[1][1]) /2

					aap3LoopPrevData[1][1] = p3FirstOffEdgeInt
					aap3LoopPrevData[2][1] = p3FirstOffEdgeInt
					aap3LoopPrevData[1][iNumEdges01] = p3FirstOffEdgeInt
				)
			)
			else
			(
				-- No loop at all
				p3FirstOffEdgeInt = (aaaEdgeRings[1][1][3] + (aaaEdgeRings[1][1][4] - aaaEdgeRings[1][1][3]) * fEdgeProp)
				aap3LoopPrevData[1][1] = aap3LoopPrevData[2][1] = p3FirstOffEdgeInt
			)
		)
	)

--------------------------------------------------------------------------------

-- ceilPoint3 returns a Point3 with each value rounded to its nearest upper
-- integer

	function ceilPoint3 p3Value =
	(
		for i = 1 to 3 do
			p3Value[i] = ceil p3Value[i]

		return p3Value
	)

-- splitDrawingArray splits an array storing drawing points positions into
-- chunks. It is needed because gw drawing functions have a limit on the number
-- of segments in a single polyline they can draw

	function splitDrawingArray aRaw iChunkSize =
	(
		if ((classOf aRaw) != Array) then
			return false

		local iNumItems = aRaw.count
		local iNumChunks = ceil(aRaw.count / (iChunkSize as Float))

		local aaSplitArray = #()
		aaSplitArray[iNumChunks] = 0

		local aTempChunk = #()
		aTempChunk[iChunkSize] = 0

		for j = 0 to iNumChunks do
		(
			aTempChunk = for i in 1 to (iChunkSize + 1) where ((i + (j * iChunkSize)) <= iNumItems) collect aRaw[i + (j * iChunkSize)]

			if (aTempChunk[1] != undefined) then
				aaSplitArray[j + 1] = aTempChunk
		)
		return aaSplitArray
	)

-- previewEdge is a drawing function. It draws a colored segment over poly edge
-- provided and a marker on the projection of the current hit point over the edge.
-- It makes use of the aaaEdgeRings local to the macroscript filled with edge
-- extremities and hit point projection positions.

	function previewEdge &ap3EdgeData =
	(
		gw.setTransform (matrix3 1)

		local baFaces = polyOp.getFacesUsingEdge PolyObj iCurrEdge
		local iNumQuad = 0

		for iFace in baFaces do
			if (polyOp.getFaceDeg PolyObj iFace == 4) then
				iNumQuad += 1

		if (iNumQuad > 0) then
			gw.setColor #line green
		else
			gw.setColor #line red

		gw.polyLine #(ap3EdgeData[1], ap3EdgeData[2]) false

		local p3HitPosScreen = gw.transPoint ap3EdgeData[3]
		p3HitPosScreen = ceilPoint3(p3HitPosScreen)

		local ap3CustSquare = #()
		local fRadius = 3

		for iAlpha = 45 to 360 by 90 do
			append ap3CustSquare ([fRadius * (cos iAlpha), fRadius * (sin iAlpha), 0] + p3HitPosScreen)

		gw.wPolyLine ap3CustSquare true

		gw.enlargeUpdateRect #whole
		gw.updateScreen()
	)

-- regEdgePreview is a function alias to allow redraw callback registration and
-- passing values by reference to previewEdge function.
-- It is registered during the #freeMove mouseTrack stage when over the active
-- object and unregistered when out.

	function regEdgePreview = previewEdge &ap3EdgePrevData

-- previewLoop is a drawing function. It draws colored segments and a marker on
-- the projection of the current hit point over the edge as a visual preview of
-- the PolySplitRing. It makes use of the aaaEdgeRings local to the macroscript
-- filled with positions along ring edges according to proportion parameter.

	function previewLoop &aap3LoopData =
	(
		local iMaxCount = 50
		local aap3LoopStack01 = #()
		local aap3LoopStack02 = #()

		if (aap3LoopData[1].count <= iMaxCount) then
			aap3LoopStack01[1] = aap3LoopData[1]
		else
			aap3LoopStack01 = splitDrawingArray aap3LoopData[1] iMaxCount

		if (aap3LoopData[2].count <= iMaxCount) then
			aap3LoopStack02[1] = aap3LoopData[2]
		else
			aap3LoopStack02 = splitDrawingArray aap3LoopData[2] iMaxCount

		local iNumLoop01 = aap3LoopStack01.count
		local iNumLoop02 = aap3LoopStack02.count

---------------------------------------

		gw.setTransform (matrix3 1)

		local p3HitPosScreen = (gw.transPoint aap3LoopData[1][1])
		p3HitPosScreen = ceilPoint3(p3HitPosScreen)

		local ap3CustSquare = #()
		local fRadius = 3

		if ( (aap3LoopData[1].count == 1) and (aap3LoopData[2].count == 1) ) then
		(
			gw.setColor #line red
			fRadius = 5
		)
		else
		(
			gw.setColor #line green

			for i = 1 to iNumLoop01 do
				gw.polyLine aap3LoopStack01[i] false

			for i = 1 to iNumLoop02 do
				gw.polyLine aap3LoopStack02[i] false
		)

		for iAlpha = 45 to 360 by 90 do
			append ap3CustSquare ([fRadius * cos iAlpha, fRadius * sin iAlpha, 0] + p3HitPosScreen)

		gw.wPolyLine ap3CustSquare true

		gw.enlargeUpdateRect #whole
		gw.updateScreen()
	)

-- regLoopPreview is a function alias to allow redraw callback registration and
-- passing values by reference to previewLoop function.
-- It is registered at the start of #mouseDrag mouseTrack stage when dragging
-- over the active object and unregistered when the cut happens.

	function regLoopPreview = previewLoop &aap3LoopPrevData

--------------------------------------------------------------------------------

-- Following group of functions selectively calls other functions during the
-- various stages of the PolySplitRing action. They set values in variables
-- local to macroscript.

-- setEdgePreview fills the ap3VertLoop01 and ap3VertLoop02 with poly edge
-- extremities and projection of the hit point positions.

	function setEdgePreview &p3Point =
	(
		local aEdgeData = getHitProjAndProp &iCurrEdge &p3Point

		ap3EdgePrevData = #(aEdgeData[1], aEdgeData[2], aEdgeData[4])
	)

-- setLoopPreview calls the operations needed only once before the starting the
-- previewLoop, like recursive functions to collect ring edges, then fills
-- ap3VertLoop01 and ap3VertLoop02 with positions to feed drawing functions.

	function setLoopPreview &p3Point =
	(
		local fEdgeProp = (getHitProjAndProp &iCurrEdge &p3Point)[5]

		startArrayCurse(&fEdgeProp)

		getPosAlongEdges &aaaEdgeRings &fEdgeProp
	)

-- updateLoopPreview calls the operations that need continuously update data
-- during previewLoop, then fills ap3VertLoop01 and ap3VertLoop02 with updated
-- positions to feed drawing functions.

	function updateLoopPreview &p3Point =
	(
		local fEdgeProp = (getHitProjAndProp &iCurrEdge &p3Point)[5]

		getPosAlongEdges &aaaEdgeRings &fEdgeProp
	)

--------------------------------------------------------------------------------

-- cutRing executes the cut. It gets the edges to cut from aaaEdgeRings arrays,
-- calculates the current proportion, inserts a vertex in each edge and connects
-- all new vertices creating the loop.

	function cutRing &p3Point =
	(
		with redraw off
		(
			local iNumEdges01 = aaaEdgeRings[1].count

			if ( (aaaEdgeRings[1][1] == aaaEdgeRings[1][iNumEdges01]) and (iNumEdges01 > 1) ) then
			(
				deleteItem aaaEdgeRings[1] iNumEdges01
				deleteItem aaaEdgeRings 2
			)
			else if ( (aaaEdgeRings[1][1] == aaaEdgeRings[1][iNumEdges01]) and (iNumEdges01 == 1) ) then
			(
				deleteItem aaaEdgeRings 2
			)
			else
			(
				local iNumEdges02 = aaaEdgeRings[2].count

				if (iNumEdges02 == 1) then
				(
					deleteItem aaaEdgeRings 2
				)
				else
				(
					deleteItem aaaEdgeRings[1] 1
					deleteItem aap3LoopPrevData[1] 1
				)
			)

			local fEdgeProp = (getHitProjAndProp &iCurrEdge &p3Point)[5]
			polyOp.setVertSelection PolyObj #{}

			if (keyboard.shiftPressed == false) then
			(
				for aaItem in aaaEdgeRings do
				(
					for aItem in aaItem do
					(
						if ( (fEdgeProp > 0) and (fEdgeProp < 1) ) then
						(
							PolyObj.insertVertexInEdge aItem[1] (abs(aItem[2] - fEdgeProp)) select:true
						)
					)
				)
			)
			else
			(
				local baNewVerts = #{}
				local ap3shift = #()

				local iNumLoops = aaaEdgeRings.count
				for k = 1 to iNumLoops do
				(
					local iNumEdges = aaaEdgeRings[k].count
					for i = 1 to iNumEdges do
					(
						if (fEdgeProp > 0) then
						(
							local iNewVert = PolyObj.insertVertexInEdge aaaEdgeRings[k][i][1] 0.5 select:true
							local p3NewVertPos = polyOp.getVert PolyObj iNewVert

							baNewVerts[iNewVert] = true
							append ap3shift (aap3LoopPrevData[k][i] - p3NewVertPos)
						)
					)
				)
				polyOp.moveVert PolyObj baNewVerts ap3Shift
			)
			polyOp.setEdgeSelection PolyObj #{}
			PolyObj.connectVertices vertexFlag:1

			aaaEdgeRings = #()

			MeshObj.mesh = PolyObj.mesh
			update MeshObj
		)
	)

--xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx--
-- MOUSE TRACK FUNCTION
--xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx--

-- doInsertLoop is the function driving the whole PolySplitRing action.
-- It defines its behaviour.

	function doInsertLoop msg ir obj faceNum shift ctrl alt =
	(
		case msg of
		(
			#freeMove:
			(
				if (iClickNumber == 0) then
				(
					-- Hovering above the editable poly before clicking anywhere.
					-- Shows a visual hint about the edge and the point where the
					-- cut will start.

					if (ir != undefined) then
					(
						p3LastMousePos = ir.pos
						p3MouseWorldPos = [0,0,0]

						setPolyAndEdge &faceNum &ir.pos
						setEdgePreview &ir.pos

						nodeInvalRect PolyObj
						redrawViews()

						if (bEdgePrevActive == false) then
						(
							registerRedrawViewsCallback regEdgePreview
							bEdgePrevActive = true
							completeRedraw()
						)
					)
					else
					(
						unRegisterRedrawViewsCallback regEdgePreview
						bEdgePrevActive = false
					)
				)
				else if (iClickNumber == 1) then
				(
					-- Hovering above the editable poly after the first click.
					-- Shows a visual hint about the full loop that will be cut.

					if (ir != undefined) then
					(
						p3LastMousePos = ir.pos
						p3MouseWorldPos = [0,0,0]

						updateLoopPreview &ir.pos
					)
					else
					(
						p3CameraWorldPos = (inverse(getViewTM())).row4
						p3CameraWorldDir = -(inverse(getViewTM())).row3
						fViewAngleDot = dot (normalize(p3LastMousePos - p3CameraWorldPos)) p3CameraWorldDir

						fViewDepth = (distance p3LastMousePos p3CameraWorldPos) * fViewAngleDot
						p2MouseScreenPos = mouse.pos
						p3MouseWorldPos = (mapScreenToView p2MouseScreenPos -fViewDepth) * inverse(getViewTM())

						updateLoopPreview &p3MouseWorldPos
					)
					nodeInvalRect PolyObj
					redrawViews()
				)
				#continue
			)
			#mousePoint:
			(
				unRegisterRedrawViewsCallback regEdgePreview
				bEdgePrevActive = false

				if (bOnDrag == false) then
				(
					iClickNumber += 1;

					if (iClickNumber == 1) then
					(
						-- Executed once by the first click. Starts the edge preview.

						if (ir != undefined) then
						(
							p3LastMousePos = ir.pos

							setPolyAndEdge &faceNum &ir.pos
							setLoopPreview &ir.pos

							registerRedrawViewsCallback regLoopPreview
							completeRedraw()
						)
						else
						(
							iClickNumber = 0
						)
					)
					else if (iClickNumber == 2) then
					(
						-- Executed once by the second click. Starts the loop preview.

						if (ir != undefined) then
						(
							cutRing &ir.pos
						)
						else
						(
							cutRing &p3MouseWorldPos
						)

						unRegisterRedrawViewsCallback regLoopPreview
						completeRedraw()

						iClickNumber = 0
					)
				)
				else
				(
					-- Executed once at the end of a drag action.

					bOnDrag = false
				)
				#continue
			)
			#mouseMove:
			(
				unRegisterRedrawViewsCallback regEdgePreview
				bEdgePrevActive = false

				if (bOnDrag == false) then
				(
					-- Executed once after first click starting a drag action.

					bOnDrag = true

					iClickNumber += 1;

					if (iClickNumber == 1) then
					(
						-- Starts the loop preview

						if (ir != undefined) then
						(
							setPolyAndEdge &faceNum &ir.pos
							setLoopPreview &ir.pos

							registerRedrawViewsCallback regLoopPreview
							completeRedraw()
						)
						else
						(
							iClickNumber = 0
						)
					)
					else if (iClickNumber == 2) then
					(
						-- Executed once after second click if a second drag
						-- action is started. It performs the cut.

						if (ir != undefined) then
						(
							cutRing &ir.pos
						)
						else
						(
							cutRing &p3MouseWorldPos
						)

						unRegisterRedrawViewsCallback regLoopPreview
						completeRedraw()

						iClickNumber = 0
					)
				)
				else
				(
					-- Executed continuously during the drag action.

					if (iClickNumber == 1) then
					(
						if (ir != undefined) then
						(
							p3LastMousePos = ir.pos
							p3MouseWorldPos = [0,0,0]

							updateLoopPreview &ir.pos
						)
						else
						(
							p3CameraWorldPos = (inverse(getViewTM())).row4
							p3CameraWorldDir = -(inverse(getViewTM())).row3
							fViewAngleDot = dot (normalize(p3LastMousePos - p3CameraWorldPos)) p3CameraWorldDir

							fViewDepth = (distance p3LastMousePos p3CameraWorldPos) * fViewAngleDot
							p2MouseScreenPos = mouse.pos
							p3MouseWorldPos = (mapScreenToView p2MouseScreenPos -fViewDepth) * (inverse(getViewTM()))

							updateLoopPreview &p3MouseWorldPos

						)
						nodeInvalRect PolyObj
						redrawViews()
					)
				)
				#continue
			)
			#mouseAbort:
			(
				-- Called by right clicking terminates the PolySplitRing action

				if (iClickNumber == 0) then
				(
					-- Called once if aborting during edge preview

					unRegisterRedrawViewsCallback regEdgePreview
					completeRedraw()

					#stop
				)
				else if (iClickNumber == 1) then
				(
					-- Called once if aborting during loop preview

					unRegisterRedrawViewsCallback regLoopPreview
					completeRedraw()

					iClickNumber = 0

					#continue
				)
			)
		)
	)

--xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx--
-- MACROSCRIPT EVENTS
--xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx--

	on isVisible do ( (selection[1] != undefined) and (selection.count == 1) and ((classOf selection[1].baseObject) == Editable_Poly) )

	on isEnabled do ( (selection[1] != undefined) and (selection.count == 1) and ((classOf selection[1].baseObject) == Editable_Poly) )

	on isChecked do bScriptRunning

	on execute do
	(
		unRegisterRedrawViewsCallback regEdgePreview
		unRegisterRedrawViewsCallback regLoopPreview
		completeRedraw()

		if (bScriptRunning == false) then
		(
--			undo on
--			(
				initData()

				bScriptRunning = true

				mouseTrack on:MeshObj trackCallback:doInsertLoop

				unRegisterRedrawViewsCallback regEdgePreview
				unRegisterRedrawViewsCallback regLoopPreview
				completeRedraw()

				modViewOn()
				deleteData()

				bScriptRunning = false
--			)
		)

		if ( (baModViewStatus.isEmpty == false) or (bScriptRunning == true) ) then
		(
			modViewOn()
			deleteData()

			bScriptRunning = false
		)
	)

--------------------------------------------------------------------------------

) -- End macroScript