
selectByName [title:<string>] [buttonText:<string>] [ filter:<fn>] [showHidden:<boolean>] [single:<boolean>]

title:"string" specifies the dialog window title.
buttonText:"string" lets you specify the label text in the 'accept' button in the dialog. The default value is "Select".
filter:<fn> lets you specify a filter function that determines which objects should be displayed in the list
fn shape_filt obj = isKindOf obj Shape
single:<boolean> controls whether single or multiple objects may be selected in the selector
/*
fn polyFilt o = (superClassOf o == Editable_Poly)
-- which you could use like this:
pickObject prompt:"enter a shape" filter:polyFilt
*/
	fn isMeshOrPoly obj=(classOf obj.baseobject == Editable_Mesh or classOf obj.baseobject == Editable_Poly)
	fn findIntersectPoint mesh_obj=
	(
		local view_point_ray = mapScreentoWorldRay mouse.pos
		intersectRay mesh_obj view_point_ray
	)
	local target_mesh = pickObject message:"Pick Target Surface:" filter:isMeshOrPoly
	if isValidNode target_mesh do
	(
		local int_point = findIntersectPoint target_mesh
		if int_point != undefined then my_obj.pos = int_point.pos
	)




macroscript MoveToSurface category: "HowTo"
(
fn g_filter o = superclassof o == Geometryclass
fn find_intersection z_node node_to_z =
(
 local testRay = ray node_to_z.pos [0,0,-1]
 local nodeMaxZ = z_node.max.z
 testRay.pos.z = nodeMaxZ + 0.0001 * abs nodeMaxZ
 intersectRay z_node testRay
)
on isEnabled return selection.count > 0
on Execute do
(
 target_mesh = pickObject message:"Pick Target Surface:" filter:g_filter
 if isValidNode target_mesh then
 (
  undo "MoveToSurface" on
  (
   for i inselection do
   (
    int_point = find_intersection target_mesh i
    if int_point != undefined then i.pos = int_point.pos
   )--end i loop
  )--end undo
 )--end if
)--end execute
)--end script