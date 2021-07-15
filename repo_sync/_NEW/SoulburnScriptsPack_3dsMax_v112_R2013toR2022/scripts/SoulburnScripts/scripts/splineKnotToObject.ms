-------------------------------------------------------------------------------
-- splineKnotToObject.ms
-- By Neil Blevins (info@neilblevins.com)
-- v 1.04
-- Created On: 08/03/05
-- Modified On: 04/18/08
-- tested using Max 8.0
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Required Files:
-- sLib.ms
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Description:
-- Takes all selected splines and places a specified object at their knots.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Tutorial:
-- Select a spline. Run the script in UI form. Hit Do. Spheres will appear at each 
-- knot of your spline.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Revision History:
--
-- v 1.01 Defined ui as new function.
--
-- v 1.02 Added some new code to more cleanly open and close the UI.
--
-- v 1.03 Added ability to instance the objects, and have it use the spline 
-- thickness as the object size.
--
-- v 1.04 Replaced the Close button with a Help button. Use the X button to 
-- Close the Floater.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
(
-- Globals

global splineKnotToObject
global splineKnotToObjectDefaults
global splineKnotToObjectUI

global skTOCloseOpenUI

global sKTODo
global sKTOApply
global sKTOHelp
global sKTOLoadDef
global sKTOSaveDef

global sKTODefineUI
global sKTORollout
global sKTOFloater

-- Includes

include "$scripts\SoulburnScripts\lib\sLib.ms"

-- Variables

sKTOObjTypeValue = 1
sKTOSizeValue = 30
sKTOInstanceValue = true
sKTOSplineThicknessValue = false
sKTOPosValue = [400,400]

-- Functions

fn splineKnotToObject sKTOObjType sKTOSize sKTOInstance sKTOSplineThickness = 
	(
	undo "splineKnotToObject" on
		(
		-- Setup Variables
		error = false
		obj = undefined
		
		-- Start
		for s in selection do
			(
			if classof s == SplineShape or classof s == line then
				(
				-- Define Size
				if sKTOSplineThickness == true then
					(
					if s.baseobject.renderable == true or s.baseobject.DisplayRenderMesh == true then finalSize = s.thickness
					else finalSize = sKTOSize
					)
				else finalSize = sKTOSize
					
				-- Create Object
				if sKTOObjType == 1 then obj = Sphere radius:(finalSize/2) recenter:off
				else if sKTOObjType == 2 then obj = Point size:finalSize Box:on
				else obj = Box lengthsegs:1 widthsegs:1 heightsegs:1 length:finalSize width:finalSize height:finalSize
		
				ns = numSplines s
				if ns > 0 then
					(
					for i = 1 to ns do
						(
						nk = numKnots s i
						if nk > 0 then
							(
							for j = 1 to nk do
								(
								-- Create New Object
								if sKTOInstance == true then newObj = instance obj
								else newObj = copy obj
								
								-- Define Pos
								knotPos = (getKnotPoint s i j)
								
								-- Modify Object Position
								if sKTOObjType == 1 then newObj.pos = knotPos
								else if sKTOObjType == 2 then newObj.pos = knotPos
								else newObj.pos = [knotPos.x,knotPos.y,knotPos.z-(finalSize/2)]
								)
							)
						)
					)
				updateShape s
				delete obj
				)
			else error = true
			)
		if error == true then MessageBox "At least one object in your selection was not an Editable Spline and cannot be affected by this script." title:"splineKnotToObject"
		)
	)
	
fn splineKnotToObjectDefaults = 
	(
	sKTOLoadDef()
	splineKnotToObject sKTOObjTypeValue sKTOSizeValue sKTOInstanceValue sKTOSplineThicknessValue
	)
	
fn splineKnotToObjectUI = 
	(
	sKTOLoadDef()
	sKTOCloseOpenUI sKTOPosValue
	)
	
fn sKTOCloseOpenUI pos = 
	(
	if sKTOFloater != undefined then CloseRolloutFloater sKTOFloater
	sKTODefineUI()
	sKTOFloater = newRolloutFloater "splineKnotToObject v1.04" 310 114 pos.x pos.y
	addRollout sKTORollout sKTOFloater
	)

fn sKTODo = 
	(
	splineKnotToObject sKTOObjTypeValue sKTOSizeValue sKTOInstanceValue sKTOSplineThicknessValue
	if sKTOFloater != undefined then CloseRolloutFloater sKTOFloater
	)

fn sKTOApply = 
	(
	splineKnotToObject sKTOObjTypeValue sKTOSizeValue sKTOInstanceValue sKTOSplineThicknessValue
	)
	
fn sKTOHelp = 
	(
	sLibSSPrintHelp "splineKnotToObject"
	)
	
fn sKTOLoadDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	sKTOInputFilename = presetDir + "splineKnotToObject.ini"
	if (sLibFileExist sKTOInputFilename == true) then
		(
		sKTOObjTypeValue = execute (getINISetting sKTOInputFilename "splineKnotToObject" "sKTOObjTypeValue")
		sKTOSizeValue = execute (getINISetting sKTOInputFilename "splineKnotToObject" "sKTOSizeValue")
		sKTOInstanceValue = execute (getINISetting sKTOInputFilename "splineKnotToObject" "sKTOInstanceValue")
		sKTOSplineThicknessValue = execute (getINISetting sKTOInputFilename "splineKnotToObject" "sKTOSplineThicknessValue")
		sKTOPosValue = execute (getINISetting sKTOInputFilename "splineKnotToObject" "sKTOPosValue")
		
		if sKTOObjTypeValue == OK then sKTOObjTypeValue = 1
		if sKTOSizeValue == OK then sKTOSizeValue = 30
		if sKTOInstanceValue == OK then sKTOInstanceValue = true
		if sKTOSplineThicknessValue == OK then sKTOSplineThicknessValue = false
		if sKTOPosValue == OK then sKTOPosValue = [400,400]
		)
	else
		(
		sKTOObjTypeValue = 1
		sKTOSizeValue = 30
		sKTOInstanceValue = true
		sKTOSplineThicknessValue = false
		sKTOPosValue = [400,400]
		)
	)
	
fn sKTOSaveDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	if (getDirectories presetDir).count == 0 then makeDir presetDir
	sKTOOutputFilename = presetDir + "splineKnotToObject.ini"
	if (sLibFileExist sKTOOutputFilename == true) then deleteFile sKTOOutputFilename
	setINISetting sKTOOutputFilename "splineKnotToObject" "sKTOObjTypeValue" (sKTOObjTypeValue as string)
	setINISetting sKTOOutputFilename "splineKnotToObject" "sKTOSizeValue" (sKTOSizeValue as string)
	setINISetting sKTOOutputFilename "splineKnotToObject" "sKTOInstanceValue" (sKTOInstanceValue as string)
	setINISetting sKTOOutputFilename "splineKnotToObject" "sKTOSplineThicknessValue" (sKTOSplineThicknessValue as string)
	setINISetting sKTOOutputFilename "splineKnotToObject" "sKTOPosValue" (sKTOFloater.pos as string)
	)

-- UI

fn sKTODefineUI = 
	(
	rollout sKTORollout "splineKnotToObject"
		(
		label label1 "Obj Type:" pos:[10,10]
		dropdownlist sKTOObjTypeDropdown "" items:#("Sphere", "Point", "Box") selection:sKTOObjTypeValue pos:[60,7] width:120
		spinner sKTOSizeSpinner "Size: " range:[0,99999999,sKTOSizeValue] fieldWidth:55 type:#float pos:[190,9]
		checkbox sKTOInstanceCheckbox "Instance Objects? " checked:sKTOInstanceValue align:#left across:2 offset:[0,4]
		checkbox sKTOSplineThicknessCheckbox "Spline Thickness as Size? " checked:sKTOSplineThicknessValue align:#right offset:[0,4]

		on sKTOObjTypeDropdown selected i do sKTOObjTypeValue = i
		on sKTOSizeSpinner changed val do sKTOSizeValue = val
		on sKTOInstanceCheckbox changed state do sKTOInstanceValue = state
		on sKTOSplineThicknessCheckbox changed state do sKTOSplineThicknessValue = state

		button sKTODoButton "Do" width:70 toolTip:"Do It and Close UI" pos:[5,57]
		on sKTODoButton pressed do sKTODo()
		button sKTOApplyButton "Apply" width:70 toolTip:"Do It and Keep UI Open" pos:[77,57]
		on sKTOApplyButton pressed do sKTOApply()
		button sKTOHelpButton "Help" width:70 toolTip:"Help" pos:[149,57]
		on sKTOHelpButton pressed do sKTOHelp()
		button sKTOSaveDefButton "SaveDef" width:70 toolTip:"Save Current Settings as Default" pos:[221,57]
		on sKTOSaveDefButton pressed do sKTOSaveDef()
		)
	)
)
-------------------------------------------------------------------------------