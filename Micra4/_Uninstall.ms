
--if Micra is running, unload first
if mcPath != undefined do (
	
	local unloader_file = mcPath()+"_Unloader.ms"
	if doesFileExist unloader_file do fileIn unloader_file
)

--Remove autorun file
(
	local autorun_file = GetDir #userStartupScripts + "\\Micra_Autorun.ms"
	if doesFileExist autorun_file do deleteFile autorun_file
)

MessageBox "Micra uninstal is finished. Stay cool :-)" title:"...:*Micra*:..."