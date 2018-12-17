global netnetformtesttest
assemblyFileName = "E:\\Micra2\\App\\MaxCustomControls.dll"
-- Load the class library created 
dotnet.LoadAssembly assemblyFileName 
 try(form.close()) catch()
form = dotnetobject "form"
form.size = dotnetobject "System.Drawing.Size" 200 200
form.opacity = 0.7
		
tb = dotnetobject "Button"
tb.text = "Top Button"
tb.Dock = tb.Dock.Top

bb = dotnetobject "Button"
bb.text = "Bottom Button"
bb.Dock = bb.Dock.Bottom	
	
fn onLoad s a =
(
	top = dotnetobject "Form"
	top.StartPosition = top.StartPosition.Manual
	top.ShowInTaskBar = off
	top.FormBorderStyle = top.FormBorderStyle.None
	top.TransparencyKey = top.BackColor
	top.Controls.addrange #(tb, bb)

	s.AddOwnedForm top
	top.Location = s.PointToScreen (dotnetclass "System.Drawing.Point").Empty
	top.Size = s.ClientSize
	top.Show() --(dotnetobject "MaxCustomControls.Win32HandleWrapper" (dotnetobject "System.IntPtr" s.handle))
)	
dotNet.addEventHandler form "Load" onLoad
fn onLocationChanged s a = if (top = s.OwnedForms[1]) != undefined do top.location = s.PointToScreen (dotnetclass "System.Drawing.Point").Empty	
dotNet.addEventHandler form "LocationChanged" onLocationChanged
fn onSizeChanged s a = if (top = s.OwnedForms[1]) != undefined do top.Size = s.ClientSize	
dotNet.addEventHandler form "ClientSizeChanged" onSizeChanged

 p = DotNetObject "System.IntPtr" ( Windows.GetMAXHWND() )
 form.Show() --( DotNetObject "MaxCustomControls.Win32HandleWrapper" p )

  
