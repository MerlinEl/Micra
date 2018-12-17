fn checkForDipplicateNames =
(
	local all_names = for i in objects collect i.name
	local dupplicates = #()
	while all_names.count != 0 do
	(
		local n = all_names[1]
		deleteItem all_names 1 
		if findItem all_names n != 0 do dupplicates += #(n)
	)
	format "dupplicates found:%\n" dupplicates.count
	print dupplicates
)
checkForDipplicateNames()




fn findItemByName items str ignoreCase:true =  --dotnet
(
	local tempAry = #()
	local pat = str + "*"
	for i in items do if matchPattern i.text pattern:pat do append tempAry i --made by Akram
	tempAry
)



		fn findItemCaseNotSensisive words word = 
		(	
			for w in words where (matchPattern w pattern:word) do return true
			return false
		)