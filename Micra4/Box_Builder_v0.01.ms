(	
	fn getScreenRayAtNode obj =
    (
        screenRay = mapScreenToWorldRay mouse.pos
        finalRay = intersectRay obj screenRay
        finalRay
    )
	fn drawLineBetweenTwoPoints pointA pointB clr:green =
	(
		local sp = SplineShape pos:pointA
		addNewSpline sp
		addKnot sp 1 #corner #line PointA
		addKnot sp 1 #corner #line PointB
		updateShape sp
		sp.wirecolor = clr
		return sp
	)	
	fn moveFace obj f p1 p2 p3 p4 dist =
	(
		local face_n = polyOp.getFaceNormal obj f
		local verts  = polyOp.getVertsUsingFace obj f as array
		polyOp.setVert obj verts[1] (p1+face_n*dist)
		polyOp.setVert obj verts[2] (p2+face_n*dist)
		polyOp.setVert obj verts[3] (p3+face_n*dist)
		polyOp.setVert obj verts[4] (p4+face_n*dist)
		redrawViews()
	)
	fn rotatePivotByNormal obj n =
	(
		local p = point pos:obj.pos dir:n
		local p_rotation = p.rotation
		obj.dir              = n
		obj.objectOffsetRot *= p_rotation
		obj.objectOffsetPos *= p_rotation
		delete p
	)
	fn isFliped new_box dir n =
	(
		if (dot dir n) > 0 then return true else return false	
	)
	tool three_point_box
	(
		--local key, fill, back, targ
		local sp = #(), p1, p2, p3, p4, new_box, verts =#(), last_click, start_new = true
		local poly_obj = (selection as array)[1]
		on start            do (if classOf poly_obj != editable_poly do #stop)
		on mousePoint click do --coordsys grid
		(
			local ir = getScreenRayAtNode poly_obj
			
			if ir != undefined and click > 1 then 
			(
				if start_new do
				(
					convertToPoly (new_box = mesh vertices:#() faces:#())
					new_box.update
					start_new = false
				)
				
				(
					if p1 == undefined then				
					(
						p1 = ir.pos
						verts += #(polyOp.createVert new_box p1)
						sp    += #(point pos:p1 wirecolor:white)
					)
					else if p2 == undefined then 
					(
						p2 = ir.pos
						verts += #(polyOp.createVert new_box p2)
						sp    += #(point pos:p2 wirecolor:white)
						sp    += #(drawLineBetweenTwoPoints p1 p2 clr:yellow)
					)
					else if p3 == undefined then 
					(
						p3 = ir.pos
						verts += #(polyOp.createVert new_box p3)
						--move second point in to right angle between p1 and p3
						local v1 = normalize (p2 - p1)
						local v2 = (p3 - p1)
						p2 = p1+v1*(dot v1 v2)
						polyOp.setVert new_box 2 p2 --move second point in to new pos
						--cleate fourth point
						p4 = p1 + (p3 - p2)
						verts += #(polyOp.createVert new_box p4)
						sp    += #(point pos:p3 wirecolor:white)
						sp    += #(drawLineBetweenTwoPoints p2 p3 clr:yellow)
						--create a face
						polyOp.createPolygon new_box verts
						
						--check / fix face normal
						local n = polyOp.getFaceNormal new_box 1
						local is_flipped = (dot ir.dir n) < 0
						format "is_flipped:%\n" is_flipped
						if is_flipped do --polyOp.flipNormals new_box 1
						(
							polyOp.setVert new_box 1 p2
							polyOp.setVert new_box 2 p1
							polyOp.setVert new_box 3 p4
							polyOp.setVert new_box 4 p3
							
							local a = p1
							local b = p3 
							p1 = p2
							p2 = a
							p3 = p4
							p4 = b
						)
						--position and aligh pivot to object
						new_box.pivot = (p1+p2+p3+p4)/4
						
						--rotatePivotByNormal new_box (polyOp.getFaceNormal new_box 1)
						--?????
						
						--extrude face
						polyOp.extrudeFaces new_box 1 0.1
						last_click = mouse.pos
						--cap bottom of box
						polyOp.capHolesByVert new_box #(1,2,3,4)
					)
					else 
					(
						last_click = undefined
						--reset and start from begin
						p1 = undefined
						p2 = undefined
						p3 = undefined
						p4 = undefined
						start_new = true
						verts = #()
					)
				)
			)
			else if p4 != undefined do
			(
				last_click = undefined
				--reset and start from begin
				p1 = undefined
				p2 = undefined
				p3 = undefined
				p4 = undefined
				start_new = true
				verts = #()
			)
		)
		on mouseMove click do 
		(
			if last_click != undefined do 
			(
				local dist = distance last_click mouse.pos
				--format "mouse dist:%\n" dist
				moveFace new_box 1 p1 p2 p3 p4 (dist/5)
			)
		)
		on stop do try (delete sp) catch()
		on mouseAbort click do (print "aborted")
	)
	starttool three_point_box
)