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
		
		local obj = selection[1]
		if obj == undefined do return false
		local fusion_pos_str = getclipboardtext()
		if fusion_pos_str.count == 0 do return false
		local fusion_pos_arr = filterString fusion_pos_str ","
		if fusion_pos_arr.count != 3 do return false
		local fusion_pos = execute ("["+fusion_pos_arr[1]+","+fusion_pos_arr[2]+","+fusion_pos_arr[3]+"]")
		local p = fusion_pos * 100
		obj.pos = p
	),
	fn moveObjectToFusionPos = (
		
		local obj = selection[1]
		if obj == undefined do return false
		local fusion_pos_str = getclipboardtext()
		if fusion_pos_str.count == 0 do return false
		local fusion_pos_arr = filterString fusion_pos_str ","
		if fusion_pos_arr.count != 3 do return false
		local fusion_pos = execute ("["+fusion_pos_arr[1]+","+fusion_pos_arr[2]+","+fusion_pos_arr[3]+"]")
		local p = fusion_pos * 100
		undo "Move To Fusion Pos" on obj.pos = p
	)
	/*<end>*/
)	
 --create instance
Global mcActionsTukej = mcStructMan.instanceStructure MICRA_TUKEJ_STRUCTURE "mcActionsTukej"
