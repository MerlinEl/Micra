-------------------------------------------------------------------------------
-- vertexAndEdgeConnector.ms
-- By Neil Blevins (info@neilblevins.com)
-- v 1.03
-- Created On: 08/09/07
-- Modified On: 02/09/09
-- tested using Max 2009
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Required Files:
-- sLib.ms
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Description:
-- Performs a number of Connect functionality in one script. For example, in 
-- vanilla max, you can't assign the same hotkey to both connect an edge and 
-- connect a vertex. You also can't have one hotkey that both connects in
-- an EditablePoly and an EditPoly. This script allows you to have one hotkey
-- to do all of that, and it detects what mode you're in to choose what action
-- to perform.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Tutorial:
-- Select an editable poly object. Select two edges. Run the script in UI mode.
-- The two edges are now connected with a new edge.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Revision History:
--
-- v 1.01 Added an override to define the number of connected edge segements.
--
-- v 1.02 Replaced the Close button with a Help button. Use the X button to 
-- Close the Floater.
--
-- v 1.03 Now lets you override the Pinch and Slide values as well.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
(
-- Globals

global vertexAndEdgeConnector
global vertexAndEdgeConnectorDefaults
global vertexAndEdgeConnectorUI

global vAECCloseOpenUI

global vAECDo
global vAECApply
global vAECHelp
global vAECLoadDef
global vAECSaveDef

global vAECDefineUI
global vAECRollout
global vAECFloater

-- Includes

include "$scripts\SoulburnScripts\lib\sLib.ms"

-- Variables

vAECDialogValue = true
vAECEdgeOverrideValue = false
vAECEdgeOverrideEdgeSegmentsValue = 1
vAECEdgeOverrideEdgePinchValue = 0 
vAECEdgeOverrideEdgeSlideValue = 0
vAECPosValue = [400,400]

-- Functions

fn vertexAndEdgeConnector vAECDialog vAECEdgeOverride vAECEdgeOverrideEdgeSegments vAECEdgeOverrideEdgePinch vAECEdgeOverrideEdgeSlide = 
	(
	undo "vertexAndEdgeConnector" on
		(	
		if getCommandPanelTaskMode() == #modify then
			(
			if (classof (modPanel.getCurrentObject()) == Editable_Poly) then
				(
				if subobjectLevel == 1 then
					(
					if vAECDialog == true then $.EditablePoly.PopupDialog #ConnectVertices
					else $.EditablePoly.ConnectVertices ()
					)
				else if subobjectLevel == 2 then
					(
					oldEdgeSegments = $.connectEdgeSegments
					oldEdgePinch = $.connectEdgePinch
					oldEdgeSlide = $.connectEdgeSlide
					if vAECEdgeOverride == true then 
						(
						$.connectEdgeSegments = vAECEdgeOverrideEdgeSegments
						$.connectEdgePinch = vAECEdgeOverrideEdgePinch
						$.connectEdgeSlide = vAECEdgeOverrideEdgeSlide
						)
					if vAECDialog == true then $.EditablePoly.PopupDialog #ConnectEdges
					else 
						(
						$.EditablePoly.ConnectEdges ()
						$.connectEdgeSegments = oldEdgeSegments
						$.connectEdgePinch = oldEdgePinch
						$.connectEdgeSlide = oldEdgeSlide
						)
					)
				)
			else if (classof (modPanel.getCurrentObject()) == Edit_Poly) then
				(
				currentModIndex = (modPanel.getModifierIndex $ (modPanel.getCurrentObject()))
				if subobjectLevel == 1 then
					(
					if vAECDialog == true then $.modifiers[currentModIndex].PopupDialog #ConnectVertices
					else $.modifiers[currentModIndex].ButtonOp #ConnectVertices
					)
				else if subobjectLevel == 2 then
					(
					oldEdgeSegments = $.modifiers[currentModIndex].connectEdgeSegments
					oldEdgePinch = $.modifiers[currentModIndex].connectEdgePinch
					oldEdgeSlide = $.modifiers[currentModIndex].connectEdgeSlide
					if vAECEdgeOverride == true then 
						(
						$.modifiers[currentModIndex].connectEdgeSegments = vAECEdgeOverrideEdgeSegments
						$.modifiers[currentModIndex].connectEdgePinch = vAECEdgeOverrideEdgePinch
						$.modifiers[currentModIndex].connectEdgeSlide = vAECEdgeOverrideEdgeSlide
						)
					if vAECDialog == true then $.modifiers[currentModIndex].PopupDialog #ConnectEdges
					else 
						(
						$.modifiers[currentModIndex].ButtonOp #ConnectEdges
						$.modifiers[currentModIndex].connectEdgeSegments = oldEdgeSegments
						$.modifiers[currentModIndex].connectEdgePinch = oldEdgePinch
						$.modifiers[currentModIndex].connectEdgeSlide = oldEdgeSlide
						)
					)
				)
			)
		)
	)
	
fn vertexAndEdgeConnectorDefaults = 
	(
	vAECLoadDef()
	vertexAndEdgeConnector vAECDialogValue vAECEdgeOverrideValue vAECEdgeOverrideEdgeSegmentsValue vAECEdgeOverrideEdgePinchValue vAECEdgeOverrideEdgeSlideValue
	)
	
fn vertexAndEdgeConnectorUI = 
	(
	vAECLoadDef()
	vAECCloseOpenUI vAECPosValue
	)

fn vAECCloseOpenUI pos = 
	(
	if vAECFloater != undefined then CloseRolloutFloater vAECFloater
	vAECDefineUI()
	vAECFloater = newRolloutFloater "vertexAndEdgeConnector v1.03" 310 131 pos.x pos.y
	addRollout vAECRollout vAECFloater
	)

fn vAECDo = 
	(
	vertexAndEdgeConnector vAECDialogValue vAECEdgeOverrideValue vAECEdgeOverrideEdgeSegmentsValue vAECEdgeOverrideEdgePinchValue vAECEdgeOverrideEdgeSlideValue
	if vAECFloater != undefined then CloseRolloutFloater vAECFloater
	)

fn vAECApply = 
	(
	vertexAndEdgeConnector vAECDialogValue vAECEdgeOverrideValue vAECEdgeOverrideEdgeSegmentsValue vAECEdgeOverrideEdgePinchValue vAECEdgeOverrideEdgeSlideValue
	)
	
fn vAECHelp = 
	(
	sLibSSPrintHelp "vertexAndEdgeConnector"
	)
	
fn vAECLoadDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	vAECInputFilename = presetDir + "vertexAndEdgeConnector.ini"
	if (sLibFileExist vAECInputFilename == true) then
		(
		vAECDialogValue = execute (getINISetting vAECInputFilename "vertexAndEdgeConnector" "vAECDialogValue")
		vAECEdgeOverrideValue = execute (getINISetting vAECInputFilename "vertexAndEdgeConnector" "vAECEdgeOverrideValue")
		vAECEdgeOverrideEdgeSegmentsValue = execute (getINISetting vAECInputFilename "vertexAndEdgeConnector" "vAECEdgeOverrideEdgeSegmentsValue")
		vAECEdgeOverrideEdgePinchValue = execute (getINISetting vAECInputFilename "vertexAndEdgeConnector" "vAECEdgeOverrideEdgePinchValue")
		vAECEdgeOverrideEdgeSlideValue = execute (getINISetting vAECInputFilename "vertexAndEdgeConnector" "vAECEdgeOverrideEdgeSlideValue")
		vAECPosValue = execute (getINISetting vAECInputFilename "vertexAndEdgeConnector" "vAECPosValue")
		
		if vAECDialogValue == OK then vAECDialogValue = true
		if vAECEdgeOverrideValue == OK then vAECEdgeOverrideValue = false
		if vAECEdgeOverrideEdgeSegmentsValue == OK then vAECEdgeOverrideEdgeSegmentsValue = 1
		if vAECEdgeOverrideEdgePinchValue == OK then vAECEdgeOverrideEdgePinchValue = 0
		if vAECEdgeOverrideEdgeSlideValue == OK then vAECEdgeOverrideEdgeSlideValue = 0
		if vAECPosValue == OK then vAECPosValue = [400,400]
		)
	else
		(
		vAECDialogValue = true
		vAECEdgeOverrideValue = false
		vAECEdgeOverrideEdgeSegmentsValue = 1
		vAECEdgeOverrideEdgePinchValue = 0
		vAECEdgeOverrideEdgeSlideValue = 0
		vAECPosValue = [400,400]
		)
	)
	
fn vAECSaveDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	if (getDirectories presetDir).count == 0 then makeDir presetDir
	vAECOutputFilename = presetDir + "vertexAndEdgeConnector.ini"
	if (sLibFileExist vAECOutputFilename == true) then deleteFile vAECOutputFilename
	setINISetting vAECOutputFilename "vertexAndEdgeConnector" "vAECDialogValue" (vAECDialogValue as string)
	setINISetting vAECOutputFilename "vertexAndEdgeConnector" "vAECEdgeOverrideValue" (vAECEdgeOverrideValue as string)
	setINISetting vAECOutputFilename "vertexAndEdgeConnector" "vAECEdgeOverrideEdgeSegmentsValue" (vAECEdgeOverrideEdgeSegmentsValue as string)
	setINISetting vAECOutputFilename "vertexAndEdgeConnector" "vAECEdgeOverrideEdgePinchValue" (vAECEdgeOverrideEdgePinchValue as string)
	setINISetting vAECOutputFilename "vertexAndEdgeConnector" "vAECEdgeOverrideEdgeSlideValue" (vAECEdgeOverrideEdgeSlideValue as string)
	setINISetting vAECOutputFilename "vertexAndEdgeConnector" "vAECPosValue" (vAECFloater.pos as string)
	)

-- UI

fn vAECDefineUI = 
	(
	rollout vAECRollout "vertexAndEdgeConnector"
		(
		checkbox vAECDialogCheckbox "Bring Up Connect Dialog?" checked:vAECDialogValue align:#center
		checkbox vAECEdgeOverrideCheckbox "Override Parameters?" checked:vAECEdgeOverrideValue align:#center
		spinner vAECEdgeOverrideEdgeSegmentsSpinner "Segs:" range:[1,999999,vAECEdgeOverrideEdgeSegmentsValue] fieldWidth:40 type:#integer align:#left across:3
		spinner vAECEdgeOverrideEdgePinchSpinner "Pinch:" range:[0,100,vAECEdgeOverrideEdgePinchValue] fieldWidth:40 type:#integer align:#center
		spinner vAECEdgeOverrideEdgeSlideSpinner "Slide:" range:[0,99999,vAECEdgeOverrideEdgeSlideValue] fieldWidth:40 type:#integer align:#right

		on vAECDialogCheckbox changed state do vAECDialogValue = state
		on vAECEdgeOverrideCheckbox changed state do 
			(
			vAECEdgeOverrideValue = state
			vAECEdgeOverrideEdgeSegmentsSpinner.enabled = vAECEdgeOverrideValue
			vAECEdgeOverrideEdgePinchSpinner.enabled = vAECEdgeOverrideValue
			vAECEdgeOverrideEdgeSlideSpinner.enabled = vAECEdgeOverrideValue
			)
		on vAECEdgeOverrideEdgeSegmentsSpinner changed val do vAECEdgeOverrideEdgeSegmentsValue = val
		on vAECEdgeOverrideEdgePinchSpinner changed val do vAECEdgeOverrideEdgePinchValue = val
		on vAECEdgeOverrideEdgeSlideSpinner changed val do vAECEdgeOverrideEdgeSlideValue = val

		button vAECDoButton "Do" width:70 toolTip:"Do It and Close UI" pos:[5,74]
		on vAECDoButton pressed do vAECDo()
		button vAECApplyButton "Apply" width:70 toolTip:"Do It and Keep UI Open" pos:[77,74]
		on vAECApplyButton pressed do vAECApply()
		button vAECHelpButton "Help" width:70 toolTip:"Help" pos:[149,74]
		on vAECHelpButton pressed do vAECHelp()
		button vAECSaveDefButton "SaveDef" width:70 toolTip:"Save Current Settings as Default" pos:[221,74]
		on vAECSaveDefButton pressed do vAECSaveDef()
		
		on vAECRollout open do 
			(
			vAECEdgeOverrideEdgeSegmentsSpinner.enabled = vAECEdgeOverrideValue
			vAECEdgeOverrideEdgePinchSpinner.enabled = vAECEdgeOverrideValue
			vAECEdgeOverrideEdgeSlideSpinner.enabled = vAECEdgeOverrideValue
			)
		)
	)
)
-------------------------------------------------------------------------------