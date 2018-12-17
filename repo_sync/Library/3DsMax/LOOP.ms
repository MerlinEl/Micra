fn getSortedVertsFromEdgeLoop obj =
(
	--get edge selection as array
	local edges = polyOp.getEdgeSelection obj as array
	--get edge verts #(#(140, 141), #(141, 142), #(142, 143), ect...)	
	local vertPair = #()
	for i=1 to edges.count do 
	(
		vertPair += #(polyOp.getEdgeVerts obj edges[i])
	)
	--set first pair
	local sortedVerts = vertPair[1]
	deleteItem vertPair 1
	--sort rest verts
	while (vertPair.count != 0 and not keyboard.escPressed) do
	(
		for i=1 to vertPair.count do
		(
			--format "pairs:%\n" vertPair
			if vertPair[i] == undefined do continue
			if (local pos = findItem vertPair[i] sortedVerts[sortedVerts.count]) != 0 do
			(
				case pos of
				(
					1: sortedVerts += #(vertPair[i][2])
					2: sortedVerts += #(vertPair[i][1])
				)
				deleteItem vertPair i 
			)
		)
	)
	return sortedVerts
)

getSortedVertsFromEdgeLoop $

--OR

-- Pass to the function the "editable poly object" and the "edge selection"
function getChainVerts oEditPoly baEdgeSelection =
(
	-- Init Edge Selection
	local baChainEdges = baEdgeSelection
	local iNumChainEdges = baEdgeSelection.numberSet

	-- Init Vert Selection
	local baChainVerts = (polyop.getVertsUsingEdge oEditPoly baEdgeSelection)
	local baInnerVerts = copy baChainVerts

	-- Sort out if it is a closed edge loop
	if (iNumChainEdges != baChainVerts.numberSet) then
	(
		-- Get chain extreme vertices
		/*
		The for loop runs through all selected edges, gets their vertices,
		then inverts their bit value in the baInnerVerts bitArray. Each vertex
		is inverted two times [true -> false -> true], with the exception
		of the extremes, which are inverted only once [true -> false],
		taking them away from the bitArray.
		Obtain extreme vertices by subtracting baInnerVerts from all
		baChainVerts bitArray.
		*/
		for iEdge in baChainEdges do
		(
			local baEdgeVerts = (polyop.getVertsUsingEdge oEditPoly iEdge)
			for iVert in baEdgeVerts do
			(
				baInnerVerts[iVert] = not baInnerVerts[iVert]
			)
		)
		local baExtremeVerts = (baChainVerts - baInnerVerts)

		-- Choose the extreme vertex to start from to collect vertices.
		/*
		This determines the direction of the vertices chain collection, but
		since it comes from a bitArray, it's quite random.
		*/
		local iExtremeStartVert = (baExtremeVerts as Array)[1] -- or [2]
	
		-- Init array for vertices collection
		local aiSortedVerts = #(iExtremeStartVert)
		
		-- Init current vertex index
		local iCurrentVert = iExtremeStartVert
		
		-- Init bitArray of processed edges to avoid walking back in the chain
		local baCrossedEdges = #{}

		-- Collect Vertices
		for i = 1 to iNumChainEdges do
		(
			-- do one step
			local baEdgesFromVert = (polyop.getEdgesUsingVert oEditPoly iCurrentVert)
			local baStepEdge = ((baEdgesFromVert * baChainEdges) - baCrossedEdges)
			
			-- non linear chain error catching
			if (baStepEdge.numberSet == 1) then
			(
				baCrossedEdges += baStepEdge
		
				-- collect the vertex
				local iCurrentVert = (((polyop.getVertsUsingEdge oEditPoly baStepEdge) - (aiSortedVerts as BitArray)) as Array)[1]
				aiSortedVerts[i+1] = iCurrentVert				
			)
			else
			(
				aiSortedVerts = #()
				messageBox "Edge Selection is not a linear chain"
				exit
			)
		)
	)
	else
	(
		-- Choose a vertex to start the collection
		local iStartVert = (baChainVerts as Array)[1]

		-- Init array for vertices collection
		local aiSortedVerts = #(iStartVert)
		
		-- Init current vertex index
		local iCurrentVert = iStartVert
			
		-- Init bitArray of processed edges to avoid walking back in the chain
		local iStartEdge = (((polyop.getEdgesUsingVert oEditPoly iCurrentVert) * baChainEdges) as Array)[1]
		local baCrossedEdges = #{iStartEdge}

		-- Collect Vertices
		for i = 1 to (iNumChainEdges - 1) do
		(
			-- do one step
			local baEdgesFromVert = (polyop.getEdgesUsingVert oEditPoly iCurrentVert)
			local baStepEdge = ((baEdgesFromVert * baChainEdges) - baCrossedEdges)

			-- non linear chain error catching
			if (baStepEdge.numberSet == 1) then
			(
				baCrossedEdges += baStepEdge
		
				-- collect the vertex
				local iCurrentVert = (((polyop.getVertsUsingEdge oEditPoly baStepEdge) - (aiSortedVerts as BitArray)) as Array)[1]
				aiSortedVerts[i+1] = iCurrentVert
			)
			else
			(
				aiSortedVerts = #()
				messageBox "Edge Selection is not a linear chain"
				exit
			)
		)	
	)
	-- Return sorted chain vertices array  
	return aiSortedVerts
)

format "Sorted Vertices Chain -> %\n" (getChainVerts $ (polyop.getEdgeSelection $))
gc light:true