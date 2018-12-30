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
rollout mcSpaceDialog "" width:204 height:144
(
	--Locals:----------------------------------------
	local dMove = false, DmPos
	local obj_a, obj_b
	--Components:-----------------------------------
	GroupBox 'grp1' "Space v1.02" pos:[4,4] width:196 height:136 align:#left
	pickbutton 'btn_obj_a' "pick start obj" pos:[56,22] width:136 height:24 align:#left
	label 'lbl1' "Start:" pos:[12,28] width:44 height:16 align:#left
	pickbutton 'btn_obj_b' "pick end obj" pos:[56,48] width:136 height:24 align:#left
	label 'lbl2' "End:" pos:[12,54] width:44 height:16 align:#left
	label 'lbl7' "Select object for distribute and press:" pos:[8,84] width:188 height:20 enabled:true align:#left
	button 'btn_fit' "Fit" pos:[8,104] width:188 height:32 align:#left
	--functions:-------------------------------------
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
	on mcSpaceDialog close do mcCall.saveIniDialog "mcSpaceDialog" "Properties_2"
	-->MoveMode
	on mcSpaceDialog lbuttondown pos do (dMove = true; DmPos = pos; if not keyboard.shiftPressed do pushprompt "Pres Shift To Move...")
	on mcSpaceDialog lbuttonup   pos do (dMove = false; pushprompt "")
	on mcSpaceDialog mouseMove   pos do
	(
		if dMove and keyboard.shiftPressed do mcDialogSnap mcSpaceDialog DmPos 
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
	on btn_fit pressed  do
	(
		undo "Distribute Objects" on distributeSelectedObjects()
	)
)
mcCall.createIniDialog "mcSpaceDialog" "Properties_2"
