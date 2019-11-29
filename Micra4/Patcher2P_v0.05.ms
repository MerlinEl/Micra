Global mcPatcher2PDialog
if ::mcPatcher2PDialog != undefined do try(destroyDialog mcPatcher2PDialog)catch()
rollout mcPatcher2PDialog "" width:348 height:156
(
	local form_title = "Patcher 2P:"
	local metric_type = units.SystemType as String
	local target_obj = undefined
	pickbutton 'btn_trgt_obj' "Pick..." pos:[84,22] width:52 height:20 align:#left
	GroupBox 'grp16' "Setup:" pos:[4,4] width:340 height:148 align:#left
	label 'lbl5' "Target Object:" pos:[8,26] width:76 height:16 align:#left
	label 'lbl_trgt_obj' "..." pos:[140,23] width:196 height:16 align:#left
	button 'btn_stitch' "STITCH" pos:[216,72] width:120 height:72 align:#left
	label 'lbl3' "Jionts Offset:" pos:[8,52] width:76 height:16 align:#left
	label 'lbl_units' "units..." pos:[156,51] width:180 height:16 align:#left
	spinner 'spn_offset' "" pos:[84,50] width:68 height:16 range:[0,100,40] type:#float scale:0.1 align:#left
	checkbox 'chk_attach' "Attach" pos:[12,92] width:64 height:16 checked:true align:#left
	checkbox 'chk_weld' "Weld" pos:[12,112] width:44 height:16 checked:true align:#left
	checkbox 'chk_triangulate' "Triangulate" pos:[12,72] width:76 height:16 checked:true align:#left
	label 'lbl_weld' "Treshold:" pos:[70,113] width:48 height:16 align:#left
	spinner 'spn_weld_offset' "" pos:[116,112] width:64 height:16 range:[0,100,0.01] type:#float scale:0.1 align:#left
	checkbox 'chk_automap' "Automap" pos:[12,132] width:60 height:16 checked:true align:#left
struct EDIT_MODEL (
		
		fn isValidObject obj modPoly:false = (

			local is_poly_obj = obj != undefined and classOf obj.baseObject == Editable_Poly
			if modPoly then (
			
				classOf obj == PolyMeshObject or is_poly_obj
				
			) else (
			
				is_poly_obj
			)
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
-- 				format "vert:% dist:%\n" v verts_dist
				if smalest_dist > verts_dist do (
					
					smalest_dist = verts_dist
					closest_vert = v
				)
			)
			if maxRange != undefined and maxRange < smalest_dist do return undefined
			closest_vert
		),
		fn getNextVert obj vert_a edge_a = (
		
			local everts = polyOp.getVertsUsingEdge obj edge_a
			everts -= #{vert_a} --remove first vert (remains second far from vert_a)
			(everts as array)[1] --return vert_b
		),
		fn getEdgeVector obj vert_a edge_a = (
		
			local vert_b = getNextVert obj vert_a edge_a
			local p1 = polyop.getVert obj vert_a
			local p2 = polyop.getVert obj vert_b
			p2 - p1
		),
		fn getVectorsAngle v1 v2 = ( acos(dot (normalize v1) (normalize v2))),
		fn getFirstEdge obj edges vert_a vert_b = (
		
			--vector AB
			local vert_a_pos = polyop.getVert obj vert_a
			local vert_b_pos = polyop.getVert obj vert_b
			local v1 = vert_b_pos - vert_a_pos
			
			--get two border vert edges
			local vedges = polyOp.getEdgesUsingVert obj vert_a
			vedges =  edges * vedges  --remain only two border edges
			--compare angle of each edge
			vedges = vedges as array
			local v2 = getEdgeVector obj vert_a vedges[1] 
			local v3 = getEdgeVector obj vert_a vedges[2] 
			local a1 = getVectorsAngle v1 v2
			local a2 = getVectorsAngle v1 v3
			--return edge with smalest angle
			if a1 < a2 then (
			
				format "last two edges:% final edge:%\n" vedges vedges[1]
				#(vedges[1], getNextVert obj vert_a vedges[1]) 
				
			)else (
			
				format "last two edges:% final edge:%\n" vedges vedges[2]
				#(vedges[2], getNextVert obj vert_a vedges[2])
			)
		),
		fn getNextEdge obj edge_a vert_a edges = (
		
			local vedges = polyOp.getEdgesUsingVert obj vert_a
			vedges *= edges --remain only two border edges
			local edge_b = ((vedges - #{edge_a}) as array)[1] --remove edge_a
			local vert_b = getNextVert obj vert_a edge_b
			#( edge_b, vert_b )  
		),
		fn isLastEdge obj ei vi = (
		
			local verts = (polyOp.getVertsUsingEdge obj ei)	as array	
-- 			format "\tverts:% ei:% vi:%\n" verts ei vi
			verts[1] == vi or verts[2] == vi
		),
		fn getLoopBetweenTwoVertices obj vert_a vert_b = (
		
			local border_edges = polyOp.getOpenEdges obj --get all open edges
			local last_vert = vert_a
			local next_edge_data = getFirstEdge obj border_edges vert_a vert_b
			local loop_vertices = #(vert_a, next_edge_data[2]) --pick next vertex
			for i=1 to border_edges.count do (
			
				
				next_edge_data = getNextEdge obj next_edge_data[1] next_edge_data[2] border_edges
				append loop_vertices next_edge_data[2]
				if isLastEdge obj next_edge_data[1] vert_b do exit
			)
			loop_vertices
		),
		fn getVertsOpenEdges obj verts = (
		
			local edges_loop = #{}
			for vi in verts do (
				
				local vedges = polyOp.getEdgesUsingVert obj vi
				for ei in vedges where mcPoly.isBorderEdge obj ei do edges_loop += #{ei} 
			)
			edges_loop
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
		fn mapObjectPlanar obj = (
		
			local uv_mod = Uvwmap ()
			uv_mod.maptype = 0
			uv_mod.axis = 2
			uv_mod.realWorldMapSize = off
			uv_mod.utile = 1
			uv_mod.vtile = 1
			uv_mod.wtile = 1
			uv_mod.channel = 0
			addModifier obj uv_mod
			maxOps.CollapseNode obj off
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
		if not em.isValidObject source_obj do return (mcMsgList.warn "not_poly")
		if not em.isValidObject target_obj do return (mcMsgList.warn "not_poly_trgt")
		if not em.isValidSelection source_obj do return (mcMsgList.warn "not_vsel_2")
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
		format "Operation was aborted. Unable get target joints. Is too far >\n\ttarget_vert_a:%\n\ttarget_vert_b:%\n" target_vert_a target_vert_b
		messageBox "Out of Range. Joints are too far." title:form_title
		return false
)
		--get target border lop from vert A to vert B
		local target_vertex_loop = em.getLoopBetweenTwoVertices target_mesh target_vert_b target_vert_a
-- 		polyop.setEdgeSelection target_mesh target_border_loop
-- 		completeRedraw()
		local border_positions = #(polyop.getVert source_mesh source_vert_a)
		for v in source_vertex_loop do append border_positions (polyop.getVert source_mesh v)
		for v in target_vertex_loop do append border_positions (polyop.getVert target_mesh v)
--		debug		
-- global debug_text = #()		
-- for i=1 to border_positions.count do (

	-- local te = text size:100 text:(i as String) pos:(border_positions[i])
	-- te.name = (uniqueName "Test_Text")
	-- append debug_text te
-- )
		
		em.cleanSnapshots #(source_mesh, target_mesh)
		undo "Create Patch 2P" on ( 
			
			local new_surface = em.createSurfaceFromPoints border_positions 
			em.unifyNormals new_surface
			if chk_triangulate.checked do (
				
				local mid_verts = (source_vertex_loop as bitarray) - #{source_vert_a, source_vert_b} --get verts without first and last
				local tirangulate_top_positions = em.getVertsPositions source_obj mid_verts
				em.triangulate new_surface tirangulate_top_positions
			)
			--map new surface 
			if chk_automap.checked do em.mapObjectPlanar new_surface
			if chk_attach.checked do (
			
				em.attachObject source_obj new_surface
				if chk_automap.checked do (
				
					-------------------
					--STITCH MAPPING--
					-------------------
					--get border edge from source object	
					local mid_verts = (source_vertex_loop as bitarray) - #{source_vert_a, source_vert_b} --get verts without first and last
					local source_border_loop = em.getVertsOpenEdges source_obj mid_verts
					polyop.setEdgeSelection source_obj source_border_loop
--collect edgefaces data
-- gd = mcPoly.getGeometryData source_obj useFaces:faces_bitarray
--add unwrap

--collect map data
-- mcPolyMap.collectUnwrapData gd

--select edges in unwrap

--stitch edges

--realx new object mapping if need ????
--collapse stack all
-- maxOps.CollapseNode obj off
				)
				if chk_weld.checked do em.weldVertices source_obj offset:spn_weld_offset.value
			)
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


/*
---debug
border_edges = polyOp.getOpenEdges $ --get all open edges
source_vsel = polyOp.getVertSelection $
vert_a = (source_vsel as array)[1]
vert_b = (source_vsel as array)[2]
vd = em.getFirstEdge $ border_edges vert_a vert_b
vd = em.getNextEdge $ vd[1] vd[2] border_edges
em.isLastEdge $ vd[1] vert_b
verts_loop = em.getLoopBetweenTwoVertices $ vert_a vert_b
verts_loop_pos = for v in verts_loop collect polyOp.getVert $ v
text_arr = #()
for i=1 to verts_loop_pos.count do (
 append text_arr (text pos:verts_loop_pos[i] text:(i as string) size:100)
)
select text_arr
target_mesh = $
pos_a = polyop.getVert source_mesh vert_a
pos_b = polyop.getVert source_mesh vert_b
target_border_edges = polyOp.getOpenEdges target_mesh --get all open edges
target_border_verts = polyop.getVertsUsingEdge target_mesh target_border_edges --get border vertices

target_vert_a = em.getClosestVertex target_mesh target_border_verts pos_a maxRange:40
target_vert_b = em.getClosestVertex target_mesh target_border_verts pos_b maxRange:40
point pos:pos_a wirecolor:red size:100
point pos:pos_b wirecolor:red size:100
polyOp.setVertSelection $ 3

*/