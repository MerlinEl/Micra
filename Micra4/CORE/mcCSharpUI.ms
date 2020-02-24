--------------------------------------------------------------------------------
/* mcCSharpUI by Orien 2019 */
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
struct MICRA_CSHARPUI_STRUCTURE	(
	
	--variables
	
	--functions
	fn getSource = getSourceFileName(), --get path of this script
	fn getClass className = (	
		case className of (
"MyNameSpace.MyClassWithArg" : (
"
using System;
namespace MyNameSpace {
	public class MyClassWithArg {
		public string arg;
		public MyClassWithArg(string thisArg) {

			arg = thisArg;
		}
		public string sayArg() {

		   return (\"MyClassWithArg.sayArg has been called.MyClassWithArg.arg = \"+ arg + \".\");
		}
	}
}
"
)		
"Rectangle2D" : (
"
using System;
public class Rectangle2D {
	public int length, width;
	// Parameterized Constructor 
	public Rectangle2D(int l, int b) {
		length = l;
		width = b;
	}
	// Method to Calculate Area  of the rectangle 
	public int Area() { 
		return length * width; 
	} 
}
"
)
"Circle2D" : (
"
abcdefg @#čžčřčžčýčýíáá = +-/		
"	
)
		)
	)
	/*<end>*/
)	
 --create instance
Global mcCSharpUI = mcStructMan.instanceStructure MICRA_CSHARPUI_STRUCTURE "mcCSharpUI"


