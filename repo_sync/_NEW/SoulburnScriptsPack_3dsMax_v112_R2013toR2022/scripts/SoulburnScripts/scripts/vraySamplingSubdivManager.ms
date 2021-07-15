-------------------------------------------------------------------------------
-- vraySamplingSubdivManager.ms
-- By Neil Blevins (info@neilblevins.com)
-- v 1.02
-- Created On: 05/28/14
-- Modified On: 05/10/15
-- tested using Max 2014
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Required Files:
-- sLib.ms
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Description:
-- Allows you to adjust the Sampling Subdiv value for scene materials and lights
-- all together, ensuring consistency.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Tutorial:
-- Run the UI version of the script. Make sure "All scene materials" is selected.
-- Hit Do. Now all scene materials have their reflection and refraction subdivs
-- set to the spinner value.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Revision History:
--
-- v 1.01 Now has a mode to affect all lights and materials in the scene in
-- a single click.
--
-- v 1.02 Fixed a crash bug that would affect Loading Default Values.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
(
-- Globals

global vraySamplingSubdivManager
global vraySamplingSubdivManagerDefaults
global vraySamplingSubdivManagerUI

global vSSMCloseOpenUI

global vSSMDo
global vSSMApply
global vSSMHelp
global vSSMLoadDef
global vSSMSaveDef

global vSSMDefineUI
global vSSMRollout
global vSSMFloater

-- Includes

include "$scripts\SoulburnScripts\lib\sLib.ms"

-- Variables

vSSMTypeValue = 1
vSSMSubdivValue = 32
vSSMPosValue = [400,400]

-- Functions

fn vraySamplingSubdivManager vSSMType vSSMSubdiv = 
	(
	undo "vraySamplingSubdivManager" on
		(
		if vSSMType == 1 then
			(
			nodes = sLibGetAllSceneMaterials()
			for i in nodes do
				(
				if classof i == VRayMtl then
					(
					i.reflection_subdivs = vSSMSubdiv
					i.refraction_subdivs = vSSMSubdiv
					)
				)
			)
		else if vSSMType == 2 then
			(
			nodes = sLibGetAllMaterialsOnSelectedObjects()
			for i in nodes do
				(
				if classof i == VRayMtl then
					(
					i.reflection_subdivs = vSSMSubdiv
					i.refraction_subdivs = vSSMSubdiv
					)
				)
			)
		else if vSSMType == 3 then
			(
			nodes = for i in lights collect i
			for i in nodes do
				(
				if classof i == VRayLight then i.subdivs = vSSMSubdiv
				)
			)
		else if vSSMType == 4 then
			(
			nodes = #()
			for i in selection do (if superclassof i == light then append nodes i)
			for i in nodes do
				(
				if classof i == VRayLight then i.subdivs = vSSMSubdiv
				)
			)
		else if vSSMType == 5 then
			(
			nodes = sLibGetAllSceneMaterials()
			for i in nodes do
				(
				if classof i == VRayMtl then
					(
					i.reflection_subdivs = vSSMSubdiv
					i.refraction_subdivs = vSSMSubdiv
					)
				)
			nodes = for i in lights collect i
			for i in nodes do
				(
				if classof i == VRayLight then i.subdivs = vSSMSubdiv
				)
			)
		)
	)
	
fn vraySamplingSubdivManagerDefaults = 
	(
	vSSMLoadDef()
	vraySamplingSubdivManager vSSMTypeValue vSSMSubdivValue
	)

fn vraySamplingSubdivManagerUI = 
	(
	vSSMLoadDef()
	vSSMCloseOpenUI vSSMPosValue
	)

fn vSSMCloseOpenUI pos = 
	(
	if vSSMFloater != undefined then CloseRolloutFloater vSSMFloater
	vSSMDefineUI()
	vSSMFloater = newRolloutFloater "vraySamplingSubdivManager v1.02" 166 137 pos.x pos.y
	addRollout vSSMRollout vSSMFloater
	)

fn vSSMDo = 
	(
	vraySamplingSubdivManager vSSMTypeValue vSSMSubdivValue
	if vSSMFloater != undefined then CloseRolloutFloater vSSMFloater
	)

fn vSSMApply = 
	(
	vraySamplingSubdivManager vSSMTypeValue vSSMSubdivValue
	)
	
fn vSSMHelp = 
	(
	sLibSSPrintHelp "vraySamplingSubdivManager"
	)
	
fn vSSMLoadDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	vSSMInputFilename = presetDir + "vraySamplingSubdivManager.ini"
	if (sLibFileExist vSSMInputFilename == true) then
		(
		vSSMTypeValue = execute (getINISetting vSSMInputFilename "vraySamplingSubdivManager" "vSSMTypeValue")
		vSSMSubdivValue = execute (getINISetting vSSMInputFilename "vraySamplingSubdivManager" "vSSMSubdivValue")
		vSSMPosValue = execute (getINISetting vSSMInputFilename "vraySamplingSubdivManager" "vSSMPosValue")
		
		if vSSMTypeValue == OK then vSSMTypeValue = 1
		if vSSMSubdivValue == OK then vSSMSubdivValue = 32
		if vSSMPosValue == OK then vSSMPosValue = [400,400]
		)
	else
		(
		vSSMTypeValue = 1
		vSSMSubdivValue = 32
		vSSMPosValue = [400,400]
		)
	)
	
fn vSSMSaveDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	if (getDirectories presetDir).count == 0 then makeDir presetDir
	vSSMOutputFilename = presetDir + "vraySamplingSubdivManager.ini"
	if (sLibFileExist vSSMOutputFilename == true) then deleteFile vSSMOutputFilename
	setINISetting vSSMOutputFilename "vraySamplingSubdivManager" "vSSMTypeValue" (vSSMTypeValue as string)
	setINISetting vSSMOutputFilename "vraySamplingSubdivManager" "vSSMSubdivValue" (vSSMSubdivValue as string)
	setINISetting vSSMOutputFilename "vraySamplingSubdivManager" "vSSMPosValue" (vSSMFloater.pos as string)
	)

-- UI

fn vSSMDefineUI = 
	(
	rollout vSSMRollout "vraySamplingSubdivManager"
		(
		dropdownlist vSSMTypeDropdown "" items:#("All Scene Materials", "All Materials On Selected Objects", "All Scene Lights", "All Lights In Selection", "All Scene Materials And Lights") selection:vSSMTypeValue width:130 align:#center
		spinner vSSMSubdivSpinner "Subdivs: " range:[0,9999,vSSMSubdivValue] fieldWidth:55 type:#integer

		on vSSMTypeDropdown selected i do vSSMTypeValue = i
		on vSSMSubdivSpinner changed val do vSSMSubdivValue = val

		button vSSMDoButton "Do" width:70 toolTip:"Do It and Close UI" pos:[5,57]
		on vSSMDoButton pressed do vSSMDo()
		button vSSMApplyButton "Apply" width:70 toolTip:"Do It and Keep UI Open" pos:[77,57]
		on vSSMApplyButton pressed do vSSMApply()
		button vSSMHelpButton "Help" width:70 toolTip:"Help" pos:[5,81]
		on vSSMHelpButton pressed do vSSMHelp()
		button vSSMSaveDefButton "SaveDef" width:70 toolTip:"Save Current Settings as Default" pos:[77,81]
		on vSSMSaveDefButton pressed do vSSMSaveDef()
		)
	)
)
-------------------------------------------------------------------------------