----------------
----------------
--            --
--   Cloner   --
--            --
----------------
----------------
----------------------------------------------------------------------------
if mcClonerDialog != undefined then destroyDialog mcClonerDialog
----------------------------------------------------------------------------

----------------------------------------------------------------------------
rollout mcClonerDialog "Cloner v1.05" width:164 height:296
(
	--Locals:----------------------------------------
	local dMove = false, DmPos, buttonPress = 0
	local ActiveButtons = #() , ActiveAction = ""
	local TempClones = #() , SelectedObjects = #()
	--Le=false,Ri=false,Up=false,Dw=false,Fr=false,Ba=false,Ce=false
	-------------------------------------------------
	GroupBox 'grp_Title' "" pos:[4,4] width:156 height:288 align:#left 
 
	checkbutton 'btnUp' "Up" pos:[60,16] width:38 height:22 toolTip:"[ Z ]" align:#left
	checkbutton 'btnLeft' "Left" pos:[20,40] width:38 height:22 toolTip:"[ -X ]" align:#left
	checkbutton 'btnRignt' "Right" pos:[100,40] width:38 height:22 toolTip:"[ X ]" align:#left
	checkbutton 'btnDown' "Down" pos:[60,88] width:38 height:22 toolTip:"[ -Z ]" align:#left
	checkbutton 'btnBack' "Back" pos:[20,64] width:38 height:22 toolTip:"[ Y ]" align:#left
	checkbutton 'btnFront' "Front" pos:[100,64] width:38 height:22 toolTip:"[ -Y ]" align:#left 
	checkbutton 'btnCenter' "Center" pos:[60,40] width:38 height:46 align:#left 
	spinner 'spnDistance' "" pos:[88,140] width:64 height:16 range:[0,10000,0] align:#left
	spinner 'spnCount' "" pos:[88,120] width:64 height:16 range:[0,10000,0] type:#integer align:#left
	checkbox 'chkInst' "Instance" pos:[8,188] width:68 height:20 align:#left
	checkbox 'chkColor' "Color" pos:[76,188] width:44 height:20 checked:true align:#left
	radiobuttons 'rdoCloneType' "Based in::" pos:[8,208] width:149 height:30 labels:#("Bounds     ", "Pivot") columns:2 align:#left
	button 'btnOverCheck' "Overlapping Check" pos:[8,240] width:116 height:20 toolTip:"Check Self-Overlapping" align:#left
	button 'btnApply' "Apply" pos:[8,264] width:56 height:20 toolTip:"Check Self-Overlapping" align:#left
	button 'btnClear' "Clear" pos:[68,264] width:56 height:20 toolTip:"Check Self-Overlapping" align:#left
	spinner 'spnElevation' "" pos:[88,160] width:64 height:16 range:[0,10000,0] align:#left
	label 'lbl1' "Count: " pos:[16,122] width:64 height:12 align:#left
	label 'lbl2' "Distance: " pos:[16,143] width:64 height:12 align:#left
	label 'lbl3' "Elevation: " pos:[16,164] width:64 height:12 align:#left
	-->Functions:---------------------------------------------------------------
	fn moveFromBounds obj axis dist elev =
	(
		local ClonesSpace = dist
		local pos = case axis of
		(
			#Up        : [0, 0, (  (obj.max.z - obj.min.z)+ClonesSpace )]
			#Down      : [0, 0, ( -(obj.max.z - obj.min.z)-ClonesSpace )]
			#Left      : [( -(obj.max.x - obj.min.x)-ClonesSpace ), 0, 0]
			#Right     : [(  (obj.max.x - obj.min.x)+ClonesSpace ), 0, 0]
			#Front     : [0, ( -(obj.max.y - obj.min.y)-ClonesSpace ), 0]
			#Back      : [0, (  (obj.max.y - obj.min.y)+ClonesSpace ), 0]
			#Center    : [0, 0, 0]
			#UpBack    : [0, (  (obj.max.y - obj.min.y)+ClonesSpace ), (  (obj.max.z - obj.min.z)+ClonesSpace )]
			#UpFront   : [0, ( -(obj.max.y - obj.min.y)-ClonesSpace ), (  (obj.max.z - obj.min.z)+ClonesSpace )]
			#UpLeft    : [( -(obj.max.x - obj.min.x)-ClonesSpace ), 0, (  (obj.max.z - obj.min.z)+ClonesSpace )]
			#UpRight   : [(  (obj.max.x - obj.min.x)+ClonesSpace ), 0, (  (obj.max.z - obj.min.z)+ClonesSpace )]
			#DownBack  : [0, (  (obj.max.y - obj.min.y)+ClonesSpace ), ( -(obj.max.z - obj.min.z)-ClonesSpace )]
			#DownFront : [0, ( -(obj.max.y - obj.min.y)-ClonesSpace ), ( -(obj.max.z - obj.min.z)-ClonesSpace )] 
			#DownLeft  : [( -(obj.max.x - obj.min.x)-ClonesSpace ), 0, ( -(obj.max.z - obj.min.z)-ClonesSpace )]
			#DownRight : [(  (obj.max.x - obj.min.x)+ClonesSpace ), 0, ( -(obj.max.z - obj.min.z)-ClonesSpace )] 
		)
		move obj pos
	)
	fn moveFromPivot obj axis dist elev =
	(
		local ClonesSpace = dist
		local pos = case axis of
		(
			#Up        : [0, 0, (  (obj.pos.z - obj.pos.z)+ClonesSpace )]
			#Down      : [0, 0, ( -(obj.pos.z - obj.pos.z)-ClonesSpace )]
			#Left      : [( -(obj.pos.x - obj.pos.x)-ClonesSpace ), 0, 0]
			#Right     : [(  (obj.pos.x - obj.pos.x)+ClonesSpace ), 0, 0]
			#Front     : [0, ( -(obj.pos.y - obj.pos.y)-ClonesSpace ), 0]
			#Back      : [0, (  (obj.pos.y - obj.pos.y)+ClonesSpace ), 0]
			#Center    : [0, 0, 0]
			#UpBack    : [0, (  (obj.pos.y - obj.pos.y)+ClonesSpace ), (  (obj.pos.z - obj.pos.z)+ClonesSpace )]
			#UpFront   : [0, ( -(obj.pos.y - obj.pos.y)-ClonesSpace ), (  (obj.pos.z - obj.pos.z)+ClonesSpace )]
			#UpLeft    : [( -(obj.pos.x - obj.pos.x)-ClonesSpace ), 0, (  (obj.pos.z - obj.pos.z)+ClonesSpace )]
			#UpRight   : [(  (obj.pos.x - obj.pos.x)+ClonesSpace ), 0, (  (obj.pos.z - obj.pos.z)+ClonesSpace )]
			#DownBack  : [0, (  (obj.pos.y - obj.pos.y)+ClonesSpace ), ( -(obj.pos.z - obj.pos.z)-ClonesSpace )]
			#DownFront : [0, ( -(obj.pos.y - obj.pos.y)-ClonesSpace ), ( -(obj.pos.z - obj.pos.z)-ClonesSpace )] 
			#DownLeft  : [( -(obj.pos.x - obj.pos.x)-ClonesSpace ), 0, ( -(obj.pos.z - obj.pos.z)-ClonesSpace )]
			#DownRight : [(  (obj.pos.x - obj.pos.x)+ClonesSpace ), 0, ( -(obj.pos.z - obj.pos.z)-ClonesSpace )] 
		)
		move obj pos
	)
	fn clearTempObjects =
	(
		if TempClones.count == 0 do return false
		try 
		(
			delete TempClones
			select SelectedObjects
		) 
		catch() 
		TempClones = #()
	)
	fn cloneSelection = 
	(
		local clones = #()
		for o in selection do clones += #(copy o)
		select clones
	)
	fn CloneTo axis =
	(
		if selection.count > 0 then
		(
			clearTempObjects()
			ActiveAction = axis
			SelectedObjects = selection as array
			
			max create mode
			-->Locals:-----------------------------------------------------------------------
			local RootColor = for i in selection collect i.wirecolor
			local Clones=#()
			local ClonesCount = mcClonerDialog.spnCount.value
			local ClonesDistance = mcClonerDialog.spnDistance.value
			local ClonesElevation = mcClonerDialog.spnElevation.value
			if mcClonerDialog.chkInst.checked then (CloneType = Instance) else (CloneType =Copy)
			-->Clones:------------------------------------------------------------------------
			while ClonesCount > 0 do
			(
				ClonesCount -=1
				for c in 1 to selection.count do ( Clones[c] = (CloneType selection[c]) )
				TempClones += Clones
				select Clones
				if mcClonerDialog.chkColor.checked do for i=1 to Clones.count do Clones[i].wirecolor = RootColor[i]
				-->Clone orientation based in Pivot or Bounds:--------------------------------
				case mcClonerDialog.rdoCloneType.state of
				(
					1:--bounds
					(
						print "bounds"
						for i in selection do moveFromBounds i axis ClonesDistance ClonesElevation
					)
					2:--pivot
					(
						print "pivot"
						for i in selection do moveFromPivot i axis ClonesDistance ClonesElevation
					)	
				)
			)
		)
		else (Messagebox "Select an Object. (0.0)" title:"Micra")
	)

	fn buttonControll state btn =
	(
		if state then ActiveButtons += #(btn) else (deleteItem ActiveButtons (findItem ActiveButtons btn))
		
		if ActiveButtons.count == 3 do (ActiveButtons[2].checked = off ; deleteItem ActiveButtons 2)

		if ActiveButtons.count == 2 then 
		(	
 				 if btnUp.checked   and btnFront.checked  then CloneTo #UpFront  --print "up fr"
			else if btnUp.checked   and btnBack.checked   then CloneTo #UpBack   --print "up ba"
			else if btnUp.checked   and btnLeft.checked   then CloneTo #UpLeft   --print "up le"
			else if btnUp.checked   and btnRignt.checked  then CloneTo #UpRight  --print "up ri"
			
			else if btnDown.checked and btnFront.checked  then CloneTo #DownFront --print "up fr"
			else if btnDown.checked and btnBack.checked   then CloneTo #DownBack  --print "up ba"
			else if btnDown.checked and btnLeft.checked   then CloneTo #DownLeft  --print "up le"
			else if btnDown.checked and btnRignt.checked  then CloneTo #DownRight --print "up ri"
			else (ActiveButtons[1].checked = off; deleteItem ActiveButtons 1)
		)
		
		if ActiveButtons.count == 1 then
		(
				 if btnUp.checked     then CloneTo #Up     --print "up"
			else if btnDown.checked   then CloneTo #Down   --print "dw"
			else if btnFront.checked  then CloneTo #Front  --print "fr"
			else if btnBack.checked   then CloneTo #Back   --print "ba"			
			else if btnLeft.checked   then CloneTo #Left   --print "le"
			else if btnRignt.checked  then CloneTo #Right  --print "ri"
			else if btnCenter.checked then CloneTo #Center --print "ce"
		)
		
		if ActiveButtons.count == 0 then
		(
			clearTempObjects()
		)
			
		format "ActiveButtons:%\n" ActiveButtons.count
	)
	fn uncheckAllButtons =
	(
		btnUp.checked     = off
		btnLeft.checked   = off
		btnRignt.checked  = off
		btnDown.checked   = off
		btnFront.checked  = off
		btnBack.checked   = off
		btnCenter.checked = off
		ActiveButtons = #()
	)
	--DialogProp --------------------------------------------------------------------

	on mcClonerDialog rbuttonup pos do (destroyDialog mcClonerDialog)
	on mcClonerDialog open do
	(
		if keyboard.controlPressed	do (cloneSelection(); destroyDialog mcClonerDialog)
		grp_Title.text = ("Cloner v"+(getInisetting mcDefaultINI "Version" "Clone2"))
		spnCount.value = 1
	)
	on mcClonerDialog close do 
	( 
		mcCall.saveIniDialog "mcClonerDialog" "Properties_2"
		clearTempObjects()
	)
	-->MoveMode
	on mcClonerDialog lbuttondown pos do (dMove = true; DmPos = pos; if not keyboard.shiftPressed do pushprompt "Pres Shift To Move...")
	on mcClonerDialog lbuttonup   pos do (dMove = false; pushprompt "")
	on mcClonerDialog mouseMove   pos do
	(
		if dMove and keyboard.shiftPressed do 
		(
			if mcDialogSnappingEnabled 
			then mcDialogSnap mcClonerDialog DmPos
			else setDialogPos mcClonerDialog (mouse.screenpos - DmPos)
		)
	)
	--Actions -----------------------------------------------------------------------
	on btnCenter changed state do buttonControll state btnCenter
	on btnUp     changed state do buttonControll state btnUp
	on btnDown   changed state do buttonControll state btnDown
	on btnLeft   changed state do buttonControll state btnLeft
	on btnRignt  changed state do buttonControll state btnRignt
	on btnFront  changed state do buttonControll state btnFront
	on btnBack   changed state do buttonControll state btnBack

	on btnApply pressed do 
	(
		clearTempObjects()
		undo "clone" on  (CloneTo ActiveAction)
		TempClones = #()
		CloneTo ActiveAction
	)
	on btnClear pressed do 
	(
		clearTempObjects()
		uncheckAllButtons()
	)
	
	on spnDistance changed val do (if ActiveAction != "" do CloneTo ActiveAction)
	on spnElevation changed val do (if ActiveAction != "" do CloneTo ActiveAction)
	on spnCount changed val do (if ActiveAction != "" do CloneTo ActiveAction)

	on btnOverCheck pressed do
	(
		if selection.count == 2 then
		(
			local rIntersects = (intersects selection[1] selection[2])
			if rIntersects == true then (messagebox "Overlapping!")
			else (messagebox "Not Owerlaping.")
		)
	)
	on chkColor changed state do (CloneTo ActiveAction)
	on chkInst  changed state do (CloneTo ActiveAction)
)
mcCall.createIniDialog "mcClonerDialog" "Properties_2"

