		fn showObjectNames =
		(	
			local sel = selection as array
			gw.setTransform(Matrix3 1)
			for o in sel do
			(
				local pos =o.min - [0,1,0]-- (o.min+o.max)/2 + [0,0,o.max.z/2] 
				gw.text pos o.name color:yellow
			)
			gw.enlargeUpdateRect #whole
			gw.updateScreen()
		)