-------------------------------------------------------------------------------
-- transformRandomizer.ms
-- By Neil Blevins (info@neilblevins.com)
-- v 1.08
-- Created On: 06/04/05
-- Modified On: 11/17/13
-- tested using Max 2014
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Required Files:
-- sLib.ms
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Description:
-- Lets you translate, rotate and scale a group of objects or modifier gizmos 
-- by a random amount.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Tutorial:
-- Select a bunch of objects. Run the UI version of the script. Make sure
-- "Object" is selected" Hit the RXYZ button. All the objects will move a 
-- random amount in X Y and Z between -1 and 1.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Revision History:
--
-- v 1.01 Renamed a bad variable.
--
-- v 1.02 Defined ui as new function.
--
-- v 1.03 Added some new code to more cleanly open and close the UI.
--
-- v 1.04 Fixed a bug that stopped the script from running in Defaults mode.
--
-- v 1.05 Added ability to transform the gizmo position of a modifier.
--
-- v 1.06 Fixed a bug where groups would get double transformed.
--
-- v 1.07 Replaced the Close button with a Help button. Use the X button to 
-- Close the Floater.
--
-- v 1.08 Fixed Translation and Scale of objects so they now respect the current 
-- Reference Coordinate System. Thanks to Simone Nastasi for the request and 
-- for some initial code.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Known Issues:
-- Modifier Gizmo Translation and Scale doesn't respect the current Reference 
-- Coordinate System
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
(
-- Globals

global transformRandomizerDefaults
global transformRandomizerUI

global tRACloseOpenUI

global tRATranslation
global tRARotation
global tRAScale
global tRAMakeModifierList

global tRAHelp
global tRALoadDef
global tRASaveDef

global tRADefineUI
global tRARollout
global tRAFloater

-- Includes

include "$scripts\SoulburnScripts\lib\sLib.ms"

-- Variables

global tRAModifierNameList = #()

tRAModeValue = 1
tRAAxisValue = 1
tRATransLowValue = -1
tRATransHighValue = 1
tRARotLowValue = -5
tRARotHighValue = 5
tRAScaleLowValue = 90
tRAScaleHighValue = 110
tRAGroupsValue = true
tRAModifyWhatValue = 1
tRAModifierValue = 1
tRAPosValue = [400,400]

-- Functions

fn transformRandomizerDefaults = 
	(
	tRALoadDef()
	tRAMakeModifierList()
	if tRAModeValue == 1 then tRATranslation tRAAxisValue tRATransLowValue tRATransHighValue tRAGroupsValue tRAModifyWhatValue (tRAModifierNameList[tRAModifierValue])
	else if tRAModeValue == 2 then tRARotation tRAAxisValue tRARotLowValue tRARotHighValue tRAGroupsValue tRAModifyWhatvalue (tRAModifierNameList[tRAModifierValue])
	else if tRAModeValue == 3 then tRAScale tRAAxisValue tRAScaleLowValue tRAScaleHighValue tRAGroupsValue tRAModifyWhatValue (tRAModifierNameList[tRAModifierValue])
	)

fn transformRandomizerUI = 
	(
	tRALoadDef()
	tRACloseOpenUI tRAPosValue
	)
	
fn tRACloseOpenUI pos = 
	(
	if tRAFloater != undefined then CloseRolloutFloater tRAFloater
	tRADefineUI()
	tRAFloater = newRolloutFloater "transformRandomizer v1.08" 540 218 pos.x pos.y
	addRollout tRARollout tRAFloater
	)

fn tRATranslation tRAAxis tRATransLow tRATransHigh tRAGroups tRAModifyWhat tRAModifier = 
	(
	undo "transformRandomizer" on
		(
		for obj in selection do
			(
			if isgroupmember obj == true and tRAGroups == true then continue
			else
				(
				if isgrouphead obj == true and tRAGroups == false then continue
				else
					(
					-- Figure Out Current Coordinate System
					coordtypes = #("world", "local", "parent", "screen")
					coord = (getRefCoordSys() as string)
					if (findItem coordtypes coord) != 0 then mycoord = coord else mycoord = "world"
					
					if tRAModifyWhat == 1 then 
						(
						if tRAAxis == 1 then in coordsys (mycoord as name) obj.pos.x += random tRATransLow tRATransHigh
						if tRAAxis == 2 then in coordsys (mycoord as name) obj.pos.y += random tRATransLow tRATransHigh
						if tRAAxis == 3 then in coordsys (mycoord as name) obj.pos.z += random tRATransLow tRATransHigh
						if tRAAxis == 4 then in coordsys (mycoord as name) obj.pos += [(random tRATransLow tRATransHigh),(random tRATransLow tRATransHigh),(random tRATransLow tRATransHigh)]
						if tRAAxis == 5 then 
							(
							sharedValue = (random tRATransLow tRATransHigh)
							in coordsys (mycoord as name) obj.pos += [sharedValue,sharedValue,sharedValue]
							)
						)
					else 
						(
						theMod = (execute tRAModifier)
						for j in obj.modifiers do
							(
							if classof j == theMod then
								(
								try
									(
									if tRAAxis == 1 then j.gizmo.pos.x += random tRATransLow tRATransHigh
									if tRAAxis == 2 then j.gizmo.pos.y += random tRATransLow tRATransHigh
									if tRAAxis == 3 then j.gizmo.pos.z += random tRATransLow tRATransHigh
									if tRAAxis == 4 then j.gizmo.pos += [(random tRATransLow tRATransHigh),(random tRATransLow tRATransHigh),(random tRATransLow tRATransHigh)]
									if tRAAxis == 5 then 
										(
										sharedValue = (random tRATransLow tRATransHigh)
										j.gizmo.pos += [sharedValue,sharedValue,sharedValue]
										)
									)
								catch ()
								)
							)
						)
					)
				)
			)
		)
	)
	
fn tRARotation tRAAxis tRARotLow tRARotHigh tRAGroups tRAModifyWhat tRAModifier = 
	(
	undo "transformRandomizer" on
		(
		for obj in selection do
			(
			if isgroupmember obj == true and tRAGroups == true then continue
			else
				(
				if isgrouphead obj == true and tRAGroups == false then continue
				else
					(
					if tRAModifyWhat == 1 then 
						(
						xValue = 0
						yValue = 0
						zValue = 0
						if tRAAxis == 1 then xValue = (angleaxis (random tRARotLow tRARotHigh) [1,0,0])
						if tRAAxis == 2 then yValue = (angleaxis (random tRARotLow tRARotHigh) [0,1,0])
						if tRAAxis == 3 then zValue = (angleaxis (random tRARotLow tRARotHigh) [0,0,1])
						if tRAAxis == 4 then 
							(
							xValue = (angleaxis (random tRARotLow tRARotHigh) [1,0,0])
							yValue = (angleaxis (random tRARotLow tRARotHigh) [0,1,0])
							zValue = (angleaxis (random tRARotLow tRARotHigh) [0,0,1])
							)
						if tRAAxis == 5 then	
							(
							ranValue = (random tRARotLow tRARotHigh)
							xValue = (angleaxis ranValue [1,0,0])
							yValue = (angleaxis ranValue [0,1,0])
							zValue = (angleaxis ranValue [0,0,1])
							)
						if xValue != 0 then sLibRotateObjByAxis obj xValue
						if yValue != 0 then sLibRotateObjByAxis obj yValue
						if zValue != 0 then sLibRotateObjByAxis obj zValue
						)
					else 
						(
						theMod = (execute tRAModifier)
						for j in obj.modifiers do
							(
							if classof j == theMod then
								(
								try
									(
									xValue = 0
									yValue = 0
									zValue = 0
									if tRAAxis == 1 then xValue = (angleaxis (random tRARotLow tRARotHigh) [1,0,0])
									if tRAAxis == 2 then yValue = (angleaxis (random tRARotLow tRARotHigh) [0,1,0])
									if tRAAxis == 3 then zValue = (angleaxis (random tRARotLow tRARotHigh) [0,0,1])
									if tRAAxis == 4 then 
										(
										xValue = (angleaxis (random tRARotLow tRARotHigh) [1,0,0])
										yValue = (angleaxis (random tRARotLow tRARotHigh) [0,1,0])
										zValue = (angleaxis (random tRARotLow tRARotHigh) [0,0,1])
										)
									if tRAAxis == 5 then	
										(
										ranValue = (random tRARotLow tRARotHigh)
										xValue = (angleaxis ranValue [1,0,0])
										yValue = (angleaxis ranValue [0,1,0])
										zValue = (angleaxis ranValue [0,0,1])
										)
									if xValue != 0 then j.gizmo.rotation += (xValue as quat)
									if yValue != 0 then j.gizmo.rotation += (yValue as quat)
									if zValue != 0 then j.gizmo.rotation += (zValue as quat)
									)
								catch ()
								)
							)
						)
					)				
				)
			)
		)
	)
	
fn tRAScale tRAAxis tRAScaleLow tRAScaleHigh tRAGroups tRAModifyWhat tRAModifier = 
	(
	undo "transformRandomizer" on
		(
		tRANormalizedScaleLow = tRAScaleLow * 0.01
		tRANormalizedScaleHigh = tRAScaleHigh * 0.01
		for obj in selection do
			(
			if isgroupmember obj == true and tRAGroups == true then continue
			else
				(
				if isgrouphead obj == true and tRAGroups == false then continue
				else
					(
					-- Figure Out Current Coordinate System
					coordtypes = #("world", "local", "parent", "screen")
					coord = (getRefCoordSys() as string)
					if (findItem coordtypes coord) != 0 then mycoord = coord else mycoord = "world"
					
					if tRAModifyWhat == 1 then 
						(
						if tRAAxis == 1 then in coordsys (mycoord as name) scale obj [random tRANormalizedScaleLow tRANormalizedScaleHigh, 1, 1]
						if tRAAxis == 2 then in coordsys (mycoord as name) scale obj [1, random tRANormalizedScaleLow tRANormalizedScaleHigh, 1]
						if tRAAxis == 3 then in coordsys (mycoord as name) scale obj [1, 1, random tRANormalizedScaleLow tRANormalizedScaleHigh]
						if tRAAxis == 4 then in coordsys (mycoord as name) scale obj [(random tRANormalizedScaleLow tRANormalizedScaleHigh),(random tRANormalizedScaleLow tRANormalizedScaleHigh),(random tRANormalizedScaleLow tRANormalizedScaleHigh)]
						if tRAAxis == 5 then 
							(
							sharedValue = (random tRANormalizedScaleLow tRANormalizedScaleHigh)
							in coordsys (mycoord as name) scale obj [sharedValue,sharedValue,sharedValue]
							)
						)
					else 
						(
						theMod = (execute tRAModifier)
						for j in obj.modifiers do
							(
							if classof j == theMod then
								(
								try
									(
									if tRAAxis == 1 then j.gizmo.scale.x *= random tRANormalizedScaleLow tRANormalizedScaleHigh
									if tRAAxis == 2 then j.gizmo.scale.y *= random tRANormalizedScaleLow tRANormalizedScaleHigh
									if tRAAxis == 3 then j.gizmo.scale.z *= random tRANormalizedScaleLow tRANormalizedScaleHigh
									if tRAAxis == 4 then j.gizmo.scale *= [(random tRANormalizedScaleLow tRANormalizedScaleHigh),(random tRANormalizedScaleLow tRANormalizedScaleHigh),(random tRANormalizedScaleLow tRANormalizedScaleHigh)]
									if tRAAxis == 5 then 
										(
										sharedValue = (random tRANormalizedScaleLow tRANormalizedScaleHigh)
										j.gizmo.scale *= [sharedValue,sharedValue,sharedValue]
										)
									)
								catch ()
								)
							)
						)
					)
				)
			)
		)
	)

fn tRAMakeModifierList = 
	(
	tRAModifierList = #()
	tRAModifierNameList = #()
	tRAModifierList = for c in modifier.classes where c.creatable collect c
	for i in tRAModifierList do append tRAModifierNameList (i as string)
	qsort tRAModifierNameList sLibCompareCaseInsensitive
	)

fn tRAHelp = 
	(
	sLibSSPrintHelp "transformRandomizer"
	)
	
fn tRALoadDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	tRAInputFilename = presetDir + "transformRandomizer.ini"
	if (sLibFileExist tRAInputFilename == true) then
		(
		tRAModeValue = execute (getINISetting tRAInputFilename "transformRandomizer" "tRAModeValue")
		tRAAxisValue = execute (getINISetting tRAInputFilename "transformRandomizer" "tRAAxisValue")
		tRATransLowValue = execute (getINISetting tRAInputFilename "transformRandomizer" "tRATransLowValue")
		tRATransHighValue = execute (getINISetting tRAInputFilename "transformRandomizer" "tRATransHighValue")
		tRARotLowValue = execute (getINISetting tRAInputFilename "transformRandomizer" "tRARotLowValue")
		tRARotHighValue = execute (getINISetting tRAInputFilename "transformRandomizer" "tRARotHighValue")
		tRAScaleLowValue = execute (getINISetting tRAInputFilename "transformRandomizer" "tRAScaleLowValue")
		tRAScaleHighValue = execute (getINISetting tRAInputFilename "transformRandomizer" "tRAScaleHighValue")
		tRAGroupsValue = execute (getINISetting tRAInputFilename "transformRandomizer" "tRAGroupsValue")
		tRAModifyWhatValue = execute (getINISetting tRAInputFilename "transformRandomizer" "tRAModifyWhatValue")
		tRAModifierValue = execute (getINISetting tRAInputFilename "transformRandomizer" "tRAModifierValue")
		tRAPosValue = execute (getINISetting tRAInputFilename "transformRandomizer" "tRAPosValue")
		
		if tRAModeValue == OK then tRAModeValue = 1
		if tRAAxisValue == OK then tRAAxisValue = 1
		if tRATransLowValue == OK then tRATransLowValue = -1
		if tRATransHighValue == OK then tRATransHighValue = 1
		if tRARotLowValue == OK then tRARotLowValue = -5
		if tRARotHighValue == OK then tRARotHighValue = 5	
		if tRAScaleLowValue == OK then tRAScaleLowValue = 90
		if tRAScaleHighValue == OK then tRAScaleHighValue = 110
		if tRAGroupsValue == OK then tRAGroupsValue = true
		if tRAModifyWhatValue == OK then tRAModifyWhatValue = 1
		if tRAModifierValue == OK then tRAModifierValue = 1
		if tRAPosValue == OK then tRAPosValue = [400,400]
		)
	else
		(
		tRAModeValue = 1
		tRAAxisValue = 1
		tRATransLowValue = -1
		tRATransHighValue = 1
		tRARotLowValue = -5
		tRARotHighValue = 5
		tRAScaleLowValue = 90
		tRAScaleHighValue = 110
		tRAGroupsValue = true
		tRAModifyWhatValue = 1
		tRAModifierValue = 1
		tRAPosValue = [400,400]
		)
	)
	
fn tRASaveDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	if (getDirectories presetDir).count == 0 then makeDir presetDir
	tRAOutputFilename = presetDir + "transformRandomizer.ini"
	if (sLibFileExist tRAOutputFilename == true) then deleteFile tRAOutputFilename
	setINISetting tRAOutputFilename "transformRandomizer" "tRAModeValue" (tRAModeValue as string)
	setINISetting tRAOutputFilename "transformRandomizer" "tRAAxisValue" (tRAAxisValue as string)
	setINISetting tRAOutputFilename "transformRandomizer" "tRATransLowValue" (tRATransLowValue as string)
	setINISetting tRAOutputFilename "transformRandomizer" "tRATransHighValue" (tRATransHighValue as string)
	setINISetting tRAOutputFilename "transformRandomizer" "tRARotLowValue" (tRARotLowValue as string)
	setINISetting tRAOutputFilename "transformRandomizer" "tRARotHighValue" (tRARotHighValue as string)
	setINISetting tRAOutputFilename "transformRandomizer" "tRAScaleLowValue" (tRAScaleLowValue as string)
	setINISetting tRAOutputFilename "transformRandomizer" "tRAScaleHighValue" (tRAScaleHighValue as string)
	setINISetting tRAOutputFilename "transformRandomizer" "tRAGroupsValue" (tRAGroupsValue as string)
	setINISetting tRAOutputFilename "transformRandomizer" "tRAModifyWhatValue" (tRAModifyWhatValue as string)
	setINISetting tRAOutputFilename "transformRandomizer" "tRAModifyWhatValue" (tRAModifyWhatValue as string)
	setINISetting tRAOutputFilename "transformRandomizer" "tRAModifierValue" (tRAModifierValue as string)
	setINISetting tRAOutputFilename "transformRandomizer" "tRAPosValue" (tRAFloater.pos as string)
	)

-- UI

fn tRADefineUI = 
	(
	rollout tRARollout "transformRandomizer"
		(
		group "Translate"
		(
		button tRATRXButton "RX" width:60 toolTip:"Random X Translation" align:#left
		button tRATRYButton "RY" width:60 toolTip:"Random Y Translation" pos:[75,26]
		button tRATRZButton "RZ" width:60 toolTip:"Random Z Translation" pos:[137,26]
		button tRATRXRYRZButton "RXRXRZ" width:60 toolTip:"Random X Random Y Random Z Translation" pos:[199,26]
		button tRATRXYZButton "RXYZ" width:60 toolTip:"Random X Y Z Translation" pos:[261,26]
		spinner tRATransLowSpinner "Low: " range:[-99999999,99999999,tRATransLowValue] fieldWidth:55 type:#float pos:[325,30]
		spinner tRATransHighSpinner "High: " range:[-99999999,99999999,tRATransHighValue] fieldWidth:55 type:#float pos:[423,30]
		)

		on tRATRXButton pressed do 
			(
			tRAModeValue = 1
			tRAAxisValue = 1
			tRATranslation tRAAxisValue tRATransLowValue tRATransHighValue tRAGroupsValue tRAModifyWhatValue (tRAModifierNameList[tRAModifierValue])
			)
		on tRATRYButton pressed do
			(
			tRAModeValue = 1
			tRAAxisValue = 2
			tRATranslation tRAAxisValue tRATransLowValue tRATransHighValue tRAGroupsValue tRAModifyWhatValue (tRAModifierNameList[tRAModifierValue])
			)
		on tRATRZButton pressed do
			(
			tRAModeValue = 1
			tRAAxisValue = 3
			tRATranslation tRAAxisValue tRATransLowValue tRATransHighValue tRAGroupsValue tRAModifyWhatValue (tRAModifierNameList[tRAModifierValue])
			)
		on tRATRXRYRZButton pressed do
			(
			tRAModeValue = 1
			tRAAxisValue = 4
			tRATranslation tRAAxisValue tRATransLowValue tRATransHighValue tRAGroupsValue tRAModifyWhatValue (tRAModifierNameList[tRAModifierValue])
			)
		on tRATRXYZButton pressed do
			(
			tRAModeValue = 1
			tRAAxisValue = 5
			tRATranslation tRAAxisValue tRATransLowValue tRATransHighValue tRAGroupsValue tRAModifyWhatValue (tRAModifierNameList[tRAModifierValue])
			)
		on tRATransLowSpinner changed val do tRATransLowValue = val
		on tRATransHighSpinner changed val do tRATransHighValue = val

		group "Rotate"
		(
		button tRARRXButton "RX" width:60 toolTip:"Random X Rotation" align:#left
		button tRARRYButton "RY" width:60 toolTip:"Random Y Rotation" pos:[75,76]
		button tRARRZButton "RZ" width:60 toolTip:"Random Z Rotation" pos:[137,76]
		button tRARRXRYRZButton "RXRXRZ" width:60 toolTip:"Random X Random Y Random Z Rotation" pos:[199,76]
		button tRARRXYZButton "RXYZ" width:60 toolTip:"Random X Y Z Rotation" pos:[261,76]
		spinner tRARotLowSpinner "Low: " range:[-99999999,99999999,tRARotLowValue] fieldWidth:55 type:#float pos:[325,80]
		spinner tRARotHighSpinner "High: " range:[-99999999,99999999,tRARotHighValue] fieldWidth:55 type:#float pos:[423,80]
		)

		on tRARRXButton pressed do
			(
			tRAModeValue = 2
			tRAAxisValue = 1
			tRARotation tRAAxisValue tRARotLowValue tRARotHighValue tRAGroupsValue tRAModifyWhatValue (tRAModifierNameList[tRAModifierValue])
			)
		on tRARRYButton pressed do
			(
			tRAModeValue = 2
			tRAAxisValue = 2
			tRARotation tRAAxisValue tRARotLowValue tRARotHighValue tRAGroupsValue tRAModifyWhatValue (tRAModifierNameList[tRAModifierValue])
			)
		on tRARRZButton pressed do
			(
			tRAModeValue = 2
			tRAAxisValue = 3
			tRARotation tRAAxisValue tRARotLowValue tRARotHighValue tRAGroupsValue tRAModifyWhatValue (tRAModifierNameList[tRAModifierValue])
			)
		on tRARRXRYRZButton pressed do
			(
			tRAModeValue = 2
			tRAAxisValue = 4
			tRARotation tRAAxisValue tRARotLowValue tRARotHighValue tRAGroupsValue tRAModifyWhatValue (tRAModifierNameList[tRAModifierValue])
			)
		on tRARRXYZButton pressed do
			(
			tRAModeValue = 2
			tRAAxisValue = 5
			tRARotation tRAAxisValue tRARotLowValue tRARotHighValue tRAGroupsValue tRAModifyWhatValue (tRAModifierNameList[tRAModifierValue])
			)
		on tRARotLowSpinner changed val do tRARotLowValue = val
		on tRARotHighSpinner changed val do tRARotHighValue = val

		group "Scale"
		(
		button tRASRXButton "RX" width:60 toolTip:"Random X Scale" align:#left
		button tRASRYButton "RY" width:60 toolTip:"Random Y Scale" pos:[75,126]
		button tRASRZButton "RZ" width:60 toolTip:"Random Z Scale" pos:[137,126]
		button tRASRXRYRZButton "RXRXRZ" width:60 toolTip:"Random X Random Y Random Z Scale" pos:[199,126]
		button tRASRXYZButton "RXYZ" width:60 toolTip:"Random X Y Z Scale" pos:[261,126]
		spinner tRAScaleLowSpinner "Low: " range:[0,99999999,tRAScaleLowValue] fieldWidth:55 type:#float pos:[325,130]
		spinner tRAScaleHighSpinner "High: " range:[0,99999999,tRAScaleHighValue] fieldWidth:55 type:#float pos:[423,130]
		)

		on tRASRXButton pressed do
			(
			tRAModeValue = 3
			tRAAxisValue = 1
			tRAScale tRAAxisValue tRAScaleLowValue tRAScaleHighValue tRAGroupsValue tRAModifyWhatValue (tRAModifierNameList[tRAModifierValue])
			)
		on tRASRYButton pressed do
			(
			tRAModeValue = 3
			tRAAxisValue = 2
			tRAScale tRAAxisValue tRAScaleLowValue tRAScaleHighValue tRAGroupsValue tRAModifyWhatValue (tRAModifierNameList[tRAModifierValue])
			)	
		on tRASRZButton pressed do
			(
			tRAModeValue = 3
			tRAAxisValue = 3
			tRAScale tRAAxisValue tRAScaleLowValue tRAScaleHighValue tRAGroupsValue tRAModifyWhatValue (tRAModifierNameList[tRAModifierValue])
			)
		on tRASRXRYRZButton pressed do
			(
			tRAModeValue = 3
			tRAAxisValue = 4
			tRAScale tRAAxisValue tRAScaleLowValue tRAScaleHighValue tRAGroupsValue tRAModifyWhatValue (tRAModifierNameList[tRAModifierValue])
			)
		on tRASRXYZButton pressed do
			(
			tRAModeValue = 3
			tRAAxisValue = 5
			tRAScale tRAAxisValue tRAScaleLowValue tRAScaleHighValue tRAGroupsValue tRAModifyWhatValue (tRAModifierNameList[tRAModifierValue])
			)
		on tRAScaleLowSpinner changed val do tRAScaleLowValue = val
		on tRAScaleHighSpinner changed val do tRAScaleHighValue = val

		checkbox tRAGroupsCheckbox "Treat Group As 1 Obj" checked:tRAGroupsValue align:#left offset:[0,4] across:3
		dropdownlist tRAModifyWhatDropdown "" items:#("Object", "Modifier Gizmo") width:95 selection:tRAModifyWhatValue offset:[-35,3]
		dropdownlist tRAModifierListDropdown "" items:tRAModifierNameList width:130 selection:tRAModifierValue offset:[-103,3] height:20
		on tRAGroupsCheckbox changed state do tRAGroupsValue = state
		on tRAModifyWhatDropdown selected i do 
			(
			tRAModifyWhatValue = i
			if i == 1 then tRAModifierListDropdown.enabled = false else tRAModifierListDropdown.enabled = true
			)
		on tRAModifierListDropdown selected i do tRAModifierValue = i

		button tRAHelpButton "Help" width:70 toolTip:"Help" pos:[380,160]
		on tRAHelpButton pressed do tRAHelp()
		button tRASaveDefButton "SaveDef" width:70 toolTip:"Save Current Settings as Default" pos:[452,160]
		on tRASaveDefButton pressed do tRASaveDef()

		on tRARollout open do
			(
			if tRAModifyWhatValue == 1 then tRAModifierListDropdown.enabled = false else tRAModifierListDropdown.enabled = true
			tRAMakeModifierList()
			tRAModifierListDropdown.items = tRAModifierNameList
			)			
		)
	)
)
-------------------------------------------------------------------------------