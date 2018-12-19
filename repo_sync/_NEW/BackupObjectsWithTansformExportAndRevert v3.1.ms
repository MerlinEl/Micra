(
	--user definitions
	local EXPORT_NODE_NAME = "lh_08_house_a_v1" 
	local EXPORT_LAYER_NAME = "LOD0" 
	
	--local definitions
	local TEMP_LAYER_NAME = "MICRA_TEMP_LAYER" 
	local TEMP_MODEL
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
	
	fn MoveNodesToLayer nodes_arr layer_name = (
			
		local target_layer = LayerManager.newLayerFromName layer_name
		for n in nodes_arr do target_layer.addNode n
	)
	
	fn CollapseGeometry obj_arr = (
		max create mode --speed up
		with undo off with redraw off (

			local geom_arr = for o in obj_arr where superClassOf o == GeometryClass collect o
			if geom_arr.count < 2 do return undefined
			local sel_count = geom_arr.count
			local single_model = Editable_Mesh()
			local iterationStart=timestamp()
			local cnt = 1
			while cnt <= geom_arr.count do (
				
				local o = geom_arr[cnt]
				o.material = undefined --remove material
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
		local source_layer = LayerManager.newLayerFromName EXPORT_LAYER_NAME
		--source_layer.current = true --set layer as active
		local layer_objects =  GetLayerNodes EXPORT_LAYER_NAME
		local clone_objects = CloneNodes layer_objects
		MoveNodesToLayer clone_objects TEMP_LAYER_NAME
	)
	
	fn DeleteLayer = (
	
		local layer_objects = GetLayerNodes TEMP_LAYER_NAME
		for o in layer_objects do delete o
		layerManager.deleteLayerByName TEMP_LAYER_NAME
		delete TEMP_MODEL --delete temp model	(is in active layer)
	)
	
	fn InitGeometry = (
		
		local ls3d_node = getNodeByName EXPORT_NODE_NAME
		if ls3d_node == undefined do return false
		local layer_objects = GetLayerNodes TEMP_LAYER_NAME
		--collapse geometry
		TEMP_MODEL = CollapseGeometry layer_objects
		--init node
		SetPivotToBase TEMP_MODEL
		TEMP_MODEL.parent = ls3d_node
		TEMP_MODEL.material = meditMaterials[2] 
		TEMP_MODEL.name = "base"
		format "linked objects:% to node:%\n" layer_objects.count ls3d_node	
	)
	
	fn LS3DExport  = (

		local ls3d_node = getNodeByName EXPORT_NODE_NAME
		if ls3d_node == undefined do return false
		select ls3d_node
		gLS3DSmartExport.exportScene()
	)
	
	
	UnlinkNode() --unlink all objects from export node
	CloneLayer()   --clone layer with all objects
	InitGeometry() --merge all cloned geometry,  reset transforms, add Ls3D material, link to node, 
	LS3DExport() --export
	DeleteLayer() --delete clones and temp layer
)