-------------------------------------------------------------------------------
-- splineKnotManager.ms
-- By Neil Blevins (info@neilblevins.com)
-- v 1.04
-- Created On: 05/23/05
-- Modified On: 04/18/08
-- tested using Max 7.1
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Required Files:
-- sLib.ms
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Description:
-- Takes all selected splines and converts all their knots to a specific knot
-- type such as "Smooth", "Corner", "Bezier" or "Bezier Corner".
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Tutorial:
-- Select a spline. Run the script in UI form. Change Knot Type to smooth. Hit Do.
-- Now every knot in your spline will be set to smooth. Change Knot Type to Corner.
-- Hit Do again. Now all the knots are set to corner.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Revision History:
--
-- v 1.01 Cleaned the code a bit.
--
-- v 1.02 Defined ui as new function.
--
-- v 1.03 Added some new code to more cleanly open and close the UI.
--
-- v 1.04 Replaced the Close button with a Help button. Use the X button to 
-- Close the Floater.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
(
-- Globals

global splineKnotManager
global splineKnotManagerDefaults
global splineKnotManagerUI

global sKMCloseOpenUI

global sKMDo
global sKMApply
global sKMHelp
global sKMLoadDef
global sKMSaveDef

global sKMDefineUI
global sKMRollout
global sKMFloater

-- Includes

include "$scripts\SoulburnScripts\lib\sLib.ms"

-- Variables

sKMKnotTypeValue = 2
sKMConvertToEditableSplineValue = true
sKMPosValue = [400,400]

-- Functions

fn splineKnotManager sKMKnotType sKMConvertToEditableSpline = 
	(
	undo "splineKnotManager" on
		(
		error = false
		for obj in selection do
			(
			if sKMConvertToEditableSpline == true then convertTo obj SplineShape
			if classof obj == SplineShape or classof obj == line then
				(
				ns = numSplines obj
				if ns > 0 then
					(
					for i = 1 to ns do
						(
						nk = numKnots obj i
						if nk > 0 then
							(
							for j = 1 to nk do
								(
								if sKMKnotType == 1 then setKnotType obj i j #smooth
								else if sKMKnotType == 2 then setKnotType obj i j #corner
								else if sKMKnotType == 3 then setKnotType obj i j #bezier
								else if sKMKnotType == 4 then setKnotType obj i j #bezierCorner
								)
							)
						)
					)
				updateShape obj
				)
			else error = true
			)
		if sKMConvertToEditableSpline == false and error == true then MessageBox "At least one object in your selection was not an Editable Spline and cannot be affected by this script. Try checking the \"Automatically Convert Selection To Editable Spline\" checkbox" title:"splineKnotManager"
		)
	)
	
fn splineKnotManagerDefaults = 
	(
	sKMLoadDef()
	splineKnotManager sKMKnotTypeValue sKMConvertToEditableSplineValue
	)
	
fn splineKnotManagerUI = 
	(
	sKMLoadDef()
	sKMCloseOpenUI sKMPosValue
	)

fn sKMCloseOpenUI pos = 
	(
	if sKMFloater != undefined then CloseRolloutFloater sKMFloater
	sKMDefineUI()
	sKMFloater = newRolloutFloater "splineKnotManager v1.04" 310 114 pos.x pos.y
	addRollout sKMRollout sKMFloater
	)

fn sKMDo = 
	(
	splineKnotManager sKMKnotTypeValue sKMConvertToEditableSplineValue
	if sKMFloater != undefined then CloseRolloutFloater sKMFloater
	)

fn sKMApply = 
	(
	splineKnotManager sKMKnotTypeValue sKMConvertToEditableSplineValue
	)
	
fn sKMHelp = 
	(
	sLibSSPrintHelp "splineKnotManager"
	)
	
fn sKMLoadDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	sKMInputFilename = presetDir + "splineKnotManager.ini"
	if (sLibFileExist sKMInputFilename == true) then
		(
		sKMKnotTypeValue = execute (getINISetting sKMInputFilename "splineKnotManager" "sKMKnotTypeValue")
		sKMConvertToEditableSplineValue = execute (getINISetting sKMInputFilename "splineKnotManager" "sKMConvertToEditableSplineValue")
		sKMPosValue = execute (getINISetting sKMInputFilename "splineKnotManager" "sKMPosValue")
		
		if sKMKnotTypeValue == OK then sKMKnotTypeValue = 2
		if sKMConvertToEditableSplineValue == OK then sKMConvertToEditableSplineValue = true
		if sKMPosValue == OK then sKMPosValue = [400,400]
		)
	else
		(
		sKMKnotTypeValue = 2
		sKMConvertToEditableSplineValue = true
		sKMPosValue = [400,400]
		)
	)
	
fn sKMSaveDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	if (getDirectories presetDir).count == 0 then makeDir presetDir
	sKMOutputFilename = presetDir + "splineKnotManager.ini"
	if (sLibFileExist sKMOutputFilename == true) then deleteFile sKMOutputFilename
	setINISetting sKMOutputFilename "splineKnotManager" "sKMKnotTypeValue" (sKMKnotTypeValue as string)
	setINISetting sKMOutputFilename "splineKnotManager" "sKMConvertToEditableSplineValue" (sKMConvertToEditableSplineValue as string)
	setINISetting sKMOutputFilename "splineKnotManager" "sKMPosValue" (sKMFloater.pos as string)
	)

-- UI

fn sKMDefineUI = 
	(
	rollout sKMRollout "splineKnotManager"
		(
		label label1 "Knot Type:" pos:[10,10]
		dropdownlist sKMKnotTypeDropdown "" items:#("Smooth", "Corner", "Bezier", "Bezier Corner") selection:sKMKnotTypeValue pos:[70,7] width:217
		on sKMKnotTypeDropdown selected i do sKMKnotTypeValue = i
		checkbox sKMConvertToEditableSplineCheckbox "Automatically Convert Selection To Editable Spline?" checked:sKMConvertToEditableSplineValue align:#left
		on sKMConvertToEditableSplineCheckbox changed state do sKMConvertToEditableSplineValue = state

		button sKMDoButton "Do" width:70 toolTip:"Do It and Close UI" pos:[5,56]
		on sKMDoButton pressed do sKMDo()
		button sKMApplyButton "Apply" width:70 toolTip:"Do It and Keep UI Open" pos:[77,56]
		on sKMApplyButton pressed do sKMApply()
		button sKMHelpButton "Help" width:70 toolTip:"Help" pos:[149,56]
		on sKMHelpButton pressed do sKMHelp()
		button sKMSaveDefButton "SaveDef" width:70 toolTip:"Save Current Settings as Default" pos:[221,56]
		on sKMSaveDefButton pressed do sKMSaveDef()
		)
	)
)
-------------------------------------------------------------------------------