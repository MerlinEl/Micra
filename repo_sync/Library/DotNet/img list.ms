	fn getIconList =
	(
		local w = h = 14
		img_list = dotNetObject "ImageList"
		img_list.ImageSize = dotNetObject "Drawing.Size" w h
		img_list.ColorDepth = img_list.ColorDepth.Depth24Bit
		img_list.transparentColor = drawingColor.fromArgb 212 212 212 --gray color
		
		local img_array = #(root_path+"Img\\DirOpen.bmp", root_path+"Img\\DirClose.bmp", root_path+"Img\\DirRoot.bmp")
		local img_class = dotNetClass "System.Drawing.Image"
		
		if not doesFileExist img_array[1] or not doesFileExist img_array[2] do return img_list
		for i in img_array do 
		(
			local img = img_class.fromFile i
			--create a clone of img and relase img
			local destBitmap = (dotNetObject "Drawing.Bitmap" w h) --Create new bitmap object
			local theGraphics = (dotNetClass "Drawing.Graphics").fromImage destBitmap --Create new Graphics object
			local destRec = (dotnetObject "Drawing.rectangle" 0 0 w h) --Set destination image size
			theGraphics.drawImage img destRec --Redraw Image
			theGraphics.dispose()
			img.dispose()
			
			img_list.images.add (destBitmap)
		)
		return img_list
	)
	
	
(
	local w = h = 14
	local img_list = dotNetObject "ImageList"
	local clipboardClass = dotNetClass "System.Windows.Forms.Clipboard" --create a Clipboard dotNetClass
	local drawingColor   = dotNetClass "drawing.color"
	img_list.ImageSize = dotNetObject "Drawing.Size" w h
	img_list.ColorDepth = img_list.ColorDepth.Depth24Bit
	img_list.transparentColor = drawingColor.fromArgb 212 212 212 --gray color
	
	for i = 7 to 10 do
	(
		local icn = mc2Dialog.getIconFromFile mc2IconI 7
		setclipboardBitmap icn
		local theBitmap = clipboardClass.getImage()
		img_list.images.add (theBitmap)
	)
	ms2ScriptManDialog.tv.ImageList = img_list
)