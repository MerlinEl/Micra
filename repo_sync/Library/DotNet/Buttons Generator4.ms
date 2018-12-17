Global WindowWrapper
Global mc2DialogCreator

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
--->Begin
try(mc2DialogCreator.close())catch()
(
	local netCursors      = (dotNetClass "Cursors")
	fn netDrColor clr     = ((dotNetClass "Drawing.Color").fromArgb clr.r clr.g clr.b)
	fn netDrBitmap size   = (dotNetObject "Drawing.Bitmap" size.x size.y)

	local dMove = false, DmPos, frame_min = [100,100], frame_max = [2048,2048]
	local netDMove = false, netDmPos
	local button_size = 40, top_offset = 10, diaSize = [324, 260]
	local lp = dotNetObject "TableLayoutPanel"
	local form = dotnetobject "Form"
	
--| --Form	SetUp
	form.width   = diaSize.x
	form.height  = diaSize.y
	form.MinimumSize = netDrSize frame_min
	form.MaximumSize = netDrSize frame_max
	form.FormBorderStyle = form.FormBorderStyle.FixedDialog--Sizable
	form.ShowInTaskbar  = false --hide from windows task bar
	form.ControlBox  = false --hide main bar
	form.backColor = netDrColor (color 0 255 0) --form Back Color
	form.opacity = 0.5
	form.StartPosition = form.StartPosition.Manual
 	form.Location = netDrPoint [ 200, 100 ]
	fn updateFramePos dia_pos: =
	(
		local view_rect = getviewsize() 
		format "rect:%\tsize:%\n" (viewport.getRegionRect viewport.activeViewport) view_rect
		form.Location = dotNetObject "System.Drawing.Point" ((view_rect.x - form.width)/2) ((view_rect.y - form.height)/2)
		--StartPosition
		--if dia_pos == unsupplied do dia_pos = getDialogPos mc2ViewportRecorderDialog
		--form.Location = dotNetObject "System.Drawing.Point" (dia_pos.x) (dia_pos.y+mc2ViewportRecorderDialog.height+6)
	)
	fn dragFrame ctrl arg = 
	(
		if netDMove do
		(
			local netDPos = [ctrl.MousePosition.x, ctrl.MousePosition.y] - netDmPos
			form.Location = dotNetObject "System.Drawing.Point" netDPos.x netDPos.y
		)
	)
	fn enableDrag  = 
	(
		form.cursor.current = netCursors.Hand
		--format "dia pos :%\t dia m pos:%\tscreen m pos:%\n" [form.Location.x, form.Location.y] [form.MousePosition.x, form.MousePosition.y] mouse.screenpos
		netDmPos = [form.MousePosition.x, form.MousePosition.y] - [form.Location.x, form.Location.y] 
		netDMove = true 
		--.Cursor : <System.Windows.Forms.Cursor>
	)
	fn disableDrag = (netDMove = false)
--|| --Form	SetUp
--| --Actions
	fn OnButtonClick send arg = 
	(
		format "send:%\targ:%\nbtn_name:%\tbtn_tag:%\n" send arg send.text send.tag
		form.close()
	)
	fn manageInterface sender arg =
	(
		lp.width = sender.Width
		lp.height = sender.Height - top_offset
		--form.width  = (lp.layoutSettings.ColumnCount*button_size)
 		--form.height = (lp.layoutSettings.RowCount*button_size   ) + 40
		--lp.layoutSettings.RowCount += 
 		--lp.layoutSettings.ColumnCount += 
	)
	fn addButton int =
	(
		local btn = (dotNetObject "Button")
		btn.size = netDrSize [button_size, button_size]
		btn.flatstyle = (dotNetclass "FlatStyle").flat
		btn.margin =  dotnetobject "padding" 0
		btn.Text = (int as integer) as string
		dotNet.addEventHandler btn "Click" OnButtonClick -- Setup an event handler for buttons
		btn
	)
	fn generateButtons columns rows =
	(
		lp.controls.clear()
		local cnt = 0
		for x = 0 to rows - 1 do
			for y = 0 to columns - 1 do
				lp.Controls.Add (addButton (cnt +=1)) y x
	)
	fn initializeInterface =
	(
		local columns = diaSize.x  / button_size
		local rows = diaSize.y / button_size
		local buttons_count = rows * columns
		
		lp.backColor = netDrColor( orange ) --form Back Color
		lp.Padding = dotNetObject "Padding" 2 --panel left up offset
		lp.Top = top_offset
		lp.BorderStyle = (dotNetClass "BorderStyle").None	
		lp.width = diaSize.x
		lp.height = diaSize.y - top_offset 
		lp.AllowDrop = true
		lp.AutoSize = true
		lp.autoscroll = true
		generateButtons columns rows
	)
--|| --Actions
	initializeInterface()
	form.Controls.Add(lp)
	dotNet.addEventHandler form "SizeChanged" manageInterface
	dotNet.addEventHandler form "MouseMove" dragFrame
	dotNet.addEventHandler form "MouseDown" enableDrag 
	dotNet.addEventHandler form "MouseUp" disableDrag
	form.show(WindowWrapper)
)