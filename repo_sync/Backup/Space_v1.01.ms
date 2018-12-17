----------------
----------------
--               --
--   Space    --
--               --
----------------
----------------
Global mcSpaceDialog
----------------------------------------------------------------------------
if mcSpaceDialog != undefined then destroyDialog mcSpaceDialog
----------------------------------------------------------------------------

rollout mcSpaceDialog "" width:196 height:76
(	
	--Locals:----------------------------------------
	local dMove = false, DmPos
	--Components:-----------------------------------
	groupBox 'grp1' "Space v1.01" pos:[4,4] width:188 height:68 align:#left
	radioButtons 'rdo_axis' "Axis:" pos:[12,24] width:97 height:30 enabled:true labels:#("X", "Y", "Z") columns:3 align:#left
	button 'btn_fit' "Fit" pos:[120,27] width:60 height:32 align:#left
	--functions:-------------------------------------
	fn distributeSelectedObjectsAlongX = ( --Distribute objects at X

		local sel = selection as Array
		if sel.count < 3 do return false
		fn compareDistance obj1 obj2 =  obj1.pos.x > obj2.pos.x 
		qsort sel compareDistance
		local first_x = sel[1].pos.x
		local last_x = sel[sel.count].pos.x
		local dist = last_x - first_x
		local shift = dist / (sel.count-1)
		for o in sel do (
			o.pos.x = first_x
			first_x += shift
		)
	)
	fn distributeSelectedObjectsAlongY = (

		local sel = selection as Array
		if sel.count < 3 do return false
		fn compareDistance obj1 obj2 =  obj1.pos.y > obj2.pos.y 
		qsort sel compareDistance
		local first_y = sel[1].pos.y
		local last_y = sel[sel.count].pos.y
		local dist = last_y - first_y
		local shift = dist / (sel.count-1)
		for o in sel do (
			o.pos.y = first_y
			first_y += shift
		)
	)
	fn distributeSelectedObjectsAlongZ = (

		local sel = selection as Array
		if sel.count < 3 do return false
		fn compareDistance obj1 obj2 =  obj1.pos.z > obj2.pos.z 
		qsort sel compareDistance
		local first_z = sel[1].pos.z
		local last_z = sel[sel.count].pos.z
		local dist = last_z - first_z
		local shift = dist / (sel.count-1)
		for o in sel do (
			o.pos.z = first_z
			first_z += shift
		)
	)
	on mcSpaceDialog open do()
	on mcSpaceDialog close do mcCall.saveIniDialog "mcSpaceDialog" "Properties_2"
	-->MoveMode
	on mcSpaceDialog lbuttondown pos do (dMove = true; DmPos = pos; if not keyboard.shiftPressed do pushprompt "Pres Shift To Move...")
	on mcSpaceDialog lbuttonup   pos do (dMove = false; pushprompt "")
	on mcSpaceDialog mouseMove   pos do
	(
		if dMove and keyboard.shiftPressed do 
		(
			if mcDialogSnappingEnabled 
			then mcDialogSnap mcSpaceDialog DmPos
			else setDialogPos mcSpaceDialog (mouse.screenpos - DmPos)
		)
	)
	on mcSpaceDialog rbuttonup pos do (destroyDialog mcSpaceDialog)
	--Actions -----------------------------------------------------------------------
	on rdo_axis changed val do()
	on btn_fit pressed  do
	(
		format "axis:%\n" rdo_axis.state
		case rdo_axis.state of (
			
			1: undo "Distribute Objects along X" on distributeSelectedObjectsAlongX()
			2: undo "Distribute Objects along Y" on distributeSelectedObjectsAlongY()
			3: undo "Distribute Objects along Z" on distributeSelectedObjectsAlongZ()
		)
	)
)
mcCall.createIniDialog "mcSpaceDialog" "Properties_2"
