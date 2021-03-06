Global mcObjectInpectorDialog

if mcObjectInpectorDialog != undefined do DestroyDialog mcObjectInpectorDialog
rollout mcObjectInpectorDialog "Object Inspector:" width:500 height:484
(
	GroupBox 'grp1' "Parameters:" pos:[4,8] width:492 height:236 align:#left
	GroupBox 'grp3' "Buffer:" pos:[4,300] width:492 height:152 align:#left
	
	button 'btn_copy' "Copy" pos:[4,248] width:492 height:24 align:#left
	button 'btn_paste' "Paste" pos:[4,456] width:492 height:24 align:#left
	checkbox 'chk_layer' "Layer" pos:[8,28] width:84 height:24 align:#left
	checkbox 'chk_link' "Link" pos:[8,52] width:84 height:24 align:#left
	checkbox 'chk_wcolor' "WireColor" pos:[8,84] width:84 height:24 align:#left
	checkbox 'chk_material' "Material" pos:[8,108] width:84 height:24 align:#left
	checkbox 'chk_id' "ID" pos:[8,132] width:84 height:24 align:#left
	checkbox 'chk_position' "Position" pos:[8,164] width:84 height:24 align:#left
	checkbox 'chk_rotation' "Rotation" pos:[8,188] width:84 height:24 align:#left
	checkbox 'chk_scale' "Scale" pos:[8,212] width:84 height:24 align:#left
	
	label 'lbl_layer' "..." pos:[92,28] width:396 height:24 align:#left
	label 'lbl_link' "..." pos:[92,52] width:396 height:24 align:#left
	label 'lbl_color' "..." pos:[92,84] width:396 height:24 align:#left
	label 'lbl_material' "..." pos:[92,108] width:396 height:24 align:#left
	label 'lbl_id' "..." pos:[92,132] width:396 height:24 align:#left
	label 'lbl_position' "..." pos:[92,164] width:396 height:24 align:#left
	label 'lbl_rotation' "..." pos:[92,188] width:396 height:24 align:#left
	label 'lbl_scale' "..." pos:[92,212] width:396 height:24 align:#left
	
	label 'lbl_buffer' "..." pos:[8,324] width:480 height:120 align:#left
	local params_data
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
		lbl_rotation.text  =  obj.rotation as String
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
		if chk_rotation.state do params_data.add "rotation" obj.rotation
		if chk_scale.state do params_data.add "scale" obj.scale
		
		lbl_buffer.text = ""
		for key in params_data.keys() do (

			local val = params_data.get key
			local val_str = if isProperty val "name" then val.name else val as string
			lbl_buffer.text += key + " = " + val_str + "\n"
		)			
	)
	fn pasteObjectData = (
		
		local obj = selection[1]
		if obj == undefined or params_data == undefined do return false 
		for key in params_data.keys() do (
			
			local val = params_data.get key
			case key of (
				
				"layer":val.addNode obj
				"link":obj.parent = val
				"wirecolor":obj.wirecolor = val
				"material":obj.material = val
				"position": obj.pos = val
				"rotation": obj.rotation = val
				"scale": obj.scale = val
			)
		)	
		updateInterfaceParams obj
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
	on mcObjectInpectorDialog open do (
		
		callbacks.addScript #selectionSetChanged "mcObjectInpectorDialog.getObjectParams()" id:#objectInpectorCallbackID
		getObjectParams()
	)
	on mcObjectInpectorDialog close do (callbacks.removeScripts #selectionSetChanged id:#objectInpectorCallbackID)
	on btn_copy pressed do copyObjectData()
	on btn_paste pressed do pasteObjectData()
)
CreateDialog mcObjectInpectorDialog

--see if your callback has been registered:
--callbacks.show()