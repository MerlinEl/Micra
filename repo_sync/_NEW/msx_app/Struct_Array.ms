Struct MY_ARRAY_STRUCTURE (	

	fn reverseArray arr = (for i=arr.count to 1 by -1 collect arr[i]),
	fn mergeClone arr1 arr2 = (
		
		local new_arr = #()
		join new_arr arr1
		join new_arr arr2
		return new_arr
	),
	fn removeItem arr index = (
		
		if classOf arr != Array or index > arr.count do return false
		--format "remove index:% from array:%\n" index arr
		deleteItem arr index
		--format "rest of arr:%\n" arr
		true
	)
)
Global myArray = MY_ARRAY_STRUCTURE()