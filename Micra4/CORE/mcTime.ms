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

	all, year, month, day, hours, mins, ms,
	fn getSource = getSourceFileName(), --get path of this script
	fn init = (
		
		all = getLocalTime()
		year = all[1] as String 
		month = all[2] as String 
		day = all[4] as String 
		hours = all[5] as String 
		mins = all[6] as String 
		ms = all[7] as String 
		OK
	),
	fn getTime = (
		
		init()
		day+"_"+month+"_"+year+"_"+hours+"_"+mins
	),
	fn getUniqueId = ( --Unique ID based on Time etc... "2018122715625"
		
		init()
		year + month + day + hours + mins + ms
	)
)
 --create instance
Global mcTime = Micra.instanceStructure MICRA_TIME "mcTime"