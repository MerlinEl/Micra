dg = dotnetObject "Drawing.Graphics[]" 1
mcsystem.show dg


b = (dotNetObject "Drawing.Bitmap" 20 10) --Create new bitmap object
gr = (dotNetClass "Drawing.Graphics").fromImage b --Create new Graphics object

mcsystem.show  gr--so--points
----
/*
.DrawClosedCurve <System.Drawing.Pen>pen <System.Drawing.Point[]>points
.DrawClosedCurve <System.Drawing.Pen>pen <System.Drawing.PointF[]>points
.DrawClosedCurve <System.Drawing.Pen>pen <System.Drawing.PointF[]>points <System.Single>tension <System.Drawing.Drawing2D.FillMode>fillmode
.DrawClosedCurve <System.Drawing.Pen>pen <System.Drawing.Point[]>points <System.Single>tension <System.Drawing.Drawing2D.FillMode>fillmode

.FillClosedCurve <System.Drawing.Brush>brush <System.Drawing.PointF[]>points
.FillClosedCurve <System.Drawing.Brush>brush <System.Drawing.Point[]>points
.FillClosedCurve <System.Drawing.Brush>brush <System.Drawing.PointF[]>points <System.Drawing.Drawing2D.FillMode>fillmode
.FillClosedCurve <System.Drawing.Brush>brush <System.Drawing.Point[]>points <System.Drawing.Drawing2D.FillMode>fillmode
.FillClosedCurve <System.Drawing.Brush>brush <System.Drawing.Point[]>points <System.Drawing.Drawing2D.FillMode>fillmode <System.Single>tension
.FillClosedCurve <System.Drawing.Brush>brush <System.Drawing.PointF[]>points <System.Drawing.Drawing2D.FillMode>fillmode <System.Single>tension
*/
b = (dotNetObject "Drawing.Bitmap" 100 100) --Create new bitmap object
gr = (dotNetClass "Drawing.Graphics").fromImage b --Create new Graphics object

points = dotnetObject "Drawing.Point[]" 3 --Create new Pionts array
--fil array with positions
points.Set 0 (dotnetObject "Drawing.Point" 0 0)
points.Set 0 (dotnetObject "Drawing.Point" 30 0)
points.Set 0 (dotnetObject "Drawing.Point" 0 30)

redPen = dotNetObject "system.drawing.pen" (netDrColor red) 2--Create new Brush object with raius 2
greenPen = dotNetObject "system.drawing.pen" (netDrColor green) 2--Create new Brush object with raius 2

gr.DrawLine redPen 0 0 25 30 
--e.Graphics.DrawLines(redPen, curvePoints)
gr.DrawLines redPen points

--FillMode = FillMode.Alternate
--<System.Drawing.Drawing2D.FillMode>fillmode
dotNetObject "System.Drawing.Drawing2D"

--tension As Single = 1F

--e.Graphics.DrawClosedCurve(greenPen, curvePoints, tension, _aFillMode)
gr.DrawClosedCurve greenPen points --draw curve

--Outline Creation
b = (dotNetObject "Drawing.Bitmap" 200 100) --Create new bitmap object
gr = (dotNetClass "Drawing.Graphics").fromImage b --Create new Graphics object
cp = (dotnetclass "ControlPaint")
mcsystem.show cp
rect = (dotnetobject "System.Drawing.Rectangle" 0 0 30 30)
fillBrush = netDrColor black 
 --.[static]DrawBorder 
 	--<System.Drawing.Graphics>graphics 
 	--<System.Drawing.Rectangle>bounds 
 	--<System.Drawing.Color>color 
 	--<System.Windows.Forms.ButtonBorderStyle>style
cp.DrawBorder gr rect fillBrush (dotnetclass "ButtonBorderStyle").Solid
		

--Outline Creation Fill Rect
local clr = execute (mcFile.saveLoadIniSetings head:"InterfaceColor" key:s.tag action:#load)
if classof clr != Color then clr = gray
local fillBrush = dotnetobject "System.Drawing.SolidBrush" (netDrColor clr)
local rect = (dotnetobject "System.Drawing.Rectangle" 0 0 40 bar_height)
a.graphics.FillRectangle fillBrush rect
local fillColor = netDrColor black
(dotnetclass "ControlPaint").DrawBorder a.graphics rect fillColor (dotnetclass "ButtonBorderStyle").Solid		
		
		
		
		
		
		
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



