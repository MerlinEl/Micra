
fn tempUnwrapPack = -- packing objects with unique falgs
(
	local sel = selection as array
	if sel.count < 2 or classOf sel[1] != Editable_Poly do return false
	local first_obj = sel[1]
	local flag = bit.shift 1 26
	polyOp.setFaceFlags first_obj first_obj.faces flag mask:flag -- set flag 26 to all faces  --undoable:true
	undo "Temp Unwrap" on for i=2 to sel.count do -- attach next obj and create new set for each
	(
		local next_obj = sel[i] --get next object from array
		if classOf next_obj != Editable_Poly do continue -- skip object if is not poly
		
		local old_faces = first_obj.faces as bitarray -- get old faces
		polyOp.attach first_obj next_obj   -- attach new object
		local all_faces = first_obj.faces as bitarray -- get all faces
		local new_faces = all_faces - old_faces -- make an intersection 
		flag = bit.shift 1 (25+i) --generate next flag
		polyOp.setFaceFlags first_obj new_faces	flag -- assing next flag for new faces
	)
	completeRedraw()
)




my_array= #{} --define an empty bitarray
b = bit.Set 0 1 true --set the first bit to true 
--now call the function and supply the empty array as
--In parameter by reference and the flag bit to filter out
$.getVerticesByFlag &my_array b 
--Now look at the content of the bitarray -
--it will contain the vertices that have their first flag bit set
--(bit 1 stands for selected, so it will contain the vertex selection)
print my_array 
