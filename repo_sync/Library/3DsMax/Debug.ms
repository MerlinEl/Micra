(
     	debug = true
     	if debug then clearListener()
     	
     	local theMod = $.unwrap_uvw
     	
     	-- set the face selection while debugging
     	-- change the bitarray to something that suits your debug object or set dubug to false
     	-- or just comment out the next line!
     	if debug do theMod.selectFaces #{235..240, 243..248, 251..256}
     	
     	local faces = theMod.getSelectedFaces()
     	local allEdges = #()
     	
     	format "faces: %\n" faces
     	
     	for f in faces do -- get all the face edges into the array 'allEdges'
     	(
     		theMod.selectFaces #{f}
     		theMod.FaceToEdgeSelect()
     		join allEdges ( (theMod.getSelectedEdges()) as array )
     	)
     	
     	if debug do format "allEdges: %\nallEdges.count: %\n" allEdges allEdges.count
     	-----------------------------------------------------------------------------
     	
     	-- This part will sort out which edges are border edges and which are internal. For this script
     	-- it is assumed that there is only 1 edge border, ie. it's not a donut shaped selection, so any
     	-- edges that appear in the allEdges array more than once must be internal edges
     	local edges = #()
     	while allEdges.count > 0 do
     	(
     		ed = allEdges[1]
     		deleteItem allEdges 1
     		-- if the edge can still be found in the array then it's not a border edge
     		if (finditem allEdges ed) > 0 then
     			while (index = finditem allEdges ed) > 0 do deleteItem allEdges index
     		else
     			append edges ed
     	)
     	
     	if debug do 
     	(
     		format "edges: %\n" edges
     		format "allEdges: %\n" allEdges
     	)
     	-----------------------------------------------------------------------------
     	
     	-- get the verts for each edge into the array 'edgeVerts'
     	local edgeVerts = #()
     	for ed in edges do
     	(
     		theMod.selectEdges #{ed}
     		theMod.edgeToVertSelect()
     		append edgeVerts ( (theMod.getSelectedVertices()) as array)
     	)
     	if debug do format "edgeVerts: %\nedgeVerts.count: %\n" edgeVerts edgeVerts.count
     	-----------------------------------------------------------------------------
     	
     	-- To prevent an endless loop in the next bit, the first set of verts is removed from the 'edgeVerts' array
     	-- and put into the 'orderedVerts' array.
     	local orderedVerts = #(edgeVerts[1])
     	deleteItem edgeVerts 1
     	
     	if debug do 
     	(
     		format "orderedVerts %\n" orderedVerts
     		format "edgeVerts: %\n" edgeVerts
     	)
     	
     	-- This process is to properly order the verts to prepair for the photoshop select function.
     	-- We start out with 1 element in the orderedVerts array that is itself a 2 element array of vertex indicies.
     	-- Now we need to find the next pair. One of the indicies in the next pair will be the same as the 2nd element
     	-- in the previous pair. When found, append the new pair to the orderedVerts array and delete from the edgeVerts
     	-- array to prevenet and endless loop. If the verts are 'out of order' ie. the matching index is the 2nd element
     	-- of the new pair, reverse the order of the array before appending and deleting. Exit the loop when a matching
     	-- pair has been found.
     	for o in orderedVerts do
     	(
     		notFound = true
     		for ed in edgeVerts while notFound where (index = finditem ed o[2]) > 0 do
     		(
     			if debug do format "ed: % index: % swap: %\n" ed index (if index == 1 then "No" else "Yes")
     			if index == 1 then append orderedVerts ed -- the array order is 'correct'
     			else append orderedVerts #(ed[2],ed[1]) -- switch the array order
     			deleteItem edgeVerts (finditem edgeVerts ed)
     			notFound = false
     		)
     	)
     	
     	if debug do format "orderedVerts: %\norderedVerts.count: %\n" orderedVerts orderedVerts.count
     	-----------------------------------------------------------------------------
     	
     	-- same function as your example just not using return because it's faster
     	fn fnRoundFloat fValue = if fValue >= 0.5 then (ceil fValue) else (floor fValue)
     	
     	-- define some variables for photoshop document width / heights
     	local textureWidth = 512
     	local textureHeight = 512
     	local finalVertArr = #()
     	for o in orderedVerts do
     	(
     		-- we only need to use the first array element from each of the orderedVerts elements
     		-- since we kept the doubles so that we could sort correctly
     		vertPos = theMod.getVertexPosition sliderTime o[1]
     		-- the y axis must be subtracted from 1 because in uv texture space [0,0] is the BOTTOM left
     		-- but photoshop's [0,0] is the TOP left
     		append finalVertArr [ fnRoundFloat (vertPos[1] * textureWidth), fnRoundFloat ((1 - vertPos[2]) * textureHeight) ]
     	)
     	
     	if debug do format "finalVertArr: %\n" finalVertArr
     	
     	-----------------------------------------------------------------------------
     	
     	-- create the jsx file
     	local pJsxFile = openFile "C:\\3dsUvSel.jsx" mode:"w"
     
     	format "var defaultRulerUnits = preferences.rulerUnits;\npreferences.rulerUnits = Units.PIXELS;\n\n" to:pJsxFile
     	format "var uvSelItem = Array(\n" to:pJsxFile
     	for i = 1 to finalVertArr.count do
     	(
     		format ("Array(" + (finalVertArr[i][1] as string) + ", " + (finalVertArr[i][2] as string)) to:pJsxFile
     		if i < finalVertArr.count do format ("),\n") to:pJsxFile
     	)
     	format "))\n\napp.activeDocument.selection.select(uvSelIte  m)\npreferences.rulerUnits = defaultRulerUnits;" to:pJsxFile
     
     	flush pJsxFile
     	close pJsxFile
     )