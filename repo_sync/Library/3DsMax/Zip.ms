extractDir = "E:\\Merlin\\Micra\\temp\\"
msZip.fileInPackage "E:\Merlin\Micra\temp\Clr.mzp" &extractDir

local extractDir = "", dropFile = ""
msZip.unloadPackage' "E:\Merlin\Micra\temp\PB_Func.mse" &extractDir &dropFile




files_array = getFiles "e:\\Micra3\\+\\work\\Micra III Instalation\*.*"

maz "E:\\Micra3\+\\work\\micra.mzp" files_array

unmaz "foo.mzp" "E:\\Merlin\\Micra\\temp\\"


	fn backupMicra dirA dirB zipName =  --zipFiles "C:\\temp\\ZipTest\\Source\\"  "C:\\temp\\ZipTest\\Target\\"  "test"
	(
		--error check
		if not doesFileExist dirA or not doesFileExist dirB do return false
		--locals
		local f
		local t = filterString localtime " :"
		local date_and_time = if t.count == 4 then t[1]+"_"+t[2]+"."+t[3]+"h" else ""
		--collecting files with full path. If all == true collecting also all files from subdir
		local files = getFiles (dirA + "*")   -- micra root files
		files += getFiles (dirA+"App\\"+"*")--applications files
		files += getFiles (dirA+"Help\\"+"*")--help files 
		files += getFiles (dirA+"Img\\"+"*")--image files 
		files += getFiles (dirA+"User\\"+"*")--user files 
		print files
		
		if files.count == 0 do return false
		
		-- generate a zip.tmp file with the list of files to be archived
		local file_list_tmp = dirB + "~zip.tmp"
		if doesFileExist file_list_tmp do deleteFile file_list_tmp -- delete old tmp file if exist
		try (f = createFile file_list_tmp) catch (print "File: " + file_list_tmp + "cannot be created"; return false)
		for i in files do format "%\n" i to:f
		flush f
		close f
		
		-- archive the files into the zip
		local curDir = sysInfo.currentDir -- store current system dir
		local zipUtil = getDir #maxRoot + "maxzip.exe"
		local zipFile = dirB+zipName+"_"+date_and_time+".zip"
		local cmd = "" as stringStream
		format "\"%\" % @%" zipUtil zipFile file_list_tmp to:cmd
		sysInfo.currentDir = dirA -- set system folder (zip tree begins here)
		print cmd
		format "status:%\n " (dosCommand cmd)
		sysInfo.currentDir = curDir -- restore old system dir
		
		-- delete the temp file list
		deleteFile file_list_tmp
	)
	
	
	--7 Zip
				--Collect all Micra components in to Zip file (except User\\ +\\ and _Backup\\)
			if doesFileExist temp_file do deleteFile temp_file
			if doesFileExist dest_file do deleteFile dest_file
			
			--zip files in temp dir
			dosCommand (z7 +" a -tzip "+ temp_file + mcPath()+"*.* "+ mcPath()+"Img "+ mcPath()+"Help "+ mcPath()+"App " )
			
			--move zip file in to server and delete temp
			copyFile temp_file dest_file
			if doesFileExist temp_file do deleteFile temp_file