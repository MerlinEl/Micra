showinterfaces (Unwrap_UVW())


unwrapMod = modpanel.getcurrentobject() -- Unwrap UVW modifier

 unwrapMod.uvLoop 0 -- select uv Loop
 unwrapMod.uvLoop 1 -- grow uv Loop
 unwrapMod.uvLoop -1 -- shrink uv Loop

 unwrapMod.uvRing 0 -- select uv Ring
 unwrapMod.uvRing 1 -- grow uv Ring
 unwrapMod.uvRing -1 -- shrink uv Ring

 unwrapMod.align true -- Align U
 unwrapMod.align false -- Align V

 unwrapMod.space true -- Space evenly in U
 unwrapMod.space false -- Space evenly in V



--light mapp channel to 2

fn addLightMapping num weld:false =
(
	local gco
	if getCommandPanelTaskMode() != #modify do setCommandPanelTaskMode mode:#modify
	if selection.count == 0 do return false
	modPanel.addModToSelection (Unwrap_UVW name:"UVW channel 1")
	gco = modPanel.getCurrentObject()
	gco.selectVertices #{1..gco.NumberVertices()}
	--gco.setWeldThreshold 0.001
	--gco.weld()
	gco.copy()
	modPanel.addModToSelection (Unwrap_UVW name:"UVW channel 2")
	gco = modPanel.getCurrentObject()
	gco.setMapChannel num
	gco.selectVertices #{1..gco.NumberVertices()}
	gco.paste false
	gco.pack 1 0.02 true true true
	gco.pack 0 0.01 true true true
	gco.selectVertices #{1..gco.NumberVertices()}
	gco.scaleSelectedCenter .95 0 --x,y
)

addLightMapping 1 weld:false

/*
In the example above, 
texture_size = [200,100] pixels
200*0.5 and 100*0.5 will result in pixel 100,50 which is exactly the center of the bitmap.
Next
meshop.getMapVert  returns a texture vertex as a point3
tf = meshop.getmapface bottle mapchannel arr[2]
tv1= meshop.getmapvert bottle mapchannel tf.x
tv2= meshop.getmapvert bottle mapchannel tf.y
tv3= meshop.getmapvert bottle mapchannel tf.z
Next
texture  = 800x600, 
the center pixel 400,300 will still land exactly at the UV coordinate 0.5,0.5
in the case of a simple textured plane - Max will just multiply the dimensions 
of the bitmap by the UV coordinates and place the correct pixel at the right coordinate.
*/

gco.rotateSelectedCenter 3.1416
0.7854 == 45
1.5708 == 90
3.1416 == 180
6.2832 == 360

$.unwrap_uvw.ScaleSelectedCenter 0.5 1
$.modifiers[#unwrap_uvw].unwrap2.setFreeFormMode on
$.modifiers[#Unwrap_UVW].texMapList.count = 0
$.modifiers[#Unwrap_UVW].texMapIDList.count = 0
$.modifiers[#Unwrap_UVW].baseMaterial = undefined
$.modifiers[#Unwrap_UVW].texMapList.count = 0
$.modifiers[#Unwrap_UVW].texMapIDList.count = 0
$.modifiers[#Unwrap_UVW].texMapList.count = 1
$.modifiers[#Unwrap_UVW].texMapIDList.count = 1
$.modifiers[#Unwrap_UVW].texMapList[1] = Checker ()
$.modifiers[#Unwrap_UVW].texMapIDList[1] = -1
subobjectLevel = 1
$.modifiers[#unwrap_uvw].unwrap.edit ()
$.modifiers[#unwrap_uvw].unwrap.selectVertices #{1..32, 34..560}
$.modifiers[#unwrap_uvw].unwrap.scale ()
$.modifiers[#unwrap_uvw].unwrap2.ScaleSelectedCenter 0.425532 0
$.modifiers[#unwrap_uvw].unwrap2.ScaleSelectedCenter 2 0


$.modifiers[#unwrap_uvw].unwrap2.ScaleSelected 0.5 0 [0.499094,0.502174,0]
$.modifiers[#unwrap_uvw].unwrap2.ScaleSelectedCenter 0.5 0
$.modifiers[#unwrap_uvw].unwrap2.moveSelected ([0.0442019,0.940922,0]/2)
$.modifiers[#unwrap_uvw].unwrap2.getSelCenter()
$.modifiers[#unwrap_uvw].unwrap2.setPivotOffset ([-0.499094,0.502174,0])


polyOp.getNumVDataChannels $
$.modifiers[#unwrap_uvw].unwrap.getSelectedVertices()
$.modifiers[#unwrap_uvw].unwrap.getSelectedPolygons()
$.modifiers[#unwrap_uvw].unwrap.GetSelectionFromFace()

$.modifiers[#unwrap_uvw].getSelectedVertices() --select all UVW shared vertices
$.modifiers[#unwrap_uvw].getSelectedGeomVerts() --select only geometry verts in UVW

<integer>NumberVertices()
<integer>numberPolygons()
$.modifiers[#unwrap_uvw].unwrap.getVertexIndexFromFace  25  1 
$.modifiers[#unwrap_uvw].unwrap.getVertexGeomIndexFromFace 34 1
$.modifiers[#unwrap_uvw].unwrap.getFaceSelectionFromStack()
<void>faceToVertSelect() -- Convert the Face Selection to Vertex Selection.
<void>setVertexPosition2 <time>time <integer>index <point3>pos <boolean>hold <boolean>update
<point3>getVertexPosition <time>time <integer>index
<void>SetVertexPosition <time>time <integer>index <point3>pos
polyOp.getVert $ 155
$.modifiers[#unwrap_uvw].unwrap.getVertexPosition 0 127
			polyOp.getMapVert $ 1 3
			--polyOp.setMapVert <Poly poly> <int mapChannel> <int index> <Point3 uvw>
			--polyOp.getNumMapVerts <Poly poly> <int mapChannel>



(
	fn RandomizeUVFaces theObject theMod theOffset =
	(
		theFaceCount = theMod.numberPolygons() --get number of polygons
		for f = 1 to theFaceCount do --loop through polygons
		(
			numPoints = theMod.numberPointsInFace f --get number of vertices in face
			theFaceOffset = (random -theOffset theOffset ) --get a single random offset
			for v = 1 to numPoints do --go through all vertices in the face
			(
				vertIndex = theMod.getVertexIndexFromFace f v --get the actual index of the vertex
				oldPos = theMod.getVertexPosition currenttime vertIndex --get its position
				theMod.setFaceVertex (OldPos+theFaceOffset) f v false--set its position - this also detaches it
			)
		)
	)--end fn

	--call function with object, modifier and offset as arguments:
	RandomizeUVFaces $ $.unwrap_uvw [0.05,0.05,0]
	select $
)





fn SplitVertsByMapVerts theMesh =
(

--first collect two arrays of bitarrays - one containing the map vertices for each mesh vertex,
--the other containing the faces using each mesh vertex:
convertToMesh theMesh 
lastVert = theMesh.numverts
lastFace = theMesh.numfaces
VertsUsage = for v = 1 to lastVert collect #{}
FaceUsage = for v = 1 to lastVert collect #{}
for f = 1 to lastFace do
(
	theFace = getFace theMesh f
	theMapFace = meshop.getMapFace theMesh 1 f
	append VertsUsage[theFace.x] theMapFace.x
	append VertsUsage[theFace.y] theMapFace.y
	append VertsUsage[theFace.z] theMapFace.z
	append FaceUsage [theFace.x] f
	append FaceUsage [theFace.y] f
	append FaceUsage [theFace.z] f
)
--Now we can go though the mesh vertex array and see if we have 2 or more map vertices.
--If yes, we count from 2 to the number of map verts and create new mesh vertices with the
--same position as the current mesh vertex. Then we go through the list of collected faces
--using that vertex and see which of the 3 components matches the current vertex and its
--corresponding map vertex matches the current map vertex. We repoint that component of the face
--to the new mesh vertex. Thus, for each previously existing map vertex, we get a new mesh vertex
--at the end of the vertex list. 

for v = 1 to VertsUsage.count do
(
	theMapVertsArray = VertsUsage[v] as array
	if theMapVertsArray.count > 1 do
	(
		theFacesArray = FaceUsage[v] as array
		theVertPos = getVert theMesh v
		for mapv = 2 to theMapVertsArray.count do
		(
			theMapVert = theMapVertsArray[mapv]
			newIndex = theMesh.numverts+1
			setNumVerts theMesh newIndex true
			setVert theMesh newIndex theVertPos 
			for f in theFacesArray do
			(
				theFaceDef = getFace theMesh f
				theMapFaceDef = meshOp.getMapFace theMesh 1 f
				if theMapFaceDef.x == theMapVert and theFaceDef.x == v do 
				(
					theFaceDef.x = newIndex 
					setFace theMesh f theFaceDef
				)				
				if theMapFaceDef.y == theMapVert and theFaceDef.y == v do 
				(
					theFaceDef.y = newIndex 
					setFace theMesh f theFaceDef
				)				
				if theMapFaceDef.z == theMapVert and theFaceDef.z == v do 
				(
					theFaceDef.z = newIndex 
					setFace theMesh f theFaceDef
				)				
			)--end f loop
		)--end v loop
	)
)
update theMesh

)

SplitVertsByMapVerts $Sphere01






/*How to get mesh vert from map vert?*/






fn getArrayOfMapVerts2VertsPOLY theObj theMapChannel =
	(
	numMapVerts = polyOp.getNumMapVerts theObj theMapChannel
	mapVerts2Verts = for mv=1 to numMapVerts collect #()
	numMapFaces = polyOp.getNumMapFaces theObj theMapChannel
	for f = 1 to numMapFaces do (
    	theMapFace = polyOp.getMapFace theObj theMapChannel f
		polyFace = polyOp.getFaceVerts theObj f
		for mv=1 to theMapFace.count do (
			mapVert = theMapFace[mv]
			if findItem mapVerts2Verts[mapVert] polyFace[mv] == 0 do append mapVerts2Verts[mapVert] polyFace[mv]
			)
		)
	mapVerts2Verts
	)

fn getArrayOfMapVerts2VertsMESH theObj theMapChannel =
	(
	numMapVerts = meshOp.getNumMapVerts theObj theMapChannel
	mapVerts2Verts = for mv=1 to numMapVerts collect #()
	numMapFaces = meshOp.getNumMapFaces theObj theMapChannel
	for f = 1 to numMapFaces do (
    	theMapFace = meshOp.getMapFace theObj theMapChannel f
		theMapFace = #(theMapFace.x as integer,theMapFace.y as integer,theMapFace.z as integer)
		meshFace = getFace theObj f
		meshFace = #(meshFace.x as integer,meshFace.y as integer,meshFace.z as integer)
		for mv=1 to theMapFace.count do (
			mapVert = theMapFace[mv]
			if findItem mapVerts2Verts[mapVert] meshFace[mv] == 0 do append mapVerts2Verts[mapVert] meshFace[mv]
			)
		)
	mapVerts2Verts
	)

fn getArrayOfMapVerts2Verts theObj theMapChannel =
	(
	array=false
	case classOf theObj of
		(
		Editable_mesh: array=getArrayOfMapVerts2VertsMESH theObj theMapChannel
		Editable_Poly: array=getArrayOfMapVerts2VertsPOLY theObj theMapChannel
		)
	array
	)

fn getArrayOfVerts2MapVerts mapVerts2Verts =
	(
	verts2MapVerts=#()
	for mv=1 to mapVerts2Verts.count do
		(
		currentVerts=mapVerts2Verts[mv]
		if currentVerts!=undefined do
			(
			for v=1 to currentVerts.count do
				(
			if verts2MapVerts[currentVerts[v]] == undefined
				then verts2MapVerts[currentVerts[v]]=#(mv)
				else append verts2MapVerts[currentVerts[v]] mv
				)
			)
		)
	verts2MapVerts
	)


clearListener()

if selection.count!=0 then
	(
	obj=selection[1]
	channel=1
	mapVerts2Verts=getArrayOfMapVerts2Verts obj channel -- create the array mapVerts ==> verts
	if mapVerts2Verts!=false do (
		verts2MapVerts=getArrayOfVerts2MapVerts mapVerts2Verts -- create the array verts ==> mapVerts
		format"%\n" obj.name
		format "\narray : mapVerts2Verts\n======================\n"
		for i=1 to mapVerts2Verts.count do format "mapVert % => verts %\n" i mapVerts2Verts[i]
		format "\narray : verts2MapVerts\n======================\n"
		for i=1 to verts2MapVerts.count do format "vert % => mapVerts %\n" i verts2MapVerts[i]
		)
	)
	
	
	
	
	
	
	
	
	
	(
	uv = modpanel.getcurrentobject() 
	mapch = uv.getmapchannel()
	if mapch == 0 do mapch = 1
	dog = uv.getSelectedVertices()
	nog = dog as array
	polyop.setVertSelection $.baseobject #all
	pom = polyop.getVertSelection $.baseobject as array
	jog = #()
	for i in pom do
	(
		dud = #()
		lom = polyop.getFacesusingVert $.baseobject i
		for f in lom do
			(
			pud = polyop.getMapFace $.baseobject mapch f
			bud = polyop.getFaceVerts $.baseobject f
			fud = finditem bud i
			append dud pud[fud]
			)
		lud = finditem nog dud[1]
		if lud != 0 do append jog i
	)
	polyop.setVertSelection $.baseobject jog
)




--automatic flatten maping
(
	local sel = selection as array
	for i in sel do
	(
		select i
		--local gco = modpanel.getcurrentobject()
		addmodifier i (Unwrap_UVW ())
		--gco.setMapChannel 2
		i.unwrap_uvw.unwrap.setMapChannel 2
		--gco.setTVSubObjectMode(3)
		i.unwrap_uvw.setTVSubObjectMode(3)
		max select all
		--(modpanel.getcurrentobject()).flattenMapNoParams()
		i.unwrap_uvw.flattenMapNoParams()
	)
)