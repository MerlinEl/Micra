Global mcMenuRad

if isStruct mcMenuRad do mcMenuRad.close()	 

struct MICRA_RADIAL_MENU (
	
	window,
	drag_pos = [0,0,0], --form mouse pos
	fn createButton btn_name pos2P size2P = (
		
		local ball = dotnetobject "System.Windows.Shapes.Ellipse"
		ball.name = btn_name
		ball.tag = mcDotnet.dPoint pos2P
		
		local transparent_color = mcDotnet.dColor (color 0 50 50)
		local mcolor = dotnetclass "System.Windows.Media.Color"
		ball.Width = size2P.x
		ball.Height = size2P.y
		ball.Stroke = dotnetobject "System.Windows.Media.SolidColorBrush" (mcolor.FromArgb 150 20 20 20) --Black --MidnightBlue
		ball.StrokeThickness = 1.5

		local radBrush = dotnetobject "System.Windows.Media.RadialGradientBrush"
		local gpClass = dotnetclass "System.Windows.Media.GradientStop"
		local mcolors = dotnetclass "System.Windows.Media.Colors"
		
		radBrush.GradientOrigin = dotnetobject "System.Windows.Point" 0.25 0.25
		radBrush.GradientStops.Add (dotnetobject gpClass mcolors.White 0.0) 
		radBrush.GradientStops.Add (dotnetobject gpClass mcolors.LightSteelBlue 0.95) 
		radBrush.GradientStops.Add (dotnetobject gpClass mcolors.SlateGray 0.99) 

		ball.Fill = radBrush
		ball
	),	
	fn generateArcButtons radius cnt center:[0,0] size:[32, 32] = (
		
		
	),
	--Move Window
	fn onMouseMove s a = ( 
		
	--	if a.Button == a.Button.left do  ( --dragForm
			
			---s.parent mcMenuRad.drag_pos 
		--)
	), 
	fn onMouseDown s a = (
			
		--local form = s.parent.parent
		--local form = s.parent.parent
		--form.cursor.current = netCursors.Hand
		--if a.Button == a.Button.left do ( --enable drag
			--mcPopUp._drag_pos = [form.MousePosition.x, form.MousePosition.y] - [form.left, form.top] 
	--	)
	),
	fn onMouseUp s a =  (
		
		case s.name of (
			
			"btn_00" : (
				
				if a.ChangedButton == mcDotnet.MouseButton.Right do s.parent.parent.close()
				if a.ChangedButton == mcDotnet.MouseButton.Left do ()
			)
			default : (
				
				--generateArcButtons	
			)
		)
		format "mouse up... btn:%\n" s.name 
	),
	fn genereteRadialButtons radius cnt center:[0,0] size:[32, 32] = (

		local btns = #()
		local div = 360.0 / cnt
		for i = 1 to cnt do (
			
			local step = div*i
			local v = [cos step, sin step] 
			local p = center + (v * radius) 
			local btn = createButton ("btn_0" + i as string) p size
			dotnet.addeventhandler btn "MouseUp" onMouseUp
			append btns btn
		)
		btns
	),
	fn buildRadialMenu btns_count  rad:50 size_1:48 size_2:32 = (
		
		local min_size = (size_1 + size_2) / 2
		if  min_size > rad do rad = min_size
		--local rad = size_1 + size_2 * 2 
		local pos_1 = [rad - size_1 / 2, rad - size_1 / 2]
		local pos_2 = [rad - size_2 / 2, rad - size_2 / 2]
		local mcolor = dotnetclass "System.Windows.Media.Color"
		
		local center_button = createButton "btn_00" pos_1 [size_1, size_1]
		dotnet.addeventhandler center_button "MouseDown" onMouseDown
		dotnet.addeventhandler center_button "MouseUp" onMouseUp
		dotnet.addeventhandler center_button "MouseMove" onMouseMove
		
		local radial_buttons = genereteRadialButtons rad btns_count center:pos_2 size:[size_2, size_2]
		append radial_buttons center_button
		
		local cv = dotnetobject "System.Windows.Controls.Canvas"
		cv.Width = rad*2
		cv.Height = rad*2
		
		for btn in radial_buttons do (
			
			--format "add button:% at:%\n" btn.name [btn.tag.x, btn.tag.y]
			local pos = btn.tag
			if pos != undefined do (
				
				cv.SetLeft btn pos.x
				cv.SetTop btn pos.y
			)
			cv.Children.Add btn
		)
		--create window component
		local wp = dotnetobject "System.Windows.Window"
		wp.Width = rad*2 + size_2
		wp.Height = rad*2 + size_2
		--open window at mouse cursor
		wp.WindowStartupLocation = wp.WindowStartupLocation.Manual
		local mouse_hit = mouse.screenpos - ( [rad, rad]  / 2 )
		wp.Left = mouse_hit.x - rad / 2 - size_1 / 2
		wp.Top = mouse_hit.y - rad / 2 - size_1 / 2
		--set window transparency
		wp.WindowStyle = wp.WindowStyle.None
		wp.AllowsTransparency = true
		local scb =  dotnetobject "System.Windows.Media.SolidColorBrush" (mcolor.FromArgb 0 0 50 50)
		local mbrush = dotnetobject "System.Windows.Media.Brush" scb
		wp.Background = mbrush--(dotnetclass "System.Windows.Media.Colors").AliceBlue --transparent_color
		--
		wp.Title = "ExtraToolball"
		wp.ShowInTaskbar = off
		--add canvas
		wp.content = cv
		--bind window in to max form
		local wih = dotnetobject "System.Windows.Interop.WindowInteropHelper" wp
		wih.owner = dotnetobject "IntPtr" (windows.getmaxhwnd())
		window = wp
	),
	fn show = (window.show()),
	fn close = (window.close())
)
-- cnt = min_max = [1, 7]
mcMenuRad = MICRA_RADIAL_MENU()
mcMenuRad.buildRadialMenu 7  rad:40 size_1:42 size_2:32 --max 20 (size 32)
mcMenuRad.Show()

/*
eli = dotnetobject "System.Windows.Shapes.Ellipse"
.Cursor : <System.Windows.Input.Cursor>  
.Dispatcher : <System.Windows.Threading.Dispatcher>, read-only
.Effect : <System.Windows.Media.Effects.Effect>
.Fill : <System.Windows.Media.Brush>
.Focusable : <System.Boolean>
.HorizontalAlignment : <System.Windows.HorizontalAlignment>
.Margin : <System.Windows.Thickness>
.Name : <System.String>
.Opacity : <System.Double>
.OpacityMask : <System.Windows.Media.Brush>
.ToolTip : <System.Object>
.Style : <System.Windows.Style>
.Tag : <System.Object>
.VerticalAlignment : <System.Windows.VerticalAlignment>

*/