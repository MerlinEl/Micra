--delete duplicate lines

rollout delDoubleLinesDialog " Remove Dupplicate Lines:" width:376 height:112
(
	groupBox grp1 "" pos:[4,4] width:368 height:100
	editText edt_file "" pos:[12,40] width:288 height:24 enabled:false
	label lbl1 "File:" pos:[16,24] width:76 height:12
	button btn_browse "Add..." pos:[304,40] width:60 height:24
	button btn_go "GO" pos:[16,68] width:348 height:28
	fn remove_duplicate_lines_in the_array =
	(
		the_array = #("temp_string")+the_array
		local new_array = for i=2 to the_array.count where the_array[i] != the_array[i-1] collect the_array[i]
		return new_array
	)
	on btn_browse pressed  do
	(
		local file = getOpenFileName caption: " Chose File..." types:"Text files: [*.txt, *.inf, *.ini, *.ms, *.mcr, *.api]"
		if file != undefined do edt_file.text = file
	)
	on btn_go pressed  do
	(
		if doesFileExist edt_file.text do
		(
			local f = openFile edt_file.text
			local lines_array = #()
			while not eof f do -- read until reach end of file
			(
				lines_array += #(readline f) -- read in a line
			)
			flush f
			close f
		)
		
		local new_array = remove_duplicate_lines_in lines_array

		if new_array.count != 0 do
		(
			local f = openFile edt_file.text mode:"w"
			for i in new_array do format "%\n" i to:f
			flush f
			close f
		)
	)
)
createDialog delDoubleLinesDialog style:#(#style_sysmenu, #style_titlebar, #style_toolwindow) 