fn resourceLoadTest = (
	local outstr = ""
	local new_script = newScript()
	try (
		local max_user_dir = getDir #maxData
		outstr += max_user_dir + " exists:" +(doesFileExist max_user_dir as string) + "\n"
		
		local max_root_dir = getDir #maxRoot
		outstr += max_root_dir + " exists:" +(doesFileExist max_root_dir as string) + "\n"
		
		local max_cfg = max_root_dir + "3dsmax.exe.config"
		outstr += max_cfg + " exists:" +(doesFileExist max_cfg as string) + "\n"
		
		local temp_cfg = max_user_dir+"3dsmax.exe.config"
		outstr += temp_cfg + " exists:" +(doesFileExist temp_cfg as string) + "\n"
		
		local result = copyFile max_cfg temp_cfg
		outstr += "temp copy cfg:" +(result as string) + "\n"
		
		local fstream = openFile temp_cfg mode:"r+"
		while (not eof fstream) do (
			
			local sline = readline fstream
			if findString sline "loadFromRemoteSources"  != undefined do (
				
				outstr += sline
				format "%\n" outstr to:new_script 
				exit
			)
		)
		close fstream
		delete temp_cfg
	) catch (
		
		format "%\n" outstr to:new_script 
	)
)
resourceLoadTest()

/*
max_ini = max_user_dir + "3dsmax.ini"
getFileSize max_cfg
getFileAttribute max_cfg #readOnly
setFileAttribute max_cfg #readOnly false
getFileModDate max_cfg
getFileSecurityInfo max_cfg #read 
getFileSecurityInfo max_cfg #write 
isDirectoryWriteable max_root_dir
*/