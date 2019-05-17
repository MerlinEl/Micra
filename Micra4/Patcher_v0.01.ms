 struct MC_POLYGON_PATCHER_STRUCT (
	
	old_sel,
	work_mesh,
	new_patch,
	trace_vert_pos,
	hits_pos = #(),
	temp_point,
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
	fn createObjectFromVertices selected:true= (
			
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
		
		gw.setTransform(Matrix3 1)
		
		/*if trace_vert_pos != undefined do (
			
			gw.Marker trace_vert_pos #plusSign color:green --selected measure line have two markers
		)*/
		local old_p
		gw.setColor #line red
		for p in hits_pos do (
			
			gw.Marker p #circle color:red --selected measure line have two markers
			if old_p != undefined do gw.Polyline #(old_p, p) false 
			old_p = p
		)
		gw.enlargeUpdateRect #whole
		gw.updateScreen()
	),
	fn finalize = (
		
		unRegisterRedrawViewsCallback drawMarkers
		delete temp_point
		if isValidNode work_mesh do delete work_mesh
		if classOf old_sel == Array do (
			
			select old_sel
			unhide old_sel
		)
		if hits_pos.count >= 3 do createObjectFromVertices()
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
		if trace_vert_pos != undefined do (
			
			temp_point.pos = trace_vert_pos
		)
	),
	fn addHitMarker ir obj face_index = (
		
		local vert_pos = getClosestFaceVertPos ir obj face_index
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
	/**
	*@Example
		mouseTrack trackCallback:createPatchCallback on:selection prompt:"Tracking" snap:#3D
	*/
	fn createPatchCallback msg ir obj face_index shift ctrl alt = (    
		
		--format "msg:% ir:% obj:% face:% shift:% ctrl:% alt:%\n" msg ir obj face_index shift ctrl alt
		local breaked = false
		case msg of (
			
			#mousePoint: addHitMarker ir obj face_index --select points
			#mouseAbort: breaked = true --finish selection
		)
		if not breaked then (
			
			traceSurface ir obj face_index
			#continue 
			
		) else (
			
			finalize()
			#stop
		)
	),
	fn createPointAt pos = (
		
		local p = point pos:work_mesh.pos wirecolor:green
		p.size = 5
		p.constantScreenSize = true
		p.box = false
		p.axisTripod = false
		p.centerMarker = false
		p
	),
	fn build = (
		
		old_sel = selection as Array
		if old_sel.count == 0 do return false
		work_mesh = snapshotAsMeshAll old_sel
		select work_mesh
		hide old_sel
		unRegisterRedrawViewsCallback drawMarkers --simple prevent double run
		registerRedrawViewsCallback drawMarkers
		completeRedraw()
		temp_point = createPointAt work_mesh.pos
		mouseTrack trackCallback:createPatchCallback on:work_mesh prompt:"Tracking" snap:#3D
	)
)
pps = MC_POLYGON_PATCHER_STRUCT()
pps.build()

/*
denisT say>
on:<node> MouseTrack feature works for editable_meshes only because it uses IntersectRay() 
(which really works only for editable meshes). But you can not use on node thing, and calculate intersection ray yourself. 
You have a node, you have a ray, use RayMeshGridIntersect interface to get any hit info (face, bary, normal, distance, etc.). 
It works for any geometry class.
*/