if printScreenTestDialog != undefined do destroyDialog printScreenTestDialog
rollout printScreenTestDialog "" width:256 height:88
(
	local cnt = 0, root = GetDir #image + "\\", frame_array = #()
	Timer tmr_print "Timer" pos:[220,56] width:24 height:24 enabled:true interval:1000 active:false
	button btn_start "Start" pos:[8,32] width:56 height:20
	spinner spn_fps "FPS:" pos:[96,60] width:64 height:16 range:[1,100,1] type:#integer scale:1
	button btn_stop "Stop" pos:[192,32] width:56 height:20
	button btn_dir "Dir" pos:[8,60] width:56 height:20
	GroupBox grp1 "" pos:[4,0] width:248 height:84
	label lbl_info "Captured Frames: 0" pos:[76,36] width:108 height:16
	button btn_close "Close" pos:[192,60] width:56 height:20
	spinner spn_w "w" pos:[96,12] width:64 height:16 range:[64,5000,256] type:#integer scale:1
	spinner spn_h "h" pos:[184,12] width:64 height:16 range:[64,5000,256] type:#integer scale:1
	checkbox chk_crop "Croping:" pos:[8,12] width:72 height:16
	fn CropImage OriginalImage TopLeft BottomRight =
	(
		btmCropped  = (dotNetObject "Drawing.Bitmap" (BottomRight.Y - TopLeft.Y) (BottomRight.X - TopLeft.X)) --Create new bitmap object
		grpOriginal = (dotNetClass "Drawing.Graphics").fromImage btmCropped --Create new Graphics object
		
		newRect = dotnetObject "Drawing.rectangle" 0  0  btmCropped.Width  btmCropped.Height
		graphicsUnit = dotNetClass "Drawing.GraphicsUnit"
		grpOriginal.DrawImage OriginalImage newRect TopLeft.X TopLeft.Y btmCropped.Width btmCropped.Height graphicsUnit.Pixel
		
		Return btmCropped
	)
	fn crop img Hq:false = -- Image HighQuality
	(
		local w=spn_w.value
		local h=spn_h.value
--SD.Bitmap(Width, Height, OriginalImage.PixelFormat)		
		local new_img = (dotNetObject "Drawing.Bitmap" w h) --Create new bitmap object
		new_img.SetResolution img.HorizontalResolution img.VerticalResolution --copy dpi from img
		local graphics_obj = (dotNetClass "Drawing.Graphics").fromImage new_img --Create new Graphics object

		if Hq do 
		(
			graphics_obj.SmoothingMode     = graphics_obj.SmoothingMode.AntiAlias
			graphics_obj.InterpolationMode = graphics_obj.InterpolationMode.HighQualityBicubic
			graphics_obj.PixelOffsetMode   = graphics_obj.PixelOffsetMode.HighQuality
		)
		
		--Graphic.DrawImage(OriginalImage, new SD.Rectangle(0, 0, Width, Height), X, Y, Width, Height, SD.GraphicsUnit.Pixel)
		local rect = (dotnetObject "Drawing.rectangle" 0  0  img.width img.height)
		local x = 10
		local y = 10
		print rect
		graphics_obj.drawImage img  rect X  Y  w  h  --graphics_obj.GraphicsUnit.Pixel)
		
		/*
		  MemoryStream ms = new MemoryStream();
          bmp.Save(ms, OriginalImage.RawFormat);
          return ms.GetBuffer()
		*/
		
		graphics_obj.dispose()
		return new_img
		
	)
	fn printScreen file_name =
	(
		(dotnetClass "SendKeys").SendWait "{%} {PRTSC}" -- ("{PRTSC}")
		(dotnetClass  "Clipboard").ContainsImage()
		local img = (dotnetClass "Clipboard").getImage() --dotNetObject:System.Drawing.Bitmap
		
		if chk_crop.checked do
		(
			local s1 = [img.width, img.height] --image size
			local s2 = [spn_w.value, spn_h.value] --new image size
			
			if s1.x < s2.x or s1.y < s2.y do 
			(
				--img.dispose()
				print "Cant crop more! Image A is smaler than Image B"
				return false 
			)

			--define new image rect in pos [0, 0]
			local s2_min = [0, 0] --min TL
			local s2_max = [s2.x, s2.y] --max BR 
			
			--move rect center in to pos [0, 0]
			s2_min = -[s2.x, s2.y]/2
			s2_max = [s2.x, s2.y]/2

			--move rect center in to mouse.screenpos    
			local mp = mouse.screenpos
			local TopLeft = (mp + s2_min)
			local BottomRight= (mp + s2_max)
			
--format "min:%\tmax:%\tnew min:%\tnew max:%\n" s2_min s2_max (mp + (s2_min/2)) (mp + (s2_max/2))

			--or define new image rect from original image center
			
			img = CropImage img TopLeft BottomRight
		)
		
		if img != undefined 
		then
		(
			img.tag = file_name
			frame_array += #(img)
		)
		else (print "Error: Cant Grab Screen")
	)
	fn saveCapturedFrames =
	(
		local file_format = (dotNetClass "Drawing.Imaging.ImageFormat").jpeg
		for i in frame_array do 
		(
			i.Save i.tag file_format 
			i.dispose()
		)
	)
	on printScreenTestDialog open do
	(
		theFileName = GetDir #image + "\\ImageClipboard.jpg"
	)
	on tmr_print tick do
	(
		cnt +=1
		tmr_print.interval = 1000 / spn_fps.value
		file_name = root + cnt as string + "printScreen.jpg"
		printScreen file_name
		lbl_info.text = "Captured Frames: "+ cnt as string
	)
	on btn_start pressed do
	(
		cnt = 0
		frame_array = #()
		tmr_print.active = true
	)
	on btn_stop pressed do
	(
		tmr_print.active = false
		if frame_array.count != 0 and (querybox "Do you wish to save Captured Frames?" title:" Viewport Recorder:") do saveCapturedFrames()
	)
	on btn_dir pressed do
	(
		ShellLaunch root ""
	)
	on btn_close pressed do
	(
		destroyDialog printScreenTestDialog
	)
)
createDialog printScreenTestDialog pos:[200,200] style:#(#style_border)


/*
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


---DOT NET Maxscript


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

*/





/*

w = (dotnetClass "Convert").ToInt32(W.Value)

ClassOf: dotNetObject
SuperClassOf: Value
No ShowClass for dotNetObject:System.Drawing.Rectangle
No Show for dotNetObject:System.Drawing.Rectangle
  .Bottom : <System.Int32>, read-only
  .Height : <System.Int32>
  .IsEmpty : <System.Boolean>, read-only
  .Left : <System.Int32>, read-only
  .Location : <System.Drawing.Point>
  .Right : <System.Int32>, read-only
  .Size : <System.Drawing.Size>
  .Top : <System.Int32>, read-only
  .Width : <System.Int32>
  .X : <System.Int32>
  .Y : <System.Int32>
  .Empty : <System.Drawing.Rectangle>, read-only, static
PROPERTIES:
  .[static]<System.Drawing.Rectangle>Ceiling <System.Drawing.RectangleF>value
  .<System.Boolean>Contains <System.Drawing.Point>pt
  .<System.Boolean>Contains <System.Drawing.Rectangle>rect
  .<System.Boolean>Contains <System.Int32>x <System.Int32>y
  .<System.Boolean>Equals <System.Object>obj
  .[static]<System.Boolean>Equals <System.Object>objA <System.Object>objB
  .[static]<System.Drawing.Rectangle>FromLTRB <System.Int32>left <System.Int32>top <System.Int32>right <System.Int32>bottom
  .<System.Int32>GetHashCode()
  .<System.Type>GetType()
  .Inflate <System.Drawing.Size>size
  .Inflate <System.Int32>width <System.Int32>height
  .[static]<System.Drawing.Rectangle>Inflate <System.Drawing.Rectangle>rect <System.Int32>x <System.Int32>y
  .Intersect <System.Drawing.Rectangle>rect
  .[static]<System.Drawing.Rectangle>Intersect <System.Drawing.Rectangle>a <System.Drawing.Rectangle>b
  .<System.Boolean>IntersectsWith <System.Drawing.Rectangle>rect
  .Offset <System.Drawing.Point>pos
  .Offset <System.Int32>x <System.Int32>y
  .[static]<System.Boolean>ReferenceEquals <System.Object>objA <System.Object>objB
  .[static]<System.Drawing.Rectangle>Round <System.Drawing.RectangleF>value
  .<System.String>ToString()
  .[static]<System.Drawing.Rectangle>Truncate <System.Drawing.RectangleF>value
  .[static]<System.Drawing.Rectangle>Union <System.Drawing.Rectangle>a <System.Drawing.Rectangle>b
METHODS:
EVENTS:
PropNames: #(#Bottom, #height, #isEmpty, #left, #location, #right, #size, #Top, #width, #x, #y, #empty)
No Interface for dotNetObject:System.Drawing.Rectangle
*/