--------------------------------------------------------------------------------
/* mcMax by Orien 2019 */
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
struct MICRA_MAX_STRUCTURE	(
	
	--variables

	
	--functions
	fn getSource = getSourceFileName(), --get path of this script
	fn alignObject = (max align)
	/*<end>*/
)	
 --create instance
Global mcMax = mcStructMan.instanceStructure MICRA_MAX_STRUCTURE "mcMax"
