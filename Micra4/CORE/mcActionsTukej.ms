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
		
		local player_obj =  (for o in objects where findString o.name "player" != undefined collect o)[1]
		if player_obj != undefined do (
			
			select player_obj
			player_obj.isHidden = false
			if keyboard.controlPressed do max zoomext sel
		)
	)
	/*<end>*/
)	
 --create instance
Global mcActionsTukej = mcStructMan.instanceStructure MICRA_TUKEJ_STRUCTURE "mcActionsTukej"
