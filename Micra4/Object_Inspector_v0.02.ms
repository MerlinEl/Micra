Global mcObjectInpectorDialog
Global mcObjectInpectorMenu
rcmenu   mcObjectInpectorMenu (

	local used_id = -1
	local used_objs = #()
	local used_faces = #()
	subMenu "Materials"(
		menuItem m1_4 "Show Used Materials"
		menuItem m1_5 "Select Objects By Material Name"
		menuItem m1_2 "Select Objects By Material ID"
		separator sep1
		menuItem m1_3 "Get Faces Count"
		--menuItem m1_1 "Pick Face Material ID"
	)
	subMenu "Selections" (
		menuItem m2_1 "Slelect All Nodes Children"
		menuItem m2_2 "Unhide Selection"
		menuItem m2_3 "Hide Selection"
		separator sep2
		menuItem m2_4 "Show Linked Parents"
	)
	--1------------------------------------------------------------------------------------------------
	/*on m1_1 picked do (
		local obj = selection[1]
		if classOf obj != Editable_Poly do return false 
		local sel_face = (polyOp.getFaceSelection obj as array)[1]
		if sel_face != undefined do (
			used_id  = polyOp.getFaceMatID obj sel_face
			m1_1.text = "Pick Face Material ID:" + used_id as string
			m1_1.checked=true
			messageBox  ("Picked Material ID:" + used_id as string) title:"Info:"
		)
	)*/
	on m1_2 picked do (
		used_objs  = #()
		used_faces = #()
		used_id = typeBox "Type Material ID:"
		if used_id != undefined do used_id = execute used_id
		if classOf used_id != Integer do return false
		for o in selection  do (

			if classOf o != Editable_Poly do (
				format "skip nonpoly object:%\n" o.name
				continue
			)
			for f=1 to o.faces.count where polyOp.getFaceMatID o f == used_id do (

				append used_faces f
				appendIfUnique used_objs o 
			)	
		)
		messageBox  ("Found > Objects:" + used_objs.count as string + "\tFaces:" + used_faces.count as string) title:"Info:"
		format "found objs:%\n" used_objs.count
		format "found glass faces:%\n" used_faces.count
		select used_objs
	)
	on m1_3 picked do ( format "found glass faces:%\n" used_faces.count)
	on m1_4 picked do (
		
			local used_materials = #()
			for o in selection where superClassOf o == GEometryClass do (
				/*if classOf o != Editable_Poly do (
					format "skip nonpoly object:%\n" o.name
					continue
				)*/
				/*for f=1 to o.faces.count do (

					
					append glass_faces f
					appendIfUnique used_objs o 
				)*/	
				appendIfUnique used_materials o.material.name 
			)
			messageBox  ("Used Materials:\n\t" +  used_materials as string) title:"Info:"
			format  "Found > Used Materials:\n\t%\n"  used_materials
	)
	on m1_5 picked do (
		
		local mat_name = typeBox "Type Material Name:"
		if mat_name == undefined do return false
		local objs = for o in selection where (superClassOf o == GEometryClass and o.material.name == mat_name) collect o
		select objs
		messageBox ("Selected ( " + objs.count as string + " ) objects") title:"Info:"
	)
	---2------------------------------------------------------------------------------------------------
	on m2_1 picked do (

		local nodes_children = #()
		for o in selection do join nodes_children o.children
		select nodes_children
	)
	on m2_2 picked do (for o in selection do o.isHidden = false)
	on m2_3 picked do (for o in selection do o.isHidden = true)
	on m2_4 picked do (
		local used_parents = #()
		for o in selection where o.parent != undefined do appendIfUnique  used_parents o.parent.name
		messageBox  ("Used Parents:\n\t" +  used_parents as string) title:"Info:"
		format  "Found > Used Parents:\n\t%\n"  used_parents
	)
)

if mcObjectInpectorDialog != undefined do DestroyDialog mcObjectInpectorDialog
rollout mcObjectInpectorDialog "Object Inspector:" width:344 height:464
(
	GroupBox 'grp1' "Parameters:" pos:[4,8] width:336 height:236 align:#left
	GroupBox 'grp3' "Buffer:" pos:[4,280] width:336 height:152 align:#left
	
	button 'btn_Copy' "Copy" pos:[4,248] width:336 height:24 align:#left
	button 'btn_paste' "Paste" pos:[4,436] width:336 height:24 align:#left
	checkbox 'chk_layer' "Layer" pos:[8,28] width:84 height:24 align:#left
	checkbox 'chk_link' "Link" pos:[8,52] width:84 height:24 align:#left
	checkbox 'chk_wcolor' "WireColor" pos:[8,84] width:84 height:24 align:#left
	checkbox 'chk_material' "Material" pos:[8,108] width:84 height:24 align:#left
	checkbox 'chk_id' "ID" pos:[8,132] width:84 height:24 align:#left
	checkbox 'chk_position' "Position" pos:[8,164] width:84 height:24 align:#left
	checkbox 'chk_rotation' "Rotation" pos:[8,188] width:84 height:24 align:#left
	checkbox 'chk_scale' "Scale" pos:[8,212] width:84 height:24 align:#left
	
	label 'lbl_layer' "..." pos:[92,32] width:236 height:24 align:#left
	label 'lbl_link' "..." pos:[92,58] width:236 height:24 align:#left
	label 'lbl_color' "..." pos:[92,90] width:236 height:24 align:#left
	label 'lbl_material' "..." pos:[92,114] width:236 height:24 align:#left
	label 'lbl_id' "..." pos:[92,138] width:236 height:24 align:#left
	label 'lbl_position' "..." pos:[92,170] width:236 height:24 align:#left
	label 'lbl_rotation' "..." pos:[92,194] width:236 height:24 align:#left
	label 'lbl_scale' "..." pos:[92,218] width:236 height:24 align:#left
	
	label 'lbl_buffer' "..." pos:[8,304] width:324 height:120 align:#left

	local params_data
	fn getRotation obj = 
	(
		local x = obj.rotation.x_rotation
		local y = obj.rotation.y_rotation
		local z = obj.rotation.z_rotation
		return [x,y,z]
	)
	fn setRotation obj rot = 
	(
		obj.rotation.x_rotation = rot.x
		obj.rotation.y_rotation = rot.y
		obj.rotation.z_rotation = rot.z
	)
	fn clearInterfaceParams = (
		
		lbl_layer.text = "..."
		lbl_link.text =  "..."
		lbl_color.text =  "..."
		lbl_material.text =  "..."
		lbl_position.text  = "..."
		lbl_rotation.text  =  "..."
		lbl_scale.text  =  "..."
	)
	fn updateInterfaceParams obj = (
		
		lbl_layer.text = obj.layer.name
		lbl_link.text = if obj.parent != undefined then obj.parent.name else "..."
		lbl_color.text = obj.wireColor as string	
		lbl_material.text = if obj.material  != undefined then obj.material.name else "..."	
		lbl_position.text  = obj.pos as String
		lbl_rotation.text  =  (getRotation obj) as String
		lbl_scale.text  =  obj.scale as String
	)
	fn copyObjectData = (
		
		local obj = selection[1]
		if obj == undefined do return false 
		params_data = mcObject()
		if chk_layer.state do params_data.add "layer" obj.layer
		if chk_link.state do params_data.add "link" obj.parent
		if chk_wcolor.state do params_data.add "wirecolor" obj.wireColor	
		if chk_material.state do params_data.add "material" obj.material
		if chk_position.state do params_data.add "position" obj.pos
		if chk_rotation.state do params_data.add "rotation" (getRotation obj)
		if chk_scale.state do params_data.add "scale" obj.scale
		
		lbl_buffer.text = ""
		for key in params_data.keys() do (

			local val = params_data.get key
			local val_str = if isProperty val "name" then val.name else val as string
			lbl_buffer.text += key + " = " + val_str + "\n"
		)			
	)
	fn pasteObjectData = (
		
		local sel = selection as Array
		if sel.count == 0 or params_data == undefined do return false 
		undo "Object Inspector Paste" on for obj in sel do (
			
			for key in params_data.keys() do  (
				
				local val = params_data.get key
				case key of (
					
					"layer":val.addNode obj
					"link":obj.parent = val
					"wirecolor":obj.wirecolor = val
					"material":obj.material = val
					"position": obj.pos = val
					"rotation": setRotation obj val
					"scale": obj.scale = val
				)
			)	
		)
		updateInterfaceParams sel[1]
	)
	fn getObjectParams = (
		
		local obj = selection[1]
		if obj != undefined then updateInterfaceParams obj else 	clearInterfaceParams()
	)	
	fn setObjectParams = (
		local obj = selection[1]
		if obj == undefined do (
		
			clearInterfaceParams()
			return OK
		)
		updateInterfaceParams obj
	)	
	fn fin = (
	
		callbacks.removeScripts #selectionSetChanged id:#objectInpectorCallbackID
		mcFile.saveDialogSettings "mcObjectInpectorDialog" "Properties_2" --save form position after close
	)
	on mcObjectInpectorDialog open do (
		
		callbacks.addScript #selectionSetChanged "mcObjectInpectorDialog.getObjectParams()" id:#objectInpectorCallbackID
		getObjectParams()
		local version = " v" + (mcFile.getScriptVersion "Object_Inspector") --get cript version
		mcObjectInpectorDialog.title = "Object Inspector:" +(if version != undefined then version else "")
	)
	on mcObjectInpectorDialog close do (fin())
	on btn_copy pressed do copyObjectData()
	on btn_paste pressed do pasteObjectData()
)

--Open dialog at pos
(
	local form_settings = mcFile.readDialogSettings "mcObjectInpectorDialog" "Properties_2" --get saved pos and size
	if form_settings != undefined then (
		
		createDialog mcObjectInpectorDialog pos:(execute (form_settings.get "pos")) menu:mcObjectInpectorMenu
		
	) else (
	
		createDialog mcObjectInpectorDialog
	)
)

--see if your callback has been registered:
--callbacks.show()