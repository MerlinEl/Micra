-------------------------------------------------------------------------------
-- wireColorRandomizer.ms
-- By Neil Blevins (info@neilblevins.com)
-- v 1.01
-- Created On: 07/30/07
-- Modified On: 04/18/08
-- tested using Max 8.0
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Required Files:
-- sLib.ms
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Description:
-- Changes the wirecolor of all selected objects to a random value.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Tutorial:
-- Select a bunch of objects. Run the UI version of the script. Hit Do. All
-- the objects wireframe colors will change to something random.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Revision History:
--
-- v 1.01 Replaced the Close button with a Help button. Use the X button to 
-- Close the Floater.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
(
-- Globals

global wireColorRandomizer
global wireColorRandomizerDefaults
global wireColorRandomizerUI

global wCRCloseOpenUI

global wCRDo
global wCRApply
global wCRHelp
global wCRLoadDef
global wCRSaveDef

global wCRDefineUI
global wCRRollout
global wCRFloater

-- Includes

include "$scripts\SoulburnScripts\lib\sLib.ms"

-- Variables

wCRActionValue = 1
wCRPosValue = [400,400]

-- Functions

fn wireColorRandomizer wCRAction = 
	(
	undo "wireColorRandomizer" on
		(
		if wCRAction == 1 then
			(
			for i in selection do 
				(
				i.wirecolor = (color (random 0 255) (random 0 255) (random 0 255)) 
				)
			)
		)
	)
	
fn wireColorRandomizerDefaults = 
	(
	wCRLoadDef()
	wireColorRandomizer wCRActionValue
	)
	
fn wireColorRandomizerUI = 
	(
	wCRLoadDef()
	wCRCloseOpenUI wCRPosValue
	)

fn wCRCloseOpenUI pos = 
	(
	if wCRFloater != undefined then CloseRolloutFloater wCRFloater
	wCRDefineUI()
	wCRFloater = newRolloutFloater "wireColorRandomizer v1.01" 310 91 pos.x pos.y
	addRollout wCRRollout wCRFloater
	)

fn wCRDo = 
	(
	wireColorRandomizer wCRActionValue
	if wCRFloater != undefined then CloseRolloutFloater wCRFloater
	)

fn wCRApply = 
	(
	wireColorRandomizer wCRActionValue
	)
	
fn wCRHelp = 
	(
	sLibSSPrintHelp "wireColorRandomizer"
	)
	
fn wCRLoadDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	wCRInputFilename = presetDir + "wireColorRandomizer.ini"
	if (sLibFileExist wCRInputFilename == true) then
		(
		wCRActionValue = execute (getINISetting wCRInputFilename "wireColorRandomizer" "wCRActionValue")
		wCRPosValue = execute (getINISetting wCRInputFilename "wireColorRandomizer" "wCRPosValue")
		
		if wCRActionValue == OK then wCRActionValue = 1
		if wCRPosValue == OK then wCRPosValue = [400,400]
		)
	else
		(
		wCRActionValue = 1
		wCRPosValue = [400,400]
		)
	)
	
fn wCRSaveDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	if (getDirectories presetDir).count == 0 then makeDir presetDir
	wCROutputFilename = presetDir + "wireColorRandomizer.ini"
	if (sLibFileExist wCROutputFilename == true) then deleteFile wCROutputFilename
	setINISetting wCROutputFilename "wireColorRandomizer" "wCRActionValue" (wCRActionValue as string)
	setINISetting wCROutputFilename "wireColorRandomizer" "wCRPosValue" (wCRFloater.pos as string)
	)

-- UI

fn wCRDefineUI = 
	(
	rollout wCRRollout "wireColorRandomizer"
		(
		label label1 "Action:" pos:[10,10]
		dropdownlist wCRActionDropdown "" items:#("Totally Random") selection:wCRActionValue pos:[50,7] width:237
		on wCRActionDropdown selected i do wCRActionValue = i

		button wCRDoButton "Do" width:70 toolTip:"Do It and Close UI" pos:[5,34]
		on wCRDoButton pressed do wCRDo()
		button wCRApplyButton "Apply" width:70 toolTip:"Do It and Keep UI Open" pos:[77,34]
		on wCRApplyButton pressed do wCRApply()
		button wCRHelpButton "Help" width:70 toolTip:"Help" pos:[149,34]
		on wCRHelpButton pressed do wCRHelp()
		button wCRSaveDefButton "SaveDef" width:70 toolTip:"Save Current Settings as Default" pos:[221,34]
		on wCRSaveDefButton pressed do wCRSaveDef()
		)
	)
)
-------------------------------------------------------------------------------