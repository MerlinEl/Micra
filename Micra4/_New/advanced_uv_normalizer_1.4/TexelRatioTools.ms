-- Hangar 13
-- https://hangar13games.com
-- Copyright (c) 2017 Hangar13. All Rights Reserved
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- struct takes care about Texel Density stuff
-- asociated file: TexelRatioToolsUI.ms
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


if(::gTexelRatioTools != undefined and ::gTexelRatioToolsUI != undefined)then destroyDialog ::gTexelRatioToolsUI

global gTexelRatioTools = undefined


----------------------------------------------------------------------------------------------------------------------------------------------
-- sTexelRatioTools
----------------------------------------------------------------------------------------------------------------------------------------------

struct sTexelRatioTools
(	
	texture_sizes = #("64", "128","256","512","1024","2048","4096", "8192"),
	map_channels = #("1","2","3","4"),
	isHold = false,
	cmLengthSize = 100.0,
	
	public function initUIChannels &ddl =
	(
		ddl.Items = map_channels
	),
	
	public function initUITextureSizes &ddl =
	(
		ddl.Items = texture_sizes
	),
	
	public function GetConfigProperty propName default type=
	(
		return ((::gSaveConfig.GetConfigProperty "P3DTexelRatioTools" propName default:default) as type)
	),

	public function ExistsModifier obj modClass =
	(
		for m in obj.modifiers do
		(
			if(classof m == modClass)then
			(
				return true
			)
		)
		return false
	),

	public function confirmReset =
	(
		hwnd = dialogMonitorOps.getWindowHandle()
		if UIAccessor.GetWindowText hwnd == "Unwrap UVW" then
		(
			UIAccessor.pressDefaultButton()
			true
		)
		else false
	),
	
	public function FilterInstances &inSelection =
	(
		mySelection = inSelection
		newSelection = #()
		for obj in mySelection do
		(
			myInstances = #()
			
			if InstanceMgr.GetInstances obj &myInstances > 0 then
			(
				if findItem newSelection myInstances[1] == 0 do
				(
					append newSelection myInstances[1]
					continue
				)
			)
		)
		inSelection = #()
		inSelection = newSelection
	),
	
	public function GetTexelDensity obj pixelSize_x pixelSize_y mapChannel isCollapseStack=
	(
		setCommandPanelTaskMode #modify
		maxOps.CollapseNodeTo obj 1 off
		unwrapUVWMod = Unwrap_UVW()
		addModifier obj unwrapUVWMod
		
		dialogMonitorOps.unRegisterNotification id:#unwrap_reset
			unwrapUVWMod.SetMapChannel mapChannel
			dialogMonitorOps.enabled = true
			dialogMonitorOps.interactive = false
		dialogMonitorOps.RegisterNotification confirmReset id:#unwrap_reset
		unwrapUVWMod.reset()
		dialogMonitorOps.enabled = false
		
		selPolys = #{1..obj.numFaces}
		subObjectLevel = 3
		unwrapUVWMod.selectFacesByNode #{} obj
		unwrapUVWMod.selectFacesByNode #{1..obj.numFaces} obj
		
		unwrapUVWMod.getAreaByNode selPolys &areaUVW &areaGeom obj
		subObjectLevel = 0
		sqrResolution = pixelSize_x * pixelSize_y * 1.0			-- px
		sqrRealLength = cmLengthSize * cmLengthSize * 1.0		-- cm
		avgAreaGeom = areaGeom / sqrRealLength
		avgAreaUVW = areaUVW/*/obj.numFaces*/
		
		texelDensity = sqrt ((sqrResolution * avgAreaUVW) / (sqrRealLength * avgAreaGeom))
		
		if(isCollapseStack)then
		(
			maxOps.CollapseNodeTo obj 1 off
			
		)
		
		return texelDensity
	),
	
	public function SetTexelDensityOnSelection inObjects newTexelDensity pixelSize_x pixelSize_y mapChannel collapseMod=
	(

		backupObjects = inObjects
		setCommandPanelTaskMode #modify
		maxOps.CollapseNodeTo obj 1 off
		filterInstances &inObjects		-- filters Instance Objects
		
		
		for obj in inObjects do (
			
			select obj
			oldTexelDensity = GetTexelDensity obj  pixelSize_x pixelSize_y mapChannel false
		
			newScale = newTexelDensity / oldTexelDensity
			
			subObjectLevel = 3
			obj.modifiers[#unwrap_uvw].selectFacesByNode #{} obj
			obj.modifiers[#unwrap_uvw].selectFacesByNode #{1..obj.numFaces} obj
			
			obj.modifiers[#unwrap_uvw].scaleSelectedCenter (newScale) 0
			subObjectLevel = 0
			
			if(collapseMod)then
			(
				
				maxOps.CollapseNodeTo obj 1 off
				
			)
		)
		
		select backupObjects
		oldTexelDensity
	),
	
	--UVW
	public function GetTexelDensityUV mod_uvw fsel pixelSize_x pixelSize_y mapChannel =(
	
		subObjectLevel = 3
		
		mod_uvw.getArea fsel &left &bottom &width &height &uv_area &area_geo
		
		sqrResolution = pixelSize_x * pixelSize_y * 1.0			-- px
		sqrRealLength = cmLengthSize * cmLengthSize * 1.0		-- cm
		avgAreaGeom = area_geo / sqrRealLength
		avgAreaUVW = uv_area
		
		texelDensity = sqrt ((sqrResolution * avgAreaUVW) / (sqrRealLength * avgAreaGeom))
		
		return texelDensity
	),
	
	public function SetTexelDensityUV mod_uvw fsel newTexelDensity pixelSize_x pixelSize_y mapChannel = (
	
		subObjectLevel = 3
		local first_uv_face =  #{(fsel as array)[1]}
		oldTexelDensity = GetTexelDensityUV mod_uvw first_uv_face pixelSize_x pixelSize_y mapChannel
	
		newScale = newTexelDensity / oldTexelDensity
		
		mod_uvw.scaleSelectedCenter (newScale) 0
		oldTexelDensity
	),
	
	public function SaveConfig =
	(		
		--SetDialogPos dlgTexelRatioUI ((gTexelRatioTools.GetConfigProperty edtRatio.name [600,600] point2) as point2)
		local dialogPos = GetDialogPos ::gTexelRatioToolsUI
		-- ::gSaveConfig.SetConfigProperty "P3DTexelRatioTools" "pos" #point2 dialogPos
		-- ::gSaveConfig.SetConfigProperty "P3DTexelRatioTools" ::gTexelRatioToolsUI.edtTexture.name #float (::gTexelRatioToolsUI.edtTexture.text as integer)
-- 		::gSaveConfig.SetConfigProperty "P3DTexelRatioTools" ::gTexelRatioToolsUI.edtTexture.name #float (1024 as integer)
		-- ::gSaveConfig.SetConfigProperty "P3DTexelRatioTools" ::gTexelRatioToolsUI.ddlUV.name #float (::gTexelRatioToolsUI.ddlUV.selection as integer)
		-- ::gSaveConfig.SetConfigProperty "P3DTexelRatioTools" ::gTexelRatioToolsUI.edtRatio.name #float (::gTexelRatioToolsUI.edtRatio.text as float)
		-- ::gSaveConfig.SetConfigProperty "P3DTexelRatioTools" ::gTexelRatioToolsUI.edtSpacing.name #float (::gTexelRatioToolsUI.edtSpacing.text as float)
		-- ::gSaveConfig.SetConfigProperty "P3DTexelRatioTools" ::gTexelRatioToolsUI.chckNormalize.name #boolean (::gTexelRatioToolsUI.chckNormalize.checked as booleanClass)
		-- ::gSaveConfig.SetConfigProperty "P3DTexelRatioTools" ::gTexelRatioToolsUI.chckRotate.name #boolean (::gTexelRatioToolsUI.chckRotate.checked as booleanClass)
		-- ::gSaveConfig.SetConfigProperty "P3DTexelRatioTools" ::gTexelRatioToolsUI.chckFillHoles.name #boolean (::gTexelRatioToolsUI.chckFillHoles.checked as booleanClass)
		-- ::gSaveConfig.SetConfigProperty "P3DTexelRatioTools" ::gTexelRatioToolsUI.chckCollapse.name #boolean (::gTexelRatioToolsUI.chckCollapse.checked as booleanClass)
		-- ::gSaveConfig.SetConfigProperty "P3DTexelRatioTools" ::gTexelRatioToolsUI.chckRescale.name #boolean (::gTexelRatioToolsUI.chckRescale.checked as booleanClass)
		
	),
	
	public function CloseDialog =
	(
		destroyDialog ::gTexelRatioToolUI
	),
	
	public function OpenDialog =
	(
		createDialog ::gTexelRatioToolsUI
	),
	
	-- public function LoadConfig &edtPixelSize &ddlUV =
	-- (
		-- edtPixelSize.text = (::gSaveConfig.GetConfigProperty "P3DTexelRatioTools" "PixelSizeSel" default:512) as string
		-- ddlUV.Selection = ::gSaveConfig.GetConfigProperty "P3DTexelRatioTools" "UVSel" default:1
	-- ),
	
	function Init =
	(
		-- This function is initializing muhehe
	)
)

-------------------------------------------------------------------------------
-- INIT
-------------------------------------------------------------------------------
if(::gTexelRatioTools == undefined)then
(
	::gTexelRatioTools = sTexelRatioTools()
	::gTexelRatioTools.Init()
)
