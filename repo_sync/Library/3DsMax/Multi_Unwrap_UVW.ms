fn tempUnwrapPack chn:8 val:10.0 = -- using vert data channel 8 , starting at value 10.0
(
	local sel = selection as array
	local first_obj = sel[1]
	if sel.count < 2 or classOf first_obj != Editable_Poly do return false
	-- setup place for vData 
	polyOp.setNumVDataChannels first_obj chn -- add new channel
	polyOp.setVDataChannelSupport first_obj chn TRUE -- enable new channel supporting 
	-- assing a value for first verts group
	polyOp.setVDataValue first_obj chn first_obj.verts val
	local group_values = #( val                 )
	local group_names  = #( first_obj.name      )
	local group_pivots = #( first_obj.pivot     )
	local group_colors = #( first_obj.wirecolor )
	-- grouping poly objects
	undo "Temp Unwrap" on for i=2 to sel.count do -- attach next obj and create new set for each
	(
		local next_obj = sel[i] --get next object from array
		if classOf next_obj != Editable_Poly do continue -- skip object if is not poly
		
		group_values += #( val+i              )
		group_names  += #( next_obj.name      )
		group_pivots += #( next_obj.pivot     )
		group_colors += #( next_obj.wirecolor )
		
		local old_verts = first_obj.verts as bitarray -- get old verts
		polyOp.attach first_obj next_obj   -- attach new object
		local all_verts = first_obj.verts as bitarray -- get all verts
		local new_verts = all_verts - old_verts -- make an intersection 
		
		polyOp.setVDataValue first_obj chn new_verts ( val+i ) -- assing next flag for new verts
	)
	--store old objects data
	setUserProp first_obj "VDataChannelValues" group_values
	setUserProp first_obj "VDataChannelNames"  group_names
	setUserProp first_obj "VDataChannelPivots" group_pivots
	setUserProp first_obj "VDataChannelColors" group_colors
	setUserProp first_obj "VDataChannel"       chn
	
	clearSelection()
	select first_obj
)

fn tempUnwrapUnPack =
(
	local obj = selection[1]
	local chn = (getUserProp obj "VDataChannel")
	
	if chn == undefined then return false
	
	if classOf obj != Editable_Poly or not (polyOp.getVDataChannelSupport obj chn) do return false
	
	local values = getUserProp obj "VDataChannelValues"
	local pivots = getUserProp obj "VDataChannelPivots"
	local colors = getUserProp obj "VDataChannelColors"
	local names  = getUserProp obj "VDataChannelNames"

	if values  == undefined then return false else values  = execute values 
	if pivots  == undefined then return false else pivots  = execute pivots
	if colors  == undefined then return false else colors  = execute colors
	if names   == undefined then return false else names   = execute names

	for i=2 to values.count do
	(
		local new_obj_verts = #()
		for v in obj.verts as bitarray do 
		(
			local val = polyOp.getVDataValue obj chn v
			if val == values[i] do new_obj_verts += #(v)
		)
		if new_obj_verts.count > 2 do 
		(
			local faces = polyOp.getFacesUsingVert obj new_obj_verts
			polyOp.detachFaces obj faces delete:true asNode:true name:names[i] 
			local node = getNodeByName names[i] 
			if node != undefined do 
			(
				node.pivot     = pivots[i]
				node.wirecolor = colors[i]
			)
		)
	)
	completeRedraw()
)

/*
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
*/


/*
my_array= #{} --define an empty bitarray
b = bit.Set 0 1 true --set the first bit to true 
--now call the function and supply the empty array as
--In parameter by reference and the flag bit to filter out
$.getVerticesByFlag &my_array b 
--Now look at the content of the bitarray -
--it will contain the vertices that have their first flag bit set
--(bit 1 stands for selected, so it will contain the vertex selection)
print my_array 
*/




/*
fn tempUnwrapPack =
(
	local sel = selection as array
	if sel.count < 2 or classOf sel[1] != Editable_Poly do return false
	local first_obj = sel[1]
	first_obj.faces[#1] = first_obj.faces -- make set from first object faces
	print first_obj.name
	undo "Temp Unwrap" on for i=2 to sel.count do -- attach next obj and create new set for each
	(
		local next_obj = sel[i] --get next object from array
		if classOf next_obj != Editable_Poly do continue -- skip object if is not poly
		
		local old_faces = first_obj.faces as bitarray -- get old faces
		polyOp.attach first_obj next_obj   -- attach new object
		local all_faces = first_obj.faces as bitarray -- get all faces
		local new_faces = all_faces - old_faces -- make an intersection 
		first_obj.faces[i as string] = new_faces	 -- assing new faces in to set with new index
	)
	completeRedraw()
)

fn tempUnwrapUnPack =
(
	
	
	
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
*/