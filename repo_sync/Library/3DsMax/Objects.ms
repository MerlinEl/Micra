function getFloorNum node = (return getUserProp node "FloorNumber")
function setFloorNum node value = (setUserProp node "FloorNumber" value)
sceneexplorermanager.addproperty "Floor Number" getFloorNum setFloorNum

 $.INode.handle
 --or 
 $.handle
 
 --related method
 maxOps.getNodeByHandle id



fn ReplaceObjectByNormal =
(
	local sel = selection as array
	for i=1 to sel.count where classOf sel[i] == Editable_Poly do 
	(
		local obj_normal = (polyOP.getFaceNormal sel[i] 1)
		local leaf = copy $leaf_01
		leaf.pos = sel[i].pos
		leaf.dir = obj_normal
		delete sel[i]
		mc2Call.progeressbar (100.*i/sel.count)
	)
	mc2Call.progeressbar 100 close:true
)

Some of the automatic collections available to you are:

    * objects -- all the objects in the scene, including lights, cameras, helpers, etc.
    * geometry -- geometry objects only
    * lights
    * cameras
    * helpers
    * shapes
    * selection -- the objects currently selected in the scene
    * selectionSets -- all the selection sets in the scene
    * meditMaterials -- all the materials in the Material Editor

targ_obj = $sphere01
obj_outside = (for i in selection where (intersects targ_obj i) == false collect i.name)

--Returns true if the bounding boxes of the two specified nodes overlap, or false if they do not overlap.
intersects <node> <node>


$.height
$.length
$.width
$.max.x
$.max.y
$.max.z
$.center.x
$.min.y
$.transform


non_hidden = for obj in Objects where obj.isHidden==false collect obj


fn hiddenobj = 
	(
	a = #()
	for i in $* do
		(
		if i.ishidden == true then append a i
		)
	qsort a name_compare_case_insensitive
	return a
	)

fn unhiddenobj = 
	(
	a = #()
	for i in $* do
		(
		if i.ishidden == false then append a i
		)
	qsort a name_compare_case_insensitive
	return a
	)
	
	
fn getObjVersion objName =
(
	local v = ""
	for i=objName.count to 1 by -1 do
	(
		if (objName[i] as integer) != undefined
		then v = objName[i]+v
		else exit
	)
	return v as integer
)

myObj =  for i in $box* where ((getObjVersion i.name) < 10.0 ) collect i
select myObj

--ID Handle
idh = $.inode.handle
maxops.getNodeByHandle idh
for i in objects do print i.inode.handle


fn ShrinkAlreadySelected FilterObj =
(
	if (FilterObj == $) then
		(return false)
		else
		(return true)
)
set_obj = selectByName title:"Select Target objects" buttontext:"Conform" filter:ShrinkAlreadySelected
if TargetObjects != undefined do