-------------------------------------------------------------------------------
-- materialFromSelectedObject.ms
-- By Neil Blevins (info@neilblevins.com)
-- v 1.06
-- Created On: 04/20/05
-- Modified On: 09/27/15
-- tested using Max 2016
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Required Files:
-- sLib.ms
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Description:
-- Gets the material from the currently selected object and places it in the 
-- material editor. If multiple objects are selected, chooses the material from
-- the first selected object.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Tutorial:
-- Select an object that has a material assigned. Select material slot 1. Run 
-- the UI version of the script. Hit Do. The material assigned to your object 
-- be put in material slot 1.
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
-- v 1.04 Added error handling for if you don't have any object selected.
--
-- v 1.05 Changed name of script to materialFromSelectedObject.
--
-- v 1.06 Now you can place the material into the SME.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
(
-- Globals

global materialFromSelectedObject
global materialFromSelectedObjectDefaults
global materialFromSelectedObjectUI

global gMFSOCloseOpenUI

global gMFSODo
global gMFSOApply
global gMFSOHelp
global gMFSOLoadDef
global gMFSOSaveDef

global gMFSODefineUI
global gMFSORollout
global gMFSOFloater

-- Includes

include "$scripts\SoulburnScripts\lib\sLib.ms"

-- Variables

gMFSOPutTypeValue = 1
gMFSOSlotValue = 1
gMFSOPosValue = [400,400]

-- Functions

fn materialFromSelectedObject gMFSOPutType gMFSOSlot = 
	(
	if selection.count == 0 then (MessageBox "Please select at least one object." title:"materialFromSelectedObject")
	else
		(
		if ((classof selection[1]) == VRayLight) and (selection[1].texmap != undefined) then (meditMaterials[medit.GetActiveMtlSlot()] = selection[1].texmap)
        	else
        		(
        		mymat = selection[1].material
			if mymat == undefined then (MessageBox "The first object you selected has no material." title:"materialFromSelectedObject")
			else
				(
				if gMFSOPutType == 1 then
					(
					meditmaterials[medit.GetActiveMtlSlot()] = mymat
					)
				else if gMFSOPutType == 2 then
					(
					medit.SetActiveMtlSlot gMFSOSlot false
					meditmaterials[gMFSOSlot] = mymat
					)
				else if gMFSOPutType == 3 then
					(
					if (sme.IsOpen()) == false then (sme.Open())
					CurrentSMEView = sme.getView (sme.activeView)
					CurrentSMEView.CreateNode mymat [0,0]					
					)
				)
			)
		)
	)

fn materialFromSelectedObjectDefaults = 
	(
	gMFSOLoadDef()
	materialFromSelectedObject gMFSOPutTypeValue gMFSOSlotValue
	)
	
fn materialFromSelectedObjectUI = 
	(
	gMFSOLoadDef()
	gMFSOCloseOpenUI gMFSOPosValue
	)

fn gMFSOCloseOpenUI pos = 
	(
	if gMFSOFloater != undefined then CloseRolloutFloater gMFSOFloater
	gMFSODefineUI()
	gMFSOFloater = newRolloutFloater "materialFromSelectedObject v1.06" 310 118 pos.x pos.y
	addRollout gMFSORollout gMFSOFloater
	)

fn gMFSODo = 
	(
	materialFromSelectedObject gMFSOPutTypeValue gMFSOSlotValue
	if gMFSOFloater != undefined then CloseRolloutFloater gMFSOFloater
	)

fn gMFSOApply = 
	(
	materialFromSelectedObject gMFSOPutTypeValue gMFSOSlotValue
	)
	
fn gMFSOHelp = 
	(
	sLibSSPrintHelp "materialFromSelectedObject"
	)
	
fn gMFSOLoadDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	gMFSOInputFilename = presetDir + "materialFromSelectedObject.ini"
	if (sLibFileExist gMFSOInputFilename == true) then
		(
		gMFSOPutTypeValue = execute (getINISetting gMFSOInputFilename "materialFromSelectedObject" "gMFSOPutTypeValue")
		gMFSOSlotValue = execute (getINISetting gMFSOInputFilename "materialFromSelectedObject" "gMFSOSlotValue")
		gMFSOPosValue = execute (getINISetting gMFSOInputFilename "materialFromSelectedObject" "gMFSOPosValue")
		
		if gMFSOPutTypeValue == OK then gMFSOPutTypeValue = 1
		if gMFSOSlotValue == OK then gMFSOSlotValue = 1
		if gMFSOPosValue == OK then gMFSOPosValue = [400,400]
		)
	else
		(
		gMFSOPutTypeValue = 1
		gMFSOSlotValue = 1
		gMFSOPosValue = [400,400]
		)
	)
	
fn gMFSOSaveDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	if (getDirectories presetDir).count == 0 then makeDir presetDir
	gMFSOOutputFilename = presetDir + "materialFromSelectedObject.ini"
	if (sLibFileExist gMFSOOutputFilename == true) then deleteFile gMFSOOutputFilename
	setINISetting gMFSOOutputFilename "materialFromSelectedObject" "gMFSOPutTypeValue" (gMFSOPutTypeValue as string)
	setINISetting gMFSOOutputFilename "materialFromSelectedObject" "gMFSOSlotValue" (gMFSOSlotValue as string)
	setINISetting gMFSOOutputFilename "materialFromSelectedObject" "gMFSOPosValue" (gMFSOFloater.pos as string)
	)

-- UI

fn gMFSODefineUI = 
	(
	rollout gMFSORollout "materialFromSelectedObject"
		(
		dropdownlist gMFSOPutTypeDropdown "" items:#("Use Selected Medit Slot", "Use Specific Medit Slot", "Place in Active SME") selection:gMFSOPutTypeValue
		spinner gMFSOSlotSpinner "Slot: " range:[1,24,gMFSOSlotValue] fieldWidth:50 type:#integer align:#right enabled:false

		on gMFSOPutTypeDropdown selected i do 
			(
			if i == 2 then gMFSOSlotSpinner.enabled = true else gMFSOSlotSpinner.enabled = false
			gMFSOPutTypeValue = i
			)
		on gMFSOSlotSpinner changed val do gMFSOSlotValue = val

		button gMFSODoButton "Do" width:70 toolTip:"Do It and Close UI" pos:[5,60]
		on gMFSODoButton pressed do gMFSODo()
		button gMFSOApplyButton "Apply" width:70 toolTip:"Do It and Keep UI Open" pos:[77,60]
		on gMFSOApplyButton pressed do gMFSOApply()
		button gMFSOHelpButton "Help" width:70 toolTip:"Help" pos:[149,60]
		on gMFSOHelpButton pressed do gMFSOHelp()
		button gMFSOSaveDefButton "SaveDef" width:70 toolTip:"Save Current Settings as Default" pos:[221,60]
		on gMFSOSaveDefButton pressed do gMFSOSaveDef()
		)
	)
)
-------------------------------------------------------------------------------