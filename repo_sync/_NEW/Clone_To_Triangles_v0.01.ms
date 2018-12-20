
fn cloneInstanceObj source_obj  clones_count = 
(
	local instances = #()
	for i = 1 to clones_count do instances += #(instance source_obj)
	return instances
)
/*
fn getVertNormalPos obj vert_index = ( --thanks to phoelix
	
	local pos=(getVert obj.mesh vert_index)*obj.objectTransform
   local row1=(getNormal obj.mesh vert_index)*obj.objectTransform.rotation
   local row2=normalize (cross row1 [0,0,-1])
   local row3=normalize (cross row1 row2)
   return (matrix3 row1 row2 row3 pos)
)*/

fn getVertNormalPos obj vert_index = ( --thanks to phoelix
	
	local pos=(getVert obj.mesh vert_index)*obj.objectTransform
   local row1=(getNormal obj.mesh vert_index)*obj.objectTransform.rotation
   local row2=normalize (cross row1 [0,0, -1])
   local row3=normalize (cross row1 row2)
   return (matrix3 row1 row2 row3 pos)
)

target_obj = $
obj_verts = target_obj.GetNumVertices()

source_obj = $


undo "Instance Objects To Verts Normal" on (

	local all_instances = cloneInstanceObj source_obj obj_verts
	for index = 1 to obj_verts do(	
			
		local obj = all_instances[index]	
		local vert_pos = polyOp.getVert target_obj index
		--format "vert:% pos:%\n" index vert_pos
		obj.pos = vert_pos
		obj.dir = getVert target_obj.mesh index
		--obj.dir.z = (getVert target_obj.mesh index).x
		--local vert_normal = getVert target_obj.mesh index
		--format "vert normal:%\n" vert_normal

		--local tm = getVertNormalPos target_obj index
		--obj.transform = tm
		
		--rotate object at local
		--obj.transform = (rotateZmatrix 90) * obj.transform
		--obj.transform = (rotateYmatrix 90) * obj.transform
		--obj.transform = (rotateXmatrix -90) * obj.transform
	)
)


target_obj = $
obj_verts = getNumVerts target_obj
source_obj = $

undo "Instance Objects To Verts Normal" on (

	local all_instances = cloneInstanceObj source_obj obj_verts
	for index = 1 to obj_verts do(	
			
		local obj = all_instances[index]	
		local vert_pos = getVert target_obj index
		obj.pos = vert_pos
		obj.dir = getVert target_obj index
		/*local pos=(getVert target_obj index)*target_obj.objectTransform
		local row1=(getNormal target_obj index)*target_obj.objectTransform.rotation
		local row2=normalize (cross row1 [0,0, 0])
		local row3=normalize (cross row1 row2)
		all_instances[index].transform = matrix3 row1 row2 row3 pos*/
	)
)


/*
getNormal $ 1


vertFaces = polyOp.getFacesUsingVert $ 1 
tNormal = [0,0,0]; for i in vertFaces do tNormal += polyOp.getFaceNormal $ i
tNormal / vertFaces.numberSet

*/


(
    local sourceObj = Box()
    local obj = convertToMesh (Sphere())
    obj.selectedVerts = #{2..4}

    if isKindOf obj Editable_Mesh do
        for vert in getVertSelection obj do
            instance sourceObj transform:(translate (arbAxis (getNormal obj vert)) (getVert obj vert))
)


(--Vojtech Cada
    local source_obj = $Box125
    local target_obj = $Teapot005
    local obj_verts = getNumVerts target_obj
	for index = 1 to obj_verts do(	
		
		instance source_obj transform:(translate (arbAxis (getNormal target_obj index)) (getVert target_obj index))
	)
)


--Scater To vertex Normal
undo "Scater To vertex Normal" on (
	
    local source_obj = $Box242
    local target_obj = $Sphere001
    local obj_verts = target_obj.GetNumVertices()
	
	for index = 1 to obj_verts do(	
		
		local vert_pos = getVert target_obj.mesh index * target_obj.transform
		local vert_normal = getNormal target_obj.mesh index
		instance source_obj transform:(translate (arbAxis vert_normal) vert_pos)
	)
)

--Scater To vertex Normal
fn  scaterTovertexNormal = (
	undo "Scater To vertex Normal" on (
		
		if selection.count != 2 do return false
		local source_obj = selection[1]
		local target_obj = selection[2]
		local obj_verts = target_obj.GetNumVertices()
		
		for index = 1 to obj_verts do(	
			
			local vert_pos = getVert target_obj.mesh index * target_obj.transform
			local vert_normal = getNormal target_obj.mesh index
			
			--swap x y
			/*local axis_y = vert_normal.y
			local axis_x = vert_normal.x
			vert_normal.y = axis_x
			vert_normal.x = axis_y*/
			
			--swap z x
			/*local axis_z = vert_normal.z
			local axis_x = vert_normal.x
			vert_normal.z = axis_x
			vert_normal.x = axis_z*/
			
			--swap z y
			/*local axis_z = vert_normal.z
			local axis_y = vert_normal.y
			vert_normal.z = axis_y
			vert_normal.y = axis_z*/
			local new_obj = instance source_obj transform:(translate (arbAxis vert_normal) vert_pos) --Vojtech Cada
			--new_obj.transform = (rotateXmatrix 90) * new_obj.transform
			--new_obj.transform = (rotateYmatrix -180) * new_obj.transform
		)
	)
)



fn scaterTovertexNormal = (
	
		if selection.count != 2 do return false
		local source_obj = selection[1]
		local target_obj = selection[2]
		--target_obj.Faces
		undo "Scater To vertex Normal" on for f_id = 1 to target_obj.numFaces do (
			
			local f_verts = meshop.getVertsUsingFace target_obj f_id
			format "face:% vettices:%\n" f_id f_verts
			local verts_pos = for v_id in f_verts collect getVert target_obj v_id
			local end_pos, min_dist = 1e9
			format "verts_pos:%\n" verts_pos
			struct vedge (vert_1, vert_2)
			local edge_1 = vedge f_verts[1] f_verts[2]
			local edge_2 = vedge f_verts[2] f_verts[3]
			local edge_3 = vedge f_verts[3] f_verts[1]
			
			/*if edge_1 < min_dist then (
				
				min_dist = edge_1
				end_pos = 
			)*/
			
			
			/*if distance verts_pos[1] verts_pos[2]  < min_dist do (
				
				end_pos = p1
				min_dist = distance verts_pos[1] verts_pos[2]
			)*/
			
			/*for i = 1 to verts_pos.count do (
				
				local p1 = verts_pos[i]
				local p2 = if i == verts_pos.count then verts_pos[1] else verts_pos[i+1]
				local vert_dist = distance p1 p2 
				if vert_dist > max_dist do (
					
					end_pos = p1
					max_dist = vert_dist
				)
				format "\tvert_dist:%\n" vert_dist
			)
			local p = point pos:end_pos
		)*/
		--local all_tris = getFace
		--getVertNums
)
scaterTovertexNormal()


fn getEdgesData obj edges = (
	
	struct edge_data (id, verts, len, mid)	
	local e_data = #()
	for e_id in edges do (
		
		local e_verts = (meshOp.getVertsUsingEdge obj e_id)
		local v1_id = (e_verts as Array)[1]
		local v2_id = (e_verts as Array)[2]
		local p_1 =  getVert obj v1_id
		local p_2 =  getVert obj v2_id
		local len = distance p_1 p_2
		local mid = (p_1 + p_2)/2
		local data = edge_data e_id e_verts len mid
		e_data = append e_data data
	)
	return e_data
)
fn scaterTovertexNormal = (
	
	if selection.count != 2 do return false
	local source_obj = selection[1]
	local target_obj = selection[2]
	--target_obj.Faces
	undo "Scater To vertex Normal" on for f_id = 1 to target_obj.numFaces do (
		
		--get shortest edge (start point)
		local f_edges = meshop.getEdgesUsingFace target_obj f_id
		--format "face:% f_edges:%\n" f_id f_edges
		local e_data  = getEdgesData target_obj f_edges
		local min_len = 1e9
		local shortest_edge
		for d in e_data do (
			
			if d.len < min_len do (
				
				shortest_edge = d
				min_len = d.len
			)
		)
		local start_pos = shortest_edge.mid
		--get end point
		local f_verts = meshop.getVertsUsingFace target_obj f_id
		local last_vert = ((f_verts - shortest_edge.verts)as array)[1]
		local end_pos = getVert target_obj last_vert
		
		--point pos:start_pos wirecolor:red
		--point pos:end_pos wirecolor:green
		
		local points_dir = normalize (end_pos - start_pos)
		local obj_inst = instance source_obj pos:start_pos dir:points_dir
		in coordsys local obj_inst.rotation.y_rotation -= 90
	)
)
scaterTovertexNormal()



