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
	)
	/*<end>*/
)	
 --create instance
Global mcActionsTukej = mcStructMan.instanceStructure MICRA_TUKEJ_STRUCTURE "mcActionsTukej"
