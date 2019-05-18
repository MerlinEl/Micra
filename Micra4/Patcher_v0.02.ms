	
struct MC_PATCH_STRUCT (	
	
	PatchTool,
	rubberband = false,
	is_tool_enabled = false,
	props = #("active", "markSize", "snapRadius", "displayRubberBand"),
	fn fn_sd = (struct SNAP_DATA (active, markSize, snapRadius, displayRubberBand);),
	sd = fn_sd(),
	old_snap_settings =  ( 
		
		sd \
		snapMode.active \
		snapMode.markSize \
		snapMode.snapRadius \
		snapMode.displayRubberBand
	),
	new_snap_settings = (
		
		sd \
		active:true \
		markSize:40 \
		snapRadius:20 \
		displayRubberBand:false
	),
	view_point,
	wr, --screen to world point ray
	ir,	 --intersect object ray
	target_obj,
	back_faces,
	trace_range = 10, --how far search for a vertex
	hits_pos = #(),
	fn isValidTarget = (isValidNode target_obj and classOf target_obj == Editable_Poly),
	fn transferSettings src_obj trgt_obj props = (
		
		--format "src:\n%\ntrgt:\n%\n" src_obj trgt_obj 
		for p in props do  (
			
			if not (hasProperty src_obj p) or not (hasProperty trgt_obj p) do continue
			setProperty trgt_obj p (getProperty src_obj p)
		)
	),
	fn storeSnapSettings = (
		
		transferSettings new_snap_settings snapMode props
		back_faces = target_obj.backfaceCull
		target_obj.backfaceCull = on
	),
	fn restoreSnapSettings = (
		
		transferSettings old_snap_settings snapMode props
		target_obj.backfaceCull  = back_faces
	),
	fn drawMarkers = (
		
		gw.setTransform(Matrix3 1)
		local old_p
		gw.setColor #line red
		for p in hits_pos do (
			
			gw.Marker p #circle color:red --selected measure line have two markers
			if old_p != undefined do gw.Polyline #(old_p, p) false 
			old_p = p
		)
		if rubberband and hits_pos.count != 0 do ( --draw rubber band
			
			local last_point = gw.transPoint hits_pos[hits_pos.count]
			local screen_point = gw.transPoint ir.pos
			gw.wPolyline #(last_point, screen_point) off
		)
		gw.enlargeUpdateRect #whole
		gw.updateScreen()
	),
	fn getHitVertPos = (
		
		if not (isValidTarget()) do return undefined
		local all_vert_list = #{1..(polyop.getNumVerts target_obj)} as Array
		if ir == undefined or all_vert_list.count == 0 do return undefined
		local closest_pos, closest_dist
		for v in all_vert_list do (
			
			local vpos = polyOp.getVert target_obj v
			local dist = 	distance ir.pos vpos
			if closest_dist == undefined or dist < closest_dist do (
				
				closest_dist = dist
				closest_pos = vpos
			)
		)
		if closest_dist > trace_range then undefined else closest_pos
	),
	fn addRemoveHitMarker = (
		
		local vert_pos = getHitVertPos()
		if vert_pos == undefined do return false
		local used_index = findItem hits_pos vert_pos
		--Add - Remove in Collection
		if used_index != 0 then ( --remove it
			
			deleteItem hits_pos used_index
			
		) else ( --add it
			
			append hits_pos vert_pos
		)
		CompleteRedraw()
	),
	fn toolStart = (

		format "PatchTool > start....\n"
		if is_tool_enabled do return false --prevent to double run this tool
		is_tool_enabled = true
		storeSnapSettings()
		registerRedrawViewsCallback drawMarkers
	),
	fn toolEnd = (
		
		unRegisterRedrawViewsCallback drawMarkers
		is_tool_enabled = false
		restoreSnapSettings()
		format "PatchTool > end.\n"
	),
	fn toolClick clickno = (

		format "PatchTool > click mouse....\n"
		if clickno == 1 do return false
		addRemoveHitMarker()
		CompleteRedraw()
	),
	fn init = (
		
		target_obj = selection[1]	
		if not (isValidTarget()) then (
			
			format "Exit > Invalid Target:%\n" target_obj
			false
			
		) else (
		
			true
		)
	),
	fn build = (
	
		if not ( init () ) do return false
		tool PatchTool  ( --prompt:"Start buils you mesh." numPoints:4
	
			on start							do	toolStart()
			on stop 							do	toolEnd()
			on mousePoint clickno	do	(
				
				view_point = viewPoint
				wr = mapScreenToWorldRay viewPoint
				if isValidNode target_obj do ir = intersectRay target_obj wr
				toolClick clickno
			)
			/*on freeMove 					do	(
				
				--maybe rubber band
				toolFreeMove() 
			)*/
			on mousemove click	do  rubberband = true
		)
		startTool PatchTool snap:#3D
	)
)
( --local space
	local mcp = MC_PATCH_STRUCT()
	mcp.build()
)