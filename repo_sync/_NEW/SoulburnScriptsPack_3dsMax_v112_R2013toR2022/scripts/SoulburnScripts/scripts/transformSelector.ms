-------------------------------------------------------------------------------
-- transformSelector.ms
-- By Neil Blevins (info@neilblevins.com)
-- v 1.07
-- Created On: 06/17/05
-- Modified On: 03/14/13
-- tested using Max 2011
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Required Files:
-- sLib.ms
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Description:
-- Lets you select objects based on their position, rotation or scale. Thanks 
-- to MrPoofe for the idea.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Tutorial:
-- Select the objects you want to process, choose your search criteria, then 
-- press do, it will select from those objects the ones that fit your criteria.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Revision History:
--
-- v 1.01 Now the scale spinners go negative allowing you to select things
-- that have a negative scale. A check is also performed to make sure that your
-- low value is not larger than your high value, and if they are, the values 
-- are swapped. Fixed a typo in the Global definitions.
--
-- v 1.02 Defined ui as new function.
--
-- v 1.03 Added some new code to more cleanly open and close the UI.
--
-- v 1.04 Added a fix to properly deselect objects.
--
-- v 1.05 Replaced the Close button with a Help button. Use the X button to 
-- Close the Floater.
--
-- v 1.06 Added ability to find non-reset transforms. Good for finding any 
-- objects that have no had their transforms reset.
--
-- v 1.07 Fixed a bug where the wrong values would be searched for in rotation.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
(
-- Globals

global transformSelector
global transformSelectorDefaults
global transformSelectorUI

global tSCloseOpenUI

global tSDo
global tSApply
global tSHelp
global tSLoadDef
global tSSaveDef

global tSDefineUI
global tSRollout
global tSFloater

-- Includes

include "$scripts\SoulburnScripts\lib\sLib.ms"

-- Variables

tSValueTypeValue = 1
tSModeValue = 2
tSAxisValue = 1
tSPosLowValue = -10
tSPosHighValue = 10
tSRotLowValue = -30
tSRotHighValue = 30
tSScaleLowValue = 90
tSScaleHighValue = 110
tSPosValue = [400,400]

-- Functions

fn transformSelector tSValueType tSMode tSAxis tSPosLow tSPosHigh tSRotLow tSRotHigh tSScaleLow tSScaleHigh = 
	(
	undo "transformSelector" on
		(
		-- Check that high value is not lower than low value
		if tSPosLow > tSPosHigh then 
			(
			w = tSPosLow
			tSPosLow = tSPosHigh
			tSPosHigh = w
			)
		if tSRotLow > tSRotHigh then 
			(
			w = tSRotLow
			tSRotLow = tSRotHigh
			tSRotHigh = w
			)
		if tSScaleLow > tSScaleHigh then 
			(
			w = tSScaleLow
			tSScaleLow = tSScaleHigh
			tSScaleHigh = w
			)
		
		-- Perform selection
		a = #()
		for i in selection do
			(
			if tSValueType == 1 then
				(
				if tSMode == 1 then
					(
					-- Position
					if tSAxis == 1 then (if i.pos.x <= tSPosHigh and i.pos.x >= tSPosLow then append a i)
					else if tSAxis == 2 then (if i.pos.y <= tSPosHigh and i.pos.y >= tSPosLow then append a i)
					else if tSAxis == 3 then (if i.pos.z <= tSPosHigh and i.pos.z >= tSPosLow then append a i)
					)
				else if tSMode == 2 then
					(
					-- Rotation
					if tSAxis == 1 then (if i.rotation.x_rotation <= tSRotHigh and i.rotation.x_rotation >= tSRotLow then append a i)
					else if tSAxis == 2 then (if i.rotation.y_rotation <= tSRotHigh and i.rotation.y_rotation >= tSRotLow then append a i)
					else if tSAxis == 3 then (if i.rotation.z_rotation <= tSRotHigh and i.rotation.z_rotation >= tSRotLow then append a i)
					)
				else if tSMode == 3 then
					(
					-- Scale
					if tSAxis == 1 then (if i.scale.x <= tSScaleHigh*0.01 and i.scale.x >= tSScaleLow*0.01 then append a i)
					else if tSAxis == 2 then (if i.scale.y <= tSScaleHigh*0.01 and i.scale.y >= tSScaleLow*0.01 then append a i)
					else if tSAxis == 3 then (if i.scale.z <= tSScaleHigh*0.01 and i.scale.z >= tSScaleLow*0.01 then append a i)
					)
				)
			else if tSValueType == 2 then
				(
				if tSMode == 1 then
					(
					if i.pos != [0,0,0] then append a i
					)
				else if tSMode == 2 then
					(
					if i.rotation != (quat 0 0 0 1) then append a i
					)
				else if tSMode == 3 then
					(
					if i.scale != [1,1,1] then append a i
					)
				)
			)
		deselect selection
		select a
		)
	)
	
fn transformSelectorDefaults = 
	(
	tSLoadDef()
	transformSelector tSValueTypeValue tSModeValue tSAxisValue tSPosLowValue tSPosHighValue tSRotLowValue tSRotHighValue tSScaleLowValue tSScaleHighValue
	)

fn transformSelectorUI = 
	(
	tSLoadDef()
	tSCloseOpenUI tSPosValue
	)
	
fn tSCloseOpenUI pos = 
	(
	if tSFloater != undefined then CloseRolloutFloater tSFloater
	tSDefineUI()
	tSFloater = newRolloutFloater "transformSelector v1.07" 166 371 pos.x pos.y
	addRollout tSRollout tSFloater
	)

fn tSDo = 
	(
	transformSelector tSValueTypeValue tSModeValue tSAxisValue tSPosLowValue tSPosHighValue tSRotLowValue tSRotHighValue tSScaleLowValue tSScaleHighValue
	if tSFloater != undefined then CloseRolloutFloater tSFloater
	)

fn tSApply = 
	(
	transformSelector tSValueTypeValue tSModeValue tSAxisValue tSPosLowValue tSPosHighValue tSRotLowValue tSRotHighValue tSScaleLowValue tSScaleHighValue
	)
	
fn tSHelp = 
	(
	sLibSSPrintHelp "transformSelector"
	)
	
fn tSLoadDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	tSInputFilename = presetDir + "transformSelector.ini"
	if (sLibFileExist tSInputFilename == true) then
		(
		tSValueTypeValue = execute (getINISetting tSInputFilename "transformSelector" "tSValueTypeValue")
		tSModeValue = execute (getINISetting tSInputFilename "transformSelector" "tSModeValue")
		tSAxisValue = execute (getINISetting tSInputFilename "transformSelector" "tSAxisValue")
		tSPosLowValue = execute (getINISetting tSInputFilename "transformSelector" "tSPosLowValue")
		tSPosHighValue = execute (getINISetting tSInputFilename "transformSelector" "tSPosHighValue")
		tSRotLowValue = execute (getINISetting tSInputFilename "transformSelector" "tSRotLowValue")
		tSRotHighValue = execute (getINISetting tSInputFilename "transformSelector" "tSRotHighValue")
		tSScaleLowValue = execute (getINISetting tSInputFilename "transformSelector" "tSScaleLowValue")
		tSScaleHighValue = execute (getINISetting tSInputFilename "transformSelector" "tSScaleHighValue")
		tSPosValue = execute (getINISetting tSInputFilename "transformSelector" "tSPosValue")
		
		if tSValueTypeValue == OK then tSValueTypeValue = 1
		if tSModeValue == OK then tSModeValue = 2
		if tSAxisValue == OK then tSAxisValue = 1
		if tSPosLowValue == OK then tSPosLowValue = -10
		if tSPosHighValue == OK then tSPosHighValue = 10
		if tSRotLowValue == OK then tSRotLowValue = -30
		if tSRotHighValue == OK then tSRotHighValue = 30	
		if tSScaleLowValue == OK then tSScaleLowValue = 90
		if tSScaleHighValue == OK then tSScaleHighValue = 110
		if tSPosValue == OK then tSPosValue = [400,400]
		)
	else
		(
		tSValueTypeValue = 1
		tSModeValue = 2
		tSAxisValue = 1
		tSPosLowValue = -10
		tSPosHighValue = 10
		tSRotLowValue = -30
		tSRotHighValue = 30
		tSScaleLowValue = 90
		tSScaleHighValue = 110
		tSPosValue = [400,400]
		)
	)
	
fn tSSaveDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	if (getDirectories presetDir).count == 0 then makeDir presetDir
	tSOutputFilename = presetDir + "transformSelector.ini"
	if (sLibFileExist tSOutputFilename == true) then deleteFile tSOutputFilename
	setINISetting tSOutputFilename "transformSelector" "tSValueTypeValue" (tSValueTypeValue as string)
	setINISetting tSOutputFilename "transformSelector" "tSModeValue" (tSModeValue as string)
	setINISetting tSOutputFilename "transformSelector" "tSAxisValue" (tSAxisValue as string)
	setINISetting tSOutputFilename "transformSelector" "tSPosLowValue" (tSPosLowValue as string)
	setINISetting tSOutputFilename "transformSelector" "tSPosHighValue" (tSPosHighValue as string)
	setINISetting tSOutputFilename "transformSelector" "tSRotLowValue" (tSRotLowValue as string)
	setINISetting tSOutputFilename "transformSelector" "tSRotHighValue" (tSRotHighValue as string)
	setINISetting tSOutputFilename "transformSelector" "tSScaleLowValue" (tSScaleLowValue as string)
	setINISetting tSOutputFilename "transformSelector" "tSScaleHighValue" (tSScaleHighValue as string)
	setINISetting tSOutputFilename "transformSelector" "tSPosValue" (tSFloater.pos as string)
	)

-- UI

fn tSDefineUI = 
	(
	rollout tSRollout "transformSelector"
		(
		dropdownlist tSValueTypeDropdown "" items:#("Specific Value", "Non-Reset All-Axis Value") selection:tSValueTypeValue align:#center
		dropdownlist tSModeDropdown "" items:#("Position", "Rotation", "Scale") selection:tSModeValue align:#center
		dropdownlist tSAxisDropdown "" items:#("Local X Axis", "Local Y Axis", "Local Z Axis") selection:tSAxisValue align:#center

		group "Position"
		(
		spinner tSPosLowSpinner "Low: " range:[-99999999,99999999,tSPosLowValue] fieldWidth:55 type:#float
		spinner tSPosHighSpinner "High: " range:[-99999999,99999999,tSPosHighValue] fieldWidth:55 type:#float
		)
		on tSPosLowSpinner changed val do tSPosLowValue = val
		on tSPosHighSpinner changed val do tSPosHighValue = val

		group "Rotate"
		(
		spinner tSRotLowSpinner "Low: " range:[-99999999,99999999,tSRotLowValue] fieldWidth:55 type:#float
		spinner tSRotHighSpinner "High: " range:[-99999999,99999999,tSRotHighValue] fieldWidth:55 type:#float
		)
		on tSRotLowSpinner changed val do tSRotLowValue = val
		on tSRotHighSpinner changed val do tSRotHighValue = val

		group "Scale"
		(
		spinner tSScaleLowSpinner "Low: " range:[-99999999,99999999,tSScaleLowValue] fieldWidth:55 type:#float
		spinner tSScaleHighSpinner "High: " range:[-99999999,99999999,tSScaleHighValue] fieldWidth:55 type:#float
		)
		on tSScaleLowSpinner changed val do tSScaleLowValue = val
		on tSScaleHighSpinner changed val do tSScaleHighValue = val

		on tSValueTypeDropdown selected i do 
			(
			tSValueTypeValue = i
			curPos = tSFloater.pos
			tSCloseOpenUI curPos
			)
		on tSModeDropdown selected i do 
			(
			tSModeValue = i
			curPos = tSFloater.pos
			tSCloseOpenUI curPos
			)
		on tSAxisDropdown selected i do tSAxisValue = i

		button tSDoButton "Do" width:70 toolTip:"Do It and Close UI" pos:[5,290]
		on tSDoButton pressed do tSDo()
		button tSApplyButton "Apply" width:70 toolTip:"Do It and Keep UI Open" pos:[77,290]
		on tSApplyButton pressed do tSApply()
		button tSHelpButton "Help" width:70 toolTip:"Help" pos:[5,314]
		on tSHelpButton pressed do tSHelp()
		button tSSaveDefButton "SaveDef" width:70 toolTip:"Save Current Settings as Default" pos:[77,314]
		on tSSaveDefButton pressed do tSSaveDef()

		on tSRollout open do
			(
			if tSValueTypeValue == 2 then
				(
				tSAxisDropdown.enabled = false
				tSPosLowSpinner.enabled = false
				tSPosHighSpinner.enabled = false
				tSRotLowSpinner.enabled = false
				tSRotHighSpinner.enabled = false
				tSScaleLowSpinner.enabled = false
				tSScaleHighSpinner.enabled = false				
				)
			else if tSModeValue == 1 then 
				(
				tSAxisDropdown.enabled = true
				tSPosLowSpinner.enabled = true
				tSPosHighSpinner.enabled = true
				tSRotLowSpinner.enabled = false
				tSRotHighSpinner.enabled = false
				tSScaleLowSpinner.enabled = false
				tSScaleHighSpinner.enabled = false
				)
			else if tSModeValue == 2 then 
				(
				tSAxisDropdown.enabled = true
				tSPosLowSpinner.enabled = false
				tSPosHighSpinner.enabled = false
				tSRotLowSpinner.enabled = true
				tSRotHighSpinner.enabled = true
				tSScaleLowSpinner.enabled = false
				tSScaleHighSpinner.enabled = false
				)
			else if tSModeValue == 3 then 
				(
				tSAxisDropdown.enabled = true
				tSPosLowSpinner.enabled = false
				tSPosHighSpinner.enabled = false
				tSRotLowSpinner.enabled = false
				tSRotHighSpinner.enabled = false
				tSScaleLowSpinner.enabled = true
				tSScaleHighSpinner.enabled = true
				)
			)
		)
	)
)
-------------------------------------------------------------------------------