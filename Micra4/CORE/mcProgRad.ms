Global mcProgRad
if isStruct mcProgRad do mcProgRad.closeForm()
struct MICRA_PROGRESSBAR_STRUCT (	
	
	form = dotNetObject "MaxCustomControls.MaxForm",
	tm = dotnetobject "system.timers.timer",
	cp_path = micra.AppsDir +@"Assembly\CircularProgressBar.dll",
-- 	wf_path = micra.AppsDir +@"Assembly\WinFormAnimation.dll",
	font1		= dotnetobject "System.Drawing.Font" "Impact" 20,
	font2		= dotnetobject "System.Drawing.Font" "Impact" 12,
	btn_start	= dotnetobject "Button",
	btn_close= dotnetobject "Button",	
	circ_bar	= undefined,
	transparent_color = mcDotnet.dColor (color 0 50 50),
	fn onBackColorChanged s a = ( --set form transparency
		
		s.backColor = mcProgRad.transparent_color
		s.TransparencyKey = s.BackColor
	),
	fn OnPaint s = ( --set form antialiasing
			--draw rect test
			--arg.graphics.clear((dotNetClass "system.drawing.color")fromargb 255 255 255)
--     		rec=dotNetObject "system.drawing.rectangle" 2 2 200 200
--     		bgColor=(dotNetClass "system.drawing.color").fromargb 255 255 0 0 
--     		brush=dotnetobject "System.Drawing.SolidBrush" bgColor
--     		s.graphics.FillRectangle brush rec
		local g = s.Graphics
		g.SmoothingMode = g.SmoothingMode.HighQuality
		g.CompositingQuality = g.CompositingQuality.HighQuality
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
		
		if mcProgRad.circ_bar.value >= mcProgRad.circ_bar.maximum do (
			
			mcProgRad.stopTimer()
			return OK
		)
		mcProgRad.circ_bar.value += 1
		mcProgRad.circ_bar.text = mcProgRad.circ_bar.value as String
	),
	fn onStartTimerPressed s a = (
		
		format "n:%\n" s.text
		case s.text of (
			
			"RUN":(
			
				s.text = "PAUSE"
				mcProgRad.startTimer()
			)
			"PAUSE":(
			
				s.text = "RUN"	
				mcProgRad.stopTimer()
			)
		)
	),
	fn maxHW = (
		
			local hv = DotNetObject "NativeWindow"
			hv.AssignHandle (DotNetObject "System.IntPtr" (Windows.GetMaxHWND())) 
			return hv
	),
	fn showForm = (
		
		local hw = maxHW()
		mcProgRad.form.show(hw)
	),
	fn hideForm = (mcProgRad.form.hide()),
	fn closeForm = (mcProgRad.form.close()),
	fn onHideFormPressed s a = (
		
		mcProgRad.stopTimer()
		mcProgRad.hideForm()
	),
	fn initForm = (
		
		form.StartPosition = form.StartPosition.Manual
		form.ShowInTaskBar = false
		form.FormBorderStyle = form.FormBorderStyle.None
		form.AllowTransparency=false
		form.TransparencyKey = transparent_color
		form.width = 200
		form.height = 300
		form.location = mcDotnet.dPoint (mcSystem.getMaxCenter() - [form.width, form.height] / 2)
		form.opacity = 0.6
		
		local a = dotnet.LoadAssembly cp_path 
	-- 	a.GetTypes()
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
		circ_bar.SuperscriptColor = mcDotnet.dColor green --(color 0 200 200)
		circ_bar.SuperscriptMargin = mcDotnet.dPadding 10 55 0 0
		circ_bar.SubscriptText = ""
-- 		circ_bar.SubscriptColor = ""
		circ_bar.outerColor = mcDotnet.dColor (color 0 120 120)
		circ_bar.progressColor = mcDotnet.dColor green
		circ_bar.innerColor = transparent_color
		circ_bar.foreColor = mcDotnet.dColor green --(color 0 200 200)
		circ_bar.minimum = 0
		circ_bar.maximum = 100
		circ_bar.ProgressWidth = 20
		circ_bar.MaximumSize = mcDotnet.dSize [200, 200]
		circ_bar.Font = mcDotnet.dFont font:"Tahoma" size:35 style:"Bold"
		circ_bar.location = mcDotnet.dPoint (([form.width , form.height] - [circ_bar.width , circ_bar.height]) / 2)
		circ_bar.value =  0
		circ_bar.AutoSize = true
		--circ_bar.Dock = circ_bar.Dock.Top
		  
		tm.Interval = 100
		tm.Enabled = false

		form.Controls.addrange #(btn_start, btn_close, circ_bar)
		
		dotnet.addEventHandler form "BackColorChanged" onBackColorChanged
		dotnet.addEventHandler form "Paint" OnPaint
		dotnet.addeventhandler tm "Elapsed" timerTick
		dotNet.addEventHandler btn_start "MouseUp" onStartTimerPressed
		dotNet.addEventHandler btn_close "MouseUp" onHideFormPressed
	),
	on create do (initForm())
)
mcProgRad = MICRA_PROGRESSBAR_STRUCT()
mcProgRad.showForm()