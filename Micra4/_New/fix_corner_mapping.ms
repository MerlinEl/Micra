-- global vsel_left
-- global vsel_right
-- global mod_uvw
--select corner edges and run script
fn fixCornerMapping obj = (

	sublvl = subObjectLevel
	--store Editable_Poly geometry data
	geo_data = mcPoly.getGeometryData obj
	esel = polyop.getEdgeSelection obj 
	everts = polyop.getVertsUsingEdge obj esel
	efaces = polyop.getFacesUsingEdge obj esel
	--select edge faces
	subObjectLevel = 4
	polyop.setFaceSelection obj efaces
	--select whole element for mapping to prevent split uvs
	obj.selectElement()
	--add unwrap modifier
	mod_uvw = Unwrap_UVW () 
	modPanel.addModToSelection mod_uvw ui:on
	mod_uvw.edit()	
	mod_uvw.fit()
	--gather vertex uv data
	mcPolyMap.collectUnwrapData obj geo_data
	subObjectLevel = 1
	--convert geometry vert selection to UV vetr selection
	uv_verts = mcPoly.geoVertsToMapVerts everts geo_data
	format "verts geo:% uv:%\n" everts.numberset  uv_verts.numberset
	vsel_left = vsel_right = #{}
	if everts.numberset == uv_verts.numberset - 1 then ( --split edges

		mod_uvw.selectVertices uv_verts
		--select edges from verts and break them
		mod_uvw.vertToEdgeSelect()
		subObjectLevel = 2
		mod_uvw.breakSelected()
		subObjectLevel = 1	
		--remove old UV data
		mcPolyMap.clearUnwrapData geo_data
		--recolect new UV data
		mcPolyMap.collectUnwrapData obj geo_data
		--gather left and right vertices from splited edge
		vsel_left = mod_uvw.getSelectedVertices()
		mod_uvw.selectVertices (mcPoly.geoVertsToMapVerts everts geo_data)
		vsel_right = (mod_uvw.getSelectedVertices()) - vsel_left
	) else ( --divide vertices in to two groups
		
		min_x = (mod_uvw.getVertexPosition 1 (uv_verts as Array)[1]).x
		for v in uv_verts do (
			
			pos_x = (mod_uvw.getVertexPosition 1 v).x
			if 	pos_x < min_x do min_x = pos_x
		)	
		for v in uv_verts do (
			
			pos_x = (mod_uvw.getVertexPosition 1 v).x	
			if pos_x <= min_x then vsel_right += #{v} else vsel_left +=#{v}
		)
	)
return ok
	--fix UV distortion on left vertices
	mcPolyMap.skewVerticesUvs mod_uvw vsel_left 75
	--fix UV distortion on left vertices
	mcPolyMap.skewVerticesUvs mod_uvw vsel_right -75	
	--
	maxOps.CollapseNodeTo obj 1 true
	subObjectLevel = sublvl	
)
undo "Fix Corner Mapping" on fixCornerMapping $


/*
mcPolyMap.skewVerticesUvs mod_uvw vsel_left -4
mcPolyMap.skewVerticesUvs mod_uvw vsel_right 4



obj = $
mod_uvw = modPanel.getCurrentObject()
mcPoly.printGeometryData geo_data
mod_uvw.getSelectedGeomEdgesByNode $ --maybe works only mesh object
*/


/* break uvs along uv seams without unwrap ?
https://forums.cgsociety.org/t/break-uvs-along-uv-seams-without-unwrap/1605657
(
	function getArrayOfTVerts2VertsMESH theObj theMapChannel =
	(
		-- both following function are from PrettyPixel:  http://forums.cgsociety.org/showthread.php?t=298713
		
		_getNumMapVerts = meshOp.getNumMapVerts
		_getNumMapFaces = meshOp.getNumMapFaces
		_getMapFace = meshOp.getMapFace
		
		local numMapVerts = _getNumMapVerts theObj theMapChannel
		local mapVerts2Verts = (for mv=1 to numMapVerts collect #())
		local numMapFaces = _getNumMapFaces theObj theMapChannel
		for f=1 to numMapFaces do
		(
			local theMapFace = _getMapFace theObj theMapChannel f
			theMapFace = #(theMapFace.x as integer,theMapFace.y as integer,theMapFace.z as integer)
			
			local meshFace = getFace theObj f
			meshFace = #(meshFace.x as integer,meshFace.y as integer,meshFace.z as integer)
			
			for mv=1 to theMapFace.count do
			(
				local mapVert = theMapFace[mv]
				if (findItem mapVerts2Verts[mapVert] meshFace[mv] == 0) do append mapVerts2Verts[mapVert] meshFace[mv]
			)
		)
		mapVerts2Verts
	)
	function getArrayOfVerts2TVerts mapVerts2Verts =
	(
		verts2MapVerts=#()
		for mv=1 to mapVerts2Verts.count do
		(
			currentVerts=mapVerts2Verts[mv]
			if currentVerts!=undefined do
			(
				for v=1 to currentVerts.count do
				(
					if verts2MapVerts[currentVerts[v]] == undefined	then	verts2MapVerts[currentVerts[v]]=#(mv)
																	else	append verts2MapVerts[currentVerts[v]] mv
				)
			)
		)
		verts2MapVerts
	)
	
	
	function getOpenMapEdges node channel:1 debug:off = if iskindof node GeometryClass and canconvertto node editable_mesh do
	(
		-- DenisT + PolyTools function from http://forums.cgsociety.org/showthread.php?f=98&t=1113501&page=3&pp=15
		-- slighly modified to get the vertices indices only
		
		local mesh = snapshotasmesh node
		local edges = #()
		
		local _getEdgesUsingVert = meshop.getEdgesUsingVert

		if meshop.getmapsupport mesh channel do
		(
			numtverts = meshop.getnummapverts mesh channel
			getmapface = meshop.getmapface
			
			tfaces = for f=1 to mesh.numfaces collect (getmapface mesh channel f)
			
			local emesh = TriMesh()
			setmesh emesh numverts:numtverts numfaces:mesh.numfaces 
			setmesh emesh faces:tfaces

			seamed = meshop.getopenedges emesh 
			opened = meshop.getopenedges mesh * seamed
			faces = meshop.getfacesusingedge mesh seamed 
			
			for f in faces do
			(
				vv = getface mesh f
				e = f*3 - 3
				
				if seamed[e += 1] and (vv[1] < vv[2] or opened[e]) do append edges #(vv.x, vv.y) 	-- get the indices of the vertices only
				if seamed[e += 1] and (vv[2] < vv[3] or opened[e]) do append edges #(vv.y, vv.z)
				if seamed[e += 1] and (vv[3] < vv[1] or opened[e]) do append edges #(vv.x, vv.z)
			)
			
			free mesh
			free emesh
		)
		edges
	)
	
	function BreakUVSeams obj =
	(
		local edges = getOpenMapEdges obj channel:1
		local verts2Tverts = getArrayOfVerts2TVerts (getArrayOfTVerts2VertsMESH obj 1)
		
		local unwrapMod = Unwrap_UVW()
		addModifier obj unwrapMod
		
		if (getCommandPanelTaskMode() != #modify) do setCommandPanelTaskMode #modify
		
		unwrapMod.setTVSubObjectMode 1
		
		-- convert the edges array in an array of the tverts matching both vertices of the edge
		local Tedges = for i=1 to edges.count collect #()
		for i=1 to edges.count do ( for j=1 to 2 do ( for tv in verts2Tverts[edges[i][j]] do append Tedges[i] tv) )
		local uvSeams = #{}
		
		-- time consuming bottleneck
		for Tedge in Tedges do
		(
			unwrapMod.selectVertices (Tedge as bitarray)
			unwrapMod.vertToEdgeSelect()
			uvSeams = uvSeams + unwrapMod.getSelectedEdges()
		)
		unwrapMod.setTVSubObjectMode 2
		unwrapMod.selectEdges uvSeams
		
		unwrapMod.breakSelected()
	)
	
	
	--=========================
	
	gc()
	st = timestamp(); sh = heapfree
	local part = converttomesh $test
	select part
	BreakUVSeams part
	format "faces:% time:% ram:%
" $.numfaces (timestamp()-st) (sh-heapfree)
)
*/


/*

mod_uvw.selectEdges esel
mod_uvw.selectVertices#{1..10}
mod_uvw.selectFaces #{1..10}
mod_uvw.UpdateView()
-- mod_uvw.selectEdges 
mod_uvw.edgeToVertSelect()
subObjectLevel = 2
mod_uvw.selectEdges (gUnwrap_Data_Manager.geoEdgesToMapEdges everts geo_data)
-- mod_uvw.fitSelected()
-- 

$.baseobject.numfaces
$.faces.count

mod_uvw.getVertexIndexFromFace 1 5
uv_data = collectUnwrapData mod_uvw


--Scan whole mapping


mod_uvw.getVertexGeomIndexFromFace face_Index uv_vert_index
<void><Unwrap_UVW>.setFaceVertex <point3>pos <integer>faceIndex <integer>ithVertex <boolean>sel

<void><Unwrap_UVW>.rotateSelectedVerticesCenter <float>angle
<void><Unwrap_UVW>.scaleSelectedVerticesCenter <float>scale <integer>dir
<void><Unwrap_UVW>.moveSelectedVertices <point3>offset
mod_uvw.unwrap2.rotateSelectedCenter <float>angle
mod_uvw.unwrap2.scaleSelectedCenter <float>scale <integer>dir
<integer><Unwrap_UVW>.NumberVertices()
<integer><Unwrap_UVW>.numberPolygons()
<void><Unwrap_UVW>.detachEdgeVertices()
<void><Unwrap_UVW>.fitSelectedElement()
<void><Unwrap_UVW>.SetVertexPosition <time>time <integer>index <point3>pos

mod_uvw.unwrap2.setSelectedGeomVets everts
mod_uvw.setSelectedGeomVets

.contractSelection()
.expandSelection()
mod_uvw.uvEdgeSelect()
mod_uvw.getSelectedEdges()
mod_uvw.selectEdges esel
mod_uvw.getSelectedGeomEdges()
mod_uvw.unwrap2.getGeomSelectElementMode()
mod_uvw.unwrap2.getSelectedEdges()
mod_uvw.unwrap2.openEdgeSelect()
mod_uvw.unwrap5.getSelectedGeomEdges()
mod_uvw.getSelectedGeomEdges()

Call <Unwrap_UVW>.setSelectedGeomVets #{geo vert indicies}
Convert selection to UV edges using <Unwrap_UVW>.vertToEdgeSelect()

selectUVOuterEdges();
    <point3>getSelCenter()
    <void>openEdgeSelect()
    <boolean>isEdgeSelected <integer>index
    <boolean>getDisplayOpenEdges()
    <void>setDisplayOpenEdges <boolean>displayOpenEdges
    <void>selectFaces <bitArray>selection
getSelectedFaces
    <void>expandGeomFaceSelection()
    <void>contractGeomFaceSelection()
   <void>setGeomSelectElementMode <boolean>mode
mod_uvw.GetSelectionFromFace() 
mod_uvw.GetSelectionFromEdge() 

mod_uvw.getSelectedGeomVerts()
mod_uvw.getSelectedGeomEdges()
mod_uvw.getSelectedGeomFace()

Yes it’s possible. 
The EDGE ID is always the same, 
because the edge under the ID stores the mapping data 
(UV coordinates in this case) in the Mapping channel. 
So currently you just have to store the selection in a global variable 
and pass it to the unwrap uvw modifier


<boolean><Unwrap_UVW>.getShowEdgeDistortion()
Returns the state of the Show Edge Distortion option in the Display menu of the Edit UVWs dialog.
Exposed via unwrap5 interface in 3ds Max 8 and higher.
<void><Unwrap_UVW>.setShowEdgeDistortion <boolean>show
Sets the state of the Show Edge Distortion option in the Display menu of the Edit UVWs dialog.
Exposed via unwrap5 interface in 3ds Max 8 and higher.
<float><Unwrap_UVW>.getEdgeDistortionScale()
Returns the Edge Distortion Scale value.
Exposed via unwrap5 interface in 3ds Max 8 and higher.
<void><Unwrap_UVW>.setEdgeDistortionScale <float>scale
Sets the Edge Distortion Scale value.
Exposed via unwrap5 interface in 3ds Max 8 and higher.

*/