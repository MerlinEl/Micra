
offsetY	= 20

globalZero = Point3 0 0 0

globalFirstHit = TRUE

globalDistNode = #(undefined,undefined,undefined)
globalDistNodeMirror = #(undefined,undefined,undefined)

globalHairCopy = #(undefined,undefined,undefined)
globalHairCopyMirror = #(undefined,undefined,undefined)

globalLastNode = #(undefined,undefined,undefined)
globalLastNodeMirror = #(undefined,undefined,undefined)
globalLastPos = #(undefined,undefined,undefined)
globalLastNormal = #(undefined,undefined,undefined)
globalLastPosMirror = #(undefined,undefined,undefined)
globalLastNormalMirror = #(undefined,undefined,undefined)
globalLastStr = 1
globalLastRadius = 1

globalUseDist = #(FALSE,FALSE,FALSE)

globalHairPos = #(globalZero,globalZero,globalZero )
globalHairNormal = #(globalZero,globalZero,globalZero)

globalHairPosMirror = #(globalZero,globalZero,globalZero )
globalHairNormalMirror = #(globalZero,globalZero,globalZero)
globalAlignNormal = 3
globalAlignStroke = 1

globalScaleOption = 1
globalScaleNormal = TRUE
globalScaleStroke = TRUE
globalScaleStrength = TRUE
globalScaleX = 1.0
globalScaleY = 1.0
globalScaleZ = 1.0

globalSourceNode = #()

globalInstance = FALSE

matrix3 fn GetMatrix hairPos mousePos normal  str radius =
(
	tm = matrix3 1 
	strNormal = 1
	normalBase = 1
	strengthBase = 1
	strokeBase = 1
	strStroke = 1
	strStrength = 1
	
	xvec = Point3 1 0 0
  	yvec = Point3 0 1 0
	zvec = Point3 0 0 1
   	mouseVec = Point3 1 0 0
   
   	zvec = normalize normal 
   
	mouseVec = mousePos - hairPos  

	mouseVec = normalize mouseVec
   
	xvec = cross mouseVec zvec 
	xvec = Normalize xvec
   
	yvec = cross  zvec xvec
	yvec = normalize yvec
			
	if (globalScaleOption == 1) then
		(		
		)
	else if (globalScaleOption == 2) then
		(
		str = globalScaleX
		if (globalScaleY > str) then str = globalScaleY
		if (globalScaleZ > str) then str = globalScaleZ
		str = Length(mousePos - hairPos)/str
		xvec = xvec * str
		yvec = yvec * str
		zvec = zvec * str
		)
	else if (globalScaleOption == 3) then
		(
		if (globalScaleNormal) then
			(
			strNormal = str*thePainterInterface.normalScale
			if (globalAlignNormal == 1) then
				normalBase = globalScaleX
			else if (globalAlignNormal == 2) then
				normalBase = globalScaleY
			else if (globalAlignNormal == 3) then
				normalBase = globalScaleZ
				
			strNormal = strNormal/normalBase
			zvec = zvec * strNormal
			)
					
		if (globalScaleStroke) then
			(
			strStroke = Length(mousePos - hairPos)
			if (globalAlignStroke == 1) then
				strokeBase = globalScaleX
			else if (globalAlignStroke == 2) then
				strokeBase = globalScaleY
			else if (globalAlignStroke == 3) then
				strokeBase = globalScaleZ
			
			strStroke = strStroke/strokeBase
			yvec = yvec * strStroke
			)				
					
		if (globalScaleStrength) then
			(
			strStrength = radius
			if (globalAlignStroke == 1)then
				(
				if (globalAlignNormal == 2)then
					strengthBase = globalScaleZ
				else if (globalAlignNormal == 3)then
					strengthBase = globalScaleY
				)
			else if (globalAlignStroke == 2)then
				(
				if (globalAlignNormal == 1)then
					strengthBase = globalScaleZ
				else if (globalAlignNormal == 3)then
					strengthBase = globalScaleX
				)				
			if (globalAlignStroke == 3)then
				(
				if (globalAlignNormal == 1)then
					strengthBase = globalScaleY
				else if (globalAlignNormal == 2)then
					strengthBase = globalScaleX
				)						
			strStrength = strStrength/strengthBase
			xvec = xvec * strStrength 
			)						


		)

	if (globalAlignNormal == 1) then
		(
		tm.row3 = xvec
		if (globalAlignStroke == 2) then
			(
	   		tm.row1 = yvec
			tm.row2 = zvec					
			)
		else
			( 
	   		tm.row1 = zvec
			tm.row2 = yvec					
			)				
				
		)
	else if (globalAlignNormal == 2) then
		(
		tm.row3 = yvec
		if (globalAlignStroke == 1) then
			(
	   		tm.row1 = xvec
			tm.row2 = zvec					
			)
		else
			( 
	   		tm.row1 = zvec
			tm.row2 = xvec	
			)			
		)
	else 
		(
		tm.row3 = zvec
		if (globalAlignStroke == 1) then
			(
   			tm.row1 = yvec
			tm.row2 = xvec	
			)
		else
			( 
			tm.row1 = xvec
			tm.row2 = yvec	
			)
		)
				
	tm.row4 = hairPos


	return tm
)

fn StartStroke = 
(
	globalFirstHit = TRUE
	thePainterInterface.undoStart()
)

fn PlaceStroke = 
(

  localHit = Point3 0 0 0
  localNormal = Point3 0 0 0
  worldHit = Point3 0 0 0
  worldNormal = Point3 0 0 0
  str = 0.0f
  radius = 0.0f
  if (globalFirstHit == TRUE) then
  	(
	globalFirstHit = FALSE	
	undo on
		(
		for i = 1 to 3 do
			(
			if (globalUseDist[i]) then
				(
				if (globalInstance) then globalHairCopy[i] = instance globalDistNode[i] 
				else globalHairCopy[i] = copy globalDistNode[i] 
			
  				thePainterInterface.getHitPointData &localHit &localNormal &worldHit &worldNormal &radius &str 0
	
				globalHairPos[i] = worldHit
				globalHairNormal[i] = worldNormal

			   	if (thePainterInterface.mirrorEnable == TRUE) then
					(
					if (globalInstance) then globalHairCopyMirror[i] = instance globalDistNode[i]
					else globalHairCopyMirror[i] = copy globalDistNode[i]
					thePainterInterface.getMirrorHitPointData &localHit &localNormal &worldHit &worldNormal 0
					globalHairPosMirror[i]	= worldHit	
					globalHairNormalMirror[i] = worldNormal
					)	
				)
				
			)
		)
	
	)
	
 --retrieves the last hit point
  thePainterInterface.getHitPointData &localHit &localNormal &worldHit &worldNormal &radius &str 0
  
--This gets whether the stroke point actually hit the mesh
--Since the user can paint off the mesh 
--Right now we ignore this and create a cylinder regardless if they are painting on the mesh or not		
   hit = thePainterInterface.getIsHit -1
     
  thePainterInterface.offMeshHitPos  = globalHairPos[1]

  for i = 1 to 3 do
  		(
		if (globalUseDist[i]) then
			(
			
  			globalScaleX = abs (globalDistNode[i].max[1] - globalDistNode[i].pos[1])
		  	globalScaleY = abs (globalDistNode[i].max[2] - globalDistNode[i].pos[2])
  			globalScaleZ = abs (globalDistNode[i].max[3] - globalDistNode[i].pos[3])

  			minScaleX = abs (globalDistNode[i].min[1] - globalDistNode[i].pos[1])
		  	minScaleY = abs (globalDistNode[i].min[2] - globalDistNode[i].pos[2])
  			minScaleZ = abs (globalDistNode[i].min[3] - globalDistNode[i].pos[3])
			
			if (minScaleX > globalScaleX) then globalScaleX = minScaleX
			if (minScaleY > globalScaleY) then globalScaleY = minScaleY
			if (minScaleZ > globalScaleZ) then globalScaleZ = minScaleZ
			
		   	tm = matrix3 1 
			
   			globalHairCopy[i].transform = GetMatrix globalHairPos[i] worldHit globalHairNormal[i] str radius
			
--checks if the mirror is on, if so make sure to get that point and proces it also   
   			if (thePainterInterface.mirrorEnable == TRUE) then
				(
-- Put mirror stuff here
				thePainterInterface.getMirrorHitPointData &localHit &localNormal &worldHit &worldNormal 0
				globalHairCopyMirror[i].transform = GetMatrix globalHairPosMirror[i] worldHit globalHairNormalMirror[i] str radius
				
				)	
			)
		)
	


)

fn PaintStroke = 
(


  localHit = Point3 0 0 0
  localNormal = Point3 0 0 0
  worldHit = Point3 0 0 0
  mirrorWorldHit = Point3 0 0 0
  worldNormal = Point3 0 0 0
  str = 0.0f
  radius = 0.0f

  for i = 1 to 3 do
  	(
	if (globalUseDist[i]) then
		(
		if (globalInstance) then globalHairCopy[i] = instance globalDistNode[i] 
		else globalHairCopy[i] = copy globalDistNode[i] 
			
  		thePainterInterface.getHitPointData &localHit &localNormal &worldHit &worldNormal &radius &str 0
	
		globalHairPos[i] = worldHit
		globalHairNormal[i] = worldNormal

	   	if (thePainterInterface.mirrorEnable == TRUE) then
			(
			if (globalInstance) then globalHairCopyMirror[i] = instance globalDistNode[i]
			else globalHairCopyMirror[i] = copy globalDistNode[i]
			thePainterInterface.getMirrorHitPointData &localHit &localNormal &worldHit &worldNormal 0
			globalHairPosMirror[i]	= worldHit	
			globalHairNormalMirror[i] = worldNormal
			)	
		)
	)
	
 --retrieves the last hit point
  thePainterInterface.getHitPointData &localHit &localNormal &worldHit &worldNormal &radius &str 0
  
--This gets whether the stroke point actually hit the mesh
--Since the user can paint off the mesh 
--Right now we ignore this and create a cylinder regardless if they are painting on the mesh or not		
   hit = thePainterInterface.getIsHit -1
     
  thePainterInterface.offMeshHitPos  = globalHairPos[1]

  for i = 1 to 3 do
  		(
		if (globalUseDist[i]) then
			(
			
  			globalScaleX = abs (globalDistNode[i].max[1] - globalDistNode[i].pos[1])
		  	globalScaleY = abs (globalDistNode[i].max[2] - globalDistNode[i].pos[2])
  			globalScaleZ = abs (globalDistNode[i].max[3] - globalDistNode[i].pos[3])

  			minScaleX = abs (globalDistNode[i].min[1] - globalDistNode[i].pos[1])
		  	minScaleY = abs (globalDistNode[i].min[2] - globalDistNode[i].pos[2])
  			minScaleZ = abs (globalDistNode[i].min[3] - globalDistNode[i].pos[3])
			
			if (minScaleX > globalScaleX) then globalScaleX = minScaleX
			if (minScaleY > globalScaleY) then globalScaleY = minScaleY
			if (minScaleZ > globalScaleZ) then globalScaleZ = minScaleZ
			
		   	tm = matrix3 1 
			
			projVec =  Point3 0 0 1
			if (thePainterInterface.getHitCount() > 1) then projVec = worldHit + (worldHit - globalLastPos[i])
			else projVec = worldHit
			
	   		globalHairCopy[i].transform = GetMatrix globalHairPos[i] projVec globalHairNormal[i] str radius
				
			
--checks if the mirror is on, if so make sure to get that point and proces it also   
   			if (thePainterInterface.mirrorEnable == TRUE) then
				(
-- Put mirror stuff here
				thePainterInterface.getMirrorHitPointData &localHit &localNormal &mirrorWorldHit  &worldNormal 0

				if (thePainterInterface.getHitCount() > 1) then projVec = mirrorWorldHit  + (mirrorWorldHit  - globalLastPosMirror[i])
				else projVec = mirrorWorldHit  
				
				globalHairCopyMirror[i].transform = GetMatrix globalHairPosMirror[i] projVec globalHairNormalMirror[i] str radius
				
				)	
			)
		)
	


   if (thePainterInterface.getHitCount() > 1) then
   		(
		for i = 1 to 3 do
  			(
			if (globalUseDist[i]) then
				(
				globalLastNode[i].transform = GetMatrix globalLastPos[i] worldHit globalLastNormal[i] globalLastStr globalLastRadius 

				
	   			if (thePainterInterface.mirrorEnable == TRUE) then
					(				
					globalLastNodeMirror[i].transform = GetMatrix globalLastPosMirror[i] mirrorWorldHit globalLastNormalMirror[i] globalLastStr globalLastRadius 

					)
				)
			)
		
		)
		
  for i = 1 to 3 do
  	(
	if (globalUseDist[i]) then
		(
		globalLastNode[i] = globalHairCopy[i]
		globalLastNodeMirror[i] = globalHairCopyMirror[i]
		globalLastPos[i] = globalHairPos[i]
		globalLastNormal[i] = globalHairNormal[i]
		globalLastPosMirror[i] = globalHairPosMirror[i]
		globalLastNormalMirror[i] = globalHairNormalMirror[i]
		globalLastStr = str
		globalLastRadius = radius
		)
	)
	

)

fn CancelStroke = 
(
	thePainterInterface.undoCancel()
)

fn EndStroke = 
(
	thePainterInterface.undoAccept()
)

fn systemEnd =
(
  PaintHairRollout.PaintButton.checked = off 
  PaintHairRollout.PlaceButton.checked = off 
)





rollout PaintHairRollout "Paremeters" width:211 height:300
	(
	

	
	Button SourceButton "Set Sel. As Source" pos:[86,10] width:101 height:24
	label SourceObject "Source Object" pos:[11,16] width:72 height:15
	

	pickButton Dist1Button "Pick Distribution 1" pos:[86,41] width:101 height:24
	pickButton Dist2Button "Pick Distribution 2" pos:[86,70] width:101 height:24
	pickButton Dist3Button "Pick Distribution 3" pos:[86,101] width:101 height:24
	checkbox UseDist1 "Use As Dist" pos:[7,45] width:76 height:15
	checkbox UseDist2 "Use As Dist" pos:[7,74] width:76 height:15
	checkbox UseDist3 "Use As Dist" pos:[7,104] width:76 height:15

	
	
	checkButton PlaceButton "Place" pos:[7,135] width:104 height:24
	checkButton PaintButton "Paint" pos:[7,163] width:104 height:24
	button Options "..." pos:[113,135] width:41 height:24


	checkbox UseInstance "Instance Copies" pos:[7,193] width:120 height:15

	
    
	
	label Align "Align Objects " pos:[2,198+offsetY] width:66 height:15
	label Align2 " Axis To Normal " pos:[108,198+offsetY] width:92 height:15
    dropDownList AlignNormal "" pos:[72,198+offsetY] width:37 height:21 items:#("X", "Y", "Z") selection:3
	
	label Align3 "Align Objects " pos:[2,222+offsetY] width:66 height:15
	label Align4 " Axis To Stroke " pos:[108,222+offsetY] width:92 height:15
    dropDownList AlignStroke "" pos:[72,222+offsetY] width:37 height:21 items:#("X", "Y", "Z") selection:1

	label Align5 "Scale Options " pos:[2,246+offsetY] width:66 height:15
    dropDownList ScaleOptions "" pos:[72,246+offsetY] width:100 height:21 items:#("None", "Uniform Scale", "Custom Scale") selection:1
	
	checkbox chkScaleNormal "Scale Based On Normal" pos:[28,272+offsetY] width:145 height:22 checked:true
	checkbox chkScaleStroke "Scale Based On Stroke" pos:[28,292+offsetY] width:145 height:22 checked:true
	checkbox chkScaleStrength "Scale Based On Strength" pos:[28,312+offsetY] width:145 height:22 checked:true
	


	
	on SourceButton pressed do
		(
		globalSourceNode = $
		)
		
	on Dist1Button picked obj do
		(
		globalDistNode[1] = obj
		Dist1Button.text = obj.name
		UseDist1.checked = TRUE
		globalUseDist[1] = TRUE
		)
	on Dist2Button picked obj do
		(
		globalDistNode[2] = obj
		Dist2Button.text = obj.name
		UseDist2.checked = TRUE
		globalUseDist[2] = TRUE		
		)
	on Dist3Button picked obj do
		(
		globalDistNode[3] = obj
		Dist3Button.text = obj.name
		UseDist3.checked = TRUE
		globalUseDist[3] = TRUE		
		)
	on UseDist1 changed state do	
		globalUseDist[1] = state
	on UseDist2 changed state do
		globalUseDist[2] = state
	on UseDist3 changed state do
		globalUseDist[3] = state		
		
	on UseInstance  changed state do
		globalInstance = state		
		
	on PlaceButton changed state do
		(
		if (PaintButton.checked) then
			(
			PaintButton.checked = FALSE
			thePainterInterface.EndPaintSession()
			)
		
		
	    if thePainterInterface.InPaintMode() then
			(
			PlaceButton.checked = FALSE
			thePainterInterface.EndPaintSession()
			)
		else 
			(
			PaintButton.checked = FALSE
			PlaceButton.checked = TRUE
			
			thePainterInterface.initializeNodes 0 globalSourceNode 	

			thePainterInterface.pointGatherEnable = FALSE
			thePainterInterface.buildNormals = TRUE
			thePainterInterface.offMeshHitType = 2
			thePainterInterface.drawTrace = FALSE

			thePainterInterface.ScriptFunctions startStroke placeStroke endStroke  cancelStroke  systemEnd

			thePainterInterface.startPaintSession()
		

			)
		)	


	on PaintButton changed state do
		(
		if (PlaceButton.checked) then
			(
			PlaceButton.checked = FALSE
			thePainterInterface.EndPaintSession()
			)
			
	    if thePainterInterface.InPaintMode() then
			(
			PaintButton.checked = FALSE
			thePainterInterface.EndPaintSession()
			)
		else 
			(
			PaintButton.checked = TRUE
				
			thePainterInterface.initializeNodes 0 globalSourceNode 	

			thePainterInterface.pointGatherEnable = FALSE
			thePainterInterface.buildNormals = TRUE
			thePainterInterface.offMeshHitType = 2
			thePainterInterface.drawTrace = FALSE

			thePainterInterface.ScriptFunctions startStroke paintStroke endStroke  cancelStroke  systemEnd

			thePainterInterface.startPaintSession()
		

			)
		)	

	On Options 	pressed do
		(
		thePainterInterface.paintOptions()
		)
		
	on AlignNormal selected sel do
		(
		globalAlignNormal = sel
		)
	on AlignStroke selected sel do
		(
		globalAlignStroke = sel
		)	
		
	on ScaleOptions selected sel do
		(
		globalScaleOption  = sel
		)	

	on chkScaleNormal changed state do	
		globalScaleNormal = state		

	on chkScaleStrength changed state do	
		globalScaleStrength = state		

	on chkScaleStroke changed state do	
		globalScaleStroke = state		
		
	on PaintHairRollout  oktoclose do 
		(
		thePainterInterface.endPaintSession()
		)		
	)
	

-- create the rollout window and add the  rollout
if FloaterExampleFloater != undefined do
	(
	closerolloutfloater FloaterExampleFloater
	)		
Floater = newRolloutFloater "Paint Hair Floater" 220 425 
addRollout PaintHairRollout Floater
	 




	
