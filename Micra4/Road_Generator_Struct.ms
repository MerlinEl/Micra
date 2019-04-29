--------------------------------------------------------------------------------
/* roGenStruct by Orien 2019 */
--------------------------------------------------------------------------------
/*
*@Used Structures
	undefined
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
struct ROAD_GENERATOR_STRUCTURE	(
	
	--variables

	
	--functions
	fn getSource = getSourceFileName(), --get path of this script
	/**
	*@Example
		hasCustomAttribute $ #RoadGenCa
	*/
	fn hasCustomAttribute obj attr = (

		if not (isValidNode obj) do return false 
		local defs = custAttributes.getDefs obj
		if defs == undefined do return false
		for a in defs where a.name == attr do return true
		false
	),
	fn isRoad obj = (
		
		hasCustomAttribute obj #RoadGenCa
	),
	fn isCrossRoad obj = (
		
		hasCustomAttribute obj #CrossRoadKids
	),
	fn deleteLayerByName layer_name forceDelete:false=  (
	
		local layerToDelete = LayerManager.getLayerFromName layer_name--find layer that you need to delate
		if layerToDelete == undefined then (messagebox ("Layer *"+layer_name+"* don't exist!!!") title:"DeleteLayerByName" beep:false) else (
			
			if (LayerManager.current.name) == layer_name do (layermanager.getlayer 0).current = true	--if desired layer is current make default as current
			local layer_nodes
			layerToDelete.nodes &layer_nodes --get layer nodes
			if layer_nodes.count != 0 and not forceDelete then  (messagebox ("Layer *"+layer_name+"* is not empty!!!") title:"DeleteLayerByName" beep:false) else (
				
				for o in layer_nodes where isValidNode o do delete o
				LayerManager.deleteLayerbyname layer_name
			)
		)
	),
	fn reloadPrefabs road_tool_file = (
	
		--close road tool
		try(closeRolloutFloater  ::floaterGenerator)catch()
		--delete layer with components
		deleteLayerByName "---noexport---terrain_generator_helpers" forceDelete:true
		deleteLayerByName "---noexport---terrain_generator_modules" forceDelete:true
		--start tool and load all prefab components
		fileIn road_tool_file
	),
	fn setVertexColor obj clr map_channel = (

		local num_verts = polyop.getNumVerts obj
		for i = 1 to num_verts do polyOp.setVertColor obj map_channel i clr
		update obj
	),
	/** 
	*@Author Petr Čapek 18.4.2019
	*/
	fn fixBrokenCrossroad obj = (
			
		if obj == undefined or findString obj.name "generator_crossroad" == undefined do return false 
		--collect all helpers
		local road_helpers =  for kid in obj.CrossRoadKids.kids where isValidNode kid collect kid 
		if road_helpers.count != 8 do (
			
			format "fixBrokenCrossroad > Unable to fix Cross Road [ % ]. Some helpers is missing.\n" obj.name
			return false
		)
		obj.CrossRoadKids.kids = #() --clear data
		--link all in hierarchy
		for i = 1 to 4 do (
		
			local joint_helper = road_helpers[i]
			local tangent_helper = road_helpers[i+4]
			joint_helper.parent = obj --link joint in to road
			tangent_helper.parent = road_helpers[i] --link tangent helper in to joint
		)
		--fill data
		obj.CrossRoadKids.kids = road_helpers
		format "fixBrokenCrossroad >  Cross Road  [ % ] has been fixed.\n" obj.name
	),
	/**
	*@Usage > make short version of selected road with two connection dummies and convert it to corssroad
	*/
	fn createCrossroadFromRoad obj = (


		format "is road:%\n" (isRoad obj)
	)	
	/*<end>*/
)	
 --create instance
Global roGenStruct = ROAD_GENERATOR_STRUCTURE()
