Global mcObjectHilighter
if mcObjectHilighter != undefined do mcObjectHilighter.stop()
struct MC_OBJECT_HILIGHTER (
	
	target_obj = undefined,
	line_color = green,
	fn getBoundingBoxPoints = (
		
		local local_bbox = nodeLocalBoundingBox target_obj --(required AvGuard Extension)
		-- compensate not reset xform
		local tm = target_obj.objecttransform
		local bmin = local_bbox[1]*(inverse tm) 
		local bmax = local_bbox[2]*(inverse tm)
		local bbox_size = local_bbox[2] - local_bbox[1] -- w l h
		local center = (bmin + bmax)/2

		local p0 = center --center red
		local p1 = [center.x,center.y,bmin.z] --bottom green
		local p2 = [center.x,center.y,bmax.z] --top blue
		local p3 = [center.x,bmin.y,center.z] --front yellow
		local p4 = [center.x,bmax.y,center.z] --back gray
		local p5 = [bmin.x,center.y,center.z] --left white
		local p6 = [bmax.x,center.y,center.z] --right brown

		local p7  = bmin --LFD min
		local p8  = [bmin.x, bmin.y, bmax.z] --LFU
		local p9  = [bmin.x, bmax.y, bmax.z] --LBU
		local p10 = [bmin.x, bmax.y, bmin.z] --LBD
		local p11 = [bmax.x, bmax.y, bmin.z] --RBD
		local p12 = bmax --RBU max
		local p13 = [bmax.x, bmin.y, bmax.z] --RFU
		local p14 = [bmax.x, bmin.y, bmin.z] --RFD
		
		local bounding_box_shape_half_a = #(p10, p7, p8, p9, p10, p11, p12, p9) --1 half box
		local bounding_box_shape_half_b = #(p14, p11, p12, p13, p14, p7, p8, p13) --2 half box
		
		#(bounding_box_shape_half_a, bounding_box_shape_half_b)
	),
	fn drawBB = (
		
		if Superclassof target_obj != GeometryClass do return false
			
		gw.setTransform(target_obj.transform)	
		gw.setColor #line line_color
		local bb_points = getBoundingBoxPoints()
		gw.polyline bb_points[1] false --close shape true - false
		gw.polyline bb_points[2] false --close shape true - false
		gw.enlargeUpdateRect #whole
		gw.updateScreen()
	),
	fn getGeoObject = (
		
		target_obj = $
	),
	fn stop = (

		deleteAllChangeHandlers id:#OBJECT_HILIGHTER
		unregisterRedrawViewsCallback drawBB
		CompleteRedraw()
	),
	fn start clr:green = (
	
		target_obj = obj 
		line_color = clr
		stop()
		when select $objects changes id:#OBJECT_HILIGHTER do mcObjectHilighter.getGeoObject()  
		getGeoObject()
		registerRedrawViewsCallback drawBB
	)

)
mcObjectHilighter = MC_OBJECT_HILIGHTER()
mcObjectHilighter.start()
