--------------------------------------------------------------------------------
/* mcUIColors by Orien 2019 */
--------------------------------------------------------------------------------
/*
*@Used Structures
	Micra
	mcFile
*
*@Used Objects


*@Example:
	mcUIColors.get #back
	or
	mcDotnet.uiColor #back
*/
Struct MICRA_UI_COLORS(

Public
	fn getSource = getSourceFileName(), --get path of this script
	fn get clr = (
		local last_profile = execute (mcFile.readSettings Micra.UserSettings "Interface/lastprofile")
		local profiles = #("DefaultColor", "UserColor", "ForestColor", "EarthColor", "MoonColor", "SeaColor", "SunColor")
		local head_str = profiles[last_profile]
		case clr of (
			
			#back		: execute (mcFile.readSettings Micra.UserSettings (head_str +"/backcolor"))
			#fore		: execute (mcFile.readSettings Micra.UserSettings (head_str +"/forecolor"))
			#sel		: execute (mcFile.readSettings Micra.UserSettings (head_str +"/selected" ))
			#mark		: execute (mcFile.readSettings Micra.UserSettings (head_str +"/marked" ))
			#btn		: execute (mcFile.readSettings Micra.UserSettings (head_str +"/button"  ))
			#inact		: execute (mcFile.readSettings Micra.UserSettings (head_str +"/inactive" ))
			#text		: execute (mcFile.readSettings Micra.UserSettings (head_str +"/textcolor" ))
			#seltext	: execute (mcFile.readSettings Micra.UserSettings (head_str +"/seltext" ))
			#opacity	: execute (mcFile.readSettings Micra.UserSettings (head_str +"/opacity" )) --remove it because is not color and mcDotnet.uiColor #opacity == undefined
			#edtback	: execute (mcFile.readSettings Micra.UserSettings (head_str +"/editback" ))
			#edtfore	: execute (mcFile.readSettings Micra.UserSettings (head_str +"/editfore" ))
		)
	)
	/*<end>*/
)
 --create instance
Global mcUIColors = mcStructMan.instanceStructure MICRA_UI_COLORS "mcUIColors"