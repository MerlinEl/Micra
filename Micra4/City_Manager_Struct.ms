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
			polyop.createPolygon new_obj #(1,2,4,3)	
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
	fn createCarAndPlayerCollisions = (

		local obj = selection[1]
		if classOf obj != Editable_Poly do return false
		local esel = polyOp.getEdgeSelection obj
		if esel.numberset != 2 do return false
		local everts = polyOp.getVertsUsingEdge obj esel
		if everts.numberset != 4 do return false
		subobjectLevel = 0 --exit from current selection
		local verts_pos = for v in everts collect polyop.getVert obj v

		local player_coll = createStairsCollision obj verts_pos 100 7	--player
		local car_coll 	 = createStairsCollision obj verts_pos 100 29		--car
		select player_coll
	)
	/*<end>*/
)	
 --create instance
Global gCityManager = mcStructMan.instanceStructure sCityManager "gCityManager"
