--resize
new_img = (dotNetObject "Drawing.Bitmap" 240 240) --Create new bitmap object
g  = (dotNetClass "Drawing.Graphics").fromImage new_img --Create new Graphics object
g.pixelOffsetMode = g.pixelOffsetMode.highQuality
g.DrawImage img 0 0 240 240
--Note that when drawing images without resizing them, 
--you will want to set this parameter to pixelOffsetMode.None for higher precision.



	fn resizeImage img w h =  --redraw method
	(
		local new_img  = dotNetObject "Drawing.Bitmap" w h  --Create new bitmap object
		local g     = (dotNetClass "Drawing.Graphics").fromImage new_img --Create new Graphics object
		--g.InterpolationMode = (dotnetClass "Drawing.Drawing2D.InterpolationMode").NearestNeighbor
		local brush_size = w/img.width 
		for x = 0 to img.width-1 do
		(
			for y = 0 to img.height-1 do
			(
				--format "pos:%\n" [x, y]
				local brush_color = img.getPixel x y
				if brush_color == undefined do continue
				local brush = dotNetObject "drawing.SolidBrush" brush_color--(netDrColor yellow)
				g.FillRectangle brush (x*brush_size) (y*brush_size) brush_size brush_size
			)
		)
		return new_img
	)
	
	
	fn resizeBitmapNET srcBitmap width height useHighQuality:false=
	(
		local destBitmap = (dotNetObject "System.Drawing.Bitmap" width height) --Create new bitmap object
		destBitmap.SetResolution srcBitmap.HorizontalResolution srcBitmap.VerticalResolution
		local theGraphics = (dotNetClass "System.Drawing.Graphics").fromImage destBitmap --Create new Graphics object
		local destRec = (dotnetObject "System.Drawing.rectangle" 0 0 width height) --Set destination image size
		IF useHighQuality DO theGraphics.InterpolationMode = theGraphics.InterpolationMode.HighQualityBicubic
		theGraphics.drawImage srcBitmap destRec --Resize the image
		theGraphics.dispose() --gc
		return destBitmap
	)
	(
		--grab a screenshot and save in to disc
		img = (gw.getViewportDib())
		file_name = "C:\\temp\\grab\\"  + "ImageClipboard.jpg" --define a temp.file name
		img.filename = file_name
		save img
		close img
		display img
		
		--open screenshot a dotnet image class ,resize and save
		image_class = dotNetClass "System.Drawing.Image" --create an Image dotNetClass
		dotnet_bitmap = image_class.FromFile file_name --get the saved image from file as bitmap
		bmp_img = resizeBitmapNET dotnet_bitmap 280 180 
		dotnet_bitmap.Dispose() --release the bitmap 
		img_format  = dotNetClass "System.Drawing.Imaging.ImageFormat" -- file formats --img_format.Jpeg
		bmp_img.save file_name img_format.Jpeg --save resized bitmap
		bmp_img.Dispose()
		
		--open resized bitmap
		img = openBitmap file_name
		close img
		display img
		
		--remove this file from disc
		deleteFile file_name --delete the temp. file
	)
	
	
		fn resizeImage_old2 icn w:240 h:240 = 
	(
		local new_img  = dotNetObject "Drawing.Bitmap" 240 240  --Create new bitmap object
		local new_g     = (dotNetClass "Drawing.Graphics").fromImage new_img --Create new Graphics object
		new_g.InterpolationMode = (dotnetClass "Drawing.Drawing2D.InterpolationMode").NearestNeighbor
		--new_g.SmoothingMode = (dotnetClass "Drawing.Drawing2D.SmoothingMode").none
		--local rect = dotnetObject "Drawing.rectangle" 0 0 240 240
		--mcsystem.show new_g
		--new_g.DrawImage icn rect 0 0 24 24 --(dotNetClass "Drawing.GraphicsUnit").pixel
		new_g.DrawImage icn 0 0 240 240
		return new_img
	)
	fn resizeImage_old srcBitmap width height =
	(
		local destBitmap = (dotNetObject "System.Drawing.Bitmap" width height) --Create new bitmap object
		destBitmap.SetResolution srcBitmap.HorizontalResolution srcBitmap.VerticalResolution
		local theGraphics = (dotNetClass "System.Drawing.Graphics").fromImage destBitmap --Create new Graphics object
		local destRec = (dotnetObject "System.Drawing.rectangle" 0 0 width height) --Set destination image size
		theGraphics.InterpolationMode = theGraphics.InterpolationMode.NearestNeighbor--HighQualityBicubic
		theGraphics.drawImage srcBitmap destRec --Resize the image
		theGraphics.dispose() --gc
		return destBitmap
	)
	/*
	
img_formats
	
  .Bmp : <System.Drawing.Imaging.ImageFormat>, read-only, static
  .Emf : <System.Drawing.Imaging.ImageFormat>, read-only, static
  .Exif : <System.Drawing.Imaging.ImageFormat>, read-only, static
  .Gif : <System.Drawing.Imaging.ImageFormat>, read-only, static
  .Icon : <System.Drawing.Imaging.ImageFormat>, read-only, static
  .Jpeg : <System.Drawing.Imaging.ImageFormat>, read-only, static
  .MemoryBmp : <System.Drawing.Imaging.ImageFormat>, read-only, static
  .Png : <System.Drawing.Imaging.ImageFormat>, read-only, static
  .Tiff : <System.Drawing.Imaging.ImageFormat>, read-only, static
  .Wmf : <System.Drawing.Imaging.ImageFormat>, read-only, static
  
  */