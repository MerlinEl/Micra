-------------------------------------------------------------------------------------
-- Color Mixer
--
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
-- Modify: MerlinEl 2020
-------------------------------------------------------------------------------------
Global mcColorMixer3
if mcColorMixer3 != undefined do destroyDialog mcColorMixer3
rollout mcColorMixer3 "Color Mixer v0.06" width:500 height:24
(
	---------------------------------------------------------------------------------
	-- Layout Section
	---------------------------------------------------------------------------------

	spinner spnPrecisonVal "Count:" pos:[33,4] width:50 height:16 range:[3,200,10] type:#integer
	
	colorPicker cpSet1Color1 "" pos:[86,5] width:17 height:14 color:[255,0,0]
	colorPicker cpSet1Color2 "" pos:[mcColorMixer3.width - 159,5] width:17 height:14 color:[0,255,0]
	
	colorPicker cpSet2Color1 "" pos:[86,14*2] width:17 height:14 color:[255,0,0]
	colorPicker cpSet2Color2 "" pos:[mcColorMixer3.width - 159,5] width:17 height:14 color:[0,255,0]
	
	colorPicker cpSet3Color1 "" pos:[86,14*3 + 10] width:17 height:14 color:[255,0,0]
	colorPicker cpSet3Color2 "" pos:[mcColorMixer3.width - 159,5] width:17 height:14 color:[0,255,0]
	--todo
	dotNetControl dncPanel "Panel" pos:[108,4] width:(mcColorMixer3.width - 269) height:14
	-- dotNetControl dncPanel "Panel" pos:[108,4] width:(mcColorMixer3.width - 269) height:14
	-- dotNetControl dncPanel "Panel" pos:[108,4] width:(mcColorMixer3.width - 269) height:14
	
	dotNetControl dncSet1TriBtn1 "Button" pos:[dncPanel.pos.x + dncPanel.width/2 - 3,-1]
	dotNetControl dncSet2TriBtn1 "Button" pos:[dncPanel.pos.x + dncPanel.width/2 - 3, 14*2]
	dotNetControl dncSet3TriBtn1 "Button" pos:[dncPanel.pos.x + dncPanel.width/2 - 3, 14*3+10]
	
	dotNetControl dncSet1TriBtn2 "Button" pos:[dncSet1TriBtn1.pos.x,18]
	-- dotNetControl dncSet1TriBtn2 "Button" pos:[dncSet1TriBtn1.pos.x,18]
	-- dotNetControl dncSet1TriBtn2 "Button" pos:[dncSet1TriBtn1.pos.x,18]
	
	

	
	
	progressBar pbFrame pos:[mcColorMixer3.width - 133,3] width:28 height:17 enabled:off
	colorPicker cpResult "" pos:(pbFrame.pos - [3,-2]) width:30 height:14

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

	local btn_controls = #()
	local ini_file = (dotNetClass "Application").LocalUserAppDataPath + "\\mcColorMixer3.ini"
	local gamma = if isGammaActive() then 1d0/displayGamma else 1d0

	---------------------------------------------------------------------------------
	-- Structs
	---------------------------------------------------------------------------------

	struct colorRange
	(
		cp1, cp2,
		clr1 = mcColorMixer3.gammaCorrect cp1.color gamma,
		clr2 = mcColorMixer3.gammaCorrect cp2.color gamma,
		clr_diff = clr1 - clr2,
		tile_count = spnPrecisonVal.value,
		clr_step = 1.0 / (tile_count + 1),
		curr_step = 0.0,
		fn getSizeFix size = (tile_count as double) / (dncPanel.width - size * tile_count),
		fn next = clr_diff * (curr_step += clr_step)
	)

	---------------------------------------------------------------------------------
	-- Functions
	---------------------------------------------------------------------------------
	fn convertFloat2dnColor float_color = (
	
		float_color *= 255
		dn_color.FromARGB float_color[1] float_color[2] float_color[3]
	)
	fn gammaCorrect clr gamma = (
	
		clr /= 255.
		255 * [clr.r^gamma, clr.g^gamma, clr.b^gamma] as color
	)
	fn maxColor dn_clr = (color dn_clr.R dn_clr.G dn_clr.B)
	fn getStepColor clr clr_step = (clr + clr_step)
	fn onBtnMouseUp ctrl evnt = (
	
		if evnt.Button == dn_buttons_class.Left then
		(
			cpResult.color = gammaCorrect (maxColor ctrl.BackColor) (1/gamma)
			dncSet1TriBtn1.pos.x = dncSet1TriBtn2.pos.x = (dncPanel.pos.x + ctrl.Location.x + ctrl.width/2 - 3)
			local max_col = mcDotnet.mColor ctrl.BackColor
			if mcVertexColorDialog != undefined do mcVertexColorDialog.setSelectionColor max_col
		)
	)
	fn getColorAtPos pos &ctrl: = (
	
		if (local curr_ctrl = dncPanel.GetChildAtPoint (dotNetObject dn_point pos 0)) != undefined do
		(
			if ctrl != unsupplied do ctrl = curr_ctrl
			gammaCorrect (maxColor curr_ctrl.BackColor) (1/gamma)
		)
	)
	
	mapped fn disposeBtns btn = btn.Dispose()
	
	fn collectButtons range =
	(
		local ctrl_size = int(dncPanel.width / range.tile_count)
		local size_fix_step = range.getSizeFix ctrl_size
		local size_fix_next = size_fix_step
		local size_base = dotNetObject dn_size ctrl_size dncPanel.height
		local size_base_ext = dotNetObject dn_size (ctrl_size + 1) dncPanel.height

		for btn_index = 1 to range.tile_count collect
		(
			local curr_clr = getStepColor range.clr2 (range.next())
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
		local curr_clr = getStepColor range.clr2 (range.next())
		ctrl.BackColor = dn_color.FromARGB curr_clr.r curr_clr.g curr_clr.b
	)

	fn fillPanel reset:false changeRes:false rindex:1 =
	(
		local range = case rindex of (
		
			1 : colorRange cpSet1Color1 cpSet1Color2
			2 : colorRange cpSet2Color1 cpSet2Color2
			3 : colorRange cpSet3Color1 cpSet3Color2
		)
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
			cpResult.color = getColorAtPos (int(dncSet1TriBtn1.pos.x - 105))
	)

	fn resizeClrDialog size = (
	
		mcColorMixer3.width = if size.x > 436 then size.x else 436 --min size
		mcColorMixer3.height = 24 * 3 --fixed height
		dncPanel.width = mcColorMixer3.width - 189
		cpSet1Color2.pos.x = mcColorMixer3.width - 75
		pbFrame.pos.x = mcColorMixer3.width - 33
		cpResult.pos.x = mcColorMixer3.width - 32
		dncSet1TriBtn1.pos.x = dncSet1TriBtn2.pos.x = dncPanel.pos.x + dncPanel.width / 2
		fillPanel reset:on rindex:1
		-- fillPanel reset:on rindex:2
		-- fillPanel reset:on rindex:3
	)

	fn testClass defVal val = (
	
		if isKindOf val (classOf defVal) AND val != "" then val else defVal
	)

	fn setupTriButtons = (
		local triangle_path_1 = dotNetObject "System.Drawing.Drawing2D.GraphicsPath"
		local triangle_path_2 = dotNetObject "System.Drawing.Drawing2D.GraphicsPath"
		triangle_path_1.AddLines #(dotNetObject dn_point 0 0, dotNetObject dn_point 3 6, dotNetObject dn_point 6 0)
		triangle_path_2.AddLines #(dotNetObject dn_point 3 0, dotNetObject dn_point 6 6, dotNetObject dn_point 0 6)

	    dncSet1TriBtn1.Size = dncSet1TriBtn2.Size = dotNetObject "System.Drawing.Size" 8 8 
	    dncSet1TriBtn1.Region = dotNetObject "System.Drawing.Region" triangle_path_1
		dncSet1TriBtn2.Region = dotNetObject "System.Drawing.Region" triangle_path_2

	    triangle_path_1.Dispose()
		triangle_path_2.Dispose()
	)

	fn loadIniFile = if doesFileExist ini_file do (
	
		setDialogPos mcColorMixer3 (testClass (getDialogPos mcColorMixer3) (readValue ((getIniSetting ini_file #Dialog #Position) as stringStream)))
		mcColorMixer3.width = testClass mcColorMixer3.width (readValue ((getIniSetting ini_file #Dialog #Width) as stringStream))
		spnPrecisonVal.value = testClass spnPrecisonVal.value (readValue ((getIniSetting ini_file #Items #Count) as stringStream))
	)

	fn saveIniFile = (
	
		setIniSetting ini_file "Dialog" #Position ((getDialogPos mcColorMixer3) as string)
		setIniSetting ini_file "Dialog" #Width (mcColorMixer3.width as string)
		setIniSetting ini_file "Items" #Count (spnPrecisonVal.value as string)
	)

	---------------------------------------------------------------------------------
	-- Event Handlers
	---------------------------------------------------------------------------------

	on mcColorMixer3 open do
	(
		loadIniFile()

		dncPanel.BorderStyle = dncPanel.BorderStyle.None
		dncPanel.BackColor = convertFloat2dnColor (colorMan.getColor #background)

		setupTriButtons()

		mcColorMixer3.resized [mcColorMixer3.width, 24 * 3]
		cpResult.color = getColorAtPos (int(dncSet1TriBtn1.pos.x - 105))
	)

	on mcColorMixer3 resized size do resizeClrDialog size
	on mcColorMixer3 close do saveIniFile()
	on spnPrecisonVal changed val do (
	
		fillPanel reset:on changeRes:on rindex:1
		-- fillPanel reset:on changeRes:on rindex:2
		-- fillPanel reset:on changeRes:on rindex:3
	)
	on cpSet1Color1 changed val do fillPanel changeRes:on rindex:1
	on cpSet1Color2 changed val do fillPanel changeRes:on rindex:1
)
createDialog mcColorMixer3 pos:[590,193] style:#(#style_toolwindow, #style_sysmenu, #style_resizing)
