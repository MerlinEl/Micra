--This Can Be Executed From Notepad++ Externaly
(
	fn saveAsCopy file overwrite:off = if doesFileExist file do
	(
		local sioFile = dotnetclass "System.IO.File"
		local filedir = getFilenamePath file
		local filename = getFilenameFile file
		local ext = getFilenameType file
		local newfile = pathconfig.appendpath filedir (filename+"_copy"+ext)
		if not overwrite and doesFileExist newfile then 
		(
			messageBox "Copy of this file already exist!" title:"Warning" beep:off
		)
		else (sioFile.copy file newfile overwrite ; ok)
	)
	local sceneName = maxFilePath + (getFilenameFile maxFileName) 
	--if sceneName != "" do saveAsCopy (sceneName + "_backup")
	--useNewFile --> false == the saved file is not set as the current scene file and the file is not put in the Most Recently Used list. 
	--This lets you save a backup file of the scene to a different name without the name becoming the current one or appearing on the list of recent files.”
	if maxFilePath != "" do savemaxFile (sceneName + "_backup.max") useNewFile:false quiet:true
)