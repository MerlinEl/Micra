-------------------------------------------------------------------------------
-- nodeTypeDisplayer.ms
-- By Neil Blevins (info@neilblevins.com)
-- v 1.04
-- Created On: 05/23/05
-- Modified On: 01/28/15
-- tested using Max 7.1
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Required Files:
-- sLib.ms
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Description:
-- Prints the Class or SuperClass of selected nodes.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Tutorial:
-- Select an object. Run the UI version of the script. Hit Do. It will print
-- the superclass of the object in the maxscript editor.
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
--
-- v 1.04 Changed name of script to nodeTypeDisplayer.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
(
-- Globals

global nodeTypeDisplayer
global nodeTypeDisplayerDefaults
global nodeTypeDisplayerUI

global gNTCloseOpenUI

global gNTDo
global gNTApply
global gNTHelp
global gNTLoadDef
global gNTSaveDef

global gNTDefineUI
global gNTRollout
global gNTFloater

-- Includes

include "$scripts\SoulburnScripts\lib\sLib.ms"

-- Variables

gNTActionValue = 1
gNTPosValue = [400,400]

-- Functions

fn nodeTypeDisplayer gNTAction = 
	(
	a = for obj in selection collect obj
	qsort a sLibNameCompareCaseInsensitive
	if a.count != 0 then
		(
		for i = 1 to a.count do
			(
			if gNTAction == 1 then print ((a[i].name as string) + " : " + ((SuperClassOf a[i]) as string))
			else if gNTAction == 2 then print ((a[i].name as string) + " : " + ((ClassOf a[i]) as string))
			)
		)
	)
	
fn nodeTypeDisplayerDefaults = 
	(
	gNTLoadDef()
	nodeTypeDisplayer gNTActionValue
	)
	
fn nodeTypeDisplayerUI = 
	(
	gNTLoadDef()
	gNTCloseOpenUI gNTPosValue
	)

fn gNTCloseOpenUI pos = 
	(
	if gNTFloater != undefined then CloseRolloutFloater gNTFloater
	gNTDefineUI()
	gNTFloater = newRolloutFloater "nodeTypeDisplayer v1.04" 310 91 pos.x pos.y
	addRollout gNTRollout gNTFloater
	)

fn gNTDo = 
	(
	nodeTypeDisplayer gNTActionValue
	if gNTFloater != undefined then CloseRolloutFloater gNTFloater
	)

fn gNTApply = 
	(
	nodeTypeDisplayer gNTActionValue
	)
	
fn gNTHelp = 
	(
	sLibSSPrintHelp "nodeTypeDisplayer"
	)
	
fn gNTLoadDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	gNTInputFilename = presetDir + "nodeTypeDisplayer.ini"
	if (sLibFileExist gNTInputFilename == true) then
		(
		gNTActionValue = execute (getINISetting gNTInputFilename "nodeTypeDisplayer" "gNTActionValue")
		gNTPosValue = execute (getINISetting gNTInputFilename "nodeTypeDisplayer" "gNTPosValue")
		
		if gNTActionValue == OK then gNTActionValue = 1
		if gNTPosValue == OK then gNTPosValue = [400,400]
		)
	else
		(
		gNTActionValue = 1
		gNTPosValue = [400,400]
		)
	)
	
fn gNTSaveDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	if (getDirectories presetDir).count == 0 then makeDir presetDir
	gNTOutputFilename = presetDir + "nodeTypeDisplayer.ini"
	if (sLibFileExist gNTOutputFilename == true) then deleteFile gNTOutputFilename
	setINISetting gNTOutputFilename "nodeTypeDisplayer" "gNTActionValue" (gNTActionValue as string)
	setINISetting gNTOutputFilename "nodeTypeDisplayer" "gNTPosValue" (gNTFloater.pos as string)
	)

-- UI

fn gNTDefineUI = 
	(
	rollout gNTRollout "nodeTypeDisplayer"
		(
		label label1 "Action:" pos:[10,10]
		dropdownlist gNTActionDropdown "" items:#("SuperClassOf", "ClassOf") selection:gNTActionValue pos:[50,7] width:237
		on gNTActionDropdown selected i do gNTActionValue = i

		button gNTDoButton "Do" width:70 toolTip:"Do It and Close UI" pos:[5,34]
		on gNTDoButton pressed do gNTDo()
		button gNTApplyButton "Apply" width:70 toolTip:"Do It and Keep UI Open" pos:[77,34]
		on gNTApplyButton pressed do gNTApply()
		button gNTHelpButton "Help" width:70 toolTip:"Help" pos:[149,34]
		on gNTHelpButton pressed do gNTHelp()
		button gNTSaveDefButton "SaveDef" width:70 toolTip:"Save Current Settings as Default" pos:[221,34]
		on gNTSaveDefButton pressed do gNTSaveDef()
		)
	)
)
-------------------------------------------------------------------------------