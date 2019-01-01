--------------------------------------------------------------------------------
/* mcString by Orien 2019 */
--------------------------------------------------------------------------------
/*
*@Used Structures
	Micra
*
*@Used Objects

*
*/
struct MICRA_STRING (

	fn replaceSymbol str str_1 str_2 =
	(
		-->erorr block
		if str   == undefined or classOf str   != String do return ""
		if str_1 == undefined or classOf str_1 != String do return ""
		if str_2 == undefined or classOf str_2 != String do return ""
		-->function
		local str_1Pos = 0
		while str_1Pos != undefined and not keyboard.escPressed do
		( 	
			local str_1Pos = findString str str_1
			if str_1Pos   != undefined do str[str_1Pos] = str_2
		)
		str
	),
	fn replaceCharInString str inchar tochar =
	(
		for i = 1 to str.count where str[i] == inchar do str[i] = tochar
		str
	),
	fn upperLowerCase str type = --replace uper case to lower ad vice versa 
	( 
		local upperCase="ABCDEFGHIJKLMNOPQRSTUVWXYZ" --26
		local lowerCase="abcdefghijklmnopqrstuvwxyz" --26
		local arr = case type of
		(
			#Up:#(lowerCase,upperCase)
			#Down:#(upperCase,lowerCase)
		)
		for n=1 to str.count do
		(
			for s=1 to 26 do (if str[n] == arr[1][s] do str[n] = arr[2][s])
		)
		str 
	), --Call: mcString.upperLowerCase "ABCDE" #down
	fn stringToNum str = (
	
		local eval_str =  execute str --format "str:% eval:%\n" str eval_str
		case classOf eval_str of (
			
			float:eval_str
			integer:eval_str
			default:undefined	
		)
	)
)
 --create instance
Global mcString = Micra.instanceStructure MICRA_STRING "mcString"