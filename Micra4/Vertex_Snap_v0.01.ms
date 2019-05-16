Global mcVertexSnapDialog
if mcVertexSnapDialog != undefined do destroyDialog mcVertexSnapDialog
rollout mcVertexSnapDialog "Vertex Snap" width:320 height:152
(
	local metric_type = units.SystemType as String
	pickbutton 'btn_pick_trgt' "None" pos:[96,92] width:212 height:20 align:#left
	label 'lbl5' "Target Object:" pos:[16,96] width:76 height:16 align:#left
	button 'btn_snap' "Snap" pos:[228,116] width:80 height:24 align:#left
	label 'lbl6' "Range:" pos:[16,120] width:76 height:16 align:#left
	spinner 'spn_offset' "" pos:[96,120] width:72 height:16 range:[0,100,0.1] align:#left
	label 'lbl_units' "meters" pos:[172,120] width:52 height:16 align:#left
	
	GroupBox 'grp2' "Single:" pos:[8,4] width:308 height:56 align:#left
	button 'btn_get_pos' "Get Position" pos:[16,24] width:136 height:24 align:#left
	button 'btn_set_pos' "Set Position" pos:[160,24] width:148 height:24 align:#left
	GroupBox 'grp3' "Multiple:" pos:[8,72] width:308 height:76 align:#left
			
	local target_object
	local vert_pos
	fn getClosetPos obj src_pos range = (
		
		local all_vert_list = #{1..(polyop.getNumVerts obj)}
		local closest_pos
		local smalest_dist = 9999999
		for v in all_vert_list do  (
			
			local trgt_pos = polyOp.getVert obj v
			local verts_dist = distance src_pos trgt_pos
			if verts_dist > range do continue
			if smalest_dist > verts_dist do (
				
				smalest_dist = verts_dist
				closest_pos = trgt_pos
			)
		)
		closest_pos
	)
	on btn_pick_trgt picked obj do	(
		
		if classOf obj != Editable_Poly do return false 
		target_object = obj
		btn_pick_trgt.text = obj.name
	)
	on btn_snap pressed  do (
		
		local obj = selection[1]
		if classOf obj != Editable_Poly or target_object == undefined do return false
		undo "Snap vertices" on (
			
			local vsel = polyOP.getVertSelection obj
			local failed_snap_vertices = #{}
			for v in vsel do (
			
				local vertex_pos = polyOp.getVert obj v
				local closest_pos_in_range = getClosetPos target_object vertex_pos spn_offset.value
				if closest_pos_in_range == undefined do (
					
					--format "Failed snap vertex %\n" v	
					failed_snap_vertices += #{v}
					continue
				)
				--format "Succes snap vertex:%\n" v	
				polyOp.setVert obj v closest_pos_in_range
			)
			if failed_snap_vertices.numberset > 0 then (
				
				polyOP.setVertSelection obj failed_snap_vertices 
				format "Some vertices( % / % )  was unable to snap.\n" failed_snap_vertices.numberset vsel.numberset
				
			) else (
				
				format "All vertices( % / % ) was snapped Succes.\n" vsel.numberset vsel.numberset
				polyOP.setVertSelection obj #{} 
			)
		)
	)
	on btn_get_pos pressed  do (
		
		local obj = selection[1]
		if obj == undefined do return false
		local vert = (polyop.getVertSelection obj as array)[1]
		if vert == undefined do return false
		vert_pos = polyop.getVert obj vert	
		format "vert pos:%\n" vert_pos
	)
	on btn_set_pos pressed  do (
			
		if vert_pos == undefined do return false
		local obj = selection[1]
		if obj == undefined do return false
		if subobjectLevel == 0 then ( --snap object to pos

			obj.pos = vert_pos
			
		) else ( --snap vertex to pos
			
			local vert = (polyop.getVertSelection obj as array)[1]
			if vert == undefined do return false
			undo "Snap vertex" on polyop.setVert obj vert vert_pos
		)
	)
)
createDialog mcVertexSnapDialog