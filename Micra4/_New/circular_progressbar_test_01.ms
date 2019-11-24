Global gProgressBarTest
if isStruct gProgressBarTest do gProgressBarTest.closeForm()
struct sProgressBarTest (	
	
	form = dotNetObject "MaxCustomControls.MaxForm",
	tm = dotnetobject "system.timers.timer",
	cp_path = micra.AppsDir +@"Assembly\CircularProgressBar.dll",
-- 	wf_path = micra.AppsDir +@"Assembly\WinFormAnimation.dll",
	font1		= dotnetobject "System.Drawing.Font" "Impact" 20,
	font2		= dotnetobject "System.Drawing.Font" "Impact" 12,
	btn_start	= dotnetobject "Button",
	btn_close= dotnetobject "Button",	
	circ_bar	= undefined,
	transparent_color = (color 0 50 50),
	fn showForm = (gProgressBarTest.form.showmodeless()),
	fn hideForm = (gProgressBarTest.form.hide()),
	fn closeForm = (gProgressBarTest.form.close()),
	fn onBackColorChanged s a = (

		s.backColor = mcDotnet.dColor gProgressBarTest.transparent_color
		s.TransparencyKey = s.BackColor
	),
	fn startTimer =
	(
		tm.start()
		print "Timer Started"
	),
	fn stopTimer =
	(
		tm.stop()
		print "Timer Stoped"
	),
	fn timerTick s a = (
		
		if gProgressBarTest.circ_bar.value >= gProgressBarTest.circ_bar.maximum do (
			
			gProgressBarTest.stopTimer()
			return OK
		)
		gProgressBarTest.circ_bar.value += 1
		gProgressBarTest.circ_bar.text = gProgressBarTest.circ_bar.value as String
	),
	fn onStartTimerPressed s a = (
		
		format "n:%\n" s.text
		case s.text of (
			
			"RUN":(
			
				s.text = "PAUSE"
				gProgressBarTest.startTimer()
			)
			"PAUSE":(
			
				s.text = "RUN"	
				gProgressBarTest.stopTimer()
			)
		)
	),
	fn onHideFormPressed s a = (
		
		gProgressBarTest.hideForm()
	),
	fn initForm = (
		
		form.StartPosition = form.StartPosition.Manual
		form.ShowInTaskBar = false
		form.FormBorderStyle = form.FormBorderStyle.None
-- 		form.Controls.addrange #(btn_start, btn_stop, circ_bar)
		form.width = 400
		form.height = 400
		form.location = mcDotnet.dPoint (mcSystem.getMaxCenter() - [form.width, form.height] / 2)
		form.opacity = 0.8
		
	-- 	doesFileExist cp_path
	-- 	doesFileExist wf_path
		a = dotnet.LoadAssembly cp_path 
	-- 	b = dotnet.LoadAssembly wf_path 
	-- 	a.GetTypes()
	-- 	b.GetTypes()
		circ_bar = dotnetObject "CircularProgressBar.CircularProgressBar"
		
		btn_start.text = "RUN"
		btn_start.name = "btn_start"
		btn_start.font = font2
		btn_start.foreColor = mcDotnet.dColor (color 9 102 51)
		btn_start.backColor = mcDotnet.dColor green
		btn_start.Dock = btn_start.Dock.Top

		btn_close.text = "CLOSE"
		btn_close.name = "btn_close"
		btn_close.font = font2
		btn_close.foreColor = mcDotnet.dColor  (color 9 102 51)
		btn_close.backColor = mcDotnet.dColor green
		btn_close.Dock = btn_close.Dock.Bottom
		
		circ_bar.Name = "circ_bar"
		circ_bar.Text = "0"
		circ_bar.SuperscriptText = "%"
		circ_bar.SuperscriptColor = mcDotnet.dColor (color 0 120 120)
		circ_bar.SubscriptText = ""
-- 		circ_bar.SubscriptColor = ""
		circ_bar.outerColor = mcDotnet.dColor (color 0 120 120)
		circ_bar.progressColor = mcDotnet.dColor green
		circ_bar.innerColor = mcDotnet.dColor transparent_color
		circ_bar.foreColor = mcDotnet.dColor (color 0 120 120)
		circ_bar.minimum = 0
		circ_bar.maximum = 100
		circ_bar.width = 300
		circ_bar.height = 300
		circ_bar.location = mcDotnet.dPoint (([form.width , form.height] - [circ_bar.width , circ_bar.height]) / 2)
		--circ_bar.AutoSize = true
		--circ_bar.Dock = circ_bar.Dock.Top
		  
		tm.Interval = 100
		tm.Enabled = false
		--tm.radius = 100
-- 		tm.bounds = mcDotnet.drect
		
		form.Controls.addrange #(btn_start, btn_close, circ_bar)
		
		dotnet.addEventHandler form "BackColorChanged" onBackColorChanged
		dotnet.addeventhandler tm "Elapsed" timerTick
		dotNet.addEventHandler btn_start "MouseUp" onStartTimerPressed
		dotNet.addEventHandler btn_close "MouseUp" onHideFormPressed
	),
	on create do (initForm())
)
gProgressBarTest = sProgressBarTest()
gProgressBarTest.showForm()