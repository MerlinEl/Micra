global testRoll
try( testRoll.close(); testRoll.dispose() )catch()
(
	local transparent_color = (dotNetClass "system.drawing.color").fromArgb 0 50 50

	local button_fill_default_color = mcDotnet.dColor green
	local button_fill_hover_color = mcDotnet.dColor (color 153 228 114)
	local button_fill_press_color = mcDotnet.dColor (color 27 177 27)
	
	local button_outline_default_color = mcDotnet.dColor black
	local button_outline_hover_color = mcDotnet.dColor white
	local button_outline_press_color = mcDotnet.dColor green
	
	local button_outline_pen = dotNetObject "system.drawing.pen" button_outline_default_color 2	--color and thickness
	local button_fill_brush =  dotNetObject "System.Drawing.SolidBrush" button_fill_default_color
	
	fn drawArc gra rect start_angle end_angle radius:15 thickness:10 fil_color:white border_color:black border_thickness:3 = (
		
		local brush = dotNetObject "System.Drawing.SolidBrush" (mcDotnet.dColor fil_color) --background
		local pen = dotNetObject "system.drawing.pen" brush thickness 
		gra.DrawArc pen rect start_angle end_angle --draw arc fill	
	)
	fn drawElipse gra pos radius border_color:black border_thickness:2 = (
		
		local brush = dotNetObject "System.Drawing.SolidBrush" (mcDotnet.dColor border_color) --background
		local pen = dotNetObject "system.drawing.pen" brush border_thickness  
		local rect = mcDotnet.dRect pos ([radius*2, radius*2])
		gra.DrawEllipse pen  rect
	)
	fn drawRectangle gra rect fil_color:white border_color:black border_thickness:3 = (
		
		local fillBrush = dotnetobject "System.Drawing.SolidBrush" (mcDotnet.dColor fil_color)
		local outLinePen =dotNetObject "system.drawing.pen" (mcDotnet.dColor border_color) border_thickness	
		gra.FillRectangle fillBrush rect
	)
	fn drawRoundRectangle gra rect radius:15 fil_color:white border_color:black border_thickness:3 = (

		local diminisher = 1
		local gpath = dotNetobject "System.Drawing.Drawing2D.GraphicsPath"
		gpath.AddArc rect.X rect.Y radius  radius  180  90 
		gpath.AddArc (rect.X + rect.Width - radius - diminisher) rect.Y  radius radius 270 90
		gpath.AddArc (rect.X + rect.Width - radius - diminisher) (rect.Y + rect.Height - radius - diminisher) radius radius 0 90
		gpath.AddArc rect.X (rect.Y + rect.Height - radius - diminisher) radius radius 90 90
		gpath.CloseAllFigures()
		
		local fillBrush = dotNetObject "System.Drawing.SolidBrush" (mcDotnet.dColor fil_color)
		local outLinePen =dotNetObject "system.drawing.pen" (mcDotnet.dColor border_color) border_thickness	
		gra.FillPath fillBrush gpath
		gra.DrawPath outLinePen gpath	
	)
	fn createRoundRectanglePath rect radius:15 = (

		local diminisher = 1
		local gpath = dotNetobject "System.Drawing.Drawing2D.GraphicsPath"
		gpath.AddArc rect.X rect.Y radius  radius  180  90 
		gpath.AddArc (rect.X + rect.Width - radius - diminisher) rect.Y  radius radius 270 90
		gpath.AddArc (rect.X + rect.Width - radius - diminisher) (rect.Y + rect.Height - radius - diminisher) radius radius 0 90
		gpath.AddArc rect.X (rect.Y + rect.Height - radius - diminisher) radius radius 90 90
		gpath.CloseAllFigures()
		return gpath
	)
 	fn OnFormPaint s a = (
		
		local gra = a.graphics
		drawRectangle gra (mcDotnet.dRect [10,10] [100, 100]) fil_color:blue border_color:red	
		drawRoundRectangle gra (mcDotnet.dRect [120,10] [200, 100]) radius:40 fil_color:red border_color:blue	
		drawElipse gra [350,20] 40
		drawArc gra (mcDotnet.dRect [460,10] [100, 100]) 0 300 radius:15 thickness:10 fil_color:orange
 	)
	fn OnLabelPaint s a = (
		
		local gpath = createRoundRectanglePath s.ClientRectangle radius:22
		local gra = a.graphics
		gra.clear transparent_color
		
		gra.SmoothingMode = gra.SmoothingMode.AntiAlias
		gra.InterpolationMode = gra.InterpolationMode.HighQualityBilinear
        gra.CompositingQuality = gra.CompositingQuality.HighQuality
        gra.PixelOffsetMode = gra.PixelOffsetMode.HighQuality
		
		local fillBrush = dotNetObject "System.Drawing.SolidBrush" s.BackColor
		local outLinePen = dotNetObject "system.drawing.pen" s.ForeColor 2	--color and thickness
		gra.FillPath fillBrush gpath
		gra.DrawPath outLinePen gpath
		mcDotnet.TextRenderer.DrawText gra s.text s.Font s.ClientRectangle s.ForeColor
	)
	fn OnOkButtonPaint s a = (
		
		format "paint button\n"
-- 		format "paint button IsHovered :%\n" s.IsHovered 
		local gpath = createRoundRectanglePath s.ClientRectangle radius:22
		local gra = a.graphics
		gra.clear transparent_color
		gra.SmoothingMode = gra.SmoothingMode.AntiAlias
		gra.InterpolationMode = gra.InterpolationMode.HighQualityBilinear
        gra.CompositingQuality = gra.CompositingQuality.HighQuality
        gra.PixelOffsetMode = gra.PixelOffsetMode.HighQuality
-- 		outLinePen.Alignment = mcDotnet.PenAlignment.Inset
		gra.FillPath button_fill_brush gpath
		gra.DrawPath button_outline_pen gpath
		mcDotnet.TextRenderer.DrawText gra s.text s.Font s.ClientRectangle s.ForeColor
-- 		s.Invalidate() --Zruší platnost celého povrchu ovládacího prvku a zpusobí prekreslení ovládacího prvku.
	)
	fn OnOkButtonMouseEnter s a = (
		
		format "MouseEnter button\n"
-- 		button_fill_brush = dotNetObject "System.Drawing.SolidBrush" button_fill_hover_color
		button_outline_pen = dotNetObject "system.drawing.pen" button_outline_hover_color 2
	)
	fn OnOkButtonMouseLeave s a = (
		
		format "MouseLeave button\n"
-- 		button_fill_brush = dotNetObject "System.Drawing.SolidBrush" button_fill_default_color
		button_outline_pen = dotNetObject "system.drawing.pen" button_outline_default_color 2
	)
	fn onOkButtonMouseDown s a = (
		
		format "MouseDown button\n"
		button_fill_brush = dotNetObject "System.Drawing.SolidBrush" button_fill_press_color
		button_outline_pen = dotNetObject "system.drawing.pen" button_outline_press_color 2	--color and thickness
	)
	fn onOkButtonMouseUp s a = (
		
		format "MouseUp button\n"
		s.parent.close()
	)
 	testRoll = dotnetobject "System.Windows.Forms.Form"
	testRoll.StartPosition = testRoll.StartPosition.Manual
 	testRoll.width = 600
 	testRoll.height = 400
	testRoll.TopMost = true
	testRoll.Location = dotnetObject "Drawing.Point" 50 300
	testRoll.opacity = 0.8
	formBackColor=(dotNetClass "system.drawing.color").fromArgb 0 50 50
 	testRoll.backColor=formBackColor
 	testRoll.TransparencyKey=formBackColor
	
	testLbl = dotNetObject "Label"
	testLbl.text = "Test Label 00001"
	testLbl.font = mcDotnet.dFont font:"Arial" size:20 style:"Regular"
	testLbl.BackColor = mcDotnet.uiColor #back
	testLbl.ForeColor = mcDotnet.uiColor #text
-- 	testLbl.BorderStyle = testLbl.BorderStyle.None
	testLbl.textAlign = testLbl.textAlign.MiddleCenter
	testLbl.autosize = true
	testLbl.location = mcDotnet.dPoint [10, 150]
 	
	testBtn = dotNetObject "Button"
	testBtn.text = "OK"
	testBtn.font  = mcDotnet.dFont font:"Impact" size:20 style:"Regular"
-- 	testBtn.foreColor = mcDotnet.dColor black
-- 	testBtn.backColor = mcDotnet.dColor green
	testBtn.Bounds = mcDotnet.dRect [10, 200] [60, 32]
-- 	testBtn.FlatStyle = testBtn.FlatStyle.Flat
-- 	testBtn.FlatAppearance.BorderSize = 0
-- 	testBtn.FlatAppearance.MouseOverBackColor = (dotNetClass "system.drawing.color").fromArgb 0 50 50
		


	testRoll.controls.addRange #( testLbl, testBtn)
	
 	dotnet.addEventHandler testRoll "Paint" OnFormPaint
 	dotnet.addEventHandler testLbl "Paint" OnLabelPaint
 	dotnet.addEventHandler testBtn "Paint" OnOkButtonPaint
	dotNet.addEventHandler testBtn "MouseUp" onOkButtonMouseUp
	dotNet.addEventHandler testBtn "MouseDown" onOkButtonMouseDown
	dotNet.addEventHandler testBtn "MouseEnter" OnOkButtonMouseEnter
	dotNet.addEventHandler testBtn "MouseLeave" OnOkButtonMouseLeave
)	
testRoll.Show()