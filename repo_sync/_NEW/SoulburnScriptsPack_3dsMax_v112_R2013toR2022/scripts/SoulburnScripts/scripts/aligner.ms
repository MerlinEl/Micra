-------------------------------------------------------------------------------
-- aligner.ms
-- By Neil Blevins (info@neilblevins.com)
-- v 1.04
-- Created On: 06/25/05
-- Modified On: 04/18/08
-- tested using Max 8.0
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Required Files:
-- sLib.ms
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Description:
-- Aligns one object to another. Similar to the Align tool in max, but optimized
-- to allow a variety of aligns with the least number of mouse clicks necessary.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Tutorial:
-- Open the script's UI, Pick Mode means you select the objects you want to align, 
-- then hit Do and it will prompt you to pick the object you want to align to. 
-- Now select 2 objects. Selection Mode means the first objects you have selected 
-- will be aligned to the last object you have selected with you hit the Do button.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Revision History:
--
-- v 1.01 Defined ui as new function.
--
-- v 1.02 Added some new code to more cleanly open and close the UI.
--
-- v 1.03 Made the script group friendly.
--
-- v 1.04 Replaced the Close button with a Help button. Use the X button to 
-- Close the Floater.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
(
-- Globals

global aligner
global alignerDefaults
global alignerUI

global aLGNCloseOpenUI

global aLGNObjects

global aLGNDo
global aLGNApply
global aLGNHelp
global aLGNLoadDef
global aLGNSaveDef

global aLGNDefineUI
global aLGNRollout
global aLGNFloater

-- Includes

include "$scripts\SoulburnScripts\lib\sLib.ms"

-- Variables

aLGNModeValue = 1
aLGNPosXValue = true
aLGNPosYValue = true
aLGNPosZValue = true
aLGNSourceSpotValue = 2
aLGNTargetSpotValue = 2
aLGNRotXValue = false
aLGNRotYValue = false
aLGNRotZValue = false
aLGNScaleXValue = false
aLGNScaleYValue = false
aLGNScaleZValue = false
aLGNPosValue = [400,400]

-- Functions

fn aligner aLGNMode aLGNPosX aLGNPosY aLGNPosZ aLGNSourceSpot aLGNTargetSpot aLGNRotX aLGNRotY aLGNRotZ aLGNScaleX aLGNScaleY aLGNScaleZ = 
	(
	undo "aligner" on
		(
		-- Define objects
		noGroupMembers = #()
		
		-- Remove group members from selection		
		for i in selection do 
			(
			if isGroupMember i == false then append noGroupMembers i
			else 
				(
				sel = for i in $ collect i
				groupHead = sLibGetGroupHead i
				if (findItem sel groupHead == 0) then append noGroupMembers i
				)
			)
			
		if aLGNModeValue == 1 then
			(
			if selection.count < 2 then 
				(
				MessageBox "Please pick at least 2 objects" title:"aligner"
				)
			else
				(
				i1 = (for i = 1 to (noGroupMembers.count - 1) collect noGroupMembers[i])
				i2 = noGroupMembers[noGroupMembers.count]
				aLGNObjects i1 i2 aLGNMode aLGNPosX aLGNPosY aLGNPosZ aLGNSourceSpot aLGNTargetSpot aLGNRotX aLGNRotY aLGNRotZ aLGNScaleX aLGNScaleY aLGNScaleZ
				)
			)
		else
			(
			if selection.count == 0 then 
				(
				MessageBox "Please pick at least 1 object" title:"aligner"
				)
			else
				(
				i1 = (for i = 1 to noGroupMembers.count collect noGroupMembers[i])
				i2 = pickobject message:"Please select node to align to" rubberBand:selection.center
				if i2 != #escape then aLGNObjects i1 i2 aLGNMode aLGNPosX aLGNPosY aLGNPosZ aLGNSourceSpot aLGNTargetSpot aLGNRotX aLGNRotY aLGNRotZ aLGNScaleX aLGNScaleY aLGNScaleZ
				)
			)
		)
	)
	
fn aLGNObjects i1 i2 aLGNMode aLGNPosX aLGNPosY aLGNPosZ aLGNSourceSpot aLGNTargetSpot aLGNRotX aLGNRotY aLGNRotZ aLGNScaleX aLGNScaleY aLGNScaleZ = 
	(
	for i in i1 do
		(
		-- Rotation		
		a = i.pos.x
		b = i.pos.y
		c = i.pos.z
		if aLGNRotX == true then i.rotation.controller[1].value = i2.rotation.controller[1].value
		if aLGNRotY == true then i.rotation.controller[2].value = i2.rotation.controller[2].value
		if aLGNRotZ == true then i.rotation.controller[3].value = i2.rotation.controller[3].value
		i.pos.x = a
		i.pos.y = b
		i.pos.z = c

		-- Scale
		if aLGNScaleX == true then i.scale.x = i2.scale.x
		if aLGNScaleY == true then i.scale.y = i2.scale.y
		if aLGNScaleZ == true then i.scale.z = i2.scale.z
		
		-- Position
		if aLGNSourceSpot == 1 and aLGNTargetSpot == 1 then
			(
			if aLGNPosX == true then i.pos.x = i2.pos.x
			if aLGNPosY == true then i.pos.y = i2.pos.y
			if aLGNPosZ == true then i.pos.z = i2.pos.z
			)
		if aLGNSourceSpot == 1 and aLGNTargetSpot == 2 then
			(
			if aLGNPosX == true then i.pos.x = i2.center.x
			if aLGNPosY == true then i.pos.y = i2.center.y
			if aLGNPosZ == true then i.pos.z = i2.center.z
			)
		if aLGNSourceSpot == 2 and aLGNTargetSpot == 1 then
			(
			if aLGNPosX == true then i.center.x = i2.pos.x
			if aLGNPosY == true then i.center.y = i2.pos.y
			if aLGNPosZ == true then i.center.z = i2.pos.z
			)
		if aLGNSourceSpot == 2 and aLGNTargetSpot == 2 then
			(
			if aLGNPosX == true then i.center.x = i2.center.x
			if aLGNPosY == true then i.center.y = i2.center.y
			if aLGNPosZ == true then i.center.z = i2.center.z
			)
		)
	)

fn alignerDefaults = 
	(
	aLGNLoadDef()
	aligner aLGNModeValue aLGNPosXValue aLGNPosYValue aLGNPosZValue aLGNSourceSpotValue aLGNTargetSpotValue aLGNRotXValue aLGNRotYValue aLGNRotZValue aLGNScaleXValue aLGNScaleYValue aLGNScaleZValue
	)
	
fn alignerUI = 
	(
	aLGNLoadDef()
	aLGNCloseOpenUI aLGNPosValue
	)

fn aLGNCloseOpenUI pos = 
	(
	if aLGNFloater != undefined then CloseRolloutFloater aLGNFloater
	aLGNDefineUI()
	aLGNFloater = newRolloutFloater "aligner v1.04" 166 307 pos.x pos.y
	addRollout aLGNRollout aLGNFloater
	)

fn aLGNDo = 
	(
	aligner aLGNModeValue aLGNPosXValue aLGNPosYValue aLGNPosZValue aLGNSourceSpotValue aLGNTargetSpotValue aLGNRotXValue aLGNRotYValue aLGNRotZValue aLGNScaleXValue aLGNScaleYValue aLGNScaleZValue
	if aLGNFloater != undefined then CloseRolloutFloater aLGNFloater
	)

fn aLGNApply = 
	(
	aligner aLGNModeValue aLGNPosXValue aLGNPosYValue aLGNPosZValue aLGNSourceSpotValue aLGNTargetSpotValue aLGNRotXValue aLGNRotYValue aLGNRotZValue aLGNScaleXValue aLGNScaleYValue aLGNScaleZValue
	)
	
fn aLGNHelp = 
	(
	sLibSSPrintHelp "aligner"
	)

fn aLGNLoadDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	aLGNInputFilename = presetDir + "aligner.ini"
	if (sLibFileExist aLGNInputFilename == true) then
		(
		aLGNModeValue = execute (getINISetting aLGNInputFilename "aligner" "aLGNModeValue")
		aLGNPosXValue = execute (getINISetting aLGNInputFilename "aligner" "aLGNPosXValue")
		aLGNPosYValue = execute (getINISetting aLGNInputFilename "aligner" "aLGNPosYValue")
		aLGNPosZValue = execute (getINISetting aLGNInputFilename "aligner" "aLGNPosZValue")
		aLGNSourceSpotValue = execute (getINISetting aLGNInputFilename "aligner" "aLGNSourceSpotValue")
		aLGNTargetSpotValue = execute (getINISetting aLGNInputFilename "aligner" "aLGNTargetSpotValue")
		aLGNRotXValue = execute (getINISetting aLGNInputFilename "aligner" "aLGNRotXValue")
		aLGNRotYValue = execute (getINISetting aLGNInputFilename "aligner" "aLGNRotYValue")
		aLGNRotZValue = execute (getINISetting aLGNInputFilename "aligner" "aLGNRotZValue")
		aLGNScaleXValue = execute (getINISetting aLGNInputFilename "aligner" "aLGNScaleXValue")
		aLGNScaleYValue = execute (getINISetting aLGNInputFilename "aligner" "aLGNScaleYValue")
		aLGNScaleZValue = execute (getINISetting aLGNInputFilename "aligner" "aLGNScaleZValue")
		aLGNPosValue = execute (getINISetting aLGNInputFilename "aligner" "aLGNPosValue")
		
		if aLGNModeValue == OK then aLGNModeValue = 1
		if aLGNPosXValue == OK then aLGNPosXValue = true
		if aLGNPosYValue == OK then aLGNPosYValue = true
		if aLGNPosZValue == OK then aLGNPosZValue = true
		if aLGNSourceSpotValue == OK then aLGNSourceSpotValue = 2
		if aLGNTargetSpotValue == OK then aLGNTargetSpotValue = 2
		if aLGNRotXValue == OK then aLGNRotXValue = false
		if aLGNRotYValue == OK then aLGNRotYValue = false
		if aLGNRotZValue == OK then aLGNRotZValue = false
		if aLGNScaleXValue == OK then aLGNScaleXValue = false
		if aLGNScaleYValue == OK then aLGNScaleYValue = false
		if aLGNScaleZValue == OK then aLGNScaleZValue = false 	
		if aLGNPosValue == OK then aLGNPosValue = [400,400]
		)
	else
		(
		aLGNModeValue = 1
		aLGNPosXValue = true
		aLGNPosYValue = true
		aLGNPosZValue = true
		aLGNSourceSpotValue = 2
		aLGNTargetSpotValue = 2
		aLGNRotXValue = false
		aLGNRotYValue = false
		aLGNRotZValue = false
		aLGNScaleXValue = false
		aLGNScaleYValue = false
		aLGNScaleZValue = false
		aLGNPosValue = [400,400]
		)
	)
	
fn aLGNSaveDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	if (getDirectories presetDir).count == 0 then makeDir presetDir
	aLGNOutputFilename = presetDir + "aligner.ini"
	if (sLibFileExist aLGNOutputFilename == true) then deleteFile aLGNOutputFilename
	setINISetting aLGNOutputFilename "aligner" "aLGNModeValue" (aLGNModeValue as string)
	setINISetting aLGNOutputFilename "aligner" "aLGNPosXValue" (aLGNPosXValue as string)
	setINISetting aLGNOutputFilename "aligner" "aLGNPosYValue" (aLGNPosYValue as string)
	setINISetting aLGNOutputFilename "aligner" "aLGNPosZValue" (aLGNPosZValue as string)
	setINISetting aLGNOutputFilename "aligner" "aLGNSourceSpotValue" (aLGNSourceSpotValue as string)
	setINISetting aLGNOutputFilename "aligner" "aLGNTargetSpotValue" (aLGNTargetSpotValue as string)
	setINISetting aLGNOutputFilename "aligner" "aLGNRotXValue" (aLGNRotXValue as string)
	setINISetting aLGNOutputFilename "aligner" "aLGNRotYValue" (aLGNRotYValue as string)
	setINISetting aLGNOutputFilename "aligner" "aLGNRotZValue" (aLGNRotZValue as string)
	setINISetting aLGNOutputFilename "aligner" "aLGNScaleXValue" (aLGNScaleXValue as string)
	setINISetting aLGNOutputFilename "aligner" "aLGNScaleYValue" (aLGNScaleYValue as string)
	setINISetting aLGNOutputFilename "aligner" "aLGNScaleZValue" (aLGNScaleZValue as string)
	setINISetting aLGNOutputFilename "aligner" "aLGNPosValue" (aLGNFloater.pos as string)
	)

-- UI

fn aLGNDefineUI = 
	(
	rollout aLGNRollout "aligner"
		(
		dropdownlist aLGNModeDropdown "" items:#("Selection Mode", "Pick Mode") selection:aLGNModeValue
		on aLGNModeDropdown selected i do aLGNModeValue = i
		
		Group "Position"
		(
		checkbox aLGNPosXCheckbox "X" checked:aLGNPosXValue across:3
		checkbox aLGNPosYCheckbox "Y" checked:aLGNPosYValue
		checkbox aLGNPosZCheckbox "Z" checked:aLGNPosZValue
		dropdownlist aLGNSourceSpotDropdown "" items:#("Source Pivot", "Source Center") selection:aLGNSourceSpotValue
		dropdownlist aLGNTargetSpotDropdown "" items:#("Target Pivot", "Target Center") selection:aLGNTargetSpotValue
		)
		on aLGNPosXCheckbox changed state do aLGNPosXValue = state
		on aLGNPosYCheckbox changed state do aLGNPosYValue = state
		on aLGNPosZCheckbox changed state do aLGNPosZValue = state
		on aLGNSourceSpotDropdown selected i do aLGNSourceSpotValue = i
		on aLGNTargetSpotDropdown selected i do aLGNTargetSpotValue = i
		
		Group "Rotation"
		(
		checkbox aLGNRotXCheckbox "X" checked:aLGNRotXValue across:3
		checkbox aLGNRotYCheckbox "Y" checked:aLGNRotYValue
		checkbox aLGNRotZCheckbox "Z" checked:aLGNRotZValue
		)
		on aLGNRotXCheckbox changed state do aLGNRotXValue = state
		on aLGNRotYCheckbox changed state do aLGNRotYValue = state
		on aLGNRotZCheckbox changed state do aLGNRotZValue = state
		
		Group "Scale"
		(
		checkbox aLGNScaleXCheckbox "X" checked:aLGNScaleXValue across:3
		checkbox aLGNScaleYCheckbox "Y" checked:aLGNScaleYValue
		checkbox aLGNScaleZCheckbox "Z" checked:aLGNScaleZValue
		)
		on aLGNScaleXCheckbox changed state do aLGNScaleXValue = state
		on aLGNScaleYCheckbox changed state do aLGNScaleYValue = state
		on aLGNScaleZCheckbox changed state do aLGNScaleZValue = state
	
		button aLGNDoButton "Do" width:70 toolTip:"Do It and Close UI" pos:[5,224]
		on aLGNDoButton pressed do aLGNDo()
		button aLGNApplyButton "Apply" width:70 toolTip:"Do It and Keep UI Open" pos:[77,224]
		on aLGNApplyButton pressed do aLGNApply()
		button aLGNHelpButton "Help" width:70 toolTip:"Help" pos:[5,250]
		on aLGNHelpButton pressed do aLGNHelp()
		button aLGNSaveDefButton "SaveDef" width:70 toolTip:"Save Current Settings as Default" pos:[77,250]
		on aLGNSaveDefButton pressed do aLGNSaveDef()
		)
	)
)
-------------------------------------------------------------------------------