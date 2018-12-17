
	

(	
	
	fn CropImage OriginalImage TopLeft BottomRight =
	(
		btmCropped  = (dotNetObject "Drawing.Bitmap" (BottomRight.x - TopLeft.x) (BottomRight.y - TopLeft.y)) --Create new bitmap object
		grpOriginal = (dotNetClass "Drawing.Graphics").fromImage btmCropped --Create new Graphics object
		
		newRect = dotnetObject "Drawing.rectangle" 0  0  btmCropped.Width  btmCropped.Height
		graphicsUnit = dotNetClass "Drawing.GraphicsUnit"
		grpOriginal.DrawImage OriginalImage newRect TopLeft.X TopLeft.Y btmCropped.Width btmCropped.Height graphicsUnit.Pixel
		
		Return btmCropped
	)
	--there is 4 types which you can use : Live_Area / Action Safe / Title Safe / User Safe
	fn getSafeFrameSize type:#Live_Area =
	(
		local offset = case type of --Safe Frames Default Settings!!! 
		(
			#Live_Area: 0
			--#Action_Safe: 10*2 --need more calculation here
			--#Title_Safe: 20*2 --need more calculation here
			--#User_Safe: 30*2 --need more calculation here
		)
		
		local image_aspect_ratio = getRendImageAspect()
		local view_size = getViewSize()

		local frame_a = [view_size.x, view_size.x / image_aspect_ratio]
		local frame_b = [view_size.y * image_aspect_ratio, view_size.y]
		
		if frame_a.x <= view_size.x and frame_a.y <= view_size.y 
		then return frame_a - offset
		else return frame_b - offset
	)
	
	local img = gw.getViewportDib() 	
	local file_name = GetDir #image + "\\grab_002.jpg"  --- here put a filename where will be you image saved
	img.filename = file_name
	save img
	close img
	
	local img_class  = dotNetClass "System.Drawing.Image" --create an Image dotNetClass
	local img        = img_class.FromFile file_name --get the saved image from file as bitmap

	local frame_area = getSafeFrameSize type:#Live_Area
	local TopLeft    = (getViewSize()) - frame_area
	local BottomRight= frame_area
	if frame_area.x == (getViewSize()).x then
	(
		TopLeft.y /= 2 
		BottomRight.y += TopLeft.y+1
	)
	else
	(
		TopLeft.x /= 2 
		BottomRight.x += TopLeft.x+1
	)
	
	--format "Vsize::%\tArea:%\tTopLeft:%\tBottomRight:%\n" (getViewSize()) frame_area TopLeft BottomRight

	local croped_img = CropImage img TopLeft BottomRight 
	img.Dispose() --release the bitmap
	local file_format = (dotNetClass "Drawing.Imaging.ImageFormat").jpeg 
	croped_img.Save file_name file_format --save croped image
	croped_img.Dispose() --release the bitmap

)





---OR



--Denis
fn getViewportSafeframeDib show:on =
(
	 local x = y = 0, v
	 local s = getViewSize()
	 local k = getRendImageAspect()
	 
	 if k < (s.x/s.y) then
	 (
		  v = [s.y*k,s.y]
		  x = (s.x-v.x)/2 + 1
	 )
	 else
	 (
		  v = [s.x, s.x/k]
		  y = (s.y-v.y)/2 + 1
	 )
	
	 bmp = bitmap v.x v.y
	 pasteBitmap (gw.getViewportDib()) bmp (box2 x y v.x v.y) [0,0]
	 if show do display bmp
	 bmp
)
getViewportSafeframeDib()