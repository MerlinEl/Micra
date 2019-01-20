--------------------------------------------------------------------------------
/* mcCursor by Orien 2019 */
--------------------------------------------------------------------------------
/*
*@Used Structures
	Micra
*
*@Used Objects

*@Example:
	mcCursor.get #cursor
*/
Struct MICRA_CURCOR (

	fn getSource = getSourceFileName(), --get path of this script
	fn get type = (
		return case type of (
			
			#cursor	: dotNetClass "System.Windows.Forms.cursor"
			#cross	:dotNetObject "System.Windows.Forms.Cursor" (Micra.ImgPath+"cross.ico")
			#pipe		: dotNetObject "System.Windows.Forms.Cursor" (Micra.ImgPath+"pipe.ico")
			#fill		: dotNetObject "System.Windows.Forms.Cursor" (Micra.ImgPath+"fill.ico")
			#arrow	: dotNetObject "System.Windows.Forms.Cursor" (Micra.ImgPath+"harrow.ico")
			#grab	: dotNetObject "System.Windows.Forms.Cursor" (Micra.ImgPath+"hmove.ico")	
		)
	)
	/*<end>*/
)
--create instance
Global mcCursor = Micra.instanceStructure MICRA_CURCOR "mcCursor"
