Global uiDotNetPictureBox
if uiDotNetPictureBox != undefined do uiDotNetPictureBox.close()
fn netDrawArc radius start_angle end_angle  offset:[0, 0] thickness:10 fill_clr:blue border_clr:black= (
	
	local brush_1 = dotNetObject "System.Drawing.SolidBrush" (mcDotnet.dColor gray) --background
	local brush_2 = dotNetObject "System.Drawing.SolidBrush" (mcDotnet.dColor fill_clr) --fill arc
	local brush_3 = dotNetObject "System.Drawing.SolidBrush" (mcDotnet.dColor border_clr) --border
	local pen_1 = dotNetObject "system.drawing.pen" brush_1 thickness  
	local pen_2 = dotNetObject "system.drawing.pen" brush_2 thickness  
	local pen_3 = dotNetObject "system.drawing.pen" brush_3 2  
	local bm = dotNetObject "System.Drawing.Bitmap" (radius*2) (radius*2)
	local g = mcDotnet.Graphics.FromImage bm 
	g.Clear(mcDotnet.dColor (color 0 50 50)) -- blue)
	--set best quality
	g.InterpolationMode = g.InterpolationMode.HighQualityBilinear
	g.CompositingQuality = g.CompositingQuality.HighQuality
	g.PixelOffsetMode = g.PixelOffsetMode.HighQuality
	g.SmoothingMode = g.SmoothingMode.AntiAlias
    --Create rectangle to bound ellipse.
	local pos_1 = [thickness, thickness]/2 + 1
	local pos_2 = [1, 1]
	local pos_3 = [1, 1] + thickness
    local rect = mcDotnet.dRect pos_1 ([radius*2, radius*2] - thickness-2)
    local rect_out = mcDotnet.dRect pos_2 ([radius*2, radius*2]-2)
	local rect_in = mcDotnet.dRect pos_3 ([radius*2, radius*2]-2 - thickness*2)
   --Draw arc to screen.
	g.DrawEllipse pen_1 rect --draw circle background
    g.DrawArc pen_2 rect start_angle end_angle --draw arc fill
	g.DrawEllipse pen_3 rect_out --draw outer border
	g.DrawEllipse pen_3 rect_in	--draw inner border
	bm
)
fn createDotnetProgressBar radius thickness percent = (
	
	local margins = 0
	local form_size =  radius*2 + margins*2
	local form_center = [form_size, form_size]/2
	local form = dotNetObject "MaxCustomControls.MaxForm"
	local canvas = dotNetObject  "System.Windows.Forms.PictureBox"
	local lbl_info = dotnetObject "Label"
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
	canvas.Image = netDrawArc radius -90 percent_to_angle offset:form_center thickness:thickness fill_clr:green border_clr:(color 6 50 6)
	canvas.BorderStyle = canvas.BorderStyle.None
	canvas.bounds = mcDotnet.dRect [margins,  margins] [form_size, form_size]
	--canvas.bounds = mcDotnet.dRect [margins - thickness/2, margins- thickness/2] [radius*2 + thickness, radius*2 + thickness]
	canvas.backColor = transparent_color
	
	lbl_info.font = mcDotnet.dFont font:"Arial" size:50 style:"Regular"
	lbl_info.AutoSize = true
	lbl_info.textAlign = lbl_info.textAlign.MiddleCenter
	lbl_info.text = "100%"
	lbl_info.update()
	lbl_info.invalidate()
	--lbl_info.size = mcDotnet.dSize [radius+45, radius]
	lbl_info.location = mcDotnet.dPoint (form_center - [lbl_info.width/2, lbl_info.height/2])
	lbl_info.foreColor = mcDotnet.dColor white
	lbl_info.backColor = transparent_color
	--dotnet.addEventHandler canvas "Paint" onCanvasPaint
	
	
	--if uiDotNetPictureBox == undefined or not uiDotNetPictureBox.visible do (
		
		form.controls.addRange #(lbl_info, canvas)
		uiDotNetPictureBox = form
		local hv = DotNetObject "NativeWindow"
		hv.AssignHandle (DotNetObject "System.IntPtr" (Windows.GetMaxHWND())) 
		uiDotNetPictureBox.show(hv)
	--)
)
createDotnetProgressBar 148 30 90 --progress percentage
	--uiDotNetPictureBox.lbl_info.location = mcDotnet.dPoint (([uiDotNetPictureBox.width, uiDotNetPictureBox.height]/2) - [lbl_info.width/2, lbl_info.height])