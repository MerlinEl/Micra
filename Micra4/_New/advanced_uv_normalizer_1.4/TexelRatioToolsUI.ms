fileIn "ChannelInfoTools.ms"
fileIn "TexelRatioTools.ms"

-- Hangar 13
-- https://hangar13games.com
-- Copyright (c) 2017 Hangar13. All Rights Reserved
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- struct takes care about Texel Density stuff
-- asociated file: TexelRatioToolsUI.ms
-- created by hajnis
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


global gTexelRatioToolsUI = undefined

rollout dlgTexelRatioUI "Texel Ratio" width:240 height:569
(
	GroupBox 'grp22' "Texture Size:" pos:[35,456] width:169 height:56 align:#left
	dropdownList 'ddl_texture_x' "" pos:[52,480] width:60 height:21 items:#("64", "128", "256", "512", "1024", "2048", "4096") selection:5 align:#left
	dropdownList 'ddl_texture_y' "" pos:[128,480] width:60 height:21 items:#("64", "128", "256", "512", "1024", "2048", "4096") selection:5 align:#left
	label 'lbl_w' "w:" pos:[40,484] width:12 height:17 across:2 align:#left
	label 'lbl_h' "h:" pos:[116,484] width:12 height:17 across:2 align:#left
	label 'lbl_px' "px" pos:[192,480] width:20 height:16 align:#left

	button 'btnGetRatio' "Get Texel Ratio from Selection" pos:[39,169] width:160 height:23 across:1 align:#left
	label 'lblUV' "UV:" pos:[43,29] width:20 height:16 across:4 align:#left
	dropdownList 'ddlUV' "" pos:[115,26] width:48 height:21 across:4 align:#left
	edittext 'edtRatio' "Ratio:" pos:[43,197] width:90 height:17 enabled:true align:#left
	button 'btnSetRatio' "Set Texel Ratio to Selection (Multiple)" pos:[39,221] width:160 height:40 across:1 align:#left
	GroupBox 'grp1' "Texel Density" pos:[35,6] width:170 height:91 align:#left
	--groupBox 'grp1' "Texel Density" width:170 height:138 align:#center
	
	checkbox 'chckNormalize' "Normalize" pos:[43,344] width:71 height:23 checked:false align:#left
	checkbox 'chckRotate' "Rotate" pos:[118,345] width:71 height:23 checked:false align:#left
	checkbox 'chckFillHoles' "FillHoles" pos:[43,365] width:71 height:23 checked:false align:#left
	edittext 'edtSpacing' "Spacing" pos:[118,370] width:80 height:17 align:#left
	checkbox 'chckCollapse' "Collapse *" pos:[43,388] width:68 height:23 checked:false align:#left
	button 'btnNormalize' "Pack UV Elements" pos:[39,419] width:160 height:23 across:1 align:#left
	GroupBox 'grp2' "Pack UVs" pos:[35,329] width:170 height:120 align:#left
	--groupBox 'grp2' "Pack UVs" width:170 height:120 align:#center
	label 'lblInfo' "* Collapse Stack checker works on all three buttons." pos:[43,520] width:150 height:30 align:#left
	
	
	button 'btnSetDefaultDensity' "Set Texel density 512 px/m" pos:[39,53] width:160 height:37 across:1 align:#left enabled:false
	label 'lbl16' "px/m" pos:[140,197] width:30 height:17 across:2 align:#left
	GroupBox 'grp9' "Texel Ratio" pos:[35,110] width:170 height:156 align:#left
	label 'lblRatioUV' "UV: 1" pos:[43,149] width:32 height:16 aLOADcross:4 align:#left
	label 'lblRatioTexture' "Texture Size: 1024px" pos:[43,132] width:104 height:16 across:4 align:#left
	button 'btnUndo' "UNDO Set/Pack Operations" pos:[39,277] width:160 height:37 enabled:false across:1 align:#left
	
	
	checkbox 'chckRescale' "Rescale" pos:[118,388] width:73 height:23 checked:false align:#left
	on dlgTexelRatioUI open do
	(
		-- SetDialogPos dlgTexelRatioUI ((::gTexelRatioTools.GetConfigProperty "pos" [600,600] point2) as point2)
-- 		edtTexture.text = (::gTexelRatioTools.GetConfigProperty edtTexture.name 1024 integer) as string

		-- edtRatio.text = (::gTexelRatioTools.GetConfigProperty edtRatio.name 1024 float) as string
		-- edtSpacing.text = (::gTexelRatioTools.GetConfigProperty edtSpacing.name 0.0 float) as string
		-- chckNormalize.checked = (::gTexelRatioTools.GetConfigProperty chckNormalize.name true booleanClass) as booleanClass
		-- chckRotate.checked = (::gTexelRatioTools.GetConfigProperty chckRotate.name false booleanClass) as booleanClass
		-- chckFillHoles.checked = (::gTexelRatioTools.GetConfigProperty chckFillHoles.name false booleanClass) as booleanClass
		-- chckCollapse.checked = (::gTexelRatioTools.GetConfigProperty chckCollapse.name false booleanClass) as booleanClass
		-- chckRescale.checked = (::gTexelRatioTools.GetConfigProperty chckRescale.name false booleanClass) as booleanClass
		--::gTexelRatioTools.GetPixelSizes ddlPixelSize
		::gTexelRatioTools.GetUVs ddlUV
		-- ddlUV.selection = (::gTexelRatioTools.GetConfigProperty ddlUV.name 1 integer) as integer
		lblRatioUV.text = "UV: " + ddlUV.selection as string
		--::gTexelRatioTools.LoadConfig edtTexture ddlUV
		
-- 		btnSetDefaultDensity.text = "Set Texel Density "+edtTexture.text+ " px/m"
		btnSetDefaultDensity.text = "Set Texel Density 512 px/m"
	)
	on dlgTexelRatioUI close do
	(
		::gTexelRatioTools.SaveConfig()
	)
	-- on edtTexture entered val do
	-- (
		-- lblRatioTexture.text = "Texture Size: " + val + " px"
		-- btnSetDefaultDensity.text = "Set Texel Density "+val+ " px/m"
	-- )
	on btnGetRatio pressed do
	(
		if(selection.count == 0)then
		(
			messageBox "!!!Would you kindly… select an Object?!!!"
		)else
		(
			--if(::gP3DChannelInfoTools.TestIfChannelExist selection[1] (ddlUV.selected as integer))then
			(
				local texture_width = ddl_texture_x.text as float
				local texture_height = ddl_texture_y.text as float
				edtRatio.text = ((::gTexelRatioTools.GetTexelDensity selection[1] texture_width texture_height ::gTexelRatioTools.cmLengthSize (ddlUV.selected as integer) chckCollapse.checked) * 100) as string
				clearUndoBuffer()
			)
			-- else
			-- (
				-- messageStr = "!!!Selected object has no channel " + ddlUV.selection as string+ "!!!"
				-- messageBox messageStr
			-- )
		)
	)
	on ddlUV selected itemId do
	(
		lblRatioUV.text = "UV: " + itemId as string
	)
	on edtRatio entered newValue do
	(
		ratio = newValue as float
		if(edtRatio.text == "")then
		(
			edtRatio.text = "512"
		)
		if( Classof ratio == UndefinedClass)then
		(
			messageBox "!!!Stop right there, criminal scum!!!\n !!!Do not put non-float values into Ratio text field!!!"
			edtRatio.text = "512"
		)
	)
	on btnSetRatio pressed do
	(
		arrSelection = selection as array
		if(arrSelection.count == 0)then
		(
			messageBox "!!!Wait... I know you! How can one apply Texel Ratio on 0 Objects?!!!"
		)
		else
		(
			holdMaxFile()
			--suspendEditing()
-- 			texelRatio = (edtTexture.text as float)/::gTexelRatioTools.cmLengthSize
-- 			print (((edtRatio.text as float)/100.0) as string)
			local texture_width = ddl_texture_x.text as float
			local texture_height = ddl_texture_y.text as float
			::gTexelRatioTools.SetTexelDensityOnSelection arrSelection ((edtRatio.text as float)/100.0) texture_width texture_height ::gTexelRatioTools.cmLengthSize (ddlUV.selected as integer) chckCollapse.checked
-- 			::gTexelRatioTools.SetTexelDensityOnSelection arrSelection (texelRatio) (edtTexture.text as float) ::gTexelRatioTools.cmLengthSize (ddlUV.selected as integer) chckCollapse.checked
			btnUndo.enabled = true
			--resumeEditing()
			clearUndoBuffer()
			
		)
	)
	on edtSpacing entered newValue do
	(
		spacing = newValue as float
		if(edtSpacing.text == "")then
		(
			edtSpacing.text = "0.02"
		)
		if(classof spacing == UndefinedClass)then
		(
			edtSpacing.text = "0.02"
		)
	)
	on btnNormalize pressed do
	(
		arrSelection = selection as array
		holdMaxFile()
		--suspendEditing()
		::gTexelRatioTools.PackSelection arrSelection (edtSpacing.text as float) chckNormalize.checked chckRotate.checked chckFillHoles.checked (ddlUV.selected as integer) chckCollapse.checked chckRescale.checked
		btnUndo.enabled = true
		--resumeEditing()
		clearUndoBuffer()
	)
	on btnSetDefaultDensity pressed do
	(
		arrSelection = selection as array
		if(arrSelection.count == 0)then
		(
			messageBox "!!!Wait... I know you! How can one apply Texel Ratio on 0 Objects?!!!"
		)
		else
		(
			holdMaxFile()
			--suspendEditing()
			texelRatio = (512 as float)/::gTexelRatioTools.cmLengthSize
-- 			print texelRatio
			local texture_width = ddl_texture_x.text as float
			local texture_height = ddl_texture_y.text as float
			::gTexelRatioTools.SetTexelDensityOnSelection arrSelection (texelRatio) texture_width  texture_height ::gTexelRatioTools.cmLengthSize (ddlUV.selected as integer) chckCollapse.checked
			btnUndo.enabled = true
			--resumeEditing()
			clearUndoBuffer()	
		)
	)
	on btnUndo pressed do
	(
		fetchMaxFile quiet:true
		btnUndo.enabled = false
	)
)

------------------------------------------------------------------------------------------------------------
-- INIT gTexelRatioToolsUI
------------------------------------------------------------------------------------------------------------
if(::gTexelRatioToolsUI == undefined)then
(
	::gTexelRatioToolsUI = dlgTexelRatioUI
)

-- TEST
--createDialog gTexelRati
createDialog gTexelRatioToolsUI