unregisterRedrawViewsCallback drawSelBBAndControllers
fn drawSelBBAndControllers =	 (
	
		--get bb from selected obj(s)
		local sel = selection
		if sel.count == 0 do return false
		local mi = sel.min, ma = sel.max
		local sel_pos = (sel.min + sel.max)/2
		sel_pos.z = sel.min.z
		--all cube points (CW way)
		local p1=[mi.x,mi.y,mi.z] --min
		local p2=[mi.x,mi.y,ma.z]
		local p3=[ma.x,mi.y,ma.z]
		local p4=[ma.x,mi.y,mi.z]
		local p5=[mi.x,ma.y,mi.z]
		local p6=[mi.x,ma.y,ma.z]
		local p7=[ma.x,ma.y,ma.z] --max
		local p8=[ma.x,ma.y,mi.z]
	local rect_1 = #(p1, p2, p3, p4)
	local rect_2 = #(p5, p6, p7, p8)
	--draw corner markers
	local corner_markers = #(p1, p2, p3, p4, p5, p6, p7, p8)
	for p in corner_markers do ( gw.Marker p #Circle color:green)
	--draw middle markers
	local middle_markers = #(
		(p1+p2)/2, (p2+p3)/2, (p3+p4)/2, (p4+p1)/2, (p1+p5)/2, (p5+p6)/2, (p6+p7)/2, (p7+p8)/2, (p8+p5)/2,
		(p2+p6)/2, (p3+p7)/2, (p4+p8)/2
	)
	for p in middle_markers do ( gw.Marker p #hollowBox color:yellow)
	--draw center markers
	local center_markers = #((p1+p3)/2, (p1+p6)/2, (p1+p8)/2, (p7+p2)/2, (p7+p4)/2, (p7+p5)/2)
	for p in center_markers do ( gw.Marker p #Circle color:green)
	--draw boubding box (TODO > set min width, height, length >  to avoid zero scale)
	gw.setColor #line gray
	gw.Polyline rect_1 true --isClosed_boolean 
	gw.Polyline rect_2 true
	gw.Polyline #(p1, p5) false
	gw.Polyline #(p2, p6) false
	gw.Polyline #(p3, p7) false
	gw.Polyline #(p4, p8) false
	-- Update the viewports
	gw.enlargeUpdateRect #whole
	gw.updateScreen()
)
RegisterRedrawViewsCallback drawSelBBAndControllers
completeRedraw()