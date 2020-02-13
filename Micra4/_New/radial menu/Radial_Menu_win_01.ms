
try(wp.close()) catch()
fn makeToolBall size:[50,50] =
(
	global _b = ball = dotnetobject "System.Windows.Shapes.Ellipse"
	local transparent_color = mcDotnet.dColor (color 0 50 50)
	local mcolor = dotnetclass "System.Windows.Media.Color"
	ball.Width = size.x
	ball.Height = size.y
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
	
	local wp = dotnetobject "System.Windows.Window"
	wp.WindowStartupLocation = wp.WindowStartupLocation.Manual
	wp.Left = 800
	wp.Top = 200
	wp.Width = ball.Width + 40
	wp.Height = ball.Height + 50
	wp.WindowStyle = wp.WindowStyle.None ---wp.WindowStyle.ToolWindow

	wp.AllowsTransparency=true
	
	scb =  dotnetobject "System.Windows.Media.SolidColorBrush" (mcolor.FromArgb 0 0 50 50)
	mbrush = dotnetobject "System.Windows.Media.Brush" scb
	wp.Background = mbrush--(dotnetclass "System.Windows.Media.Colors").AliceBlue --transparent_color
		--wp.TransparencyKey = transparent_color



	wp.Title = "ExtraToolball"
	wp.ShowInTaskbar = off

	fn onMouseDown s e = 
	(
		format "mouse down..."
	)
	dotnet.addeventhandler ball "MouseDown" onMouseDown
	fn onMouseUp s e = 
	(
		s.parent.parent.close()
		format "mouse up..."
	)
	dotnet.addeventhandler ball "MouseUp" onMouseUp
	wp.content = cv
	
	wih = dotnetobject "System.Windows.Interop.WindowInteropHelper" wp
	wih.owner = dotnetobject "IntPtr" (windows.getmaxhwnd())

	wp
)	
wp = makeToolBall()
wp.Show()

