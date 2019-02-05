--read write inidata test
clearListener()

--Read string data as [object]
fn readDataFromFile fpath =  (
	
	if  not doesFileExist fpath do return false
	local fstream = openFile fpath
	local str_lines = #()
	while (not eof fstream) do (
		
		local sline = readline fstream --btn_G20 = action:Fuse_Verts_In_Line icon:157
		local arr = filterString sline "=" --split button id: btn_G20
		if arr.count == 2 do str_lines += #(arr[2]) --get data only:  action:Fuse_Verts_In_Line icon:157
	)
	close fstream
	for str in str_lines do (
		
		--format "str:%\n" str
		local obj = mcString.toObject str 
		--obj.toString()
		obj.print()
	)
)   


fn convertIniToXml ini_file = (
	local br = "----------------------------------------------------------------"
		local keys  = getIniSetting ini_file "Buttons" 
		if keys.count == 0 do (
			
			delINISetting ini_file "Icons"
			return OK
		)
		format "%\n[ % ]\n%\n" br ini_file br
		--replace key single value with object data
		for i=1 to keys.count do (
		
			local btn_id  = keys[i]
			local action = getINISetting ini_file "Buttons"  btn_id
			local icon_index = getINISetting ini_file "Icons"  btn_id
			local data  = mcObject()
			data.add "action" action
			data.add "icon" icon_index
			print (data.toString())
			--write ini data as object
			 setINISetting ini_file "Buttons"  btn_id (data.toString())
		)
		delINISetting ini_file "Icons"
)

/*
readDataFromFile (Micra.UserDir + "Profile_01.ini")
*/