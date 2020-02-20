--MAX MAIN WINDOW SAFE RECTANGLE
form = dotNetObject "MaxCustomControls.MaxForm"
lbl = dotNetObject "Label"
form.FormBorderStyle = form.FormBorderStyle.None
form.StartPosition = form.StartPosition.Manual
form.AllowTransparency = true
-- form.TransparencyKey =  (dotNetClass "Drawing.Color").fromArgb 0 50 50
max_handle =  Windows.GetMAXHWND()
max_bounds = windows.getWindowPos max_handle
form_offset = 7.5
form_size = [max_bounds.w-form_offset*2, max_bounds.h-form_offset*2]
form.Size = mcDotnet.dSize form_size
form.location = mcDotnet.dPoint [max_bounds.x+form_offset, max_bounds.y+form_offset]

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
-- 	format "x: % y: % width: % height: %\n" rect.x rect.y rect.width rect.height
	local clr = (dotNetClass "Drawing.Color").fromArgb 255 81 68
	pen = dotnetobject  "Drawing.Pen" clr 6
	a.Graphics.DrawRectangle pen rect
)
dotNet.addEventHandler form "Paint" onFormPaint	
dotNet.addEventHandler lbl "MouseUp" onLblMouseUp
hv = DotNetObject "NativeWindow"
hv.AssignHandle (DotNetObject "System.IntPtr" (max_handle)) 
form.show(hv)