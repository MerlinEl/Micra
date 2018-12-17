
paint_box.SizeMode = (dotNetClass "PictureBoxSizeMode").StretchImage


(
	local res = [256, 256]

	fn grabImage s a =
	(
		local img = gw.getViewportDib() 
		local new_img = bitmap res.x res.y
		copy img new_img
		display new_img  
		setclipboardBitmap new_img
		local clipboardClass = dotNetClass "System.Windows.Forms.Clipboard" --create a Clipboard dotNetClass
		s.image = if clipboardClass.containsimage() then clipboardClass.getImage()
	)
	
	local f = dotNetObject "Form"
	
	f.Size = dotNetObject "System.Drawing.Size" (res.x+6) (res.y+12)
	local b = dotNetObject "button"
	b.Size = dotNetObject "System.Drawing.Size" res.x res.y
	dotNet.addEventHandler b "MouseUp" grabImage
	f.controls.addRange #(b)
	f.show()
)




	fn maxImageToDotnet img =
	(
		setclipboardBitmap img
		local clipboardClass = dotNetClass "System.Windows.Forms.Clipboard" --create a Clipboard dotNetClass
		if clipboardClass.containsimage() then clipboardClass.getImage()
	)
	
	
	
	file_name = "C:\\Temp\\cicka1.jpg"
img  = openBitmap file_name
icon = (getImageRegion img 24 24 [10, 10])
close img
display icon


fn getImageRegionDotNet img w h pos =
(
	icon = (dotNetObject "Drawing.Bitmap" w h) --Create new bitmap object
	gra  = (dotNetClass "Drawing.Graphics").fromImage icon --Create new Graphics object
	newRect = dotnetObject "Drawing.rectangle" 0 0  w  h
	gra.DrawImage img newRect pos.x pos.y w h (dotNetClass "Drawing.GraphicsUnit").Pixel
	icon
)


file_name = "J:\\Micra2\\Img\\mc2Icons_24_480x480i.bmp"
img = (dotNetClass "Drawing.Image").FromFile file_name --get the saved image from file as bitmap
icon = getImageRegionDotNet img 24 24 [24, 24]
icon.save (GetDir #image +"\\test2.jpg")
img.dispose()
img.dispose()
ShellLaunch (GetDir #image +"\\test2.jpg") ""


-----------------------

fn getImageRegionDotNet w h =
(
	img=(dotNetObject "System.Drawing.Bitmap" w h)
	gfx=(DotNetClass "system.drawing.Graphics").fromImage img
	screenCap=gfx.CopyFromScreen 0 0 0 0 (dotNetObject "System.Drawing.Size" w h)
	gfx.CopyFromScreen 0 0 0 0 (dotNetObject "System.Drawing.Size" w h)
	file_path = (GetDir #image +"\\test.jpg")
	img.save file_path
	img.dispose()
	file_path
)

ShellLaunch (getImageRegionDotNet 24 24) ""