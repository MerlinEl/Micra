Global mcCloneToTriangleDialog
if mcCloneToTriangleDialog != undefined then destroyDialog mcCloneToTriangleDialog
rollout mcCloneToTriangleDialog "Clone To Triangles v0.02" width:344 height:128
(
	GroupBox 'grp1' "Parameters:" pos:[4,4] width:336 height:88 align:#left
	pickbutton 'btn_pick_instance' "Pick Instance" pos:[12,24] width:104 height:28 align:#left
	pickbutton 'btn_pick_triangles' "Pick Triangles" pos:[12,56] width:104 height:28 align:#left
	label 'lbl_inst' "undefined" pos:[120,32] width:212 height:12 align:#left
	label 'lbl_tri' "undefined" pos:[120,64] width:212 height:12 align:#left
	button 'btn_run' "Do The Magic For Tomas" pos:[8,96] width:268 height:24 align:#left
	checkbox 'chk_debug' "Debug" pos:[284,100] width:52 height:16 align:#left
	local source_obj, target_obj
	fn getEdgesData obj edges = (
		
		struct edge_data (id, verts, len, mid)	
		local e_data = #()
		for e_id in edges do (
			
			local e_verts = meshOp.getVertsUsingEdge obj e_id
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
	fn scaterToVertexNormal = (
		
		--if selection.count != 2 do return false
		--local source_obj = selection[1]
		--local target_obj = selection[2]
		if source_obj == undefined or target_obj == undefined do return false
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
			
			if chk_debug.checked do (
				
				point pos:start_pos wirecolor:red
				point pos:end_pos wirecolor:green
			)
			local points_dir = normalize (end_pos - start_pos)
			local obj_inst = instance source_obj pos:start_pos dir:points_dir
			--in coordsys local obj_inst.rotation.y_rotation -= 90
		)
		completeRedraw()
	)

	on btn_pick_instance picked obj do
	(
		if  superClassOf obj != GeometryClass  do (
				
			messageBox "Instance Object must be GeometryClass." title:"Warning"
			return false
		)
		source_obj = obj
		lbl_inst.text = obj.name
	)
	on btn_pick_triangles picked obj do
	(
		if  classOf obj != Editable_Mesh do (
				
			messageBox "Triangles Object must be Editable_Mesh." title:"Warning"
			return false
		)
		target_obj = obj	
		lbl_tri.text = obj.name	
	)
	on btn_run pressed do
		scaterToVertexNormal()
)
createDialog mcCloneToTriangleDialog