 struct MC_POLYGON_PATCHER_STRUCT (
	
	old_sel,
	old_snap_mode,
	work_mesh,
	new_patch,
	trace_vert_pos,
	hits_pos = #(),
	mouse_pos,
	is_tool_enabled = false,
	breaked = false,
	fn reverseArray &refArray = (
		
		local last = refArray.count
		local half = last / 2
		
		for i = 1 to half do
			swap refArray[i] refArray[last - i + 1]
	),
	fn snapshotAsMeshAll obj_arr = (
	
		local base_mesh = mesh vertices:#() faces:#() name:(uniqueName "Polygon_Patcher_Temp_Mesh")
		for o in obj_arr do (
			
			meshop.attach base_mesh (snapshotAsMesh o)
		)
		base_mesh.pivot = (base_mesh.min + base_mesh.max) / 2
		base_mesh.material = standardMaterial name:"Polygon_Patcher_Material" diffuse:(color 226 199 82) --(color 155 155 187)
		base_mesh
	),
	fn createObjectFromVertices selected:true = (
		
		if hits_pos.count < 3 do return false
		local base_mesh = mesh vertices:hits_pos faces:#() name:(uniqueName "Polygon_Patcher_Final_Mesh")
		convertToPoly base_mesh
		local all_vert_list = #{1..(polyop.getNumVerts base_mesh)} as Array
		reverseArray &all_vert_list
		polyOp.createPolygon base_mesh all_vert_list
		base_mesh.pivot = (base_mesh.min + base_mesh.max) / 2
		base_mesh.wirecolor = blue
		if selected do select base_mesh
		base_mesh
	),
	fn drawMarkers = (
		
		--draw preview snap point
		if trace_vert_pos != undefined do (
			
			gw.Marker trace_vert_pos #asterisk color:green --selected measure line have two markers
		)
		if hits_pos.count != 0 do gw.Marker hits_pos[1] #circle color:red --draw circle at first  point
		if hits_pos.count < 1 do return false
		gw.setTransform(Matrix3 1)
		--draw markers and edges
		gw.setColor #line red
		for k=2 to hits_pos.count do (
			
			gw.Marker hits_pos[k] #circle color:red --draw circle at next  point
			gw.Polyline #(hits_pos[k-1], hits_pos[k]) off
		)
		--draw rubberband
		if  mouse_pos != undefined do (
			gw.setcolor #line yellow
			local last_point = gw.transPoint hits_pos[hits_pos.count]
			local mouse_point = gw.transPoint mouse_pos
			gw.wPolyline #(last_point, mouse_point) off
		)
		--show in screen
		gw.enlargeUpdateRect #whole
		gw.updateScreen()
	),
	fn finalize = (
		
		unRegisterRedrawViewsCallback drawMarkers
		if isValidNode work_mesh do delete work_mesh
		if classOf old_sel == Array do (
			
			select old_sel
			unhide old_sel
		)
		snapMode.active = old_snap_mode
		is_tool_enabled = false
		undo "Create Patch" on createObjectFromVertices()
		completeRedraw()
	),
	fn getClosestFaceVertPos ir obj face_index = (
		
		if ir == undefined or obj == undefined or face_index == undefined do return undefined
	
		local face_verts = meshOp.getVertsUsingFace obj face_index
		local closest_pos = meshOp.getVert obj (face_verts as Array)[1]
		local closest_dist = distance ir.pos closest_pos
		
		for v in face_verts do (
			
			local vpos = meshOp.getVert obj v
			local dist = 	distance ir.pos vpos
			if dist < closest_dist do (
				
				closest_dist = dist
				closest_pos = vpos
			)
		)
		closest_pos
	),
	fn traceSurface ir obj face_index = (
	
		trace_vert_pos = getClosestFaceVertPos ir obj face_index
	),
	fn addHitMarker ir obj face_index = (
		
		local vert_pos = getClosestFaceVertPos ir obj face_index
		if vert_pos == undefined do return false
		--if shape is closed then end drawing
		if hits_pos.count > 1 and hits_pos[1] == vert_pos then (
			
			breaked = true
			return OK
		)
		--else continue drawing
		local used_index = findItem hits_pos vert_pos
		--Add - Remove in Collection
		if used_index != 0 then ( --remove it
			
			deleteItem hits_pos used_index
			
		) else ( --add it
			
			append hits_pos vert_pos
		)
		completeRedraw()
	),
	/**
	*@Example
		mouseTrack trackCallback:createPatchCallback on:selection prompt:"Tracking" snap:#3D
	*/
	fn createPatchCallback msg ir obj face_index shift ctrl alt = (    
		
		--format "msg:% ir:% obj:% face:% shift:% ctrl:% alt:%\n" msg ir obj face_index shift ctrl alt
		mouse_pos = if ir != undefined then ir.pos else undefined --viewPoint-- (mapScreenToWorldRay mouse.pos).pos
		case msg of (
			
			#mousePoint: addHitMarker ir obj face_index --select points
			#mouseAbort: breaked = true --finish selection
			#freeMove: completeRedraw() --need for preview gw drawing helpers 
			--#mouseMove: if hits_pos.count > 0 do completeRedraw() --dont realy need
		)
		if not breaked then (
			
			traceSurface ir obj face_index
			#continue 
			
		) else (
			
			finalize()
			#stop
		)
		--if msg == #mouseAbort then #abort else #continue
	),
	fn build = (
		
		old_sel = selection as Array
		if is_tool_enabled or old_sel.count == 0 do return false
		is_tool_enabled = true	--prevent double run
		old_snap_mode = snapMode.active
		snapMode.active = false
--suspendEditing()
		with undo off  ( --undo not realy works...
			
			work_mesh = snapshotAsMeshAll old_sel
			select work_mesh
		)
		hide old_sel
		unRegisterRedrawViewsCallback drawMarkers --simple prevent double run
		registerRedrawViewsCallback drawMarkers
		completeRedraw()
		mouseTrack trackCallback:createPatchCallback on:work_mesh prompt:"Tracking" snap:#3D
	)
)
pps = MC_POLYGON_PATCHER_STRUCT()
pps.build()

/*
------------------------------------------------------------------------------------------
denisT say>
on:<node> MouseTrack feature works for editable_meshes only because it uses IntersectRay() 
(which really works only for editable meshes). But you can not use on node thing, and calculate intersection ray yourself. 
You have a node, you have a ray, use RayMeshGridIntersect interface to get any hit info (face, bary, normal, distance, etc.). 
It works for any geometry class.
------------------------------------------------------------------------------------------
fn createPointAt pos = (
	
	local p = point pos:work_mesh.pos wirecolor:green
	p.size = 5
	p.constantScreenSize = true
	p.box = false
	p.axisTripod = false
	p.centerMarker = false
	p
),
------------------------------------------------------------------------------------------
*/