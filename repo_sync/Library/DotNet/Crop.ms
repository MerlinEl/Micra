--grab a rect from screen
(
	img=(dotNetObject "System.Drawing.Bitmap" 100 100)
	gfx=(DotNetClass "system.drawing.Graphics").fromImage img
	screenCap=gfx.CopyFromScreen 0 0 0 0 (dotNetObject "System.Drawing.Size" 100 100)
	gfx.CopyFromScreen 0 0 0 0 (dotNetObject "System.Drawing.Size" 100 100)
	img.save "C:\\test.jpg"
	img.dispose()
)


Function CropImage OriginalImage TopLeft BottomRight =
(
	btmCropped  = (dotNetObject "Drawing.Bitmap" (BottomRight.Y - TopLeft.Y) (BottomRight.X - TopLeft.X)) --Create new bitmap object
	grpOriginal = (dotNetClass "Drawing.Graphics").fromImage btmCropped --Create new Graphics object
	
	newRect = dotnetObject "Drawing.rectangle" 0  0  btmCropped.Width  btmCropped.Height
	graphicsUnit = dotNetClass "Drawing.GraphicsUnit"
	grpOriginal.DrawImage OriginalImage newRect TopLeft.X TopLeft.Y btmCropped.Width btmCropped.Height graphicsUnit.Pixel
	
	Return btmCropped
)


--usage example

file_name = "C:\\Documents and Settings\\rbaca\\My Documents\\3dsmax\\sceneassets\\images\\1printScreen.bmp"
image_class = dotNetClass "System.Drawing.Image" --create an Image dotNetClass
OriginalImage = image_class.FromFile file_name --get the saved image from file as bitmap
TopLeft=[10,10]
BottomRight=[50,50]

bmpImage = CropImage OriginalImage TopLeft BottomRight

OriginalImage.Dispose()
file_name = "C:\\Documents and Settings\\rbaca\\My Documents\\3dsmax\\sceneassets\\images\\1printScreen_crop.bmp"
file_format = (dotNetClass "Drawing.Imaging.ImageFormat").bmp 
bmpImage.Save file_name file_format
bmpImage.dispose()




/* From ASP.NET  vbnet
function
  
   1. 	  Private Function CropImage(ByVal OriginalImage As Bitmap, ByVal TopLeft As Point, ByVal BottomRight As Point) As Bitmap
   2.     Dim btmCropped As New Bitmap((BottomRight.Y - TopLeft.Y), (BottomRight.X - TopLeft.X))
   3.     Dim grpOriginal As Graphics = Graphics.FromImage(btmCropped)
   4.  
   5.     grpOriginal.DrawImage(OriginalImage, New Rectangle(0, 0, btmCropped.Width, btmCropped.Height), _
   6.         TopLeft.X, TopLeft.Y, btmCropped.Width, btmCropped.Height, GraphicsUnit.Pixel)
   7.     grpOriginal.Dispose()
   8.  
   9.     Return btmCropped
  10. End Function



usage example
   1. Dim bmpImage As New Bitmap("c:\point.jpg")
   2. bmpImage = CropImage(bmpImage, New Point(0, 0), New Point(100, 100))
*/