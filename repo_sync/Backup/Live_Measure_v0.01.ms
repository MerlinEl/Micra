--TODO > Bind measure to vertices. When object changes then measure changes too (edge or teo vertices)

--------------------------------------------------------------------------------
/* mcLiveMeasure by Orien 2019 */
--------------------------------------------------------------------------------
/*
*@Used Structures
	mcStructMan
	mcMath
*
*@Used Objects
	undefined
*
*@Usage
	undefined
*
*@Example	
	undefined
*
*/
if mcLiveMeasure != undefined do mcLiveMeasure.stop() --unregister callbacks
struct MICRA_LIVE_MEASURE_STRUCTURE	(
	
	--variables
	keep_current_selection = false,
	vsel = #(),
	esel = #(),
	bsel = #(),
	fsel = #(),
	elsel = #(),
	--functions
	fn getSource = getSourceFileName(), --get path of this script
	fn drawMeasure p1 p2 = (

		if classOf p1 != Point3 or classOf p2 != Point3 do return false 
		local dist = mcMath.roundFloat (distance p1 p2) pre:0.001
		local mid_pos = (p1 + p2)/2
		gw.setTransform(Matrix3 1)
		gw.setColor #line green 
		gw.polyline #(p1, p2) false --close shape true - false
		gw.text mid_pos (dist as String) color:yellow
		
		--Think about recalculate size of UPDATE rect ...
		/*local rect = (box2 13 47 96 97)
		gw.wrect rect red
		eRect = rect -- enlargeUpdateRect 1 pixel too small in either direction?
		eRect.right += 1
		eRect.bottom += 1
		gw.enlargeUpdateRect eRect*/

		gw.enlargeUpdateRect #whole
		gw.updateScreen()
	),
	fn measureVertices obj = (
		
		if not keep_current_selection do vsel = obj.getSelection #Vertex as Array
		if vsel.count != 2 do return false
		local p1 = polyop.getVert obj vsel[1]
		local p2 = polyop.getVert obj vsel[2]
		drawMeasure p1 p2
	),
	fn measureEdges obj = (
		
		if not keep_current_selection do esel = obj.getSelection #Edge as Array
		if esel.count < 1 do return false
		for i in esel do (
			
			local two_verts = polyop.getEdgeVerts	obj i as Array
			local p1 = polyop.getVert obj two_verts[1]
			local p2 = polyop.getVert obj two_verts[2]
			drawMeasure p1 p2
		)
	),
	fn measureBorders obj = (
		
		local esel = obj.getSelection #Edge as Array
		
		if esel.count < 1 do return false
	),
	fn measureFaces obj = (
		
		local fsel = obj.getSelection #Face as Array
	),
	fn measureElements obj = (
		
		
	),
	fn measureCallbacks = (
		
		local sel = selection as array 
		if sel.count == 0 do return false
		if sel.count > 1 then ( --if many object selecteds
			
			--format "object multislection\n"
			
		) else ( --if single object selected
			
			--format "object single selection\n"
			
			local obj = sel[1]
			if classOf obj != Editable_Poly do return false
			case subobjectlevel of (
			
				1: measureVertices obj
				2: measureEdges obj
				3: measureBorders obj
				4: measureFaces obj
				5: measureElements obj
			)
		)
	),
	fn start = (
	
		unRegisterRedrawViewsCallback mcLiveMeasure.measureCallbacks
		registerRedrawViewsCallback mcLiveMeasure.measureCallbacks
	),
	fn stop = (
		
		unRegisterRedrawViewsCallback mcLiveMeasure.measureCallbacks
	)
	/*<end>*/
)	
--create instance
Global mcLiveMeasure = mcStructMan.instanceStructure MICRA_LIVE_MEASURE_STRUCTURE "mcLiveMeasure"
Global mcLiveMeasureDialog
if mcLiveMeasureDialog != undefined do DestroyDialog mcLiveMeasureDialog
rollout mcLiveMeasureDialog "VPM:" width:112 height:116 (
	
	checkbox chk_keep_current "Keep Current" pos:[12,44] width:92 height:16
	GroupBox grp1 "Setup:" pos:[4,4] width:104 height:108
	checkbox chk_auto_measure "Auto Measure" pos:[12,24] width:92 height:16
	on chk_keep_current changed state do (
	
		mcLiveMeasure.keep_current_selection = state
	)
	on chk_auto_measure changed state do (
		
		if state then mcLiveMeasure.start() else mcLiveMeasure.stop()
		CompleteRedraw()
	)
)
createDialog mcLiveMeasureDialog
/*

mcLiveMeasure.stop()
*/



/*
rect = (box2 13 47 96 97)
gw.wrect rect red
eRect = rect -- enlargeUpdateRect 1 pixel too small in either direction?
eRect.right += 1
eRect.bottom += 1


(
	local local_bbox = nodeLocalBoundingBox $ --(required AvGuard Extension)
	local tm = $.transform
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
	local points = #(p0, p1, p2, p3, p4, p5, p6)
	local colors = #(red, green, blue, yellow, gray, white, brown)
	global geo_points = #()
	for i=1 to points.count do append geo_points (point pos:(points[i]*$.transform) wirecolor:colors[i])
)

delete geo_points
*/

