-------------------------------------------------------------------------------
-- elementSelectByFace.ms
-- By Neil Blevins (info@neilblevins.com)
-- v 1.00
-- Created On: 12/13/15
-- Modified On: 12/13/15
-- tested using Max 2014
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Required Files:
-- sLib.ms
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Description:
-- Once you've selected a face of an Editable Poly, it will select the entire 
-- element the face is associated with. Great for selecting elements without
-- having to leave face mode.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Tutorial:
-- Create an Editable Poly object. Select a face. Bind this script to a hotkey.
-- Hot the hotkey. The entire element has been selected, but you're still in 
-- face mode.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
(
-- Globals

global elementSelectByFace
global elementSelectByFaceDefaults
global elementSelectByFaceUI

global eSBFCloseOpenUI

global eSBFDo
global eSBFApply
global eSBFHelp
global eSBFLoadDef
global eSBFSaveDef

global eSBFDefineUI
global eSBFRollout
global eSBFFloater

-- Includes

include "$scripts\SoulburnScripts\lib\sLib.ms"

-- Variables

eSBFActionValue = 1
eSBFPosValue = [400,400]

-- Functions

fn elementSelectByFace eSBFAction = 
	(
	undo "elementSelectByFace" on
		(
		if selection.count != 1 then (MessageBox "Please select only one object." title:"elementSelectByFace")
		else 
			(
			obj = selection[1]
			-- Editable Poly
			if classof (modPanel.getCurrentObject ()) == Editable_Poly then 
				(
				a = polyop.getElementsUsingFace obj (getfaceselection obj)
				polyop.setFaceSelection obj a
				)
			-- Edit Poly
			else if classof (modPanel.getCurrentObject ()) == Edit_Poly then 
				(
				currentModIndex = (modPanel.getModifierIndex obj (modPanel.getCurrentObject()))
				myMod = obj.modifiers[currentModIndex]
				myMod.ConvertSelection #Face #Element
				)
			completeRedraw()
			if eSBFAction == 2 then subobjectLevel = 5
			)
		)
	)
	
fn elementSelectByFaceDefaults = 
	(
	eSBFLoadDef()
	elementSelectByFace eSBFActionValue
	)
	
fn elementSelectByFaceUI = 
	(
	eSBFLoadDef()
	eSBFCloseOpenUI eSBFPosValue
	)

fn eSBFCloseOpenUI pos = 
	(
	if eSBFFloater != undefined then CloseRolloutFloater eSBFFloater
	eSBFDefineUI()
	eSBFFloater = newRolloutFloater "elementSelectByFace v1.00" 310 91 pos.x pos.y
	addRollout eSBFRollout eSBFFloater
	)

fn eSBFDo = 
	(
	elementSelectByFace eSBFActionValue
	if eSBFFloater != undefined then CloseRolloutFloater eSBFFloater
	)

fn eSBFApply = 
	(
	elementSelectByFace eSBFActionValue
	)
	
fn eSBFHelp = 
	(
	sLibSSPrintHelp "elementSelectByFace"
	)
	
fn eSBFLoadDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	eSBFInputFilename = presetDir + "elementSelectByFace.ini"
	if (sLibFileExist eSBFInputFilename == true) then
		(
		eSBFActionValue = execute (getINISetting eSBFInputFilename "elementSelectByFace" "eSBFActionValue")
		eSBFPosValue = execute (getINISetting eSBFInputFilename "elementSelectByFace" "eSBFPosValue")
		
		if eSBFActionValue == OK then eSBFActionValue = 1
		if eSBFPosValue == OK then eSBFPosValue = [400,400]
		)
	else
		(
		eSBFActionValue = 1
		eSBFPosValue = [400,400]
		)
	)
	
fn eSBFSaveDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	if (getDirectories presetDir).count == 0 then makeDir presetDir
	eSBFOutputFilename = presetDir + "elementSelectByFace.ini"
	if (sLibFileExist eSBFOutputFilename == true) then deleteFile eSBFOutputFilename
	setINISetting eSBFOutputFilename "elementSelectByFace" "eSBFActionValue" (eSBFActionValue as string)
	setINISetting eSBFOutputFilename "elementSelectByFace" "eSBFPosValue" (eSBFFloater.pos as string)
	)

-- UI

fn eSBFDefineUI = 
	(
	rollout eSBFRollout "elementSelectByFace"
		(
		label label1 "Action:" pos:[10,10]
		dropdownlist eSBFActionDropdown "" items:#("Stay With Current Subobject Type", "Switch To Element Subobject Type") selection:eSBFActionValue pos:[50,7] width:237
		on eSBFActionDropdown selected i do eSBFActionValue = i

		button eSBFDoButton "Do" width:70 toolTip:"Do It and Close UI" pos:[5,34]
		on eSBFDoButton pressed do eSBFDo()
		button eSBFApplyButton "Apply" width:70 toolTip:"Do It and Keep UI Open" pos:[77,34]
		on eSBFApplyButton pressed do eSBFApply()
		button eSBFHelpButton "Help" width:70 toolTip:"Help" pos:[149,34]
		on eSBFHelpButton pressed do eSBFHelp()
		button eSBFSaveDefButton "SaveDef" width:70 toolTip:"Save Current Settings as Default" pos:[221,34]
		on eSBFSaveDefButton pressed do eSBFSaveDef()
		)
	)
)
-------------------------------------------------------------------------------