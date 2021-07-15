-------------------------------------------------------------------------------
-- objectDetacher.ms
-- By Neil Blevins (info@neilblevins.com)
-- v 1.14
-- Created On: 11/06/05
-- Modified On: 05/02/15
-- tested using Max 2014
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Required Files:
-- sLib.ms
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Description:
-- Takes selected objects (meshs, polys or splines) and seperates all their 
-- elements into seperate objects. Thanks To Alex McLeod for some of the 
-- code this script is based on.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Tutorial:
-- Select 2 objects. Use the attachSelectedObjects script to attach them 
-- together (part of the soulburn scripts). Run the UI version of the script. 
-- Hit Do. Now your object is back to being 2 separate objects.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Revision History:
--
-- v 1.01 Fixed a bug that would cause the modify panel to flash.
--
-- v 1.02 Added some new code to more cleanly open and close the UI.
--
-- v 1.03 Added code to properly remove a useless node that was a byproduct of 
-- the detach.
--
-- v 1.04 Fixed a bug where it wouldn't detect some types of shapes. Added
-- the ability to retain the wirecolor of the original object. Added ability to 
-- select all the resulting objects.
--
-- v 1.05 Added a fix to properly deselect objects.
--
-- v 1.06 Replaced the Close button with a Help button. Use the X button to 
-- Close the Floater.
--
-- v 1.07 Gives an error message when trying to work on an object it can't affect.
--
-- v 1.08 Retains the same layer info when detaching.
--
-- v 1.09 Added a count-up in the prompt area so you see how many objects
-- the script has detached at a given point. Cleaned up the code a bunch, and 
-- fixed a bug which caused the script to sometimes not select the correct
-- detached objects.
--
-- v 1.10 Added ability to turn off undo to fix a max memory issue.
--
-- v 1.11 Fixed a bug that caused the presets to not be saved properly.
--
-- v 1.12 Added ability to adjust the placement of the pivot.
--
-- v 1.13 Moved some controls around.
--
-- v 1.14 Added ability to place the final pivot at the origin.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Known Issues:
-- Sometimes when executing this script (especially if it's on a large 
-- number of objects) your copy of max will seem to hang. In most cases, 
-- max is actually busy detaching, and you should leave the script 
-- running for some reasonable amount of time to be sure. Unfortunately, 
-- I can't seem to find a way in script to notify the user if max is 
-- actual hung or just appears to be hung. if I ever find a good way, 
-- I'll add the functionality to the script.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
(
-- Globals

global objectDetacher
global objectDetacherDefaults
global objectDetacherUI

global oDTCloseOpenUI

global oDTWarning
global oDTDetachSelection
global oDTGeometry
global oDTSpline

global oDTDo
global oDTApply
global oDTHelp
global oDTLoadDef
global oDTSaveDef

global oDTDefineUI
global oDTRollout
global oDTFloater

-- Includes

include "$scripts\SoulburnScripts\lib\sLib.ms"

-- Variables

global oDTDetachedObjects

oDTShowWarningValue = false
oDTDeleteOriginalValue = true
oDTKeepWireColorValue = true
oDTSelectResultValue = true
oDTUndoOnValue = true
oDTCenterPivotValue = true
oDTPivotPlacementValue = 1
oDTPosValue = [400,400]

-- Functions

fn objectDetacher oDTShowWarning oDTDeleteOriginal oDTKeepWireColor oDTSelectResult oDTUndoOn oDTCenterPivot oDTPivotPlacement = 
	(
	if oDTUndoOn == true then
		(
		undo "objectDetacher" on 
			(
			oDTWarning oDTShowWarning oDTDeleteOriginal oDTKeepWireColor oDTSelectResult oDTCenterPivot oDTPivotPlacement
			)
		)
	else oDTWarning oDTShowWarning oDTDeleteOriginal oDTKeepWireColor oDTSelectResult oDTCenterPivot oDTPivotPlacement
	)
	
fn objectDetacherDefaults = 
	(
	oDTLoadDef()
	objectDetacher oDTShowWarningValue oDTDeleteOriginalValue oDTKeepWireColorValue oDTSelectResultValue oDTUndoOnValue oDTCenterPivotValue oDTPivotPlacementValue
	)

fn objectDetacherUI = 
	(
	oDTLoadDef()
	oDTCloseOpenUI oDTPosValue
	)

fn oDTCloseOpenUI pos = 
	(
	if oDTFloater != undefined then CloseRolloutFloater oDTFloater
	oDTDefineUI()
	oDTFloater = newRolloutFloater "objectDetacher v1.14" 187 214 pos.x pos.y
	addRollout oDTRollout oDTFloater
	)

fn oDTWarning oDTShowWarning oDTDeleteOriginal oDTKeepWireColor oDTSelectResult oDTCenterPivot oDTPivotPlacement = 
	(
	if oDTShowWarning == true then
		(
		if (queryBox "Detach Selected Objects?" title:"objectDetacher") == true then oDTDetachSelection oDTDeleteOriginal oDTKeepWireColor oDTSelectResult oDTCenterPivot oDTPivotPlacement
		)
	else oDTDetachSelection oDTDeleteOriginal oDTKeepWireColor oDTSelectResult oDTCenterPivot oDTPivotPlacement
	)
	
fn oDTDetachSelection oDTDeleteOriginal oDTKeepWireColor oDTSelectResult oDTCenterPivot oDTPivotPlacement = 
	(
	objs = for i in selection collect i
	if objs.count < 1 then MessageBox "Please select an object." title:"objectDetacher"
	else
		(
		error = false
		oDTDetachedObjects = #()
		for i in objs do
			(
			if classof i == Editable_mesh or classof i == Editable_Poly then oDTGeometry i oDTDeleteOriginal oDTKeepWireColor oDTCenterPivot oDTPivotPlacement
			else if superclassof i == Shape then oDTSpline i oDTDeleteOriginal oDTKeepWireColor oDTCenterPivot oDTPivotPlacement
			else error = true
			)
		if oDTDetachedObjects.count > 0 then
			(
			if oDTSelectResult == true then (select oDTDetachedObjects;replacePrompt(""))
			else deselect selection
			oDTDetachedObjects = #()
			)
		if error == true then MessageBox "At least one of your objects could not be affected by this script. Please convert to an Editable Mesh or Poly." title:"objectDetacher"
		)
	)

fn oDTGeometry obj deleteOriginal keepWireColor CenterPivot PivotPlacement = 
	(
	disableSceneRedraw()
	try
		(
		if keepWireColor == true then MyColor = obj.wirecolor
		newObj = copy obj
		doMesh = false
		if classof newObj == Editable_mesh then doMesh = true
		convertTo newObj (Editable_Poly)
		i = 1
		while newObj.getnumfaces() != 0 do
			(
			-- prep
			if getCommandPanelTaskMode() == #modify then max create mode
			newDetachedObjName = obj.name + "_Detached" + (sLibPadValue i 2)
			
			-- do detach
			newObj.EditablePoly.SetSelection #Face #{1}
			newObj.selectElement()
			facesToDetach = polyop.getFaceSelection newObj
			polyop.detachFaces newObj facesToDetach asNode:true delete:true name:newDetachedObjName
			
			-- set new poly object properties
			newDetachedObj = getnodebyname newDetachedObjName
			sLibCopyAndPasteLayerFromNodeToNode obj newDetachedObj
			if keepWireColor == true then newDetachedObj.wirecolor = MyColor else newDetachedObj.wirecolor = (color (random 0 255) (random 0 255) (random 0 255))
			if doMesh == true then convertTo newDetachedObj (Editable_Mesh)
			replacePrompt("Objects Detached: " + (i as string))
			i += 1
			append oDTDetachedObjects newDetachedObj
			if centerPivot == true then 
				(
				if pivotPlacement == 1 then newDetachedObj.pivot = [(newDetachedObj.max.x+newDetachedObj.min.x)/2, (newDetachedObj.max.y+newDetachedObj.min.y)/2, (newDetachedObj.max.z+newDetachedObj.min.z)/2]
				else if pivotPlacement == 2 then newDetachedObj.pivot = [(newDetachedObj.max.x+newDetachedObj.min.x)/2, (newDetachedObj.max.y+newDetachedObj.min.y)/2, newDetachedObj.min.z]
				else if pivotPlacement == 3 then newDetachedObj.pivot = [0,0,0]
				)
			)
		delete newObj
		if deleteOriginal == true then delete obj
		)
	catch (MessageBox "An error has occured. You may want to undo." title:"objectDetacher")
	enableSceneRedraw()
	completeRedraw()
	)

fn oDTSpline obj deleteOriginal keepWireColor CenterPivot PivotPlacement = 
	(
	disableSceneRedraw()
	try
		(
		numOfItems = numsplines obj
		if numOfItems > 1 then
			(
			if keepWireColor == true then MyColor = obj.wirecolor
			for i = 1 to numOfItems do
				(
				-- prep
				newObjName = obj.name + "_Detached" + (sLibPadValue i 2)
				
				-- do detach
				newDetachedObj = copy obj
				select newDetachedObj
				max modify mode
				subobjectLevel = 3
				setsplineselection newDetachedObj ((#{1..numOfItems}-#{i}) as array)
				-- the command below deletes the selected splines
				actionMan.executeAction 0 "40020"
				subobjectLevel = 0
				
				-- set new spline properties
				newDetachedObj.name = newObjName
				sLibCopyAndPasteLayerFromNodeToNode obj newDetachedObj
				if keepWireColor == true then newDetachedObj.wirecolor = MyColor
				replacePrompt("Objects Detached: " + (i as string))
				append oDTDetachedObjects newDetachedObj
				if centerPivot == true then 
					(
					if pivotPlacement == 1 then newDetachedObj.pivot = [(newDetachedObj.max.x+newDetachedObj.min.x)/2, (newDetachedObj.max.y+newDetachedObj.min.y)/2, (newDetachedObj.max.z+newDetachedObj.min.z)/2]
					else if pivotPlacement == 2 then newDetachedObj.pivot = [(newDetachedObj.max.x+newDetachedObj.min.x)/2, (newDetachedObj.max.y+newDetachedObj.min.y)/2, newDetachedObj.min.z]
					else if pivotPlacement == 3 then newDetachedObj.pivot = [0,0,0]
					)
				)
			if deleteOriginal == true then delete obj
			)
		)
	catch (MessageBox "An error has occured. You may want to undo." title:"objectDetacher")
	enableSceneRedraw()
	completeRedraw()
	)
	
fn oDTDo = 
	(
	objectDetacher oDTShowWarningValue oDTDeleteOriginalValue oDTKeepWireColorValue oDTSelectResultValue oDTUndoOnValue oDTCenterPivotValue oDTPivotPlacementValue
	if oDTFloater != undefined then CloseRolloutFloater oDTFloater
	)

fn oDTApply = 
	(
	objectDetacher oDTShowWarningValue oDTDeleteOriginalValue oDTKeepWireColorValue oDTSelectResultValue oDTUndoOnValue oDTCenterPivotValue oDTPivotPlacementValue
	)
	
fn oDTHelp = 
	(
	sLibSSPrintHelp "objectDetacher"
	)
	
fn oDTLoadDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	oDTInputFilename = presetDir + "objectDetacher.ini"
	if (sLibFileExist oDTInputFilename == true) then
		(
		oDTShowWarningValue = execute (getINISetting oDTInputFilename "objectDetacher" "oDTShowWarningValue")
		oDTDeleteOriginalValue = execute (getINISetting oDTInputFilename "objectDetacher" "oDTDeleteOriginalValue")
		oDTKeepWireColorValue = execute (getINISetting oDTInputFilename "objectDetacher" "oDTKeepWireColorValue")
		oDTSelectResultValue = execute (getINISetting oDTInputFilename "objectDetacher" "oDTSelectResultValue")
		oDTUndoOnValue = execute (getINISetting oDTInputFilename "objectDetacher" "oDTUndoOnValue")
		oDTCenterPivotValue = execute (getINISetting oDTInputFilename "objectDetacher" "oDTCenterPivotValue")
		oDTPivotPlacementValue = execute (getINISetting oDTInputFilename "objectDetacher" "oDTPivotPlacementValue")
		oDTPosValue = execute (getINISetting oDTInputFilename "objectDetacher" "oDTPosValue")
		
		if oDTShowWarningValue == OK then oDTShowWarningValue = false
		if oDTDeleteOriginalValue == OK then oDTDeleteOriginalValue = true
		if oDTKeepWireColorValue == OK then oDTKeepWireColorValue = true
		if oDTSelectResultValue == OK then oDTSelectResultValue = true
		if oDTUndoOnValue == OK then oDTUndoOnValue = true
		if oDTCenterPivotValue == OK then oDTCenterPivotValue = true
		if oDTPivotPlacementValue == OK then oDTPivotPlacementValue = 1
		if oDTPosValue == OK then oDTPosValue = [400,400]
		)
	else
		(
		oDTShowWarningValue = false
		oDTDeleteOriginalValue = true
		oDTKeepWireColorValue = true
		oDTSelectResultValue = true
		oDTUndoOnValue = true
		oDTCenterPivotValue = true
		oDTPivotPlacementValue = 1
		oDTPosValue = [400,400]
		)
	)
	
fn oDTSaveDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	if (getDirectories presetDir).count == 0 then makeDir presetDir
	oDTOutputFilename = presetDir + "objectDetacher.ini"
	if (sLibFileExist oDTOutputFilename == true) then deleteFile oDTOutputFilename
	setINISetting oDTOutputFilename "objectDetacher" "oDTShowWarningValue" (oDTShowWarningValue as string)
	setINISetting oDTOutputFilename "objectDetacher" "oDTDeleteOriginalValue" (oDTDeleteOriginalValue as string)
	setINISetting oDTOutputFilename "objectDetacher" "oDTKeepWireColorValue" (oDTKeepWireColorValue as string)
	setINISetting oDTOutputFilename "objectDetacher" "oDTSelectResultValue" (oDTSelectResultValue as string)
	setINISetting oDTOutputFilename "objectDetacher" "oDTUndoOnValue" (oDTUndoOnValue as string)
	setINISetting oDTOutputFilename "objectDetacher" "oDTCenterPivotValue" (oDTCenterPivotValue as string)
	setINISetting oDTOutputFilename "objectDetacher" "oDTPivotPlacementValue" (oDTPivotPlacementValue as string)
	setINISetting oDTOutputFilename "objectDetacher" "oDTPosValue" (oDTFloater.pos as string)
	)

-- UI

fn oDTDefineUI = 
	(
	rollout oDTRollout "objectDetacher"
		(
		checkbox oDTKeepWireColorCheckbox "Keep Wireframe Color?" checked:oDTKeepWireColorValue align:#left
		on oDTKeepWireColorCheckbox changed state do oDTKeepWireColorValue = state
		
		checkbox oDTSelectResultCheckbox "Select Result?" checked:oDTSelectResultValue align:#left
		on oDTSelectResultCheckbox changed state do oDTSelectResultValue = state

		checkbox oDTShowWarningCheckbox "Show Warning?" checked:oDTShowWarningValue align:#left
		on oDTShowWarningCheckbox changed state do oDTShowWarningValue = state
		
		checkbox oDTUndoOnCheckbox "Undo On?" checked:oDTUndoOnValue align:#left
		on oDTUndoOnCheckbox changed state do oDTUndoOnValue = state
		
		checkbox oDTDeleteOriginalCheckbox "Delete Original Objects?" checked:oDTDeleteOriginalValue align:#left
		on oDTDeleteOriginalCheckbox changed state do oDTDeleteOriginalValue = state

		checkbox oDTCenterPivotCheckbox "Align Pivot?" checked:oDTCenterPivotValue align:#left across:2
		on oDTCenterPivotCheckbox changed state do oDTCenterPivotValue = state
		dropdownlist oDTPivotPlacementDropdown "" items:#("Center", "Bottom Center", "Origin") selection:oDTPivotPlacementValue width:70 align:#right offset:[0,-2]
		on oDTPivotPlacementDropdown selected i do oDTPivotPlacementValue = i

		button oDTDoButton "Do" width:70 toolTip:"Do It and Close UI" pos:[15,133]
		on oDTDoButton pressed do oDTDo()
		button oDTApplyButton "Apply" width:70 toolTip:"Do It and Keep UI Open" pos:[87,133]
		on oDTApplyButton pressed do oDTApply()
		button oDTHelpButton "Help" width:70 toolTip:"Help" pos:[15,157]
		on oDTHelpButton pressed do oDTHelp()
		button oDTSaveDefButton "SaveDef" width:70 toolTip:"Save Current Settings as Default" pos:[87,157]
		on oDTSaveDefButton pressed do oDTSaveDef()
		)
	)
)
-------------------------------------------------------------------------------