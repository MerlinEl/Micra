Global gtest
if isStruct gtest do gtest.stopTimer()
struct stest ( 
	
	form = dotNetObject "MaxCustomControls.MaxForm",
	d_timer = dotnetobject "system.timers.timer",
	d_bw = dotNetObject "system.componentModel.backgroundWorker"
	delay = 5000,
	ticks_count = 0,
	timer_enabled = false,
	fn dRect pos size = (dotnetObject "Drawing.Rectangle" pos.x pos.y size.x size.y),
	fn timerTick s a = (
		
		if not gtest.timer_enabled do return false
		gtest.ticks_count += 1
		format "current tick:%\n" gtest.ticks_count
		if gtest.ticks_count == 5 then (
			
			gtest.form.show()
		)
		if gtest.ticks_count == 10 then (
			
			gtest.form.hide()
			gtest.ticks_count = 0
		)
	),
	fn startTimer = (
		
		timer_enabled = true
		d_timer.start()
		OK
	),
	fn stopTimer = (
		
		timer_enabled = false
		d_timer.stop()
		form.hide()
		OK
	),
	on create do (
		
		form.bounds = dRect [0, 0] [200, 100]
		d_timer.interval = 4000
		dotnet.addeventhandler d_timer "Elapsed" timerTick
	)
)
gtest = stest()
/*
gtest.startTimer()
gtest.stopTimer()
*/

/*
myThreads = #() 
fn doSomeStuff = ( for i = 1 to 10000000 do pi * pi * pi print "done" ) 
for i = 1 to 8 do ( 

	myThreads[i] = dotNetObject "system.componentModel.backgroundWorker" 
	dotnet.addEventHandler myThreads[i] "DoWork" doSomeStuff myThreads[i].runWorkerAsync() 

) magical!
*/