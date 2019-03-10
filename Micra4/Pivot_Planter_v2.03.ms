----------------------
----------------------
--                  --
--  Pivot Planter 2 --
--                  --
----------------------
----------------------

--Pivot Planter 2 30.10.2009


Global mc_PIVOT_PLANTER

if mc_PIVOT_PLANTER != undefined do stopTool mc_PIVOT_PLANTER

(
	local sel = selection
	local sp_size = (distance sel.min sel.max) / 29
	local temp_box_marker , marked, old_radius, temp_layer
	local clr = white --green --gray--
	
	
	fn createPivotMarker sel clr =
	(
		--get bb from obj
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
		--set all transparent
		sel.xray = true
		--calculate size of bigest sphere
		local sp_size = (distance mi ma) / 30
		--drav spines around
		local sp = SplineShape pos:sel_pos name:"temp_box_marker01" 
		addNewSpline sp
		--rect1
		addKnot sp 1 #corner #line p1
		addKnot sp 1 #corner #line p2
		addKnot sp 1 #corner #line p3
		addKnot sp 1 #corner #line p4
		addKnot sp 1 #corner #line p1
		--rect 2
		addKnot sp 1 #corner #line p5
		addKnot sp 1 #corner #line p6
		addKnot sp 1 #corner #line p7
		addKnot sp 1 #corner #line p8
		addKnot sp 1 #corner #line p5
		addNewSpline sp
		addKnot sp 2 #corner #line p2
		addKnot sp 2 #corner #line p6	
		addNewSpline sp
		addKnot sp 3 #corner #line p3
		addKnot sp 3 #corner #line p7	
		addNewSpline sp
		addKnot sp 4 #corner #line p4
		addKnot sp 4 #corner #line p8
		updateShape sp
		sp.displayRenderMesh = false --true
		sp.thickness = 0.4
		sp.wirecolor = gray--clr
		sp.steps = 0
		--insert spheres in corners and mid points
		--center
		local s00 = sphere radius:sp_size pos:((p1+p7)/2) name:(uniqueName "temp_s1_marker") wirecolor:clr
		--main
		local s01 = sphere radius:((sp_size/3)*2) pos:p1 name:(uniqueName "temp_s1_marker") wirecolor:clr
		local s02 = sphere radius:((sp_size/3)*2) pos:p2 name:(uniqueName "temp_s1_marker") wirecolor:clr
		local s03 = sphere radius:((sp_size/3)*2) pos:p3 name:(uniqueName "temp_s1_marker") wirecolor:clr
		local s04 = sphere radius:((sp_size/3)*2) pos:p4 name:(uniqueName "temp_s1_marker") wirecolor:clr
		local s05 = sphere radius:((sp_size/3)*2) pos:p5 name:(uniqueName "temp_s1_marker") wirecolor:clr
		local s06 = sphere radius:((sp_size/3)*2) pos:p6 name:(uniqueName "temp_s1_marker") wirecolor:clr
		local s07 = sphere radius:((sp_size/3)*2) pos:p7 name:(uniqueName "temp_s1_marker") wirecolor:clr
		local s08 = sphere radius:((sp_size/3)*2) pos:p8 name:(uniqueName "temp_s1_marker") wirecolor:clr
		--middle
		local s09 = sphere radius:(sp_size/3) pos:((p1+p2)/2) name:(uniqueName "temp_s1_marker") wirecolor:clr
		local s10 = sphere radius:(sp_size/3) pos:((p2+p3)/2) name:(uniqueName "temp_s1_marker") wirecolor:clr
		local s11 = sphere radius:(sp_size/3) pos:((p3+p4)/2) name:(uniqueName "temp_s1_marker") wirecolor:clr
		local s12 = sphere radius:(sp_size/3) pos:((p4+p1)/2) name:(uniqueName "temp_s1_marker") wirecolor:clr
		local s13 = sphere radius:(sp_size/3) pos:((p1+p5)/2) name:(uniqueName "temp_s1_marker") wirecolor:clr
		local s14 = sphere radius:(sp_size/3) pos:((p5+p6)/2) name:(uniqueName "temp_s1_marker") wirecolor:clr
		local s15 = sphere radius:(sp_size/3) pos:((p6+p7)/2) name:(uniqueName "temp_s1_marker") wirecolor:clr
		local s16 = sphere radius:(sp_size/3) pos:((p7+p8)/2) name:(uniqueName "temp_s1_marker") wirecolor:clr
		local s17 = sphere radius:(sp_size/3) pos:((p8+p5)/2) name:(uniqueName "temp_s1_marker") wirecolor:clr
		local s18 = sphere radius:(sp_size/3) pos:((p2+p6)/2) name:(uniqueName "temp_s1_marker") wirecolor:clr
		local s19 = sphere radius:(sp_size/3) pos:((p3+p7)/2) name:(uniqueName "temp_s1_marker") wirecolor:clr
		local s20 = sphere radius:(sp_size/3) pos:((p4+p8)/2) name:(uniqueName "temp_s1_marker") wirecolor:clr
		--side centers
		local s21 = sphere radius:(sp_size/3) pos:((p1+p3)/2) name:(uniqueName "temp_s1_marker") wirecolor:clr
		local s22 = sphere radius:(sp_size/3) pos:((p1+p6)/2) name:(uniqueName "temp_s1_marker") wirecolor:clr
		local s23 = sphere radius:(sp_size/3) pos:((p1+p8)/2) name:(uniqueName "temp_s1_marker") wirecolor:clr
		local s24 = sphere radius:(sp_size/3) pos:((p7+p5)/2) name:(uniqueName "temp_s1_marker") wirecolor:clr
		local s25 = sphere radius:(sp_size/3) pos:((p7+p2)/2) name:(uniqueName "temp_s1_marker") wirecolor:clr
		local s26 = sphere radius:(sp_size/3) pos:((p7+p4)/2) name:(uniqueName "temp_s1_marker") wirecolor:clr
		
		local elements = #(sp,s00,s01,s02,s03,s04,s05,s06,s07,s08,s09,s10,s11,s12,s13,s14,s15,s16,s17,s18,s19,s20,s21,s22,s23,s24,s25,s26)
		local temp_box_marker = group elements name:"temp_box_marker" select:false
		--add markers in to a layer
		temp_layer = LayerManager.newLayer()
		temp_layer.setName (uniqueName "Pivot Planter Tmp")
		for o in elements do temp_layer.addNode o
		temp_layer.addNode temp_box_marker
		return elements
	)

	fn getObjectFromRay ray objs =
	(
		struct object_data (obj, ray)
		--collect all visible objects in scene
		local od = #()
		local ray_dist    = #()
		--collect objects shoted by ray
		for o in objs do (
			
			local i = intersectRay o ray
			if i!= undefined do 
			(
				od += #(object_data o i)
				ray_dist    += #(distance ray.pos i.pos)
			)
		)
		if od.count      == 0
		then return undefined
		else if od.count == 1
		then return od[1] 
		else --return the closest object to ray begin
		(
			copy_ray_dist = #()+ray_dist --4fun
			sort copy_ray_dist
			return od[findItem ray_dist copy_ray_dist[1]]
		)
	)

	tool mc_PIVOT_PLANTER (
		
		on start do 
		(
			--print "start"
			if sel.count != 0 
			then temp_box_marker = undo off (createPivotMarker sel clr)
			else #stop
		)
		on freeMove do --detect closest objects in marker from mouse pointer
		(
			local obj_data = getObjectFromRay (mapScreentoWorldRay viewPoint) temp_box_marker
			--format "obj_data:%\n" obj_data
			if obj_data != undefined
			then
			(
				if marked != undefined and obj_data.obj != marked
				then
				(
					marked.wirecolor = clr
					marked.radius = old_radius
					old_radius = undefined
					marked = undefined
				)
				else
				(
					marked = obj_data.obj
					if old_radius == undefined do old_radius = marked.radius
					marked.radius = sp_size --old_radius * 2
					marked.wirecolor =red --yellow --
				)
			)
			else if marked != undefined do
			(
				marked.wirecolor = clr
				marked.radius = old_radius
				old_radius = undefined
				marked = undefined
			)
		)
		on mousePoint clickno do 
		(
			if marked != undefined 
			then 
			(
				undo "Pivot Plant" on sel.pivot = marked.pivot
				#stop
			)
			else #stop
		)
		on mouseMove clickno do ()
		on mouseAbort clickno do ()
		on stop do 
		(
			local m = getNodeByName "temp_box_marker"
			if m != undefined do undo off
			(
				delete m
				LayerManager.deleteLayerByName temp_layer.name
				sel.xray = false
			)
			--print "end"
		)
	)
	mcDotnet.focusViewport() --after action button  pressed, wee need to focus at viewport
	startTool mc_PIVOT_PLANTER --start tool
)