MacroScript SweepProfile category:"Track" tooltip:"Sweep Profile" icon:#("TrackScripts",10) buttontext:"Sweep" (
	on execute do (
		fileIn "TrackScripts/SweepProfile.mse"
	)
)--www
(
	fileIn (getDir #userMacros + "/Track-SweepProfile.mcr")
	local rootPath = getFilenamePath (getsourceFileName()) + "\\"
	fileIn (rootPath + "/SweepInstall.mse")
	colorman.reinitIcons()
	messagebox "         Completed!\nSee script in Track category\n\n  Alexander Kramer\nwww.3d-kstudio.com"
	-- actionMan.executeAction 0 "59226"  -- Customize User Interface: Customize User Interface
)