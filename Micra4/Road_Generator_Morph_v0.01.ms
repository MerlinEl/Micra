--Transform road to different type (outside of citty) 
fn getFacesById obj faces_arr faces_id = (

	for face_index in faces_arr where polyOp.getFaceMatID obj face_index == faces_id collect face_index
)
fn getEdgeLength obj edge_index = (

	local everts = polyOp.getEdgeVerts obj edge_index
	distance (polyOp.getVert obj everts[1]) (polyOp.getVert obj everts[2])
)
fn getShortestEdge obj edges_arr = (

	local shortest_edge_index = (edges_arr as array)[1]
	local shortest_edge_len = getEdgeLength obj shortest_edge_index
	
	for e_index in edges_arr do (

		local len = getEdgeLength obj e_index
		if shortest_edge_len > len do (
		
			shortest_edge_len = len
			shortest_edge_index = e_index
		)
	)
	shortest_edge_index
)
fn getLongestEdge obj edges_arr = (

	local longest_edge_index = (edges_arr as array)[1]
	local longest_edge_len = getEdgeLength obj longest_edge_index
	
	for e_index in edges_arr do (

		local len = getEdgeLength obj e_index
		if longest_edge_len < len do (
		
			longest_edge_len = len
			longest_edge_index = e_index
		)
	)
	longest_edge_index
)
fn getBigestFaceById obj faces_arr faces_id:-1 = (

	if faces_id != -1 do (

		faces_arr =	getFacesById obj faces_arr faces_id
	)
	local bigest_face_index = 1
	local bigest_face_area = polyOp.getFaceArea obj bigest_face_index
	
	for f_index in faces_arr do (

		local face_area = polyOp.getFaceArea obj f_index
		if bigest_face_area < face_area do (
		
			bigest_face_area = face_area
			bigest_face_index = f_index
		)
	)
	bigest_face_index
)
fn getSimilarEdges obj edges_arr edge_index offset:0.1 = (
	
	local shortest_edge_len = getEdgeLength obj edge_index
	local similar_edges = #{edge_index}
	for e_index in edges_arr do (

		local len = getEdgeLength obj e_index
		if shortest_edge_len + offset >= len do (

			similar_edges += #{e_index}
		)
	)
	similar_edges
)
fn replaceMatID obj src_id trgt_id = (
	
	local all_faces = #{1..(polyop.getNumFaces obj)}
	for f in all_faces where polyOp.getFaceMatID obj f == src_id do polyOp.setFaceMatID obj f trgt_id
)


obj = $
elevation_asphalt = 10
elevation_center = 16
asphalt_id = 5
pavement_id = 8
undo "Morph Road" on (
	
	convertToPoly obj
	
	max modify mode
	subObjectLevel = 4
	--get shortest edge
	all_edges = #{1..(polyop.getNumEdges obj)}
	shortest_edge_index = getShortestEdge obj all_edges
	--select all edges with shortest edge length +- offset
	tiny_edges = getSimilarEdges obj all_edges shortest_edge_index offset:0.5
	polyOp.setEdgeSelection obj tiny_edges
	subObjectLevel = 2
	--select loop +- 1
	obj.setLoopShift -1 false true
	obj.setLoopShift 1 false true
	--select ring
	obj.SelectEdgeRing()
	--collapse edges
	obj.collapse #Edge
	--find two pavement faces
	all_faces = #{1..(polyop.getNumFaces obj)} 
	big_pavement_face_a = getBigestFaceById obj all_faces faces_id:asphalt_id
	--get both pavement faces
	longest_edge = getLongestEdge obj (polyOp.getEdgesUsingFace obj big_pavement_face_a)
	polyOp.setEdgeSelection obj longest_edge
	obj.SelectEdgeRing()
	edges_faces = polyOp.getFacesUsingEdge obj (polyOp.getEdgeSelection obj)
	two_asphalt_faces = getFacesById obj edges_faces asphalt_id
	polyOp.setFaceSelection obj two_asphalt_faces
	--get shortest edges from faces
	--FIX IT
	/*
-- 	alternative
	shortest_edge_1 = getShortestEdge obj (polyOp.getEdgesUsingFace obj 5
	shortest_edge_2 = getShortestEdge obj (polyOp.getEdgesUsingFace obj 4
	
	*/
	
	
	shortest_edge_1 = getShortestEdge obj (polyOp.getEdgesUsingFace obj two_asphalt_faces[1])
	shortest_edge_2 = getShortestEdge obj (polyOp.getEdgesUsingFace obj two_asphalt_faces[2])
	
	--for both edges make ring and split it at 70%
	obj.connectEdgeSegments = 1
	obj.connectEdgePinch = 0
	--first
	polyOp.setEdgeSelection obj shortest_edge_1
	obj.SelectEdgeRing()
	obj.connectEdgeSlide = -70
	obj.ConnectEdges ()
	--second
	polyOp.setEdgeSelection obj shortest_edge_2
	obj.SelectEdgeRing()
	obj.connectEdgeSlide = 70
	obj.ConnectEdges ()
	
	 --move the asphalt edge little bit up
	 all_faces = #{1..(polyop.getNumFaces obj)} 
	 asphalt_faces = getFacesById obj all_faces asphalt_id
	subObjectLevel = 4
	polyOp.setFaceSelection obj asphalt_faces
	obj.EditablePoly.ShrinkSelection ()
	move obj.selectedFaces [0,0,elevation_asphalt]
	
	--move center edge up
	subobjectLevel = 2
	obj.ConvertSelection #Face #Edge
	obj.ShrinkSelection ()
	move obj.selectedEdges [0,0,elevation_center]
	
	--slice sides 3 -18 -96
	
	--end 
	subobjectLevel = 0
	replaceMatID obj 8 11
)

/*
$.connectEdgeSegments = 3
$.connectEdgePinch = 18
$.connectEdgeSlide = -96
$.EditablePoly.ConnectEdges ()



$.connectEdgeSegments = 3
$.connectEdgePinch = -18
$.connectEdgeSlide = 96
$.EditablePoly.ConnectEdges ()

$.connectEdgeSegments = 3
$.connectEdgePinch = -18
$.connectEdgeSlide = -96
$.EditablePoly.ConnectEdges ()



modPanel.addModToSelection (VertexPaint ()) ui:on
*/

completeRedraw()

