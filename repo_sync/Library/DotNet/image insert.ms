


  (
	--Create Interface
	form = dotNetObject "form"
	b1 = dotnetObject "button"
	b2 = dotnetObject "button"
	p1 = dotnetObject  "pictureBox"

	--Functions
	fn resizeImage img =
	(
		local new_img = (dotNetObject "Drawing.Bitmap" 240 240) --Create new bitmap object
		local g  = (dotNetClass "Drawing.Graphics").fromImage new_img --Create new Graphics object
		g.InterpolationMode = (dotnetClass "Drawing.Drawing2D.InterpolationMode").NearestNeighbor
		g.pixelOffsetMode = g.pixelOffsetMode.highQuality
		g.DrawImage img 0 0 240 240
		return new_img
	)
	fn getImageFromClipboard s =
	(
		--get image from clipboard
		local clipboardClass = dotNetClass "System.Windows.Forms.Clipboard" --create a Clipboard dotNetClass
		if not clipboardClass.ContainsImage() 
		then return undefined
		else s.image =  resizeImage (clipboardClass.getImage())
	)
	fn copyImageToClipboard img =
	(
		local clipboardClass = dotNetClass "System.Windows.Forms.Clipboard" --create a Clipboard dotNetClass
		clipboardClass.setImage img --copy the image to clipboard
	)
	fn onOpenForm = (p1.image = dotNetObject "Drawing.Bitmap" 480 480)
	fn onCloseForm = ()
	fn onBtn1MouseUp a s = (copyImageToClipboard p1.image)
	fn onBtn2MouseUp a s = (getImageFromClipboard p1)


	--Inicialize Interface
	form.Name = "Form1"
	form.Text = "Form1"
	form.backcolor = netDrColor yellow
	
	b1.text = "Copy"
	b2.text = "Paste 24x24"
	p1.text = "Image"
	
	form.bounds = netDrRect [200, 200] [400,400]
	b1.bounds = netDrRect [0, 0] [100, 24]
	b2.bounds = netDrRect [0, 24] [100, 24]

	p1.bounds = netDrRect [100, 50] [240, 240]
	p1.backcolor = netDrColor gray
	
	--handlers
	dotNet.addEventHandler form "Shown" onOpenForm
	dotNet.addEventHandler form "Closed" onCloseForm
	
	dotNet.addEventHandler b1 "MouseUp" onBtn1MouseUp
	dotNet.addEventHandler b2 "MouseUp" onBtn2MouseUp
	form.controls.addRange #(b1,  b2,  p1)
	
	form.show()
)



/*
fn getIconDotNetx icnNum icnSize:24 =
(
	if icnNum == 0 do return undefined
	local img_lib = (dotNetClass "Drawing.Image").FromFile mcIconI --get the saved image from file as bitmap
	local w = h = icnSize
	local img_lib_size = [img_lib.width, img_lib.height]
	local icnCount  = (img_lib_size/icnSize)
	icnNum -= 1
if debug == 5 do format "lib size:% icn count:%\n"	img_lib_size icnCount	
	local X = (mod icnNum icnCount.x)
	local Y = (icnNum / icnCount.y) as integer
if debug == 5 do format "x:% y:%\n" x y		
	local pix_x = X * icnSize
	local pix_y = Y * icnSize
	
	local pos = [pix_x, pix_y]
	
if debug == 5 do format "ic_num:%\ticon pos in img_lib:%\n" icnNum pos

	local icon = (dotNetObject "Drawing.Bitmap" w h) --Create new bitmap object
	--icon.ColorDepth = icon.ColorDepth.Depth24Bit
	local gra  = (dotNetClass "Drawing.Graphics").fromImage icon --Create new Graphics object
	local newRect = netDrRect [ 0, 0 ] [icnSize, icnSize]  --adjust icon offset X in button 
	gra.DrawImage img_lib newRect pos.x pos.y w h (dotNetClass "Drawing.GraphicsUnit").Pixel	
	img_lib.dispose()
	icon.MakeTransparent (netDrColor black)--(color 75 75 75)) --gray
	icon
)
*/


/*
  (
	form = dotNetObject "form"
	form.Name = "Form1"
	form.Text = "Form1"
	form.backcolor = netDrColor yellow
	b = dotnetObject "button"
	--b.flatstyle = b.flatstyle.flat --flat --Standard--System--Popup--
	b.flatstyle = b.flatstyle.flat
	b.bounds = netDrRect [100, 50] [24, 24]
	b.FlatAppearance.BorderSize = 0
	b.backcolor = netDrColor blue
	img = getIconDotNetx 226
	--img.ImageDropShadow = false
	--img.ImageBorderEnabled = false
	b.image = img
	--b.ImageAlign = (dotnetClass "Drawing.ContentAlignment").BottomRight--TopCenter--MiddleCenter
	 -- mcsystem.show b
	form.controls.add b
	--functions
	fn copyImageToClipboard img =
	(
		local clipboardClass = dotNetClass "System.Windows.Forms.Clipboard" --create a Clipboard dotNetClass
		clipboardClass.setImage img --copy the image to clipboard
	)
	fn onOpenForm = 
	(
		copyImageToClipboard b.image
	)
	fn onCloseForm = ()
	--handlers
	dotNet.addEventHandler form "Shown" onOpenForm
	dotNet.addEventHandler form "Closed" onCloseForm
	
	form.show()
)
*/