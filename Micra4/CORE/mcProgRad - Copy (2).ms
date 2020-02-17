--------------------------------------------------------------------------------
/* mcProgRad by Orien 2020 */
--------------------------------------------------------------------------------
/*
*@Used Structures
	mcDotnet
*
*@Used Objects

*
*@Example
	mcProgRad.progressTo a.ProgressPercentage msg:"Downoading Update:"
	if a.ProgressPercentage >= 100 do mcProgRad.progressTo 100 msg:"Downoad Finished:" close:true 
	
	mcProgRad.progressTo 0 msg:"..."
	mcProgRad.progressTo 25 msg:"Downoading..."
	mcProgRad.progressTo 45 msg:"Downoading..."
	mcProgRad.progressTo 65 msg:"Downoading..."
	mcProgRad.progressTo 100 msg:"Downoad Finished:"
	mcProgRad.progressTo 100 msg:"Downoad Finished:" close:true 
*/
Global mcProgRad
if isStruct mcProgRad do mcProgRad.closeForm()
struct MICRA_PROGRESSBAR_STRUCT (	
	
	form = dotNetObject "MaxCustomControls.MaxForm",
	canvas = dotNetObject  "System.Windows.Forms.PictureBox",
	lbl_title = dotnetObject "Label",
	lbl_info = dotnetObject "Label",
	btn_close= dotnetobject "Button",	
	font1		= mcDotnet.dFont font:"Impact" size:20 style:"Regular",
	font2		= mcDotnet.dFont font:"Impact" size:16 style:"Regular",
	font3		= mcDotnet.dFont font:"Impact" size:30 style:"Regular",
	circ_bar	= undefined,
	bar_radius= 124,
	bar_thickness = 30,
	transparent_color = mcDotnet.dColor (color 0 50 50),
	border_color = color 50 50 50,
	fn showForm = (

		local hv = DotNetObject "NativeWindow"
		hv.AssignHandle (DotNetObject "System.IntPtr" (Windows.GetMaxHWND())) 
		mcProgRad.form.show(hv)
	),
	fn hideForm = (mcProgRad.form.hide()),
	fn closeForm = (mcProgRad.form.close()),
	fn onHideFormPressed s a = (
		
		mcProgRad.hideForm()
	),
	fn onFormPaint s a = (
	
		s.backColor = mcDotnet.dColor (color 0 50 50) --get rid off remains untranspared areas
	),
	-- fn onLabelPaint s a = (

		-- local g = a.Graphics
		-- ControlPaint.DrawBorder(e.Graphics, label1.DisplayRectangle, Color.Blue, ButtonBorderStyle.Solid);
	-- ),
	fn onInfoChanged s a = ( --realign info text  component
		
		local canvas = mcProgRad.canvas
		local lbl_info = mcProgRad.lbl_info
		local canvas_center = [canvas.width, canvas.height]/2 + [canvas.location.x, canvas.location.y]
		lbl_info.location = mcDotnet.dPoint (canvas_center - [lbl_info.width/2, lbl_info.height/2])
	),
	fn onFormShown s a = (
		
		mcProgRad.onInfoChanged undefined undefined
	),
	fn drawProgressBar radius start_angle end_angle thickness:10 fill_clr:blue border_clr:black= (
	
		local brush_1 = dotNetObject "System.Drawing.SolidBrush" (mcDotnet.dColor gray) --background
		local brush_2 = dotNetObject "System.Drawing.SolidBrush" (mcDotnet.dColor fill_clr) --fill arc
		local brush_3 = dotNetObject "System.Drawing.SolidBrush" (mcDotnet.dColor border_clr) --border
		local pen_1 = dotNetObject "system.drawing.pen" brush_1 thickness  
		local pen_2 = dotNetObject "system.drawing.pen" brush_2 thickness  
		local pen_3 = dotNetObject "system.drawing.pen" brush_3 2  
		local bm = dotNetObject "System.Drawing.Bitmap" (radius*2) (radius*2)
		local g = mcDotnet.Graphics.FromImage bm 
		g.Clear(mcDotnet.dColor (color 0 50 50))
		-- g.Clear(mcDotnet.dColor blue)
		--set best quality
		g.InterpolationMode = g.InterpolationMode.HighQualityBilinear
		g.CompositingQuality = g.CompositingQuality.HighQuality
		g.PixelOffsetMode = g.PixelOffsetMode.HighQuality
		g.SmoothingMode = g.SmoothingMode.AntiAlias
		--Create rectangle to bound ellipse. (in ,out, center)
		local pos_1 = [thickness, thickness]/2 + 1
		local pos_2 = [1, 1]
		local pos_3 = [1, 1] + thickness
		local rect = mcDotnet.dRect pos_1 ([radius*2, radius*2] - thickness-2)
		local rect_out = mcDotnet.dRect pos_2 ([radius*2, radius*2]-2)
		local rect_in = mcDotnet.dRect pos_3 ([radius*2, radius*2]-2 - thickness*2)
	   --Draw arc to screen.
		pen_1.StartCap = mcDotnet.LineCap.Round
        pen_1.EndCap = mcDotnet.LineCap.Round
		g.DrawEllipse pen_1 rect --draw circle background
		g.DrawArc pen_2 rect start_angle end_angle --draw arc fill
		g.DrawEllipse pen_3 rect_out --draw outer border
		g.DrawEllipse pen_3 rect_in	--draw inner border
		bm
	),
	fn progressTo percent msg:"Loading..." close:false = (
	
		local start_angle = -90
		local end_angle = (360.0 / 100.0) * percent
		lbl_title.text = msg
		lbl_info.text = "( "+percent as string+"% )"
		canvas.Image = drawProgressBar bar_radius  start_angle end_angle thickness:bar_thickness fill_clr:green border_clr:border_color
		if not form.visible do showForm()
		if close do (sleep 0.3;hideForm())
	),
	fn initForm = (
		
		local margins = 2
		local percent = 90
		local form_size = bar_radius*2
		local form_center = [form_size, form_size]/2
		form.StartPosition = form.StartPosition.Manual
		form.ShowInTaskBar = false
		form.FormBorderStyle = form.FormBorderStyle.None
		form.AllowTransparency = true
		form.TransparencyKey = transparent_color
		form.Size = mcDotnet.dSize [form_size, form_size + 64]
		form.location = mcDotnet.dPoint (mcSystem.getMaxCenter() - [form.width, form.height] / 2)
		form.opacity = 0.8
		
		lbl_title.text = "Loading..."
		lbl_title.name = "lbl_title"
		lbl_title.BorderStyle = lbl_title.BorderStyle.None
		lbl_title.textAlign = lbl_title.textAlign.MiddleCenter
		lbl_title.font = font2
		lbl_title.foreColor = mcDotnet.dColor (color 215 247 122)
		lbl_title.backColor = mcDotnet.dColor green
		lbl_title.Dock = lbl_title.Dock.Top
		lbl_title.backColor = transparent_color
		
		canvas.BorderStyle = canvas.BorderStyle.None
		canvas.bounds = mcDotnet.dRect [0, lbl_info.height+8] [form_size, form_size]
		canvas.backColor = transparent_color
		canvas.Dock = canvas.Dock.None

		lbl_info.text = "( 100% )"
		lbl_info.name = "lbl_title"
		lbl_info.AutoSize = true
		lbl_info.BorderStyle = lbl_info.BorderStyle.None
		lbl_info.textAlign = lbl_info.textAlign.MiddleCenter
		lbl_info.font = font3
		lbl_info.foreColor = mcDotnet.dColor (color 215 247 122)
		lbl_info.backColor = mcDotnet.dColor green
		lbl_info.Dock = lbl_info.Dock.None
		lbl_info.backColor = transparent_color
		
		btn_close.text = "OK"
		btn_close.name = "btn_close"
		btn_close.font = font1
		btn_close.foreColor = mcDotnet.dColor border_color
		btn_close.backColor = mcDotnet.dColor green
		btn_close.Dock = btn_close.Dock.None
		-- btn_close.Dock = btn_close.Dock.Bottom
		btn_close.Bounds = mcDotnet.dRect [form_center.x-30, form_center.y+80] [60, 32]
		-- btn_close.backColor = transparent_color
		btn_close.visible = false

		form.Controls.addrange #(lbl_info, lbl_title, btn_close, canvas)

		dotNet.addEventHandler form "Paint" onFormPaint
		dotNet.addEventHandler btn_close "MouseUp" onHideFormPressed
		dotNet.addEventHandler form "Shown" onFormShown
		dotNet.addEventHandler lbl_info "TextChanged" onInfoChanged
	),
	on create do (initForm())
)
mcProgRad = MICRA_PROGRESSBAR_STRUCT()

