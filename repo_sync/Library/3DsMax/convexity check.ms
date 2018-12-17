fn concaveCheck = -- <> convex >< concave
(
	--get all Edgs
	fn isEPoly obj = (classOf obj == Editable_Poly)
	fn collectEdgeFaces obj =
	(
		struct OBJ_DATA (edge, faces=#())
		local data=#()
		for i=1 to obj.edges.count do
		(
			local faces = (polyop.getFacesUsingEdge obj i) as array
			if faces.count == 2 do append data (OBJ_DATA i faces)
		)   
		return data
	)
	fn isConcave obj faces edg debug:false=
	(
		local edge_verts = (polyop.getVertsUsingEdge obj edg) as array
		
		local n1= polyop.getFaceNormal obj faces[1]
		local n2= polyop.getFaceNormal obj faces[2]
		
		local a1 = polyop.getFaceCenter obj faces[1]
		local a2 = n1*10+a1
		local b1 = polyop.getFaceCenter obj faces[2]
		local b2 = n2*10+b1
		local btm_dist = distance a1 b1
		local top_dist = distance a2 b2
		
		if debug do
		(
			point pos:a1 wirecolor:yellow
			point pos:b1 wirecolor:yellow
			point pos:a2 wirecolor:red
			point pos:b2 wirecolor:red
			format "Is concave?:%\n" (btm_dist > top_dist)
		)
		btm_dist > top_dist --if is concave return true
	)
	local sel = for o in selection where isEPoly o collect o
	for o in sel do
	(
		local concave_edges = #()
		local obj_data = collectEdgeFaces o
		for d in obj_data where isConcave o d.faces d.edge debug:false do append concave_edges d.edge
		polyOp.setEdgeSelection o concave_edges	
	)	
)
concaveCheck()


p1 = $
p2 = copy p1
p2.pos.x = abs(p1.min.x - p1.max.x)*2
convertToMesh p2
faces = p2.faces
edges = p2.edges
-- turn off all visible edges
for f = 1 to p2.numfaces do
(
	setEdgeVis p2 f 1 true
	setEdgeVis p2 f 2 true 
	setEdgeVis p2 f 3 true
)
update p2
convertToPoly p2
