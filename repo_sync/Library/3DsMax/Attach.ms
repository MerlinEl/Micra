fn attachObjectsWithUniqueID =
(
	local sel = selection as array
	--filter non editable poly obj
	fn convertToEPoly obj =
	(
		if superClassOf obj != GeometryClass do return false
		try (convertToPoly obj) catch (false)
	)

	sel = for i in sel where convertToEPoly i != false collect i

	if sel.count < 2 do return false
	local obj = sel[1]
	
	local obj_faces = (for i = 1 to obj.faces.count collect i) as bitarray
	polyop.setFaceMatID obj obj_faces 1
	
	undo "Attach By ID" on for i = 2 to sel.count do with redraw off
	(
		local next_obj = sel[i]
		(
			polyOp.attach obj next_obj
			all_obj_faces = (for i = 1 to obj.faces.count collect i) as bitarray
			local next_obj_faces =  all_obj_faces - obj_faces
			polyOp.setFaceMatID obj next_obj_faces i
			obj_faces = all_obj_faces
		)
	)
	completeRedraw()
)



fn detachByID =
(
	local mc2CenterPivot
	fn mc2CenterPivot obj =
	(
		if obj == undefined do return false
		obj.pivot = (obj.min + obj.max)/2
	)
	local obj = selection[1]
	if classOf obj != Editable_Poly do return false
	local dettaching = true
	local ID = 0
	local new_objects_names = #()
	undo "Detach By ID" on while dettaching and not keyboard.escPressed do with redraw off
	(
		--format "id:%\tdetaching:%\n" id dettaching
		ID += 1
		obj.EditablePoly.selectByMaterial ID
		local element_faces = polyOp.getFaceSelection obj
		local new_obj_name = uniQueName obj.name
		new_objects_names += #(new_obj_name)
		dettaching = polyOp.detachFaces obj element_faces delete:true asNode:true name:new_obj_name
	)
	clearselection()
	delete obj
	for i in new_objects_names do mc2CenterPivot (getNodeByName i)
	completeRedraw()
)

/*
attachObjectsWithUniqueID()
detachByID()

*/

--.namedSelCopy <string>Name
--.namedSelPaste <bool>useRenameDialog
