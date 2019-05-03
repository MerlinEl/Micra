--------------------------------------------------------------------------------
/* mcSpline by Orien 2019 */
--------------------------------------------------------------------------------
/*
*@Used Structures
	mcStructMan
*
*@Used Objects
	undefined
*
*@Usage
	undefined
*
*@Example	
	undefined
*
*/
struct MICRA_NEW_STRUCTURE	(
	
	--variables

	
	--functions
	fn getSource = getSourceFileName(), --get path of this script
	/**
	*@Example
		new_spline = drawLineBetweenTwoPoints [10,20,30] [100,200,10]
		new_spline = drawLineBetweenTwoPoints selection[1].pos selection[1].pos
	*/
	fn drawLineBetweenTwoPoints p1 p2 = (
	
	  local ss = SplineShape pos:p1
	  addNewSpline ss
	  addKnot ss 1 #corner #line p1
	  addKnot ss 1 #corner #line p2
	  updateShape ss
	  ss
	),
	/**
	*@Example
		new_arc = mcSpline.drawArcBetweenTwoPoints2D selection[1].pos selection[2].pos
	*/
	fn drawArcBetweenTwoPoints2D p1 p2 angle_start:0 angle_end:90 = ( 
	
		if classOf p1 != Point3 or classOf p2 != Point3 do return false
		local p3 = [p2.x, p1.y, 0]
		local r = distance p3 p1
		arc radius:r from:angle_start to:angle_end pos:p3
	)
	/*<end>*/
)	
 --create instance
Global mcSpline = mcStructMan.instanceStructure MICRA_NEW_STRUCTURE "mcSpline"



/*
fn roundCornerSpline width length radius px py pz curv roundness:0.5 tm: name:"roundCorner" = (

	local circle_round = 0.551785 -- perfect circle
	if roundness == unsupplied do roundness = circle_round
	radius = amin #(width,length,radius)
	r = radius*roundness
	x = width - radius
	y = length - radius
	corner = Sp_line
	veram = numKnots corner
	ght = getKnotPoint corner 1 veram

	p1 = ght --[px,py,pz]
	p2 = p1 + [x,0,0]
	p4 = p1 + [width,length,0]
	p3 = p4 - [0,y,0]
	--print curv
	--print p1
	-- corner = line name:(uniquename name)



	-- addnewspline corner
	addKnot corner 1 #corner #line p1
	if x > 0 do addKnot corner 1 #corner #line p2
	addKnot corner 1 #bezierCorner #curve p2 p2 (p2 + [r,0,0])
	addKnot corner 1 #bezierCorner #curve p3 (p3 - [0,r,0]) p3
	if y > 0 do addKnot corner 1 #corner #line p4
	updateshape corner
	convertToSplineShape corner
	if iskindof tm Matrix3 do corner.transform = tm
	corner
	veram = numKnots corner
	ght = getKnotPoint corner 1 veram 
	curv = 1
)
*/