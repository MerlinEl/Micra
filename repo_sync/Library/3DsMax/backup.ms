fn backupMaxFile =
(
	local file_path = maxFilePath
	local file_name = maxFileName
	
	if file_path == "" do (messageBox "Save you scene first." title:" Backup Failed:" ;return false)
	
	local backup_dir = file_path + "BK\\" --define backup dir
	local file       = file_path+file_name
	
	format "Current file: %\n" file
	
	if not doesFileExist backup_dir do makeDir backup_dir

	local max_files = getFiles (backup_dir+"*.max") --get all max files from BK dir
	local backup_files = for f in max_files where findString f "_[BK]_" != undefined collect f --get only backup files
	
	if backup_files.count == 0 --first backup
	then
	(
		local file_versioned = backup_dir+"_[BK]_0.01_"+file_name
		copyFile file file_versioned
	)
	else
	(
		local last_file    = backup_files[backup_files.count] --get last backup file
		
		format "Last    file: %\n" last_file 
		
		local last_version = (filterString (filenameFromPath last_file) "_")[2] as float --get last file version
		
		format "Last version:%\n" last_version
		
		if classOf last_version != float do return false
		
		local new_version = (last_version + .01) as string
		if new_version.count < (last_version as string).count do new_version += "0" --keep always the same patern 00.00
		local file_versioned = backup_dir+"_[BK]_"+new_version+"_"+file_name
		copyFile file file_versioned
	)

)
backupMaxFile()