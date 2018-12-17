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
	local bar_height      = 14
	local form_bounds     = 2
	local form_offset     = 4
	local columns         = 6
	local rows            = 2
	local btn_size        = 24
	local count_limit     = 40
	local netDMove = false, netDmPos , minimized = false, old_height, edit_mode = false
	local icon_file = ((GetDir #ui)+"Icons\\Maintoolbar_24i.bmp")
	local clr_border = color 39 142 201
	local clr_button = color 24 92 130
	local clr_label  = color 17 62 88
	
	--Interface Elements
	mc2ButtonForm  = dotnetObject "Form"
	local form     = mc2ButtonForm
	local tlp      = dotNetObject "TableLayoutPanel"
	local btnMin  = dotNetObject "button"
	local btnHL    = dotNetObject "button"
	local btnHR    = dotNetObject "button"
	local btnVU    = dotNetObject "button"
	local btnVD    = dotNetObject "button"
	local lblT     = dotNetObject "label" 
	local lblH     = dotNetObject "label" 
	local lblV     = dotNetObject "label" 

	--Interface Setup
	form.ControlBox  = false --hide main bar
	form.StartPosition = form.StartPosition.Manual
	form.Location = netDrPoint [200, 100]
	--form.Bounds = netDrRect [200, 100] [form_size.x, form_size.y]
	form.FormBorderStyle = form.FormBorderStyle.none
	form.BackColor = netDrColor clr_border --yellow
	form.MinimumSize = netDrSize [btn_size, bar_height]
	form.MaximumSize = netDrSize [btn_size*count_limit, btn_size*count_limit]
	--form.AutoSize = false
	--form.AutoScale = false
	form.opacity = 0.8
	
	--mc2system.show form

	lblT.BackColor = netDrColor clr_label --(color 84 132 15)
	lblT.ForeColor = netDrColor clr_border
	lblT.text = "Modifiers:"
	
	
	btnMin.FlatStyle = btnMin.FlatStyle.flat
	btnMin.BackColor = netDrColor clr_button --(color 124 196 22)
	btnMin.text = "-"
	--btnMin.ToolTip = "Minimize..."
	mc2system.show btnMin
	tlp.backColor = netDrColor clr_button --( green )
	
	btnHL.FlatStyle = btnHR.FlatStyle.flat
	btnHL.text = "-"
	btnHL.tag = "HL"
	btnHL.BackColor = netDrColor clr_button --(color 124 196 22)
	
	btnHR.FlatStyle = btnHR.FlatStyle.flat
	btnHR.text = "+"
	btnHR.tag = "HR"
	btnHR.BackColor = netDrColor clr_button --(color 124 196 22)
	
	
	btnVU.FlatStyle = btnHR.FlatStyle.flat
	btnVU.text = "-"
	btnVU.tag = "VU"
	btnVU.BackColor = netDrColor clr_button --(color 124 196 22)
	
	btnVD.FlatStyle = btnHR.FlatStyle.flat
	btnVD.text = "+"
	btnVD.tag = "VD"
	btnVD.BackColor = netDrColor clr_button --(color 124 196 22)
	
	lblH.TextAlign = lblH.TextAlign.MiddleCenter
	lblH.BackColor = netDrColor clr_label --(color 84 132 15)
	lblH.text = (columns as integer) as string
	
	lblV.TextAlign = lblH.TextAlign.MiddleCenter
	lblV.BackColor = netDrColor clr_label --(color 84 132 15)
	lblV.text = (rows as integer) as string
	
	--Functions
	fn getIconDotNet img h icn_num =
	(
		local x = (h * icn_num)

		local icon = (dotNetObject "Drawing.Bitmap" h h) --Create new bitmap object
		local gra  = (dotNetClass "Drawing.Graphics").fromImage icon --Create new Graphics object
		local newRect = dotnetObject "Drawing.rectangle" 0 0  h  h
		gra.DrawImage img newRect x 0 h h (dotNetClass "Drawing.GraphicsUnit").Pixel	
		icon
	)
	fn getIconList =
	(
		
		local img = (dotNetClass "Drawing.Image").FromFile icon_file --get the saved image from file as bitmap
		local w = img.width
		local h = img.height
		local icn_count = (w / h) as integer
		
		local img_list = dotNetObject "ImageList"
		img_list.ImageSize = netDrSize [h, h]
		img_list.ColorDepth = img_list.ColorDepth.Depth24Bit
		img_list.transparentColor = netDrColor gray
		for i = 1 to icn_count do img_list.images.add (getIconDotNet img h i)
		img.dispose()
		return img_list

	)
	fn closeForm = (form.close())
	fn minMaxForm =
	(
		if edit_mode do return false
		minimized = not minimized
		if minimized
		then 
		(
			btnMin.text = "+"
			old_height  = form.height 
			form.height = bar_height + form_bounds*2
		)
		else
		(
			btnMin.text = "-"
			form.height = old_height
		)
		
	) 
	fn onBtnMouseUp s a = 
	(
		format "name:%\t tag:%\n" s.name s.tag
	)
	fn addButton int img =
	(
		local btn = (dotNetObject "Button")
		btn.size = netDrSize [btn_size, btn_size]
		--btn.flatstyle = btn.flatstyle.flat
		btn.margin =  dotnetobject "padding" 0
		--btn.text = (int as integer) as string
		--btn.name = "button_"+btn.text
		btn.name = "button_"+(int as integer) as string
		btn.tag = "BTN"
       	btn.Image = img
  --.ImageAlign : <System.Drawing.ContentAlignment>
  --.ImageIndex : <System.Int32>
  --.ImageKey : <System.String>
  --.ImageList : <System.Windows.Forms.ImageList>
		dotNet.addEventHandler btn "MouseUp" onBtnMouseUp
		btn
	)
	fn generateButtons =
	(
		tlp.controls.clear()
		local image_list = getIconList()
		--print image_list.Images.count
		local cnt = 0
		for x = 0 to rows - 1 do
			for y = 0 to columns - 1 do
				tlp.Controls.Add (addButton (cnt +=1) (image_list.Images.Item (random 1 (image_list.Images.count-1))) ) y x
	)
	fn resizeInterface style:#extended =
	(
		local table_size = [btn_size, btn_size] * [columns, rows]
		case style of
		(
			#extended:
			(
				local table_size = [btn_size, btn_size] * [columns, rows]
				local form_size  = table_size + bar_height + form_offset + [0, bar_height]
				form.size        = netDrSize form_size
				lblT.Bounds      = netDrRect [form_bounds, form_bounds] [table_size.x , bar_height]
				tlp.Bounds       = netDrRect [form_bounds, bar_height + form_bounds] table_size
				btnHL.Bounds     = netDrRect [form_bounds  , tlp.height + bar_height + form_bounds] [btn_size, bar_height]
				btnHR.Bounds     = netDrRect [tlp.width - btn_size + form_bounds, tlp.height + bar_height + form_bounds] [btn_size, bar_height]
				btnVU.Bounds     = netDrRect [tlp.width + form_bounds, form_bounds] [bar_height, btn_size]
				btnVD.Bounds     = netDrRect [tlp.width + form_bounds , form_size.y - btn_size - form_bounds] [bar_height, btn_size]
				lblH.Bounds      = netDrRect [form_bounds, form_size.y - bar_height - form_bounds] [form_size.x - form_bounds*2, bar_height]
				lblV.Bounds      = netDrRect [tlp.width + form_bounds, form_bounds] [bar_height, form_size.y - form_bounds*2]
			)
			#compact:
			(
				
				local form_size  = table_size + form_offset + [0, bar_height]
				form.size        = netDrSize form_size
				lblT.Bounds      = netDrRect [form_bounds, form_bounds] [table_size.x - btn_size, bar_height]
				btnMin.Bounds   = netDrRect [table_size.x - btn_size + form_bounds, form_bounds] [btn_size, bar_height]
				tlp.Bounds       = netDrRect [form_bounds, bar_height + form_bounds] table_size
			)
		)
	)
	fn manageInterface s a =
	(
		--incremental phase
		case s.tag of
		(
			"HL":(if columns > 2           do columns -= 1)
			"HR":(if columns < count_limit do columns += 1)
			"VU":(if rows    > 1           do rows    -= 1)
			"VD":(if rows    < count_limit do rows    += 1)	
		)
		
		format "columns:%\trows:%\n"  columns rows
		
		--resize interface move button
		if columns > 1 and columns < count_limit and 
		   rows    > 0 and rows    < count_limit do
		(
			lblH.text = (columns as integer) as string
			lblV.text = (rows as integer) as string
			
			generateButtons()
			resizeInterface()
		)
		--reset limits
		if columns == 0           do columns  = 1
		if columns == count_limit do columns -= 1
		if rows    == 0           do rows     = 1
		if rows    == count_limit do rows    -= 1
	)
	fn showRcMenu =
	(
		rcMenu mainMenu
		(
			separator file_menu_1
			menuItem m_close "Close..."
			separator file_menu_2
			menuItem m_edit "Edit..."
			menuItem m_lock2 "Lock..."
			on m_close picked do (form.close())
			on m_edit  picked do 
			(
				dotNet.addEventHandler btnHL "MouseUp" manageInterface
				dotNet.addEventHandler btnHR "MouseUp" manageInterface
				dotNet.addEventHandler btnVU "MouseUp" manageInterface
				dotNet.addEventHandler btnVD "MouseUp" manageInterface
				form.controls.remove(btnMin)
				form.controls.add(btnHL)
				form.controls.add(btnHR)
				form.controls.add(btnVU)
				form.controls.add(btnVD)
				form.controls.add(lblH)
				form.controls.add(lblV)
				resizeInterface style:#extended
				edit_mode = true
			)
			on m_lock2  picked do 
			(
				dotNet.removeEventHandler btnHL "MouseUp" manageInterface
				dotNet.removeEventHandler btnHR "MouseUp" manageInterface
				dotNet.removeEventHandler btnVU "MouseUp" manageInterface
				dotNet.removeEventHandler btnVD "MouseUp" manageInterface
				form.controls.remove(btnHL)
				form.controls.remove(btnHR)
				form.controls.remove(btnVU)
				form.controls.remove(btnVD)
				form.controls.remove(lblH)
				form.controls.remove(lblV)
				form.controls.add(btnMin)
				resizeInterface style:#compact
				edit_mode = false
			)
		)
		PopupMenu mainMenu
	)
	--Form move
	fn onLblTMouseMove sender arg = 
	(
		if netDMove do --dragForm
		(
			local netDPos = [sender.MousePosition.x, sender.MousePosition.y] - netDmPos
			form.Location = dotNetObject "System.Drawing.Point" netDPos.x netDPos.y
		)
	)
	fn onLblTMouseDown sender arg = 
	(
		if arg.Button == arg.Button.left do --enableDrag
		(
			form.cursor.current = netCursors.Hand
			netDmPos = [form.MousePosition.x, form.MousePosition.y] - [form.left, form.top] 
			netDMove = true 
		)
	)
	fn onLblTMouseUp sender arg = 
	(
		netDMove = false --disableDrag
		if arg.Button == arg.Button.right then showRcMenu()
	)
	--Event Handlers
	dotNet.addEventHandler btnMin "MouseUp"   minMaxForm
	dotNet.addEventHandler lblT   "MouseMove" onLblTMouseMove
	dotNet.addEventHandler lblT   "MouseDown" onLblTMouseDown 
	dotNet.addEventHandler lblT   "MouseUp"   onLblTMouseUp
	
	--mc2system.show btnHL
	
	form.controls.add(tlp)
	form.controls.add(lblT)
	form.controls.add(btnMin)
	generateButtons()
	resizeInterface style:#compact
	form.show(WindowWrapper)
)

/*
mc2ButtonForm.hide()
mc2ButtonForm.show()
*/
