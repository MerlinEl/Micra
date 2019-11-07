Global gMcDrawBezierDialog 
/**
*@Created by denisT 2011
*@Modified by MerlinEl 2019
*@Example
	----
*/
if ::gMcDrawBezierDialog != undefined do try(gMcDrawBezierDialog.close())catch()
struct sgMcDrawBezierDialog  (
	
public	
	title,
	--define interface components
	form = dotNetObject "MaxCustomControls.MaxForm",
	lblT = dotNetObject "label",
	btnMin = dotNetObject "button",
	tlp = dotNetObject "TableLayoutPanel",
	canvas = dotnetobject "UserControl",		
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
	btnDraw = dotNetObject "button",
	btnClear = dotNetObject "button",
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
	
		local _mcs = gMcDrawBezierDialog --struct instance
		if _mcs.netDMove do  mcDialog.moveAndSnap _mcs.form
	),
	fn onLblTMouseDown s a = ( --start drag
			
		local _mcs = gMcDrawBezierDialog --struct instance
		_mcs.form.cursor.current = netCursors.Hand
		if a.Button == a.Button.left do ( --enable drag
		
			mcDialog.init _mcs.form
			_mcs.netDMove = true 
		)
	),
	fn onLblTMouseUp s a = --stop drag
	(
		local _mcs = gMcDrawBezierDialog --struct instance
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
		
		local _mcs = gMcDrawBezierDialog --struct instance
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
	public fn onMouseDown s a = if a.Button == a.Button.Left do ( s.tag = a.Location ),
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
	fn clearCanvas s a = (
	
		local _mcs = gMcDrawBezierDialog --struct instance
		_mcs.canvas.Controls.Clear()
		-- _mcs.canvas.Grapgics.Clear()
		-- _mcs.form.backColor = mcDotnet.dColor (mcUIColors.get #fore)
	),
	fn drawOnCanvas s a = (
	
		local dot_size = 9
		local handle_size = 5
		local canvas_margins = 4
		local sp = selection[1]
		local _mcs = gMcDrawBezierDialog --struct instance
		_mcs.clearCanvas s a
		if classOf sp != SplineShape and classOf sp != Line do return false
		local sp_data = mcSpline.splineToScript sp
		local rect = sp_data.rect
		_mcs.canvas.width = rect.wi + dot_size + canvas_margins --rect.ma.x - rect.mi.x --
		_mcs.canvas.height = rect.he + dot_size + canvas_margins --rect.ma.y - rect.mi.y --
		-- local zero_offset = sp_data.pos + [] --move spline to center
		local zero_offset = sp_data.pos - canvas_margins / 2 --move spline center to top left corner
		zero_offset.x -= rect.wi / 2 --move spline to center x
		zero_offset.y -= rect.he / 2 --move spline to center y	
		local sp_verts = sp_data.splines[1]
		local spline_ui_points = #()
		for i=1 to sp_verts.count do (
		
			local v = sp_verts[i]
			local pos = v.pos - zero_offset--translate pos to zero
			local inVect = v.inVec - zero_offset --translate pos to zero
			local outVec = v.outVec - zero_offset --translate pos to zero
			format "vert:% type:% pos:% zero_offset:%  inVect:% outVect:%\n" i v.type pos zero_offset inVec outVec
			
			local spline_point	= dotnetobject "UserControl"
			local handle_in		= dotnetobject "UserControl"
			local handle_out		= dotnetobject "UserControl"
			
			spline_point.Bounds = dotnetobject "System.Drawing.Rectangle" pos.x pos.y dot_size dot_size
			spline_point.Backcolor = spline_point.Backcolor.Red
			
			handle_in.Bounds = dotnetobject "System.Drawing.Rectangle" inVect.x inVect.y handle_size handle_size
			handle_in.Backcolor = handle_in.Backcolor.Green

			handle_out.Bounds = dotnetobject "System.Drawing.Rectangle" outVec.x outVec.y handle_size handle_size
			handle_out.Backcolor = handle_in.Backcolor.Green
			
			dotnet.addEventHandler spline_point "MouseDown" _mcs.onMouseDown
			dotnet.addEventHandler spline_point "MouseMove" _mcs.onMouseMove1
			
			--dotNet.setLifeTimeControl spline_point #dotNet
			
			join spline_ui_points #(spline_point, handle_in, handle_out) 
		)
		_mcs.canvas.Controls.AddRange spline_ui_points
		--e.Graphics.ScaleTransform(1.75f, 0.5f);
		/*
		grp.ScaleTransform(1, 2) 'zvětším vše v Y směru dvakrát
		grp.DrawString(sHodnota, pFont, pBrush, posX, posY * 0.5, sf) 
		'tady manipuluji s Y souřadnicí výchozího bodu, 
		protože transformace ji ovlivní také ale pořád je text jinde než očekávám
		'nebo obdobně s objektem RectangleF grp.DrawString(sHodnota, pFont, pBrush, rect, sf)
		grp.ResetTransform()
		*/
		-- messageBox "Drawing a Shape." title:"Warning:"
	), 
	fn onPaint s a = ( -- s:Forms.UserControl	a:Forms.PaintEventArgs
		
		format "controls count:%\n" s.Controls.count
		if s.Controls.count < 2 do return false
		local _mcs = gMcDrawBezierDialog --struct instance
		fn cpoint s id = (
		
			local c = s.Controls.Item[id]
			dotnetobject "System.Drawing.Point" (c.Location.x + c.Size.width/2) (c.Location.y + c.Size.height/2) 
		)
		local g = a.Graphics
		g.SmoothingMode = g.SmoothingMode.HighQuality
		--g.Clear(_mcs.canvas.Backcolor)
		struct POINT_DATA (pos, inVect, outVec)
		local points_data = for i = 0 to s.Controls.count - 1 by 3 collect POINT_DATA (cpoint s i) (cpoint s (i+1)) (cpoint s (i+2)) 
		-- mcArray.reverseArray points_data
		for i = 1 to points_data.count by 2 do ( -- 
			
			local d1 = points_data[i]
			local d2 = (
			
				if (i < points_data.count) then points_data[i+1] else points_data[1]
			)
			local spline_point_a	= d1.pos
			local spline_point_b	= d2.pos
			local point_a_out	= d1.outVec 
			local point_b_in		= d2.inVect 
			
			g.DrawBezier _mcs.cPen spline_point_a point_a_out point_b_in spline_point_b
			-- g.DrawLine _mcs.aPen spline_point_a point_a_out
			-- g.DrawLine _mcs.bPen spline_point_b point_b_in
		)
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
		canvas.Backcolor = canvas.Backcolor.LightYellow
		canvas.bounds = tlp.Bounds
		btnDraw.text = "Draw"
		btnClear.text = "Clear"
		btnDraw.bounds = mcDotnet.dRect [size.x-120, size.y-66] [100 , 24]
		btnClear.bounds = mcDotnet.dRect [size.x-220, size.y-66] [100 , 24]
		---canvas.Dock = canvas.Dock.Fill
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
		dotnet.addEventHandler canvas "Paint" onPaint
		dotNet.addEventHandler btnDraw  "MouseUp" drawOnCanvas
		dotNet.addEventHandler btnClear "MouseUp" clearCanvas
		-->
		--Add Controls	
		form.Controls.addRange ( #(btnDraw, btnClear, canvas, tlp, btnMin, lblT)  )
		OK
	),
	initialized = init()  --strange think but works
)
::gMcDrawBezierDialog = sgMcDrawBezierDialog title:"gMcDrawBezierDialog"
::gMcDrawBezierDialog.open()