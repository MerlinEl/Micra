How to Create and Save Bitmap/Image? 

Okay, the SDK shows how: 

 newBitmap = New Bitmap(800,600,PixelFormat.Format32bppARGB)
g = Graphics.FromImage(newBitmap)

g.FillRectangle(New SolidBrush(Color.White), New Rectangle(0,0,800,600))

' I needed to save to a GIF...

newBitmap.Save (...)