	mc2System.show dotnet_bitmap.PixelFormat
	bit_32 = (dotNetClass "System.Drawing.Imaging.PixelFormat").Format32bppArgb
	bit_24 = (dotNetClass "System.Drawing.Imaging.PixelFormat").Format24bppRgb
	bit_16 = (dotNetClass "System.Drawing.Imaging.PixelFormat").Format16bppRgb565 --.Format16bppRgb555, .Format16bppGrayScale, .Format16bppArgb1555
	bit_8 = (dotNetClass "System.Drawing.Imaging.PixelFormat").Format8bppIndexed


s_d_img = dotNetClass "System.Drawing.Image"
s_d_img.GetPixelFormatSize theBitmap24.PixelFormat	

	w=dotnet_bitmap.width
	h=dotnet_bitmap.height
rect = (dotNetClass "System.Drawing.Rectangle").FromLTRB 0 0 w h --(left top) and (right bottom)
theBitmap24  = theBitmap.clone rect pixel_format
theBitmap24.Save theFileName
theBitmap.Dispose() --release the bitmap
theBitmap24.Dispose() --release the bitmap
--shows info
