--------------------------------------------------------------------------------
/* mcActionsTukej by Orien 2019 */
--------------------------------------------------------------------------------
/*
*@Used Structures
	mcStructMan
*
*@Used Objects
	undefined
*
*@Usage
	undefined
*
*@Example	
	undefined
*
*/
struct MICRA_TUKEJ_STRUCTURE	(
	
	--variables

	
	--functions
	fn getSource = getSourceFileName(), --get path of this script
	fn smartLS3DExport = (
		
		macros.run "LS3D Engine" "LS3DSmartExport"
	),
	fn directXLS3DSwitch = (
		
		if ::gLS3DDXSupport != undefined do ::gLS3DDXSupport.OpenConfigDialog()
	),
	fn testNormalMapToggle = (
		
		mcMaterial.normalmapTesterToggle tile_uv:[4, 4]
	),
	fn selectPlayer = (
		
		local player_obj =  (for o in objects where findString o.name "temp_player_lincoln_ruler" != undefined collect o)[1]
		if player_obj != undefined do (
			
			select player_obj
			player_obj.isHidden = false
			if keyboard.controlPressed do max zoomext sel
		)
	),
	fn moveObjectToFusionPos = (
		
		
		if Keyboard.shiftPressed do ( --copy pos to fusion
			
			if selection.count == 0 do return false
			format "Copy position for fusion\n"
			format "\tmax pos:%\n" selection[1].pos
			local fusion_pos = (selection[1].pos / 100)
			format "\tfusion pos:%\n" fusion_pos
			setclipboardtext fusion_pos
			return OK
		)
		
		local obj = getNodeByName "FusionPositionMarker" --try to pick marker if is already created
		format "Pick FusionPositionMarker:%\n" (obj!=undefined)
		if obj == undefined  do ( --create new marker
			
			obj = pyramid width:100 height:-400 depth:100 name:"FusionPositionMarker"
			obj.pivot.z -= 400
			obj.material = standardMaterial useSelfIllumColor:false selfIllumAmount:100 Diffuse:(color 255 0 234)	
			format "Create new FusionPositionMarker.\n" 
		)
				subobjectlevel = 0
				select obj
		
		local fusion_pos_str = getclipboardtext()
		if fusion_pos_str.count == 0 do return false
		local fusion_pos_arr = filterString fusion_pos_str ","
		if fusion_pos_arr.count != 3 do return false
		format "\tfusion pos:%\n" fusion_pos_str
		local fusion_pos = execute ("["+fusion_pos_arr[1]+","+fusion_pos_arr[2]+","+fusion_pos_arr[3]+"]")
		local p = fusion_pos * 100
		format "\tmax pos:%\n" p
		obj.pos = p
		mcMax.zoomToSelection()
	)
	/*<end>*/
)	
 --create instance
Global mcActionsTukej = mcStructMan.instanceStructure MICRA_TUKEJ_STRUCTURE "mcActionsTukej"
