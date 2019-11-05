macroScript DrawSpline
category:"BFDtools"
tooltip:"DrawSpline - Draw a spline on a surface"
buttontext:"DrawSpline"
icon:#("BFDtools-Icons",7)
(

------------------------------------------------------------------------------------------
-- Contents:
--		DrawSpline - Description: Draw a spline on a surface that optionally tracks the animated surface.
--
-- Requires:
--		jbFunctions.ms
--		BindPoints.dlm
--		MOUSTRAK.DLX (r3.x only)
------------------------------------------------------------------------------------------

if (
	if (jbFunctionsCurrentVersion == undefined OR (jbFunctionsCurrentVersion() < 11)) then (
		local str = "This script requires jbFunctions to run properly.\n\nYou can get the latest version at http://www.johnburnett.com/.\n\nWould you like to connect there now?"
		if (QueryBox str title:"Error") then ( try (ShellLaunch "http://www.johnburnett.com/" "") catch () )
		FALSE
	) else (
		jbFunctionsVersionCheck #( #("jbFunctions",11), #("bind",0), #("mouseTrack",0) )
	)
) then (

	local thisTool = BFDtool	toolName:"DrawSpline"		\
								author:"John Burnett"		\
								createDate:[6,22,2000]		\
								modifyDate:[5,21,2001]		\
								version:6					\
								defFloaterSize:[200,349]	\
								autoLoadRolloutStates:true	\
								autoLoadFloaterSize:false

	rollout DLGaboutRollout "About" (
		button DLGhelp "Help"
		label DLGAbout01 "" offset:[0,5]
		label DLGAbout02 ""
		label DLGAbout03 ""

		on DLGhelp pressed do (
			local helpStr = "Help Goes Here"
			messageBox helpStr title:"DrawSpline Help"
		)

		on DLGaboutRollout open do (
			DLGabout01.text = thisTool.toolName
			DLGabout02.text = thisTool.author
			DLGabout03.text =	(thisTool.modifyDate.x as integer) as string + "." +
								(thisTool.modifyDate.y as integer) as string + "." +
								(thisTool.modifyDate.z as integer) as string
		)

		on DLGaboutRollout close do ( thisTool.closeTool() )
	)

	rollout DLGmainRollout "Main Rollout" (
		local COLORS

		local linkToSurf
		local minDelta
		local knotType
		local lineColor
		local knotColor

		struct drawnLine (
			hitArray = #(),
			lineColor = green,
			knotColor = red,
			knotType = 1,
			linkToSurf = true
		)

		fn updateUI = (
			local R = DLGmainRollout
			R.DLGlinkToSurf.checked = linkToSurf
			R.DLGminDelta.value = minDelta
			R.DLGlineColor.color = lineColor
			R.DLGknotColor.color = knotColor
			R.DLGknotType.state = knotType
		)

		-- array of drawnLines, one for each line
		-- this is outside the SketchOnObject function now so
		-- the EraseLastPoint/Line functions can get to it
		local drawnLines

		fn DrawAllLines =
		(
			completeRedraw()

			gw.enlargeUpdateRect #whole
			gw.setTransform (matrix3 1)

			for lIdx in 1 to drawnLines.count do
			(
				local drawnLine = drawnLines[lIdx]
				local lastIr = drawnLines[lIdx].hitArray[1]

				for kIdx in 1 to drawnLines[lIdx].hitArray.count do
				(
					local ir = drawnLines[lIdx].hitArray[kIdx]

					gw.setColor #line drawnLine.lineColor
					gw.polyline #(lastIr.pos, ir.pos) false
					if drawnLine.linkToSurf then
						gw.marker ir.pos #smallHollowBox color:drawnLine.knotColor
					else
						gw.marker ir.pos #smallDiamond color:drawnLine.lineColor

					lastIr = ir
				)
			)

			gw.updateScreen()
		)

		fn EraseLastLine =
		(
			local numLines = drawnLines.count

			if (numLines > 1) then
			(
				DeleteItem drawnLines numLines
				drawnLines[(numLines-1)] = drawnLine()
			)

			DrawAllLines()
		)

		local lastPos		-- last hit position
		local firstPoint	-- in first point in a line
		fn linedrawCallback msg ir obj faceNum shift ctrl alt = (
			case msg of (
				#mouseMove: (
					if (ir != undefined) do (
						if (lastPos == undefined) do (
							lastPos = ir.pos
							firstPoint = true
							drawnLines[drawnLines.count].lineColor = lineColor
							drawnLines[drawnLines.count].knotColor = knotColor
							drawnLines[drawnLines.count].knotType = knotType
							drawnLines[drawnLines.count].linkToSurf = linkToSurf
						)
						if (abs (length (ir.pos-lastPos)) > minDelta) OR firstPoint do (
							firstPoint = false
							append drawnLines[drawnLines.count].hitArray ir

							gw.setTransform (matrix3 1)
							gw.setColor #line lineColor
							gw.enlargeUpdateRect #whole
							gw.polyline #(lastPos, ir.pos) false
							if linkToSurf then
								gw.marker ir.pos #smallHollowBox color:knotColor
							else
								gw.marker ir.pos #smallDiamond color:lineColor
							gw.updateScreen()

							lastPos = ir.pos
						)
					)
				)
				#freeMove: (
					if (lastPos != undefined) do (
						append drawnLines (drawnLine())
					)
					lastPos = undefined
				)
			)
			if msg != #mouseAbort then #continue
		)

		-- returns an array of arrays, each one containing all the
		-- hitrays recorded for a single line
		fn SketchOnObject obj = (
			lastPos = [0,0,0]		-- last hit position
			firstPoint = true		-- in first point in a line

			gw.setRndLimits #(#wireframe,#noAtts)
			mouseTrack on:obj trackCallBack:linedrawCallback

			redrawViews()

			if (drawnLines[drawnLines.count].hitArray.count == 0) do deleteItem drawnLines drawnLines.count
		)

		fn DrawPointOnObject obj = (
			local hitRecs = #()

			local d = drawnLine		lineColor:lineColor		\
									knotColor:knotColor		\
									knotType:knotType		\
									linkToSurf:linkToSurf
			append drawnLines d

			local cont = TRUE
			while cont do (
				-- Pick a viewport point
				local pnt = PickPoint()
				if (ClassOf pnt == Point3) then (
					local ir = IntersectPickPoint obj pnt

					if (ir != undefined) then (
						append d.hitArray ir
					)
				) else (
					cont = FALSE
				)
			)
		)

		-- flips the head and tail of a ray
		mapped fn flipRay aRay = (
			aRay.pos += aRay.dir
			aRay.dir = -aRay.dir
			return aRay
		)

		fn BuildDrawnLines drawnLines obj =
		(
			for lineIdx = 1 to drawnLines.count do (
				local dLine = drawnLines[lineIdx]
				local hitArray = dLine.hitArray

				if (hitArray.count >= 2) do (
					local shp = splineShape wireColor:dLine.lineColor
					shp.transform = obj.transform
					shp.name = uniqueName (obj.name + "_DrawnLine")
					addNewSpline shp
					if (dLine.knotType == 1) then
						for h in hitArray do (addKnot shp 1 #corner #line h.pos)
					else
						for h in hitArray do (addKnot shp 1 #smooth #curve h.pos)
					updateShape shp

					if dLine.linkToSurf do (
						flipRay hitArray

						local tmpObj = snapShot obj
						convertToMesh tmpObj
						local intersectArray = for h in hitArray collect (intersectRayEx tmpObj h)
						delete tmpObj

						local bMod = BindToFace()
						bindOps.AddNode bMod shp obj
						bindOps.SetNumPoints bMod ((NumKnots shp)*3)

						for i in 1 to intersectArray.count do (
							if (intersectArray[i] != undefined) then
								bindOps.Bind bMod shp (i*3-1) 1 intersectArray[i][2] 1.0
						)

						AddModifier shp bMod
					)
				)
				DLGmainRollout.DLGprogressA.value = lineIdx/drawnLines.count as float*100.0
			)
		)

		-- return true if all spacewarps are disabled
		fn noEnabledSpacewarps obj = (
			if (obj.modifiers.count != 0) then (
				local mods = obj.modifiers
				for i in mods.count to 1 by -1 do (
					if	(superClassOf mods[i] == SpacewarpModifier) AND
						(mods[i].enabled) then return false
				)
			)
			return true
		)

		group "Spline" (
			radiobuttons DLGknotType "" labels:#("Linear","Smooth")
			checkbox DLGlinkToSurf "Link Spline To Surface" checked:true align:#center
		)
		group "Line Color" (
			colorPicker DLGlineColor "Line:" fieldWidth:25
			dropdownlist DLGlineColorPresets "" items:#("Red","Green","Blue","Cyan","Magenta","Yellow","White","Black") width:14 offset:[53,-25]
			colorPicker DLGknotColor "Knot:" fieldWidth:25 offset:[75,-27]
			dropdownlist DLGknotColorPresets "" items:#("Red","Green","Blue","Cyan","Magenta","Yellow","White","Black") width:14 offset:[130,-25]
		)
		group "Sketch" (
			spinner DLGminDelta "Drawing Accuracy " range:[0.001,1000,0.1] scale:0.01 fieldWidth:40 align:#center
			button DLGeraseLastLine "Erase Last Line" enabled:false align:#left
			checkbutton DLGsketch "Sketch" width:50 offset:[45,-26]
		)
		group "Point By Point" (
			checkbutton DLGdrawPoint "Draw Point By Point" width:145
		)
		progressBar DLGprogressA color:(color 255 0 0) width:160 height:7 align:#center
		progressBar DLGprogressB color:(color 192 0 0) width:160 height:7 align:#center offset:[0,-4]

		on DLGknotType changed state do ( knotType = state; updateUI() )
		on DLGlinkToSurf changed state do ( linkToSurf = state; updateUI() )
		on DLGlineColor changed col do ( lineColor = col; updateUI() )
		on DLGlineColorPresets selected idx do ( lineColor = COLORS[idx]; updateUI() )
		on DLGknotColor changed col do ( knotColor = col; updateUI() )
		on DLGknotColorPresets selected idx do ( knotColor = COLORS[idx]; updateUI() )
		on DLGminDelta changed val do ( minDelta = val; updateUI() )

		on DLGeraseLastLine pressed do ( EraseLastLine() )

		on DLGsketch changed state do (
			if	(selection.count == 1) AND
				(objectExists selection[1]) AND
				(canConvertTo selection[1] editable_mesh) then (

				local obj = selection[1]

				if (noEnabledSpacewarps obj) then (

					DLGsketch.enabled = DLGdrawPoint.enabled = false
					DLGeraseLastLine.enabled = true
					--clear selection to avoid RC-menu when finished drawing
					clearSelection()

					drawnLines = #()
					RegisterRedrawViewsCallback DrawAllLines
					SketchOnObject obj
					UnregisterRedrawViewsCallback DrawAllLines

					BuildDrawnLines drawnLines obj

					select obj

					DLGsketch.enabled = DLGdrawPoint.enabled = true
					DLGeraseLastLine.enabled = false
					DLGprogressA.value = DLGprogressB.value = 0
				) else (
					messageBox "Please disable all spacewarps on object before painting." title:"Error"
				)
			) else (
				messageBox "Please select a single mesh object to draw on." title:"Error"
			)
			DLGsketch.checked = false
		)

		on DLGdrawPoint changed state do (
			if	(selection.count == 1) AND
				(objectExists selection[1]) AND
				(canConvertTo selection[1] editable_mesh) then (

				local obj = selection[1]

				if (noEnabledSpacewarps obj) then (

					DLGsketch.enabled = DLGdrawPoint.enabled = false
					--clear selection to avoid RC-menu when finished drawing
					clearSelection()

					drawnLines = #()
					RegisterRedrawViewsCallback DrawAllLines
					DrawPointOnObject obj
					UnregisterRedrawViewsCallback DrawAllLines

					BuildDrawnLines drawnLines obj

					select obj

					DLGsketch.enabled = DLGdrawPoint.enabled = true
					DLGeraseLastLine.enabled = false
					DLGprogressA.value = DLGprogressB.value = 0
				) else (
					messageBox "Please disable all spacewarps on object before painting." title:"Error"
				)
			) else (
				messageBox "Please select a single mesh object to draw on." title:"Error"
			)
			DLGdrawPoint.checked = false
		)

		on DLGmainRollout open do (
			COLORS = #(
			(color 255 0 0),
			(color 0 255 0),
			(color 0 0 255),
			(color 0 255 255),
			(color 255 0 255),
			(color 255 255 0),
			(color 255 255 255),
			(color 0 0 0))

			linkToSurf = true
			minDelta = 5.0
			knotType = 2
			lineColor = red
			knotColor = green

			drawnLines = #()

			updateUI()
		)
	)

	thisTool.addRoll #(DLGaboutRollout,DLGmainRollout) rolledUp:#(true,false)

	thisTool.openTool thisTool
)
)
