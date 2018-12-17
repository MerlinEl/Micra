findItemString arr str  ignoreCase:true =
(
	if  ignoreCase then 
	(
		local lower_arr = for i in arr collect toLower i
		local lower_str = toLower str
		return ( findItem lower_arr lower_str != 0 )
	)
	else return ( findItem arr str != 0 )
)


old_sel = deepCopy sel

--COPY ARRAY!!!
a = #(1,2,30)
b = #()
join b a
deleteitem a 2

--------ARRAY--------------
<bitArray> as array
<integer array> as bitArray
---------------------------



--Example:
a=#{1..5,10}
b=a as array
--Output:
#{1..5, 10}
#(1, 2, 3, 4, 5, 10)
---------------------------
--Example:
a=#{1..5,10}
c=b as bitarray
--Output:
#{1..5, 10}
#{1..5, 10}

if x[1] > x[2] then x = deleteItem x 2 else x = deleteItem x 1



#{4,23,9,2,56}*#{56,23,8,2,48} --intersection
#{4,23,9,2,16,56}-#{56,23,8,2,48} --difference
#{4,23,9,2,16,56}+#{56,23,8,2,48} --union
-#{56,23,8,2,48} --inverse


(
local x=#("25", "2", "712", "258", "21", "585", "145", "1", "11", "58", "85", "6")
while x.count > 1 do
	(
	local y = if (x[1] as float) > (x[2] as float) then x = deleteItem x 2 else x = deleteItem x 1
	)
local x=#("25", "2", "712", "258", "21", "585", "145", "1", "11", "58", "85", "6")
findItem x y[1]
)

fn sort_asc a = 
	(
	sort a
	)
	
fn sort_dec a =
	(
	the_new_array = #()
	sort a
	for w = 1 to a.count do
		(
		append the_new_array a[a.count]
		deleteitem a a.count
		)
	the_new_array
	)
	
	
fn mcDeleteItem arObj num =
(
	local count = 0
	local arr
	case (classOf arObj) of
	(
		BitArray: 
		(
			if arObj.numberset < num do  return (print "Runtime error: array index out of bounds." ; #{})
			arr = #{}
			for i in arObj where (count += 1) != num do arr += #{i}
		)
		Array: 
		(
			if arObj.count < num do  return (print "Runtime error: array index out of bounds." ; #())
			arr = #()
			for i in arObj where (count += 1) != num do arr += #(i)
		)
	)
	return arr
)