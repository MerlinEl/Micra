if mcMoveTowardsDialog != undefined do destroyDialog mcMoveTowardsDialog 
rollout mcMoveTowardsDialog "" width:200 height:76
(
	-->Locals:-----------------------------------------------------------------
	local dMove = false , DmPos
	local lastRotX = 0
	local lastRotY = 0
	local lastRotZ = 0
	--Menu:---------------------------------------------------------------------
	radiobuttons rdoAxis "Axis:" pos:[16,24] width:97 height:30 labels:#("X", "Y", "Z") default:1 columns:3
	spinner spnTowards "" pos:[116,40] width:70 height:16 range:[-10000,10000,0] type:#float
	GroupBox grp1 "Move Towards:" pos:[6,4] width:190 height:64
	fn moveTowards val =
	(
		local sel = selection as array
		if sel.count != 2 do return ok
		case rdoAxis.state of
		(
			1:
			(
				in coordsys local move sel[1] [ val - lastRotX,0,0]
				in coordsys local move sel[2] [-val + lastRotX,0,0]
			)
			2:
			(
				in coordsys local move sel[1] [0, val - lastRotY,0]
				in coordsys local move sel[2] [0,-val + lastRotY,0]
			)
			3:			
			(
				in coordsys local move sel[1] [0,0,val - lastRotZ]
				in coordsys local move sel[2] [0,0,-val + lastRotZ]
			)
		)
	)
	fn saveRdoAxis val =
	(
		case rdoAxis.state of
		(
			1: lastRotX = val
			2: lastRotY = val
			3: lastRotZ = val
		)
	)
	fn setRdoAxisVal state =
	(
		print state
		spnTowards.value = case state of
		(
			1: lastRotX
			2: lastRotY
			3: lastRotZ
		)
	)
	on mcMoveTowardsDialog close           do(mcFile.saveIniDialog "mcMoveTowardsDialog" "Properties_2")
	on mcMoveTowardsDialog rbuttonup pos   do(destroyDialog mcMoveTowardsDialog)
	-->Move Dialog Mode
	on mcMoveTowardsDialog lbuttondown pos do(dMove = true ; DmPos = pos)
	on mcMoveTowardsDialog lbuttonup pos   do(dMove = false)
	on mcMoveTowardsDialog mouseMove pos do
	(
		if dMove and keyboard.shiftPressed do mcDialog.snapDialog mcMoveTowardsDialog DmPos
	)
	on rdoAxis changed state  do (setRdoAxisVal state )
	on spnTowards changed val do 
	(
		moveTowards val 
		saveRdoAxis val
	)
)
mcCall.createIniDialog "mcMoveTowardsDialog" "Properties_2"