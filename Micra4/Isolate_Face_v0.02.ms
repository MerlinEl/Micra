
try destroyDialog IsolateFaceDialog catch ()
rollout IsolateFaceDialog "" width:148 height:68
(
	--Locals:----------------------------------------
	local dMove = false, DmPos
	local isolated_faces = #(), current_level = 0
	-------------------------------------------------
	GroupBox grp_title "Isolation Level: 0" pos:[4,4] width:140 height:60
	button btn_faces "Selection" pos:[8,20] width:60 height:20
	button btn_id "ID " pos:[68,20] width:32 height:20
	button btn_smg "SMG" pos:[100,20] width:40 height:20
	button btn_return "<< Return >>" pos:[8,40] width:132 height:20
	button btn_close "*" pos:[132,4] width:12 height:12
	
	fn isEpolySelected obj = (classOf obj == editable_poly)
	fn getVisibleFaces =
	(
		local sub = subObjectLevel
		subObjectLevel = 4
		local obj = selection[1]
		if not isEpolySelected obj do return #()
		local face_sel = (polyOp.getFaceSelection obj as array)
		max select all
		local visible_faces = (polyOp.getFaceSelection obj as array)
		polyop.setFaceSelection obj face_sel
		subObjectLevel = sub
		return visible_faces
	)
	fn isoFaceSelection =
	(
		local sub = subObjectLevel
		subObjectLevel = 4
		local obj = selection[1]
		if not isEpolySelected obj do return false
		local face_sel = (polyOp.getFaceSelection obj as array)
		if face_sel.count == 0 or (getVisibleFaces()).count < 2 do return false
		max select invert
		append isolated_faces (polyOp.getFaceSelection obj as array)
		obj.hide #Face
		polyop.setFaceSelection obj face_sel
		
		current_level += 1
		grp_title.text = "Isolation Level: "+current_level as string
		subObjectLevel = sub
	)
	fn unisolate =
	(
		local sub = subObjectLevel
		subObjectLevel = 4
		local obj = selection[1]
		if not isEpolySelected obj do return false
		if current_level == 0 or isolated_faces.count == 0 do return false 
		local face_sel = (polyOp.getFaceSelection obj as array)
		max select all
		local visible_faces = (polyOp.getFaceSelection obj as array)
		obj.unhideAll #Face
		local current_level_faces = visible_faces + isolated_faces[current_level]
		polyop.setFaceSelection obj current_level_faces
		max select invert
		obj.hide #Face
		polyop.setFaceSelection obj face_sel
		deleteItem isolated_faces current_level
		
		current_level -= 1
		grp_title.text = "Isolation Level: "+current_level as string
		subObjectLevel = sub
	)
	
	fn isoByFaceSmoothGroup =
	(
		local sub = subObjectLevel
		subObjectLevel = 4
		local obj = selection[1]
		if not isEpolySelected obj do return false
		local face_sel = (polyOp.getFaceSelection obj as array)[1]
		if face_sel == undefined do return false
		local face_smg = polyOp.getFaceSmoothGroup obj face_sel as integer
		local visible_faces = getVisibleFaces()
		local faces = #()
		for i=1 to visible_faces.count do
		(
			local smg = (polyOp.getFaceSmoothGroup obj i as integer) 
			if smg == face_smg do faces += #(i)
		)
		polyop.setFaceSelection obj faces
		max select invert
		append isolated_faces (polyOp.getFaceSelection obj as array)
		obj.hide #Face
		polyop.setFaceSelection obj face_sel
		
		current_level += 1
		grp_title.text = "Isolation Level: "+current_level as string
		subObjectLevel = sub
	)
	fn isoByFaceID = 
	(
		local sub = subObjectLevel
		subObjectLevel = 4
		local obj = selection[1]
		if not isEpolySelected obj do return false
		local face_sel = (polyOp.getFaceSelection obj as array)[1]
		if face_sel == undefined do return false
		local face_id = (polyop.getFaceMatID obj face_sel) as integer
		local visible_faces = getVisibleFaces()
		local faces = #()
		for i=1 to visible_faces.count do
		(
			local id = (polyop.getFaceMatID obj i) as integer 
			if id == face_id do faces += #(i)
		)
		polyop.setFaceSelection obj faces
		max select invert
		append isolated_faces (polyOp.getFaceSelection obj as array)
		obj.hide #Face
		polyop.setFaceSelection obj face_sel
		
		current_level += 1
		grp_title.text = "Isolation Level: "+current_level as string
		subObjectLevel = sub
	)
	-->Dialog prop
	on IsolateFaceDialog rbuttonup pos do (destroyDialog IsolateFaceDialog)
	on IsolateFaceDialog close do ( mcCall.saveIniDialog "IsolateFaceDialog" "Properties_2" )
	on btn_close pressed do (destroyDialog IsolateFaceDialog)
	-->MoveMode
	on IsolateFaceDialog lbuttondown pos do (dMove = true; DmPos = pos; if not keyboard.shiftPressed do pushprompt "Pres Shift To Move...")
	on IsolateFaceDialog lbuttonup   pos do (dMove = false; pushprompt "")
	on IsolateFaceDialog mouseMove   pos do
	(
		if dMove and keyboard.shiftPressed do 
		(
			if mcDialogSnappingEnabled 
			then mcDialogSnap IsolateFaceDialog DmPos
			else setDialogPos IsolateFaceDialog (mouse.screenpos - DmPos)
		)
	)
	-->Actions
	on btn_faces  pressed  do (isoFaceSelection())
	on btn_id     pressed  do (isoByFaceID())
	on btn_smg    pressed  do (isoByFaceSmoothGroup())
	on btn_return pressed  do (unisolate())
)
mcCall.createIniDialog "IsolateFaceDialog" "Properties_2"