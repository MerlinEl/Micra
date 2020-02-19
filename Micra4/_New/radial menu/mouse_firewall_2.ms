--MAX MAIN WINDOW SAFE RECTANGLE
form = dotNetObject "MaxCustomControls.MaxForm"
canvas = dotNetObject  "System.Windows.Forms.PictureBox"
form.FormBorderStyle = form.FormBorderStyle.None
form.StartPosition = form.StartPosition.Manual
-- form.opacity = 0.8
form.AllowTransparency = true
form.TransparencyKey =  (dotNetClass "Drawing.Color").fromArgb 0 50 50
max_handle =  Windows.GetMAXHWND()
max_bounds = windows.getWindowPos max_handle
form.bounds = dotnetObject "Drawing.Rectangle" max_bounds.x max_bounds.y max_bounds.w max_bounds.h

-- lbl.BackColor = (dotNetClass "Drawing.Color").fromArgb 0 212 232
-- canvas.BackColor = (dotNetClass "Drawing.Color").fromArgb 180 180 180 --1 255 0 0
canvas.bounds = form.bounds
-- lbl.location = dotnetObject "Drawing.Point" (max_bounds.x + max_bounds.w/2) (max_bounds.y + max_bounds.h/2)
fn onLblMouseUp s a = (s.parent.close())
fn onFormPaint s a = (s.backColor = (dotNetClass "Drawing.Color").fromArgb 0 50 50)
fn onLabelPaint s a = (
	
-- 	local bm = dotNetObject "System.Drawing.Bitmap" s.width s.height
-- 	local g = (dotNetClass "System.Drawing.Graphics").FromImage bm 
-- 	g.DrawImage bm
	local g= a.Graphics
	format "g:%\n" g
	local b = dotNetObject "System.Drawing.SolidBrush" ((dotNetClass "Drawing.Color").fromArgb 10 0 255 0)
	g.FillRectangle b s.bounds
	g.TextRenderingHint = g.TextRenderingHint.ClearTypeGridFit
)
dotNet.addEventHandler form "Paint" onFormPaint	
dotNet.addEventHandler canvas "Paint" onLabelPaint	
dotNet.addEventHandler canvas "MouseUp" onLblMouseUp
form.controls.Add canvas
hv = DotNetObject "NativeWindow"
hv.AssignHandle (DotNetObject "System.IntPtr" (max_handle)) 
form.show(hv)
