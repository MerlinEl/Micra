--------------------------------------------------------------------------------
/* mcShell by Orien 2019 */
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
struct MICRA_SHELL_STRUCTURE	(
	
	--variables
	
	--functions
	fn getSource = getSourceFileName(), --get path of this script
	fn openApp app_name = (
		
		--format "app name:%\n" app_name
		case app_name of(
		
			"calc": ShellLaunch "C:\\WINDOWS\\system32\\calc.exe"
		)
	)
	/*<end>*/
)	
 --create instance
Global mcShell = mcStructMan.instanceStructure MICRA_SHELL_STRUCTURE "mcShell"
