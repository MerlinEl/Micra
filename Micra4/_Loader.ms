----------------------------------------------------------------------------
--xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx--

                               -- Micra Loader --
							 
--xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx--
--                       Created by MerlinEl 2018                         --
----------------------------------------------------------------------------
Global Micra
(
	--> Get Micra_Main File In Current Directory
	local micra_file = ( getFilenamePath (getSourceFileName()) )+ "Micra_Main.ms"
	--> Load Main Structure
	if doesFileExist micra_file then ( 
		
		fileIn micra_file 
		if Micra != undefined do Micra.initialize()
		
	) else (
	
		messageBox "Micra Not Found." title:"Warning:"
	)
)