MacroScript ThreePointAlign
ButtonText:"3Pt Align"
Category:"MB Tools"
Tooltip:"3Pt Align"

-- ThreePointAlign v 1.2 - 02.10.03 - (c) M. Breidt (martin@breidt.net)
--
-- This code is released under "Quote ware" license:
--      If you use this tool in a production environment with a group of more than two people,
--      or have used it in the past under such conditions, then you are obliged to tell 
--      me (martin@breidt.net) about it and allow me to list that project title and your 
--      company name as a reference on my website http://scripts.breidt.net
--
-- Installation:
-- After executing this file (MAXScript > Run Script), there will be a new
-- entry named '3Pt Align' in Customize > Customize User Interface in the 
-- category 'MB Tools'. Just assign a hotkey, or put it in a quad manue or 
-- toolbar.
--
-- Usage: 
-- Select any object, then invoke macro. Pick three source points (1-3) 
-- in the viewport (you might want to turn on vertex snap); then select 
-- three target points (4-6). 
-- The selected object will be realigned in 3D space in such a way that 
--   * Point 1 and Point 4 will coincide
--   * Point 1-3 will be on the plane of Point 4-6
--   * The line (Point 1->2) will be parallel to line (Point 4->5)
-- After you picked the last point, a dialog will be presented that allows
-- for further modification: you can flip the orientation of the aligment
-- and you can offset the aligned object along the alignment plane's normal
--
-- Known limitations: 
-- If you invert the alignment, the aligned object will have negative scaling 
-- which might cause problems at a later stage.

(
	struct pointdata (pos, txt, col)	-- Data structure for storing viewport marker data
	global ThreePtAlignMarkers = #()	-- viewport marker list
	global ThreePtAlignActive = false

	-- callback function that draws all viewport markers found in ThreePtAlignMarkers
	fn drawCoord = (
		gw.setTransform(Matrix3 1)
		local i
		-- print "--- Redraw"
		for i in ThreePtAlignMarkers do (
			-- print i.txt
			p = gw.hTransPoint i.pos
			gw.hText p i.txt color:i.col
			gw.hMarker p #smallHollowBox color:[255,255,255]
		)
		if ThreePtAlignMarkers.count > 1 then (
			gw.SetColor #line [255,255,0]
			gw.hPolyline #(gw.hTransPoint ThreePtAlignMarkers[1].pos, gw.hTransPoint ThreePtAlignMarkers[2].pos) false
		)
		if ThreePtAlignMarkers.count > 2 then (
			gw.SetColor #line [0,255,255]
			gw.hPolyline #(gw.hTransPoint ThreePtAlignMarkers[1].pos, gw.hTransPoint ThreePtAlignMarkers[3].pos) false
		)
		if ThreePtAlignMarkers.count > 3 then (
			gw.SetColor #line [255,0,0]
			gw.hPolyline #(gw.hTransPoint ThreePtAlignMarkers[1].pos, gw.hTransPoint ThreePtAlignMarkers[4].pos) false
		)
		if ThreePtAlignMarkers.count > 4 then (
			gw.SetColor #line [255,255,0]
			gw.hPolyline #(gw.hTransPoint ThreePtAlignMarkers[4].pos, gw.hTransPoint ThreePtAlignMarkers[5].pos) false
		)
		gw.enlargeUpdateRect #whole
		gw.updateScreen()
	)
		
	-- returns the transformation matrix which will transform a point from world into 
	-- the coordinate system derived from p1-p2 and p1-p3
	fn localMatrix p1 p2 p3 = (
		v1 = normalize (p2 - p1)
		v3 = normalize (cross v1 (normalize (p3 - p1)))
		v2 = normalize (cross v3 v1)
		return matrix3 v1 v2 v3 p1
	)

	-- creates a temporary marker (red sphere, green box, blue box) at position p
	fn createMarker p type = (
		return case type of (
			#sphere:	(undo off Sphere pos:p radius:5 segments:8 wirecolor:[255,0,0])
			#box1:		(undo off Box pos:(p-[0,0,5]) width:10 length:10 height:10 wirecolor:[0,255,0])
			#box2:		(undo off Box pos:(p-[0,0,5]) width:10 length:10 height:10 wirecolor:[0,0,255])
		)
	)

	local myObj			-- local global variable which object should be moved
	local dialog_ok		-- local global variable with result of dialog (OK/Cancel)
	local trgtPlane, srcPlane, old_transform

	-- Dialog for transformation after six points have been selected
	-- expects: node in myObj, original transformation in old_transform, 
	--          source and target matrix in srcPlane and trgtPlane 
	rollout option_ro "3Pt Align Options" (
		local start_transform		-- object transformation upon start of dialog
		local scale = 1
		local trans = 0

		-- transformation update function including mirroring and offset
		fn transformObj = (
			myObj.transform = start_transform * (inverse trgtPlane) * transMatrix [0,0,trans] * scaleMatrix [1,1,scale] * trgtPlane
		)
		
		-- User Interface
		label l1 "3Pt Align v1.2" align:#center
		label l2 "© 03-05 M. Breidt" align:#center
		hyperLink hl "(martin@breidt.net)" address:"mailto:martin@breidt.net" align:#center
		checkbox inv_align "Invert alignment" align:#center
		spinner offset_s "Z Offset:" type:#worldunits range:[-1e10, 1e10, 0] align:#center
		button ok_b "OK" across:2 width:65
		button cancel_b "Cancel" width:65
		
		-- Event Handler
		on option_ro open do (
			-- do initial transform
			myObj.transform = old_transform * (inverse srcPlane) * trgtPlane
			-- store start values
			start_transform = myObj.transform
			scale = 1
			trans = 0
			transformObj()
		)
		on inv_align changed checkstate do (
			scale *= -1
			transformObj()
		)
		on offset_s changed val do (
			trans = val
			transformObj()
		)
		on ok_b pressed do (
			dialog_ok = true
			format "3Pt Align done.\n"
			ThreePtAlignActive = false
			destroyDialog option_ro
		)
		on cancel_b pressed do (
			dialog_ok = false
			myObj.transform = old_transform 	-- restore original transformation
			format "\n*** 3Pt Align canceled ***\n" 			
			ThreePtAlignActive = false
			destroyDialog option_ro
		)
	)

	on isEnabled do (selection.count > 0)
	
	on isChecked do ThreePtAlignActive
	
	on execute do (
		local canceled = true	-- we assume the user has canceled the operation until we know otherwise
		local oldSnapMode = snapMode.active
		snapMode.active = true
		ThreePtAlignActive = true
		
		-- clean viewport marker list
		ThreePtAlignMarkers = #()
		unregisterRedrawViewsCallback drawCoord
		registerRedrawViewsCallback drawCoord
		
		dialog_ok = false
		if (classOf (a01 = pickPoint prompt:"Pick 1st source point" snap:#3D) == Point3) then (
			format "%\n" a01
			append ThreePtAlignMarkers (pointdata pos:a01 txt:"Point A1" col:[255,0,0])
			if (classOf (a02 = pickPoint prompt:"Pick 2nd source point" snap:#3D rubberBand:a01) == Point3) then (
				format "%\n" a02
				append ThreePtAlignMarkers (pointdata pos:a02 txt:"Point A2" col:[0,255,0])
				if (classOf (a03 = pickPoint prompt:"Pick 3rd source point" snap:#3D rubberBand:a01) == Point3) then (
					format "%\n\n" a03
					append ThreePtAlignMarkers (pointdata pos:a03 txt:"Point A3" col:[0,0,255])
					-- next 3 points
					if (classOf (b01 = pickPoint prompt:"Pick 1st destination point" snap:#3D) == Point3) then (					
						format "%\n" b01
						append ThreePtAlignMarkers (pointdata pos:b01 txt:"Point B1" col:[255,0,0])
						if (classOf (b02 = pickPoint prompt:"Pick 2nd destination point" snap:#3D rubberBand:b01) == Point3) then (
							format "%\n" b02
							append ThreePtAlignMarkers (pointdata pos:b02 txt:"Point B2" col:[0,255,0])
							if (classOf (b03 = pickPoint prompt:"Pick 3rd destination point" snap:#3D rubberBand:b01) == Point3) then (
								format "%\n" b03
								append ThreePtAlignMarkers (pointdata pos:b03 txt:"Point B3" col:[0,0,255])
								myObj = selection[1]					-- store object that will be transformed
								while (isGroupMember myObj) do 
									myObj=myObj.parent					-- find group head
								if (isValidNode myObj) then (
									old_transform = myObj.transform		-- backup current transformation for dialog cancel
									-- get local coordinate systems								
									srcPlane = localMatrix a01 a02 a03
									trgtPlane = localMatrix b01 b02 b03
									-- clean up viewport markers once markers have been defined
									unregisterRedrawViewsCallback drawCoord									
									-- open modeless dialog that handles transformation and options
									createDialog option_ro
									canceled = false
								) else (
									format "Error! Cannot find parent object!\n"
								) -- end: if isValidNode
							) -- end: if b03
						) -- end: if b02
					) -- end: if b01
				) -- end: if a03
			) -- end: if a02
		) -- end: if a01
		if canceled then (	-- user has not entered all 6 points
			unregisterRedrawViewsCallback drawCoord
			ThreePtAlignActive = false
			format "\n*** 3Pt Align canceled ***\n" 
		)
		snapMode.active = oldSnapMode	
	) -- on execute 
) -- macroscript