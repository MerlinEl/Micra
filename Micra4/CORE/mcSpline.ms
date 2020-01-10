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
	fn createSplineObject start_pos:[0, 0, 0] selected:false = (
	
		local sps = SplineShape pos:start_pos
		if selected do (
		
			mcMax.deselectAll()
			select sps
		)
		sps
	),
	/**
	*@Example
		new_spline = mcSpline.drawLineBetweenTwoPoints [10,20,30] [100,200,10]
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
	*@Usage >	draw spline arrow helper
	*@Example
		mcSpline.drawArrow [0,0,0] [100,0,0]
		mcSpline.drawArrow selection[1].pos selection[2].pos
	*/
	fn drawArrow p_start p_end clr:green head_size:4 arrow_name:"Arrow_Helper_" = (

		local sp_arrow = line()
		local dist = distance p_start p_end
		local z_end = [0,0,dist]
		--create arrow body ( -- ) in coords word at zero
		addnewspline sp_arrow
		addKnot sp_arrow 1 #corner  #line [0,0,0]
		addKnot sp_arrow 1 #corner  #line z_end
		--create arrow head ( > )
		local p1=[0, -head_size, -head_size] + z_end
		local p2=[0, 0, 0] + z_end
		local p3=[0, head_size, -head_size] + z_end
		addnewspline sp_arrow
		addKnot sp_arrow 2 #corner  #line p1
		addKnot sp_arrow 2 #corner  #line p2
		addKnot sp_arrow 2 #corner  #line p3
		--final setup
		updateshape sp_arrow
		sp_arrow.wirecolor = clr
		--add custom name or default unique name
		sp_arrow.name = if arrow_name == "Arrow_Helper_" then uniqueName arrow_name else arrow_name
		--move arrow to start and align
		sp_arrow.pos = p_start
		sp_arrow.dir = normalize (p_end - p_start)
		sp_arrow
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
	),
	fn splineToScript sp =
	(
		if classOf sp != SplineShape and classOf sp != line do return false
		local SPLINE_DATA, VERTEX_DATA
		struct SPLINE_DATA (pos, rect, steps, clr, splines, closed = #())
		struct VERTEX_DATA (index, pos, type, invec, outvec)
		local splines =#() --collect verts for each spline
		for s=1 to (numSplines sp) do --for all splines
		(
			local points_array = #()
			for v=1 to (numKnots sp s) do --for verts in current spline
			(
				points_array += #(VERTEX_DATA v (getKnotPoint sp s v) (getKnotType sp s v) (getInVec sp s v) (getOutVec sp s v))
			)
			append splines points_array
		)
		local rect = mcRect sp.min sp.max
		local SD = SPLINE_DATA sp.pos rect sp.steps sp.wirecolor splines
		for s=1 to (numSplines sp) do SD.closed += #(isClosed sp s) -- collect if spline is closed
		return SD
	),
	fn scriptToSpline sp_data =
	(
		local sps = SplineShape pos:sp_data.pos wirecolor:sp_data.clr --create spline
		for sp_index = 1 to sp_data.splines.count do --for all splines
		(	
			addNewSpline sps --add new spline in shape
			local sp_verts = sp_data.splines[sp_index] --pick spline verts
			for v in sp_verts do (addKnot sps sp_index v.type #curve v.pos v.inVec v.OutVec)
			if sp_data.closed[sp_index] do close sps sp_index
		)
		updateShape sps
		return sps
	),
	fn pointsFromSpline sp =
	(
		if classOf sp != SplineShape and classOf sp != line do return false
		local splines =#() --collect verts for each spline
		for s=1 to (numSplines sp) do
		(
			local points_array = #()
			for v=1 to (numKnots sp s) do
			(
				points_array += #(getKnotPoint sp s v)
			)
			append splines points_array
		)
		return splines
	),
	fn splineFromPoints sps num points_array type:#corner =
	(
		addNewSpline sps
		for p in points_array do 
		(
			case type of --#smooth | #corner | #bezier | #bezierCorner
			(
				#corner:addKnot sps num #corner #line p
				#smooth:addKnot sps num #smooth #curve p
			)
		)
	),
	fn splinesFromPoints points_array type:#corner color:green centerPivot:true = --created by Merlin in "6.2.2007 13:27:34"
	(
		if classOf points_array != Array do return false
		local sps
		if classOf points_array[1] == Array --more splines than one
		then 
		(
			sps = SplineShape pos:points_array[1][1] 
			for s=1 to points_array.count do (splineFromPoints sps s points_array[s] type:type)
		)
		else 
		(
			sps = SplineShape pos:points_array[1] 
			splineFromPoints sps 1 points_array type:type
		)
		updateShape sps
		sps.wirecolor = color
		if centerPivot do sps.pivot = (sps.min+sps.max)/2
		return sps
	),
	fn rebuildSpline type:#corner = --type:#smooth
	(
		local obj = selection[1]
		if classOf obj != SplineShape do return false
		undo "Rbuild Spline" on
		(
			local verts = numKnots obj 1
			local points_array = for v=1 to verts collect (getKnotPoint obj 1 v)
			splinesFromPoints points_array type:type
			delete obj 
			completeRedraw()
		)
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