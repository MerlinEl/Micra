Global mcMenuRad

try(mcMenuRad.close()) catch()
	
fn genereteRadialButtons radius cnt pos:[0,0,0] = (

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
)	
	
	
fn buildRadialMenu rad:100 =
(
	global _b = ball = dotnetobject "System.Windows.Shapes.Ellipse"
	local transparent_color = mcDotnet.dColor (color 0 50 50)
	local mcolor = dotnetclass "System.Windows.Media.Color"
	ball.Width = 50
	ball.Height = 50
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
	
	local cv = dotnetobject "System.Windows.Controls.Canvas"
	cv.Width = ball.Width
	cv.Height = ball.Height
	cv.Children.Add ball
	
	
-- 	local btns = genereteRadialButtons 100 8 
-- 	for b in btns do format "btn:%\n" b--cv.Children.Add b
	
	
	
	local wp = dotnetobject "System.Windows.Window"
	--open window at mouse cursor
	wp.WindowStartupLocation = wp.WindowStartupLocation.Manual
	wp.Width = ball.Width + 40
	wp.Height = ball.Height + 50
	wp.Left = mouse.screenpos.x - wp.Width / 2
	wp.Top = mouse.screenpos.y - wp.Height / 2
	--set window transparency
	wp.WindowStyle = wp.WindowStyle.None
	wp.AllowsTransparency=true
	local scb =  dotnetobject "System.Windows.Media.SolidColorBrush" (mcolor.FromArgb 0 0 50 50)
	local mbrush = dotnetobject "System.Windows.Media.Brush" scb
	wp.Background = mbrush--(dotnetclass "System.Windows.Media.Colors").AliceBlue --transparent_color


	wp.Title = "ExtraToolball"
	wp.ShowInTaskbar = off

	fn onMouseDown s e =  (
		
		format "mouse down..."
	)
	dotnet.addeventhandler ball "MouseDown" onMouseDown
	fn onMouseUp s e =  (
		
		s.parent.parent.close()
		format "mouse up..."
	)
	
	dotnet.addeventhandler ball "MouseUp" onMouseUp
	wp.content = cv
	wih = dotnetobject "System.Windows.Interop.WindowInteropHelper" wp
	wih.owner = dotnetobject "IntPtr" (windows.getmaxhwnd())
	wp
)	
mcMenuRad = buildRadialMenu()
mcMenuRad.Show()

