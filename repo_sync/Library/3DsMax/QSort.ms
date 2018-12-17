--Value Comparator

vals = for i=1 to 10 collect random 1 50
fn valueArrayComparator a b = 
(
	if a > b then 1
	else if a < b then -1
	else 0
)
qsort vals valueArrayComparator
vals

--Text Comparator

abc= #("a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z")
gen = for i=1 to 15 collect (abc[random 1 abc.count] + abc[random 1 abc.count] + abc[random 1 abc.count] + abc[random 1 abc.count]) --generate words
texts = deepCopy gen

--(A) only for first letter
fn textArrayComparator a b = 
(
	if a[1] > b[1] then 1
	else if a[1] < b[1] then -1
	else 0
)

--(B) for all letters
fn textArrayComparator a b = 
(
	local lvl = for i=1 to a.count do if a[i] != b[i] do exit with i  --search lethers one by one and exit if is different or "B" is undefined
	if classOf lvl != integer do return 0 -- if both is same (they not moving anywhere)
	if b[lvl] == undefined do return 1 --( "A" is moving forward )
	
	if a[lvl] > b[lvl] then 1
	else if a[lvl] < b[lvl] do -1
)

qsort texts textArrayComparator
texts




--#((Vert_Data num:1 vect:[58.69,0]), (Vert_Data num:2 vect:[58.69,0]), (Vert_Data num:3 vect:[58.69,0]), (Vert_Data num:4 vect:[58.69,0]))

struct Vert_Data (num, vect)
rand= #(8,4,6,2)
vd = for i =1 to 4 collect Vert_Data rand[i] [58.69,0]

for p in vd do print p

print "next"
fn compareFN v1 v2 =
(
	local d = v1.num - v2.num
	case of
	(
		(d < 0.): -1
		(d > 0.):  1
		default:   0
	)
)

qsort vd compareFN 

for p in vd do print p

----------------------------
-----------------------------

 fn compByHeight n1 n2 reverse:off = 
 (
 	   a = if n1.pos.z < n2.pos.z then -1 else  if n1.pos.z > n2.pos.z then 1 else 0
 	   if reverse then -a else a
 )
 qsort nodelist compByHeight reverse:on

------------------------------

multi_array = #
(
	#($Box03, (ray [17.95,-44.5864,6.1285] [0,1,0]), 264.279), 
	#($Box05, (ray [16.1156,-57.1404,4.30729] [-0.566788,0.823864,0]), 277.096), 
	#($Teapot01, (ray [15.5211,-61.2089,3.71707] [0.302224,0.314786,-0.899761]), 281.25), 
	#($Box10, (ray [20.3307,-28.2941,8.49203] [0,0.917437,0.39788]), 247.645)
)
fn sortByHitDistance n1 n2 = if n1[3] < n2[3] then -1 else if n1[3] > n2[3] then 1 else 0 
qsort multi_array sortByHitDistance


--------------------------------

multi_array = #
(
	#($Box01, (ray [17.95,-44.5864,6.1285] [0,1,0]), 264.279), 
	#($Box03, (ray [16.1156,-57.1404,4.30729] [-0.566788,0.823864,0]), 277.096), 
	#($Teapot01, (ray [15.5211,-61.2089,3.71707] [0.302224,0.314786,-0.899761]), 281.25), 
	#($Box04, (ray [20.3307,-28.2941,8.49203] [0,0.917437,0.39788]), 247.645)
)
fn sortByHitDistance n1 n2 lvl:1 = (if n1[ lvl ] < n2[ lvl ] then -1 else if n1[ lvl ] > n2[ lvl ] then 1 else 0)
qsort multi_array sortByHitDistance lvl:3
multi_array

---------------------------------

fn lowercase instring =
(
	upper="ABCDEFGHIJKLMNOPQRSTUVWXYZ"
	lower="abcdefghijklmnopqrstuvwxyz" 
	outstring=copy instring 
	for i = 1 to outstring.count do 
		(
		j=findString upper outstring[i]
		if (j != undefined) do outstring[i]=lower[j]
		)
	outstring
)
fn name_compare_case_insensitive s1 s2 = 
(
	if (lowercase s1.name) < (lowercase s2.name) then return -1
	else if (lowercase s1.name) > (lowercase s2.name) then return 1
	else return 0
)
fn get_scene_materials = 
(
	local a = #()
	for i in $* do
		(
		if i.material != undefined then
			(
			if (finditem a i.material) == 0 then append a i.material
			)
		)
	qsort a name_compare_case_insensitive
	return a
)