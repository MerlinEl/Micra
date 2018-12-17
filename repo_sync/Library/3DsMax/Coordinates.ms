if getRefCoordSys() == #hybrid then Toolmode.coordsys #local else Toolmode.coordsys #view


--
in coordsys $Box03.transform move $Point01 [-2,0,0]
--or
box_tm = $Box03.transform
p1_tm = $Point02.transform
$Point01.pos -= box_tm.row1 * 2
--or
tm_new = preTranslate box_tm [-2,0,0]
$Box03.transform = tm_new



fn LocalbboxOfCube node =
(
	if classof node != editable_mesh do return false
	for v=1 to 8 do
	(
		local v_pos=(in coordsys local getvert node v)* node.objecttransform
		point pos:v_pos
	) 
)
LocalbboxOfCube $


fn CalculateVolumeAndCenterOfMass obj = 
( 
	Volume= 0.0 
	Center= [0.0, 0.0, 0.0] 
	theMesh = snapshotasmesh obj
	numFaces = theMesh.numfaces 
	for i = 1 to numFaces do 
	( 
		Face= getFace theMesh i 
		vert2 = getVert theMesh Face.z 
		vert1 = getVert theMesh Face.y 
		vert0 = getVert theMesh Face.x 
		dV = Dot (Cross (vert1 - vert0) (vert2 - vert0)) vert0
		Volume+= dV 
		Center+= (vert0 + vert1 + vert2) * dV 
	) 
	delete theMesh
	Volume /= 6 
	Center /= 24 
	Center /= Volume 
	#(Volume,Center) 
)
--Call the function on a geometry object - the result will be a list 
--containing the Volume and the Center of mass in local space.
theVolAndCom = CalculateVolumeAndCenterOfMass $Sphere01
--To get the world space of the Center of Mass just like in the Utility,
--you have to do some extra work:
theComInWorld = theVolAndCom[2] * $Sphere01.objectTransform



-- Setting a node's rotation relative to world space without 
-- messing with its position:
fn setNodeWorldRotation theNode theRot = 
(
	in coordsys (transmatrix theNode.transform.pos) 
	theNode.rotation = theRot
)
setNodeWorldRotation $ (eulerangles 45 45 0)


--matrix3
transmatrix $.transform.pos --translation matrix
matrix3 0 --zero matrix
matrix3 1 --identity matrix
matrixFromNormal <point3>

<matrix3>.row1 : Point3 --rotation scale (xy?)
<matrix3>.row2 : Point3 --rotation scale (z?)
<matrix3>.row3 : Point3 --rotation scale (xy?)
<matrix3>.row4 : Point3 --pos
<matrix3>.translation : Point3

--DOES NOTHING:
$Teapot01.transform.row4 = [10.0,20.0,30.0] 
--WORKS:
myTransform = $Teapot01.transform
myTransform.row4 = [10.0,20.0,30.0] 
$Teapot01.transform = myTransform


--set obj transformation to zero
tm = $.transform * inverse $.transform
$.transform = tm

--set obj transformation to zero
tm = matrix3 0
tm = xformMat $.transform tm 
$.transform = tm


fn mcGetObjTransform type = 
(
	case type of
	(
	Px:($.pos.x)
	Py:($.pos.y)
	Pz:($.pos.z)

	Rx:($.rotation.x_rotation)
	Ry:($.rotation.y_rotation)
	Rz:($.rotation.z_rotation)

	Sx:($.scale.x*100)
	Sy:($.scale.y*100)
	Sz:($.scale.z*100)
	)
)