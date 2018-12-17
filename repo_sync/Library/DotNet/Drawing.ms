
mcsystem.show (dotnetClass "Drawing.Bitmap")
mcsystem.show(dotnetClass "Drawing.Graphics")
mcsystem.show(dotnetClass "Drawing.Image")



-- dotNetObject:System.Drawing.Bitmap
bmap = (dotNetObject "Drawing.Bitmap" "c:\\temp\\pivotplanterpv2.gif") 
-- dotNetObject:System.Drawing.Graphics
g = (dotnetclass "Drawing.Graphics").FromImage bmap
g = (dotnetclass "Drawing.Graphics").FromImage bmap.image
--dotNetObject:System.Drawing.Image

g = bmap.createGraphics() 


		--get icon from library
		new_img  = dotNetObject "Drawing.Bitmap" 24 24 --Create new bitmap object
		new_g     = (dotNetClass "Drawing.Graphics").fromImage new_img --Create new Graphics object
		g_unit = dotNetClass "Drawing.GraphicsUnit"
		mcsystem.show new_g
		new_g.DrawImage a.image rect corner.x corner.y 24 24 g_unit.Pixel
		activeIcon = new_img 

pen = dotnetobject  "Drawing.Pen" (netDrColor yellow)
rect = dotnetObject "Drawing.rectangle" 0 0  24  24
g.DrawRectangle pen rect

Brush = dotnetobject "Drawing.SolidBrush" (netDrColor yellow)
g.FillRectangle brush rect


--In Flat style GroupBox has border, but its color is defined by system. 
--When GroupBox added to MaxCustomControls.MaxForm controls it lost its border. 
--Maybe MAXForm draws gb's border but somewhere outside the form. 

try (Form.Close()) catch()
global Form 
 (
	Font = dotNetObject "System.Drawing.Font" "comic sans ms" 15 (dotNetClass "System.Drawing.FontStyle").Regular (dotNetClass "System.Drawing.GraphicsUnit").Pixel
	Form = dotNetObject "Form"
	Form.Size = dotNetObject "System.Drawing.Size" 300 300
	
	GB = dotnetobject "System.Windows.Forms.GroupBox"
	GB.text = "Custom GroupBox 1"
	GB.Location = dotNetObject "System.Drawing.Point" 38 8 
	GB.size = dotNetObject "System.Drawing.Size" 200 50
	GB.font = Font
	GB.flatStyle = (dotnetclass "System.Windows.Forms.FlatStyle").Flat
	
	fn onPaint this e = 
	(
		tSize = (dotnetclass "TextRenderer").MeasureText this.Text this.Font
		borderRect = dotnetobject "System.Drawing.Rectangle" 0 0 this.Bounds.Width this.Bounds.Height 
		borderRect.Y += tSize.Height/2
		borderRect.Height -= tSize.Height/2
		
		borderColor = (dotnetclass "System.Drawing.Color").Brown  
		(dotnetclass "ControlPaint").DrawBorder e.Graphics borderRect borderColor (dotnetclass "ButtonBorderStyle").Solid

		textRect = dotnetobject "System.Drawing.Rectangle" 0 0 this.Bounds.Width this.Bounds.Height
		textRect.X += 6
		textRect.Width  = tSize.Width
		textRect.Height = tSize.Height
		brush = dotnetobject "System.Drawing.SolidBrush" this.BackColor
		e.Graphics.FillRectangle brush textRect
		
		brush = dotnetobject "System.Drawing.SolidBrush" borderColor
		textPoint = dotnetobject "System.Drawing.PointF" textRect.x textRect.y
		e.Graphics.DrawString this.text this.Font brush textPoint		
	)
	
	dotNet.addeventhandler GB "Paint" onPaint
	
	GB2 = dotnetobject "System.Windows.Forms.GroupBox"
	GB2.text = "Custom GroupBox 2"
	GB2.Location = dotNetObject "System.Drawing.Point" 38 60
	GB2.size = dotNetObject "System.Drawing.Size" 200 50
	GB2.font = Font
	GB2.flatStyle = (dotnetclass "System.Windows.Forms.FlatStyle").System
	
	Form.Controls.Add(GB)
	Form.Controls.Add(GB2)	
	Form.Show()
)






		tSize = (dotnetclass "TextRenderer").MeasureText this.Text this.Font
		borderRect = dotnetobject "System.Drawing.Rectangle" 0 0 this.Bounds.Width this.Bounds.Height 
		borderRect.Y += tSize.Height/2
		borderRect.Height -= tSize.Height/2
		
		borderColor = (dotnetclass "System.Drawing.Color").Brown  
		(dotnetclass "ControlPaint").DrawBorder e.Graphics borderRect borderColor (dotnetclass "ButtonBorderStyle").Solid

		textRect = dotnetobject "System.Drawing.Rectangle" 0 0 this.Bounds.Width this.Bounds.Height
		textRect.X += 6
		textRect.Width  = tSize.Width
		textRect.Height = tSize.Height
		brush = dotnetobject "System.Drawing.SolidBrush" this.BackColor
		e.Graphics.FillRectangle brush e.clipBounds--textRect
		
		brush = dotnetobject "System.Drawing.SolidBrush" borderColor
		textPoint = dotnetobject "System.Drawing.PointF" textRect.x textRect.y
		e.Graphics.DrawString this.text this.Font brush textPoint	
		
	
	system.drawing.brush
 Remarks:
This is an abstract base class and cannot be instantiated. To create a brush object, use classes derived from Brush, such as SolidBrush, TextureBrush, and LinearGradientBrush.

--And
 Inheritance Hierarchy:
System.Object
  System.MarshalByRefObject
    System.Drawing.Brush
      System.Drawing.Drawing2D.HatchBrush
      System.Drawing.Drawing2D.LinearGradientBrush
      System.Drawing.Drawing2D.PathGradientBrush
      System.Drawing.SolidBrush
      System.Drawing.TextureBrush
	  
objBrush = New LinearGradientBrush(objRect, Color.White, Color.Black, LinearGradientMode.Horizontal)  
System.Drawing.Drawing2D.LinearGradientBrush <System.Drawing.RectangleF>rect <System.Drawing.Color>color1 <System.Drawing.Color>color2 <System.Single>angle

rect = (dotnetobject "System.Drawing.Rectangle" 0 0 8 14)
cla = dotnetClass "System.Drawing.Drawing2D.LinearGradientBrush"
mcsystem.show cla
bru=dotnetobject "System.Drawing.Drawing2D.LinearGradientBrush" rect (netDrColor white) (netDrColor green) (dotnetobject "System.Single" 0)

si=dotnetobject "System.Single" 1
si=dotnetclass "System.Single" 
mcsystem.show si