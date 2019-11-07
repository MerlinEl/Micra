macroscript PivotCenterSpline
  	category:"Maxis"
(
	/*
	Sets the pivot in the center of the selection.
	Works with vertices, segments and splines.
	*/
	fn middlepointVectors VectorsArray =
		(
			Vec = [0,0,0]
			for i in VectorsArray do(vec += i)
			vec /= VectorsArray.count
			return vec
		)

	fn GetSegsVectorArr seg_Arr = (--- Segments  
		tmpVec = #()	
		for i=1 to 	seg_Arr.count do(
			if seg_Arr[i].count != 0 do(
				k1 = (getKnotPoint $ i seg_Arr[i][1])
				modknt = if  (seg_Arr[i][1] ==  (numKnots $ i)) then(
							if (isClosed $ i) then (1) else(seg_Arr[i][1])
						)else((seg_Arr[i][1])+1)--end modKnot1
				k2 =(getKnotPoint $ i modknt)
				arr = #(k1,k2)
				if seg_Arr[i].count > 1 do(1
					for k=2 to seg_Arr[i].count do(
						append arr (getKnotPoint $ i seg_Arr[i][k])				
						modknt = if  ((seg_Arr[i][k])) ==  (numKnots $ i) then(
									if (isClosed $ i) then (1) else(seg_Arr[i][k])
								)else((seg_Arr[i][k])+1)--end modKnot
						append arr (getKnotPoint $ i modknt)--((seg_Arr[i][k])+1)
					)--for k
				)--if >1
				join tmpVec arr
			)--if != 0
		)--for i 
		return tmpVec
	)


	fn getSegmentsSelectedSpline =(
		gSpl = getSplineSelection  $
		SegArray = #()
		for i = 1 to (numSplines $) do (
			segArr = #()
			fi = findItem gSpl i
			if fi != 0 do(
				for k=1 to numSegments $ gSpl[fi]  do(
					append segArr k 
				)
			)--find item 
			append SegArray segArr
		)
		return SegArray
	)  	

	
------------------------------------|------------------------------------|------------------------------------|------------------------------------|	
	
if selection.count == 1 then(	
	if classof $ == SplineShape or classof $ == line then(
		case subobjectLevel of 
		(
		1:	(
			KnotsArray = for i=1 to (numSplines $) collect getKnotSelection $ i--getKnotSelection
			VecArray = #()

			for i=1 to KnotsArray.count do (
					for k=1 to KnotsArray[i].count do(
						append VecArray (getKnotPoint $ i KnotsArray[i][k])
					)--k
				)--i

			$.pivot = middlepointVectors VecArray	
			)--1
			
		2:	(
			SegsArray = for i=1 to (numSplines $) collect (getSegSelection $  i)
			VecArray = GetSegsVectorArr SegsArray
			$.pivot = middlepointVectors VecArray
			)--2
			
		3:	(
			SegsArray = getSegmentsSelectedSpline()
			VecArray = GetSegsVectorArr SegsArray
			$.pivot = middlepointVectors VecArray
			)--3	
		default:($.pivot = $.center) 	
		)
	)else(print "Selection Spline")	
)else(print "Selection object")	
------------------------------------|------------------------------------|------------------------------------|------------------------------------|	

)--end secript 

