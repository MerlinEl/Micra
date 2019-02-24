Global mcDotnetVisualEditorDialog 
/**
*@Created by MerlinEl 2019
*@Inspired by biddle
*@Example
	mcDotnetVisualEditorDialog.open()
	mcDotnetVisualEditorDialog.close()
	mcDotnetVisualEditorDialog.moveTo [100, 200]
	atd...
*/
struct DOTNET_MAIN_STRUCT  (
	
public	
	title,
	--define interface components
	form = dotNetObject "MaxCustomControls.MaxForm",
	tlp = dotNetObject "TableLayoutPanel",
	cursor = dotnetclass "System.Windows.Forms.Cursor",
	--private variables
	pos					= [0, 0],
	size					= [800, 600],
	cursor_offset, --mouse pos on dialog
	minimized		= false, 
	old_height, 
	bar_height		= 14,
	border_offset	= 2,
	btn_size			= 24,
	debug				= 0,
public
	--Open / Close (with default setup, save position to INI)
	fn open = (if iskindof form dotnetobject do mcDotnet.dShow form),
	fn close = (if iskindof form dotnetobject do form.Close()),
	fn getName = ( title ),
	fn getPos = ( [form.location.x, form.location.y] ),
	fn getSize = ( [form.width, form.height] ),
private
	fn changeBackcolor s a = (s.backColor = mcDotnet.dColor (mcUIColors.get #fore)), --override form backcolor
	fn onFormCreated s a = (
		
		--format "onFormCreated > state:%\n" (s.WindowState.toString())
	),
	fn onCloseForm s a = (
		
		--format " save form:%  pos:% size:%\n" s.name (s.location.toString()) (s.size.toString())
		mcFile.saveDialogSettings s.name "Properties_2"
	),
	-- Custom  Functions
	-->
	
	-- main function
	fn init  =  (
		
		form.name = form.text = title
		--form.ControlBox  = false --hide main bar
		--form.ShowInTaskbar = false
		form.StartPosition = form.StartPosition.Manual
		form.bounds = mcDotnet.dRect pos size
		--form.FormBorderStyle = form.FormBorderStyle.none
		form.BackColor = mcDotnet.uiColor #fore
		form.opacity = 1 ---mcUIColors.get #opacity
		--form.TopMost = true --keep fotm upper from all toolbars
		
		
		--Componnts Layout
		tlp.Bounds  = mcDotnet.dRect [100, 200] [200, 100]
		tlp.backColor = mcDotnet.uiColor #btn
		
		--Custom Components
		-->
		
		-- Default Events
		dotnet.addEventHandler form "Shown" onFormCreated
		dotnet.addEventHandler form "Closed" onCloseForm
		dotnet.AddEventHandler form "BackColorChanged" changeBackcolor --override form backcolor (without this form color is default)
		
		--movable resizable component
		--Move / Snap Dialog /
		fn onLblTMouseMove s a = (  --drag form
			
			local mcs = mcDotnetVisualEditorDialog
			if a.Button == a.Button.left do  (
				
					local clientPosition = s.parent.PointToClient mcs.cursor.Position
					clientPosition.x -= mcs.cursor_offset.x --adjust position X
					clientPosition.y -= mcs.cursor_offset.y --adjust position Y
					clientPosition.x = mcMath.roundToInt clientPosition.x 10 --round snap pos x
					clientPosition.y = mcMath.roundToInt clientPosition.y 10 --round snap pos y
					s.location = clientPosition
					mcDotnetVisualEditorDialog.form .Update()
			)
		)
		fn onLblTMouseDown s a = ( --start drag
			
			local mcs = mcDotnetVisualEditorDialog
			if a.Button == a.Button.left do ( --enable drag

				mcs.cursor_offset = a.location --Save the location of the mouse pointer relative to the top-left corner of our control
				mcs.form.cursor = mcDotnet.Cursors.Hand	--change mouse icon to hand
			)
		)
		fn onLblTMouseUp s a = ( --stop drag
			
			local mcs = mcDotnetVisualEditorDialog
			mcs.form.cursor = mcDotnet.Cursors.Arrow--change mouse icon to arrow
		)
		dotNet.addEventHandler tlp   "MouseMove" onLblTMouseMove
		dotNet.addEventHandler tlp   "MouseDown" onLblTMouseDown 
		dotNet.addEventHandler tlp   "MouseUp" onLblTMouseUp
		--Custom Events
		-->
		
		--Add Controls
		form.controls.addRange ( #(tlp)  )
		OK
	),
	initialized = init()  --strange think but works
)
::mcDotnetVisualEditorDialog = DOTNET_MAIN_STRUCT title:"mcDotnetVisualEditorDialog"
::mcDotnetVisualEditorDialog.open()


--test TopMost
/*
Global User32
fn CreateUser32Assembly = (

	local source = "using System;\n"
	source += "using System.Runtime.InteropServices;\n"
	source += "class User32\n"
	source += "{\n"
	source += " [DllImport(\"user32.dll\")]\n"
	source += " public static extern bool SetWindowPos(Int64 hWnd, int hWndArg, int Left, int Top, int Width, int Height, int hWndFlags);\n"
	source += "}\n"
	csharpProvider = dotnetobject "Microsoft.CSharp.CSharpCodeProvider"
	compilerParams = dotnetobject "System.CodeDom.Compiler.CompilerParameters"			
	compilerParams.GenerateInMemory = on
	compilerResults = csharpProvider.CompileAssemblyFromSource compilerParams #(source)
	compilerResults.CompiledAssembly.CreateInstance "User32"
)
User32 = CreateUser32Assembly()

fn showTopmost name act:on = if (hwnd = windows.getChildHWND 0 name) != undefined do  (
	
	local HWND_TOPMOST 	= -1
	local HWND_NOTOPMOST 	= -2
	User32.setWindowPos hwnd[1] (if act then HWND_TOPMOST else HWND_NOTOPMOST) 0 0 0 0 0x3 -- (SWP_NOSIZE = 0x1, SWP_NOMOVE = 0x2)
	act
)
*/
/*
showTopmost "mcDotnetVisualEditorDialog" act:on
showTopmost "mcDotnetVisualEditorDialog" act:off
*/
