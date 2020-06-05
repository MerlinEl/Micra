--------------------------------------------------------------------------------
/* mcMax by Orien 2019 */
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
struct MICRA_MAX_STRUCTURE	(
	
	--variables

	
	--functions
	fn getSource = getSourceFileName(), --get path of this script
	fn alignObject = (max align),
	fn getSelectionType = (
		
		if selection.count == 0 do return "undefined" 
		case subobjectLevel of (
			
			undefined : "objects"
			0	:  "objects"
			1	: "verts"	
			2	: "edges"	
			3	: "edges"
			4	: "faces"
			5	: "faces"
			default : "undefined"
		)
	),
	fn deselectAll = (
		--first exit from any editing mode
		if selection.count > 0 and subObjectLevel != undefined do (
		
			subObjectLevel = 0
		)
		max select none
	),
	fn hideAll = (if (queryBox "Hide All Objects?" title:"Action:") do hide objects; max zoomext sel all),
	fn unhideAll = (if (queryBox "Unhide All Objects?" title:"Action:") do unhide objects; max zoomext sel all),
	fn hideSelected = (hide selection),
	fn unhideSelected = (unhide selection; max zoomext sel),
	fn zoomToSelection = (max zoomext sel),
	fn maxCreateMode = (max create mode),
	fn selectObjectsByName str visibleOnly:true ignoreCase:true exclude:#() method:#any = (

		select ( for o in objects where (
		
			(if visibleOnly then not o.isHidden else true) and --if is visible
			(findString (toUpper o.name) str != undefined) and --if name contains str
			not (mcArray.wordFind exclude o.name ignoreCase:true) --if not excluded
		) collect o )
	),
	fn selectObjectsByMaterial visibleOnly:true = (
	
		local obj = selection[1]
		if obj == undefined or obj.material == undefined do return false
		select ( for o in objects where (
		
			(if visibleOnly then not o.isHidden else true) and
			o.material != undefined and o.material.name == obj.material.name
			
		) collect o )
	),
	fn selectObjectsByMaterialID visibleOnly:true = ( 
	
		local obj = selection[1]
		if obj == undefined or classOf obj != Editable_Poly do return false
		local mat_id = if subobjectLevel == undefined or subObjectLevel == 0 then ( --pick first face matid
		
			polyOp.getFaceMatID obj 1
			
		) else ( --if face selected pick her id 
			
			local fsel = polyOp.getFaceSelection obj as array 
			if fsel.count > 0 then polyOp.getFaceMatID obj fsel[1] else polyOp.getFaceMatID obj 1
		)
		select ( for o in objects where (
		
			(if visibleOnly then not o.isHidden else true) and
			classOf o == Editable_Poly and (
						--format "obj:% a:% b:%\n" o.name mat_id (polyOp.getFaceMatID o 1)
				polyOp.getFaceMatID o 1 == mat_id
			)
			
		) collect o )
	),
	fn isUniqueInstancesSet collection instances = (
		
		local dupes = 0
		for o in instances where findItem collection o do dupes += 1
		dupes == 0
	),
	fn selectUniqueInstances objs appendSingles: false = (
		local collection = #() --all used
		local unique_objs = #() --collect only single objects (no multiple instances)
		if objs.count < 2 do return false
		for o in objs do (
			local object_instances = #()
			InstanceMgr.GetInstances o &object_instances
			--check if we added a instance member already
			if object_instances.count > 1 then ( --add one instance from objects

				if  (isUniqueInstancesSet collection object_instances) do (
					
					append unique_objs (instance o)
				)
				join collection object_instances -- exclude instances from search
			) else (
				if appendSingles do appendIfUnique unique_objs o
				appendIfUnique collection o  -- exclude object from search
			)
		)
		select unique_objs
	),
	fn getetOrCreateLayer layer_name make_active:false = (

		local layer_item = LayerManager.getLayerFromName layer_name --pick layer by name
		if layer_item == undefined do layer_item = LayerManager.newLayerFromName layer_name --create layer if not exists
		if make_active do layer_item.current = true
		layer_item
	),
	fn deleteEmptyLayers = (
	
		if not (queryBox "You are sure to Delete Empty Layers?" title:micra.version) do return false
		local counter = 0
		for id = LayerManager.count - 1 to 1 by -1 do (
		
			local layer = LayerManager.getLayer id
			local contains_nodes = LayerManager.doesLayerHierarchyContainNodes layer.name
			if not contains_nodes then (
			
				local deleted = LayerManager.deleteLayerByName layer.name
				if deleted then counter += 1
			)
		)
		return counter
	)
	/*<end>*/
)	
 --create instance
Global mcMax = mcStructMan.instanceStructure MICRA_MAX_STRUCTURE "mcMax"
