-------------------------------------------------------------------------------
-- curvatureManager.ms
-- By Neil Blevins (info@neilblevins.com)
-- v 1.01
-- Created On: 11/12/16
-- Modified On: 10/08/17
-- tested using Max 2018
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Required Files:
-- sLib.ms
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Description:
-- Lets you change parameters of any Curvature Data Channel on your selected
-- objects. Also lets you propagate an existing curvature modifier to all 
-- selected objects. So say you have 3 objects that have a curvature Data 
-- Channel modifier and you add 2 objects to your model, propagating will copy 
-- and paste that modifier to all 5 objects.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Tutorial:
-- Select some objects that have Data Modifiers that you created using the 
-- curvatureMaker script. Run The UI version of the script. Change the Map 
-- Channel to 15. Click "Do". Now all the Data Modifiers in your selection
-- have their map channel value in the Vertex Output operators set to 15.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Revision History:
--
-- v 1.01 All of the maxscript names have been changed for the Data Modifier 
-- in max 2018, so added some code to make the script compatible.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
(
-- Globals

global curvatureManager
global curvatureManagerDefaults
global curvatureManagerUI

global cMANCloseOpenUI

global cMANPropagate

global cMANDo
global cMANApply
global cMANHelp
global cMANLoadDef
global cMANSaveDef

global cMANDefineUI
global cMANRollout
global cMANFloater

-- Includes

include "$scripts\SoulburnScripts\lib\sLib.ms"

-- Variables

cMANModeValue = 1
cMANDoCurveScaleValue = false
cMANCurveScaleValue  = 10.0
cMANDoMapChannelValue = true
cMANMapChannelValue = 66
 
cMANPosValue = [400,400]

-- Functions

fn curvatureManager cMANMode cMANDoCurveScale cMANCurveScale cMANDoMapChannel cMANMapChannel = 
	(
	undo "curvatureManager" on
		(
		objs = for i in selection collect i
		for obj in objs do
			(
			if obj.modifiers.count != 0 then
				(
				for j = 1 to obj.modifiers.count do
					(
					if obj.modifiers[j].name == "cMAK_Curvature" then 
						(
						numops = obj.modifiers[j].StackCount()
						if numops != 0 then
							(
							for w = 1 to numops do
								(
								obj.modifiers[j].StackOperatorName w &opname
								if sLibMaxVer() <= 19.0 then
									(
									if cMANDoMapChannel == true then
										(
										if opname == "Vertex Output" then obj.modifiers[j].operators[w].channelNumSpinBox = cMANMapChannel
										)
									if cMANDoCurveScale == true then
										(
										if opname == "Curvature" then obj.modifiers[j].operators[w].scaleDoubleSpinBox = cMANCurveScale
										)
									)
								else
									(
									obj.modifiers[j].SelectStackOperator w
									if cMANDoMapChannel == true then
										(
										if opname == "Vertex Output" then obj.modifiers[j].operators[w].channelNum = cMANMapChannel
										)
									if cMANDoCurveScale == true then
										(
										if opname == "Curvature" then obj.modifiers[j].operators[w].scale = cMANCurveScale
										)
									)
								)
							)
						)
					)
				)
			)
		)
	)

fn curvatureManagerDefaults = 
	(
	cMANLoadDef()
	curvatureManager cMANModeValue cMANDoCurveScaleValue cMANCurveScaleValue cMANDoMapChannelValue cMANMapChannelValue
	)
	
fn curvatureManagerUI = 
	(
	cMANLoadDef()
	cMANCloseOpenUI cMANPosValue
	)

fn cMANCloseOpenUI pos = 
	(
	if cMANFloater != undefined then CloseRolloutFloater cMANFloater
	cMANDefineUI()
	cMANFloater = newRolloutFloater "curvatureManager v1.01" 200 267 pos.x pos.y
	addRollout cMANRollout cMANFloater
	)
	
fn cMANPropagate = 
	(
	max modify mode
	
	themod = undefined
	tempobj = undefined
	objs = for i in selection collect i

	-- Can selection be affected by Data Channel?
	error = false
	for i in objs do
		(
		if (validModifier i Data_Channel) == false then error = true
		)
	if error == true then (MessageBox "One of your selected Objects can't accept a Data Channel modifier. Please select a new set of objects." title:"curvatureManager")
	else
		(
		-- Find a Data Channel Mod and delete the others
		for i in objs do
			(
			if i.modifiers.count != 0 then
				(
				for j = 1 to i.modifiers.count do
					(
					if i.modifiers[j].name == "cMAK_Curvature" then 
						(
						if themod == undefined then 
							(
							themod = i.modifiers[j]
							tempobj = Sphere name:"cMANTemp"
							select tempobj
							modPanel.addModToSelection themod
							)
						sLibRemoveModifiersByName i "cMAK_Curvature"			
						)
					)
				)
			)

		-- Propagate
		if themod == undefined then (MessageBox "Could not find a Data Channel Curvature Modifier to Propagate." title:"curvatureManager")
		else
			(
			select objs
			modPanel.addModToSelection tempobj.modifiers[1]
			delete tempobj
			)
		)
	)

fn cMANDo = 
	(
	curvatureManager cMANModeValue cMANDoCurveScaleValue cMANCurveScaleValue cMANDoMapChannelValue cMANMapChannelValue
	if cMANFloater != undefined then CloseRolloutFloater cMANFloater
	)

fn cMANApply = 
	(
	curvatureManager cMANModeValue cMANDoCurveScaleValue cMANCurveScaleValue cMANDoMapChannelValue cMANMapChannelValue
	)
	
fn cMANHelp = 
	(
	sLibSSPrintHelp "curvatureManager"
	)
	
fn cMANLoadDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	cMANInputFilename = presetDir + "curvatureManager.ini"
	if (sLibFileExist cMANInputFilename == true) then
		(
		cMANModeValue = execute (getINISetting cMANInputFilename "curvatureManager" "cMANModeValue")
		cMANDoCurveScaleValue = execute (getINISetting cMANInputFilename "curvatureManager" "cMANDoCurveScaleValue")
		cMANCurveScaleValue = execute (getINISetting cMANInputFilename "curvatureManager" "cMANCurveScaleValue")
		cMANDoMapChannelValue = execute (getINISetting cMANInputFilename "curvatureManager" "cMANDoMapChannelValue")
		cMANMapChannelValue = execute (getINISetting cMANInputFilename "curvatureManager" "cMANMapChannelValue")
		cMANPosValue = execute (getINISetting cMANInputFilename "curvatureManager" "cMANPosValue")
		
		if cMANModeValue == OK then cMANModeValue = 1
		if cMANDoCurveScaleValue == OK then cMANDoCurveScaleValue = true
		if cMANCurveScaleValue == OK then cMANCurveScaleValue = 10.0
		if cMANDoMapChannelValue == OK then cMANDoMapChannelValue = true
		if cMANMapChannelValue == OK then cMANMapChannelValue = 66
		if cMANPosValue == OK then cMANPosValue = [400,400]
		)
	else
		(
		cMANModeValue = 1
		cMANDoCurveScaleValue = false
		cMANCurveScaleValue = 10.0
		cMANDoMapChannelValue = true
		cMANMapChannelValue = 66
		cMANPosValue = [400,400]
		)
	)
	
fn cMANSaveDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	if (getDirectories presetDir).count == 0 then makeDir presetDir
	cMANOutputFilename = presetDir + "curvatureManager.ini"
	if (sLibFileExist cMANOutputFilename == true) then deleteFile cMANOutputFilename
	setINISetting cMANOutputFilename "curvatureManager" "cMANModeValue" (cMANModeValue as string)
	setINISetting cMANOutputFilename "curvatureManager" "cMANDoCurveScaleValue" (cMANDoCurveScaleValue as string)
	setINISetting cMANOutputFilename "curvatureManager" "cMANCurveScaleValue" (cMANCurveScaleValue as string)
	setINISetting cMANOutputFilename "curvatureManager" "cMANDoMapChannelValue" (cMANDoMapChannelValue as string)
	setINISetting cMANOutputFilename "curvatureManager" "cMANMapChannelValue" (cMANMapChannelValue as string)
	setINISetting cMANOutputFilename "curvatureManager" "cMANPosValue" (cMANFloater.pos as string)
	)

-- UI

fn cMANDefineUI = 
	(
	rollout cMANRollout "curvatureManager"
		(
		group "Mode"
		(
		dropdownlist cMANModeDropdown "" items:#("Data Channel") selection:cMANModeValue align:#right width:160
		)
		on cMANModeDropdown selected i do cMANModeValue = i
		
		group "Data Channel"
		(
		button cMANPropagateButton "Propagate To Sel" width:160 toolTip:"Propagate Existing Curvature Modifier To All Selected Objects" align:#center
		checkbox cMANDoCurveScaleCheckbox "Do Curve Scale?" checked:cMANDoCurveScaleValue align:#left
		spinner cMANCurveScaleSpinner "Curve Scale: " range:[0.0,100.0,cMANCurveScaleValue] fieldWidth:50 type:#integer align:#right
		checkbox cMANDoMapChannelCheckbox "Do Map Channel?" checked:cMANDoMapChannelValue align:#left
		spinner cMANMapChannelSpinner "Map Channel: " range:[-2,98,cMANMapChannelValue] fieldWidth:50 type:#integer align:#right
		)
		on cMANPropagateButton pressed do cMANPropagate()
		on cMANDoCurveScaleCheckbox changed state do 
			(
			cMANDoCurveScaleValue = state
			cMANCurveScaleSpinner.enabled = state
			)
		on cMANCurveScaleSpinner changed state do cMANCurveScaleValue = state
		on cMANDoMapChannelCheckbox changed state do 
			(
			cMANDoMapChannelValue = state
			cMANMapChannelSpinner.enabled = state
			)
		on cMANMapChannelSpinner changed state do cMANMapChannelValue = state
		
		button cMANDoButton "Do" width:70 toolTip:"Do It and Close UI" pos:[23,192]
		on cMANDoButton pressed do cMANDo()
		button cMANApplyButton "Apply" width:70 toolTip:"Do It and Keep UI Open" pos:[95,192]
		on cMANApplyButton pressed do cMANApply()
		button cMANHelpButton "Help" width:70 toolTip:"Help" pos:[23,216]
		on cMANHelpButton pressed do cMANHelp()
		button cMANSaveDefButton "SaveDef" width:70 toolTip:"Save Current Settings as Default" pos:[95,216]
		on cMANSaveDefButton pressed do cMANSaveDef()
		
		on cMANRollout open do
			(
			cMANMapChannelSpinner.enabled = cMANDoMapChannelValue
			)
		)
	)
)
-------------------------------------------------------------------------------