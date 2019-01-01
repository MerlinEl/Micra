--------------------------------------------------------------------------------
/* mcUIColors by Orien 2019 */
--------------------------------------------------------------------------------
/*
*@Used Structures
	Micra
	mcFile
*
*@Used Objects

*
*@Example:
	mcUIColors.get #back
*/
Struct MICRA_UI_COLORS(
	
	fn get clr = (
		
		local last_profile = execute (mcFile.saveLoadIniSetings head:"Interface" key:"lastprofile" action:#load)
		local profiles = #("DefaultColor", "UserColor", "ForestColor", "EarthColor", "MoonColor", "SeaColor", "SunColor", "Close")
		local head_str = profiles[last_profile]
		case clr of (
			
			#back		: execute (mcFile.saveLoadIniSetings head:head_str key:"backcolor" action:#load)
			#fore		: execute (mcFile.saveLoadIniSetings head:head_str key:"forecolor" action:#load)
			#sel			: execute (mcFile.saveLoadIniSetings head:head_str key:"selected"  action:#load)
			#mark		: execute (mcFile.saveLoadIniSetings head:head_str key:"marked"  action:#load)
			#btn			: execute (mcFile.saveLoadIniSetings head:head_str key:"button"   action:#load)
			#inact		: execute (mcFile.saveLoadIniSetings head:head_str key:"inactive"  action:#load)
			#text		: execute (mcFile.saveLoadIniSetings head:head_str key:"textcolor"  action:#load)
			#seltext	: execute (mcFile.saveLoadIniSetings head:head_str key:"seltext"  action:#load)
			#opacity	:execute (mcFile.saveLoadIniSetings head:head_str key:"opacity"  action:#load)
			#edtback	:execute (mcFile.saveLoadIniSetings head:head_str key:"editback"  action:#load)
			#edtfore	:execute (mcFile.saveLoadIniSetings head:head_str key:"editfore"  action:#load)
		)
	)
)
 --create instance
Global mcUIColors = Micra.instanceStructure MICRA_UI_COLORS "mcUIColors"