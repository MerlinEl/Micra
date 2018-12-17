--paint a line to wiew top a on shape selected edges
fn HighlightSelPolyEdges =
(
	if is #sel_1 and is #poly then
	(
		local obj,eSel,r,n,eVerts,p1,p2
		obj = (selection as array)[1]
		eSel = mcGet #eSel
		gw.setColor #line blue
		
		r=0.05
		n=12
		
		for i in eSel do
		(
			eVerts = (polyOp.getVertsUsingEdge obj i) as array
			p1 = (polyOp.getVert obj eVerts[1])
			p2 = (polyOp.getVert obj eVerts[2])
			
			v = (p2 - p1) -- get the vector
			l = length v
			
			-- format "p1: % p2: % \n" p1 p2
			-- make a matrix perpendicular to the vector
			vm = matrixFromNormal (normalize v)
			-- and positioned at p1 - makes it easier
			vm.translation = p1
			-- to draw
			gw.setTransform vm
			-- calculate and draw the lines
			for i in 1 to n do
			(
				a = (360 / n) * i
				x = r * (cos a)
				y = r * (sin a)
				--format "#(%,\t%)\n" [x,y,0] [x,y,l]
				gw.polyline #([x,y,0], [x,y,l]) false
			)
			
		)
		gw.enlargeUpdateRect #whole
		gw.updateScreen()
	)
)