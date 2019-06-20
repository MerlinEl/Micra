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
	
		--conform road to spline
-- 		roGenStruct.conformRoadToSpline road_sum spline twsit_deg pt1 tn1 --old way
		roGenStruct.conformRoadToSpline road_sum spline twsit_deg
		
		--Cut excess part of road mesh (p2)
		--Adjust coonection angle with crossroad
		roGenStruct.cutExcessPartOfRoad road_sum road_prefabric pt2 tn2


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

	
-- A translation that brings point 1 to the origin
-- Rotation around the origin by the required angle
-- A translation that brings point 1 back to its original position	
fn rotateVertexAroundpoint obj v_index angle_deg = (
	
	newX = centerX + (point2x-centerX)*Math.cos(angle_deg) - (point2y-centerY)*Math.sin(angle_deg)
	newY = centerY + (point2x-centerX)*Math.sin(angle_deg) + (point2y-centerY)*Math.cos(angle_deg)
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
		
		------------------------------		
		--fix start border line
		------------------------------
		vert_at_start = (roGenStruct.getClosestVert road_sum pt1)[1] 
		border_edges = roGenStruct.getBorderEdgesFromVertex road_sum vert_at_start
		road_sum.selectedEdges = border_edges
		road_sum.SelectEdgeLoop() --border edges
		border_vertices = polyop.getVertsUsingEdge road_sum (polyOp.getEdgeSelection road_sum)
		road_sum.selectedVertices = border_vertices --border vertices
		--get tangent vector
		v1 = tn1 - pt1
		--get right point
		rm = rotateZMatrix 90 --create a rotation matrix from the value
		rv1 = v1 * rm --transform the original vector using the matrix
		right_point = pt1 + rv1
		right_point.z = pt1.z --if is tangent rotated make it straight
		--get left point
		rm = rotateZMatrix -90 --create a rotation matrix from the value
		rv2 = v1 * rm --transform the original vector using the matrix
		left_point =  pt1 + rv2
		left_point.z = pt1.z --if is tangent rotated make it straight

po1 = point pos:right_point
po2 = point pos:left_point
sp1 = roGenStruct.drawLineBetweenTwoPoints po1.pos po2.pos  yellow
select #(po1, po2, sp1)

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
