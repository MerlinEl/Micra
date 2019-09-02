Global mcQuickMaterialsDialog
if mcQuickMaterialsDialog != undefined do destroyDialog mcQuickMaterialsDialog
rollout mcQuickMaterialsDialog "Quick Materials:" width:288 height:288
(
	struct MAT_ITEM (key, id)
	local items_pattern = #(
		
		MAT_ITEM "grass" 140,
		MAT_ITEM "pavement1" 53,
		MAT_ITEM "pavement2" 58,
		MAT_ITEM "pavement3" 50, 
		MAT_ITEM "bricks1" 54, 
		MAT_ITEM "bricks2" 59,  
		MAT_ITEM "bricks3" 51, 
		MAT_ITEM "dirt" 103,
		MAT_ITEM "asphalt" 3
	)
	button 'btn_apply' "Apply" pos:[8,252] width:100 height:28 align:#left
	dropdownList 'ddl_mat_names' "" pos:[84,24] width:104 height:21 align:#left
	label 'lbl1' "Add material" pos:[16,28] width:64 height:12 align:#left
	GroupBox 'grp1' "Set-Up:" pos:[4,4] width:280 height:280 align:#left
	label 'lbl2' "to selected faces." pos:[192,28] width:92 height:12 align:#left
	button 'btn_close' "Close" pos:[176,252] width:100 height:28 align:#left
	checkbox 'chk_collapse' "collapse" pos:[112,260] width:56 height:16 checked:true align:#left
	bitmap 'bmp_preview' "Bitmap" pos:[12,48] width:264 height:200 align:#left
	local current_mat_id = 140
	fn getMatIDByName mod_name = (
		
		for itm in items_pattern where itm.key == mod_name do return itm.id
	)
	fn addTempMaterial obj mod_name = (
		
		if classOf obj != Editable_Poly do return false
		local mod_matid, u_tile, v_tile, mod_name, sublevel = subobjectLevel
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
			)			
			"asphalt"		: (
				
				u_tile = mod_uvw.width * 0.004
				v_tile = mod_uvw.length * 0.004
			)			
			"dirt"		: (
				
				u_tile = mod_uvw.width * 0.004
				v_tile = mod_uvw.length * 0.004
			)
			"bricks1"		: (
				
				u_tile = mod_uvw.width * 0.004
				v_tile = mod_uvw.length * 0.004
			)
			"bricks2"		: (
				
				u_tile = mod_uvw.width * 0.004
				v_tile = mod_uvw.length * 0.004
			)
			"bricks3"		: (
				
				u_tile = mod_uvw.width * 0.009
				v_tile = mod_uvw.length * 0.009
			)
			"pavement1"	: (

				u_tile = mod_uvw.width * 0.0016
				v_tile = mod_uvw.length * 0.0032
			)
			"pavement2"	: (

				u_tile = mod_uvw.width * 0.0025
				v_tile = mod_uvw.length * 0.0025
			)
			"pavement3"		: (
				
				u_tile = mod_uvw.width * 0.0012
				v_tile = mod_uvw.length * 0.0025
			)
			default		: (

				u_tile = mod_uvw.width * 0.0016
				v_tile = mod_uvw.length * 0.0032
			)
		)
		local mat_id = getMatIDByName mod_name
		mod_matid = Materialmodifier materialID:mat_id
		mod_uvw.utile = u_tile	--length is in generic units
		mod_uvw.vtile = v_tile	--width is in generic units
		modPanel.addModToSelection  mod_matid	
		if chk_collapse.checked do maxOps.CollapseNodeTo obj 1 true
		if sublevel != undefined do subobjectLevel = sublevel
	)
	fn stretchBitmapTo bm w h = (
		
		local bb= bitmap w h color:black 
		local tx = bitmaptexture bitmap:bm
		rendermap tx into:bb size:[bb.width,bb.height] filter:on display:off	
		bb
	)
	fn previewMaterial mat_id = (
		
		local terrain_mat = meditMaterials["lh_terain"]
		if terrain_mat == undefined do return false
		local mat = terrain_mat[mat_id]
		local bm = case classOf mat of (

			DirectX_9_Shader: (
				
				local mt = mat.renderMaterial
				local dm = if classOf mt == LS3DMaterial then mt.diffuseMap else undefined
				if dm != undefined then dm.bitmap else undefined
			)
			LS3DMaterial: (

				local dm = mt.diffuseMap
				if dm != undefined then dm.bitmap else undefined
			)
			default: undefined
		)
		if classOf bm == BitMap do bmp_preview.bitmap = stretchBitmapTo bm 264 200
	)
	fn init = (
		
		ddl_mat_names.items = for itm in items_pattern collect itm.key
		previewMaterial current_mat_id
	)
	on mcQuickMaterialsDialog open do init()
	on ddl_mat_names selected sel do previewMaterial (getMatIDByName ddl_mat_names.items[ sel ])
	on btn_apply pressed do (addTempMaterial $ ddl_mat_names.selected)
	on btn_close pressed do (destroyDialog mcQuickMaterialsDialog)
)
createDialog mcQuickMaterialsDialog