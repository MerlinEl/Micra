Global mcProgRad
/**
*@Usage
	val = 1
	mcProgRad.progeressbar val msg:"Downoading Update:"
	if val >= 100 do mcProgRad.progeressbar 100 msg:"Downoad Finished:" close:true 
	
	
		mcProgRad.progeressbar i msg:"Downoading Update:"
	if i >= 100 do mcProgRad.progeressbar 100 msg:"Downoad Finished:" close:true 

	mcProgRad.openForm()
	mcProgRad.hideForm()
	
	
	
*/
if isStruct mcProgRad do mcProgRad.closeForm()
struct MICRA_PROGRESSBAR_STRUCT (	
	
	form = dotNetObject "MaxCustomControls.MaxForm",
	cp_path = micra.AppsDir +@"Assembly\CircularProgressBar.dll",
-- 	wf_path = micra.AppsDir +@"Assembly\WinFormAnimation.dll",
	font1		= dotnetobject "System.Drawing.Font" "Impact" 20,
	font2		= dotnetobject "System.Drawing.Font" "Impact" 12,
	btn_ok		= dotnetobject "Button",	
	circ_bar	= undefined,
	transparent_color = mcDotnet.dColor (color 0 50 50),
	fn onBackColorChanged s a = ( --set form transparency
		
		s.backColor = mcProgRad.transparent_color
		s.TransparencyKey = s.BackColor
	),
	fn OnPaint s = ( --set form antialiasing
		
		local g = s.Graphics
		g.SmoothingMode = g.SmoothingMode.HighQuality
		g.CompositingQuality = g.CompositingQuality.HighQuality
	),
	fn isFormHidden = (not mcProgRad.form.visible),
	fn closeForm = (mcProgRad.form.close()),
	fn showForm = (
		
		local hv = DotNetObject "NativeWindow"
		hv.AssignHandle (DotNetObject "System.IntPtr" (Windows.GetMaxHWND())) 
		mcProgRad.form.show(hv)	
	),
	fn hideForm = (
		
		mcProgRad.hideForm()
		mcProgRad.circ_bar.value = 0
		mcProgRad.circ_bar.text =  "0"
	),
	fn onOkPressed s a = (
		
		mcProgRad.hideForm()
	),
	fn progeressBar val color:(color 255 200 18) msg:"Progress..." image:"default" close:false = (
		
		if mcProgRad.isFormHidden() do showForm()
		local img_path = case image of (
			
			"default" : Micra.RootDir+"Img\\3DGall_Loader_01.bmp"	
		)
		if mcProgRad.circ_bar.value < mcProgRad.circ_bar.maximum then (
			
			mcProgRad.circ_bar.value  = val
			mcProgRad.circ_bar.text = mcProgRad.circ_bar.value as String
			--mcProgressBarDialog.grp_info.text = msg +"( "+ ((val as integer) as string) + " )%"
		) else (

			if close do (sleep 0.3; mcProgRad.hideForm())
		)
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
		form.opacity = 0.9
		
		btn_ok.text = "OK"
		btn_ok.name = "btn_ok"
		btn_ok.font = font2
		btn_ok.foreColor = mcDotnet.dColor  (color 9 102 51)
		btn_ok.backColor = mcDotnet.dColor green
		btn_ok.Dock = btn_ok.Dock.Bottom
		
		local a = dotnet.LoadAssembly cp_path 
	-- 	a.GetTypes()
		circ_bar = dotnetObject "CircularProgressBar.CircularProgressBar"
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

		form.Controls.addrange #(circ_bar)
		
		dotnet.addEventHandler form "BackColorChanged" onBackColorChanged
		dotnet.addEventHandler form "Paint" OnPaint
		dotNet.addEventHandler btn_ok "MouseUp" onOkPressed
	),
	on create do (initForm())
)
mcProgRad = MICRA_PROGRESSBAR_STRUCT()