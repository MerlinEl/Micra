--> collect all autobaks files
try (BackupFiles = getfiles ((GetDir #Maxroot) + "\\autoback\\Autobak?.*")) catch (backupfile = #())
--> get the date on each file
if BackupFiles.count != 0 then
	(
	Files_Date   = #()
	Array_Date   = #()
	Array_Year   = #()
	Array_Month  = #()
	Array_Day    = #()
	Array_Hour   = #()
	Array_Minute = #()
	Final_Check  = #()
	for i in 1 to BackupFiles.count do
		(
		--get file date => "7/13/2005 11:39:22 PM"
		Files_Date[i] = (GetFileModDate BackupFiles[i]) 	
		--break date to parts  => #("7", "13", "2005", "11", "39", "22", "PM")
		Array_Date[i] = filterString Files_Date[i] "/ :"   
		
		Array_Year[i]   = (Array_Date[i] [3])--collect all years
		Array_Month[i]  = (Array_Date[i] [1])--collect all months
		Array_Day[i]    = (Array_Date[i] [2])--collect all days
		Array_Hour[i]   = (Array_Date[i] [4])--collect all hours
		Array_Minute[i] = (Array_Date[i] [5])--collect all minutes
		Final_Check[i]  = (Array_Date[i] [5])--collect all minutes
		)
	)
fn Del_Arr_Lower items =
	(
	local y ="amin "
	for i in 1 to items.count do (y +=  (items[i] as string)+" ")
	local z = (execute y)
	local n = (findItem items (z as string))

	for i in 1 to items.count do
	(
	if items[n] != items[i] do
		(
		deleteItem Array_Year n
		deleteItem Array_Month n
		deleteItem Array_Day n
		deleteItem Array_Hour n
		deleteItem Array_Minute n
		(print "go to Next")
		)
	)
)

 Del_Arr_Lower Array_Year 
 Del_Arr_Lower Array_Month 
 Del_Arr_Lower Array_Day 
 Del_Arr_Lower Array_Hour 
 Del_Arr_Lower Array_Minute 

findItem  Final_Check (Array_Minute[1])










/*
	--find the higer year pos in array
	(
	local y="amax "
	for i in 1 to Array_Year.count do (y +=  (Array_Year[i] as string)+" ")
	z= execute y
	)
	--find the higer Month pos in array
	(
	local y="amax "
	for i in 1 to Array_Month.count do (y +=  (Array_Month[i] as string)+" ")
	local z= execute y
	Higher_Month = findItem Array_Month (z as string)
	)	
)
(
--test find the last date from 5 files
Array_Year = #("2004", "2005", "2005", "2005", "2005")
Array_Month = #("10", "11", "8", "11", "11")
Array_Day = #("10", "2", "10", "10", "10")
Array_Hour = #("7", "6", "6", "6", "11")
Array_Minute = #("49", "54", "34", "39", "44")
)


*/


/*
(
--find the lower Year in array
y ="amin "
for i in 1 to Array_Year.count do (y +=  (Array_Year[i] as string)+" ")
z = (execute y)
n = (findItem Array_Year (z as string))

for i in 1 to Array_Year.count do
	(
	if Array_Year[n] != Array_Year[i] then
		(
		deleteItem Array_Year n
		deleteItem Array_Month n
		deleteItem Array_Day n
		deleteItem Array_Hour n
		deleteItem Array_Minute n
		)
	else (print "go to Month")
	)
)
--find the lower Month in array 	
(
y ="amin "
for i in 1 to Array_Month.count do (y +=  (Array_Month[i] as string)+" ")
z = (execute y)
n = (findItem Array_Month (z as string))

for i in 1 to Array_Year.count do
	(
	if Array_Month[n] != Array_Month[i] then
		(
		deleteItem Array_Year n
		deleteItem Array_Month n
		deleteItem Array_Day n
		deleteItem Array_Hour n
		deleteItem Array_Minute n
		)
	else (print "go to Day")
	)
)
--find the lower Day in array 	
(
y ="amin "
for i in 1 to Array_Day.count do (y +=  (Array_Day[i] as string)+" ")
z = (execute y)
n = (findItem Array_Day (z as string))
if Array_Day[n] != Array_Day[i] then
	(
	deleteItem Array_Year n
	deleteItem Array_Month n
	deleteItem Array_Day n
	deleteItem Array_Hour n
	deleteItem Array_Minute n
	)
else (print "go to Hour")
)
*/
	
	
	
	


	/*
	Array_Date[1] [3]
	amax Files_Date
	(amax Array_Year)
	(amax Array_Month)
	(amax Array_Day)
	(amax Array_Hour)
	(amax Array_Minute)
	*/
	
	
	
	
	
	
	
	
/*x=Array_Minute[1]
for i in Array_Minute do
if x < i then x = i
findItem Array_Minute x

x=Array_Hour[1]
for i in Array_Hour do
if x < i then x = i
findItem Array_Hour x
*/

/*
(
local x=#("25", "2", "712", "258", "21", "585", "145", "1", "11", "58", "85", "6")
while x.count > 1 do
	(
	local y = if (x[1] as float) > (x[2] as float) then x = deleteItem x 2 else x = deleteItem x 1
	)
local x=#("25", "2", "712", "258", "21", "585", "145", "1", "11", "58", "85", "6")
findItem x y[1]
)	
	
	

char="0123456789abcdef"
for i=1 to char.count do
for j=1 to char.count do
(
s=execute("\"\\x"+char[i]+char[j]+"\"")
format "%% %\n" char[i] char[j] s
)

y=""
for i in x do y = (amax (x[i]))

y="amax "
for i in 1 to x.count do (y +=  (x[i] as string)+" ") ;execute y
*/
/*

--1
#("2005", "2005", "2005", "2005", "2005", "2005")
#("10"  , "10"  , "10"  , "10"  , "10"  , "7"   )
#("9"   , "9"   , "9"   , "9"   , "9"   , "13"  )
#("5"   , "5"   , "5"   , "5"   , "5"   , "11"  )
#("34"  , "39"  , "44"  , "49"  , "54"  , "39"  )
--2
#("2005", "2005", "2005", "2005", "2005")
#("10"  , "10"  , "10"  , "10"  , "10"  )
#("9"   , "9"   , "9"   , "9"   , "9"   )
#("5"   , "5"   , "5"   , "5"   , "5"   )
#("34"  , "39"  , "44"  , "49"  , "54"  )
--3
#( "2005")
#( "10"  )
#( "9"   )
#( "5"   )
#( "54"  )
*/
