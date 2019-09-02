Global mcQuickMaterialsDialog
if mcQuickMaterialsDialog != undefined do destroyDialog mcQuickMaterialsDialog
rollout mcQuickMaterialsDialog "Quick Materials:" width:292 height:92
(
	button 'btn_apply' "Apply" pos:[12,48] width:108 height:28 align:#left
	dropdownList 'ddl_mat_names' "" pos:[84,24] width:104 height:21 items:#("grass", "pavement", "bricks", "dirt") align:#left
	label 'lbl1' "Add material" pos:[16,28] width:64 height:12 align:#left
	GroupBox 'grp1' "Set-Up:" pos:[4,4] width:284 height:84 align:#left
	label 'lbl2' "to selected faces." pos:[192,28] width:92 height:12 align:#left
	fn addTempMaterial obj mod_name = (
		
		if classOf obj != Editable_Poly do return false
		local mod_id, u_tile, v_tile, mod_name, sublevel = subobjectLevel
		local mod_uvw = uvwMap maptype:0 mapChannel:1 realWorldMapSize:false name:mod_name
		mod_uvw.axis = 2
		modPanel.addModToSelection mod_uvw -- Add UVW Map Modifier to selection 
		format "mo w:% h:% name:%\n" mod_uvw.width mod_uvw.length mod_name
		case mod_name of (

			"grass"		: (
				
				u_tile = mod_uvw.width * 0.004
				v_tile = mod_uvw.length * 0.004
				mod_id = Materialmodifier materialID:140
			)
			"dirt"		: (
				
				u_tile = mod_uvw.width * 0.004
				v_tile = mod_uvw.length * 0.004
				mod_id = Materialmodifier materialID:103 
			)
			"bricks"		: (
				
				u_tile = mod_uvw.width * 0.004
				v_tile = mod_uvw.length * 0.004
				mod_id = Materialmodifier materialID:54 
			)
			"pavement"	: (

				u_tile = mod_uvw.width * 0.0016
				v_tile = mod_uvw.length * 0.0032
				mod_id = Materialmodifier materialID:53
			)
			default		: (

				u_tile = mod_uvw.width * 0.0016
				v_tile = mod_uvw.length * 0.0032
				mod_id = Materialmodifier materialID:1 
			)
		)
		mod_uvw.utile = u_tile	--length is in generic units
		mod_uvw.vtile = v_tile	--width is in generic units
		modPanel.addModToSelection  mod_id	
		maxOps.CollapseNodeTo obj 1 true
		if sublevel != undefined do subobjectLevel = sublevel
	)

	button 'btn_close' "Close" pos:[172,48] width:108 height:28 align:#left
	on btn_apply pressed do addTempMaterial $ ddl_mat_names.selected
	on btn_close pressed do destroyDialog mcQuickMaterialsDialog

)
createDialog mcQuickMaterialsDialog