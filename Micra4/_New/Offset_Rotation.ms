Global mcOffsetRotationDialog
if mcOffsetRotationDialog != undefined do destroyDialog mcOffsetRotationDialog
rollout mcOffsetRotationDialog "Offset Rotation" width:108 height:124
(
	button 'btn_pick_src_edge' "Get Source Edge" pos:[8,20] width:92 height:28 align:#left
	button 'btn_pick_trgt_edge' "Get Target Edge" pos:[8,52] width:92 height:28 align:#left
	button 'btn_rotate_src' "Rotate Source" pos:[8,84] width:92 height:28 align:#left
	groupBox 'grp1' "Acrtions:" pos:[4,4] width:100 height:116 align:#left
	local src_obj, src_edge_index
	local trgt_obj, trgt_edge_index
	fn getSelectedEdge &obj &edge_index = (
		
		obj = selection[1]
		if classOf obj != Editable_Poly do return false
		edge_index = (polyOp.getEdgeSelection obj as array)[1]
	)
	fn rotateObjectByEdgesAngleOffset = (
		
		if 	src_edge_index == undefined or trgt_edge_index == undefined do return false
		local e1_verts = polyOp.getVertsUsingEdge src_obj src_edge_index
		local e2_verts = polyOp.getVertsUsingEdge trgt_obj trgt_edge_index
		--format "e1_verts:% e2_verts:%\n" e1_verts e2_verts
		local e1_pos = for v in e1_verts collect polyOp.getVert src_obj v
		local e2_pos = for v in e2_verts collect polyOp.getVert trgt_obj v
		--format "e1_pos:% e2_pos:%\n" e1_pos e2_pos
		local center_p = if e1_pos[1] == e2_pos[1] then e1_pos[1] else e1_pos[2]
		local src_p	=  if e1_pos[1] == center_p then e1_pos[2] else e1_pos[1]
		local trgt_p	=  if e2_pos[1] == center_p then e2_pos[2] else e2_pos[1]
		local v1 = src_p - center_p
		local v2 = trgt_p - center_p
		local offset_angle = (acos(dot (normalize v1) (normalize v2)))
		--format "v1:% v2:% offset angle:%\n" v1 v2 offset_angle
		undo "Offset Rotate" on (src_obj.rotation.z_rotation += offset_angle)
	)
	on btn_pick_src_edge pressed  do (
		getSelectedEdge &src_obj &src_edge_index
		if src_edge_index != undefined do btn_pick_src_edge.text = ("Source Edge("+src_edge_index as String+")")
	)
	on btn_pick_trgt_edge pressed  do (
		
		getSelectedEdge &trgt_obj &trgt_edge_index
		if trgt_edge_index != undefined do btn_pick_trgt_edge.text = ("Target Edge("+trgt_edge_index as String+")")
	)
	on btn_rotate_src pressed  do rotateObjectByEdgesAngleOffset()
)
createDialog mcOffsetRotationDialog