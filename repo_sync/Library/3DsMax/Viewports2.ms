fn mcSetScreenScaleFactor SF =
(
	local curSF = getScreenScaleFactor [0,0,0]
	if curSF == SF do return false
	if curSF < SF
	then 
	(	
		print "zoom in" 
	
	)
	else 
	(	
		print "zoom out"
	)
)


/*
sf = getscreenScaleFactor [0,0,0]
mcSetScreenScaleFactor sf


viewport.ZoomToBounds false [20,20,20] [80,80,80]

tm = viewport.getTM()
viewport.setTM tm
*/

viewport.DispBkgImage = (not viewport.DispBkgImage)
completeredraw()
viewport.ResetAllViews()
backgroundImageFileName
InvalidateAllBackgrounds()