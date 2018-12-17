(dotnetclass "System.gc").collect() 

dgc = dotnetclass "system.gc"
dgc.collect()

			
--create a clone of img and relase img
local img_class = dotNetClass "System.Drawing.Image"
local img = img_class.fromFile "C:\Temp\colt01_ai_d.tga"
local destBitmap = (dotNetObject "Drawing.Bitmap" w h) --Create new bitmap object
local theGraphics = (dotNetClass "Drawing.Graphics").fromImage destBitmap --Create new Graphics object
local destRec = (dotnetObject "Drawing.rectangle" 0 0 w h) --Set destination image size
theGraphics.drawImage img destRec --Redraw Image
theGraphics.dispose()
img.dispose()