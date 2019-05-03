fn getLongestEdge obj fedges = (

	local edge_data = #(0,0)
	for edge_index in fedges do (

		local everts = polyOp.getEdgeVerts obj edge_index
		local len = distance (polyOp.getVert obj everts[1]) (polyOp.getVert obj everts[2])
		if edge_data[1] < len do (
		
			edge_data[1] = len
			edge_data[2] = edge_index
		)
	)
	edge_data[2]
)
fn removeEdges obj fedges = (	

	polyop.setEdgeSelection obj fedges
	local deadVerts = #{}
	local verts = polyop.getVertsUsingEdge obj fedges
	for v in verts do (
		
		local everts = polyOp.getVertsUsingEdge obj #{v}
		everts -= fedges
		if (everts.numberset == 2) or (everts.numberset == 0) do (append deadVerts v)
	)
	polyOp.setVertSelection obj deadVerts
	obj.remove selLevel:#edge
	obj.remove selLevel:#vertex
)
/*
fn exclude4EndEdges obj fedges = (
	
	verts_a = polyOp.getEdgeVerts $ 47
	verts_b = polyOp.getEdgeVerts $ 885
	edges_a = polyOp.getEdgesUsingVert  $ verts_a
	edges_b = polyOp.getEdgesUsingVert  $ verts_b
	edges_a.numberSet
	edges_b.numberSet	
)*/
fn optimizeRails obj = (

	if classOf obj != Editable_Poly do return false
	max modify mode
	--subobjectlevel = 4
	--get all elements
	local fcount = obj.getnumfaces()
	local all_faces = #{1..fcount}
	local all_elements = #()
	while all_faces.numberset > 0 do (
		
		--if (keyboard.escPressed) do ( throw "ESCAPE PRESSED" )
		--format "all_faces.numberset:% cnt:%\n" all_faces.numberset max_cnt
		obj.SetSelection #Face #{(all_faces as array)[1]}
		obj.selectElement()
		local fsel = polyOp.getFaceSelection obj
		append all_elements fsel
		all_faces -= fsel
	)
	--format "Elements Count:%\n" all_elements.count
	--for each object element
	--subobjectlevel = 2	
	local edges_to_remove = #{}
	for el in all_elements do (
		
		--format "\telement faces:% count:%\n" el el.numberset
		--select longest edge
		local fedges = polyop.getEdgesUsingFace obj el
		local longest_edge = getLongestEdge obj fedges
		if longest_edge == 0 do continue
		polyop.setEdgeSelection obj longest_edge
		--create ring and desetect two edges at each end
		obj.SelectEdgeRing()
		obj.setRingShift -4 false false --shring ring by 4
		obj.setRingShift 2 true false --shift ring by 2
		--select loop loop
		obj.SelectEdgeLoop()
		local ring_edges = polyOp.getEdgeSelection obj
		join edges_to_remove ring_edges
	)
	--remove edges
	--format "edges_to_remove:%\n" edges_to_remove
	undo "Optimize Rails" on removeEdges obj edges_to_remove
	completeRedraw()
	true --if all is ok return true
)
optimizeRails $