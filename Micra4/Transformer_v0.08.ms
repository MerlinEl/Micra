-------------------------------
-------------------------------
--                                  --
--  Object Transformer 2 --
--                                  --
-------------------------------
-------------------------------

--Created / 25.03.2011 - 12.04.2011 by Rene Baca
--Thanks to Martin Capousek :-) 

Global mc_OBJECT_TRANSFORMER

if mc_OBJECT_TRANSFORMER != undefined do stopTool mc_OBJECT_TRANSFORMER

(
	struct OBJECT_TRANSFORMER_DT
	(
		sel, marked, temp_box_marker, temp_layer, angle_markers = #(),
		sp_size, old_radius, rot_angle = 90,  aborted = 0,
		clr_1 = green, clr_2 = gray, clr_3 = red
	)
	local OTD = OBJECT_TRANSFORMER_DT()

	struct OBJECT_TRANSFORMER_FN
	(	
		fn splineFromPoints sps num points_array type:#corner =
		(
			addNewSpline sps
			for p in points_array do 
			(
				case type of --#smooth | #corner | #bezier | #bezierCorner
				(
					#corner:addKnot sps num #corner #line p
					#smooth:addKnot sps num #smooth #curve p
				)
			)
		),
		fn splinesFromPoints points_array type:#corner clr:green = --created by Merlin in "6.2.2007 13:27:34"
		(
			if classOf points_array != Array do return false
			local sps
			if classOf points_array[1] == Array --more splines than one
			then 
			(
				sps = SplineShape pos:points_array[1][1] 
				for s=1 to points_array.count do (splineFromPoints sps s points_array[s] type:type)
			)
			else 
			(
				sps = SplineShape pos:points_array[1] 
				splineFromPoints sps 1 points_array type:type
			)
			sps.render_renderable = false
			sps.render_displayRenderMesh = false
			updateShape sps
			sps.wirecolor = clr
			sps.pivot = (sps.min+sps.max)/2
			return sps
		),
		fn setAngle val =
		(
			OTD.rot_angle = val
			local angle_marker = case val of
			(
				5  :(OTD.angle_markers[1])
				10 :(OTD.angle_markers[2])
				15 :(OTD.angle_markers[3])
				25 :(OTD.angle_markers[4])
				45 :(OTD.angle_markers[5])
				90 :(OTD.angle_markers[6])
				180:(OTD.angle_markers[7])
			)
			angle_marker.text = "[ "+val as string+" ]"
			angle_marker.wirecolor = green
			--format "angle_marker:%\n" angle_marker
		),
		fn createTextControls nums pos:[0,0,0] size:1 clr:green =
		(
			OTD.angle_markers = #()
			sphere_objs = #()
			local cnt = 18
			local p = pos
			for n in nums do
			(
				cnt +=1
				p.z += size*3
				local na = "mcTransformerMarkerM_" + cnt as string
				local t = text text:(n as string) size:(size*3) pos:p dir:[0,-1,0] wirecolor:clr name:na
				t.render_renderable = false
				t.render_displayRenderMesh = false
				OTD.angle_markers += #(t)
				sphere_objs += #(sphere radius:size pos:((t.min+t.max)/2) name:("mcTransformerMarkerS_" + cnt as string) wirecolor:clr)
			) 
			hide sphere_objs
			setAngle OTD.rot_angle
			return (OTD.angle_markers + sphere_objs)
		),
		fn resizeShape sps size =
		(
			local tm = sps.transform
			local new_tm = tm * scaleMatrix [size,size,size]
			new_tm.pos = tm.pos
			sps.transform = new_tm
		),
		fn createShapeMarker type:#arrow clr:green name:(uniqueName "marker") pos:[0,0,0] size:[1,1,1] =
		(
			local points = case type of
			(
				#arrow: #
				(
					[-0.2,1.42706,0],
					[-0.2,-0.14027,0],
					[-0.950979,-0.14027,0],
					[-0.0812519,-1.42705,-2.16527e-007],
					[0.950979,-0.14027,0],
					[0.2,-0.14027,0],
					[0.2,1.42706,0],
					[-0.2,1.42706,0]
				)
				#arrowcw: #
				(
					[0.364336,0.9358,0],[0.317504,0.583026,0],[0.699567,0.402785,0],
					[0.841289,0.0730993,0],[0.776447,-0.281485,0],[0.540419,-0.511438,0],
					[0.17719,-0.584585,0],[-0.126295,-0.46535,0],[-0.280116,-0.247122,0],
					[-0.315151,-0.0166116,0],[0.180311,-0.015682,0],[-0.46935,0.749659,0],
					[-1.19129,-0.0303035,0],[-0.674101,-0.0324515,0],[-0.63834,-0.341285,0],
					[-0.461903,-0.679046,0],[-0.140909,-0.903034,0],[0.271381,-0.9358,0],
					[0.714841,-0.827787,0],[1.09664,-0.453396,0],[1.19129,0.104062,0],
					[0.916809,0.667235,0],[0.364336,0.9358,0]
				)
				#arrowccw: #
				(
					[-0.364336,0.9358,0],[-0.317504,0.583026,0],[-0.699567,0.402785,0],
					[-0.841289,0.0730993,0],[-0.776447,-0.281485,0],[-0.540419,-0.511438,0],
					[-0.17719,-0.584585,0],[0.126295,-0.46535,0],[0.280116,-0.247122,0],
					[0.315151,-0.0166116,0],[-0.180311,-0.015682,0],[0.46935,0.749659,0],
					[1.19129,-0.0303035,0],[0.674101,-0.0324515,0],[0.63834,-0.341285,0],
					[0.461903,-0.679046,0],[0.140909,-0.903034,0],[-0.271381,-0.9358,0],
					[-0.714841,-0.827787,0],[-1.09664,-0.453396,0],[-1.19129,0.104062,0],
					[-0.916809,0.667235,0],[-0.364336,0.9358,0]
				)
				#mirror: #
				(
					#([-0.196439,-1.16108,0], [-0.196439,1.16108,0], [0.203561,1.16108,0], [0.203561,-1.16108,0], [-0.196439,-1.16108,0]),
					#([1.15357,-0.899712,0], [0.207069,-0.0299847,0], [1.15357,1.00225,0], [1.15357,-0.899712,0]),
					#([-1.15357,0.843361,0], [-0.207068,-0.0263665,0], [-1.15357,-1.0586,0], [-1.15357,0.843361,0])
				)
			)
			local sps = splinesFromPoints points clr:clr
			sps.pos = pos
			sps.name = name
			if size != [1,1,1] do resizeShape sps size
			return sps
		),
		fn isPolygonSelection obj =
		(
			classOf obj == Editable_Poly \
			and (subObjectLevel == 4 or subObjectLevel == 5) \
			and (polyOp.getFaceSelection obj).numberset != 0 \
		),
		fn getPolySelectionMinMax obj type:#world debug:false =
		(
			local fsel = polyOp.getFaceSelection obj
			local bmin, bmax, verts = polyOp.getVertsUsingFace obj fsel

			for v in verts do
			(
				local p = polyOp.getVert obj v --vert pos
				if type == #local do p *= inverse obj.transform
				
				if bmin != undefined then
				(
					bmin.x = amin #(p.x, bmin.x)
					bmin.y = amin #(p.y, bmin.y)
					bmin.z = amin #(p.z, bmin.z)
					
					bmax.x = amax #(p.x, bmax.x)
					bmax.y = amax #(p.y, bmax.y)
					bmax.z = amax #(p.z, bmax.z)
				)
				else bmin = copy (bmax = p)
			)
			
			if debug do
			(
				local bb = if type == #world then #(bmin, bmax) else #(bmin*obj.transform, bmax*obj.transform)
				format "Poly:%\nBounding Box:%\n" obj bb
				point pos:bb[1] wirecolor:green
				point pos:bb[2] wirecolor:green
			)
			
			case type of --return min & max
			(
				#world: return #(bmin, bmax) 
				#local: return #(bmin*obj.transform, bmax*obj.transform)
			)
		),
		fn createPivotMarker sel clr =
		(
			--get bb from obj
			if sel.count == 0 do return false
			local mi, ma
			if sel.count == 1 and isPolygonSelection sel[1] 
			then 
			(
				mima = getPolySelectionMinMax sel[1]
				mi = mima[1]
				ma = mima[2]
			)
			else 
			(
				mi = sel.min
				ma = sel.max
			)
			local sel_pos = (sel.min + sel.max)/2
			sel_pos.z = sel.min.z
			--corner points (CW way)
			local p1=[mi.x,mi.y,mi.z] --min
			local p2=[mi.x,mi.y,ma.z]
			local p3=[ma.x,mi.y,ma.z]
			local p4=[ma.x,mi.y,mi.z]
			local p5=[mi.x,ma.y,mi.z]
			local p6=[mi.x,ma.y,ma.z]
			local p7=[ma.x,ma.y,ma.z] --max
			local p8=[ma.x,ma.y,mi.z]
			--middle points
			local p09 = ((p1+p2)/2)
			local p10 = ((p2+p3)/2)
			local p11 = ((p3+p4)/2)
			local p12 = ((p4+p1)/2)
			local p13 = ((p1+p5)/2)
			local p14 = ((p5+p6)/2)
			local p15 = ((p6+p7)/2)
			local p16 = ((p7+p8)/2)
			local p17 = ((p8+p5)/2)
			local p18 = ((p2+p6)/2)
			local p19 = ((p3+p7)/2)
			local p20 = ((p4+p8)/2)
			--side centers
			local p21 = ((p1+p3)/2)
			local p22 = ((p1+p6)/2)
			local p23 = ((p1+p8)/2)
			local p24 = ((p7+p5)/2)
			local p25 = ((p7+p2)/2)
			local p26 = ((p7+p4)/2)
			--set all transparent
	--sel.xray = true
			--calculate size of bigest sphere
			OTD.sp_size = ((distance mi ma) / 30)/2
			--drav spines around
			local sp = SplineShape pos:sel_pos name:"temp_box_marker01" 
			sp.render_renderable = false
			sp.render_displayRenderMesh = false
			--rect1
			addNewSpline sp
			addKnot sp 1 #corner #line p18
			addKnot sp 1 #corner #line p19
			addKnot sp 1 #corner #line p20
			addKnot sp 1 #corner #line p13
			addKnot sp 1 #corner #line p18
			--rect 2
			addNewSpline sp
			addKnot sp 2 #corner #line p10
			addKnot sp 2 #corner #line p12
			addKnot sp 2 #corner #line p17
			addKnot sp 2 #corner #line p15
			addKnot sp 2 #corner #line p10
			--rect 3
			addNewSpline sp
			addKnot sp 3 #corner #line p11
			addKnot sp 3 #corner #line p16
			addKnot sp 3 #corner #line p14
			addKnot sp 3 #corner #line p09
			addKnot sp 3 #corner #line p11
			--update and setup
			updateShape sp
			sp.displayRenderMesh = false --true
			--sp.thickness = 0.4
			sp.wirecolor = OTD.clr_2
			sp.steps = 0
			--create markers for rotation
			local m01 = createShapeMarker type:#arrowcw name:("mcTransformerMarkerM_01") size:OTD.sp_size pos:p09 clr:clr
			local m02 = createShapeMarker type:#arrowccw name:("mcTransformerMarkerM_02") size:OTD.sp_size pos:p10 clr:clr
			local m03 = createShapeMarker type:#arrowccw name:("mcTransformerMarkerM_03") size:OTD.sp_size pos:p11 clr:clr
			local m04 = createShapeMarker type:#arrowccw name:("mcTransformerMarkerM_04") size:OTD.sp_size pos:p12 clr:clr
			local m05 = createShapeMarker type:#arrowcw name:("mcTransformerMarkerM_05") size:OTD.sp_size pos:p13 clr:clr
			local m06 = createShapeMarker type:#arrowccw name:("mcTransformerMarkerM_06") size:OTD.sp_size pos:p14 clr:clr
			local m07 = createShapeMarker type:#arrowccw name:("mcTransformerMarkerM_07") size:OTD.sp_size pos:p15 clr:clr
			local m08 = createShapeMarker type:#arrowcw name:("mcTransformerMarkerM_08") size:OTD.sp_size pos:p16 clr:clr
			local m09 = createShapeMarker type:#arrowccw name:("mcTransformerMarkerM_09") size:OTD.sp_size pos:p17 clr:clr
			local m10 = createShapeMarker type:#arrowcw name:("mcTransformerMarkerM_10") size:OTD.sp_size pos:p18 clr:clr
			local m11 = createShapeMarker type:#arrowccw name:("mcTransformerMarkerM_11") size:OTD.sp_size pos:p19 clr:clr
			local m12 = createShapeMarker type:#arrowccw name:("mcTransformerMarkerM_12") size:OTD.sp_size pos:p20 clr:clr
			rotate m02 (quat 90 [0,1,0])
			rotate m02 (quat -90 [1,0,0])
			rotate m04 (quat -90 [0,1,0])
			rotate m04 (quat 90 [1,0,0])
			rotate m05 (quat 90 [1,0,0])
			rotate m06 (quat 180 [0,0,1])
			rotate m07 (quat -90 [0,1,0])
			rotate m07 (quat -90 [1,0,0])
			rotate m08 (quat -180 [0,0,1])
			rotate m09 (quat 90 [0,1,0])
			rotate m09 (quat 90 [1,0,0])
			rotate m10 (quat -90 [1,0,0])
			rotate m11 (quat -90 [1,0,0])
			rotate m12 (quat 90 [1,0,0])
			--create markers for mirror
			local m13 = createShapeMarker type:#mirror name:("mcTransformerMarkerM_13") size:OTD.sp_size pos:p21 clr:clr
			local m14 = createShapeMarker type:#mirror name:("mcTransformerMarkerM_14") size:OTD.sp_size pos:p22 clr:clr
			local m15 = createShapeMarker type:#mirror name:("mcTransformerMarkerM_15") size:OTD.sp_size pos:p23 clr:clr
			local m16 = createShapeMarker type:#mirror name:("mcTransformerMarkerM_16") size:OTD.sp_size pos:p24 clr:clr
			local m17 = createShapeMarker type:#mirror name:("mcTransformerMarkerM_17") size:OTD.sp_size pos:p25 clr:clr
			local m18 = createShapeMarker type:#mirror name:("mcTransformerMarkerM_18") size:OTD.sp_size pos:p26 clr:clr
			rotate m13 (quat 90 [0,0,1])
			rotate m15 (quat 90 [0,1,0])
			rotate m16 (quat 90 [0,0,1])
			rotate m17 (quat 90 [0,1,0])
			--create icons for rotation
			local s01 = sphere radius:OTD.sp_size pos:p09 name:("mcTransformerMarkerS_01") wirecolor:clr
			local s02 = sphere radius:OTD.sp_size pos:p10 name:("mcTransformerMarkerS_02") wirecolor:clr
			local s03 = sphere radius:OTD.sp_size pos:p11 name:("mcTransformerMarkerS_03") wirecolor:clr
			local s04 = sphere radius:OTD.sp_size pos:p12 name:("mcTransformerMarkerS_04") wirecolor:clr
			local s05 = sphere radius:OTD.sp_size pos:p13 name:("mcTransformerMarkerS_05") wirecolor:clr
			local s06 = sphere radius:OTD.sp_size pos:p14 name:("mcTransformerMarkerS_06") wirecolor:clr
			local s07 = sphere radius:OTD.sp_size pos:p15 name:("mcTransformerMarkerS_07") wirecolor:clr
			local s08 = sphere radius:OTD.sp_size pos:p16 name:("mcTransformerMarkerS_08") wirecolor:clr
			local s09 = sphere radius:OTD.sp_size pos:p17 name:("mcTransformerMarkerS_09") wirecolor:clr
			local s10 = sphere radius:OTD.sp_size pos:p18 name:("mcTransformerMarkerS_10") wirecolor:clr
			local s11 = sphere radius:OTD.sp_size pos:p19 name:("mcTransformerMarkerS_11") wirecolor:clr
			local s12 = sphere radius:OTD.sp_size pos:p20 name:("mcTransformerMarkerS_12") wirecolor:clr
			--create icons for mirror
			local s13 = sphere radius:OTD.sp_size pos:p21 name:("mcTransformerMarkerS_13") wirecolor:clr
			local s14 = sphere radius:OTD.sp_size pos:p22 name:("mcTransformerMarkerS_14") wirecolor:clr
			local s15 = sphere radius:OTD.sp_size pos:p23 name:("mcTransformerMarkerS_15") wirecolor:clr
			local s16 = sphere radius:OTD.sp_size pos:p24 name:("mcTransformerMarkerS_16") wirecolor:clr
			local s17 = sphere radius:OTD.sp_size pos:p25 name:("mcTransformerMarkerS_17") wirecolor:clr
			local s18 = sphere radius:OTD.sp_size pos:p26 name:("mcTransformerMarkerS_18") wirecolor:clr
			--create text for percent scale
			local tx = createTextControls #(5,10,15,25,45,90,180) pos:(p25+[0,0,OTD.sp_size*3]) size:OTD.sp_size clr:clr
			
			local markers = #(sp,m01,m02,m03,m04,m05,m06,m07,m08,m09,m10,m11,m12,m13,m14,m15,m16,m17,m18)
			local elements = #(s01,s02,s03,s04,s05,s06,s07,s08,s09,s10,s11,s12,s13,s14,s15,s16,s17,s18)
			hide elements
			OTD.temp_box_marker = group (elements+markers+tx) name:"mcTransform Object" select:false
			--add markers in to a layer
			OTD.temp_layer = LayerManager.newLayer()
			OTD.temp_layer.setName (uniqueName "Pivot Planter Tmp")
			for o in elements do OTD.temp_layer.addNode o
			OTD.temp_layer.addNode OTD.temp_box_marker
		),
		fn getObjectFromRay ray objs =
		(
			struct object_data (obj, ray)
			local od = #()
			local ray_dist    = #()
			--collect objects shoted by ray
			for o in objs do
			(
				local i = intersectRay o ray
				if i!= undefined do 
				(
					od += #(object_data o i)
					ray_dist    += #(distance ray.pos i.pos)
				)
			)
			if od.count      == 0 --if nothong hit
			then return undefined 
			else if od.count == 1 --if hit one object
			then return od[1]     --if hit more objects
			else --return the closest object to ray begin
			(
				copy_ray_dist = #()+ray_dist --4fun
				sort copy_ray_dist
				return od[findItem ray_dist copy_ray_dist[1]]
			)
		),	
		fn rotateObjects axis cv:true =
		(
			local sel = selection as array
			if sel.count == 0 do return false
			--local coord = if rdo_coord.state == 1 then "local" else "world"
			local rangle = if cv then OTD.rot_angle else -OTD.rot_angle
			
			for o in sel do
			(
				local opos = o.pos
				in coordsys world rotate o \
				(
					case axis of
					(
						#X:(quat rangle [1,0,0])
						#Y:(quat rangle [0,1,0])
						#Z:(quat rangle [0,0,1])
					)
				)
				o.pos = opos
			)
		),
		fn mirrorObjects_old axis = with undo off
		(
			local sel = selection as array
			if sel.count == 0 do return false
			for o in sel do
			(
				local opos = o.pos
				o.transform *= case axis of
				(
					#X:(matrix3 [-1,0,0] [0,1,0] [0,0,1] [0,0,0])
					#Y:(matrix3 [1,0,0] [0,-1,0] [0,0,1] [0,0,0])
					#Z:(matrix3 [1,0,0] [0,1,0] [0,0,-1] [0,0,0])
				)
				o.pos = opos
			)
		),	
		fn mirrorObjects axis =
		(
			local sel = selection as array
			if sel.count == 0 do return false
			--addModifier
			for o in sel do with redraw off
			(
				if classOf o != Editable_Poly do continue
				for v=1 to getnumverts o do
				(
					 local vert_pos = polyOp.getvert o v
					 case axis of
					 (
						#X: vert_pos[1] = o.position.x - (vert_pos[1] - o.position.x)
						#Y: vert_pos[2] = o.position.y - (vert_pos[2] - o.position.y)
						#Z: vert_pos[3] = o.position.z - (vert_pos[3] - o.position.z)
					)
					
					 polyOp.setvert o v vert_pos 
				 )
				max Modify Mode
				 local lvl = subobjectLevel
				 subobjectLevel = 4
				 polyop.flipNormals $ #{1..$.numFaces}
				subobjectLevel = lvl
				 /*
				convertToMesh o
				meshop.flipNormals o #{1..o.numFaces}
				convertToPoly o
				*/
				 update o
			)
		),
		fn rotateSelectedFaces obj axis cv:true =
		(
			local fsel = polyOp.getFaceSelection obj
			local vsel = polyOp.getVertsUsingFace obj fsel
			local rangle = if cv then -OTD.rot_angle else OTD.rot_angle
			
			--get bounding box center
			local mima = getPolySelectionMinMax obj type:#world
			local sel_center = (mima[1] + mima[2]) /2
			
			--rotate faces along axis
			for v in vsel do
			(
				local vpos = polyOp.getVert obj v
				local v1 = vpos - sel_center
				local v2 = v1 * 
				(
					case axis of
					(
						#X:(quat rangle [1,0,0])
						#Y:(quat rangle [0,1,0])
						#Z:(quat rangle [0,0,1])
					)
				)
				local v3 = v2 + sel_center
				polyOp.setVert obj v v3
			)
		),
		fn mirrorSelectedFaces obj axis =
		(
			local fsel = polyOp.getFaceSelection obj
			local vsel = polyOp.getVertsUsingFace obj fsel
			--get bounding box center
			local mima = getPolySelectionMinMax obj type:#world
			local sel_center = (mima[1] + mima[2]) /2
			--mirror verts in face selection center
			for v in vsel do
			(
				local vpos = polyOp.getvert obj v
				case axis of
				(
					#X:vpos.x = sel_center.x - (vpos.x - sel_center.x)
					#Y:vpos.y = sel_center.y - (vpos.y - sel_center.y)
					#Z:vpos.z = sel_center.z - (vpos.z - sel_center.z)
				)
				polyOp.setvert obj v vpos 
			)
			polyOp.flipNormals obj fsel
			update obj 
		),	
		fn colorizeIcon	obj clr =
		(
			if not isValidNode obj do return false
			local icon_str = "mcTransformerMarkerM_" +(filterString obj.name "_")[2]
			local icon = getNodeByName icon_str
			if not isValidNode icon do return false
			icon.wirecolor = clr
		),
		fn transformObject mname =
		(
			case mname of
			(
				"mcTransformerMarkerS_00": ()
				"mcTransformerMarkerS_01": (in coordsys world rotateObjects #z cv:false)
				"mcTransformerMarkerS_02": (in coordsys world rotateObjects #x cv:true)
				"mcTransformerMarkerS_03": (in coordsys world rotateObjects #z cv:true)
				"mcTransformerMarkerS_04": (in coordsys world rotateObjects #x cv:false)
				"mcTransformerMarkerS_05": (in coordsys world rotateObjects #y cv:true)
				"mcTransformerMarkerS_06": (in coordsys world rotateObjects #z cv:true)
				"mcTransformerMarkerS_07": (in coordsys world rotateObjects #x cv:false)
				"mcTransformerMarkerS_08": (in coordsys world rotateObjects #z cv:false)
				"mcTransformerMarkerS_09": (in coordsys world rotateObjects #x cv:true)
				"mcTransformerMarkerS_10": (in coordsys world rotateObjects #y cv:false)
				"mcTransformerMarkerS_11": (in coordsys world rotateObjects #y cv:true)
				"mcTransformerMarkerS_12": (in coordsys world rotateObjects #y cv:false)
				"mcTransformerMarkerS_13": (mirrorObjects #y)
				"mcTransformerMarkerS_14": (mirrorObjects #x)
				"mcTransformerMarkerS_15": (mirrorObjects #z)
				"mcTransformerMarkerS_16": (mirrorObjects #y)
				"mcTransformerMarkerS_17": (mirrorObjects #z)
				"mcTransformerMarkerS_18": (mirrorObjects #x)
			)
		),
		fn transformFaces obj mname =
		(
			case mname of
			(
				"mcTransformerMarkerS_00": ()
				"mcTransformerMarkerS_01": (rotateSelectedFaces obj #z cv:false)
				"mcTransformerMarkerS_02": (rotateSelectedFaces obj #x cv:true)
				"mcTransformerMarkerS_03": (rotateSelectedFaces obj #z cv:true)
				"mcTransformerMarkerS_04": (rotateSelectedFaces obj #x cv:false)
				"mcTransformerMarkerS_05": (rotateSelectedFaces obj #y cv:true)
				"mcTransformerMarkerS_06": (rotateSelectedFaces obj #z cv:true)
				"mcTransformerMarkerS_07": (rotateSelectedFaces obj #x cv:false)
				"mcTransformerMarkerS_08": (rotateSelectedFaces obj #z cv:false)
				"mcTransformerMarkerS_09": (rotateSelectedFaces obj #x cv:true)
				"mcTransformerMarkerS_10": (rotateSelectedFaces obj #y cv:false)
				"mcTransformerMarkerS_11": (rotateSelectedFaces obj #y cv:true)
				"mcTransformerMarkerS_12": (rotateSelectedFaces obj #y cv:false)
				"mcTransformerMarkerS_13": (mirrorSelectedFaces obj #y)
				"mcTransformerMarkerS_14": (mirrorSelectedFaces obj #x)
				"mcTransformerMarkerS_15": (mirrorSelectedFaces obj #z)
				"mcTransformerMarkerS_16": (mirrorSelectedFaces obj #y)
				"mcTransformerMarkerS_17": (mirrorSelectedFaces obj #z)
				"mcTransformerMarkerS_18": (mirrorSelectedFaces obj #x)
			)
		),
		fn runAction mname =
		(
			--format "picked: %\n" mname
			if isPolygonSelection OTD.sel[1] 
			then transformFaces OTD.sel[1] mname
			else transformObject mname
			
			case mname of
			(
				"mcTransformerMarkerS_19": (setAngle 5  )
				"mcTransformerMarkerS_20": (setAngle 10 )
				"mcTransformerMarkerS_21": (setAngle 15 )
				"mcTransformerMarkerS_22": (setAngle 25 )
				"mcTransformerMarkerS_23": (setAngle 45 )
				"mcTransformerMarkerS_24": (setAngle 90 )
				"mcTransformerMarkerS_25": (setAngle 180)
			)
		)
	)
	local OTF = OBJECT_TRANSFORMER_FN()
	OTD.sel     = selection

	tool mc_OBJECT_TRANSFORMER
	(
		on start do 
		(
			--print "start"
			if OTD.sel.count != 0 
			then undo off (OTF.createPivotMarker OTD.sel OTD.clr_1)
			else #stop
		)
		on freeMove do --detect closest objects in marker from mouse pointer
		(
			local obj_data = OTF.getObjectFromRay (mapScreentoWorldRay viewPoint) OTD.temp_box_marker
			--format "obj_data:%\n" obj_data
			if obj_data != undefined
			then
			(
				if isValidNode OTD.marked and obj_data.obj != OTD.marked
				then
				(
					OTF.colorizeIcon OTD.marked OTD.clr_1
					OTD.marked.radius = OTD.old_radius
					OTD.old_radius = undefined
					OTD.marked = undefined
				)
				else
				(
					OTD.marked = obj_data.obj
					if OTD.old_radius == undefined do OTD.old_radius = OTD.marked.radius
					OTD.marked.radius = OTD.sp_size --old_radius * 2
					OTF.colorizeIcon OTD.marked OTD.clr_3
				)
			)
			else if isValidNode OTD.marked do
			(
				OTF.colorizeIcon OTD.marked OTD.clr_1
				OTD.marked.radius = OTD.old_radius
				OTD.old_radius = undefined
				OTD.marked = undefined
			)
		)
		on mousePoint clickno do 
		(
			if isValidNode OTD.marked 
			then 
			(
				if keyboard.controlPressed 
				then
				(
					undo "Pivot Plant" on for o in OTD.sel do o.pivot = OTD.marked.pos --gpos[which+1]*OTD.marked.objecttransform
					OTD.aborted = 0
					#stop
				)
				else
				(
					undo "Transform Object" on OTF.runAction OTD.marked.name 
					OTD.aborted = 0
					#stop
				)
			)
			else #stop
		)
		on mouseMove clickno do ()
		on mouseAbort clickno do (OTD.aborted += 1)
		on stop do 
		(
			try undo off 
			(
				
				delete OTD.temp_box_marker
				LayerManager.deleteLayerByName OTD.temp_layer.name
				--sel.xray = false
			)
			catch()
			CompleteRedraw()
			--print "end"
		)
	)

	fn mcObjectTransformer = (if selection.count != 0 do (while OTD.aborted < 1 do startTool mc_OBJECT_TRANSFORMER) )
	mcObjectTransformer() 
)


