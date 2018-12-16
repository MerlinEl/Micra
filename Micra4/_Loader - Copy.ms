--------------
--------------
--	        --
--	Loader  --
--	        --
--------------
--------------

Global Micra
(
	--> Get Micra File
	local micra_file = ( getFilenamePath (getSourceFileName()) )+ "Micra_Main.ms"
	if not doesFileExist micra_file do (
		
		messageBox "Micra Not Found." title:"Warning:"
		return false
		
	--> Load Main Structure 	
	) else (
	
		fileIn micra_file 
	)
)