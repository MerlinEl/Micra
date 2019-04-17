utility mapsteal "Map theif V1.0"
	(
	local sourcepolys, mapinfo, tvcount, vcount, mid, currenttv, near, mapverts, gizmopolycount, nearto	
	local source = undefined
	local dest = undefined
	
	function groupmatids obj = 
		(
		ids = #()
		for i = 1 to obj.numfaces do
			(
			fm = getfacematid obj i
			if ids[fm] == undefined do ids[fm] = #()
			append ids[fm] i
			)
		
		i = 1
		while i < ids.count do
			(
			if ids[i] == undefined do
				(
				ids[i] = #()
				)
			i += 1
			)
		
		return ids
		)
		
	function pointthreeminmax points = 
		(
		mid = [0,0,0]
		for i = 1 to points.count do
			(
			mid += points[i]
			)
		mid /= points.count
		
		themin = copy mid
		themax = copy mid
		
		for i = 1 to points.count do
			(
			if points[i].x > themax.x then
				(
				themax.x = points[i].x
				)
			else
				(
				if points[i].x < themin.x do
					(
					themin.x = points[i].x
					)
				)
	
			if points[i].y > themax.y then
				(
				themax.y = points[i].y
				)
			else
				(
				if points[i].y < themin.y do
					(
					themin.y = points[i].y
					)
				)
	
			if points[i].z > themax.z then
				(
				themax.z = points[i].z
				)
			else
				(
				if points[i].z < themin.z do
					(
					themin.z = points[i].z
					)
				)			
			)
		
		return #(themin, themax, mid)
		)
	
	function mapgizmo obj p = 
		(
		struct pbound (axis, width, height, depth, majouraxis, UVorigin, UVwidth, UVheight, midpoint, normal)
		--*******************************
		--*	get world bounds of face	*
		--*******************************
		verts = #{}
		tvert = #{}
		v = #()
		tv = #()
		vcount = 0
		tvcount = 0
		n = [0,0,0]
		
		for i = 1 to p.count do
			(
			f = getface obj p[i]
			tf = gettvface obj p[i]
			n += getfacenormal obj p[i]
			verts[f.x] = true
			verts[f.y] = true
			verts[f.z] = true
	
			tvert[tf.x] = true
			tvert[tf.y] = true
			tvert[tf.z] = true
			)
		
		for i in verts do
			(
			v[vcount += 1] = getvert obj i
			)
		
		for i in tvert do
			(
			tv[tvcount += 1] = gettvert obj i
			)
		
		n = normalize n
		sizes = pointthreeminmax v
		fmin = sizes[1]
		fmax = sizes[2]
		cp = sizes[3]
		sizes = pointthreeminmax tv
		UVmin = sizes[1]
		UVmax = sizes[2]
		
		--*******************************
		--*	get majour axis of plane	*
		--*******************************
		maxis = #()
		maxis[1] = abs n.x
		maxis[2] = abs n.y
		maxis[3] = abs n.z
		ma = 1
		
		if maxis[2] > maxis[1] do ma = 2
		if maxis[3] > maxis[ma] do ma = 3
		
		case ma of
			(
			1 : (if n.x < 0.0 do ma = 4)
			2 : (if n.y < 0.0 do ma = 5)
			3 : (if n.z < 0.0 do ma = 6)
			)
		
		--*******************************************
		--*	set bounding rectangle in majour axis	*
		--*******************************************
		p = #()
		dir = [0,0,0]
		case ma of 
			(
			1 : (
				p[1] = [fmax.x, fmin.y, fmax.z]
				p[2] = [fmax.x, fmax.y, fmax.z]
				p[3] = [fmax.x, fmax.y, fmin.z]
				p[4] = [fmax.x, fmin.y, fmin.z]
				dir = [-1,0,0]			
				)
			2 :	(
				p[1] = [fmax.x, fmax.y, fmax.z]
				p[2] = [fmin.x, fmax.y, fmax.z]
				p[3] = [fmin.x, fmax.y, fmin.z]
				p[4] = [fmax.x, fmax.y, fmin.z]		
				dir = [0,-1,0]
				)
			3 :	(
				p[1] = [fmin.x, fmax.y, fmax.z]
				p[2] = [fmax.x, fmax.y, fmax.z]
				p[3] = [fmax.x, fmin.y, fmax.z]
				p[4] = [fmin.x, fmin.y, fmax.z]		
				dir = [0,0,-1]
				)
			4 :	(
				p[1] = [fmin.x, fmax.y, fmax.z]
				p[2] = [fmin.x, fmin.y, fmax.z]
				p[3] = [fmin.x, fmin.y, fmin.z]
				p[4] = [fmin.x, fmax.y, fmin.z]		
				dir = [1,0,0]
				)
			5 :	(
				p[1] = [fmin.x, fmin.y, fmax.z]
				p[2] = [fmax.x, fmin.y, fmax.z]
				p[3] = [fmax.x, fmin.y, fmin.z]
				p[4] = [fmin.x, fmin.y, fmin.z]		
				dir = [0,1,0]
				)
			6 :	(
				p[1] = [fmin.x, fmin.y, fmin.z]
				p[2] = [fmax.x, fmin.y, fmin.z]
				p[3] = [fmax.x, fmax.y, fmin.z]
				p[4] = [fmin.x, fmax.y, fmin.z]		
				dir = [0,0,1]
				)			
			)
			
		--*******************************************************
		--*	intersect points along majour axis onto face plane	*
		--*******************************************************
		
		for i = 1 to 4 do
			(
			t = (dot (cp - p[i]) n) / (dot ((p[i] + (dir * 1000)) - p[i]) n)
			np = (p[i] + t * (p[i] + (dir * 1000) - p[i]))
			p[i] = np
			)
		
		--***************************************
		--*	return axis set and width / height	*
		--***************************************
		w = (p[2] - p[1])
		h = (p[1] - p[4])
		
		return pbound axis:(inverse (matrix3 (normalize w) (normalize h) n p[4])) depth:(length w) width:(length w) height:(length h) majouraxis:([0,0,0] - dir) UVorigin:UVmin UVwidth:(UVmax.x - UVmin.x) UVheight:(UVmax.y - UVmin.y) midpoint:cp normal:n
		)

	function mousecallback msg ir obj facenum shift crtl alt args = 
		(
		pushprompt "Mat Id paint (Right click to cancel - CRTL to pick ID)"

		case msg of
			(
			#mouseabort :	(
							return false		
							)

			#mousemove :	(
							if facenum != undefined do
								(
								if (not crtl) then
									(
									try
										(
										setfacematid obj facenum args[1]
										update obj geometry:false topology:false normals:false
										return #continue
										)
									catch
										(
										pushprompt "Missed object!"
										return #continue
										)
									)
								else
									(
									try
										(
										args[1] = getfacematid obj facenum 
										mapsteal.pmatid.value = args[1]
										return #continue
										)
									catch
										(
										pushprompt "Missed object!"
										return #continue
										)									
									)
								)
							)
				#mousepoint : 	(
								if facenum != undefined do
									(
									if crtl do
										(
										try
											(
											args[1] = getfacematid obj facenum 
											mapsteal.pmatid.value = args[1]
											return #continue
											)
										catch
											(
											pushprompt "Missed object!"
											return #continue
											)
										)
									)
								)
				)
			return #continue
			)
	
	group "Source"
		(
		pickbutton picksource "Pick" width:120 highlightcolor:red
		label sourceinfo "Faces:0" align:#center
		)
	
	group "Destination"
		(
		pickbutton pickdest "Pick" width:120
		label destinfo "Faces:0" align:#center
		)
	
	group "Setup"
		(
		button guessmap "Guess Assignment" align:#center width:120
		spinner bias "Bias Angle" range:[-0.9, 0.9, 0.2] align:#center scale:0.01 width:80
		checkbutton paintmat "Paint Mat ID" highlightcolor:(color 0 255 150) width:120
		spinner pmatid "ID" range:[1,999,1] type:#integer align:#center width:45
		)
	button remap "Remap" width:120
	progressbar pbar "" height:10 color:(color 255 0 0) align:#center
	label inf1 "Ready..."
	
	on paintmat changed val do
		(
		if (val and (dest != undefined)) then
			(
			if (mousetrack on:dest trackcallback:#(mousecallback,#(pmatid.value))) != #continue do
				(
				paintmat.checked = false
				)
			)
		else
			(
			messagebox "Pick a Destination object!" title:"Map theif V1.0"
			paintmat.checked = false
			)
		)
	
	on guessmap pressed do
		(
		if (querybox "This will erase any manual assignmets you have made\nContinue?" title:"Map theif V1.0") do
			(
			if ((source != undefined) and (dest != undefined)) then
				(
				for i = 1 to dest.numfaces do
					(
					dist = 99999999
					f = getface dest i
					mid = ((getvert dest f.x) + (getvert dest f.y) + (getvert dest f.z)) / 3
					for n = 1 to gizmopolycount do
						(
						if (dot mapinfo[n].normal (getfacenormal dest i)) > bias.value do
							(
							if (abs (d = dot mapinfo[n].normal (mapinfo[n].midpoint - mid))) < dist do
								(
								near = n
								dist = d
								)
							)
						)
					setfacematid dest i near
					)
				update dest topology:false normals:false geometry:false
				)
			else
				(
				messagebox "pick a source and destination object!" title:"Map theif V1.0"
				)
			)
		)
	
	on picksource picked obj do
		(
		if classof obj != editable_mesh do
			(
			messagebox "This object need to be an editable mesh" title:"Map theif V1.0"
			return undefined			
			)
	
		if obj.modifiers.count != 0 do
			(
			if (Querybox "This object has modifiers\nShall I collapse it?" title:"Map theif V1.0") then
				(
				collapsestack obj
				)
			else
				(
				return undefined	
				)
			)
		
		if obj.numtverts == 0 do
			(
			messagebox "This object has no mapping"  title:"Map theif V1.0"
			return undefined
			)
		
		source = obj
		sourcepolygons = groupmatids source
		gizmopolycount = sourcepolygons.count				
		nearto = #()
		mapinfo = #()
		for i = 1 to gizmopolycount do
			(
			nearto[i] = #()
			mapinfo[i] = mapgizmo source sourcepolygons[i]
			pbar.value = (i as float / gizmopolycount) * 100
			)
		picksource.text = obj.name
		sourceinfo.text = ("Faces: " + obj.numfaces as string)		
		pbar.value = 0  
		)
	
	on pickdest picked obj do
		(
		if classof obj != editable_mesh do
			(
			messagebox "This object need to be an editable mesh" title:"Map theif V1.0"
			return undefined			
			)
	
		if obj.modifiers.count != 0 do
			(
			if (Querybox "This object has modifiers\nShall I collapse it?" title:"Map theif V1.0") then
				(
				collapsestack obj
				)
			else
				(
				return undefined	
				)
			)
	
		dest = obj
		pickdest.text = obj.name
		destinfo.text = ("Faces: " + obj.numfaces as string)		
		)
	
	on remap pressed do
		(
		local domap = true
		
		if source == undefined then
			(
			return (messagebox "You must pick a source object" title:"Map theif V1.0")
			)
		else
			(
			domap = true
			)
	
		if dest == undefined then
			(
			return (messagebox "You must pick a destination object" title:"Map theif V1.0")
			)
		else
			(
			domap = true
			)
		
		
		if domap do
			(
			mapverts = #()
			currenttv = 0
			
			inf1.text = "Sorting near polygons..."
			pbar.color = blue
			for i = 1 to dest.numfaces do
				(
				--***********************************
				--*	get all useful destpoly info	*
				--***********************************
				
				matid = getfacematid dest i
				append nearto[matid] i
				pbar.value = (i as float / gizmopolycount) * 100
				)
			update dest
			
			numtverts = 0
			for i = 1 to gizmopolycount do
				(
				numtverts += ((meshop.getvertsusingface dest nearto[i])as array).count
				)
			setnumtverts dest numtverts false
			buildtvfaces dest false
			
			format "%\n" gizmopolycount
			
			inf1.text = "Mapping polygons..."
			pbar.color = red
			depthmod = ((dest.max.z - dest.min.z) + (dest.max.x - dest.min.x) + (dest.max.y - dest.min.y)) / 3
			for i = 1 to gizmopolycount do
				(
				--*******************************************
				--*	get rebuilt tfaces for dest polygons	*
				--*******************************************
				polyverts = (meshop.getvertsusingface dest nearto[i]) as array
				
				for n = 1 to polyverts.count do
					(
					mapverts[polyverts[n]] = (currenttv += 1)
					v = getvert dest polyverts[n]
					newtv = v * mapinfo[i].axis
					newtv = [newtv.x / mapinfo[i].width, newtv.y / mapinfo[i].height, newtv.z / depthmod]
					settvert dest currenttv [mapinfo[i].UVorigin.x + (mapinfo[i].UVwidth * newtv.x), mapinfo[i].UVorigin.y + (mapinfo[i].UVheight * newtv.y), 1.0 + newtv.z]
					)
				
				for n = 1 to nearto[i].count do
					(
					tvface = getface dest nearto[i][n]
					settvface dest  nearto[i][n] [mapverts[tvface.x], mapverts[tvface.y], mapverts[tvface.z]]
					)
				pbar.value = (i as float / gizmopolycount) * 100
				)
			update dest
			pbar.value = 0.0
			inf1.text = "Ready..."
			)
		)
	)--*end of script
	
	