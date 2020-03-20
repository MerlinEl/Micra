		
	fn createPolygonBetweenTwoEdges obj =  (
		
		SuspendEditing()
		local new_obj = #()
		with redraw off  try(
		
			if classOf obj != Editable_Poly do return false
			local esel = polyOp.getEdgeSelection obj
			local everts = polyOp.getVertsUsingEdge obj esel
			local verts_pos = for v in everts collect (polyOp.getVert obj v) 
			local points_center = [0,0,0]
			for p in verts_pos do points_center += p
			points_center /= verts_pos.count
			--point size:10 pos:points_center wirecolor:red
			local v1 = verts_pos[1] - points_center 
			qsort verts_pos mcPoly.sortVertsByCenter center:points_center CW:false
			local normal_angle = cross (verts_pos[1] - verts_pos[2]) (verts_pos[3] - verts_pos[2])
			if normal_angle.z > 0 do verts_pos = mcArray.reverseArray verts_pos
			--format "normal:%\n"	normal_angle
			--visualize + info
			/*vcolors = #(red, green, blue, yellow)
			for i=1 to verts_pos.count do (

				local p1 = verts_pos[i]
				local p2 = if i < verts_pos.count then verts_pos[i+1] else verts_pos[1]
				local v1 = p1 - points_center
				local v2 = p2 - points_center
				ang = mcMath.getVectorsAngle v1 v2
				format "verts a:% b:% angle:%\n" i (if verts_pos.count then i+1 else 1) ang 

				local te = text size:11 kerning:0 leading:0 pos:p1 wirecolor:vcolors[i]
				te.text = i as string
				te.rotation.x_rotation += 90
				te.rotation.z_rotation -= 90
				mcSpline.drawArrow points_center p1 head_size:1 clr:vcolors[i]
			)*/
			local new_name = uniqueName (obj.name+"stairs_coll_")
			new_obj = mcPoly.createPolygonObj verts_pos objName:new_name
		) catch ResumeEditing()
		ResumeEditing()
		select new_obj
	)
	undo "Create Polygon Between Two Edges" on createPolygonBetweenTwoEdges $