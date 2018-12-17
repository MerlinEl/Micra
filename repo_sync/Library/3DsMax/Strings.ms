--rename sel
for i in sel do (
	
	n = i.name
	na = substring n 1 (n.count-5)
	i.name = na
	
)

fn stringToInteger str=(for i=1 to str.count collect bit.charAsInt str[i])
fn integerToString int_array =(str="";for n in int_array do str+= bit.intAsChar n; str)

stringToInteger "mt_parent_005"
integerToString #(109, 116, 95, 112, 97, 114, 101, 110, 116, 95, 48, 48, 53)


toLower "AFDGDFghfgGFGFH"
toUpper "AFDGDFghfgGFGFH"

"string" == "\"string\""

<Point2> GetTextExtent<string>

How do I remove duplicate arrays from an array?
MAXScript Frequently Asked Questions 

A user asked:
I've been trying to figure out how to do this for a while now, but I just can't get it. Here's the situation, let's say I have an array of arrays like this:

#(#(1, 5), #(6, 10), #(6, 10), #(14, 18), #(14, 18))

How can I search for, and get rid of, the duplicates, which in this case would be 2 & 3, and 4 & 5.

If I use findItem, it just returns the first instance and doesn't continue searching. I've also tried comparing the first and second numbers using nested 'for' loops, but I can't seem to set it up so that it works like I want. Mainly, there seem to be problems when deleting items from an array while it's going through a loop.

Answer:
Here is a long version with some debug prints so you can see what is happening.

The key is to always count BACKWARDS when deleting elements from an array you are looping through! Otherwise, the loop will get confused as deleting elements renumbers the array items.

 

Long Version:

(

theArray = #(#(1, 5), #(6, 10), #(6, 10), #(14, 18), #(14, 18))

print "Before:"

print theArray

fn compareSubArrays first second =

(

result = true

if first.count != second.count then 

result = false

else 

for i = 1 to first.count do 

if first[i] != second[i] do result = false

result 

)

 

for i = 1 to theArray.count do

(

for j = theArray.count to i+1 by -1 do

(

format "Comparing %:% to %:% \n" i theArray[i] j theArray[j]

test = (compareSubArrays theArray[i] theArray[j])

print test

if test do 

(

deleteItem theArray j

format "Deleting %\n" j

) 

) 

) 

print "After:"

print theArray 

)

 

Result:

"Before:"

#(1, 5)

#(6, 10)

#(6, 10)

#(14, 18)

#(14, 18)

Comparing 1:#(1, 5) to 5:#(14, 18) 

false

Comparing 1:#(1, 5) to 4:#(14, 18) 

false

Comparing 1:#(1, 5) to 3:#(6, 10) 

false

Comparing 1:#(1, 5) to 2:#(6, 10) 

false

Comparing 2:#(6, 10) to 5:#(14, 18) 

false

Comparing 2:#(6, 10) to 4:#(14, 18) 

false

Comparing 2:#(6, 10) to 3:#(6, 10) 

true

Deleting 3

Comparing 3:#(14, 18) to 4:#(14, 18) 

true

Deleting 4

"After:"

#(1, 5)

#(6, 10)

#(14, 18)

OK

OK

 

Compact Version with Comments:

(

theArray = #(#(1, 5), #(6, 10), #(6, 10), #(14, 18), #(14, 18))

 

--Function to compare the content of two arrays

fn compareSubArrays first second =

(

result = true --init. return value to true

if first.count != second.count then --if the count of the two subarrays is different,

result = false --return false

else --otherwise

for i = 1 to first.count do --go through all elements in the arrays

if first[i] != second[i] do result = false --and see if two elements are different

result --return the result - true if identical, false if not

)

 

for i = 1 to theArray.count do --go through all elements of the main array

for j = theArray.count to i+1 by -1 do --go backwards from the last to the current+1

if compareSubArrays theArray[i] theArray[j] do 

deleteItem theArray j --if identical, delete the one with the higher index

format "%\n" theArray --print the result to the Listener

)
Result:
#(#(1, 5), #(6, 10), #(14, 18))


if (findString curTime "/") != undefined then (local tSymbol = "/") else (local tSymbol = ".")



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


fn reverse_string s =
	(
	new_string = ""
	if s.count != 0 then
		(
		for i = s.count to 1 by -1 do
			(
			new_string += s[i]
			)
		)
	return new_string
	)