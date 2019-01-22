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
	mcDate.getUniqueId() --"2018122715851"
	"day:" + mcDate.day + " month:" + mcDate.month + " year:" + mcDate.year
*/
Struct MICRA_TIME (
private
	_cur_date = (dotNetClass "System.DateTime").Now,
	_new_date,
public
	year, month, day, hours, mins, sec, ms,
	fn getSource = getSourceFileName(), --get path of this script
	/**
	*@Usage
	
	*@Example
		mcDate.fromString "4/14/97 10:24:57 AM"
		return --> (MICRA_TIME year:"97" month:"4" day:"14" hours:"10" mins:"24" sec:"57" ms:"57000")
	*/
	fn fromString str = (
	
		local date_arr = filterString str "/\\: " --#("4", "14", "97", "10", "24", "57", "AM")
		year = date_arr[3]
		month = date_arr[1] --depends on country (can be day)
		day = date_arr[2] --depends on country (can be month)
		hours = date_arr[4]
		mins = date_arr[5]
		sec = date_arr[6]
		ms = ((execute sec)*1000) as string
		this
	),
	fn toString = (
	
		
	),
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
	fn toStringCz = (
		
		init()
		day+"_"+month+"_"+year+"_"+hours+"_"+mins
	),
	fn getUniqueId = ( --Unique ID based on Time etc... "2018122715625"
		
		init()
		year + month + day + hours + mins + ms
	),

	fn offset from_day precision:#ms = (
	
		
	)
	/*<end>*/
)
 --create instance
Global mcDate = Micra.instanceStructure MICRA_TIME "mcDate"



/*
	fn offset from_day precision:#min = (
	
		local val = (execute year) * 525948 --.766
			val += (execute month) * 43829 --.0639
			val += (execute day) * 1440
			val += (execute mins)
	)
*/