----------------------------------------------------------------------------
if ro != undefined do destroydialog ro
----------------------------------------------------------------------------
rollout ro "Tick" width:65 height:30
(
	Timer tick_1 "" pos:[52,4] interval:2000 active:false
	checkbutton ckbTest "Test" pos:[4,4] width:57 height:20
	on tick_1 tick do 
		(tick_1.active = off ; ro.ckbTest.checked = off)
	on ckbTest changed state do
		(if ro.ckbTest.checked then ro.tick_1.active = true else ro.tick_1.active = false)
)
----------------------------------------------------------------------------
createdialog ro
----------------------------------------------------------------------------


--ro.tick_1.interval = 2000

/*
----------------------------------------------------------------------------
if ro != undefined do destroydialog ro
----------------------------------------------------------------------------
rollout ro "Tick" width:76 height:52
	(
	timer clock "testClock" interval:400
	label test "1"
	on clock tick do
		(
		valUp = (test.text as integer)+1
		test.text = valUp as string
		)
	)
----------------------------------------------------------------------------
createdialog ro
----------------------------------------------------------------------------
*/

/*
----------------------------------------------------------------------------
if ro != undefined do destroydialog ro
----------------------------------------------------------------------------
(
Local valUp = 0
rollout ro "Tick" width:76 height:52
(
	Timer tick_1 "Timer" pos:[52,4] width:24 height:24 interval:1000 active:false
	checkbutton ckbTest "Loop" pos:[4,4] width:48 height:20
	checkbutton ckb5 "1time" pos:[4,28] width:48 height:20
	on tick_1 tick do
	(
	print "tick" 
	valUp += 1
	if valUp > 2 then (tick_1.active = off ; ro.ckbTest.checked = off)
	)
	on ckbTest changed state do
	(
	if ro.ckbTest.checked then (ro.tick_1.active = true) else (ro.tick_1.active = false)
	valUp = 0
	)
	on ckb5 changed state do
	(
	if ro.ckbTest.checked then (ro.tick_1.active = true) else (ro.tick_1.active = false)
	)
)
----------------------------------------------------------------------------
createdialog ro
----------------------------------------------------------------------------
)
*/

/*
--count time while ned to create some objects 
start = timeStamp()
box() sphere() -- do some big job
end = timeStamp()
format "Processing took % seconds\n" ((end - start) / 1000.0)
*/


/*
--Sets the range of time in timeslider (for animation lenght)
animationRange=interval 0 2000
*/

/*
--time slider as time val
fn time_p = print currentTime
registerTimeCallback time_p
unRegisterTimeCallback time_p
*/

/*
--time slider as frame val
fn time_cb = print currentTime
fn tcb = time_cb()
registerTimeCallback tcb
unRegisterTimeCallback tcb
*/