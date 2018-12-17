
--This is a simple example of basic usage of thePainterInterface.  All it does is create cylinders along 
--the stroke.  It uses the str and radius to define the cylinder radius and height.

--it tests these methods
--		getHitPointData
--		getMirrorHitPointData 
--		getIsHit
--it tested these paint options
--		Presuure Sensitivity for str, size
--		Predefined Str/Size
--		Update on mouse up
--		Mirror X/Y/Z

--Everything runs through thePainterInterface static interface.  The thePainterInterface drives
--all its callbacks through functions.  All you need to do is to define functions to handle these 
--stroke conditions
--		StartStroke
--		PaintStroke
--		EndStroke
--		CancelStroke
--      SystemEnd
--These functions are callbacks in response to the paint system.  They will
--get called as the users paints across a mesh

--To initialize this use these functions call you need to call the 
--thePainterInterface.ScriptFunctions <function>startStroke <function>paintStroke <function>endStroke  <function>cancelStroke  <function>systemEnd



--For instance a script would call this line to register its functions 

--fn startStroke = print "Handle start stroke here"
--fn paintStroke = print "Handle paint stroke here"
--fn endStroke = print "Handle end stroke here"
--fn cancelStroke = print "Handle cancel stroke here"
--fn systemEnd = print "Handle system end here"
--thePainterInterface.ScriptFunctions startStroke paintStroke endStroke  cancelStroke  systemEnd

--Once you establish the connection the thePainterInterface you need to tell it 
--what to paint on.  This done with initializeNodes
--<void>initializeNodes <integer>flags <node array>normalList
--	<integer>flags - not currently used
--	<node array>normalList - list of nodes that you want to paint on

--So if you wanted to paint on the current selection you would do

--	nodeList = $
--	thePainterInterface.initializeNodes 0 nodeList
	
--Once you have this setup you need to tell the system when you want to start or
--end a paint session with
--    <void>startPaintSession()
--    <void>endPaintSession()

--Once you have called startPaintSession thePainterInterface will call your functions
--StartStroke/PaintStroke/EndStroke or Cancel Stroke

--things that this script does not show are
--		interactive predetermined str/sizes 
--		gathering of points inside the envelope (not yet implemented in the interface yet) 

--*********************************************************************

--StartStroke gets called when the user begins a stroke across the mesh.
--This is here to let you do things like setup caches and set up the hold
--state.

--**********************************************************************

fn StartStroke = 
	
(
--this starts the undo system so anmything you do in the paint stroke will be put on the undo stack
--this must be paired with thePainterInterface.undoAccept() or thePainterInterface.undoCancel()
thePainterInterface.undoStart()
)


--*********************************************************************

--PaintStroke gets called when as the user a stroke across the mesh if the 
--system is set up to not update on mouse up.  This will get called repeatedly
--for each mouse move.  To retrieve the mouse/hit data call

--<void>getHitPointData 
--	   <&point3>localHit - the hit space in local space of the node that was hit
--	   <&point3>localNormal - the normal of the face that was hit in local space of the node that was hit
--	   <&point3>worldHit - the world space hit point
--	   <&point3>worldNormal - the world space normal of the hit face
--	   <&float>radius  - the radius of the brush at the time of the hit
--	   <&float>str - the strength of the brush at the time of the hit
--	   <integer>tabIndex - this is the index of the hit point that you want to get
--	   					   If this value is 0 it will return the last hit point
--		This function lets you retrieve the hit point data of the stroke

--<void>getHitFaceData 
--     <&point3>bary - the barycentric coords of the face that was hit
--	   <&integer>faceIndex - the index of the face that was hit
--	   <node>node - the node that was hit
--	   <integer>tabIndex - this is the index of the hit point that you want to get
--	   					   If this value is 0 it will return the last hit point
--		This function lets you retrieve the hit face data of the stroke.  This is the
--		face data that exists at the top of the stack.
	   
--<void>getHitPressureData 
--		<&boolean>shift - the state of the shift key 
--		<&boolean>ctrl  - the state of the ctrl key 
--		<&boolean>alt  - the state of the alt key 
--		<&float>pressure  - the pressure from pressure sensitive tablets 
--		<integer>tabIndex - this is the index of the hit point that you want to get
--	   					   If this value is 0 it will return the last hit point
--		This returns the key state and pressure state of a stroke point
		
--<integer>getHitCount()	
--		returns the number of hit points in a stroke



--**********************************************************************
fn PaintStroke = 
	
(

  localHit = Point3 0 0 0
  localNormal = Point3 0 0 0
  worldHit = Point3 0 0 0
  worldNormal = Point3 0 0 0
  str = 0.0f
  radius = 0.0f
 --retrieves the last hit point
  thePainterInterface.getHitPointData &localHit &localNormal &worldHit &worldNormal &radius &str 0
  
--This gets whether the stroke point actually hit the mesh
--Since the user can paint off the mesh 
--Right now we ignore this and create a cylinder regardless if they are painting on the mesh or not		
   hit = thePainterInterface.getIsHit -1
  

   
--creates a clynder aligned to that hit point 
   test = cylinder radius:radius height:str 
   tm = matrix3 1 
   tm = matrixFromNormal  worldNormal 
   test.rotation = inverse tm.rotationpart
   test.pos = worldHit
--checks if the mirror is on, if so make sure to get that point and proces it also   
   if (thePainterInterface.mirrorEnable == TRUE) then
			(
			
			thePainterInterface.getMirrorHitPointData &localHit &localNormal &worldHit &worldNormal 0
 
			test = cylinder radius:radius height:str 
			tm = matrix3 1 
			tm = matrixFromNormal  worldNormal 
 
			test.rotation = inverse tm.rotationpart
			test.pos = worldHit
			
			)	



 print "Painting Stroke PaintCylinders "
 
)


--*********************************************************************

--EndStroke gets called when the user ends stroke.  This is allows you
--to clean up any caches and the hold state.

--You should also check the thePainterInterface.updateOnMouseUp and if that
--is on.  If it is on you should ask thePainterInterface for all the hit 
--points and process them.  You should als check the mirror flag and if that 
--is set grab the mirror data

--**********************************************************************


fn EndStroke = 
(

--check if update on mouse up is on
--if so we were in non interactive mode so we need to go back and process those points
if (thePainterInterface.updateOnMouseUp == TRUE) then
	(
	
	--Get the number hits
	hitCount = thePainterInterface.GetHitCount()

	--if so we need to process all those points
	for i = 1 to hitCount do
		(
		localHit = Point3 0 0 0
		localNormal = Point3 0 0 0
		worldHit = Point3 0 0 0
		worldNormal = Point3 0 0 0
		str = 0.0f
		radius = 0.0f
 
 		--This gets whether the stroke point actually hit the mesh
		--Since the user can paint off the mesh 
		--Right now we ignore this and create a cylinder regardless if they are painting on the mesh or not		
		hit = thePainterInterface.getIsHit i
		

		--Get the hit point data
		thePainterInterface.getHitPointData &localHit &localNormal &worldHit &worldNormal &radius &str i
 
		test = cylinder radius:radius height:str 
		tm = matrix3 1 
		tm = matrixFromNormal  worldNormal 
 
		test.rotation = inverse tm.rotationpart
		test.pos = worldHit
		
		--check to see if mirror is enabled
	    if (thePainterInterface.mirrorEnable == TRUE) then
			(
			
			thePainterInterface.getMirrorHitPointData &localHit &localNormal &worldHit &worldNormal i
 
			test = cylinder radius:radius height:str 
			tm = matrix3 1 
			tm = matrixFromNormal  worldNormal 
 
			test.rotation = inverse tm.rotationpart
			test.pos = worldHit
			
			)			

		)
	)
	
--this accpets the undo state and puts it on the stack
thePainterInterface.undoAccept()
	
print "End Stroke PaintCylinders"
)


--*********************************************************************

--CancelStroke gets called when the user cancels stroke.  This is allows you
--to clean up any caches and the hold state.

--**********************************************************************
fn CancelStroke =
(
--this cancels the undo state undos the current stroke
thePainterInterface.undoCancel()

print "Cancel Stroke PaintCylinders"
)

--**********************************************************************
fn SystemEndPaintSession = 
(
print "System end"
PaintCylindersRollout.PaintButton.checked = off 

)


--just a simple rollout to put up a paint button in a floater
rollout PaintCylindersRollout "Paremeters" width:210 height:60
(
	checkButton PaintButton "Paint" pos:[7,3] width:140 height:24
	button Options "..." pos:[150,3] width:33 height:24

	on PaintButton changed state do
		(
			
	    if thePainterInterface.InPaintMode() then
			(
			PaintButton.checked = FALSE
			thePainterInterface.EndPaintSession()
			)
		else 
			(
			PaintButton.checked = TRUE
				
			nodeList = $
			thePainterInterface.initializeNodes 0 nodeList 	
			thePainterInterface.offMeshHitType = 2
			thePainterInterface.ScriptFunctions startStroke paintStroke endStroke  cancelStroke  SystemEndPaintSession 
			thePainterInterface.startPaintSession()
			)
		)	

	On Options 	pressed do
		(
		thePainterInterface.paintOptions()
		)
	on PaintCylindersRollout  oktoclose do 
		(
		thePainterInterface.endPaintSession()
		)		
)

-- create the rollout window and add the  rollout
if FloaterExampleFloater != undefined do
	(
	closerolloutfloater FloaterExampleFloater
	)		
Floater = newRolloutFloater   "Paint Cylinder Floater" 214 94
addRollout PaintCylindersRollout  Floater