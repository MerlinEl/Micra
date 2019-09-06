--ID Obj or Face
Global mcObjIDDialog
Global mcSetObjectIDCalbacks
Global mcSetFaceIDCalbacks


if mcObjIDDialog != undefined do destroyDialog mcObjIDDialog
rollout mcObjIDDialog "" width:144 height:124
(
	--Locals:----------------------------------------
	local dMove = false, DmPos
	-------------------------------------------------
	spinner 'spn_id' "" pos:[8,20] width:80 height:16 enabled:true range:[0,1000,0] type:#integer scale:1 align:#left
	GroupBox 'grp1' "Material ID:" pos:[4,4] width:136 height:116 align:#left
	button 'btn_00' "0" pos:[8,100] width:24 height:16 align:#left
	button 'btn_01' "1" pos:[8,80] width:24 height:16 align:#left
	button 'btn_02' "2" pos:[36,80] width:24 height:16 align:#left
	button 'btn_03' "3" pos:[64,80] width:24 height:16 align:#left
	button 'btn_04' "4" pos:[8,60] width:24 height:16 align:#left
	button 'btn_05' "5" pos:[36,60] width:24 height:16 align:#left
	button 'btn_06' "6" pos:[64,60] width:24 height:16 align:#left
	button 'btn_07' "7" pos:[8,40] width:24 height:16 align:#left
	button 'btn_08' "8" pos:[36,40] width:24 height:16 align:#left
	button 'btn_09' "9" pos:[64,40] width:24 height:16 align:#left
	button 'btn_get_sel' "Get" pos:[92,44] width:44 height:24 align:#left
	button 'btn_set_sel' "Set" pos:[92,16] width:44 height:24 align:#left
	button 'btn_Clear' "Clear" pos:[36,100] width:52 height:16 align:#left
	--button 'btn_close' "*" pos:[92,4] width:12 height:12 align:#left
	fn getFaceID =
	(
		local obj = selection[1]
		if obj == undefined do return false
		if subobjectLevel == 4 or subobjectLevel == 5 
		then
		(
			local sel_face = ((polyOp.getFaceSelection obj)as array )[1]
			if sel_face == undefined 
			then spn_id.value = 1
			else spn_id.value = (polyop.getFaceMatID obj sel_face)
		)
		else spn_id.value = 1
	)
	fn getObjectID =
	(
		local obj = selection[1]
		if obj != undefined and classOf obj == Editable_Poly do
		(
			--print "deactivate when"
			deleteAllChangeHandlers id:#mcSetFaceIDCalbacks
			--print "activate when "
			when select obj changes id:#mcSetFaceIDCalbacks do mcObjIDDialog.getFaceID()
			
			if subobjectLevel != 4 or subobjectLevel != 5 do
			(
				spn_id.value = (polyop.getFaceMatID obj 1)
			)
		)	
	)
	fn set_Obj_or_Face id =
	(
		local sel = selection as array
		if subobjectLevel == 4 or subobjectLevel == 5 then
		(
			local obj = sel[1]
			if classOf obj != Editable_Poly do return false
			local fsel = polyOp.getFaceSelection obj
			undo "Set Face(s) Material ID" on polyop.setFaceMatID obj fsel id	
		)
		else if sel.count != 0 do (
			
			undo "Set Object(s) Material ID" on  for i in sel where classOf i == Editable_Poly do (
				
				local fcount = i.faces.count
				if fcount != 0 do polyop.setFaceMatID i #{1..fcount} id
			)
		)
		completeRedraw()
	)
	fn  get_Obj_or_Face id  =(
		
		local sel = selection as array
		if subobjectLevel == 4 or subobjectLevel == 5 then
		(
			local obj = sel[1]
			if classOf obj != Editable_Poly do return false
			local newFaceSel = #()
			for f = 1 to obj.numfaces where polyop.getFaceMatID obj f == id do append newFaceSel f
			setFaceSelection obj newFaceSel --set the selection when the loop is done!
		)
	)
	fn addToNumpad num_str = (
		
		local val_str = spn_id.value as String
		spn_id.value = execute (val_str + num_str)
	)
	--DialogProp --------------------------------------------------------------------
	on mcObjIDDialog rbuttonup pos do (destroyDialog mcObjIDDialog)
	on mcObjIDDialog open do
	(
		callbacks.removeScripts id:#mcSetObjectIDCalbacks --Remove any existing callbacks with this ID.
		deleteAllChangeHandlers id:#mcSetFaceIDCalbacks --Remove any existing callbacks with this ID.
		
		local obj = selection[1]
		
		if obj != undefined do (when select obj changes id:#mcSetFaceIDCalbacks do mcObjIDDialog.getFaceID())
		callbacks.addScript #selectionSetChanged "mcObjIDDialog.getObjectID()" id:#mcSetObjectIDCalbacks
	)
	on mcObjIDDialog close do 
	( 
		callbacks.removeScripts id:#mcSetObjectIDCalbacks --Remove any existing callbacks with this ID.
		deleteAllChangeHandlers id:#mcSetFaceIDCalbacks --Remove any existing callbacks with this ID.
		mcFile.saveDialogSettings "mcObjIDDialog" "Properties_2"
	)
	-->MoveMode
	on mcObjIDDialog lbuttondown pos do (dMove = true; DmPos = pos; if not keyboard.shiftPressed do pushprompt "Pres Shift To Move...")
	on mcObjIDDialog lbuttonup   pos do (dMove = false; pushprompt "")
	on mcObjIDDialog mouseMove   pos do
	(
		if dMove and keyboard.shiftPressed do mcDialog.snapDialog mcObjIDDialog DmPos
	)
	--Actions -----------------------------------------------------------------------
	--on spn_id changed val do (set_Obj_or_Face spn_id.value)
	--on btn_close pressed do (destroyDialog mcObjIDDialog)
	on btn_00 pressed  do (addToNumpad "0") --left mouse btn set
	on btn_01 pressed  do (addToNumpad "1") --left mouse btn set
	on btn_02 pressed  do (addToNumpad "2")
	on btn_03 pressed  do (addToNumpad "3")
	on btn_04 pressed  do (addToNumpad "4")
	on btn_05 pressed  do (addToNumpad "5")
	on btn_06 pressed  do (addToNumpad "6")
	on btn_07 pressed  do (addToNumpad "7")
	on btn_08 pressed  do (addToNumpad "8")
	on btn_09 pressed  do (addToNumpad "9")

	on btn_clear pressed do spn_id.value = 0
	on btn_set_sel pressed  do set_Obj_or_Face 	spn_id.value
	on btn_get_sel pressed  do
	(
		local sel = selection as array
		if subobjectLevel == 4 or subobjectLevel == 5 then
		(
			local obj = sel[1]
			if classOf obj != Editable_Poly do return false
			local fsel = mcPoly.get #fSel
			if fsel.count < 1 do return false
			--format "fsel:% cnt:%\n" fsel fsel.count
			local id  = polyop.getFaceMatID obj fsel[1]
			if id != undefined do (
				
				spn_id.value = id
				get_Obj_or_Face id
			)
		)
	)
)
mcCall.createXMLDialog "mcObjIDDialog" "Properties_2"