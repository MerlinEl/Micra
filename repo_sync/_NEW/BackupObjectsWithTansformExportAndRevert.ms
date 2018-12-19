(
	--user definitions
	local EXPORT_NODE_NAME = "lh_08_house_a_v1" 
	local EXPORT_LAYER_NAME = "LOD0" 
	
	--local definitions
	local BACKUP_NODES = #()
	local CLONED_NODES = #()
	local BACKUP_LAYER_NAME = "mcLS3D_Backup_Layer" 
	local LINK_PARENTS = #()
	local USED_MATERIALS = #()
	
	fn mcLS3DBackupUnlinkTransformed = 
	(
		--collect transformed nodes
		local layer_objects = #()
		local export_layer = LayerManager.getLayerFromName EXPORT_LAYER_NAME
		export_layer.nodes &layer_objects
		--collect only transformed
		BACKUP_NODES = for o in layer_objects where o.scale != [1,1,1] collect o
		print "-------------------------------"
		format "Transformed objects count:%\n" BACKUP_NODES.count
		for o in BACKUP_NODES do format "backup object:% scale:%\n" o.name o.scale
		print "-------------------------------"
		--backup - unlink  transformed  objects
		local bk_layer = LayerManager.newLayerFromName BACKUP_LAYER_NAME
		for o in BACKUP_NODES do (
			--backup nodes to another layer
			bk_layer.addNode o
			--store parent
			local node_parent = o.parent
			local parent_name = (if node_parent == undefined then "undefined" else node_parent.name)
			LINK_PARENTS += parent_name
			--remove parent
			o.parent = undefined
		)
	)
	
	fn mcLS3DCloneAndResetTransforms = (

		--clone originals ad move to defined layer
		maxOps.cloneNodes BACKUP_NODES cloneType:#instance newNodes:&CLONED_NODES #nodialog
		--move clones to export folder and reset transform
		local export_layer = LayerManager.getLayerFromName EXPORT_LAYER_NAME
		for o in CLONED_NODES do (
			
			export_layer.addNode o
			ResetTransform o
		)
		select CLONED_NODES
	)

	fn mcLS3DExport  = (

		--link all nodes in defined layer to node
		local layer_objects
		(LayerManager.getLayerFromName "LOD0").nodes &layer_objects
		--backup materials and assing default LS3D
		for o in layer_objects do (
			
			local mat = (if o.material == undefined then "undefined" else o.material)
			USED_MATERIALS +=  mat
			o.material = meditMaterials[1] 
		)
		--link all to export node
		local ls3d_node = getNodeByName EXPORT_NODE_NAME
		format "linked objects:% to node:%\n" layer_objects.count ls3d_node
		layer_objects.parent = ls3d_node
		--export
		select ls3d_node
		gLS3DSmartExport.exportScene()
	)

	fn mcLS3DRevertBackups = (
		
		if CLONED_NODES != undefined and CLONED_NODES.count > 0 do (for o in CLONED_NODES do delete o)
		local export_layer = LayerManager.getLayerFromName EXPORT_LAYER_NAME
		--local backup_layer = LayerManager.getLayerFromName BACKUP_LAYER_NAME 
		--local layer_objects = #()
		--backup_layer.nodes &layer_objects
		--for o in layer_objects do export_layer.addNode o
		for i = 1 to BACKUP_NODES.count do (
			
			local o = BACKUP_NODES[i]
			export_layer.addNode o
			if LINK_PARENTS.count != BACKUP_NODES.count do continue
			--relink
			local node_parent = LINK_PARENTS[i]
			if node_parent != "undefined" do o.parent = getNodeByName node_parent
		)
		layerManager.deleteLayerByName BACKUP_LAYER_NAME
		--restore materials
		local layer_objects
		(LayerManager.getLayerFromName "LOD0").nodes &layer_objects
		if USED_MATERIALS.count != layer_objects.count do return false
		for i = 1 to layer_objects.count do (
			
			local obj = layer_objects[i]
			local mat  = USED_MATERIALS[i]
			if mat != "undefined" do obj.material = mat
		)
	)

	mcLS3DBackupTransformed()
	mcLS3DCloneAndResetTransforms()
	mcLS3DExport()
	mcLS3DRevertBackups()
)