-- replace part of a string with another string
fn fnReplaceString argString search replace = (
	local varFind
	local varNewString
	
	-- find string
	varFind = findstring argString search
	while varFind != undefined do (
	
		-- replace string
		varNewString = ""
		if varFind > 1 then varNewString += substring argString 1 (varFind - 1)
		varNewString += replace
		varNewString += substring argString (varFind + search.count) argString.count
		argString = varNewString
		varFind = findstring argString search
	)
	
	argString
)

-- correct subobject name
fn fnCorrectString argString =  (
	local varLower = "abcdefghijklmnopqrstuvwxyz"
	local varUpper = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
	local varFind
	local varChar
	local i
	
	-- replace underscore with space
	argString = fnReplaceString argString "_" " "
	
	-- make first letter uppercase
	varFind = findstring varLower (substring argString 1 1)
	if varFind != undefined then (
		argString = (substring varUpper varFind 1) + (substring argString 2 argString.count)
	)
	
	-- replace each character after a space with an uppercase character
	for i = 1 to argString.count do (
		if (substring argString i 1 == " ") then (
			varFind = findstring varLower (substring argString (i + 1) 1)
			if varFind != undefined then (
				varChar = substring varUpper varFind 1
				argString = (substring argString 1 i) + varChar + (substring argString (i + 2) argString.count)
			)
		)
	)
	
	argString
)

