--------------------------------------------------
--move points in to a line betwen two points--
--------------------------------------------------
fn straightenVertices = 
(
	struct VERT_DATA (num, pos, dist) 
	--get all points
	local VD = #()
	local o = selection[1]
	if classOf o != Editable_Poly do return false
	local vsel = polyOp.getVertSelection o as array
	if vsel.count < 3 do return false
	for v in vsel do VD += #(VERT_DATA num:v pos:(polyOp.getVert o v))

	--get two outer points  
		--get center
		local center = [0,0,0]
		for v in VD do center += v.pos
		center /= VD.count
		--collect distances from center
		for v in VD do v.dist = distance center v.pos
		--get first vert
		fn compareFN v1 v2 =
		(
			local d = v1.dist - v2.dist
			
			case of
			(
				(d < 0.): -1
				(d > 0.):  1
				default:   0
			)
		)
		--sort verts data by distance from center
		qsort vd compareFN 
		local vert1 = vd[vd.count]
		--remove this point from VD
		deleteItem VD vd.count 
		--to get second vert you must find farthest vertex from vert1
		for v in VD do v.dist = distance vert1.pos v.pos
		qsort vd compareFN 
		local vert2 = vd[vd.count]
		--remove this point from VD
		deleteItem VD vd.count 
		
	--move the rest points in to line which is between vert1 and vert2
	fn projectPointOnLine pA pB pC = 
	(
		local vAB=pB-pA
		local vAC=pC-pA
		local d=dot (normalize vAB) (normalize vAC)
		(pA+(vAB*(d*(length vAC/length vAB))))
	)
	for v in VD do  
	(
		local line_proj_pos = (projectPointOnLine vert1.pos vert2.pos v.pos)	 
		polyOp.setVert o v.num line_proj_pos
	)	
)
--straightenVertices()

-------------------------------------------------------------
--move points in to a curve (circle) betwen two points--
-------------------------------------------------------------
fn curveVertices = 
(	
	struct VERT_DATA (num, pos, dist) 
	--get all points
	local VD = #()
	local o = selection[1]
	if classOf o != Editable_Poly do return false
	local vsel = polyOp.getVertSelection o as array
	if vsel.count < 3 do return false
	for v in vsel do VD += #(VERT_DATA num:v pos:(polyOp.getVert o v))

	--get two outer points  
		--get center
		local center = [0,0,0]
		for v in VD do center += v.pos
		center /= VD.count
		--collect distances from center
		for v in VD do v.dist = distance center v.pos
		--get first vert
		fn compareFN v1 v2 =
		(
			local d = v1.dist - v2.dist
			
			case of
			(
				(d < 0.): -1
				(d > 0.):  1
				default:   0
			)
		)
		--sort verts data by distance from center
		qsort vd compareFN 
		local vert1 = vd[vd.count]
		--remove this point from VD
		deleteItem VD vd.count 
		--to get second vert you must find farthest vertex from vert1
		for v in VD do v.dist = distance vert1.pos v.pos
		qsort vd compareFN 
		local vert2 = vd[vd.count]
		--remove this point from VD
		deleteItem VD vd.count 
		--move the rest points in to curve which is between vert1 and vert2
		fn projectPointOnLine pA pB pC = 
		(
			local vAB=pB-pA
			local vAC=pC-pA
			local d=dot (normalize vAB) (normalize vAC)
			(pA+(vAB*(d*(length vAC/length vAB))))
		)
		--calculate radius
		center = (vert1.pos+vert2.pos)/2
		point pos:center wirecolor:green
		print vd.count
		for v in VD do  
		(
			local line_proj_pos = (projectPointOnLine vert1.pos vert2.pos v.pos)	
			point pos:line_proj_pos wirecolor:red
			
			local rad = distance vert1.pos center
			local dist1 = distance  line_proj_pos center
			local dist2 = distance v.pos line_proj_pos
			format "dist1:%\tdist2:%\trad:%\n" dist1 dist2 rad
			local h = sqrt (rad^2 - dist1^2)
			local norm = normalize (cross (vert1.pos  - vert2.pos) [0,0,1])
			local curve_proj_pos = line_proj_pos - h * norm --((v.pos - line_proj_pos)/dist2)
			
			polyOp.setVert o v.num curve_proj_pos
		)	
	)		
	curveVertices()
	
	
	/*
	prozkoumat 
	
MultiHidePoly
MultiHidefunc()
SaveSelection
SaveSelfunc()
GeoPoly
GeoPolyfunc()
CurveLoop
CurveLoopfunc()
	*/