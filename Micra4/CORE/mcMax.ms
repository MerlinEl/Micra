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
	fn selectObjectsByName str visibleOnly:true ignoreCase:true method:#any = (

		select ( for o in objects where (
		
			(if visibleOnly then not o.isHidden else true) and
			findString (toUpper o.name) str != undefined
			
		) collect o )
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
