-------------------------------------------------------------------------------
-- uVPlacer.ms
-- By Neil Blevins (info@neilblevins.com)
-- v 1.05
-- Created On: 03/21/07
-- Modified On: 06/01/08
-- tested using Max 2009
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Required Files:
-- sLib.ms
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Description:
-- Lets you modify the positions of selected uvs using a handy dialog box.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Tutorial:
-- Select a polygonal object, apply a UVWUnwrap modifier to it, edit the uvs
-- using the modifier, select some uvs (either in vertex or edge mode). Run the 
-- UI version of the script, choose whether you want to modify the U or V axis, 
-- then click in the dialog to place your selected uvs at that position.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Revision History:
--
-- v 1.01 Fixed a bug that stopped the script from running in Defaults mode.
--
-- v 1.02 Added ability to affect both the U and V values at the same time. Added
-- four squares that place the value directly at 0.5
--
-- v 1.03 Added Average button, which averages the U or V values of the selected
-- UVs.
--
-- v 1.04 Replaced the Close button with a Help button. Use the X button to 
-- Close the Floater.
--
-- v 1.05 Removed the average button, and replaced the functionality with a new 
-- script called uVFlattener.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
(
-- Globals

global uVPlacer
global uVPlacerDefaults
global uVPlacerUI

global uVPCloseOpenUI

global uVPHelp
global uVPLoadDef
global uVPSaveDef

global uVPDefineUI
global uVPRollout
global uVPFloater

-- Includes

include "$scripts\SoulburnScripts\lib\sLib.ms"

-- Variables

uVPUonValue = true
uVPVonValue = false
uVPUValue = 0
uVPVValue = 0
uVPModeValue = 1
uVPUIYOffsetValue = 0
uVPPosValue = [400,400]

uVPBitmap = openbitmap ((getdir #scripts) + "\\SoulburnScripts\\images\\" + "uVPlacer.bmp")

-- Functions

fn uVPlacer uVPUon uVPVon uVPU uVPV = 
	(
	undo "uVPlacer" on
		(
		if classof (modPanel.getCurrentObject()) == Unwrap_UVW then
			(
			-- change uvs
			if (modPanel.getCurrentObject()).getTVSubObjectMode() == 2 then (modPanel.getCurrentObject()).edgeToVertSelect()
				
			-- make values
			uvalue = 0
			if uVPU < 0 then uvalue = 0
			else if uVPU > 1 then uvalue = 1
			else uvalue = uVPU

			vvalue = 0
			if uVPV < 0 then vvalue = 0
			else if uVPV > 1 then vvalue = 1
			else vvalue = uVPV

			-- set values
			if uVPUon == true then (modPanel.getCurrentObject()).unwrap.moveX uvalue
			if uVPVon == true then (modPanel.getCurrentObject()).unwrap.moveY vvalue
			)
		)
	)
	
fn uVPlacerDefaults = 
	(
	uVPLoadDef()
	uVPlacer uVPUonValue uVPVonValue uVPUValue uVPVValue
	)

fn uVPlacerUI = 
	(
	uVPLoadDef()
	uVPCloseOpenUI uVPPosValue
	)
	
fn uVPCloseOpenUI pos = 
	(
	if uVPFloater != undefined then CloseRolloutFloater uVPFloater
	uVPDefineUI()
	uVPFloater = newRolloutFloater "uVPlacer v1.05" 260 399 pos.x pos.y
	addRollout uVPRollout uVPFloater
	)
	
fn uVPHelp = 
	(
	sLibSSPrintHelp "uVPlacer"
	)
	
fn uVPLoadDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	uVPInputFilename = presetDir + "uVPlacer.ini"
	if (sLibFileExist uVPInputFilename == true) then
		(
		uVPUonValue = execute (getINISetting uVPInputFilename "uVPlacer" "uVPUonValue")
		uVPVonValue = execute (getINISetting uVPInputFilename "uVPlacer" "uVPVonValue")
		uVPUValue = execute (getINISetting uVPInputFilename "uVPlacer" "uVPUValue")
		uVPVValue = execute (getINISetting uVPInputFilename "uVPlacer" "uVPVValue")
		uVPModeValue = execute (getINISetting uVPInputFilename "uVPlacer" "uVPModeValue")
		uVPUIYOffsetValue = execute (getINISetting uVPInputFilename "uVPlacer" "uVPUIYOffsetValue")
		uVPPosValue = execute (getINISetting uVPInputFilename "uVPlacer" "uVPPosValue")
		
		if uVPUonValue == OK then uVPUonValue = true
		if uVPVonValue == OK then uVPVonValue = false
		if uVPUValue == OK then uVPUValue = 0
		if uVPVValue == OK then uVPVValue = 0
		if uVPModeValue == OK then uVPModeValue = 1
		if uVPUIYOffsetValue == OK then uVPUIYOffsetValue = 0
		if uVPPosValue == OK then uVPPosValue = [400,400]
		)
	else
		(
		uVPUonValue = true
		uVPVonValue = false
		uVPUValue = 0
		uVPVValue = 0
		uVPModeValue = 1
		uVPUIYOffsetValue = 0
		uVPPosValue = [400,400]
		)
	)
	
fn uVPSaveDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	if (getDirectories presetDir).count == 0 then makeDir presetDir
	uVPOutputFilename = presetDir + "uVPlacer.ini"
	if (sLibFileExist uVPOutputFilename == true) then deleteFile uVPOutputFilename
	setINISetting uVPOutputFilename "uVPlacer" "uVPUonValue" (uVPUonValue as string)
	setINISetting uVPOutputFilename "uVPlacer" "uVPVonValue" (uVPVonValue as string)
	setINISetting uVPOutputFilename "uVPlacer" "uVPUValue" (uVPUValue as string)
	setINISetting uVPOutputFilename "uVPlacer" "uVPVValue" (uVPVValue as string)
	setINISetting uVPOutputFilename "uVPlacer" "uVPModeValue" (uVPModeValue as string)	
	setINISetting uVPOutputFilename "uVPlacer" "uVPUIYOffsetValue" (uVPUIYOffsetValue as string)
	setINISetting uVPOutputFilename "uVPlacer" "uVPPosValue" (uVPFloater.pos as string)
	)

-- UI

fn uVPDefineUI = 
	(
	rollout uVPRollout "uVPlacer"
		(
		checkbutton uVPModeUButton "U" checked:uVPUonValue width:100 across:2
		checkbutton uVPModeVButton "V" checked:uVPVonValue width:100
		group "Value"
		(
		imgTag uVPImgTag bitmap:uVPBitmap align:#center
		)
		dropdownlist uVPModeDropdown "" items:#("Single Axis Mode", "Dual-Axis Mode") selection:uVPModeValue width:140 align:#center
		spinner uVPUIYOffsetSpinner "UI Y Offset:" range:[-20,50,uVPUIYOffsetValue] fieldWidth:30 type:#integer align:#center
	
		on uVPImgTag click do 
			(
			uVPMX = mouse.screenpos.x
			uVPMY = mouse.screenpos.y
			uVPFX = uVPFloater.pos.x
			uVPFY = uVPFloater.pos.y
			uVPUY = uVPUIYOffsetValue
			if uVPMX > uVPFX+22 and uVPMX < uVPFX+34 and uVPMY > uVPFY+uVPUY+214 and uVPMY < uVPFY+uVPUY+226 then uVPlacer uVPUonValue uVPVonValue 0 0.5
			else if uVPMX > uVPFX+236 and uVPMX < uVPFX+248 and uVPMY > uVPFY+uVPUY+214 and uVPMY < uVPFY+uVPUY+226 then uVPlacer uVPUonValue uVPVonValue 1 0.5
			else if uVPMX > uVPFX+129 and uVPMX < uVPFX+141 and uVPMY > uVPFY+uVPUY+110 and uVPMY < uVPFY+uVPUY+122 then uVPlacer uVPUonValue uVPVonValue 0.5 1
			else if uVPMX > uVPFX+129 and uVPMX < uVPFX+141 and uVPMY > uVPFY+uVPUY+322 and uVPMY < uVPFY+uVPUY+334 then uVPlacer uVPUonValue uVPVonValue 0.5 0
			else uVPlacer uVPUonValue uVPVonValue (0.01*(0.5*(uVPMX - uVPFX-35))) (0.01*(100-(0.5*(uVPMY - uVPFY + uVPUY - 121))))
			)
		on uVPModeUButton changed state do 
			(
			if state == true then
				(
				if uVPModeValue == 1 then (uVPUonValue = true;uVPVonValue = false;uVPModeVButton.checked = false)
				else uVPUonValue = state
				)
			else 
				(
				uVPUonValue = state
				)
			)
		on uVPModeVButton changed state do 
			(
			if state == true then
				(
				if uVPModeValue == 1 then (uVPUonValue = false;uVPVonValue = true;uVPModeUButton.checked = false)
				else uVPVonValue = state
				)
			else 
				(
				uVPVonValue = state
				)
			)

		on uVPModeDropdown selected i do 
			(
			uVPModeValue = i
			if uVPModeValue == 1 then 
				(
				if uVPUonValue == true then (uVPModeUButton.checked = true;uVPModeVButton.checked = false;uVPVonValue = false)
				else if uVPUonValue == false then (uVPModeUButton.checked = false;uVPModeVButton.checked = true)
				)
			)
		on uVPUIYOffsetSpinner changed val do uVPUIYOffsetValue = val
	
		button uVPHelpButton "Help" width:70 toolTip:"Help" pos:[48,343]
		on uVPHelpButton pressed do uVPHelp()
		button uVPSaveDefButton "SaveDef" width:70 toolTip:"Save Current Settings as Default" pos:[120,343]
		on uVPSaveDefButton pressed do uVPSaveDef()
		
		on uVPRollout open do
			(
			if uVPModeValue == 1 then 
				(
				if uVPUonValue == true then (uVPModeUButton.checked = true;uVPModeVButton.checked = false;uVPVonValue = false)
				else if uVPUonValue == false then (uVPModeUButton.checked = false;uVPModeVButton.checked = true)
				)
			)
		)
	)
)
-------------------------------------------------------------------------------