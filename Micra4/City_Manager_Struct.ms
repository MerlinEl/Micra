--------------------------------------------------------------------------------
/* gCityManager by Orien 2019 */
--------------------------------------------------------------------------------
/*
*@Used Structures
	mcStructMan
*
*@Used Objects
	undefined
*
*@Usage
	undefined
*
*@Example	
	undefined
*
*/
struct sCityManager	(
	
	--variables
	
	--functions
	fn getSource = getSourceFileName(), --get path of this script
	fn getCollisionLayer obj = (
	
		local layer_name = obj.layer.name + "_coll"
		local collision_layer = LayerManager.getLayerFromName layer_name --pick layer by name
		if collision_layer == undefined do collision_layer = LayerManager.newLayerFromName layer_name --create layer if not exists
		collision_layer
	),
	fn getCollisionNode obj = (
	
		local node_name
		if obj.parent != undefined then (
		
			local geometry_node_name = obj.parent.name
			local suffix_geometry_index = findString geometry_node_name "_geometry"
			if suffix_geometry_index != undefined then (
			
				node_name = (subString geometry_node_name 1 suffix_geometry_index) + "coll" 	
				
			) else (
				
				--format "Unable to create collision from [ % ]. Export Node has invalid name [ % ].\n" obj.name obj.parent.name
				gProgLog.msg ("Unable to create collision from [ "+obj.name+" ]. Export Node has invalid name [ "+obj.parent.name+" ].") ty:"error"
				return undefined
			)
		)  else (
			
			-- format "Unable to create collision from [ % ]. Object is not linked to Export Node.\n" obj.name
			gProgLog.msg ("Unable to create collision from [ "+obj.name+" ]. Object is not linked to Export Node.") ty:"error"
			return undefined
		)
		local coll_export_node = getNodeByName node_name
		if coll_export_node == undefined then (
			
			-- format "Unable to create collision from [ % ]. Missing collision node [ % ].\n" obj.name node_name
			gProgLog.msg ("Unable to create collision from [ "+obj.name+" ]. Missing collision node [ "+node_name+" ].") ty:"error"
			undefined
		) else (
			
			coll_export_node
		)
	),
	fn createStairsCollision obj verts_pos mat_id layer_index = (
	
		local new_obj = Editable_mesh()
		undo off (
		
			convertToPoly new_obj
			for p in verts_pos do polyop.createVert new_obj p -- node:<node=unsupplied>
			polyop.createPolygon new_obj #(1,2,3,4)	
			new_obj.pivot = (new_obj.min + new_obj.max) / 2 --center pivot
			new_obj.name = uniqueName (obj.name+"stairs_coll_")
			--set material ID
			for f=1 to new_obj.numFaces do ( polyOp.setFaceMatID new_obj f mat_id )
			--add semantic material	
			local s_mat = currentMaterialLibrary["semantic_materials"]
			new_obj.material = s_mat
			--add collision prameter (Data Manager)
			AddCustomAttributeByName new_obj "CollisionMesh"
			new_obj.'~layer' = layer_index
			local coll_layer = getCollisionLayer obj
			local coll_export_node = getCollisionNode obj
			coll_layer.addNode new_obj --ad to coll laer
			new_obj.parent = coll_export_node -- link to coll node
		)
		update new_obj
		new_obj
	),
	fn createCarAndPlayerCollisions CCV:true SPIN:false = (

		local obj = selection[1]
		if classOf obj != Editable_Poly do return false
		local esel = polyOp.getEdgeSelection obj as Array
		if esel.count != 2 do return false
		--------------------------
		-- reorder 4 vertices CCV
		--------------------------
		--get edges vertices
		local everts_a = (polyOp.getVertsUsingEdge obj esel[1] as Array)
		local everts_b = (polyOp.getVertsUsingEdge obj esel[2] as Array)
		local vert_1 = polyOp.getVert obj everts_b[2]
		local vert_2 = polyOp.getVert obj everts_b[1]
		local vert_3 = polyOp.getVert obj everts_a[2]
		local vert_4 = polyOp.getVert obj everts_a[1]
		--get edges vectors
		local v1 = vert_1 - vert_2
		local v2 = vert_2 - vert_3
		--check if both vectors directing in same way (if not switch)
		if (dot v1 v2) < 0 then (
			--swap vertices
			local v = everts_b[1]
			everts_b[1] = everts_b[2]
			everts_b[2] = v
			--get positoins again
			vert_1 = polyOp.getVert obj everts_b[2]
			vert_2 = polyOp.getVert obj everts_b[1]
		) 
		--check CCV points order
		--TODO
		local verts_pos = if CCV then #(vert_1, vert_2, vert_3, vert_4) else #(vert_4, vert_3, vert_2, vert_1)
		if SPIN do verts_pos = #(verts_pos[1], verts_pos[2], verts_pos[4], verts_pos[3])
		subobjectLevel = 0 --exit from current selection
		local player_coll = createStairsCollision obj verts_pos 100 7	--player
		local car_coll 	 = createStairsCollision obj verts_pos 100 29		--car
		select player_coll
	)
	/*<end>*/
)	
 --create instance
Global gCityManager = mcStructMan.instanceStructure sCityManager "gCityManager"



/*
obj = $
esel = polyOp.getEdgeSelection obj as Array
everts_a = (polyOp.getVertsUsingEdge obj esel[1] as Array)
everts_b = (polyOp.getVertsUsingEdge obj esel[2] as Array)
vert_1 = polyOp.getVert obj everts_b[2]
vert_2 = polyOp.getVert obj everts_b[1]
vert_3 = polyOp.getVert obj everts_a[2]
vert_4 = polyOp.getVert obj everts_a[1]
v1 = vert_1 - vert_2
v2 = vert_2 - vert_3
--check if both vectors directing in same way
if (dot v1 v2) < 0 then (
	--swap vertices
	v = everts_b[1]
	everts_b[1] = everts_b[2]
	everts_b[2] = v
	vert_1 = polyOp.getVert obj everts_b[2]
	vert_2 = polyOp.getVert obj everts_b[1]
	v1 = vert_1 - vert_2
	v2 = vert_2 - vert_3
) 
--now is both paralel vectors directing in same way
dot v1 v2
verts_pos = #(everts_b[2], everts_b[1], everts_a[2], everts_a[1])

polyop.createPolygon $ verts_pos
update $

v3 = vert_2 - vert_3
cross v1 v3

*/
