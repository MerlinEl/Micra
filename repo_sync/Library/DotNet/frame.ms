Global mc2ViewportRecorderForm
Global WindowWrapper
(	
	local netDMove = false, netDmPos, resize_in_center = true
	local frame_min = [100,100], frame_max = [2048,2048]
	local enabledTransform = true 
	local cursors = dotNetClass "System.Windows.Forms.Cursors"
	local cursor = dotNetClass "System.Windows.Forms.Cursor"
	local color_class = (dotnetclass "System.Drawing.Color")
	
	try( mc2ViewportRecorderForm.close(); mc2ViewportRecorderForm.dispose() )catch()
	
	mc2ViewportRecorderForm = dotnetobject "System.Windows.Forms.Form"
	local netform = mc2ViewportRecorderForm
	local lbl_info= dotnetobject "system.windows.forms.label"
	
	--mc2system.show netform
	fn formPaint sender arg =
	(
	print sender
	print arg
	--	arg.graphics.clear((dotNetClass "system.drawing.color")fromargb 255 255 255)
		rec=dotNetObject "system.drawing.rectangle" 2 2 200 200
		bgColor=(dotNetClass "system.drawing.color").fromargb 255 255 0 0 
		brush=dotnetobject "System.Drawing.SolidBrush" bgColor
		arg.graphics.FillRectangle brush rec
		print arg.graphics
	)
	
	fn separator sender arg = 
	(
		local rect = dotNetObject "system.drawing.rectangle" 0 16 sender.width 2
		local clr=(dotNetClass "system.drawing.color").fromargb 255 255 255
		local brush= dotnetobject "System.Drawing.SolidBrush" clr
		arg.graphics.FillRectangle brush rect
	)
	fn getWindowWrapper = --made by DenisT :-)
	(
		print "compile WindowWrapper"
		
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
	fn resizing sender arg =
	(
		lbl_info.text="["+sender.Width as string+" , "+sender.Height as string+"]"
		lbl_info.width = netform.width
		--if resize_in_center do
		--(
			--netform.Location = dotNetObject "System.Drawing.Point" (netform.Location.x + sender.Width/2) (netform.Location.y + sender.Height/2)
		--)
	)
	fn resizeForm sender arg =
	(
		if not enabledTransform do return false
		netform.cursor.current = cursors.SizeAll
		
		local step = 10--if keyboard.shiftPressed then 20 else 10
		
		if arg.Delta > 0 
		then (netform.width += 10 ; netform.height += step)
		else (netform.width -= 10 ; netform.height -= step)

		local netDPos =  [netform.left, netform.top] + (if arg.Delta > 0 then - step/2 else step/2)
		netform.Location = dotNetObject "System.Drawing.Point" netDPos.x netDPos.y
	)
	fn updateFramePos dia_pos: =
	(
		local max_pos = getMAXWindowPos()--Returns the 3ds max window position in pixels relative to the upper left corner of the desktop. Returns [-4,-4] when the application is maximized.
		local max_size = getMAXWindowSize()--Returns the 3ds max window size in pixels.
		local max_center = max_size/2 + max_pos
		netform.left = max_center.x
		netform.top = max_center.y
		--netform.Location = dotNetObject "System.Drawing.Point" max_center.x max_center.y
	)
	fn dragFrame sender arg = 
	(
		if netDMove do
		(
			local netDPos = [sender.MousePosition.x, sender.MousePosition.y] - netDmPos
			netform.Location = dotNetObject "System.Drawing.Point" netDPos.x netDPos.y
		)
	)
	fn enableDrag sender arg = 
	(
		if arg.Button == arg.Button.left and enabledTransform do
		(
			netform.cursor.current = cursors.Hand--IBeam--cross--SizeAll
			--format "dia pos :%\t dia m pos:%\tscreen m pos:%\n" [netform.Location.x, netform.Location.y] [netform.MousePosition.x, netform.MousePosition.y] mouse.screenpos
			netDmPos = [netform.MousePosition.x, netform.MousePosition.y] - [netform.left, netform.top] 
			netDMove = true 
		)
	)
	fn showRcMenu =
	(
		rcMenu recFrameMenu
		(
			menuItem mnu_rec	"Rec..."
			menuItem mnu_stop	"Stop..."
			separator file_menu_2
			menuItem mnu_help	"Help..."
			menuItem mnu_close	"Quit..."
			on mnu_close  picked do (netform.close())
			on mnu_rec picked do 
			(
				netform.FormBorderStyle = netform.FormBorderStyle.FixedDialog 
				netform.backColor = color_class.fromArgb 0 255 0 --form Back Color
				netform.TransparencyKey = netform.backColor
				enabledTransform = false
			)
			on mnu_stop picked do 
			(
				netform.FormBorderStyle = netform.FormBorderStyle.Sizable
				netform.TransparencyKey = undefined
				enabledTransform = true
			)
		)
		popUpMenu recFrameMenu
	)
	fn disableDrag sender arg = 
	(
		netDMove = false
		if arg.Button == arg.Button.right then showRcMenu()
	)
	
	--Begin
	if WindowWrapper == undefined do
	(
		getWindowWrapper()
		WindowWrapper = dotnetobject "WindowWrapper" (windows.getMAXHWND()) 
		print WindowWrapper
	)

	netform.width = 200
	netform.height = 200
	netform.MinimumSize = dotNetObject "System.Drawing.Size" frame_min.x frame_min.y
	netform.MaximumSize = dotNetObject "System.Drawing.Size" frame_max.x frame_max.y
	netform.FormBorderStyle = netform.FormBorderStyle.Sizable
	
	netform.ShowInTaskbar  = false --hide from windows task bar
	netform.ControlBox  = false --hide main bar
	netform.backColor = color_class.fromArgb 0 255 0 --form Back Color
	netform.opacity = 0.5
	
	--mc2system.show netform
	
	--.Controls : <System.Windows.Forms.Control+ControlCollection>, read-only
	
	lbl_info.text="[0, 0]"
	lbl_info.width = netform.width
	lbl_info.height = 16
	lbl_info.foreColor = color_class.fromArgb 255 255 255
	lbl_info.backColor = color_class.fromArgb 0 255 255
	lbl_info.Location=dotNetObject "System.Drawing.Point" 0 0

	lbl_info.RectangleToClient (dotNetObject "system.drawing.rectangle" 0 5 20 6)

	netform.controls.add(lbl_info)
	
	dotNet.addEventHandler netform "SizeChanged" resizing
	dotNet.addEventHandler netform "MouseMove" dragFrame
	dotNet.addEventHandler netform "MouseDown" enableDrag 
	dotNet.addEventHandler netform "MouseUp" disableDrag
	dotNet.addEventHandler netform "MouseWheel" resizeForm
	
	dotnet.addEventHandler netform "paint" separator --formPaint--
	dotNet.addEventHandler lbl_info "MouseMove" dragFrame
	dotNet.addEventHandler lbl_info "MouseDown" enableDrag 
	dotNet.addEventHandler lbl_info "MouseUp" disableDrag
	
	mc2ViewportRecorderForm.Show ( WindowWrapper )

	updateFramePos()
)