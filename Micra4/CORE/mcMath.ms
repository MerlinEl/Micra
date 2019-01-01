--------------------------------------------------------------------------------
/* mcMath by Orien 2019 */
--------------------------------------------------------------------------------
/*
*@Used Structures
	Micra
*
*@Used Objects

*
*/
struct MICRA_MATH (
	fn isInteger num = (mod num 1 == 0),
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
	--round down a number amd convert it to even: 12445 to 12444
	fn roundToEven num = (
		
		return 2 * int( num / 2)
	),
	fn getVectorsAngle v1 v2 = (acos(dot (normalize v1) (normalize v2))),
	fn movePointAlongVector p v val = ( p + (normalize v) * val ),
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
	function get2DBoundingBox pos_array =
	(
		local bmin, bmax
		for v in pos_array do
		(
			if bmin != undefined then
			(
				bmin.x = amin #(v.x, bmin.x)
				bmin.y = amin #(v.y, bmin.y)
				
				bmax.x = amax #(v.x, bmax.x)
				bmax.y = amax #(v.y, bmax.y)
			)
			else bmin = copy (bmax = v)
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
)
--create instance
Global mcMath = Micra.instanceStructure MICRA_MATH "mcMath"