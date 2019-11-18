Global gRoadGeneratorCollision
struct sRoadGeneratorCollision (

	collision_wirecolor = color 176 26 26,
	force_load_structures = true,
	materal_id_offset = 1000, --ofset all mat ID to prevent replacement
	fn detachRail obj faces = (
		
		--detach,  rename
		local rails_name = uniqueName (obj.name + "_rails")
		polyOp.detachFaces obj faces delete:true asNode:true name:rails_name --node:&obj_rails
		--add collision params
		getNodeByName rails_name
	),
	fn optimizeRails obj = (
	
		local all_elements = ::mcPoly.getObjectElements obj
		local edges_to_remove = #{}
		for el in all_elements do (
			
			--select longest edge
			local fedges = polyop.getEdgesUsingFace obj el
			local longest_edge = ::mcPoly.getLongestEdge obj fedges
			if longest_edge == 0 do continue
			polyop.setEdgeSelection obj longest_edge
			--create ring and desetect two edges at each end
			obj.SelectEdgeRing()
			obj.setRingShift -4 false false --shring ring by 4
			obj.setRingShift 2 true false --shift ring by 2
			--select loop loop
			obj.SelectEdgeLoop()
			local ring_edges = polyOp.getEdgeSelection obj
			join edges_to_remove ring_edges
		)
		--remove edges
		undo "Optimize Rails" on (
		
			::mcPoly.removeEdges obj edges_to_remove
			::mcPoly.setObjectSMG obj 1
		)
		true --if all is ok return true
	),
	fn skewNavmeshRailTop obj = ( --val 1% -- 100%
	
		local all_elements = ::mcPoly.getObjectElements obj
		for el in all_elements do (
		
			--select shortest edge
			local fedges = polyop.getEdgesUsingFace obj el
			local shortest_edge = ::mcPoly.getShortestEdge obj fedges
			polyOp.setEdgeSelection obj shortest_edge
			--select top edge
			obj.SelectEdgeLoop()
			obj.setLoopShift -2 true true
			obj.setLoopShift 1 true false
			--get all top edges
			obj.SelectEdgeRing()
			--scale all edges to 90 percent
			local ring_edges = polyOp.getEdgeSelection obj
			for edge_index in ring_edges do ::mcPoly.scaleEdgeTo obj edge_index 90
		)
	),
	fn generateNavmeshFromRails road_coll obj = (
	
		format "generateNavmeshFromRails > obj:%\n" obj.name
		addModifier obj (Push Push_Value:4.5)
		convertToPoly obj
		skewNavmeshRailTop obj
		::mcPoly.setObjectId obj 50
		::mcPoly.setObjectSMG obj 1
		road_coll.layer.addNode obj
		AddCustomAttributeByName obj "CollisionMesh"
		obj.'~layer' = 4
	),
	fn createRailsCollisions road_coll rail_faces export_coll_node = (
		
		local obj_rails = detachRail road_coll rail_faces
		--format "detach:\n\trails:%\n\tfrom:%\n" obj_rails.name road_coll.name
		optimizeRails obj_rails
		--generate navmesh helper
		local obj_navmesh = copy obj_rails
		generateNavmeshFromRails road_coll obj_navmesh
		--set link and collision params
		obj_navmesh.parent = export_coll_node
		obj_navmesh.wirecolor = collision_wirecolor
		obj_navmesh.name = road_coll.name + "_navmesh"
		--move navmesh in to road collision layer
		road_coll.layer.addNode obj_navmesh
		--attach rails back to instance
		polyOp.attach road_coll obj_rails
	),
	fn generateRoadCollisions = (
		
		gProgLog.msg "@" --clear log
		gProgLog.progSub 0 0
		gProgLog.msg "TERRAIN COLLISION GENERATOR:" ti:"Initialize...." ty:"new_task"
		gProgLog.msg "Proces Start" ti:"3DsMax..." ty:"task_open"
		
		if superClassOf roGenStruct == StructDef do ::roGenStruct.All_CALLBACKS_ENABLED = false
		sliderTime = 0 --some roads have linkedXform with animated dummy. Collision must be genereted at frame 0
		
		local s_mat = currentMaterialLibrary["semantic_materials"]
		if s_mat == undefined do  s_mat = meditmaterials["semantic_materials"]
		if s_mat == undefined do (
			
			gProgLog.msg ("Unable to create collisions. Semantic Material not found.") ty:"error"
			return false
		)
		local xml_file = (LS3DGUP.LS3DGUP.UtilsPath + "coll_bourbon_table.xml")
		if not (doesFileExist xml_file) do (
		
			format "Unable to Locate coll_bourbon_table.xml.\n"
			--gProgLog.msg ("Unable to Locate coll_bourbon_table.xml.") ty:"error"
			return false
		)
		local xml_data = ::gCityManager.parseXmlTable xml_file
		local sel = selection as array
		local sel_count = selection.count
		with redraw off for i=1 to sel_count do (


			local obj = sel[i]
			local collision_layer = ::gCityManager.getCollisionLayer obj
			local export_coll_node = ::gCityManager.getCollisionNode obj
			if not isValidNode export_coll_node do (
			
				format "Unable to create collision from [ % ] . Collision Node not exists.\n" obj.name
				continue
			)
			gProgLog.progSub i sel_count
			gProgLog.msg ("progress obj:"+obj.name) ty:"proc"
			
			local o_instance = ::gCityManager.cloneObject obj "coll"  --create road clone
			o_instance.wirecolor = collision_wirecolor
			o_instance.material = s_mat
			AddCustomAttributeByName o_instance "CollisionMesh"
			o_instance.parent = export_coll_node --link to export collision node
			collision_layer.addNode o_instance --add instance to collision layer
			local rail_faces = #{}
			--for whole object offset ids by 1000 to avoid replacment
			local object_ids = ::gCityManager.getObjectIDS o_instance
			::gCityManager.offsetMaterialsIDs o_instance object_ids offset:materal_id_offset
			for f=1 to o_instance.numFaces do ( --replace ids with semantic material
				
				local mat_id = polyop.getFaceMatID o_instance f
				-- local sem_id = matIdToSemanticId (mat_id - materal_id_offset)
--temp fix for cobblestones
				local sem_id = ( --exception for now 52 for cobblestones_car
				
					if mat_id == (425+materal_id_offset) then 52 else ::gCityManager.getSIDByID xml_data (mat_id - materal_id_offset)
				)
				--format "face:% mat_id:% sem_id:%\n" f mat_id sem_id
				polyop.setFaceMatID o_instance f sem_id	
				--if face is rail add to collection
				if sem_id == 65 do rail_faces += #{f}
			)
			--detach rails to separate mesh, optimize and clone to navmesh, transform navmesh
			if rail_faces.numberSet != 0 do (
			
				createRailsCollisions o_instance rail_faces export_coll_node 
			)
			--format "Generated Collisions for:%\n" obj.name
		)
		max select none
		gProgLog.progSub sel_count sel_count
		gProgLog.msg "All Done" ty:"task_close"
		if superClassOf roGenStruct == StructDef do ::roGenStruct.All_CALLBACKS_ENABLED = true
		completeRedraw()
	)
)
gRoadGeneratorCollision = sRoadGeneratorCollision ()

/*
rails nav mesh
- clone rails optimized
- push 0.045
- select top edges ring and scale 90%
- collision + layer 4
- sem mat 50

custAttributes.count $
*/

/*
for o in selection do o.parent = $lh_02_little_italy_block_h_roads_coll
--select rails collisions
select(for o in selection where findString o.name "rails" != undefined collect o)
*/

/*
fn exclude4EndEdges obj fedges = (
	
	verts_a = polyOp.getEdgeVerts $ 47
	verts_b = polyOp.getEdgeVerts $ 885
	edges_a = polyOp.getEdgesUsingVert  $ verts_a
	edges_b = polyOp.getEdgesUsingVert  $ verts_b
	edges_a.numberSet
	edges_b.numberSet	
)*/