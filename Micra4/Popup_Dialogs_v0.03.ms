----------------------------------------------------------------------------
--xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx--

                           -- Pop Up Dialogs --
							 
--xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx--
----------------------------------------------------------------------------
Global mcPopUp

Struct MICRA_POPUP (

	_drag_pos = [0,0,0], --form mouse pos
	_typed_text = "",
	_invalid_characters = "^[]()\\/*{}-+><=;:,.%@#&?!$ ",
	_saved_pos = "MaxCenter",
	fn defNWin = (
		local nw = DotNetObject "NativeWindow"
		nw.AssignHandle (DotNetObject "System.IntPtr" (Windows.GetMaxHWND())) 
		return nw
	),
	fn closeForm form = (
		
		form.close()
		if _saved_pos != "MaxCenter" do mcFile.saveIniDialog form "Properties_2" _saved_pos
	),
	fn removeInvalidChars str =	(
		
			if str.count == 0 do return str
			local new_str = ""
			for i=1 to str.count do (
				
				local char = str[i]
				if findString _invalid_characters char != undefined do continue
				new_str += char
			)
			return new_str
	),
	fn messageBox msg title:"Micra:" = (
		
		--TODO dotnet version more elegant :-)
		::messageBox msg title:title beep:false
	),
	/**
	* @example 
		typed_text = mcPopup.textBox()
		format "typed_text:%\n" typed_text
	*/
	fn textBox title:"Type a text here:" saved_pos:"MaxCenter" = (
	
		local form = dotNetObject "MaxCustomControls.Maxform"
		local lblT = dotNetObject "label"
		local edtBox = dotNetObject "textbox"
		local form_size = [320, 60]
		local border_offset  = 2
		local btn_size       = 24
		local bar_height     = 14
		_saved_pos = saved_pos
		local max_center = mcSystem.getMaxCenter()
		max_center.x -= form_size.x / 2
		local form_rect = netDrRect max_center form_size
		
		if saved_pos != "MaxCenter" then (
			
			local fpos = (mcCall.getIniDataFromArray Micra.TempProfileIni "Properties_2" saved_pos 2)
			if fpos == undefined do fpos = (mcCall.getIniDataFromArray Micra.DefaultProfileIni "Properties_2" saved_pos 2)
			if fpos != undefined do form_rect = netDrRect fpos form_size
		) 
		fn textBoxControll s a  = (
		
			local char_str = a.Keycode.toString()
			case char_str of (
				
				"Escape":( --Escape
				
				print "escape"
				
					mcPopUp._typed_text = ""
					mcPopUp.closeForm s.parent
				)
				"Return":( --Enter
				
					mcPopUp._typed_text = s.text
					mcPopUp.closeForm s.parent
				)
				default:(
				
					if s.text.count > 0 do (
						
						s.text = mcPopUp.removeInvalidChars s.text --remove invalid characters
						s.SelectionStart = s.text.count --move cursor at end
					)
				)
			)
		)
		--Move / Snap Dialog
		fn onLblTMouseMove s a = ( if a.Button == a.Button.left do mcFormSnap s.parent mcPopUp._drag_pos ) --dragForm
		fn onLblTMouseDown s a = (
				
			local form = s.parent
			form.cursor.current = netCursors.Hand
			if a.Button == a.Button.left do ( --enable drag
				mcPopUp._drag_pos = [form.MousePosition.x, form.MousePosition.y] - [form.left, form.top] 
			)
		)
		--RC close form
		fn onLblTMouseUp s a = ( if a.Button == a.Button.right then mcPopUp.closeForm s.parent ) --drop form

		form.ControlBox  = false --hide main bar
		form.StartPosition = form.StartPosition.Manual
		form.bounds = form_rect
		form.BackColor = netDrColor (mcUIColors.get #fore)
		form.ShowInTaskbar = false
		form.FormBorderStyle = form.FormBorderStyle.none
		form.opacity = 1--(mcUIColors.get #opacity)
		--form.TopMost=true
		
		--toolbar
		lblT.bounds = netDrRect [border_offset, border_offset] [form_size.x - border_offset*10 , bar_height]
		lblT.BackColor = netDrColor (mcUIColors.get #back)
		lblT.ForeColor = netDrColor (mcUIColors.get #text)
		lblT.TextAlign = lblT.TextAlign.MiddleCenter
		lblT.Text = title
		
		edtBox.bounds = netDrRect [ border_offset ,bar_height+border_offset*2] [312, 22]
		edtBox.Multiline = true
		edtBox.BackColor= netDrColor (mcUIColors.get #edtback)
		edtBox.ForeColor= netDrColor (mcUIColors.get #edtfore)
		local dnfontlarge = dotNetObject "System.Drawing.Font" "Verdana" 12 ((dotNetClass "System.Drawing.FontStyle").bold)
		edtBox.font = dnfontlarge
		
		dotNet.addEventHandler lblT   "MouseMove" onLblTMouseMove
		dotNet.addEventHandler lblT   "MouseDown" onLblTMouseDown 
		dotNet.addEventHandler lblT   "MouseUp" onLblTMouseUp
		dotnet.addEventHandler edtBox "KeyUp" textBoxControll

		form.controls.addRange ( #(lblT, edtBox)  )
		form.ShowModal() 
		return _typed_text
	)
)
mcPopUp = MICRA_POPUP()