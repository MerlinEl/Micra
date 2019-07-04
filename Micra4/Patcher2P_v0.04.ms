Global mcPatcher2PDialog --not used yet
if ::mcPatcher2PDialog != undefined do try(destroyDialog mcPatcher2PDialog)catch()
rollout mcPatcher2PDialog "" width:348 height:140
(
	local form_title = "Patcher 2P:"
	local metric_type = units.SystemType as String
	local target_obj = undefined
	pickbutton 'btn_trgt_obj' "Pick..." pos:[84,22] width:52 height:20 align:#left
	GroupBox 'grp16' "Setup:" pos:[4,4] width:340 height:132 align:#left
	label 'lbl5' "Target Object:" pos:[8,26] width:76 height:16 align:#left
	label 'lbl_trgt_obj' "..." pos:[140,23] width:196 height:16 align:#left
	button 'btn_stitch' "STITCH" pos:[8,96] width:328 height:36 align:#left
	label 'lbl3' "Jionts Offset:" pos:[8,52] width:76 height:16 align:#left
	label 'lbl_units' "units..." pos:[156,51] width:180 height:16 align:#left
	spinner 'spn_offset' "" pos:[84,50] width:68 height:16 range:[0,100,40] type:#float scale:0.1 align:#left
	checkbox 'chk_attach' "Attach" pos:[12,76] width:64 height:16 checked:true align:#left
	checkbox 'chk_weld' "Weld" pos:[80,76] width:68 height:16 checked:true align:#left
	checkbox 'chk_triangulate' "Triangulate" pos:[152,76] width:76 height:16 checked:true align:#left
	struct EDIT_MODEL (
		
		fn isValidObject obj = (

			obj != undefined and classOf obj.baseObject == Editable_Poly -- or classOf obj.baseObject == Editable_Mesh
		),
		fn isValidSelection obj = (
			
			(polyop.getVertSelection obj).numberset == 2
		),
		fn snapshotAsPoly obj obj_name = (
			
			local theTMesh = snapshotAsMesh obj --snapshot as TriMesh to memory
			local theNewMesh = Editable_mesh() --create an empty EMesh
			theNewMesh.mesh = theTMesh --assign TriMesh value to the EMesh
			convertTo theNewMesh Editable_Poly --collapse to EPoly
			delete theTMesh --free up memory
			theNewMesh.name = obj_name
			theNewMesh
		),
		fn unifyNormals obj = (
			
			if obj.numFaces == 0 do return false
			local first_polygon_normal = polyOp.getFaceNormal obj 1
			if first_polygon_normal.z < 0 do (
				
				addModifier obj (Normalmodifier flip:true)
				collapseStack obj
			)
-- 			converttoMesh obj
-- 			meshOp.unifyNormals obj #all	
-- 			convertTopoly obj
		),
		fn getVertsPositions obj verts = (
			
			for v in verts collect polyOp.getVert obj v
		),
		fn getClosestVertex obj verts pos maxRange:undefined = (
	
			local closest_vert  = (verts as array)[1]
			local smalest_dist = distance pos (polyOp.getVert obj closest_vert) --get first vertex distance
			for v in verts do  (
				
				local trgt_pos = polyOp.getVert obj v
				local verts_dist = distance pos trgt_pos
				if maxRange != undefined and maxRange < verts_dist do continue
				if smalest_dist > verts_dist do (
					
					smalest_dist = verts_dist
					closest_vert = v
				)
			)
			closest_vert
		),
		fn getClosestEdge obj edges vert_a vert_b = (
	
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
		fn triangulate obj top_positions = (
			
			if top_positions.count != 0 then (
				
				local border_edges = polyOp.getOpenEdges obj --get all open edges
				local source_verts = polyop.getVertsUsingEdge obj border_edges
				local target_verts = #{}
				for pos in top_positions do (
				
					local vert_index = getClosestVertex obj source_verts pos maxRange:4
					if vert_index == undefined do continue
					target_verts += #{vert_index}
				)
				if target_verts.numberset == 0 do return false
				source_verts -= target_verts --remove top verts from loop
-- 				format "triangulate obj:%\n\tsource_verts:%\n\ttarget_verts:%\n" obj.name source_verts target_verts
				for v in source_verts do (
			
					local vpos = polyOp.getVert obj v
					local vert_index = getClosestVertex obj target_verts vpos
-- 					format "\t\tconnecting vertA:% vetrB:%\n" vert_index v
					if vert_index == undefined do continue
					polyop.setVertSelection obj #{vert_index, v}
					obj.ConnectVertices()
				)
			) else (
				
				convertTo obj Editable_Patch
				convertTopoly obj
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
				local next_edge_and_vert = getClosestEdge obj two_edges next_vert vert_b
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
			base_mesh
		),
		fn attachObject obj_base obj_new = (
		
-- 			format "attachObject base:% new:%\n" obj_base obj_new
-- 			modPanel.setCurrentObject obj_base.baseObject
			polyOp.attach obj_base obj_new
		),
		fn weldVertices obj offset:0.01 = (
			
-- 			format "weldVertices obj:% offset:%\n" obj offset
-- 			modPanel.setCurrentObject obj_base.baseObject
			local all_vert_list = #{1..(polyop.getNumVerts obj)}
			obj.weldThreshold = offset
			polyop.weldVertsByThreshold obj all_vert_list --weld all vertices
		),
		fn cleanSnapshots objs = (
			
			with undo off ( delete objs )	
		)
	)
	local em = EDIT_MODEL()
	fn getTargetObject obj = (
		
		target_obj = obj
		lbl_trgt_obj.text = obj.name	
	)
	fn stitchSurfaces = (
		
		--validate souurce and target object
		local source_obj = selection[1]	
		if not em.isValidObject source_obj do return false
		if not em.isValidObject target_obj do return false
		if not em.isValidSelection source_obj do return false 
		--make snapshot for calculations (speed up with collapsed modifiers)
		local source_mesh, target_mesh
		with undo off (
			
			source_mesh	= em.snapshotAsPoly source_obj (uniqueName "Patcher_2P_Temp_Mesh")
			target_mesh	= em.snapshotAsPoly target_obj (uniqueName "Patcher_2P_Temp_Mesh")
			source_mesh.wirecolor = target_mesh.wirecolor = orange
			modPanel.setCurrentObject source_obj.baseObject --return back to base object
		)
-- 		hide #(source_mesh, target_mesh)
-- 		select #(source_mesh, targe_mesh)
		
		--get two vertex selection from source
		local source_vsel = polyOp.getVertSelection source_mesh
		if source_vsel.numberset != 2 do return false
		local source_vert_a = (source_vsel as array)[1]
		local source_vert_b = (source_vsel as array)[2]
-- if source_vert_a == undefined or source_vert_b == undefined do ( 
-- 	
-- 		em.cleanSnapshots #(source_mesh, target_mesh)
-- 		format "Operation was aborted. Unable get all data >\n\tsource_vert_a:%\n\tsource_vert_b:%\n" source_vert_a source_vert_b
-- 		return false
-- )
-- 		format "verts a:% b:%\n" source_vert_a source_vert_b
		--get source border lop from vert A to vert B
		local source_vertex_loop = em.getLoopBetweenTwoVertices source_mesh source_vert_a source_vert_b
-- 		polyop.setEdgeSelection source_mesh source_border_loop
-- 		completeRedraw()
		
		
		local target_border_edges = polyOp.getOpenEdges target_mesh --get all open edges
		local target_border_verts = polyop.getVertsUsingEdge target_mesh target_border_edges --get border vertices
		local pos_a = polyop.getVert source_mesh source_vert_a
		local pos_b = polyop.getVert source_mesh source_vert_b
		local target_vert_a = em.getClosestVertex target_mesh target_border_verts pos_a maxRange:spn_offset.value
		local target_vert_b = em.getClosestVertex target_mesh target_border_verts pos_b maxRange:spn_offset.value
if target_vert_a == undefined or target_vert_b == undefined do ( --when one of two target vertices not found (too far)
	
		em.cleanSnapshots #(source_mesh, target_mesh)
		format "Operation was aborted. Unable get target joints. Is too far >\n\target_vert_a:%\n\ttarget_vert_b:%\n" target_vert_a target_vert_b
		return false
)
		--get target border lop from vert A to vert B
		local target_vertex_loop = em.getLoopBetweenTwoVertices target_mesh target_vert_b target_vert_a
-- 		polyop.setEdgeSelection target_mesh target_border_loop
-- 		completeRedraw()		
--		debug
		local border_positions = #(polyop.getVert source_mesh source_vert_a)
		for v in source_vertex_loop do append border_positions (polyop.getVert source_mesh v)
		for v in target_vertex_loop do append border_positions (polyop.getVert target_mesh v)
-- 		for i=1 to border_positions.count do te = text size:10 text:(i as String) pos:(border_positions[i])
		
		em.cleanSnapshots #(source_mesh, target_mesh)
		undo "Create Patch 2P" on ( 
			
			local new_surface = em.createSurfaceFromPoints border_positions 
			em.unifyNormals new_surface
			if chk_triangulate.checked do (
				
				local mid_verts = ((source_vertex_loop as bitarray) - #{source_vert_a}) - #{source_vert_b}
				local tirangulate_top_positions = em.getVertsPositions source_obj mid_verts
				em.triangulate new_surface tirangulate_top_positions
			)
			if chk_attach.checked do em.attachObject source_obj new_surface
			if chk_weld.checked   do em.weldVertices source_obj
		)
	)
	fn init = (
		
		lbl_units.text = metric_type
		mcPatcher2PDialog.title = form_title
	)
	on btn_trgt_obj picked obj do getTargetObject obj
	on btn_stitch pressed  do stitchSurfaces()
	on  mcPatcher2PDialog open do (init())
)
createDialog mcPatcher2PDialog
