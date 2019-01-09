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
	/*
	@Example
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
	),
	fn sortByName arr = ( --not used not tested
	
		fn compareNames str1 str2 = stricmp str1.name str2.name
		qSort arr compareNames
	)
)
--create instance
Global mcArray = Micra.instanceStructure MCRA_ARRAY "mcArray"



--sort keys with labels at end (allow mouse hit on other components)
/*format "A > keys:%\n" keys
fn compareLabels str1 str2 =  str1.key == "lbl"
qSort keys compareLabels
format "B > keys:%\n" keys*/