-------------------------------------------------------------------------------
-- viewportControl.ms
-- By Neil Blevins (info@neilblevins.com)
-- v 1.03
-- Created On: 10/09/05
-- Modified On: 04/18/08
-- tested using Max 7.1
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Required Files:
-- sLib.ms
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Description:
-- Lets you control the view you're currently seeing in the viewport in a handy
-- dialog box.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Tutorial:
-- Select a view. Run the UI version of the script. Click one of the big letters,
-- like T. Now your viewport will change to a Top view. Click the C button. It
-- gives you a list of all cameras in the scene. Double-click one of them to 
-- choose that camera view.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Revision History:
--
-- v 1.01 Defined ui as new function. Added Expert Mode.
--
-- v 1.02 Added some new code to more cleanly open and close the UI.
--
-- v 1.03 Replaced the Close button with a Help button. Use the X button to 
-- Close the Floater.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
(
-- Globals

global viewportControl
global viewportControlDefaults
global viewportControlUI
global viewportControlExpertMode

global VCCloseOpenUI

global vCCamList
global vCSwitchToCam

global vCDo
global vCApply
global vCHelp
global vCLoadDef
global vCSaveDef

global vCDefineUI
global vCRollout
global vCDefineEMUI
global vCEMRollout
global vCCamRollout
global vCFloater

-- Includes

include "$scripts\SoulburnScripts\lib\sLib.ms"

-- Variables

vCSceneCams = #()
vCSceneCamsNames = #()
vCCurrentCamera = 1

vCViewValue = 1
vCAutoZoomValue = true
vCZoomRegionValue = true
vCCamSafeFrameValue = true
vCUIYOffsetValue = 0
vCPosValue = [400,400]

vCBitmap = openbitmap ((getdir #scripts) + "\\SoulburnScripts\\images\\" + "viewportControl.bmp")

-- Functions

fn viewportControl vCView vCAutoZoom vCZoomRegion vCCamSafeFrame = 
	(
	undo "viewportControl" on
		(
		if vCView < 8 then
			(
			disableSceneRedraw()
			displaySafeFrames = false

			if vCView == 1 then viewport.setType #view_top
			else if vCView == 2 then viewport.setType #view_bottom
			else if vCView == 3 then viewport.setType #view_front
			else if vCView == 4 then viewport.setType #view_back
			else if vCView == 5 then viewport.setType #view_left
			else if vCView == 6 then viewport.setType #view_right
			else if vCView == 7 then viewport.setType #view_persp_user

			if vCAutoZoom == true then max tool zoomextents
			if vCZoomRegion == true then max tool zoomregion
			enableSceneRedraw()
			redrawViews()
			)
		if vCView == 8 then vCCamList()
		)
	)
	
fn viewportControlDefaults = 
	(
	vCLoadDef()
	viewportControl vCViewValue vCAutoZoomValue vCZoomRegionValue vCCamSafeFrameValue
	)

fn viewportControlUI = 
	(
	vCLoadDef()
	vCCloseOpenUI vCPosValue
	)
	
fn vCCloseOpenUI pos = 
	(
	if vCFloater != undefined then CloseRolloutFloater vCFloater
	vCDefineUI()
	vCFloater = newRolloutFloater "viewportControl v1.03" 120 297 pos.x pos.y
	addRollout vCRollout vCFloater
	)
	
fn viewportControlExpertMode = 
	(
	vCLoadDef()
	if vCEMRollout != undefined then destroydialog vCEMRollout
	vCDefineEMUI()
	createDialog vCEMRollout style:#(#style_titlebar, #style_sysmenu) bitmap:vCBitmap model:false width:106 height:106 pos:[vCPosValue.x,vCPosValue.y]
	)

fn vCCamList = 
	(
	-- Setup Variables
	vCSceneCams = #()
	vCSceneCamsNames = #()
	vCCurrentCamera = 1

	-- Collect The Cameras
	for c in cameras do
		(
		if sLibCameraFilter c == true then append vCSceneCams c
		)
	qsort vCSceneCams sLibNameCompareCaseInsensitive
	for c in vCSceneCams do append vCSceneCamsNames c.name

	-- Set Dialog Height
	heightValue = ((13 * vCSceneCams.count) + 20)
	if heightValue > systemTools.GetScreenHeight() then heightValue = (systemTools.GetScreenHeight() - 20)
	
	-- Find Current Camera
	if viewport.getCamera() != undefined then vCCurrentCamera = finditem vCSceneCams (viewport.getCamera())

	-- Show Dialog	
	if vCSceneCams.count == 0 then (MessageBox "No Cameras In Scene" title:"viewportControl")
	else 
		(
		if vCSceneCams.count == 1 then vCSwitchToCam vCCurrentCamera vCCamSafeFrameValue
		else 
			(
			createDialog vCCamRollout modal:true width:250 height:heightValue pos:[mouse.screenpos.x, mouse.screenpos.y]
			)
		)
	)
	
fn vCSwitchToCam theCam vCCamSafeFrame = 
	(
	disableSceneRedraw()
	viewport.setCamera vCSceneCams[theCam]
	displaySafeFrames = vCCamSafeFrame
	destroydialog vCCamRollout
	enableSceneRedraw()
	redrawViews()
	)

fn vCDo = 
	(
	viewportControl vCViewValue vCAutoZoomValue vCZoomRegionValue vCCamSafeFrameValue
	if vCFloater != undefined then CloseRolloutFloater vCFloater
	)

fn vCApply = 
	(
	viewportControl vCViewValue vCAutoZoomValue vCZoomRegionValue vCCamSafeFrameValue
	)
	
fn vCHelp = 
	(
	sLibSSPrintHelp "viewportControl"
	)
	
fn vCLoadDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	vCInputFilename = presetDir + "viewportControl.ini"
	if (sLibFileExist vCInputFilename == true) then
		(
		vCViewValue = execute (getINISetting vCInputFilename "viewportControl" "vCViewValue")
		vCAutoZoomValue = execute (getINISetting vCInputFilename "viewportControl" "vCAutoZoomValue")
		vCZoomRegionValue = execute (getINISetting vCInputFilename "viewportControl" "vCZoomRegionValue")
		vCCamSafeFrameValue = execute (getINISetting vCInputFilename "viewportControl" "vCCamSafeFrameValue")
		vCUIYOffsetValue = execute (getINISetting vCInputFilename "viewportControl" "vCUIYOffsetValue")
		vCPosValue = execute (getINISetting vCInputFilename "viewportControl" "vCPosValue")
		
		if vCViewValue == OK then vCViewValue = 1
		if vCAutoZoomValue == OK then vCAutoZoomValue = true		
		if vCZoomRegionValue == OK then vCZoomRegionValue = true
		if vCCamSafeFrameValue == OK then vCCamSafeFrameValue = true
		if vCPosValue == OK then vCPosValue = [400,400]
		if vCUIYOffsetValue == OK then vCUIYOffsetValue = 0
		)
	else
		(
		vCViewValue = 1
		vCAutoZoomValue = true
		vCZoomRegionValue = true
		vCCamSafeFrameValue = true
		vCPosValue = [400,400]
		vCUIYOffsetValue = 0
		)
	)
	
fn vCSaveDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	if (getDirectories presetDir).count == 0 then makeDir presetDir
	vCOutputFilename = presetDir + "viewportControl.ini"
	if (sLibFileExist vCOutputFilename == true) then deleteFile vCOutputFilename
	setINISetting vCOutputFilename "viewportControl" "vCViewValue" (vCViewValue as string)
	setINISetting vCOutputFilename "viewportControl" "vCAutoZoomValue" (vCAutoZoomValue as string)
	setINISetting vCOutputFilename "viewportControl" "vCZoomRegionValue" (vCZoomRegionValue as string)
	setINISetting vCOutputFilename "viewportControl" "vCCamSafeFrameValue" (vCCamSafeFrameValue as string)
	setINISetting vCOutputFilename "viewportControl" "vCUIYOffsetValue" (vCUIYOffsetValue as string)
	setINISetting vCOutputFilename "viewportControl" "vCPosValue" (vCFloater.pos as string)
	)

-- UI

fn vCDefineUI = 
	(
	rollout vCRollout "viewportControl"
		(
		imgTag vCImgTag bitmap:vCBitmap align:#center
		spinner vCViewSpinner "Place:" range:[1,27,vCViewValue] fieldWidth:37 type:#integer align:#center
		checkbox vCAutoZoomCheckbox "Auto Zoom" checked:vCAutoZoomValue align:#center
		checkbox vCZoomRegionCheckbox "Zoom Region" checked:vCZoomRegionValue align:#center
		checkbox vCCamSafeFrameCheckbox "Cam SafeFrame" checked:vCCamSafeFrameValue align:#center
		spinner vCUIYOffsetSpinner "UI Y Offset:" range:[-20,50,vCUIYOffsetValue] fieldWidth:30 type:#integer align:#right offset:[7,0]
	
		on vCImgTag click do 
			(
			vCMX = mouse.screenpos.x
			vCMY = mouse.screenpos.y
			vCFX = vCFloater.pos.x
			vCFY = vCFloater.pos.y
			vCUY = vCUIYOffsetValue
			if vCMX > vCFX+18 and vCMX < vCFX+44 and vCMY > vCFY+vCUY+64 and vCMY < vCFY+vCUY+90 then (viewportControl 1 vCAutoZoomValue vCZoomRegionValue vCCamSafeFrameValue; vCViewValue = 1; vCViewSpinner.value = 1)
			if vCMX > vCFX+46 and vCMX < vCFX+64 and vCMY > vCFY+vCUY+92 and vCMY < vCFY+vCUY+110 then (viewportControl 2 vCAutoZoomValue vCZoomRegionValue vCCamSafeFrameValue; vCViewValue = 2; vCViewSpinner.value = 2)
			if vCMX > vCFX+68 and vCMX < vCFX+94 and vCMY > vCFY+vCUY+64 and vCMY < vCFY+vCUY+90 then (viewportControl 3 vCAutoZoomValue vCZoomRegionValue vCCamSafeFrameValue; vCViewValue = 3; vCViewSpinner.value = 3)
			if vCMX > vCFX+96 and vCMX < vCFX+114 and vCMY > vCFY+vCUY+92 and vCMY < vCFY+vCUY+110 then (viewportControl 4 vCAutoZoomValue vCZoomRegionValue vCCamSafeFrameValue; vCViewValue = 4; vCViewSpinner.value = 4)
			if vCMX > vCFX+18 and vCMX < vCFX+44 and vCMY > vCFY+vCUY+114 and vCMY < vCFY+vCUY+141 then (viewportControl 5 vCAutoZoomValue vCZoomRegionValue vCCamSafeFrameValue; vCViewValue = 5; vCViewSpinner.value = 5)
			if vCMX > vCFX+46 and vCMX < vCFX+64 and vCMY > vCFY+vCUY+142 and vCMY < vCFY+vCUY+160 then (viewportControl 6 vCAutoZoomValue vCZoomRegionValue vCCamSafeFrameValue; vCViewValue = 6; vCViewSpinner.value = 6)
			if vCMX > vCFX+68 and vCMX < vCFX+94 and vCMY > vCFY+vCUY+114 and vCMY < vCFY+vCUY+141 then (viewportControl 8 vCAutoZoomValue vCZoomRegionValue vCCamSafeFrameValue; vCViewValue = 8; vCViewSpinner.value = 8)
			if vCMX > vCFX+96 and vCMX < vCFX+114 and vCMY > vCFY+vCUY+142 and vCMY < vCFY+vCUY+160 then (viewportControl 7 vCAutoZoomValue vCZoomRegionValue vCCamSafeFrameValue; vCViewValue = 7; vCViewSpinner.value = 7)
			)
		on vCViewSpinner changed val do vCViewValue = val
		on vCAutoZoomCheckbox changed state do vCAutoZoomValue = state
		on vCZoomRegionCheckbox changed state do vCZoomRegionValue = state
		on vCCamSafeFrameCheckbox changed state do vCCamSafeFrameValue = state
		on vCUIYOffsetSpinner changed val do vCUIYOffsetValue = val
	
		button vCDoButton "Do" width:47 toolTip:"Do It and Close UI" pos:[5,216]
		on vCDoButton pressed do vCDo()
		button vCApplyButton "Apply" width:47 toolTip:"Do It and Keep UI Open" pos:[54,216]
		on vCApplyButton pressed do vCApply()
		button vCHelpButton "Help" width:47 toolTip:"Help" pos:[5,240]
		on vCHelpButton pressed do vCHelp()
		button vCSaveDefButton "SaveDef" width:47 toolTip:"Save Current Settings as Default" pos:[54,240]
		on vCSaveDefButton pressed do vCSaveDef()
		)
	)
	
fn vCDefineEMUI = 
	(
	rollout vCEMRollout "viewportControl"
		(
		on vCEMRollout lbuttondown clickPos do 
			(
			vCMX = clickPos.x
			vCMY = clickPos.y
			if vCMX > 6 and vCMX < 33 and vCMY > 5 and vCMY < 32 then viewportControl 1 vCAutoZoomValue vCZoomRegionValue vCCamSafeFrameValue
			if vCMX > 35 and vCMX < 50 and vCMY > 33 and vCMY < 52 then viewportControl 2 vCAutoZoomValue vCZoomRegionValue vCCamSafeFrameValue
			if vCMX > 55 and vCMX < 82 and vCMY > 5 and vCMY < 32 then viewportControl 3 vCAutoZoomValue vCZoomRegionValue vCCamSafeFrameValue
			if vCMX > 85 and vCMX < 104 and vCMY > 33 and vCMY < 52 then viewportControl 4 vCAutoZoomValue vCZoomRegionValue vCCamSafeFrameValue
			if vCMX > 6 and vCMX < 33 and vCMY > 55 and vCMY < 82 then viewportControl 5 vCAutoZoomValue vCZoomRegionValue vCCamSafeFrameValue
			if vCMX > 35 and vCMX < 50 and vCMY > 85 and vCMY < 102 then viewportControl 6 vCAutoZoomValue vCZoomRegionValue vCCamSafeFrameValue
			if vCMX > 55 and vCMX < 82 and vCMY > 55 and vCMY < 82 then viewportControl 8 vCAutoZoomValue vCZoomRegionValue vCCamSafeFrameValue
			if vCMX > 85 and vCMX < 104 and vCMY > 85 and vCMY < 102 then viewportControl 7 vCAutoZoomValue vCZoomRegionValue vCCamSafeFrameValue
			)
		)
	)

rollout vCCamRollout "viewportControl" 
	(
	listbox vCCameraSelectListbox items:vCSceneCamsNames height:vCSceneCamsNames.count selection:vCCurrentCamera
	on vCCameraSelectListbox doubleClicked i do vCSwitchToCam i vCCamSafeFrameValue
	)
)
-------------------------------------------------------------------------------