--------------------------------------------------------------------------------
/* mcNode by Orien 2019 */
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
struct MICRA_NODE_STRUCTURE	(
	
	--variables

	
	--functions
	fn getSource = getSourceFileName(), --get path of this script
	fn removeChildren obj = (for ch in obj.children do ch.parent = undefined)
	/*<end>*/
)	
 --create instance
Global mcNode = mcStructMan.instanceStructure MICRA_NODE_STRUCTURE "mcNode"
