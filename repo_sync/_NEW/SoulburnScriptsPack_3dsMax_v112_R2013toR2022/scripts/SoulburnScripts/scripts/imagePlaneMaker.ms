-------------------------------------------------------------------------------
-- imagePlaneMaker.ms
-- By Neil Blevins (info@neilblevins.com)
-- v 1.08
-- Created On: 01/14/07
-- Modified On: 09/04/18
-- tested using Max 2017
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Required Files:
-- sLib.ms
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Description:
-- Creates a set of 2d image planes you can use to create a 3d model. Just draw
-- a front, side and top view of your object, scan the views into photoshop, 
-- adjust their size, save them as 3 images, and this script will import them 
-- into max.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Tutorial:
-- Draw a front, side and top view of your object, scan the views into photoshop, 
-- adjust their size, save them as 3 images. Run the script in UI mode. Add your
-- 3 images by clicking on the 3 F's to the right of the UI. Hit Do. Now you have
-- 3 image planes with your images on them. Will also work if you have only 1 
-- or 2 images.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Revision History:
--
-- v 1.01 Fixed a bug that would stop the Ini file from loading.
--
-- v 1.02 Replaced the Close button with a Help button. Use the X button to 
-- Close the Floater.
--
-- v 1.03 Now has a button to quickly hide or unhide the templates.
--
-- v 1.04 Fixed a bug that would crash the script when given a blank map name.
--
-- v 1.05 Fixed a bug that shows up if you have max set to use Real World Scale
-- by default.
--
-- v 1.06 Added an option to create a new Layer For Your Template on template 
-- creation.
--
-- v 1.07 When creating a new layer, the layer is now frozen by default.
--
-- v 1.08 Layer is places the templates is now called "_imagePlaneMaker" so 
-- it appears at the top of the layer stack.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
(
-- Globals

global imagePlaneMaker
global imagePlaneMakerDefaults
global imagePlaneMakerUI

global iPMCloseOpenUI

global iPMDo
global iPMApply
global iPMHelp
global iPMLoadDef
global iPMSaveDef

global iPMDefineUI
global iPMRollout
global iPMFloater

-- Includes

include "$scripts\SoulburnScripts\lib\sLib.ms"

-- Variables

iPMTopImageValue = ""
iPMFrontImageValue = ""
iPMSideImageValue = ""
iPMScaleValue = 1.0
iPMRenderableValue = false
iPMFrozenValue = false
iPMMakeLayerValue = true
iPMPosValue = [400,400]

wBLastImagePlaneMaker = #()

-- Functions

fn imagePlaneMaker iPMTopImage iPMFrontImage iPMSideImage iPMScale iPMRenderable iPMFrozen iPMMakeLayer = 
	(
	undo "imagePlaneMaker" on
		(
		wBLastImagePlaneMaker = #()
		iPImages = #()
		iPImageNames = #()
		ipImageWidths = #()
		ipImageHeights = #()		
		
		-- Get Image Info
		
		-- Top
		error = false
		if iPMTopImage != "" then 
			(
			try 
				(
				iPMTopImageOpened = openbitmap iPMTopImage
				append iPImages iPMTopImage
				append iPImageNames (getFilenameFile iPMTopImage)
				append ipImageWidths (iPMScale*iPMTopImageOpened.width)
				append ipImageHeights (iPMScale*iPMTopImageOpened.height)
				)
			catch (error = true)
			)
		else (error = true)
		if error == true then
			(
			append iPImages undefined
			append iPImageNames undefined
			append ipImageWidths 0
			append ipImageHeights 0
			)
		-- Front
		error = false
		if iPMFrontImage != "" then 
			(
			try 
				(
				iPMFrontImageOpened = openbitmap iPMFrontImage
				append iPImages iPMFrontImage
				append iPImageNames (getFilenameFile iPMFrontImage)
				append ipImageWidths (iPMScale*iPMFrontImageOpened.width)
				append ipImageHeights (iPMScale*iPMFrontImageOpened.height)
				)
			catch (error = true)
			)
		else (error = true)
		if error == true then
			(
			append iPImages undefined
			append iPImageNames undefined
			append ipImageWidths 0
			append ipImageHeights 0
			)
		-- Side
		error = false
		if iPMSideImage != "" then 
			(
			try 
				(
				iPMSideImageOpened = openbitmap iPMSideImage
				append iPImages iPMSideImage
				append iPImageNames (getFilenameFile iPMSideImage)
				append ipImageWidths (iPMScale*iPMSideImageOpened.width)
				append ipImageHeights (iPMScale*iPMSideImageOpened.height)
				)
			catch (error = true)
			)
		else (error = true)
		if error == true then
			(
			append iPImages undefined
			append iPImageNames undefined
			append ipImageWidths 0
			append ipImageHeights 0
			)

		-- Create Planes
		
		-- Top
		if iPImages[1] != undefined then
			(
			mat = Standardmaterial ()
			mat.name = "ImagePlaneTop_" + iPImageNames[1]
			mat.diffuseMap = Bitmaptexture fileName:iPImages[1]
			mat.diffuseMap.coords.realWorldScale = off
			mat.selfIllumAmount = 100
			mat.twoSided = on

			obj = Plane length:ipImageHeights[1] width:ipImageWidths[1]
			obj.realWorldMapSize = off
			
			-- pos
			obj.pos = [0,0,0]
			
			obj.name = "ImagePlaneTop_" + iPImageNames[1]
			obj.material = mat
			showTextureMap obj.material obj.material.diffusemap on
			obj.showFrozenInGray = off
			obj.wirecolor = color 70 70 70
			obj.isfrozen = iPMFrozen
			obj.renderable = iPMRenderable
			append wBLastImagePlaneMaker obj
			)
		-- Front
		if iPImages[2] != undefined then 
			(
			mat = Standardmaterial ()
			mat.name = "ImagePlaneFront_" + iPImageNames[2]
			mat.diffuseMap = Bitmaptexture fileName:iPImages[2]
			mat.diffuseMap.coords.realWorldScale = off
			mat.selfIllumAmount = 100
			mat.twoSided = on

			obj = Plane length:ipImageHeights[2] width:ipImageWidths[2] transform:(matrix3 [1,0,0] [0,0,1] [0,-1,0] [0,0,0])
			obj.realWorldMapSize = off
			
			-- pos
			frontYPos = ipImageHeights[1]
			frontZPos = ipImageHeights[2]			
			if ipImageHeights[1] == 0 then frontYPos = ipImageWidths[3]
			obj.pos = [0,0.5*frontYPos,0.5*frontZPos]
			
			obj.name = "ImagePlaneFront_" + iPImageNames[2]
			obj.material = mat
			showTextureMap obj.material obj.material.diffusemap on
			obj.showFrozenInGray = off
			obj.wirecolor = color 70 70 70
			obj.isfrozen = iPMFrozen
			obj.renderable = iPMRenderable
			append wBLastImagePlaneMaker obj
			)
		-- Side
		if iPImages[3] != undefined then 
			(
			mat = Standardmaterial ()
			mat.name = "imagePlaneSide_" + iPImageNames[3]
			mat.diffuseMap = Bitmaptexture fileName:iPImages[3]
			mat.diffuseMap.coords.realWorldScale = off
			mat.selfIllumAmount = 100
			mat.twoSided = on

			obj = Plane length:ipImageHeights[3] width:ipImageWidths[3] transform:(matrix3 [0,1,0] [0,0,1] [1,0,0] [0,0,0])
			obj.realWorldMapSize = off
			
			-- pos
			sideXPos = ipImageWidths[1]
			sideZPos = ipImageHeights[2]
			if ipImageWidths[1] == 0 then sideXPos = ipImageWidths[2] 
			if ipImageHeights[2] == 0 then sideZPos = ipImageHeights[3] 
			obj.pos = [-0.5*sideXPos,0,0.5*sideZPos]
			
			obj.name = "imagePlaneSide_" + iPImageNames[3]
			obj.material = mat
			showTextureMap obj.material obj.material.diffusemap on
			obj.showFrozenInGray = off
			obj.wirecolor = color 70 70 70
			obj.isfrozen = iPMFrozen
			obj.renderable = iPMRenderable
			append wBLastImagePlaneMaker obj
			)

		if iPMMakeLayer == true then
			(		
			if wBLastImagePlaneMaker.count != 0 then 
				(
				if LayerManager.getLayerFromName "_imagePlaneMaker" == undefined then layermanager.newLayerFromName "_imagePlaneMaker"
				myLayer = LayerManager.getLayerFromName "_imagePlaneMaker"
				for obj in wBLastImagePlaneMaker do myLayer.addnode obj
				myLayer.isFrozen = true
				)
			)
		if wBLastImagePlaneMaker.count != 0 then selectionSets["imagePlaneMaker"] = wBLastImagePlaneMaker
		)
	)
	
fn imagePlaneMakerDefaults = 
	(
	iPMLoadDef()
	imagePlaneMaker iPMTopImageValue iPMFrontImageValue iPMSideImageValue iPMScaleValue iPMRenderableValue iPMFrozenValue iPMMakeLayerValue
	)
	
fn imagePlaneMakerUI = 
	(
	iPMLoadDef()
	iPMCloseOpenUI iPMPosValue
	)
	
fn iPMCloseOpenUI pos = 
	(
	if iPMFloater != undefined then CloseRolloutFloater iPMFloater
	iPMDefineUI()
	iPMFloater = newRolloutFloater "imagePlaneMaker v1.08" 450 256 pos.x pos.y
	addRollout iPMRollout iPMFloater
	)

fn iPMDo = 
	(
	imagePlaneMaker iPMTopImageValue iPMFrontImageValue iPMSideImageValue iPMScaleValue iPMRenderableValue iPMFrozenValue iPMMakeLayerValue
	if iPMFloater != undefined then CloseRolloutFloater iPMFloater
	)

fn iPMApply = 
	(
	imagePlaneMaker iPMTopImageValue iPMFrontImageValue iPMSideImageValue iPMScaleValue iPMRenderableValue iPMFrozenValue iPMMakeLayerValue
	)
	
fn iPMHelp = 
	(
	sLibSSPrintHelp "imagePlaneMaker"
	)
	
fn iPMLoadDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	iPMInputFilename = presetDir + "imagePlaneMaker.ini"
	if (sLibFileExist iPMInputFilename == true) then
		(
		iPMTopImageValue = (getINISetting iPMInputFilename "imagePlaneMaker" "iPMTopImageValue")
		iPMFrontImageValue = (getINISetting iPMInputFilename "imagePlaneMaker" "iPMFrontImageValue")
		iPMSideImageValue = (getINISetting iPMInputFilename "imagePlaneMaker" "iPMSideImageValue")
		iPMScaleValue = execute (getINISetting iPMInputFilename "imagePlaneMaker" "iPMScaleValue")
		iPMRenderableValue = execute (getINISetting iPMInputFilename "imagePlaneMaker" "iPMRenderableValue")
		iPMFrozenValue = execute (getINISetting iPMInputFilename "imagePlaneMaker" "iPMFrozenValue")
		iPMMakeLayerValue = execute (getINISetting iPMInputFilename "imagePlaneMaker" "iPMMakeLayerValue")
		iPMPosValue = execute (getINISetting iPMInputFilename "imagePlaneMaker" "iPMPosValue")
		
		if iPMTopImageValue == OK then iPMTopImageValue = ""
		if iPMFrontImageValue == OK then iPMFrontImageValue = ""
		if iPMSideImageValue == OK then iPMSideImageValue = ""
		if iPMScaleValue == OK then iPMScaleValue = 1.0
		if iPMRenderableValue == OK then iPMRenderableValue = false
		if iPMFrozenValue == OK then iPMFrozenValue = false
		if iPMMakeLayerValue == OK then iPMMakeLayerValue = true
		if iPMPosValue == OK then iPMPosValue = [400,400]
		)
	else
		(
		iPMTopImageValue = ""
		iPMFrontImageValue = ""
		iPMSideImageValue = ""
		iPMScaleValue = 1.0
		iPMRenderableValue = false
		iPMFrozenValue = false
		iPMMakeLayerValue = true
		iPMPosValue = [400,400]
		)
	)
	
fn iPMSaveDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	if (getDirectories presetDir).count == 0 then makeDir presetDir
	iPMOutputFilename = presetDir + "imagePlaneMaker.ini"
	if (sLibFileExist iPMOutputFilename == true) then deleteFile iPMOutputFilename
	setINISetting iPMOutputFilename "imagePlaneMaker" "iPMTopImageValue" (iPMTopImageValue as string)
	setINISetting iPMOutputFilename "imagePlaneMaker" "iPMFrontImageValue" (iPMFrontImageValue as string)
	setINISetting iPMOutputFilename "imagePlaneMaker" "iPMSideImageValue" (iPMSideImageValue as string)
	setINISetting iPMOutputFilename "imagePlaneMaker" "iPMScaleValue" (iPMScaleValue as string)
	setINISetting iPMOutputFilename "imagePlaneMaker" "iPMRenderableValue" (iPMRenderableValue as string)
	setINISetting iPMOutputFilename "imagePlaneMaker" "iPMFrozenValue" (iPMFrozenValue as string)
	setINISetting iPMOutputFilename "imagePlaneMaker" "iPMMakeLayerValue" (iPMMakeLayerValue as string)
	setINISetting iPMOutputFilename "imagePlaneMaker" "iPMPosValue" (iPMFloater.pos as string)
	)

-- UI

fn iPMDefineUI = 
	(
	rollout iPMRollout "imagePlaneMaker"
		(
		group "Images"
		(
		edittext iPMTopImageEditText "Top:" fieldWidth:355 text:iPMTopImageValue align:#left offset:[3,0] across:2
		button iPMTopFileButton "F" width:20 toolTiPM:"Choose File" align:#right offset:[0,-2]
		edittext iPMFrontImageEditText "Front:" fieldWidth:355 text:iPMFrontImageValue align:#left offset:[-2,0] across:2
		button iPMFrontFileButton "F" width:20 toolTiPM:"Choose File" align:#right offset:[0,-2]
		edittext iPMSideImageEditText "Side:" fieldWidth:355 text:iPMSideImageValue align:#left offset:[1,0] across:2
		button iPMSideFileButton "F" width:20 toolTiPM:"Choose File" align:#right offset:[0,-2]
		)

		on iPMTopImageEditText changed text do iPMTopImageValue = iPMTopImageEditText.text
		on iPMTopFileButton pressed do 
			(
			myfile = getOpenFileName()
			if myfile == undefined then 
				(
				iPMTopImageEditText.text = ""
				iPMTopImageValue = ""
				)
			else 
				(
				iPMTopImageEditText.text = myfile
				iPMTopImageValue = myfile
				)
			)
		on iPMFrontImageEditText changed text do iPMFrontImageValue = iPMFrontImageEditText.text
		on iPMFrontFileButton pressed do 
			(
			myfile = getOpenFileName()
			if myfile == undefined then 
				(
				iPMFrontImageEditText.text = ""
				iPMFrontImageValue = ""
				)
			else 
				(
				iPMFrontImageEditText.text = myfile
				iPMFrontImageValue = myfile
				)
			)
		on iPMSideImageEditText changed text do iPMSideImageValue = iPMSideImageEditText.text
		on iPMSideFileButton pressed do 
			(
			myfile = getOpenFileName()
			if myfile == undefined then 
				(
				iPMSideImageEditText.text = ""
				iPMSideImageValue = ""
				)
			else 
				(
				iPMSideImageEditText.text = myfile
				iPMSideImageValue = myfile
				)
			)

		group "Options"
		(
		checkbox iPMRenderableCheckbox "Renderable" checked:iPMRenderableValue align:#left across:2
		checkbox iPMFrozenCheckbox "Frozen" checked:iPMFrozenValue align:#right
		checkbox iPMMakeLayerCheckbox "Make New Frozen Layer" checked:iPMMakeLayerValue align:#left across:2
		spinner iPMScaleSpinner "Scale Factor: " range:[0.01,9999.0,iPMScaleValue] type:#float fieldWidth:50 align:#right
		button iPMDeletePlanesButton "Delete Existing Planes" width:200 toolTip:"Delete Existing Planes" align:#left across:2
		button iPMVisibilityToggleButton "Visibility Toggle" width:200 toolTip:"Toggle Visibility Of Existing Planes" align:#right
		)

		on iPMRenderableCheckbox changed state do iPMRenderableValue = state
		on iPMFrozenCheckbox changed state do iPMFrozenValue = state
		on iPMMakeLayerCheckbox changed state do iPMMakeLayerValue = state
		on iPMScaleSpinner changed val do iPMScaleValue = val
		
		on iPMDeletePlanesButton pressed do 
			(
			try
				(
				undo "imagePlaneMaker" on
					(
					for i in wBLastImagePlaneMaker do delete i
					)
				)
			catch (MessageBox "This operation has failed. The previous Image Planes either no longer exists, or you've closed the script floater since it was made." title:"imagePlaneMaker")
			)
		on iPMVisibilityToggleButton pressed do 
			(
			try
				(
				for i in selectionSets["imagePlaneMaker"] do
					(
					if i.isHidden == true then i.isHidden = false
					else i.isHidden = true
					)
				)
			catch ()
			)

		button iPMDoButton "Do" width:70 toolTiPM:"Do It and Close UI" pos:[70,199]
		on iPMDoButton pressed do iPMDo()
		button iPMApplyButton "Apply" width:70 toolTiPM:"Do It and Keep UI Open" pos:[142,199]
		on iPMApplyButton pressed do iPMApply()
		button iPMHelpButton "Help" width:70 toolTiPM:"Help" pos:[214,199]
		on iPMHelpButton pressed do iPMHelp()
		button iPMSaveDefButton "SaveDef" width:70 toolTiPM:"Save Current Settings as Default" pos:[287,199]
		on iPMSaveDefButton pressed do iPMSaveDef()
		)
	)
)
-------------------------------------------------------------------------------