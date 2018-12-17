	local new_img  = dotNetObject "Drawing.Bitmap" w h  --Create new bitmap object
	new_img.SetPixel 10 10 (netDrColor yellow)
	
	fn onPaintLabels s a =
	(
		local fillBrush = dotnetobject "System.Drawing.SolidBrush" (netDrColor yellow)
		a.graphics.FillRectangle fillBrush (dotnetobject "System.Drawing.Rectangle" 0 0 30 30)
	)
	
	local lbl = dotNetObject "label"
	dotNet.addeventhandler lbl "Paint" onPaintLabels
	
------------------------
-------------------------
 
(
	local Image_path = "C:\\Temp\\manip11.jpg" --"C:\\Temp\\colt01_ai_d.tga"
	local Image = openbitmap "C:\\Temp\\manip11.jpg" --"C:\\Temp\\colt01_ai_d.tga"
	local bmpDisplayed = dotNetObject "System.Drawing.Bitmap" Image_path
	local bmpRectangle = dotNetObject "System.Drawing.Rectangle" 0 0 Image.width Image.height
	 
	rollout PictureBox_Rollout "PictureBox_Rollout"
	(
		dotNetControl uiPictureBox "System.Windows.Forms.PictureBox" pos:[0,0] width:Image.width height:Image.height
		 
		fn updateZoom =
		( 
			Image_path = "C:\\Temp\\manip8.jpg"
			bmpDisplayed = dotNetObject "System.Drawing.Bitmap" Image_path
			uiPictureBox.Width = Image.width
			uiPictureBox.Height = Image.height
			uiPictureBox.Invalidate()
		)
		 
		on uiPictureBox Paint senderArg paintEventArgs do
		(
			Graphics = paintEventArgs.Graphics
			Graphics.DrawImage bmpDisplayed bmpRectangle
		)
		 
		on uiPictureBox mouseMove pos do
		(
			val = 100.0*((pos.x/PictureBox_Rollout.width as float))
			print val
		)
		on PictureBox_Rollout mouseMove pos do
		(
			val = 100.0*((pos.x/PictureBox_Rollout.width))
			print val 
		)
	)
)
createdialog PictureBox_Rollout


     -----    

	fn resizeImage img w h =  --redraw method
	(
		local new_img  = dotNetObject "Drawing.Bitmap" w h  --Create new bitmap object
		local brush_size = w/img.width as float
		for x = 0 to w-1 do
		(
			for y = 0 to h-1 do
			(
				--format "pos:%\n" [x, y]
				local p = img.getPixel (x/brush_size) (y/brush_size)
				new_img.SetPixel x y p
			)
		)
		return new_img
	)




 theBitmap = dotNetObject "system.drawing.bitmap" 100 100 
          
          theGraphicsClass =  dotNetClass "System.Drawing.Graphics"
          theGraphics = theGraphicsClass.FromImage theBitmap 
          
          dotNetColor = dotNetClass "system.drawing.Color" 
          theColor = dotNetColor.FromArgb 150 150 200
          
          theBrush = dotNetObject "system.drawing.SolidBrush" theColor 
          
          theGraphics.FillRectangle theBrush 0 0 100 100
   

       
rollout testPbox "testPbox" height:110 width:110 
(
	local theBitmap = dotNetObject "system.drawing.bitmap" 100 100 
	dotNetControl pic "system.windows.forms.pictureBox" width:100 height:40 align:#center

	on pic mousedown arg do 
	(
		--mcsystem.show arg
		--mcsystem.show arg.Button
		--format "button:%\tx:%\ty:%\n" arg.Button arg.x arg.y
		--.Clicks
		--.Location
		--ToString()
		mcsystem.show pic
		--print (arg.Button.ToString())
		--pic.image = theBitmap 
	)
		
)
createdialog testPbox escapeEnable:true









private void ShowPensAndSmoothingMode(PaintEventArgs e)
{

    // Set the SmoothingMode property to smooth the line.
    e.Graphics.SmoothingMode = 
        System.Drawing.Drawing2D.SmoothingMode.AntiAlias;

    // Create a new Pen object.
    Pen greenPen = new Pen(Color.Green);

    // Set the width to 6.
    greenPen.Width = 6.0F;

    // Set the DashCap to round.
    greenPen.DashCap = System.Drawing.Drawing2D.DashCap.Round;

    // Create a custom dash pattern.
    greenPen.DashPattern = new float[]{4.0F, 2.0F, 1.0F, 3.0F};

    // Draw a line.
    e.Graphics.DrawLine(greenPen, 20.0F, 20.0F, 100.0F, 240.0F);

    // Change the SmoothingMode to none.
    e.Graphics.SmoothingMode = 
        System.Drawing.Drawing2D.SmoothingMode.None;

    // Draw another line.
    e.Graphics.DrawLine(greenPen, 100.0F, 240.0F, 160.0F, 20.0F);

    // Dispose of the custom pen.
    greenPen.Dispose();
}