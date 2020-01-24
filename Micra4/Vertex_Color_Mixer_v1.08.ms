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
rollout mcColorMixer3 "Vertex Color Mixer ( RGB ) v0.07" width:500 height:24
(
	---------------------------------------------------------------------------------
	-- Layout Section
	---------------------------------------------------------------------------------

	spinner spnPrecisonVal "Count:" pos:[33,4] width:50 height:16 range:[3,200,10] type:#integer
	
	colorPicker cpSet1Color1 "" pos:[86,5] width:17 height:14 color:[255,0,0]
	colorPicker cpSet1Color2 "" pos:[mcColorMixer3.width - 159,5] width:17 height:14 color:[0,255,0]
	
	colorPicker cpSet2Color1 "" pos:[86,14*2] width:17 height:14 color:[0,255,0]
	colorPicker cpSet2Color2 "" pos:[mcColorMixer3.width - 159,14*2] width:17 height:14 color:[0,0,255]
	
	colorPicker cpSet3Color1 "" pos:[86,14*3 + 10] width:17 height:14 color:[0,0,255]
	colorPicker cpSet3Color2 "" pos:[mcColorMixer3.width - 159,14*3+10] width:17 height:14 color:[255,0,0]

	dotNetControl dncSet1Panel "Panel" pos:[108,4] width:(mcColorMixer3.width - 269) height:14
	dotNetControl dncSet2Panel "Panel" pos:[108,14*2] width:(mcColorMixer3.width - 269) height:14
	dotNetControl dncSet3Panel "Panel" pos:[108,14*3+10] width:(mcColorMixer3.width - 269) height:14
	
	progressBar pbSet1Frame pos:[mcColorMixer3.width - 133,3] width:28 height:17 enabled:off
	progressBar pbSet2Frame pos:[mcColorMixer3.width - 133,14*2] width:28 height:17 enabled:off
	progressBar pbSet3Frame pos:[mcColorMixer3.width - 133,14*3+10] width:28 height:17 enabled:off
	
	colorPicker cpSet1Result "" pos:(pbSet1Frame.pos - [3,-2]) width:30 height:14
	colorPicker cpSet2Result "" pos:(pbSet2Frame.pos - [3,-2]) width:30 height:14
	colorPicker cpSet3Result "" pos:(pbSet3Frame.pos - [3,-2]) width:30 height:14
	
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

	local btn_controls_set1 = #()
	local btn_controls_set2 = #()
	local btn_controls_set3 = #()
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
		fn getSizeFix size = (tile_count as double) / (dncSet1Panel.width - size * tile_count),
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
	
		if evnt.Button == dn_buttons_class.Left then (
		
			-- format "brn clr:% rindex:%\n" (maxColor ctrl.BackColor) ctrl.tag
			case ctrl.tag of (
			
				1 : cpSet1Result.color = gammaCorrect (maxColor ctrl.BackColor) (1/gamma)
				2 : cpSet2Result.color = gammaCorrect (maxColor ctrl.BackColor) (1/gamma)
				3 : cpSet3Result.color = gammaCorrect (maxColor ctrl.BackColor) (1/gamma)
			)
			--colorize vertices or edges or faces
			if mcVertexColorDialog != undefined do mcVertexColorDialog.setSelectionColor (maxColor ctrl.BackColor)
		)
	)
	fn getColorFromButton ctrl = (
	
		gammaCorrect (maxColor ctrl.BackColor) (1/gamma)
	)
	
	mapped fn disposeBtns btn = btn.Dispose()
	
	fn collectButtons range rindex =
	(
		local ctrl_size = int(dncSet1Panel.width / range.tile_count)
		local size_fix_step = range.getSizeFix ctrl_size
		local size_fix_next = size_fix_step
		local size_base = dotNetObject dn_size ctrl_size dncSet1Panel.height
		local size_base_ext = dotNetObject dn_size (ctrl_size + 1) dncSet1Panel.height

		for btn_index = 1 to range.tile_count collect
		(
			local curr_clr = getStepColor range.clr2 (range.next())
			local dn_button = dotNetObject dn_button_class
				dn_button.BackColor = dn_color.FromARGB curr_clr.r curr_clr.g curr_clr.b
				dn_button.FlatAppearance.BorderSize = 0
				dn_button.tag = rindex

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
	
	fn recolorButtons btn_controls range = for ctrl in btn_controls do (
	
		local curr_clr = getStepColor range.clr2 (range.next())
		ctrl.BackColor = dn_color.FromARGB curr_clr.r curr_clr.g curr_clr.b
	)

	fn fillPanel reset:false changeRes:false rindex:1 = (
	
		local range
		case rindex of (
		
			1 : (
				range = colorRange cpSet1Color1 cpSet1Color2
				if reset then (
				
					disposeBtns btn_controls_set1

					btn_controls_set1 = collectButtons range 1
					btn_controls_set1.FlatStyle = dn_flat_style
					btn_controls_set1.Dock = dn_dock.Left

					dncSet1Panel.Controls.Clear()
					dncSet1Panel.Controls.AddRange btn_controls_set1
					
				) else recolorButtons btn_controls_set1 range
				if changeRes do cpSet1Result.color = getColorFromButton btn_controls_set1[1]
			)
			2 : (
				range = colorRange cpSet2Color1 cpSet2Color2
				if reset then (
			
					disposeBtns btn_controls_set2

					btn_controls_set2 = collectButtons range 2
					btn_controls_set2.FlatStyle = dn_flat_style
					btn_controls_set2.Dock = dn_dock.Left

					dncSet2Panel.Controls.Clear()
					dncSet2Panel.Controls.AddRange btn_controls_set2
					
				) else recolorButtons btn_controls_set2 range
				if changeRes do cpSet2Result.color = getColorFromButton btn_controls_set2[1]
			)
			3 : (
				range = colorRange cpSet3Color1 cpSet3Color2
				if reset then (
			
					disposeBtns btn_controls_set3

					btn_controls_set3 = collectButtons range 3
					btn_controls_set3.FlatStyle = dn_flat_style
					btn_controls_set3.Dock = dn_dock.Left

					dncSet3Panel.Controls.Clear()
					dncSet3Panel.Controls.AddRange btn_controls_set3
					
				) else recolorButtons btn_controls_set3 range
				if changeRes do cpSet3Result.color = getColorFromButton btn_controls_set3[1]
			)
		)
		dn_garbage.Collect()
		gc light:on
	)

	fn resizeClrDialog size = (
	
		mcColorMixer3.width = if size.x > 436 then size.x else 436 --min size
		mcColorMixer3.height = 24 * 3 --fixed height
		dncSet1Panel.width = dncSet2Panel.width = dncSet3Panel.width =  mcColorMixer3.width - 189
		cpSet1Color2.pos.x = cpSet2Color2.pos.x = cpSet3Color2.pos.x = mcColorMixer3.width - 75
		pbSet1Frame.pos.x = pbSet2Frame.pos.x = pbSet3Frame.pos.x = mcColorMixer3.width - 33
		cpSet1Result.pos.x = cpSet2Result.pos.x = cpSet3Result.pos.x = mcColorMixer3.width - 32
		fillPanel reset:on rindex:1
		fillPanel reset:on rindex:2
		fillPanel reset:on rindex:3
		dn_garbage.Collect()
		gc light:on
	)


	fn testClass defVal val = (
	
		if isKindOf val (classOf defVal) AND val != "" then val else defVal
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

		dncSet1Panel.BorderStyle = dncSet1Panel.BorderStyle.None
		dncSet1Panel.BackColor = convertFloat2dnColor (colorMan.getColor #background)
		mcColorMixer3.resized [mcColorMixer3.width, 24 * 3]
		cpSet1Result.color = mcColorMixer3.cpSet1Color1.color --get color from left picker
		cpSet2Result.color = mcColorMixer3.cpSet2Color1.color
		cpSet3Result.color = mcColorMixer3.cpSet3Color1.color
	)

	---on mcColorMixer3 resized size do resizeClrDialog size
	on mcColorMixer3 close do saveIniFile()
	on spnPrecisonVal changed val do (
	
		fillPanel reset:on changeRes:on rindex:1
		fillPanel reset:on changeRes:on rindex:2
		fillPanel reset:on changeRes:on rindex:3
	)
	on cpSet1Color1 changed val do fillPanel changeRes:on rindex:1
	on cpSet1Color2 changed val do fillPanel changeRes:on rindex:1
	
	on cpSet2Color1 changed val do fillPanel changeRes:on rindex:2
	on cpSet2Color2 changed val do fillPanel changeRes:on rindex:2
	
	on cpSet3Color1 changed val do fillPanel changeRes:on rindex:3
	on cpSet3Color2 changed val do fillPanel changeRes:on rindex:3
)
createDialog mcColorMixer3 pos:[590,193] style:#(#style_toolwindow, #style_sysmenu, #style_resizing)
