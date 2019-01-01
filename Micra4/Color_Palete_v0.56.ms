-->Color Palete
Global mcColorPickerDialog
Global mcColorPaleteDialog
--Dialog:--------------------------------------------------------------------
try ( mcColorPaleteDialog.close() ) catch()
-----------------------------------------------------------------------------
(
	-->Locals-----------------------------------------------------------------
	local netDMove = false, netDmPos
	local last_profile = execute (mcFile.saveLoadIniSetings head:"Interface" key:"lastprofile" action:#load)
	local profiles = #("DefaultColor", "UserColor", "ForestColor", "EarthColor", "MoonColor", "SeaColor", "SunColor", "Close")
	local head_str = profiles[last_profile]
	local clr_back     = execute (mcFile.saveLoadIniSetings head:head_str key:"backcolor" action:#load)
	local clr_fore     = execute (mcFile.saveLoadIniSetings head:head_str key:"forecolor" action:#load)
	local clr_sel      = execute (mcFile.saveLoadIniSetings head:head_str key:"selected"  action:#load)
	local clr_mark     = execute (mcFile.saveLoadIniSetings head:head_str key:"marked"  action:#load)
	local clr_btn      = execute (mcFile.saveLoadIniSetings head:head_str key:"button"   action:#load)
	local clr_inact    = execute (mcFile.saveLoadIniSetings head:head_str key:"inactive"  action:#load)
	local clr_text     = execute (mcFile.saveLoadIniSetings head:head_str key:"textcolor"  action:#load)
	local clr_seltext  = execute (mcFile.saveLoadIniSetings head:head_str key:"seltext"  action:#load)
	local form_opacity = execute (mcFile.saveLoadIniSetings head:head_str key:"opacity"  action:#load)
	local bar_height      = 14
	local form_bounds     = 2
	local form_offset     = 4
	local btn_size        = 24
	local cp_width        = 48
	local count_limit     = 40
	local columns_rows    = [10, 4]
	local debug = 0

	-->Components---------------------------------------------------------------------
	mcColorPaleteDialog = dotNetObject "Form" 
	struct MICRA_COMPONENTS_STRUCT
	(
		tlp = dotNetObject "TableLayoutPanel",
		ToolTip       = dotNetObject "ToolTip",
		tooltip_duration = 8,
		buttons = #(),
		picked_color = netDrColor gray,
		last_button
	)
	
	mcColorPaleteDialog.tag = dotNetMXSValue (MICRA_COMPONENTS_STRUCT()) --manual Lifetime
	
	fn removeBorder mcs s = --remove highlight
	(
		if mcs.last_button == s do return false
		mcs.last_button.FlatAppearance.BorderColor = netDrColor clr_back
		mcs.last_button = s
	)
	
	fn setButtonColor net_clr = (
		
		local last_button = mcColorPaleteDialog.tag.value.last_button
		--format "Color Palete > setButtonColor > clr:% on button:%\n" net_clr last_button.tag	
		last_button.backColor = net_clr
		local rgb_clr = netColorToRGB net_clr
		setIniSetting Micra.UserSettings "ColorPalete" last_button.tag (rgb_clr as string)
		--format "saved color done:%\n" rgb_clr
	)
	fn changeObjectsWire net_clr = (
		
		if selection.count != 0 do selection.wirecolor = netColorToRGB net_clr 
	)
	fn onMouseDown s a = --show highlight
	(
		mcGM.setParam "color_picker_start_color" s.backColor
		local mcs = s.parent.parent.tag.value
		if a.Clicks > 1  then (
			
			removeBorder mcs s
			mcEvents.registerEvent "Color_Picker_Add_Color" setButtonColor
			mcEvents.registerEvent "Color_Picker_Mod_Color" changeObjectsWire
			Micra.fileInVersion "Color_Picker"
			--if not mcColorPickerDialog.visible() do mcColorPickerDialog.init()
			
		) else (
			
			if mcs.last_button == s or keyboard.controlPressed or keyboard.altPressed or a.button == a.button.right do return false
			s.FlatAppearance.BorderColor = netDrColor clr_seltext
		)
	)

	/*on lv DoubleClick  s a do (
		
		
	)*/
	fn onMouseUp s a = 
	(
		local mcs = s.parent.parent.tag.value
		case a.button of
		(
			(a.button.middle)  : 
			(
				
			)
			(a.button.left )  : 
			(
				local clr = netColorToRGB s.backColor

				if keyboard.shiftPressed then
				(
					mcs.picked_color = s.backColor 
					removeBorder mcs s
				)
				else if keyboard.controlPressed then
				(
					--set button color
					if selection.count != 0 
					then s.backcolor = netDrColor selection[1].wirecolor
					else s.backcolor = mcs.picked_color
					--save to ini
					clr = netColorToRGB s.backColor
					setIniSetting Micra.UserSettings "ColorPalete" s.tag (clr as string)
				)
				else if keyboard.altPressed then (
					
					s.backcolor = netDrColor gray
					setIniSetting Micra.UserSettings "ColorPalete" s.tag (gray as string)
					
				) else ( --apply color to selected objects. Also if color picker is open send him color too
					
					if selection.count != 0 do undo "Set Color" on (selection.wirecolor = clr)
					if mcColorPickerDialog != undefined and mcColorPickerDialog.visible() do mcColorPickerDialog.setBackColor s.backColor
					removeBorder mcs s
				)
			)
			(a.button.right) : (s.parent.parent.hide())
		)
	)
	fn onMouseDoubleClick s a =
	(
		print "dd"
		if mcColorPickerDialog != undefined and mcColorPickerDialog.isDisplayed do
		(
			mcColorPickerDialog.newColorBt.backColor = s.backColor
		)
	)
	fn updateColors s a =
	(
		local mcs = s.tag.value
		local clr
		for i in mcs.buttons
		where (
			clr = execute (getIniSetting Micra.UserSettings "ColorPalete" i.tag) 
			classOf clr == color
		) do i.backColor = netDrColor clr
		
		pushprompt ":Apply Color = LMB :Edit = RMB :Copy = Shift+LMB :Paste = Ctrl+LMB :Remove = Alt+LMB :Close = MMB."
	)
	--generate colored buttons
	fn addButtons mcs form cr = 
	(
		local buttons_count = cr.x*cr.y
		for i = 1 to buttons_count do
		(
			btn = dotnetObject "button"
			btn.size  = netDrSize [btn_size, bar_height]
			btn.FlatStyle = btn.FlatStyle.flat
			btn.FlatAppearance.BorderColor = netDrColor clr_back
			btn.FlatAppearance.BorderSize = 1
			btn.margin =  dotnetobject "padding" 0
			btn.name = "btn_" + (i as integer) as string
			btn.tag = (i as integer) as string
			btn.backColor = netDrColor gray
			local	msg   = "Add	(Ctrl+LMB)\n"
						msg += "Del	(Alt+LMB)\n"
						msg += "Edit	(Double Click)\n"
						msg += "Copy	(Shift+LMB)\n"
						msg += "Paste	(Ctrl+LMB)\n"
						msg += "Close	(RMB)\n"
			mcs.ToolTip.SetToolTip btn msg
			dotNet.addEventHandler btn "MouseUp" onMouseUp
			dotNet.addEventHandler btn "MouseDown" onMouseDown
			dotNet.addEventHandler btn "DoubleClick" onMouseDoubleClick
			mcs.buttons += #(btn)
		)
		mcs.tlp.controls.addRange ( mcs.buttons )
		
		mcs.last_button = mcs.buttons[1]
		mcs.last_button.FlatAppearance.BorderColor = netDrColor clr_seltext
	)

	fn onClosing s a = --onClosed
	(
		print "form exited"
	)
	fn onVisibleChanged s a = 
	(
		if s.Visible 
		then (updateColors s a)
		else (
			pushprompt ""
			mcEvents.unregisterEventSet "Color_Picker_Add_Color" --remove event add color to palete
			mcEvents.unregisterEventSet "Color_Picker_Mod_Color" --remove event mod color to selection
		)
	)
	fn inicializeInterface form mcs =
	(
		form.name = "mcColorPaleteDialog"
		form.ControlBox  = false --hide main bar
		form.FormBorderStyle = form.FormBorderStyle.none
		form.ShowInTaskbar = false
		form.BackColor = netDrColor clr_fore
		local form_size  =[btn_size*columns_rows.x + form_offset, bar_height*columns_rows.y + form_offset]
		local fpos = 
		(
			if classOf mcMicraDialog == dotnetObject then (
				
				local s = mcMicraDialog.tag.value.cp_wirePicker
				local screen_pos = s.PointToScreen (dotnetclass "System.Drawing.Point").Empty
				local win_size = getMaxWindowSize()
				if screen_pos.x > win_size.x / 2 then ( --if Micra is in right Border
						
					screen_pos.x -= form_size.x - btn_size - 2
				)
				[screen_pos.x, screen_pos.y]
			)
			else (mcFile.getIniDataFromArray Micra.TempProfileIni "Properties_2" "mcColorPaleteDialog" 2)
		)
		form.StartPosition = form.StartPosition.Manual
		form.MinimumSize = netDrSize [btn_size, bar_height]
		form.MaximumSize = netDrSize [btn_size*count_limit, bar_height*count_limit]
		form.bounds = netDrRect fpos form_size
		--form.opacity = 0.8
		
		mcs.ToolTip.IsBalloon = true
		mcs.ToolTip.BackColor = netDrColor clr_back
		mcs.ToolTip.ForeColor = netDrColor clr_text
		mcs.ToolTip.AutoPopDelay = 10000 --duration
		mcs.ToolTip.InitialDelay = 800
		mcs.ToolTip.ReshowDelay = 1000
		mcs.ToolTip.ShowAlways = true

		--mcs.tlp.bounds = form.bounds
		--mcs.tlp.location = netDrPoint [2, 2]
		--mcs.tlp.margin =  dotnetobject "padding" 2
		mcs.tlp.padding = dotnetobject "padding" 2
		mcs.tlp.backColor = netDrColor clr_fore --clr_btn
		mcs.tlp.AutoSize = true
		mcs.tlp.AutoSizeMode = mcs.tlp.AutoSizeMode.GrowAndShrink
		mcs.tlp.ColumnCount = columns_rows.x
		mcs.tlp.RowCount = columns_rows.y
		
		addButtons mcs form columns_rows
		updateColors form undefined
		form.controls.add (mcs.tlp)
		--dotNet.addEventHandler form "Closing" onClosing
		dotNet.addEventHandler form "VisibleChanged" onVisibleChanged
	)
	inicializeInterface mcColorPaleteDialog mcColorPaleteDialog.tag.value
	mcDotnet.dShow mcColorPaleteDialog saved_pos:false
)