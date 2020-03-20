escapeEnable = true
 fn QuickHull vertices =
 (
 	/* By johnwhile */
	/* check no-colinear and other.... */
 	if vertices.count<3 do return undefined
 	if vertices.count<4 do return mesh faces:#([1,2,3]) vertices:vertices
 	/*  inizialize double triangle  */
 	faceDouble = #([1,2,3],[3,2,1])
 	qhull = mesh faces:faceDouble vertices:vertices
 	convertTo qhull Editable_Poly --meshop.createPolygon have a bug, it duplicate edges
 
 	local vmark = #{4..vertices.count}
 	with undo off
 	with redraw off 
 	for iv in vmark do
 	(
 		if getProgressCancel() do return undefined
 		--format "* process vertex % *\n" iv
 		vmark[iv] = FALSE
 		local vp = vertices[iv]
 		local visibleFaces = #{}
 		for iif=1 to qhull.numfaces do
 		(
 			local face = getFace qhull.mesh iif
 			local a = vertices[face.x] - vp
 			local b = vertices[face.y] - vp
 			local c = vertices[face.z] - vp
 			/* get volume size */
 			visibleFaces[iif] = (a.x * (b.y*c.z - b.z*c.y) + a.y * (b.z*c.x - b.x*c.z) + a.z * (b.x*c.y - b.y*c.x))<0.5
 		)
 		--format ">> found % visible faces\n" visibleFaces.numberset
 		if visibleFaces.count>0 then
 		(
 			/* delete the face what "look" the vertex iv, but preserve isoverts to don't change internal index */
 			polyop.deleteFaces qhull visibleFaces delIsoVerts:false
 			BorderEdges = polyop.getOpenEdges qhull
 			newFaceArr = for ie in BorderEdges collect
 			(
 				/* obtein true oriented face very important , the algorithm don't converge into convex if some face are wrong oriented */
 				local adjface = polyop.getFacesUsingEdge qhull #{ie} as array
 				local face = getFace qhull.mesh adjface[1]
 				/* insert new vertex */
 				edgeverts = polyop.getVertsUsingEdge qhull #{ie}
 				local i=1 ; while i<3 and edgeverts[face[i]] do i+=1 ; face[i] = iv
 				/* invert orientation */
 				swap face.x face.z
 				#(face.x , face.y , face.z)
 			)
 			for newface in newFaceArr do polyop.createPolygon qhull newface
 			--format ">> build % faces\n" newFaceArr.count
 		)
 	)
 	update qhull
 	qhull
 )
 
 (
 delete objects
 clearListener()
 vertices = for i=1 to 50 collect random [-10,-10,-10] [10,10,10]
 st = timestamp()
 qhullMesh = QuickHull vertices
 format "> QuickHull complete in % ms for % vertices\n" (timestamp()-st) vertices.count
 qhullMesh.vertexticks = true
 )