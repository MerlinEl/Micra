
fn roundUp val =
(
	(ceil (val *= 1.0)) as integer
)
roundUp 9.5

-- rounds a value to n decimal places
fn round_to val n =
(
	&nbsp;&nbsp;&nbsp;&nbsp;local mult = 10.0 ^ n
	&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;(floor ((val * mult) + 0.5)) / mult
)

-- example
a = 49.248454
(round_to a 0) as integer
(round_to a 2)

fn roundFloat val = 
(
	local str = filterstring (val as string) "."
	if str.count != 2 do return val
	if str[2][1] as integer >= 5 then ceil val else floor val
)

roundFloat a


fn roundToLastInt val =
(
	fn roundInteger intg = if intg > 4 then 10 else 0 
	val = val as integer -- cut float values if exist
	str = val as string
	if str.count == 1 then  -- if value si between 0 to 9
	(
		return roundInteger val
	)
	else if str.count > 1 do -- if value is between 10 to infinite
	(
		new_str = substring str 1 (str.count-1) --cut the last int
	    last_int = roundInteger (str[str.count] as integer) --round last int
		return ((new_str+"0") as integer + last_int) as integer -- join last int back
	)
)

roundToLastInt 0.5

doubleval = dotnetobject "system.double" 48.4133
mc2system.show (dotnetclass "MidpointRounding")
decimalplaces = 0.01
math = (dotnetclass "system.math")
mc2system.show math
math.round (dotnetobject "decimal" 48.4133)
math.round doubleval
math.Floor (dotnetobject "decimal" 48.4133)
math.Ceiling (dotnetobject "decimal" 48.4133)

fn roundInt n = (n+0.5) as integer



--monkey_tester
--Step by step, assuming you're using "int" variables:
 x = 127-- start with 127
 x = x + 5-- add 5 (half of 10), x now equals 132
 x = x / 10-- divide by 10, yielding 13 (division of ints throws away the decimal part)
 x = x * 10-- multiply by 10, giving you 130



val = 619.402454
step = 10

fn roundInteger val step:10 = --10 , 100, 1000
(
	local num = val as integer -- throw away the decimal part
	if val >0 then num += step/2 else num -= step/2 -- add half of step
	num /= step -- divide by step, (division of ints throws away the decimal part)
	num *= step -- multiply by step
	return num
)

roundInteger 754 step:10 == 750
roundInteger 754 step:100 == 800
roundInteger 754 step:1000 == 1000

roundInteger 619.402454 step:10 == 620
roundInteger 6 step:10 == 10

roundInteger 169 step:10