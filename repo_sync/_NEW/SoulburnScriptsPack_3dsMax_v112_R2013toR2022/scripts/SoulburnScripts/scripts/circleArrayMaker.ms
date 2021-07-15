-------------------------------------------------------------------------------
-- circleArrayMaker.ms
-- By Neil Blevins (info@neilblevins.com)
-- v 1.04
-- Created On: 11/14/07
-- Modified On: 02/05/17
-- tested using Max 2017
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Required Files:
-- sLib.ms
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Description:
-- Similar to array, but always rotates your objects to make a complete circle.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Tutorial:
-- Make a sphere in thew top view. Make a small box on the sphere from the top 
-- view. Change the reference Coordinate System to "pick", then pick the sphere.
-- Turn on "Use Transform Coordinate Center". Now your coordinate system is 
-- centered around the sphere. Open the UI of the script. Choose the Z axis.
-- Hit Apply. Now you have 12 little boxes around your sphere.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Revision History:
--
-- v 1.01 Now works on multiple selections. Still doesn't work too well with
-- groups and heirarchies.
--
-- v 1.02 Replaced the Close button with a Help button. Use the X button to 
-- Close the Floater.
--
-- v 1.03 Now the new objects are placed on the same layer as the original 
-- object.
--
-- v 1.04 Fixed a bug where a rounding error would cause the copies to be
-- rotated an incorrect amount.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
(
-- Globals

global circleArrayMaker
global circleArrayMakerDefaults
global circleArrayMakerUI

global cAMCloseOpenUI

global cAMRotateGeometry

global cAMDo
global cAMApply
global cAMHelp
global cAMLoadDef
global cAMSaveDef

global cAMDefineUI
global cAMRollout
global cAMFloater

-- Includes

include "$scripts\SoulburnScripts\lib\sLib.ms"

-- Variables

cAMNumberOfCopiesValue = 12
cAMAxisValue = 3
cAMTypeValue = 2
cAMPosValue = [400,400]

-- Functions

fn circleArrayMaker cAMNumberOfCopies cAMAxis cAMType = 
	(
	undo "circleArrayMaker" on
		(
		if cAMNumberOfCopies >= 2 then
			(
			for obj in selection do
				(
				myangle = (360 as float) / (cAMNumberOfCopies as float)
				for i = 1 to (cAMNumberOfCopies - 1) do
					(
					cAMRotateGeometry cAMAxis myangle obj
					if cAMType == 1 then newobj = copy obj
					else if cAMType == 2 then newobj = instance obj
					else if cAMType == 3 then newobj = reference obj
					newobj.wirecolor = obj.wirecolor
					newobj.material = obj.material
					sLibCopyAndPasteLayerFromNodeToNode obj newobj
					)
				cAMRotateGeometry cAMAxis myangle obj
				)
			)
		)
	)
	
fn circleArrayMakerDefaults = 
	(
	cAMLoadDef()
	circleArrayMaker cAMNumberOfCopiesValue cAMAxisValue cAMTypeValue
	)
	
fn circleArrayMakerUI = 
	(
	cAMLoadDef()
	cAMCloseOpenUI cAMPosValue
	)

fn cAMCloseOpenUI pos = 
	(
	if cAMFloater != undefined then CloseRolloutFloater cAMFloater
	cAMDefineUI()
	cAMFloater = newRolloutFloater "circleArrayMaker v1.04" 310 121 pos.x pos.y
	addRollout cAMRollout cAMFloater
	)

fn cAMRotateGeometry Axis Angle Object = 
	(
	if Axis == 1 then 
		(
		xValue = (angleaxis Angle [1,0,0])
		sLibRotateObjByAxis Object xValue
		)
	else if Axis == 2 then 
		(
		yValue = (angleaxis Angle [0,1,0])
		sLibRotateObjByAxis Object yValue
		)
	else if Axis == 3 then 
		(
		zValue = (angleaxis Angle [0,0,1])
		sLibRotateObjByAxis Object zValue
		)
	)

fn cAMDo = 
	(
	circleArrayMaker cAMNumberOfCopiesValue cAMAxisValue cAMTypeValue
	if cAMFloater != undefined then CloseRolloutFloater cAMFloater
	)

fn cAMApply = 
	(
	circleArrayMaker cAMNumberOfCopiesValue cAMAxisValue cAMTypeValue
	)
	
fn cAMHelp = 
	(
	sLibSSPrintHelp "circleArrayMaker"
	)
	
fn cAMLoadDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	cAMInputFilename = presetDir + "circleArrayMaker.ini"
	if (sLibFileExist cAMInputFilename == true) then
		(
		cAMNumberOfCopiesValue = execute (getINISetting cAMInputFilename "circleArrayMaker" "cAMNumberOfCopiesValue")
		cAMAxisValue = execute (getINISetting cAMInputFilename "circleArrayMaker" "cAMAxisValue")
		cAMTypeValue = execute (getINISetting cAMInputFilename "circleArrayMaker" "cAMTypeValue")
		cAMPosValue = execute (getINISetting cAMInputFilename "circleArrayMaker" "cAMPosValue")
		
		if cAMNumberOfCopiesValue == OK then cAMNumberOfCopiesValue = 12
		if cAMAxisValue == OK then cAMAxisValue = 3
		if cAMTypeValue == OK then cAMTypeValue = 2
		if cAMPosValue == OK then cAMPosValue = [400,400]
		)
	else
		(
		cAMNumberOfCopiesValue = 12
		cAMAxisValue = 3
		cAMTypeValue = 2
		cAMPosValue = [400,400]
		)
	)
	
fn cAMSaveDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	if (getDirectories presetDir).count == 0 then makeDir presetDir
	cAMOutputFilename = presetDir + "circleArrayMaker.ini"
	if (sLibFileExist cAMOutputFilename == true) then deleteFile cAMOutputFilename
	setINISetting cAMOutputFilename "circleArrayMaker" "cAMNumberOfCopiesValue" (cAMNumberOfCopiesValue as string)
	setINISetting cAMOutputFilename "circleArrayMaker" "cAMAxisValue" (cAMAxisValue as string)
	setINISetting cAMOutputFilename "circleArrayMaker" "cAMTypeValue" (cAMTypeValue as string)
	setINISetting cAMOutputFilename "circleArrayMaker" "cAMPosValue" (cAMFloater.pos as string)
	)

-- UI

fn cAMDefineUI = 
	(
	rollout cAMRollout "circleArrayMaker"
		(
		spinner cAMNumberOfCopiesSpinner "Number Of Copies: " range:[2,9999999,cAMNumberOfCopiesValue] fieldWidth:50 type:#integer across:3 offset:[70,3]
		on cAMNumberOfCopiesSpinner changed val do cAMNumberOfCopiesValue = val

		label label1 "Axis:" offset:[50,3]
		dropdownlist cAMAxisDropdown "" items:#("X", "Y", "Z") selection:cAMAxisValue width:60 offset:[20,0]
		on cAMAxisDropdown selected i do cAMAxisValue = i

		label label2 "Object Type:" across:2 offset:[10,3]
		dropdownlist cAMTypeDropdown "" items:#("Copy", "Instance", "Reference") selection:cAMTypeValue width:120 offset:[-20,0]
		on cAMTypeDropdown selected i do cAMTypeValue = i

		button cAMDoButton "Do" width:70 toolTip:"Do It and Close UI" pos:[5,64]
		on cAMDoButton pressed do cAMDo()
		button cAMApplyButton "Apply" width:70 toolTip:"Do It and Keep UI Open" pos:[77,64]
		on cAMApplyButton pressed do cAMApply()
		button cAMHelpButton "Help" width:70 toolTip:"Help" pos:[149,64]
		on cAMHelpButton pressed do cAMHelp()
		button cAMSaveDefButton "SaveDef" width:70 toolTip:"Save Current Settings as Default" pos:[221,64]
		on cAMSaveDefButton pressed do cAMSaveDef()
		)
	)
)
-------------------------------------------------------------------------------