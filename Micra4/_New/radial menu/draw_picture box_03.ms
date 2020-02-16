Global uiDotNetPictureBox
if uiDotNetPictureBox != undefined do uiDotNetPictureBox.close()
fn drawCircle radius offset:[0, 0] thickness:10 clr:blue = (	
	
	local pen = dotNetObject "system.drawing.pen" (mcDotnet.dColor clr) thickness  
	local bm = dotNetObject "System.Drawing.Bitmap" (radius*2) (radius*2)
	local g = (dotnetclass "system.drawing.graphics").fromImage bm 
	g.SmoothingMode = g.SmoothingMode.HighQuality
	local px = offset.x + thickness / 2
	local py = offset.y + thickness / 2
	radius -= thickness
	format "canvas px:% py:%\n" px py
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
fn createDotnetCircle radius thickness = (
	
	local margins = 2
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
	form.location = mcDotnet.dPoint [140, 400]
-- 	form.location = mcDotnet.dPoint (mcSystem.getMaxCenter() - [form.width, form.height] / 2)
	--form.opacity = 0.9
	
	canvas.Image = drawCircle radius offset:[radius, radius]  thickness:thickness clr:green
	canvas.BorderStyle = canvas.BorderStyle.None
	canvas.bounds = mcDotnet.dRect [margins/2 - thickness/2, margins/2- thickness/2] [radius*2 + thickness, radius*2 + thickness]
	canvas.backColor = transparent_color
	
	--dotnet.addEventHandler canvas "Paint" onCanvasPaint
	
	form.controls.add canvas
	
	uiDotNetPictureBox = form
	local hv = DotNetObject "NativeWindow"
	hv.AssignHandle (DotNetObject "System.IntPtr" (Windows.GetMaxHWND())) 
	uiDotNetPictureBox.show(hv)
)
createDotnetCircle 100 10