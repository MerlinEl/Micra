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
	SLECT_OBJECT_CALLBACK_ENABLED = true,
	
	--functions
	fn getSource = getSourceFileName(), --get path of this script
	-------------------------------------------------------------
	------              		GET    	                   ------
	-------------------------------------------------------------
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
		
		if obj == undefined do return false
		hasCustomAttribute obj #RoadGenCa
	),
	fn isCrossRoad obj = (
		
		if obj == undefined do return false
		hasCustomAttribute obj #CrossRoadKids
	),
	fn isShortcut obj = (
	
		if obj == undefined do return false
		hasCustomAttribute obj #ShortcutCa
	),
	fn getRestOfKids kids = (
	
		local joiningKids = #() -- hidden points from tangents
		for kid in kids do(
			if kid != undefined then append joiningKids kid.children[1]
			else append joiningKids undefined
		)
		join kids joiningKids
	),
	fn getKidsOfCrossRoad children = (
	
		local childCount = children.count
		local yPoses = #()
		local kids = #() -- list containing normal road points and hidden points
		
		if childCount < 4 then(
			for p in children do append yPoses p.pos.y
			
			thirdPointPos = yPoses[3]
			if thirdPointPos > yPoses[2] then(
				kids[1] = children[1]
				kids[2] = children[2]
				kids[3] = children[3]
				kids[4] = undefined
			)else(
				kids[1] = children[1]
				kids[2] = children[2]
				kids[3] = undefined
				kids[4] = children[3]
			)
		)else(
		
			select children
			kids = selection as Array
		)
		kids = getRestOfKids kids
		kids 
	),
	fn getCAControlsSTR dialog controlsArr = (	
	
		result = ""
		subStr = ""
		
		for cntr in controlsArr do (
			if classof cntr == SpinnerControl then ( 	-- spinner
			
				subStr = dialog.name  + "." + cntr.name + ".value = " + (cntr.value as string)
			)
			
			if classof cntr == CheckBoxControl or classof cntr == RadioControl then( -- checkbox, radiobutton
			
				subStr = dialog.name  + "." + cntr.name + ".state = " + (cntr.state as string)
			)
			
			if classof cntr == ComboBoxControl then (
			
				subStr = dialog.name  + "." + cntr.name + ".selection = " + (cntr.selection as string)
			)
			result += subStr
			result += ";"
		)
		result
	),
	fn getSelectedFacesCenter obj = (
	
		if (classof obj != Editable_poly) do return false
		local fsel = (polyOp.getFaceSelection obj) as Array
		if fsel.count == 0 do return false
		local faceCenter = [0,0,0]
		for f in fsel do faceCenter += polyop.getFaceCenter obj f
		faceCenter / fsel.count
	),
	-------------------------------------------------------------
	------                   SET                           ------
	-------------------------------------------------------------
	fn setRoadCA road rSpline sPoint ePoint dialog controlsArr = (
	
		custAttributes.add road gRoadGenCa #unique --BaseObject:True
		road.roadSpline 	= rSpline
		road.startPoint 	= sPoint
		road.endPoint 		= ePoint
		road.controlsStr	= GetCAControlsSTR dialog controlsArr
		True
	),
	fn setCrossRoadCA road dialog controlsArr = (
	
		custAttributes.add road gCACrossRoadKids #unique
		road.kids = getKidsOfCrossRoad road.children
		road.controlsStr = getCAControlsSTR dialog controlsArr
	),
	fn setShortcutCA road rSpline sPoint ePoint dialog controlsArr = (
	
		custAttributes.add road gShortcutCa #unique
		sPoint.parent = road
		ePoint.parent = road
		rSpline.parent = road
		road.controlsStr = getCAControlsSTR dialog controlsArr
	),
	fn setVertexColor obj clr map_channel = (

		local num_verts = polyop.getNumVerts obj
		for i = 1 to num_verts do polyOp.setVertColor obj map_channel i clr
		update obj
	),
	fn setPointAppearance p = (
	
		p.size = 600
		p.centermarker = off
		p.axistripod = off
		p.cross = on
		p.Box = on
		p.constantscreensize = off
		p.drawontop = off
	-- 	p.wirecolor = color 87 225 87
		p.wirecolor = color 27 177 27
	),
	fn setCrossRoadWireColor crossRoad oldColor:undefined=
	(
		if oldColor != undefined then(
		
			crossRoad.wirecolor = oldColor
			
		) else (
		
		 crossRoad.wirecolor = color 7 206 224
		)
	),
	-------------------------------------------------------------
	------                   REMOVE                        ------
	-------------------------------------------------------------
	/**
	*@Example
		removeCustomAttribute $ #RoadGenCa
	*/
	fn removeCustomAttribute obj attr = (
	
		if not (hasCustomAttribute obj attr) do return false
		local defs = custAttributes.getDefs obj baseObject:true
		for def in defs do(
			
			if def.name == #RoadGenCa do custAttributes.delete obj def baseObject:true
		)
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
	-------------------------------------------------------------
	------                 TRANSFORM                       ------
	-------------------------------------------------------------
	fn reverseArray arr = (
	
		new_arr = #()
		for i in arr.count to 1 by -1 do
		(
			--swap_items arr[i] arr[arr.count-i+1]
			append new_arr arr[i]
		)
		return new_arr
	),
	fn swapPoints p1 p2 = (
	
		local p = p1.pos
		p1.pos = p2.pos
		p2.pos = p
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
	/**
	*@Usage > move tangents from dumy along vector by given distance
	*/
	fn moveTangetPoints dp1 dp2 dist debug:false = (
		
		--collect components
		local tp1 = dp1.children[1]
		local tp2 = dp2.children[1]
		local p1 = dp1.pos
		local p2 = dp2.pos
		--move tangents along vector
		local v1 = normalize( tp1.pos - p1 )
		local v2 = normalize( tp2.pos - p2 )
		tp1.pos = p1 + (v1*dist)
		tp2.pos = p2 + (v2*dist)
		if debug do (
			
			point pos:(p1 + (v1*dist)) wirecolor:red
			point pos:(p2 + (v2*dist)) wirecolor:green
		)
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
	fn setUpCrossRoadPoints max_dist_left max_dist_right c_tangent_offset road:undefined hidden_tn:true= (
	
		local dp1, dp2, tp1, tp2, pRight, pLeft -- dp > dummy(point) tp > tangent(point)
		if road == undefined then ( --create controll points
		
			dp1 = point()
			dp2 = point()
			tp1 = point()
			tp2 = point()
			if hidden_tn do hide #(tp1, tp2)
			SetPointAppearance dp1
			SetPointAppearance dp2
			append dp1.children tp1
			append dp2.children tp2
			
		) else ( --define controll points
		
			pRight 	= road.kids[1]
			pLeft 	= road.kids[2]
			dp1 = pRight
			tp1 = pRight.children[1]
			dp2 = pLeft
			tp2 = pLeft.children[1]
		)
		
		dp1.position = [max_dist_right, 0, 0]
		tp1.position = [max_dist_right+c_tangent_offset, 0, 0]
		dp2.position = [max_dist_left, 0, 0]
		tp2.position = [max_dist_left-c_tangent_offset, 0, 0]
		#(dp1, dp2)
	),
	/**
	*@Usage > make short version of selected road with two connection dummies and convert it to corssroad
	*/
	fn generateRoadShortcut = (
		
		--Compatibility Check
		if (selection as Array).count > 1 do return false		--not applicable if two dummies is selected (this is for road creation)
		local road = selection[1]
		if isRoad road do return false 		--not applicable for Road
		if isCrossRoad road do return false	--not applicable for CrossRoad
		--Define Variables
		local road_thickness = 200
		local min_tangent_dist = 50
		local max_tangent_dist = 1000
		local pts = #(), sp = undefined, finalPos = [0,0,0], dp1, dp2, tp1, tp2 -- dp > dummy(point) tp > tangent(point)
		--Check if Shortcut or geometry is selected
		if isShortcut road then ( --recreate current road
		
			if (road.children.count != 3) do ( 
				
				format "roGenStruct > generateRoadShortcut > Invalid components, use Rad Anatomy to see issues\n" road.name
				return false
			)
			pts = #(road.children[1], road.children[2])
			moveTangetPoints pts[1] pts[2] min_tangent_dist --move tangent points close
			finalPos = road.pos --keep road position
			delete road.children[3] -- delete old spline
			delete road -- delete old road
			
		) else if subobjectlevel == 4 do ( --face(s) is selected (build at place)
		
			finalPos = roGenStruct.getSelectedFacesCenter road --try to get selected faces position
			subobjectlevel = 0 
			max select none
		)
		--create new controll points
		if pts.count != 2 do pts = setUpCrossRoadPoints -road_thickness road_thickness 500 hidden_tn:false	
		--reverse tangents to inner
		swapPoints pts[1] pts[2]
		if not (isShortcut road) do moveTangetPoints pts[1] pts[2] min_tangent_dist --move tangent points close
		SLECT_OBJECT_CALLBACK_ENABLED = false --disable callback before selection
		select pts
		--generate road geometry
		RoadGeneratorTool.btn_generate.pressed() --generate road
		SLECT_OBJECT_CALLBACK_ENABLED = true --enable callback
		--collect components
		road = selection[1]
		sp  = road.roadSpline
		dp1 = road.startPoint
		dp2 = road.endPoint
		-------------------------------
		--convert road in to Shortcut road
		-------------------------------
		swapPoints pts[1] pts[2] --reverse tangents outside
		moveTangetPoints dp1 dp2 max_tangent_dist --move tangent points far
		--remove custom attribute
		removeCustomAttribute road #RoadGenCa
		setShortcutCA road sp dp1 dp2 RoadGeneratorTool RoadGeneratorTool.controlsArr
		road.pos = finalPos
	)	
	/*<end>*/
)	
 --create instance
Global roGenStruct = ROAD_GENERATOR_STRUCTURE()
