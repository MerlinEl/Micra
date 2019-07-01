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
	All_CALLBACKS_ENABLED = true,
	TANGENT_TEST_COUNT = 100,
	C_LAYER_NAME = "---noexport---terrain_generator_modules",
	H_LAYER_NAME = "---noexport---terrain_generator_helpers",
	--functions
	fn getSource = getSourceFileName(), --get path of this script
	-------------------------------------------------------------
	-------------------------------------------------------------
	------              		GET    	                   ------
	-------------------------------------------------------------
	-------------------------------------------------------------
	fn isAnyUndefined obj_arr = (
	
		for o in obj_arr where o == undefined do exit with true
		false
	),
	fn isObjectWithDuplicateName obj = (
	
	
		local identical_names =  0
		for o in objects where obj.name == o.name do identical_names += 1
		identical_names > 1
	),
	/**
	*@Example
		roGenStruct.hasCustomAttribute $ #RoadGenCa
	*/
	fn hasCustomAttribute obj attr = (

		if not (isValidNode obj) do return false 
		local defs = custAttributes.getDefs obj
		if defs == undefined do return false
		for a in defs where a.name == attr do return true
		false
	),
	fn isJoint obj = (

		classOf obj == Point and obj.children.count == 1
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
	/** 
	*@Usage > get constrained object by type [ spline path ] from [ shortcut or road ]
	*@Example	
		roGenStruct.getConstraintObject obj SplineShape
	*/
	fn getConstraintObject obj_src node_type = (
	
	-- obj_src.controller.getNode 1
		local obj = for o in refs.dependentnodes obj_src where classOf o == node_type do exit with o
		if isValidNode obj then obj else undefined
	),
	fn isValidShortcut obj = (
	
		local sPoint	= obj.children[1]
		local ePoint	= obj.children[2]
		local rSpline= getConstraintObject obj SplineShape
		if rSpline == undefined or sPoint == undefined or ePoint == undefined do (
		
			format "Error: Unable to clone Shortcut: Missing components A.\n"
			return false
		)
		local tn1		= sPoint.children[1]
		local tn2		= ePoint.children[1]
		if tn1 == undefined or tn2 == undefined do (
		
			format "Error: Unable to clone Shortcut: Missing components B.\n"
			return false
		)
		true
	),
	/**
	*@Usage  ASCII Signs Generator
	*@Example
		getRoadSymbol #("a", "a", "r", "s", "r", "a", "a")
		"▄▄⽬⽬▄▄"
	*/
	fn getRoadSymbol arr = (

		local str = ""
		for char in arr do (

			case char of (
			
				"a"	:	str += bit.intAsChar 9604 --road
				"r"	:	str += bit.intAsChar 12140 --rails
				"s"	:	str += " "
			)
		)
		str
	),
	/**
	*@Usage	> Generate ASCII Icons List
		a = road
		r = rails
		s = space
	*/
	fn getUIPrefabsIcons = (

		/*#(
			"(1-6)     "	+ getRoadSymbol #("a", "a") ,								   							   
			"(2-2)R   "	+ getRoadSymbol #("a", "a", "r", "s", "r", "a", "a") ,
			"(2-4)     "	+ getRoadSymbol #("a", "a", "s", "a", "a") ,
			"(2-4)R   "	+ getRoadSymbol #("a", "a", "r", "s", "r", "a", "a") ,
			"(2-5)     "	+ getRoadSymbol #("a", "a", "s", "a", "a"),
			"(4-4)    "		+ getRoadSymbol #("a", "a", "s", "a", "a", "s", "a", "a", "s", "a", "a") ,
			"(4-5)    "		+ getRoadSymbol #("a", "a", "s", "a", "a", "s", "a", "a", "s", "a", "a"),
			--new 2019
			"(1-6)D   "	+ getRoadSymbol #("a", "a") ,	
			"(2-6)D  "		+ getRoadSymbol #("a", "a", "s", "a", "a"),
			"(2-6)C  "		+ getRoadSymbol #("a", "a", "s", "a", "a")
		)*/
		
		#(
			"(1-6)                      "	+ getRoadSymbol #("a", "a", "a", "a", "a", "a") ,																		--1					   							   
			"(2-2)R                   "	+ getRoadSymbol #("a", "a", "r", "s", "r", "a", "a") ,																		--2
			"(2-4)                   "		+ getRoadSymbol #("a", "a", "a", "a", "s", "a", "a", "a", "a") ,															--3
			"(2-4)R                "		+ getRoadSymbol #("a", "a", "a", "a", "r", "s", "r", "a", "a", "a", "a") ,													--4
			"(2-5)                "		+ getRoadSymbol #("a", "a", "a", "a", "a", "s", "a", "a", "a", "a", "a"),														--5
			"(4-4)       "			+ getRoadSymbol #("a", "a", "a", "a", "s", "a", "a", "a", "a", "s", "a", "a", "a", "a", "s", "a", "a", "a", "a") ,					--6
			"(4-5)  "				+ getRoadSymbol #("a", "a", "a", "a", "a", "s", "a", "a", "a", "a", "a", "s", "a", "a", "a", "a", "a", "s", "a", "a", "a", "a", "a"),	--7
			"(1-6D)                      "	+ getRoadSymbol #("a", "a", "a", "a", "a", "a") ,																		--8
			"(2-6D)                "		+ getRoadSymbol #("a", "a", "a", "a", "a", "a", "s", "a", "a", "a", "a", "a", "a"),												--9
			"(2-6C)                "		+ getRoadSymbol #("a", "a", "a", "a", "a", "a", "s", "a", "a", "a", "a", "a", "a"),												--10
			"(2-4S)                "		+ getRoadSymbol #("a", "a", "a", "a", "s", "a", "a", "a", "a")																--11
		)	
	),
	fn getMissingPrefabs = (
	
		local prefabs_list = #( -- to do add spec files for new prefabs
		
			--road types
			"generator_road_1_6",
			"generator_road_2_2_rail",
			"generator_road_2_4",
			"generator_road_2_4_spec",
			"generator_road_2_4_rail",
			"generator_road_2_5",
			"generator_road_2_5_spec",
			"generator_road_4_4",
			"generator_road_4_5",
			"generator_road_4_5_spec",
			--road types new 2019
			"generator_road_1_6d",
			"generator_road_2_6d",
			"generator_road_2_6c",
			"generator_road_2_4s",
			--sidewalks
			"generator_sidewalk_left",
			"generator_sidewalk_right",
			--corners
			"generator_corner",
			"generator_corner_p",
			--parking lanes
			"generator_parking_lane_left",
			"generator_parking_lane_right"
		)
		for n in prefabs_list where (getNodeByName n == undefined) collect n
	),
	fn collectAllPrefabs &roads &sidewalks &corners &parking_lanes = (
	
		--road types
		append roads $generator_road_1_6		--1
		append roads $generator_road_2_2_rail	--2
		append roads $generator_road_2_4		--3
		append roads $generator_road_2_4_rail	--4	
		append roads $generator_road_2_5		--5
		append roads $generator_road_4_4		--6
		append roads $generator_road_4_5		--7
		--road types new 2019
		append roads $generator_road_1_6d		--8
		append roads $generator_road_2_6d		--9
		append roads $generator_road_2_6c		--10
		append roads $generator_road_2_4s		--11
		--sidewalks
		append sidewalks $generator_sidewalk_left
		append sidewalks $generator_sidewalk_right
		--corners
		append corners $generator_corner
		append corners $generator_corner_p
		--parking lanes
		append parking_lanes $generator_parking_lane_left
		append parking_lanes $generator_parking_lane_right
	),
	fn collectRoadPrefabs &roads &specs = ( --order must be same like in rollout RoadGeneratorTool > dd_road_prefabs_1

		--road types
		append roads $generator_road_1_6		--1
		append roads $generator_road_2_2_rail	--2
		append roads $generator_road_2_4		--3
		append roads $generator_road_2_4_rail	--4
		append roads $generator_road_2_5		--5
		append roads $generator_road_4_4		--6
		append roads $generator_road_4_5		--7
		--road types new 2019
		append roads $generator_road_1_6d		--8
		append roads $generator_road_2_6d		--9
		append roads $generator_road_2_6c		--10
		append roads $generator_road_2_4s		--11
		--sidewalks and parking places
		append specs $generator_parking_lane_left
		append specs $generator_parking_lane_right
		append specs $generator_sidewalk_left
		append specs $generator_sidewalk_right
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
	fn getVertsCenter obj verts = (
	
		local center = [0,0,0]
		for v in verts do center += polyop.getVert obj v
		center /= verts.count
		center
	),
	fn getFaceCenter obj f_index = (
		
		local verts = polyop.getFaceVerts obj f_index
		getVertsCenter obj verts
	),
	fn getSelectedFacesCenter obj = (
	
		if (classof obj != Editable_poly) do return undefined
		local fsel = (polyOp.getFaceSelection obj) as Array
		if fsel.count == 0 do return undefined
		local faceCenter = [0,0,0]
		for f in fsel do faceCenter += polyop.getFaceCenter obj f
		faceCenter / fsel.count
	),
	fn getClosestVert obj_poly pos maxDist:undefined = (
	
		local vert, dist = if maxDist != undefined then maxDist else 1e9
		local d, obj_mesh = snapshotasmesh obj_poly
		local verts = #{1..obj_mesh.numverts}
		for v in verts where (d = distance (getvert obj_mesh v) pos) < dist do (
			
			vert = v
			dist = d
		)
		#(vert, dist)
	),
	fn isBorderEdge obj e_index = (
	
		local efaces = polyop.getFacesUsingEdge obj e_index
		efaces.numberset == 1
	),
	fn getBorderEdgesFromVertex obj v_index = (
		
		local edges = polyop.getEdgesUsingVert obj v_index
		for ei in edges where isBorderEdge obj ei collect ei	
	),
	fn alignRoadToNormal obj joint_pos tangent_pos = (
	
		--snap road to joint (adjust pivot to start midle vertex)
		local center_vert = (getClosestVert obj joint_pos)[1] 
		obj.pivot = polyop.getVert obj center_vert
		obj.pos = joint_pos
		-- transform matrix vectors for road (align road to tangent)
		local t_x = normalize (tangent_pos-joint_pos)
		local t_y = normalize([-t_x.y, t_x.x, 0.0])
		local t_z = cross t_x t_y
		
		local tm = obj.transform
		tm.row1 = t_x
		tm.row2 = t_y
		tm.row3 = t_z	
		obj.transform = tm
	),
	/**
	*@Usage > get road edge(at start or end) vertices and positions
	*/
	fn getRoadEdge obj joint_pos = (
		
		local center_vert = (getClosestVert obj joint_pos)[1] 
		local border_edges = getBorderEdgesFromVertex obj center_vert
		obj.selectedEdges = border_edges
		obj.SelectEdgeLoop() --border edges
		local border_vertices = polyop.getVertsUsingEdge obj (polyOp.getEdgeSelection obj) --get border vertices
		local vd = struct VERTEX_DATA (index, pos)
		for v in border_vertices collect vd v (polyOp.getVert obj v) --gather verts_data
	),
	fn getLongestEdge obj edges = ( --Not Used

		local ed = ( struct EDGE_DATA (index, length) ; EDGE_DATA() ) --quick object instance build
		for edge_index in edges do (

			local everts = polyOp.getEdgeVerts obj edge_index
			local len = distance (polyOp.getVert obj everts[1]) (polyOp.getVert obj everts[2])
			if ed.length < len do (
			
				ed.index = edge_index
				ed.length = len
			)
		)
		ed --return edge index and length
	),
	fn getBoundingBox &poly = (
	
		local p_min = [C_FLOAT_MAX, C_FLOAT_MAX, C_FLOAT_MAX]
		local p_max = [-C_FLOAT_MAX, -C_FLOAT_MAX, -C_FLOAT_MAX]

		--go through all vertices and find min and max
		local numVert = poly.GetNumVertices()
		for i in 1 to numVert do
		(
			if not (polyop.isVertDead poly i) then (
				v = poly.GetVertex i
				p_min = [RMin p_min.x v.x, RMin p_min.y v.y, RMin p_min.z v.z]
				p_max = [RMax p_max.x v.x, RMax p_max.y v.y, RMax p_max.z v.z]
			)
		)
		
		bb = #(p_min, p_max)
		--print ("BB: "+(getWidthBB bb as string)+" "+(GetLengthBB bb as string)+" "+(GetHeightBB bb as string))
		--print ("Bottom: "+(GetBottomBB bb as string)+" "+(GetTopBB bb as string))	
		return bb
	),
	--get width of bounding box
	fn getWidthBB bb		=(return abs(bb[2].x - bb[1].x)),
	--get length of bounding box
	fn getLengthBB bb	=(return abs (bb[2].y - bb[1].y)),
	--get height of bounding box
	fn getHeightBB bb	=(return abs (bb[2].z - bb[1].z)),
	fn getBottomBB bb	=(return bb[1].z),
	fn getTopBB bb		=(return bb[2].z),
	fn getFrontBB bb		=(return bb[1].y),
	fn getLeftBB bb		=(return bb[1].x),
	fn getRightBB bb		=(return bb[2].x),
	fn getNeighborsVertsOnLoop obj verts_arr vertMask:#{} = (
	
		local vert_a_edges = polyop.getEdgesUsingVert obj verts_arr[1]
		local vert_b_edges = polyop.getEdgesUsingVert obj verts_arr[2]
		local everts_a = polyop.getVertsUsingEdge obj vert_a_edges
		local everts_b = polyop.getVertsUsingEdge obj vert_b_edges
		local two_verts = everts_a + everts_b
		if vertMask.numberset > 0 do two_verts *= vertMask	
		two_verts -= verts_arr as BitArray --remove previous verts	
		-- format "mask:%\ntwo_verts:%\n" vertMask two_verts	
		two_verts as Array
	),
	fn getVectorsAngle v1 v2 = ( acos(dot (normalize v1) (normalize v2))),
	fn getRoadFaceCenterDistances editable =
	(
		face_count = polyop.getNumFaces editable
		face_offsets = #()
		for i in 1 to face_count do
		(
			face_center = getFaceCenter editable i
			--pt = point()
			--pt.position = face_center
	-- 		print ("Face center: "+pt as string)
			dist = length (editable.position-face_center)
			append face_offsets ((dot (normalize(editable.position-face_center)) [0,1,0]) * dist)
		)
		return face_offsets
	),
	fn getRoadFaceCenters editable =
	(
		face_count = polyop.getNumFaces editable
		face_offsets = #()
		for i in 1 to face_count do
		(
			face_center = getFaceCenter editable i
			--pt = point()
			--pt.position = face_center
	-- 		print ("Face center: "+pt as string)
			face_center_origin = (face_center-editable.position)
			normal = polyop.getFaceNormal editable i
			append face_offsets #(face_center_origin+5.0*normal, -polyop.getFaceNormal editable i)
		)
		return face_offsets
	),
	fn getMeshFaceToPoly epoly mesh_face = (
	-- 	print ("Mesh available: "+(epoly.mesh != undefined) as string)
		-- get polys for this face
		local mesh_polys = meshop.getpolysusingface epoly.mesh #{mesh_face} threshhold:360
		-- get verts using these polys
		local mesh_verts = meshop.getvertsusingface epoly.mesh mesh_polys

		-- get polys in editable_poly using these verts
		local vert_polys = (polyop.getfacesusingvert epoly mesh_verts) as array
		local p = 1
		local poly_verts

		-- poly index returned by this function
		local poly = undefined

		-- find poly
		while p <= vert_polys.count do
		(
			-- get verts from poly
			poly_verts = polyop.getvertsusingface epoly vert_polys[p]
			
			-- same number of vertices?
			if (poly_verts as array).count == (mesh_verts as array).count do
			(
				-- intersecting the bitarray should result in array of identical size
				if ((poly_verts + mesh_verts) as array).count == (mesh_verts as array).count then
				(
					-- poly found!
					poly = vert_polys[p]
					-- exit the loop
					p = vert_polys.count + 1
				)
			)

			-- check next poly
			p += 1
		)
		poly -- return the found poly (undefined if not found)
	),
	fn getMeshFacesToPoly epoly mesh_faces = (
	
		face_indices = #()
		for i in 1 to mesh_faces.count do
		(
			append face_indices (GetMeshFaceToPoly epoly mesh_faces[i])
		)
		
		return face_indices
	),
	fn findAllIntersectionsUsingRays mpoly rays = (
	
		local rm = RayMeshGridIntersect()
		rm.Initialize 10
		rm.AddNode mpoly
		rm.buildGrid()
		
		local hit_array = #()
		for i in 1 to rays.count do
		(
			hit_count = rm.intersectRay rays[i].pos rays[i].dir true
			--drawLineBetweenTwoPoints rayOrigin (rayOrigin+dir*50.0) (color 0 0 255)
	-- 		print("Hit count: "+hit_count as string)
			if(hit_count > 0) then (
				hit_index = rm.getClosestHit()
				face_index = rm.getHitFace hit_index
				append hit_array face_index
			)
		)
		--free all resources
		rm.Free()
		--return result
		return hit_array
	),
	/**
	*@Usage find which splines using same road
	*@Example
		select (roGenStruct.getSplinesUsingRoad $)
	*/
	fn getSplinesUsingRoad road = (

		for o in objects where (

			classOf o == SplineShape and 
				isProperty o "road" and 
					o.road == road.name
		) collect o
	),
	fn getRoadComponents obj = (
	
		if not (isRoad obj) do return #()
		local sp = obj.roadSpline
		local p1 = obj.startPoint
		local p2 = obj.endPoint
		local t1 = p1.children[1]
		local t2 = p2.children[1]
		#(p1, p2, t1, t2, sp)
	),
	/**
	*@Usage > Collect all components from given objects
	*@Example 
		roGenStruct.getAllComponents (selection as Array)
	*/
	fn getAllComponents obj_arr = (

		local all_components = #()
		for o in selection do (

			append all_components o
			if isRoad o do join all_components (getRoadComponents o)
			if isCrossRoad do ()
			if isShortcut do ()
		)
		for o in all_components where isValidNode o collect o --return only validated objects
	),
	/**
	*@Usage > Get layer by name. If not found and create is set to true create new one.
	*@Example
		roGenStruct.getLayerByName "01_test" create:true
	*/
	fn getLayerByName layer_name create:false = (
	
		local layer = LayerManager.getLayerFromName layer_name --pick layer by name
		if layer == undefined and create then (
		
			layer = LayerManager.newLayerFromName layer_name --create layer
		)
		layer
	),
	-------------------------------------------------------------
	-------------------------------------------------------------
	------                   SET                           ------
	-------------------------------------------------------------
	-------------------------------------------------------------
	/**
	*@Example	
		roGenStruct.setObjectUniqueName $
	*/
	fn setObjectUniqueName obj debug:false = (
	
		local old_name = obj.name
		local new_name = uniqueName old_name
		obj.name = new_name
		if debug do format "setObjectUniqueName > Node: [ % ] has been Renamed to  [ % ]\n" old_name new_name
		new_name
	),
	fn fixDuplicitNames debug:false = (
	-- 		SelectVisuals()
		local sel = selection as Array
		local succes = 0
		local failed = #()
		for o in sel do (
			
			setObjectUniqueName o debug:debug 
			
			--update spline attribute
			if isRoad o and isProperty o "roadSpline" then (
			
				local spline = o.roadSpline
				if spline != undefined and isProperty spline "road" then (spline.road = o.name) else (
				
					append failed o
					format "fixDuplicitNames > failed at:%\n" o.name
					continue
				) 
				
			) else if isShortcut o then (
			
				local spline = roGenStruct.getConstraintObject o SplineShape
				if spline != undefined and isProperty spline "road" then (spline.road = o.name) else (
				
					append failed o
					format "fixDuplicitNames > failed at:%\n" o.name
					continue
				)
				
			) else (
		
				append failed o
				format "fixDuplicitNames > failed at:%\n" o.name
				continue
			)
			succes += 1
		)
		select failed
		MessageBox ("Finished with  result:"+succes as string + " / " + sel.count as string) title:"Fix Duplicit Names:"
	),
	fn showObjectsByNamePart obj_array name_part state = (
		
		for o in obj_array where findString o.name name_part != undefined do o.isHidden = not state
	),
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
	fn setShortcutCA road dialog controlsArr = (
	
		custAttributes.add road gShortcutCa #unique
		road.controlsStr = getCAControlsSTR dialog controlsArr
	),
	fn setVertexColor obj clr map_channel = (

		local num_verts = polyop.getNumVerts obj
		for i = 1 to num_verts do polyOp.setVertColor obj map_channel i clr
		update obj
	),
	fn setRoadBoundVerts obj verts_data = (
	
		ConvertTo obj Editable_Poly
		for v in verts_data do polyOp.setVert obj v.index v.pos
		
		completeRedraw()
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
	fn pickRoadPrefab roads dd_selection spec = (	
	
		local roadPointer = dd_selection
		roads[roadPointer]
	),
	/** 
	*@Usage > link constrain [ spline path ] to [ shortcut or road ]
	*/
	fn linkConstraint obj_target obj_source = (
		
		obj_source.controller = link_constraint()
		obj_source.controller.addTarget obj_target 1 --at frame 1
	),
	fn hideHelpPoints = (
	
		for obj in geometry do(
		
			if matchPattern obj.name pattern:"generator_crossroad*"do (
			
				for kid in obj.children do hide kid.children
			)
		)	
	),
	fn selectVisuals = (
			
		local roadsCrossToselect = #()
		for obj in geometry do(
		
			local crossForuCheck 	= matchPattern obj.name pattern:"generator_crossroad_4*"
			local crossThreeCheck	= matchPattern obj.name pattern:"generator_crossroad_3*"
			local roadCheck			= matchPattern obj.name pattern:"generator_connect_road*"
			local customRoadCheck	= matchPattern obj.name pattern:"custom_road*"
			
			if crossForuCheck or crossThreeCheck or roadCheck or customRoadCheck then(
				append roadsCrossToselect obj
			)
		)
		if keyboard.controlPressed then(
			sel = selection as Array
			join roadsCrossToselect sel
			select roadsCrossToselect
		)
		
		select roadsCrossToselect
	),
	fn selectCollisions = (
	
		local roadsCollsToselect = #()
		for obj in geometry do(
		
			local crossForuCheck 	= matchPattern obj.name pattern:"coll_generator_crossroad_4*"
			local crossThreeCheck	= matchPattern obj.name pattern:"coll_generator_crossroad_3*"
			local roadCheck			= matchPattern obj.name pattern:"coll_generator_connect_road*"
			local customRoadCheck	= matchPattern obj.name pattern:"coll_custom_road*"
			
			if  crossForuCheck or crossThreeCheck or roadCheck or customRoadCheck then(
				append roadsCollsToselect obj
			)
		)
		
		if keyboard.controlPressed then(
			sel = selection as Array
			join roadsCollsToselect sel
			select roadsCollsToselect
		)
		
		select roadsCollsToselect
	),
	fn selectChildren = (
		
		local sel = selection as Array
		local addSel = #()
		for obj in sel do (
		
			crossForuCheck 	= matchPattern obj.name pattern:"generator_crossroad_4*"
			crossThreeCheck	= matchPattern obj.name pattern:"generator_crossroad_3*"
			roadCheck		= matchPattern obj.name pattern:"generator_connect_road*"
			if crossForuCheck or crossThreeCheck then(
				objChildren = obj.children
				for child in objChildren do(
					append addSel child
					append addSel child.children[1]
				)			
			)
			
			if roadCheck then append addSel obj.roadSpline
		)
		join sel addSel
		select sel
	),
	fn selectUnlinkedRoads = (

		selectVisuals()
		local orphaned_roads = for o in selection where o.parent == undefined collect o
		max select none
		select orphaned_roads
		local msg = ""
		for o in orphaned_roads do msg += (o.name + "\n")
		messageBox ("Selected Orphaned Roads("+orphaned_roads.count as String+")\n"+msg) title:"Search Orphaned Roads:"
	),
	fn unhideRoadsFull = (
		
		undo "Unhide Roads" on (
		
			selectVisuals()
			for o in selection do (

				o.isHidden = false --unhide roads geometry
				for c1 in o.children do (

					c1.isHidden = false --unhide joint dummyes
					for c2 in c1.children do (

						c2.isHidden = false --unhide tangent points
					)
				)
			)
			for o in objects where classOf o == SplineShape do unhide o
		)
	),
	/**
	*@Usage 
		check for missing roads components
		move existing components in same layer
	*@Example
		roGenStruct.validateSelectedRoads()
	*/
	fn validateSelectedRoads = (
	
		for o in selection do (
				
			local layer = o.layer
			format "Check road:% status:" o.name
			if isRoad o then (
			
				local spline = o.roadSpline
				if spline == undefined then (
				
					format "Error > Missing spline in road:[ % ]\n" o.name
					
					)else (
					
					layer.addNode spline
					format "OK\n"
				)
				
			) else if isCrossRoad o then (
			
				local joints = o.children
				if joints.count != 4 then (
				
					format "Error > Missing joints in cross_road:[ % ]\n" o.name
					
				) else (
				
					for jo in joints do (
						
						layer.addNode jo
						local tangent_point = jo.children[1]
						if tangent_point == undefined then (
						
							format "Error > Missing tangents in cross_road:[ % ]\n" o.name
							
						) else (
						
							layer.addNode tangent_point
						)
					)
					format "OK\n"
				)
			) else if isShortcut o do (
				
				local joints = o.children
				local spline_path = getConstraintObject o SplineShape
				if spline_path == undefined then (
				
					format "Error > Missing spline in shortcut_road:[ % ]\n" o.name
					
				) else if joints.count != 2 then (
				
					format "Error > Missing joints [ % ] in shortcut_road:[ % ]\n" joints o.name
					
				) else (
					
					layer.addNode spline_path
					for jo in joints do (
						
						layer.addNode jo
						local tangent_point = jo.children[1]
						if tangent_point == undefined then (
						
							format "Error > Missing tangents in shortcut_road:[ % ]\n" o.name
							
						) else (
						
							layer.addNode tangent_point
						)
					)
					format "OK\n"
				)
			)
		)
	),
	/**
	*@Usage > Move each object in to layer(name is teaken from node name)
	*@Info
		jmenové konvence
		
		layer_model	= lh_06_downtown_block_h_terrain
		layer_coll	= lh_06_downtown_block_h_terrain_coll
		
		node_model	= lh_06_downtown_block_h_geometry
		node_coll	= lh_06_downtown_block_h_coll
	*/
	fn distributeRoadsInToLayers = (
	
		for o in selection do (
		
			local parent_node = o.parent --lh_07_hoboken_block_c_geometry
			if classOf parent_node != LS3DModel do (
			
				format "Skipped road [ % ] which is not linked to node.\n" o.name 
				continue
			)
			--bug (do not use as parameter "_ge" only "ge")
			-- trimRight "lh_07_hoboken_block_e_geometry" "_geometry"
			-- lh_07_hoboken_block --missing _e
			--https://regex101.com/
			--recreate this function TODO
			local layer_name = trimRight parent_node.name "geometry" --lh_07_hoboken_block_c_
			layer_name += "terrain"
			format "Validate road [ % ]\n\tmoving to layer:%\n\tlinked to node:%\n" o.name layer_name parent_node.name
			local layer = getLayerByName layer_name create:true
			layer.addNode o
		)
	),
	/**
	*@Example
		roGenStruct.selectAllRoads()
		roGenStruct.selectAllCrossroads()
		roGenStruct.selectAllShortcuts()
	*/
	fn selectAllRoads = (
	
		select(for o in objects where isRoad o collect o)
	),
	fn selectAllCrossroads = (
	
		select(for o in objects where isCrossroad o collect o)
	),
	fn selectAllShortcuts = (
	
		select(for o in objects where isShortcut o collect o)
	),
	-------------------------------------------------------------
	-------------------------------------------------------------
	------                   REMOVE                        ------
	-------------------------------------------------------------
	-------------------------------------------------------------
	/**
	*@Example
		removeCustomAttribute $ #RoadGenCa
	*/
	fn deleteCrossRoadChildren obj = (
	
		local crossChildren = obj.kids
		local crossCount = crossChildren.count
		for i in crossCount to 1 by -1 do(
			if isValidNode crossChildren[i] then delete crossChildren[i]

		)
	),
	fn removeCustomAttribute obj attr = (
	
		if not (hasCustomAttribute obj attr) do return false
		local defs = custAttributes.getDefs obj baseObject:true
		for def in defs do(
			
			if def.name == #RoadGenCa do custAttributes.delete obj def baseObject:true
		)
	),
	fn removeAllCustomAttributes obj = (
	
		for i = custAttributes.count obj to 1 by -1 do custAttributes.delete obj i
	),
	fn deleteLayerByName layer_name forceDelete:false=  (
	
		local layerToDelete = LayerManager.getLayerFromName layer_name--find layer that you need to delate
		if layerToDelete != undefined then (
		
			if (LayerManager.current.name) == layer_name do (layermanager.getlayer 0).current = true	--if desired layer is current make default as current
			local layer_nodes
			layerToDelete.nodes &layer_nodes --get layer nodes
			if layer_nodes.count != 0 and not forceDelete then  (messagebox ("Layer *"+layer_name+"* is not empty!!!") title:"DeleteLayerByName" beep:false) else (
				
				for o in layer_nodes where isValidNode o do delete o
				LayerManager.deleteLayerbyname layer_name --return true or false
			)
		) else (
		
			false --return false if layer not found
		)
	),
	-------------------------------------------------------------
	-------------------------------------------------------------
	------                 TRANSFORM                       ------
	-------------------------------------------------------------
	-------------------------------------------------------------
	fn arrayToString arr formated:true = ( --for debug or message

		local str = ""
		for o in arr do str += ("\t" + o as string +"\n")
		str
	),
	fn weldEditPoly epoly precision = (
	
		local all_vert_list = #{1..(polyop.getNumVerts epoly)}
		epoly.weldThreshold = precision
		polyop.weldVertsByThreshold epoly all_vert_list --weld all vertices
	),
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
	fn rotateVectorAroundNormal v deg = (
	
		local rm = rotateZMatrix deg --create a rotation matrix from the value
		v * rm --transform the original vector using the matrix
	),
	fn rotateVertexAroundZBackward obj v_index center p2 = (
		
		local p1 = polyop.getVert obj v_index
		local v1 = p1 - center
		local v2 = p2 - center
		local vert_angle = getVectorsAngle v1 v2
		local rotated_vector = rotateVectorAroundNormal v1 -vert_angle
		polyOp.setVert obj v_index ( center + rotated_vector)
	),	
	/**
	*@Example 
		roGenStruct.rotateVerticesAroundPoint $ (polyop.getVertSelection $) 20
	*/
	fn rotateVerticesAroundPoint obj verts deg center:undefined = (
		
		--if center is not defined, calculate vertex center
		if center == undefined do getVertsCenter obj verts
		local tm = obj.transform --get the node's TM 
		tm.row4 = center  --move the TM to the center Orientation of local Z remains the same!
		local rot_mat = (rotateZMatrix deg) * tm  --rotation matrix is now in local coords!
		for v in verts do  (
			in coordsys tm vertex_position = (polyop.getVert obj v) 
			polyop.setVert obj v (vertex_position * rot_mat ) 
		)
	),
	fn loadPrefabs road_tool_file = (
	
		local layer_components	= LayerManager.getLayerFromName C_LAYER_NAME
		local layer_helpers		= LayerManager.getLayerFromName H_LAYER_NAME
		deleteLayerByName C_LAYER_NAME forceDelete:true --clear old layer if exist
		deleteLayerByName H_LAYER_NAME forceDelete:true --clear old layer if exist
		
		mergemaxfile road_tool_file --merge prefabs from file
		
		--check it again
		layer_components	= LayerManager.getLayerFromName roGenStruct.C_LAYER_NAME
		layer_helpers 		= LayerManager.getLayerFromName roGenStruct.H_LAYER_NAME
		missing_prefabs 	= roGenStruct.getMissingPrefabs()

		if layer_components == undefined or layer_helpers == undefined or missing_prefabs.count > 0 do (
		
			return missing_prefabs --return missing prefabs array
		
		)
		--hide prefabs layers
		layer_components.isHidden	= true
		layer_helpers.isHidden 		= true
		#() --return missing 0
	),
	fn reloadPrefabs road_tool_file = (
	
		--close road tool
		try(closeRolloutFloater  ::floaterGenerator)catch()
		--delete layer with components
		deleteLayerByName H_LAYER_NAME forceDelete:true
		deleteLayerByName C_LAYER_NAME forceDelete:true
		--start tool and load all prefab components
		fileIn road_tool_file
	),
	fn validatePrefabs road_tool_file = (
	
		local missing_prefabs	 = getMissingPrefabs()
		if missing_prefabs.count > 0 do (

			missing_prefabs = loadPrefabs road_tool_file --merge prefabs from file
			if missing_prefabs.count > 0 do (

				MessageBox ("( "+missing_prefabs.count as string+" ) Missing prefabs >\n" + (arrayToString missing_prefabs)) title:"Unable start Road Tool:"
				return false
			)
		)
		format "roGenStruct > validatePrefabs > Success!\n"
		true
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
	*@Example
		roGenStruct.fixBrokenCrossroad $
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
	*@Example
		roGenStruct.fixBrokenRoad dp1:$Point819 dp2:$Point805 sp:$Shape394
	*/
	fn fixBrokenRoad obj:undefined dp1:undefined dp2:undefined sp:undefined = (

		local dialog = RoadGeneratorTool
		--check model
		if classOf obj != Editable_poly do obj = selection[1] --try to pic selected shortcut
		if classOf obj != Editable_poly do (

			format "fixShortcut > Unable to fix shortcut. Shortcut mesh not found."
			return false
		)
		--check joints
		if classOf dp1 != Point or classOf dp2 != Point do (

			format "fixShortcut > Unable to fix shortcut. Joints are not found."
			return false
		)
		--check spline
		if classOf sp != SplineShape do (

			format "fixShortcut > Unable to fix shortcut. Spline are not found."
			return false
		)
		--add attribute
		roGenStruct.removeAllCustomAttributes obj
		setRoadCA obj sp dp1 dp2 dialog dialog.controlsArr
		custAttributes.add sp gSplineGenCa #unique
		sp.road = obj.name
	),
	/**
	*@Usage Revert Road back in to Shortcut when is STOLEN.
	*/
	fn convertRoadToShortcut road joint_start joint_end path_spline = (
	
		if isAnyUndefined #(road, joint_start, joint_end, path_spline) do return false 
		road.name = uniqueName road.name--create unique name
		path_spline.road = road.name --replace road name
		roGenStruct.removeAllCustomAttributes obj --remove all attributes
		local dialog = ::RoadGeneratorTool
		setShortcutCA road dialog dialog.controlsArr --add shortcut attribute
		--link spline and joints
		linkConstraint road path_spline	
		joint_start.parent = road
		joint_end.parent = road
	),
	/**
	*@Example
		roGenStruct.fixBrokenShortcut sp:$Shape401
		roGenStruct.fixBrokenShortcut obj:$
	*/
	fn fixBrokenShortcut obj:undefined dp1:undefined dp2:undefined sp:undefined = (

		local dialog = ::RoadGeneratorTool
		--check model
		if classOf obj != Editable_poly do obj = selection[1] --try to pic selected shortcut
		if classOf obj != Editable_poly do (

			format "fixShortcut > Unable to fix shortcut. Shortcut mesh not found."
			return false
		)
		--check joints
		if classOf dp1 != Point do if obj.children.count > 0 do dp1 = obj.children[1]
		if classOf dp2 != Point do if obj.children.count > 1 do dp2 = obj.children[2]
		if classOf dp1 != Point or classOf dp2 != Point do (

			format "fixShortcut > Unable to fix shortcut. Joints are not found."
			return false
		)
		--check spline
		if classOf sp != SplineShape do sp = getConstraintObject obj SplineShape
		if classOf sp != SplineShape do (

			format "fixShortcut > Unable to fix shortcut. Spline are not found."
			return false
		)
		--add attribute
		roGenStruct.removeAllCustomAttributes obj
		setShortcutCA obj dialog dialog.controlsArr
		if classOf sp.controller == Link_Constraint do ( --remove all links
			
			sp.transform.controller = prs ()
		)
		--link spline and joints
		linkConstraint obj sp
		dp1.parent = obj
		dp2.parent = obj
	),
	/**
	*@Usage > 
		delete old shortcut and spline 
		select two dummyes
		setup rollout
		generate new shortcut
	*/
	/*fn rebuildBrokenShortcut obj = (	--temp fix broken shortcut (when road tool stole a shortcut)
	
		format "todo"
		local sel = selection as array
		if sel.count == 2  then (
		
			All_CALLBACKS_ENABLED = false
			if not ( isJoint sel[1] ) or not ( isJoint sel[2] ) do (
		
				messageBox "Unable to create Shortcut. Two Joints wasn't selected or missing components."
				All_CALLBACKS_ENABLED = true
				return false
			)
			--create shortcut
			moveTangetPoints pts[1] pts[2] min_tangent_dist --move tangent points close
			dialog.btn_generate.pressed() --generate road
		)
	),*/
	fn setUpCrossRoadPoints max_dist_left max_dist_right c_tangent_offset road:undefined hidden_tn:true = (
	
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
	fn adjustTangentsLength = (
		
		local joints = #()
		local spline_path = undefined
		local sel = selection as Array
		if sel.count == 1 and isRoad sel[1] then (
		
			local comp = getRoadComponents sel[1]
			if comp.count != 5 do (
			
				format "Error 1: Unble Adjust tangent. Missing tanget Points. Components:%\n" comp
				return false
			)
			joints = #(comp[1], comp[2])
			spline_path = comp[5]
			
		) else (
	
			joints = sel
		) 
		if joints.count != 2 do (
		
			format "Error 2: Unble Adjust tangent. Missing tanget Points. Components:%\n" joints
			return false
		)
		local d1 = joints[1]
		local d2 = joints[2]
		local t1 = d1.children[1]
		local t2 = d2.children[1]
		if t1 == undefined or t2 == undefined do (
		
			format "Error 3: Unble Adjust tangent. Missing tanget Points\n"
			return false
		)
		local joints_dist = distance joints[1].pos joints[2].pos
		local tangent_dist = joints_dist / 6
		local v1 = normalize(t1.pos - d1.pos)
		local v2 = normalize(t2.pos - d2.pos)
		t1.pos = d1.pos + v1 * tangent_dist
		t2.pos = d2.pos + v2 * tangent_dist
		if spline_path != undefined do ( --adjust spline handles
		
			
		)
		format "finished adjust tangents in:%\n" #(joints[1].name, joints[2].name)
	),
	fn syncSpline update_curve = (
	
		local sel = selection as array
		for o in sel do (
		
			if not (roGenStruct.isRoad o) do (
			
				format "syncSpline > Unable sync road:%\n" o.name
				continue
			)
			local rSpline 	= o.roadSpline
			local startPoint = o.startPoint
			local endPoint = o.endPoint
			local sPointPos 	= startPoint.pos
			local ePointPos 	= endPoint.pos
			
			local knot_count = numKnots rSpline 1
			setKnotPoint    rSpline 1 1 sPointPos
			setKnotPoint    rSpline 1 knot_count ePointPos
			
			if update_curve do (
			
				local tIn 	= startPoint.children[1].pos
				local tOut	= endPoint.children[1].pos
				setOutVec rSpline 1 1 (tIn)
				setInVec rSpline 1 knot_count (tOut)
			)
			updateShape rSpline
			subobjectLevel = 0 --exit editing spline
		)
	),
	-------------------------------------------------------------
	-------------------------------------------------------------
	------                   CREATE                        ------
	-------------------------------------------------------------
	-------------------------------------------------------------
	fn drawBoundingBox pos bb = (
		
		bb_box = box pos:pos width:(getWidthBB bb) length:(getLengthBB bb) height:(getHeightBB bb)
	),
	fn drawLineBetweenTwoPoints pointA pointB col = (
	
	  local ss = SplineShape pos:pointA
	  addNewSpline ss
	  addKnot ss 1 #corner #line PointA
	  addKnot ss 1 #corner #line PointB
	  updateShape ss
	  ss.wirecolor = col
	  ss
	),
	fn copyUniqueShortcut obj hidden_tn:false = (
	
		if not (isShortcut obj) or not (isValidShortcut obj) do return false
		
		--collect source components
		local src_spline = getConstraintObject obj SplineShape
		local src_sPoint = obj.children[1]
		local src_ePoint = obj.children[2]
		local src_tn1 = src_sPoint.children[1]
		local src_tn2 = src_ePoint.children[1]

		--format "copyUniqueShortcut >\n\tspline:%\n\tsPoint:%\n\tePoint:%\n\ttn1:%\n\ttn2:%\n" src_spline src_sPoint src_ePoint src_tn1 src_tn2
		
		--clone components
		local new_obj	= copy obj
		local sPoint	= copy src_sPoint
		local ePoint	= copy src_ePoint
		local rSpline	= copy src_spline
		local tn1		= copy src_tn1
		local tn2		= copy src_tn2
		
		--setup clones
		new_obj.wirecolor	= obj.wirecolor
		sPoint.wirecolor	= src_sPoint.wirecolor
		ePoint.wirecolor	= src_ePoint.wirecolor
		rSpline.wirecolor	= src_spline.wirecolor
		tn1.wirecolor		= src_tn1.wirecolor
		tn2.wirecolor		= src_tn2.wirecolor
		
		--link clones
		sPoint.parent = new_obj
		ePoint.parent = new_obj
		linkConstraint new_obj rSpline
		rSpline.pos = src_spline.pos --restore pos
		tn1.parent = sPoint
		tn2.parent = ePoint
		
		if hidden_tn do hide #(tn1, tn2)
		select new_obj
	),
	fn copyUniqueCrossRoad obj hidden_tn:false = (
	
		if not (isCrossRoad obj) do return false
		local kidsShift = 4
		local new_obj = copy obj
		setCrossRoadWireColor new_obj oldColor:obj.wirecolor
		local originalCRChildren = obj.children
		local childrenCount = originalCRChildren.count
		
		for i =1 to childrenCount do (
		
			origPt 	= originalCRChildren[i]
			origTn 	= origPt.children[1]
			
			newPt = copy origPt
			newTn = copy origTn
			
			roGenStruct.SetPointAppearance newPt
			if hidden_tn do hide newTn
			
			newTn.parent = newPt
			append new_obj.children newPt
			
			new_obj.kids[i] = newPt
			new_obj.kids[i +kidsShift] = newTn
		)

		when new_obj deleted id:#CrossDelete obj do ( --define a when construct
		
			roGenStruct.deleteCrossRoadChildren obj
		)
		select new_obj
	),
	--specs(parking_left, parking_right, sidewalk_left, sidewalk_right)
	fn constructRoadPrototype road specs placeParkingLeft placeParkingRight placeSidewalkLeft placeSidewalkRight = (
		--
		local bb = getBoundingBox road
		local bb_parking = getBoundingBox specs[1]
		local bb_sidewalk = getBoundingBox specs[3]
		local cpy_road = copy road
		local offset = getLengthBB bb_sidewalk
		
		local offsetLeft 	= offset
		local offsetRight	= offset
		
		if(placeParkingLeft) 	then offsetLeft += getLengthBB bb_parking
		if(placeParkingRight) 	then offsetRight += getLengthBB bb_parking

		--	
		left_pivot = road.position - (getWidthBB bb)/2.0 * road.transform.row1 + ((getLengthBB bb)/2.0 + offsetLeft) * road.transform.row2 + (getHeightBB bb_sidewalk) * road.transform.row3
		right_pivot = road.position - (getWidthBB bb)/2.0 * road.transform.row1 - ((getLengthBB bb)/2.0 + offsetRight) * road.transform.row2 + (getHeightBB bb_sidewalk) * road.transform.row3
		
		-- parking left
		if (placeParkingLeft) then
		(
			parking_left = copy specs[1]
			parking_left.position = left_pivot
			cpy_road.attach parking_left cpy_road
		)
		-- parking right
		if (placeParkingRight) then
		(
			parking_right = copy specs[2]
			parking_right.position = right_pivot
			cpy_road.attach parking_right cpy_road
		)
		--place sidewalk Left
		if (placeSidewalkLeft) then
		(
			sidewalk_left = copy specs[3]
			sidewalk_left.position = left_pivot
			cpy_road.attach sidewalk_left cpy_road
		)
		--place sidewalk Right
		if (placeSidewalkRight) then
		(
			sidewalk_right = copy specs[4]
			sidewalk_right.position = right_pivot
			cpy_road.attach sidewalk_right cpy_road
		)
		--weldEditPoly road_sum 1.0
		--return road
		return cpy_road
		
	),
	fn createSplineFromJoints jo_1 jo_2 = (
	
		local p1 = jo_1.position
		local t1 = jo_1.children[1].position
		local p2 = jo_2.position
		local t2 = jo_2.children[1].position

		local sp = splineShape()
		addNewSpline sp
		addKnot sp 1 #corner #curve p1
		addKnot sp 1 #corner #curve p2
		setKnotType sp 1 1 #bezierCorner
		setKnotType sp 1 2 #bezierCorner
		setOutVec sp 1 1 (t1)
		setInVec sp 1 2 (t2)
		updateShape sp
		sp.adaptive = true
		sp.pivot = (sp.min + sp.max)/2 --center pivot to spline
		sp.wirecolor = color 7 206 224
		sp
	),
	/**
	*@Usage > Create road assembled from number of parts to cover whole spline
	*/
	fn assemblyRoadFromPrefabs spline_length road_prefabric pt1_pos &road_sum &road_length  = (

		local road_bb = getBoundingBox road_prefabric
		road_length = getWidthBB road_bb
		road_sum = copy road_prefabric --clone prefab
		road_sum.pivot -= road_prefabric.transform.row1 * 0.5 * road_length --set pivot to border center
		local road_count = (spline_length/road_length) as integer
		local road_sum_length = road_length
		for i in 1 to road_count do (
		
			local copy_road = copy road_prefabric
			copy_road.position += copy_road.transform.row1 * road_length * i
			road_sum.attach copy_road road_sum
			road_sum_length += road_length
		)
		road_sum.position = pt1_pos
		weldEditPoly road_sum 0.5
	),
	/**
	*@Usage > Slice road along spline with constant distances | | | | | | | | | | |
	*/
	fn cutRoadAlongSpline road_sum spline spline_length road_length adaption = (

		local tangent_fst = tangentCurve3D spline 1 ((1 as double)/TANGENT_TEST_COUNT)
		local last_i = 1
		local sum_d = 0.0
		with redraw off (
		
			for i in 2 to TANGENT_TEST_COUNT do ( --trun off redraw for this loop
			
				local tangent_snd = tangentCurve3D spline 1 ((i as double)/TANGENT_TEST_COUNT)
				local d = acos (dot (normalize tangent_fst) (normalize tangent_snd))
				sum_d += d
		-- 		print ("Angle sum: "+sum_d as string)
				if sum_d > adaption then (
		-- 			print("Diff: "+(i-last_i) as string)
					-- compute params
					local param = (((i+last_i)/2.0)/TANGENT_TEST_COUNT)
					local pt = interpCurve3D spline 1 param pathParam:true
					--p = point ()
					--p.position = pt
					--add slice modifier
					local slice = sliceModifier()
					addModifier road_sum slice 
					--setup modifier
					slice.slice_type = 1
					slice.slice_plane.position = [0.0, 0.0, param*spline_length-road_length*0.5]
					slice.slice_plane.rotation = (angleaxis (90) [0, 1, 0]) as quat
					-- save for next iteration
					last_i = i
					sum_d = 0.0
				)
				tangent_fst = tangent_snd
			)
			--cut road length
			slice = sliceModifier()
			addModifier road_sum slice 
			slice.slice_type = 2
			slice.slice_plane.position = [0.0, 0.0, spline_length-road_length*0.5]
			slice.slice_plane.rotation = (angleaxis (90) [0, 1, 0]) as quat
			ConvertTo road_sum editable_poly
			weldEditPoly road_sum 1.0
		)
	),
	fn conformRoadToSpline road_sum spline twsit_deg rotation_deg = (
format "---Used Path_Deform_2 ------------------------------------------------------------------\n"
		local pd = Path_Deform2 ()
		addModifier road_sum pd 
		pd.Spline = spline
		pd.axis = 0
		pd.percent_along_path = 0
		pd.stretch = 1
		pd.rotation = 0
		pd.rotation = rotation_deg
		pd.twist = twsit_deg
		pd.uniform = true
		pd.auto_stretch = false
		pd.UsePivotPoint = true
		pd.PreserveForm = false
		pd.UpVector = 1
		pd.AcrossShapes = 1
		pd.flip = false
	),
	fn fixRoadEndBorder obj joint_pos tangent_pos = ( --left (pt1 tn1) right (pt2 tn2)

		--get start border
		local center_vert = (getClosestVert obj joint_pos)[1] 
		local border_edges = getBorderEdgesFromVertex obj center_vert
		obj.selectedEdges = border_edges
		obj.SelectEdgeLoop() --border edges
		local border_vertices = polyop.getVertsUsingEdge obj (polyOp.getEdgeSelection obj)
		obj.selectedVertices = border_vertices --border vertices
		--calculate border line (guideline)
		local v1 = (normalize (tangent_pos - joint_pos) ) * 10000--get tangent vector
		--get right point
		local rm = rotateZMatrix -90 --create a rotation matrix from the value
		local v_left = v1 * rm --transform the original vector using the matrix
		local left_point = joint_pos + v_left --move vector to pt1
		left_point.z = joint_pos.z --if is tangent rotated make it straight
		--get left point
		local rm = rotateZMatrix 90 --create a rotation matrix from the value
		local v_right = v1 * rm --transform the original vector using the matrix
		local right_point =  joint_pos + v_right --move vector to pt1
		right_point.z = joint_pos.z --if is tangent rotated make it straight

		--Debug
		-- sp_right = drawLineBetweenTwoPoints joint_pos right_point  yellow
		-- sp_left = drawLineBetweenTwoPoints joint_pos left_point  yellow
		-- select #(sp_left, sp_right)

		--pick bot vertices one by one from center and rotate them to guideline (vector left or right)
		local last_verts = #(center_vert, center_vert)
		local next_verts = getNeighborsVertsOnLoop obj last_verts vertMask:(border_vertices)
		while next_verts.count == 2  and not keyboard.escPressed do (
			
			-- 	obj.selectedVertices =  next_verts
			last_verts = join (copy next_verts #nomap) last_verts
			--get left and rifht vert
			local left_vert, right_vert 
			if distance left_point (polyop.getVert obj next_verts[1]) < distance left_point (polyop.getVert obj next_verts[2]) then  (
				
				left_vert = next_verts[1] 
				right_vert = next_verts[2] 
				
			) else (
				
				left_vert = next_verts[2] 
				right_vert = next_verts[1] 
			)
			--snap roatate left vert
			rotateVertexAroundZBackward obj left_vert joint_pos left_point
			--snap roatate right vert
			rotateVertexAroundZBackward obj right_vert joint_pos right_point
			--pick nex two vertices
			next_verts = getNeighborsVertsOnLoop obj last_verts vertMask:(border_vertices)
		)
	),
	fn createRoadFromSpline road_prefabric spline adaption twsit_deg rotation_deg collapsed:true = (
	
		disableSceneRedraw()
		-- get segment length
		local segment_lengths = (getSegLengths spline 1 cum:false)
		local spline_length = segment_lengths[segment_lengths.count]

		-- get joints and tangents
		local knot_count = numKnots spline 1
		local pt1 = getKnotPoint spline 1 1
		local tn1 = getOutVec spline 1 1
		local pt2 = getKnotPoint spline 1 knot_count
		local tn2 = getInVec spline 1 knot_count
		
		-- create road assembled from number of parts to cover whole spline
		local road_sum, road_length
		assemblyRoadFromPrefabs spline_length road_prefabric pt1 &road_sum &road_length
		
		-- cut road along spline
		cutRoadAlongSpline road_sum spline spline_length road_length adaption
	
		--align road to joint tangent
		alignRoadToNormal road_sum pt1 tn1
	
		---store start border vertices with positions
		start_border_vertices = roGenStruct.getRoadEdge road_sum pt1 type:#start

		--conform road to spline
		conformRoadToSpline road_sum spline twsit_deg rotation_deg
		
		-- fix START and END borders
		setRoadBoundVerts road_sum start_border_vertices
		fixRoadEndBorder road_sum pt2 tn2
		
		enableSceneRedraw()
		return road_sum
	),
	fn conformRoadToSplineOld road_sum spline twsit_deg rotation_deg pt1 tn1 = (	
format "---Used Path_Deform_1 ------------------------------------------------------------------\n"	
		-- transform matrix vectors for road 
		local t_x = normalize (tn1-pt1)
		local t_y = normalize([-t_x.y, t_x.x, 0.0])
		local t_z = cross t_x t_y
		
		local road_transform = road_sum.transform
		road_transform.row1 = t_x
		road_transform.row2 = t_y
		road_transform.row3 = t_z
		--adjust road position and rotation	
		road_sum.transform = road_transform
		
		-- update path deform gizmo to be at start of road (calculation translate world position to object space of road)
		local path_deform = pathDeform()
		addModifier road_sum path_deform
		
		path_deform.rotation = rotation_deg
		path_deform.twist = twsit_deg
		path_deform.axis = 0
		path_deform.path = spline
		path_deform.gizmo.position = pt1 * (getModContextTM road_sum path_deform) * (inverse road_sum.objecttransform)
	),
	/**
	*@Usage > cut excess part of road and adjust angle of second road connection border
	*/
	fn cutExcessPartOfRoad  road_sum road_prefabric pt2 tn2 debug:false = (
		
		--convert back forward to get triangles later
		local road_sum_mesh = ConvertTo road_sum editable_mesh
		local road_sum = ConvertTo road_sum editable_poly
		-- compute face distances, 
		--face_distances = GetRoadFaceCenterDistances road_prefabric
		local face_centers = getRoadFaceCenters road_prefabric
		local t2_x = normalize(tn2-pt2)
		local t2_y = normalize([-t2_x.y, t2_x.x, 0.0])
		local t2_z = normalize(cross t2_x t2_y)
		
		local t_matrix = matrix3 0
		t_matrix.row1 = t2_x
		t_matrix.row2 = t2_y
		t_matrix.row3 = t2_z
		
		local rays = #()
		for i in 1 to face_centers.count do
		(
			--rayOrigin = (pt2+t2_y*face_distances[i]+t2_z*100.0)
			--dir = (-t2_z)
			local rayOrigin = face_centers[i][1] * t_matrix + pt2
			local dir = face_centers[i][2] * t_matrix
			if debug do  drawLineBetweenTwoPoints rayOrigin (rayOrigin+dir*20.0) (Color 255 0 0)
			append rays (ray rayOrigin dir)
		)		
		local hitArray = findAllIntersectionsUsingRays road_sum rays
			
		--slice (gismo orientation pt2 t2_x)
		local poly_faces = getMeshFacesToPoly road_sum hitArray 
		polyop.slice road_sum poly_faces (ray pt2 t2_x)
		
		--Select faces for delete
		rays = #()
		for i in 1 to face_centers.count do
		(
			--rayOrigin = (pt2+t2_y*face_distances[i]+t2_z*10.0-t2_x*10.0)
			--dir = (-t2_z)
			local rayOrigin = face_centers[i][1] * t_matrix + pt2 - t2_x*10.0
			local dir = face_centers[i][2] * t_matrix
			if debug do  drawLineBetweenTwoPoints rayOrigin (rayOrigin+dir*20.0) (Color 0 255 0)		
			append rays (ray rayOrigin dir)
		)	
		hitArray = findAllIntersectionsUsingRays road_sum rays
		ConvertTo road_sum editable_poly
		--remove all wrong faces
		polyop.deleteFaces road_sum (getMeshFacesToPoly road_sum hitArray)
		weldEditPoly road_sum 1.0	
	),
	fn createRoadFromSplineOld road_prefabric spline adaption twsit_deg rotation_deg = (
	
		disableSceneRedraw() 
		-- get segment length
		local segment_lengths = (getSegLengths spline 1 cum:false)
		local spline_length = segment_lengths[segment_lengths.count]
		
		-- get knots position
		local knot_count = numKnots spline 1
		local pt1 = getKnotPoint spline 1 1
		local tn1 = getOutVec spline 1 1
		local pt2 = getKnotPoint spline 1 knot_count
		local tn2 = getInVec spline 1 knot_count
		
		-- create road assembled from number of parts to cover whole spline
		local road_sum, road_length
		assemblyRoadFromPrefabs spline_length road_prefabric pt1 &road_sum &road_length
		
		-- cut road along spline
		cutRoadAlongSpline road_sum spline spline_length road_length adaption
		
		--align road to joint tangent
		-- alignRoadToNormal road_sum pt1 tn1
				
		-- transform matrix vectors for road
		local t_x = normalize (tn1-pt1)
		local t_y = normalize([-t_x.y, t_x.x, 0.0])
		local t_z = cross t_x t_y
		local road_transform = road_sum.transform
		road_transform.row1 = t_x
		road_transform.row2 = t_y
		road_transform.row3 = t_z
		road_sum.transform = road_transform
		

		--conform road to spline
		conformRoadToSplineOld road_sum spline twsit_deg rotation_deg pt1 tn1

		--slice road end and delete rest
		cutExcessPartOfRoad road_sum road_prefabric pt2 tn2
			
		enableSceneRedraw()
		return road_sum
	),
	/**
	*@Usage > make short version of selected road with two connection dummies and convert it to corssroad
	*/
	fn generateRoadShortcut dialog old_way:true = (
		
		--Compatibility Check
		if (selection as Array).count > 1 do return false		--not applicable if two dummies is selected (this is for road creation)
		local road = selection[1] 
		if isRoad road do return false 		--not applicable for Road
		if isCrossRoad road do return false	--not applicable for CrossRoad
		--Disable all Road Tool callbacks at Begin
		All_CALLBACKS_ENABLED = false
		--Define Variables
		local road_thickness = 200
		local min_tangent_dist = 50
		local max_tangent_dist = 1000
		local pts = #(), sp = undefined, finalPos = [0,0,0], dp1, dp2, tp1, tp2 -- dp > dummy(point) tp > tangent(point)
		--Check if Shortcut or geometry is selected
		if isShortcut road then ( --rebuild current shortcut
			
			if not (isValidShortcut road) do ( --if all components are defined
				
				format "roGenStruct > generateRoadShortcut > Invalid components, use Road Anatomy to see issues\n" road.name
				All_CALLBACKS_ENABLED = true
				return false
			)
			pts = #(road.children[1], road.children[2])
			moveTangetPoints pts[1] pts[2] min_tangent_dist --move tangent points close
			finalPos = road.pos --keep road position
			local old_path = getConstraintObject road SplineShape
			delete road -- delete old road first to prevent crash (after deleting road, constraints will be also removed)
			if old_path != undefined do delete old_path
			
		) else if subobjectlevel == 4 then ( --face(s) is selected (build at place)
		
			finalPos = getSelectedFacesCenter road --try to get selected faces position
			subobjectlevel = 0 
			max select none
			
		) else if selection.count == 1 do ( --dummy or other object are selected
		
			finalPos = selection[1].pos
			max select none
		)
		--create new controll points
		if pts.count != 2 do pts = setUpCrossRoadPoints -road_thickness road_thickness 500 hidden_tn:false	
		--reverse tangents to inner
		swapPoints pts[1] pts[2]
		if not (isShortcut road) do moveTangetPoints pts[1] pts[2] min_tangent_dist --move tangent points close
		select pts
		--generate road geometry
		if old_way then dialog.btn_generate_old.pressed() else dialog.btn_generate.pressed()--generate road
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
		setShortcutCA road dialog dialog.controlsArr
		--link spline and joints
		linkConstraint road sp	
		dp1.parent = road
		dp2.parent = road
		road.pos = finalPos
		--Reenable all Road Tool callbacks at End
		All_CALLBACKS_ENABLED = true
	),	
	fn createRoadFromRolloutSettings dialog roads specs spline startPoint endPoint road_clr:undefined road_name:undefined old:true= (
	
		--deselect all (speed up progress)
		subobjectlevel = 0 --exit from edit mode
		max select none
		
		--collect current rollout settings
		local tangent_deg	= dialog.spinner_tangent.value
		local rotation_deg	= if isProperty dialog "spinner_rotate" then dialog.spinner_rotate.value else 0
		local twist_deg		= if isProperty dialog "spinner_twist" then dialog.spinner_twist.value else 0
		local prefabs_sel	= dialog.dd_road_prefabs_1.selection
		local pl_left_state	= dialog.cb_parking_lane_left.state 
		local pl_right_state	= dialog.cb_parking_lane_right.state 
		local sw_left_state	= dialog.cb_sidewalks_left.state 
		local sw_right_state	= dialog.cb_sidewalks_right.state

		--get road core	
		local selected_road = pickRoadPrefab roads prefabs_sel false
		--assembly road from components
		local road = constructRoadPrototype selected_road specs pl_left_state pl_right_state sw_left_state sw_right_state
--conform-slice road along spline
local finalRoad = if old then (

	createRoadFromSplineOld road spline tangent_deg twist_deg rotation_deg
	
) else (

	createRoadFromSpline road spline tangent_deg twist_deg rotation_deg collapsed:false
)
		if road_name == undefined then ( --genereate new name from prefab name (when create new road)
		
			finalRoad.name = replace finalRoad.name 11 6 "connect_road" --"generator_road_2_6d" > "generator_connect_road_6d"
			finalRoad.name = uniqueName finalRoad.name
			
		) else ( --use original road name (when rebuild a road)
		
			finalRoad.name = road_name
		)
		--set custom attributes
		setRoadCA finalRoad spline startPoint endPoint dialog dialog.controlsArr

		custAttributes.add spline gSplineGenCa #unique
		spline.road = finalRoad.name
		--sp.parent = finalRoad --MerlinEl (2.24.2019) --can't do this, depency loop TODO:(try to use link constraints)
		------------------------------------------------------------------
		delete road

		setCrossRoadWireColor finalRoad oldColor:road_clr
		finalRoad
	),
	/**
	*@Usage >  create road from two points or rebuild selected road( select road or spline )
	*/
	fn generateRoad dialog roads specs old_way:true = (
	
		local sel = selection as Array
		local obj = sel[1]
		local road, spline, finalRoad
		if isCrossRoad sel[1] or isShortcut sel[1] do return false --not applicable for crossroad or shortcut
		All_CALLBACKS_ENABLED = false
		undo off (
		
			---------------------------------------------------------------------------
-- 			TWO POINTS ARE SELECTED (Create new road)
			---------------------------------------------------------------------------
			if sel.count == 2  then (
				
				if not ( isJoint sel[1] ) or not ( isJoint sel[2] ) do (
			
					messageBox "Unable to create road. Two Joints wasn't selected or missing components."
					All_CALLBACKS_ENABLED = true
					return false
				)
				--create road
				spline = createSplineFromJoints sel[1] sel[2]
				finalRoad = createRoadFromRolloutSettings dialog roads specs spline sel[1] sel[2] old:old_way
			)
			---------------------------------------------------------------------------
-- 			ROAD or SPLINE SELECTED (keep spline and Rebuild road)
			---------------------------------------------------------------------------
			if sel.count == 1 then(
				
				--pick road components
				if classOf obj == SplineShape then ( --if path is selected
				
					spline = obj
					road = getNodeByName spline.road
					
				)else( --if road is selected
				
					spline = obj.roadSpline
					road = obj
				)
				if classOf spline != SplineShape or classOf road != Editable_Poly do (
				
					messageBox "Unable to create road.  Road or spline wasn't selected."
					All_CALLBACKS_ENABLED = true
					return false
				)
				
				--pick old road data
				local layer = road.layer
				local wire_clr = road.wirecolor
				local export_node = road.parent
				local startPoint = road.startPoint
				local endPoint = road.endPoint
				local old_name = road.name
				
--debug			
-- format "A DEBUG > Rebuild road before:............................................... [ % ]........................................................................\n" road.name
-- format "Dupplicates found:%\n" (isObjectWithDuplicateName road)
-- for o in objects where findString o.name "generator_connect_road" != undefined do print o.name
-- format "< ..................................................................................................................................\n"						
				
				delete road -- delete old road

				--create new road
				finalRoad = createRoadFromRolloutSettings dialog roads specs spline startPoint endPoint road_clr:wire_clr road_name:old_name old:old_way
				finalRoad.parent = export_node
				layer.addNode finalRoad
				layer.addNode spline
				
--debug	
local dupe = (isObjectWithDuplicateName finalRoad)	
if dupe do messageBox ("Road with dupplicate Name was created.\nPlease fix road with name:"+finalRoad.name) title:"Alert:"	
-- format "B DEBUG > Rebuild road after:............................................. [ % ]........................................................................\n" finalRoad.name
-- format "Dupplicates found:%\n" dupe
-- for o in objects where findString o.name "generator_connect_road" != undefined do print o.name 
-- format "<  ..................................................................................................................................\n"

			)
		)
		select finalRoad
		All_CALLBACKS_ENABLED = true
	)
	/*<end>*/
)	
 --create instance
Global roGenStruct = ROAD_GENERATOR_STRUCTURE()



/*
----------A procedure in shortcuts only
for o in slection do print o.name
for o in selection do o.name = uniqueName o.name
sh = for o in selection where roGenStruct.isShortcut o collect o
select sh
for o in sh do (


	sp = o.children[3]
	sp.parent = undefined
	roGenStruct.linkConstraint s sp
)

----------Check cross road children
cr = for o in selection where findString o.name "generator_crossroad" != undefined collect o
select cr
invalid_cross_roads = #()
for o in cr do (

	local ch = o.children
	format "Check CorssRoad:% children:%\n" o.name o.children.count
	if o.children.count != 4 do (

		format "missing children....."
		append invalid_cross_roads o
		continue
	)
	for ch in o.children do format "\tpoints a:% b:%\n" o.children[1].name o.children[1].children[1].name
)
format "invalid_cross_roads count:%\n" invalid_cross_roads.count
select invalid_cross_roads

----------Select empty points
po = for o in objects where classOf o == Point collect o
select (for o in po where o.parent == undefined collect o)
*/