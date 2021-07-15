-------------------------------------------------------------------------------
-- selectionRandomizer.ms
-- By Neil Blevins (info@neilblevins.com)
-- v 1.04
-- Created On: 10/09/05
-- Modified On: 04/18/08
-- tested using Max 8.0
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Required Files:
-- sLib.ms
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Description:
-- Will randomly select objects based on a value provided.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Tutorial:
-- Select a bunch of objects, run the UI version of the script, hit Do, it will 
-- randomly select the number of objects you specify from your initial selection.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Revision History:
--
-- v 1.01 Defined ui as new function.
--
-- v 1.02 Added some new code to more cleanly open and close the UI.
--
-- v 1.03 Added a fix to properly deselect objects.
--
-- v 1.04 Replaced the Close button with a Help button. Use the X button to 
-- Close the Floater.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
(
-- Globals

global selectionRandomizer
global selectionRandomizerDefaults
global selectionRandomizerUI

global sRACloseOpenUI

global sRADo
global sRAApply
global sRAHelp
global sRALoadDef
global sRASaveDef

global sRADefineUI
global sRARollout
global sRAFloater

-- Includes

include "$scripts\SoulburnScripts\lib\sLib.ms"

-- Variables

sRATypeValue = 3
sRAWeightValue = 50
sRAExactValue = 0
sRAPercentageValue = 50
sRAPosValue = [400,400]

-- Functions

fn selectionRandomizer sRAType sRAWeight sRAExact sRAPercentage = 
	(
	undo "selectionRandomizer" on
		(
		if selection.count == 0 then (MessageBox "Please select at least one object" title:"selectionRandomizer")
		else
			(
			objs = for i in selection collect i
			toBeSelected = #()
					
			if sRAType == 1 then toBeSelected = sLibChooseUniqueValuesByWeight objs sRAWeight
			else if sRAType == 2 then toBeSelected = sLibChooseUniqueValuesByNumber objs sRAExact
			else toBeSelected = sLibChooseUniqueValuesByPercentage objs sRAPercentage
				
			if toBeSelected.count == 0 then deselect selection
			else select toBeSelected
			toBeSelected = #()
			)
		)
	)

fn selectionRandomizerDefaults = 
	(
	sRALoadDef()
	selectionRandomizer sRATypeValue sRAWeightValue sRAExactValue sRAPercentageValue
	)
	
fn selectionRandomizerUI = 
	(
	sRALoadDef()
	sRACloseOpenUI sRAPosValue
	)

fn sRACloseOpenUI pos = 
	(
	if sRAFloater != undefined then CloseRolloutFloater sRAFloater
	sRADefineUI()
	sRAFloater = newRolloutFloater "selectionRandomizer v1.04" 175 183 pos.x pos.y
	addRollout sRARollout sRAFloater
	)

fn sRADo = 
	(
	selectionRandomizer sRATypeValue sRAWeightValue sRAExactValue sRAPercentageValue
	if sRAFloater != undefined then CloseRolloutFloater sRAFloater
	)

fn sRAApply = 
	(
	selectionRandomizer sRATypeValue sRAWeightValue sRAExactValue sRAPercentageValue
	)
	
fn sRAHelp = 
	(
	sLibSSPrintHelp "selectionRandomizer"
	)
	
fn sRALoadDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	sRAInputFilename = presetDir + "selectionRandomizer.ini"
	if (sLibFileExist sRAInputFilename == true) then
		(
		sRATypeValue = execute (getINISetting sRAInputFilename "selectionRandomizer" "sRATypeValue")
		sRAWeightValue = execute (getINISetting sRAInputFilename "selectionRandomizer" "sRAWeightValue")
		sRAExactValue = execute (getINISetting sRAInputFilename "selectionRandomizer" "sRAExactValue")
		sRAPercentageValue = execute (getINISetting sRAInputFilename "selectionRandomizer" "sRAPercentageValue")
		sRAPosValue = execute (getINISetting sRAInputFilename "selectionRandomizer" "sRAPosValue")
		
		if sRATypeValue == OK then sRATypeValue = 3
		if sRAWeightValue == OK then sRAWeightValue = 50
		if sRAExactValue == OK then sRAExactValue = 0
		if sRAPercentageValue == OK then sRAPercentageValue = 50
		if sRAPosValue == OK then sRAPosValue = [400,400]
		)
	else
		(
		sRATypeValue = 3
		sRAWeightValue = 50
		sRAExactValue = 0
		sRAPercentageValue = 50
		sRAPosValue = [400,400]
		)
	)
	
fn sRASaveDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	if (getDirectories presetDir).count == 0 then makeDir presetDir
	sRAOutputFilename = presetDir + "selectionRandomizer.ini"
	if (sLibFileExist sRAOutputFilename == true) then deleteFile sRAOutputFilename
	setINISetting sRAOutputFilename "selectionRandomizer" "sRATypeValue" (sRATypeValue as string)
	setINISetting sRAOutputFilename "selectionRandomizer" "sRAWeightValue" (sRAWeightValue as string)
	setINISetting sRAOutputFilename "selectionRandomizer" "sRAExactValue" (sRAExactValue as string)
	setINISetting sRAOutputFilename "selectionRandomizer" "sRAPercentageValue" (sRAPercentageValue as string)
	setINISetting sRAOutputFilename "selectionRandomizer" "sRAPosValue" (sRAFloater.pos as string)
	)

-- UI

fn sRADefineUI = 
	(
	rollout sRARollout "selectionRandomizer"
		(
		dropdownlist sRATypeDropdown "" items:#("Weight", "Exact Number", "Percentage %") selection:sRATypeValue
		spinner sRAWeightSpinner "Weight: " range:[0,100,sRAWeightValue] fieldWidth:40 type:#integer
		spinner sRAExactSpinner "Exact Number: " range:[0,999999999,sRAExactValue] fieldWidth:40 type:#integer
		spinner sRAPercentageSpinner "Percentage %: " range:[0,100,sRAPercentageValue] fieldWidth:40 type:#integer

		on sRATypeDropdown selected i do 
			(
			sRATypeValue = i
			curPos = sRAFloater.pos
			sRACloseOpenUI curPos
			)
		on sRAWeightSpinner changed val do sRAWeightValue = val
		on sRAExactSpinner changed val do sRAExactValue = val
		on sRAPercentageSpinner changed val do sRAPercentageValue = val

		button sRADoButton "Do" width:70 toolTip:"Do It and Close UI" pos:[9,102]
		on sRADoButton pressed do sRADo()
		button sRAApplyButton "Apply" width:70 toolTip:"Do It and Keep UI Open" pos:[81,102]
		on sRAApplyButton pressed do sRAApply()
		button sRAHelpButton "Help" width:70 toolTip:"Help" pos:[9,126]
		on sRAHelpButton pressed do sRAHelp()
		button sRASaveDefButton "SaveDef" width:70 toolTip:"Save Current Settings as Default" pos:[81,126]
		on sRASaveDefButton pressed do sRASaveDef()

		on sRARollout open do
			(
			if sRATypeValue == 1 then
				(
				sRAWeightSpinner.enabled = true
				sRAExactSpinner.enabled = false
				sRAPercentageSpinner.enabled = false
				)
			else if sRATypeValue == 2 then
				(
				sRAWeightSpinner.enabled = false
				sRAExactSpinner.enabled = true
				sRAPercentageSpinner.enabled = false
				)
			else if sRATypeValue == 3 then
				(
				sRAWeightSpinner.enabled = false
				sRAExactSpinner.enabled = false
				sRAPercentageSpinner.enabled = true
				)
			)
		)
	)
)
-------------------------------------------------------------------------------