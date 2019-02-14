--ID Obj or Face
Global mcObjIDDialog
Global mcSetObjectIDCalbacks
Global mcSetFaceIDCalbacks


if mcObjIDDialog != undefined do destroyDialog mcObjIDDialog
rollout mcObjIDDialog "" width:144 height:84
(
	--Locals:----------------------------------------
	local dMove = false, DmPos
	-------------------------------------------------
	spinner spn_id "" pos:[76,24] width:60 height:16 range:[1,100,1] type:#integer scale:1
	GroupBox grp1 "Material ID:" pos:[4,4] width:136 height:76
	label 'lbl1' "et - Set:" pos:[26,24] width:47 height:16
	button btn_close "*" pos:[128,4] width:12 height:12
	button btn_01 "1" pos:[8,44] width:16 height:16
	button btn_02 "2" pos:[24,44] width:16 height:16
	button btn_03 "3" pos:[40,44] width:16 height:16
	button btn_04 "4" pos:[56,44] width:16 height:16
	button btn_05 "5" pos:[72,44] width:16 height:16
	button btn_06 "6" pos:[88,44] width:16 height:16
	button btn_07 "7" pos:[104,44] width:16 height:16
	button btn_08 "8" pos:[120,44] width:16 height:16
	button btn_09 "9" pos:[8,60] width:16 height:16
	button btn_10 "10" pos:[24,60] width:16 height:16
	button btn_11 "11" pos:[40,60] width:16 height:16
	button btn_12 "12" pos:[56,60] width:16 height:16
	button btn_13 "13" pos:[72,60] width:16 height:16
	button btn_14 "14" pos:[88,60] width:16 height:16
	button btn_15 "15" pos:[104,60] width:16 height:16
	button btn_16 "16" pos:[120,60] width:16 height:16
	button 'btn_get_sel' "G" pos:[8,22] width:16 height:16
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
	fn set_Obj_or_Face id pre:false =
	(
		local sel = selection as array
		if subobjectLevel == 4 or subobjectLevel == 5 then
		(
			local obj = sel[1]
			if classOf obj != Editable_Poly do return false
			local fsel = polyOp.getFaceSelection obj
			polyop.setFaceMatID obj fsel id	
		)
		else if sel.count != 0 do
		(
			for i in sel where classOf i == Editable_Poly do
			(
				local fcount = i.faces.count
				if fcount != 0 do polyop.setFaceMatID i #{1..fcount} id
			)
		)
		if pre do spn_id.value = id
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
	on spn_id changed val do (set_Obj_or_Face spn_id.value)
	on btn_close pressed do (destroyDialog mcObjIDDialog)
	on btn_01 pressed  do (set_Obj_or_Face 1 pre:true) --left mouse btn set
	on btn_02 pressed  do (set_Obj_or_Face 2 pre:true)
	on btn_03 pressed  do (set_Obj_or_Face 3 pre:true)
	on btn_04 pressed  do (set_Obj_or_Face 4 pre:true)
	on btn_05 pressed  do (set_Obj_or_Face 5 pre:true)
	on btn_06 pressed  do (set_Obj_or_Face 6 pre:true)
	on btn_07 pressed  do (set_Obj_or_Face 7 pre:true)
	on btn_08 pressed  do (set_Obj_or_Face 8 pre:true)
	on btn_09 pressed  do (set_Obj_or_Face 9 pre:true)
	on btn_10 pressed  do (set_Obj_or_Face 10 pre:true)
	on btn_11 pressed  do (set_Obj_or_Face 11 pre:true)
	on btn_12 pressed  do (set_Obj_or_Face 12 pre:true)
	on btn_13 pressed  do (set_Obj_or_Face 13 pre:true)
	on btn_14 pressed  do (set_Obj_or_Face 14 pre:true)
	on btn_15 pressed  do (set_Obj_or_Face 15 pre:true)
	on btn_16 pressed  do (set_Obj_or_Face 16 pre:true)
	
	on btn_01 rightclick  do (get_Obj_or_Face 1) --right mouse btn get
	on btn_02 rightclick  do (get_Obj_or_Face 2)
	on btn_03 rightclick  do (get_Obj_or_Face 3)
	on btn_04 rightclick  do (get_Obj_or_Face 4)
	on btn_05 rightclick  do (get_Obj_or_Face 5)
	on btn_06 rightclick  do (get_Obj_or_Face 6)
	on btn_07 rightclick  do (get_Obj_or_Face 7)
	on btn_08 rightclick  do (get_Obj_or_Face 8)
	on btn_09 rightclick  do (get_Obj_or_Face 9)
	on btn_10 rightclick  do (get_Obj_or_Face 10)
	on btn_11 rightclick  do (get_Obj_or_Face 11)
	on btn_12 rightclick  do (get_Obj_or_Face 12)
	on btn_13 rightclick  do (get_Obj_or_Face 13)
	on btn_14 rightclick  do (get_Obj_or_Face 14)
	on btn_15 rightclick  do (get_Obj_or_Face 15)
	on btn_16 rightclick  do (get_Obj_or_Face 16)
	
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