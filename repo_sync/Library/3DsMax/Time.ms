FrameRate==25 --> true for PAL, false for any other frame rate incl. NTSC
FrameRate==30 --> true for NTSC, false for any other frame rate incl. PAL
FrameRate = 25 --set to PAL
timeDisplayMode = #frames

t = tick
f = frame
s = second
m = minute

0s0m --> 0f
1m1f --> 1801f (1 min = 60 sec. * 30 fps = 1800f + 1f = 1801f)
2f100t --> 2.625f


--LocalTime
Local curTime = LocalTime
Local tArray = filterString curTime ". :" --filtering  "."  "space"  ":" 
Local mDate = tArray[1] + "." + tArray[2] + "." + tArray[3]
Local mTime = tArray[4] + ":" + tArray[5]

mLocalTime = "Micra: "+mTime+" "+mDate
--LocalTime



----------------------------------------------------------------------------
if mClock != undefined do destroydialog mClock
----------------------------------------------------------------------------
rollout mClock "Tick" 
(
	Timer tick_c "" pos:[52,4] interval:1000 active:false
	label lblTime "" pos:[52,4] width:104 height:16
	checkbox ckbTim "Time:" pos:[4,4] width:48 height:16 
	button btn1 "" pos:[164,4] width:8 height:16
	on ckbTim changed state do
		(
		if mClock.ckbTim.checked then (tick_c.active = on)
		else (tick_c.active = off ; mClock.title = "Tick")
		)
	on tick_c tick do
		(mClock.title = "Tick:"+" "+localtime)
	on btn1 pressed  do
		(
		destroydialog mClock
		)
)
----------------------------------------------------------------------------
createdialog mClock 176 24 150 250 style:#(#style_titlebar)
----------------------------------------------------------------------------

/*
----------------------------------------------------------------------------
if mClock != undefined do destroydialog mClock
----------------------------------------------------------------------------
rollout mClock "Tick" 
(
	Timer tick_c "" pos:[52,4] interval:1000 active:false
	label lblTime "" pos:[52,4] width:104 height:16
	checkbox ckbTim "Time:" pos:[4,4] width:48 height:16 
	button btn1 "" pos:[164,4] width:8 height:16
	on ckbTim changed state do
		(
		if mClock.ckbTim.checked then (tick_c.active = on)
		else (tick_c.active = off ; mClock.lblTime.caption = "")
		)
	on tick_c tick do
		(mClock.lblTime.caption = localtime)
	on btn1 pressed  do
		(
		destroydialog mClock
		)
)
----------------------------------------------------------------------------
createdialog mClock 176 24 150 250 style:#(#style_sysMenu, #style_border)
----------------------------------------------------------------------------
*/

----------------------------------------------------------------------------
--Function
----------------------------------------------------------------------------
/* Function for send LocalTime to label */
/*
fn time_caption = (mClock.lblTime.caption = localtime)
registerTimeCallback time_caption
*/
/* Call: time_caption() */
----------------------------------------------------------------------------
/* Function for send LocalTime to top of screen */
/*
fn TimeText = 
	(
	completeredraw() 
	gw.wtext [5,40,1000]  (localtime)  color:(color 255 234 0)
	gw.enlargeUpdateRect #whole 
	gw.updateScreen()
	)
*/
/* Call:		
unregisterRedrawViewsCallback (TimeText())
registerRedrawViewsCallback (TimeText()) ; completeredraw()
*/




fn GetFormattedTime totSec = (
	local tmp, h, m, s

	h = (totSec / 3600) as integer
	tmp = mod totSec 3600
	m = (tmp / 60) as integer
	s = (mod tmp 60) as integer

	return ( (h as string) + "h:" + (m as string) + "m:" + (s as string) + "s" )
)


h = TimeStamp() / 3600000
m = TimeStamp() / 60000 - (h * 60)
s = TimeStamp() / 1000 - (h * 3600 + m * 60)




--- Timer
global ST_delay = 100
global timeS1=timestamp(),  timeS2=timestamp()
timeS1=timestamp()
timeS2=timestamp()+10
timeT =  timeS2 - timeS1
if timeT > ST_delay  do
(
timeT =  timeS2 - timeS1
print "tick"
)