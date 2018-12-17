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
	top.Show(dotnetobject "WindowWrapper" (dotnetobject "System.IntPtr" s.handle))
)	
dotNet.addEventHandler form "Load" onLoad
fn onLocationChanged s a = if (top = s.OwnedForms[1]) != undefined do top.location = s.PointToScreen (dotnetclass "System.Drawing.Point").Empty	
dotNet.addEventHandler form "LocationChanged" onLocationChanged
fn onSizeChanged s a = if (top = s.OwnedForms[1]) != undefined do top.Size = s.ClientSize	
dotNet.addEventHandler form "ClientSizeChanged" onSizeChanged

form.Show(WindowWrapper)
  
