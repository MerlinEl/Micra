
e       -- Euler's number
pi      -- pi
log x   -- natural logarithm
log10 x -- log base 10
exp x   -- exponantial
abs x   -- absolute value
floor x -- floor
ceil x  -- ceiling
pow x y -- power (mocnina)
sqrt x -- square root (odmocnina)



fn getRandomNumbers a b =
(
	local start = timeStamp()
	local fpath = (GetDir #export + "\\random_nums.txt")
	deleteFile fpath
	local f = createFile fpath
	format "#(" to:f
	
	local nums = #{a..b} as array
	local random_nums = #()
	
	local line_counter = 0
	for n=nums.count to 1 by -1 do
	(
		local random_pos = random  1 nums.count
		
		line_counter += 1
		if line_counter > 100 --next_line
		then (format "%,\n" nums[random_pos] to:f ; line_counter = 0)
		else if nums.count > 1 
			then (format "%," nums[random_pos] to:f)
			else (format "%)\n" nums[random_pos] to:f) --if last number, array is cosed

		deleteItem nums random_pos
	)
	close f
	
	local end = timeStamp()
	format "Processing took % seconds\n" ((end - start) / 1000.0)
)

getRandomNumbers 1 1000000



fn getRandomNumbers a b =
(
	--collect all numbers
	local nums = #{a..b} as array
	--define locals
	local random_nums = #()
	--collect random numbers
	for n=nums.count to 1 by -1 do
	(
		--get random pos in array
		local random_pos = random  1 nums.count
		--store number in this pos
		random_nums += #( nums[random_pos] )
		--remove the number from array
		deleteItem nums random_pos
	)
	format "random nums:%\n" random_nums
)

getRandomNumbers 1 100000



	fn refineLine p1 p2 cnt =
	(
		local v = p2 - p1
		for i=0 to cnt collect ( p1 + v * (i/cnt as float) )
	)

--Get Vectors Angle (eulerangle)

p1 = polyOp.getVert $ (polyOp.getVertSelection $ as array)[1]
p2 = polyOp.getVert $ (polyOp.getVertSelection $ as array)[1]
p3 = polyOp.getVert $ (polyOp.getVertSelection $ as array)[1]
p4 = polyOp.getVert $ (polyOp.getVertSelection $ as array)[1]

v1 = p2-p1
v2 = p4-p1
n1 = normalize v1
n2 = normalize v2

the_angle = acos (dot N1 N2)



--MODULO

mod 7 3 == 1

or

7/3 = 2*3 + 1

--distance

v1=(a.pos.x - b.pos.x)^2
v2=(a.pos.y - b.pos.y)^2
v3=(a.pos.z - b.pos.z)^2
backward = (v1 + v2 + v3)^0.5

getvert


theobj=$plane01 --You will need to make this plane and convert to editable_mesh!
--getfacearea
meshop.getfacearea theobj 1
--or
polyop.getFaceArea theobj 1
--or
theface =  polyop.getVertsUsingFace theobj 1
thevert1 = (polyop.getVert theobj 1)--.x
thevert2 = (polyop.getVert theobj 2)--.y
thevert3 = (polyop.getVert theobj 3)--.z
thevector1 = thevert2 - thevert1
thevector2 = thevert3 - thevert1
thearea1 = ( length (cross thevector1 thevector2) )/2


--vypocet mista ve ctvercovem poli
--computation place in a square box

fn getTableGridPoint rows columns num =
(
	local c = rows * columns

	local x = (num/columns+1)-1
	local y = if num > columns then (num/columns)+1 else 1
	--local y = num/rows + 1
	--c / (mod a c) as integer
	[x, y]
)

getTableGridPoint 6 5 26

--how to get the address given point (x, y) in a grid sized (w, h)

num = (y * w) + x


mod num w
div num w

x = num mod w<br>
y = num INT_DIV w

http://stackoverflow.com/questions/1384683/how-to-get-address-of-point-x-y-in-a-grid-sized-w-h