 -- set PNG settings
 pngio.setType #true24
 pngio.setAlpha true
 pngio.setInterlaced false

 -- render and save to temporary tif
 b = render()
 b.filename = filename
 save b quiet:true
 close b

 -- load the tif as .NET bitmap
 ImageClass = dotnetclass "System.Drawing.Image"
 theImage = ImageClass.FromFile filename true

 -- resave as a png. must be a different filename
 modifiedFilename = sysinfo.tempDir + "tempRenderModified.png"
 ImageFormat = dotnetclass "System.Drawing.Imaging.ImageFormat"
 theImage.Save modifiedFilename ImageFormat.png

 -- open and display in max
 dnBitmap = openBitmap modifiedFilename
 display dnBitmap not as clean as using the clipboard but it works!
 
 
 
 'Dim bm As BitmapSource = Clipboard.GetImage()'looses alpha channel
                'Dim bmS As New WriteableBitmap(bm)'does work but still without alpha information
                Dim bmF As System.Drawing.Bitmap = System.Windows.Forms.Clipboard.GetImage 'Get working image
                Dim bmS As BitmapSource = TB.Imaging.WPF.BitmapToWpfBitmapSource(bmF, Me) 'convert Bitmap into BitmapSource
                Me.Source = bmS
				
				
				
				
				Bitmap clipboardImage = Clipboard.GetImage();
clipboardImage.MakeTransparent()
string imagePath = Path.GetTempFileName();
clipboardImage.Save(imagePath);




--get image from clipboard
	cd = (dotNetClass "Clipboard").GetDataObject()
	if cd.GetDataPresent (dotNetClass "DataFormats").Bitmap do
	(
		img = cd.GetData (dotNetClass "DataFormats").Bitmap

	)
	
	img = clipboard.getImage()
--save image to temp
	file_path = (mcPath() +"/temp"+"/temp_image2.PNG")
	--pixel_format = (dotnetClass "Drawing.Imaging.PixelFormat").Format32bppArgb
	img_format  = (dotNetClass "Drawing.Imaging.ImageFormat") -- file formats
	--img.GetPixelFormatSize pixel_format
	--img.IsAlphaPixelFormat pixel_format 
	img.MakeTransparent()
	img.save file_path img_format.PNG
	img.dispose()
	
	
	bgColor = ((colorMan.getColor #background)*255) as color
	img.MakeTransparent (netDrColor bgColor)
	
	
	clipboard = dotNetClass "Clipboard" --create a Clipboard dotNetClass
		--img.makeTransparent (netDrColor white) 
		clipboard.setImage img --copy the image to clipboard
	
	

mcIconMakerDialog.tag.value.paint_box.image = img

	mcsystem.show img_format
	mcsystem.show cd
	mcsystem.show  (dotNetClass "DataFormats")
	mcsystem.show img
	
	
	img.GetPixelFormatSize (dotnetClass "Drawing.Imaging.PixelFormat").Alpha
img.GetPixelFormatSize (dotnetClass "Drawing.Imaging.PixelFormat").Format32bppArgb
	
	pixel_format = (dotnetClass "Drawing.Imaging.PixelFormat").Format32bppArgb
	rect = netDrRect [0, 0] [240, 240]
	theBitmap32 = img.clone rect pixel_format