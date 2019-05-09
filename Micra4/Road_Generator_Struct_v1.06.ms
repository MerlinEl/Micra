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
	
	--functions
	fn getSource = getSourceFileName(), --get path of this script
	-------------------------------------------------------------
	-------------------------------------------------------------
	------              		GET    	                   ------
	-------------------------------------------------------------
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
	fn getFaceCenter editable verts = (
		point_avg = [0,0,0]
		for i in 1 to verts.count do
		(
			pt = polyop.getVert editable verts[i]
			point_avg += pt
	-- 		print("pt to sum: "+pt as string)
		)
	-- 	print("pt sum: "+point_avg as string)
		point_avg /= verts.count
	-- 	print ("Face vert count: "+verts.count as string)
		return point_avg
	),
	fn getRoadFaceCenterDistances editable =
	(
		face_count = polyop.getNumFaces editable
		face_offsets = #()
		for i in 1 to face_count do
		(
			face_center = getFaceCenter editable (polyop.getFaceVerts editable i)
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
			face_center = getFaceCenter editable (polyop.getFaceVerts editable i)
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
	fn getConstraintObject obj_target node_type = (
	
		local all_dependents = refs.dependents obj_target
		local filter_objects = for ref in all_dependents where (superClassOf ref == node_type) collect ( ref )
		filter_objects[1]
	),
	-------------------------------------------------------------
	-------------------------------------------------------------
	------                   SET                           ------
	-------------------------------------------------------------
	-------------------------------------------------------------
	fn fixDuplicitNames debug:false = (
	-- 		SelectVisuals()
		local sel = selection as Array
		for o in sel do (
			
			local new_name = uniquename o.name
			if debug do format "fixDuplicitNames > from:% to:%\n" o.name new_name
			o.name = new_name
			if isRoad o do o.roadSpline.road = new_name --update spline attribute
		)
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
	/** 
	*@STATE In Progress....
	*/
	fn setShortcutCA road rSpline sPoint ePoint dialog controlsArr = (
	
		custAttributes.add road gShortcutCa #unique
		sPoint.parent = road
		ePoint.parent = road
		--rSpline.parent = road
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
	fn pickRoadPrefab roads dd_selection spec = (	
	
		roadPointer = dd_selection
		roads[roadPointer]
	),
	fn linkConstraint obj_target obj_source = (
		
		obj_source.controller = link_constraint()
		obj_source.controller.addTarget obj_target 1 --at frame 1
		/*
		--print all keys' index, time and target
		lc = link_constraint() --create a Link Constraint instance
		or i = 1 to lc.getNumTargets() do format "%: Frame:% - Target:% \n" i (lc.getFrameNo i) (lc.getNode  i) 
		*/
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
	-------------------------------------------------------------
	------                 TRANSFORM                       ------
	-------------------------------------------------------------
	-------------------------------------------------------------
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

		if not (isShortcut obj) do return false
		
		local new_obj = copy obj
local src_spline = getConstraintObject obj Shape
		new_obj.wirecolor = obj.wirecolor
		
		local sPoint = copy obj.children[1]
		local ePoint = copy obj.children[2]
		local rSpline = copy src_spline
		local tn1 = copy obj.children[1].children[1]
		local tn2 = copy obj.children[2].children[1]
		
		sPoint.wirecolor = obj.children[1].wirecolor
		ePoint.wirecolor = obj.children[2].wirecolor
		rSpline.wirecolor = src_spline.wirecolor
		tn1.wirecolor = obj.children[1].children[1].wirecolor
		tn2.wirecolor = obj.children[2].children[1].wirecolor
		
		sPoint.parent = new_obj
		ePoint.parent = new_obj
		-- rSpline.parent = new_obj
linkConstraint new_obj rSpline
		tn1.parent = sPoint
		tn1.parent = ePoint
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
		
		if(placeParkingLeft) 		then offsetLeft += getLengthBB bb_parking
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
	fn createRoadFromSpline road_prefabric spline adaption = (
	
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
		local road_bb = getBoundingBox road_prefabric
		local road_length = getWidthBB road_bb
				
		local road_sum = copy road_prefabric
		road_sum.pivot -= road_prefabric.transform.row1 * 0.5 * road_length
		local road_count = spline_length/road_length as integer
		local road_sum_length = road_length
	-- 	print ("Road count: "+(road_count as string))
		for i in 1 to road_count do (
		
			copy_road = copy road_prefabric
			copy_road.position += copy_road.transform.row1 * road_length * i
			road_sum.attach copy_road road_sum
			road_sum_length += road_length
		)
		road_sum.position = pt1
		
		weldEditPoly road_sum 1.0
		
		-- cut road along spline
		local tangent_fst = tangentCurve3D spline 1 ((1 as double)/TANGENT_TEST_COUNT)
		local last_i = 1
		local sum_d = 0.0
		for i in 2 to TANGENT_TEST_COUNT do
		(
			tangent_snd = tangentCurve3D spline 1 ((i as double)/TANGENT_TEST_COUNT)
			d = acos (dot (normalize tangent_fst) (normalize tangent_snd))
			sum_d += d
	-- 		print ("Angle sum: "+sum_d as string)
			if sum_d > adaption then (
	-- 			print("Diff: "+(i-last_i) as string)
				-- compute params
				param = (((i+last_i)/2.0)/TANGENT_TEST_COUNT)
				pt = interpCurve3D spline 1 param pathParam:true
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
		
		local slice = sliceModifier()
		addModifier road_sum slice 
		--setup modifier
		slice.slice_type = 2
		slice.slice_plane.position = [0.0, 0.0, spline_length-road_length*0.5]
		slice.slice_plane.rotation = (angleaxis (90) [0, 1, 0]) as quat
		
		road_sum = ConvertTo road_sum editable_poly
		
		-- transform matrix vectors for road
		t_x = normalize (tn1-pt1)
		t_y = normalize([-t_x.y, t_x.x, 0.0])
		t_z = cross t_x t_y
		
		road_transform = road_sum.transform
		road_transform.row1 = t_x
		road_transform.row2 = t_y
		road_transform.row3 = t_z
			
		road_sum.transform = road_transform
		
		-- update path deform gizmo to be at start of road (calculation translate world position to object space of road)
		path_deform = pathDeform()
		addModifier road_sum path_deform
		
		path_deform.axis = 0
		path_deform.path = spline
		path_deform.gizmo.position = pt1 * (getModContextTM road_sum path_deform) * (inverse road_sum.objecttransform)
		
		road_sum_mesh = ConvertTo road_sum editable_mesh
		road_sum = ConvertTo road_sum editable_poly
		
		-- compute face distances, 
		--face_distances = GetRoadFaceCenterDistances road_prefabric
		face_centers = getRoadFaceCenters road_prefabric
		t2_x = normalize(tn2-pt2)
		t2_y = normalize([-t2_x.y, t2_x.x, 0.0])
		t2_z = normalize(cross t2_x t2_y)
		
		t_matrix = matrix3 0
		t_matrix.row1 = t2_x
		t_matrix.row2 = t2_y
		t_matrix.row3 = t2_z
		
		rays = #()
		for i in 1 to face_centers.count do
		(
			--rayOrigin = (pt2+t2_y*face_distances[i]+t2_z*100.0)
			--dir = (-t2_z)
			rayOrigin = face_centers[i][1] * t_matrix + pt2
			dir = face_centers[i][2] * t_matrix
			--drawLineBetweenTwoPoints rayOrigin (rayOrigin+dir*20.0) (Color 255 0 0)
			append rays (ray rayOrigin dir)
		)
		hitArray = findAllIntersectionsUsingRays road_sum_mesh rays
			
		--slice
		polyop.slice road_sum (getMeshFacesToPoly road_sum hitArray) (ray pt2 t2_x)
		
		road_sum_mesh = ConvertTo road_sum editable_mesh
		--rebuild ray mesh intersect with updated data
		
		rays = #()
		for i in 1 to face_centers.count do
		(
			--rayOrigin = (pt2+t2_y*face_distances[i]+t2_z*10.0-t2_x*10.0)
			--dir = (-t2_z)
			rayOrigin = face_centers[i][1] * t_matrix + pt2 - t2_x*10.0
			dir = face_centers[i][2] * t_matrix
			--drawLineBetweenTwoPoints rayOrigin (rayOrigin+dir*20.0) (Color 0 255 0)
			append rays (ray rayOrigin dir)
		)
		hitArray = findAllIntersectionsUsingRays road_sum_mesh rays
		road_sum = ConvertTo road_sum editable_poly
		--remove all wrong faces
		polyop.deleteFaces road_sum (getMeshFacesToPoly road_sum hitArray)
		weldEditPoly road_sum 1.0
			
		enableSceneRedraw()
		return road_sum
	),
	/**
	*@Usage > make short version of selected road with two connection dummies and convert it to corssroad
	*/
	fn generateRoadShortcut dialog = (
		
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
		dialog.btn_generate.pressed() --generate road
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
		setShortcutCA road sp dp1 dp2 dialog dialog.controlsArr
linkConstraint road sp
		road.pos = finalPos
	),	
	fn generateRoad dialog roads specs = (
	
		if isCrossRoad selection[1] or isShortcut selection[1] do return false
		undo off (
		
			local sel = selection as Array
			local selCount = sel.count
			local tangent_deg		= dialog.spinner_tangent.value
			local prefabs_sel		= dialog.dd_road_prefabs_1.selection
			local pl_left_state	= dialog.cb_parking_lane_left.state 
			local pl_right_state	= dialog.cb_parking_lane_right.state 
			local sw_left_state	= dialog.cb_sidewalks_left.state 
			local sw_right_state	= dialog.cb_sidewalks_right.state
			
			---------------------------------------------------------------------------
-- 			TWO POINTS  (Create)
			---------------------------------------------------------------------------
			if selCount == 2 and classof sel[1] == Point and classof sel[2] == Point then (
				
				local p1 = sel[1].position
				local t1 = sel[1].children[1].position
				local p2 = sel[2].position
				local t2 = sel[2].children[1].position
				
				-- create spline from selected points
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
				sp.pivot = [0, 0, 0]
				sp.wirecolor = color 7 206 224
				
				local selected_road = pickRoadPrefab roads prefabs_sel false
				local road = constructRoadPrototype selected_road specs pl_left_state pl_right_state sw_left_state sw_right_state
				local finalRoad = createRoadFromSpline road sp tangent_deg
				------------------------------------------------------------------
				finalRoad.name = replace finalRoad.name 11 6 "connect_road"
				finalRoad.name = uniquename(finalRoad.name)
				
				setRoadCA finalRoad sp $[1] $[2] dialog dialog.controlsArr
				custAttributes.add sp gSplineGenCa #unique
				sp.road = finalRoad.name
				--sp.parent = finalRoad --MerlinEl (2.24.2019) --can't do this, depency loop
				------------------------------------------------------------------
				delete road

				setCrossRoadWireColor finalRoad
				select finalRoad				
			)

			---------------------------------------------------------------------------
-- 			ROAD or SPLINE  (Update)
			---------------------------------------------------------------------------
			if selCount == 1 then(
				
				local obj = sel[1], road
				if classOf obj == SplineShape then (
				
					spline = obj
					road = getNodeByName spline.road
					
				)else(
				
					spline = obj.roadSpline
					road = obj
				)
				
				local fSel = #(road, spline)
				local oldWireColor = road.wirecolor
				local prevParent = undefined
				
				if fSel[1] != undefined and fSel[2] != undefined then(
				
					select fSel
					local selected_road = pickRoadPrefab roads prefabs_sel false
					selected_road = constructRoadPrototype selected_road specs pl_left_state pl_right_state sw_left_state sw_right_state
					road = undefined
					spline = undefined
					-- get items from selection
					for i in 1 to $.count do
					(
-- 						print ("ClassOf "+(classOf $[i] as string))
						if (classOf $[i] == Editable_Poly) or (classOf $[i] == PolyMeshObject) then
						(
							road = $[i]
-- 							print ("Road was detected.")
						)
						if (classOf $[i] == SplineShape) then
						(
							spline = $[i]
-- 							print ("Spline was detected.")
						)
					)
					if(road == undefined or spline == undefined) then (
					
						messageBox "Road or spline wasn't selected."
						
					) else (
						--create road
						finalRoad = createRoadFromSpline selected_road spline tangent_deg
						finalRoad.name = replace finalRoad.name 11 6 "connect_road"
						finalRoad.name = uniquename(finalRoad.name)
						
						setRoadCA finalRoad spline road.startPoint road.endPoint dialog dialog.controlsArr
						spline.road = finalRoad.name
						-- delete old road
						
						prevParent = road.parent
											
						delete road
						delete selected_road
						
						setCrossRoadWireColor finalRoad oldColor:oldWireColor
						finalRoad.parent = prevParent
						select finalRoad
					)
				)
			)
		)
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
invalid_roads = #()
for o in selection do (

	local ch = o.children
	format "Check CorssRoad:% children:%\n" o.name o.children.count
	if o.children.count != 4 do (

		format "missing children....."
		append invalid_roads o
		continue
	)
	for ch in o.children do format "\tpoints a:% b:%\n" o.children[1].name o.children[1].children[1].name
)
select invalid_roads

----------Select empty points
po = for o in objects where classOf o == Point collect o
select (for o in po where o.parent == undefined collect o)
*/