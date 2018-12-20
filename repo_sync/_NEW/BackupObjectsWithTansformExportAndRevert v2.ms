(
	--user definitions
	local USER_NODE_NAME = "lh_08_house_a_v1" 
	local USER_LAYER_NAME = "LOD0" 
	
	--local definitions
	local EXPORT_LAYER_NAME = "mcLS3D_EXPORT_LAYER" 
	-----------------------------------------------------------------------------------------------
	
	fn mcLS3DUnlinkObjectsFromNode = 
	(
		local layer_objects = #()
		(LayerManager.getLayerFromName USER_LAYER_NAME).nodes &layer_objects
		for o in layer_objects do (
			
			local obj_parent = o.parent
			if obj_parent== undefined do continue 
			if obj_parent.name ==  USER_NODE_NAME do o.parent = undefined
		)
	)
	
	fn mcLS3DCloneObjects = (

		local layer_objects = #()
		(LayerManager.getLayerFromName USER_LAYER_NAME).nodes &layer_objects
		local cloned_objects = #()
		maxOps.cloneNodes layer_objects cloneType:#instance newNodes:&cloned_objects #nodialog
		local export_layer = LayerManager.newLayerFromName EXPORT_LAYER_NAME
		for o in cloned_objects do export_layer.addNode o
	)
	
	fn mcLS3DExport  = (

		local layer_objects = #()
		(LayerManager.getLayerFromName EXPORT_LAYER_NAME).nodes &layer_objects
		--reset clones transform, set pivot to node pos,  set ls3d material, link to node 
		local ls3d_node = getNodeByName USER_NODE_NAME
		if ls3d_node == undefined do return false
		for o in layer_objects do (
			
			if o.scale != [1,1,1] do ResetTransform o --if scaled reset
			o.material = meditMaterials[1] 
			o.parent = ls3d_node
			--o.pivot = ls3d_node.pivot
		)
		format "linked objects:% to node:%\n" layer_objects.count ls3d_node
		--export
		select ls3d_node
		gLS3DSmartExport.exportScene()
	)
	
	fn mcLS3DClean = (
	
		local layer_objects = #()
		(LayerManager.getLayerFromName EXPORT_LAYER_NAME).nodes &layer_objects	
		for o in layer_objects do delete o
		layerManager.deleteLayerByName EXPORT_LAYER_NAME
	)
	
	mcLS3DUnlinkObjectsFromNode() --unlink all objects in given layer from node
	mcLS3DCloneObjects() --Clone objects from given layer to export layer
	mcLS3DExport() --ResetTransforms, Add Ls3D Material, Link to node, Export
	mcLS3DClean() --delete clones and export layer
)