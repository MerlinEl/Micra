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
	isHold = false,
	myItems = #("128","256","512","1024","2048","4096", "8192"),
	myUVs = #("1","2","3","4"),
	cmLengthSize = 100.0,
	
	public function GetUVs &ddlUVs =
	(
		ddlUVs.Items = myUVs
	),
	
	public function GetConfigProperty propName default type=
	(
		return ((::gSaveConfig.GetConfigProperty "P3DTexelRatioTools" propName default:default) as type)
	),
	
	public function GetPixelSizes &ddlPixels=
	(
		--ddlPixels.items = myItems
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
	
	public function GetTexelDensity obj pixelSize_x pixelSize_y lengthSize mapChannel isCollapseStack=
	(
-- 		pixelSize_x = 1024													-- this is not nice, but its fixed so what? Sue me universe!
-- 		print pixelSize_x
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
		sqrRealLength = lengthSize * lengthSize * 1.0		-- cm
		avgAreaGeom = areaGeom / sqrRealLength
		avgAreaUVW = areaUVW/*/obj.numFaces*/
		
		texelDensity = sqrt ((sqrResolution * avgAreaUVW) / (sqrRealLength * avgAreaGeom))
		
		if(isCollapseStack)then
		(
			maxOps.CollapseNodeTo obj 1 off
			
		)
		
		return texelDensity
	),
	
	public function SetTexelDensityOnSelection inObjects newTexelDensity pixelSize_x pixelSize_y lengthSize mapChannel collapseMod=
	(
-- 		pixelSize_x = 512													-- this is not nice, but its fixed so what? Sue me universe!
		
-- 		print newTexelDensity
-- 		print pixelSize_x
		backupObjects = inObjects
		setCommandPanelTaskMode #modify
		maxOps.CollapseNodeTo obj 1 off
		::gP3DChannelInfoTools.FilterInstances &inObjects		-- filters Instance Objects
		
		
		for obj in inObjects do
		(
			
			select obj
			
			oldTexelDensity = GetTexelDensity obj  pixelSize_x pixelSize_y lengthSize mapChannel false
			
			--oldTexelDensity = GetTexelDensity obj  pixelSize_x lengthSize mapChannel false
			
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
	),
	
	public function PackSelection inObjects spacing isNormalized isRotate isFillHoles mapChannel collapseMod isRescale=
	(
		setCommandPanelTaskMode #modify
		::gP3DChannelInfoTools.FilterInstances &inObjects
		
		for obj in inObjects do
		(
			select obj
			unwrapUVWMod
			if(ExistsModifier obj Unwrap_UVW == false)then
			(
				unwrapUVWMod = Unwrap_UVW()
				addModifier obj unwrapUVWMod	
			)
			else
			(
				unwrapUVWMod = obj.modifiers[#unwrap_uvw]
			)
			
			dialogMonitorOps.unRegisterNotification id:#unwrap_reset
				unwrapUVWMod.SetMapChannel mapChannel
				dialogMonitorOps.enabled = true
				dialogMonitorOps.interactive = false
			dialogMonitorOps.RegisterNotification confirmReset id:#unwrap_reset
			unwrapUVWMod.reset()
			dialogMonitorOps.enabled = false
			
			subObjectLevel = 3
			unwrapUVWMod.selectFacesByNode #{} obj
			unwrapUVWMod.selectFacesByNode #{1..obj.numFaces} obj
			
			
			unwrapUVWMod.SetPackRescaleCluster isRescale
			unwrapUVWMod.pack 2 spacing isNormalized isRotate isFillHoles
			
			
			subObjectLevel = 0
			
			if(collapseMod)then
			(
				maxOps.CollapseNodeTo obj 1 off
			)
		)
		select inObjects
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
		::P3DLogL "START: TexelRatioTools"
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



macroScript TexelRatioTools
category:"Pivo3D"
tooltip:"Texel Ratio Tools"
buttonText:"Texel Ratio Tools"
Icon:#("P3DIcons",10)
(
	on execute do ::gTexelRatioTools.OpenDialog()
)

-- gTexelRatioTools.OpenDialog()