--Bridge 2--
(
	fn isEditPoly obj = (classOf obj == editable_poly)
	fn drawLineBetweenTwoPoints p1 p2 =
	(
		local sp = SplineShape pos:p1
		addNewSpline sp
		addKnot sp 1 #corner #line p1
		addKnot sp 1 #corner #line p2
		updateShape sp
		return sp
	)
	fn refineSpline sp cnt =
	(
		local p1  = getKnotPoint sp 1 1
		local p2  = getKnotPoint sp 1 2
		local v = p2 - p1
		for i=1 to cnt do refineSegment sp 1 i 0.5
		setKnotType sp 1 1 #corner
		setKnotType sp 1 (numKnots sp) #corner
		updateShape sp
	)
	fn capHoles obj =
	(
		local esel = polyOp.getEdgeSelection obj		
		--ic cap created success do select last two polygons
		if (polyOp.capHolesByEdge obj esel) do polyOp.setFaceSelection obj #(obj.faces.count, obj.faces.count-1)
		--local fuedge = polyOp.getFacesUsingEdge obj esel
		--polyOp.setFaceSelection obj fuedge
	)
	fn createSplineBridge obj type =
	(
		local fsel = polyOp.getFaceSelection obj as array
		if fsel.count != 2 do return false
		local p1 = polyOp.getFaceCenter obj fsel[1]
		local p2 = polyOp.getFaceCenter obj fsel[2]
		local sp = drawLineBetweenTwoPoints p1 p2
		refineSpline sp 3
		select sp
		subObjectLevel = 1
	)
	local obj = (selection as array)[1]
	if isEditPoly obj do
	(
		case subObjectLevel of
		(
			2:(capHoles obj)
			3:(capHoles obj)
		)
		subObjectLevel = 4
		createSplineBridge obj poly
	)
)