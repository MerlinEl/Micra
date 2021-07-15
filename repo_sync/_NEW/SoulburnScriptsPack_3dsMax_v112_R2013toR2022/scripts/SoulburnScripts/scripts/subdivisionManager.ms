-------------------------------------------------------------------------------
-- subdivisionManager.ms
-- By Neil Blevins (info@neilblevins.com)
-- v 1.05
-- Created On: 04/03/05
-- Modified On: 08/11/14
-- tested using Max 2015.5
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Required Files:
-- sLib.ms
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Description:
-- Lets you modify various subdivision controls on all selected objects (both 
-- polyobjects and meshsmooth modifiers)
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Tutorial:
-- Select a bunch of editable polys. Run the UI version of the script. Hit Do. 
-- Now all the selected objects will have the values that you specified in the 
-- UI.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Revision History:
--
-- v 1.01 Added isoline support. Defined ui as new function.
--
-- v 1.02 Defined ui as new function.
--
-- v 1.03 Works now with turbosmooth modifier. Thanks to captainchet for the
-- inspiration. Added some new code to more cleanly open and close the UI.
--
-- v 1.04 Replaced the Close button with a Help button. Use the X button to 
-- Close the Floater.
--
-- v 1.05 Added OpenSubdiv Support.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
(
-- Globals

global subdivisionManager
global subdivisionManagerDefaults
global subdivisionManagerUI

global sMCloseOpenUI

global sMSetPoly
global sMSetMeshsmooth
global sMSetTurbosmooth
global sMSetOpenSubdiv

global sMDo
global sMApply
global sMHelp
global sMLoadDef
global sMSaveDef

global sMDefineUI
global sMRollout
global sMFloater

-- Includes

include "$scripts\SoulburnScripts\lib\sLib.ms"

-- Variables

sMSetAsSubdivValue = true
sMDoRenderValue = true
sMIsolineValue = false
sMDispIterValue = 1
sMRendIterValue = 2
sMPosValue = [400,400]

sMAffectPolyValue = true
sMAffectMeshsmoothValue = false
sMAffectTurbosmoothValue = false
sMAffectOpenSubdivValue = false

-- Functions

fn subdivisionManager sMAffectPoly sMAffectMeshsmooth sMAffectTurbosmooth sMAffectOpenSubdiv sMSetAsSubdiv sMDoRender sMIsoline sMDispIter sMRendIter = 
	(
	if sMAffectPoly == true then sMSetPoly sMSetAsSubdiv sMDoRender sMIsoline sMDispIter sMRendIter
	if sMAffectMeshsmooth == true then sMSetMeshsmooth sMDoRender sMIsoline sMDispIter sMRendIter
	if sMAffectTurbosmooth == true then sMSetTurbosmooth sMDoRender sMIsoline sMDispIter sMRendIter
	if sMAffectOpenSubdiv == true then sMSetOpenSubdiv sMDoRender sMIsoline sMDispIter sMRendIter
	)

fn subdivisionManagerDefaults = 
	(
	sMLoadDef()
	subdivisionManager sMAffectPolyValue sMAffectMeshsmoothValue sMAffectTurbosmoothValue sMAffectOpenSubdivValue sMSetAsSubdivValue sMDoRenderValue sMIsolineValue sMDispIterValue sMRendIterValue
	)

fn subdivisionManagerUI = 
	(
	sMLoadDef()
	sMCloseOpenUI sMPosValue
	)

fn sMCloseOpenUI pos = 
	(
	if sMFloater != undefined then CloseRolloutFloater sMFloater
	sMDefineUI()
	sMFloater = newRolloutFloater "subdivisionManager v1.05" 310 218 pos.x pos.y
	addRollout sMRollout sMFloater
	)

fn sMSetPoly sMSetAsSubdiv sMDoRender sMIsoline sMDispIter sMRendIter = 
	(
	if $ == undefined then (MessageBox "Please select at least one object" title:"subdivisionManager")
	else
		(
		for i in selection do
			(
			if (sLibEditablePolyFilter i) == true then
				(
				i.surfSubdivide = sMSetAsSubdiv
				i.iterations = sMDispIter
				i.useRenderIterations = sMDoRender
				i.renderIterations = sMRendIter
				i.isolineDisplay = sMIsoline			
				)
			)
		)
	)
	
fn sMSetMeshsmooth sMDoRender sMIsoline sMDispIter sMRendIter = 
	(
	if $ == undefined then (MessageBox "Please select at least one object" title:"subdivisionManager")
	else
		(
		for i in selection do
			(
			if i.modifiers.count == 0 then continue
			else
				(
				for j = 1 to i.modifiers.count do
					(
					if classof i.modifiers[j] == MeshSmooth then
						(
						i.modifiers[j].iterations = sMDispIter
						i.modifiers[j].useRenderIterations = sMDoRender
						i.modifiers[j].renderIterations = sMRendIter
						i.modifiers[j].isolineDisplay = sMIsoline
						)
					)
				)
			)
		)
	)
	
fn sMSetTurbosmooth sMDoRender sMIsoline sMDispIter sMRendIter = 
	(
	if $ == undefined then (MessageBox "Please select at least one object" title:"subdivisionManager")
	else
		(
		for i in selection do
			(
			if i.modifiers.count == 0 then continue
			else
				(
				for j = 1 to i.modifiers.count do
					(
					if classof i.modifiers[j] == TurboSmooth then
						(
						i.modifiers[j].iterations = sMDispIter
						i.modifiers[j].useRenderIterations = sMDoRender
						i.modifiers[j].renderIterations = sMRendIter
						i.modifiers[j].isolineDisplay = sMIsoline
						)
					)
				)
			)
		)
	)

fn sMSetOpenSubdiv sMDoRender sMIsoline sMDispIter sMRendIter = 
	(
	if $ == undefined then (MessageBox "Please select at least one object" title:"subdivisionManager")
	else
		(
		for i in selection do
			(
			if i.modifiers.count == 0 then continue
			else
				(
				for j = 1 to i.modifiers.count do
					(
					if classof i.modifiers[j] == OpenSubdiv then
						(
						i.modifiers[j].iterations = sMDispIter
						i.modifiers[j].useRenderIterations = sMDoRender
						i.modifiers[j].renderIterations = sMRendIter
						i.modifiers[j].isolineDisplay = sMIsoline
						)
					)
				)
			)
		)
	)

fn sMDo = 
	(
	subdivisionManager sMAffectPolyValue sMAffectMeshsmoothValue sMAffectTurbosmoothValue sMAffectOpenSubdivValue sMSetAsSubdivValue sMDoRenderValue sMIsolineValue sMDispIterValue sMRendIterValue
	if sMFloater != undefined then CloseRolloutFloater sMFloater
	)

fn sMApply = 
	(
	subdivisionManager sMAffectPolyValue sMAffectMeshsmoothValue sMAffectTurbosmoothValue sMAffectOpenSubdivValue sMSetAsSubdivValue sMDoRenderValue sMIsolineValue sMDispIterValue sMRendIterValue
	)
	
fn sMHelp = 
	(
	sLibSSPrintHelp "subdivisionManager"
	)
	
fn sMLoadDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	sMInputFilename = presetDir + "subdivisionManager.ini"
	if (sLibFileExist sMInputFilename == true) then
		(
		sMSetAsSubdivValue = execute (getINISetting sMInputFilename "subdivisionManager" "sMSetAsSubdivValue")
		sMDoRenderValue = execute (getINISetting sMInputFilename "subdivisionManager" "sMDoRenderValue")
		sMIsolineValue = execute (getINISetting sMInputFilename "subdivisionManager" "sMIsolineValue")
		sMDispIterValue = execute (getINISetting sMInputFilename "subdivisionManager" "sMDispIterValue")
		sMRendIterValue = execute (getINISetting sMInputFilename "subdivisionManager" "sMRendIterValue")
		sMAffectPolyValue = execute (getINISetting sMInputFilename "subdivisionManager" "sMAffectPolyValue")
		sMAffectMeshsmoothValue = execute (getINISetting sMInputFilename "subdivisionManager" "sMAffectMeshsmoothValue")
		sMAffectTurbosmoothValue = execute (getINISetting sMInputFilename "subdivisionManager" "sMAffectTurbosmoothValue")
		sMAffectOpenSubdivValue = execute (getINISetting sMInputFilename "subdivisionManager" "sMAffectOpenSubdivValue")
		sMPosValue = execute (getINISetting sMInputFilename "subdivisionManager" "sMPosValue")

		if sMSetAsSubdivValue == OK then sMSetAsSubdivValue = true
		if sMDoRenderValue == OK then sMDoRenderValue = true
		if sMIsolineValue == OK then sMIsolineValue = false
		if sMDispIterValue == OK then sMDispIterValue = 1
		if sMRendIterValue == OK then sMRendIterValue = 2
		if sMAffectPolyValue == OK then sMAffectPolyValue = true
		if sMAffectMeshsmoothValue == OK then sMAffectMeshsmoothValue = false
		if sMAffectTurbosmoothValue == OK then sMAffectTurbosmoothValue = false
		if sMAffectOpenSubdivValue == OK then sMAffectOpenSubdivValue = false
		if sMPosValue == OK then sMPosValue = [400,400]
		)
	else
		(
		sMSetAsSubdivValue = true
		sMDoRenderValue = true
		sMIsolineValue = false
		sMDispIterValue = 1
		sMRendIterValue = 2
		sMAffectPolyValue = true
		sMAffectMeshsmoothValue = false
		sMAffectTurbosmoothValue = false
		sMAffectOpenSubdivValue = false
		sMPosValue = [400,400]
		)
	)
	
fn sMSaveDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	if (getDirectories presetDir).count == 0 then makeDir presetDir
	sMOutputFilename = presetDir + "subdivisionManager.ini"
	if (sLibFileExist sMOutputFilename == true) then deleteFile sMOutputFilename
	setINISetting sMOutputFilename "subdivisionManager" "sMSetAsSubdivValue" (sMSetAsSubdivValue as string)
	setINISetting sMOutputFilename "subdivisionManager" "sMDoRenderValue" (sMDoRenderValue as string)
	setINISetting sMOutputFilename "subdivisionManager" "sMIsolineValue" (sMIsolineValue as string)
	setINISetting sMOutputFilename "subdivisionManager" "sMDispIterValue" (sMDispIterValue as string)
	setINISetting sMOutputFilename "subdivisionManager" "sMRendIterValue" (sMRendIterValue as string)
	setINISetting sMOutputFilename "subdivisionManager" "sMAffectPolyValue" (sMAffectPolyValue as string)
	setINISetting sMOutputFilename "subdivisionManager" "sMAffectMeshsmoothValue" (sMAffectMeshsmoothValue as string)
	setINISetting sMOutputFilename "subdivisionManager" "sMAffectTurbosmoothValue" (sMAffectTurbosmoothValue as string)
	setINISetting sMOutputFilename "subdivisionManager" "sMAffectOpenSubdivValue" (sMAffectOpenSubdivValue as string)
	setINISetting sMOutputFilename "subdivisionManager" "sMPosValue" (sMFloater.pos as string)
	)

-- UI

fn sMDefineUI = 
	(
	rollout sMRollout "subdivisionManager"
		(
		group "Set Values:"
		(	
		checkbox sMSetAsSubdivCheckbox "Set as Subdiv" checked:sMSetAsSubdivValue align:#left across:2
		spinner sMdispIterSpinner "Display Iters: " range:[0,10,sMDispIterValue] fieldWidth:50 type:#integer align:#right
		checkbox sMDoRenderCheckbox "Do Render Iterations" checked:sMDoRenderValue align:#left across:2
		spinner sMRendIterSpinner "Render Iters: " range:[0,10,sMRendIterValue] fieldWidth:50 type:#integer align:#right
		checkbox sMIsolineCheckbox "Isoline Display" checked:sMIsolineValue align:#left
		)
	
		on sMSetAsSubdivCheckbox changed state do sMSetAsSubdivValue = state
		on sMDoRenderCheckbox changed state do sMDoRenderValue = state
		on sMIsolineCheckbox changed state do sMIsolineValue = state
		on sMdispIterSpinner changed val do sMDispIterValue = val
		on sMRendIterSpinner changed val do sMRendIterValue = val
	
		group "Affect:"
		(
		checkbox sMAffectPolyCheckbox "Polyobject Subdivision" checked:sMAffectPolyValue align:#left across:2
		checkbox sMAffectMeshsmoothCheckbox "Meshsmooth Modifiers" checked:sMAffectMeshsmoothValue align:#right
		checkbox sMAffectTurbosmoothCheckbox "Turbosmooth Modifiers" checked:sMAffectTurbosmoothValue align:#left across:2
		checkbox sMAffectOpenSubdivCheckbox "OpenSubdiv Modifiers" checked:sMAffectOpenSubdivValue align:#right
		)
	
		on sMAffectPolyCheckbox changed state do sMAffectPolyValue = state
		on sMAffectMeshsmoothCheckbox changed state do sMAffectMeshsmoothValue = state
		on sMAffectTurbosmoothCheckbox changed state do sMAffectTurbosmoothValue = state
		on sMAffectOpenSubdivCheckbox changed state do sMAffectOpenSubdivValue = state
	
		button sMDoButton "Do" width:70 toolTip:"Do It and Close UI" pos:[5,161]
		on sMDoButton pressed do sMDo()
		button sMApplyButton "Apply" width:70 toolTip:"Do It and Keep UI Open" pos:[77,161]
		on sMApplyButton pressed do sMApply()
		button sMHelpButton "Help" width:70 toolTip:"Help" pos:[149,161]
		on sMHelpButton pressed do sMHelp()
		button sMSaveDefButton "SaveDef" width:70 toolTip:"Save Current Settings as Default" pos:[221,161]
		on sMSaveDefButton pressed do sMSaveDef()
		)
	)
)
-------------------------------------------------------------------------------