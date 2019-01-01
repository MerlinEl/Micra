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
rollout mcSpaceDialog "" width:392 height:184
(
	--Locals:----------------------------------------
	local dMove = false, DmPos
	local obj_a, obj_b
	--Components:-----------------------------------
	GroupBox 'grp1' "Space v1.01" pos:[4,4] width:384 height:176 align:#left
	radiobuttons 'rdo_axis' "Axis:" pos:[52,76] width:97 height:30 enabled:true labels:#("X", "Y", "Z") columns:3 align:#left
	button 'btn_fit_a' "Fit" pos:[12,132] width:168 height:32 align:#left
	
	GroupBox 'grp2' "By Axis:" pos:[12,24] width:180 height:148 align:#left
	pickbutton 'btn_obj_a' "pick start obj" pos:[252,72] width:120 height:24 align:#left
	label 'lbl1' "Start:" pos:[208,78] width:44 height:16 align:#left
	pickbutton 'btn_obj_b' "pick end obj" pos:[252,100] width:120 height:24 align:#left
	label 'lbl2' "End:" pos:[208,106] width:44 height:16 align:#left
	label 'lbl7' "Select object without borders" pos:[208,48] width:168 height:20 enabled:true align:#left
	button 'btn_fit_b' "Fit" pos:[204,132] width:168 height:32 align:#left
	label 'lbl8' "Select all object with borders" pos:[20,48] width:160 height:20 enabled:true align:#left
	GroupBox 'grp15' "By Vector:" pos:[200,24] width:180 height:148 align:#left
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
	fn moveAlongVector o posA posB offset = (
		
		local v = normalize (posB - posA)
		o.pos = posA+(v*offset)
	)
	fn distributeSelectedObjects = ( --Distribute objects by vector

		if obj_a == undefined or obj_b == undefined do (
			
			MessageBox "Start  - End objects are not defined."
			return false
		)
		local sel = selection as Array
		if sel.count == 0 do (
			
			MessageBox "Select some objects to distribute between Start - End."
			return false
		)
		local p_start = obj_a.pos
		local p_end = obj_b.pos
		local dist = distance p_start  p_end
		local segment = dist / (sel.count+1)
		local offset = 0
		for o in sel do (
			
			offset += segment
			--moveAlongVector o p_start p_end offset
			moveAlongVector o p_start p_end offset
		)
	)

	on mcSpaceDialog open do()
	on mcSpaceDialog close do mcFile.saveIniDialog "mcSpaceDialog" "Properties_2"
	-->MoveMode
	on mcSpaceDialog lbuttondown pos do (dMove = true; DmPos = pos; if not keyboard.shiftPressed do pushprompt "Pres Shift To Move...")
	on mcSpaceDialog lbuttonup   pos do (dMove = false; pushprompt "")
	on mcSpaceDialog mouseMove   pos do
	(
		if dMove and keyboard.shiftPressed do mcDialog.snapDialog mcSpaceDialog DmPos
	)
	on mcSpaceDialog rbuttonup pos do (destroyDialog mcSpaceDialog)
	--Actions -----------------------------------------------------------------------
	on btn_obj_a picked obj do (
		
		btn_obj_a.text = obj.name
		obj_a = obj
	)
	on btn_obj_b picked obj do (
		
		btn_obj_b.text = obj.name
		obj_b = obj
	)
	on btn_fit_a pressed  do
	(
		format "axis:%\n" rdo_axis.state
		case rdo_axis.state of (
			
			1: undo "Distribute Objects along X" on distributeSelectedObjectsAlongX()
			2: undo "Distribute Objects along Y" on distributeSelectedObjectsAlongY()
			3: undo "Distribute Objects along Z" on distributeSelectedObjectsAlongZ()
		)
	)
	on btn_fit_b pressed  do
	(
		undo "Distribute Objects" on distributeSelectedObjects()
	)
)
mcCall.createIniDialog "mcSpaceDialog" "Properties_2"
