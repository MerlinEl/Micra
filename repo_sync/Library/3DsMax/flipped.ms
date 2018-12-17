	--martin fedor
	
	
	fn createCWPolygon dir p1 p2 p3 p4 obj verts =
	(
		--check if verts ids created CW
		local v1 = p2-p1
		local v2 = p3-p2
		local sk = cross v1 v2
		--format "dir:%\tvect:%\n" dir (dot sk dir)
		if (dot sk dir) < 0 do --is fliped face
		(
			
		)
		polyOp.createPolygon new_box verts
	)