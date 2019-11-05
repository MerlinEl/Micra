--------------------------------------------------------------------------------
/* mcMouse by Orien 2019 */
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
struct MICRA_NEW_STRUCTURE	(
	
	--variables

	
	--functions
	fn getSource = getSourceFileName(), --get path of this script
	fn getObjectsUnderMouse = (

		(boxPickNode (box2 (mouse.pos - [2,2]) (mouse.pos + [2,2])) crossing:true )
	)
	/*<end>*/
)	
 --create instance
Global mcMouse = mcStructMan.instanceStructure MICRA_NEW_STRUCTURE "mcMouse"
