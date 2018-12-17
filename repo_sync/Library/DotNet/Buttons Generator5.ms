Global mc2ButtonForm
Global WindowWrapper
(
	try (mc2ButtonForm.close()) catch()
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
	
	--DotNet Components
	fn netDrSize size     = (dotNetObject "Drawing.Size" size.x size.y)
	fn netDrPoint pos     = (dotnetObject "Drawing.Point" pos.x pos.y)
	fn netDrColor clr     = ((dotNetClass "Drawing.Color").fromArgb clr.r clr.g clr.b)
	fn netDrRect pos size = (dotnetObject "Drawing.Rectangle" pos.x pos.y size.x size.y)
	local netCursors      = (dotNetClass  "Cursors")
	
	--Local Variables
	local spinner_width = 20
	local form_bounds = 8
	local columns = 6
	local rows = 2
	local btn_vh_size = 22
	local btn_size = 24
	local count_limit = 10
	local form_size = ([btn_size, btn_size] * [columns, rows])+spinner_width + form_bounds
	
	--Interface Elements
	mc2ButtonForm  = dotnetObject "Form"
	local form     = mc2ButtonForm
	local tlp      = dotNetObject "TableLayoutPanel"
	local btnExit  = dotNetObject "button"
	local btnHL    = dotNetObject "button"
	local btnHR    = dotNetObject "button"
	local btnVU    = dotNetObject "button"
	local btnVD    = dotNetObject "button"
	local lblH     = dotNetObject "label" 
	local lblV     = dotNetObject "label" 

	--Interface Setup
	form.ControlBox  = false --hide main bar
	form.StartPosition = form.StartPosition.Manual
	form.Bounds = dotnetObject "Drawing.Rectangle" 200 100 form_size.x form_size.y
	--form.size = netDrSize form_size
	form.FormBorderStyle = form.FormBorderStyle.FixedDialog
	--form.Location = netDrPoint [ 200, 100 ]
	form.BackColor = netDrColor yellow
	form.MinimumSize = netDrSize [btn_size, btn_size]
	form.MaximumSize = netDrSize [btn_size*count_limit, btn_size*count_limit]
	form.AutoSize = false
	form.AutoScale = false
	form.opacity = 0.8
	
	--mc2system.show form.FormBorderStyle
	
	tlp.size = netDrSize (form_size - spinner_width - form_bounds)
	tlp.backColor = netDrColor( green )
	
	btnHL.Bounds = netDrRect [0  , tlp.height] [btn_vh_size, btn_vh_size]
	btnHL.FlatStyle = btnHR.FlatStyle.flat
	btnHL.text = "-"
	btnHL.tag = "HL"
	btnHL.BackColor = netDrColor (color 124 196 22)
	
	btnHR.Bounds = netDrRect [tlp.width - btn_vh_size, tlp.height] [btn_vh_size, btn_vh_size]
	btnHR.FlatStyle = btnHR.FlatStyle.flat
	btnHR.text = "+"
	btnHR.tag = "HR"
	btnHR.BackColor = netDrColor (color 124 196 22)
	
	btnVU.Bounds = netDrRect [tlp.width , 0] [btn_vh_size, btn_vh_size]
	btnVU.FlatStyle = btnHR.FlatStyle.flat
	btnVU.text = "-"
	btnVU.tag = "VU"
	btnVU.BackColor = netDrColor (color 124 196 22)
	
	btnVD.Bounds = netDrRect [tlp.width , tlp.height - btn_vh_size] [btn_vh_size, btn_vh_size]
	btnVD.FlatStyle = btnHR.FlatStyle.flat
	btnVD.text = "+"
	btnVD.tag = "VD"
	btnVD.BackColor = netDrColor (color 124 196 22)
	
	lblH.Bounds = netDrRect [btn_vh_size, tlp.height] [tlp.width - 2*btn_vh_size, btn_vh_size]
	lblH.TextAlign = lblH.TextAlign.MiddleCenter
	lblH.BackColor = netDrColor (color 84 132 15)
	lblH.text = "Columns:" + ((columns as integer) as string)
	
	lblV.Bounds = netDrRect [tlp.width, btn_vh_size] [btn_vh_size, tlp.height - 2*btn_vh_size]
	lblV.TextAlign = lblH.TextAlign.MiddleCenter
	lblV.BackColor = netDrColor (color 84 132 15)
	lblV.text = "Rows:" + ((rows as integer) as string)
	
	btnExit.size = netDrSize [btn_vh_size, btn_vh_size]
	btnExit.location = netDrPoint [tlp.width,tlp.height]
	btnExit.BackColor = netDrColor (green)--color 138 15 15)
	btnExit.text = "X"

	--Functions
	fn closeForm = (form.close())
	fn rClickMenu s a =
	(
		if a.Button == a.Button.Right do
		(
			rcMenu mainMenu
			(
				separator file_menu_1
				menuItem new_1 "Close Form..."
				separator file_menu_2
				on new_1 picked do (form.close())
			)
			PopupMenu mainMenu
		)
	)
	fn onBtnMouseUp s a = 
	(
		format "name:%\t tag:%\n" s.name s.tag
	)
	fn addButton int =
	(
		local btn = (dotNetObject "Button")
		btn.size = netDrSize [btn_size, btn_size]
		btn.flatstyle = btn.flatstyle.flat
		btn.margin =  dotnetobject "padding" 0
		btn.text = (int as integer) as string
		btn.name = "button_"+btn.text
		btn.tag = "BTN"
		dotNet.addEventHandler btn "MouseUp" onBtnMouseUp
		btn
	)
	fn generateButtons =
	(
		tlp.controls.clear()
		local cnt = 0
		for x = 0 to rows - 1 do
			for y = 0 to columns - 1 do
				tlp.Controls.Add (addButton (cnt +=1)) y x
	)
	fn resizeInterface s a =
	(
		--incremental phase
		case s.tag of
		(
			"HL":(if columns > 0           do columns -= 1)
			"HR":(if columns < count_limit do columns += 1)
			"VU":(if rows    > 0           do rows    -= 1)
			"VD":(if rows    < count_limit do rows    += 1)	
		)
		
		format "columns:%\trows:%\n"  columns rows
		
		--resize interface move button
		if columns > 0 and columns < count_limit and 
		   rows    > 0 and rows    < count_limit do
		(
			lblH.text = "Columns:" + ((columns as integer) as string)
			lblV.text = "Rows:" + ((rows as integer) as string)
			
			generateButtons()
			
			form_size = ([btn_size, btn_size] * [columns, rows])+spinner_width+form_bounds
			form.size = netDrSize form_size
			tlp.size = netDrSize (form_size - spinner_width - form_bounds)
			btnHL.Bounds = netDrRect [0  , tlp.height] [btn_vh_size, btn_vh_size]
			btnHR.Bounds = netDrRect [tlp.width - btn_vh_size, tlp.height] [btn_vh_size, btn_vh_size]
			btnVU.Bounds = netDrRect [tlp.width , 0] [btn_vh_size, btn_vh_size]
			btnVD.Bounds = netDrRect [tlp.width , tlp.height - btn_vh_size] [btn_vh_size, btn_vh_size]
			lblH.Bounds = netDrRect [btn_vh_size, tlp.height] [tlp.width - 2*btn_vh_size, btn_vh_size]
			lblV.Bounds = netDrRect [tlp.width, btn_vh_size] [btn_vh_size, tlp.height - 2*btn_vh_size]
			btnExit.location = netDrPoint [tlp.width,tlp.height]

		)
		--reset limits
		if columns == 0           do columns  = 1
		if columns == count_limit do columns -= 1
		if rows    == 0           do rows     = 1
		if rows    == count_limit do rows    -= 1
	)
	--Event Handlers
	dotNet.addEventHandler btnExit "MouseUp" closeForm
	dotNet.addEventHandler btnHL "MouseUp" resizeInterface
	dotNet.addEventHandler btnHR "MouseUp" resizeInterface
	dotNet.addEventHandler btnVU "MouseUp" resizeInterface
	dotNet.addEventHandler btnVD "MouseUp" resizeInterface
	dotNet.addEventHandler lblV "mouseUp" rClickMenu
	dotNet.addEventHandler lblH "mouseUp" rClickMenu
	
	form.controls.add(tlp)
	form.controls.add(btnHL)
	form.controls.add(btnHR)
	form.controls.add(btnVU)
	form.controls.add(btnVD)
	form.controls.add(lblH)
	form.controls.add(lblV)
	form.controls.add(btnExit)
	generateButtons()
	form.show(WindowWrapper)
)
