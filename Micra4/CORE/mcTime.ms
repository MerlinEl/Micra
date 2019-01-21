--------------------------------------------------------------------------------
/* mcTime by Orien 2019 */
--------------------------------------------------------------------------------
/*
*@Used Structures
	Micra
*
*@Used Objects

*
@Example
	mcTime.getUniqueId() --"2018122715851"
	"day:" + mcTime.day + " month:" + mcTime.month + " year:" + mcTime.year
*/
Struct MICRA_TIME (

	year, month, day, hours, mins, sec, ms,
	fn getSource = getSourceFileName(), --get path of this script
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
	fn getTime = (
		
		init()
		day+"_"+month+"_"+year+"_"+hours+"_"+mins
	),
	fn getUniqueId = ( --Unique ID based on Time etc... "2018122715625"
		
		init()
		year + month + day + hours + mins + ms
	),
	--> mcTime.fromString "4/14/97 10:24:57 AM"
	fn fromString str = (
	
		local all_arr = filterString str " "
		local date_arr = filterString all_arr[1] "/"
		local time_arr = filterString all_arr[2] ":"
		year = date_arr[3]
		month = date_arr[1] --depends on country (can be day)
		day = date_arr[2] --depends on country (can be month)
		hours = time_arr[1]
		mins = time_arr[2]
		sec = time_arr[3]
		ms = ((execute sec)*1000) as string
		this
	),
	fn toInt precision:#min = (
	
		local val = (execute year) * 525948 --.766
			val += (execute month) * 43829 --.0639
			val += (execute day) * 1440
			val += (execute mins)
	)
	/*<end>*/
)
 --create instance
Global mcTime = Micra.instanceStructure MICRA_TIME "mcTime"