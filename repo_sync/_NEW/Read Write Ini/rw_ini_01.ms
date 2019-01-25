--read write inidata test
clearListener()


--Write data as [string] "action:Move_To_X icon:28"
fn writeDataToFile fname = (
	local baction  = (getIniSetting Micra.TempProfileIni "Buttons" )
	local ss = stringstream ""
	format "\n" to:ss
	for i=1 to baction.count do (
		
		local btn_id  = baction[i]
		local action = getINISetting Micra.TempProfileIni "Buttons"  btn_id
		local icon = getINISetting Micra.TempProfileIni "Icons"  btn_id
		format "% = action:% icon:%\n"  btn_id	action icon to:ss
	)
	print ss
	close ss
	flush ss
	local user_dir = Micra.RootDir + "User\\"
	local fpath = user_dir + fname
	if  doesFileExist fpath do deleteFile fpath
	local fstream = createFile fpath
	format "%" (ss as string) to:fstream
	close fstream
	close ss
)

--Read string data as [object]
fn readDataFromFile fname =  (
	
	local user_dir = Micra.RootDir + "User\\"
	local fpath = user_dir + fname
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

--Replace Buttons single value with object string
--Remove Icons header
--change read data from ini in dotnet dialog creator
--"Profile_1.ini", "Profile_2.ini", "Profile_3.ini", "Profile_4.ini", "Profile_5.ini", "Profile_6.ini", "Profile_7.ini", "Profile_8.ini"
fn fixProfilesINI = (
	local br = "----------------------------------------------------------------"
	for i = 1 to 8 do (
		
		local profile_name = "Profile_"+i as string+".ini"
		local ini_file =  micra.UserDir + profile_name
		local keys  = getIniSetting ini_file "Buttons" 
		if keys.count == 0 do (
			
			--delINISetting ini_file "Icons"
			continue
		)
		format "%\n[ % ]\n%\n" br profile_name br
		--replace key single value with object data
		local ss = stringstream ""
		for i=1 to keys.count do (
		
			local btn_id  = keys[i]
			local action = getINISetting ini_file "Buttons"  btn_id
			local icon_index = getINISetting ini_file "Icons"  btn_id
			format "% = action:% icon:%\n"  btn_id	action icon_index to:ss
			format "% = action:% icon:%\n"  btn_id	action icon_index
			
		)
		---if ss.count if ss not empty write buttons
		--delete header [Icons]
		close ss
	)
)

/*
fixProfilesINI()
writeDataToFile "Profile_09.ini"
readDataFromFile"Profile_09.ini"

xmlfile = "c:/temp/abc.xml" 
doc = XmlDocument() 
doc.LoadXml xmlfile 
-- fail, doc is now undefined


*/