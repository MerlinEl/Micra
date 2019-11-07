Global mcDrawBezierDialog 
/**
*@Created by denisT 2011
*@Modified by MerlinEl 2019
*@Example
	----
*/
if ::mcDrawBezierDialog != undefined do try(mcDrawBezierDialog.close())catch()
struct DOTNET_MAIN_STRUCT  (
	
public	
	title,
	--define interface components
	form = dotNetObject "MaxCustomControls.MaxForm",
	lblT = dotNetObject "label",
	btnMin = dotNetObject "button",
	tlp = dotNetObject "TableLayoutPanel",
	panel = dotnetobject "UserControl",	
	p0 = dotnetobject "UserControl"	,
	p1 = dotnetobject "UserControl"	,
	p2 = dotnetobject "UserControl"	,
	p3 = dotnetobject "UserControl"	,
	--private variables
	pos			= [600, 610],
	size			= [660, 540],
	minimized		= false, 
	old_height, 
	bar_height		= 14,
	border_offset	= 2,
	btn_size		= 24,
	debug			= 0,
	netDMove = false,
	aPen = dotnetobject "System.Drawing.Pen" (dotnetclass "System.Drawing.Color").Pink 1,
	bPen = dotnetobject "System.Drawing.Pen" (dotnetclass "System.Drawing.Color").LightGreen 1,
	cPen = dotnetobject "System.Drawing.Pen" (dotnetclass "System.Drawing.Color").Orange 2,
	cursors = dotNetClass "System.Windows.Forms.Cursors",
	cursor = dotNetClass "System.Windows.Forms.Cursor",
public
	--Open / Close (with default setup, save position to INI)
	fn open = (if iskindof form dotnetobject do mcDotnet.dShow form),
	fn close = (if iskindof form dotnetobject do form.Close()),
	fn getName = ( title ),
	fn getPos = ( [form.location.x, form.location.y] ),
	fn getSize = ( [form.width, form.height] ),
	fn setPos pos = ( form.location = mcDotnet.dPoint pos ),
private
	--Move / Snap Dialog /
	fn onLblTMouseMove s a = (  --drag form
	
		local _mcs = mcDrawBezierDialog --struct instance
		if _mcs.netDMove do  mcDialog.moveAndSnap _mcs.form
	),
	fn onLblTMouseDown s a = ( --start drag
			
		local _mcs = mcDrawBezierDialog --struct instance
		_mcs.form.cursor.current = netCursors.Hand
		if a.Button == a.Button.left do ( --enable drag
		
			mcDialog.init _mcs.form
			_mcs.netDMove = true 
		)
	),
	fn onLblTMouseUp s a = --stop drag
	(
		local _mcs = mcDrawBezierDialog --struct instance
		_mcs.netDMove = false 
		case a.Button.ToString() of (
		
			"Left"	: (
				--format " save form:%  pos:% size:%\n" form.name (form.location.toString()) (form.size.toString())
				mcFile.saveDialogSettings _mcs.form.name "Properties_2" --save form position after drag
			)
			"Right"	: (
			
				_mcs.form.close()
			)
			"Middle"	: (
			

			)
		)
	),
	-- min max form
	fn minMaxForm s a = ( -- s = Button, a = MouseEventArgs
		
		local _mcs = mcDrawBezierDialog --struct instance
		if _mcs.old_height == undefined do _mcs.old_height = _mcs.form.height
		local minimized = _mcs.form.height < _mcs.old_height
		--format "height old:% current:% was minimized:%\n"  _mcs.old_height _mcs.form.height minimized
		if minimized then ( --maximize
			
			s.text = "+"
			_mcs.form.height = _mcs.old_height --restore height
		) else ( --minimize
			
			s.text = "-"
			_mcs.old_height		=	_mcs.form.height --store max size
			_mcs.form.height	= _mcs.bar_height + _mcs.border_offset*2 --minimize
		)
	),		
	fn changeBackcolor s a = (s.backColor = mcDotnet.dColor (mcUIColors.get #fore)), --override form backcolor
	fn onFormCreated s a = (
		
		--format "onFormCreated > state:%\n" (s.WindowState.toString())
	),
	fn onCloseForm s a = (
		
		--format " save form:%  pos:% size:%\n" s.name (s.location.toString()) (s.size.toString())
		mcFile.saveDialogSettings s.name "Properties_2" --save form position after close
	),
	-- Custom  Functions
	fn onMouseEnter a = ( --System.EventArgs
		
		local _mcs = mcDrawBezierDialog --struct instance
		_mcs.cursor.current = _mcs.cursors.hand	
	),
	fn onMouseLeave a = ( --System.EventArgs
		
		local _mcs = mcDrawBezierDialog --struct instance
		_mcs.cursor.current = _mcs.cursors.arrow	
	),

	fn initButtonsCursor buttons = (
		
		for i=0 to buttons.count - 1 do (
				
				local b = buttons.Item[i]
				format "btn:%\n" b
				dotnet.addEventHandler b "MouseEnter" onMouseEnter
				--dotnet.addEventHandler b "MouseHover" onMouseEnter
				dotnet.addEventHandler b "MouseLeave" onMouseLeave
		)
	),
	fn onMouseDown s a = if a.Button == a.Button.Left do ( s.tag = a.Location ),
	public fn onMouseMove s a = if a.Button == a.Button.Left do (
		
		s.Location.x += a.x - s.Tag.x 
		s.Location.y += a.y - s.Tag.y
		s.parent.Refresh()
	),
	fn onMouseMove1 s a = if a.Button == a.Button.Left do (
		
		local _mcs = mcDrawBezierDialog --struct instance
		c = s.parent.controls.item[1]
		c.Location.x += a.x - s.Tag.x 
		c.Location.y += a.y - s.Tag.y 
		_mcs.onMouseMove s a
	),
	fn onMouseMove2 s a = if a.Button == a.Button.Left do (
		
		local _mcs = mcDrawBezierDialog --struct instance
		c = s.parent.controls.item[2]
		c.Location.x += a.x - s.Tag.x 
		c.Location.y += a.y - s.Tag.y 
		_mcs.onMouseMove s a
	),
	fn onPaint s a = ( -- s:Forms.UserControl	a:Forms.PaintEventArgs
		
		local _mcs = mcDrawBezierDialog --struct instance
		fn cpoint s id =
		(
			local c = s.Controls.Item[id]
			dotnetobject "System.Drawing.Point" (c.Location.x + c.Size.width/2) (c.Location.y + c.Size.height/2) 
		)
		g = a.Graphics
		g.SmoothingMode = g.SmoothingMode.HighQuality
		g.DrawBezier _mcs.cPen (cpoint s 0) (cpoint s 1) (cpoint s 2) (cpoint s 3)
		g.DrawLine _mcs.aPen (cpoint s 0) (cpoint s 1) 
		g.DrawLine _mcs.bPen (cpoint s 2) (cpoint s 3)
	),
	-->
	
	-- main function
	fn init  =  (
		
		--setup interface
		local form_settings = mcFile.readDialogSettings title "Properties_2" --get saved pos and size
		if form_settings != undefined do (
		
			pos = execute (form_settings.get "pos")
			--size = execute (form_settings.get "pos") --causeing trouble
		)
		--size = from_data.size (when loaded every time is les and less....????)
		--format " load form:%  pos:% size:%\n" title pos size
		
		form.name = form.text = title
		form.ControlBox  = false --hide main bar
		form.ShowInTaskbar = false
		form.StartPosition = form.StartPosition.Manual
		form.bounds = mcDotnet.dRect pos size
		form.FormBorderStyle = form.FormBorderStyle.none
		form.BackColor = mcDotnet.uiColor #fore
		form.opacity = 1 ---mcUIColors.get #opacity
		--form.TopMost = true --keep fotm upper from all toolbars
		
		--toolbar
		lblT.bounds = mcDotnet.dRect [border_offset, border_offset] [size.x - border_offset*10 , bar_height]
		lblT.BackColor = mcDotnet.uiColor #back
		lblT.ForeColor = mcDotnet.uiColor #text
		lblT.Text = "Draw Bezier Curve v0.01" -- + (mcFile.getScriptVersion "Draw_Bezier") --update script title with version
		
		--min max button
		btnMin.FlatStyle = btnMin.FlatStyle.flat
		btnMin.BackColor = mcDotnet.uiColor #btn
		btnMin.ForeColor = mcDotnet.uiColor #text
		btnMin.text = "-"
		btnMin.Bounds = mcDotnet.dRect [size.x - (btnMin.width /2) - (border_offset*2) - 1 , border_offset] [btn_size, bar_height]
		
		--Componnts Layout
		tlp.Bounds  = mcDotnet.dRect [border_offset, bar_height + border_offset * 2] [size.x - 20, size.y - 58]
		tlp.backColor = mcDotnet.uiColor #btn
		
		--Custom Components
		panel.Backcolor = panel.Backcolor.LightYellow
		panel.bounds = tlp.Bounds
		---panel.Dock = panel.Dock.Fill
		p0.Backcolor = p0.Backcolor.Red
		p0.Bounds = dotnetobject "System.Drawing.Rectangle" 10 10 9 9
		p1.Backcolor = p1.Backcolor.Red
		p1.Bounds = dotnetobject "System.Drawing.Rectangle" 100 12 5 5
		p2.Backcolor = p2.Backcolor.Green
		p2.Bounds = dotnetobject "System.Drawing.Rectangle" 530 462 5 5
		p3.Backcolor = p3.Backcolor.Green
		p3.Bounds = dotnetobject "System.Drawing.Rectangle" 620 460 9 9
		-->
		
		-- Default Events
		dotnet.addEventHandler form "Shown" onFormCreated
		dotnet.addEventHandler form "Closed" onCloseForm
		dotnet.AddEventHandler form "BackColorChanged" changeBackcolor --override form backcolor (without this form color is default)
		dotNet.addEventHandler btnMin "MouseClick" minMaxForm
		dotNet.addEventHandler lblT   "MouseMove" onLblTMouseMove
		dotNet.addEventHandler lblT   "MouseDown" onLblTMouseDown 
		dotNet.addEventHandler lblT   "MouseUp" onLblTMouseUp
	
		--Custom Events
		dotnet.addEventHandler p0 "MouseDown" onMouseDown
		dotnet.addEventHandler p0 "MouseMove" onMouseMove1
		dotnet.addEventHandler p1 "MouseDown" onMouseDown
		dotnet.addEventHandler p1 "MouseMove" onMouseMove
		dotnet.addEventHandler p2 "MouseDown" onMouseDown
		dotnet.addEventHandler p2 "MouseMove" onMouseMove
		dotnet.addEventHandler p3 "MouseDown" onMouseDown
		dotnet.addEventHandler p3 "MouseMove" onMouseMove2
		
		dotnet.addEventHandler panel "Paint" onPaint
		-->
		--Add Controls
		panel.Controls.AddRange #(p0,p1,p2,p3)
		initButtonsCursor panel.Controls 	
		form.Controls.addRange ( #(panel, tlp, btnMin, lblT)  )
		OK
	),
	initialized = init()  --strange think but works
)
::mcDrawBezierDialog = DOTNET_MAIN_STRUCT title:"mcDrawBezierDialog"
::mcDrawBezierDialog.open()