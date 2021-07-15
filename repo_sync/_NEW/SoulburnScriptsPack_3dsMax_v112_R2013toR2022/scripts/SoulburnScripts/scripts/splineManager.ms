-------------------------------------------------------------------------------
-- splineManager.ms
-- By Neil Blevins (info@neilblevins.com)
-- v 1.03
-- Created On: 11/26/06
-- Modified On: 04/18/08
-- tested using Max 8.0
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Required Files:
-- sLib.ms
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Description:
-- Lets you modify various controls for all selected splines.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Tutorial:
-- Select multiple splines. Run the UI version of the script. Hit Do. Now all 
-- the selected splines will have the values that you specified in the UI.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Revision History:
--
-- v 1.01 Added controls for the Rectangular Renderable Splines.
--
-- v 1.02 Added interactive mode so you can change values and have them
-- automatically affect the selected splines.
--
-- v 1.03 Replaced the Close button with a Help button. Use the X button to 
-- Close the Floater.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
(
-- Globals

global splineManager
global splineManagerDefaults
global splineManagerUI

global sPMCloseOpenUI

global sPMDo
global sPMApply
global sPMHelp
global sPMLoadDef
global sPMSaveDef

global sPMDefineUI
global sPMRollout
global sPMFloater

-- Includes

include "$scripts\SoulburnScripts\lib\sLib.ms"

-- Variables

global sPMInteractiveValue = false

sPMDoEnableInRenderValue = false
sPMEnableInRenderValue = true
sPMDoEnableInViewValue = false
sPMEnableInViewValue = true
sPMDoMappingValue = false
sPMMappingValue = true

sPMDoThicknessValue = false
sPMThicknessValue = 1.0
sPMDoSidesValue = false
sPMSidesValue = 6
sPMDoAngleValue = false
sPMAngleValue = 0
sPMDoRectangularValue = false
sPMRectangularValue = false
sPMDoRectLengthValue = false
sPMRectLengthValue = 6.0
sPMDoRectWidthValue = false
sPMRectWidthValue = 2.0
sPMDoRectAngleValue = false
sPMRectAngleValue = 0.0
sPMDoAspectLockedValue = false
sPMAspectLockedValue = false

sPMDoStepsValue = false
sPMStepsValue = 6
sPMDoOptimizeValue = false
sPMOptimizeValue = true
sPMDoAdaptiveValue = false
sPMAdaptiveValue = false
sPMPosValue = [400,400]

-- Functions

fn splineManager sPMDoEnableInRender sPMEnableInRender sPMDoEnableInView sPMEnableInView sPMDoMapping sPMMapping sPMDoThickness sPMThickness sPMDoSides sPMSides sPMDoAngle sPMAngle sPMDoRectangular sPMRectangular sPMDoRectLength sPMRectLength sPMDoRectWidth sPMRectWidth sPMDoRectAngle sPMRectAngle sPMDoAspectLocked sPMAspectLocked sPMDoSteps sPMSteps sPMDoOptimize sPMOptimize sPMDoAdaptive sPMAdaptive = 
	(
	if selection.count == 0 then (MessageBox "Please select at least one spline" title:"splineManager")
	else
		(
		for i in selection do
			(
			if (sLibShapeFilter i) == true then
				(
				if sPMDoEnableInRender == true then i.baseobject.renderable = sPMEnableInRender
				if sPMDoEnableInView == true then i.baseobject.DisplayRenderMesh = sPMEnableInView
				if sPMDoMapping == true then i.baseobject.mapCoords = sPMMapping
				
				if sPMDoThickness == true then i.baseobject.render_thickness = sPMThickness
				if sPMDoSides == true then i.baseobject.render_sides = sPMSides
				if sPMDoAngle == true then i.baseobject.render_angle = sPMAngle
				if sPMDoRectangular == true then i.baseobject.render_rectangular = sPMRectangular
				if sPMDoRectLength == true then i.baseobject.render_length = sPMRectLength
				if sPMDoRectWidth == true then i.baseobject.render_width = sPMRectWidth
				if sPMDoRectAngle == true then i.baseobject.render_angle2 = sPMRectAngle
				if sPMDoAspectLocked == true then i.baseobject.render_aspect_locked = sPMAspectLocked
			
				if sPMDoSteps == true then i.baseobject.steps = sPMSteps
				if sPMDoOptimize == true then i.baseobject.optimize = sPMOptimize
				if sPMDoAdaptive == true then i.baseobject.adaptive = sPMAdaptive
				)
			)
		)
	)

fn splineManagerDefaults = 
	(
	sPMLoadDef()
	splineManager sPMDoEnableInRenderValue sPMEnableInRenderValue sPMDoEnableInViewValue sPMEnableInViewValue sPMDoMappingValue sPMMappingValue sPMDoThicknessValue sPMThicknessValue sPMDoSidesValue sPMSidesValue sPMDoAngleValue sPMAngleValue sPMDoRectangularValue sPMRectangularValue sPMDoRectLengthValue sPMRectLengthValue sPMDoRectWidthValue sPMRectWidthValue sPMDoRectAngleValue sPMRectAngleValue sPMDoAspectLockedValue sPMAspectLockedValue sPMDoStepsValue sPMStepsValue sPMDoOptimizeValue sPMOptimizeValue sPMDoAdaptiveValue sPMAdaptiveValue
	)

fn splineManagerUI = 
	(
	sPMLoadDef()
	sPMCloseOpenUI sPMPosValue
	)

fn sPMCloseOpenUI pos = 
	(
	if sPMFloater != undefined then CloseRolloutFloater sPMFloater
	sPMDefineUI()
	sPMFloater = newRolloutFloater "splineManager v1.03" 230 476 pos.x pos.y
	addRollout sPMRollout sPMFloater
	)

fn sPMDo = 
	(
	splineManager sPMDoEnableInRenderValue sPMEnableInRenderValue sPMDoEnableInViewValue sPMEnableInViewValue sPMDoMappingValue sPMMappingValue sPMDoThicknessValue sPMThicknessValue sPMDoSidesValue sPMSidesValue sPMDoAngleValue sPMAngleValue sPMDoRectangularValue sPMRectangularValue sPMDoRectLengthValue sPMRectLengthValue sPMDoRectWidthValue sPMRectWidthValue sPMDoRectAngleValue sPMRectAngleValue sPMDoAspectLockedValue sPMAspectLockedValue sPMDoStepsValue sPMStepsValue sPMDoOptimizeValue sPMOptimizeValue sPMDoAdaptiveValue sPMAdaptiveValue
	if sPMFloater != undefined then CloseRolloutFloater sPMFloater
	)

fn sPMApply = 
	(
	splineManager sPMDoEnableInRenderValue sPMEnableInRenderValue sPMDoEnableInViewValue sPMEnableInViewValue sPMDoMappingValue sPMMappingValue sPMDoThicknessValue sPMThicknessValue sPMDoSidesValue sPMSidesValue sPMDoAngleValue sPMAngleValue sPMDoRectangularValue sPMRectangularValue sPMDoRectLengthValue sPMRectLengthValue sPMDoRectWidthValue sPMRectWidthValue sPMDoRectAngleValue sPMRectAngleValue sPMDoAspectLockedValue sPMAspectLockedValue sPMDoStepsValue sPMStepsValue sPMDoOptimizeValue sPMOptimizeValue sPMDoAdaptiveValue sPMAdaptiveValue
	)
	
fn sPMHelp = 
	(
	sLibSSPrintHelp "splineManager"
	)
	
fn sPMLoadDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	sPMInputFilename = presetDir + "splineManager.ini"
	if (sLibFileExist sPMInputFilename == true) then
		(
		sPMDoEnableInRenderValue = execute (getINISetting sPMInputFilename "splineManager" "sPMDoEnableInRenderValue")
		sPMEnableInRenderValue = execute (getINISetting sPMInputFilename "splineManager" "sPMEnableInRenderValue")
		sPMDoEnableInViewValue = execute (getINISetting sPMInputFilename "splineManager" "sPMDoEnableInViewValue")
		sPMEnableInViewValue = execute (getINISetting sPMInputFilename "splineManager" "sPMEnableInViewValue")
		sPMDoMappingValue = execute (getINISetting sPMInputFilename "splineManager" "sPMDoMappingValue")
		sPMMappingValue = execute (getINISetting sPMInputFilename "splineManager" "sPMMappingValue")
		sPMDoThicknessValue = execute (getINISetting sPMInputFilename "splineManager" "sPMDoThicknessValue")
		sPMThicknessValue = execute (getINISetting sPMInputFilename "splineManager" "sPMThicknessValue")
		sPMDoSidesValue = execute (getINISetting sPMInputFilename "splineManager" "sPMDoSidesValue")
		sPMSidesValue = execute (getINISetting sPMInputFilename "splineManager" "sPMSidesValue")
		sPMDoAngleValue = execute (getINISetting sPMInputFilename "splineManager" "sPMDoAngleValue")
		sPMAngleValue = execute (getINISetting sPMInputFilename "splineManager" "sPMAngleValue")
		sPMDoRectangularValue = execute (getINISetting sPMInputFilename "splineManager" "sPMDoRectangularValue")
		sPMRectangularValue = execute (getINISetting sPMInputFilename "splineManager" "sPMRectangularValue")
		sPMDoRectLengthValue = execute (getINISetting sPMInputFilename "splineManager" "sPMDoRectLengthValue")
		sPMRectLengthValue = execute (getINISetting sPMInputFilename "splineManager" "sPMRectLengthValue")
		sPMDoRectWidthValue = execute (getINISetting sPMInputFilename "splineManager" "sPMDoRectWidthValue")
		sPMRectWidthValue = execute (getINISetting sPMInputFilename "splineManager" "sPMRectWidthValue")
		sPMDoRectAngleValue = execute (getINISetting sPMInputFilename "splineManager" "sPMDoRectAngleValue")
		sPMRectAngleValue = execute (getINISetting sPMInputFilename "splineManager" "sPMRectAngleValue")
		sPMDoAspectLockedValue = execute (getINISetting sPMInputFilename "splineManager" "sPMDoAspectLockedValue")
		sPMAspectLockedValue = execute (getINISetting sPMInputFilename "splineManager" "sPMAspectLockedValue")
		sPMDoStepsValue = execute (getINISetting sPMInputFilename "splineManager" "sPMDoStepsValue")
		sPMStepsValue = execute (getINISetting sPMInputFilename "splineManager" "sPMStepsValue")
		sPMDoOptimizeValue = execute (getINISetting sPMInputFilename "splineManager" "sPMDoOptimizeValue")
		sPMOptimizeValue = execute (getINISetting sPMInputFilename "splineManager" "sPMOptimizeValue")
		sPMDoAdaptiveValue = execute (getINISetting sPMInputFilename "splineManager" "sPMDoAdaptiveValue")
		sPMAdaptiveValue = execute (getINISetting sPMInputFilename "splineManager" "sPMAdaptiveValue")
		sPMPosValue = execute (getINISetting sPMInputFilename "splineManager" "sPMPosValue")

		if sPMDoEnableInRenderValue == OK then sPMDoEnableInRenderValue = false
		if sPMEnableInRenderValue == OK then sPMEnableInRenderValue = true
		if sPMDoEnableInViewValue == OK then sPMDoEnableInViewValue = false
		if sPMEnableInViewValue == OK then sPMEnableInViewValue = true
		if sPMDoMappingValue == OK then sPMDoMappingValue = false
		if sPMMappingValue == OK then sPMMappingValue = true
		if sPMDoThicknessValue == OK then sPMDoThicknessValue = false
		if sPMThicknessValue == OK then sPMThicknessValue = 1.0
		if sPMDoSidesValue == OK then sPMDoSidesValue = false
		if sPMSidesValue == OK then sPMSidesValue = 6
		if sPMDoAngleValue == OK then sPMDoAngleValue = false
		if sPMAngleValue == OK then sPMAngleValue = 0
		if sPMDoRectangularValue == OK then sPMDoRectangularValue = false
		if sPMRectangularValue == OK then sPMRectangularValue = false
		if sPMDoRectLengthValue == OK then sPMDoRectLengthValue = false
		if sPMRectLengthValue == OK then sPMRectLengthValue = 6.0
		if sPMDoRectWidthValue == OK then sPMDoRectWidthValue = false
		if sPMRectWidthValue == OK then sPMRectWidthValue = 2.0
		if sPMDoRectAngleValue == OK then sPMDoRectAngleValue = false
		if sPMRectAngleValue == OK then sPMRectAngleValue = 0.0
		if sPMDoAspectLockedValue == OK then sPMDoAspectLockedValue = false
		if sPMAspectLockedValue == OK then sPMAspectLockedValue = false
		if sPMDoStepsValue == OK then sPMDoStepsValue = false
		if sPMStepsValue == OK then sPMStepsValue = 6
		if sPMDoOptimizeValue == OK then sPMDoOptimizeValue = false
		if sPMOptimizeValue == OK then sPMOptimizeValue = true
		if sPMDoAdaptiveValue == OK then sPMDoAdaptiveValue = false
		if sPMAdaptiveValue == OK then sPMAdaptiveValue = false
		if sPMPosValue == OK then sPMPosValue = [400,400]
		)
	else
		(
		sPMDoEnableInRenderValue = false
		sPMEnableInRenderValue = true
		sPMDoEnableInViewValue = false
		sPMEnableInViewValue = true
		sPMDoMappingValue = false
		sPMMappingValue = true
		sPMDoThicknessValue = false
		sPMThicknessValue = 1.0
		sPMDoSidesValue = false
		sPMSidesValue = 6
		sPMDoAngleValue = false
		sPMAngleValue = 0
		sPMDoRectangularValue = false
		sPMRectangularValue = false
		sPMDoRectLengthValue = false
		sPMRectLengthValue = 6.0
		sPMDoRectWidthValue = false
		sPMRectWidthValue = 2.0
		sPMDoRectAngleValue = false
		sPMRectAngleValue = 0.0
		sPMDoAspectLockedValue = false
		sPMAspectLockedValue = false
		sPMDoStepsValue = false
		sPMStepsValue = 6
		sPMDoOptimizeValue = false
		sPMOptimizeValue = true
		sPMDoAdaptiveValue = false
		sPMAdaptiveValue = false
		sPMPosValue = [400,400]
		)
	)

fn sPMSaveDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	if (getDirectories presetDir).count == 0 then makeDir presetDir
	sPMOutputFilename = presetDir + "splineManager.ini"
	if (sLibFileExist sPMOutputFilename == true) then deleteFile sPMOutputFilename
	setINISetting sPMOutputFilename "splineManager" "sPMDoEnableInRenderValue" (sPMDoEnableInRenderValue as string)
	setINISetting sPMOutputFilename "splineManager" "sPMEnableInRenderValue" (sPMEnableInRenderValue as string)
	setINISetting sPMOutputFilename "splineManager" "sPMDoEnableInViewValue" (sPMDoEnableInViewValue as string)
	setINISetting sPMOutputFilename "splineManager" "sPMEnableInViewValue" (sPMEnableInViewValue as string)
	setINISetting sPMOutputFilename "splineManager" "sPMDoMappingValue" (sPMDoMappingValue as string)
	setINISetting sPMOutputFilename "splineManager" "sPMMappingValue" (sPMMappingValue as string)
	setINISetting sPMOutputFilename "splineManager" "sPMDoThicknessValue" (sPMDoThicknessValue as string)
	setINISetting sPMOutputFilename "splineManager" "sPMThicknessValue" (sPMThicknessValue as string)
	setINISetting sPMOutputFilename "splineManager" "sPMDoSidesValue" (sPMDoSidesValue as string)	
	setINISetting sPMOutputFilename "splineManager" "sPMSidesValue" (sPMSidesValue as string)
	setINISetting sPMOutputFilename "splineManager" "sPMDoAngleValue" (sPMDoAngleValue as string)
	setINISetting sPMOutputFilename "splineManager" "sPMAngleValue" (sPMAngleValue as string)
	setINISetting sPMOutputFilename "splineManager" "sPMDoRectangularValue" (sPMDoRectangularValue as string)
	setINISetting sPMOutputFilename "splineManager" "sPMRectangularValue" (sPMRectangularValue as string)
	setINISetting sPMOutputFilename "splineManager" "sPMDoRectLengthValue" (sPMDoRectLengthValue as string)
	setINISetting sPMOutputFilename "splineManager" "sPMRectLengthValue" (sPMRectLengthValue as string)
	setINISetting sPMOutputFilename "splineManager" "sPMDoRectWidthValue" (sPMDoRectWidthValue as string)
	setINISetting sPMOutputFilename "splineManager" "sPMRectWidthValue" (sPMRectWidthValue as string)
	setINISetting sPMOutputFilename "splineManager" "sPMDoRectAngleValue" (sPMDoRectAngleValue as string)
	setINISetting sPMOutputFilename "splineManager" "sPMRectAngleValue" (sPMRectAngleValue as string)
	setINISetting sPMOutputFilename "splineManager" "sPMDoAspectLockedValue" (sPMDoAspectLockedValue as string)
	setINISetting sPMOutputFilename "splineManager" "sPMAspectLockedValue" (sPMAspectLockedValue as string)
	setINISetting sPMOutputFilename "splineManager" "sPMDoStepsValue" (sPMDoStepsValue as string)
	setINISetting sPMOutputFilename "splineManager" "sPMStepsValue" (sPMStepsValue as string)
	setINISetting sPMOutputFilename "splineManager" "sPMDoOptimizeValue" (sPMDoOptimizeValue as string)
	setINISetting sPMOutputFilename "splineManager" "sPMOptimizeValue" (sPMOptimizeValue as string)
	setINISetting sPMOutputFilename "splineManager" "sPMDoAdaptiveValue" (sPMDoAdaptiveValue as string)
	setINISetting sPMOutputFilename "splineManager" "sPMAdaptiveValue" (sPMAdaptiveValue as string)
	setINISetting sPMOutputFilename "splineManager" "sPMPosValue" (sPMFloater.pos as string)
	)

-- UI

fn sPMDefineUI = 
	(
	rollout sPMRollout "splineManager"
		(
		group "Rendering Parameters:"
		(
		checkbox sPMDoEnableInRenderCheckbox "" across:2
		checkbox sPMEnableInRenderCheckbox "Enable In Renderer" enabled:sPMDoEnableInRenderValue checked:sPMEnableInRenderValue align:#right
		checkbox sPMDoEnableInViewCheckbox "" across:2
		checkbox sPMEnableInViewCheckbox "Enable In Viewport" enabled:sPMDoEnableInRenderValue checked:sPMEnableInViewValue align:#right
		checkbox sPMDoMappingCheckbox "" across:2
		checkbox sPMMappingCheckbox "Generate Mapping Coords." enabled:sPMDoMappingValue checked:sPMMappingValue align:#right
		)

		on sPMDoEnableInRenderCheckbox changed state do 
			(
			sPMEnableInRenderCheckbox.enabled = state;sPMDoEnableInRenderValue = state
			if state == true then (if sPMInteractiveValue == true then (for i in selection do (if (sLibShapeFilter i) == true then i.baseobject.renderable = sPMEnableInRenderValue)))
			)
		on sPMEnableInRenderCheckbox changed state do 
			(
			sPMEnableInRenderValue = state
			if sPMInteractiveValue == true then (for i in selection do (if (sLibShapeFilter i) == true then i.baseobject.renderable = sPMEnableInRenderValue))
			)
		on sPMDoEnableInViewCheckbox changed state do 
			(
			sPMEnableInViewCheckbox.enabled = state;sPMDoEnableInViewValue = state
			if state == true then (if sPMInteractiveValue == true then (for i in selection do (if (sLibShapeFilter i) == true then i.baseobject.DisplayRenderMesh = sPMEnableInViewValue)))
			)
		on sPMEnableInViewCheckbox changed state do 
			(
			sPMEnableInViewValue = state
			if sPMInteractiveValue == true then (for i in selection do (if (sLibShapeFilter i) == true then i.baseobject.DisplayRenderMesh = sPMEnableInViewValue))
			)
		on sPMDoMappingCheckbox changed state do 
			(
			sPMMappingCheckbox.enabled = state;sPMDoMappingValue = state
			if state == true then (if sPMInteractiveValue == true then (for i in selection do (if (sLibShapeFilter i) == true then i.baseobject.mapCoords = sPMMappingValue)))
			)
		on sPMMappingCheckbox changed state do 
			(
			sPMMappingValue = state
			if sPMInteractiveValue == true then (for i in selection do (if (sLibShapeFilter i) == true then i.baseobject.mapCoords = sPMMappingValue))
			)

		group "Renderer Parameters:"
		(
		checkbox sPMDoThicknessCheckbox "" across:2
		spinner sPMThicknessCheckbox "Thickness: " range:[0,9999999,sPMThicknessValue] fieldWidth:45 enabled:sPMDoThicknessValue type:#float
		checkbox sPMDoSidesCheckbox "" across:2
		spinner sPMSidesCheckbox "Sides: " range:[3,100,sPMSidesValue] fieldWidth:45 enabled:sPMDoSidesValue type:#integer
		checkbox sPMDoAngleCheckbox "" across:2
		spinner sPMAngleCheckbox "Angle: " range:[-9999999,9999999,sPMAngleValue] fieldWidth:45 enabled:sPMDoAngleValue type:#float

		checkbox sPMDoRectangularCheckbox "" across:2
		checkbox sPMRectangularCheckbox "Rectangular" enabled:sPMDoRectangularValue checked:sPMRectangularValue align:#right

		checkbox sPMDoRectLengthCheckbox "" across:2
		spinner sPMRectLengthCheckbox "Rect Length: " range:[0,9999999,sPMRectLengthValue] fieldWidth:45 enabled:sPMDoRectLengthValue type:#float
		checkbox sPMDoRectWidthCheckbox "" across:2
		spinner sPMRectWidthCheckbox "Rect Width: " range:[0,9999999,sPMRectWidthValue] fieldWidth:45 enabled:sPMDoRectWidthValue type:#float
		checkbox sPMDoRectAngleCheckbox "" across:2
		spinner sPMRectAngleCheckbox "Rect Angle: " range:[-9999999,9999999,sPMRectAngleValue] fieldWidth:45 enabled:sPMDoRectAngleValue type:#float
		checkbox sPMDoAspectLockedCheckbox "" across:2
		checkbox sPMAspectLockedCheckbox "Rect Aspect Locked" enabled:sPMDoAspectLockedValue checked:sPMAspectLockedValue align:#right
		)

		on sPMDoThicknessCheckbox changed state do 
			(
			sPMThicknessCheckbox.enabled = state;sPMDoThicknessValue = state
			if state == true then (if sPMInteractiveValue == true then (for i in selection do (if (sLibShapeFilter i) == true then i.baseobject.render_thickness = sPMThicknessValue)))
			)
		on sPMThicknessCheckbox changed val do 
			(
			sPMThicknessValue = val
			if sPMInteractiveValue == true then (for i in selection do (if (sLibShapeFilter i) == true then i.baseobject.render_thickness = sPMThicknessValue))
			)
		on sPMDoSidesCheckbox changed state do 
			(
			sPMSidesCheckbox.enabled = state;sPMDoSidesValue = state
			if state == true then (if sPMInteractiveValue == true then (for i in selection do (if (sLibShapeFilter i) == true then i.baseobject.render_sides = sPMSidesValue)))
			)
		on sPMSidesCheckbox changed val do 
			(
			sPMSidesValue = val
			if sPMInteractiveValue == true then (for i in selection do (if (sLibShapeFilter i) == true then i.baseobject.render_sides = sPMSidesValue))
			)
		on sPMDoAngleCheckbox changed state do 
			(
			sPMAngleCheckbox.enabled = state;sPMDoAngleValue = state
			if state == true then (if sPMInteractiveValue == true then (for i in selection do (if (sLibShapeFilter i) == true then i.baseobject.render_angle = sPMAngleValue)))
			)
		on sPMAngleCheckbox changed val do 
			(
			sPMAngleValue = val
			if sPMInteractiveValue == true then (for i in selection do (if (sLibShapeFilter i) == true then i.baseobject.render_angle = sPMAngleValue))
			)
		
		on sPMDoRectangularCheckbox changed state do 
			(
			sPMRectangularCheckbox.enabled = state;sPMDoRectangularValue = state
			if state == true then (if sPMInteractiveValue == true then (for i in selection do (if (sLibShapeFilter i) == true then i.baseobject.render_rectangular = sPMRectangularValue)))
			)
		on sPMRectangularCheckbox changed state do 
			(
			sPMRectangularValue = state
			if sPMInteractiveValue == true then (for i in selection do (if (sLibShapeFilter i) == true then i.baseobject.render_rectangular = sPMRectangularValue))
			)
		
		on sPMDoRectLengthCheckbox changed state do 
			(
			sPMRectLengthCheckbox.enabled = state;sPMDoRectLengthValue = state
			if state == true then (if sPMInteractiveValue == true then (for i in selection do (if (sLibShapeFilter i) == true then i.baseobject.render_length = sPMRectLengthValue)))
			)
		on sPMRectLengthCheckbox changed val do 
			(
			sPMRectLengthValue = val
			if sPMInteractiveValue == true then (for i in selection do (if (sLibShapeFilter i) == true then i.baseobject.render_length = sPMRectLengthValue))
			)
		on sPMDoRectWidthCheckbox changed state do 
			(
			sPMRectWidthCheckbox.enabled = state;sPMDoRectWidthValue = state
			if state == true then (if sPMInteractiveValue == true then (for i in selection do (if (sLibShapeFilter i) == true then i.baseobject.render_width = sPMRectWidthValue)))
			)
		on sPMRectWidthCheckbox changed val do 
			(
			sPMRectWidthValue = val
			if sPMInteractiveValue == true then (for i in selection do (if (sLibShapeFilter i) == true then i.baseobject.render_width = sPMRectWidthValue))
			)
		on sPMDoRectAngleCheckbox changed state do 
			(
			sPMRectAngleCheckbox.enabled = state;sPMDoRectAngleValue = state
			if state == true then (if sPMInteractiveValue == true then (for i in selection do (if (sLibShapeFilter i) == true then i.baseobject.render_angle2 = sPMRectAngleValue)))
			)
		on sPMRectAngleCheckbox changed val do 
			(
			sPMRectAngleValue = val
			if sPMInteractiveValue == true then (for i in selection do (if (sLibShapeFilter i) == true then i.baseobject.render_angle2 = sPMRectAngleValue))
			)
		on sPMDoAspectLockedCheckbox changed state do 
			(
			sPMAspectLockedCheckbox.enabled = state;sPMDoAspectLockedValue = state
			if state == true then (if sPMInteractiveValue == true then (for i in selection do (if (sLibShapeFilter i) == true then i.baseobject.render_aspect_locked = sPMAspectLockedValue)))
			)
		on sPMAspectLockedCheckbox changed state do 
			(
			sPMAspectLockedValue = state
			if sPMInteractiveValue == true then (for i in selection do (if (sLibShapeFilter i) == true then i.baseobject.render_aspect_locked = sPMAspectLockedValue))
			)

		group "Interpolation Parameters:"
		(
		checkbox sPMDoStepsCheckbox "" across:2
		spinner sPMStepsSpinner "Steps: " range:[0,100,sPMStepsValue] fieldWidth:45 enabled:sPMDoStepsValue type:#integer
		checkbox sPMDoOptimizeCheckbox "" across:2
		checkbox sPMOptimizeCheckbox "Optimize" enabled:sPMDoOptimizeValue checked:sPMOptimizeValue align:#right
		checkbox sPMDoAdaptiveCheckbox "" across:2
		checkbox sPMAdaptiveCheckbox "Adaptive" enabled:sPMDoAdaptiveValue checked:sPMAdaptiveValue align:#right
		)

		on sPMDoStepsCheckbox changed state do 
			(
			sPMStepsSpinner.enabled = state;sPMDoStepsValue = state
			if state == true then (if sPMInteractiveValue == true then (for i in selection do (if (sLibShapeFilter i) == true then i.baseobject.steps = sPMStepsValue)))
			)
		on sPMStepsSpinner changed val do 
			(
			sPMStepsValue = val
			if sPMInteractiveValue == true then (for i in selection do (if (sLibShapeFilter i) == true then i.baseobject.steps = sPMStepsValue))
			)
		on sPMDoOptimizeCheckbox changed state do 
			(
			sPMOptimizeCheckbox.enabled = state;sPMDoOptimizeValue = state
			if state == true then (if sPMInteractiveValue == true then (for i in selection do (if (sLibShapeFilter i) == true then i.baseobject.optimize = sPMOptimizeValue)))
			)
		on sPMOptimizeCheckbox changed state do 
			(
			sPMOptimizeValue = state
			if sPMInteractiveValue == true then (for i in selection do (if (sLibShapeFilter i) == true then i.baseobject.optimize = sPMOptimizeValue))
			)
		on sPMDoAdaptiveCheckbox changed state do 
			(
			sPMAdaptiveCheckbox.enabled = state;sPMDoAdaptiveValue = state
			if state == true then (if sPMInteractiveValue == true then (for i in selection do (if (sLibShapeFilter i) == true then i.baseobject.adaptive = sPMAdaptiveValue)))
			)
		on sPMAdaptiveCheckbox changed state do 
			(
			sPMAdaptiveValue = state
			if sPMInteractiveValue == true then (for i in selection do (if (sLibShapeFilter i) == true then i.baseobject.adaptive = sPMAdaptiveValue))
			)

		checkbutton sPMInteractiveButton "Interactive Mode" checked:false align:#center width:170
		on sPMInteractiveButton changed state do sPMInteractiveValue = state

		button sPMDoButton "Do" width:70 toolTip:"Do It and Close UI" pos:[35,395]
		on sPMDoButton pressed do sPMDo()
		button sPMApplyButton "Apply" width:70 toolTip:"Do It and Keep UI Open" pos:[107,395]
		on sPMApplyButton pressed do sPMApply()
		button sPMHelpButton "Help" width:70 toolTip:"Help" pos:[35,419]
		on sPMCloseButton pressed do sPMClose()
		button sPMSaveDefButton "SaveDef" width:70 toolTip:"Save Current Settings as Default" pos:[107,419]
		on sPMSaveDefButton pressed do sPMSaveDef()
		)
	)
)
-------------------------------------------------------------------------------