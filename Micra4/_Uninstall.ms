
--if Micra is running, unload first
if Micra.RootDir != undefined do (
	
	local unloader_file = Micra.RootDir+"_Unloader.ms"
	if doesFileExist unloader_file do fileIn unloader_file
)

--Remove autorun file
(
	local autorun_file = GetDir #userStartupScripts + "\\Micra_Autorun.ms"
	if doesFileExist autorun_file do deleteFile autorun_file
	
	--deleteFile (Micra.RootDir+"Micra_Macro.mcr") Macro
	--delIniSetting Micra.MaxUserSettings "Directories" "Micra Plugins" PluginsDir
)

MessageBox "Micra uninstal is finished. Stay cool :-)" title:"...:*Micra*:..."