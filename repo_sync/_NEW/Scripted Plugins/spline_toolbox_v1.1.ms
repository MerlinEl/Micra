-------------------------
-------------------------
/*
	Spline Toolbox v1.1 (written in 06/2012)
	It is 6 tools in one interface :
	- Spline select tool (it allows dot selection, random and by angle)
	- Outline extended (it's the basic outline tool with more options) / Updated (realtime feedback ,keeps original selection and mousetool creation)
	- 2-Tangents circle allows to create a circle relative to two tangents 
		(usefull in design/architecture when trying to place precisely a circle in a corner)
	- Divide Spl. Segs by percent allows to divide one or multiple segments by percent 
		and choosing between 2 interpolation methods "path" or "length" that can give different results only in curved splines
	- Constrain Spl. Verts, working in vertex suboject mode, just constrains the vertex along the same spline
		(it works with any vertex type but with the bezier type, the tangents don't follow exactly the curve, maybe for a next version...)
	- Spline segments infos gives realtime infos about the selected segments and total spline length
*/
-------------------------
-------------------------

fn isSpline obj = classof obj == splineshape or classof obj == line
	
fn hasSelection obj =
(
	if (for i = 1 to numsplines $ where (a = getsegselection $ i).count > 0 collect a).count > 0 then true else false
)
	
rollout SplineSelectTool "Spline Select Tool" width:162 height:308
(
	button dotVerts "Select every n-vertices" pos:[10,46] width:141 height:27
	button dotSegs "Select every n-segments" pos:[10,77] width:141 height:27
	spinner nspace "n-Space" pos:[69,23] width:82 height:16 type:#integer
	spinner percentSel "Percent selected" pos:[35,139] width:117 height:16 range:[0,100,0] type:#integer
	button RandVert "Random vert. selection" pos:[10,160] width:141 height:27
	button RandSegs "Random seg. selection" pos:[10,191] width:141 height:27
	spinner degmin "min" pos:[21,276] width:56 height:16 range:[0,180,0] type:#integer
	spinner degmax "max" pos:[92,276] width:56 height:16 range:[0,180,180] type:#integer
	button AnVerts "Select vert. by angle" pos:[10,244] width:141 height:27
	groupBox grp1 "Dot Selection" pos:[6,6] width:151 height:104
	groupBox grp2 "Random selection" pos:[6,120] width:150 height:103
	groupBox grp3 "By Angle Selection" pos:[7,228] width:149 height:72
	
	fn dotVertSelect dotSpace splID knotID nKnots =
	(
		knotsArr = #()
		for i = knotID to nKnots by dotSpace do append knotsArr i
		setknotselection $ splID knotsArr
	)

	fn dotSegSelect dotSpace splID segID nSegs =
	(
		segArr = #()
		for i = segID to nSegs by dotSpace do append segArr i
		setsegselection $ splID segArr
	)

	fn randVertSelect splID nKnots prc = 
	(
		selPrc = nKnots * prc / 100
		rndVerts = #()
		if selPrc > 0 do 
		(
			for i = 1 to selPrc do 
			(
				append rndVerts (random 1 nKnots)
			)
			setknotselection $ splID rndVerts
		)
	)	

	fn randSegSelect splID nSegs prc = 
	(
		selPrc = nSegs * prc / 100
		rndSegs = #()
		if selPrc > 0 do 
		(
			for i = 1 to selPrc do 
			(
				append rndSegs (random 1 nSegs)
			)
			setsegselection $ splID rndSegs
		)
	)	

	fn selVertsbyAngle splID degMin degMax =
	(
		TabAngle = #()
		vertArr = #()
		for i = 1 to numknots $ splID do
		(
			if i == 1 then a = numknots $ splID else a = i-1
			b = i
			if i == numknots $ splID then c = 1 else c = i+1
			a = getknotpoint $ splID a
			b = getknotpoint $ splID b
			c = getknotpoint $ splID c
			v1 = a-b
			v2 = c-b
			N1 = normalize V1 
			N2 = normalize V2 
			An = acos (dot N1 N2)
			TabAngle[i] = An
		)
		id = 0
		for j in TabAngle do 
		( 
			id += 1
			if id > 1 and id < numknots $ splID do
			(
				if j < degMax and j > degMin  do append vertArr id 
			)
		)
		setknotselection $ splID vertArr
	)
	on dotVerts pressed  do
	(
		if isSpline $ do
		(
			for i = 1 to numsplines $ do if (knotSel = getknotselection $ i).count > 0 do dotVertSelect nspace.value i knotSel[1] (numknots $ i)
		)
	)
	on dotSegs pressed  do
	(
		if isSpline $ do
		(
			for i = 1 to numsplines $ do if (segSel = getsegselection $ i).count > 0 do dotSegSelect nspace.value i segSel[1] (numsegments $ i)
		)
	)
	on RandVert pressed  do
	(
		if isSpline $ do
		(
			for i = 1 to numsplines $ do if (getknotselection $ i).count > 0 do randVertSelect i (numknots $ i) percentSel.value
		)
	)
	on RandSegs pressed  do
	(
		if isSpline $ do
		(
			for i = 1 to numsplines $ do if (getsegselection $ i).count > 0 do randSegSelect i (numsegments $ i) percentSel.value
		)
	)
	on AnVerts pressed  do
	(
		if isSpline $ do
		(
			for i = 1 to numsplines $ do if (getknotselection $ i).count > 0 do selVertsbyAngle i degmin.value degmax.value
		)
	)
)


rollout two_Tangents_circle "2-Tangents_circle" width:162 height:140
(
	spinner spn1 "Radius" pos:[26,28] width:120 height:16 type:#worldunits
	label lbl1 "Enter the circle radius :" pos:[18,8] width:131 height:18
	label lbl2 "Select 2 adjacent segments in a spline to have an angle and click the ''create'' button" pos:[15,52] width:140 height:44
	button create "Create circle" pos:[16,97] width:134 height:27
	
	fn centerCircle r a b c =
	(
	v1 = a-b
	v2 = c-b
	N1 = normalize V1 
	N2 = normalize V2 
	N3 = normalize (N1 + N2)
	An = ((acos (dot N1 N2))/2.0)
	c = r / (sin An)
	center = ((N3 * c) + b)
	)
	
	on create pressed  do
	(
		if isSpline $ do
		(
			seg = #()
			splineID = #()
			segID = #()
			for i = 1 to numsplines $ do if (seg = getsegselection $ i).count == 2 do (append splineID i; append segID seg) 
			if segID.count == 0 do append segID #()
			if splineID.count > 1 or segID[1].count != 2 or (segID[1][1]+1) != segID[1][2] then messagebox "Select 2 adjacent segments" else
			(
				a = getknotpoint $ splineID[1] segID[1][1]
				b = getknotpoint $ splineID[1] segID[1][2]
				c = getknotpoint $ splineID[1] (segID[1][2]+1)
				center = centerCircle spn1.value a b c
				circle radius:(spn1.value) pos:center
			)
		)
	)
)

rollout Outline_Ext "Outline_Extended" width:162 height:169
(
	radiobuttons rdo1 "Selection level :" pos:[10,15] width:144 height:30 labels:#("Segment", "Spline") columns:2
	spinner spn1 "Offset value : " pos:[17,64] width:135 height:16 range:[-10000,10000,0] type:#worldunits
	checkbutton apply "Outline Mode" pos:[10,106] width:142 height:22
	checkbox chk1 "Copy" pos:[20,85] width:52 height:15 checked:true
	checkbox chk2 "Center" pos:[83,85] width:52 height:15 checked:true
	button UndoBtn "Undo Outline" pos:[10,135] width:142 height:22 toolTip:"Undo only the last operation"
	local init = false, undoArr = #(), segSelection = #(), originalSelection = #(), CloseArr = #()
	
	fn createTempOffset dist =
	(
		with redraw off 
		(
			hide (copySpl = copy $)
			local ns = numsplines $
			for i = 1 to ns do (if isclosed $ i == false do close copySpl i)	
			
			applyOffset copySpl dist
			
			while numsplines copySpl > numsplines $ do
			(
				deletespline copySpl 1
				updateshape copySpl
			)
			for i = 1 to (numsplines $) do (setsegselection copySpl i  ((#{1..(numSegments copySpl i)} - ((getsegselection $ i) as bitarray)) as array))
			updateshape copySpl
			copySpl
		)
	)
	
	fn createSegOffset tmp =
	(
		local ns = numsplines tmp
		with redraw off
		for i = 1 to ns do
		(
			splID = addnewSpline $
			
			for j = 1 to numknots tmp i do
			(
				KnotType = (getKnotType tmp i j)
				if j == (numknots tmp i) then SegmentType = (getSegmentType tmp i (j-1)) else SegmentType = (getSegmentType tmp i j)
				PointPos = (getknotpoint tmp i j)
				inVec = (getinvec tmp i j)
				outVec = (getoutvec tmp i j)
				addknot $ splID KnotType SegmentType PointPos inVec outVec
			)
			updateshape $
			if isclosed tmp i then close $ splID else reverse $ splID
			for i = 1 to numsplines $ do setsegselection $ i #()
			updateshape $
			append segSelection #(splID, getsegselection tmp i)
		)
	)
	
	fn initSpline = 
	(
		free originalSelection
		free CloseArr
		free undoArr
		if isSpline $ do if hasSelection $ and subobjectlevel == 2 do
		(
			apply.checked = true
			ns = numsplines $
			for i = 1 to ns do 
			(
				append undoArr (
					for j = 1 to numknots $ i collect 
					(
						if j == (numknots $ i) then segtype = (getSegmentType $ i (j-1)) else segtype = (getSegmentType $ i j)
						#(getKnotType $ i j, segtype, getknotpoint $ i j, getinvec $ i j, getoutvec $ i j)
					)
				)
				append originalSelection (getsegselection $ i)
				append CloseArr (isclosed $ i)
			)
			init = true
		)
	)
	
	fn applyOutline =
	(
		if isSpline $ do if hasSelection $ and subobjectlevel == 2 do
		(
			with redraw off
			undo off
			(
				
				local offset = spn1.value
				local doCopy = chk1.checked
				local center = chk2.checked
				if center == true do offset /= 2.0
				sbLevel = rdo1.state
				
				if sbLevel == 2 do
				(
					for i = 1 to numsplines $ where (getsegselection $ i).count > 0 do setsegselection $ i (#{1..(numsegments $ i)} as array)
				)
				
				if center == true then 
				(
					obj1 = createTempOffset offset 
					obj2 = createTempOffset (-offset)
					createSegOffset obj1
					createSegOffset obj2
				) 
				else 
				(
					obj1 = createTempOffset offset
					createSegOffset obj1
				)
				
				for i in segSelection do (setsegselection $ i[1] i[2] keep:true)
				
				if doCopy == false do 
				(
					for i = 1 to originalSelection.count do (setsegselection $ i originalSelection[i] keep:true)
				)
				updateshape $
				max delete
				if doCopy == true do 
				(
					for i = 1 to originalSelection.count do (setsegselection $ i originalSelection[i] keep:true)
				)
				
				delete obj1
				if center == true do if isvalidnode obj2 do delete obj2
				free segSelection
			)
		)
	)
	
	fn resetSpl =
	(
		with redraw off
		(
			while numsplines $ > 0 do deletespline $ 1
			for i = 1 to undoArr.count do
			(
				splID = addnewSpline $
				for j in undoArr[i] do
				(
					addknot $ splID j[1] j[2] j[3] j[4] j[5]
				)
				if CloseArr[i] == true do close $ splID
				updateshape $
			)
			for s = 1 to originalSelection.count do (setsegselection $ s originalSelection[s] keep:true)
			updateshape $
		)
	)
	
	tool MouseRClick
	(
		local p
		on mousePoint arg do 
		(
			if arg == 1 do  p = worldPoint
			if arg == 2 do #stop
		)
		on mouseMove arg do 
		(
			if arg == 2 do 
			(
				spn1.value = (p.y - worldPoint.y)
				with redraw off
				(
					if init == false then initSpline() else resetSpl()
					applyOutline()
				)
			)
		)
		on mouseAbort arg do (apply.checked = false; spn1.value = 0.0; init = false)
	)
	
	on Outline_Ext close do
	(
		free CloseArr
		free undoArr
		free segSelection
		free originalSelection
		gc()
	)
	
	on chk1 changed state do
	(
		if init == true do (resetSpl(); applyOutline())
	)
	
	on chk2 changed state do
	(
		if init == true do (resetSpl(); applyOutline())
	)
	
	on rdo1 changed state do
	(
		if init == true do (resetSpl(); applyOutline())
	)
	
	on spn1 changed val do
	(
		with redraw off
		(
			if init == false then initSpline() else resetSpl()
			applyOutline()
		)
	)
	
	on apply changed state do
	(
		if state == false then
		(
			stopTool MouseRClick
			spn1.value = 0.0
			init = false
		)
		else
		(
			starttool MouseRClick
		)
	)
	
	on UndoBtn pressed do
	(
		if isSpline $ and undoArr.count > 0 do
		(
			stopTool MouseRClick
			resetSpl()
			spn1.value = 0.0
			apply.checked = false
			free originalSelection
			init = false
			free CloseArr
			free undoArr
			gc()
		)
	)
)

rollout DivideSplSeg "Divide Spl. Segs by percent" width:162 height:130
(
	spinner spn1 "Subdivision % " pos:[25,10] width:116 height:16 type:#float
	checkbutton ckb1 "Subdivision Mode" pos:[19,66] width:123 height:24 toolTip:"Works only with splines in segment sub-object"
	button btn1 "Undo" pos:[19,95] width:123 height:24 tooltip:"Undo only the last operation"
	radioButtons rdo1 "" pos:[22,45] width:119 height:16 labels:#("Path", "Length") columns:2
	label lbl1 "Interpolation Method :" pos:[27,31] width:108 height:12
	
	local originalSelection = #(), CloseArr = #(), splArr = #()

	fn copySpl = 
	(
		free originalSelection
		free CloseArr
		free splArr
		ns = numsplines $
		for i = 1 to ns do 
		(
			append splArr (
				for j = 1 to numknots $ i collect 
				(
					if j == (numknots $ i) then segtype = (getSegmentType $ i (j-1)) else segtype = (getSegmentType $ i j)
					#(getKnotType $ i j, segtype, getknotpoint $ i j, getinvec $ i j, getoutvec $ i j)
				)
			)
			append originalSelection (getsegselection $ i)
			append CloseArr (isclosed $ i)
		)
	)

	fn resetSpl =
	(
		with redraw off
		(
			while numsplines $ > 0 do deletespline $ 1
			for i = 1 to splArr.count do
			(
				splID = addnewSpline $
				for j in splArr[i] do
				(
					addknot $ splID j[1] j[2] j[3] j[4] j[5]
				)
				if CloseArr[i] == true do close $ splID
				updateshape $
			)
			for s = 1 to originalSelection.count do (setsegselection $ s originalSelection[s] keep:true)
			updateshape $
		)
	)
	
	fn subSpline prct =
	(
		local addP, pathparam
		local segsel = for i = 1 to numsplines $ collect getsegselection $ i
		for i in segsel do for j = 1 to i.count do i[j] += (j-1)
		if rdo1.state == 1 then pathparam = true else pathparam = false
		
		for i = 1 to segsel.count do 
		(	
			for j = 1 to segsel[i].count do
			(
				splID = i
				segId = segsel[i][j]
				p = interpBezier3D $ splID segId prct pathParam:pathparam
				np = nearestPathParam $ splID p
				numSegs = numSegments $ splID
				targetSeg = (numSegs * np) as integer + 1
				segParam = np * numSegs - targetSeg + 1
				refineSegment $ i targetSeg segParam 
			)
		)
		updateshape $
	)
	
	on DivideSplSeg close do
	(
		free originalSelection
		free CloseArr
		free splArr
	)
	
	on spn1 changed val do
	(
		if ckb1.state == true do if isSpline $ do 
			if hasSelection $ and subobjectlevel == 2 do (resetSpl(); subSpline (val/100.0))
	)
	
	on rdo1 changed state do
	(
		if ckb1.state == true do if isSpline $ do 
			if hasSelection $ and subobjectlevel == 2 do (resetSpl(); subSpline (spn1.value/100.0))
	)
	
	on ckb1 changed state do
	(
		if isSpline $ do if hasSelection $ and subobjectlevel == 2 do
			if state == true then copySpl() else spn1.value = 0.0
	)
	
	on btn1 pressed do
	(
		spn1.value = 0.0
		ckb1.state = false
		resetSpl()
		free originalSelection
		free CloseArr
		free splArr
	)
)
	 
rollout ConstrainSplVerts "Constrain Spl. Verts" width:162 height:63
(
	checkButton ckb1 "Constrain Spl. Verts Mode" pos:[9,15] width:144 height:33 toolTip:"Works only with splines in vertex sub-object"
	
	local cSpl
	on ckb1 changed state do
	(
		if state == true and isSpline $ and subobjectlevel == 1 then
		(
			deleteAllChangeHandlers id:#geoChange
			hide (cSpl = copy $)
			
			when geometry $ changes id:#geoChange do
			(
				if isSpline $ and subobjectlevel == 1 then
				(
					for i = 1 to numsplines $ do for j in (getKnotSelection $ i) do
					(
						pos = getknotpoint $ i j
						param = (nearestPathParam cSpl i pos)
						newpos = pathInterp cSpl i param
						setknotpoint $ i j newpos
						type = getKnotType $ i j
						setKnotType $ i j #smooth
						updateshape $
						setKnotType $ i j type
						updateshape $
					)
				)
				else (subobjectlevel = 1)
			)
		)
		else (deleteAllChangeHandlers id:#geoChange; ckb1.state = false; if isvalidnode cSpl do delete cSpl)
	)
)

rollout SplineSegInfo "Spline Segments Infos" width:162 height:125
(
	checkbutton ckb1 "Show spline segments infos" pos:[17,14] width:146 height:31 checked:false
	label lbl1 "Segments selected : " pos:[8,55] width:165 height:16
	label lbl2 "Segments length : " pos:[8,74] width:165 height:16
	label lbl3 "Total spl. length : " pos:[8,93] width:165 height:16
	
	fn showInfos =
	(
		lengthArr = #()
		selectionArr = #()
		totalSeg = 0
		totalLen = 0
		splineLength = 0

		for i = 1 to numsplines $ do
		(
			append lengthArr (getSegLengths $ i)
			sel = getsegselection $ i
			if sel.count > 0 do append selectionArr #(i, sel)
		)

		for i in lengthArr do splineLength += i[i.count]

		for i in selectionArr do 
		(
			totalSeg += i[2].count
			numseg = (numsegments $ i[1])
			for j in i[2] do totalLen += (lengthArr[i[1]][j + numseg])
		)
		lbl1.text = ("Segments selected : " + totalSeg as string)
		lbl2.text = ("Segments length : " + units.formatValue (totalLen))
		lbl3.text = ("Total spl. length : "+ units.formatValue (splineLength))
	)
	
	fn clearInfos =
	(
		deleteAllChangeHandlers id:#changesel
		deleteAllChangeHandlers id:#changegeo
		deleteAllChangeHandlers id:#deletedObj
		lbl1.text = "Segments selected : "
		lbl2.text = "Segments length : "
		lbl3.text = "Total spl. length : "
	)
	
	on ckb1 changed state do
	(
		if state == true then
		(
			when select $ changes id:#changesel do (if isSpline $ do showInfos())
			when geometry $ changes id:#changegeo do (if isSpline $ do showInfos())
			when $ deleted id:#deletedObj do (ckb1.checked = false; clearInfos())
			if isSpline $ do showInfos()
		)
		else 
		(
			clearInfos()
		)
	)
)
theNewFloater = newRolloutFloater "Spline Toolbox v1.1" 180 560
addRollout SplineSelectTool theNewFloater rolledUp:false
addRollout Outline_Ext theNewFloater rolledUp:true
addRollout two_Tangents_circle theNewFloater rolledUp:true
addRollout DivideSplSeg theNewFloater rolledUp:true
addRollout ConstrainSplVerts theNewFloater rolledUp:true
addRollout SplineSegInfo theNewFloater rolledUp:false
