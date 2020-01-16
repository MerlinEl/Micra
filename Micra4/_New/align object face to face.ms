fn getVectorsAngle v1 v2 = (
	
	acos (dot (normalize v1) (normalize v2))
)
src_obj = $road_profile_013
src_face_index = 10
trgt_obj = $block_a_terrain_01_lod0
edge_index = (polyOp.getEdgeSelection trgt_obj as array)[1]
everts = polyOp.getEdgeVerts trgt_obj edge_index
verts_pos = for v in everts collect polyop.getvert trgt_obj v
p1 = verts_pos[1]
p2 = verts_pos[2]
v1 = normalize (p1 - p2)
v2 = polyOp.getFaceNormal src_obj src_face_index

a.rotation.z_rotation += 
src_obj.pos = p1





fn getVectorsAngle v1 v2 =
(
acos (dot (normalize v1) (normalize v2))
)
fn getNormalVector v1 v2 =
(
normalize (cross v1 v2)
)
fn rotateMatrix tm q =
(
x = tm.row1 * q
y = tm.row2 * q
z = tm.row3 * q
matrix3 x y z tm.pos
)

a = $road_profile_013
b = $block_a_terrain_01_lod0

a_face_index = 10
b_face_index = 1646

za = a.transform.row3
zb = polyOp.getFaceNormal a a_face_index --b.transform.row3

ang = getVectorsAngle za zb
norm = getNormalVector za zb
q = quat -ang norm -- not sure why the angle has to be negative, but it works...

a.transform = rotateMatrix a.transform q
a.pos = polyOp.getFaceCenter b b_face_index
a.rotation.x_rotation = 180


/*
subobjectLevel
 polyOp.getVertsUsingEdge


obj = $
faces = (polyOp.getFaceSelection obj) as array
face = faces[1]
theMatrix = matrixFromNormal(polyOp.getFaceNormal obj face)
theMatrix.row4 = polyOp.getFaceCenter obj face
$.transform = theMatrix


src_obj = $road_profile_013
trgt_obj = $block_a_terrain_01_lod0
src_face_index = 10
trgt_face_index = 1646

Pos= polyop.getFaceCenter src_obj src_face_index
Norm = (polyOp.getFaceNormal src_obj src_face_index)
worldUpVector = (polyOp.getFaceNormal trgt_obj trgt_face_index)
rightVector = normalize(cross worldUpVector Norm)
upVector = normalize(cross rightVector Norm)   
theMatrix = matrix3 rightVector upVector Norm Pos
src_obj.transform = theMatrix


dependsOn $ (

	faces = (polyOp.getFaceSelection obj) as array
	face = faces[1]
	Pos= polyop.getFaceCenter obj face
	Norm = (polyOp.getFaceNormal obj face)
	worldUpVector = [0,0,1]
	rightVector = normalize(cross worldUpVector Norm)
	upVector = normalize(cross rightVector Norm)   
	theMatrix = matrix3 rightVector upVector Norm Pos
)
*/