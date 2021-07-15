-------------------------------------------------------------------------------
-- vrayMatteManager.ms
-- By Neil Blevins (info@neilblevins.com)
-- v 1.01
-- Created On: 03/05/19
-- Modified On: 05/22/19
-- tested using Max 2017
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Required Files:
-- sLib.ms
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Description:
-- Allows you to turn on or turn off the shadow catching Matte properites of
-- selected objects for vray.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Tutorial:
-- Select a set of objects. Run the UI version of the script. Hit Do. It will 
-- turn all selected objects into shadow catchers. Change the dropdown. Hit Do.
-- It will turn off the shadow catching properties, returning the objects to 
-- normal.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Revision History:
--
-- v 1.01 Added ability to make objects a matte object with no shadow catching 
-- ability.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
(
-- Globals

global vrayMatteManager
global vrayMatteManagerDefaults
global vrayMatteManagerUI

global vMMCloseOpenUI

global vMMDo
global vMMApply
global vMMHelp
global vMMLoadDef
global vMMSaveDef

global vMMDefineUI
global vMMRollout
global vMMFloater

-- Includes

include "$scripts\SoulburnScripts\lib\sLib.ms"

-- Variables

vMMActionValue = 1
vMMPosValue = [400,400]

-- Functions

fn vrayMatteManager vMMAction = 
	(
	for obj in selection do
		(
		if vMMAction == 1 then
			(
			setUserProp obj "VRay_Matte_Enable" true
			setUserProp obj "VRay_Secondary_Matte_Enable" true
			setUserProp obj "VRay_Matte_Alpha" -1.0
			setUserProp obj "VRay_Matte_Shadows" true
			setUserProp obj "VRay_Matte_ShadowAlpha" true
			)
		else if vMMAction == 2 then
			(
			setUserProp obj "VRay_Matte_Enable" true
			setUserProp obj "VRay_Secondary_Matte_Enable" true
			setUserProp obj "VRay_Matte_Alpha" -1.0
			setUserProp obj "VRay_Matte_Shadows" false
			setUserProp obj "VRay_Matte_ShadowAlpha" false
			)
		else if vMMAction == 3 then
			(
			setUserProp obj "VRay_Matte_Enable" false
			setUserProp obj "VRay_Secondary_Matte_Enable" false
			setUserProp obj "VRay_Matte_Alpha" 1.0
			setUserProp obj "VRay_Matte_Shadows" false
			setUserProp obj "VRay_Matte_ShadowAlpha" false
			)
		)
	)
	
fn vrayMatteManagerDefaults = 
	(
	vMMLoadDef()
	vrayMatteManager vMMActionValue
	)
	
fn vrayMatteManagerUI = 
	(
	vMMLoadDef()
	vMMCloseOpenUI vMMPosValue
	)

fn vMMCloseOpenUI pos = 
	(
	if vMMFloater != undefined then CloseRolloutFloater vMMFloater
	vMMDefineUI()
	vMMFloater = newRolloutFloater "vrayMatteManager v1.01" 310 91 pos.x pos.y
	addRollout vMMRollout vMMFloater
	)

fn vMMDo = 
	(
	vrayMatteManager vMMActionValue
	if vMMFloater != undefined then CloseRolloutFloater vMMFloater
	)

fn vMMApply = 
	(
	vrayMatteManager vMMActionValue
	)
	
fn vMMHelp = 
	(
	sLibSSPrintHelp "vrayMatteManager"
	)
	
fn vMMLoadDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	vMMInputFilename = presetDir + "vrayMatteManager.ini"
	if (sLibFileExist vMMInputFilename == true) then
		(
		vMMActionValue = execute (getINISetting vMMInputFilename "vrayMatteManager" "vMMActionValue")
		vMMPosValue = execute (getINISetting vMMInputFilename "vrayMatteManager" "vMMPosValue")
		
		if vMMActionValue == OK then vMMActionValue = 1
		if vMMPosValue == OK then vMMPosValue = [400,400]
		)
	else
		(
		vMMActionValue = 1
		vMMPosValue = [400,400]
		)
	)
	
fn vMMSaveDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	if (getDirectories presetDir).count == 0 then makeDir presetDir
	vMMOutputFilename = presetDir + "vrayMatteManager.ini"
	if (sLibFileExist vMMOutputFilename == true) then deleteFile vMMOutputFilename
	setINISetting vMMOutputFilename "vrayMatteManager" "vMMActionValue" (vMMActionValue as string)
	setINISetting vMMOutputFilename "vrayMatteManager" "vMMPosValue" (vMMFloater.pos as string)
	)

-- UI

fn vMMDefineUI = 
	(
	rollout vMMRollout "vrayMatteManager"
		(
		label label1 "Action:" pos:[10,10]
		dropdownlist vMMActionDropdown "" items:#("Turn Selection Into Shadow Catchers", "Turn Selection Into Matte Objects", "Turn off Matte / Shadow Properties Of Selection") selection:vMMActionValue pos:[50,7] width:237
		on vMMActionDropdown selected i do vMMActionValue = i

		button vMMDoButton "Do" width:70 toolTip:"Do It and Close UI" pos:[5,34]
		on vMMDoButton pressed do vMMDo()
		button vMMApplyButton "Apply" width:70 toolTip:"Do It and Keep UI Open" pos:[77,34]
		on vMMApplyButton pressed do vMMApply()
		button vMMHelpButton "Help" width:70 toolTip:"Help" pos:[149,34]
		on vMMHelpButton pressed do vMMHelp()
		button vMMSaveDefButton "SaveDef" width:70 toolTip:"Save Current Settings as Default" pos:[221,34]
		on vMMSaveDefButton pressed do vMMSaveDef()
		)
	)
)
-------------------------------------------------------------------------------