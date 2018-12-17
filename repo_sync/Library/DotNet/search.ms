

fn findItemByName items str ignoreCase:true =  --dotnet
(
	local tempAry = #()
	local pat = str + "*"
	for i in items do if matchPattern i.text pattern:pat do append tempAry i --made by Akram
	tempAry
)