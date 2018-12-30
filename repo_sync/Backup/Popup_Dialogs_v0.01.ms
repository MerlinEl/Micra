----------------------------------------------------------------------------
--xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx--

                           -- Pop Up Dialogs --
							 
--xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx--
----------------------------------------------------------------------------
Global mcPopUp

Struct MICRA_POPUP (

	_msg = "",
	_text_box,
	/**
	* @example 
		typed_text = mcPopup.textBox()
		format "typed_text:%\n" typed_text
	*/
	fn textBox msg:"Type a text here:" = (
	
		if (_text_box != undefined and _text_box.isDisplayed) do DestroyDialog _text_box
		_msg = msg
		rollout _text_box " Command Box v0.1" width:320 height:52
		(
			-->locals
			local typed_text = ""
			dotNetControl lblMsg "label" pos:[4,4] width:312 height:18
			dotNetControl edtBox "textbox" pos:[4,26] width:312 height:24
			fn correctSymbolCheck text =
			(
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
			)
			fn textBoxControll a s  = --#KeyPress
			(
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
			)
			on _text_box open do (
				
				lblMsg.BackColor = netDrColor (mcUIColors.get #back)
				lblMsg.ForeColor = netDrColor (mcUIColors.get #text)
				lblMsg.TextAlign = lblMsg.TextAlign.MiddleCenter
				lblMsg.text = _msg
				local dnfontlarge = dotNetObject "System.Drawing.Font" "Verdana" 12 ((dotNetClass "System.Drawing.FontStyle").bold)
				edtBox.font = dnfontlarge
				edtBox.BackColor= netDrColor (mcUIColors.get #edtback)
				edtBox.ForeColor= netDrColor (mcUIColors.get #edtfore)
				edtBox.AcceptsTab = true
				edtBox.Multiline = true
				edtBox.focus()
			)
			on edtBox keyPress a s do (textBoxControll a s) -- method:#KeyPress
  			--on edtBox keyUp    a s do (textBoxControll a s method:#KeyUp)
		)
		/*local under_mouse_pos = Mouse.screenPos
		under_mouse_pos.x -= _text_box.width / 2
		under_mouse_pos.y -= _text_box.height*/
		
		local max_center_pos = mcSystem.getMaxCenter()
		max_center_pos.x -= _text_box.width / 2
		CreateDialog _text_box pos:max_center_pos style:#(#style_border) modal:true --escapeEnable:true crashing!!!
		return _text_box.typed_text
	)
)
mcPopUp = MICRA_POPUP()