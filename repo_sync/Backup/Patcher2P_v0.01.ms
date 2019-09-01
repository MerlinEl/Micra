Global mcPatcher2PDialog --not used yet
if ::mcPatcher2PDialog != undefined do try(destroyDialog mcPatcher2PDialog)catch()
rollout mcPatcher2PDialog "Patcher 2P:" width:432 height:68
(
	local title_msg = mcPatcher2PDialog.title
	local target_obj = undefined
	pickButton 'btn_trgt_obj' "Pick..." pos:[84,28] width:52 height:20 align:#left
	groupBox 'grp16' "Setup:" pos:[4,4] width:424 height:60 align:#left
	label 'lbl5' "Target Object:" pos:[8,32] width:76 height:16 align:#left
	label 'lbl_trgt_obj' "..." pos:[140,29] width:196 height:16 align:#left
	button 'btn_stitch' "STITCH" pos:[340,20] width:80 height:36 align:#left
	fn getTargetObject obj = (
	
		target_obj = obj
		lbl_trgt_obj.text = obj.name	
	)
	fn filterBorderVerts obj = (
		
		local verts = #{1..(polyop.getNumVerts obj)}
		local edges = polyop.getOpenEdges obj
		local newVerts = #{}
		for edg in edges do
		(
			for edgeVert in (polyop.getEdgeVerts obj edg) do
			(
				if((findItem verts edgeVert)!=0)then append newVerts edgeVert
			)
		)
		#(newVerts, edges)
	)
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
	)
	fn getEdgeCenter obj ei = (
	
		local verts = (polyOp.getVertsUsingEdge obj ei)	as array
		local p1 = polyOp.getVert obj verts[1]
		local p2 = polyOp.getVert obj verts[2]
		(p1 + p2) / 2
	)
	fn getClosestEdge obj edges vert = (
		
		local closest_edge = (edges as array)[1]
		local edge_center = getEdgeCenter obj closest_edge
		local vert_pos = polyOp.getVert obj vert
		for ei in edges do (
			
			local next_center = getEdgeCenter obj ei
			if (distance next_center vert_pos) < (distance edge_center vert_pos) do (
				
				closest_edge = ei
				edge_center = next_center
			)
		)	
		closest_edge
	)
	fn isLastEdge obj ei vi = (
		
		local verts = (polyOp.getVertsUsingEdge obj ei)	as array	
		verts[1] == vi or verts[2] == vi
	)
	fn getLoopBetweenTwoVertices obj vert_a ver_b border_verts border_edges = (
		
		local verts_loop = #{}
		local next_vert = vert_a
		for i=1 to border_verts.numberset do (
			
			local vedges = polyOp.getEdgesUsingVert obj next_vert
			vedges = vedges * border_edges --remove edges which is not in border
			local vedge = getClosestEdge obj vedges ver_b
			local everts = polyOp.getVertsUsingEdge obj vedge
-- 			format "everts:% next_vert:%\n" everts next_vert
			next_vert = ((everts - #{next_vert}) as array) [1]
			verts_loop += everts
			if isLastEdge obj vedge ver_b do exit
		)
		verts_loop
	)
	fn createSurfaceFromPoints obj verts = (
		
		local hits_pos = for vi in verts collect polyOp.getVert obj vi
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
	fn stitchSurfaces = (
		
		if target_obj == undefined do return false
		--SOURCE get two vertices
		local gco = modPanel.getCurrentObject()
		if gco == undefined do return false
		local vsel = gco.getSelection #Vertex as Array
		if vsel.count != 2 do return false
		format "vsel:%\n" vsel
		--TARGET get two closest vertices
		local border_elements = filterBorderVerts target_obj
		local border_verts = border_elements[1]
		local border_edges = border_elements[2]
		format "border_verts:%\n" border_verts
		local pos_a = gco.GetVertex vsel[1]
		local pos_b = gco.GetVertex vsel[2]
		local trgt_vert_a = getClosestVertex target_obj border_verts pos_a 10
		local trgt_vert_b = getClosestVertex target_obj border_verts pos_b 10
		format "trgt_vert a:% b:%\n" trgt_vert_a trgt_vert_b
		--get line between two vertices
		local verts_loop = getLoopBetweenTwoVertices target_obj trgt_vert_b trgt_vert_a border_verts border_edges
		format "verts_loop:%\n" verts_loop
		createSurfaceFromPoints target_obj verts_loop
		--debug
		/*local points = #()
		for v in verts_loop do (
			
			local p = point pos:(polyOp.getVert target_obj v)
			append points p
		)
		subobjectlevel = 0
		select points*/
	)
	on btn_trgt_obj picked obj do getTargetObject obj
	on btn_stitch pressed  do stitchSurfaces()
)
createDialog mcPatcher2PDialog
