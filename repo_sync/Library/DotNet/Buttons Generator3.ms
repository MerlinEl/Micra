Global WindowWrapper
Global mc2DialogCreator
try(mc2DialogCreator.close())catch()
if WindowWrapper == undefined do --mage by DenisT
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
---
(


	local button_size = 40, top_offset = 10, diaSize = [324, 260]
	local form = dotnetobject "Form"
	local lp = dotNetObject "FlowLayoutPanel"
	form.width   = diaSize.x
	form.height  = diaSize.y
	
	fn OnButtonClick send arg = 
	(
		format "send:%\targ:%\nbtn_name:%\tbtn_tag:%\n" send arg send.text send.tag
	)
	fn manageInterface sender arg =
	(
		lp.width = sender.Width
		lp.height = sender.Height - top_offset
	)
	fn generateButtons buttons_count =
	(
		lp.controls.clear()
		for i = 1 to buttons_count do
		(
			local btn = (dotNetObject "Button")
			btn.size = netDrSize [button_size, button_size]
			btn.flatstyle = (dotNetclass "FlatStyle").flat
			btn.margin =  dotnetobject "padding" 0
			btn.textalign =  (dotnetclass "Drawing.ContentAlignment").BottomCenter
			btn.Text = (i as integer) as string
			dotNet.addEventHandler btn "Click" OnButtonClick -- Setup an event handler for buttons
			lp.Controls.Add btn
		)
	)
	fn initializeInterface =
	(
		local buttons_X = diaSize.x  / button_size
		local buttons_Y = diaSize.y / button_size
		local buttons_count = buttons_X * buttons_Y
		lp.backColor = netDrColor( orange ) --form Back Color
		lp.Padding = dotNetObject "Padding" 2 --panel left up offset
		lp.Top = top_offset
		lp.BorderStyle = (dotNetClass "BorderStyle").None	
		lp.width = diaSize.x
		lp.height = diaSize.y - top_offset 
		lp.AllowDrop = true
		lp.AutoSize = true
		lp.autoscroll = true
		generateButtons buttons_count
	)
	initializeInterface()
	form.Controls.Add(lp)
	dotNet.addEventHandler form "SizeChanged" manageInterface
	form.show(WindowWrapper)
)