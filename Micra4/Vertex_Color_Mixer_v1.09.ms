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
Global mcColorMixerRGB
if mcColorMixerRGB != undefined do destroyDialog mcColorMixerRGB
rollout mcColorMixerRGB "Vertex Color Mixer ( RGB ) v0.09" width:500 height:72
(
	---------------------------------------------------------------------------------
	-- Layout Section
	---------------------------------------------------------------------------------

	spinner spnPrecisonVal "Count:" pos:[33,4] width:50 height:16 range:[3,200,10] type:#integer
	
	colorPicker cpSet1Color1 "" pos:[86,5] width:17 height:14 color:[255,0,0]
	colorPicker cpSet1Color2 "" pos:[mcColorMixerRGB.width - 159,5] width:17 height:14 color:[0,255,0]
	
	colorPicker cpSet2Color1 "" pos:[86,14*2] width:17 height:14 color:[0,255,0]
	colorPicker cpSet2Color2 "" pos:[mcColorMixerRGB.width - 159,14*2] width:17 height:14 color:[0,0,255]
	
	colorPicker cpSet3Color1 "" pos:[86,14*3 + 10] width:17 height:14 color:[0,0,255]
	colorPicker cpSet3Color2 "" pos:[mcColorMixerRGB.width - 159,14*3+10] width:17 height:14 color:[255,0,0]

	dotNetControl dncSet1Panel "Panel" pos:[108,4] width:(mcColorMixerRGB.width - 269) height:14
	dotNetControl dncSet2Panel "Panel" pos:[108,14*2] width:(mcColorMixerRGB.width - 269) height:14
	dotNetControl dncSet3Panel "Panel" pos:[108,14*3+10] width:(mcColorMixerRGB.width - 269) height:14
	
	progressBar pbSet1Frame pos:[mcColorMixerRGB.width - 133,3] width:28 height:17 enabled:off
	progressBar pbSet2Frame pos:[mcColorMixerRGB.width - 133,14*2] width:28 height:17 enabled:off
	progressBar pbSet3Frame pos:[mcColorMixerRGB.width - 133,14*3+10] width:28 height:17 enabled:off
	
	colorPicker cpSet1Result "" pos:(pbSet1Frame.pos - [3,-2]) width:30 height:14
	colorPicker cpSet2Result "" pos:(pbSet2Frame.pos - [3,-2]) width:30 height:14
	colorPicker cpSet3Result "" pos:(pbSet3Frame.pos - [3,-2]) width:30 height:14
	
	dotNetControl btnSet1Mark1 "Label" pos:[dncSet1Panel.pos.x + dncSet1Panel.width/2 - 3,14+4]
	dotNetControl btnSet2Mark1 "Label" pos:[dncSet2Panel.pos.x + dncSet2Panel.width/2 - 3, 14*3]
	dotNetControl btnSet3Mark1 "Label" pos:[dncSet3Panel.pos.x + dncSet3Panel.width/2 - 3, 14*4+10]
	
	dotNetControl btnSet1Mark2 "Label" pos:[dncSet1Panel.pos.x + dncSet1Panel.width/2 - 3,2]
	dotNetControl btnSet2Mark2 "Label" pos:[dncSet2Panel.pos.x + dncSet2Panel.width/2 - 3, 14*2-2]
	dotNetControl btnSet3Mark2 "Label" pos:[dncSet3Panel.pos.x + dncSet3Panel.width/2 - 3, 14*3+10-2]
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
	local ini_file = (dotNetClass "Application").LocalUserAppDataPath + "\\mcColorMixerRGB.ini"
	local gamma = if isGammaActive() then 1d0/displayGamma else 1d0
	---------------------------------------------------------------------------------
	-- Structs
	---------------------------------------------------------------------------------

	struct colorRange
	(
		cp1, cp2,
		clr1 = mcColorMixerRGB.gammaCorrect cp1.color gamma,
		clr2 = mcColorMixerRGB.gammaCorrect cp2.color gamma,
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
			
				1 : (
					cpSet1Result.color = gammaCorrect (maxColor ctrl.BackColor) (1/gamma)
					btnSet1Mark1.pos.x = btnSet1Mark2.pos.x = (dncSet1Panel.pos.x + ctrl.Location.x + ctrl.width/2 - 2)
				)
				2 : (
				
					cpSet2Result.color = gammaCorrect (maxColor ctrl.BackColor) (1/gamma)
					btnSet2Mark1.pos.x = btnSet2Mark2.pos.x = (dncSet2Panel.pos.x + ctrl.Location.x + ctrl.width/2 - 2)
				)
				3 : (
					cpSet3Result.color = gammaCorrect (maxColor ctrl.BackColor) (1/gamma)
					btnSet3Mark1.pos.x = btnSet3Mark2.pos.x = (dncSet3Panel.pos.x + ctrl.Location.x + ctrl.width/2 - 2)
				)
			)
			--colorize vertices or edges or faces
			if mcVertexColorDialog != undefined do mcVertexColorDialog.setSelectionColor (maxColor ctrl.BackColor)
		)
	)
	fn getColorAtPos pos &ctrl: = (
	
		if (local curr_ctrl = dncSet1Panel.GetChildAtPoint (dotNetObject dn_point pos 0)) != undefined do
		(
			if ctrl != unsupplied do ctrl = curr_ctrl
			gammaCorrect (maxColor curr_ctrl.BackColor) (1/gamma)
		)
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
				if changeRes do cpSet1Result.color = getColorAtPos (int(btnSet1Mark1.pos.x - 105))
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
				if changeRes do cpSet2Result.color = getColorAtPos (int(btnSet2Mark1.pos.x - 105))
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
				if changeRes do cpSet3Result.color = getColorAtPos (int(btnSet3Mark1.pos.x - 105))
			)
		)
		dn_garbage.Collect()
		gc light:on
	)

	fn resizeClrDialog size = (
	
		format "resize:%\n" size
		mcColorMixerRGB.width = if size.x > 436 then size.x else 436 --min size
		mcColorMixerRGB.height = 24 * 3 --fixed height
		dncSet1Panel.width = dncSet2Panel.width = dncSet3Panel.width =  mcColorMixerRGB.width - 189
		cpSet1Color2.pos.x = cpSet2Color2.pos.x = cpSet3Color2.pos.x = mcColorMixerRGB.width - 75
		pbSet1Frame.pos.x = pbSet2Frame.pos.x = pbSet3Frame.pos.x = mcColorMixerRGB.width - 33
		cpSet1Result.pos.x = cpSet2Result.pos.x = cpSet3Result.pos.x = mcColorMixerRGB.width - 32
		fillPanel reset:on rindex:1
		fillPanel reset:on rindex:2
		fillPanel reset:on rindex:3
		local marker_pos_x = dncSet1Panel.pos.x + (btn_controls_set1[1].width / 2) - 2--+ dncSet1Panel.width / 2
		btnSet1Mark1.pos.x = btnSet2Mark1.pos.x = btnSet3Mark1.pos.x = marker_pos_x
		btnSet1Mark2.pos.x = btnSet2Mark2.pos.x = btnSet3Mark2.pos.x = marker_pos_x
	)


	fn setupMarkButtons = (
	
		local dclr = dn_color.FromARGB 100 100 100
		local dsize = dotNetObject "System.Drawing.Size" 8 2
		local pos_x = 0 --dncSet1Panel.pos.x
		btnSet1Mark1.BackColor = btnSet2Mark1.BackColor = btnSet3Mark1.BackColor = dclr 
		btnSet1Mark2.BackColor = btnSet2Mark2.BackColor = btnSet3Mark2.BackColor = dclr
		btnSet1Mark1.Size = btnSet2Mark1.Size = btnSet3Mark1.Size = dsize
		btnSet1Mark2.Size = btnSet2Mark2.Size = btnSet3Mark2.Size = dsize
	)

	fn testClass defVal val = (
	
		if isKindOf val (classOf defVal) AND val != "" then val else defVal
	)


	fn loadIniFile = if doesFileExist ini_file do (
	
		setDialogPos mcColorMixerRGB (testClass (getDialogPos mcColorMixerRGB) (readValue ((getIniSetting ini_file #Dialog #Position) as stringStream)))
		mcColorMixerRGB.width = testClass mcColorMixerRGB.width (readValue ((getIniSetting ini_file #Dialog #Width) as stringStream))
		spnPrecisonVal.value = testClass spnPrecisonVal.value (readValue ((getIniSetting ini_file #Items #Count) as stringStream))
	)

	fn saveIniFile = (
	
		setIniSetting ini_file "Dialog" #Position ((getDialogPos mcColorMixerRGB) as string)
		setIniSetting ini_file "Dialog" #Width (mcColorMixerRGB.width as string)
		setIniSetting ini_file "Items" #Count (spnPrecisonVal.value as string)
	)

	---------------------------------------------------------------------------------
	-- Event Handlers
	---------------------------------------------------------------------------------

	on mcColorMixerRGB open do
	(
		loadIniFile()

		setupMarkButtons()

		dncSet1Panel.BorderStyle = dncSet1Panel.BorderStyle.None
		dncSet1Panel.BackColor = convertFloat2dnColor (colorMan.getColor #background)
		mcColorMixerRGB.resized [mcColorMixerRGB.width, 24 * 3]
		cpSet1Result.color = mcColorMixer3.cpSet1Color1.color --get color from left picker
		cpSet2Result.color = mcColorMixer3.cpSet2Color1.color
		cpSet3Result.color = mcColorMixer3.cpSet3Color1.color
	)

	on mcColorMixerRGB resized size do resizeClrDialog size
	on mcColorMixerRGB close do saveIniFile()
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
createDialog mcColorMixerRGB pos:[590,193] style:#(#style_toolwindow, #style_sysmenu, #style_resizing)