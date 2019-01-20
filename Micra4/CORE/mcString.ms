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
	testr = "So after we did that we copy the files to the following directories:",
Private
	/**
	*@Usage
		value:int 	input number
		min_val:int	minimum value	
		max_val:int	maximum value
		return:int	min, max or value
	*@Example
		mcMath.minMax 100	1	50	--> 50
		mcMath.minMax -1	1	50	--> 1
		mcMath.minMax 100	1	200	--> 100
	*/
	fn minMax value min_val max_val = (
	
		value = amax #(value, min_val) --min
		value = amin #(value, max_val) --max
	),
Public
	fn getSource = getSourceFileName(), --get path of this script
	fn charAt str index = (str[index]), --mcString.charAt mcString.testr 5
	--fn indexOf str value = (findstring str value), --mcString.indexOf mcString.testr "we"
	/**
	*@Usage 
		str:String			source
		value:String		search string
		startIndex:int		search start index
		count:int			how many chars will step forward from startIndex (startIndex + count !> str.count)
		ignore_case:Boolean	ignore case	
		return:int			index or undefined
	*@Example
		first_index = mcString.indexOf mcString.testr "we" ignore_case:true  --> 10 
		first_index = mcString.indexOf mcString.testr "WE" ignore_case:false --> undefined 
		next_index  = mcString.indexOf mcString.testr "we" startIndex:(first_index+"we".count) count:2 --> undefined
		next_index  = mcString.indexOf mcString.testr "we" startIndex:(first_index+"we".count) count:-1 --> 22
		next_index  = mcString.indexOf mcString.testr "we" startIndex:(first_index+"we".count) count:12 --> 22
	*/
	fn indexOf str value startIndex:0 count:-1 ignore_case:true = (	
	
		if startIndex == undefined do startIndex = 0
		if count == undefined do count = -1
		startIndex -= 1 --conversion field start( max = 1 , dotnet = 0 )
		startIndex = minMax startIndex 0 (str.count-1) --min max cap		
		if count < 0 do count = str.count-1 -- if cnt == -1 then set max count
		count = amin #(count, str.count - startIndex - 1) --max cap
		--format "mcString > findStringAt >\n\tstr:%\n\tvalue:% startIndex:% count:% ignore_case:%\n" str value startIndex count ignore_case
		global ds = dotnetObject "System.String" str
		local find_index = (
			local comp = dotnetClass "System.StringComparison"
			if ignore_case
				then ds.indexOf value startIndex count comp.CurrentCultureIgnoreCase
				else ds.indexOf value startIndex count comp.Ordinal
		)
		if find_index == -1 then undefined else find_index+1
	),
	fn lastIndexOf str value = (local ds = dotnetObject "System.String" str; ds.lastIndexOf value),
	fn contains str value = (findstring str value != undefined), --mcString.contains mcString.testr "we"
	fn split str value = (filterString str value), --mcString.split mcString.testr " "
	fn dSplit str value = (local ds = dotnetObject "System.String" str; ds.split value), --dotnet version Test
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
	*@Usage	Find and replace first identicle word
	*@Example
		local str = "So after we did that we copy the files to the following directories:"
		mcString.replace str "we" "he"
		--> "So after he did that we copy the files to the following directories:"
	*/
	fn replace str old_str new_str = (
	
		local find_index = findString str old_str
		if find_index != undefined do ::replace str find_index old_str.count new_str
	),
	/**
	*@Usage	Find and replace all identicle word
	*@Example 
		str = "So after we did that we copy the files to the following directories:"
		mcString.replaceAll str "we" "she"
		--> "So after she did that she copy the files to the following directories:"
	*/
	fn replaceAll str old_str new_str = (
		
		local rgx = dotnetObject "System.Text.RegularExpressions.Regex" old_str
		rgx.Replace str new_str
	),
	fn dRreplaceAll str old_str new_str = (local dstr = dotnetObject "System.String" str; dstr.replace old_str new_str), --dotnet version Test
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
	/**
	*@Usage	Correct filename
	*@Example
		fileP = "C:temp\temp Folder\\newFolder/tempFile.xxx"
		--> C:temp	emp Folder\newFolder/tempFile.xxx
		mcString.correctPath fileP
		--> C:temp\temp Folder\newFolder\tempFile.xxx
	*/
	fn correctPath str = (

		str = substituteString str "\n" "\\n"
		str = substituteString str "\t" "\\t"
		str = substituteString str "/" "\\"
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
	/* Not tested
	,
	fn tabulate str = (
	
		local t = "	"	-- tab character
		local r = "
"						-- return character
		local str2 = t + t
		while not (eof str) do
		(
			char = (readChar str)
			if char != "\n" then str2 += char
			else str2 += (r + t + t)
		)
		close str
		str2
	)*/
	/*<end>*/
)
 --create instance
Global mcString = Micra.instanceStructure MICRA_STRING "mcString"



/**
*@Example
	local str = "So after we did that we copy the files to the following directories:"
	local first_we_index  = findString str "we"
	local second_we_index = mcString.findStringAt str "we" (first_we_index+"we".count)
	substring str second_we_index -1
	--> "we copy the files to the following directories:"

fn findStringAt str value start_index = (

	if start_index > str.count do return undefined
	if start_index == 1 do return findString str value
	local str_rest = substring str start_index -1
	local next_index = findString str_rest value
	--format "mcString > findStringAt > str:%\n\tstr_rest:%\n\tstart_index:% next_index:%\n" str str_rest start_index next_index
	if next_index == undefined then undefined else start_index+next_index-1 
),
*/

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