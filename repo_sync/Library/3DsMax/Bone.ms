BoneSys.createBone <startPosition> <endPosition> <zAxis>
<startPosition> --The location of the new bone as point3
<endPosition> --The direction (X axis) of the bone and the bone length as point3
<zAxis>--The direction of the Z axis for the new bone node as point3


<node>.boneAutoAlign 
<node>.realignBoneToChild()
.posInParent : point3 : Read --Gets the node’s position relatively to its parent
.rotInParent : point3 : Read --Gets the node’s rotation relatively to its parent.

maxops.affectchildren = false

$Bone06.length = 10
bPos = $.pos
bRot = $.rotation
bAxi = $.dir
BoneSys.createBone bPos (bPos+10) bAxi

$.lenght


fn inceraseVersion strNum =
(
	if strNum[strNum.count] = 9
	do
	
	for i=strNum.count to 1 by -1 do
	(
		if strNum[i] = 9
	)
)

fn addVersionIn strName =
(
	local digits = "0123456789"
	local values  = "" 
	local numbers = ""
	for i=1 to strName.count do
	(
		if findString digits strName[i] == undefined
		then values += strName[i]
		else numbers += strName[i]
	)
	return #(values,numbers)	
)

fn CreateEndBone LastBone: =
(
	local EndBone = BoneSys.createBone LastBone.transform.translation (LastBone.transform.translation+6) LastBone.dir
	EndBone.transform = LastBone.transform
	in coordSys local move Endbone [LastBone.length,0,0]
	Endbone.parent = LastBone
	
	EndBone.width = LastBone.width
	EndBone.height = LastBone.height
	EndBone.taper = 90
	EndBone.length = (LastBone.width+LastBone.height)/2
	EndBone.wirecolor = color 6 134 6 --LastBone.wirecolor
	EndBone.sidefins = off
	EndBone.frontfin = off
	EndBone.backfin = off
	EndBone.name = addVersionIn LastBone.name
	return EndBone
)


---createLastBoneInFingers---createLastBoneInFingers---createLastBoneInFingers

fn addVersionIn strName =
(
	return (substring strName 1 (strName.count-1)) + "4"
)
fn CreateEndBone LastBone =
(
	local EndBone = BoneSys.createBone LastBone.transform.translation (LastBone.transform.translation+6) LastBone.dir
	EndBone.transform = LastBone.transform
	in coordSys local move Endbone [LastBone.length,0,0]
	Endbone.parent = LastBone
	
	EndBone.width = LastBone.width
	EndBone.height = LastBone.height
	EndBone.taper = 90
	EndBone.length = (LastBone.width+LastBone.height)/2
	EndBone.wirecolor = color 6 134 6
	EndBone.sidefins = off
	EndBone.frontfin = off
	EndBone.backfin = off
	EndBone.name = addVersionIn LastBone.name
	return EndBone
)
fn createLastBoneInFingers =
(
	local fingersIndex3   = 
	#(
		"RightHandIndex3" ,
		"RightHandThumb3" ,
		"RightHandMiddle3",
		"RightHandRing3"  ,
		"RightHandPinky3" ,
		"LeftHandThumb3"  ,
		"LeftHandIndex3"  ,
		"LeftHandMiddle3" ,
		"LeftHandRing3"   ,
		"LeftHandPinky3"
	)
	for i in fingersIndex3 where (local LastBone = getNodeByName i) != undefined do CreateEndBone LastBone
)



fn createBonesAlongThePath =
(
	local obj = selection[1]
	if classOf obj != SplineShape do return false
	local verts = numKnots obj 1
	local points_array = for v=1 to verts collect (getKnotPoint obj 1 v)
	local bones_array = #()
	undo "Create Bones Along Path" on
	(
		--build bones
		for i=1 to points_array.count do
		(
			local p1 = points_array[i]
			local p2 = points_array[i+1]
			if p1 != undefined and p2 != undefined do bones_array += #(BoneSys.createBone p1 p2 obj.dir)
		) 
		--link bones
		for i=bones_array.count to 1 by -1 do if i > 1 do bones_array[i].parent = bones_array[i-1] 
	)
)

---------------------
fn moveBonesToSpline =
(
	local obj = selection[1]
	if classOf obj != SplineShape do return false
	local verts = numKnots obj 1
	local points_array = for v=1 to verts collect (getKnotPoint obj 1 v)
	for i=2 to selection.count do 
	(
		selection[i].pos = points_array[i]
		if i < selection.count do selection[i].dir = normalize (points_array[i+1] - points_array[i])
	)
)

p1= (getKnotPoint $bone_path01 1 1)
p2= (getKnotPoint $bone_path01 1 2)
$.pos =  p1
dir =  normalize (p2-p1)
dir_x = dir.x
dir_y = dir.y
dir_z = dir.z

dir.z = dir_x
dir.x = dir_z
$.dir = dir

$.rotation.axis = dir
$.rotation.angle = 90

$.rotation = quat 90 $.pos
-------------------------


fn generateBonesInSpline =
(
	local sp = selection[1]
	if classOf sp != SplineShape do return false
	local verts = numKnots sp 1
	local last_bone
	for v=1 to (verts-1) do
	(
		local p1 = getKnotPoint sp 1 v
		local p2 = getKnotPoint sp 1 (v+1)
		format "p1:%\tp2:%\n" p1 p2
		local b=BoneSys.createBone p1 p2 [0,0,1]
		b.name = (uniquename "bone_")
		if last_bone != undefined do b.parent = last_bone
		last_bone = b
	)
)
generateBonesInSpline()