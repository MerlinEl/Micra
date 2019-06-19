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
		roGenStruct.conformRoadToSpline road_sum spline twsit_deg pt1 tn1
		
		--Cut excess part of road mesh (p2)
		--Adjust coonection angle with crossroad
		roGenStruct.cutExcessPartOfRoad road_sum road_prefabric pt2 tn2
