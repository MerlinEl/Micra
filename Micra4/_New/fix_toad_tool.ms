fileIn (micra.rootDir + "Road_Generator_Struct_v1.11.ms")
spline = selection[2]
road_prefabric = selection[1]
adaption = 4
twsit_deg = 0

		-- get segment length
		 segment_lengths = (getSegLengths spline 1 cum:false)
		 spline_length = segment_lengths[segment_lengths.count]
		
		-- get knots position
		 knot_count = numKnots spline 1
		 pt1 = getKnotPoint spline 1 1
		 tn1 = getOutVec spline 1 1
		 pt2 = getKnotPoint spline 1 knot_count
		 tn2 = getInVec spline 1 knot_count
		
		-- create road assembled from number of parts to cover whole spline
		global road_sum, road_length
		roGenStruct.adjustRoadLength spline_length road_prefabric pt1 &road_sum &road_length
		
		-- cut road along spline
		roGenStruct.cutRoadAlongSpline road_sum spline spline_length road_length adaption
	
		--snap - align road to joint
		roGenStruct.alignRoadToNormal road_sum pt1 tn1
		
		---store start border vertices with positions
		start_border_vertices = roGenStruct.getRoadEdge road_sum pt1 type:#start

		--conform road to spline
		roGenStruct.conformRoadToSpline road_sum spline twsit_deg
		
		-------------------------------------
		--  FIX START BORDER   --
		-------------------------------------
		roGenStruct.setRoadBoundVerts road_sum start_border_vertices
		
		-------------------------------------
		--  FIX END BORDER   --
		-------------------------------------
		roGenStruct.fixRoadEndBorder road_sum pt2 tn2
		
		--Cut excess part of road mesh (p2)
		--Adjust coonection angle with crossroad
-- 		roGenStruct.cutExcessPartOfRoad road_sum road_prefabric pt2 tn2


	fn getClosestVert obj p verts:#{} = (
	
		local cv, obj = snapshotasmesh obj
		local lastvert = obj.numverts + 1
		setnumverts obj lastvert true
		setvert obj lastvert p
		
		local cd = meshop.minvertexdistancefrom obj lastvert vArray
		
		for v in vArray where distance (getvert obj v) p == cd do exit with cv = v
		
		delete obj
		#(cv, cd)
	)

	
		spline = selection[2]
		road_sum = selection[1]

		-- update path deform gizmo to be at start of road (calculation translate world position to object space of road)
		pd = Path_Deform2 ()
		addModifier road_sum pd 
		pd.Spline = spline
		pd.axis = 0
		pd.UsePivotPoint = true
		pd.percent_along_path = 0
		pd.stretch = 1
		pd.rotation = 0
		pd.twist = 0
		pd.uniform = true
		pd.auto_stretch = false
		pd.PreserveForm = false
		pd.UpVector = 1
		pd.AcrossShapes = 1
		pd.flip = false
		
		
		--convert back forward to get triangles later
		 road_sum_mesh = ConvertTo road_sum editable_mesh
		 road_sum = ConvertTo road_sum editable_poly
		
		------------------------------		
		--FIX ROAD START
		------------------------------
		select (point pos:pt1)
		--get start border
		vert_at_start = (roGenStruct.getClosestVert road_sum pt1)[1] 
		border_edges = roGenStruct.getBorderEdgesFromVertex road_sum vert_at_start
		road_sum.selectedEdges = border_edges
		road_sum.SelectEdgeLoop() --border edges
		border_vertices = polyop.getVertsUsingEdge road_sum (polyOp.getEdgeSelection road_sum)
		road_sum.selectedVertices = border_vertices --border vertices
		--calculate border line (guideline)
		v1 = (normalize (tn1 - pt1) ) * 10000--get tangent vector
		--get right point
		rm = rotateZMatrix -90 --create a rotation matrix from the value
		v_left = v1 * rm --transform the original vector using the matrix
		left_point = pt1 + v_left --move vector to pt1
		left_point.z = pt1.z --if is tangent rotated make it straight
		--get left point
		rm = rotateZMatrix 90 --create a rotation matrix from the value
		v_right = v1 * rm --transform the original vector using the matrix
		right_point =  pt1 + v_right --move vector to pt1
		right_point.z = pt1.z --if is tangent rotated make it straight

--visualize (Debug)
-- sp_right = roGenStruct.drawLineBetweenTwoPoints pt1 right_point  yellow
-- sp_left = roGenStruct.drawLineBetweenTwoPoints pt1 left_point  yellow
-- select #(sp_left, sp_right)

--pick bot vertices one by one from center and rotate them to guideline (vector left or right)
last_verts = #(vert_at_start, vert_at_start)
next_verts = roGenStruct.getNeighborsVertsOnLoop road_sum last_verts vertMask:(border_vertices)
while next_verts.count == 2  and not keyboard.escPressed do (
	
	-- 	road_sum.selectedVertices =  next_verts
	last_verts = join (copy next_verts #nomap) last_verts
	--get left and rifht vert
	local left_vert, right_vert 
	if distance left_point (polyop.getVert road_sum next_verts[1]) < distance left_point (polyop.getVert road_sum next_verts[2]) then  (
		
		left_vert = next_verts[1] 
		right_vert = next_verts[2] 
		
	) else (
		
		left_vert = next_verts[2] 
		right_vert = next_verts[1] 
	)
	--snap roatate left vert
	roGenStruct.rotateVertexAroundZBackward road_sum left_vert pt1 left_point
	--snap roatate right vert
	roGenStruct.rotateVertexAroundZBackward road_sum right_vert pt1 right_point
	--pick nex two vertices
	next_verts = roGenStruct.getNeighborsVertsOnLoop road_sum last_verts vertMask:(border_vertices)
)


fn fixRoadEndBorder obj pt2 tn2 = (

	--get start border
	local center_vert = (getClosestVert obj pt2)[1] 
	local border_edges = getBorderEdgesFromVertex obj center_vert
	obj.selectedEdges = border_edges
	obj.SelectEdgeLoop() --border edges
	local border_vertices = polyop.getVertsUsingEdge obj (polyOp.getEdgeSelection obj)
	obj.selectedVertices = border_vertices --border vertices
	--calculate border line (guideline)
	local v1 = (normalize (tn2 - pt2) ) * 10000--get tangent vector
	--get right point
	local rm = rotateZMatrix -90 --create a rotation matrix from the value
	local v_left = v1 * rm --transform the original vector using the matrix
	local left_point = pt2 + v_left --move vector to pt1
	left_point.z = pt2.z --if is tangent rotated make it straight
	--get left point
	local rm = rotateZMatrix 90 --create a rotation matrix from the value
	local v_right = v1 * rm --transform the original vector using the matrix
	local right_point =  pt2 + v_right --move vector to pt1
	right_point.z = pt2.z --if is tangent rotated make it straight

	--Debug
	-- sp_right = drawLineBetweenTwoPoints pt2 right_point  yellow
	-- sp_left = drawLineBetweenTwoPoints pt2 left_point  yellow
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
		rotateVertexAroundZBackward obj left_vert pt2 left_point
		--snap roatate right vert
		rotateVertexAroundZBackward obj right_vert pt2 right_point
		--pick nex two vertices
		next_verts = getNeighborsVertsOnLoop obj last_verts vertMask:(border_vertices)
	)
)



		
		local p_left_vert = polyop.getVert road_sum left_vert
		local v_left_vert = p_left_vert - pt1
		local vert_angle = getLinesAngle pt1 p_left_vert pt1 left_point
		local rotated_vector = rotateVectorAroundNormal v_left_vert -vert_angle
		polyOp.setVert road_sum left_vert ( pt1 + rotated_vector)

select (point pos:p_left_vert)
select (point pos:(pt1 + rotatedVector))


	
	
	
	-- A translation that brings point 1 to the origin
-- Rotation around the origin by the required angle
-- A translation that brings point 1 back to its original position	
fn rotateVertexAroundpoint obj v_index angle_deg = (
	
	newX = centerX + (point2x-centerX)*Math.cos(angle_deg) - (point2y-centerY)*Math.sin(angle_deg)
	newY = centerY + (point2x-centerX)*Math.sin(angle_deg) + (point2y-centerY)*Math.cos(angle_deg)
)

	
final_angle  = [0,0,1] * inverse ($.rotation as matrix3)
--rotate vector - angle
staticVector = [0,0,1]
rotatingVector = v_left_vert
centerOfRotatoin = pt1

finalVector= cross staticVector rotatingVector
tm = matrix3 staticVector rotatingVector finalVector centerOfRotatoin
rotateX tm (degToRad -vert_angle)
rotatedVector = tm.row2
polyOp.setVert road_sum left_vert ( pt1 + rotatedVector)







rotateVertexAroundpoint road_sum left_vert -vert_angle axis:#z
fn rotateVertexAroundpoint obj v_index angle_deg axis:#z = (
	
	local newX = centerX + (point2x-centerX)*Math.cos(angle_deg) - (point2y-centerY)*Math.sin(angle_deg)
	local newY = centerY + (point2x-centerX)*Math.sin(angle_deg) + (point2y-centerY)*Math.cos(angle_deg)
	local vert_pos = polyop.getVert obj v_index
	polyOp.setVert obj v_index [newX, newY, vert_pos.z]
)

fn rotateVertexAroundpoint obj v_index angle_deg axis:#z = (
	
	--use static vector and rotating vector to derive a 3rd axis.
	finalVector= cross(staticVector,rotatingVector)
	--contruct a matrix 3
	-- rotating vector is in row2
	tm = matrix 3 staticVector rotatingVector finalVector centerOfRotatoin
	--rotate
	rotateX tm 90
	--extract the new vector
	rotatedVector = tm.row2
)



select (point pos:v_left_vert)

road_sum.selectedVertices  = #{157}
v_right_vert = polyop.getVert road_sum right_vert






roGenStruct.rotateVerticesAroundPoint $ (polyop.getVertSelection $) 20



		--convert back forward to get triangles later
		 road_sum_mesh = ConvertTo road_sum editable_mesh
		 road_sum = ConvertTo road_sum editable_poly
		-- compute face distances, 
		--face_distances = GetRoadFaceCenterDistances road_prefabric
		 face_centers = roGenStruct.getRoadFaceCenters road_prefabric
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
roGenStruct.drawLineBetweenTwoPoints rayOrigin (rayOrigin+dir*20.0) (Color 255 0 0)
			append rays (ray rayOrigin dir)
		)		
		 hitArray = roGenStruct.findAllIntersectionsUsingRays road_sum rays
			
		--slice (gismo orientation pt2 t2_x)
		 poly_faces =  roGenStruct.getMeshFacesToPoly road_sum hitArray 
		polyop.slice road_sum poly_faces (ray pt2 t2_x)
		
		--Select faces for delete
		rays = #()
		for i in 1 to face_centers.count do
		(
			--rayOrigin = (pt2+t2_y*face_distances[i]+t2_z*10.0-t2_x*10.0)
			--dir = (-t2_z)
			 rayOrigin = face_centers[i][1] * t_matrix + pt2 - t2_x*10.0
			 dir = face_centers[i][2] * t_matrix
roGenStruct.drawLineBetweenTwoPoints rayOrigin (rayOrigin+dir*20.0) (Color 0 255 0)	
point pos:rayOrigin			
point pos:(rayOrigin+dir*20.0)			
			append rays (ray rayOrigin dir)
		)	
		hitArray = roGenStruct.findAllIntersectionsUsingRays road_sum rays
		ConvertTo road_sum editable_poly
		--remove all wrong faces
		polyop.deleteFaces road_sum (roGenStruct.getMeshFacesToPoly road_sum hitArray)
		weldEditPoly road_sum 1.0	
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		pt1 = getKnotPoint spline 1 1
		tn1 = getOutVec spline 1 1
		pt2 = getKnotPoint spline 1 knot_count
		tn2 = getInVec spline 1 knot_count

		-- transform matrix vectors for road 
		t_x = normalize (tn1-pt1)
		t_y = normalize([-t_x.y, t_x.x, 0.0])
		t_z = cross t_x t_y
		--adjust road position and rotation	
		road_transform = road_sum.transform
		road_transform.row1 = t_x
		road_transform.row2 = t_y
		road_transform.row3 = t_z
			
		road_sum.transform = road_transform
		
		pd.gizmo.position = pt1 * (getModContextTM road_sum pd) * (inverse road_sum.objecttransform)

		
		pd.gizmo.rotation = (quat -0.999978 0 0.00663416 0)
		pd.gizmo.rotation.x = -0.999978
		pd.gizmo.rotation.y = 0
		pd.gizmo.rotation.z = 0.00663416

		
		
		
		
		
		
		
		
		
		
		
		Available in 3ds Max 2008 and higher. Previously available in the Avguard Extensions. 
		bb= nodeLocalBoundingBox $teapot01
		point pos:bb[1]
		point pos:bb[2]

		
		
repairShape spline		
fn repairShape spline = (
	
	undo off (
		local n, w, c
		n=spline.name ; w=spline.wirecolor; c=circle();
		c.rotation = spline.rotation; c.pos = spline.pos;
		convertTo c SplineShape; addAndWeld c spline 0.0; 
		open c 1; deleteSpline c 1; updateshape c;
		c.name=n ; c.wirecolor = w
	)
)


			--	$.selectedEdges = polyop.getBorderFromEdge $ 82
