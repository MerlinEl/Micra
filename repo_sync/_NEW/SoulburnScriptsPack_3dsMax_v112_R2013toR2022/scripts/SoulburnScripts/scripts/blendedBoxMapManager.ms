-------------------------------------------------------------------------------
-- blendedBoxMapManager.ms
-- By Neil Blevins (info@neilblevins.com)
-- v 1.10
-- Created On: 10/21/15
-- Modified On: 07/03/16
-- tested using Max 2018
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Required Files:
-- sLib.ms
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Description:
-- Lets you change parameters to any Blended Box Map inside the material
-- you currently have active or the objects you have selected.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Tutorial:
-- Select a material in the Material Editor that contains several VrayTriplanarTex
-- maps. Run The UI version of the script. Check "Do Scale", set the Scale to 1.
-- Click "Do". Now all VrayTriplanarTex maps in the material have that same
-- value.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Revision History:
--
-- v 1.10 You can now update the parameters of a Max BlendedBoxMap map.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
(
-- Globals

global blendedBoxMapManager
global blendedBoxMapManagerDefaults
global blendedBoxMapManagerUI

global bBMMANCloseOpenUI

global bBMMANDo
global bBMMANApply
global bBMMANHelp
global bBMMANLoadDef
global bBMMANSaveDef

global bBMMANDefineUI
global bBMMANRollout
global bBMMANFloater

-- Includes

include "$scripts\SoulburnScripts\lib\sLib.ms"

-- Variables

global bBMMANNodeObject = undefined

bBMMANModeValue = 1
bBMMANDoScaleValue = false
bBMMANScaleValue = 0.01
bBMMANDoBlendValue = true
bBMMANBlendValue = 0.3
bBMMANDoSpaceValue = false
bBMMANSpaceValue = 2
bBMMANDoRandTexOffsetValue = false
bBMMANRandTexOffsetValue = true
bBMMANDoMaxScaleValue = false
bBMMANMaxScaleValue = 100.0
bBMMANDoMaxBlendValue = true
bBMMANMaxBlendValue = 25.0
bBMMANPosValue = [400,400]

-- Functions

fn blendedBoxMapManager bBMMANMode bBMMANDoScale bBMMANScale bBMMANDoBlend bBMMANBlend bBMMANDoSpace bBMMANSpace bBMMANDoRandTexOffset bBMMANRandTexOffset bBMMANDoMaxScale bBMMANMaxScale bBMMANDoMaxBlend bBMMANMaxBlend = 
	(
	undo "blendedBoxMapManager" on
		(
		mat = undefined
		a = #()

		if bBMMANMode == 1 then 
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
			else (MessageBox "There doesn't appear to be a material properly selected in the material editor." title:"blendedBoxMapManager")	
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
			if bBMMANDoScale == true then i.scale = bBMMANScale
			if bBMMANDoBlend == true then i.blend = bBMMANBlend
			if bBMMANDoSpace == true then 
				(
				i.space = (bBMMANSpace - 1)
				i.reference_node = bBMMANNodeObject
				)
			if bBMMANDoRandTexOffset == true then i.random_texture_offset = bBMMANRandTexOffset
			)
		for i in c do
			(
			if i.mode == 0 or i.mode == 1 then
				(
				if bBMMANDoMaxScale == true then i.mapscale = bBMMANMaxScale
				if bBMMANDoMaxBlend == true then i.Blend = bBMMANMaxBlend
				)
			)
		)
	)
	
fn blendedBoxMapManagerDefaults = 
	(
	bBMMANLoadDef()
	blendedBoxMapManager bBMMANModeValue bBMMANDoScaleValue bBMMANScaleValue bBMMANDoBlendValue bBMMANBlendValue bBMMANDoSpaceValue bBMMANSpaceValue bBMMANDoRandTexOffsetValue bBMMANRandTexOffsetValue bBMMANDoMaxScaleValue bBMMANMaxScaleValue bBMMANDoMaxBlendValue bBMMANMaxBlendValue
	)
	
fn blendedBoxMapManagerUI = 
	(
	bBMMANLoadDef()
	bBMMANCloseOpenUI bBMMANPosValue
	)

fn bBMMANCloseOpenUI pos = 
	(
	if bBMMANFloater != undefined then CloseRolloutFloater bBMMANFloater
	bBMMANDefineUI()
	bBMMANFloater = newRolloutFloater "blendedBoxMapManager v1.10" 310 441 pos.x pos.y
	addRollout bBMMANRollout bBMMANFloater
	)

fn bBMMANDo = 
	(
	blendedBoxMapManager bBMMANModeValue bBMMANDoScaleValue bBMMANScaleValue bBMMANDoBlendValue bBMMANBlendValue bBMMANDoSpaceValue bBMMANSpaceValue bBMMANDoRandTexOffsetValue bBMMANRandTexOffsetValue bBMMANDoMaxScaleValue bBMMANMaxScaleValue bBMMANDoMaxBlendValue bBMMANMaxBlendValue
	if bBMMANFloater != undefined then CloseRolloutFloater bBMMANFloater
	)

fn bBMMANApply = 
	(
	blendedBoxMapManager bBMMANModeValue bBMMANDoScaleValue bBMMANScaleValue bBMMANDoBlendValue bBMMANBlendValue bBMMANDoSpaceValue bBMMANSpaceValue bBMMANDoRandTexOffsetValue bBMMANRandTexOffsetValue bBMMANDoMaxScaleValue bBMMANMaxScaleValue bBMMANDoMaxBlendValue bBMMANMaxBlendValue
	)
	
fn bBMMANHelp = 
	(
	sLibSSPrintHelp "blendedBoxMapManager"
	)
	
fn bBMMANLoadDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	bBMMANInputFilename = presetDir + "blendedBoxMapManager.ini"
	if (sLibFileExist bBMMANInputFilename == true) then
		(
		bBMMANModeValue = execute (getINISetting bBMMANInputFilename "blendedBoxMapManager" "bBMMANModeValue")
		bBMMANDoScaleValue = execute (getINISetting bBMMANInputFilename "blendedBoxMapManager" "bBMMANDoScaleValue")
		bBMMANScaleValue = execute (getINISetting bBMMANInputFilename "blendedBoxMapManager" "bBMMANScaleValue")
		bBMMANDoBlendValue = execute (getINISetting bBMMANInputFilename "blendedBoxMapManager" "bBMMANDoBlendValue")
		bBMMANBlendValue = execute (getINISetting bBMMANInputFilename "blendedBoxMapManager" "bBMMANBlendValue")
		bBMMANDoSpaceValue = execute (getINISetting bBMMANInputFilename "blendedBoxMapManager" "bBMMANDoSpaceValue")
		bBMMANSpaceValue = execute (getINISetting bBMMANInputFilename "blendedBoxMapManager" "bBMMANSpaceValue")
		bBMMANDoRandTexOffsetValue = execute (getINISetting bBMMANInputFilename "blendedBoxMapManager" "bBMMANDoRandTexOffsetValue")
		bBMMANRandTexOffsetValue = execute (getINISetting bBMMANInputFilename "blendedBoxMapManager" "bBMMANRandTexOffsetValue")
		bBMMANDoMaxScaleValue = execute (getINISetting bBMMANInputFilename "blendedBoxMapManager" "bBMMANDoMaxScaleValue")
		bBMMANMaxScaleValue = execute (getINISetting bBMMANInputFilename "blendedBoxMapManager" "bBMMANMaxScaleValue")
		bBMMANDoMaxBlendValue = execute (getINISetting bBMMANInputFilename "blendedBoxMapManager" "bBMMANDoMaxBlendValue")
		bBMMANMaxBlendValue = execute (getINISetting bBMMANInputFilename "blendedBoxMapManager" "bBMMANMaxBlendValue")
		bBMMANPosValue = execute (getINISetting bBMMANInputFilename "blendedBoxMapManager" "bBMMANPosValue")
		
		if bBMMANModeValue == OK then bBMMANModeValue = 1
		if bBMMANDoScaleValue == OK then bBMMANDoScaleValue = false
		if bBMMANScaleValue == OK then bBMMANScaleValue = 0.01
		if bBMMANDoBlendValue == OK then bBMMANDoBlendValue = true
		if bBMMANBlendValue == OK then bBMMANBlendValue = 0.3
		if bBMMANDoSpaceValue == OK then bBMMANDoSpaceValue = false
		if bBMMANSpaceValue == OK then bBMMANSpaceValue = 2
		if bBMMANDoRandTexOffsetValue == OK then bBMMANDoRandTexOffsetValue = false
		if bBMMANRandTexOffsetValue == OK then bBMMANRandTexOffsetValue = true
		if bBMMANDoMaxScaleValue == OK then bBMMANDoMaxScaleValue = false
		if bBMMANMaxScaleValue == OK then bBMMANMaxScaleValue = 100.0
		if bBMMANDoMaxBlendValue == OK then bBMMANDoMaxBlendValue = true
		if bBMMANMaxBlendValue == OK then bBMMANMaxBlendValue = 25.0
		if bBMMANPosValue == OK then bBMMANPosValue = [400,400]
		)
	else
		(
		bBMMANModeValue = 1
		bBMMANDoScaleValue = false
		bBMMANScaleValue = 0.01
		bBMMANDoBlendValue = true
		bBMMANBlendValue = 0.3
		bBMMANDoSpaceValue = false
		bBMMANSpaceValue = 2
		bBMMANDoRandTexOffsetValue = false
		bBMMANRandTexOffsetValue = true
		bBMMANDoMaxScaleValue = false
		bBMMANMaxScaleValue = 100.0
		bBMMANDoMaxBlendValue = true
		bBMMANMaxBlendValue = 25.0
		bBMMANPosValue = [400,400]
		)
	)
	
fn bBMMANSaveDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	if (getDirectories presetDir).count == 0 then makeDir presetDir
	bBMMANOutputFilename = presetDir + "blendedBoxMapManager.ini"
	if (sLibFileExist bBMMANOutputFilename == true) then deleteFile bBMMANOutputFilename
	setINISetting bBMMANOutputFilename "blendedBoxMapManager" "bBMMANModeValue" (bBMMANModeValue as string)
	setINISetting bBMMANOutputFilename "blendedBoxMapManager" "bBMMANDoScaleValue" (bBMMANDoScaleValue as string)
	setINISetting bBMMANOutputFilename "blendedBoxMapManager" "bBMMANScaleValue" (bBMMANScaleValue as string)
	setINISetting bBMMANOutputFilename "blendedBoxMapManager" "bBMMANDoBlendValue" (bBMMANDoBlendValue as string)
	setINISetting bBMMANOutputFilename "blendedBoxMapManager" "bBMMANBlendValue" (bBMMANBlendValue as string)
	setINISetting bBMMANOutputFilename "blendedBoxMapManager" "bBMMANDoSpaceValue" (bBMMANDoSpaceValue as string)
	setINISetting bBMMANOutputFilename "blendedBoxMapManager" "bBMMANSpaceValue" (bBMMANSpaceValue as string)
	setINISetting bBMMANOutputFilename "blendedBoxMapManager" "bBMMANDoRandTexOffsetValue" (bBMMANDoRandTexOffsetValue as string)
	setINISetting bBMMANOutputFilename "blendedBoxMapManager" "bBMMANRandTexOffsetValue" (bBMMANRandTexOffsetValue as string)
	setINISetting bBMMANOutputFilename "blendedBoxMapManager" "bBMMANDoMaxScaleValue" (bBMMANDoMaxScaleValue as string)
	setINISetting bBMMANOutputFilename "blendedBoxMapManager" "bBMMANMaxScaleValue" (bBMMANMaxScaleValue as string)
	setINISetting bBMMANOutputFilename "blendedBoxMapManager" "bBMMANDoMaxBlendValue" (bBMMANDoMaxBlendValue as string)
	setINISetting bBMMANOutputFilename "blendedBoxMapManager" "bBMMANMaxBlendValue" (bBMMANMaxBlendValue as string)
	setINISetting bBMMANOutputFilename "blendedBoxMapManager" "bBMMANPosValue" (bBMMANFloater.pos as string)
	)

-- UI

fn bBMMANDefineUI = 
	(
	rollout bBMMANRollout "blendedBoxMapManager"
		(
		group "Mode"
		(
		dropdownlist bBMMANModeDropdown "" items:#("Maps in Active Medit Slot", "Maps On Sel Objects") selection:bBMMANModeValue align:#right width:270
		)
		on bBMMANModeDropdown selected i do bBMMANModeValue = i
		
		group "VrayTriplanarTex Maps"
		(
		checkbox bBMMANDoScaleCheckbox "Do Scale?" checked:bBMMANDoScaleValue align:#left
		spinner bBMMANScaleSpinner "Scale: " range:[0,10000,bBMMANScaleValue] fieldWidth:50 type:#float align:#right
		checkbox bBMMANDoBlendCheckbox "Do Blend?" checked:bBMMANDoBlendValue align:#left
		spinner bBMMANBlendSpinner "Blend: " range:[0.0,1.0,bBMMANBlendValue] fieldWidth:50 type:#float align:#right
		checkbox bBMMANDoSpaceCheckbox "Do Space?" checked:bBMMANDoSpaceValue align:#left
		label label1 "Space:" offset:[30,3] across:2
		dropdownlist bBMMANSpaceDropdown "" items:#("Local object", "Node") selection:bBMMANSpaceValue align:#right width:150
		pickbutton bBMMANPickObject "Pick The Node" width:150 toolTip:"Pick The Node" align:#right
		checkbox bBMMANDoRandTexOffsetCheckbox "Do Rand Tex Offset?" checked:bBMMANDoRandTexOffsetValue align:#left
		checkbox bBMMANRandTexOffsetCheckbox "Rand Tex Offset" checked:bBMMANRandTexOffsetValue align:#right
		)
		
		on bBMMANDoScaleCheckbox changed state do 
			(
			bBMMANDoScaleValue = state
			bBMMANScaleSpinner.enabled = state
			)
		on bBMMANScaleSpinner changed state do bBMMANScaleValue = state
		on bBMMANDoBlendCheckbox changed state do 
			(
			bBMMANDoBlendValue = state
			bBMMANBlendSpinner.enabled = state
			)
		on bBMMANBlendSpinner changed state do bBMMANBlendValue = state
		on bBMMANDoSpaceCheckbox changed state do 
			(
			bBMMANDoSpaceValue = state
			label1.enabled = state
			bBMMANSpaceDropdown.enabled = state
			bBMMANPickObject.enabled = state
			)
		on bBMMANSpaceDropdown selected i do bBMMANSpaceValue = i
		on bBMMANPickObject picked obj do 
			(
			if obj == undefined then 
				(
				bBMMANPickObject.text = "Pick The Node"
				)
			else
				(
				bBMMANNodeObject = obj
				bBMMANPickObject.text = obj.name
				)
			)
		on bBMMANDoRandTexOffsetCheckbox changed state do 
			(
			bBMMANDoRandTexOffsetValue = state
			bBMMANRandTexOffsetCheckbox.enabled = state
			)
		on bBMMANRandTexOffsetCheckbox changed state do 
			(
			bBMMANRandTexOffsetValue = state
			)

		group "BlendedBoxMap Maps"
		(
		checkbox bBMMANDoMaxScaleCheckbox "Do Scale?" checked:bBMMANDoMaxScaleValue align:#left
		spinner bBMMANMaxScaleSpinner "Scale: " range:[0.01,100000,bBMMANMaxScaleValue] fieldWidth:50 type:#float align:#right
		checkbox bBMMANDoMaxBlendCheckbox "Do Blend?" checked:bBMMANDoMaxBlendValue align:#left
		spinner bBMMANMaxBlendSpinner "Blend: " range:[0.0,100.0,bBMMANMaxBlendValue] fieldWidth:50 type:#float align:#right
		)
		on bBMMANDoMaxScaleCheckbox changed state do 
			(
			bBMMANDoMaxScaleValue = state
			bBMMANMaxScaleSpinner.enabled = state
			)
		on bBMMANMaxScaleSpinner changed state do bBMMANMaxScaleValue = state
		on bBMMANDoMaxBlendCheckbox changed state do 
			(
			bBMMANDoMaxBlendValue = state
			bBMMANMaxBlendSpinner.enabled = state
			)
		on bBMMANMaxBlendSpinner changed state do bBMMANMaxBlendValue = state
		
		button bBMMANDoButton "Do" width:70 toolTip:"Do It and Close UI" pos:[5,384]
		on bBMMANDoButton pressed do bBMMANDo()
		button bBMMANApplyButton "Apply" width:70 toolTip:"Do It and Keep UI Open" pos:[77,384]
		on bBMMANApplyButton pressed do bBMMANApply()
		button bBMMANHelpButton "Help" width:70 toolTip:"Help" pos:[149,384]
		on bBMMANHelpButton pressed do bBMMANHelp()
		button bBMMANSaveDefButton "SaveDef" width:70 toolTip:"Save Current Settings as Default" pos:[221,384]
		on bBMMANSaveDefButton pressed do bBMMANSaveDef()
		
		on bBMMANRollout open do
			(
			bBMMANScaleSpinner.enabled = bBMMANDoScaleValue
			bBMMANBlendSpinner.enabled = bBMMANDoBlendValue
			label1.enabled = bBMMANDoSpaceValue
			bBMMANSpaceDropdown.enabled = bBMMANDoSpaceValue
			bBMMANPickObject.enabled = bBMMANDoSpaceValue
			bBMMANRandTexOffsetCheckbox.enabled = bBMMANDoRandTexOffsetValue
			bBMMANMaxScaleSpinner.enabled = bBMMANDoMaxScaleValue
			bBMMANMaxBlendSpinner.enabled = bBMMANDoMaxBlendValue			
			)
		)
	)
)
-------------------------------------------------------------------------------