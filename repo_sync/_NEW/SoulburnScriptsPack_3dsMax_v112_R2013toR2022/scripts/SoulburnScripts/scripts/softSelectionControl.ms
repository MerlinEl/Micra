-------------------------------------------------------------------------------
-- softSelectionControl.ms
-- By Neil Blevins (info@neilblevins.com)
-- v 1.01
-- Created On: 02/15/08
-- Modified On: 04/18/08
-- tested using Max 8.0
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Required Files:
-- sLib.ms
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Description:
-- Toggles, or turns on or off the soft selection tool for objects.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Tutorial:
-- Select an editable poly object. Run the UI version of the script. Hit Do. 
-- It will toggle the soft selection control.
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

global softSelectionControl
global softSelectionControlDefaults
global softSelectionControlUI

global sSCCloseOpenUI

global sSCDo
global sSCApply
global sSCHelp
global sSCLoadDef
global sSCSaveDef

global sSCDefineUI
global sSCRollout
global sSCFloater

-- Includes

include "$scripts\SoulburnScripts\lib\sLib.ms"

-- Variables

sSCActionValue = 1
sSCPosValue = [400,400]

-- Functions

fn softSelectionControl sSCAction = 
	(
	obj = selection[1]
	-- Editable Mesh
	if classof (modPanel.getCurrentObject ()) == Editable_Mesh then
		(
		if sSCAction == 1 then
			(
			if (meshop.getSoftSel (modPanel.getCurrentObject ())) == true then (meshop.setSoftSel (modPanel.getCurrentObject ()) false)
			else (meshop.setSoftSel (modPanel.getCurrentObject ()) true)
			)
		else if sSCAction == 2 then (meshop.setSoftSel (modPanel.getCurrentObject ()) true)
		else if sSCAction == 3 then (meshop.setSoftSel (modPanel.getCurrentObject ()) false)
		)
	-- Edit Mesh
	else if classof (modPanel.getCurrentObject ()) == Edit_Mesh then
		(
		if sSCAction == 1 then
			(
			if (meshop.getUIParam obj (modPanel.getCurrentObject ()) #SoftSel) == 1 then (meshop.setUIParam obj (modPanel.getCurrentObject ()) #SoftSel 0)
			else (meshop.setUIParam obj (modPanel.getCurrentObject ()) #SoftSel 1)
			)
		else if sSCAction == 2 then (meshop.setUIParam obj (modPanel.getCurrentObject ()) #SoftSel 1)
		else if sSCAction == 3 then (meshop.setUIParam obj (modPanel.getCurrentObject ()) #SoftSel 0)		
		)
	-- Editable Poly or Edit Poly
	else if classof (modPanel.getCurrentObject ()) == Editable_Poly or classof (modPanel.getCurrentObject ()) == Edit_Poly then
		(
		if sSCAction == 1 then
			(
			if (modPanel.getCurrentObject ()).useSoftSel == true then (modPanel.getCurrentObject ()).useSoftSel = false
			else (modPanel.getCurrentObject ()).useSoftSel = true
			)
		else if sSCAction == 2 then (modPanel.getCurrentObject ()).useSoftSel = true
		else if sSCAction == 3 then (modPanel.getCurrentObject ()).useSoftSel = false
		)
	-- Editable Spline
	else if (sLibShapeFilter obj) then (MessageBox "Solt Selection in Splines is not accessible to maxscript." title:"SoftSelectionToggler")
	)
	
fn softSelectionControlDefaults = 
	(
	sSCLoadDef()
	softSelectionControl sSCActionValue
	)
	
fn softSelectionControlUI = 
	(
	sSCLoadDef()
	sSCCloseOpenUI sSCPosValue
	)

fn sSCCloseOpenUI pos = 
	(
	if sSCFloater != undefined then CloseRolloutFloater sSCFloater
	sSCDefineUI()
	sSCFloater = newRolloutFloater "softSelectionControl v1.01" 310 91 pos.x pos.y
	addRollout sSCRollout sSCFloater
	)

fn sSCDo = 
	(
	softSelectionControl sSCActionValue
	if sSCFloater != undefined then CloseRolloutFloater sSCFloater
	)

fn sSCApply = 
	(
	softSelectionControl sSCActionValue
	)
	
fn sSCHelp = 
	(
	sLibSSPrintHelp "softSelectionControl"
	)
	
fn sSCLoadDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	sSCInputFilename = presetDir + "softSelectionControl.ini"
	if (sLibFileExist sSCInputFilename == true) then
		(
		sSCActionValue = execute (getINISetting sSCInputFilename "softSelectionControl" "sSCActionValue")
		sSCPosValue = execute (getINISetting sSCInputFilename "softSelectionControl" "sSCPosValue")
		
		if sSCActionValue == OK then sSCActionValue = 1
		if sSCPosValue == OK then sSCPosValue = [400,400]
		)
	else
		(
		sSCActionValue = 1
		sSCPosValue = [400,400]
		)
	)
	
fn sSCSaveDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	if (getDirectories presetDir).count == 0 then makeDir presetDir
	sSCOutputFilename = presetDir + "softSelectionControl.ini"
	if (sLibFileExist sSCOutputFilename == true) then deleteFile sSCOutputFilename
	setINISetting sSCOutputFilename "softSelectionControl" "sSCActionValue" (sSCActionValue as string)
	setINISetting sSCOutputFilename "softSelectionControl" "sSCPosValue" (sSCFloater.pos as string)
	)

-- UI

fn sSCDefineUI = 
	(
	rollout sSCRollout "softSelectionControl"
		(
		label label1 "Action:" pos:[10,10]
		dropdownlist sSCActionDropdown "" items:#("Toggle", "On", "Off") selection:sSCActionValue pos:[50,7] width:237
		on sSCActionDropdown selected i do sSCActionValue = i

		button sSCDoButton "Do" width:70 toolTip:"Do It and Close UI" pos:[5,34]
		on sSCDoButton pressed do sSCDo()
		button sSCApplyButton "Apply" width:70 toolTip:"Do It and Keep UI Open" pos:[77,34]
		on sSCApplyButton pressed do sSCApply()
		button sSCHelpButton "Help" width:70 toolTip:"Help" pos:[149,34]
		on sSCHelpButton pressed do sSCHelp()
		button sSCSaveDefButton "SaveDef" width:70 toolTip:"Save Current Settings as Default" pos:[221,34]
		on sSCSaveDefButton pressed do sSCSaveDef()
		)
	)
)
-------------------------------------------------------------------------------