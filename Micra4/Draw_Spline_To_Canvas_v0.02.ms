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
		_mcs.canvas.Invalidate()
	),
	fn onBtnDrawClick s a = (
	
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
		-- sp_verts = mcArray.reverseArray sp_verts
		local spline_ui_points = #()
		local colors = #(red, green ,blue , orange, brown, black, black, black, black)
		format "onBtnDrawClick > verts count:%\n" sp_verts.count
		local vertex_data = #()
		for i=1 to sp_verts.count do (
		
			local v = sp_verts[i]
			local pos = v.pos - zero_offset--translate pos to zero
			local inVect = v.inVec - zero_offset --translate pos to zero
			local outVec = v.outVec - zero_offset --translate pos to zero
			format "onBtnDrawClick > vert:% type:% pos:% zero_offset:%  inVect:% outVect:%\n" v.index v.type pos zero_offset inVec outVec
			
			append vertex_data (dotNetMXSValue v)
			
			local spline_point	= dotnetobject "UserControl"
			local handle_in		= dotnetobject "UserControl"
			local handle_out		= dotnetobject "UserControl"
			
			spline_point.Bounds = dotnetobject "System.Drawing.Rectangle" pos.x pos.y dot_size dot_size
			spline_point.Backcolor = mcDotnet.dColor colors[i*i+1] --spline_point.Backcolor.Red
			spline_point.tag = v.type as String
			
			handle_in.Bounds = dotnetobject "System.Drawing.Rectangle" inVect.x inVect.y handle_size handle_size
			handle_in.Backcolor = mcDotnet.dColor colors[i*i]--handle_in.Backcolor.Green

			handle_out.Bounds = dotnetobject "System.Drawing.Rectangle" outVec.x outVec.y handle_size handle_size
			handle_out.Backcolor = mcDotnet.dColor colors[i*i+2]--handle_in.Backcolor.Green
			
			-- dotnet.addEventHandler spline_point "MouseDown" _mcs.onMouseDown
			-- dotnet.addEventHandler spline_point "MouseMove" _mcs.onMouseMove1
			-- dotNet.setLifeTimeControl spline_point #dotNet
			
			join spline_ui_points #(spline_point, handle_in, handle_out) 
		)
		_mcs.canvas.Controls.AddRange spline_ui_points
		format "vertex data array\n" 
		for v in vertex_data do format "\t%\n" v
		local type = dotnetclass "System.Object[]"
		_mcs.canvas.tag = vertex_data --DotNet value holding the MAXScript value
		--_mcs.canvas.tag = dotNet.ValueToDotNetObject vertex_data type --DotNet value holding the MAXScript value
		-- local type = dotnetclass "System.Single[][]"
		--_mcs.canvas.tag = dotnet.ValueToDotNetObject vertex_data typefa --DotNet value holding the MAXScript value
	), 
	fn onPaint s a = ( -- s:Forms.UserControl	a:Forms.PaintEventArgs

		format "onPaint > controls count:%\n" s.Controls.count
		local _mcs = gMcDrawBezierDialog --struct instance
		if s.Controls.count < 2 or _mcs.canvas.tag == undefined do return false

/*local vertex_data = _mcs.canvas.tag--.value		
for i = 1 to vertex_data.count do  (

	local vd = vertex_data[i].value
	format "vertex_data:%\n" vd
)
return ok*/
		local g = a.Graphics
		g.SmoothingMode = g.SmoothingMode.HighQuality
		-- g.SmoothingMode = g.SmoothingMode.AntiAlias
		-- g.Clear(_mcs.canvas.Backcolor)
			format "onPaint >_mcs.canvas.tag:%\n" _mcs.canvas.tag
		local vertex_data = _mcs.canvas.tag
		fn point3DtoXY p = ( [p.x, p.y] )
		-- _mcs.cPen.Width = 6.0F
		for i = 1 to vertex_data.count by 2 do ( -- 
			
			local d1 = vertex_data[i].value
			local d2 = (
			
				if (i < vertex_data.count) then vertex_data[i+1].value else vertex_data[1].value
			)
			format "onPaint > d1:%\n" d1
			format "onPaint > d2:%\n" d2
			
			local spline_point_a	= point3DtoXY d1.pos
			local spline_point_b	= point3DtoXY d2.pos
			local point_a_out	= point3DtoXY d1.outVec 
			local point_b_in		= point3DtoXY d2.inVec 
			local type_a			= d1.type
			local type_b			= d2.type
			format "onPaint > vert_a( % ) pos:% type:% vert_b( % ) pos:% type:%\n" d1.index spline_point_a type_a d2.index spline_point_b type_b
			
			/*c1 = s.Controls.Item[i]
			c2 = s.Controls.Item[i+3]
			format "c1:% c2:%\n" c1 c2*/
			--c1.Backcolor = c1.Backcolor.Yellow
			--c2.Backcolor = c2.Backcolor.Blue
			
			-- g.DrawLine _mcs.cPen spline_point_a spline_point_b
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
		dotNet.addEventHandler btnDraw  "MouseUp" onBtnDrawClick
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


/*
			--e.Graphics.ScaleTransform(1.75f, 0.5f);
		
		grp.ScaleTransform(1, 2) 'zvětším vše v Y směru dvakrát
		grp.DrawString(sHodnota, pFont, pBrush, posX, posY * 0.5, sf) 
		'tady manipuluji s Y souřadnicí výchozího bodu, 
		protože transformace ji ovlivní také ale pořád je text jinde než očekávám
		'nebo obdobně s objektem RectangleF grp.DrawString(sHodnota, pFont, pBrush, rect, sf)
		grp.ResetTransform()
		
		-- messageBox "Drawing a Shape." title:"Warning:"	
--_mcs.canvas "System.Drawing.Rectangle" outVec.x outVec.y handle_size handle_size
-- _mcs.canvas.Grapgics.Clear()
-- _mcs.form.backColor = mcDotnet.dColor (mcUIColors.get #fore)
*/