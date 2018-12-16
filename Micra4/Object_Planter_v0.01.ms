
----------------------
----------------------
--	                --
--	Object Planter  --
--	                --
----------------------
----------------------
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~--

if mcObjectPlanterDialog != undefined then destroyDialog mcObjectPlanterDialog

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~--

rollout mcObjectPlanterDialog " Object Planter v0.1" width:356 height:92
(
	--Locals:--------------------------------------------------------------------
	local dMove = false, DmPos
	-----------------------------------------------------------------------------
	GroupBox grp1 "Objects Planter:" pos:[4,4] width:344 height:84
	checkbutton ckbPick "Pick the Ground" pos:[12,28] width:104 height:24
	button btnDrop "Drop" pos:[12,56] width:104 height:24
	label lblObj "Select you building and pick the ground..." pos:[128,32] width:212 height:16
	label lblDistance "Distance from the base:" pos:[128,60] width:115 height:16
	label lblUnits "uni" pos:[318,60] width:28 height:16
	spinner spnHeight "" pos:[242,60] width:72 height:16 range:[0,10000,0] type:#float
	------------------------------------------------------------------------
	/* Dialog */
	------------------------------------------------------------------------
	on mcObjectPlanterDialog open do (lblUnits.text = mcUnitsType())
	on mcObjectPlanterDialog close do (mcCall.saveIniDialog "mcObjectPlanterDialog" "Properties_2")
    on mcObjectPlanterDialog rbuttonup pos do (DestroyDialog mcObjectPlanterDialog)
	-->MoveMode
	on mcObjectPlanterDialog lbuttondown pos do (dMove = true; DmPos = pos; if not keyboard.shiftPressed do pushprompt "Pres Shift To Move...")
	on mcObjectPlanterDialog lbuttonup   pos do (dMove = false; pushprompt "")
	on mcObjectPlanterDialog mouseMove   pos do
	(
		if dMove and keyboard.shiftPressed do mcDialogSnap mcObjectPlanterDialog DmPos
	)
	------------------------------------------------------------------------
	/* Actions */
	------------------------------------------------------------------------
	on ckbPick changed state do
	(
		if ckbPick.checked and selection.count == 1 do
		(
			tool mcGetLevelDistance
			(
				on mousePoint clickno do
				(
					local the3DPoint
					
					if clickno == 1 then
					(
						local theRay = mapScreentoWorldRay mouse.pos
						the3DPoint = (intersectRay $ theRay)
						if the3DPoint != undefined do 
						(
							spnHeight.value = the3DPoint.pos.z
							ckbPick.text = $.name
							lblObj.text = "God! Now select some object and hit Drop"
							ckbPick.checked = off
							#stop
						)
					)
					else #stop
				)
			)
			starttool mcGetLevelDistance
		)
	)
	on btnDrop pressed do
	(
		local dist = spnHeight.value
		if selection.count != 0 do (for i in selection do i.pos.z = dist-(i.min.z-i.pos).z) 
	)
)

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~--

mcCall.createIniDialog "mcObjectPlanterDialog" "Properties_2"

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~--

--**\ Created by Merlin el' 6.7.2006 0:47:17 /**--
