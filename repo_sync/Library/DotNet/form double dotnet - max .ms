global WindowWrapper 
if WindowWrapper == undefined do
( 
	fn getWindowWrapper = 
	(
		source = ""
		source += "using System;\n"
		source += "using System.Windows.Forms;\n"
		source += "public class WindowWrapper : IWin32Window\n"
		source += "{\n"
		source += "	public WindowWrapper(IntPtr handle) { _hwnd = handle; }\n"
		source += "	public WindowWrapper(Int32 handle) { _hwnd = (IntPtr)handle; }\n"
		source += "	public IntPtr Handle { get { return _hwnd; } }\n"
		source += "	private IntPtr _hwnd;\n"
		source += "}\n"
		-- Compile on fly
		csharpProvider = dotnetobject "Microsoft.CSharp.CSharpCodeProvider"
		compilerParams = dotnetobject "System.CodeDom.Compiler.CompilerParameters"
		compilerParams.ReferencedAssemblies.Add("System.dll");
		compilerParams.ReferencedAssemblies.Add("System.Windows.Forms.dll");
		compilerParams.GenerateInMemory = on
		compilerResults = csharpProvider.CompileAssemblyFromSource compilerParams #(source)

		compilerResults.CompiledAssembly
	)
	getWindowWrapper()
	WindowWrapper = dotnetobject "WindowWrapper" (windows.getMAXHWND()) 
)

 try(form.close()) catch()
--Main From
form = dotnetobject "form"
form.size = dotnetobject "System.Drawing.Size" 200 200
form.opacity = 0.7

fn netDrColor clr       = ((dotNetClass "Drawing.Color").fromArgb clr.r clr.g clr.b)
fn netDrRect pos size   = (dotnetObject "Drawing.Rectangle" pos.x pos.y size.x size.y)
fn closeTopForm s a = (s.parent.owner.close() )	
fn onSizeChanged s a =
(
	local top = s.OwnedForms[1] 
	if top != undefined do top.Size = s.ClientSize
)
fn onLocationChanged s a = 
(
	local top = s.OwnedForms[1] 
	if top != undefined do top.location = s.PointToScreen (dotnetclass "System.Drawing.Point").Empty
)	
fn onLoad s a =
(
	tb = dotnetobject "Button"
	tb.text = "Top Button"
	tb.backColor = netDrColor green
	tb.Dock = tb.Dock.Top
	
	bb = dotnetobject "Button"
	bb.text = "Close"
	bb.backColor = netDrColor green
	bb.Dock = bb.Dock.Bottom
	
	top = dotnetobject "Form"
	top.StartPosition = top.StartPosition.Manual
	top.ShowInTaskBar = false
	top.FormBorderStyle = top.FormBorderStyle.None
	top.TransparencyKey = top.BackColor
	top.Controls.addrange #(tb, bb)
	
	dotNet.addEventHandler bb "MouseUp" closeTopForm

	s.AddOwnedForm top
	top.Location = s.PointToScreen (dotnetclass "System.Drawing.Point").Empty
	top.Size = s.ClientSize
	top.Show()
)

dotNet.addEventHandler form "Load" onLoad
dotNet.addEventHandler form "LocationChanged" onLocationChanged	
dotNet.addEventHandler form "ClientSizeChanged" onSizeChanged

form.Show(WindowWrapper)
