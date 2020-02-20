--MAX MAIN WINDOW SAFE RECTANGLE
form = dotNetObject "MaxCustomControls.MaxForm"
lbl = dotNetObject "Label"
form.FormBorderStyle = form.FormBorderStyle.None
form.StartPosition = form.StartPosition.Manual
form.AllowTransparency = true
-- form.TransparencyKey =  (dotNetClass "Drawing.Color").fromArgb 0 50 50
max_handle =  Windows.GetMAXHWND()
max_bounds = windows.getWindowPos max_handle
form.bounds = dotnetObject "Drawing.Rectangle" max_bounds.x max_bounds.y max_bounds.w max_bounds.h

lbl.text = "Close Safe Frame"
lbl.ForeColor = (dotNetClass "Drawing.Color").fromArgb 0 0  0
lbl.BackColor = (dotNetClass "Drawing.Color").fromArgb 180 180 180 --1 255 0 0
lbl.location = dotnetObject "Drawing.Point" 12 11
lbl.textAlign = lbl.textAlign.TopLeft
lbl.Autosize = true
form.Controls.Add lbl

fn onLblMouseUp s a = (s.parent.close())
fn onFormPaint s a = (
	
	s.backColor = (dotNetClass "Drawing.Color").fromArgb 0 50 50
	local rect = s.ClientRectangle
	format "x: % y: % width: % height: %\n" rect.x rect.y rect.width rect.height
-- 	rect.Inflate -10 -10
	rect.offset 9 9
	rect.width -= 19
	rect.height -= 19
	local clr = (dotNetClass "Drawing.Color").fromArgb 255 81 68
	pen = dotnetobject  "Drawing.Pen" clr 4
	a.Graphics.DrawRectangle pen rect
)
dotNet.addEventHandler form "Paint" onFormPaint	
dotNet.addEventHandler lbl "MouseUp" onLblMouseUp
hv = DotNetObject "NativeWindow"
hv.AssignHandle (DotNetObject "System.IntPtr" (max_handle)) 
form.show(hv)