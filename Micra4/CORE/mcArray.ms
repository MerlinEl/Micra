--------------------------------------------------------------------------------
/* mcArray by Orien 2019 */
--------------------------------------------------------------------------------
/*
*@Used Structures
	Micra
*
*@Used Objects

*
*/
struct MCRA_ARRAY (

	fn getSource = getSourceFileName(), --get path of this script
	fn appendIfUnique inArray newElement = (
		local elementExists = false
		for elem = 1 to inArray.count do
		(
	 		if ((inArray[elem] as string) == (newElement as string)) then
	 		elementExists = true
	 	)
	 	if (not elementExists) then
		append inArray newElement
	),
	fn prepend inArray newElement = (
	
		insertItem newElement inArray 1
		inArray
	), 
	/**
	*@Author	denisT
	*@Usage		find duplicates in an array
	*@Example
		mcArray.findDuplicates #(1,2,3,2,1,4) > #(#{1, 5}, #{2, 4})
		mcArray.findDuplicates #("a","b","c","a","b","d") > #(#{1, 4}, #{2, 5})
	*/
	fn findDuplicates list = (
	
		local vals = #()
		local dups = #()
		for k=1 to list.count do 
		(
			if (i = finditem vals list[k]) != 0 then append dups[i] k else 
			(
				append vals list[k]
				dups[vals.count] = #{k}
			)
		)
		--collect only bitarrays with two or more dups (drop singles which is not realy dups)
		for ba in dups where ba.numberSet > 1 collect ba
	),
	/**
	*@Author > PolyTools3D
	*@Usage > find all words in an array
	*@Example
		mcArray.findWord #("a", "b", "c", "b") "B" > #()
		mcArray.findWord #("a", "b", "c", "b") "B" ignoreCase:true > #(2, 4)
		return an array of indexes where word is found
	*/
	fn findWord arr str ignoreCase:false = (
	
		local regex = dotnetclass "system.text.regularexpressions.regex"
		local pattern = "\b" + str + "\b"
		if ignoreCase do pattern = "(?i)" + pattern
		for j = 1 to arr.count where ((regex.match arr[j] pattern).success) collect j
	),
	/*
	*@Usage > Search for an item in multiarray
	*@Example
	a = #( #(1,2), #("c","d","e"), #(56,47) ) 
	b = findItem2 a "c" 1
	b = findItem2 a 47 2
	*/
	fn findItem2 array2 val ID = (
		local index
		for i=1 to array2.count do
		( 
			if array2[i][ID] == val do index = i
		)
		return index
	),
	fn copyArray arr =(for i in arr collect i),
	fn reverseArray arr = (for i=arr.count to 1 by -1 collect arr[i]),
	fn swapItems arr index_a index_b = (
	
		local item_a = arr[index_a]
		local item_b = arr[index_b]
		arr[index_a] = item_b
		arr[index_b] = item_a
	),
	/**
	*@Usage > Rotate an array cnt times forward or backward
	*@Example
		ar = #(1, 2, 3, 4)
		mcArray.rotateItems ar 1 > #(4, 1, 2, 3)
		mcArray.rotateItems ar 2 > #(3, 4, 1, 2)
		mcArray.rotateItems ar 1 way:#left > #(2, 3, 4, 1)
	*/
	fn rotateItems arr cnt way:#right = (

		for i=1 to cnt do ( --how many times we shift
		
			case way of (
			
				#right:(
					local next = 2
					for j=1 to arr.count-1 do ( --shift each except last
				
						swapItems arr 1 next --swap first with next
						next+=1
					)
				)
				#left:(
					local prev = arr.count - 1
					for j=arr.count to 2 by -1 do ( --shift each except first
				
						swapItems arr arr.count prev --swap last with prev
						prev-=1
					)
				)
			)
		)
	),
	/**
	*@Usage > join two arrays in to new one
	*/
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
	),
	/**
		mcArray.getValueInPath arr "box.top"
	*/
	fn getValueInPath obj key_path = (
	
		local keys = filterString key_path "."
		local out_val = copy obj
		for k in keys do (
		
			if isProperty out_val k do out_val = getProperty out_val k
		)
		out_val
	),
	fn sortByName arr = ( --not used not tested
	
		fn compareNames str1 str2 = stricmp str1.name str2.name
		qSort arr compareNames
	),
	/**
	*@Example
		mcArray.sortByParam arr "top"
	*/
	fn sortByParam arr key = (
	
		fn compareParams obj_a obj_b param:  =  (
		
			local a = getProperty obj_a param
			local b = getProperty obj_b param
			case of (
			
				(a < b) : -1 
				(a > b) : 1
				default: 0
			)
		)
		qSort arr compareParams param:key
	),
	/**
	*@Example
		mcArray.sortByParams arr "box.top"
	*/
	fn sortByParams arr key_path = (
	
		fn compareParams obj_a obj_b params:"" =  (
		
			local a = getValueInPath obj_a params
			local b = getValueInPath obj_b params
			-- format "compare a:% b:% a < b :%\n" a b (a < b)
			case of (
			
				(a < b) : -1 
				(a > b) : 1
				default: 0
			)
		)
		qSort arr compareParams params:key_path
	),
	fn shuffle arr =(
	
		for counter = arr.count to 1 by -1 collect(
		
			local swapIndex = random 1 counter
			swap arr[swapIndex] arr[counter]
		)
	),
	-- compare generic Arrays
	fn isEqualArrays ar1 ar2 = (
		with printAllElements on (ar1 as string == ar2 as string)
	),
	-- compare BitArrays
	fn isEqualBitArrays ba1 ba2 = (
		ba1.numberSet == ba2.numberSet and (ba1 - ba2).isEmpty
	)
	/*<end>*/
)
--create instance
Global mcArray = mcStructMan.instanceStructure MCRA_ARRAY "mcArray"



--sort keys with labels at end (allow mouse hit on other components)
/*format "A > keys:%\n" keys
fn compareLabels str1 str2 =  str1.key == "lbl"
qSort keys compareLabels
format "B > keys:%\n" keys*/