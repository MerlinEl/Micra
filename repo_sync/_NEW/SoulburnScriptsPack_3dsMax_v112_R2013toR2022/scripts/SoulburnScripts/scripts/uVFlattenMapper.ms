-------------------------------------------------------------------------------
-- uVFlattenMapper.ms
-- By Neil Blevins (info@neilblevins.com)
-- v 1.01
-- Created On: 03/11/15
-- Modified On: 03/24/15
-- tested using Max 2014
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Required Files:
-- sLib.ms
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Description:
-- Applies Flatten Mapping (also sometimes refered to as Automatic UVs), which 
-- is the same as the Flatten Mapping in the UVWUnwrap modifier, but unlike that 
-- one, can be applied to a selection of objects with each object using their 
-- own map, or all the objects sharing a single map. Good for just getting 
-- some sort of mapping on all scene objects in one button press, perhaps to 
-- then send to a paint app or to bake a texture map.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Tutorial:
-- Select a number fo objects. Run the script in UI mode. Hit Do. Now all the 
-- objects have a UVWUnwrap assigned with its mapping flattened.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Revision History:
--
-- v 1.01 Fixed a bug that caused presets not to load. Fixed a crash bug by 
-- removing the unnecessary mappingReset() call.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
(
-- Globals

global uVFlattenMapper
global uVFlattenMapperDefaults
global uVFlattenMapperUI

global uVFMCloseOpenUI

global uVFMDo
global uVFMApply
global uVFMHelp
global uVFMLoadDef
global uVFMSaveDef

global uVFMDefineUI
global uVFMRollout
global uVFMFloater

-- Includes

include "$scripts\SoulburnScripts\lib\sLib.ms"

-- Variables

uVFMModeValue = 1
uVFMMapChannelValue = 1
uVFMPolyAngleValue = 45.0
uVFMSpacingValue = 0.02
uVFMNormalizeValue = true
uVFMRotateValue = true
uVFMFillHolesValue = true
uVFMLayoutValue = 1
uVFMPosValue = [400,400]

-- Functions

fn uVFlattenMapper uVFMMode uVFMMapChannel uVFMPolyAngle uVFMSpacing uVFMNormalize uVFMRotate uVFMFillHoles uVFMLayout = 
	(
	objs = #()
	for i in selection do (if (sLibGeometryFilter i) == true then append objs i)
	max modify mode
	if uVFMMode == 1 then
		(
		-- One Map Per Object
		for o in objs do
			(
			select o
			unwrapMod = unwrap_UVW()
			addModifier o unwrapMod
			unwrapMod.setPreventFlattening off
			unwrapMod.setMapChannel uVFMMapChannel
			--unwrapMod.mappingReset()
			allfaces = for i = 1 to (unwrapMod.numberPolygons()) collect i
			unwrapMod.selectFaces (allfaces as bitarray)
			unwrapMod.flattenMap uVFMPolyAngle #([1,0,0], [-1,0,0], [0,1,0], [0,-1,0], [0,0,1], [0,0,-1]) uVFMSpacing uVFMNormalize (uVFMLayout-1) uVFMRotate uVFMFillHoles
			deselect o
			)
		)
	else if uVFMMode == 2 then
		(
		-- One Map For All Objects
		select objs
		unwrapMod = unwrap_UVW()
		addModifier objs unwrapMod
		unwrapMod.setPreventFlattening off
		unwrapMod.setMapChannel uVFMMapChannel
		--unwrapMod.mappingReset()
		for o in objs do unwrapMod.selectFacesByNode #{1..o.numfaces} o
		unwrapMod.flattenMap uVFMPolyAngle #([1,0,0], [-1,0,0], [0,1,0], [0,-1,0], [0,0,1], [0,0,-1]) uVFMSpacing uVFMNormalize (uVFMLayout-1) uVFMRotate uVFMFillHoles
		deselect objs
		)
	)

fn uVFlattenMapperDefaults = 
	(
	uVFMLoadDef()
	uVFlattenMapper uVFMModeValue uVFMMapChannelValue uVFMPolyAngleValue uVFMSpacingValue uVFMNormalizeValue uVFMRotateValue uVFMFillHolesValue uVFMLayoutValue
	)

fn uVFlattenMapperUI = 
	(
	uVFMLoadDef()
	uVFMCloseOpenUI uVFMPosValue
	)
	
fn uVFMCloseOpenUI pos = 
	(
	if uVFMFloater != undefined then CloseRolloutFloater uVFMFloater
	uVFMDefineUI()
	uVFMFloater = newRolloutFloater "uVFlattenMapper v1.01" 310 237 pos.x pos.y
	addRollout uVFMRollout uVFMFloater
	)

fn uVFMDo = 
	(
	uVFlattenMapper uVFMModeValue uVFMMapChannelValue uVFMPolyAngleValue uVFMSpacingValue uVFMNormalizeValue uVFMRotateValue uVFMFillHolesValue uVFMLayoutValue
	if uVFMFloater != undefined then CloseRolloutFloater uVFMFloater
	)

fn uVFMApply = 
	(
	uVFlattenMapper uVFMModeValue uVFMMapChannelValue uVFMPolyAngleValue uVFMSpacingValue uVFMNormalizeValue uVFMRotateValue uVFMFillHolesValue uVFMLayoutValue
	)
	
fn uVFMHelp = 
	(
	sLibSSPrintHelp "uVFlattenMapper"
	)
	
fn uVFMLoadDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	uVFMInputFilename = presetDir + "uVFlattenMapper.ini"
	if (sLibFileExist uVFMInputFilename == true) then
		(
		uVFMModeValue = execute (getINISetting uVFMInputFilename "uVFlattenMapper" "uVFMModeValue")
		uVFMMapChannelValue = execute (getINISetting uVFMInputFilename "uVFlattenMapper" "uVFMMapChannelValue")
		uVFMPolyAngleValue = execute (getINISetting uVFMInputFilename "uVFlattenMapper" "uVFMPolyAngleValue")
		uVFMSpacingValue = execute (getINISetting uVFMInputFilename "uVFlattenMapper" "uVFMSpacingValue")
		uVFMNormalizeValue = execute (getINISetting uVFMInputFilename "uVFlattenMapper" "uVFMNormalizeValue")
		uVFMRotateValue = execute (getINISetting uVFMInputFilename "uVFlattenMapper" "uVFMRotateValue")
		uVFMFillHolesValue = execute (getINISetting uVFMInputFilename "uVFlattenMapper" "uVFMFillHolesValue")
		uVFMLayoutValue = execute (getINISetting uVFMInputFilename "uVFlattenMapper" "uVFMLayoutValue")
		uVFMPosValue = execute (getINISetting uVFMInputFilename "uVFlattenMapper" "uVFMPosValue")
		
		if uVFMModeValue == OK then uVFMModeValue = 1
		if uVFMMapChannelValue == OK then uVFMMapChannelValue = 1
		if uVFMPolyAngleValue == OK then uVFMPolyAngleValue = 45.0
		if uVFMSpacingValue == OK then uVFMSpacingValue = 0.02
		if uVFMNormalizeValue == OK then uVFMNormalizeValue = true
		if uVFMRotateValue == OK then uVFMRotateValue = true
		if uVFMFillHolesValue == OK then uVFMFillHolesValue = true
		if uVFMLayoutValue == OK then uVFMLayoutValue = 1
		if uVFMPosValue == OK then uVFMPosValue = [400,400]
		)
	else
		(
		uVFMModeValue = 1
		uVFMMapChannelValue = 1
		uVFMPolyAngleValue = 45.0
		uVFMSpacingValue = 0.02
		uVFMNormalizeValue = true
		uVFMRotateValue = true
		uVFMFillHolesValue = true
		uVFMLayoutValue = 1
		uVFMPosValue = [400,400]
		)
	)
	
fn uVFMSaveDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	if (getDirectories presetDir).count == 0 then makeDir presetDir
	uVFMOutputFilename = presetDir + "uVFlattenMapper.ini"
	if (sLibFileExist uVFMOutputFilename == true) then deleteFile uVFMOutputFilename
	setINISetting uVFMOutputFilename "uVFlattenMapper" "uVFMModeValue" (uVFMModeValue as string)
	setINISetting uVFMOutputFilename "uVFlattenMapper" "uVFMMapChannelValue" (uVFMMapChannelValue as string)
	setINISetting uVFMOutputFilename "uVFlattenMapper" "uVFMPolyAngleValue" (uVFMPolyAngleValue as string)
	setINISetting uVFMOutputFilename "uVFlattenMapper" "uVFMSpacingValue" (uVFMSpacingValue as string)
	setINISetting uVFMOutputFilename "uVFlattenMapper" "uVFMNormalizeValue" (uVFMNormalizeValue as string)
	setINISetting uVFMOutputFilename "uVFlattenMapper" "uVFMRotateValue" (uVFMRotateValue as string)
	setINISetting uVFMOutputFilename "uVFlattenMapper" "uVFMFillHolesValue" (uVFMFillHolesValue as string)
	setINISetting uVFMOutputFilename "uVFlattenMapper" "uVFMLayoutValue" (uVFMLayoutValue as string)
	setINISetting uVFMOutputFilename "uVFlattenMapper" "uVFMPosValue" (uVFMFloater.pos as string)
	)

-- UI

fn uVFMDefineUI = 
	(
	rollout uVFMRollout "uVFlattenMapper"
		(
		label label1 "Mode:" across:2 align:#left
		dropdownlist uVFMModeDropdown "" items:#("One Map Per Object", "One Map For All Objects") selection:uVFMModeValue width:180 offset:[-100,-2]
		spinner uVFMMapChannelSpinner "Map Channel: " range:[1,99,uVFMMapChannelValue] fieldWidth:50 type:#integer align:#left
		spinner uVFMPolyAngleSpinner "Polygon Angle: " range:[0,180,uVFMPolyAngleValue] fieldWidth:50 type:#float align:#left
		spinner uVFMSpacingSpinner "Spacing: " range:[0.00,1.00,uVFMSpacingValue] fieldWidth:50 type:#float align:#left
		checkbox uVFMNormalizeCheckbox "Normalize Clusters?" checked:uVFMNormalizeValue align:#left
		checkbox uVFMRotateCheckbox "Rotate Clusters?" checked:uVFMRotateValue align:#left
		checkbox uVFMFillHolesCheckbox "Fill Holes?" checked:uVFMFillHolesValue align:#left
		label label2 "Layout Type:" across:2 align:#left
		dropdownlist uVFMLayoutDropdown "" items:#("Bottom To Top, Left To Right", "Left To Right, Bottom To Top") selection:uVFMLayoutValue width:180 offset:[-65,-2]
		
		on uVFMModeDropdown selected i do uVFMModeValue = i
		on uVFMMapChannelSpinner changed val do uVFMMapChannelValue = val
		on uVFMPolyAngleSpinner changed val do uVFMMapChannelValue = val
		on uVFMSpacingSpinner changed val do uVFMSpacingValue = val
		on uVFMNormalizeCheckbox changed state do uVFMNormalizeValue = state
		on uVFMRotateCheckbox changed state do uVFMRotateValue = state
		on uVFMFillHolesCheckbox changed state do uVFMFillHolesValue = state
		on uVFMLayoutDropdown selected i do uVFMLayoutValue = i
		
		button uVFMDoButton "Do" width:70 toolTip:"Do It and Close UI" pos:[5,180]
		on uVFMDoButton pressed do uVFMDo()
		button uVFMApplyButton "Apply" width:70 toolTip:"Do It and Keep UI Open" pos:[77,180]
		on uVFMApplyButton pressed do uVFMApply()
		button uVFMHelpButton "Help" width:70 toolTip:"Help" pos:[149,180]
		on uVFMHelpButton pressed do uVFMHelp()
		button uVFMSaveDefButton "SaveDef" width:70 toolTip:"Save Current Settings as Default" pos:[221,180]
		on uVFMSaveDefButton pressed do uVFMSaveDef()
		)
	)
)
-------------------------------------------------------------------------------