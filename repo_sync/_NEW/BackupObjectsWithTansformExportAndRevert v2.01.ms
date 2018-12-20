(
	--user definitions
	local EXPORT_NODE_NAME = "lh_08_house_a_v1" 
	local EXPORT_LAYER_NAME = "LOD0" 
	
	--local definitions
	local TEMP_LAYER_NAME = "MICRA_TEMP_LAYER" 
	-----------------------------------------------------------------------------------------------
	fn GetLayerNodes layer_name = (
	
		local layer_nodes = #()
		(LayerManager.getLayerFromName layer_name).nodes &layer_nodes
		return layer_nodes 		
	)
	
	fn CloneNodes source_objects = (
	
		local cloned_nodes = #()
		maxOps.cloneNodes source_objects cloneType:#copy newNodes:&cloned_nodes #nodialog	
		return cloned_nodes
	)
	
	fn CollapseGeometry obj_arr = (
		
		with undo off with redraw off (

			local geom_arr = for o in obj_arr where (superClassOf o == GeometryClass or superClassOf o == Shape) collect o
			if geom_arr.count < 2 do return undefined
			local sel_count = geom_arr.count
			local single_model = Editable_Mesh()
			local iterationStart=timestamp()
			local cnt = 1
			while cnt <= geom_arr.count do (
				
				local o = geom_arr[cnt]
				convertToMesh o --collapse stack and break instance link
				meshop.attach single_model o
				format "progress:[% / %] TotalTime:[%s] IterationTime:[%s] \n" cnt sel_count (timestamp()*.001) ((timestamp()-iterationStart)*.001)
				cnt += 1
			)
			CenterPivot  single_model
			return single_model
		)
	)
	
	fn SetPivotToBase obj = (
	
		local pivot_pos = obj.pivot
		obj.pivot = [pivot_pos.x, pivot_pos.y, obj.min.z]	
	)
	
	fn UnlinkNode = 
	(
		local ls3d_node = getNodeByName EXPORT_NODE_NAME
		if ls3d_node == undefined do return false
		for c in ls3d_node.children do c.parent = undefined
		return true
	)
	
	fn CloneLayer  =
	(		
		--clone nodes
		local source_objects = GetLayerNodes EXPORT_LAYER_NAME
		local clone_objects = CloneNodes source_objects
		--move originals in to backup
		local backup_layer = LayerManager.newLayerFromName TEMP_LAYER_NAME
		for n in source_objects do backup_layer.addNode n
	)
	
	fn DeleteLayer = (
	
		--empty export dir
		local clone_objects = GetLayerNodes EXPORT_LAYER_NAME
		for o in clone_objects do delete o
		--return originals from backup
		local source_objects = GetLayerNodes TEMP_LAYER_NAME
		local source_layer = LayerManager.getLayerFromName EXPORT_LAYER_NAME
		for n in source_objects do source_layer.addNode n
		--delete backup layer	
		layerManager.deleteLayerByName TEMP_LAYER_NAME
	)
	
	fn InitGeometry = (
		
		local ls3d_node = getNodeByName EXPORT_NODE_NAME
		if ls3d_node == undefined do return false
		local clone_objects = GetLayerNodes EXPORT_LAYER_NAME
		--collapse geometry
		local single_model = CollapseGeometry clone_objects
		--init node
		SetPivotToBase single_model
		single_model.parent = ls3d_node
		single_model.material = meditMaterials[1] 
		single_model.name = "base"
		format "linked objects:% to node:%\n" clone_objects.count ls3d_node	
	)
	
	fn LS3DExport  = (

		local ls3d_node = getNodeByName EXPORT_NODE_NAME
		if ls3d_node == undefined do return false
		select ls3d_node
		gLS3DSmartExport.exportScene()
	)
	
	
	UnlinkNode() --unlink all objects from export node
	CloneLayer()   --clone layer with all objects -- originals moved in to backup
	InitGeometry() --merge all cloned geometry,  reset transforms, add Ls3D material, link to node, 
	LS3DExport() --export
	DeleteLayer() --delete clones and temp layer
)