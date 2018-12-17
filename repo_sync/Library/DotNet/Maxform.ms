--form color
--you just override the backcolorchanged event 



 maxForm = dotNetObject "MaxCustomControls.MaxForm"
 Form.backcolor=(dotnetclass "System.Drawing.Color").FromARGB 255 0 0
 fn changeBackcolor = (maxForm.backColor = (dotnetclass "System.Drawing.Color").FromARGB 255 0 0)
 dotnet.AddEventHandler maxForm "BackColorChanged" changeBackcolor
 maxForm.showmodeless() 

---ok
fn changeBackcolor s a = (s.backColor = netDrColor clr_fore)
dotnet.AddEventHandler form "BackColorChanged" changeBackcolor
---ok

 Edit : 

 another solution would be to change the Property after you create the form , 
 but this will not be very suitable for different UI schemes 


 maxForm = dotNetObject "MaxCustomControls.MaxForm"
 Form.backcolor=(dotnetclass "System.Drawing.Color").FromARGB 0 0 255
 maxForm.showmodeless()
 maxForm.backColor = (dotnetclass "System.Drawing.Color").FromARGB 255 0 0