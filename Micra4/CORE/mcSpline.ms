--------------------------------------------------------------------------------
/* mcSpline by Orien 2019 */
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
	/**
	*@Example
		newSpline = drawLineBetweenTwoPoints [10,20,30] [100,200,10]
		newSpline = drawLineBetweenTwoPoints selection[1].pos selection[1].pos
	*/
	fn drawLineBetweenTwoPoints p1 p2 = (
	
	  local ss = SplineShape pos:p1
	  addNewSpline ss
	  addKnot ss 1 #corner #line p1
	  addKnot ss 1 #corner #line p2
	  updateShape ss
	  ss
	),
	fn drawArcBetweenTwoPoints p1 p2 = ( 
	
		
	)
	/*<end>*/
)	
 --create instance
Global mcSpline = mcStructMan.instanceStructure MICRA_NEW_STRUCTURE "mcSpline"
