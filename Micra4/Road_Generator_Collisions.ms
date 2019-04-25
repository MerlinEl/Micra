Global roadGeneratorCollisionDialog
if roadGeneratorCollisionDialog != undefined do DestroyDialog roadGeneratorCollisionDialog
rollout roadGeneratorCollisionDialog "Road Collision Generator:" width:544 height:88
(
	groupBox 'grp1' "Set-Up:" pos:[4,8] width:400 height:72 align:#left
	label 'lbl1' "Collision Node:" pos:[16,36] width:76 height:16 align:#left
	editText 'edt_coll_node' "" pos:[96,32] width:292 height:20 align:#left
	label 'lbl2' "Collision Layer:" pos:[16,56] width:76 height:16 align:#left
	editText 'edt_coll_layer' "" pos:[96,52] width:292 height:20 align:#left
	button 'btn_create_colls' "GNERATE" pos:[408,12] width:132 height:68 align:#left
	--for o in selection do o.parent = $lh_02_little_italy_block_h_roads_coll
	fn matIdToSemanticId id = (
		
		case id of (

			2:	65	--rails
			3:	52	--cobblestone
			4: 56	--crub
			5: 50	--road
			6: 50	--road side
			7: 50	--road tile
			8: 53	--pavement
			default: 1
		)
	)
	fn cloneRoad obj prefix = (
		
		local new_o = copy obj
		new_o.name = prefix+"_"+ obj.name
		--for c in new_o.children do c.parent = undefined --dont need (a clone have no children)
		--hasProperty $ "CrossRoadKids" --not works
		for i = custAttributes.count new_o to 1 by -1 do custAttributes.delete new_o i --delete all custom attributes
		--select new_o
		--custAttributes.count new_o
		new_o
	)
	fn detachRail obj faces = (
		
		--detach,  rename
		local rails_name =  (obj.name + "_rails")
		polyOp.detachFaces obj faces delete:true asNode:true name:rails_name --node:&obj_rails
		--add collision params
		getNodeByName rails_name
	)
	fn createRoadsCollisions = (
		
		local export_coll_node = getNodeByName edt_coll_node.text 
		local collision_layer = LayerManager.getLayerFromName edt_coll_layer.text
		local s_mat = meditmaterials["semantic_materials"]
		for o in selection do (

			local o_instance = cloneRoad o "coll"  --create road clone
			o_instance.wirecolor = color 176 26 26
			o_instance.material = s_mat
			AddCustomAttributeByName o_instance "CollisionMesh"
			o_instance.parent = export_coll_node --link to export collision node
			collision_layer.addNode o_instance --add instance to collision layer
			local rail_faces = #()
			for f=1 to o_instance.numFaces do ( --replace ids with semantic material
				
				local mat_id = polyop.getFaceMatID o_instance f
				local sem_id = matIdToSemanticId mat_id
				--format "face:% mat_id:% sem_id:%\n" f mat_id sem_id
				polyop.setFaceMatID o_instance f sem_id	
				--if face is rail add to collection
				if sem_id == 65 do append rail_faces f
			)
			--detach rails to separate mesh
			if rail_faces.count != 0 do (
				
				local obj_rails = detachRail o_instance rail_faces
				obj_rails.parent = export_coll_node
				collision_layer.addNode obj
				AddCustomAttributeByName obj "CollisionMesh"
				obj.'~layer' = 4
			)
		)
		/*
		--select rails collisions
		select(for o in selection where findString o.name "rails" != undefined collect o)
		*/
	)
	fn init = (
		
		edt_coll_layer.text = "lh_02_little_italy_roads_coll" 
		edt_coll_node.text ="lh_02_little_italy_block_h_roads_coll"
	)
	on roadGeneratorCollisionDialog open do init()
	on btn_create_colls pressed  do createRoadsCollisions()
)
CreateDialog roadGeneratorCollisionDialog

/*
rails nav mesh
- clone rails optimized
- push 0.045
- select top edges ring and scale 90%
- collision + layer 4
- sem mat 1

custAttributes.count $
*/
