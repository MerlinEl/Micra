Global mcSplineBridgeDialog
if mcSplineBridgeDialog != undefined do DestroyDialog mcSplineBridgeDialog
rollout mcSplineBridgeDialog "Spline Bridge:" width:196 height:84
(
	groupBox 'grp1' "Settings:" pos:[4,4] width:184 height:44 align:#left
	radioButtons 'rdo_updown' "" pos:[80,24] width:100 height:16 labels:#("Up", "Down") default:1 columns:2 align:#left
	label 'lbl1' "Dir:" pos:[12,24] width:60 height:16 align:#left
	button 'btn_generate' "Generate" pos:[4,52] width:184 height:24 align:#left
	fn isEditPoly obj = (classOf obj == editable_poly)
	fn drawLineBetweenTwoPoints p1 p2 = (
		
		local sp = SplineShape pos:p1
		addNewSpline sp
		addKnot sp 1 #corner #line p1
		addKnot sp 1 #corner #line p2
		updateShape sp
		return sp
	)
	fn refineSpline sp cnt = (
		
		local p1  = getKnotPoint sp 1 1
		local p2  = getKnotPoint sp 1 2
		local v = p2 - p1
		for i=1 to cnt do refineSegment sp 1 i 0.5
		setKnotType sp 1 1 #corner
		setKnotType sp 1 (numKnots sp) #corner
		updateShape sp
	)
	fn capHoles obj = (
		
		local fcount = obj.faces.count
		local esel = polyOp.getEdgeSelection obj		
		--if both cap created do select 2 new polygons
		polyOp.capHolesByEdge obj esel
		if obj.faces.count - fcount == 2 do polyOp.setFaceSelection obj #(obj.faces.count, obj.faces.count-1)
	)
	fn getDistanceBetweenPoints pt1Pos pt2Pos = (
		
		local x1 = pt1Pos.x
		local y1 = pt1Pos.y
		local x2 = pt2Pos.x
		local y2 = pt2Pos.y
		
		local u = x2 - x1
		local v = y2 - y1
		sqrt(u ^2 + v ^2)  -- distance between points
	)
	fn getThirdPointCoordinates p1 p2 &firstCandidatePos &secondCadidatePos =	(
		
		local d = getDistanceBetweenPoints p1 p2            -- length of segment between points
		local s = (p1 + p2)/2                                        -- mid point pos between points
		local h = getDistanceBetweenPoints p1 s
		
		local partX = h*(p2.y - p1.y)/(d)
		local partY = h*(p2.x - p1.x)/(d)

		local firstCandidatePos     = [s.x + partX, s.y - partY, 0]
		local secondCadidatePos     = [s.x - partX, s.y + partY, 0]
		true
	)
	fn createSplineBridge obj type =	(
		local fsel = polyOp.getFaceSelection obj as array
		if fsel.count != 2 do return false
		local p1 = polyOp.getFaceCenter obj fsel[1]
		local p2 = polyOp.getFaceCenter obj fsel[2]
		local sp = drawLineBetweenTwoPoints p1 p2
		refineSpline sp 1
		select sp
		subObjectLevel = 1
	)
	fn moveSplineCornerTo way = (
		
		local sp = selection[1]
		if classOf sp != SplineShape do return false
		if numsplines sp != 1 or numknots sp 1 != 3 do return false
		local p1 = getKnotPoint sp 1 1
		local p2 = getKnotPoint sp 1 3
		
		local up_pos = [0,0,0]
		local down_pos = [0,0,0]

		getThirdPointCoordinates p1 p2 &up_pos &down_pos
		
		setKnotPoint sp 1 2 (if way == 1 then up_pos else down_pos)
		updateShape sp
	)
	fn generateBridge = (
		
		local sel = selection as Array
		local obj = sel[1]
		if sel.count == 2 then (
			
			local sp = drawLineBetweenTwoPoints sel[1].pos sel[2].pos
			refineSpline sp 1
			select sp
			max modify mode
			subObjectLevel = 1
			moveSplineCornerTo rdo_updown.state
			
		) else if isEditPoly obj do (
			
			case subObjectLevel of
			(
				2:(capHoles obj)
				3:(capHoles obj)
			)
			subObjectLevel = 4
			createSplineBridge obj poly
		)
	)
	on btn_generate pressed  do (generateBridge())
	on rdo_updown changed state do (moveSplineCornerTo state)
)
CreateDialog mcSplineBridgeDialog