-------------------------------------------------------------------------------
-- thinFaceSelector.ms
-- By Neil Blevins (info@neilblevins.com)
-- v 1.00
-- Created On: 03/03/09
-- Modified On: 03/03/09
-- tested using Max 2009
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Required Files:
-- sLib.ms
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Description:
-- Find and selects faces that are really tall and thin. Good for finding thin
-- faces in a complex mesh, faces that may be best to subdivide to make all your
-- faces more square.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Tutorial:
-- Select an Editable Poly object. Run the UI version of the script. Hit Do. 
-- It will select all the thin faces based on the threshold. As the threshold
-- gets closer to 1, faces that are more square are selected. As the threshold 
-- gets further from 1, only the skinniest faces get selected.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
(
-- Globals

global thinFaceSelector
global thinFaceSelectorDefaults
global thinFaceSelectorUI

global tFSCloseOpenUI

global tFSDo
global tFSApply
global tFSHelp
global tFSLoadDef
global tFSSaveDef

global tFSDefineUI
global tFSRollout
global tFSFloater

-- Includes

include "$scripts\SoulburnScripts\lib\sLib.ms"

-- Variables

tFSModeValue = 1
tFSThresholdValue = 1.8
tFSPosValue = [400,400]

-- Functions

fn thinFaceSelector tFSMode tFSThreshold = 
	(
	undo "thinFaceSelector" on
		(
		if selection.count != 0 then
			(
			obj = selection[1]
			if (classof obj.baseobject) == Editable_Poly then
				(
				if getCommandPanelTaskMode() != #modify then max modify mode
				subobjectLevel = 0
				numfaces = polyop.getNumFaces obj
				myfaces = #()
				if tFSMode == 1 then myfaces = for f = 1 to numfaces collect f else myfaces = getfaceselection obj
				finalFaces = #()
				if myfaces != 0 then
					(
					-- reset xform on object
					newObj = copy obj
					convertTo newObj (Editable_Poly)
					sLibResetXForm newObj
					convertTo newObj (Editable_Poly)

					-- check faces
					for i in myfaces do
						(
						if (polyop.getFaceDeg newObj i) == 4 then
							(
							area = polyop.getFaceArea newObj  i
							edges = polyop.getFaceEdges newObj  i
							edgeLengthArray = #()
							for e in edges do
								(
								verts = polyop.getEdgeVerts newObj  e
								edgelength = distance (polyop.getvert newObj verts[1]) (polyop.getvert newObj verts[2])
								append edgeLengthArray edgelength
								)
							value = (((edgeLengthArray[1] + edgeLengthArray[2] + edgeLengthArray[3] + edgeLengthArray[4])/4)^2)/area
							if value > tFSThreshold then append finalFaces i
							)
						)
					)
				if finalFaces.count != 0 then polyop.setFaceSelection obj finalFaces
				delete newObj
				select obj
				subobjectLevel = 4
				)
			else MessageBox "Please select an Editable Poly object" title:"thinFaceSelector"
			)
		)
	)
	
fn thinFaceSelectorDefaults = 
	(
	tFSLoadDef()
	thinFaceSelector tFSModeValue tFSThresholdValue
	)
	
fn thinFaceSelectorUI = 
	(
	tFSLoadDef()
	tFSCloseOpenUI tFSPosValue
	)

fn tFSCloseOpenUI pos = 
	(
	if tFSFloater != undefined then CloseRolloutFloater tFSFloater
	tFSDefineUI()
	tFSFloater = newRolloutFloater "thinFaceSelector v1.00" 310 91 pos.x pos.y
	addRollout tFSRollout tFSFloater
	)
	
fn tFSDo = 
	(
	thinFaceSelector tFSModeValue tFSThresholdValue
	if tFSFloater != undefined then CloseRolloutFloater tFSFloater
	)

fn tFSApply = 
	(
	thinFaceSelector tFSModeValue tFSThresholdValue
	)
	
fn tFSHelp = 
	(
	sLibSSPrintHelp "thinFaceSelector"
	)
	
fn tFSLoadDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	tFSInputFilename = presetDir + "thinFaceSelector.ini"
	if (sLibFileExist tFSInputFilename == true) then
		(
		tFSModeValue = execute (getINISetting tFSInputFilename "thinFaceSelector" "tFSModeValue")
		tFSThresholdValue = execute (getINISetting tFSInputFilename "thinFaceSelector" "tFSThresholdValue")
		tFSPosValue = execute (getINISetting tFSInputFilename "thinFaceSelector" "tFSPosValue")
		
		if tFSModeValue == OK then tFSModeValue = 1
		if tFSThresholdValue == OK then tFSThresholdValue = 1.8
		if tFSPosValue == OK then tFSPosValue = [400,400]
		)
	else
		(
		tFSModeValue = 1
		tFSThresholdValue = 1.8
		tFSPosValue = [400,400]
		)
	)
	
fn tFSSaveDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	if (getDirectories presetDir).count == 0 then makeDir presetDir
	tFSOutputFilename = presetDir + "thinFaceSelector.ini"
	if (sLibFileExist tFSOutputFilename == true) then deleteFile tFSOutputFilename
	setINISetting tFSOutputFilename "thinFaceSelector" "tFSModeValue" (tFSModeValue as string)
	setINISetting tFSOutputFilename "thinFaceSelector" "tFSThresholdValue" (tFSThresholdValue as string)
	setINISetting tFSOutputFilename "thinFaceSelector" "tFSPosValue" (tFSFloater.pos as string)
	)

-- UI

fn tFSDefineUI = 
	(
	rollout tFSRollout "thinFaceSelector"
		(
		label label1 "Mode:" pos:[17,10]
		dropdownlist tFSModeDropdown "" items:#("Entire Object", "Selected Faces") selection:tFSModeValue pos:[52,7] width:110
		spinner tFSThresholdSpinner "Threshold: " range:[1,9999999,tFSThresholdValue] fieldWidth:45 type:#float pos:[167,10]

		on tFSModeDropdown selected i do tFSModeValue = i
		on tFSThresholdSpinner changed val do tFSThresholdValue = val

		button tFSDoButton "Do" width:70 toolTip:"Do It and Close UI" pos:[5,34]
		on tFSDoButton pressed do tFSDo()
		button tFSApplyButton "Apply" width:70 toolTip:"Do It and Keep UI Open" pos:[77,34]
		on tFSApplyButton pressed do tFSApply()
		button tFSHelpButton "Help" width:70 toolTip:"Help" pos:[149,34]
		on tFSHelpButton pressed do tFSHelp()
		button tFSSaveDefButton "SaveDef" width:70 toolTip:"Save Current Settings as Default" pos:[221,34]
		on tFSSaveDefButton pressed do tFSSaveDef()
		)
	)
)
-------------------------------------------------------------------------------