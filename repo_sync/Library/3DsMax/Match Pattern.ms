
s="text1"
matchPattern s pattern:"text?"-- returns true
matchPattern s pattern:"T*"-- returns true
matchPattern s pattern:"T*"ignoreCase:false-- returns false
matchPattern s pattern:"s*"-- returns false
matchPattern s pattern:"text2*"-- returns false






fn lowerCase text =
  	(
  		local upper="ABCDEFGHIJKLMNOPQRSTUVWXYZ"
  		local lower="abcdefghijklmnopqrstuvwxyz"
  		new_text = ""
  		for i = 1 to text.count do
  		(
  			local column = findString upper text[i] 
  			if column == undefined
  			then new_text += text[i]
  			else new_text += lower[column]
  		)
  		new_text
  	)

 	fn compareTexts textArray text ignoreCase:false =
  	(
  		for i = 1 to textArray.count do
  		(
  			if  textArray[i].count < text.count do return 0
  			local text_part = subString textArray[i] 1 text.count
  			if ignoreCase do
  			(
  				text_part = lowerCase text_part
  				text	  = lowerCase text 
  			)
  			--format "text_part:%\ttext:%\n"  text_part text 
  			if text_part == text do return i
  		)
  		return 0
  	)

--or

	fn searchInListbox txt = --made by Akram
  	(
		items = #("abc","cba","acb","bac")
		tempAry = #()
		pat = txt + "*"
		for i in items do
		(
			if matchPattern i pattern:pat do
			(
				append tempAry i
			)
		)
		
		tempAry
  	)