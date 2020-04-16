----------------------------------------------------------------------------
--xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx--

                               -- Micra Loader --
							 
--xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx--
--                       Created by MerlinEl 2018                         --
----------------------------------------------------------------------------
Global TypeBox
fn TypeBox msg = (

	local rdia = dotNetObject "MaxCustomControls.RenameInstanceDialog" ""
	rdia.text = msg
	local DialogResult = rdia.Showmodal()
	local OK_CLASS = (dotnetclass "System.Windows.Forms.DialogResult").OK
	if dotnet.compareenums rdia.DialogResult OK_CLASS and rdia.InstanceName.count != 0 then (
		rdia.InstanceName 
	) else undefined
)

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