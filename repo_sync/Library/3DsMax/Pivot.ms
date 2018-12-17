fn addPointToVertSelection =
(
	local obj = selection[1]
	if classOf obj != Editable_Poly do return false
	--get Pos from Vert Selection
	local vert_sel = polyOp.getVertSelection obj as array
	if vert_sel.count < 3 do return false
	local verts_pos = for v in vert_sel collect polyOp.getVert obj v
	--get Center from Vert Selection
	local verts_center = [0,0,0]
	for p in verts_pos do verts_center += p
	verts_center = verts_center/vert_sel.count
	--get Normal from Vert Selection
	local verts_normals = #()
	for i = 1 to vert_sel.count by 3 do
	(
		local pA = verts_pos [ 1 ]
		local pB = verts_pos [ if i+1 > vert_sel.count then 1 else i+1 ]
		local pC = verts_pos [ if i+2 > vert_sel.count then 2 else i+2 ]
		local vAB=pB-pA
		local vAC=pC-pA
		verts_normals += #( cross vAB vAC )
		if i+2 > vert_sel.count do exit
	)
	local verts_normal =
	(
		if verts_normals.count == 1 
		then verts_normals[1]
		else
		(
			local n = [0,0,0]
			for i in verts_normals do n += i
			n/verts_normals.count
		)
	)
	undo "add point" on point pos:verts_center dir:verts_normal name:(uniqueName "point_center")
)
addPointToVertSelection()


(
	fn AlignPivotTo Obj Trgt =
	(
		-- Get matrix from object
		if classOf Trgt != matrix3 then Trgt = Trgt.transform
		
		-- Store child transforms
		local ChldTms = in coordSys Trgt ( for Chld in Obj.children collect Chld.transform )
		
		-- Current offset transform matrix
		local TmScale = scaleMatrix Obj.objectOffsetScale
		local TmRot = Obj.objectOffsetRot as matrix3
		local TmPos = transMatrix Obj.objectOffsetPos
		local TmOffset = TmScale * TmRot * TmPos
		
		-- New offset transform matrix
		TmOffset *= obj.transform * inverse Trgt
		
		-- Apply matrix
		Obj.transform = Trgt
		
		-- Restore offsets
		Obj.objectOffsetPos = TmOffset.translation
		Obj.objectOffsetRot = TmOffset.rotation
		Obj.objectOffsetScale = TmOffset.scale
		
		-- Restore child transforms
		for i = 1 to Obj.children.count do Obj.children[i].transform = ChldTms[i] * inverse Trgt * Obj.transform
	)
	
	-- Examples
	AlignPivotTo $Box01 $Point01
	AlignPivotTo $Box02 (matrix3 1)
)






WorldAlignPivot.rotation.y_rotation : Float --Y rotation of node


fn RotatePivotOnly obj rotation = 
( 
	local RotValInv=inverse rotation
	in coordsys local obj.rotation*=RotValInv
	obj.objectoffsetrot*=RotValInv
	obj.objectoffsetpos*=RotValInv
)
RotatePivotOnly obj p_rotation


(
fn RotatePivotToNormal obj =
	(
		local obj_normal = (polyOP.getFaceNormal obj 1)
		local p = point pos:obj.pos dir:obj_normal
		local p_rotation = p.rotation
		obj.dir              = obj_normal
		obj.objectOffsetRot *= p_rotation
		obj.objectOffsetPos *= p_rotation
		delete p
	)
	local sel = selection as array
	for i=1 to sel.count where classOf sel[i] == Editable_Poly do 
	(
		RotatePivotToNormal sel[i]
	
		local leaf = copy $leaf_01
		leaf.transform = sel[i].transform
		mc2Call.progeressbar (100.*i/sel.count)
		delete sel[i]
	)
	mc2Call.progeressbar 100 close:true
)



You will need <node>.objectOffsetPos, <node>.objectOffsetRot, <node>.objectOffsetScale, read up on it in the SDK.



--PivotMode_Toggle
(
	on execute do 
	(
		if maxops.pivotmode != #pivotonly
		then maxops.pivotmode = #pivotonly
		else maxops.pivotmode = #none

	)
)





--------------------------------
rotate $ (angleaxis 50.0 [1,1,1])



-------------------------------
 --Affect Pivot Only & Rotation...


fn RotatePivot obj x y z absolute:true =
(
-- store the object's position for later
p = obj.pos

if absolute do
(
-- store the object's rotation as an offset from the
-- identity matrix (aka zero world transform)
offsetrot = inverse (obj.rotation * inverse (matrix3 1))

-- use the stored offset to zero the pivot rotation
-- in world coords. after this step, the supplied x y z 
-- will be an absolute offset from world coords:)
obj.rotation *= offsetrot
obj.objectoffsetrot *= offsetrot
)

-- get the supplied x y z degrees as a quaternion offset.
-- the inversion changes the rotation from a right-handed 
-- coordinate system to the expected left-handed system.
-- Rotation in Maxscript sure is tricky!
rot = inverse ((eulerangles x y z) as quat)

-- finally, apply the final offset to the object's pivot.
-- Basically, we're transforming the whole object, and then
-- using .objectoffsetrot to backtransform just the object's 
-- geometry. Pretty neat, huh?
obj.rotation *= rot
obj.objectoffsetrot *= rot

-- set the object to it's original position
obj.pos = p

return ok
)

**edit** - Now that I have time, I'll insert an explanation of sorts:

An object's transformations are held in its node transform, which is represented by the local pivot. All of the vertices of an object's geometry are positioned relative to a matrix which represents an offset from the node transform. This offset matrix is called the object offset transform. Normally when you transform an object in the viewport, you are changing the node transform, and the object offset transform remains unchanged (the offset from the node transform is still the same). Naturally, the effect is that the object's geometry transforms along with the pivot.

When you do the same with "affect object only" mode turned on, though, only the object offset transform is changed. The node transform remains unchanged, with the effect that the geometry transforms while the pivot remains stationary.

Then there's the case of having "affect pivot only" mode turned on. In this case, the node transform and the object offset transform are both changing - the latter by the same magnitude as the former, but in the opposite direction. The net effect is that the pivot changes while the geometry remains stationary.

Unfortunately, Maxscript does not recognize the affect pivot only or affect object only modes - transforming an object always changes the node transform. Fortunately, Maxscript exposes the component parts of the object offset transform: the objectOffsetPos, objectOffsetRot, and objectOffsetScale. Using these properties, you can emulate the effect of the modes, which is what the above function does. 

Now that I've written all that, I hope I haven't over-explained the concept. But hey, nobody forced you to read the whole thing:p 


RH






--------------
=============






this is just a post for the benifit of any other maxscript newcomers..
i found the solution
say you want to aligh obj2's pivot to obj1's pivot
pivrot=obj1.rotation;

in coordsys local obj2.rotation*=pivrot;

obj2.objectoffsetrot*=pivrot;

obj2.objectoffsetpos*=pivrot;

good luck now!

mark tsang
---------------------------------------------


(for i in selection do (i.pivot = [i.pos.x, i.pos.y, i.min.z]))
---------------------------------------------
oldPivot = $.pivot
$.pivot = [$.pos.x, $.pos.y, $.min.z]
$.pos = [$.pos.x, $.pos.y, 0]
$.pivot = oldPivot
---------------------------------------------
Base_Pos =[$.pos.x, $.pos.y, $.min.z]
Pivot_Pos =$.pivot
---------------------------------------------


if selection.count > 0 then
	(
	undo on
	for i in selection do
		(
		local Base_Object = i.pivot.z - i.min.z
		i.pos =[i.pos.x, i.pos.y, Base_Object]
		)
	)




	fn posIn p = 
	(
		Local mini = $.min
		Local maxi = $.max
		
		case p of 
		(
			#fld: mini --Front.Left.Down
			#flu: [mini.x, mini.y, maxi.z]
			#frd: [maxi.x, mini.y, mini.z]
			#fru: [maxi.x, mini.y, maxi.z]
		
			#bru: maxi --Back.Right.Up
			#brd: [maxi.x, maxi.y, mini.z]
			#blu: [mini.x, maxi.y, maxi.z]
			#bld: [mini.x, maxi.y, mini.z]
		)	
	)

