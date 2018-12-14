---------------------
---------------------
--                 --
--  Spline Magnet  --
--                 --
---------------------
---------------------
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~--
(--begin
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~--
-->Structure
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~--
struct splineMagnetStruct
(
	RayPnt,RayInt,PolyObj,MeshObj,CircleMarkers = #(),CirclePoints = #(),
	ActiveSpline,BreakCount = 0,ActiveCircle,PolyObjPos,ActiveKnot,
	fn inicialize =
	(
		if selection.count != 1 do return false
		PolyObj = selection[1]
		if classOf PolyObj != editable_poly do return false
		PolyObjPos = PolyObj.pos
		--print "pass"
		hide (MeshObj = snapshot PolyObj)
		return true
	),
	fn drawCircleMarker =
	(
		local sf   = getscreenScaleFactor PolyObjPos
		local cpos = RayInt.pos 
		if ActiveCircle != undefined and ActiveCircle.wirecolor == red do RayInt.pos = ActiveCircle.pos  
		ActiveCircle = circle radius:(sf/200) wirecolor:green pos:RayInt.pos dir:RayInt.dir
		CircleMarkers += #(ActiveCircle) 
	),
	fn resizeCircleMarker =
	(
		if CircleMarkers.count == 0 do return false
		local sf = getscreenScaleFactor PolyObjPos
		for i in CircleMarkers do i.radius = (sf/200)
	),
	fn circlesHilightCheck = 
	(
		if CircleMarkers.count == 0 or RayInt == undefined do return false
		local cmPos  = for i in CircleMarkers collect distance RayInt.pos i.pos
		local dist = (amin cmPos)
		ActiveCircle = CircleMarkers[findItem cmPos dist]
		--format "circle:%\tdist:%\n" circle dist
		if dist < 0.1 
		then (ActiveCircle.wirecolor = red)
		else (ActiveCircle.wirecolor = green ; ActiveCircle = undefined)
	),
	fn drawCreationLine =
	(
		if CirclePoints.count == 0 do return false
		gw.setTransform (Matrix3 1)
		gw.setColor #line (color 255 234 0)
		for s=2 to CirclePoints.count by 2 do
		(
			gw.Polyline CirclePoints[s] false
		)
		gw.enlargeUpdateRect #whole 
		gw.updateScreen()
	),
	fn createNewSpline =
	(
		--format "BreakCount:%\tRayInt:%\n" BreakCount RayInt 
		if BreakCount == 1 or RayInt == undefined do return false
		if ActiveCircle != undefined do RayInt.pos = ActiveCircle.pos
		ActiveSpline = SplineShape pos:RayInt.pos wirecolor:(color 80 255 40)
		addNewSpline ActiveSpline
		--store spline data in structure
		CirclePoints += #(ActiveSpline,#()) --data for visualize line
	),
	fn addNewKnot =
	(
		if ActiveSpline == undefined or RayInt == undefined do return false
		if ActiveCircle != undefined do RayInt.pos = ActiveCircle.pos
		ActiveKnot = addKnot ActiveSpline 1 #smooth #curve RayInt.pos -- #corner #line
		if numKnots ActiveSpline 1 > 1 do updateShape ActiveSpline
		drawCircleMarker()
		setUserProp ActiveCircle "spline" ActiveSpline.name --data for removing knots
		CirclePoints[CirclePoints.count] += #(RayInt.pos) --data for visualize line
	),
	fn removeKnot =
	(
		if CircleMarkers.count == 0 or ActiveCircle == undefined do return false
		local spline = getNodeByName (getUserProp ActiveCircle "spline")--read name from marker		
		--remove knot
		if spline != undefined do
		(
			
			for i=1 to (numKnots spline 1) where (getKnotPoint spline 1 i) == ActiveCircle.pos do
			(
				--format "knot:%\n" i
				deleteKnot spline 1 i
				exit
			)
			
			local pointsPos  = (findItem CirclePoints spline)+1
			
			if numKnots spline 1 > 1 
			then 
			(
				updateShape spline
				--clear CirclePoints Var
				deleteItem CirclePoints[pointsPos] (findItem CirclePoints[pointsPos] ActiveCircle.pos)
			)
			else 
			(
				delete spline
				ActiveSpline = undefined
				--clear CirclePoints Var
				deleteItem CirclePoints pointsPos -- delte array points
				deleteItem CirclePoints (pointsPos-1) -- delete spline name
			)
		)
		--clear marker property
		deleteItem CircleMarkers (findItem CircleMarkers ActiveCircle)
		--delete circle
		delete ActiveCircle
		ActiveCircle = undefined
	),
	fn clear =
	(
		unregisterRedrawViewsCallback resizeCircleMarker
		unregisterRedrawViewsCallback drawCreationLine
		try (delete MeshObj) catch (print "can't delete snapshot")
		try (delete CircleMarkers) catch (print "can't delete CircleMarkers")
	),
	fn errorCheck =
	(
		--format "MeshObj:%\tPolyObj:%\n" MeshObj PolyObj
		if not isValidNode MeshObj or not isValidNode PolyObj do return true 
		return false
	),
	fn collectData viewPoint =
	(
		RayPnt  = mapScreenToWorldRay viewPoint
		RayInt  = intersectRay MeshObj RayPnt
		--format "RayInt:%\n" acs.RayInt
	)
)
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~--
-->Tool
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~--
(
	local acs = splineMagnetStruct()
	
	if acs.inicialize() then
	(
		tool splineMagnetTool --prompt:"Welcome to LowPolygon Wizard Tool" numPoints:4
		( 
			on start do
			(
				--print "start tool"
				if acs.errorCheck() do #stop
			)
			on mousePoint clickno do --undo label:"create spline" on
			(
				--format "click%\n" clickno

				if altKey then --Remove Knot
				(
					--print "remove knot"
					acs.removeKnot()
				)
				else --Add Knot
				(
					--format "click:%\n" clickno
					acs.collectData viewPoint
					undo label:"create spline" on (acs.createNewSpline())
					undo label:"add vert"      on (acs.addNewKnot     ())
				)
				acs.BreakCount = 0
				#stop -- end turn
			)
			on freeMove do 
			(
				acs.collectData viewPoint
				acs.circlesHilightCheck()
			)
			on stop do
			(
		 		--print "end circle"
				acs.BreakCount += 1
		 	)
		)
		
		registerRedrawViewsCallback acs.resizeCircleMarker
		registerRedrawViewsCallback acs.drawCreationLine
		while not acs.errorCheck() and (not acs.BreakCount > 2) and (not keyboard.escPressed) do (startTool splineMagnetTool)
		acs.clear() 
	)
	else (print "Not valid poly object")
)
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~--
)--end
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~--

/*HELP*/
--1) Hold alt key for remove vertices 

/*
----------------------------------------------------------------------------------------------------------
MacroScript SplineMagnet
category:"Micra"
toolTip:"Spline Magnet"
(
	On IsEnabled Return Filters.Is_EditPoly() 
	On IsVisible Return Filters.Is_EditPoly()
	On Execute Do (fileIn (mPath()+"Spline_Magnet_v0.05.ms"))
)
----------------------------------------------------------------------------------------------------------
*/
