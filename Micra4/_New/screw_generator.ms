  /* denisT collection 2013 */
   
   plugin simpleObject Screw name:"Screw"
   classID:#(0x00001967, 0x1063899f)
   category:"Standard Plus" 
   version:1
   (
   	local screwobject, bodyobject
   	parameters params rollout:params
   	(
   		curve type:#maxobject
   		
   		radius1 type:#worldUnits default:4 ui:ui_radius1
   		radius2 type:#worldUnits default:6 ui:ui_radius2
   
   		height type:#worldUnits default:10 ui:ui_height
   
   		turns type:#float default:1 ui:ui_turns
   		step type:#worldUnits default:1 ui:ui_step
   		sides type:#integer default:16 ui:ui_sides
   		direction type:#integer default:1 animatable:off ui:ui_direction	
   
   		autosmooth type:#float default:45 ui:ui_autosmooth
   
   		mapCoords type:#boolean default:on ui:ui_mapCoords
   		realWorldMapSize type:#boolean default:off ui:ui_realWorldMapSize 
   		
   		manualUpdate type:#boolean default:off animatable:off ui:ui_manualUpdate
   	)
   	rollout params "Parameters" 
   	(
   		local updating = on
   			
   		group "Geometry: "
   		(
   			spinner ui_radius1 "Inner Radius: " type:#worldUnits range:[0,1e9,0] fieldwidth:50 align:#right offset:[2,0]
   			spinner ui_radius2 "Outer Radius: " type:#worldUnits range:[0,1e9,0] fieldwidth:50 align:#right offset:[2,-2]
   			spinner ui_height "Height: " type:#worldUnits range:[0,1e9,0] fieldwidth:50 align:#right offset:[2,6]
   			spinner ui_turns "Thread Turns: " type:#float range:[1,256,0] fieldwidth:50 scale:0.1 align:#right offset:[2,6]
   			spinner ui_step "Thread Width: " type:#worldUnits range:[0,1e9,0] fieldwidth:50 scale:0.1 align:#right offset:[2,-2]
   			spinner ui_sides "Sides: " type:#integer range:[3,256,0] fieldwidth:50 align:#right offset:[2,-2]
   			radiobuttons ui_direction labels:#("CW", "CCW") columns:1 align:#left offset:[79,2]	
   
   			spinner ui_autosmooth "Auto Smooth: " type:#float range:[0,180,45] fieldwidth:50 align:#right offset:[2,2]
   
   			checkbox ui_mapCoords "Generate Map Coords." align:#left offset:[-2,4]
   			checkbox ui_realWorldMapSize "Real-World Map Size" align:#left offset:[-2,0]
   		)
   		group "Profile: "
   		(
   			CurveControl ui_profile numCurves:1 width:144 height:100 align:#left offset:[-4,2] enabled:on \
   				x_range:[0,1] y_range:[-0.5,1] x_value:0 \
   				scrollValues:[0,-10] zoomValues:[128,60] \
   				uiFlags:#(#constrainY, #noFilterButtons) \
   				rcmFlags:#(#move_xy, #move_x, #move_y, #corner, #delete) 
   			
   			checkbox ui_manualUpdate "Manual Update" align:#left offset:[-2,0]
   			button ui_updateProfile "Update" width:71 align:#left offset:[-4,0] tooltip:"Update Profile" across:2
   			button ui_resetProfile "Reset" width:71 align:#right offset:[4,0] tooltip:"Reset Profile"
   		)
   		
   		fn setProfile action:#ui update: = if isproperty this #curve do 
   		(
   			if update == unsupplied do update = not manualUpdate
   			c = ui_profile.curves[1]
   			
   			if not iskindof curve bezier_float do curve = bezier_float()
   			t = curve
   				
   			n = 1f
   			
   			while t.keys.count < c.points.count do addnewkey t (n += 1)
   			while t.keys.count > c.points.count do deletekey t 1
   			for n=1 to c.points.count do 
   			(
   				p = c.points[n]
   				k = t.keys[n]
   				
   				k.time = p.value.x
   				k.value = p.value.y
   				k.inTangentType = #linear
   				k.outTangentType = #linear
   				k.x_locked = p.lock_x
   				k.y_locked = p.lock_y
   				k.selected = p.selected
   			)
   			if update do 
   			(
   				this.domesh()
   				redrawviews()
   			)
   		)
   		fn getProfile = if isproperty this #curve do 
   		(
   			c = ui_profile.curves[1]
   			t = curve
   			
   			c.numPoints = t.keys.count
   			for n=t.keys.count to 1 by -1 do 
   			(
   				p = c.points[n]
   				k = t.keys[n]
   
   				p.value = [k.time, k.value]
   				p.bezier = off
   				p.corner = on
   				p.lock_x = k.x_locked
   				p.lock_y = k.y_locked
   				p.selected = k.selected
   			)
   		)
   
   		on ui_profile deleted c val do if not loading and not updating do setProfile()
   		on ui_profile ptChanged c val do if not loading and not updating do setProfile()
   		on ui_profile tangentChanged c val type do if not loading and not updating do setProfile()
   		
   		fn resetProfile update:off = 
   		(
   			c = ui_profile.curves[1]
   			c.numpoints = 3
   			c.points[2].value = [0.5,1]
   			c.points[3].value = [1,0]
   			c.points[1].lock_x = c.points[3].lock_x = on
   			c.points.lock_y = off
   			
   			setProfile update:update
   		)
   		on ui_updateProfile pressed do undo "Update Screw Profile" on 
   		(
   			updating = on
   			setProfile update:on
   			updating = off
   		)
   		on ui_resetProfile pressed do undo "Reset Screw Profile" on 
   		(
   			updating = on
   			resetProfile update:on
   			updating = off
   		)
   		on params open do
   		(
   			updating = on
   			deleteAllChangeHandlers id:#screw_callback
   			c = ui_profile.curves[1]
   			if not iskindof curve bezier_float then resetProfile update:off else getProfile()
   
   			ccTarget = (refs.dependents ui_profile.curves[1])[1]
   			when topology ccTarget change id:#screw_callback do 
   			(
   				if ui_profile.curves[1].numpoints != numkeys curve do setProfile action:#curve
   			)
   			updating = off
   		)
   		on params close do 
   		(
   			deleteAllChangeHandlers id:#screw_callback
   		)
   	)
   	
   	fn domesh = 
   	(
   		if screwobject == undefined do screwobject = createinstance plane width:1 length:1
   		screwobject.widthsegs = if iskindof curve bezier_float then (numkeys curve)-1 else 1
   		screwobject.lengthsegs = sides*turns
   		screwobject.mapCoords = mapCoords
   		screwobject.realWorldMapSize = realWorldMapSize
   		mesh = screwobject.mesh
   
   		if bodyobject == undefined do bodyobject = createinstance plane width:1 length:1 widthsegs:1
   		bodyobject.lengthsegs = sides*(turns-1)
   		bodyobject.mapCoords = mapCoords
   		bodyobject.realWorldMapSize = realWorldMapSize
   		bodymesh = bodyobject.mesh
   		
   		points = curve.keys.count
   		h = (height - step)/sides/turns
      		ang = 360./sides
   		if direction > 1 do ang = -ang 
   		verts = mesh.verts as bitarray
   		v = 0
   		turn = 0
   		a = 0 
   		f = radius2 - radius1
   		while not verts.isempty do
   		(
   			for k=1 to points while not verts.isempty do
   			(
   				v += 1
   				verts[v] = off
   				p = getvert mesh v
   				p.x = curve.keys[k].time
     				p.z = curve.keys[k].value
   				pos = [(radius1 + p.z*f)*(cos a), (radius1 + p.z*f)*(sin a), p.x*step + turn]
   				setvert mesh v pos
   			)
   			a += ang
   			turn += h
   		)
   		
   		verts = bodymesh.verts as bitarray
   		for v in verts do
   		(
   			if mod v 2 > 0 then
   			(
   				n = (v+1)/2*points
   			)
   			else
   			( 
   				n = (v/2 + sides - 1)*points + 1
   			)
   			if n <= mesh.numverts do setvert bodymesh v (getvert mesh n)
   		)
   		n = mesh.numfaces
   		meshop.attach mesh bodymesh
   		for f=n+1 to mesh.numfaces do setfacematid mesh f 2
   
   		meshop.weldVertsByThreshold mesh #all 0.0001
   		
   		if direction < 2 do meshop.flipNormals mesh #all			
   		meshop.autoSmooth mesh #all autosmooth
   		update mesh
   		mesh
   	)
   	
   
   	on buildmesh do domesh()
   
   	tool create
   	(
   		on mousePoint click do case click of
   		(
   			1: 
   			(
   				nodeTM.translation = gridPoint
   				radius1 = radius2
   				height = 0.01
   				turns = 2
   				step = 0.001
   			)
   			4: #stop
   		)
   		on mouseMove click do case click of
   		(
   			2: radius1 = radius2 = amax (abs gridDist.x) (abs gridDist.y)
   			3: 
   			(
   				height = gridDist.z
   				step = height/turns*0.9
   			)
   			4: radius2 = amax (abs gridDist.x) (abs gridDist.y)
   		)
   	)
   	on update do domesh()
   )
   