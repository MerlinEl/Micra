global testform
fn showForm = (
	
	testform = dotNetObject "MaxCustomControls.MaxForm"
	testform.show()
)
showForm()
/*
bworker = dotNetObject "system.componentModel.backgroundWorker"
dotnet.addEventHandler bworker "DoWork" showForm
bworker.runWorkerAsync() 
testform.close()*/

Global gtest, gTestUI
if isStruct gtest do gtest.stopTimer()
struct sTestUI (

	form = dotNetObject "MaxCustomControls.MaxForm",	
	fn dRect pos size = (dotnetObject "Drawing.Rectangle" pos.x pos.y size.x size.y),
	fn showForm = (form.show()),
	fn hideForm = (form.hide()),
	fn isOpen = (form.visible),
	fn handleVisibility = (
		
		format "B worker start\n"
		showForm()
	),
	on create do (
	
		form.bounds = dRect [0, 0] [200, 100]
	)
)

struct stest ( 
	
	d_timer = dotnetobject "system.timers.timer",
	bworker = dotNetObject "system.componentModel.backgroundWorker",
	delay = 5000,
	ticks_count = 0,
	timer_enabled = false,
	fn timerTick s a = (
		
		if not gtest.timer_enabled do return false
		gtest.ticks_count += 1
		format "current tick:%\n" gtest.ticks_count
		if gtest.ticks_count == 5 then (
			
			format "current tick:%\n" gtest.ticks_count
			--gTestUI.showForm()
		)
		if gtest.ticks_count == 10 then (
			
			gTestUI.hideForm()
			gtest.ticks_count = 0
		)
	),
	fn startTimer = (
		
		timer_enabled = true
		--d_timer.start()
		bworker.runWorkerAsync() 
			format "A worker start\n"
		--System.Threading.Thread.Sleep(500);
		OK
	),
	fn stopTimer = (
		
		timer_enabled = false
		--d_timer.stop()
		dotNet.removeAllEventHandlers bworker
		gTestUI.hideForm()
		OK
	),
	fn testHandler = (
		
		format "handled\n"
		gTestUI.handleVisibility()
	),
	on create do (
		
		gTestUI = sTestUI()
		dotnet.addEventHandler bworker "DoWork" testHandler
		format "worker register\n"

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