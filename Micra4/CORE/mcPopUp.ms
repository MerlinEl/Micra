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
	_form_name = "MaxCenter",
	_btn_size   = 24,
	_border_offset  = 2,
	_bar_height     = 14,
	fn defNWin = (
		local nw = DotNetObject "NativeWindow"
		nw.AssignHandle (DotNetObject "System.IntPtr" (Windows.GetMaxHWND())) 
		return nw
	),
	fn closeForm form = (
		
		form.close()
		if _form_name != "MaxCenter" do mcFile.saveIniDialog _form_name "Properties_2" 
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
		typed_text = mcPopup.textBox title:"New Profile Name:" saved_pos:"Micra_TextBox"
		format "typed_text:%\n" typed_text
	@info this code can't be executed by enter (he would close immediately). For call, use  menu, buttons, etc...
	*/
	fn textBox title:"Type a text here:" form_name:"MaxCenter" = ( --if form_name is not "MaxCenter" save - load  pos at defined Name
	
		local form = dotNetObject "MaxCustomControls.Maxform"
		local lblT = dotNetObject "label"
		local edtBox = dotNetObject "textbox"
		
		local border_offset = mcPopUp._border_offset
		local bar_height = mcPopUp._bar_height
		local btn_size = mcPopUp._btn_size
		
		local form_size = [320, 60]
		_form_name = form_name
		local max_center = mcSystem.getMaxCenter() - (form_size/2)
		local form_rect = netDrRect max_center form_size
		--load pos from ini
		if form_name != "MaxCenter" then (
			
			local fpos = (mcFile.getIniDataFromArray Micra.TempProfileIni "Properties_2" form_name 2)
			if fpos == undefined do fpos = (mcFile.getIniDataFromArray Micra.DefaultProfileIni "Properties_2" form_name 2)
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
		fn onLblTMouseMove s a = ( if a.Button == a.Button.left do mcDialog.snapForm s.parent mcPopUp._drag_pos ) --dragForm
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
		--form.BackColor = netDrColor (mcUIColors.get #fore)
		form.ShowInTaskbar = false
		form.FormBorderStyle = form.FormBorderStyle.none
		form.opacity = 1--(mcUIColors.get #opacity)
		--form.TopMost=true
		
		--toolbar
		lblT.bounds = netDrRect [border_offset, border_offset] [form.width - border_offset*10 , bar_height]
		lblT.BackColor = netDrColor (mcUIColors.get #back)
		lblT.ForeColor = netDrColor (mcUIColors.get #text)
		lblT.TextAlign = lblT.TextAlign.MiddleCenter
		lblT.Text = title
		
		edtBox.bounds = netDrRect [ border_offset ,bar_height+border_offset*2] [300, 22]
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
	),
	/**
	* @example 
		mcPopUp.msgBox "Ahoj" duration:1.5 
	* @info if duration is set, window will apear in compact mode
	*/
	fn msgBox msg title:"Micra:" duration:undefined pos:undefined = (
	 	
		local form = dotNetObject "MaxCustomControls.Maxform"
		local lblT = dotNetObject "label"
		local edtBox = dotNetObject "textBox"
		local btnOk = dotNetObject "button"
		
		local border_offset = mcPopUp._border_offset
		local bar_height = mcPopUp._bar_height
		local btn_size = mcPopUp._btn_size
	
		local text_box_size = [400, 200]
		local form_size = [
			text_box_size.x + border_offset * 2 + 16 , -- +16 why?, I dont know
			text_box_size.y + bar_height + btn_size + border_offset * 4 + 14 \ -- +14 why?, I dont know 
		]
		
		/*local form_width = amax #(text_box_size.x , 420) --220 is minimum width
		local form_height = amax #(bar_height + text_box_size.y + btn_size + border_offset * 3 , 220) --220 is minimum height
		form_width = amin #(form_width, 400) --400 is maximum width
		form_height = amin #(form_height, 600) --400 is maximum height
		--if duration == undefined then  ok button
		local form_size = [form_width, form_height]*/
		
		local max_center = mcSystem.getMaxCenter() - (form_size/2)
		local form_rect = if pos == undefined  then netDrRect max_center form_size else netDrRect pos form_size
			
		--Move / Snap Dialog
		fn onLblTMouseMove s a = ( if a.Button == a.Button.left do mcDialog.snapForm s.parent mcPopUp._drag_pos ) --dragForm
		fn onLblTMouseDown s a = (
				
			local form = s.parent
			form.cursor.current = netCursors.Hand
			if a.Button == a.Button.left do ( --enable drag
				mcPopUp._drag_pos = [form.MousePosition.x, form.MousePosition.y] - [form.left, form.top] 
			)
		)
		--RC close form
		fn onLblTMouseUp s a = ( if a.Button == a.Button.right then mcPopUp.closeForm s.parent ) --drop form
		fn onOkMouseUp s a = (s.parent.close())
		
		form.ControlBox  = false --hide main bar
		form.ShowInTaskbar = false
		form.StartPosition = form.StartPosition.Manual
		form.bounds = form_rect
		form.FormBorderStyle = form.FormBorderStyle.none
		form.BackColor = netDrColor (mcUIColors.get #fore)
		form.opacity = 1--(mcUIColors.get #opacity)
			
		--toolbar
		lblT.bounds = netDrRect [border_offset, border_offset] [form.width - border_offset * 2, bar_height]
		lblT.BackColor = netDrColor (mcUIColors.get #back)
		lblT.ForeColor = netDrColor (mcUIColors.get #text)
		lblT.TextAlign = lblT.TextAlign.MiddleCenter
		lblT.Text = title
		
		edtBox.bounds = netDrRect [ border_offset ,bar_height+border_offset*2] text_box_size
		edtBox.Multiline = true	
		--edtBox.enabled = false	
		edtBox.BackColor= netDrColor (mcUIColors.get #edtback)
		edtBox.ForeColor= netDrColor (mcUIColors.get #edtfore)
		--edtBox.TextAlign = edtBox.TextAlign.MiddleCenter	
		local dnfontlarge = dotNetObject "System.Drawing.Font" "Verdana" 12 ((dotNetClass "System.Drawing.FontStyle").bold)
		edtBox.font = dnfontlarge
		edtBox.text = msg
		
		btnOk.bounds = netDrRect [ form.width/2 - 50 ,bar_height+border_offset*2 + edtBox.height] [100, btn_size]
		btnOk.BackColor= netDrColor (mcUIColors.get #back)
		btnOk.ForeColor= netDrColor (mcUIColors.get #text)
		btnOk.text = "OK"
		
		dotNet.addEventHandler lblT   "MouseMove" onLblTMouseMove
		dotNet.addEventHandler lblT   "MouseDown" onLblTMouseDown 
		dotNet.addEventHandler lblT   "MouseUp" onLblTMouseUp
		dotNet.addEventHandler btnOk  "MouseUp" onOkMouseUp
		
		form.controls.addRange ( #(lblT, edtBox, btnOk)  )
		mcDotnet.dShow form saved_pos:false
	)
)
mcPopUp = MICRA_POPUP()


/*
	--TODO Remake it in Dotnet
	-- Created by Merlin el' 9.4.2006 12:59:28 
	-- mcCall.popUp "Ahoj" 1.5 
	fn msgBox str tim dPos:undefined = (
	 	if mcPopUpDialog != undefined then destroyDialog mcPopUpDialog

		Global popStr  = str
		Global popTime = tim
		Global txtSize = gw.getTextExtent popStr
		
		rollout mcPopUpDialog "" width:80 height:44
		(
		 	-->Local
			Local sec = 500
			Local elapsedTime = 0 
			GroupBox grp_1 "" pos:[6,2] width:(txtSize.x+20) height:36
			label lbl_1 "" pos:[16,16] width:(txtSize.x) height:16
			timer popTick "" pos:[12,12] width:24 height:24 interval:sec active:true
		 	on mcPopUpDialog rbuttonup pos do destroyDialog mcPopUpDialog
			on mcPopUpDialog lbuttonup pos do destroyDialog mcPopUpDialog
			on mcPopUpDialog open do 
		 	(  
				mcPopUpDialog.width  = (txtSize.x+32)
				mcPopUpDialog.height = (txtSize.y+32)
				lbl_1.text = popStr
			)
		 	on mcPopUpDialog close do 
		 	( 
		 	 	popStr  = undefined
				popTime = undefined
				txtSize = undefined
			)
		 	on popTick tick  do
		 	(
				elapsedTime += 0.5
				if elapsedTime >= popTime do destroyDialog mcPopUpDialog
		 	)
		)
		if classof dPos == Point2
		then CreateDialog mcPopUpDialog pos:dPos style:#(#style_border)
		else CreateDialog mcPopUpDialog style:#(#style_border)
	),
	fn teleportText title:"" =
	(
		if mcTeleportTextDialog != undefined then destroyDialog mcTeleportTextDialog
		rollout mcTeleportTextDialog title width:444 height:40
		(
			local apply = false
			edittext edtBox "12345678910" pos:[12,12] width:312 height:16 bold:true
		 	button btnAcpt "Accept" pos:[332,12] width:48 height:16
		 	button btnCncl "Cancel" pos:[384,12] width:48 height:16
		 	groupBox gr_1 "" pos:[4,0] width:436 height:36
			on mcTeleportTextDialog open    do 
			(
				edtBox.caption = mcTeleportTextDialog.title + ":"
				setFocus edtBox
			)
			on btnAcpt pressed           do 
			(
				if edtBox.text.count > 0 do
				( 
					DestroyDialog mcTeleportTextDialog
					apply = true 
				)
			)
			on btnCncl pressed           do (DestroyDialog mcTeleportTextDialog)
			on edtBox entered text       do (btnAcpt.pressed())
		)
		CreateDialog mcTeleportTextDialog style:#(#style_border) modal:true
		
		return #(mcTeleportTextDialog.apply, mcTeleportTextDialog.edtBox.text)
	),
	fn progeressbar val close:false color:(color 255 200 18) =
	(
		if mcProgressBarDialog == undefined do
		(
			rollout mcProgressBarDialog " Inicialize 3DGallery Database:" width:332 height:132
			(
				GroupBox grp_info "Progress...0%" pos:[8,4] width:316 height:120
				bitmap bmpPop1 "Bitmap" pos:[16,20] width:300 height:80 fileName:(Micra.RootDir+"Img\\3DGall_Loader_01.bmp")
				progressBar pBar "ProgressBar" pos:[16,104] width:300 height:13
				button btn_close "*" pos:[312,4] width:12 height:12
				on btn_close pressed do destroyDialog mcProgressBarDialog
			)
			createDialog mcProgressBarDialog style:#(#style_border) --modal:true
			mcProgressBarDialog.pBar.color = color
		)
		if not mcProgressBarDialog.isDisplayed then
		(
			createDialog mcProgressBarDialog style:#(#style_border) --modal:true
			mcProgressBarDialog.pBar.color = color
		)
		mcProgressBarDialog.pBar.value    = val
		mcProgressBarDialog.grp_info.text = "Progress..."+ ((val as integer) as string) + "%"
		if close do (sleep 0.3; destroyDialog mcProgressBarDialog)
	),
*/