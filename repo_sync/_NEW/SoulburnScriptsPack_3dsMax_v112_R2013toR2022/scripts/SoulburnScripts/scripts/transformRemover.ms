-------------------------------------------------------------------------------
-- transformRemover.ms
-- By Neil Blevins (info@neilblevins.com)
-- v 1.04
-- Created On: 06/04/05
-- Modified On: 04/18/08
-- tested using Max 7.1
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Required Files:
-- sLib.ms
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Description:
-- Resets the position, rotation and / or scale of the selected objects.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Tutorial:
-- Select a bunch of objects that have different positions, scales and rotation 
-- values. Run the UI version of the script. Hit Do. Now all your objects will 
-- move back to 0,0,0, become unrotated and be scaled back to their original size.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Revision History:
--
-- v 1.01 Reordered some of the functions.
--
-- v 1.02 Defined ui as new function.
--
-- v 1.03 Added some new code to more cleanly open and close the UI.
--
-- v 1.04 Replaced the Close button with a Help button. Use the X button to 
-- Close the Floater.
--
-- v 1.05 Changed name of script to transformRemover.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
(
-- Globals

global transformRemover
global transformRemoverDefaults
global transformRemoverUI

global tRCloseOpenUI

global tRPosition
global tRRotation
global tRScale

global tRDo
global tRApply
global tRHelp
global tRLoadDef
global tRSaveDef

global tRDefineUI
global tRRollout
global tRFloater

-- Includes

include "$scripts\SoulburnScripts\lib\sLib.ms"

-- Variables

tRTXValue = true
tRTYValue = true
tRTZValue = true
tRRXValue = true
tRRYValue = true
tRRZValue = true
tRSXValue = true
tRSYValue = true
tRSZValue = true
tRGroupsValue = true
tRPosValue = [400,400]

-- Functions

fn transformRemover tRTX tRTY tRTZ tRRX tRRY tRRZ tRSX tRSY tRSZ tRGroups = 
	(
	undo "transformRemover" on
		(
		-- seperate out objects
		groupHeads = #()
		groupMembers = #()
		nonGroups = #()
		for obj in selection do
			(
			if isGroupHead obj == true then append groupHeads obj
			else if isgroupmember obj == true then append groupMembers obj
			else append nonGroups obj
			)
			
		-- clear objects
		for obj in groupHeads do
			(
			tRPosition obj tRTX tRTY tRTZ
			tRRotation obj tRRX tRRY tRRZ
			tRScale obj tRSX tRSY tRSZ
			)
		for obj in groupMembers do
			(
			if tRGroups == false then
				(
				tRPosition obj tRTX tRTY tRTZ
				tRRotation obj tRRX tRRY tRRZ
				tRScale obj tRSX tRSY tRSZ
				)
			)
		for obj in nonGroups do
			(
			tRPosition obj tRTX tRTY tRTZ
			tRRotation obj tRRX tRRY tRRZ
			tRScale obj tRSX tRSY tRSZ
			)
		)
	)
	
fn transformRemoverDefaults = 
	(
	tRLoadDef()
	transformRemover tRTXValue tRTYValue tRTZValue tRRXValue tRRYValue tRRZValue tRSXValue tRSYValue tRSZValue tRGroupsValue
	)
	
fn transformRemoverUI = 
	(
	tRLoadDef()
	tRCloseOpenUI tRPosValue
	)

fn tRCloseOpenUI pos = 
	(
	if tRFloater != undefined then CloseRolloutFloater tRFloater
	tRDefineUI()
	tRFloater = newRolloutFloater "transformRemover v1.05" 177 193 pos.x pos.y
	addRollout tRRollout tRFloater
	)

fn tRPosition obj tRTX tRTY tRTZ = 
	(
	if tRTX == true then obj.pos.x = 0
	if tRTY == true then obj.pos.y = 0
	if tRTZ == true then obj.pos.z = 0
	)
	
fn tRRotation obj tRRX tRRY tRRZ = 
	(
	a = obj.pos.x
	b = obj.pos.y
	c = obj.pos.z
	if tRRX == true then obj.rotation.x = 0
	if tRRY == true then obj.rotation.y = 0
	if tRRZ == true then obj.rotation.z = 0		
	obj.pos.x = a
	obj.pos.y = b
	obj.pos.z = c
	)
	
fn tRScale obj tRSX tRSY tRSZ = 
	(
	if tRSX == true then obj.scale.x = 1
	if tRSY == true then obj.scale.y = 1
	if tRSZ == true then obj.scale.z = 1
	)

fn tRDo = 
	(
	transformRemover tRTXValue tRTYValue tRTZValue tRRXValue tRRYValue tRRZValue tRSXValue tRSYValue tRSZValue tRGroupsValue
	if tRFloater != undefined then CloseRolloutFloater tRFloater
	)

fn tRApply = 
	(
	transformRemover tRTXValue tRTYValue tRTZValue tRRXValue tRRYValue tRRZValue tRSXValue tRSYValue tRSZValue tRGroupsValue
	)
	
fn tRHelp = 
	(
	sLibSSPrintHelp "transformRemover"
	)
	
fn tRLoadDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	tRInputFilename = presetDir + "transformRemover.ini"
	if (sLibFileExist tRInputFilename == true) then
		(
		tRTXValue = execute (getINISetting tRInputFilename "transformRemover" "tRTXValue")
		tRTYValue = execute (getINISetting tRInputFilename "transformRemover" "tRTYValue")
		tRTZValue = execute (getINISetting tRInputFilename "transformRemover" "tRTZValue")
		tRRXValue = execute (getINISetting tRInputFilename "transformRemover" "tRRXValue")
		tRRYValue = execute (getINISetting tRInputFilename "transformRemover" "tRRYValue")
		tRRZValue = execute (getINISetting tRInputFilename "transformRemover" "tRRZValue")
		tRSXValue = execute (getINISetting tRInputFilename "transformRemover" "tRSXValue")
		tRSYValue = execute (getINISetting tRInputFilename "transformRemover" "tRSYValue")
		tRSZValue = execute (getINISetting tRInputFilename "transformRemover" "tRSZValue")
		tRGroupsValue = execute (getINISetting tRInputFilename "transformRemover" "tRGroupsValue")
		tRPosValue = execute (getINISetting tRInputFilename "transformRemover" "tRPosValue")
		
		if tRTXValue == OK then tRTXValue = true
		if tRTYValue == OK then tRTYValue = true
		if tRTZValue == OK then tRTZValue = true
		if tRRXValue == OK then tRRXValue = true
		if tRRYValue == OK then tRRYValue = true
		if tRRZValue == OK then tRRZValue = true
		if tRSXValue == OK then tRSXValue = true
		if tRSYValue == OK then tRSYValue = true
		if tRSZValue == OK then tRSZValue = true
		if tRGroupsValue == OK then tRGroupsValue = true
		if tRPosValue == OK then tRPosValue = [400,400]
		)
	else
		(
		tRTXValue = true
		tRTYValue = true
		tRTZValue = true
		tRRXValue = true
		tRRYValue = true
		tRRZValue = true
		tRSXValue = true
		tRSYValue = true
		tRSZValue = true
		tRGroupsValue = true
		tRPosValue = [400,400]
		)
	)
	
fn tRSaveDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	if (getDirectories presetDir).count == 0 then makeDir presetDir
	tROutputFilename = presetDir + "transformRemover.ini"
	if (sLibFileExist tROutputFilename == true) then deleteFile tROutputFilename
	setINISetting tROutputFilename "transformRemover" "tRTXValue" (tRTXValue as string)
	setINISetting tROutputFilename "transformRemover" "tRTYValue" (tRTYValue as string)
	setINISetting tROutputFilename "transformRemover" "tRTZValue" (tRTZValue as string)
	setINISetting tROutputFilename "transformRemover" "tRRXValue" (tRRXValue as string)
	setINISetting tROutputFilename "transformRemover" "tRRYValue" (tRRYValue as string)
	setINISetting tROutputFilename "transformRemover" "tRRZValue" (tRRZValue as string)
	setINISetting tROutputFilename "transformRemover" "tRSXValue" (tRSXValue as string)
	setINISetting tROutputFilename "transformRemover" "tRSYValue" (tRSYValue as string)
	setINISetting tROutputFilename "transformRemover" "tRSZValue" (tRSZValue as string)
	setINISetting tROutputFilename "transformRemover" "tRGroupsValue" (tRGroupsValue as string)
	setINISetting tROutputFilename "transformRemover" "tRPosValue" (tRFloater.pos as string)
	)

-- UI

fn tRDefineUI = 
	(
	rollout tRRollout "transformRemover"
		(
		label label1 "Pos" align:#left pos:[13,7]
		checkbox tRTXCheckbox "X" checked:tRTXValue pos:[13,25]
		checkbox tRTYCheckbox "Y" checked:tRTYValue pos:[13,45]
		checkbox tRTZCheckbox "Z" checked:tRTZValue pos:[13,65]
		on tRTXCheckbox changed state do tRTXValue = state
		on tRTYCheckbox changed state do tRTYValue = state
		on tRTZCheckbox changed state do tRTZValue = state

		label label2 "Rot" align:#left pos:[65,7]
		checkbox tRRXCheckbox "X" checked:tRRXValue pos:[65,25]
		checkbox tRRYCheckbox "Y" checked:tRRYValue pos:[65,45]
		checkbox tRRZCheckbox "Z" checked:tRRZValue pos:[65,65]
		on tRRXCheckbox changed state do tRRXValue = state
		on tRRYCheckbox changed state do tRRYValue = state
		on tRRZCheckbox changed state do tRRZValue = state

		label label3 "Scale" align:#left pos:[117,7]
		checkbox tRSXCheckbox "X" checked:tRSXValue pos:[117,25]
		checkbox tRSYCheckbox "Y" checked:tRSYValue pos:[117,45]
		checkbox tRSZCheckbox "Z" checked:tRSZValue pos:[117,65]
		on tRSXCheckbox changed state do tRSXValue = state
		on tRSYCheckbox changed state do tRSYValue = state
		on tRSZCheckbox changed state do tRSZValue = state

		checkbox tRGroupsCheckbox "Treat Group As One Obj" checked:tRGroupsValue align:#left offset:[0,4]
		on tRGroupsCheckbox changed state do tRGroupsValue = state

		button tRDoButton "Do" width:70 toolTip:"Do It and Close UI" pos:[10,112]
		on tRDoButton pressed do tRDo()
		button tRApplyButton "Apply" width:70 toolTip:"Do It and Keep UI Open" pos:[82,112]
		on tRApplyButton pressed do tRApply()
		button tRHelpButton "Help" width:70 toolTip:"Help" pos:[10,136]
		on tRHelpButton pressed do tRHelp()
		button tRSaveDefButton "SaveDef" width:70 toolTip:"Save Current Settings as Default" pos:[82,136]
		on tRSaveDefButton pressed do tRSaveDef()
		)
	)
)
-------------------------------------------------------------------------------