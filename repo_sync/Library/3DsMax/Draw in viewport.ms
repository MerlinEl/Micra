		fn drawMarker pos dir =
		(
			--gw.resetUpdateRect()
			completeredraw()
			--gw.clearScreen (Box2 800 600 20 30 ) useBkg:false
			local GridTm = matrixFromNormal dir
			GridTm.row4 = pos
			gw.setTransform GridTm
		
			--draw axis
			gw.setColor #line red
			gw.Polyline #([-20,0,0],[20,0,0]) false --Line X
			gw.setColor #line green
			gw.Polyline #([0,-20,0],[0,20,0]) false --Line Y
			gw.setColor #line blue
			gw.Polyline #([0,0,0] , [0,0,20]) false --Line Z
			
			--draw circle
			local n = 24
			local r = 5
			local ring = #()
			for i = 1 to n do
			(
				local a = (360 / n) * i
				local x = r * (cos a)
				local y = r * (sin a)
				--format "X:% Y:%\n" x y
				ring  += #([x,y,0])--, [x,y,1])
			)
			gw.setColor #line yellow
			gw.polyline ring  true

			gw.enlargeUpdateRect #whole
			gw.updateScreen()
		)



if is #sel_1 and is #shp then
(
	sel = $selection[1]
	verts = numKnots sel
	edges = numSegments sel 1
	gw.setTransform sel.transform
	gw.setColor #line blue
	
	
	vectArr = for v=1 to (verts/2) collect 	(getInVec sel v 1)

	gw.Polyline vectArr false
	gw.enlargeUpdateRect #whole
	gw.updateScreen()
)
/*
--Line X
gw.setTransform (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])
gw.setColor #line blue
gw.Polyline #([-70,0,0],[70,0,0]) false
gw.enlargeUpdateRect #whole
gw.updateScreen()
--Line Y
gw.setTransform (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])
gw.setColor #line blue
gw.Polyline #([0,-70,0],[0,70,0]) false
gw.enlargeUpdateRect #whole
gw.updateScreen()
*/
--paint a line to wiew top on a shape
fn HighlightSpline =
(
	if is #sel_1 and is #spline then
	(
		verts = numKnots $
		edges = numSegments $ 1
		r=0.05
		n=6
		
		for i in 2 to verts by 2 do
		(
			p1 = getKnotPoint $ 1 i
			p2 = getKnotPoint $ 1 (i-1)
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
			for i in 1 to 6 do
			(
				a = (360 / n) * i
				x = r * (cos a)
				y = r * (sin a)
				-- format "X:% Y:%\n" x y
				gw.polyline #([x,y,0], [x,y,l]) false
			)
			
		)
		gw.enlargeUpdateRect #whole
		gw.updateScreen()
	)
)

--paint a line to wiew top a on shape
fn HighlightPolyEdges =
(
	if is #sel_1 and is #poly then
	(
		verts = $.Verts.count
		edges = $.Edges.count
		gw.setColor #line blue
		r=0.05
		n=6
		
		for i in 2 to verts by 2 do
		(
			p1 = polyOp.getVert $ (i-1)
			p2 = polyOp.getVert $ i
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
			for i in 1 to 12 do
			(
				a = (360 / n) * i
				x = r * (cos a)
				y = r * (sin a)
				-- format "X:% Y:%\n" x y
				gw.polyline #([x,y,0], [x,y,l]) false
			)
			
		)
		gw.enlargeUpdateRect #whole
		gw.updateScreen()
	)
)
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
				-- format "X:% Y:%\n" x y
				gw.polyline #([x,y,0], [x,y,l]) false
			)
			
		)
		gw.enlargeUpdateRect #whole
		gw.updateScreen()
	)
)



/*
fn drawBoundingBox theMin theMax =
(
gw.setTransform(Matrix3 1)
lineArrays = #(
#(theMin ,[theMin.x, theMin.y, theMax.z], [theMin.x, theMax.y, theMax.z],[theMin.x, theMax.y, theMin .z]),
#(theMax ,[theMax.x, theMin.y, theMax.z], [theMax.x, theMin.y, theMin.z],[theMax.x, theMax.y, theMin .z]),
#(theMin ,[theMax.x, theMin.y, theMin.z]),
#([theMin.x,theMax.y,theMin.z] ,[theMax.x, theMax.y, theMin.z]),
#([theMin.x,theMax.y,theMax.z] ,[theMax.x, theMax.y, theMax.z]),
#([theMin.x,theMin.y,theMax.z] ,[theMax.x, theMin.y, theMax.z])
)

gw.setColor #line [255,0,0]
for lines in lineArrays do gw.polyline lines true
gw.enlargeUpdateRect #whole
gw.updateScreen()
)

fn drawBBoxesForSelection =
(
	for o in selection do drawBoundingBox o.min o.max
)

unregisterRedrawViewsCallback drawBBoxesForSelection
registerRedrawViewsCallback drawBBoxesForSelection 
*/