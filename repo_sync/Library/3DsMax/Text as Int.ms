		fn textBox2 =
		(
			rollout mcTextBoxDialog " Command Box v0.1" width:444 height:40
			(
				edittext edtBox "New Name:" pos:[12,12] width:312 height:18 bold:true
			 	button btnAcpt "Accept" pos:[332,12] width:48 height:16
			 	button btnCncl "Cancel" pos:[384,12] width:48 height:16
			 	groupBox grpTx "" pos:[4,0] width:436 height:36
				fn filterText text =
				(
					local enterFound = false
					local last_leter = text[text.count] -- get last letter
					--The name cannot contain any of the following characters
					local bad_char = case bit.charAsInt last_leter of
					(
						10: (enterFound = true)--enter
						92: (true) --\
						47: (true) --/
						42: (true) --*
						58: (true) --:
						63: (true) --?
						34: (true) --"
						60: (true) --<
						62: (true) -->
						124:(true) --|
						--32: (true) --:space
						--61: (true) --=
						--33: (true) --!
					)
					format "letter:%\tchar:%\tbad_char:%\n" last_leter (bit.charAsInt last_leter) bad_char
					if bad_char != undefined do -- if bad character found?
					(
						text = substring text 1 (text.count - 1)-- removes last letter from text
					)
					return #(text, enterFound)
				)
				on mcTextBoxDialog open do (setFocus edtBox)
				on btnAcpt pressed      do (if edtBox.text != "" do DestroyDialog mcTextBoxDialog)
				on btnCncl pressed      do (edtBox.text = ""; DestroyDialog mcTextBoxDialog)
				on edtBox changed text do
				(
					-- detect if enter pressed
					local filter_data = filterText text
					if filter_data[2] == true 
					then 
					(
						edtBox.text = filter_data[1]
						btnAcpt.pressed()
					)
					else edtBox.text = filter_data[1]
				)
			)
			CreateDialog mcTextBoxDialog pos:[444,40] style:#(#style_border) modal:true --escapeEnable:true
			return mcTextBoxDialog.edtBox.text
		)
		textBox2()