showSource
--dot 
fn dotProduct v1 v2 = ( v1.x*v2.x+v1.y*v2.y+v1.z*v2.z )
--degToRad
fn deg2Rad deg = ( deg*(pi/180.0) )


-----------------------------------------------------------
max time ? -- shows all the time-related commands
max sel ? -- shows all the commands with ‘sel’ in them as a substring
max ? -- shows all the commands (there are a lot)
-----------------------------------------------------------
as string   | "#("Box02", "Sphere02")"
as array    |  #("Box02", "Sphere02")
as bitarray |  #{"Box02", "Sphere02"}
as float    |  "2334.45" > 2334.45
as name     |  "name_x"  > #name_x
-----------------------------------------------------------
for r=0 to h-1 do -- for each row in the bitmap
-----------------------------------------------------------
my_array= #{} --define an empty bitarray
-----------------------------------------------------------
my_array= #{1,2,3,4} --define an bitarray with some bits set
-----------------------------------------------------------
--create aflag array
my_array= #{} --define an empty bitarray
b = bit.Set 0 1 true --set the first bit to true 
--now call the function and supply the empty array as
--In parameter by reference and the flag bit to filter out
$.getVerticesByFlag &my_array b 
--Now look at the content of the bitarray -
--it will contain the vertices that have their first flag bit set
--(bit 1 stands for selected, so it will contain the vertex selection)
print my_array
----------------------------------------------------------- 
for i in 1 to 10 do ( /* messageBox "in loop"; */ frabulate i )
----------------------------------------------------------- 
case of
(
	(a > b): print "a is big"
	(b < c): print "b is little"
	--default: reference $foo
)
-----------------------------------------------------------
new_obj = case copy_type.state of
(
	2: copy $foo
	3: instance $foo
	default: reference $foo
)
-----------------------------------------------------------
function sign val:0 =   --call <sign val:-5>
(
	if val == 0
	then messagebox ("Equal to 0")
	else if val > 0
	then messagebox ("Greater than 0")
	else messagebox ("Less than 0")
)
----------------------------------------------------------- 
/* Function for displaying message */
fn mBox y n =
	( 	
	if y == 1 then messagebox "A"
	if y == 2 then messagebox "B"

--
	if n == 1 then messagebox "C"
	if n == 2 then messagebox "D"

	)
/* Call: mBox <num> y or n <num>| example: mBox 10 y  or mBox n 10 */
----------------------------------------------------------- 
/* Function for Displaying Messages */
fn mBox x = 
	( 	
	if x == 1 then messagebox "A"
	if x == 2 then messagebox "B"
	if x == 3 then messagebox "C"
	if x == 4 then messagebox "D"
	)
/* Call: mBox <num> | example: mBox 1 */
----------------------------------------------------------- 
/* Function for Displaying Messages */
fn mBox title = 
	(
		case title of
		(
			1: messagebox "A"
			2: messagebox "B"
			3: messagebox "C"
			4: messagebox "D"
		)
	)
/* Call: mBox <num> | example: mBox 1 */
-----------------------------------------------------------
gvn = get_viewport_name as string --convert viewport name to string
gvn = substring gvn 6 (gvn.count-5) --cut the string
----------------------------------------------------------- 
a=1 ; b=2
a+b
--Result:
3
-----------------------------------------------------------
a="Ahoj " ; b="Rene"
a+b
--Result:
"Ahoj Rene" 
-----------------------------------------------------------
--Script:
Struct person (name, height, age, sex) --define struct
Bill = person name:"Bill" height:72 age:34 sex:#male --create user 1
Joe = person name:"Joseph" sex:#male --create user 1
--1 Call: 
person Bill
--1 Result:
person name:"Bill" height:72 age:34 sex:#male height:undefined age:undefined sex:undefined
--2 Call:
bill.age
--2 Result
34
-----------------------------------------------------------
--Example: 

--given the following struct definition,
struct foo (name, age, height, hair="brown")

--you can create instances, in several ways:
f1 = foo "bill" 23 72 -- fills in name, age, height in order
f2 = foo age:45 name:"sam" -- random named initializers
f3 = foo "mary" hair:"red" -- first name, then keywords
-----------------------------------------------------------
a="1" -- create a string value, put reference in a
b= $objects.count as string -- put string’s reference in b
format "#(%..%\n)" a b -- and print their values
--Result:
#(1..12)
-----------------------------------------------------------
a=1 -- create a value, put reference in a
b=$objects.count -- create a value, put reference in a
ListObj.LBox.selection = #{a..b} --use result for selection
-----------------------------------------------------------
/* Function for displaying objects count as array */
fn oCountAr c=
	(
	a=1
	b=$objects.count
	c=#{a..b}
	)
/*Call: oCountAr c | Result: #{1..15} */
----------------------------------------------------------------------------
/* Function for displaying Number of selected objects */
--fn SoCount = (if ($ != undefined) then (x = $selection.count))
/* Call: oCount() */
----------------------------------------------------------------------------
/* Function for displaying Name of selected objects */
--fn SoName = (if ($ != undefined) then (x = for i in selection collect i.name))
/* Call: SoName() */
----------------------------------------------------------------------------
/* Function for displaying Numbers of all objects as array */
--fn oNum = (for i in 1 to $objects.count collect i)
/* Call: oNum() */
----------------------------------------------------------------------------
fn UpperCase =
	(
	local upper, lower -- declare variables as local
	upper="ABCDEFGHIJKLMNOPQRSTUVWXYZ" -- set variables to literals
	lower="abcdefghijklmnopqrstuvwxyz"
	for i in $Objects do -- for all objects in scene
		(
		if findString upper i.name[1] != undefined do -- if first char in name is not a number
			if (i.name[1] == upper[findString upper i.name[1]]) != true do -- if first char in name is not upper
				i.name = replace i.name 1 1 upper[findString lower i.name[1]] -- change first char in name to upper
		)
	)
	
fn recursiveTest type =
(
	case type of
	(
	#a: count = 10
	#b: len = 20
	#c: wid = (recursiveTest #a + recursiveTest #b)
	)
)

fn mcGetObjTransform type = 
(
	case type of
	(
	Px:($.pos.x)
	Py:($.pos.y)
	Pz:($.pos.z)

	Rx:($.rotation.x_rotation)
	Ry:($.rotation.y_rotation)
	Rz:($.rotation.z_rotation)

	Sx:($.scale.x*100)
	Sy:($.scale.y*100)
	Sz:($.scale.z*100)
	)
)
