--------------------------------------------------------------------------------
/* mcDate by Orien 2019 */
--------------------------------------------------------------------------------
/*
*@Used Structures
	Micra
*
*@Used Objects

*
@Example
	(mcDate.current()).toString() --"1/22/2019 3:38:26 PM"
	(mcDate.current()).getUniqueId() --"4242019123949"
	(mcDate.fromString "1/10/2019 12:00:00 PM").offset units:#days --12.1706 days
*/
Struct MICRA_DATE (
private
	_cur_date = (dotNetClass "System.DateTime").Now, --default is current time
public
	fn getSource = getSourceFileName(), --get path of this script
	fn current = (_cur_date = (dotNetClass "System.DateTime").Now; this),
	/**
	*@Usage
	
	*@Example
		tm = mcDate.fromString "4/24/2019 12:39:49 PM"
		tm.toString() --"4/24/2019 12:39:49 PM"
		tm.toStringSimple() --"4_24_2019_12_39_49"
	*/
	fn fromString str = (
		--dotNetObject:System.DateTime
		_cur_date = (dotNetClass "System.DateTime").parse str
		this
	),
	/**
	*@Examlpe
		(mcDate.current()).toString()
		"1/22/2019 3:34:48 PM"
	*/
	fn toString = (_cur_date.toString()),
	/**
	*@Examlpe
		mcDate.toStringSimple() --return last used mcDate time
		or
		(mcDate.current()).toStringSimple() --always return current date
		"4_24_2019_12_39_49"
		or 
		(mcDate.fromString "4/24/2019 12:00:00 PM").toStringSimple() --return user date
		"4_24_2019_12_00_00"
	*/
	fn toStringSimple = (
	
		local str = toString() --"4/24/2019 12:39:49 PM"
		local date_arr = filterString str "/\\: " --#("4", "24", "2019", "12", "39", "49", "PM")
		local new_str = ""
		for i=1 to date_arr.count-1 do new_str += date_arr[i] + (if i < date_arr.count - 1 then "_" else "")
		new_str --"4_24_2019_12_39_49"
	),
	fn year = (_cur_date.date.Year), 
	fn month = (_cur_date.date.Month), 
	fn day = (_cur_date.date.Day), 
	fn hours = (_cur_date.date.Hour), 
	fn mins = (_cur_date.date.Minute), 
	fn sec = (_cur_date.date.Second), 
	fn ms = (_cur_date.date.Millisecond),
	/**
	*@Usage
		Unique ID based on Time etc... "2018122715625"
		year + month + day + hours + mins + ms
	*@Example
		(mcDate.current()).getUniqueId()
		"122201944228",
		"122201944229",
		"122201944229",
		"122201944230",...
	*/
	fn getUniqueId = (
		
		local id = toStringSimple()
		substituteString id "_" ""
	),
	/**
	*@Usage
		get diference between two days in (current time - user time)
	*@Example
		local user_time = getFileModDate f --file_mod_date("1/10/2019 12:00:00 PM")
		(mcDate.fromString user_time).offset units:#days
		12.1706
	*/
	fn offset units:#ms = (
	
		local now = (dotNetClass "System.DateTime").Now --"1/22/2019 4:05:35 PM"
		--format "date current:% user:%\n" (now.toString()) (toString())
		local ts = now.Subtract(_cur_date) --dotNetObject:System.TimeSpan
		local units_double = case units of (
		
			#days	: ts.TotalDays
			#hours	: ts.TotalHours
			#mins	: ts.TotalMinutes
			#sec	: ts.TotalSeconds
			#ms		: ts.Milliseconds
		)
		units_double as Float --12.1706 days
	)
	/*<end>*/
)
 --create instance
Global mcDate = Micra.instanceStructure MICRA_DATE "mcDate"




/*
--old way
fn init = (
	
	local all = getLocalTime() --#(2019, 1, 1, 21, 19, 38, 15, 594)
	year = all[1] as String 
	month = all[2] as String 
	day = all[4] as String 
	hours = all[5] as String 
	mins = all[6] as String 
	sec = all[7] as String 
	ms = all[8] as String 
	OK
),
*/