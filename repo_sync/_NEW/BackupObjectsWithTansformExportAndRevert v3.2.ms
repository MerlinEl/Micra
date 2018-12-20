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
	
	fn MoveNodesToLayer nodes_arr layer_name = (
			
		local target_layer = LayerManager.newLayerFromName layer_name
		for n in nodes_arr do target_layer.addNode n
	)
	
	fn CollapseGeometry obj_arr = (
			max create mode --speed up
			local sel_geometry = for i in obj_arr where (superClassOf i == GeometryClass or superClassOf i == Shape) collect i
			if sel_geometry.count < 2 do return false
			try undo "Collapse" off
			(
				with redraw off 
				(
					convertToPoly sel_geometry
					local first_obj = sel_geometry[1]
					for i=2 to sel_geometry.count do 
					(
						polyOp.attach first_obj sel_geometry[i]
						mcCall.progeressbar (100.*i/sel_geometry.count)
					)
					mcCall.progeressbar 100 close:true
				)
				return first_obj
			) 
			catch (mcCall.popUp "Incorrect objecs!" 3)		
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
		return ls3d_node
	)
	
	fn CloneObjectsInLayer layer_name =
	(
		local source_objects =  GetLayerNodes layer_name
		local cloned_nodes = #()
		maxOps.cloneNodes source_objects cloneType:#copy newNodes:&cloned_nodes #nodialog	
		return cloned_nodes
	)
	
	fn SetupModel temp_model ls3d_node = (
		
		SetPivotToBase temp_model
		temp_model.parent = ls3d_node
		temp_model.material = meditMaterials[2] 
		temp_model.name = "base"
		format "linked objects:% to node:%\n" temp_model.name ls3d_node.name	
	)
	
	fn LS3DExport ls3d_node = (

		select ls3d_node
		gLS3DSmartExport.exportScene()
	)
	
	
	local ls3d_node = UnlinkNode() --unlink all objects from export node
	local clone_nodes  = CloneObjectsInLayer EXPORT_LAYER_NAME  --clone objects in given layer
	local temp_model = CollapseGeometry clone_nodes --merge all cloned geometry
	SetupModel temp_model ls3d_node --add Ls3D material, link to node, 
	LS3DExport ls3d_node --export
	--delete temp_model --delete and temp model
)