(
	rollout uiDotNetPictureBox "Dot.Net Canvas:" width:320 height:240
	(
		dotNetControl canvas "System.Windows.Forms.PictureBox" pos:[0,0] width:320 height:240
		fn createBrush size clr = (
			
			local bm = dotnetobject "System.Drawing.Bitmap" size size
			bm.SetPixel 0 0 (mcDotnet.dColor clr)
			bm
		)
		fn drawCircle graphics radius clr = (
			
			local g = graphics
			local radian = pi / 180
			local brush =  createBrush 200 clr --thickness and color
			for j = 1 to 5 do ( --how many circles
				
				local radius = (j + 1) * 5
				for i = 0 to 360 do ( --points around circle
					
					local ang = i * radian
					local pos_x = int ( 150 + radius * (cos ang) )
					local pos_y = int ( 150 + radius * (sin ang) )
					g.DrawImageUnscaled brush pos_x pos_y
				)
			)
		)
		on canvas Paint s a do (	
			
			local g = a.Graphics
			g.SmoothingMode = g.SmoothingMode.HighQuality
			drawCircle g 5 blue
		)
	)
	try(destroyDialog uiDotNetPictureBox) catch()
	createdialog uiDotNetPictureBox style:#(#style_titlebar, #style_border, #style_sysmenu)
)