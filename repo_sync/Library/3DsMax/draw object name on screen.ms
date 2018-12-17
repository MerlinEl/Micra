	fn drawMarkers2 =
	(
		gw.setTransform(Matrix3 1) 
		if selection.count != 0 do
		(
			local p = gw.hTransPoint $.pos
			gw.hText p "gjhghjg" color:red
			gw.hMarker p #BigHollowBox color:[255,255,255]
		)
		gw.enlargeUpdateRect #whole
		gw.updateScreen()
	)
	unregisterRedrawViewsCallback drawMarkers2
	registerRedrawViewsCallback drawMarkers2