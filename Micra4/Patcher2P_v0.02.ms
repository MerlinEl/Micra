Global mcPatcher2PDialog --not used yet
if ::mcPatcher2PDialog != undefined do try(destroyDialog mcPatcher2PDialog)catch()
rollout mcPatcher2PDialog "Patcher 2P:" width:432 height:68
(
-- 	local title_msg = mcPatcher2PDialog.title
	local target_obj = undefined
	struct EDIT_MODEL (
		
		fn isValidObject obj = (classOf obj.baseObject == Editable_Poly or classOf obj.baseObject == Editable_Mesh),
		fn snapshotAasPoly obj = (
			
			local theTMesh = snapshotAsMesh obj --snapshot as TriMesh to memory
			local theNewMesh = Editable_mesh() --create an empty EMesh
			theNewMesh.mesh = theTMesh --assign TriMesh value to the EMesh
			convertTo theNewMesh Editable_Poly --collapse to EPoly
			delete theTMesh --free up memory
			theNewMesh
		),
		fn getClosestVertex obj verts pos offset = (
	
			local closest_vert
			local smalest_dist = 9999999
			for v in verts do  (
				
				local trgt_pos = polyOp.getVert obj v
				
				local verts_dist = distance pos trgt_pos
				if verts_dist > offset do continue
				if smalest_dist > verts_dist do (
					
					smalest_dist = verts_dist
					closest_vert = v
				)
			)
			closest_vert
		),
		fn getClosestEdgeTo obj edges vert_a vert_b = (
	
			local edges_arr = edges as array
			local everts_a = polyop.getVertsUsingEdge obj edges_arr[1]
			local everts_b = polyop.getVertsUsingEdge obj edges_arr[2]
			local evert_a = ((everts_a - #{vert_a}) as array)[1]
			local evert_b = ((everts_b - #{vert_a}) as array)[1]
			--get which from teo vertices is clossest to vert_b
			local vert_b_pos = polyop.getVert obj vert_b
			local evert_a_pos = polyop.getVert obj evert_a
			local evert_b_pos = polyop.getVert obj evert_b
			if distance evert_a_pos vert_b_pos < distance evert_b_pos vert_b_pos then (
				
				#(edges_arr[1], evert_a)
				
			) else (
				
				#(edges_arr[2], evert_b)
			)
		),
		fn isLastEdge obj ei vi = (
		
			local verts = (polyOp.getVertsUsingEdge obj ei)	as array	
-- 			format "\tverts:% ei:% vi:%\n" verts ei vi
			verts[1] == vi or verts[2] == vi
		),
		fn getLoopBetweenTwoVertices obj vert_a vert_b = (
			
			local border_edges = polyOp.getOpenEdges obj --get all open edges
			local next_vert = vert_a
			local next_edge = undefined
			local loop_edges = #()
			local loop_vertices = #()
			for i=1 to border_edges.count do (
				
-- 				format "next_vert:%\n" next_vert 
				local vertex_edges = polyOp.getEdgesUsingVert obj next_vert
				local two_edges = border_edges * vertex_edges
-- 				format "vertex_edges:% two_edges:%\n" vertex_edges two_edges
				local next_edge_and_vert = getClosestEdgeTo obj two_edges next_vert vert_b
-- 				format "next_edge_and_vert:%\n" next_edge_and_vert
				next_edge	= next_edge_and_vert[1]
				next_vert		= next_edge_and_vert[2]
				append loop_edges next_edge
				append loop_vertices next_vert
-- 				format "next edge:% vert:% last vetr:% is last edge:%\n" next_edge next_vert vert_b (isLastEdge obj next_edge ver_b)
				if isLastEdge obj next_edge vert_b do exit
-- 				format "loop_edges:%\n" loop_edges 	
			)
			loop_vertices
		),
		fn createSurfaceFromPoints hits_pos = (
		
			if hits_pos.count < 3 do return false
			local base_mesh = mesh vertices:hits_pos faces:#() name:(uniqueName "Polygon_Patcher_Final_Mesh")
			convertToPoly base_mesh
			local all_vert_list = #{1..(polyop.getNumVerts base_mesh)} as Array
			polyOp.createPolygon base_mesh all_vert_list
			base_mesh.pivot = (base_mesh.min + base_mesh.max) / 2
			base_mesh.wirecolor = blue
			subobjectLevel = 0
			select base_mesh
		)
	)
	local em = EDIT_MODEL()
	pickButton 'btn_trgt_obj' "Pick..." pos:[84,28] width:52 height:20 align:#left
	groupBox 'grp16' "Setup:" pos:[4,4] width:424 height:60 align:#left
	label 'lbl5' "Target Object:" pos:[8,32] width:76 height:16 align:#left
	label 'lbl_trgt_obj' "..." pos:[140,29] width:196 height:16 align:#left
	button 'btn_stitch' "STITCH" pos:[340,20] width:80 height:36 align:#left
	fn getTargetObject obj = (
	
		target_obj = obj
		lbl_trgt_obj.text = obj.name	
	)
	fn stitchSurfaces = (
		
		--validate souurce and target object
		local source_obj = selection[1]	
		if not em.isValidObject source_obj do return false
		if not em.isValidObject target_obj do return false
		--make snapshot for calculations (speed up with collapsed modifiers)
		local source_mesh	= em.snapshotAasPoly source_obj
		local target_mesh		= em.snapshotAasPoly target_obj
		hide #(source_mesh, target_mesh)
-- 		select #(source_mesh, targe_mesh)
		
		--get two vertex selection from source
		local source_vsel = polyOp.getVertSelection source_mesh
		if source_vsel.numberset != 2 do return false
		local source_vert_a = (source_vsel as array)[1]
		local source_vert_b = (source_vsel as array)[2]
		
-- 		format "verts a:% b:%\n" source_vert_a source_vert_b
		--get source border lop from vert A to vert B
		local source_vertex_loop = em.getLoopBetweenTwoVertices source_mesh source_vert_a source_vert_b
-- 		polyop.setEdgeSelection source_mesh source_border_loop
-- 		completeRedraw()
		
		
		local target_border_edges = polyOp.getOpenEdges target_mesh --get all open edges
		local target_border_verts = polyop.getVertsUsingEdge target_mesh target_border_edges --get border vertices
		local pos_a = polyop.getVert source_mesh source_vert_a
		local pos_b = polyop.getVert source_mesh source_vert_b
		local target_vert_a = em.getClosestVertex target_mesh target_border_verts pos_a 10
		local target_vert_b = em.getClosestVertex target_mesh target_border_verts pos_b 10
		--get target border lop from vert A to vert B
		local target_vertex_loop = em.getLoopBetweenTwoVertices target_mesh target_vert_b target_vert_a
-- 		polyop.setEdgeSelection target_mesh target_border_loop
-- 		completeRedraw()		
--		debug
		local border_positions = #(polyop.getVert source_mesh source_vert_a)
		for v in source_vertex_loop do append border_positions (polyop.getVert source_mesh v)
		for v in target_vertex_loop do append border_positions (polyop.getVert target_mesh v)
-- 		for i=1 to border_positions.count do te = text size:10 text:(i as String) pos:(border_positions[i])
		
		delete #(source_mesh, target_mesh)
		em.createSurfaceFromPoints border_positions
	)
	on btn_trgt_obj picked obj do getTargetObject obj
	on btn_stitch pressed  do stitchSurfaces()
)
createDialog mcPatcher2PDialog
