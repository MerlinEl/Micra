-------------------------------------------------------------------------------
-- iDSetter.ms
-- By Neil Blevins (info@neilblevins.com)
-- v 1.06
-- Created On: 02/09/14
-- Modified On: 01/05/19
-- tested using Max 2016
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Required Files:
-- sLib.ms
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Description:
-- Takes all selected objects and applies a material modifier, modifies their
-- object ID, or modifies their User Defined Properties to either a random ID 
-- between the high and low value, or a sequential set of IDs based on 
-- selection order.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Tutorial:
-- Select 5 objects, run the UI version of the script. Hit Do. Now each object
-- has a material modifier on it with a different random number between the 
-- high and low value.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Revision History:
--
-- v 1.01 Added ability to give a constant value for all the objects.
--
-- v 1.02 Added ability to choose a specific set of ramdom IDs, like if you type
-- "1,10,15", it will give each selected object one of those 3 ids randomly.
--
-- v 1.03 Revised default settings. If you prefered the old ones, remember you 
-- can always set them back and hit "SaveDef". Added ability to use existing 
-- Material modifiers when setting the material ID, or you can keep having the
-- script adding a new one.
--
-- v 1.04 Fixed an issue where it would have problem in "Object ID" and "User 
-- Defined Properties" mode with instances.
--
-- v 1.05 Now it renames the Material modifier something more meaningful.
--
-- v 1.06 Fixed a crash bug when using SaveDef.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
(
-- Globals

global iDSetter
global iDSetterDefaults
global iDSetterUI

global iDSCloseOpenUI

global iDSWhereTopMatModifier

global iDSDo
global iDSApply
global iDSHelp
global iDSLoadDef
global iDSSaveDef

global iDSDefineUI
global iDSRollout
global iDSFloater

-- Includes

include "$scripts\SoulburnScripts\lib\sLib.ms"

-- Variables

iDSIDTypeValue = 1
iDSUserPropValue = "ColorID"
iDSModeValue = 3
iDSStartValue = 1
iDSLowValue = 1
iDSHighValue = 10
iDSSetValue = "1,3,4,5"
iDSUseExistingValue = false
iDSPosValue = [400,400]

-- Functions

fn iDSetter iDSIDType iDSUserProp iDSMode iDSStart iDSLow iDSHigh iDSSet iDSUseExisting = 
	(
	undo "iDSetter" on
		(
		if iDSIDType == 1 then (a = sLibRemoveUnneededInstancesFromArray selection) else (a = for i in selection collect i)
		if a.count != 0 then
			(
			for i = 1 to a.count do
				(
				-- Random
				if iDSMode == 1 then
					(
					value = ((random iDSLow iDSHigh) as integer)
					if iDSIDType == 1 then
						(
						modposition = iDSWhereTopMatModifier a[i]
						if iDSUseExisting == false or modposition == 0 then
							(
							theMod = materialmodifier()
							if validModifier a[i] theMod then 
								(
								addmodifier a[i] theMod
								theMod.name = ("SetMatID")
								theMod.materialID = value
								)
							)
						if iDSUseExisting == true and modposition != 0 then
							(
							a[i].modifiers[modposition].materialID = value
							)
						)
					else if iDSIDType == 2 then
						(
						a[i].gbufferchannel = value
						)
					else if iDSIDType == 3 then
						(
						setUserProp a[i] iDSUserProp value
						)
					)
				-- Sequence
				else if iDSMode == 2 then
					(
					if iDSIDType == 1 then
						(
						modposition = iDSWhereTopMatModifier a[i]
						if iDSUseExisting == false or modposition == 0 then
							(
							theMod = materialmodifier()
							if validModifier a[i] theMod then 
								(
								addmodifier a[i] theMod
								theMod.name = ("iDSetter")
								theMod.materialID = ((i+iDSStart-1) as integer)
								)
							)
						if iDSUseExisting == true and modposition != 0 then
							(
							a[i].modifiers[modposition].materialID = ((i+iDSStart-1) as integer)
							)
						)
					else if iDSIDType == 2 then
						(
						a[i].gbufferchannel = ((i+iDSStart-1) as integer)
						)
					else if iDSIDType == 3 then
						(
						setUserProp a[i] iDSUserProp ((i+iDSStart-1) as integer)
						)					
					)
				-- Constant
				else if iDSMode == 3 then
					(
					if iDSIDType == 1 then
						(
						modposition = iDSWhereTopMatModifier a[i]
						if iDSUseExisting == false or modposition == 0 then
							(
							theMod = materialmodifier()
							if validModifier a[i] theMod then 
								(
								addmodifier a[i] theMod
								theMod.name = ("iDSetter")
								theMod.materialID = (iDSStart as integer)
								)
							)
						if iDSUseExisting == true and modposition != 0 then
							(
							a[i].modifiers[modposition].materialID = (iDSStart as integer)
							)
						)
					else if iDSIDType == 2 then
						(
						a[i].gbufferchannel = (iDSStart as integer)
						)
					else if iDSIDType == 3 then
						(
						setUserProp a[i] iDSUserProp (iDSStart as integer)
						)					
					)
				-- Random From Set
				else if iDSMode == 4 then
					(
					setstring = filterString iDSSet ","
					setvalues = #()
					for i in setstring do
						(
						temp = i as integer
						if i != undefined then append setvalues temp
						)
					if setvalues.count > 0 then
						(	
						value = (random 1 setvalues.count) as integer
						if iDSIDType == 1 then
							(
							modposition = iDSWhereTopMatModifier a[i]
							if iDSUseExisting == false or modposition == 0 then
								(
								theMod = materialmodifier()
								if validModifier a[i] theMod then 
									(
									addmodifier a[i] theMod
									theMod.name = ("iDSetter")
									theMod.materialID = setvalues[value]
									)
								)
							if iDSUseExisting == true and modposition != 0 then
								(
								a[i].modifiers[modposition].materialID = setvalues[value]
								)
							)
						else if iDSIDType == 2 then
							(
							a[i].gbufferchannel = setvalues[value]
							)
						else if iDSIDType == 3 then
							(
							setUserProp a[i] iDSUserProp setvalues[value]
							)					
						)
					)
				)
			)
		)
	)
	
fn iDSetterDefaults = 
	(
	iDSLoadDef()
	iDSetter iDSIDTypeValue iDSUserPropValue iDSModeValue iDSStartValue iDSLowValue iDSHighValue iDSSetValue iDSUseExistingValue
	)

fn iDSetterUI = 
	(
	iDSLoadDef()
	iDSCloseOpenUI iDSPosValue
	)

fn iDSCloseOpenUI pos = 
	(
	if iDSFloater != undefined then CloseRolloutFloater iDSFloater
	iDSDefineUI()
	iDSFloater = newRolloutFloater "iDSetter v1.06" 166 271 pos.x pos.y
	addRollout iDSRollout iDSFloater
	)
	
fn iDSWhereTopMatModifier obj = 
	(
	modposition = 0
	if obj.modifiers.count != 0 then
		(
		for j = 1 to obj.modifiers.count do
			(
			if classof obj.modifiers[j] == Materialmodifier then 
				(
				modposition = j
				exit
				)
			)
		)
	return modposition
	)

fn iDSDo = 
	(
	iDSetter iDSIDTypeValue iDSUserPropValue iDSModeValue iDSStartValue iDSLowValue iDSHighValue iDSSetValue iDSUseExistingValue
	if iDSFloater != undefined then CloseRolloutFloater iDSFloater
	)

fn iDSApply = 
	(
	iDSetter iDSIDTypeValue iDSUserPropValue iDSModeValue iDSStartValue iDSLowValue iDSHighValue iDSSetValue iDSUseExistingValue
	)
	
fn iDSHelp = 
	(
	sLibSSPrintHelp "iDSetter"
	)
	
fn iDSLoadDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	iDSInputFilename = presetDir + "iDSetter.ini"
	if (sLibFileExist iDSInputFilename == true) then
		(
		iDSIDTypeValue = execute (getINISetting iDSInputFilename "iDSetter" "iDSIDTypeValue")
		iDSUserPropValue = getINISetting iDSInputFilename "iDSetter" "iDSUserPropValue"
		iDSModeValue = execute (getINISetting iDSInputFilename "iDSetter" "iDSModeValue")
		iDSStartValue = execute (getINISetting iDSInputFilename "iDSetter" "iDSStartValue")
		iDSLowValue = execute (getINISetting iDSInputFilename "iDSetter" "iDSLowValue")
		iDSHighValue = execute (getINISetting iDSInputFilename "iDSetter" "iDSHighValue")
		iDSSetValue = getINISetting iDSInputFilename "iDSetter" "iDSSetValue"
		iDSUseExistingValue = execute (getINISetting iDSInputFilename "iDSetter" "iDSUseExistingValue")
		iDSPosValue = execute (getINISetting iDSInputFilename "iDSetter" "iDSPosValue")
		
		if iDSIDTypeValue == OK then iDSIDTypeValue = 1
		if iDSUserPropValue == OK then iDSUserPropValue = 1
		if iDSModeValue == OK then iDSModeValue = 3
		if iDSStartValue == OK then iDSStartValue = 1
		if iDSLowValue == OK then iDSLowValue = 1
		if iDSHighValue == OK then iDSHighValue = 10
		if iDSSetValue == OK then iDSSetValue = "1,3,4,5"
		if iDSUseExistingValue == OK then iDSUseExistingValue = false
		if iDSPosValue == OK then iDSPosValue = [400,400]
		)
	else
		(
		iDSIDTypeValue = 1
		iDSUserPropValue = "ColorID"
		iDSModeValue = 3
		iDSStartValue = 1
		iDSLowValue = 1
		iDSHighValue = 10
		iDSSetValue = "1,3,4,5"
		iDSUseExistingValue = false
		iDSPosValue = [400,400]
		)
	)
	
fn iDSSaveDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	if (getDirectories presetDir).count == 0 then makeDir presetDir
	iDSOutputFilename = presetDir + "iDSetter.ini"
	if (sLibFileExist iDSOutputFilename == true) then deleteFile iDSOutputFilename
	setINISetting iDSOutputFilename "iDSetter" "iDSIDTypeValue" (iDSIDTypeValue as string)
	setINISetting iDSOutputFilename "iDSetter" "iDSUserPropValue" (iDSUserPropValue as string)
	setINISetting iDSOutputFilename "iDSetter" "iDSModeValue" (iDSModeValue as string)
	setINISetting iDSOutputFilename "iDSetter" "iDSStartValue" (iDSStartValue as string)
	setINISetting iDSOutputFilename "iDSetter" "iDSLowValue" (iDSLowValue as string)
	setINISetting iDSOutputFilename "iDSetter" "iDSHighValue" (iDSHighValue as string)
	setINISetting iDSOutputFilename "iDSetter" "iDSSetValue" (iDSSetValue as string)
	setINISetting iDSOutputFilename "iDSetter" "iDSUseExistingValue" (iDSUseExistingValue as string)
	setINISetting iDSOutputFilename "iDSetter" "iDSPosValue" (iDSFloater.pos as string)
	)

-- UI

fn iDSDefineUI = 
	(
	rollout iDSRollout "iDSetter"
		(
		dropdownlist iDSIDTypeDropdown "" items:#("Material ID", "Object ID", "User Defined Properties") selection:iDSIDTypeValue width:130 align:#center
		edittext iDSUserPropEditText "User Def:" fieldWidth:80 text:iDSUserPropValue
		dropdownlist iDSModeDropdown "" items:#("Random", "Sequence", "Constant", "Random From Set") selection:iDSModeValue width:130 align:#center
		spinner iDSLowSpinner "Low: " range:[0,99999999,iDSLowValue] fieldWidth:55 type:#integer
		spinner iDSHighSpinner "High: " range:[0,99999999,iDSHighValue] fieldWidth:55 type:#integer
		spinner iDSStartSpinner "Start: " range:[0,99999999,iDSStartValue] fieldWidth:55 type:#integer
		edittext iDSSetEditText "Set:" fieldWidth:103 text:iDSSetValue
		checkbox iDSUseExistingCheckbox "Use Existing MatID Mods" checked:iDSUseExistingValue align:#left offset:[-6,0]

		on iDSIDTypeDropdown selected i do 
			(
			iDSIDTypeValue = i
			if iDSIDTypeValue == 1 then 
				(
				iDSUserPropEditText.enabled = false
				iDSUseExistingCheckbox.enabled = true
				)
			else if iDSIDTypeValue == 2 then 
				(
				iDSUserPropEditText.enabled = false
				iDSUseExistingCheckbox.enabled = false
				)
			else if iDSIDTypeValue == 3 then 
				(
				iDSUserPropEditText.enabled = true
				iDSUseExistingCheckbox.enabled = false
				)
			)
		on iDSUserPropEditText changed text do iDSUserPropValue = iDSUserPropEditText.text
		on iDSModeDropdown selected i do 
			(
			iDSModeValue = i
			if iDSModeValue == 1 then
				(
				iDSLowSpinner.enabled = true
				iDSHighSpinner.enabled = true
				iDSStartSpinner.enabled = false
				iDSSetEditText.enabled = false
				)
			else if iDSModeValue == 2 or iDSModeValue == 3 then
				(
				iDSLowSpinner.enabled = false
				iDSHighSpinner.enabled = false
				iDSStartSpinner.enabled = true
				iDSSetEditText.enabled = false
				)				
			else if iDSModeValue == 4 then
				(
				iDSLowSpinner.enabled = false
				iDSHighSpinner.enabled = false
				iDSStartSpinner.enabled = false
				iDSSetEditText.enabled = true
				)
			)
		on iDSStartSpinner changed val do iDSStartValue = val
		on iDSLowSpinner changed val do iDSLowValue = val
		on iDSHighSpinner changed val do iDSHighValue = val
		on iDSSetEditText changed text do iDSSetValue = iDSSetEditText.text
		on iDSUseExistingCheckbox changed state do iDSUseExistingValue = state

		button iDSDoButton "Do" width:70 toolTip:"Do It and Close UI" pos:[5,190]
		on iDSDoButton pressed do iDSDo()
		button iDSApplyButton "Apply" width:70 toolTip:"Do It and Keep UI Open" pos:[77,190]
		on iDSApplyButton pressed do iDSApply()
		button iDSHelpButton "Help" width:70 toolTip:"Help" pos:[5,214]
		on iDSHelpButton pressed do iDSHelp()
		button iDSSaveDefButton "SaveDef" width:70 toolTip:"Save Current Settings as Default" pos:[77,214]
		on iDSSaveDefButton pressed do iDSSaveDef()
		
		on iDSRollout open do
			(
			if iDSIDTypeValue == 1 then 
				(
				iDSUserPropEditText.enabled = false
				iDSUseExistingCheckbox.enabled = true
				)
			else if iDSIDTypeValue == 2 then 
				(
				iDSUserPropEditText.enabled = false
				iDSUseExistingCheckbox.enabled = false
				)
			else if iDSIDTypeValue == 3 then 
				(
				iDSUserPropEditText.enabled = true
				iDSUseExistingCheckbox.enabled = false
				)
			if iDSModeValue == 1 then
				(
				iDSLowSpinner.enabled = true
				iDSHighSpinner.enabled = true
				iDSStartSpinner.enabled = false
				iDSSetEditText.enabled = false
				)
			else if iDSModeValue == 2 or iDSModeValue == 3 then
				(
				iDSLowSpinner.enabled = false
				iDSHighSpinner.enabled = false
				iDSStartSpinner.enabled = true
				iDSSetEditText.enabled = false
				)				
			else if iDSModeValue == 4 then
				(
				iDSLowSpinner.enabled = false
				iDSHighSpinner.enabled = false
				iDSStartSpinner.enabled = false
				iDSSetEditText.enabled = true
				)
			)
		)
	)
)
-------------------------------------------------------------------------------