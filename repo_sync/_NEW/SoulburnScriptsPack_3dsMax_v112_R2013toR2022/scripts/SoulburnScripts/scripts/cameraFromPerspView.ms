-------------------------------------------------------------------------------
-- cameraFromPerspView.ms
-- By Neil Blevins (info@neilblevins.com)
-- v 1.09
-- Created On: 03/23/05
-- Modified On: 06/17/18
-- tested using Max 2017
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Required Files:
-- sLib.ms
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Description:
-- Changes an active perspective viewport into a camera viewport.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Tutorial:
-- Select a view (like perspective). Run the script. It will turn your view 
-- into a camera view.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Revision History:
--
-- v 1.01 Defined ui as new function.
--
-- v 1.02 Added some new code to more cleanly open and close the UI.
--
-- v 1.03 Added Brazil2 camera support.
--
-- v 1.04 Replaced the Close button with a Help button. Use the X button to 
-- Close the Floater.
--
-- v 1.05 Added Vray camera support.
--
-- v 1.06 Adjusted some default values.
--
-- v 1.07 Added Max 2016 Physical Camera Support.
--
-- v 1.08 Fixed a bug where the wrong parameter was being set in the default
-- Max 2016 Physical Camera.
--
-- v 1.09 Added ability to place the newly created camera on a new layer.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Known Issues:
-- Recommended for use on perspective views only. It will cause some funky 
-- results if you try and convert an orthogonal view. Will not copy over roll 
-- angle parameter if you use it on a camera view.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
(
-- Globals

global cameraFromPerspView
global cameraFromPerspViewDefaults
global cameraFromPerspViewUI

global cFPVCloseOpenUI

global cFPVDo
global cFPVApply
global cFPVHelp
global cFPVLoadDef
global cFPVSaveDef

global cFPVDefineUI
global cFPVRollout
global cFPVFloater

-- Includes

include "$scripts\SoulburnScripts\lib\sLib.ms"

-- Variables

cFPVCamTypeValue = 1
cFPVAddSafeFrameValue = true
cFPVAddNewLayerValue = true
cFPVNewLayerNameValue = "_Cams"
cFPVPosValue = [400,400]

-- Functions

fn cameraFromPerspView cFPVcamType cFPVAddSafeFrame cFPVAddNewLayer cFPVNewLayerName = 
	(
	undo "cameraFromPerspView" on
		(
		focdistance = gw.GetFocalDist()
		tm = inverse (viewport.getTM())
		cp = ray tm[4] -tm[3]
		ct = targetobject position:(cp.pos+(cp.dir*focdistance))
		fov_value = getViewFOV()

		myerror = false
		-- Max Camera
		if cFPVcamType == 1 then 
			(
			newCam = targetcamera pos:cp.pos target:ct
			newCam.fov = fov_value		
			)
		-- Brazil 1
		else if cFPVcamType == 2 then 
			(
			if (sLibBrazil1Test() == false) then (MessageBox "Please install Brazil 1.x to use this option." title:"cameraFromPerspView";myerror=true)
			else
				(
				newCam = BCam cam_type:1 pos:cp.pos target:ct
				newCam.fov_ui_value = fov_value
				)
			)
		-- Brazil 2
		else if cFPVcamType == 3 then 
			(
			if (sLibBrazil2Test() == false) then (MessageBox "Please install Brazil 2.x to use this option." title:"cameraFromPerspView";myerror=true)
			else
				(
				newCam = Main_Camera target_on:on pos:cp.pos target:ct
				newCam.lens.fov = fov_value
				)
			)
		-- Vray Physical Camera
		else if cFPVcamType == 4 then 
			(
			if sLibMaxVer() > 17.0 then (MessageBox "This camera type no longer exists in Max 2016 and above." title:"cameraFromPerspView";myerror=true)
			else
				(
				if (sLibVrayTest() == false) then (MessageBox "Please install Vray 2.4 to use this option." title:"cameraFromPerspView";myerror=true)
				else
					(
					newCam = VRayPhysicalCamera pos:cp.pos target:ct
					newCam.specify_fov = on
					newCam.fov = fov_value
					newCam.exposure = on
					newCam.vignetting = off
					newCam.whiteBalance_preset = 1
					newCam.f_number = 5.6
					newCam.shutter_speed = 50
					newCam.ISO = 400
					)
				)
			)
		-- Max Physical Camera
		else if cFPVcamType == 5 then 
			(
			if sLibMaxVer() < 18.0 then (MessageBox "This camera type only works in Max 2016 and above." title:"cameraFromPerspView";myerror=true)
			else
				(
				newCam = Physical pos:cp.pos target:ct
				newCam.specify_fov = on
				newCam.fov = fov_value
				newCam.vignetting_enabled = off
				newCam.white_balance_type = 2
				newCam.f_number = 5.6
				newCam.shutter_unit_type = 0
				newCam.shutter_length_seconds = 0.02
				newCam.exposure_gain_type = 0
				newCam.iso = 400
				)
			)

		if myerror == false then
			(
			newCam.name = (Uniquename "Cam")
			newCam.target.name = newCam.name + ".Target"
			objs = #(newCam,newCam.target)
			viewport.setCamera newCam
			displaySafeFrames = cFPVAddSafeFrame
			if cFPVAddNewLayer == true then 
				(
				if LayerManager.getLayerFromName cFPVNewLayerName == undefined then layermanager.newLayerFromName cFPVNewLayerName
				myLayer = LayerManager.getLayerFromName cFPVNewLayerName
				for obj in objs do myLayer.addnode obj
				)
			)
		)
	)

fn cameraFromPerspViewDefaults = 
	(
	cFPVLoadDef()
	cameraFromPerspView cFPVCamTypeValue cFPVAddSafeFrameValue cFPVAddNewLayerValue cFPVNewLayerNameValue
	)
	
fn cameraFromPerspViewUI = 
	(
	cFPVLoadDef()
	cFPVCloseOpenUI cFPVPosValue
	)

fn cFPVCloseOpenUI pos = 
	(
	if cFPVFloater != undefined then CloseRolloutFloater cFPVFloater
	cFPVDefineUI()
	cFPVFloater = newRolloutFloater "cameraFromPerspView v1.09" 310 133 pos.x pos.y
	addRollout cFPVRollout cFPVFloater
	)

fn cFPVDo = 
	(
	cameraFromPerspView cFPVCamTypeValue cFPVAddSafeFrameValue cFPVAddNewLayerValue cFPVNewLayerNameValue
	if cFPVFloater != undefined then CloseRolloutFloater cFPVFloater
	)

fn cFPVApply = 
	(
	cameraFromPerspView cFPVCamTypeValue cFPVAddSafeFrameValue cFPVAddNewLayerValue cFPVNewLayerNameValue
	)
	
fn cFPVHelp = 
	(
	sLibSSPrintHelp "cameraFromPerspView"
	)
	
fn cFPVLoadDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	cFPVInputFilename = presetDir + "cameraFromPerspView.ini"
	if (sLibFileExist cFPVInputFilename == true) then
		(
		cFPVCamTypeValue = execute (getINISetting cFPVInputFilename "cameraFromPerspView" "cFPVCamTypeValue")
		cFPVAddSafeFrameValue = execute (getINISetting cFPVInputFilename "cameraFromPerspView" "cFPVAddSafeFrameValue")
		cFPVAddNewLayerValue = execute (getINISetting cFPVInputFilename "cameraFromPerspView" "cFPVAddNewLayerValue")
		cFPVNewLayerNameValue = getINISetting cFPVInputFilename "cameraFromPerspView" "cFPVNewLayerNameValue"
		cFPVPosValue = execute (getINISetting cFPVInputFilename "cameraFromPerspView" "cFPVPosValue")
		
		if cFPVCamTypeValue == OK then cFPVCamTypeValue = 1
		if cFPVAddSafeFrameValue == OK then cFPVAddSafeFrameValue = true
		if cFPVAddNewLayerValue == OK then cFPVAddNewLayerValue = true
		if cFPVNewLayerNameValue == OK then cFPVNewLayerNameValue = "_Cams"
		if cFPVPosValue == OK then cFPVPosValue = [400,400]
		)
	else
		(
		cFPVCamTypeValue = 1
		cFPVAddSafeFrameValue = true
		cFPVAddNewLayerValue = true
		cFPVNewLayerNameValue = "_Cams"
		cFPVPosValue = [400,400]
		)
	)
	
fn cFPVSaveDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	if (getDirectories presetDir).count == 0 then makeDir presetDir
	cFPVOutputFilename = presetDir + "cameraFromPerspView.ini"
	if (sLibFileExist cFPVOutputFilename == true) then deleteFile cFPVOutputFilename
	setINISetting cFPVOutputFilename "cameraFromPerspView" "cFPVCamTypeValue" (cFPVCamTypeValue as string)
	setINISetting cFPVOutputFilename "cameraFromPerspView" "cFPVAddSafeFrameValue" (cFPVAddSafeFrameValue as string)
	setINISetting cFPVOutputFilename "cameraFromPerspView" "cFPVAddNewLayerValue" (cFPVAddNewLayerValue as string)
	setINISetting cFPVOutputFilename "cameraFromPerspView" "cFPVNewLayerNameValue" (cFPVNewLayerNameValue as string)
	setINISetting cFPVOutputFilename "cameraFromPerspView" "cFPVPosValue" (cFPVFloater.pos as string)
	)

-- UI

fn cFPVDefineUI = 
	(
	rollout cFPVRollout "cameraFromPerspView"
		(
		dropdownlist cFPVCamTypeDropdown "" items:#("Max Camera", "Brazil 1 Camera", "Brazil 2 Camera", "Vray Physical Camera", "Max Physical Camera") selection:cFPVCamTypeValue
		checkbox cFPVAddSafeFrameCheckbox "Add Safeframe?" checked:cFPVAddSafeFrameValue align:#left
		checkbox cFPVAddNewLayerCheckbox "Add To Layer?" checked:cFPVAddNewLayerValue align:#left across:2
		edittext cFPVNewLayerNameEditText "" fieldWidth:150 text:cFPVNewLayerNameValue offset:[-50,1] enabled:cFPVAddNewLayerValue
		
		on cFPVCamTypeDropdown selected i do cFPVCamTypeValue = i
		on cFPVAddSafeFrameCheckbox changed state do cFPVAddSafeFrameValue = state
		on cFPVAddNewLayerCheckbox changed state do 
			(
			cFPVAddNewLayerValue = state
			cFPVNewLayerNameEditText.enabled = state
			)
		on cFPVNewLayerNameEditText changed text do cFPVNewLayerNameValue = cFPVNewLayerNameEditText.text

		button cFPVDoButton "Do" width:70 toolTip:"Do It and Close UI" pos:[5,78]
		on cFPVDoButton pressed do cFPVDo()
		button cFPVApplyButton "Apply" width:70 toolTip:"Do It and Keep UI Open" pos:[77,78]
		on cFPVApplyButton pressed do cFPVApply()
		button cFPVHelpButton "Help" width:70 toolTip:"Help" pos:[149,78]
		on cFPVHelpButton pressed do cFPVHelp()
		button cFPVSaveDefButton "SaveDef" width:70 toolTip:"Save Current Settings as Default" pos:[221,78]
		on cFPVSaveDefButton pressed do cFPVSaveDef()
		)
	)
)
-------------------------------------------------------------------------------