in mcPath != undefined and doesFileExist (mcPath()) do (

	fileIn (mcPath()+"_Unloader.ms") 
	local sFile = (GetDir #userStartupScripts + "\\Micra_Autorun.ms")
	if doesFileExist sFile do deleteFile sFile
)