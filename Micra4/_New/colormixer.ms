-------------------------------------------------------------------------------------
-- Color Mixer
--
-- File: colorMixer.ms
-- Author: Vojtech Cada
-- e-mail: vojta@krypton.cz
--
-- Created on: 07/2011
-- Last Updated: 03/2019
-- Version: 0.06
--
-- Compatibility: Max 9+/VIZ 2008+
-- Required Extensions: for Max 9/VIZ 2008 AVGuard is needed
--
-- Description: Allows mixing two colors with user defined amount and number of steps
-------------------------------------------------------------------------------------

try destroyDialog ::colorMixer catch()
rollout colorMixer "Color Mixer v0.06" width:500 height:24
(
	---------------------------------------------------------------------------------
	-- Layout Section
	---------------------------------------------------------------------------------

	spinner spnPrecisonVal "Count:" pos:[33,4] width:50 height:16 range:[3,200,10] type:#integer
	colorPicker cpColor1 "" pos:[86,5] width:17 height:14 color:[0,150,25]
	dotNetControl dncPanel "Panel" pos:[108,4] width:(colorMixer.width - 269) height:14
	dotNetControl dncTriBtn1 "Button" pos:[dncPanel.pos.x + dncPanel.width/2 - 3,-1]
	dotNetControl dncTriBtn2 "Button" pos:[dncTriBtn1.pos.x,18]
	colorPicker cpColor2 "" pos:[colorMixer.width - 159,5] width:17 height:14 color:[255,255,0]
	progressBar pbFrame pos:[colorMixer.width - 133,3] width:28 height:17 enabled:off
	colorPicker cpResult "" pos:(pbFrame.pos - [3,-2]) width:30 height:14
	spinner spnPercent "" pos:[colorMixer.width - 88,4] width:48 height:16 range:[0.,100.,50.]
	label lblPercent "%" pos:[colorMixer.width - 49,6] visible:off
	button btnRgbHsv "RGB" pos:[colorMixer.width - 32,4] width:28 height:16

	---------------------------------------------------------------------------------
	-- Private Globals
	---------------------------------------------------------------------------------

	local dn_color = dotNetClass "System.Drawing.Color"
	local dn_buttons_class = dotNetClass "MouseButtons"
	local dn_button_class = dotNetClass "Button"
	local dn_point = dotNetClass "System.Drawing.Point"
	local dn_cursor = dotNetClass "Cursor"
	local dn_cursors = dotNetClass "Cursors"
	local dn_dock = dotNetClass "DockStyle"
	local dn_flat_style = (dotNetClass "FlatStyle").Flat
	local dn_size = dotNetClass "System.Drawing.Size"
	local dn_garbage = dotNetClass "System.GC"

	fn isGammaActive =
		if isProperty IDisplayGamma #gamma then
			IDisplayGamma.colorCorrectionMode == #gamma AND IDisplayGamma.affectColorPickers
		else getIniSetting (getMaxIniFile()) "Gamma" "Enable" as integer > 0 AND
			getIniSetting (getMaxIniFile()) "Gamma" "CorrectColorPickerState" as integer > 0

	local click_start_pos = [0,0,0]
	local slider_start_pos
	local slider_pos = [165,4]
	local mouse_is_down = false
	local btn_controls = #()
	local ini_file = (dotNetClass "Application").LocalUserAppDataPath + "\\colorMixer.ini"
	local gamma = if isGammaActive() then 1d0/displayGamma else 1d0
	local mode = #rgb

	---------------------------------------------------------------------------------
	-- Structs
	---------------------------------------------------------------------------------

	struct colorRange
	(
		clr1 = colorMixer.gammaCorrect cpColor1.color gamma,
		clr2 = colorMixer.gammaCorrect cpColor2.color gamma,
		clr_diff = case mode of
		(
			#rgb : clr1 - clr2
			#hsv : colorMixer.getHsvDiff clr1 clr2
		);,

		tile_count = spnPrecisonVal.value,
		clr_step = 1.0 / (tile_count + 1),
		curr_step = 0.0,

		fn getSizeFix size =
			(tile_count as double) / (dncPanel.width - size * tile_count),

		fn next =
			clr_diff * (curr_step += clr_step)
	)

	---------------------------------------------------------------------------------
	-- Right-click Menu
	---------------------------------------------------------------------------------

	local colorMenu = rcMenu colorMenu
	(
		local clr

		menuItem miCopyRGB "Copy to Clipboard as RGB"
		menuItem miCopyRGBGamma "Copy to Clipboard as RGB with gamma"
		separator sepVoid1
		menuItem miCopyCMYK "Copy to Clipboard as CMYK"
		menuItem miCopyCMYKGamma "Copy to Clipboard as CMYK with gamma"
		separator sepVoid2
		menuItem miCopyHEX "Copy to Clipboard as HEX"
		menuItem miCopyHEXGamma "Copy to Clipboard as HEX with gamma"
		separator sepVoid3
		menuItem miCopyOLE "Copy to Clipboard as OLE"
		menuItem miCopyOLEGamma "Copy to Clipboard as OLE with gamma"
		separator sepVoid4
		menuItem miCopyHSB "Copy to Clipboard as HSB"
		menuItem miCopyHSBGamma "Copy to Clipboard as HSB with gamma"

		fn show ctrlClr =
		(
			popupMenu colorMenu
			clr = ctrlClr
		)

		fn convertColor2HEX clr =
			"#" + bit.intAsHex clr.r + bit.intAsHex clr.g + bit.intAsHex clr.b

		fn convertColor2OLE clr =
			int(clr.b * 65536 + clr.g * 256 + clr.r)

		fn convertColor2HSB clr =
			[clr.h/255.*360, clr.s/2.55, clr.v/2.55]

		fn convertColor2CMYK clr =
		(
			local maxClr = amax clr.r clr.g clr.b
			local c = (maxClr - clr.r) / maxClr
			local m = (maxClr - clr.g) / maxClr
			local y = (maxClr - clr.b) / maxClr
			[c, m, y, 1 - maxClr / 255.] * 100
		)

		on miCopyRGB picked do
			setClipboardText (((colorMixer.maxColor clr) as point3) as string)

		on miCopyRGBGamma picked do
			setClipboardText (((colorMixer.gammaCorrect (colorMixer.maxColor clr) (1/gamma)) as point3) as string)

		on miCopyCMYK picked do
			setClipboardText ((convertColor2CMYK (colorMixer.maxColor clr)) as string)

		on miCopyCMYKGamma picked do
			setClipboardText ((convertColor2CMYK (colorMixer.gammaCorrect (colorMixer.maxColor clr) (1/gamma))) as string)

		on miCopyHEX picked do
			setClipboardText (convertColor2HEX (colorMixer.maxColor clr))

		on miCopyHEXGamma picked do
			setClipboardText (convertColor2HEX (colorMixer.gammaCorrect (colorMixer.maxColor clr) (1/gamma)))

		on miCopyOLE picked do
			setClipboardText ((convertColor2OLE (colorMixer.maxColor clr)) as string)

		on miCopyOLEGamma picked do
			setClipboardText ((convertColor2OLE (colorMixer.gammaCorrect (colorMixer.maxColor clr) (1/gamma))) as string)

		on miCopyHSB picked do
			setClipboardText ((convertColor2HSB (colorMixer.maxColor clr)) as string)

		on miCopyHSBGamma picked do
			setClipboardText ((convertColor2HSB (colorMixer.gammaCorrect (colorMixer.maxColor clr) (1/gamma))) as string)
	)

	---------------------------------------------------------------------------------
	-- Functions
	---------------------------------------------------------------------------------

	fn convertHsv2rgb hsv =
	(
		local rgb = red
		rgb.v = hsv[3]
		rgb.s = hsv[2]
		rgb.h = hsv[1]
		rgb
	)

	fn convertFloat2dnColor float_color =
	(
		float_color *= 255
		dn_color.FromARGB float_color[1] float_color[2] float_color[3]
	)

	fn gammaCorrect clr gamma =
	(
		clr /= 255.
		255 * [clr.r^gamma, clr.g^gamma, clr.b^gamma] as color
	)

	fn maxColor dn_clr =
		color dn_clr.R dn_clr.G dn_clr.B

	fn getHsvDiff clr1 clr2 =
		[clr1.h - clr2.h, clr1.s - clr2.s, clr1.v - clr2.v]

	fn getStepColor clr clr_step mode =
		case mode of
		(
			#rgb : clr + clr_step
			#hsv : convertHsv2rgb [clr.h + clr_step[1], clr.s + clr_step[2], clr.v + clr_step[3]] mode:255
		)

	fn onBtnMouseUp ctrl evnt =
		if evnt.Button == dn_buttons_class.Left then
		(
			cpResult.color = gammaCorrect (maxColor ctrl.BackColor) (1/gamma)
			dncTriBtn1.pos.x = dncTriBtn2.pos.x = (dncPanel.pos.x + ctrl.Location.x + ctrl.width/2 - 3)
			spnPercent.value = 100./(btn_controls.count + 1) * (btn_controls.count + 1 - findItem btn_controls ctrl)
		)
		else if evnt.Button == dn_buttons_class.Right do colorMenu.show ctrl.BackColor

	fn getColorAtPos pos &ctrl: =
		if (local curr_ctrl = dncPanel.GetChildAtPoint (dotNetObject dn_point pos 0)) != undefined do
		(
			if ctrl != unsupplied do ctrl = curr_ctrl
			gammaCorrect (maxColor curr_ctrl.BackColor) (1/gamma)
		)

	mapped fn disposeBtns btn =
		btn.Dispose()

	fn collectButtons range =
	(
		local ctrl_size = int(dncPanel.width / range.tile_count)
		local size_fix_step = range.getSizeFix ctrl_size
		local size_fix_next = size_fix_step
		local size_base = dotNetObject dn_size ctrl_size dncPanel.height
		local size_base_ext = dotNetObject dn_size (ctrl_size + 1) dncPanel.height

		for btn_index = 1 to range.tile_count collect
		(
			local curr_clr = getStepColor range.clr2 (range.next()) mode
			local dn_button = dotNetObject dn_button_class
				dn_button.BackColor = dn_color.FromARGB curr_clr.r curr_clr.g curr_clr.b
				dn_button.FlatAppearance.BorderSize = 0

			dotNet.addEventHandler dn_button "MouseUp" onBtnMouseUp

			if btn_index == int(size_fix_next) then
			(
				dn_button.Size = size_base_ext
				size_fix_next += size_fix_step
			)
			else dn_button.Size = size_base

			dn_button
		)
	)
	
	fn recolorButtons range = for ctrl in btn_controls do
	(
		local curr_clr = getStepColor range.clr2 (range.next()) mode
		ctrl.BackColor = dn_color.FromARGB curr_clr.r curr_clr.g curr_clr.b
	)

	fn fillPanel reset:false changeRes:false range:(colorRange()) =
	(
		if reset then
		(
			disposeBtns btn_controls

			btn_controls = collectButtons range
			btn_controls.FlatStyle = dn_flat_style
			btn_controls.Dock = dn_dock.Left

			dncPanel.Controls.Clear()
			dncPanel.Controls.AddRange btn_controls
			dn_garbage.Collect()
			gc light:on
		)
		else recolorButtons range

		if changeRes do
			cpResult.color = getColorAtPos (int(dncTriBtn1.pos.x - 105))
	)

	fn resizeClrDialog size =
	(
		colorMixer.width = if size.x > 436 then size.x else 436
		colorMixer.height = 24
		dncPanel.width = colorMixer.width - 269
		cpColor2.pos.x = colorMixer.width - 155
		pbFrame.pos.x = colorMixer.width - 133
		cpResult.pos.x = colorMixer.width - 132
		spnPercent.pos.x = colorMixer.width - 65
		lblPercent.pos.x = colorMixer.width - 49
		btnRgbHsv.pos.x = colorMixer.width - 32
		dncTriBtn1.pos.x = dncTriBtn2.pos.x = dncPanel.pos.x + dncPanel.width / 2
		spnPercent.value = 50

		fillPanel reset:on
	)

	fn moveSpinner pos =
	(
		mouse_is_down = on
		click_start_pos = mouse.screenPos
		slider_start_pos = pos
		slider_pos.x = pos.x
	)

	fn colorFromSpinner = if mouse_is_down do
	(
	    dn_cursor.current = dn_cursors.SizeWE
		local currentPos = mouse.screenPos - click_start_pos
		local movedPos = (slider_start_pos + (currentPos)).x
		dncTriBtn1.pos.x = dncTriBtn2.pos.x = if 106 < movedPos AND movedPos < (104 + dncPanel.width) then movedPos else if 106 > movedPos then 105 else 104 + dncPanel.width
		local ctrl = "", ctrl_color = getColorAtPos (int(dncTriBtn2.pos.x - 105)) ctrl:&ctrl

		if ctrl_color != undefined do
		(
			cpResult.color = gammaCorrect ctrl_color (1d0 / gamma)
			spnPercent.value = 100d0 / (btn_controls.count + 1) * (btn_controls.count + 1 - findItem btn_controls ctrl)
		)
	)

	fn testClass defVal val =
		if isKindOf val (classOf defVal) AND val != "" then val else defVal

	fn setupTriButtons =
	(
		local triangle_path_1 = dotNetObject "System.Drawing.Drawing2D.GraphicsPath"
		local triangle_path_2 = dotNetObject "System.Drawing.Drawing2D.GraphicsPath"
		triangle_path_1.AddLines #(dotNetObject dn_point 0 0, dotNetObject dn_point 3 6, dotNetObject dn_point 6 0)
		triangle_path_2.AddLines #(dotNetObject dn_point 3 0, dotNetObject dn_point 6 6, dotNetObject dn_point 0 6)

	    dncTriBtn1.Size = dncTriBtn2.Size = dotNetObject "System.Drawing.Size" 8 8 
	    dncTriBtn1.Region = dotNetObject "System.Drawing.Region" triangle_path_1
		dncTriBtn2.Region = dotNetObject "System.Drawing.Region" triangle_path_2

	    triangle_path_1.Dispose()
		triangle_path_2.Dispose()
	)

	fn setupPercentSpinner =
	(
		local hwnd = windows.getChildHWND 0 colorMixer.title
		local spinners = for ctrl in (windows.getChildrenHWND hwnd[1]) where ctrl[4] == "SpinnerControl" collect ctrl[1]
		lblPercent.visible = true
	)

	fn loadIniFile = if doesFileExist ini_file do
	(
		setDialogPos colorMixer (testClass (getDialogPos colorMixer) (readValue ((getIniSetting ini_file #Dialog #Position) as stringStream)))
		colorMixer.width = testClass colorMixer.width (readValue ((getIniSetting ini_file #Dialog #Width) as stringStream))
		cpColor1.color = testClass cpColor1.color (readValue ((getIniSetting ini_file #Items #Color1) as stringStream))
		cpColor2.color = testClass cpColor2.color (readValue ((getIniSetting ini_file #Items #Color2) as stringStream))
		spnPrecisonVal.value = testClass spnPrecisonVal.value (readValue ((getIniSetting ini_file #Items #Count) as stringStream))
		btnRgbHsv.text = testClass btnRgbHsv.text (getIniSetting ini_file #Items #ColorSpace)
		mode = btnRgbHsv.text as name
	)

	fn saveIniFile =
	(
		setIniSetting ini_file "Dialog" #Position ((getDialogPos colorMixer) as string)
		setIniSetting ini_file "Dialog" #Width (colorMixer.width as string)
		setIniSetting ini_file "Items" #Color1 (cpColor1.color as string)
		setIniSetting ini_file "Items" #Color2 (cpColor2.color as string)
		setIniSetting ini_file "Items" #Count (spnPrecisonVal.value as string)
		setIniSetting ini_file "Items" #ColorSpace btnRgbHsv.text
	)

	---------------------------------------------------------------------------------
	-- Event Handlers
	---------------------------------------------------------------------------------

	on colorMixer open do
	(
		loadIniFile()

		dncPanel.BorderStyle = dncPanel.BorderStyle.None
		dncPanel.BackColor = convertFloat2dnColor (colorMan.getColor #background)

		setupPercentSpinner()
		setupTriButtons()

		colorMixer.resized [colorMixer.width, 24]
		cpResult.color = getColorAtPos (int(dncTriBtn1.pos.x - 105))
	)

	on colorMixer resized size do
		resizeClrDialog size

	on colorMixer close do
		saveIniFile()

	on spnPrecisonVal changed val do
		fillPanel reset:on changeRes:on

	on cpColor1 changed val do
		fillPanel changeRes:on

	on cpColor2 changed val do
		fillPanel changeRes:on

	on spnPercent changed val do
	(
		local ctrl = btn_controls[(0.01 * btn_controls.count) * (100 - val) + 1]
		dncTriBtn1.pos.x = dncTriBtn2.pos.x = 106 + ctrl.Location.X + ctrl.Width/2
		cpResult.color = getColorAtPos (int(dncTriBtn1.pos.x - 105))
	)

	on btnRgbHsv pressed do
	(
		btnRgbHsv.text = if btnRgbHsv.text == "RGB" then "HSV" else "RGB"
		mode = btnRgbHsv.text as name
		fillPanel changeRes:on
	)

	on dncTriBtn1 MouseDown sender args do
		if args.Button == dn_buttons_class.Left do moveSpinner sender.pos

	on dncTriBtn2 MouseDown sender args do
		if args.Button == dn_buttons_class.Left do moveSpinner sender.pos

	on dncTriBtn1 MouseUp args do
		mouse_is_down = args.Button != dn_buttons_class.Left

	on dncTriBtn2 MouseUp args do
		mouse_is_down = args.Button != dn_buttons_class.Left

	on dncTriBtn1 MouseHover args do
		dn_cursor.current = dn_cursors.SizeWE

	on dncTriBtn2 MouseHover do
		dn_cursor.current = dn_cursors.SizeWE

	on dncTriBtn1 MouseMove do
		colorFromSpinner()

	on dncTriBtn2 MouseMove do
		colorFromSpinner()
)
createDialog colorMixer pos:[590,193] style:#(#style_toolwindow, #style_sysmenu, #style_resizing)
