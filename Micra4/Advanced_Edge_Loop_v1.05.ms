(--strat

	local obj = selection[1]
	if obj != undefined and classOf obj == Editable_Poly do
	(
		local FirstEdge     = polyOp.getEdgeselection obj --> define first edge
		if (subobjectLevel == 2 and FirstEdge.numberset == 1) then
		(
			--clear selection ,and select one edge
			polyOp.setEdgeselection $ (polyOp.getEdgeselection $ as array)[1]
			--*********--
			--TRUE RING--
			--*********--
			local step, EndProgress, FacesFrEdge, MyFaceArray, EdgesFrFace, VertsFrEdge, EdgesFrVerts, MyEdgeArray, eLoop, LoopStep
			step = 0
			EndProgress  = false
			
			FacesFrEdge  = polyOp.getFacesUsingEdge $ FirstEdge
			MyFaceArray  = deleteItem ((polyOp.getFacesUsingEdge $ FirstEdge)as array) 2 -->get last face from edges
			EdgesFrFace  = polyOp.getEdgesUsingFace $ MyFaceArray   --> get edges from first face
			VertsFrEdge  = polyOp.getVertsUsingEdge $ FirstEdge   --> get verts from first edge
			EdgesFrVerts = polyOp.getEdgesUsingVert $ VertsFrEdge --> get edges from verts
			MyEdgeArray  = (FirstEdge as array) + ((EdgesFrFace-EdgesFrVerts) as array) --> collecting my array
			(
				while EndProgress == false do
				(
					FacesFrEdge  = polyOp.getFacesUsingEdge $ MyEdgeArray[MyEdgeArray.count] 
					
					--Check end of geometry (exit loop)
					if FacesFrEdge.numberset == 1 do (EndProgress = true ; print "Progress Terminated:(End of geometry).")
					
					MyFaceArray = MyFaceArray + deleteItem FacesFrEdge MyFaceArray[MyFaceArray.count]
					EdgesFrFace = polyOp.getEdgesUsingFace $ (deleteItem FacesFrEdge MyFaceArray[MyFaceArray.count-1])
					
					VertsFrEdge  = polyOp.getVertsUsingEdge $ MyEdgeArray[MyEdgeArray.count]
					EdgesFrVerts = polyOp.getEdgesUsingVert $ VertsFrEdge
					MyEdgeArray = MyEdgeArray + ((EdgesFrFace - EdgesFrVerts) as array)
					
					--Check duplicate edges (exit loop)
					if (FirstEdge as array)[1] == MyEdgeArray[MyEdgeArray.count] do (EndProgress = true ; print "Progress Terminated:(Double Edges).")
					
					
					--Prevent loop for Kill Max
					step += 1
					if step == 3000 do (EndProgress = true ; print "Progress Terminated:(Error).")
				)
			)
			--format "%" MyEdgeArray
			/*
			--select loop by 1
			polyOp.setEdgeselection $ MyEdgeArray ; completeredraw()
			*/
			--select loop by 2
			eLoop = #()
			LoopStep = 2
			for i in 1 to MyEdgeArray.count by LoopStep do eLoop[i] = MyEdgeArray[i]
			while findItem eLoop undefined != 0 do deleteItem eLoop (findItem eLoop undefined)
			polyOp.setEdgeselection $ eLoop ; completeredraw()
		)
		else ( print "Select a edge first")
	)
)--end