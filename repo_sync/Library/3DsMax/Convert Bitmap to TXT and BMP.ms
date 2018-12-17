struct mcBmp8
(
	b1,b2,b3,b4,b5,b6,b7,b8,

	fn InicializeBitmaps fPath =
	(
		for i=1 to 8 do ("f"+i as string+"="fPath)--colect bitmaps from path
		mcBitmapFiles = mcBmp8 b1:f1 b2:f2 b3:f3 b4:f4 b5:f5 b6:f6 b8:f7 b8:f8
	),
	
	fn ResetBitmaps =
	(
		local b = (bitmap 10 10)
		mcBitmapFiles = mcBmp8 b1:b b2:b b3:b b4:b b5:b b6:b b8:b b8:b
	)
)

/* Function for convert a bitmap to text file */
fn mcConvertBitmapToTxtFile bmp fPath =
(
	local bname="bitmap_"+(mcGetFile fPath #Name)
	local w=bmp.width
	local h=bmp.height
	Local f
	if mcExistFile fPath then (f = openFile fPath mode:"w") else (f = createFile fPath)
	
	format "Global mcBitmapFile\n" to:f
	format "----------\nfn load_% = (\n" bname to:f
	format "local %=bitmap % %\n" bname w h to:f
	format "fn unpack val = for p in val collect (r=p/256^2; g=p/256-r*256; bmp=mod p 256; color r g bmp)\n" to:f
	
		for r=0 to h-1 do
		( 
			format "setpixels % [0,%] (unpack #(" bname r to:f
			local pixels=getpixels bmp [0,r] w 
			for c=1 to w do
			( 
				local p=pixels[c]
				format "%" (((p.r as integer)*256+(p.g as integer))*256+(p.b as integer)) to:f
				if c != w then format ", " to:f
				else format "))\n" to:f
			)
		)
	format "return mcBitmapFile = %\n" bname to:f
	format ")\n----------\n" to:f
	format "load_%()\n" bname to:f
	format "load_%=undefined\n" bname to:f
	
	close f
)
/* Call: mcConvertBitmapToTxtFile bmp "C:\\temp\\folder.mic" */
----------------------------------------------------------------------------

b=selectbitmap()
display b

mcConvertBitmapToTxtFile b "C:\\temp\\button.ms"

mcBitmapFiles = un
mcBmp8.ResetBitmaps()
fileIn "C:\\temp\\folder.ms"
mcBitmapFiles.b1 = mcBitmapFile

display mcBitmapFiles.b1


	
	fn convertJpegToGiff jpg_filename =
	(
		local image_class = dotNetClass "System.Drawing.Image" --create an Image dotNetClass
		local img_format  = dotNetClass "System.Drawing.Imaging.ImageFormat" -- file formats --img_format.Jpeg
		local dotnet_bitmap = image_class.FromFile jpg_filename --get the saved image from file as bitmap
		local gif_filename = (getFilenamePath jpg_filename) + (getFilenameFile jpg_filename) + ".gif"
		
		local w=dotnet_bitmap.width
		local h=dotnet_bitmap.height
		local rect   = (dotNetClass "System.Drawing.Rectangle").FromLTRB 0 0 w h --left top right bottom
		local bit_24 = (dotNetClass "System.Drawing.Imaging.PixelFormat").Format24bppRgb
		local dotnet_bitmap_24bit = dotnet_bitmap.clone rect bit_24 --set bitmap bit depth 24
		dotnet_bitmap_24bit.save gif_filename img_format.gif --save jpg as gif
		dotnet_bitmap.Dispose()
		dotnet_bitmap_24bit.Dispose()
		deleteFile jpg_filename
	)