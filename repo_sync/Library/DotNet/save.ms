		img_format  = dotNetClass "System.Drawing.Imaging.ImageFormat" -- file formats --img_format.Jpeg
		bmp_img.save file_name img_format.Jpeg --save resized bitmap
		bmp_img.Dispose()