-------------------------------------------------------------------------------
-- calculatorLauncher.ms
-- By Neil Blevins (info@neilblevins.com)
-- v 1.01
-- Created On: 08/05/07
-- Modified On: 04/18/08
-- tested using Max 8.0
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Required Files:
-- sLib.ms
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Description:
-- Launches the calculator. Great for having quick access to the calculator
-- from inside the max interface, assign it to a hotkey. Got the idea from
-- watching one of the blur gnomon DVDs.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Tutorial:
-- Run the UI version of the script. Make sure the edittext box points to your
-- windows directory (hit ther SaveDef button to save the location so you 
-- don't have to enter it every time you run the script). Hit Do. The 
-- calculator is run.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Revision History:
--
-- v 1.01 Replaced the Close button with a Help button. Use the X button to 
-- Close the Floater.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
(
-- Globals

global calculatorLauncher
global calculatorLauncherDefaults
global calculatorLauncherUI

global cLCloseOpenUI

global cLDo
global cLApply
global cLHelp
global cLLoadDef
global cLSaveDef

global cLDefineUI
global cLRollout
global cLFloater

-- Includes

include "$scripts\SoulburnScripts\lib\sLib.ms"

-- Variables

cLWinDirValue = "C:/WINDOWS/"
cLPosValue = [400,400]

-- Functions

fn calculatorLauncher cLWinDir = 
	(
	if cLWinDir[cLWinDir.count] != "/" then cLWinDir += "/"
	myFile = cLWinDir + "system32/calc.exe"
	if (shellLaunch myFile "") == false then (MessageBox "Can't find the calculator program. Please make sure you have entered the correct path to your windows directory, for example: C:/WINDOWS/." title:"calculatorLauncher")
	)
	
fn calculatorLauncherDefaults = 
	(
	cLLoadDef()
	calculatorLauncher cLWinDirValue
	)
	
fn calculatorLauncherUI = 
	(
	cLLoadDef()
	cLCloseOpenUI cLPosValue
	)

fn cLCloseOpenUI pos = 
	(
	if cLFloater != undefined then CloseRolloutFloater cLFloater
	cLDefineUI()
	cLFloater = newRolloutFloater "calculatorLauncher v1.01" 310 91 pos.x pos.y
	addRollout cLRollout cLFloater
	)

fn cLDo = 
	(
	calculatorLauncher cLWinDirValue
	if cLFloater != undefined then CloseRolloutFloater cLFloater
	)

fn cLApply = 
	(
	calculatorLauncher cLWinDirValue
	)
	
fn cLHelp = 
	(
	isLibSSPrintHelp "calculatorLauncher"
	)
	
fn cLLoadDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	cLInputFilename = presetDir + "calculatorLauncher.ini"
	if (sLibFileExist cLInputFilename == true) then
		(
		cLWinDirValue = execute (getINISetting cLInputFilename "calculatorLauncher" "cLWinDirValue")
		cLPosValue = execute (getINISetting cLInputFilename "calculatorLauncher" "cLPosValue")
		
		if cLWinDirValue == OK then cLWinDirValue = "C:/WINDOWS/"
		if cLPosValue == OK then cLPosValue = [400,400]
		)
	else
		(
		cLWinDirValue = "C:/WINDOWS/"
		cLPosValue = [400,400]
		)
	)
	
fn cLSaveDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	if (getDirectories presetDir).count == 0 then makeDir presetDir
	cLOutputFilename = presetDir + "calculatorLauncher.ini"
	if (sLibFileExist cLOutputFilename == true) then deleteFile cLOutputFilename
	setINISetting cLOutputFilename "calculatorLauncher" "cLWinDirValue" (cLWinDirValue as string)
	setINISetting cLOutputFilename "calculatorLauncher" "cLPosValue" (cLFloater.pos as string)
	)

-- UI

fn cLDefineUI = 
	(
	rollout cLRollout "calculatorLauncher"
		(
		label label1 "Windows Dir:" pos:[10,10] across:2
		edittext cLWinDirEditText "" fieldWidth:205 text:cLWinDirValue pos:[75,8]
		on cLWinDirEditText entered text do cLWinDirValue = cLWinDirEditText.text
		
		button cLDoButton "Do" width:70 toolTip:"Do It and Close UI" pos:[5,34]
		on cLDoButton pressed do cLDo()
		button cLApplyButton "Apply" width:70 toolTip:"Do It and Keep UI Open" pos:[77,34]
		on cLApplyButton pressed do cLApply()
		button cLHelpButton "Help" width:70 toolTip:"Help" pos:[149,34]
		on cLHelpButton pressed do cLHelp()
		button cLSaveDefButton "SaveDef" width:70 toolTip:"Save Current Settings as Default" pos:[221,34]
		on cLSaveDefButton pressed do cLSaveDef()
		)
	)
)
-------------------------------------------------------------------------------