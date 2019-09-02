Global mcQuickMaterialsDialog
if mcQuickMaterialsDialog != undefined do destroyDialog mcQuickMaterialsDialog
rollout mcQuickMaterialsDialog "Quick Materials:" width:292 height:92
(
	button 'btn_apply' "Apply" pos:[12,48] width:100 height:28 align:#left
	dropdownList 'ddl_mat_names' "" pos:[84,24] width:104 height:21 items:#("grass", "pavement1", "pavement2", "pavement3", "bricks1", "bricks2", "bricks3", "dirt", "asphalt") align:#left
	label 'lbl1' "Add material" pos:[16,28] width:64 height:12 align:#left
	GroupBox 'grp1' "Set-Up:" pos:[4,4] width:284 height:84 align:#left
	label 'lbl2' "to selected faces." pos:[192,28] width:92 height:12 align:#left
	button 'btn_close' "Close" pos:[180,48] width:100 height:28 align:#left
	checkbox 'chk_collapse' "collapse" pos:[116,56] width:56 height:16 align:#left checked:true
	fn addTempMaterial obj mod_name = (
		
		if classOf obj != Editable_Poly do return false
		local mod_id, u_tile, v_tile, mod_name, sublevel = subobjectLevel
		max modify mode
		--all terrains must use one multimaterial
		if obj.material == undefined or obj.material.name != "lh_terain" do ( 
			
			local terrain_mat = meditMaterials["lh_terain"]
			if terrain_mat == undefined do (
					
				messageBox "Terrain Material Not Found" title:"Aborted"
				return false
			)
			obj.material = terrain_mat
		)
		--continute to add and setup modifiers
		local mod_uvw = uvwMap maptype:0 mapChannel:1 realWorldMapSize:false name:mod_name
		mod_uvw.axis = 2
		modPanel.addModToSelection mod_uvw -- Add UVW Map Modifier to selection 
		--format "mo w:% h:% name:%\n" mod_uvw.width mod_uvw.length mod_name
		case mod_name of (

			"grass"		: (
				
				u_tile = mod_uvw.width * 0.004
				v_tile = mod_uvw.length * 0.004
				mod_id = Materialmodifier materialID:140
			)			
			"asphalt"		: (
				
				u_tile = mod_uvw.width * 0.004
				v_tile = mod_uvw.length * 0.004
				mod_id = Materialmodifier materialID:3
			)			
			"dirt"		: (
				
				u_tile = mod_uvw.width * 0.004
				v_tile = mod_uvw.length * 0.004
				mod_id = Materialmodifier materialID:103 
			)
			"bricks1"		: (
				
				u_tile = mod_uvw.width * 0.004
				v_tile = mod_uvw.length * 0.004
				mod_id = Materialmodifier materialID:54 
			)
			"bricks2"		: (
				
				u_tile = mod_uvw.width * 0.004
				v_tile = mod_uvw.length * 0.004
				mod_id = Materialmodifier materialID:59
			)
			"bricks3"		: (
				
				u_tile = mod_uvw.width * 0.009
				v_tile = mod_uvw.length * 0.009
				mod_id = Materialmodifier materialID:51
			)
			"pavement1"	: (

				u_tile = mod_uvw.width * 0.0016
				v_tile = mod_uvw.length * 0.0032
				mod_id = Materialmodifier materialID:53
			)
			"pavement2"	: (

				u_tile = mod_uvw.width * 0.0025
				v_tile = mod_uvw.length * 0.0025
				mod_id = Materialmodifier materialID:58
			)
			"pavement3"		: (
				
				u_tile = mod_uvw.width * 0.0012
				v_tile = mod_uvw.length * 0.0025
				mod_id = Materialmodifier materialID:50
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
		if chk_collapse.checked do maxOps.CollapseNodeTo obj 1 true
		if sublevel != undefined do subobjectLevel = sublevel
	)
	on btn_apply pressed do (addTempMaterial $ ddl_mat_names.selected)
	on btn_close pressed do (destroyDialog mcQuickMaterialsDialog)
)
createDialog mcQuickMaterialsDialog