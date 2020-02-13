Global mcMenuRad
if isStruct mcMenuRad do mcMenuRad.closeForm()
struct MICRA_RADIALMENU_STRUCT (	
	
	form = dotNetObject "MaxCustomControls.MaxForm",
	font1		= dotnetobject "System.Drawing.Font" "Impact" 20,
	font2		= dotnetobject "System.Drawing.Font" "Impact" 12,
	btn_start	= dotnetobject "Button",
	buttons = #(),
	circ_bar	= undefined,
	button_size = 24,
	transparent_color = mcDotnet.dColor (color 0 50 50),
	--> Math FN
	fn createRadialMenu radius cnt pos:[0,0,0] = (

		local btns = #()
		local div = 360.0 / cnt
		for i = 1 to cnt do (
			
			local btn = dotnetobject "Button"
			local step = div*i
			local p = [cos step, sin step] * radius
			btn.location = mcDotnet.dPoint [p.x + pos.x, p.y + pos.y]
			append btns btn
		)
		btns
	),
	--Interface FN
	fn onBackColorChanged s a = ( --set form transparency
		
		s.backColor = mcMenuRad.transparent_color
		s.TransparencyKey = s.BackColor
	),
	fn OnPaint s = ( --set form antialiasing

		local g = s.Graphics
		g.SmoothingMode = g.SmoothingMode.HighQuality
		g.CompositingQuality = g.CompositingQuality.HighQuality
	),
	fn maxHW = (
		
		local hv = DotNetObject "NativeWindow"
		hv.AssignHandle (DotNetObject "System.IntPtr" (Windows.GetMaxHWND())) 
		return hv
	),
	fn showForm = (
		
		local hw = maxHW()
		mcMenuRad.form.show(hw)
	),
	fn hideForm = (mcMenuRad.form.hide()),
	fn closeForm = (mcMenuRad.form.close()),
	fn onHideFormPressed s a = (
		
		mcMenuRad.hideForm()
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
		
		btn_start.text = "X"
		btn_start.name = "btn_start"
		btn_start.font = font2
		btn_start.foreColor = mcDotnet.dColor  (color 9 102 51)
		btn_start.backColor = mcDotnet.dColor green
		btn_start.Size = mcDotnet.dSize [button_size, button_size]
		--btn_start.Dock = btn_start.Dock.Fill -- .Bottom, Fill, Left, None, Right, Top 
		--btn_start.Dock = btn_start.Dock.Bottom
		
		
		
		
		form.Controls.addrange #(btn_start)
		
		dotnet.addEventHandler form "BackColorChanged" onBackColorChanged
		dotnet.addEventHandler form "Paint" OnPaint
		dotNet.addEventHandler btn_start "MouseUp" onHideFormPressed
	),
	on create do (initForm())
)
mcMenuRad = MICRA_RADIALMENU_STRUCT()
mcMenuRad.showForm()