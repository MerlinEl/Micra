Global uiDotNetPictureBox
if uiDotNetPictureBox != undefined do DestroyDialog uiDotNetPictureBox
rollout uiDotNetPictureBox "Dot.Net Canvas:" width:320 height:240
(
	dotNetControl canvas "System.Windows.Forms.PictureBox" pos:[0,0] width:320 height:240
	local pen = dotNetObject "system.drawing.pen" (dotNetClass "system.drawing.color").blue 10  
	on canvas Paint s a do (	
		
		local g = a.Graphics
		g.SmoothingMode = g.SmoothingMode.HighQuality
		
		local radius = 100
		local px = canvas.Width/2
		local py = canvas.Height/2
		format "canvas px:% py:%\n" px py
		local first_point1 = int( (Cos 0) * radius + px)
		local first_point2 = int( (Sin 0) * radius + py)

		local p1= [first_point1, first_point2]
		for i = 1 to 500 do (
		
			local dx = int( (Cos i) * radius + px)
			local dy = int( (Sin i) * radius + py)
			local p2 = [dx, dy]
			g.DrawLine pen (mcDotnet.dPoint p1) (mcDotnet.dPoint p2)
			p1 = p2
		)
	)
)
try(destroyDialog uiDotNetPictureBox) catch()
createdialog uiDotNetPictureBox style:#(#style_titlebar, #style_border, #style_sysmenu)
