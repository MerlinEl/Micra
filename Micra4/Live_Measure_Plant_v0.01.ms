Global gQuickMeasure
--
struct sQuickMeasure (

	intersection_ray = undefined,
	pickRays = #(),
	drawEdges = #(),
	rect_color = mcColor.hexToRGB #2edd88,
	text_color =mcColor.hexToRGB #1e8c45,
	fn drawCross = (

		if intersection_ray == undefined do return OK
		--gw.setTransform(Matrix3 1)	
		--gw.Marker pos #diamond color:green
		--gw.resetUpdateRect()
		completeredraw()
		--gw.clearScreen (Box2 800 600 20 30 ) useBkg:false
		local GridTm = matrixFromNormal intersection_ray.dir
		GridTm.row4 = intersection_ray.pos
		gw.setTransform GridTm
		gw.setColor #line yellow
		gw.Polyline #([-10,0,0],[10,0,0]) false--Line X
		gw.Polyline #([0,-10,0],[0,10,0]) false--Line Y
					
		--draw markers, edges and texts
		gw.setTransform (Matrix3 1)
		for pp in drawEdges do (
			
			local p1 = pp[1]
			local p2 = pp[2]
			--draw marker
			gw.Marker p1 #diamond color:yellow
			--draw edges
			gw.setColor #line green
			gw.Polyline #(p1, p2) false
			--draw rectangle with text(line length)
			local dist = mcMath.roundFloat (distance p1 p2) pre:0.001
			local mid_pos = (p1 + p2)/2
			local rect_text = dist as String + " " + mcSystem.unitsType()
			local text_size = gw.getTextExtent rect_text
			local pos2d = gw.wTransPoint (mid_pos)
			local box_rect = (box2 (pos2d.x-3) (pos2d.y-text_size.y-5) (text_size.x+8) (text_size.y+6)) --(box2 x y width height )
			gw.wrect box_rect rect_color
			gw.wtext pos2d rect_text color:text_color
			--draw rect border
			gw.setColor #line yellow	
			gw.wpolyline #(
				[box_rect.left, box_rect.top, 0], 
				[box_rect.right, box_rect.top, 0], 
				[box_rect.right, box_rect.bottom, 0], 
				[box_rect.left, box_rect.bottom, 0]
			) true --close shape true - false	
		)
		
		--draw rubberband
		if pickRays.count != 0 do (
			
			gw.setColor #line green
			gw.Polyline #(pickRays[pickRays.count].pos, intersection_ray.pos) false
		)
		--gw.enlargeUpdateRect #whole
		--gw.updateScreen()
	),
	fn addRay ir addEdge = (

		if addEdge do (
			
			append drawEdges (#(pickRays[pickRays.count].pos, ir.pos))	
		)
		append pickRays ir
	),
	fn mouseTracking msg ir obj faceNum shift ctrl alt = (

		-- format "msg:% obj:%\n" msg obj
		case msg of
		(
			#mouseAbort: (

				format "finished\n"
				gQuickMeasure.stopDraw()
			)
			#freeMove: (
			
				if ir != undefined do (

					intersection_ray = ir
					--drawCross ir.pos ir.dir; format "ir pos:%\tir dir:%\n" ir.pos ir.dir
					redrawViews()
				)
			)
			#mousePoint: (

				local trgt_obj = obj
				if ir != undefined and trgt_obj != undefined do  undo off (

					if gQuickMeasure.pickRays.count == 0 then (
						
						gQuickMeasure.addRay ir false
						
					) else (
						
						gQuickMeasure.addRay ir true
					)
				)
			)
			#mouseMove: (
			)
		)
		if msg == #mouseAbort then #abort else #continue 
	),
	fn startDraw = (

		unRegisterRedrawViewsCallback drawCross
		local visible_geo_objects = for o in objects where not o.isHidden and superClassOf o == GeometryClass collect o
		registerRedrawViewsCallback drawCross
		mouseTrack trackCallback:mouseTracking on:visible_geo_objects
	),
	fn stopDraw = (

		unRegisterRedrawViewsCallback drawCross
		completeRedraw()
	)
)

gQuickMeasure = sQuickMeasure()
gQuickMeasure.startDraw()



/*
max show statistics toggle
#(#illum, #Specular, #texture, #zBuffer, #polyEdges, #Lighting)
gw.getRndLimits()
*/
--simple way

/*
fn moveObjectToPoint src_obj view_point = (

	local trgt_obj = (mcMouse.getObjectsUnderMouse())[1]
	if superClassOf trgt_obj != GeometryClass do return false
	local RayPnt  = mapScreenToWorldRay view_point
	format "RayPnt:%\n" RayPnt
	trgt_mesh_obj = snapshot trgt_obj
	local RayInt  = intersectRay trgt_mesh_obj RayPnt
	delete trgt_mesh_obj
	src_obj.pos = RayInt.pos
)
tool getAimPoint (

	on start do ( if selection.count != 1 do #stop )
	on mousePoint clickno do (

		moveObjectToPoint selection[1] viewPoint
		#stop
	)
)

undo "Object's to Surface" on
 (
			if selection.count == 1 then (--aim snap object
				
				local obj = selection[1]
				if obj == undefined do return false
				--Store Snap Settings
				local snap_settings = mcSnap.getSnapSettings()

				completeredraw()
				
				--Enable 3D Snap only in Faces
				snapMode.type = #3D
				snapMode.Active = on
				mcSnap.setItems off
				mcSnap.enabled #("Face") on
				
				--Get aim point from picked surface
                      startTool getAimPoint

				--Restore Snap Settings
				mcSnap.setSnapSettings snap_settings
			)
		)
	)
*/