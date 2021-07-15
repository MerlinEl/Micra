-------------------------------------------------------------------------------
-- blendedBoxMapMaker.ms
-- By Neil Blevins (info@neilblevins.com)
-- v 3.11
-- Created On: 02/14/08
-- Modified On: 05/21/17
-- tested using Max 2017
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Required Files:
-- sLib.ms
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Description:
-- Creates a Blended Box Map for your selected objects. Basically, it's 
-- box mapping, but the edges of the box are blended so you can place the
-- map on a curved surface and not have horrible seams.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Tutorial:
-- For Pre Max 2018: 
-- Make a sphere. Run the script in UI mode. Select an image you'd like mapped 
-- to the sphere (something tilable is ideal). Choose Falloff Method and 
-- UVWMapping Method. Hit Do. Your object will now have 3 new mapping modifiers 
-- assigned to it, and the medit slot of your choice will have a map tree that 
-- you can put into the object's color slot, bump slot, etc. Adjust the curves 
-- on the 2 falloff maps to get harder or softer blends on the box edges.
--
-- For Post Max 2018: 
-- Make a sphere. Run the script in UI mode. Select an image you'd like mapped 
-- to the sphere (something tilable is ideal). Choose Vray Triplanar Method. 
-- Uncheck "Create Mapping Modifiers". Hit Do. The medit slot of your choice 
-- will now have a VrayTriplanarTex map that you can put into the object's color 
-- slot, bump slot, etc.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Revision History:
--
-- v 1.01 Added ability to clear mapping modifiers from selected objects. Added
-- controls to only do the maps or only do the modifiers. Now can use the
-- selected medit slot, or a specific one.
--
-- v 1.02 Added tiling control to the modifiers. Added two new box types.
--
-- v 1.03 Cleaned Up The UI a bit. Added a way to name the modifiers.
--
-- v 1.04 Replaced the Close button with a Help button. Use the X button to 
-- Close the Floater.
--
-- v 1.05 Added a way to specify the size of the modifiers.
--
-- v 1.06 Fixed a bug that would crash the script when reading in defs.
--
-- v 1.07 Fixed a bug that would crash the script when given a blank map name.
--
-- v 1.08 Some UI wasn't turning on and off properly, now it does.
--
-- v 1.09 Removed the align option and turned it on permanently, as there's no
-- reason not to have this on.
--
-- v 1.10 Added ability to change the Tile Amount of the maps, separate from 
-- the Tile Amount on the modifiers.
--
-- v 2.00 Added support for CameraMapGemini plugin (v0.16) by Markus Boos 
-- (http://www.projectgemini.net/CameraMapGemini/). The script can now use 2 methods,
-- UVW Mapping Method and CameraMapGemini Method. The UVWMapping method works the
-- same as the old method. The CameraMapGemini Method creates the same sort of
-- mapping, except using cameras for projection. The main advantage to this method
-- is the cameras exist as a rig in world space. So moving objects after applying
-- the blendedBoxMap does not misalign the projection. For more information, visit 
-- http:/www.neilblevins.com and look for the blendedBoxMap tutorial in the
-- education section.
--
-- v 2.01 Fixed a crash bug that would occur if not every object you selected was
-- geometry.
--
-- v 2.02 Added better defaults for Angle Blend Threshold. Added better names
-- for the maps the script creates. Cleaned up some code. Now you can rotate the 
-- different projections randomly, which can give you better results when you don't 
-- need your pattern to line up. Added a 6 sided projection CameraMapGemini mode, 
-- which produces better results on highly curved objects like spheres and 
-- cylinders. Now hooks up the crop of the maps to each other through wiring, 
-- so changing the crop of one map affects all maps equally.
--
-- v 2.03 Works with Real World Mapping now.
--
-- v 2.04 Fixed an issue with the cameraMapGemini mode by moving the cameras 
-- further away from the object. This workaround will have to do until a 
-- cameraMapGemini bug gets fixed.
--
-- v 2.05 Change CameraMapGemini Distance to a Multiplier.
--
-- v 2.06 I completely botched up the distance calculation for the placement
-- of the CameraMapGemini cameras. This fixes that. Uniquifies camera names.
--
-- v 2.07 Makes a much more accurate calculation on the "Auto Calculate Size"
-- for the mapping UVW modifiers.
--
-- v 3.00 Now you can mix and match map types and mapping types. Removed the 
-- unneeded 6 side mode.
--
-- v 3.01 Adjusted both the UVWMapping and CameramapGemini Auto Calculate Size
-- so they now match.
--
-- v 3.02 Now you can place the BlendedBoxMap Map into the Slate Material 
-- Editor.
--
-- v 3.03 Cleaned up a lot of code. Fixed a problem that meant the specific
-- size spinner didn't work properly.
--
-- v 3.10 You can now create a BlendedBoxMap using max's BlendedBoxMap 
-- map. Also added compatibility with vray's Triplanartex map.
--
-- v 3.11 Fixed some UI that wasn't disabling properly.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Known Issues:
-- These are not issues with the script, but known issues with the CameraMapGemini
-- plugin, which seem worth mentionning here. 1) CameraMapGemini doesn't work in 
-- mentalray 2) CameraMapGemini doesn't support bump mapping yet 3) CameraMapGemini
-- takes a little longer to render than the UVWMapping method. I've seen a 2x 
-- slowdown rendering objects.
-- 
-- If when using CameraMapGemini you see more blending than you'd expect, try 
-- increasing the CameraMapGemini Camera Distance Multiplier.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
(
-- Globals

global blendedBoxMapMaker
global blendedBoxMapMakerDefaults
global blendedBoxMapMakerUI

global bBMMCloseOpenUI

global bBMMDoMapFunction
global bBMMDoMappingFunction

global bBMMDo
global bBMMApply
global bBMMHelp
global bBMMLoadDef
global bBMMSaveDef

global bBMMDefineUI
global bBMMRollout
global bBMMFloater

-- Includes

include "$scripts\SoulburnScripts\lib\sLib.ms"

-- Variables

bBMMDoMapValue = true
bBMMMapTypeValue = 3
bBMMDoMappingValue = false
bBMMMappingTypeValue = 2
bBMMTopImageValue = ""
bBMMMeditSlotTypeValue = 1
bBMMMeditSlotValue = 1
bBMMMapTileValue = 1.0
bBMMTriScaleValue = 0.01
bBMMTriBlendValue = 0.3
bBMMMaxScaleValue = 100.0
bBMMMaxBlendValue = 25.0
bBMMTopChannelValue = 2
bBMMRightChannelValue = 3
bBMMFrontChannelValue = 4
bBMMShowWarningValue = true
bBMMModifierNameValue = ""
bBMMModTileValue = 1.0
bBMMCalculateSizeValue = true
bBMMSpecificSizeValue = 100.0
bBMMMapRotateValue = true
bBMMGeminiDistanceValue = 3.0
bBMMPosValue = [400,400]

-- Functions

fn blendedBoxMapMaker bBMMDoMap bBMMMapType bBMMDoMapping bBMMMappingType bBMMTopImage bBMMMeditSlotType bBMMMeditSlot bBMMMapTile bBMMTriScale bBMMTriBlend bBMMMaxScale bBMMMaxBlend bBMMTopChannel bBMMRightChannel bBMMFrontChannel bBMMShowWarning bBMMModifierName bBMMModTile bBMMCalculateSize bBMMSpecificSize bBMMMapRotate bBMMGeminiDistance = 
	(
	themap = bBMMDoMapFunction bBMMDoMap bBMMMapType bBMMDoMapping bBMMMappingType bBMMTopImage bBMMMeditSlotType bBMMMeditSlot bBMMMapTile bBMMTriScale bBMMTriBlend bBMMMaxScale bBMMMaxBlend bBMMTopChannel bBMMRightChannel bBMMFrontChannel bBMMShowWarning bBMMModifierName bBMMModTile bBMMCalculateSize bBMMSpecificSize bBMMMapRotate bBMMGeminiDistance
	bBMMDoMappingFunction themap bBMMDoMap bBMMMapType bBMMDoMapping bBMMMappingType bBMMTopImage bBMMMeditSlotType bBMMMeditSlot bBMMMapTile bBMMTriScale bBMMTriBlend bBMMMaxScale bBMMMaxBlend bBMMTopChannel bBMMRightChannel bBMMFrontChannel bBMMShowWarning bBMMModifierName bBMMModTile bBMMCalculateSize bBMMSpecificSize bBMMMapRotate bBMMGeminiDistance
	)
	
fn blendedBoxMapMakerDefaults = 
	(
	bBMMLoadDef()
	blendedBoxMapMaker bBMMDoMapValue bBMMMapTypeValue bBMMDoMappingValue bBMMMappingTypeValue bBMMTopImageValue bBMMMeditSlotTypeValue bBMMMeditSlotValue bBMMMapTileValue bBMMTriScaleValue bBMMTriBlendValue bBMMMaxScaleValue bBMMMaxBlendValue bBMMTopChannelValue bBMMRightChannelValue bBMMFrontChannelValue bBMMShowWarningValue bBMMModifierNameValue bBMMModTileValue bBMMCalculateSizeValue bBMMSpecificSizeValue bBMMMapRotateValue bBMMGeminiDistanceValue
	)
	
fn blendedBoxMapMakerUI = 
	(
	bBMMLoadDef()
	bBMMCloseOpenUI bBMMPosValue
	)
	
fn bBMMCloseOpenUI pos = 
	(
	if bBMMFloater != undefined then CloseRolloutFloater bBMMFloater
	bBMMDefineUI()
	bBMMFloater = newRolloutFloater "blendedBoxMapMaker v3.11" 450 488 pos.x pos.y
	addRollout bBMMRollout bBMMFloater
	)
	
fn bBMMDoMapFunction bBMMDoMap bBMMMapType bBMMDoMapping bBMMMappingType bBMMTopImage bBMMMeditSlotType bBMMMeditSlot bBMMMapTile bBMMTriScale bBMMTriBlend bBMMMaxScale bBMMMaxBlend bBMMTopChannel bBMMRightChannel bBMMFrontChannel bBMMShowWarning bBMMModifierName bBMMModTile bBMMCalculateSize bBMMSpecificSize bBMMMapRotate bBMMGeminiDistance = 
	(
	mymap = undefined
	if bBMMDoMap == true then
		(
		-- Create The Map
		if bBMMMapType == 1 then
			(
			mymap = Mix ()
			mymap.name = (getFilenameFile bBMMTopImage) + "BBM"

			mymap.map1 = Mix ()
			mymap.map1.name = "TopRight"

			mymap.map2 = Bitmaptexture fileName:bBMMTopImage
			mymap.map2.name = "FrontTex"
			mymap.map2.coordinates.mapChannel = bBMMFrontChannel
			mymap.map2.coords.U_Tiling = bBMMMapTile
			mymap.map2.coords.V_Tiling = bBMMMapTile
			if bBMMMapRotate == true then mymap.map2.coords.W_Angle = 0

			mymap.Mask = falloff ()
			mymap.Mask.name = "FrontRightTopBlend"
			mymap.Mask.type = 1
			mymap.Mask.direction = 5
			mymap.Mask.color1 = white
			mymap.Mask.color2 = black

			mymap.map1.map1 = Bitmaptexture fileName:bBMMTopImage
			mymap.map1.map1.name = "TopTex"
			mymap.map1.map1.coordinates.mapChannel = bBMMTopChannel
			mymap.map1.map1.coords.U_Tiling = bBMMMapTile
			mymap.map1.map1.coords.V_Tiling = bBMMMapTile
			if bBMMMapRotate == true then mymap.map2.coords.W_Angle = 35
			paramWire.connect2way mymap.map1.map1[#Clip_U_Offset] mymap.map2[#Clip_U_Offset] "Clip_U_Offset" "Clip_U_Offset"
			paramWire.connect2way mymap.map1.map1[#Clip_V_Offset] mymap.map2[#Clip_V_Offset] "Clip_V_Offset" "Clip_V_Offset"
			paramWire.connect2way mymap.map1.map1[#Clip_U_Width] mymap.map2[#Clip_U_Width] "Clip_U_Width" "Clip_U_Width"
			paramWire.connect2way mymap.map1.map1[#Clip_V_Width] mymap.map2[#Clip_V_Width] "Clip_V_Width" "Clip_V_Width"

			mymap.map1.map2 = Bitmaptexture fileName:bBMMTopImage
			mymap.map1.map2.name = "RightTex"
			mymap.map1.map2.coordinates.mapChannel = bBMMRightChannel
			mymap.map1.map2.coords.U_Tiling = bBMMMapTile
			mymap.map1.map2.coords.V_Tiling = bBMMMapTile
			if bBMMMapRotate == true then mymap.map1.map2.coords.W_Angle = 70
			paramWire.connect2way mymap.map1.map2[#Clip_U_Offset] mymap.map2[#Clip_U_Offset] "Clip_U_Offset" "Clip_U_Offset"
			paramWire.connect2way mymap.map1.map2[#Clip_V_Offset] mymap.map2[#Clip_V_Offset] "Clip_V_Offset" "Clip_V_Offset"
			paramWire.connect2way mymap.map1.map2[#Clip_U_Width] mymap.map2[#Clip_U_Width] "Clip_U_Width" "Clip_U_Width"
			paramWire.connect2way mymap.map1.map2[#Clip_V_Width] mymap.map2[#Clip_V_Width] "Clip_V_Width" "Clip_V_Width"

			mymap.map1.Mask = falloff ()
			mymap.map1.Mask.name = "TopRightBlend"
			mymap.map1.Mask.type = 1
			mymap.map1.Mask.direction = 6
			)
		else if bBMMMapType == 2 then
			(
			if sLibCameraMapGeminiMapTest() == false then (MessageBox "Please install the Markus Boos Plugin sLibCameraMapGeminiMapTest to use this method" title:"blendedBoxMapMaker")
			else
				(
				mymap = CompositeTexturemap ()
				mymap.name = (getFilenameFile bBMMTopImage) + "BBM"
				mymap.mapEnabled.count = 3
				mymap.layername[1] = "Top"
				mymap.layername[2] = "Right"
				mymap.layername[3] = "Front"
				
				mymap.mapList[1] = CameraMapGeminiMap ()
				mymap.mapList[1].name = "TopTexProj"
				mymap.mapList[1].map01 = Bitmaptexture fileName:bBMMTopImage
				mymap.mapList[1].map01.name = "TopTex"
				mymap.mapList[1].map01.coordinates.mapChannel = bBMMTopChannel
				mymap.mapList[1].map01.coords.U_Tiling = bBMMMapTile
				mymap.mapList[1].map01.coords.V_Tiling = bBMMMapTile
				if bBMMMapRotate == true then mymap.mapList[1].map01.coords.W_Angle = 35
				mymap.mapList[1].backFace = on
				mymap.mapList[1].rearProjection = on
				mymap.mapList[1].angleThresholdActive = off
				mymap.mapList[1].angleThresholdMin = 60
				mymap.mapList[1].angleThresholdMax = 85
				mymap.mapList[1].angleThresholdSymmetric = on
				mymap.mapList[1].applyBlendingToMonoChannel = on
				mymap.mapList[1].useMaskForMonoChannel01 = on
				
				mymap.mapList[2] = CameraMapGeminiMap ()
				mymap.mapList[2].name = "RightTexProj"
				mymap.mapList[2].map01 = Bitmaptexture fileName:bBMMTopImage
				mymap.mapList[2].map01.name = "RightTex"
				mymap.mapList[2].map01.coordinates.mapChannel = bBMMRightChannel
				mymap.mapList[2].map01.coords.U_Tiling = bBMMMapTile
				mymap.mapList[2].map01.coords.V_Tiling = bBMMMapTile
				if bBMMMapRotate == true then mymap.mapList[2].map01.coords.W_Angle = 70
				paramWire.connect2way mymap.mapList[2].map01[#Clip_U_Offset] mymap.mapList[1].map01[#Clip_U_Offset] "Clip_U_Offset" "Clip_U_Offset"
				paramWire.connect2way mymap.mapList[2].map01[#Clip_V_Offset] mymap.mapList[1].map01[#Clip_V_Offset] "Clip_V_Offset" "Clip_V_Offset"
				paramWire.connect2way mymap.mapList[2].map01[#Clip_U_Width] mymap.mapList[1].map01[#Clip_U_Width] "Clip_U_Width" "Clip_U_Width"
				paramWire.connect2way mymap.mapList[2].map01[#Clip_V_Width] mymap.mapList[1].map01[#Clip_V_Width] "Clip_V_Width" "Clip_V_Width"
				mymap.mapList[2].backFace = on
				mymap.mapList[2].rearProjection = on
				mymap.mapList[2].angleThresholdActive = on
				mymap.mapList[2].angleThresholdMin = 60
				mymap.mapList[2].angleThresholdMax = 85
				mymap.mapList[2].angleThresholdSymmetric = on
				mymap.mapList[2].applyBlendingToMonoChannel = on
				mymap.mapList[2].useMaskForMonoChannel01 = on
				
				mymap.mapList[3] = CameraMapGeminiMap ()
				mymap.mapList[3].name = "FrontTexProj"
				mymap.mapList[3].map01 = Bitmaptexture fileName:bBMMTopImage
				mymap.mapList[3].map01.name = "FrontTex"
				mymap.mapList[3].map01.coordinates.mapChannel = bBMMFrontChannel
				mymap.mapList[3].map01.coords.U_Tiling = bBMMMapTile
				mymap.mapList[3].map01.coords.V_Tiling = bBMMMapTile
				if bBMMMapRotate == true then mymap.mapList[3].map01.coords.W_Angle = 0
				paramWire.connect2way mymap.mapList[3].map01[#Clip_U_Offset] mymap.mapList[1].map01[#Clip_U_Offset] "Clip_U_Offset" "Clip_U_Offset"
				paramWire.connect2way mymap.mapList[3].map01[#Clip_V_Offset] mymap.mapList[1].map01[#Clip_V_Offset] "Clip_V_Offset" "Clip_V_Offset"
				paramWire.connect2way mymap.mapList[3].map01[#Clip_U_Width] mymap.mapList[1].map01[#Clip_U_Width] "Clip_U_Width" "Clip_U_Width"
				paramWire.connect2way mymap.mapList[3].map01[#Clip_V_Width] mymap.mapList[1].map01[#Clip_V_Width] "Clip_V_Width" "Clip_V_Width"
				mymap.mapList[3].backFace = on
				mymap.mapList[3].rearProjection = on
				mymap.mapList[3].angleThresholdActive = on
				mymap.mapList[3].angleThresholdMin = 60
				mymap.mapList[3].angleThresholdMax = 85
				mymap.mapList[2].angleThresholdSymmetric = on
				mymap.mapList[3].applyBlendingToMonoChannel = on
				mymap.mapList[3].useMaskForMonoChannel01 = on
				)
			)
		else if bBMMMapType == 3 then
			(
			if sLibVrayTest() == false then (MessageBox "Please install vray to use this feature" title:"blendedBoxMapMaker")
			else
				(
				mymap = VrayTriPlanarTex ()
				mymap.name = (getFilenameFile bBMMTopImage) + "BBM"
				mymap.texture_mode = 0
				mymap.texture = Bitmaptexture fileName:bBMMTopImage
				mymap.scale = bBMMTriScaleValue
				mymap.blend = bBMMTriBlendValue
				if bBMMMapRotate == true then mymap.texture_rotation = [290,35,0]
				)
			)
		else if bBMMMapType == 4 then
			(
			if (classof BlendedBoxMap) == UndefinedClass then (MessageBox "Only works in max 2017 Ext 1 and above." title:"blendedBoxMapMaker")
			else
				(
				mymap = BlendedBoxMap ()
				mymap.name = (getFilenameFile bBMMTopImage) + "BBM"
				mymap.mode = 0
				mymap.texturespace = 0
				mymap.tex[1] = Bitmaptexture fileName:bBMMTopImage
				mymap.mapscale = bBMMMaxScaleValue
				mymap.Blend = bBMMMaxBlendValue
				if bBMMMapRotate == true then 
					(
					mymap.rota = 0
					mymap.rotb = 290
					mymap.rotc = 35
					)
				)
			)
		
		-- Place the map
		if mymap != undefined then
			(
			if bBMMMeditSlotType == 1 then meditMaterials[(medit.GetActiveMtlSlot())] = mymap
			else if bBMMMeditSlotType == 2 then meditMaterials[bBMMMeditSlot] = mymap
			else if bBMMMeditSlotType == 3 then
				(
				if (sme.IsOpen()) == false then (sme.Open())
				CurrentSMEView = sme.getView (sme.activeView)
				CurrentSMEView.CreateNode mymap [0,0]
				)
			else if bBMMMeditSlotType == 4 then
				(
				-- Do not place the map in Medit and just return the map
				)
			)
		)
	return mymap
	)
	
fn bBMMDoMappingFunction inputmap bBMMDoMap bBMMMapType bBMMDoMapping bBMMMappingType bBMMTopImage bBMMMeditSlotType bBMMMeditSlot bBMMMapTile bBMMTriScale bBMMTriBlend bBMMMaxScale bBMMMaxBlend bBMMTopChannel bBMMRightChannel bBMMFrontChannel bBMMShowWarning bBMMModifierName bBMMModTile bBMMCalculateSize bBMMSpecificSize bBMMMapRotate bBMMGeminiDistance = 
	(
	bBMMfinalCams = #()
	bBMMCamsPoint = #()
	if bBMMDoMapping == true then
		(
		if selection.count !=0 then
			(
			bBMMObjs = #()
			for i in selection do (if ValidModifier i UVWMap then append bBMMObjs i)
			select bBMMObjs
			if bBMMShowWarning == true then (if (queryBox "In general, the mapping modifiers don't work properly with objects that have been heavily transformed (especially rotated). We recommend performing a Reset Xform on your objects before adding the mapping modifiers. Have you performed this operation?" title:"blendedBoxMapMaker") == false then return false)

			-- Decide projection size
			w = 1024.00;h = 1024.00
			if bBMMDoMap == true then (if bBMMTopImage != undefined and bBMMTopImage != "" then (w = (getBitmapInfo bBMMTopImage)[3];h = (getBitmapInfo bBMMTopImage)[4]))

			-- Get Selection Boundingbox
			objsBoundingBox = sLibGetCollectionBBox bBMMObjs
			objsCenter = [(objsBoundingBox[1].x + objsBoundingBox[2].x)/2, (objsBoundingBox[1].y + objsBoundingBox[2].y)/2, (objsBoundingBox[1].z + objsBoundingBox[2].z)/2]
			xLength = abs(objsBoundingBox[2].x-objsBoundingBox[1].x)
			yLength = abs(objsBoundingBox[2].y-objsBoundingBox[1].y)
			zLength = abs(objsBoundingBox[2].z-objsBoundingBox[1].z)

			-- Calculate squareSize
			if bBMMCalculateSize == true then
				(
				-- Top
				if xLength > yLength then squareSizeZ = (xLength/2) * 2.5
				else squareSizeZ = (yLength/2) * (w/h) * 2.5

				-- Right
				if yLength > zLength then squareSizeX = (yLength/2) * 2.5
				else squareSizeX = (zLength/2) * (w/h) * 2.5

				-- Front
				if xLength > zLength then squareSizeY = (xLength/2) * 2.5
				else squareSizeY = (zLength/2) * (w/h) * 2.5

				squareSize = amax #(squareSizeX, squareSizeY, squareSizeZ)
				)
			else squareSize = bBMMSpecificSize*1.207			

			if bBMMMappingType == 1 then
				(
				-- Make Modifiers
				max modify mode

				modPanel.addModToSelection (Uvwmap ()) ui:on
				(modPanel.getCurrentObject ()).name = ("BBM_" + bBMMModifierName + "_Top")
				(modPanel.getCurrentObject ()).maptype = 0
				if (modPanel.getCurrentObject ()).realWorldMapSize == off then
					(
					(modPanel.getCurrentObject ()).length = squareSize*0.8285
					(modPanel.getCurrentObject ()).width = squareSize*0.8285
					(modPanel.getCurrentObject ()).height = squareSize*0.8285
					)
				(modPanel.getCurrentObject ()).utile = bBMMModTile
				(modPanel.getCurrentObject ()).vtile = bBMMModTile
				(modPanel.getCurrentObject ()).wtile = bBMMModTile
				(modPanel.getCurrentObject ()).mapChannel = bBMMTopChannel
				(modPanel.getCurrentObject ()).axis = 2

				modPanel.addModToSelection (Uvwmap ()) ui:on
				(modPanel.getCurrentObject ()).name = ("BBM_" + bBMMModifierName + "_Right")
				(modPanel.getCurrentObject ()).maptype = 0
				if (modPanel.getCurrentObject ()).realWorldMapSize == off then
					(
					(modPanel.getCurrentObject ()).length = squareSize*0.8285
					(modPanel.getCurrentObject ()).width = squareSize*0.8285
					(modPanel.getCurrentObject ()).height = squareSize*0.8285
					)
				(modPanel.getCurrentObject ()).utile = bBMMModTile
				(modPanel.getCurrentObject ()).vtile = bBMMModTile
				(modPanel.getCurrentObject ()).wtile = bBMMModTile
				(modPanel.getCurrentObject ()).mapChannel = bBMMRightChannel
				(modPanel.getCurrentObject ()).axis = 0
				(modPanel.getCurrentObject ()).gizmo.rotation.x_rotation = -90 
				(modPanel.getCurrentObject ()).gizmo.rotation.z_rotation = 0

				modPanel.addModToSelection (Uvwmap ()) ui:on
				(modPanel.getCurrentObject ()).name = ("BBM_" + bBMMModifierName + "_Front")
				(modPanel.getCurrentObject ()).maptype = 0
				if (modPanel.getCurrentObject ()).realWorldMapSize == off then
					(
					(modPanel.getCurrentObject ()).length = squareSize*0.8285
					(modPanel.getCurrentObject ()).width = squareSize*0.8285
					(modPanel.getCurrentObject ()).height = squareSize*0.8285
					)
				(modPanel.getCurrentObject ()).utile = bBMMModTile
				(modPanel.getCurrentObject ()).vtile = bBMMModTile
				(modPanel.getCurrentObject ()).wtile = bBMMModTile
				(modPanel.getCurrentObject ()).mapChannel = bBMMFrontChannel
				(modPanel.getCurrentObject ()).axis = 1
				)
			else if bBMMMappingType == 2 then
				(
				if sLibCameraMapGeminiMapTest() == false then (MessageBox "Please install the Markus Boos Plugin sLibCameraMapGeminiMapTest to use this method" title:"blendedBoxMapMaker")
				else
					(
					-- Make Cameras
					-- Top
					newCamTop = Targetcamera pos:[objsCenter.x,objsCenter.y,objsCenter.z+(squareSize*bBMMGeminiDistance)] target:(Targetobject transform:(matrix3 [1,0,0] [0,1,0] [0,0,1] [objsCenter.x,objsCenter.y,objsCenter.z]))
					newCamTop.showCone = true
					newCamTop.orthoProjection = true
					newCamTop.name = uniqueName ("BBM_" + bBMMModifierName + "_TopProjection")
					newCamTop.type = #free
					newCamTop.target_Distance = squareSize
					-- Right
					newCamRight = Targetcamera pos:[objsCenter.x+(squareSize*bBMMGeminiDistance),objsCenter.y,objsCenter.z] target:(Targetobject transform:(matrix3 [1,0,0] [0,1,0] [0,0,1] [objsCenter.x,objsCenter.y,objsCenter.z]))
					newCamRight.showCone = true
					newCamRight.orthoProjection = true
					newCamRight.name = uniqueName ("BBM_" + bBMMModifierName + "_RightProjection")
					newCamRight.type = #free
					newCamRight.target_Distance = squareSize
					-- Front
					newCamFront = Targetcamera pos:[objsCenter.x,objsCenter.y-(squareSize*bBMMGeminiDistance),objsCenter.z] target:(Targetobject transform:(matrix3 [1,0,0] [0,1,0] [0,0,1] [objsCenter.x,objsCenter.y,objsCenter.z]))
					newCamFront.showCone = true
					newCamFront.orthoProjection = true
					newCamFront.name = uniqueName ("BBM_" + bBMMModifierName + "_FrontProjection")
					newCamFront.type = #free
					newCamFront.target_Distance = squareSize
					-- Camera Array
					bBMMfinalCams = #()
					append bBMMfinalCams newCamTop
					append bBMMfinalCams newCamRight
					append bBMMfinalCams newCamFront
					-- Group Cameras
					myPoint = Point box:on cross_radius:10 filter_vertices:off filter_envelopes:on filter_cross_sections:on draw_all_envelopes:off draw_vertices:on paint_feather:0.7 paint_radius:24 paint_str:0.1 ref_frame:0 always_deform:on transform:(matrix3 [1,0,0] [0,0,1] [0,-1,0] objsCenter)
					myPoint.size = 2*squareSize
					myPoint.name = ("BBM_" + bBMMModifierName + "_ProjectionCameraGroup")
					for i in bBMMfinalCams do i.parent = myPoint
					bBMMCamsPoint = myPoint

					-- Make Modifier
					max modify mode

					modPanel.addModToSelection (CameraMapGeminiModifier ()) ui:on
					(modPanel.getCurrentObject ()).name = ("BBM_" + bBMMModifierName + "Projection")
					
					(modPanel.getCurrentObject ()).nodeCam01 = newCamTop
					(modPanel.getCurrentObject ()).mapChannel0l = bBMMTopChannel
					(modPanel.getCurrentObject ()).width01 = w
					(modPanel.getCurrentObject ()).height01 = h
					
					(modPanel.getCurrentObject ()).nodeCam02 = newCamRight
					(modPanel.getCurrentObject ()).mapChannel02 = bBMMRightChannel
					(modPanel.getCurrentObject ()).width02 = w
					(modPanel.getCurrentObject ()).height02 = h
					
					(modPanel.getCurrentObject ()).nodeCam03 = newCamFront
					(modPanel.getCurrentObject ()).mapChannel03 = bBMMFrontChannel
					(modPanel.getCurrentObject ()).width03 = w
					(modPanel.getCurrentObject ()).height03 = h
					)
				)
			)
		)
	return #(bBMMfinalCams,bBMMCamsPoint)
	)
	
fn bBMMDo = 
	(
	blendedBoxMapMaker bBMMDoMapValue bBMMMapTypeValue bBMMDoMappingValue bBMMMappingTypeValue bBMMTopImageValue bBMMMeditSlotTypeValue bBMMMeditSlotValue bBMMMapTileValue bBMMTriScaleValue bBMMTriBlendValue bBMMMaxScaleValue bBMMMaxBlendValue bBMMTopChannelValue bBMMRightChannelValue bBMMFrontChannelValue bBMMShowWarningValue bBMMModifierNameValue bBMMModTileValue bBMMCalculateSizeValue bBMMSpecificSizeValue bBMMMapRotateValue bBMMGeminiDistanceValue
	if bBMMFloater != undefined then CloseRolloutFloater bBMMFloater
	)

fn bBMMApply = 
	(
	blendedBoxMapMaker bBMMDoMapValue bBMMMapTypeValue bBMMDoMappingValue bBMMMappingTypeValue bBMMTopImageValue bBMMMeditSlotTypeValue bBMMMeditSlotValue bBMMMapTileValue bBMMTriScaleValue bBMMTriBlendValue bBMMMaxScaleValue bBMMMaxBlendValue bBMMTopChannelValue bBMMRightChannelValue bBMMFrontChannelValue bBMMShowWarningValue bBMMModifierNameValue bBMMModTileValue bBMMCalculateSizeValue bBMMSpecificSizeValue bBMMMapRotateValue bBMMGeminiDistanceValue
	)
	
fn bBMMHelp = 
	(
	sLibSSPrintHelp "blendedBoxMapMaker"
	)
	
fn bBMMLoadDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	bBMMInputFilename = presetDir + "blendedBoxMapMaker.ini"
	if (sLibFileExist bBMMInputFilename == true) then
		(
		bBMMDoMapValue = execute (getINISetting bBMMInputFilename "blendedCubeProjectionMaker" "bBMMDoMapValue")
		bBMMMapTypeValue = execute (getINISetting bBMMInputFilename "blendedCubeProjectionMaker" "bBMMMapTypeValue")
		bBMMDoMappingValue = execute (getINISetting bBMMInputFilename "blendedCubeProjectionMaker" "bBMMDoMappingValue")
		bBMMMappingTypeValue = execute (getINISetting bBMMInputFilename "blendedCubeProjectionMaker" "bBMMMappingTypeValue")
		bBMMTopImageValue = (getINISetting bBMMInputFilename "blendedBoxMapMaker" "bBMMTopImageValue")
		bBMMMeditSlotTypeValue = execute (getINISetting bBMMInputFilename "blendedBoxMapMaker" "bBMMMeditSlotTypeValue")
		bBMMMeditSlotValue = execute (getINISetting bBMMInputFilename "blendedBoxMapMaker" "bBMMMeditSlotValue")
		bBMMMapTileValue = execute (getINISetting bBMMInputFilename "blendedBoxMapMaker" "bBMMMapTileValue")
		bBMMTriScaleValue = execute (getINISetting bBMMInputFilename "blendedBoxMapMaker" "bBMMTriScaleValue")
		bBMMTriBlendValue = execute (getINISetting bBMMInputFilename "blendedBoxMapMaker" "bBMMTriBlendValue")
		bBMMMaxScaleValue = execute (getINISetting bBMMInputFilename "blendedBoxMapMaker" "bBMMMaxScaleValue")
		bBMMMaxBlendValue = execute (getINISetting bBMMInputFilename "blendedBoxMapMaker" "bBMMMaxBlendValue")
		bBMMTopChannelValue = execute (getINISetting bBMMInputFilename "blendedBoxMapMaker" "bBMMTopChannelValue")
		bBMMRightChannelValue = execute (getINISetting bBMMInputFilename "blendedBoxMapMaker" "bBMMRightChannelValue")
		bBMMFrontChannelValue = execute (getINISetting bBMMInputFilename "blendedBoxMapMaker" "bBMMFrontChannelValue")
		bBMMShowWarningValue = execute (getINISetting bBMMInputFilename "blendedBoxMapMaker" "bBMMShowWarningValue")
		bBMMModifierNameValue = (getINISetting bBMMInputFilename "blendedBoxMapMaker" "bBMMModifierNameValue")
		bBMMModTileValue = execute (getINISetting bBMMInputFilename "blendedBoxMapMaker" "bBMMModTileValue")
		bBMMCalculateSizeValue = execute (getINISetting bBMMInputFilename "blendedBoxMapMaker" "bBMMCalculateSizeValue")
		bBMMSpecificSizeValue = execute (getINISetting bBMMInputFilename "blendedBoxMapMaker" "bBMMSpecificSizeValue")
		bBMMMapRotateValue = execute (getINISetting bBMMInputFilename "blendedBoxMapMaker" "bBMMMapRotateValue")
		bBMMGeminiDistanceValue = execute (getINISetting bBMMInputFilename "blendedBoxMapMaker" "bBMMGeminiDistanceValue")
		bBMMPosValue = execute (getINISetting bBMMInputFilename "blendedBoxMapMaker" "bBMMPosValue")
		
		if bBMMDoMapValue == OK then bBMMDoMapValue = true
		if bBMMMapTypeValue == OK then bBMMMapTypeValue = 3
		if bBMMDoMappingValue == OK then bBMMDoMappingValue = false
		if bBMMMappingTypeValue == OK then bBMMMappingTypeValue = 1
		if bBMMTopImageValue == OK then bBMMTopImageValue = ""
		if bBMMMeditSlotTypeValue == OK then bBMMMeditSlotTypeValue = 1
		if bBMMMeditSlotValue == OK then bBMMMeditSlotValue = 1
		if bBMMMapTileValue == OK then bBMMMapTileValue = 1
		if bBMMTriScaleValue == OK then bBMMTriScaleValue = 0.01
		if bBMMTriBlendValue == OK then bBMMTriBlendValue = 0.3
		if bBMMMaxScaleValue == OK then bBMMMaxScaleValue = 100.0
		if bBMMMaxBlendValue == OK then bBMMMaxBlendValue = 25.0
		if bBMMTopChannelValue == OK then bBMMTopChannelValue = 2
		if bBMMRightChannelValue == OK then bBMMRightChannelValue = 3
		if bBMMFrontChannelValue == OK then bBMMFrontChannelValue = 4
		if bBMMShowWarningValue == OK then bBMMShowWarningValue = true
		if bBMMModifierNameValue == OK then bBMMModifierNameValue = ""
		if bBMMModTileValue == OK then bBMMModTileValue = 1.0
		if bBMMCalculateSizeValue == OK then bBMMCalculateSizeValue = true
		if bBMMSpecificSizeValue == OK then bBMMSpecificSizeValue = 100.0
		if bBMMMapRotateValue == OK then bBMMMapRotateValue = true
		if bBMMGeminiDistanceValue == OK then bBMMGeminiDistanceValue = 3.0
		if bBMMPosValue == OK then bBMMPosValue = [400,400]
		)
	else
		(
		bBMMDoMapValue = true
		bBMMMapTypeValue = 3
		bBMMDoMappingValue = false
		bBMMMappingTypeValue = 1
		bBMMTopImageValue = ""
		bBMMMeditSlotTypeValue = 1
		bBMMMeditSlotValue = 1
		bBMMMapTileValue = 1.0
		bBMMTriScaleValue = 0.01
		bBMMTriBlendValue = 0.3
		bBMMMaxScaleValue = 100.0
		bBMMMaxBlendValue = 25.0
		bBMMTopChannelValue = 2
		bBMMRightChannelValue = 3
		bBMMFrontChannelValue = 4
		bBMMShowWarningValue = true
		bBMMModifierNameValue = ""
		bBMMModTileValue = 1.0
		bBMMCalculateSizeValue = true
		bBMMSpecificSizeValue = 100.0
		bBMMMapRotateValue = true
		bBMMGeminiDistanceValue = 3.0
		bBMMPosValue = [400,400]
		)
	)
	
fn bBMMSaveDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	if (getDirectories presetDir).count == 0 then makeDir presetDir
	bBMMOutputFilename = presetDir + "blendedBoxMapMaker.ini"
	if (sLibFileExist bBMMOutputFilename == true) then deleteFile bBMMOutputFilename
	setINISetting bBMMOutputFilename "blendedCubeProjectionMaker" "bBMMDoMapValue" (bBMMDoMapValue as string)
	setINISetting bBMMOutputFilename "blendedCubeProjectionMaker" "bBMMMapTypeValue" (bBMMMapTypeValue as string)
	setINISetting bBMMOutputFilename "blendedCubeProjectionMaker" "bBMMDoMappingValue" (bBMMDoMappingValue as string)
	setINISetting bBMMOutputFilename "blendedCubeProjectionMaker" "bBMMMappingTypeValue" (bBMMMappingTypeValue as string)
	setINISetting bBMMOutputFilename "blendedBoxMapMaker" "bBMMTopImageValue" (bBMMTopImageValue as string)
	setINISetting bBMMOutputFilename "blendedBoxMapMaker" "bBMMMeditSlotTypeValue" (bBMMMeditSlotTypeValue as string)	
	setINISetting bBMMOutputFilename "blendedBoxMapMaker" "bBMMMeditSlotValue" (bBMMMeditSlotValue as string)
	setINISetting bBMMOutputFilename "blendedBoxMapMaker" "bBMMMapTileValue" (bBMMMapTileValue as string)
	setINISetting bBMMOutputFilename "blendedBoxMapMaker" "bBMMTriScaleValue" (bBMMTriScaleValue as string)
	setINISetting bBMMOutputFilename "blendedBoxMapMaker" "bBMMTriBlendValue" (bBMMTriBlendValue as string)
	setINISetting bBMMOutputFilename "blendedBoxMapMaker" "bBMMMaxScaleValue" (bBMMMaxScaleValue as string)
	setINISetting bBMMOutputFilename "blendedBoxMapMaker" "bBMMMaxBlendValue" (bBMMMaxBlendValue as string)
	setINISetting bBMMOutputFilename "blendedBoxMapMaker" "bBMMTopChannelValue" (bBMMTopChannelValue as string)
	setINISetting bBMMOutputFilename "blendedBoxMapMaker" "bBMMRightChannelValue" (bBMMRightChannelValue as string)
	setINISetting bBMMOutputFilename "blendedBoxMapMaker" "bBMMFrontChannelValue" (bBMMFrontChannelValue as string)
	setINISetting bBMMOutputFilename "blendedBoxMapMaker" "bBMMShowWarningValue" (bBMMShowWarningValue as string)
	setINISetting bBMMOutputFilename "blendedBoxMapMaker" "bBMMModifierNameValue" (bBMMModifierNameValue as string)
	setINISetting bBMMOutputFilename "blendedBoxMapMaker" "bBMMModTileValue" (bBMMModTileValue as string)
	setINISetting bBMMOutputFilename "blendedBoxMapMaker" "bBMMCalculateSizeValue" (bBMMCalculateSizeValue as string)
	setINISetting bBMMOutputFilename "blendedBoxMapMaker" "bBMMSpecificSizeValue" (bBMMSpecificSizeValue as string)
	setINISetting bBMMOutputFilename "blendedBoxMapMaker" "bBMMMapRotateValue" (bBMMMapRotateValue as string) 
	setINISetting bBMMOutputFilename "blendedBoxMapMaker" "bBMMGeminiDistanceValue" (bBMMGeminiDistanceValue as string)
	setINISetting bBMMOutputFilename "blendedBoxMapMaker" "bBMMPosValue" (bBMMFloater.pos as string)
	)

-- UI

fn bBMMDefineUI = 
	(
	rollout bBMMRollout "blendedBoxMapMaker"
		(
		group "Action"
		(
		checkbox bBMMDoMapCheckbox "Create Map?" checked:bBMMDoMapValue align:#left across:2 offset:[0,3]
		dropdownlist bBMMMapTypeDropdown "" items:#("Falloff Method", "CameraMapGemini Method", "Vray Triplanar Method", "Max's BlendedBoxMap Method") selection:bBMMMapTypeValue width:200 align:#center enabled:false
		checkbox bBMMDoMappingCheckbox "Create Mapping Modifiers?" checked:bBMMDoMappingValue align:#left across:2 offset:[0,3]
		dropdownlist bBMMMappingTypeDropdown "" items:#("UVW Mapping Method", "CameraMapGemini Method") selection:bBMMMappingTypeValue width:200 align:#center enabled:false
		)
		
		group "Map"
		(
		dropdownlist bBMMMeditSlotTypeDropdown "" items:#("Use Selected Medit Slot", "Use Specific Medit Slot", "Place in Active SME") selection:bBMMMeditSlotTypeValue width:143 align:#center across:2 offset:[38,0] enabled:false
		spinner bBMMMeditSlotSpinner "Medit Slot: " range:[1,24,bBMMMeditSlotValue] type:#integer fieldWidth:30 align:#center offset:[-38,3] enabled:false
		edittext bBMMTopImageEditText "Map:" fieldWidth:345 text:bBMMTopImageValue align:#right offset:[180,0] across:2 enabled:false
		button bBMMTopImageFileButton "F" width:20 toolTip:"Choose File" align:#right offset:[0,-2] enabled:false
		spinner bBMMMapTileSpinner "Map Tile Amount: " range:[0.0001,999999,bBMMMapTileValue] type:#float fieldWidth:50 align:#left offset:[48,0] enabled:false

		spinner bBMMTriScaleSpinner "VrayTriplanarTex Scale: " range:[0,10000,bBMMTriScaleValue] fieldWidth:50 type:#float align:#left across:2 offset:[17,0] enabled:false
		spinner bBMMTriBlendSpinner "VrayTriplanarTex Blend: " range:[0.0,1.0,bBMMTriBlendValue] fieldWidth:50 type:#float align:#right enabled:false

		spinner bBMMMaxScaleSpinner "Max BlendedBoxMap Scale: " range:[0.01,100000,bBMMMaxScaleValue] fieldWidth:50 type:#float align:#left across:2 enabled:false
		spinner bBMMMaxBlendSpinner "Max BlendedBoxMap Blend: " range:[0.0,100.0,bBMMMaxBlendValue] fieldWidth:50 type:#float align:#right enabled:false
		
		checkbox bBMMMapRotateCheckbox "Map Random Rotation?" checked:bBMMMapRotateValue align:#right enabled:false
		)

		group "Mapping Modifiers"
		(
		checkbox bBMMShowWarningCheckbox "Show Reset Xform Warning?" checked:bBMMShowWarningValue align:#left across:2 enabled:false
		spinner bBMMModTileSpinner "Mapping Tile Amount: " range:[0.0001,999999,bBMMModTileValue] type:#float fieldWidth:40 align:#right across:2 enabled:false
		checkbox bBMMCalculateSizeCheckbox "Auto Calculate Size?" checked:bBMMCalculateSizeValue align:#left across:3 enabled:false
		spinner bBMMSpecificSizeSpinner "Size: " range:[0.0001,9999999,bBMMSpecificSizeValue] type:#float fieldWidth:55 align:#left offset:[-15,1] enabled:false
		edittext bBMMModifierNameEditText "Mod Name:" fieldWidth:120 text:bBMMModifierNameValue align:#right enabled:false
		spinner bBMMGeminiDistanceSpinner "CameraMapGemini Camera Distance Multiplier: " range:[1,9999,bBMMGeminiDistanceValue] type:#float fieldWidth:40 align:#right enabled:false
		)
		
		group "Map Channels"
		(
		spinner bBMMTopChannelSpinner "Top Map Chan:" range:[1,99,bBMMTopChannelValue] type:#integer fieldWidth:30 align:#left across:3 enabled:false
		spinner bBMMRightChannelSpinner "Right Map Chan:" range:[1,99,bBMMRightChannelValue] type:#integer fieldWidth:30 align:#center enabled:false
		spinner bBMMFrontChannelSpinner "Front Map Chan:" range:[1,99,bBMMFrontChannelValue] type:#integer fieldWidth:30 align:#right enabled:false
		)

		on bBMMDoMapCheckbox changed state do (bBMMDoMapValue = state;curPos = bBMMFloater.pos;bBMMCloseOpenUI curPos)
		on bBMMMapTypeDropdown selected i do (bBMMMapTypeValue = i;curPos = bBMMFloater.pos;bBMMCloseOpenUI curPos)
		on bBMMDoMappingCheckbox changed state do (bBMMDoMappingValue = state;curPos = bBMMFloater.pos;bBMMCloseOpenUI curPos)
		on bBMMMappingTypeDropdown selected i do (bBMMMappingTypeValue = i;curPos = bBMMFloater.pos;bBMMCloseOpenUI curPos)
		
		on bBMMMeditSlotTypeDropdown selected i do 
			(
			bBMMMeditSlotTypeValue = i
			if bBMMMeditSlotTypeValue == 2 and bBMMDoMapValue == true then bBMMMeditSlotSpinner.enabled = true else bBMMMeditSlotSpinner.enabled = false
			)
		on bBMMMeditSlotSpinner changed val do bBMMMeditSlotValue = val
		on bBMMTopImageEditText changed text do bBMMTopImageValue = bBMMTopImageEditText.text
		on bBMMTopImageFileButton pressed do 
			(
			myfile = getOpenFileName()
			if myfile == undefined then
				(
				bBMMTopImageEditText.text = ""
				bBMMTopImageValue = ""
				)
			else 
				(
				bBMMTopImageEditText.text = myfile
				bBMMTopImageValue = myfile
				)
			)
		on bBMMMapTileSpinner changed val do bBMMMapTileValue = val
		on bBMMTriScaleSpinner changed state do bBMMTriScaleValue = state
		on bBMMTriBlendSpinner changed state do bBMMTriBlendValue = state
		on bBMMMaxScaleSpinner changed state do bBMMMaxScaleValue = state
		on bBMMMaxBlendSpinner changed state do bBMMMaxBlendValue = state
		on bBMMMapRotateCheckbox changed state do bBMMMapRotateValue = state

		on bBMMShowWarningCheckbox changed state do bBMMShowWarningValue = state
		on bBMMModTileSpinner changed val do bBMMModTileValue = val
		on bBMMCalculateSizeCheckbox changed state do 
			(
			bBMMCalculateSizeValue = state
			bBMMSpecificSizeSpinner.enabled = not bBMMCalculateSizeValue
			)
		on bBMMSpecificSizeSpinner changed val do bBMMSpecificSizeValue = val
		on bBMMModifierNameEditText changed text do bBMMModifierNameValue = bBMMModifierNameEditText.text
		on bBMMGeminiDistanceSpinner changed val do bBMMGeminiDistanceValue = val

		on bBMMTopChannelSpinner changed val do bBMMTopChannelValue = val
		on bBMMRightChannelSpinner changed val do bBMMRightChannelValue = val
		on bBMMFrontChannelSpinner changed val do bBMMFrontChannelValue = val

		group "Tools"
		(
		button bBMMDeleteOldButton "Delete Blended Box Map Modifiers On Selected Objects" width:300 toolTip:"Delete Blended Box Map On Selected Objects" align:#center offset:[0,-2]
		)
		on bBMMDeleteOldButton pressed do 
			(
			sLibRemoveModifiersByNameFragment $ "bBMM_"
			sLibRemoveModifiersByNameFragment $ "BBM_"
			)
			
		button bBMMDoButton "Do" width:70 toolTip:"Do It and Close UI" pos:[70,432]
		on bBMMDoButton pressed do bBMMDo()
		button bBMMApplyButton "Apply" width:70 toolTip:"Do It and Keep UI Open" pos:[142,432]
		on bBMMApplyButton pressed do bBMMApply()
		button bBMMHelpButton "Help" width:70 toolTip:"Help" pos:[214,432]
		on bBMMHelpButton pressed do bBMMHelp()
		button bBMMSaveDefButton "SaveDef" width:70 toolTip:"Save Current Settings as Default" pos:[287,432]
		on bBMMSaveDefButton pressed do bBMMSaveDef()
		
		on bBMMRollout open do
			(
			if bBMMDoMapValue == true then
				(			
				bBMMMapTypeDropdown.enabled = true
				if bBMMMapTypeValue == 1 or bBMMMapTypeValue == 2 then
					(
					bBMMMeditSlotTypeDropdown.enabled = true
					if bBMMMeditSlotTypeValue == 2 then bBMMMeditSlotSpinner.enabled = true else bBMMMeditSlotSpinner.enabled = false
					bBMMTopImageEditText.enabled = true
					bBMMTopImageFileButton.enabled = true
					bBMMMapTileSpinner.enabled = true
					bBMMMapRotateCheckbox.enabled = true
					
					bBMMTopChannelSpinner.enabled = true
					bBMMRightChannelSpinner.enabled = true
					bBMMFrontChannelSpinner.enabled = true
					)
				else if bBMMMapTypeValue == 3 then
					(
					bBMMMeditSlotTypeDropdown.enabled = true
					if bBMMMeditSlotTypeValue == 2 then bBMMMeditSlotSpinner.enabled = true else bBMMMeditSlotSpinner.enabled = false
					bBMMTopImageEditText.enabled = true
					bBMMTopImageFileButton.enabled = true
					bBMMTriScaleSpinner.enabled = true
					bBMMTriBlendSpinner.enabled = true
					bBMMMapRotateCheckbox.enabled = true
					)
				else if bBMMMapTypeValue == 4 then
					(
					bBMMMeditSlotTypeDropdown.enabled = true
					if bBMMMeditSlotTypeValue == 2 then bBMMMeditSlotSpinner.enabled = true else bBMMMeditSlotSpinner.enabled = false
					bBMMTopImageEditText.enabled = true
					bBMMTopImageFileButton.enabled = true
					bBMMMaxScaleSpinner.enabled = true
					bBMMMaxBlendSpinner.enabled = true
					bBMMMapRotateCheckbox.enabled = true
					)
				)
			if bBMMDoMappingValue == true then			
				(
				bBMMMappingTypeDropdown.enabled = true
				if bBMMMappingTypeValue == 1 then
					(
					bBMMShowWarningCheckbox.enabled = true
					bBMMModTileSpinner.enabled = true
					bBMMCalculateSizeCheckbox.enabled = true
					bBMMSpecificSizeSpinner.enabled = not bBMMCalculateSizeValue
					bBMMModifierNameEditText.enabled = true

					bBMMTopChannelSpinner.enabled = true
					bBMMRightChannelSpinner.enabled = true
					bBMMFrontChannelSpinner.enabled = true
					)
				else if bBMMMappingTypeValue == 2 then
					(
					bBMMShowWarningCheckbox.enabled = true
					bBMMModTileSpinner.enabled = true
					bBMMCalculateSizeCheckbox.enabled = true
					bBMMSpecificSizeSpinner.enabled = not bBMMCalculateSizeValue
					bBMMModifierNameEditText.enabled = true
					bBMMGeminiDistanceSpinner.enabled = true

					bBMMTopChannelSpinner.enabled = true
					bBMMRightChannelSpinner.enabled = true
					bBMMFrontChannelSpinner.enabled = true
					)
				)
			)
		)
	)
)
-------------------------------------------------------------------------------