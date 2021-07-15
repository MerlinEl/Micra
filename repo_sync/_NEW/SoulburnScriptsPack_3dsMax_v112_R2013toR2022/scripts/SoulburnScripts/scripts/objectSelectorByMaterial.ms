-------------------------------------------------------------------------------
-- objectSelectorByMaterial.ms
-- By Neil Blevins (info@neilblevins.com)
-- v 1.05
-- Created On: 05/18/05
-- Modified On: 01/28/15
-- tested using Max 2011
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Required Files:
-- sLib.ms
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Description:
-- Finds all objects that are assigned the currently active material in the 
-- medit and does various things to them such as selecting them, printing 
-- their names, isolating them, etc.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Tutorial:
-- Select a material in the material editor that is assigned to some objects
-- in the scene. Run the UI version of the script. Change action to select. Hit 
-- Do. It has now selected all the objects in the scene that the material is 
-- assigned to.
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
-- v 1.04 Added support for max2011's Slate Material Editor.
--
-- v 1.05 Changed name of script to objectSelectorByMaterial.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
(
-- Globals

global objectSelectorByMaterial
global objectSelectorByMaterialDefaults
global objectSelectorByMaterialUI

global fBAMCloseOpenUI

global fBAMChooseAction

global fBAMDo
global fBAMApply
global fBAMHelp
global fBAMLoadDef
global fBAMSaveDef

global fBAMDefineUI
global fBAMRollout
global fBAMFloater

-- Includes

include "$scripts\SoulburnScripts\lib\sLib.ms"

-- Variables

fBAMActionValue = 1
fBAMMeditModeValue = 1
fBAMPosValue = [400,400]

-- Functions

fn objectSelectorByMaterial fBAMAction fBAMMeditMode = 
	(
	undo "objectSelectorByMaterial" on
		(
		fBAMChooseAction fBAMAction fBAMMeditMode
		)
	)
	
fn objectSelectorByMaterialDefaults = 
	(
	fBAMLoadDef()
	objectSelectorByMaterial fBAMActionValue fBAMMeditModeValue
	)
	
fn objectSelectorByMaterialUI = 
	(
	fBAMLoadDef()
	fBAMCloseOpenUI fBAMPosValue
	)

fn fBAMCloseOpenUI pos = 
	(
	if fBAMFloater != undefined then CloseRolloutFloater fBAMFloater
	fBAMDefineUI()
	fBAMFloater = newRolloutFloater "objectSelectorByMaterial v1.05" 310 116 pos.x pos.y
	addRollout fBAMRollout fBAMFloater
	)

fn fBAMChooseAction fBAMAction tPMeditMode = 
	(
	if tPMeditMode == 2 then
		(
		if sLibMaxVer() < 13.0 then (MessageBox "Slate Medit Mode only works with Max 2011 and up, please change to mode to: Use Classic Mat Editor" title:"materialInfoDisplayer";mat = undefined)
		else (mat = sme.GetMtlInParamEditor())
		)
	else (mat = (medit.GetCurMtl()))
		
	if mat != undefined then
		(
		a = #()
		for i in $* do if i.material == mat then append a i
		-- Select
		if fBAMAction == 1 then
			(
			if a.count == 0 then print "No objects are assigned this material"
			else select a
			)
		-- Isolate
		else if fBAMAction == 2 then
			(
			for i in a do i.isHidden = false
			if a.count == 0 then print "No objects are assigned this material"
			else select a
			max hide inv
			)
		)
	)

fn fBAMDo = 
	(
	objectSelectorByMaterial fBAMActionValue fBAMMeditModeValue
	if fBAMFloater != undefined then CloseRolloutFloater fBAMFloater
	)

fn fBAMApply = 
	(
	objectSelectorByMaterial fBAMActionValue fBAMMeditModeValue
	)
	
fn fBAMHelp = 
	(
	sLibSSPrintHelp "objectSelectorByMaterial"
	)
	
fn fBAMLoadDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	fBAMInputFilename = presetDir + "objectSelectorByMaterial.ini"
	if (sLibFileExist fBAMInputFilename == true) then
		(
		fBAMActionValue = execute (getINISetting fBAMInputFilename "objectSelectorByMaterial" "fBAMActionValue")
		fBAMMeditModeValue = execute (getINISetting fBAMInputFilename "objectSelectorByMaterial" "fBAMMeditModeValue")
		fBAMPosValue = execute (getINISetting fBAMInputFilename "objectSelectorByMaterial" "fBAMPosValue")
		
		if fBAMActionValue == OK then fBAMActionValue = 1
		if fBAMMeditModeValue == OK then fBAMMeditModeValue = 1
		if fBAMPosValue == OK then fBAMPosValue = [400,400]
		)
	else
		(
		fBAMActionValue = 1
		fBAMMeditModeValue = 1
		fBAMPosValue = [400,400]
		)
	)
	
fn fBAMSaveDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	if (getDirectories presetDir).count == 0 then makeDir presetDir
	fBAMOutputFilename = presetDir + "objectSelectorByMaterial.ini"
	if (sLibFileExist fBAMOutputFilename == true) then deleteFile fBAMOutputFilename
	setINISetting fBAMOutputFilename "objectSelectorByMaterial" "fBAMActionValue" (fBAMActionValue as string)
	setINISetting fBAMOutputFilename "objectSelectorByMaterial" "fBAMMeditModeValue" (fBAMMeditModeValue as string)
	setINISetting fBAMOutputFilename "objectSelectorByMaterial" "fBAMPosValue" (fBAMFloater.pos as string)
	)

-- UI

fn fBAMDefineUI = 
	(
	rollout fBAMRollout "objectSelectorByMaterial"
		(
		label label1 "Action:" pos:[10,10]
		dropdownlist fBAMActionDropdown "" items:#("Select", "Isolate") selection:fBAMActionValue pos:[50,7] width:237
		on fBAMActionDropdown selected i do fBAMActionValue = i
		dropdownlist fBAMMeditModeDropdown "" items:#("Use Classic Mat Editor", "Use Slate Mat Editor") selection:fBAMMeditModeValue width:150 align:#right
		on fBAMMeditModeDropdown selected i do fBAMMeditModeValue = i

		button fBAMDoButton "Do" width:70 toolTip:"Do It and Close UI" pos:[5,60]
		on fBAMDoButton pressed do fBAMDo()
		button fBAMApplyButton "Apply" width:70 toolTip:"Do It and Keep UI Open" pos:[77,60]
		on fBAMApplyButton pressed do fBAMApply()
		button fBAMHelpButton "Help" width:70 toolTip:"Help" pos:[149,60]
		on fBAMHelpButton pressed do fBAMHelp()
		button fBAMSaveDefButton "SaveDef" width:70 toolTip:"Save Current Settings as Default" pos:[221,60]
		on fBAMSaveDefButton pressed do fBAMSaveDef()
		)
	)
)
-------------------------------------------------------------------------------