-------------------------------------------------------------------------------
-- subdivisionIterationManip.ms
-- By Neil Blevins (info@neilblevins.com)
-- v 1.08
-- Created On: 04/22/05
-- Modified On: 01/28/15
-- tested using Max 2015.5
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Required Files:
-- sLib.ms
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Description:
-- Lets you increase or decrease the number of subdiv iterations for selected 
-- objects.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Tutorial:
-- Select an editable poly object. Run the UI version of the script. Hit Do. 
-- Now your object has it's subdivision iterations increased by 1. Bind the 
-- up and down versions of the script to hotkeys to quickly make your object
-- more or less smooth.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Revision History:
--
-- v 1.01 Defined ui as new function.
--
-- v 1.02 Modified a condition that would occur when you use the script
-- on an object for the first time, previously it would immediately jump to
-- a subdiv iter of 2. Now the first time you use the script on an object it
-- jumps to 1.
--
-- v 1.03 Works now with turbosmooth modifier. Thanks to captainchet for the
-- inspiration. Added some new code to more cleanly open and close the UI.
--
-- v 1.04 Now when you decrease iterations to 0, it turns off "Use Nurms
-- Subdivision" entirely.
--
-- v 1.05 Works properly now with instanced Modifiers.
--
-- v 1.06 Replaced the Close button with a Help button. Use the X button to 
-- Close the Floater.
--
-- v 1.07 Added OpenSubdiv Support.
--
-- v 1.08 Changed name of script to subdivisionIterationManip.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
(
-- Globals

global subdivisionIterationManip
global subdivisionIterationManipDefaults
global subdivisionIterationManipUI

global mSICloseOpenUI

global mSIPoly
global mSIMeshsmooth
global mSITurbosmooth
global mSIOpenSubdiv

global mSIDo
global mSIApply
global mSIHelp
global mSILoadDef
global mSISaveDef

global mSIDefineUI
global mSIRollout
global mSIFloater

-- Includes

include "$scripts\SoulburnScripts\lib\sLib.ms"

-- Variables

mSIDirectionValue = 1
mSIPosValue = [400,400]

mSIAffectPolyValue = true
mSIAffectMeshsmoothValue = false
mSIAffectTurbosmoothValue = false
mSIAffectOpenSubdivValue = false

-- Functions

fn subdivisionIterationManip mSIAffectPoly mSIAffectMeshsmooth mSIAffectTurbosmooth mSIAffectOpenSubdiv mSIDirection = 
	(
	if mSIAffectPoly == true then mSIPoly mSIDirection
	if mSIAffectMeshsmooth == true then mSIMeshsmooth mSIDirection
	if mSIAffectTurbosmooth == true then mSITurbosmooth mSIDirection
	if mSIAffectOpenSubdiv == true then mSIOpenSubdiv mSIDirection	
	)

fn subdivisionIterationManipDefaults = 
	(
	mSILoadDef()
	subdivisionIterationManip mSIAffectPolyValue mSIAffectMeshsmoothValue mSIAffectTurbosmoothValue mSIAffectOpenSubdivValue mSIDirectionValue
	)
	
fn subdivisionIterationManipUI = 
	(
	mSILoadDef()
	mSICloseOpenUI mSIPosValue
	)

fn mSICloseOpenUI pos = 
	(
	if mSIFloater != undefined then CloseRolloutFloater mSIFloater
	mSIDefineUI()
	mSIFloater = newRolloutFloater "subdivisionIterationManip v1.08" 180 231 pos.x pos.y
	addRollout mSIRollout mSIFloater
	)

fn mSIPoly mSIDirection = 
	(
	undo "subdivisionIterationManip" on
		(	
		disableSceneRedraw()
		a = sLibRemoveUnneededInstancesFromArray selection
		for i in a do
			(
			if sLibEditablePolyFilter i == true then
				(
				if mSIDirection == 1 then
					(
					-- Up
					if i.surfSubdivide == off then 
						(
						i.surfSubdivide = on
						if i.iterations == 0 then i.iterations = 1
						)
					else i.iterations += 1
					)
				else
					(
					-- Down
					if i.iterations > 0 then i.iterations -= 1
					if i.iterations != 0 then i.surfSubdivide = on else i.surfSubdivide = off
					)
				)
			)
		enableSceneRedraw()
		completeRedraw()
		)
	)
	
fn mSIMeshsmooth mSIDirection = 
	(
	undo "subdivisionIterationManip" on
		(	
		disableSceneRedraw()
		try 
			(
			a = sLibRemoveUnneededInstancesFromArray selection
			-- Change Values
			for i in a do
				(
				if i.modifiers.count == 0 then continue
				else
					(
					for j = 1 to i.modifiers.count do
						(
						if classof i.modifiers[j] == MeshSmooth then
							(
							if (findString (i.modifiers[j].name as string) "_mSITag") == undefined then 
								(
								i.modifiers[j].name += "_mSITag"
								if mSIDirection == 1 then i.modifiers[j].iterations += 1
								else if i.modifiers[j].iterations > 0 then i.modifiers[j].iterations -= 1
								)
							)
						)
					)
				)
			-- Remove Tag
			for i in a do
				(
				if i.modifiers.count == 0 then continue
				else
					(
					for j = 1 to i.modifiers.count do
						(
						if classof i.modifiers[j] == MeshSmooth then
							(
							if (findString (i.modifiers[j].name as string) "_mSITag") != undefined then 
								(
								nameLength = (i.modifiers[j].name).count
								i.modifiers[j].name = substring (i.modifiers[j].name) 1 (nameLength - 7)
								)
							)
						)
					)				
				)
			)
		catch ()
		enableSceneRedraw()
		completeRedraw()
		)
	)
	
fn mSITurbosmooth mSIDirection = 
	(
	undo "subdivisionIterationManip" on
		(	
		disableSceneRedraw()
		try 
			(
			a = sLibRemoveUnneededInstancesFromArray selection
			-- Change Values
			for i in a do
				(
				if i.modifiers.count == 0 then continue
				else
					(
					for j = 1 to i.modifiers.count do
						(
						if classof i.modifiers[j] == TurboSmooth then
							(
							if (findString (i.modifiers[j].name as string) "_mSITag") == undefined then 
								(
								i.modifiers[j].name += "_mSITag"
								if mSIDirection == 1 then i.modifiers[j].iterations += 1
								else if i.modifiers[j].iterations > 0 then i.modifiers[j].iterations -= 1
								)
							)
						)
					)
				)
			-- Remove Tag
			for i in a do
				(
				if i.modifiers.count == 0 then continue
				else
					(
					for j = 1 to i.modifiers.count do
						(
						if classof i.modifiers[j] == TurboSmooth then
							(
							if (findString (i.modifiers[j].name as string) "_mSITag") != undefined then 
								(
								nameLength = (i.modifiers[j].name).count
								i.modifiers[j].name = substring (i.modifiers[j].name) 1 (nameLength - 7)
								)
							)
						)
					)				
				)
			)
		catch ()
		enableSceneRedraw()
		completeRedraw()
		)
	)
	
fn mSIOpenSubdiv mSIDirection = 
	(
	undo "subdivisionIterationManip" on
		(	
		disableSceneRedraw()
		try 
			(
			a = sLibRemoveUnneededInstancesFromArray selection
			-- Change Values
			for i in a do
				(
				if i.modifiers.count == 0 then continue
				else
					(
					for j = 1 to i.modifiers.count do
						(
						if classof i.modifiers[j] == OpenSubdiv then
							(
							if (findString (i.modifiers[j].name as string) "_mSITag") == undefined then 
								(
								i.modifiers[j].name += "_mSITag"
								if mSIDirection == 1 then i.modifiers[j].iterations += 1
								else if i.modifiers[j].iterations > 0 then i.modifiers[j].iterations -= 1
								)
							)
						)
					)
				)
			-- Remove Tag
			for i in a do
				(
				if i.modifiers.count == 0 then continue
				else
					(
					for j = 1 to i.modifiers.count do
						(
						if classof i.modifiers[j] == OpenSubdiv then
							(
							if (findString (i.modifiers[j].name as string) "_mSITag") != undefined then 
								(
								nameLength = (i.modifiers[j].name).count
								i.modifiers[j].name = substring (i.modifiers[j].name) 1 (nameLength - 7)
								)
							)
						)
					)				
				)
			)
		catch ()
		enableSceneRedraw()
		completeRedraw()
		)
	)
	
fn mSIDo = 
	(
	subdivisionIterationManip mSIAffectPolyValue mSIAffectMeshsmoothValue mSIAffectTurbosmoothValue mSIAffectOpenSubdivValue mSIDirectionValue
	if mSIFloater != undefined then CloseRolloutFloater mSIFloater
	)

fn mSIApply = 
	(
	subdivisionIterationManip mSIAffectPolyValue mSIAffectMeshsmoothValue mSIAffectTurbosmoothValue mSIAffectOpenSubdivValue mSIDirectionValue
	)
	
fn mSIHelp = 
	(
	sLibSSPrintHelp "subdivisionIterationManip"
	)
	
fn mSILoadDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	mSIInputFilename = presetDir + "subdivisionIterationManip.ini"
	if (sLibFileExist mSIInputFilename == true) then
		(
		mSIDirectionValue = execute (getINISetting mSIInputFilename "subdivisionIterationManip" "mSIDirectionValue")
		mSIAffectPolyValue = execute (getINISetting mSIInputFilename "subdivisionIterationManip" "mSIAffectPolyValue")
		mSIAffectMeshsmoothValue = execute (getINISetting mSIInputFilename "subdivisionIterationManip" "mSIAffectMeshsmoothValue")
		mSIAffectTurbosmoothValue = execute (getINISetting mSIInputFilename "subdivisionIterationManip" "mSIAffectTurbosmoothValue")
		mSIAffectOpenSubdivValue = execute (getINISetting mSIInputFilename "subdivisionIterationManip" "mSIAffectOpenSubdivValue")
		mSIPosValue = execute (getINISetting mSIInputFilename "subdivisionIterationManip" "mSIPosValue")
		
		if mSIDirectionValue == OK then mSIDirectionValue = 1
		if mSIAffectPolyValue == OK then mSIAffectPolyValue = true
		if mSIAffectMeshsmoothValue == OK then mSIAffectMeshsmoothValue = false
		if mSIAffectTurbosmoothValue == OK then mSIAffectTurbosmoothValue = false
		if mSIAffectOpenSubdivValue == OK then mSIAffectOpenSubdivValue = false
		if mSIPosValue == OK then mSIPosValue = [400,400]
		)
	else
		(
		mSIDirectionValue = 1
		mSIAffectPolyValue = true
		mSIAffectMeshsmoothValue = false
		mSIAffectTurbosmoothValue = false
		mSIAffectOpenSubdivValue = false
		mSIPosValue = [400,400]
		)
	)
	
fn mSISaveDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	if (getDirectories presetDir).count == 0 then makeDir presetDir
	mSIOutputFilename = presetDir + "subdivisionIterationManip.ini"
	if (sLibFileExist mSIOutputFilename == true) then deleteFile mSIOutputFilename
	setINISetting mSIOutputFilename "subdivisionIterationManip" "mSIDirectionValue" (mSIDirectionValue as string)
	setINISetting mSIOutputFilename "subdivisionIterationManip" "mSIAffectPolyValue" (mSIAffectPolyValue as string)
	setINISetting mSIOutputFilename "subdivisionIterationManip" "mSIAffectMeshsmoothValue" (mSIAffectMeshsmoothValue as string)
	setINISetting mSIOutputFilename "subdivisionIterationManip" "mSIAffectTurbosmoothValue" (mSIAffectTurbosmoothValue as string)
	setINISetting mSIOutputFilename "subdivisionIterationManip" "mSIAffectOpenSubdivValue" (mSIAffectOpenSubdivValue as string)
	setINISetting mSIOutputFilename "subdivisionIterationManip" "mSIPosValue" (mSIFloater.pos as string)
	)

-- UI

fn mSIDefineUI = 
	(
	rollout mSIRollout "subdivisionIterationManip"
		(
		radiobuttons mSIDirectionRadio labels:#("Increase Subdiv Iterations","Decrease Subdiv Iterations") default:mSIDirectionValue
		on mSIDirectionRadio changed state do mSIDirectionValue = state

		group "Affect:"
		(
		checkbox mSIAffectPolyCheckbox "Polyobject Subdivision" checked:mSIAffectPolyValue
		checkbox mSIAffectMeshsmoothCheckbox "Meshsmooth Modifiers" checked:mSIAffectMeshsmoothValue
		checkbox mSIAffectTurbosmoothCheckbox "Turbosmooth Modifiers" checked:mSIAffectTurbosmoothValue
		checkbox mSIAffectOpenSubdivCheckbox "OpenSubdiv Modifiers" checked:mSIAffectOpenSubdivValue
		)

		on mSIAffectPolyCheckbox changed state do mSIAffectPolyValue = state
		on mSIAffectMeshsmoothCheckbox changed state do mSIAffectMeshsmoothValue = state
		on mSIAffectTurbosmoothCheckbox changed state do mSIAffectTurbosmoothValue = state
		on mSIAffectOpenSubdivCheckbox changed state do mSIAffectOpenSubdivValue = state

		button mSIDoButton "Do" width:70 toolTip:"Do It and Close UI" pos:[11,150]
		on mSIDoButton pressed do mSIDo()
		button mSIApplyButton "Apply" width:70 toolTip:"Do It and Keep UI Open" pos:[83,150]
		on mSIApplyButton pressed do mSIApply()
		button mSIHelpButton "Help" width:70 toolTip:"Help" pos:[11,174]
		on mSIHelpButton pressed do mSIHelp()
		button mSISaveDefButton "SaveDef" width:70 toolTip:"Save Current Settings as Default" pos:[83,174]
		on mSISaveDefButton pressed do mSISaveDef()
		)
	)
)
-------------------------------------------------------------------------------