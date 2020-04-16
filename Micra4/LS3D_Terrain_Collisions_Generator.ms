Global gTerrainGeneratorCollision
struct sTerrainGeneratorCollision (

	collision_wirecolor = color 176 26 26,
	materal_id_offset = 1000, --ofset all mat ID to prevent replacement
	private fn setObjectIDSbyXMLtable obj xml_data = (
	
		local object_ids = ::gCityManager.getObjectIDS obj
		::gCityManager.offsetMaterialsIDs obj object_ids offset:materal_id_offset --prevent override old ids
		for id in object_ids do (
		
			--format "setObjectIDSbyXMLtable > obj:%\n" obj.name
			local new_mat_id = ::gCityManager.getSIDByID xml_data id
			local offset_id = id+materal_id_offset
			local id_faces = ::gCityManager.getFacesByMatID obj offset_id
			--format "\told_id:% new_id:% offset_id:%\n" id new_mat_id offset_id
			polyOp.setFaceMatID obj id_faces new_mat_id	
		)
	),
	public fn generateSimpleCollisions two_nodes = (
		
		local s_mat = currentMaterialLibrary["semantic_materials"]
		if s_mat == undefined do  s_mat = meditmaterials["semantic_materials"]
		if s_mat == undefined do (
			
			-- format "Unable to create collisions. Semantic Material not found.\n"
			gProgLog.msg ("Unable to create collisions. Semantic Material not found.") ty:"error"
			return false
		)
		
		gProgLog.msg "@" --clear log
		gProgLog.progSub 0 0
		gProgLog.msg "SIMPLE COLLISION GENERATOR:" ti:"Initialize...." ty:"new_task"
		gProgLog.msg "Proces Start" ti:"3DsMax..." ty:"task_open"
		
		-- for o in selection where superClassOf o == GeometryClass do (
		local sel_count = selection.count
		for i = 1 to sel_count where superClassOf selection[i] == GeometryClass do (
		
			local o = selection[i]
			local coll_layer = ::gCityManager.getCollisionLayer o
			local coll_export_node = if two_nodes then ::gCityManager.getCollisionNode o else o
			if coll_export_node == undefined do (
			
				-- format "Unable create collision for object:%. Missing collision Node.\n" o.name
				gProgLog.msg ("Unable create collision for object:"+o.name+". Missing collision Node.") ty:"error"
				continue
			)
			gProgLog.progSub i sel_count
			gProgLog.msg ("progress obj:"+o.name) ty:"proc"
			
			--clone object
			local o_coll = ::gCityManager.cloneObject o "coll" 
			convertToPoly o_coll --collapse all modifiers
			coll_layer.addNode o_coll --ad to coll laer
			o_coll.parent = coll_export_node -- link to coll node
			--set wirecolor
			o_coll.wirecolor = collision_wirecolor
			--change material id to 1 (uni hard)
			for f=1 to o_coll.numFaces do ( polyOp.setFaceMatID o_coll f 1 )
			--assign semantic material
			o_coll.material = s_mat
			--add collision prameter (Data Manager)
			AddCustomAttributeByName o_coll "CollisionMesh"
			o_coll.'~layer' = -1
		)
		
		gProgLog.progSub sel_count sel_count
		gProgLog.msg "All Done" ty:"task_close"
	),
	public fn generateTerrainCollisions = (
	
		local s_mat = currentMaterialLibrary["semantic_materials"]
		if s_mat == undefined do  s_mat = meditmaterials["semantic_materials"]
		if s_mat == undefined do (
			
			--format "Unable to create collisions. Semantic Material not found.\n"
			gProgLog.msg ("Unable to create collisions. Semantic Material not found.") ty:"error"
			return false
		)
		local xml_file = (LS3DGUP.LS3DGUP.UtilsPath + "coll_bourbon_table.xml")
		if not (doesFileExist xml_file) do (
		
			--format "Unable to Locate coll_bourbon_table.xml.\n"
			gProgLog.msg ("Unable to Locate coll_bourbon_table.xml.") ty:"error"
			return false
		)
		local xml_data = ::gCityManager.parseXmlTable xml_file
		
		gProgLog.msg "@" --clear log
		gProgLog.progSub 0 0
		gProgLog.msg "TERRAIN COLLISION GENERATOR:" ti:"Initialize...." ty:"new_task"
		gProgLog.msg "Proces Start" ti:"3DsMax..." ty:"task_open"

		local sel_count = selection.count
		local instanced_collisions_handles = #()
		for i = 1 to sel_count where superClassOf selection[i] == GeometryClass do (
		
			local o = selection[i]
			local coll_layer = ::gCityManager.getCollisionLayer o
			local coll_export_node = ::gCityManager.getCollisionNode o
			if coll_export_node == undefined do (
			
				--format "Unable create collision for object:%. Missing collision Node.\n" o.name
				gProgLog.msg ("Unable create collision for object:"+o.name+". Missing collision Node.") ty:"error"
				continue
			)
			gProgLog.progSub i sel_count
			gProgLog.msg ("progress obj:"+o.name) ty:"proc"
			if findItem instanced_collisions_handles o.handle do continue --skip instanced collisions which is already done
			
			--clone object
			local o_coll = ::gCityManager.cloneObject o "coll"
			coll_layer.addNode o_coll --ad to coll laer
			o_coll.parent = coll_export_node -- link to coll node
			--set wirecolor
			o_coll.wirecolor = collision_wirecolor
			setObjectIDSbyXMLtable o_coll xml_data
			--assign semantic material
			o_coll.material = s_mat
			--add collision prameter (Data Manager)
			AddCustomAttributeByName o_coll "CollisionMesh"
			o_coll.'~layer' = -1
			
			--check if object is instanced and create instanced collision for all instances
			local object_instances = #()
			InstanceMgr.GetInstances o &object_instances
			if object_instances.count > 1 do (
			
				append instanced_collisions_handles o.handle --mark as done
				for oi in object_instances where oi.handle != o.handle do ( --do all except first one
				
					append instanced_collisions_handles oi.handle --mark as done
					local coll_instance = instance o_coll --instance collision
					coll_layer.addNode coll_instance --move to layer
					coll_instance.pos = oi.pos	--copy pos		
					mcTransform.setRotation coll_instance (mcTransform.getRotation oi) --copy rotation
				)
			)
		)
		gProgLog.progSub sel_count sel_count
		gProgLog.msg "All Done" ty:"task_close"
	)
)
gTerrainGeneratorCollision = sTerrainGeneratorCollision()