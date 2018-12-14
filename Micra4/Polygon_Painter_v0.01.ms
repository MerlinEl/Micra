
---------------------
-- POLYGON PAINTER --
---------------------
--Modyfied by Rene Baca 15.04.2011
--Thanks To Bobo
(

	struct POLYGON_PAINTER_DT (hp_obj, lp_obj, start_pos, next_pos)
	local PPD = POLYGON_PAINTER_DT()

	fn isEditPoly obj = (classOf obj == editable_poly)
	fn createNode obj =
	(
		local new_obj = mesh vertices:#() faces:#() name:(obj.name + "_LPW")
		convertToPoly new_obj; select new_obj; max modify mode; completeredraw(); return new_obj
	)
	fn localMatrix p1 p2 p3 = 
	(
		local v1 = normalize (p1 - p2)
		local v3 = normalize (cross v1 (normalize (p3 - p2)))
		local v2 = normalize (cross v3 v1)
		return matrix3 v1 v2 v3 [0,0,0]
	)
	fn createPolygonInHit obj hit dir rad =
	(
		if not isEditPoly obj do return false
		local tm = matrixFromNormal dir
		local a = rad * tm.row1
		local b = rad * tm.row2
		local vert_pos = #(hit - a - b, hit + a - b, hit + a + b, hit - a + b)
		local verts = for p in vert_pos collect polyOp.createVert obj p 
		polyOp.setVertSelection obj verts
		polyOp.createPolygon obj verts 
		--redrawViews()
	)
	
	fn StartStroke = 
	(
		--this starts the undo system so anmything you do in the paint stroke will be put on the undo stack
		--this must be paired with thePainterInterface.undoAccept() or thePainterInterface.undoCancel()
		thePainterInterface.undoStart()
		print "Start Stroke Paint"
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

		--creates a face aligned to that hit point 
		if PPD.start_pos == undefined do PPD.start_pos = worldHit
		PPD.next_pos = worldHit
		format "start_pos:%\tnext_pos:%\n" PPD.start_pos PPD.next_pos
		if distance PPD.start_pos PPD.next_pos > radius do createPolygonInHit PPD.lp_obj worldHit worldNormal radius
		PPD.start_pos = PPD.next_pos
		/*
		test = cylinder radius:radius height:str 
		tm = matrix3 1 
		tm = matrixFromNormal  worldNormal 
		test.rotation = inverse tm.rotationpart
		test.pos = worldHit
		*/
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
		--print "Painting Stroke PaintCylinders "
	)

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
		print "End Stroke Paint"
	)
	fn CancelStroke =
	(
		--this cancels the undo state undos the current stroke
		thePainterInterface.undoCancel()
		--print "Cancel Stroke PaintCylinders"
	)
	fn SystemEndPaintSession = 
	(
		--print "System end"
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
				PPD.hp_obj = (selection as array)[1]
				if isEditPoly PPD.hp_obj do
				(
					PPD.lp_obj = createNode PPD.hp_obj
					PaintButton.checked = TRUE

					thePainterInterface.initializeNodes 0 PPD.hp_obj --nodeList 	
					thePainterInterface.offMeshHitType = 2
					thePainterInterface.ScriptFunctions startStroke paintStroke endStroke  cancelStroke  SystemEndPaintSession 
					thePainterInterface.startPaintSession()
				)
			)
		)	
		on Options 	pressed do(thePainterInterface.paintOptions())
		on PaintCylindersRollout  oktoclose do (thePainterInterface.endPaintSession())		
	)

	-- create the rollout window and add the  rollout
	if FloaterExampleFloater != undefined do
		(
			closerolloutfloater FloaterExampleFloater
		)		
	Floater = newRolloutFloater   "Paint Cylinder Floater" 214 94
	addRollout PaintCylindersRollout  Floater
)