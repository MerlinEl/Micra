Global mcSplineBridgeDialog
if mcSplineBridgeDialog != undefined do DestroyDialog mcSplineBridgeDialog
rollout mcSplineBridgeDialog "Spline Bridge:" width:192 height:240
(
	local debug = false
	radiobuttons 'rdo_updown' "" pos:[80,152] width:100 height:16 labels:#("Up", "Down") default:1 columns:2 align:#left
	label 'lbl1' "Dir:" pos:[12,152] width:60 height:16 align:#left
	button 'btn_generate' "Generate" pos:[4,4] width:184 height:36 align:#left
	pickbutton 'btn_pickA' "None..." pos:[60,68] width:124 height:24 align:#left
	GroupBox 'grp2' "Edit:" pos:[4,48] width:184 height:184 align:#left
	button 'btn_rebuild' "Rebuild" pos:[8,172] width:176 height:24 align:#left
	pickbutton 'btn_pickB' "None..." pos:[60,96] width:124 height:24 align:#left
	pickbutton 'btn_pickS' "None..." pos:[60,124] width:124 height:24 align:#left
	label 'lbl2' "Point A:" pos:[12,72] width:48 height:16 align:#left
	label 'lbl3' "Point B:" pos:[12,100] width:48 height:16 align:#left
	label 'lbl4' "Spline:" pos:[12,128] width:48 height:16 align:#left
	checkbox 'chk_debug' "Debug" pos:[16,204] width:164 height:16 align:#left
	local multi = 0.55
	local test_point_c
	local test_point_t1
	local test_point_t2
	local arc_shape
	local points_arr = #()
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
	fn getThirdPointCoordinates p1 p2 up:true=	(
		
		local d = distance p1 p2	-- length of segment between points
		local s = (p1 + p2)/2			-- mid point pos between points
		local h = distance p1 s
		
		local partX = h*(p2.y - p1.y)/(d)
		local partY = h*(p2.x - p1.x)/(d)

		if up then [s.x + partX, s.y - partY, 0] else [s.x - partX, s.y + partY, 0]
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
	fn drawArcBetweenTwoPoints p1 p2 up:false = ( 

		local p3 = getThirdPointCoordinates p1 p2 up:up

p3.z = p1.z --hotfix for top projection

		local v1 = (p3 - p1) * multi
		local v2 = (p3 - p2) * multi
		local t1 = p1 + v1
		local t2 = p2 + v2
		
		if debug do (

			test_point_t1.pos=t1
			test_point_t2.pos=t2
			test_point_c.pos =p3
		)
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
		sp
	)
	fn moveSplineCornerTo way = (
		
		if classOf arc_shape != SplineShape or points_arr.count != 2 do return false
		local p1 = points_arr[1].pos
		local p2 = points_arr[2].pos
		local p3 = getThirdPointCoordinates p1 p2 up:(way == 1)
	
p3.z = p1.z --hotfix for top projection	
	
		local v1 = (p3 - p1) * multi
		local v2 = (p3 - p2) * multi
		local t1 = p1 + v1
		local t2 = p2 + v2
		
		t1.z = t2.z = 0

		if debug do (

			test_point_t1.pos=t1
			test_point_t2.pos=t2
			test_point_c.pos =p3
		)
		
		setOutVec arc_shape 1 1 t1
		setInVec arc_shape 1 2 t2
		updateShape arc_shape
		arc_shape.adaptive = true
	)
	fn generateBridge = (
		
		local sel = selection as Array
		local obj = sel[1]
		if sel.count == 2 then (
			
			points_arr = sel
			btn_pickA.text = sel[1].name
			btn_pickB.text = sel[2].name
			arc_shape = drawArcBetweenTwoPoints sel[1].pos sel[2].pos up:true
			btn_pickS.text = arc_shape.name
			select arc_shape
			max modify mode
			subObjectLevel = 1
			CompleteRedraw()

		) else if isEditPoly obj do (
			
			case subObjectLevel of (
			
				undefined : ()
				1 : (
				
					local vsel = polyOp.getVertSelection obj
					if vsel.numberSet == 2 do (
					
						local points = for v in vsel collect polyOp.getVert obj v
						subObjectLevel = 0
						arc_shape = drawArcBetweenTwoPoints points[1] points[2] up:true
						btn_pickS.text = arc_shape.name
						select arc_shape
						max modify mode
						subObjectLevel = 1
						CompleteRedraw()
						return OK
					)
				)
				2 : (capHoles obj)
				3 : (capHoles obj)
			)
			subObjectLevel = 4
			createSplineBridge obj poly
		)
	)
	fn rebuildShapeBridge way = ( --create new bridge and delete old one
		
		if classOf arc_shape !=  SplineShape or points_arr.count != 2 do return false
			
		local p1 = points_arr[1].pos
		local p2 = points_arr[2].pos
		local p3 = getThirdPointCoordinates p1 p2 up:(way == 1)

		local v1 = (p3 - p1) * multi
		local v2 = (p3 - p2) * multi
		local t1 = p1 + v1
		local t2 = p2 + v2
				
		format "rebuildShapeBridge >  p1:% p2:% p3:%\n" p1 p2 p3
		
		if debug do (

			test_point_t1.pos=t1
			test_point_t2.pos=t2
			test_point_c.pos =p3
		)
		
		--delete old vertices
		deleteKnot arc_shape 1 2
		deleteKnot arc_shape 1 1
		--create new vertices
		addKnot arc_shape 1 #corner #curve p1
		addKnot arc_shape 1 #corner #curve p2
		setKnotType arc_shape 1 1 #bezierCorner
		setKnotType arc_shape 1 2 #bezierCorner
		setOutVec arc_shape 1 1 (t1)
		setInVec arc_shape 1 2 (t2)
		updateShape arc_shape
		arc_shape.adaptive = true
	)
	on chk_debug changed state do (
		
		debug = state
		if state then (
			
			test_point_c = point wirecolor:red
			test_point_t1 = point wirecolor:yellow
			test_point_t2 = point wirecolor:yellow	
		
		) else (
		
			delete #(test_point_c, test_point_t1,	test_point_t2)
		)
	)
	on mcSplineBridgeDialog open do (

	)
	on mcSplineBridgeDialog close do (

		if debug do (
			
			delete #(test_point_c, test_point_t1,	test_point_t2)
		)
	)
	on btn_generate pressed  do (generateBridge())
	on rdo_updown changed state do (moveSplineCornerTo state)
	on btn_pickA picked obj do (
		
		if classOf obj  == Point do (
			
			btn_pickA.text = obj.name
			points_arr[1] = obj
		)
	)
	on btn_pickB picked obj do (
		
		if classOf obj  == Point do (
			
			btn_pickB.text = obj.name
			points_arr[2] = obj
		)
	)
	on btn_pickS picked obj do (
		
		if classOf obj  == SplineShape do (
			
			btn_pickS.text = obj.name
			arc_shape = obj
		)
	)	
	on btn_rebuild pressed do (rebuildShapeBridge rdo_updown.state)
)
CreateDialog mcSplineBridgeDialog