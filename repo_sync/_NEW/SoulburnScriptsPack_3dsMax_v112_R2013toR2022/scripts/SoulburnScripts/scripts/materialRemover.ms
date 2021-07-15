-------------------------------------------------------------------------------
-- materialRemover.ms
-- By Neil Blevins (info@neilblevins.com)
-- v 1.03
-- Created On: 04/04/05
-- Modified On: 04/18/08
-- tested using Max 7.1
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Required Files:
-- sLib.ms
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Description:
-- Removes the materials from the selected objects.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Tutorial:
-- Select an object that has a material assigned. Run the UI version of the 
-- script. Hit Do. Now the selected object has no material assigned.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Revision History:
--
-- v 1.01 Defined ui as new function.
--
-- v 1.02 Added some new code to more cleanly open and close the UI.
--
-- v 1.03 Replaced the Close button with a Help button. Use the X button to 
-- Close the Floater.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
(
-- Globals

global materialRemover
global materialRemoverDefaults
global materialRemoverUI

global mRCloseOpenUI

global mRDo
global mRApply
global mRHelp
global mRLoadDef
global mRSaveDef
global mROpenUI

global mRDefineUI
global mRRollout
global mRFloater

-- Includes

include "$scripts\SoulburnScripts\lib\sLib.ms"

-- Variables

mRShowWarningValue = true
mRPosValue = [400,400]

-- Functions

fn materialRemover mRShowWarning = 
	(
	undo "materialRemover" on
		(
		if selection.count == 0 then (MessageBox "Please select at least one object" title:"materialRemover")
		else
			(
			if mRShowWarning == true then
				(
				if (queryBox "Remove all materials from selected objects?" title:"materialRemover") == true then 
					(
					for i in selection do i.material = undefined
					)
				)
			else 
				(
				for i in selection do i.material = undefined
				)
			)
		)
	)

fn materialRemoverDefaults = 
	(
	mRLoadDef()
	materialRemover mRShowWarningValue
	)

fn materialRemoverUI = 
	(
	mRLoadDef()
	mRCloseOpenUI mRPosValue
	)

fn mRCloseOpenUI pos = 
	(
	if mRFloater != undefined then CloseRolloutFloater mRFloater
	mRDefineUI()
	mRFloater = newRolloutFloater "materialRemover v1.03" 310 86 pos.x pos.y
	addRollout mRRollout mRFloater
	)

fn mRDo = 
	(
	materialRemover mRShowWarningValue
	if mRFloater != undefined then CloseRolloutFloater mRFloater
	)

fn mRApply = 
	(
	materialRemover mRShowWarningValue
	)
	
fn mRHelp = 
	(
	sLibSSPrintHelp "materialRemover"
	)
	
fn mRLoadDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	mRInputFilename = presetDir + "materialRemover.ini"
	if (sLibFileExist mRInputFilename == true) then
		(
		mRShowWarningValue = execute (getINISetting mRInputFilename "materialRemover" "mRShowWarningValue")
		mRPosValue = execute (getINISetting mRInputFilename "materialRemover" "mRPosValue")
		
		if mRShowWarningValue == OK then mRShowWarningValue = true
		if mRPosValue == OK then mRPosValue = [400,400]
		)
	else
		(
		mRShowWarningValue = true
		mRPosValue = [400,400]
		)
	)
	
fn mRSaveDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	if (getDirectories presetDir).count == 0 then makeDir presetDir
	mROutputFilename = presetDir + "materialRemover.ini"
	if (sLibFileExist mROutputFilename == true) then deleteFile mROutputFilename
	setINISetting mROutputFilename "materialRemover" "mRShowWarningValue" (mRShowWarningValue as string)
	setINISetting mROutputFilename "materialRemover" "mRPosValue" (mRFloater.pos as string)
	)

-- UI

fn mRDefineUI = 
	(
	rollout mRRollout "materialRemover"
		(
		checkbox mRShowWarningCheckbox "Show Warning?" checked:mRShowWarningValue align:#left
		on mRShowWarningCheckbox changed state do mRShowWarningValue = state

		button mRDoButton "Do" width:70 toolTip:"Do It and Close UI" pos:[5,28]
		on mRDoButton pressed do mRDo()
		button mRApplyButton "Apply" width:70 toolTip:"Do It and Keep UI Open" pos:[77,28]
		on mRApplyButton pressed do mRApply()
		button mRHelpButton "Help" width:70 toolTip:"Help" pos:[149,28]
		on mRHelpButton pressed do mRHelp()
		button mRSaveDefButton "SaveDef" width:70 toolTip:"Save Current Settings as Default" pos:[221,28]
		on mRSaveDefButton pressed do mRSaveDef()
		)
	)
)
-------------------------------------------------------------------------------