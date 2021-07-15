-------------------------------------------------------------------------------
-- cameraLensPackager.ms
-- By Neil Blevins (info@neilblevins.com)
-- v 1.03
-- Created On: 02/27/15
-- Modified On: 09/05/18
-- tested using Max 2017
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Required Files:
-- sLib.ms
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Description:
-- Lets you set the lenses (Focal Length) on all scene or selected cameras 
-- based on 9 presets. The supplied presets are for a Panavision C Series 
-- Anamorphic Lens Package, but you can modify the presets to be your favorite 
-- values.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Tutorial:
-- Select a camera, open the script's UI, Click any button to set its lens.
-- Go into the options area to change any of the defaults, once you've set your 
-- own values, hit "Save Def", then when you reopen the script your new values
-- will eb the default.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Revision History:
--
-- v 1.01 When using vray cameras, automaticaly turns off the fov checkbox
-- to properly set the focal length.
--
-- v 1.02 Added Max 2016 Physical Camera Support.
--
-- v 1.03 Fixed an issue where button tooltips wouldn't update properly.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
(
-- Globals

global cameraLensPackager
global cameraLensPackagerDefaults
global cameraLensPackagerUI

global cLPCloseOpenUI

global cLPDo
global cLPApply
global cLPHelp
global cLPLoadDef
global cLPSaveDef

global cLPDefineUI
global cLPRollout
global cLPOptionsRollout
global cLPFloater

-- Includes

include "$scripts\SoulburnScripts\lib\sLib.ms"

-- Variables

cLPModeValue = 1
cLP1Value = 20
cLP2Value = 30
cLP3Value = 35
cLP4Value = 50
cLP5Value = 60
cLP6Value = 75
cLP7Value = 100
cLP8Value = 150
cLP9Value = 180
cLPPosValue = [400,400]

-- Functions

fn cameraLensPackager cLPMode cLPFocalLength = 
	(
	undo "cameraLensPackager" on
		(
		thecams = #()
		if cLPMode == 1 then for c in selection do (if superclassof c == camera then append thecams c)
		else for c in cameras do append thecams c
		for obj in thecams do
			(
			-- Regular
			if (classof obj) == Targetcamera or (classof obj) == Freecamera then
				(
				obj.fov = cameraFOV.MMtoFOV cLPFocalLength
				)
			-- Vray
			else if (classof obj) == VRayPhysicalCamera then
				(
				obj.specify_fov = off
				obj.focal_length = cLPFocalLength
				)
			-- Max Physical
			else if (classof obj) == Physical then
				(
				obj.specify_fov = off
				obj.focal_length_mm = cLPFocalLength
				)
			)
		)
	)
	
fn cameraLensPackagerDefaults = 
	(
	cLPLoadDef()
	cameraLensPackager cLPModeValue cLPFocalLengthValue
	)
	
fn cameraLensPackagerUI = 
	(
	cLPLoadDef()
	cLPCloseOpenUI cLPPosValue
	)

fn cLPCloseOpenUI pos = 
	(
	if cLPFloater != undefined then CloseRolloutFloater cLPFloater
	cLPDefineUI()
	cLPFloater = newRolloutFloater "cameraLensPackager v1.03" 200 172 pos.x pos.y
	addRollout cLPRollout cLPFloater
	addRollout cLPOptionsRollout cLPFloater rolledUp:true
	)

fn cLPDo = 
	(
	cameraLensPackager cLPModeValue cLPFocalLengthValue
	if cLPFloater != undefined then CloseRolloutFloater cLPFloater
	)

fn cLPApply = 
	(
	cameraLensPackager cLPModeValue cLPFocalLengthValue
	)
	
fn cLPHelp = 
	(
	sLibSSPrintHelp "cameraLensPackager"
	)

fn cLPLoadDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	cLPInputFilename = presetDir + "cameraLensPackager.ini"
	if (sLibFileExist cLPInputFilename == true) then
		(
		cLPModeValue = execute (getINISetting cLPInputFilename "cameraLensPackager" "cLPModeValue")
		cLP1Value = execute (getINISetting cLPInputFilename "cameraLensPackager" "cLP1Value")
		cLP2Value = execute (getINISetting cLPInputFilename "cameraLensPackager" "cLP2Value")
		cLP3Value = execute (getINISetting cLPInputFilename "cameraLensPackager" "cLP3Value")
		cLP4Value = execute (getINISetting cLPInputFilename "cameraLensPackager" "cLP4Value")
		cLP5Value = execute (getINISetting cLPInputFilename "cameraLensPackager" "cLP5Value")
		cLP6Value = execute (getINISetting cLPInputFilename "cameraLensPackager" "cLP6Value")
		cLP7Value = execute (getINISetting cLPInputFilename "cameraLensPackager" "cLP7Value")
		cLP8Value = execute (getINISetting cLPInputFilename "cameraLensPackager" "cLP8Value")
		cLP9Value = execute (getINISetting cLPInputFilename "cameraLensPackager" "cLP9Value")
		cLPPosValue = execute (getINISetting cLPInputFilename "cameraLensPackager" "cLPPosValue")
		
		if cLPModeValue == OK then cLPModeValue = 1
		if cLP1Value == OK then cLP1Value = 20
		if cLP2Value == OK then cLP2Value = 30
		if cLP3Value == OK then cLP3Value = 35
		if cLP4Value == OK then cLP4Value = 50
		if cLP5Value == OK then cLP5Value = 60		
		if cLP6Value == OK then cLP6Value = 75
		if cLP7Value == OK then cLP7Value = 100
		if cLP8Value == OK then cLP8Value = 150
		if cLP9Value == OK then cLP9Value = 180
		if cLPPosValue == OK then cLPPosValue = [400,400]
		)
	else
		(
		cLPModeValue = 1
		cLP1Value = 20
		cLP2Value = 30
		cLP3Value = 35
		cLP4Value = 50
		cLP5Value = 60
		cLP6Value = 75
		cLP7Value = 100
		cLP8Value = 150
		cLP9Value = 180
		cLPPosValue = [400,400]
		)
	)
	
fn cLPSaveDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	if (getDirectories presetDir).count == 0 then makeDir presetDir
	cLPOutputFilename = presetDir + "cameraLensPackager.ini"
	if (sLibFileExist cLPOutputFilename == true) then deleteFile cLPOutputFilename
	setINISetting cLPOutputFilename "cameraLensPackager" "cLPModeValue" (cLPModeValue as string)
	setINISetting cLPOutputFilename "cameraLensPackager" "cLP1Value" (cLP1Value as string)
	setINISetting cLPOutputFilename "cameraLensPackager" "cLP2Value" (cLP2Value as string)
	setINISetting cLPOutputFilename "cameraLensPackager" "cLP3Value" (cLP3Value as string)
	setINISetting cLPOutputFilename "cameraLensPackager" "cLP4Value" (cLP4Value as string)
	setINISetting cLPOutputFilename "cameraLensPackager" "cLP5Value" (cLP5Value as string)
	setINISetting cLPOutputFilename "cameraLensPackager" "cLP6Value" (cLP6Value as string)
	setINISetting cLPOutputFilename "cameraLensPackager" "cLP7Value" (cLP7Value as string)
	setINISetting cLPOutputFilename "cameraLensPackager" "cLP8Value" (cLP8Value as string)
	setINISetting cLPOutputFilename "cameraLensPackager" "cLP9Value" (cLP9Value as string)
	setINISetting cLPOutputFilename "cameraLensPackager" "cLPPosValue" (cLPFloater.pos as string)
	)

-- UI

fn cLPDefineUI = 
	(
	rollout cLPRollout "cameraLensPackager"
		(
		button cLP1Button "lens" width:50 toolTip:"lens" across:3
		button cLP2Button "lens" width:50 toolTip:"lens"
		button cLP3Button "lens" width:50 toolTip:"lens"
		button cLP4Button "lens" width:50 toolTip:"lens" across:3
		button cLP5Button "lens" width:50 toolTip:"lens"
		button cLP6Button "lens" width:50 toolTip:"lens"
		button cLP7Button "lens" width:50 toolTip:"lens" across:3
		button cLP8Button "lens" width:50 toolTip:"lens"
		button cLP9Button "lens" width:50 toolTip:"lens"

		on cLP1Button pressed do (cameraLensPackager cLPModeValue cLP1Value)
		on cLP2Button pressed do (cameraLensPackager cLPModeValue cLP2Value)
		on cLP3Button pressed do (cameraLensPackager cLPModeValue cLP3Value)
		on cLP4Button pressed do (cameraLensPackager cLPModeValue cLP4Value)
		on cLP5Button pressed do (cameraLensPackager cLPModeValue cLP5Value)
		on cLP6Button pressed do (cameraLensPackager cLPModeValue cLP6Value)
		on cLP7Button pressed do (cameraLensPackager cLPModeValue cLP7Value)
		on cLP8Button pressed do (cameraLensPackager cLPModeValue cLP8Value)
		on cLP9Button pressed do (cameraLensPackager cLPModeValue cLP9Value)

		button cLPHelpButton "Help" width:70 toolTip:"Help" pos:[25,90]
		on cLPHelpButton pressed do cLPHelp()
		button cLPSaveDefButton "SaveDef" width:70 toolTip:"Save Current Settings as Default" pos:[97,90]
		on cLPSaveDefButton pressed do cLPSaveDef()
		
		on cLPRollout open do
			(
			cLP1Button.caption = cLP1Value as string;cLP1Button.tooltip = cLP1Value as string
			cLP2Button.caption = cLP2Value as string;cLP2Button.tooltip = cLP2Value as string
			cLP3Button.caption = cLP3Value as string;cLP3Button.tooltip = cLP3Value as string
			cLP4Button.caption = cLP4Value as string;cLP4Button.tooltip = cLP4Value as string
			cLP5Button.caption = cLP5Value as string;cLP5Button.tooltip = cLP5Value as string
			cLP6Button.caption = cLP6Value as string;cLP6Button.tooltip = cLP6Value as string
			cLP7Button.caption = cLP7Value as string;cLP7Button.tooltip = cLP7Value as string
			cLP8Button.caption = cLP8Value as string;cLP8Button.tooltip = cLP8Value as string
			cLP9Button.caption = cLP9Value as string;cLP9Button.tooltip = cLP9Value as string
			)
		)
		
	rollout cLPOptionsRollout "Options"
		(
		spinner cLP1Spinner "" range:[0,500,cLP1Value] fieldWidth:42 type:#integer across:3
		spinner cLP2Spinner "" range:[0,500,cLP2Value] fieldWidth:42 type:#integer
		spinner cLP3Spinner "" range:[0,500,cLP3Value] fieldWidth:42 type:#integer
		spinner cLP4Spinner "" range:[0,500,cLP4Value] fieldWidth:42 type:#integer across:3
		spinner cLP5Spinner "" range:[0,500,cLP5Value] fieldWidth:42 type:#integer
		spinner cLP6Spinner "" range:[0,500,cLP6Value] fieldWidth:42 type:#integer
		spinner cLP7Spinner "" range:[0,500,cLP7Value] fieldWidth:42 type:#integer across:3
		spinner cLP8Spinner "" range:[0,500,cLP8Value] fieldWidth:42 type:#integer
		spinner cLP9Spinner "" range:[0,500,cLP9Value] fieldWidth:42 type:#integer
		
		on cLP1Spinner changed val do cLP1Value = val
		on cLP2Spinner changed val do cLP2Value = val
		on cLP3Spinner changed val do cLP3Value = val
		on cLP4Spinner changed val do cLP4Value = val
		on cLP5Spinner changed val do cLP5Value = val
		on cLP6Spinner changed val do cLP6Value = val
		on cLP7Spinner changed val do cLP7Value = val
		on cLP8Spinner changed val do cLP8Value = val
		on cLP9Spinner changed val do cLP9Value = val
		
		dropdownlist cLPModeDropdown "" items:#("All Selected Cameras", "All Scene Cameras") selection:cLPModeValue
		on cLPModeDropdown selected i do cLPModeValue = i
		)
	)
)
-------------------------------------------------------------------------------