Global uiDotNetPictureBox
if uiDotNetPictureBox != undefined do uiDotNetPictureBox.close()
fn netDrawCircle radius offset:[0, 0] thickness:10 clr:blue = (	
	
-- 	local way = (dotnetclass "System.Drawing.Drawing2D.LinearGradientMode").Vertical --ForwardDiagonal
-- 	local rect = mcDotnet.dRect [0, 0] [radius*2, radius*2]
-- 	local brush = dotnetobject "System.Drawing.Drawing2D.LinearGradientBrush" rect (mcDotnet.dColor white) (mcDotnet.dColor blue) way
	local brush = dotNetObject "System.Drawing.SolidBrush" (mcDotnet.dColor clr)
-- 	local pen = dotNetObject "system.drawing.pen" (mcDotnet.dColor clr) thickness  
	local pen = dotNetObject "system.drawing.pen" brush thickness  
	local bm = mcDotnet.dBitmap [radius*2, radius*2]
	local g = mcDotnet.Graphics.FromImage bm 
-- 	g.Clear(mcDotnet.dColor black);
-- 	g.SmoothingMode = g.SmoothingMode.HighQuality
	g.SmoothingMode = g.SmoothingMode.AntiAlias
	local px = offset.x + thickness / 2
	local py = offset.y + thickness / 2
	radius -= thickness
-- 	format "canvas px:% py:%\n" px py
	local first_point1 = int( (Cos 0) * radius + px)
	local first_point2 = int( (Sin 0) * radius + py)

	local p1= [first_point1, first_point2]
	for i = 1 to 360 do (
	
		local dx = int( (Cos i) * radius + px)
		local dy = int( (Sin i) * radius + py)
		local p2 = [dx, dy]
		g.DrawLine pen (mcDotnet.dPoint p1) (mcDotnet.dPoint p2)
		p1 = p2
	)
	bm
)
fn netDrawArc radius start_angle end_angle  offset:[0, 0] thickness:10 clr:blue = (
	
	local brush_1 = dotNetObject "System.Drawing.SolidBrush" (mcDotnet.dColor gray) --background
	local brush_2 = dotNetObject "System.Drawing.SolidBrush" (mcDotnet.dColor clr) --fill arc
	local brush_3 = dotNetObject "System.Drawing.SolidBrush" (mcDotnet.dColor red) --border
	local pen_1 = dotNetObject "system.drawing.pen" brush_1 thickness  
	local pen_2 = dotNetObject "system.drawing.pen" brush_2 thickness  
	local pen_3 = dotNetObject "system.drawing.pen" brush_3 2  
	local bm = dotNetObject "System.Drawing.Bitmap" (radius*2) (radius*2)
	local g = mcDotnet.Graphics.FromImage bm 
	g.Clear(mcDotnet.dColor black) --(color 0 50 50))
	g.SmoothingMode = g.SmoothingMode.AntiAlias
	
-- graphics.InterpolationMode = System.Drawing.Drawing2D.InterpolationMode.HighQualityBilinear;
-- graphics.CompositingQuality = System.Drawing.Drawing2D.CompositingQuality.HighQuality;
-- graphics.PixelOffsetMode = System.Drawing.Drawing2D.PixelOffsetMode.HighQuality;
-- graphics.SmoothingMode = System.Drawing.Drawing2D.SmoothingMode.AntiAlias;
	
    --Create rectangle to bound ellipse.
	local pos = [thickness, thickness]
    local rect = mcDotnet.dRect pos ([radius*2, radius*2] - thickness*2)
    local rect_out = mcDotnet.dRect [0,0] ([radius*2, radius*2] - thickness*2)
   --Draw arc to screen.
	g.DrawEllipse pen_1 rect
    g.DrawArc pen_2 rect start_angle end_angle
	g.DrawEllipse pen_3 rect_out	
	bm
)
fn createDotnetProgressBar radius thickness percent = (
	
	local margins = 0
	local form_size =  radius*2 + margins*2
	local form = dotNetObject "MaxCustomControls.MaxForm"
	local canvas = dotNetObject  "System.Windows.Forms.PictureBox"
	local transparent_color = mcDotnet.dColor (color 0 50 50)
	form.StartPosition = form.StartPosition.Manual
	form.ShowInTaskBar = false
	form.FormBorderStyle = form.FormBorderStyle.None
	form.AllowTransparency=false
	form.TransparencyKey = transparent_color
	form.width = form_size
	form.height = form_size
-- 	form.location = mcDotnet.dPoint [140, 400]
	form.location = mcDotnet.dPoint (mcSystem.getMaxCenter() - [form.width, form.height] / 2)
	form.opacity = 0.8
	
-- 	canvas.Image = netDrawCircle radius offset:[radius, radius]  thickness:thickness clr:green
	local percent_to_angle = (360.0 / 100.0) * percent
	canvas.Image = netDrawArc radius -90 percent_to_angle offset:([form_size, form_size]/2) thickness:thickness clr:green
	
	
	canvas.BorderStyle = canvas.BorderStyle.None
	canvas.bounds = mcDotnet.dRect [margins,  margins] [form_size, form_size]
	--canvas.bounds = mcDotnet.dRect [margins - thickness/2, margins- thickness/2] [radius*2 + thickness, radius*2 + thickness]
	canvas.backColor = transparent_color
	
	--dotnet.addEventHandler canvas "Paint" onCanvasPaint
	
	
	--if uiDotNetPictureBox == undefined or not uiDotNetPictureBox.visible do (
		
		form.controls.add canvas
		uiDotNetPictureBox = form
		local hv = DotNetObject "NativeWindow"
		hv.AssignHandle (DotNetObject "System.IntPtr" (Windows.GetMaxHWND())) 
		uiDotNetPictureBox.show(hv)
	--)
)
createDotnetProgressBar 148 30 90 --progress percentage