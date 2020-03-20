--------------------------------------------------------------------------------
/* mcMath by Orien 2019 */
--------------------------------------------------------------------------------
/*
*@Used Structures
	Micra
*
*@Used Objects

*
*@Study
http://www.illusioncatalyst.com/3dsmax_files/snippets/geometry.php
https://forums.cgsociety.org/t/geometrical-calculations-points-lines-planes-intersections-distances-angles/906269
*/
struct MICRA_MATH (

	fn getSource = getSourceFileName(), --get path of this script
	fn randomBoolean = (random 0.0 1 >= 0.5),
	fn isInteger num = (mod num 1 == 0),
	/**
	*@Usage	> get number of digits
	*@Example
		numDigits 0.56456 --> 0
		numDigits 45.56456 --> 2
		numDigits 454.56456 --> 3
	*/
	fn numDigits num = (

		num = ( floor ( log10 (abs num) ) ) + 1
		int (amax num 0)
	),
	--usage:	mcMath.roundToInt 25.45 10
	--receives the number 120 435 it return 120 000 wich is the nearest ten thousand etc..
	fn roundToInt num round = (
		
		return int((num)/round)*round
	),	
	--usage: 	mcMath.roundToDecimals 25.45454 10
	--			mcMath.roundToDecimals 25.44554 100
	--decimals 10(1) 100(2) 1000(3)
	--245.85714 -->  245.867  --number length is shorten to 6 places why ???
	fn roundToDecimals num dec = (
		
		--format "round num:% to:%\n" num dec
		local round_up = false
		local dec_str = num as String --convert num to string
		dec_str = trimLeft dec_str "1234567890" --keep decimals
		dec_str = trimLeft dec_str "." --remove dot
		local round_pos = (dec as String).count --get second place after round pos
		--format "dec_str:% round_pos:%\n" dec_str round_pos
		if dec_str.count >= round_pos do ( 
			
			round_num = execute dec_str[round_pos] --get round nuber 
			--format "round_num:%\n" round_num
			round_up = round_num >= 5
		) 
		local result = int((num as float)*dec)/float(dec) 
		if round_up do result = result + (1 /  dec as float)
		return result
	),
	--Author :  Kostadin Kotev / miau_u@yahoo.com /
	function roundFloat d pre:0.01 = (
	
		d = (d as float)/pre
		local v = if (d - (v1 = floor d)) > ((v2 = ceil d) - d) then v2 else v1 
		v*pre
	),
	--round down a number amd convert it to even: 12445 to 12444
	fn roundToEven num = (
		
		return 2 * int( num / 2)
	),
	--Round number each > 1cm, 5cm, 10cm, 50cm, 1m 
	fn roundIntLimited num step:10 = (

		--if is float round it first
		if classOf num == Float do num = int (roundFloat num pre:1)	
		local cnt = int (num / step) --steps count in num
		local m = mod num step --get modulo
		case step of (

			1		: num
			5		: if m > 2		then (cnt * step + 5		) else cnt * step
			10	: if m > 4		then (cnt * step + 10		) else cnt * step
			50	: if m > 24	then (cnt * step + 50		) else cnt * step
			100	: if m > 49	then (cnt * step + 100	) else cnt * step
			default:undefined
		)
	),
	/**
	*@Usage
		value:int 	input number
		min_val:int	minimum value	
		max_val:int	maximum value
		return:int	min, max or value
	*@Example
		mcMath.minMax 100	1	50	--> 50
		mcMath.minMax -1	1	50	--> 1
		mcMath.minMax 100	1	200	--> 100
	*/
	fn minMax value min_val max_val = (
	
		value = amax #(value, min_val) --min
		value = amin #(value, max_val) --max
	),
	fn degTorad deg = (PI/deg),
	/**
	*@Usage Kružnice vepsaná do trojúhelníku TEST
	
	--TRIGON  --by gazybara
	local spl = splineshape()
	addNewSpline spl
	addKnot spl 1 #corner #line [-50,-30,0]
	addKnot spl 1 #corner #line [0,100,0]
	addKnot spl 1 #corner #line [60,40,0]
	close spl 1
	spl.pivot = spl.center
	updateshape spl
	p1 = getknotpoint spl 1 1
	p2 = getknotpoint spl 1 2
	p3 = getknotpoint spl 1 3
	A = distance p1 p2
	B = distance p2 p3
	C = distance p1 p3
	S = (A+B+C)/2
	P = sqrt(S*(S-A)*(S-B)*(S-C))
	circle_radius = P/S
	circle_center = ((p1+p2+p3)/(A+B+C))*spl.transform
	--circle_center = mcMath.circumCenter p1 p2 p3
	circle pos:circle_center radius:circle_radius
	
	--center calculation --by Swordslayer
	fn barycentricToWorld p1 p2 p3 u v w = ( (u*p1 + v*p2 + w*p3) / (u + v + w) ),
	fn circumCenter p1 p2 p3 = ( --by Swordslayer
		
		local a = p3 - p2
		local b = p1 - p3
		local c = p2 - p1
	 
		local u = (dot a a) * (dot c b)
		local v = (dot b b) * (dot c a)
		local w = (dot c c) * (dot b a)
	 
		barycentricToWorld p1 p2 p3 u v w
	),
	*/
	fn getVectorsAngle v1 v2 = (
	
		local angle = acos(dot (normalize v1) (normalize v2))
		if angle<90.0 then angle else (180.0-angle)
	),
	fn getLinesAngle pA pB pC pD = (
	
		local vAB=pB-pA
		local vCD=pD-pC
		local angle = acos (dot (normalize vAB) (normalize vCD))
		if angle<90.0 then angle else (180.0-angle)
	),
	fn isClockwise vertices = (

		local sum = 0.0
		for i = 1 to vertices.count do (
			
			local p1 = vertices[i]
			---local p2 = vertices[(i + 1) % vertices.count] --C# style
			local p2 = if i < vertices.count then vertices[i+1] else vertices[1] --MXS style
			sum += (p2.x - p1.x) * (p2.y + p1.y)
		)
		sum > 0.0
	),
	fn isClockwise3P p1 p2 p3 = ( --not tested
	
		((p2.x - p1.x) * (p3.y - p1.y) - (p2.y - p1.y) * (p3.x - p1.x)) < 1e-9
	),
	fn movePointAlongVector p v val = ( p + (normalize v) * val ),
	/**
	*@Usage > get circular road of points around a center
	*/
	fn rotatePointAroundCenter center dir radius steps:8 inverse:false debug:false clr:green = (

		if inverse do dir = -dir
		local tm = (matrixFromNormal dir)
		local p = center+(tm.row1*radius)
		local div = 360/steps
		local points = for i = 0 to (360 - div) by div collect (

			local q = quat i (normalize dir)
			(((p - center ) * q) + center)
		)
		if debug do for i=1 to points.count do text text:(i as string) pos:points[i] size:5 wirecolor:clr
		points
	),
	fn intersectionLineLine p1 p2 p3 p4 = 
	(
		local a=p2-p1
		local b=p4-p3
		local c=p3-p1
		local cross1 = cross a b
		local cross2 = cross c b
		p1 + ( a*( (dot cross2 cross1)/((length cross1)^2) ) )
	),
	--intersection between a line and a plane
	fn planeLineIntersect plane_pos plane_normal line_point line_vector = 
	(
		local line_vector= normalize line_vector
		local d1=dot (plane_pos-line_point) plane_normal
		local d2=dot line_vector plane_normal
		if abs(d2)<.0000000754 
		then ( if abs(d1)>.0000000754 then 0 else -1 )
		else ( line_point + ( (d1/d2)*line_vector ) )
	),
	fn projectPointOnLine pA pB pC = 
	(
		local vAB=pB-pA
		local vAC=pC-pA
		local d=dot (normalize vAB) (normalize vAC)
		(pA+(vAB*(d*(length vAC/length vAB))))
	),
	fn isPointOnLine pA pB pC tol = 
	(
		local vAB=pB-pA
		local vAC=pC-pA
		local d=1.0-abs(dot (normalize vAB) (normalize vAC))
		if d<=tol then true else false
	),
	/**
	*@Usage > round Point3 to decimals
	*@Example
		po = [0.02564, 265.2655, 3.45646] 
		mcMath.roundPoint3 po 10
		po --> [0,265.3,3.5]
	*/
	fn roundPoint3 p dec = (
	
		p.x = roundToDecimals p.x dec
		p.y = roundToDecimals p.y dec
		p.z = roundToDecimals p.z dec
	),
	/**
	*@Author > Nikolay Litvinov (gniklit@gmail.com) 2014

	*/
	fn viewDirectionZ = (
	
		(inverse(getViewTM())).row3
	),
	/**
	*@Author > Joshua Newman (2004)
	*@Usage > Get Normal from 3 points
	*/
	fn get3PNormal p1 p2 p3= (
	
		local v3=normalize (p3-p1)
		local v2=normalize (p2-p1)
		normalize (cross v2 v3)
	),
	fn getPointsCenter pos_arr = (
	
		local points_center = [0,0,0]
		for p in pos_arr do points_center += p
		points_center /= pos_arr.count
	),
	function get2DBoundingBox pos_array =
	(
		local bmin = copy pos_array[1]
		local bmax = copy pos_array[1]
		for p in pos_array do (
		
			bmin.x = amin #(p.x, bmin.x)
			bmin.y = amin #(p.y, bmin.y)
			
			bmax.x = amax #(p.x, bmax.x)
			bmax.y = amax #(p.y, bmax.y)
		)
		return #(bmin, bmax)
	),
	fn get3DBoundingBox obj type:#world debug:false =
	(
		if classOf obj != Editable_Poly do return false
		local bmin, bmax, verts = obj.verts
		
		for v = 1 to verts.count do
		(
			local p = polyOp.getVert obj v --vert pos
			if type == #local do p *= inverse obj.transform
			
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
		
		if debug do
		(
			local bb = if type == #world then #(bmin, bmax) else #(bmin*obj.transform, bmax*obj.transform)
			format "Poly:%\nBounding Box:%\n" obj bb
			point pos:bb[1]
			point pos:bb[2]
		)
		
		case type of --return min & max
		(
			#world: return #(bmin, bmax) 
			#local: return #(bmin*obj.transform, bmax*obj.transform)
		)
	),
	/*
	*	@Example
	*	new_version = mcMath.versionUp 0.5
	*	0.51
	*/
	fn versionUp num = (
		
		local new_version  = num + 0.01 as float
		if isInteger new_version then int new_version else new_version
	)
	/*<end>*/
)
--create instance
Global mcMath = mcStructMan.instanceStructure MICRA_MATH "mcMath"


/*

--
--@Usage > Here is the hermite that I use for a multiplier of values to generate ease in and out setups.
	-- Tangent 1
	-- Tangent 2
	-- Input value from 0 to 1
--
fn hermite t1:3.0 t2:2.0 v:0.0 = (

	h1 = -2*v^t1 + 3*v^t2
)
---------------------------------------------------------------------------------

t = 0.5 -- our value in time between 0 and 1 
p = #(10,20,30,40) -- our array or knot vectors and tangents
n = 3 -- our nth degree generalizarion
fn factorial n = (

	if n <=0 then 1 else n * factorial(n-1)
)
e = 0
for i = 0 to n do (
	bc = (factorial n)/((factorial (n-i)) * (factorial i))
	e = e + p[(i+1)]*(bc*t^i*(1-t)^(n-i))
)


---------------------------------------------------------------------------------

fn getBezInterp p1 v1 v2 p2 val = (

  local a = val
  local b = 1 - val
 ( p1*b^3 + 3*v1*b^2*a + 3*v2*b*a^2 + p2*a^3  )
)
getBezInterp  $point01.pos $point02.pos $point03.pos $point04.pos 0.3333
*/


/*
--old
	function get2DBoundingBox pos_array =
	(
		local bmin, bmax
		for v in pos_array do (
		
			if bmin != undefined then (
			
				bmin.x = amin #(v.x, bmin.x)
				bmin.y = amin #(v.y, bmin.y)
				
				bmax.x = amax #(v.x, bmax.x)
				bmax.y = amax #(v.y, bmax.y)
			)
			else bmin = copy (bmax = v)
		)
		return #(bmin, bmax)
	),
*/