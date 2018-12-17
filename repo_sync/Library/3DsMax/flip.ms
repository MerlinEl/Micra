
fn mirrorSelectedFaces =
(
	local obj = selection[1]
	if classOf obj != Editable_Poly do return false
	local fsel = polyOp.getFaceSelection obj
	local vsel = polyOp.getVertsUsingFace obj fsel
	local vpos = [0,0,0]
	--get face selection center 
	for v in vsel do ( vpos += polyOp.getVert obj v )
	local sel_center = vpos/vsel.numberset
	--mirror verts in face selection center
	for v in vsel do
	(
		local IPos = polyOp.getvert obj v
		IPos[1] = sel_center.x - (IPos[1] - sel_center.x)
		polyOp.setvert obj v IPos 
	)
	polyOp.flipNormals obj fsel
	update obj 
)

fn mirrorFaces =
(
	local obj = selection[1]
	if classOf obj != Editable_Poly do return false
	for i=1 to obj.numverts do
	(
		local IPos = polyOp.getvert obj i
		IPos[1] = obj.position.x - (IPos[1] - obj.position.x)
		polyOp.setvert obj i IPos 
	)
	polyOp.flipNormals obj obj.faces
	update obj 
)

fn mirrorObjects axis =
(
	local sel = selection as array
	if sel.count == 0 do return false
	for o in sel do
	(
		local opos = o.pos
		o.transform *= case axis of
		(
			#X:(matrix3 [-1,0,0] [0,1,0] [0,0,1] [0,0,0])
			#Y:(matrix3 [1,0,0] [0,-1,0] [0,0,1] [0,0,0])
			#Z:(matrix3 [1,0,0] [0,1,0] [0,0,-1] [0,0,0])
		)
		o.pos = opos
	)
)

fn rotateObjects axis =
(
	local sel = selection as array
	if sel.count == 0 do return false
	for o in sel do
	(
		local opos = o.pos
		o.rotation *= case axis of
		(
			#X:(quat 90 [1,0,0])
			#Y:(quat 90 [0,1,0])
			#Z:(quat 90 [0,0,1])
		)
		o.pos = opos
	)
)

/*
mirrorObjects #x
mirrorObjects #y
mirrorObjects #z

rotateObjects #x
rotateObjects #y
rotateObjects #z
*/

--rotate object 90 along y axis
--(matrix3 [0,0,-1] [0,1,0] [-1,0,0] [0,0,0])