try destroyDialog smgManagerDialog catch ()
rollout smgManagerDialog "Hide Faces by SMG" width:200 height:288
(
	local ids
	listbox lbx_sets "SMG Sets:" pos:[4,36] width:192 height:17
	button btn_unhide "Unhide" pos:[44,4] width:40 height:28
	button btn_hide "Hide" pos:[4,4] width:36 height:28
	button btn_unhideall "Unhide All" pos:[88,4] width:60 height:28
	button btn_refresh "Reload" pos:[152,4] width:44 height:28
	fn isCorrectSelection obj = ( obj != undefined and classOf obj == Editable_Poly )
	fn faceIsHidden f =
	(
		local obj = selection[1]
		if not isCorrectSelection obj do return false
		local all_hidden_faces = polyop.getHiddenFaces obj 
		(#{f} - all_hidden_faces).numberset == 0
	)
	fn getSGarray obj = 
	(
		local SGarray=for i=1 to 32 collect #{}
		for f=1 to obj.numfaces do 
		(
			local SGnumber = polyOp.getFaceSmoothGroup obj f
			local SGbitarray=#{}
			if SGnumber < 0 do 
			(
				SGbitarray[32]=true
				SGnumber -= 2^31
			)
			for i = 1 to 31 do 
			(
				SGbitarray[i] = (mod SGnumber 2 > .5)
				SGnumber /= 2
			)
			for sg in SGbitarray do append SGarray[sg] f
		)
		--format "sg:%\n" SGarray
		SGarray
	)
	fn fillListbox arr = 
	(
		lbx_sets.items = #()
		for i=1 to 32 where arr[i].count != 0 do lbx_sets.items += #(i as string)
	)
	fn inicilaize = 
	(
		local obj = selection[1]
		if not isCorrectSelection obj do return false
		
		if obj == undefined or classOf obj != Editable_Poly do return false
		ids = getSGarray obj
		fillListbox ids
	)
	fn unhideAllFaces =
	(
		local obj = selection[1]
		if not isCorrectSelection obj do return false

		polyOp.unHideAllFaces obj
		completeRedraw()
	)
	fn hideBySmg =
	(
		local obj = selection[1]
		if not isCorrectSelection obj do return false
		local idsel = lbx_sets.selected
		if idsel == undefined then return false else idsel = idsel as integer

		polyop.setHiddenFaces obj ids[idsel]
		completeRedraw()
	)
	fn unhideBySmg =
	(
		local obj = selection[1]
		if not isCorrectSelection obj do return false
		local idsel = lbx_sets.selected
		if idsel == undefined then return false else idsel = idsel as integer
		
		local hiddenFaces = polyop.getHiddenFaces obj
		local forhide = hiddenFaces - ids[idsel]
		obj.unhideAll #Face
		polyop.setHiddenFaces obj forhide
	)
	on btn_unhide pressed    do (unhideBySmg())
	on btn_hide pressed      do (hideBySmg())
	on btn_unhideall pressed do (unhideAllFaces())
	on btn_refresh pressed   do (inicilaize())
	on smgManagerDialog open   do (inicilaize())

)
createDialog smgManagerDialog