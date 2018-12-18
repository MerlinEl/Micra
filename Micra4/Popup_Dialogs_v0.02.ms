----------------------------------------------------------------------------
--xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx--

                           -- Pop Up Dialogs --
							 
--xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx--
----------------------------------------------------------------------------
Global mcPopUp

Struct MICRA_POPUP (

	_msg = "",
	_text_box,
	_drag_pos = [0,0,0], --form mouse pos
	/**
	* @example 
		typed_text = mcPopup.textBox()
		format "typed_text:%\n" typed_text
	*/
	fn defNWin = (
		local nw = DotNetObject "NativeWindow"
		nw.AssignHandle (DotNetObject "System.IntPtr" (Windows.GetMaxHWND())) 
		return nw
	),
	fn textBox msg:"Type a text here:" = (
	
		--if (_text_box != undefined and _text_box.visible) do _text_box.close()
		local netDMove = false 
		
		
		
		local	lblMsg = dotNetObject "label"
				lblMsg.bounds = netDrRect [4,4] [312, 18]
		local	edtBox = dotNetObject "textbox"
				edtBox.bounds = netDrRect [4,26] [312, 24]
		local typed_text = ""
		
		/*fn correctSymbolCheck text =	(
		
			if text.count == 0 do return false
			local badSymbols = "[]()\/*?"
			for t=1 to text.count do
			(
				for s=1 to badSymbols.count do
				(
					if text[t] == badSymbols[s] do 
					(
						messagebox "Incorrect Name.\nSymbols []()\/*?* are not allowed." title:Micra.version
						return false
					)
				)
			)
			return true
		)*/
		/*fn textBoxControll a s  = ( --#KeyPress
		
			if  (bit.charAsInt s.KeyChar) == 27 then --escape pressed
			(
				typed_text = ""
				DestroyDialog _text_box
			)
			else if (bit.charAsInt s.KeyChar) == 13 then  --enter pressed
			( 
				typed_text = edtBox.text
				--prevent to type some invalid characters [/\*?]
				if correctSymbolCheck typed_text then DestroyDialog _text_box else setFocus edtBox
			)
		)*/
		--Move / Snap Dialog
		fn onLblTMouseMove s a = ( --dragForm
		
			if a.Button == a.Button.left do mcFormSnap mcPopUp._text_box mcPopUp._drag_pos
		)
		fn onLblTMouseDown s a = (
				
			mcPopUp._text_box.cursor.current = netCursors.Hand
			if a.Button == a.Button.left do ( --enable drag
				mcPopUp._drag_pos = [mcPopUp._text_box.MousePosition.x, mcPopUp._text_box.MousePosition.y] - [mcPopUp._text_box.left, mcPopUp._text_box.top] 
				--netDMove = true 
			)
		)
		fn onLblTMouseUp s a = ( 
		
			--netDMove = false --disable drag
			if a.Button == a.Button.right then mcPopUp._text_box.hide()
		)
		fn onOpenForm s a = (
		
			/*lblMsg.BackColor = netDrColor (mcUIColors.get #back)
			lblMsg.ForeColor = netDrColor (mcUIColors.get #text)
			lblMsg.TextAlign = lblMsg.TextAlign.MiddleCenter
			lblMsg.text = _msg
			local dnfontlarge = dotNetObject "System.Drawing.Font" "Verdana" 12 ((dotNetClass "System.Drawing.FontStyle").bold)
			edtBox.font = dnfontlarge
			edtBox.BackColor= netDrColor (mcUIColors.get #edtback)
			edtBox.ForeColor= netDrColor (mcUIColors.get #edtfore)
			edtBox.AcceptsTab = true
			edtBox.Multiline = true
			edtBox.focus()*/
		)
		
		
		--on edtBox keyPress a s do (textBoxControll a s) -- method:#KeyPress
		--on edtBox keyUp    a s do (textBoxControll a s method:#KeyUp)
		
		local form_size = [320, 52]
		local border_offset  = 2
		local btn_size       = 24
		local bar_height     = 14
		local max_center_pos = mcSystem.getMaxCenter()
		max_center_pos.x -= form_size.x / 2
		local form = dotNetObject "MaxCustomControls.Maxform"
		form.ControlBox  = false --hide main bar
		form.StartPosition = form.StartPosition.Manual
		form.bounds = netDrRect max_center_pos form_size
		form.BackColor = netDrColor (mcUIColors.get #fore)
		form.ShowInTaskbar = false
		form.FormBorderStyle = form.FormBorderStyle.none
		form.opacity = 1--(mcUIColors.get #opacity)
		--form.TopMost=true
		
		--toolbar
		local lblT = dotNetObject "label"
		lblT.bounds = netDrRect [border_offset, border_offset] [form_size.x - border_offset*10 , bar_height]
		lblT.BackColor = netDrColor (mcUIColors.get #back)
		lblT.ForeColor = netDrColor (mcUIColors.get #text)
		lblT.TextAlign = lblT.TextAlign.MiddleCenter
		lblT.Text = msg
		
		--Componnts Layout
		--tlp.Bounds  = netDrRect [border_offset, bar_height + border_offset * 2] [form_size.x - 20, form_size.y - 36]
		--tlp.backColor = netDrColor(mcUIColors.get #btn)
	
		dotNet.addEventHandler lblT   "MouseMove" onLblTMouseMove
		dotNet.addEventHandler lblT   "MouseDown" onLblTMouseDown 
		dotNet.addEventHandler lblT   "MouseUp" onLblTMouseUp
		
		form.controls.addRange ( #(lblT)  )
		
		local nw = defNWin()
		form.show(nw) 
		nw.ReleaseHandle()
		_text_box = form
		--CreateDialog _text_box pos:max_center_pos style:#(#style_border) modal:true --escapeEnable:true crashing!!!
		--return _text_box.typed_text
		return "finished"
	)
)
mcPopUp = MICRA_POPUP()