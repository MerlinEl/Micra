-------------------------------------------------------------------------------
-- alignViewportToFace.ms
-- By Neil Blevins (info@neilblevins.com)
-- v 1.04
-- Created On: 01/07/07
-- Modified On: 01/16/16
-- tested using Max 2016
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Required Files:
-- sLib.ms
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Description:
-- Aligns the viewport to the selected face. Thanks to Carl-Mikael Lagnecrantz
-- for some code inspiration.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Tutorial:
-- Select an editable poly object, select a face, run the script. Now you
-- have a new view perpendicular to that face.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Revision History:
--
-- v 1.01 Replaced the Close button with a Help button. Use the X button to 
-- Close the Floater.
--
-- v 1.02 I now give the option of facing the face or seeing it from the side.
--
-- v 1.03 Fixed a bug that would cause a crash when the selected object had
-- modifiers.
--
-- v 1.04 Onur Kardelen added some code to allow you to align the camera to
-- multple faces, by taking the average. Thanks Onur!
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
(
-- Globals

global alignViewportToFace
global alignViewportToFaceDefaults
global alignViewportToFaceUI

global aVTFCloseOpenUI

global aVTFDo
global aVTFApply
global aVTFHelp
global aVTFLoadDef
global aVTFSaveDef
global aVTFHelp

global aVTFDefineUI
global aVTFRollout
global aVTFFloater

-- Includes

include "$scripts\SoulburnScripts\lib\sLib.ms"

-- Variables

aVTFCamTypeValue = 1
aVTFDirectionValue = 1
aVTFPosValue = [400,400]

-- Functions

fn alignViewportToFace aVTFcamType aVTFDirection = 
	(
	undo "alignViewportToFace" on
		(
		if selection.count != 1 then (MessageBox "Please select one Object." title:"alignViewportToFace")
		else
			(
			if superclassof $ != GeometryClass then (MessageBox "Please select a piece of Geometry." title:"alignViewportToFace")
			else
				(
				-- get current subobject state
				subObjectState = subobjectLevel
				stackLevel = modPanel.getCurrentObject()
				
				-- copy object
				copyOfObject = snapshot $
				convertToPoly copyOfObject

				-- get selected faces
				selectedFaces = (getfaceselection copyOfObject) as array
				if selectedFaces.count == 1 then
					(
					-- construct ray
					selectedFaceNormal = polyOp.getFaceNormal copyOfObject selectedFaces[1]
					selectedFaceCenter = polyOp.getFaceCenter copyOfObject selectedFaces[1]
					worldUpVector = [0,0,1]
					rightVector = normalize (cross worldUpVector selectedFaceNormal)
					)
				else
					(
					-- Old Error Message
					--MessageBox "Please select one face." title:"alignViewportToFace"
					Normal1=0
					Normal2=0
					Normal3=0
					Center1=0
					Center2=0
					Center3=0
					dnm=1
					for dnm=1 to (selectedFaces.count) do 
						(
						selectedFaceNormall = polyOp.getFaceNormal copyOfObject selectedFaces[dnm]
						selectedFaceCenterr = polyOp.getFaceCenter copyOfObject selectedFaces[dnm]
						Normal1=Normal1+selectedFaceNormall[1]
						Normal2=Normal2+selectedFaceNormall[2]
						Normal3=Normal3+selectedFaceNormall[3]
						Center1=Center1+selectedFaceCenterr[1]
						Center2=Center2+selectedFaceCenterr[2]
						Center3=Center3+selectedFaceCenterr[3]
						)
					Normal1s=0
					Normal2s=0
					Normal3s=0
					Center1s=0
					Center2s=0
					Center3s=0
					Normal1s=Normal1/dnm
					Normal2s=Normal2/dnm
					Normal3s=Normal3/dnm
					Center1s=Center1/dnm
					Center2s=Center2/dnm
					Center3s=Center3/dnm
					selectedFaceNormal = [Normal1s,Normal2s,Normal3s]
					selectedFaceCenter = [Center1s,Center2s,Center3s]
					worldUpVector = [0,0,1]
					rightVector = normalize (cross worldUpVector selectedFaceNormal)					
					)
					
				-- choose direction
				if aVTFDirection == 1 then cameraRay = ray selectedFaceCenter selectedFaceNormal
				else cameraRay = ray selectedFaceCenter rightVector

				-- make camera
				camDistance = (distance (inverse (getViewTM()))[4] cameraRay.pos)
				camPosition = cameraRay.pos + (cameraRay.dir * camDistance)
				aVTFcam = freecamera pos:camPosition orthoProjection:true
				aVTFcam.dir = cameraRay.dir
				aVTFcam.name = uniqueName "Camera_aVTF_"
				viewport.setCamera aVTFcam
				redrawviews()
				if aVTFcamType == 2 then
					(
					viewport.setType #view_iso_user
					delete aVTFcam
					)
				delete copyOfObject
				modPanel.setCurrentObject stackLevel
				subobjectLevel = subObjectState
				)
			)
		)
	)

fn alignViewportToFaceDefaults = 
	(
	aVTFLoadDef()
	alignViewportToFace aVTFCamTypeValue aVTFDirectionValue
	)
	
fn alignViewportToFaceUI = 
	(
	aVTFLoadDef()
	aVTFCloseOpenUI aVTFPosValue
	)

fn aVTFCloseOpenUI pos = 
	(
	if aVTFFloater != undefined then CloseRolloutFloater aVTFFloater
	aVTFDefineUI()
	aVTFFloater = newRolloutFloater "alignViewportToFace v1.04" 310 93 pos.x pos.y
	addRollout aVTFRollout aVTFFloater
	)

fn aVTFDo = 
	(
	alignViewportToFace aVTFCamTypeValue aVTFDirectionValue
	if aVTFFloater != undefined then CloseRolloutFloater aVTFFloater
	)

fn aVTFApply = 
	(
	alignViewportToFace aVTFCamTypeValue aVTFDirectionValue
	)
	
fn aVTFHelp = 
	(
	sLibSSPrintHelp "alignViewportToFace"
	)
	
fn aVTFLoadDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	aVTFInputFilename = presetDir + "alignViewportToFace.ini"
	if (sLibFileExist aVTFInputFilename == true) then
		(
		aVTFCamTypeValue = execute (getINISetting aVTFInputFilename "alignViewportToFace" "aVTFCamTypeValue")
		aVTFDirectionValue = execute (getINISetting aVTFInputFilename "alignViewportToFace" "aVTFDirectionValue")
		aVTFPosValue = execute (getINISetting aVTFInputFilename "alignViewportToFace" "aVTFPosValue")
		
		if aVTFCamTypeValue == OK then aVTFCamTypeValue = 1
		if aVTFDirectionValue == OK then aVTFDirectionValue = 1
		if aVTFPosValue == OK then aVTFPosValue = [400,400]
		)
	else
		(
		aVTFCamTypeValue = 1
		aVTFDirectionValue = 1
		aVTFPosValue = [400,400]
		)
	)
	
fn aVTFSaveDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	if (getDirectories presetDir).count == 0 then makeDir presetDir
	aVTFOutputFilename = presetDir + "alignViewportToFace.ini"
	if (sLibFileExist aVTFOutputFilename == true) then deleteFile aVTFOutputFilename
	setINISetting aVTFOutputFilename "alignViewportToFace" "aVTFCamTypeValue" (aVTFCamTypeValue as string)
	setINISetting aVTFOutputFilename "alignViewportToFace" "aVTFDirectionValue" (aVTFDirectionValue as string)
	setINISetting aVTFOutputFilename "alignViewportToFace" "aVTFPosValue" (aVTFFloater.pos as string)
	)

-- UI

fn aVTFDefineUI = 
	(
	rollout aVTFRollout "alignViewportToFace"
		(
		dropdownlist aVTFCamTypeDropdown "" items:#("Create New Camera", "Create New User View") selection:aVTFCamTypeValue across:2 width:132
		dropdownlist aVTFDirectionDropdown "" items:#("Facing", "Side") selection:aVTFDirectionValue width:132

		on aVTFCamTypeDropdown selected i do aVTFCamTypeValue = i
		on aVTFDirectionDropdown selected i do aVTFDirectionValue = i

		button aVTFDoButton "Do" width:70 toolTip:"Do It and Close UI" pos:[5,35]
		on aVTFDoButton pressed do aVTFDo()
		button aVTFApplyButton "Apply" width:70 toolTip:"Do It and Keep UI Open" pos:[77,35]
		on aVTFApplyButton pressed do aVTFApply()
		button aVTFHelpButton "Help" width:70 toolTip:"Help" pos:[149,35]
		on aVTFHelpButton pressed do aVTFHelp()
		button aVTFSaveDefButton "SaveDef" width:70 toolTip:"Save Current Settings as Default" pos:[221,35]
		on aVTFSaveDefButton pressed do aVTFSaveDef()
		)
	)
)
-------------------------------------------------------------------------------