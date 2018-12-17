--------------------------------------------------------------------------

--------------------------------------------------------------------------
TheViewPoint = viewPoint
RayP = mapScreenToWorldRay viewPoint
rayInt = intersectRay HipolyModelSnp RayP	
--------------------------------------------------------------------------

--------------------------------------------------------------------------
mcAction.drawLineBetweenTwoPoints selection[1].pos selection[2].pos
vp = $.pos
p1 = $.pos
p2 = $.pos

v1 = p1 - vp
v2 = p2 - vp

--n1 = normalize v1
--n2 = normalize v2
--v1_len = distance p1 v1
--v2_len = distance p2 v1
--point pos:n1
--point pos:[0,0,0]
--v1b = vp + n1*(v1_len*2)
--v2b = vp + n2*(v2_len*2)
--point pos:v1b dir:n1
--point pos:v2b dir:n2

ray1 = ray vp v1
ray2 = ray vp v2

ir1 = intersectRay $Sphere01 ray1
ir2 = intersectRay $Sphere01 ray2

point pos:ir1.pos dir:v1
point pos:ir2.pos dir:v2
--------------------------------------------------------------------------
--ray projected on cylinder
--------------------------------------------------------------------------
mesh_obj=$Cylinder001
ring_center = $morpher_prent_001.pos
ring_tag = $morpher_tag_003.pos

tag_ray  = ray ring_center ring_tag
tag_ray  = ray  ring_tag ring_center

ray_intersect = intersectRay mesh_obj tag_ray




--------------------------------------------------------------------------
showinterface RayMeshGridIntersect.rayMeshGridIntersectOps
--------------------------------------------------------------------------
mesh_obj=$Cylinder001
ring_center = $morpher_prent_001.pos
ring_tag = $morpher_tag_003.pos

--RayMeshGridIntersect
rm = RayMeshGridIntersect()--create an instance of the Reference Target
rm.Initialize 10 --init. the voxel grid size to 10x10x10
rm.addNode mesh_obj --add the sphere to the grid
rm.intersectSphere ring_center (distance ring_center ring_tag) --<point3>center <float>radius
--rm.intersectBox ring_tag ring_center
rm.buildGrid() --build the grid data (collecting faces into the grid voxels)
theHitsCount = rm.intersectRay ring_tag (normalize (ring_center - ring_tag) )  false --<point3>p <point3>dir <boolean>doudbleSided
the_Index = rm.getClosestHit()--get the index of the closest hit by the ray
the_face = rm.getHitFace the_Index--get the face index corresponding to that indexed hit

the_ray = ray ring_tag (normalize (ring_center - ring_tag) ) 
hit_dist = rm.getHitDist the_Index --get distance from ray start
hit_pos =  (normalize the_ray.dir) * hit_dist + the_ray.pos

--Debug
point pos:hit_pos wirecolor:yellow
mesh_obj.selectedFaces = #{the_face}

ms = mesh_select() --create a mesh select modifier
addModifier mesh_obj ms --add on top of the sphere
select mesh_obj --select the sphere
max modify mode --go to modify panel
setFaceSelection mesh_obj 1 #(the_face) --set the selection in the MeshSelect
subObjectLevel = 3 --go to face selection level


rm.PrintStats()
rm.free()


--------------------------------------------------------------------------
intersectRayEx <node> <ray>
--------------------------------------------------------------------------
mesh_obj=$Cylinder001
ring_center = $morpher_prent_001.pos
ring_tag = $morpher_tag_003.pos

the_ray = ray ring_tag (normalize (ring_center - ring_tag) ) 
hit_array = intersectRayEx mesh_obj the_ray

hit_pos=(hit_array[1]).pos
hit_face=(hit_array[2])

dummy pos:hit_pos


fn getVertByHit p1 p2 mesh_obj =
(
	if classOf mesh_obj != Editable_Mesh do return false
	local the_ray = ray p1 (normalize (p2 - p1) ) 
	local hit_array = intersectRayEx mesh_obj the_ray
	local hit_pos=(hit_array[1]).pos
	local hit_face=(hit_array[2])
	if hit_face == undefined  do return false
	local face_verts =  (meshop.getVertsUsingFace mesh_obj hit_face) as array
	format "face_verts:%|n"  face_verts
	local dist = (for v in face_verts collect distance (meshOp.getVert mesh_obj v) hit_pos)
	print dist
	local min_dist  = (amin dist)
	return (face_verts[ findItem dist min_dist ])
)

vert = getVertByHit $morpher_tag_003.pos $morpher_prent_001.pos  $Cylinder001


ms = mesh_select() --create a mesh select modifier
addModifier mesh_obj ms --add on top of the sphere
select mesh_obj --select the sphere
max modify mode --go to modify panel
setVertSelection mesh_obj 1 #(vert) --set the selection in the MeshSelect
subObjectLevel = 1 --go to face selection level



