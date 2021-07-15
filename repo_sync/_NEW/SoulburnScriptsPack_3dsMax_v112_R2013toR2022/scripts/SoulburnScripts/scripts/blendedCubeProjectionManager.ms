-------------------------------------------------------------------------------
-- blendedCubeProjectionManager.ms
-- By Neil Blevins (info@neilblevins.com)
-- v 1.00
-- Created On: 07/29/16
-- Modified On: 11/12/16
-- tested using Max 2017
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Required Files:
-- sLib.ms
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Description:
-- Lets you change parameters to any Blended Cube Projection inside the material
-- you currently have active or the objects you have selected.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Tutorial:
-- Select a material in the Material Editor that contains several Blended Box Maps
-- that are set to 6 sided and Projected Onto is set to "Multiple Objects At Once".
-- Run The UI version of the script. Check "Do Projection Box", click the "Pick 
-- The Projection Box" pickbox and choose a dummy in your scene. Click "Do". 
-- Now all Blended Box Maps maps in the material have that same value.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
(
-- Globals

global blendedCubeProjectionManager
global blendedCubeProjectionManagerDefaults
global blendedCubeProjectionManagerUI

global bCPMANCloseOpenUI

global bCPMANDo
global bCPMANApply
global bCPMANHelp
global bCPMANLoadDef
global bCPMANSaveDef

global bCPMANDefineUI
global bCPMANRollout
global bCPMANFloater

-- Includes

include "$scripts\SoulburnScripts\lib\sLib.ms"

-- Variables

global bCPMANProjectionBoxObject = undefined
bCPMANModeValue = 2
bCPMANDoMaxProjectionBoxValue = true
bCPMANDoMaxBlendValue = false
bCPMANMaxBlendValue = 25.0
bCPMANDoMaxLockToFrameValue = true
bCPMANMaxLockToFrameValue = 0
 
bCPMANPosValue = [400,400]

-- Functions

fn blendedCubeProjectionManager bCPMANMode bCPMANDoMaxProjectionBox bCPMANDoMaxBlend bCPMANMaxBlend bCPMANDoMaxLockToFrame bCPMANMaxLockToFrame = 
	(
	undo "blendedCubeProjectionManager" on
		(
		mat = undefined
		a = #()
		if bCPMANDoMaxProjectionBox == true and bCPMANProjectionBoxObject == undefined then (MessageBox "Please pick a Projection Box" title:"blendedCubeProjectionManager";return false)

		if bCPMANMode == 1 then 
			(
			if MatEditor.mode == #basic then 
				(
				sl = medit.GetActiveMtlSlot() 
				mat = meditmaterials[sl]
				)
			else 
				(
				if (sme.IsOpen()) == false then sme.Open()
				mat = sme.GetMtlInParamEditor()
				)
			if mat != undefined then
				(
				if superclassof mat == textureMap then append a mat
				sLibGetMapsFromMaxWrapperObject mat a 
				)
			else (MessageBox "There doesn't appear to be a material properly selected in the material editor." title:"blendedCubeProjectionManager")	
			)
		else a = sLibGetAllMapsFromSelectedObjects()		

		b = #()
		c = #()
		for i in a do
			(
			if (classof i) == VRayTriplanarTex then append b i
			if (classof i) == BlendedBoxMap then append c i
			)
		for i in b do
			(
			)
		for i in c do
			(
			if i.mode == 2 then
				(
				if bCPMANDoMaxProjectionBox == true then
					(
					if isdeleted bCPMANProjectionBoxObject == true then MessageBox "Your Projection Box Object no longer seems to exist, please pick a new object" title:"blendedCubeProjectionManager"
					else
						(
						if (classof bCPMANProjectionBoxObject) != Dummy then MessageBox "Please pick a dummy" title:"blendedCubeProjectionManager"
						else
							(
							i.texturespace = 1
							i.node = bCPMANProjectionBoxObject
							)
						)
					)
				if bCPMANDoMaxBlend == true then i.Blend = bCPMANMaxBlend
				if bCPMANDoMaxLockToFrame == true then
					(
					i.lockToFrame = true
					i.lockFrame = bCPMANMaxLockToFrame
					)
				)
			)
		)
	)

fn blendedCubeProjectionManagerDefaults = 
	(
	bCPMANLoadDef()
	blendedCubeProjectionManager bCPMANModeValue bCPMANDoMaxProjectionBoxValue bCPMANDoMaxBlendValue bCPMANMaxBlendValue bCPMANDoMaxLockToFrameValue bCPMANMaxLockToFrameValue
	)
	
fn blendedCubeProjectionManagerUI = 
	(
	bCPMANLoadDef()
	bCPMANCloseOpenUI bCPMANPosValue
	)

fn bCPMANCloseOpenUI pos = 
	(
	if bCPMANFloater != undefined then CloseRolloutFloater bCPMANFloater
	bCPMANDefineUI()
	bCPMANFloater = newRolloutFloater "blendedCubeProjectionManager v1.00" 200 302 pos.x pos.y
	addRollout bCPMANRollout bCPMANFloater
	)

fn bCPMANDo = 
	(
	blendedCubeProjectionManager bCPMANModeValue bCPMANDoMaxProjectionBoxValue bCPMANDoMaxBlendValue bCPMANMaxBlendValue bCPMANDoMaxLockToFrameValue bCPMANMaxLockToFrameValue
	if bCPMANFloater != undefined then CloseRolloutFloater bCPMANFloater
	)

fn bCPMANApply = 
	(
	blendedCubeProjectionManager bCPMANModeValue bCPMANDoMaxProjectionBoxValue bCPMANDoMaxBlendValue bCPMANMaxBlendValue bCPMANDoMaxLockToFrameValue bCPMANMaxLockToFrameValue
	)
	
fn bCPMANHelp = 
	(
	sLibSSPrintHelp "blendedCubeProjectionManager"
	)
	
fn bCPMANLoadDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	bCPMANInputFilename = presetDir + "blendedCubeProjectionManager.ini"
	if (sLibFileExist bCPMANInputFilename == true) then
		(
		bCPMANModeValue = execute (getINISetting bCPMANInputFilename "blendedCubeProjectionManager" "bCPMANModeValue")
		bCPMANDoMaxProjectionBoxValue = execute (getINISetting bCPMANInputFilename "blendedCubeProjectionManager" "bCPMANDoMaxProjectionBoxValue")
		bCPMANDoMaxBlendValue = execute (getINISetting bCPMANInputFilename "blendedCubeProjectionManager" "bCPMANDoMaxBlendValue")
		bCPMANMaxBlendValue = execute (getINISetting bCPMANInputFilename "blendedCubeProjectionManager" "bCPMANMaxBlendValue")
		bCPMANDoMaxLockToFrameValue = execute (getINISetting bCPMANInputFilename "blendedCubeProjectionManager" "bCPMANDoMaxLockToFrameValue")
		bCPMANMaxLockToFrameValue = execute (getINISetting bCPMANInputFilename "blendedCubeProjectionManager" "bCPMANMaxLockToFrameValue")
		bCPMANPosValue = execute (getINISetting bCPMANInputFilename "blendedCubeProjectionManager" "bCPMANPosValue")
		
		if bCPMANModeValue == OK then bCPMANModeValue = 2
		if bCPMANDoMaxProjectionBoxValue == OK then bCPMANDoMaxProjectionBoxValue = true
		if bCPMANDoMaxBlendValue == OK then bCPMANDoMaxBlendValue = false
		if bCPMANMaxBlendValue == OK then bCPMANMaxBlendValue = 25.0
		if bCPMANDoMaxLockToFrameValue == OK then bCPMANDoMaxLockToFrameValue = true
		if bCPMANMaxLockToFrameValue == OK then bCPMANMaxLockToFrameValue = 0
		if bCPMANPosValue == OK then bCPMANPosValue = [400,400]
		)
	else
		(
		bCPMANModeValue = 2
		bCPMANDoMaxProjectionBoxValue = true
		bCPMANDoMaxBlendValue = false
		bCPMANMaxBlendValue = 25.0
		bCPMANDoMaxLockToFrameValue = true
		bCPMANMaxLockToFrameValue = 0
		bCPMANPosValue = [400,400]
		)
	)
	
fn bCPMANSaveDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	if (getDirectories presetDir).count == 0 then makeDir presetDir
	bCPMANOutputFilename = presetDir + "blendedCubeProjectionManager.ini"
	if (sLibFileExist bCPMANOutputFilename == true) then deleteFile bCPMANOutputFilename
	setINISetting bCPMANOutputFilename "blendedCubeProjectionManager" "bCPMANModeValue" (bCPMANModeValue as string)
	setINISetting bCPMANOutputFilename "blendedCubeProjectionManager" "bCPMANDoMaxProjectionBoxValue" (bCPMANDoMaxProjectionBoxValue as string)
	setINISetting bCPMANOutputFilename "blendedCubeProjectionManager" "bCPMANDoMaxBlendValue" (bCPMANDoMaxBlendValue as string)
	setINISetting bCPMANOutputFilename "blendedCubeProjectionManager" "bCPMANMaxBlendValue" (bCPMANMaxBlendValue as string)
	setINISetting bCPMANOutputFilename "blendedCubeProjectionManager" "bCPMANDoMaxLockToFrameValue" (bCPMANDoMaxLockToFrameValue as string)
	setINISetting bCPMANOutputFilename "blendedCubeProjectionManager" "bCPMANMaxLockToFrameValue" (bCPMANMaxLockToFrameValue as string)
	setINISetting bCPMANOutputFilename "blendedCubeProjectionManager" "bCPMANPosValue" (bCPMANFloater.pos as string)
	)

-- UI

fn bCPMANDefineUI = 
	(
	rollout bCPMANRollout "blendedCubeProjectionManager"
		(
		group "Mode"
		(
		dropdownlist bCPMANModeDropdown "" items:#("Maps in Active Medit Slot", "Maps On Sel Objects") selection:bCPMANModeValue align:#right width:160
		)
		on bCPMANModeDropdown selected i do bCPMANModeValue = i
		
		group "BlendedBoxMap Maps"
		(
		checkbox bCPMANDoMaxProjectionBoxCheckbox "Do Projection Box?" checked:bCPMANDoMaxProjectionBoxValue align:#left
		label bCPMANDoMaxProjectionBoxObjectLabel "None" align:#center
		pickbutton bCPMANMaxProjectionBoxPickObject "Pick The Projection Box" width:164 toolTip:"Pick The Projection Box" align:#center
		checkbox bCPMANDoMaxBlendCheckbox "Do Blend?" checked:bCPMANDoMaxBlendValue align:#left
		spinner bCPMANMaxBlendSpinner "Blend: " range:[0.0,100.0,bCPMANMaxBlendValue] fieldWidth:50 type:#float align:#right
		checkbox bCPMANDoMaxLockToFrameCheckbox "Do Lock To Frame?" checked:bCPMANDoMaxLockToFrameValue align:#left
		spinner bCPMANMaxLockToFrameSpinner "Frame: " range:[-999999,999999,bCPMANMaxLockToFrameValue] fieldWidth:50 type:#integer align:#right
		)
		on bCPMANDoMaxProjectionBoxCheckbox changed state do 
			(
			bCPMANDoMaxProjectionBoxValue = state
			bCPMANDoMaxProjectionBoxObjectLabel.enabled = state
			bCPMANMaxProjectionBoxPickObject.enabled = state
			)
		on bCPMANMaxProjectionBoxPickObject picked obj do 
			(
			bCPMANProjectionBoxObject = obj
			bCPMANDoMaxProjectionBoxObjectLabel.text = obj.name
			)
		on bCPMANDoMaxBlendCheckbox changed state do 
			(
			bCPMANDoMaxBlendValue = state
			bCPMANMaxBlendSpinner.enabled = state
			)
		on bCPMANMaxBlendSpinner changed state do bCPMANMaxBlendValue = state
		on bCPMANDoMaxLockToFrameCheckbox changed state do 
			(
			bCPMANDoMaxLockToFrameValue = state
			bCPMANMaxLockToFrameSpinner.enabled = state
			)
		on bCPMANMaxLockToFrameSpinner changed state do bCPMANMaxLockToFrameValue = state
		
		button bCPMANDoButton "Do" width:70 toolTip:"Do It and Close UI" pos:[23,230]
		on bCPMANDoButton pressed do bCPMANDo()
		button bCPMANApplyButton "Apply" width:70 toolTip:"Do It and Keep UI Open" pos:[95,230]
		on bCPMANApplyButton pressed do bCPMANApply()
		button bCPMANHelpButton "Help" width:70 toolTip:"Help" pos:[23,254]
		on bCPMANHelpButton pressed do bCPMANHelp()
		button bCPMANSaveDefButton "SaveDef" width:70 toolTip:"Save Current Settings as Default" pos:[95,254]
		on bCPMANSaveDefButton pressed do bCPMANSaveDef()
		
		on bCPMANRollout open do
			(
			bCPMANDoMaxProjectionBoxObjectLabel.enabled = bCPMANDoMaxProjectionBoxValue
			bCPMANMaxProjectionBoxPickObject.enabled = bCPMANDoMaxProjectionBoxValue
			bCPMANMaxBlendSpinner.enabled = bCPMANDoMaxBlendValue
			bCPMANMaxLockToFrameSpinner.enabled = bCPMANDoMaxLockToFrameValue
			)
		)
	)
)
-------------------------------------------------------------------------------