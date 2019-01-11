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

	breakline = "----------------------------------------------------------------------------------------------------------------------------------",
	fn getSource = getSourceFileName(), --get path of this script
	/**
	*@Usage 
		Trims all leading characters specified in trimChars from the given string and returns it. 
		If trimChars is not specified, basic whitespace characters (space, tab, and newlines) are trimmed.
	*/
	fn trimLeftRight str trimChars:undefined = (
	
		if trimChars == undefined then (
		
			str = trimLeft str
			str = trimRight str
		) else (
		
			str = trimLeft str trimChars
			str = trimRight str trimChars
		)
	),
	/**
	*@Example 
		result = mcString.replaceInString "221, Micra.fileInVersion 3DGallery, 3D Gallery" ", " ","
		"221,Micra.fileInVersion 3DGallery,3D Gallery"
	*/
	fn replaceInString str old_str new_str = (
		
		local pattern = "\\"+old_str
		local rgx = dotnetObject "System.Text.RegularExpressions.Regex" pattern
		rgx.Replace str new_str
	),
	/**
	*Still Testing 2019
	*@Example
		mcString.printInBlock "a: % b: %" params:#(1, 2)
		mcString.printInBlock "Customize > addNewAction > \n\tcatalog\t: %\n\taction\t: % \n\tdata\t: %\n" params:#(action_category, action_key, action_data)
	*/
	fn printInBlock str params:#() = (
		
		if findString str "%" == undefined do (
		
			format "%\n%\n%\n" breakline str breakline
			return OK
		)
	
		local out_string = breakline + "\n"
		local arr = filterString str "%"
		/*if arr.count  != params.count do (
		
			format "mcString > printInBlock > Arguments not match pattern str:% params:%\n" arr.count params.count
			return false
		)*/
		local out_string = breakline + "\n"
		for i = 1 to arr.count do 
		(
			if params[i] == undefined do continue --skip last line if
			out_string += arr[i] + params[i] as string
		)
		--format "%\n%\n%\n" breakline str breakline
		out_string += "\n" + breakline + "\n"
		format out_string
		
	),
	--This one is old causing error when multiple string replace REMOVE (use replaceInString)
	fn replaceSymbol str find_str new_str =
	(
		-->erorr block
		if classOf str   != String do return ""
		if classOf find_str != String do return ""
		if classOf new_str != String do return ""
		-->function
		local index = 0
		while index != undefined and not keyboard.escPressed do ( 	
		
			local index = findString str find_str
			if index != undefined do str[index] = new_str
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



/*
	--fn replaceInString input find_str new_str = (
	--str.replace(/\s/gi, "_"); 
	--)
		fn replaceSpaces input new_str = (
	
		local pattern = @"\s+"
		local rgx = dotnetObject "System.Text.RegularExpressions.Regex" pattern
		rgx.Replace input new_str
	)

REGEX
	----------------------------------------------------------------------------------------------------------------------
	--Replace space(s) with none another character
	----------------------------------------------------------------------------------------------------------------------
	
	pattern = @"\s+"
	input =  "This is       text with        far  too       much       whitespaces"
	rgx = dotnetObject "System.Text.RegularExpressions.Regex" pattern
	result = rgx.Replace input " "
	print input
	format "Pattern is : %\n" (rgx.toString())
	print result
	
	"This is       text with        far  too       much       whitespaces"
	"This is text with far too much whitespaces"
	
	----------------------------------------------------------------------------------------------------------------------
	--Check if pattern is match
	----------------------------------------------------------------------------------------------------------------------
	
	str = "maps/nature/water_canals_water2_0_0_1009_depth_39"
	rgx = dotnetObject "System.Text.RegularExpressions.Regex" ""
	match_patern = rgx.IsMatch str ".+_-?\\d+_-?\\d+_-?\\d+_depth_-?\\d+$"
	print str
	format "Pattern is : %\n" (rgx.toString())
	print match_patern
	
	----------------------------------------------------------------------------------------------------------------------
*/