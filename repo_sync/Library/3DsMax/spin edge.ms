(
	local drawing_points = false, poly_obj
	local hit_rays = #(), markers = #(), mid_pos, mid_vect, points_offset 
	
	fn getScreenRayAtNode obj =
    (
        screenRay = mapScreenToWorldRay mouse.pos
        finalRay = intersectRay obj screenRay
        finalRay
    )
	fn isEditPoly obj = (classOf obj == editable_poly)
	fn spinLine vp hit_rays =
	(
		if mid_pos != undefined  then
		(
			local mouse_hit = getScreenRayAtNode poly_obj --(mapScreentoWorldRay vp)
			if mouse_hit == undefined do return false
			
			format "mouse hit:%\n" mouse_hit
			
			local mouse_vect = normalize (mouse_hit.pos - mid_pos) 
			local new_vect   = normalize (cross mouse_vect mid_vect)
			local v1 =  points_offset * new_vect
			local new_p1 = mid_pos + v1 
			local new_p2 = mid_pos - v1 
			
			markers[1].pos = new_p1
			markers[2].pos = new_p2
			markers[3].pos = mouse_hit.pos
		)
	)

	tool pickPoints
	(		
		on start do 
		(
			poly_obj = selection[1]
			if not isEditPoly poly_obj do #stop
 			poly_obj.xray = true
		)
		
		on mousePoint click do
		(
			local ir = getScreenRayAtNode poly_obj
			if click > 1 do
			(
				if ir != undefined and hit_rays.count < 2 do --create two points
				(
					hit_rays += #(ir)
					--create point in hit pos
					markers += #(point pos:ir.pos dir:ir.dir name:(uniqueName "hit"))
				)
				
				if hit_rays.count == 2 and mid_pos == undefined do -- collect data and create mid point
				(
					
					mid_pos   = (hit_rays[1].pos + hit_rays[2].pos)/2
					mid_vect  = normalize (hit_rays[1].dir + hit_rays[2].dir)
					points_offset = distance hit_rays[1].pos  mid_pos
					--create middle point
					point pos:mid_pos dir:mid_vect name:"Mid Point"
					--creata point for mouse marker
					markers += #(point pos:mid_pos dir:mid_vect name:"Mouse Pos")
				)
			)
			--#stop
		)
		
		on mouseMove click do 
		( 
			if mid_pos != undefined do spinLine ViewPoint hit_rays
		)
	)
	startTool pickPoints
)