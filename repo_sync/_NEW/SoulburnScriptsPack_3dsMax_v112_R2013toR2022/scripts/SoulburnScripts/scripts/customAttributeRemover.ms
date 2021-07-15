-------------------------------------------------------------------------------
-- customAttributeRemover.ms
-- By Neil Blevins (info@neilblevins.com)
-- v 1.00
-- Created On: 06/12/14
-- Modified On: 06/12/14
-- tested using Max 2014
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Required Files:
-- sLib.ms
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Description:
-- Delete all Custom Attributes from selected or all scene objects.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Tutorial:
-- Select some objects that have Custom Attributes assigned to them. Run the 
-- UI version of the script. Hit Do. All Custom Attributes will be deleted.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
(
-- Globals

global customAttributeRemover
global customAttributeRemoverDefaults
global customAttributeRemoverUI

global cARCloseOpenUI

global cARDo
global cARApply
global cARHelp
global cARLoadDef
global cARSaveDef

global cARDefineUI
global cARRollout
global cARFloater

-- Includes

include "$scripts\SoulburnScripts\lib\sLib.ms"

-- Variables

cARActionValue = 1
cARPosValue = [400,400]

-- Functions

fn customAttributeRemover cARAction = 
	(
	undo "customAttributeRemover" on
		(
		max create mode
		if cARAction == 1 then (a = for i in $ collect i)
		else (a = for i in $* collect i)
		for i in a do
			(
			num = custAttributes.count i
			if num > 0 then
				(
				for w = num to 1 by -1 do custAttributes.delete a w
				)
			)
		)
	)
	
fn customAttributeRemoverDefaults = 
	(
	cARLoadDef()
	customAttributeRemover cARActionValue
	)
	
fn customAttributeRemoverUI = 
	(
	cARLoadDef()
	cARCloseOpenUI cARPosValue
	)

fn cARCloseOpenUI pos = 
	(
	if cARFloater != undefined then CloseRolloutFloater cARFloater
	cARDefineUI()
	cARFloater = newRolloutFloater "customAttributeRemover v1.00" 310 91 pos.x pos.y
	addRollout cARRollout cARFloater
	)

fn cARDo = 
	(
	customAttributeRemover cARActionValue
	if cARFloater != undefined then CloseRolloutFloater cARFloater
	)

fn cARApply = 
	(
	customAttributeRemover cARActionValue
	)
	
fn cARHelp = 
	(
	sLibSSPrintHelp "customAttributeRemover"
	)
	
fn cARLoadDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	cARInputFilename = presetDir + "customAttributeRemover.ini"
	if (sLibFileExist cARInputFilename == true) then
		(
		cARActionValue = execute (getINISetting cARInputFilename "customAttributeRemover" "cARActionValue")
		cARPosValue = execute (getINISetting cARInputFilename "customAttributeRemover" "cARPosValue")
		
		if cARActionValue == OK then cARActionValue = 1
		if cARPosValue == OK then cARPosValue = [400,400]
		)
	else
		(
		cARActionValue = 1
		cARPosValue = [400,400]
		)
	)
	
fn cARSaveDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	if (getDirectories presetDir).count == 0 then makeDir presetDir
	cAROutputFilename = presetDir + "customAttributeRemover.ini"
	if (sLibFileExist cAROutputFilename == true) then deleteFile cAROutputFilename
	setINISetting cAROutputFilename "customAttributeRemover" "cARActionValue" (cARActionValue as string)
	setINISetting cAROutputFilename "customAttributeRemover" "cARPosValue" (cARFloater.pos as string)
	)

-- UI

fn cARDefineUI = 
	(
	rollout cARRollout "customAttributeRemover"
		(
		label label1 "Action:" pos:[10,10]
		dropdownlist cARActionDropdown "" items:#("Delete All Custom Attributes In Selection", "Delete All Custom Attributes In Scene") selection:cARActionValue pos:[50,7] width:237
		on cARActionDropdown selected i do cARActionValue = i

		button cARDoButton "Do" width:70 toolTip:"Do It and Close UI" pos:[5,34]
		on cARDoButton pressed do cARDo()
		button cARApplyButton "Apply" width:70 toolTip:"Do It and Keep UI Open" pos:[77,34]
		on cARApplyButton pressed do cARApply()
		button cARHelpButton "Help" width:70 toolTip:"Help" pos:[149,34]
		on cARHelpButton pressed do cARHelp()
		button cARSaveDefButton "SaveDef" width:70 toolTip:"Save Current Settings as Default" pos:[221,34]
		on cARSaveDefButton pressed do cARSaveDef()
		)
	)
)
-------------------------------------------------------------------------------