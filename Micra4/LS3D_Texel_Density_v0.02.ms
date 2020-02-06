fileIn "LS3D_Texel_Density_Struct.ms"

-- Hangar 13
-- https://hangar13games.com
-- Copyright (c) 2017 Hangar13. All Rights Reserved
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- struct takes care about Texel Density stuff
-- asociated file: TexelRatioToolsUI.ms
-- created by hajnis
-- mod by MerlinEl
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


global gTexelRatioToolsUI = undefined

rollout dlgTexelRatioUI "Texel Density Transfer:" width:188 height:444
(
	GroupBox 'grp22' "Source Texture Size:" pos:[4,88] width:180 height:76 align:#left
	dropdownList 'ddl_texture_x_src' "" pos:[21,112] width:60 height:21 selection:5 align:#left
	dropdownList 'ddl_texture_y_src' "" pos:[97,112] width:60 height:21 selection:5 align:#left
	label 'lbl_w' "w:" pos:[9,116] width:12 height:17 across:2 align:#left
	label 'lbl_h' "h:" pos:[85,116] width:12 height:17 across:2 align:#left
	label 'lbl_px' "px" pos:[161,112] width:20 height:16 align:#left

	button 'btnGetRatio' "Get Texel Ratio from Object" pos:[8,280] width:168 height:28 across:1 align:#left
	label 'lblUV' "UV Channel:" pos:[12,27] width:69 height:16 across:4 align:#left
	dropdownList 'ddlUV' "" pos:[84,24] width:48 height:21 across:4 align:#left
	button 'btnSetRatio' "Set Texel Ratio to Object(s)" pos:[8,312] width:168 height:28 across:1 align:#left
	GroupBox 'grp1' "Settings:" pos:[4,4] width:180 height:80 align:#left
	
	checkbox 'chckCollapse' "Collapse Modifiers *" pos:[12,48] width:150 height:23 checked:true align:#left

	label 'lbl16' "px/m" pos:[132,140] width:30 height:17 across:2 align:#left
	GroupBox 'grp9' "Object to Object(s):" pos:[4,260] width:180 height:88 align:#left
	GroupBox 'grp4' "Target Texture Size:" pos:[4,172] width:180 height:80 align:#left
	dropdownList 'ddl_texture_x_trgt' "" pos:[21,196] width:60 height:21 selection:5 align:#left
	dropdownList 'ddl_texture_y_trgt' "" pos:[97,196] width:60 height:21 selection:5 align:#left
	label 'lbl8' "w:" pos:[9,200] width:12 height:17 across:2 align:#left
	label 'lbl9' "h:" pos:[85,200] width:12 height:17 across:2 align:#left
	label 'lbl10' "px" pos:[161,196] width:20 height:16 align:#left
	GroupBox 'grp11' "UV Face to UV Island(s):" pos:[4,352] width:180 height:88 align:#left
	button 'btn_get_uv_face_ratio' "Get Texel Ratio from UV Face" pos:[8,372] width:168 height:28 across:1 align:#left
	button 'btn_set_uv_face_ratio' "Set Texel Ratio to UV Face(s)" pos:[8,404] width:168 height:28 across:1 align:#left
	spinner 'spn_ratio_src' "Ratio:" pos:[12,140] width:120 height:16 range:[0,100000,0] align:#left
	spinner 'spn_ratio_trgt' "Ratio:" pos:[12,224] width:120 height:16 range:[0,100000,0] align:#left
	label 'lbl29' "px/m" pos:[132,224] width:30 height:17 across:2 align:#left
	
	on dlgTexelRatioUI open do
	(
		::gTexelRatioTools.initUIChannels ddlUV
		::gTexelRatioTools.initUITextureSizes ddl_texture_x_src
		::gTexelRatioTools.initUITextureSizes ddl_texture_y_src
		::gTexelRatioTools.initUITextureSizes ddl_texture_x_trgt
		::gTexelRatioTools.initUITextureSizes ddl_texture_y_trgt
	)
	
	on dlgTexelRatioUI close do
	(
		--::gTexelRatioTools.SaveConfig()
	)

	on btnGetRatio pressed do (
	
		if(selection.count == 0) do return (mcMsgList.warn "not_poly")
		local texture_width = ddl_texture_x_src.text as float
		local texture_height = ddl_texture_y_src.text as float
		local chnl  = ddlUV.selected as integer
		spn_ratio_src.value = (::gTexelRatioTools.GetTexelDensity gco texture_width texture_height cm_len chnl chckCollapse.checked) * 100
		
	)

	on btnSetRatio pressed do (
	
		local objs = selection as array
		if(objs.count == 0) do return (mcMsgList.warn "not_osel_xa")
		local texture_width = ddl_texture_x_trgt.text as float
		local texture_height = ddl_texture_y_trgt.text as float
		local chnl  = ddlUV.selected as integer
		spn_ratio_trgt.value = (::gTexelRatioTools.SetTexelDensityOnSelection objs (spn_ratio_src.value/100.0) texture_width texture_height chnl chckCollapse.checked) * 100
		clearUndoBuffer()
	)
	
	on btn_get_uv_face_ratio pressed do (
	
		local gco = modPanel.getcurrentObject()
		if classOf gco != Unwrap_UVW do return (mcMsgList.warn "not_unwrap")
		local fsel = gco.getSelectedFaces()
		if fsel.numberset != 1 do return (mcMsgList.warn "not_fseluv_1")
		local texture_width = ddl_texture_x_src.text as float
		local texture_height = ddl_texture_y_src.text as float
		local chnl  = ddlUV.selected as integer
		spn_ratio_src.value = (::gTexelRatioTools.GetTexelDensityUV gco fsel texture_width texture_height chnl) * 100
		clearUndoBuffer()
	)
	
	on btn_set_uv_face_ratio pressed do (
		
		local gco = modPanel.getcurrentObject()
		if classOf gco != Unwrap_UVW do return (mcMsgList.warn "not_unwrap")
		local fsel = gco.getSelectedFaces()
		if fsel.numberset == 0 do return (mcMsgList.warn "not_fseluv_x")
		local texture_width = ddl_texture_x_trgt.text as float
		local texture_height = ddl_texture_y_trgt.text as float
		
		local chnl  = ddlUV.selected as integer
		--get old texel density from result
		spn_ratio_trgt.value = (::gTexelRatioTools.SetTexelDensityUV gco fsel (spn_ratio_src.value/100.0) texture_width texture_height chnl) * 100
		clearUndoBuffer()
	)
)

if(::gTexelRatioToolsUI == undefined)then
(
	::gTexelRatioToolsUI = dlgTexelRatioUI
)

gTexelRatioTools.OpenDialog()
--createDialog gTexelRatioToolsUI