
$.nsides =8
mcsystem.show $.verts[1]
$.verts[1].value
$.vertices[1].value
$.verts[1].index
$.verts[1].count
$.verts[1].getvert
$.selectedverts
$.verts[1].numsubs


--try(delete objects) catch()
fn roundCornerSpline width length radius roundness:0.5 tm: name:"roundCorner" = 
(
 local circle_round = 0.551785 -- perfect circle
 if roundness == unsupplied do roundness = circle_round
 radius = amin #(width,length,radius)
 r = radius*roundness
 x = width - radius
 y = length - radius
 p1 = [0,0,0]
 p2 = p1 + [x,0,0]
 p4 = p1 + [width,length,0]
 p3 = p4 - [0,y,0]
 
 corner = line name:(uniquename name)
 addnewspline corner
 addKnot corner 1 #corner #line p1
 if x > 0 do addKnot corner 1 #corner #line p2
 addKnot corner 1 #bezierCorner #curve p2 p2 (p2 + [r,0,0])
 addKnot corner 1 #bezierCorner #curve p3 (p3 - [0,r,0]) p3
 if y > 0 do addKnot corner 1 #corner #line p4
 updateshape corner
 convertToSplineShape corner
 if iskindof tm Matrix3 do corner.transform = tm
 corner
)
roundCornerSpline 20 40 10 
roundCornerSpline 20 40 10 tm:(scalematrix [-1,1,1])
roundCornerSpline 20 20 5 tm:(translate (scalematrix [1,-1,1]) [0,60,0])
roundCornerSpline 20 20 5 tm:(translate (scalematrix [-1,-1,1]) [0,60,0])



curvelength $


(
	--cterate dummy
	local objSp = $Line02
	local verts = numKnots objSp 1
	local dumys = #()
	for v=1 to verts do 
	(
		local vPos   = (getKnotPoint objSp 1 v)
		dumys += #(dummy pos:vPos)
	)
	format "dummys:%\n" dumys
	--animate dummy
	local frames = 30
	
	sliderTime = 0f
	for f=0 to (frames-1) do animate on
	(
		sliderTime = f
		for v=1 to verts do
		(
			local vPos   = (getKnotPoint objSp 1 v)
			dumys[v].pos = vPos
		) 
	)
)


	fn refineSpline sp cnt =
	(
		local cnt += 1
		local p1  = getKnotPoint sp 1 1
		local p2  = getKnotPoint sp 1 2
		local v = p2 - p1
		for i=1 to cnt-1 do addKnot sp 1 #smooth #curve ( p1 + v * (i/cnt as float) )
		/* --debug
		for i=1 to cnt-1 do 
		(
			local p = p1 + v * (i/cnt as float)
			point pos:p
		)
		*/
		setKnotType sp 1 1 #corner
		setKnotType sp 1 (numKnots sp) #corner
		updateShape sp
	)