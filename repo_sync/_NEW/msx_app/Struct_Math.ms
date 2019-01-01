Struct MY_MATH_STRUCTURE (

	fn isInteger num = (mod num 1 == 0),
	--usage:	mcMath.roundToInt 25.45 10
	--receives the number 120 435 it return 120 000 wich is the nearest ten thousand etc..
	fn roundToInt num round = (
		
		return int((num)/round)*round
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
	)
)
Global myMath = MY_MATH_STRUCTURE()