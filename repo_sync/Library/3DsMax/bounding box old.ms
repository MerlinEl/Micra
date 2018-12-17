	fn create_bounding_box = WITH REDRAW OFF
	(
		local vsel = #{}, esel = #{}, fsel = #{}
		local bmin, bmax, center, opos, slev = subobjectLevel
		local sel = selection, obj = selection[1]
		if sel.count == 0 do return false
		if classOf obj == editable_poly do
		(
			case slev of
			(
				1:(vsel = polyOp.getVertSelection obj)
				2:(esel = polyOp.getEdgeSelection obj)
				3:(esel = polyOp.getEdgeSelection obj)
				4:(fsel = polyOp.getFaceSelection obj)
				5:(fsel = polyOp.getFaceSelection obj)
			)
		)
		
		--create dummy
		if keyboard.controlPressed then undo "Create Dummy" on
		(
			if vsel.numberSet != 0 then
			(
				local sum = [0,0,0]
				for v in vsel do sum += polyOp.getVert obj v
				center = sum/vsel.numberSet
				dummy pos:center
			)
			else (dummy pos:obj.pos dir:obj.dir)
		)
		--create mesh box
		else undo "Create Bounding Box" on
		(
			if vsel.numberSet != 0 do
			(
				local sum = [0,0,0]
				for v in vsel do
				(
					local p = polyOp.getVert obj v --vert pos				
					sum += p
					if bmin != undefined then
					(
						bmin.x = amin #(p.x, bmin.x)
						bmin.y = amin #(p.y, bmin.y)
						bmin.z = amin #(p.z, bmin.z)
						
						bmax.x = amax #(p.x, bmax.x)
						bmax.y = amax #(p.y, bmax.y)
						bmax.z = amax #(p.z, bmax.z)
					)
					else bmin = copy (bmax = p)
				)
				center = sum/vsel.numberSet
			)

			if center == undefiend 
			then 
			(
				opos   = (sel.min + sel.max)/2 
				opos.z = sel.min.z
			)
			else opos  = center
			
			local bbox = box pos:opos
			convertToPoly bbox
			local bmin = if bmin == undefiend then sel.min else bmin
			local bmax = if bmax == undefiend then sel.max else bmax
			polyOp.setVert bbox 1 bmin
			polyOp.setVert bbox 2 [bmax.x, bmin.y, bmin.z]
			polyOp.setVert bbox 3 [bmin.x, bmax.y, bmin.z]
			polyOp.setVert bbox 4 [bmax.x, bmax.y, bmin.z]
			
			polyOp.setVert bbox 5 [bmin.x, bmin.y, bmax.z]
			polyOp.setVert bbox 6 [bmax.x, bmin.y, bmax.z]
			polyOp.setVert bbox 7 [bmin.x, bmax.y, bmax.z]
			polyOp.setVert bbox 8 bmax
			local mat = standardMaterial opacity:24 diffuse:(color 196 37 248) selfIllumAmount:64
			bbox.material = mat
			bbox.name = uniqueName "UCX_"
			subobjectLevel = slev
		)
		completeRedraw()
	),