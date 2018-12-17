Fn ScreenCapture PosX PosY ImgW ImgH ImgFileName =
(
	try
	(
		local DotNetBmp,DotNetGraphics,DotNetPoint
		local tempBmp,tempGraphic
		DotNetBmp = DotNetClass "System.Drawing.Bitmap"
		DotNetGraphics = DotNetClass "System.Drawing.Graphics"
		DotNetPoint = DotNetClass "System.Drawing.Point"		
		tempBmp = DotNetObject "System.Drawing.Bitmap" ImgW ImgH 
		tempGraphic = DotNetGraphics.FromImage tempBmp 
		tempGraphic.CopyFromScreen (DotNetObject DotNetPoint PosX  PosY) \
									(DotNetObject DotNetPoint 0 0) tempBmp.Size 
		tempBmp.Save ImgFileName
		tempGraphic.Dispose()
		true
	)
	catch (false)
)

ScreenCapture  0 0 200 200 "c:\\testScreenCapture.png"