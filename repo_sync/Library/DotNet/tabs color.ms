Global testTabForm
(
	try testTabForm.close() catch()
	--net fn
	fn netDrColor clr	   = ((dotNetClass "Drawing.Color").fromArgb clr.r clr.g clr.b)
	fn netDrRect pos size   = (dotnetObject "Drawing.Rectangle" pos.x pos.y size.x size.y)
	fn netDrSize size       = (dotNetObject "Drawing.Size" size.x size.y)
	fn onPaint1 s a =
	(
		Brush = dotnetobject "System.Drawing.SolidBrush" (netDrColor red)
		format "tab size:%\n" [s.width, s.height]
		Rect = dotnetobject "System.Drawing.Rectangle" 0 0 40 20
		a.Graphics.FillRectangle Brush Rect --s.bounds
	)
	fn onPaint2 s a =
	(
		Brush = dotnetobject "System.Drawing.SolidBrush" (netDrColor yellow)
		b = (dotNetObject "Drawing.Bitmap" 20 10) --Create new bitmap object
		gr = (dotNetClass "Drawing.Graphics").fromImage b --Create new Graphics object
		gr.FillRectangle Brush s.bounds
	)
	--interface
	fo = dotnetObject "form"
	tc= dotNetObject "TabControl"
	t1= dotNetObject "TabPage" "Actions1"
	t2= dotNetObject "TabPage" "Actions2"
	--settings
	fo.bounds = netDrRect [200,100] [500,200]
	
	--tc.AccessibleRole = tc.AccessibleRole.Graphic
	tc.AutoSize = true
	tc.BackColor = netDrColor blue --not works
	tc.ForeColor = netDrColor green --not works
	tc.Appearance=tc.Appearance.FlatButtons
	tc.Dock = tc.Dock.Left
	
	tc.Alignment = tc.Alignment.right
	tc.SizeMode=tc.SizeMode.Fixed
	tc.DrawMode=tc.DrawMode.OwnerDrawFixed
	tc.bounds = netDrRect [2,2] [fo.width, fo.height]
	tc.controls.addRange #(t1,t2)
	tc.ItemSize = netDrSize [25,100]
	tc.SizeMode = tc.SizeMode.normal
	--tc.IsAccessible = true
	
	t2.BackColor = netDrColor yellow
	t2.ForeColor = netDrColor white
	
	dotNet.addeventhandler t1 "Paint" onPaint1
	dotNet.addeventhandler tc "click" onPaint2
	fo.controls.add tc
	
	testTabForm = fo
	testTabForm.show()
  )
  
  
  
  
/*
tc= dotNetObject "TabControl"
t1= dotNetObject "TabPage" "Actions"

(t1.CreateGraphics()).FillRectangle Brush Rect
*/