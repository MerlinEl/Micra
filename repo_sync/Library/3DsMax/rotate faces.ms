fn rotatePolygon obj axis val =
(
	local fsel = polyOp.getFaceSelection obj
	local vsel = polyOp.getVertsUsingFace obj fsel

	--get face selection center 
	local vpos = [0,0,0]
	for v in vsel do ( vpos += polyOp.getVert obj v )
	local center = vpos/vsel.numberset
	
	--rotate faces along axis
	for v in vsel do
	(
		local vpos = polyOp.getVert obj v
		local v1 = vpos - center
		local v2 = v1 * 
		(
			case axis of
			(
				#X:(quat val [1,0,0])
				#Y:(quat val [0,1,0])
				#Z:(quat val [0,0,1])
			)
		)
		local v3 = v2 + center
		polyOp.setVert obj v v3
	)
)
rotatePolygon $ #z 90







(
 angle = 45  --the angle to rotate at
 selected_faces = (polyOp.getFaceSelection $) as array  --the selected polygons
 center_face = polyOp.getFaceCenter $ selected_faces[1]  --the center of the first polygon
 transform_mat = matrixFromNormal (polyOp.getFaceNormal $ selected_faces[1]) --create a matrix using the normal
 transform_mat.row4 = center_face --move matrix to center of polygon
 face_vertices = (polyOp.getVertsUsingFace $ selected_faces[1]) as array --get the verts of polygon 1
 for v in face_vertices do  --for every vertex in the first polygon,
 (
 in coordsys transform_mat vertex_position = (polyOp.getVert $ v)  --get vertex in the matix coordinates
 RotateZ = (rotateZMatrix angle) * transform_mat -- create a Rotation matrix, transform in the space of the Normal's matrix
 polyOp.setVert $ v (vertex_position * RotateZ) --transform the vertex using the new matrix
 )
 )




fn rotateface rx ry rz selected_faces =
(
	for f=1 to selected_faces.count do  --for every face
	(
		center_face = polyOp.getFaceCenter $ selected_faces[f]  --the center of the first polygon
		transform_mat = matrixFromNormal (polyOp.getFaceNormal $ selected_faces[f]) --create a matrix using the normal
		transform_mat.row4 = center_face --move matrix to center of polygon
		face_vertices = (polyOp.getVertsUsingFace $ selected_faces[f]) as array --get the verts of polygon 1
		for v in face_vertices do  --for every vertex in the first polygon,
		(
			in coordsys transform_mat vertex_position = (polyOp.getVert $ v)  --get vertex in the matix coordinates
			RotateXYZ = (rotateYPRMatrix rx ry rz) * transform_mat -- create a Rotation matrix, transform in the space of the Normal's matrix
			polyOp.setVert $ v (vertex_position * RotateXYZ) --transform the vertex using the new matrix
		)--for v
	)--for f
)--fn rotateface



--main body
(
	selfaces = (polyOp.getFaceSelection $) as array  --the selected polygons
	rotateface 0 0 90 selfaces
)
 
 
 
 
 --world
 (
angle = 45 
vertsToMove = $.selectedVerts

selCenter = [0,0,0]
for v in vertsToMove do selCenter += polyop.getvert $ v.index
selCenter /= vertsToMove.count

transform_mat = transMatrix selCenter
rot_mat = (rotateZMatrix angle) * transform_mat 

for v in vertsToMove do 
(
	in coordsys transform_mat vertex_position = (polyop.getVert $ v.index) 
	polyop.setVert $ v.index (vertex_position * rot_mat ) 
)
)

--local
(
angle = 45 
vertsToMove = $.selectedVerts

selCenter = [0,0,0]
for v in vertsToMove do selCenter += polyop.getvert $ v.index
selCenter /= vertsToMove.count

transform_mat = $.transform --get the node's TM 
transform_mat.row4 = selCenter  --move the TM to the sel.center. Orientation of local Z remains the same!
rot_mat = (rotateZMatrix angle) * transform_mat  --rotation matrix is now in local coords!

for v in vertsToMove do 
(
	in coordsys transform_mat vertex_position = (polyop.getVert $ v.index) 
	polyop.setVert $ v.index (vertex_position * rot_mat ) 
)
)
