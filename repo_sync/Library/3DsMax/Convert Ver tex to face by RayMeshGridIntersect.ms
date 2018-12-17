(
	fn getFVerts mesh poly faces = --convert "mesh faces to verts" and "verts to poly faces"
	(
		if faces.count == 0 do return #()
		local meshVerts = meshop.getVertsUsingFace mesh faces
		local polyFaces = polyOp.getFacesUsingVert poly meshVerts
		return polyFaces
	)
	
	local polyObj = selection[1]
	if polyObj != undefined and classOf polyObj == Editable_Poly do
	( 
		local meshFaces = #() --init. an array to collect face selection
		
		rm = RayMeshGridIntersect() --create an instance of the Reference Target 
		rm.Initialize 10 --init. the voxel grid size to 10x10x10
		rm.addNode polyObj --add the Editable_Poly to the grid
		rm.buildGrid() --build 
		
		local theGSMesh = snapshotasmesh polyObj --grab the TriMesh of the Editable_Poly
		--local theGSMesh = snapshot polyObj
		
		local vSel = polyOp.getVertSelection polyObj
		for v in vSel do --go through all verts of the Editable_Poly
		(
			local thePos = meshop.getVert theGSMesh v --get the position of the vertex
			local theNormal = -(getNormal theGSMesh v) --get the normal of the vertex, reverse direction
			local theHitsCount = rm.intersectRay thePos theNormal false 
			
			if theHitsCount > 0 then --if have hit anything...
			(
				local theIndex = rm.getClosestHit() --get the index of the closest hit by the ray
				local theFace = rm.getHitFace theIndex --get the face index corresponding to that indexed hit
				append meshFaces theFace --add to the face array to select the 
			)
			else (format "The Ray % Missed\n" v)
		)
		--format "Mesh Face Array:%\n" meshFaces
		local polyFaces = getFVerts theGSMesh polyObj meshFaces
		polyOp.setFaceselection polyObj polyFaces
	)
)

/*
--try() delete theGSMesh catch ()
--setFaceSelection theGSMesh meshFaces
setFace <mesh> <face_index_integer> <vert_indices_point3> --Sets the face vertex indexes for the indexed face from a point3.
*/
