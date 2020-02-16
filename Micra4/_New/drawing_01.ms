--DRAW LINES
try(destroydialog drawRol1) catch()
rollout drawRol1 "Draw lines on in Label" (
	
	dotNetControl lb "System.Windows.Forms.Label" width:180 height:30 pos:[10, 10]
	local pen = dotNetObject "system.drawing.pen" (dotNetClass "system.drawing.color").red 2  
	on lb mouseDown s a do (

		g = s.createGraphics() 
		g.DrawLine pen 0 a.y s.bounds.width a.y
	)
)
createdialog drawRol1 pos:[200, 200] width:200 height:50



--DRAW PIXELS
try(destroydialog drawRol2) catch()
rollout drawRol2 "Draw dots in Label" (
	
	dotNetControl lb "System.Windows.Forms.Label" width:180 height:30 pos:[10, 10]
	local clr = (dotnetClass "System.Drawing.Color").FromARGB 255 0 0
	local brush = undefined
	local brush_color = blue
	local brush_size = 8
	fn drawImageRect w h clr:green = (

		local bytesPixel = 0
		local hColor = dotNetClass "System.Drawing.Color"
		local hBitmap = dotNetObject "System.Drawing.Bitmap" w h
		for yPixel = 1 to h do (
		  for xPixel = 1 to w do (

			iPixel = (w*(yPixel-1))+xPixel
			jPixel = ((iPixel-1)*bytesPixel)+1
			local redPixel = clr.r
			local greenPixel = clr.g
			local bluePixel = clr.b
			local alphaPixel = 255
			local hColorPixel = (hColor.FromARGB alphaPixel redPixel greenPixel bluePixel)
			hBitmap.SetPixel (xPixel-1) (yPixel-1) hColorPixel
		  )
		)
		hBitmap
	)
	on drawRol2 open do (
		
		brush = drawImageRect brush_size brush_size clr:brush_color
	)
	on lb mouseDown s a do (

		g = s.createGraphics() 
		g.SmoothingMode = g.SmoothingMode.HighQuality
		g.DrawImage brush a.x a.y brush_size brush_size
	)
)
createdialog drawRol2 pos:[200, 300] width:200 height:50
--createdialog uiDotNetPictureBox style:#(#style_titlebar, #style_border, #style_sysmenu)

/*
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
			local brush =  createBrush 1 clr --thickness and color
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
*/


/*
(
	local bmpDisplayed = dotNetObject "System.Drawing.Bitmap" 100 100
	local bmpRectangle = dotNetObject "System.Drawing.Rectangle" 0 0 320 240
	
	rollout uiDotNetPictureBox ".NET PictureBox" width:320 height:240
	(
		dotNetControl uiPictureBox "System.Windows.Forms.PictureBox" pos:[0,0] width:320 height:240
		fn drawImageRect w h clr:green = (

			local bytesPixel = 0
			local hColor = dotNetClass "System.Drawing.Color"
			local hBitmap = dotNetObject "System.Drawing.Bitmap" w h
			for yPixel = 1 to h do (
			  for xPixel = 1 to w do (

				iPixel = (w*(yPixel-1))+xPixel
				jPixel = ((iPixel-1)*bytesPixel)+1
				local redPixel = clr.r
				local greenPixel = clr.g
				local bluePixel = clr.b
				local alphaPixel = 255
				local hColorPixel = (hColor.FromARGB alphaPixel redPixel greenPixel bluePixel)
				hBitmap.SetPixel (xPixel-1) (yPixel-1) hColorPixel
			  )
			)
			hBitmap
		)
		on uiPictureBox Paint senderArg paintEventArgs do
		(	
			bmpDisplayed = drawImageRect 2 2 clr:red
			g = paintEventArgs.Graphics
			g.SmoothingMode = g.SmoothingMode.HighQuality
			g.DrawImage bmpDisplayed bmpRectangle
		)
	)
	try(destroyDialog uiDotNetPictureBox) catch()
	createdialog uiDotNetPictureBox style:#(#style_titlebar, #style_border, #style_sysmenu)
)


*/




/*
(

rollout uiDotNetPictureBox ".NET PictureBox" width:512 height:512
(
	button btn_doit "You can do it!"
	dotNetControl uiPictureBox "System.Windows.Forms.PictureBox" width:320 height:240

	on btn_doit pressed do
	(
		local bmpRectangle = dotNetObject "System.Drawing.Rectangle" 0 0 512 512
		
		theBitmap=openBitmap @"C:/test.dds"
		theImage=dotnetObject "System.Drawing.Bitmap" theBitmap.Width theBitmap.Height
		for i=0 to theBitmap.Width-1 do
		(
			for j=0 to theBitmap.Height-1 do
			(
				bWH=getPixels theBitmap [i,j] 1
				theColor=(dotnetClass "System.Drawing.Color").FromARGB bWH[1].r bWH[1].g bWH[1].b
				theImage.SetPixel i j theColor		
			)
		)	
		close theBitmap
		theBitmap=""
		uiPictureBox.Image=theImage
	)
)

try(destroyDialog uiDotNetPictureBox) catch()
createdialog uiDotNetPictureBox style:#(#style_titlebar, #style_border, #style_sysmenu)
)
*/


