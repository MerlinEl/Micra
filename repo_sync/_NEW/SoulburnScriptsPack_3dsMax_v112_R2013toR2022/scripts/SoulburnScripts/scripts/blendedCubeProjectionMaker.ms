-------------------------------------------------------------------------------
-- blendedCubeProjectionMaker.ms
-- By Neil Blevins (info@neilblevins.com)
-- v 3.11
-- Created On: 11/27/11
-- Modified On: 05/21/17
-- tested using Max 2017
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Required Files:
-- sLib.ms
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Description:
-- Applies 6 projections (Front, Back, Left, Right, Top, Bottom) to the selected
-- objects, hooks the projections up to 6 maps, and then blends between each 
-- map. Great for projecting details onto a set of objects, like box mapping, 
-- but each side can be a seperate map, and the edges of the box are blended 
-- so you can place the map on a curved surface and not have horrible seams.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Tutorial:
-- For Pre Max 2018: 
-- Make a sphere. Run the script in UI mode. Select images for all 6 directions.
-- Choose Falloff Method and UVWMapping Method. Hit Do. Your object will now 
-- have 6 new mapping modifiers assigned to it, and the medit slot of your 
-- choice will have a map tree that you can put into the object's color slot, 
-- bump slot, etc. Adjust the curves on the falloff maps to get harder or softer 
-- blends on the box edges.
--
-- For Post Max 2018: 
-- Make a sphere. Run the script in UI mode. Select images for all 6 directions.
-- Choose Max's BlendedBoxMap Method. Uncheck "Create Mapping Modifiers". 
-- Hit Do. The medit slot of your choice will have a BlendedBoxMap in it 
-- set to 6 sided mode that you can put into the object's color slot, 
-- bump slot, etc.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Revision History:
--
-- v 1.10 Added support for CameraMapGemini plugin (v0.16) by Markus Boos 
-- (http://www.projectgemini.net/CameraMapGemini/). The script can now use 2 
-- methods, UVW Mapping Method and CameraMapGemini Method. The UVWMapping method 
-- works the same as the old method. The CameraMapGemini Method creates the same 
-- sort of mapping, except using cameras for projection. The main advantage to 
-- this method is the cameras exist as a rig in world space. So moving objects 
-- after applying the blendedCubeProjectionMaker does not misalign the projection. 
-- For more information, visit http:/www.neilblevins.com and look for the 
-- blendedCubeProjection tutorial in the education section.
--
-- v 1.11 Fixed a crash bug that would occur if not every object you selected was
-- geometry.
--
-- v 1.12 Added better defaults for Angle Blend Threshold. Added better names
-- for the maps the script creates. Cleaned up some code.
--
-- v 1.13 Works with Real World Mapping now.
--
-- v 1.14 Fixed an issue with the cameraMapGemini mode by moving the cameras 
-- further away from the object. This workaround will have to do until a 
-- cameraMapGemini bug gets fixed.
--
-- v 1.15 Change CameraMapGemini Distance to a Multiplier.
--
-- v 1.16 I completely botched up the distance calculation for the placement
-- of the CameraMapGemini cameras. This fixes that. Uniquifies camera names.
--
-- v 1.17 Fixed a bug where the wrong map channel would be loaded when loading 
-- the script defaults.
--
-- v 3.00 Now you can mix and match map types and mapping types. Makes a much 
-- more accurate calculation on the "Auto Calculate Size" for the mapping UVW 
-- modifiers.
--
-- v 3.01 Adjusted both the UVWMapping and CameramapGemini Auto Calculate Size
-- so they now match. Creates reference cameras when in UVW Mapping Method
-- mode, although doesn't use the cameras for projection, uses the UVW mapping
-- modifier gizmos.
--
-- v 3.02 Now you can place the blendedCubeProjection Map into the Slate Material 
-- Editor.
--
-- v 3.03 Cleaned up a lot of code. Fixed a problem that meant the specific
-- size spinner didn't work properly.
--
-- v 3.10 You can now create a BlendedCubeProjection using max's BlendedBoxMap 
-- map.
--
-- v 3.11 Fixed some UI that wasn't disabling properly.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Known Issues:
-- These are not issues with the script, but known issues with the 
-- CameraMapGemini plugin, which seem worth mentionning here. 
-- 1) CameraMapGemini doesn't work in mentalray 2) CameraMapGemini 
-- doesn't support bump mapping yet 3) CameraMapGemini takes a little 
-- longer to render than the UVWMapping method. I've seen a 2x slowdown 
-- rendering objects.
-- 
-- If when using CameraMapGemini you see more blending than you'd expect, try 
-- increasing the CameraMapGemini Camera Distance Multiplier.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
(
-- Globals

global blendedCubeProjectionMaker
global blendedCubeProjectionMakerDefaults
global blendedCubeProjectionMakerUI

global bCPMCloseOpenUI

global bCPMDoMapFunction
global bCPMDoMappingFunction

global bCPMDo
global bCPMApply
global bCPMHelp
global bCPMLoadDef
global bCPMSaveDef

global bCPMDefineUI
global bCPMRollout
global bCPMFloater

-- Includes

include "$scripts\SoulburnScripts\lib\sLib.ms"

-- Variables

bCPMDoMapValue = true
bCPMMapTypeValue = 3
bCPMDoMappingValue = false
bCPMMappingTypeValue = 1
bCPMTopImageValue = ""
bCPMBottomImageValue = ""
bCPMRightImageValue = ""
bCPMLeftImageValue = ""
bCPMFrontImageValue = ""
bCPMBackImageValue = ""
bCPMMeditSlotTypeValue = 1
bCPMMeditSlotValue = 1
bCPMTopChannelValue = 5
bCPMBottomChannelValue = 8
bCPMRightChannelValue = 6
bCPMLeftChannelValue = 9
bCPMFrontChannelValue = 7
bCPMBackChannelValue = 10
bCPMShowWarningValue = true
bCPMModifierNameValue = ""
bCPMCalculateSizeValue = true
bCPMSpecificSizeValue = 100.0
bCPMGeminiDistanceValue = 3.0
bCPMPosValue = [400,400]

-- Functions

fn blendedCubeProjectionMaker bCPMDoMap bCPMMapType bCPMDoMapping bCPMMappingType bCPMTopImage bCPMBottomImage bCPMRightImage bCPMLeftImage bCPMFrontImage bCPMBackImage bCPMMeditSlotType bCPMMeditSlot bCPMTopChannel bCPMBottomChannel bCPMRightChannel bCPMLeftChannel bCPMFrontChannel bCPMBackChannel bCPMShowWarning bCPMModifierName bCPMCalculateSize bCPMSpecificSize bCPMGeminiDistance = 
	(
	themap = bCPMDoMapFunction bCPMDoMap bCPMMapType bCPMDoMapping bCPMMappingType bCPMTopImage bCPMBottomImage bCPMRightImage bCPMLeftImage bCPMFrontImage bCPMBackImage bCPMMeditSlotType bCPMMeditSlot bCPMTopChannel bCPMBottomChannel bCPMRightChannel bCPMLeftChannel bCPMFrontChannel bCPMBackChannel bCPMShowWarning bCPMModifierName bCPMCalculateSize bCPMSpecificSize bCPMGeminiDistance
	bCPMDoMappingFunction themap bCPMDoMap bCPMMapType bCPMDoMapping bCPMMappingType bCPMTopImage bCPMBottomImage bCPMRightImage bCPMLeftImage bCPMFrontImage bCPMBackImage bCPMMeditSlotType bCPMMeditSlot bCPMTopChannel bCPMBottomChannel bCPMRightChannel bCPMLeftChannel bCPMFrontChannel bCPMBackChannel bCPMShowWarning bCPMModifierName bCPMCalculateSize bCPMSpecificSize bCPMGeminiDistance
	)
	
fn blendedCubeProjectionMakerDefaults = 
	(
	bCPMLoadDef()
	blendedCubeProjectionMaker bCPMDoMapValue bCPMMapTypeValue bCPMDoMappingValue bCPMMappingTypeValue bCPMTopImageValue bCPMBottomImageValue bCPMRightImageValue bCPMLeftImageValue bCPMFrontImageValue bCPMBackImageValue bCPMMeditSlotTypeValue bCPMMeditSlotValue bCPMTopChannelValue bCPMBottomChannelValue bCPMRightChannelValue bCPMLeftChannelValue bCPMFrontChannelValue bCPMBackChannelValue bCPMShowWarningValue bCPMModifierNameValue bCPMCalculateSizeValue bCPMSpecificSizeValue bCPMGeminiDistanceValue
	)
	
fn blendedCubeProjectionMakerUI = 
	(
	bCPMLoadDef()
	bCPMCloseOpenUI bCPMPosValue
	)
	
fn bCPMCloseOpenUI pos = 
	(
	if bCPMFloater != undefined then CloseRolloutFloater bCPMFloater
	bCPMDefineUI()
	bCPMFloater = newRolloutFloater "blendedCubeProjectionMaker v3.11" 450 569 pos.x pos.y
	addRollout bCPMRollout bCPMFloater
	)

fn bCPMDoMapFunction bCPMDoMap bCPMMapType bCPMDoMapping bCPMMappingType bCPMTopImage bCPMBottomImage bCPMRightImage bCPMLeftImage bCPMFrontImage bCPMBackImage bCPMMeditSlotType bCPMMeditSlot bCPMTopChannel bCPMBottomChannel bCPMRightChannel bCPMLeftChannel bCPMFrontChannel bCPMBackChannel bCPMShowWarning bCPMModifierName bCPMCalculateSize bCPMSpecificSize bCPMGeminiDistance = 
	(
	mymap = undefined
	if bCPMDoMap == true then
		(
		-- Create The Map
		if bCPMMapType == 1 then
			(
			mymap = Mix ()
			mymap.name = (getFilenameFile bCPMTopImage) + "BCP"

			mymap.map1 = Mix ()
			mymap.map1.name = "TopBottomRightLeft"

			mymap.map2 = Mix ()
			mymap.map2.name = "FrontBack"

			mymap.map2.map1 = Bitmaptexture fileName:bCPMFrontImage
			mymap.map2.map1.name = "FrontTex"
			mymap.map2.map1.coordinates.mapChannel = bCPMFrontChannel
			mymap.map2.map1.coords.realWorldScale = off

			mymap.map2.map2 = Bitmaptexture fileName:bCPMBackImage
			mymap.map2.map2.name = "BackTex"
			mymap.map2.map2.coordinates.mapChannel = bCPMBackChannel
			mymap.map2.map2.coords.realWorldScale = off

			mymap.map2.mask = falloff ()
			mymap.map2.mask.name = "FrontBackBlend"
			mymap.map2.mask.type = 0
			mymap.map2.mask.direction = 5
			mymap.map2.mask.color1 = white
			mymap.map2.mask.color2 = black

			mymap.Mask = falloff ()
			mymap.Mask.name = "FrontBackRightLeftTopBottomBlend"
			mymap.Mask.type = 1
			mymap.Mask.direction = 5
			mymap.Mask.color1 = white
			mymap.Mask.color2 = black

			mymap.map1.map1 = Mix ()
			mymap.map1.map1.name = "TopBottom"

			mymap.map1.map1.map1 = Bitmaptexture fileName:bCPMTopImage
			mymap.map1.map1.map1.name = "TopTex"
			mymap.map1.map1.map1.coordinates.mapChannel = bCPMTopChannel
			mymap.map1.map1.map1.coords.realWorldScale = off

			mymap.map1.map1.map2 = Bitmaptexture fileName:bCPMBottomImage
			mymap.map1.map1.map2.name = "BottomTex"
			mymap.map1.map1.map2.coordinates.mapChannel = bCPMBottomChannel
			mymap.map1.map1.map2.coords.realWorldScale = off
			
			mymap.map1.map1.mask = falloff ()
			mymap.map1.map1.mask.name = "TopBottomBlend"
			mymap.map1.map1.mask.type = 0
			mymap.map1.map1.mask.direction = 6
			mymap.map1.map1.mask.color1 = black
			mymap.map1.map1.mask.color2 = white

			mymap.map1.map2 = Mix ()
			mymap.map1.map2.name = "RightLeft"

			mymap.map1.map2.map1 = Bitmaptexture fileName:bCPMRightImage
			mymap.map1.map2.map1.name = "RightTex"
			mymap.map1.map2.map1.coordinates.mapChannel = bCPMRightChannel
			mymap.map1.map2.map1.coords.realWorldScale = off

			mymap.map1.map2.map2 = Bitmaptexture fileName:bCPMLeftImage
			mymap.map1.map2.map2.name = "LeftTex"
			mymap.map1.map2.map2.coordinates.mapChannel = bCPMLeftChannel
			mymap.map1.map2.map2.coords.realWorldScale = off
			
			mymap.map1.map2.mask = falloff ()
			mymap.map1.map2.mask.name = "RightLeftBlend"
			mymap.map1.map2.mask.type = 0
			mymap.map1.map2.mask.direction = 4
			mymap.map1.map2.mask.color1 = black
			mymap.map1.map2.mask.color2 = white

			mymap.map1.Mask = falloff ()
			mymap.map1.Mask.name = "TopBottonRightLeftBlend"
			mymap.map1.Mask.type = 1
			mymap.map1.Mask.direction = 6
			)
		else if bCPMMapType == 2 then
			(
			if sLibCameraMapGeminiMapTest() == false then (MessageBox "Please install the Markus Boos Plugin sLibCameraMapGeminiMapTest to use this method" title:"blendedCubeProjectionMaker")
			else
				(
				mymap = CompositeTexturemap ()
				mymap.name = (getFilenameFile bCPMTopImage) + "BCP"
				mymap.mapEnabled.count = 6
				mymap.layername[1] = "Top"
				mymap.layername[2] = "Right"
				mymap.layername[3] = "Front"
				mymap.layername[4] = "Bottom"
				mymap.layername[5] = "Left"
				mymap.layername[6] = "Back"
				
				mymap.mapList[1] = CameraMapGeminiMap ()
				mymap.mapList[1].name = "TopTexProj"
				mymap.mapList[1].map01 = Bitmaptexture fileName:bCPMTopImage
				mymap.mapList[1].map01.name = "TopTex"
				mymap.mapList[1].map01.coordinates.mapChannel = bCPMTopChannel
				mymap.mapList[1].backFace = off
				mymap.mapList[1].rearProjection = on
				mymap.mapList[1].angleThresholdActive = off
				mymap.mapList[1].angleThresholdMin = 60
				mymap.mapList[1].angleThresholdMax = 85
				mymap.mapList[1].angleThresholdSymmetric = on
				mymap.mapList[1].applyBlendingToMonoChannel = on
				mymap.mapList[1].useMaskForMonoChannel01 = on
				
				mymap.mapList[2] = CameraMapGeminiMap ()
				mymap.mapList[2].name = "RightTexProj"
				mymap.mapList[2].map01 = Bitmaptexture fileName:bCPMRightImage
				mymap.mapList[2].map01.name = "RightTex"
				mymap.mapList[2].map01.coordinates.mapChannel = bCPMRightChannel
				mymap.mapList[2].backFace = off
				mymap.mapList[2].rearProjection = on
				mymap.mapList[2].angleThresholdActive = on
				mymap.mapList[2].angleThresholdMin = 60
				mymap.mapList[2].angleThresholdMax = 85
				mymap.mapList[2].angleThresholdSymmetric = on
				mymap.mapList[2].applyBlendingToMonoChannel = on
				mymap.mapList[2].useMaskForMonoChannel01 = on
				
				mymap.mapList[3] = CameraMapGeminiMap ()
				mymap.mapList[3].name = "FrontTexProj"
				mymap.mapList[3].map01 = Bitmaptexture fileName:bCPMFrontImage
				mymap.mapList[3].map01.name = "FrontTex"
				mymap.mapList[3].map01.coordinates.mapChannel = bCPMFrontChannel
				mymap.mapList[3].backFace = off
				mymap.mapList[3].rearProjection = on
				mymap.mapList[3].angleThresholdActive = on
				mymap.mapList[3].angleThresholdMin = 60
				mymap.mapList[3].angleThresholdMax = 85
				mymap.mapList[2].angleThresholdSymmetric = on
				mymap.mapList[3].applyBlendingToMonoChannel = on
				mymap.mapList[3].useMaskForMonoChannel01 = on

				mymap.mapList[4] = CameraMapGeminiMap ()
				mymap.mapList[4].name = "BottomTexProj"
				mymap.mapList[4].map01 = Bitmaptexture fileName:bCPMBottomImage
				mymap.mapList[4].map01.name = "BottomTex"
				mymap.mapList[4].map01.coordinates.mapChannel = bCPMBottomChannel
				mymap.mapList[4].backFace = off
				mymap.mapList[4].rearProjection = on
				mymap.mapList[4].angleThresholdActive = on
				mymap.mapList[4].angleThresholdMin = 60
				mymap.mapList[4].angleThresholdMax = 85
				mymap.mapList[4].angleThresholdSymmetric = on
				mymap.mapList[4].applyBlendingToMonoChannel = on
				mymap.mapList[4].useMaskForMonoChannel01 = on
				
				mymap.mapList[5] = CameraMapGeminiMap ()
				mymap.mapList[5].name = "LeftTexProj"
				mymap.mapList[5].map01 = Bitmaptexture fileName:bCPMLeftImage
				mymap.mapList[5].map01.name = "LeftTex"
				mymap.mapList[5].map01.coordinates.mapChannel = bCPMLeftChannel
				mymap.mapList[5].backFace = off
				mymap.mapList[5].rearProjection = on
				mymap.mapList[5].angleThresholdActive = on
				mymap.mapList[5].angleThresholdMin = 60
				mymap.mapList[5].angleThresholdMax = 85
				mymap.mapList[5].angleThresholdSymmetric = on
				mymap.mapList[5].applyBlendingToMonoChannel = on
				mymap.mapList[5].useMaskForMonoChannel01 = on
				
				mymap.mapList[6] = CameraMapGeminiMap ()
				mymap.mapList[6].name = "BackTexProj"
				mymap.mapList[6].map01 = Bitmaptexture fileName:bCPMBackImage
				mymap.mapList[6].map01.name = "BackTex"
				mymap.mapList[6].map01.coordinates.mapChannel = bCPMBackChannel
				mymap.mapList[6].backFace = off
				mymap.mapList[6].rearProjection = on
				mymap.mapList[6].angleThresholdActive = on
				mymap.mapList[6].angleThresholdMin = 60
				mymap.mapList[6].angleThresholdMax = 85
				mymap.mapList[6].angleThresholdSymmetric = on
				mymap.mapList[6].applyBlendingToMonoChannel = on
				mymap.mapList[6].useMaskForMonoChannel01 = on
				)
			)
		else if bCPMMapType == 3 then
			(
			if (classof BlendedBoxMap) == UndefinedClass then (MessageBox "Only works in max 2017 Ext 1 and above." title:"blendedCubeProjectionMaker")
			else
				(
				-- Make Map
				mymap = BlendedBoxMap()
				mymap.name = (getFilenameFile bCPMTopImage) + "BCP"
				mymap.mode = 2
				mymap.texturespace = 1
				
				mymap.tex[1] = Bitmaptexture fileName:bCPMTopImage
				mymap.tex[1].name = name "TopTexProj"
				mymap.tex[1].preMultAlpha = off
				mymap.tex[1].alphaSource = 0
				mymap.tex[2] = Bitmaptexture fileName:bCPMBottomImage
				mymap.tex[2].name = name "BottomTexProj"
				mymap.tex[2].alphaSource = 0
				mymap.tex[2].preMultAlpha = off
				mymap.tex[3] = Bitmaptexture fileName:bCPMLeftImage
				mymap.tex[3].name = name "LeftTexProj"
				mymap.tex[3].alphaSource = 0
				mymap.tex[3].preMultAlpha = off
				mymap.tex[4] = Bitmaptexture fileName:bCPMRightImage
				mymap.tex[4].name = name "RightTexProj"
				mymap.tex[4].alphaSource = 0
				mymap.tex[4].preMultAlpha = off
				mymap.tex[5] = Bitmaptexture fileName:bCPMFrontImage
				mymap.tex[5].name = name "FrontTexProj"
				mymap.tex[5].alphaSource = 0
				mymap.tex[5].preMultAlpha = off
				mymap.tex[6] = Bitmaptexture fileName:bCPMBackImage
				mymap.tex[6].name = name "BackTexProj"
				mymap.tex[6].alphaSource = 0
				mymap.tex[6].preMultAlpha = off
				
				mymap.mapscale = 100.0
				mymap.Blend = 25.0
				mymap.lockToFrame = true
				mymap.lockFrame = 0
				)
			)
			
		-- Place the map
		if mymap != undefined then
			(
			if bCPMMeditSlotType == 1 then meditMaterials[(medit.GetActiveMtlSlot())] = mymap
			else if bCPMMeditSlotType == 2 then meditMaterials[bCPMMeditSlot] = mymap
			else if bCPMMeditSlotType == 3 then
				(
				if (sme.IsOpen()) == false then (sme.Open())
				CurrentSMEView = sme.getView (sme.activeView)
				CurrentSMEView.CreateNode mymap [0,0]
				)
			else if bCPMMeditSlotType == 4 then
				(
				-- Do not place the map in Medit and just return the map
				)
			)
		)
	return mymap
	)
	
fn bCPMDoMappingFunction inputmap bCPMDoMap bCPMMapType bCPMDoMapping bCPMMappingType bCPMTopImage bCPMBottomImage bCPMRightImage bCPMLeftImage bCPMFrontImage bCPMBackImage bCPMMeditSlotType bCPMMeditSlot bCPMTopChannel bCPMBottomChannel bCPMRightChannel bCPMLeftChannel bCPMFrontChannel bCPMBackChannel bCPMShowWarning bCPMModifierName bCPMCalculateSize bCPMSpecificSize bCPMGeminiDistance =
	(
	bCPMfinalCams = #()
	bCPMCamsPoint = #()
	if bCPMDoMapping == true then
		(
		if selection.count !=0 then
			(
			if bCPMMappingType == 1 or bCPMMappingType == 2 then
				(
				bCPMObjs = #()
				for i in selection do (if ValidModifier i UVWMap then append bCPMObjs i)
				select bCPMObjs
				if bCPMShowWarning == true then (if (queryBox "In general, the mapping modifiers don't work properly with objects that have been heavily transformed (especially rotated). We recommend performing a Reset Xform on your objects before adding the mapping modifiers. Have you performed this operation?" title:"blendedCubeProjectionMaker") == false then return false)

				-- Decide projection size
				w = 1024.00;h = 1024.00
				if bCPMDoMap == true then (if bCPMTopImage != undefined and bCPMTopImage != "" then (w = (getBitmapInfo bCPMTopImage)[3];h = (getBitmapInfo bCPMTopImage)[4]))

				-- Get Selection Boundingbox
				objsBoundingBox = sLibGetCollectionBBox bCPMObjs
				objsCenter = [(objsBoundingBox[1].x + objsBoundingBox[2].x)/2, (objsBoundingBox[1].y + objsBoundingBox[2].y)/2, (objsBoundingBox[1].z + objsBoundingBox[2].z)/2]
				xLength = abs(objsBoundingBox[2].x-objsBoundingBox[1].x)
				yLength = abs(objsBoundingBox[2].y-objsBoundingBox[1].y)
				zLength = abs(objsBoundingBox[2].z-objsBoundingBox[1].z)

				-- Calculate squareSize
				if bCPMCalculateSize == true then
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
				else squareSize = bCPMSpecificSize*1.207

				-- Make Cameras
				-- Top
				newCamTop = Targetcamera pos:[objsCenter.x,objsCenter.y,objsCenter.z+(squareSize*bCPMGeminiDistance)] target:(Targetobject transform:(matrix3 [1,0,0] [0,1,0] [0,0,1] [objsCenter.x,objsCenter.y,objsCenter.z]))
				newCamTop.showCone = true
				newCamTop.orthoProjection = true
				newCamTop.name = uniqueName ("BCP_" + bCPMModifierName + "_TopProjection")
				newCamTop.type = #free
				newCamTop.target_Distance = squareSize
				-- Right
				newCamRight = Targetcamera pos:[objsCenter.x+(squareSize*bCPMGeminiDistance),objsCenter.y,objsCenter.z] target:(Targetobject transform:(matrix3 [1,0,0] [0,1,0] [0,0,1] [objsCenter.x,objsCenter.y,objsCenter.z]))
				newCamRight.showCone = true
				newCamRight.orthoProjection = true
				newCamRight.name = uniqueName ("BCP_" + bCPMModifierName + "_RightProjection")
				newCamRight.type = #free
				newCamRight.target_Distance = squareSize
				-- Back
				newCamBack = Targetcamera pos:[objsCenter.x,objsCenter.y+(squareSize*bCPMGeminiDistance),objsCenter.z] target:(Targetobject transform:(matrix3 [1,0,0] [0,1,0] [0,0,1] [objsCenter.x,objsCenter.y,objsCenter.z]))
				newCamBack.showCone = true
				newCamBack.orthoProjection = true
				newCamBack.name = uniqueName ("BCP_" + bCPMModifierName + "_BackProjection")
				newCamBack.type = #free
				newCamBack.target_Distance = squareSize
				-- Front
				newCamFront = Targetcamera pos:[objsCenter.x,objsCenter.y-(squareSize*bCPMGeminiDistance),objsCenter.z] target:(Targetobject transform:(matrix3 [1,0,0] [0,1,0] [0,0,1] [objsCenter.x,objsCenter.y,objsCenter.z]))
				newCamFront.showCone = true
				newCamFront.orthoProjection = true
				newCamFront.name = uniqueName ("BCP_" + bCPMModifierName + "_FrontProjection")
				newCamFront.type = #free
				newCamFront.target_Distance = squareSize
				-- Bottom
				newCamBottom = Targetcamera pos:[objsCenter.x,objsCenter.y,objsCenter.z-(squareSize*bCPMGeminiDistance)] target:(Targetobject transform:(matrix3 [1,0,0] [0,1,0] [0,0,1] [objsCenter.x,objsCenter.y,objsCenter.z]))
				newCamBottom.showCone = true
				newCamBottom.orthoProjection = true
				newCamBottom.name = uniqueName ("BCP_" + bCPMModifierName + "_BottomProjection")
				newCamBottom.type = #free
				newCamBottom.target_Distance = squareSize
				-- Left
				newCamLeft = Targetcamera pos:[objsCenter.x-(squareSize*bCPMGeminiDistance),objsCenter.y,objsCenter.z] target:(Targetobject transform:(matrix3 [1,0,0] [0,1,0] [0,0,1] [objsCenter.x,objsCenter.y,objsCenter.z]))
				newCamLeft.showCone = true
				newCamLeft.orthoProjection = true
				newCamLeft.name = uniqueName ("BCP_" + bCPMModifierName + "_LeftProjection")
				newCamLeft.type = #free
				newCamLeft.target_Distance = squareSize
				-- Camera Array
				bCPMfinalCams = #()
				append bCPMfinalCams newCamTop
				append bCPMfinalCams newCamRight
				append bCPMfinalCams newCamFront
				append bCPMfinalCams newCamBottom
				append bCPMfinalCams newCamLeft
				append bCPMfinalCams newCamBack
				-- Group Cameras
				myPoint = Point box:on cross_radius:10 filter_vertices:off filter_envelopes:on filter_cross_sections:on draw_all_envelopes:off draw_vertices:on paint_feather:0.7 paint_radius:24 paint_str:0.1 ref_frame:0 always_deform:on transform:(matrix3 [1,0,0] [0,0,1] [0,-1,0] objsCenter)
				myPoint.size = 2*squareSize
				myPoint.name = ("BCP_" + bCPMModifierName + "_CamGroup")
				for i in bCPMfinalCams do i.parent = myPoint
				bCPMCamsPoint = myPoint

				if bCPMMappingType == 1 then
					(
					-- Make Modifiers
					max modify mode

					modPanel.addModToSelection (Uvwmap ()) ui:on
					(modPanel.getCurrentObject ()).name = ("BCP_" + bCPMModifierName + "_Top")
					(modPanel.getCurrentObject ()).maptype = 0
					(modPanel.getCurrentObject ()).realWorldMapSize = off
					(modPanel.getCurrentObject ()).length = squareSize*0.8285
					(modPanel.getCurrentObject ()).width = squareSize*0.8285
					(modPanel.getCurrentObject ()).height = squareSize*0.8285
					(modPanel.getCurrentObject ()).utile = 1.0
					(modPanel.getCurrentObject ()).vtile = 1.0
					(modPanel.getCurrentObject ()).wtile = 1.0
					(modPanel.getCurrentObject ()).mapChannel = bCPMTopChannel
					(modPanel.getCurrentObject ()).axis = 2

					modPanel.addModToSelection (Uvwmap ()) ui:on
					(modPanel.getCurrentObject ()).name = ("BCP_" + bCPMModifierName + "_Bottom")
					(modPanel.getCurrentObject ()).maptype = 0
					(modPanel.getCurrentObject ()).realWorldMapSize = off
					(modPanel.getCurrentObject ()).length = squareSize*0.8285
					(modPanel.getCurrentObject ()).width = squareSize*0.8285
					(modPanel.getCurrentObject ()).height = squareSize*0.8285
					(modPanel.getCurrentObject ()).utile = 1.0
					(modPanel.getCurrentObject ()).vtile = 1.0
					(modPanel.getCurrentObject ()).wtile = 1.0
					(modPanel.getCurrentObject ()).mapChannel = bCPMBottomChannel
					(modPanel.getCurrentObject ()).axis = 2
					(modPanel.getCurrentObject ()).gizmo.rotation.x_rotation = 180

					modPanel.addModToSelection (Uvwmap ()) ui:on
					(modPanel.getCurrentObject ()).name = ("BCP_" + bCPMModifierName + "_Left")
					(modPanel.getCurrentObject ()).maptype = 0
					(modPanel.getCurrentObject ()).realWorldMapSize = off
					(modPanel.getCurrentObject ()).length = squareSize*0.8285
					(modPanel.getCurrentObject ()).width = squareSize*0.8285
					(modPanel.getCurrentObject ()).height = squareSize*0.8285
					(modPanel.getCurrentObject ()).utile = 1.0
					(modPanel.getCurrentObject ()).vtile = 1.0
					(modPanel.getCurrentObject ()).wtile = 1.0
					(modPanel.getCurrentObject ()).mapChannel = bCPMLeftChannel
					(modPanel.getCurrentObject ()).axis = 0
					(modPanel.getCurrentObject ()).gizmo.rotation.x_rotation = -90

					modPanel.addModToSelection (Uvwmap ()) ui:on
					(modPanel.getCurrentObject ()).name = ("BCP_" + bCPMModifierName + "_Right")
					(modPanel.getCurrentObject ()).maptype = 0
					(modPanel.getCurrentObject ()).realWorldMapSize = off
					(modPanel.getCurrentObject ()).length = squareSize*0.8285
					(modPanel.getCurrentObject ()).width = squareSize*0.8285
					(modPanel.getCurrentObject ()).height = squareSize*0.8285
					(modPanel.getCurrentObject ()).utile = 1.0
					(modPanel.getCurrentObject ()).vtile = 1.0
					(modPanel.getCurrentObject ()).wtile = 1.0
					(modPanel.getCurrentObject ()).mapChannel = bCPMRightChannel
					(modPanel.getCurrentObject ()).axis = 0
					(modPanel.getCurrentObject ()).gizmo.rotation.x_rotation = -90
					(modPanel.getCurrentObject ()).gizmo.rotation.z_rotation = 0

					modPanel.addModToSelection (Uvwmap ()) ui:on
					(modPanel.getCurrentObject ()).name = ("BCP_" + bCPMModifierName + "_Front")
					(modPanel.getCurrentObject ()).maptype = 0
					(modPanel.getCurrentObject ()).realWorldMapSize = off
					(modPanel.getCurrentObject ()).length = squareSize*0.8285
					(modPanel.getCurrentObject ()).width = squareSize*0.8285
					(modPanel.getCurrentObject ()).height = squareSize*0.8285
					(modPanel.getCurrentObject ()).utile = 1.0
					(modPanel.getCurrentObject ()).vtile = 1.0
					(modPanel.getCurrentObject ()).wtile = 1.0
					(modPanel.getCurrentObject ()).mapChannel = bCPMFrontChannel
					(modPanel.getCurrentObject ()).axis = 1

					modPanel.addModToSelection (Uvwmap ()) ui:on
					(modPanel.getCurrentObject ()).name = ("BCP_" + bCPMModifierName + "_Back")
					(modPanel.getCurrentObject ()).maptype = 0
					(modPanel.getCurrentObject ()).realWorldMapSize = off
					(modPanel.getCurrentObject ()).length = squareSize*0.8285
					(modPanel.getCurrentObject ()).width = squareSize*0.8285
					(modPanel.getCurrentObject ()).height = squareSize*0.8285
					(modPanel.getCurrentObject ()).utile = 1.0
					(modPanel.getCurrentObject ()).vtile = 1.0
					(modPanel.getCurrentObject ()).wtile = 1.0
					(modPanel.getCurrentObject ()).mapChannel = bCPMBackChannel
					(modPanel.getCurrentObject ()).axis = 1
					(modPanel.getCurrentObject ()).gizmo.rotation.z_rotation = 0
					)
				else if bCPMMappingType == 2 then
					(
					if sLibCameraMapGeminiMapTest() == false then (MessageBox "Please install the Markus Boos Plugin sLibCameraMapGeminiMapTest to use this method" title:"blendedCubeProjectionMaker")
					else
						(
						-- Make Modifier
						max modify mode

						modPanel.addModToSelection (CameraMapGeminiModifier ()) ui:on
						(modPanel.getCurrentObject ()).name = ("BCP_" + bCPMModifierName + "Projection")

						(modPanel.getCurrentObject ()).nodeCam01 = newCamTop
						(modPanel.getCurrentObject ()).mapChannel0l = bCPMTopChannel
						(modPanel.getCurrentObject ()).width01 = w
						(modPanel.getCurrentObject ()).height01 = h

						(modPanel.getCurrentObject ()).nodeCam02 = newCamRight
						(modPanel.getCurrentObject ()).mapChannel02 = bCPMRightChannel
						(modPanel.getCurrentObject ()).width02 = w
						(modPanel.getCurrentObject ()).height02 = h

						(modPanel.getCurrentObject ()).nodeCam03 = newCamFront
						(modPanel.getCurrentObject ()).mapChannel03 = bCPMFrontChannel
						(modPanel.getCurrentObject ()).width03 = w
						(modPanel.getCurrentObject ()).height03 = h

						(modPanel.getCurrentObject ()).nodeCam04 = newCamBottom
						(modPanel.getCurrentObject ()).mapChannel04 = bCPMBottomChannel
						(modPanel.getCurrentObject ()).width04 = w
						(modPanel.getCurrentObject ()).height04 = h

						(modPanel.getCurrentObject ()).nodeCam05 = newCamLeft
						(modPanel.getCurrentObject ()).mapChannel05 = bCPMLeftChannel
						(modPanel.getCurrentObject ()).width05 = w
						(modPanel.getCurrentObject ()).height05 = h

						(modPanel.getCurrentObject ()).nodeCam06 = newCamBack
						(modPanel.getCurrentObject ()).mapChannel06 = bCPMBackChannel
						(modPanel.getCurrentObject ()).width06 = w
						(modPanel.getCurrentObject ()).height06 = h
						)
					)
				)
			else if bCPMMappingType == 3 then
				(
				if (classof BlendedBoxMap) == UndefinedClass then (MessageBox "Only works in max 2017 Ext 1 and above." title:"blendedCubeProjectionMaker")
				else
					(
					if inputmap == undefined then (MessageBox "You can only create a Projection Box if you've already created a Max BlendedBoxMap." title:"blendedCubeProjectionMaker")
					else
						(
						-- prep projection box
						bCPMObjs = #()
						for i in selection do append bCPMObjs i
						select bCPMObjs

						-- Decide projection size
						w = 1024.00;h = 1024.00
						if bCPMTopImage != undefined and bCPMTopImage != "" then 
							(
							w = (getBitmapInfo bCPMTopImage)[3]
							h = (getBitmapInfo bCPMTopImage)[4]
							)

						-- Get Selection Boundingbox
						objsBoundingBox = sLibGetCollectionBBox bCPMObjs
						objsCenter = [(objsBoundingBox[1].x + objsBoundingBox[2].x)/2, (objsBoundingBox[1].y + objsBoundingBox[2].y)/2, (objsBoundingBox[1].z + objsBoundingBox[2].z)/2]
						xLength = abs(objsBoundingBox[2].x-objsBoundingBox[1].x)
						yLength = abs(objsBoundingBox[2].y-objsBoundingBox[1].y)
						zLength = abs(objsBoundingBox[2].z-objsBoundingBox[1].z)

						-- Calculate squareSize
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

						bCPMCamsPoint = Dummy pos:objsCenter boxsize:[squareSize*0.8285,squareSize*0.8285,squareSize*0.8285]
						bCPMCamsPoint.name = Uniquename "BCP_ProjectionBox_"
						inputmap.node = bCPMCamsPoint	
						)
					)
				)
			)
		)
	return #(bCPMfinalCams,bCPMCamsPoint)
	)

fn bCPMDo = 
	(
	blendedCubeProjectionMaker bCPMDoMapValue bCPMMapTypeValue bCPMDoMappingValue bCPMMappingTypeValue bCPMTopImageValue bCPMBottomImageValue bCPMRightImageValue bCPMLeftImageValue bCPMFrontImageValue bCPMBackImageValue bCPMMeditSlotTypeValue bCPMMeditSlotValue bCPMTopChannelValue bCPMBottomChannelValue bCPMRightChannelValue bCPMLeftChannelValue bCPMFrontChannelValue bCPMBackChannelValue bCPMShowWarningValue bCPMModifierNameValue bCPMCalculateSizeValue bCPMSpecificSizeValue bCPMGeminiDistanceValue
	if bCPMFloater != undefined then CloseRolloutFloater bCPMFloater
	)

fn bCPMApply = 
	(
	blendedCubeProjectionMaker bCPMDoMapValue bCPMMapTypeValue bCPMDoMappingValue bCPMMappingTypeValue bCPMTopImageValue bCPMBottomImageValue bCPMRightImageValue bCPMLeftImageValue bCPMFrontImageValue bCPMBackImageValue bCPMMeditSlotTypeValue bCPMMeditSlotValue bCPMTopChannelValue bCPMBottomChannelValue bCPMRightChannelValue bCPMLeftChannelValue bCPMFrontChannelValue bCPMBackChannelValue bCPMShowWarningValue bCPMModifierNameValue bCPMCalculateSizeValue bCPMSpecificSizeValue bCPMGeminiDistanceValue
	)
	
fn bCPMHelp = 
	(
	sLibSSPrintHelp "blendedCubeProjectionMaker"
	)
	
fn bCPMLoadDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	bCPMInputFilename = presetDir + "blendedCubeProjectionMaker.ini"
	if (sLibFileExist bCPMInputFilename == true) then
		(
		bCPMDoMapValue = execute (getINISetting bCPMInputFilename "blendedCubeProjectionMaker" "bCPMDoMapValue")
		bCPMMapTypeValue = execute (getINISetting bCPMInputFilename "blendedCubeProjectionMaker" "bCPMMapTypeValue")
		bCPMDoMappingValue = execute (getINISetting bCPMInputFilename "blendedCubeProjectionMaker" "bCPMDoMappingValue")
		bCPMMappingTypeValue = execute (getINISetting bCPMInputFilename "blendedCubeProjectionMaker" "bCPMMappingTypeValue")
		bCPMTopImageValue = (getINISetting bCPMInputFilename "blendedCubeProjectionMaker" "bCPMTopImageValue")
		bCPMBottomImageValue = (getINISetting bCPMInputFilename "blendedCubeProjectionMaker" "bCPMBottomImageValue")
		bCPMRightImageValue = (getINISetting bCPMInputFilename "blendedCubeProjectionMaker" "bCPMRightImageValue")
		bCPMLeftImageValue = (getINISetting bCPMInputFilename "blendedCubeProjectionMaker" "bCPMLeftImageValue")
		bCPMFrontImageValue = (getINISetting bCPMInputFilename "blendedCubeProjectionMaker" "bCPMFrontImageValue")
		bCPMBackImageValue = (getINISetting bCPMInputFilename "blendedCubeProjectionMaker" "bCPMBackImageValue")
		bCPMMeditSlotTypeValue = execute (getINISetting bCPMInputFilename "blendedCubeProjectionMaker" "bCPMMeditSlotTypeValue")
		bCPMMeditSlotValue = execute (getINISetting bCPMInputFilename "blendedCubeProjectionMaker" "bCPMMeditSlotValue")
		bCPMTopChannelValue = execute (getINISetting bCPMInputFilename "blendedCubeProjectionMaker" "bCPMTopChannelValue")
		bCPMBottomChannelValue = execute (getINISetting bCPMInputFilename "blendedCubeProjectionMaker" "bCPMBottomChannelValue")
		bCPMRightChannelValue = execute (getINISetting bCPMInputFilename "blendedCubeProjectionMaker" "bCPMRightChannelValue")
		bCPMLeftChannelValue = execute (getINISetting bCPMInputFilename "blendedCubeProjectionMaker" "bCPMLeftChannelValue")
		bCPMFrontChannelValue = execute (getINISetting bCPMInputFilename "blendedCubeProjectionMaker" "bCPMFrontChannelValue")
		bCPMBackChannelValue = execute (getINISetting bCPMInputFilename "blendedCubeProjectionMaker" "bCPMBackChannelValue")
		bCPMShowWarningValue = execute (getINISetting bCPMInputFilename "blendedCubeProjectionMaker" "bCPMShowWarningValue")
		bCPMModifierNameValue = (getINISetting bCPMInputFilename "blendedCubeProjectionMaker" "bCPMModifierNameValue")
		bCPMCalculateSizeValue = execute (getINISetting bCPMInputFilename "blendedCubeProjectionMaker" "bCPMCalculateSizeValue")
		bCPMSpecificSizeValue = execute (getINISetting bCPMInputFilename "blendedCubeProjectionMaker" "bCPMSpecificSizeValue")
		bCPMGeminiDistanceValue = execute (getINISetting bCPMInputFilename "blendedCubeProjectionMaker" "bCPMGeminiDistanceValue")
		bCPMPosValue = execute (getINISetting bCPMInputFilename "blendedCubeProjectionMaker" "bCPMPosValue")
		
		if bCPMDoMapValue == OK then bCPMDoMapValue = true
		if bCPMMapTypeValue == OK then bCPMMapTypeValue = 3
		if bCPMDoMappingValue == OK then bCPMDoMappingValue = false
		if bCPMMappingTypeValue == OK then bCPMMappingTypeValue = 1
		if bCPMTopImageValue == OK then bCPMTopImageValue = ""
		if bCPMBottomImageValue == OK then bCPMBottomImageValue = ""
		if bCPMRightImageValue == OK then bCPMRightImageValue = ""
		if bCPMLeftImageValue == OK then bCPMLeftImageValue = ""
		if bCPMFrontImageValue == OK then bCPMFrontImageValue = ""
		if bCPMBackImageValue == OK then bCPMBackImageValue = ""
		if bCPMMeditSlotTypeValue == OK then bCPMMeditSlotTypeValue = 1
		if bCPMMeditSlotValue == OK then bCPMMeditSlotValue = 1
		if bCPMTopChannelValue == OK then bCPMTopChannelValue = 5
		if bCPMBottomChannelValue == OK then bCPMBottomChannelValue = 8
		if bCPMRightChannelValue == OK then bCPMRightChannelValue = 6
		if bCPMLeftChannelValue == OK then bCPMLeftChannelValue = 9
		if bCPMFrontChannelValue == OK then bCPMFrontChannelValue = 7
		if bCPMBackChannelValue == OK then bCPMBackChannelValue = 10
		if bCPMShowWarningValue == OK then bCPMShowWarningValue = true
		if bCPMModifierNameValue == OK then bCPMModifierNameValue = ""
		if bCPMCalculateSizeValue == OK then bCPMCalculateSizeValue = true
		if bCPMSpecificSizeValue == OK then bCPMSpecificSizeValue = 100.0
		if bCPMGeminiDistanceValue == OK then bCPMGeminiDistanceValue = 3.0
		if bCPMPosValue == OK then bCPMPosValue = [400,400]
		)
	else
		(
		bCPMDoMapValue = true
		bCPMMapTypeValue = 3
		bCPMDoMappingValue = false
		bCPMMappingTypeValue = 1
		bCPMTopImageValue = ""
		bCPMBottomImageValue = ""
		bCPMRightImageValue = ""
		bCPMLeftImageValue = ""
		bCPMFrontImageValue = ""
		bCPMBackImageValue = ""
		bCPMMeditSlotTypeValue = 1
		bCPMMeditSlotValue = 1
		bCPMTopChannelValue = 5
		bCPMBottomChannelValue = 8
		bCPMRightChannelValue = 6
		bCPMLeftChannelValue = 9
		bCPMFrontChannelValue = 7
		bCPMBackChannelValue = 10
		bCPMShowWarningValue = true
		bCPMModifierNameValue = ""
		bCPMCalculateSizeValue = true
		bCPMSpecificSizeValue = 100.0
		bCPMGeminiDistanceValue = 3.0
		bCPMPosValue = [400,400]
		)
	)
	
fn bCPMSaveDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	if (getDirectories presetDir).count == 0 then makeDir presetDir
	bCPMOutputFilename = presetDir + "blendedCubeProjectionMaker.ini"
	if (sLibFileExist bCPMOutputFilename == true) then deleteFile bCPMOutputFilename
	setINISetting bCPMOutputFilename "blendedCubeProjectionMaker" "bCPMDoMapValue" (bCPMDoMapValue as string)
	setINISetting bCPMOutputFilename "blendedCubeProjectionMaker" "bCPMMapTypeValue" (bCPMMapTypeValue as string)
	setINISetting bCPMOutputFilename "blendedCubeProjectionMaker" "bCPMDoMappingValue" (bCPMDoMappingValue as string)
	setINISetting bCPMOutputFilename "blendedCubeProjectionMaker" "bCPMMappingTypeValue" (bCPMMappingTypeValue as string)
	setINISetting bCPMOutputFilename "blendedCubeProjectionMaker" "bCPMTopImageValue" (bCPMTopImageValue as string)
	setINISetting bCPMOutputFilename "blendedCubeProjectionMaker" "bCPMBottomImageValue" (bCPMBottomImageValue as string)
	setINISetting bCPMOutputFilename "blendedCubeProjectionMaker" "bCPMRightImageValue" (bCPMRightImageValue as string)
	setINISetting bCPMOutputFilename "blendedCubeProjectionMaker" "bCPMLeftImageValue" (bCPMLeftImageValue as string)
	setINISetting bCPMOutputFilename "blendedCubeProjectionMaker" "bCPMFrontImageValue" (bCPMFrontImageValue as string)
	setINISetting bCPMOutputFilename "blendedCubeProjectionMaker" "bCPMBackImageValue" (bCPMBackImageValue as string)
	setINISetting bCPMOutputFilename "blendedCubeProjectionMaker" "bCPMMeditSlotTypeValue" (bCPMMeditSlotTypeValue as string)	
	setINISetting bCPMOutputFilename "blendedCubeProjectionMaker" "bCPMMeditSlotValue" (bCPMMeditSlotValue as string)
	setINISetting bCPMOutputFilename "blendedCubeProjectionMaker" "bCPMTopChannelValue" (bCPMTopChannelValue as string)
	setINISetting bCPMOutputFilename "blendedCubeProjectionMaker" "bCPMBottomChannelValue" (bCPMBottomChannelValue as string)
	setINISetting bCPMOutputFilename "blendedCubeProjectionMaker" "bCPMRightChannelValue" (bCPMRightChannelValue as string)
	setINISetting bCPMOutputFilename "blendedCubeProjectionMaker" "bCPMLeftChannelValue" (bCPMLeftChannelValue as string)
	setINISetting bCPMOutputFilename "blendedCubeProjectionMaker" "bCPMFrontChannelValue" (bCPMFrontChannelValue as string)
	setINISetting bCPMOutputFilename "blendedCubeProjectionMaker" "bCPMBackChannelValue" (bCPMBackChannelValue as string)
	setINISetting bCPMOutputFilename "blendedCubeProjectionMaker" "bCPMShowWarningValue" (bCPMShowWarningValue as string)
	setINISetting bCPMOutputFilename "blendedCubeProjectionMaker" "bCPMModifierNameValue" (bCPMModifierNameValue as string)
	setINISetting bCPMOutputFilename "blendedCubeProjectionMaker" "bCPMCalculateSizeValue" (bCPMCalculateSizeValue as string)
	setINISetting bCPMOutputFilename "blendedCubeProjectionMaker" "bCPMSpecificSizeValue" (bCPMSpecificSizeValue as string)	
	setINISetting bCPMOutputFilename "blendedCubeProjectionMaker" "bCPMGeminiDistanceValue" (bCPMGeminiDistanceValue as string)
	setINISetting bCPMOutputFilename "blendedCubeProjectionMaker" "bCPMPosValue" (bCPMFloater.pos as string)
	)

-- UI

fn bCPMDefineUI = 
	(
	rollout bCPMRollout "blendedCubeProjectionMaker"
		(
		group "Action"
		(
		checkbox bCPMDoMapCheckbox "Create Map?" checked:bCPMDoMapValue align:#left across:2 offset:[0,3]
		dropdownlist bCPMMapTypeDropdown "" items:#("Falloff Method", "CameraMapGemini Method", "Max's BlendedBoxMap Method") selection:bCPMMapTypeValue width:200 align:#center enabled:false
		checkbox bCPMDoMappingCheckbox "Create Mapping Modifiers?" checked:bCPMDoMappingValue align:#left across:2 offset:[0,3]
		dropdownlist bCPMMappingTypeDropdown "" items:#("UVW Mapping Method", "CameraMapGemini Method", "Max's BlendedBoxMap Method") selection:bCPMMappingTypeValue width:200 align:#center enabled:false
		)

		group "Map"
		(
		dropdownlist bCPMMeditSlotTypeDropdown "" items:#("Use Selected Medit Slot", "Use Specific Medit Slot", "Place in Active SME") selection:bCPMMeditSlotTypeValue width:143 align:#right across:2 offset:[15,3] enabled:false
		spinner bCPMMeditSlotSpinner "Medit Slot: " range:[1,24,bCPMMeditSlotValue] type:#integer fieldWidth:30 align:#right offset:[-24,6] enabled:false
		edittext bCPMTopImageEditText "Top:" fieldWidth:345 text:bCPMTopImageValue align:#right offset:[180,0] across:2 enabled:false
		button bCPMTopImageFileButton "F" width:20 toolTip:"Choose File" align:#right offset:[0,-2] enabled:false
		edittext bCPMBottomImageEditText "Bottom:" fieldWidth:345 text:bCPMBottomImageValue align:#right offset:[180,0] across:2 enabled:false
		button bCPMBottomImageFileButton "F" width:20 toolTip:"Choose File" align:#right offset:[0,-2] enabled:false
		edittext bCPMRightImageEditText "Right:" fieldWidth:345 text:bCPMRightImageValue align:#right offset:[180,0] across:2 enabled:false
		button bCPMRightImageFileButton "F" width:20 toolTip:"Choose File" align:#right offset:[0,-2] enabled:false
		edittext bCPMLeftImageEditText "Left:" fieldWidth:345 text:bCPMLeftImageValue align:#right offset:[180,0] across:2 enabled:false
		button bCPMLeftImageFileButton "F" width:20 toolTip:"Choose File" align:#right offset:[0,-2] enabled:false
		edittext bCPMFrontImageEditText "Front:" fieldWidth:345 text:bCPMFrontImageValue align:#right offset:[180,0] across:2 enabled:false
		button bCPMFrontImageFileButton "F" width:20 toolTip:"Choose File" align:#right offset:[0,-2] enabled:false
		edittext bCPMBackImageEditText "Back:" fieldWidth:345 text:bCPMBackImageValue align:#right offset:[180,0] across:2 enabled:false
		button bCPMBackImageFileButton "F" width:20 toolTip:"Choose File" align:#right offset:[0,-2] enabled:false
		)

		group "Mapping Modifiers"
		(
		checkbox bCPMShowWarningCheckbox "Show Reset Xform Warning?" checked:bCPMShowWarningValue align:#left enabled:false
		checkbox bCPMCalculateSizeCheckbox "Auto Calculate Size?" checked:bCPMCalculateSizeValue align:#left across:3 enabled:false
		spinner bCPMSpecificSizeSpinner "Size: " range:[0.0001,9999999,bCPMSpecificSizeValue] type:#float fieldWidth:55 align:#left offset:[-15,1] enabled:false
		edittext bCPMModifierNameEditText "Mod Name:" fieldWidth:120 text:bCPMModifierNameValue align:#right enabled:false
		spinner bCPMGeminiDistanceSpinner "CameraMapGemini Camera Distance Multipier: " range:[1,9999,bCPMGeminiDistanceValue] type:#float fieldWidth:40 align:#right enabled:false
		)
		
		group "Map Channels"
		(
		spinner bCPMTopChannelSpinner "Top Map Channel: " range:[1,99,bCPMTopChannelValue] type:#integer fieldWidth:40 align:#left across:2 offset:[6,0] enabled:false
		spinner bCPMBottomChannelSpinner "Bottom Map Channel: " range:[1,99,bCPMBottomChannelValue] type:#integer fieldWidth:40 align:#right enabled:false
		spinner bCPMRightChannelSpinner "Right Map Channel: " range:[1,99,bCPMRightChannelValue] type:#integer fieldWidth:40 align:#left across:2 enabled:false
		spinner bCPMLeftChannelSpinner "Left Map Channel: " range:[1,99,bCPMLeftChannelValue] type:#integer fieldWidth:40 align:#right enabled:false
		spinner bCPMFrontChannelSpinner "Front Map Channel: " range:[1,99,bCPMFrontChannelValue] type:#integer fieldWidth:40 align:#left across:2 offset:[1,0] enabled:false
		spinner bCPMBackChannelSpinner "Back Map Channel: " range:[1,99,bCPMBackChannelValue] type:#integer fieldWidth:40 align:#right enabled:false
		)

		on bCPMDoMapCheckbox changed state do (bCPMDoMapValue = state;curPos = bCPMFloater.pos;bCPMCloseOpenUI curPos)
		on bCPMMapTypeDropdown selected i do (bCPMMapTypeValue = i;curPos = bCPMFloater.pos;bCPMCloseOpenUI curPos)
		on bCPMDoMappingCheckbox changed state do (bCPMDoMappingValue = state;curPos = bCPMFloater.pos;bCPMCloseOpenUI curPos)
		on bCPMMappingTypeDropdown selected i do (bCPMMappingTypeValue = i;curPos = bCPMFloater.pos;bCPMCloseOpenUI curPos)
		
		on bCPMMeditSlotTypeDropdown selected i do 
			(
			bCPMMeditSlotTypeValue = i
			if bCPMMeditSlotTypeValue == 2 and bCPMDoMapValue == true then bCPMMeditSlotSpinner.enabled = true else bCPMMeditSlotSpinner.enabled = false
			)
		on bCPMMeditSlotSpinner changed val do bCPMMeditSlotValue = val
		on bCPMTopImageEditText changed text do bCPMTopImageValue = bCPMTopImageEditText.text
		on bCPMTopImageFileButton pressed do 
			(
			myfile = getOpenFileName()
			if myfile == undefined then
				(
				bCPMTopImageEditText.text = ""
				bCPMTopImageValue = ""
				)
			else 
				(
				bCPMTopImageEditText.text = myfile
				bCPMTopImageValue = myfile
				)
			)
		on bCPMBottomImageEditText changed text do bCPMBottomImageValue = bCPMBottomImageEditText.text
		on bCPMBottomImageFileButton pressed do 
			(
			myfile = getOpenFileName()
			if myfile == undefined then
				(
				bCPMBottomImageEditText.text = ""
				bCPMBottomImageValue = ""
				)
			else 
				(
				bCPMBottomImageEditText.text = myfile
				bCPMBottomImageValue = myfile
				)
			)
		on bCPMRightImageEditText changed text do bCPMRightImageValue = bCPMRightImageEditText.text
		on bCPMRightImageFileButton pressed do
			(
			myfile = getOpenFileName()
			if myfile == undefined then
				(
				bCPMRightImageEditText.text = ""
				bCPMRightImageValue = ""
				)
			else 
				(
				bCPMRightImageEditText.text = myfile
				bCPMRightImageValue = myfile
				)
			)
		on bCPMLeftImageEditText changed text do bCPMLeftImageValue = bCPMLeftImageEditText.text
		on bCPMLeftImageFileButton pressed do 
			(
			myfile = getOpenFileName()
			if myfile == undefined then
				(
				bCPMLeftImageEditText.text = ""
				bCPMLeftImageValue = ""
				)
			else 
				(
				bCPMLeftImageEditText.text = myfile
				bCPMLeftImageValue = myfile
				)
			)
		on bCPMFrontImageEditText changed text do bCPMFrontImageValue = bCPMFrontImageEditText.text
		on bCPMFrontImageFileButton pressed do 
			(
			myfile = getOpenFileName()
			if myfile == undefined then
				(
				bCPMFrontImageEditText.text = ""
				bCPMFrontImageValue = ""
				)
			else 
				(
				bCPMFrontImageEditText.text = myfile
				bCPMFrontImageValue = myfile
				)
			)
		on bCPMBackImageEditText changed text do bCPMBackImageValue = bCPMBackImageEditText.text
		on bCPMBackImageFileButton pressed do 
			(
			myfile = getOpenFileName()
			if myfile == undefined then
				(
				bCPMBackImageEditText.text = ""
				bCPMBackImageValue = ""
				)
			else 
				(
				bCPMBackImageEditText.text = myfile
				bCPMBackImageValue = myfile
				)
			)
			
		on bCPMShowWarningCheckbox changed state do bCPMShowWarningValue = state
		on bCPMCalculateSizeCheckbox changed state do 
			(
			bCPMCalculateSizeValue = state
			bCPMSpecificSizeSpinner.enabled = not bCPMCalculateSizeValue
			)
		on bCPMSpecificSizeSpinner changed val do bCPMSpecificSizeValue = val
		on bCPMModifierNameEditText changed text do bCPMModifierNameValue = bCPMModifierNameEditText.text
		on bCPMGeminiDistanceSpinner changed val do bCPMGeminiDistanceValue = val

		on bCPMTopChannelSpinner changed val do bCPMTopChannelValue = val
		on bCPMBottomChannelSpinner changed val do bCPMBottomChannelValue = val
		on bCPMRightChannelSpinner changed val do bCPMRightChannelValue = val
		on bCPMLeftChannelSpinner changed val do bCPMLeftChannelValue = val
		on bCPMFrontChannelSpinner changed val do bCPMFrontChannelValue = val
		on bCPMBackChannelSpinner changed val do bCPMBackChannelValue = val

		group "Tools"
		(
		button bCPMDeleteOldButton "Delete Blended Cube Projection Modifiers On Selected Objects" width:320 toolTip:"Delete Blended Box Map On Selected Objects" align:#center offset:[0,-2]
		)
		on bCPMDeleteOldButton pressed do 
			(
			sLibRemoveModifiersByNameFragment $ "bCPM_"
			sLibRemoveModifiersByNameFragment $ "BCP_"
			)
			
		button bCPMDoButton "Do" width:70 toolTip:"Do It and Close UI" pos:[70,512]
		on bCPMDoButton pressed do bCPMDo()
		button bCPMApplyButton "Apply" width:70 toolTip:"Do It and Keep UI Open" pos:[142,512]
		on bCPMApplyButton pressed do bCPMApply()
		button bCPMHelpButton "Help" width:70 toolTip:"Help" pos:[214,512]
		on bCPMHelpButton pressed do bCPMHelp()
		button bCPMSaveDefButton "SaveDef" width:70 toolTip:"Save Current Settings as Default" pos:[287,512]
		on bCPMSaveDefButton pressed do bCPMSaveDef()
		
		on bCPMRollout open do
			(
			if bCPMDoMapValue == true then
				(			
				bCPMMapTypeDropdown.enabled = true
				if bCPMMapTypeValue == 1 or bCPMMapTypeValue == 2 then
					(
					bCPMMeditSlotTypeDropdown.enabled = true
					if bCPMMeditSlotTypeValue == 2 then bCPMMeditSlotSpinner.enabled = true else bCPMMeditSlotSpinner.enabled = false
					bCPMTopImageEditText.enabled = true
					bCPMTopImageFileButton.enabled = true
					bCPMBottomImageEditText.enabled = true
					bCPMBottomImageFileButton.enabled = true
					bCPMRightImageEditText.enabled = true
					bCPMRightImageFileButton.enabled = true
					bCPMLeftImageEditText.enabled = true
					bCPMLeftImageFileButton.enabled = true
					bCPMFrontImageEditText.enabled = true
					bCPMFrontImageFileButton.enabled = true
					bCPMBackImageEditText.enabled = true
					bCPMBackImageFileButton.enabled = true					
					
					bCPMTopChannelSpinner.enabled = true
					bCPMBottomChannelSpinner.enabled = true
					bCPMRightChannelSpinner.enabled = true
					bCPMLeftChannelSpinner.enabled = true
					bCPMFrontChannelSpinner.enabled = true
					bCPMBackChannelSpinner.enabled = true
					)
				if bCPMMapTypeValue == 3 then
					(
					bCPMMeditSlotTypeDropdown.enabled = true
					if bCPMMeditSlotTypeValue == 2 then bCPMMeditSlotSpinner.enabled = true else bCPMMeditSlotSpinner.enabled = false
					bCPMTopImageEditText.enabled = true
					bCPMTopImageFileButton.enabled = true
					bCPMBottomImageEditText.enabled = true
					bCPMBottomImageFileButton.enabled = true
					bCPMRightImageEditText.enabled = true
					bCPMRightImageFileButton.enabled = true
					bCPMLeftImageEditText.enabled = true
					bCPMLeftImageFileButton.enabled = true
					bCPMFrontImageEditText.enabled = true
					bCPMFrontImageFileButton.enabled = true
					bCPMBackImageEditText.enabled = true
					bCPMBackImageFileButton.enabled = true					
					)
				)
			if bCPMDoMappingValue == true then			
				(
				bCPMMappingTypeDropdown.enabled = true
				if bCPMMappingTypeValue == 1 then
					(
					bCPMShowWarningCheckbox.enabled = true
					bCPMCalculateSizeCheckbox.enabled = true
					bCPMSpecificSizeSpinner.enabled = not bCPMCalculateSizeValue
					bCPMModifierNameEditText.enabled = true

					bCPMTopChannelSpinner.enabled = true
					bCPMBottomChannelSpinner.enabled = true
					bCPMRightChannelSpinner.enabled = true
					bCPMLeftChannelSpinner.enabled = true
					bCPMFrontChannelSpinner.enabled = true
					bCPMBackChannelSpinner.enabled = true
					)
				else if bCPMMappingTypeValue == 2 then
					(
					bCPMShowWarningCheckbox.enabled = true
					bCPMCalculateSizeCheckbox.enabled = true
					bCPMSpecificSizeSpinner.enabled = not bCPMCalculateSizeValue
					bCPMModifierNameEditText.enabled = true
					bCPMGeminiDistanceSpinner.enabled = true

					bCPMTopChannelSpinner.enabled = true
					bCPMBottomChannelSpinner.enabled = true
					bCPMRightChannelSpinner.enabled = true
					bCPMLeftChannelSpinner.enabled = true
					bCPMFrontChannelSpinner.enabled = true
					bCPMBackChannelSpinner.enabled = true
					)
				if bCPMMappingTypeValue == 3 then
					(
					bCPMShowWarningCheckbox.enabled = true
					bCPMCalculateSizeCheckbox.enabled = true
					bCPMSpecificSizeSpinner.enabled = not bCPMCalculateSizeValue
					bCPMModifierNameEditText.enabled = true
					)
				)
			)
		)
	)
)
-------------------------------------------------------------------------------