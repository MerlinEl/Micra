-------------------------------------------------------------------------------
-- maxfileOldVersionSaver.ms
-- By Neil Blevins (info@neilblevins.com)
-- v 1.03
-- Created On: 07/01/14
-- Modified On: 06/10/15
-- tested using Max 2014
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Required Files:
-- sLib.ms
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Description:
-- Collects all of the max files in a directory and its subdirectories and
-- saves them as max files for older versions of max.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Tutorial:
-- Run the UI version of the script. Choose a Directory. Hit Do. All the maxfiles
-- in that directory are now coverted to the older max version.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Revision History:
--
-- v 1.01 Added Max 2015 and Max 2016. Now when it opens the max files in a 
-- directory it does so in silent mode so that it doesn't produce unwanted 
-- warning dialogs.
--
-- v 1.02 Added more error checking and the ability to save in the current max 
-- version.
--
-- v 1.03 Script now resets the max scene after processing last file.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
(
-- Globals

global maxfileOldVersionSaver
global maxfileOldVersionSaverDefaults
global maxfileOldVersionSaverUI

global mOVSCloseOpenUI

global mOVSDo
global mOVSApply
global mOVSHelp
global mOVSLoadDef
global mOVSSaveDef

global mOVSDefineUI
global mOVSRollout
global mOVSFloater

-- Includes

include "$scripts\SoulburnScripts\lib\sLib.ms"

-- Variables

mOVSPathValue = ""
mOVSRecValue = 5
mOVSVersionValue = true
mOVSPosValue = [400,400]

-- Functions

fn maxfileOldVersionSaver mOVSPath mOVSRec mOVSVersion = 
	(
	if mOVSPath != "" then 
		(
		a = sLibGetAllFilesInDir mOVSPath mOVSRec "max"
		
		value = 1
		if mOVSVersion == 2 then value = 2011
		else if mOVSVersion == 3 then value = 2012
		else if mOVSVersion == 4 then value = 2013
		else if mOVSVersion == 5 then value = 2014
		else if mOVSVersion == 6 then value = 2015
		else if mOVSVersion == 7 then value = 2016

		disableSceneRedraw()
		try
			(
			for i in a do
				(
				loadMaxFile i quiet:true
				if value == 1 then saveMaxFile i else saveMaxFile i saveAsVersion:value
				print ("Processed file: " + i)
				)
			)
		catch (MessageBox "An error has occured, perhaps this version of max can't save the version of max file you have requested." title:"maxfileOldVersionSaver")
		enableSceneRedraw()
		completeRedraw()
		resetMaxFile #noPrompt
		)
	else (MessageBox "Please pick a valid path" title:"maxfileOldVersionSaver")
	)
	
fn maxfileOldVersionSaverDefaults = 
	(
	mOVSLoadDef()
	maxfileOldVersionSaver mOVSPathValue mOVSRecValue mOVSVersionValue
	)
	
fn maxfileOldVersionSaverUI = 
	(
	mOVSLoadDef()
	mOVSCloseOpenUI mOVSPosValue
	)

fn mOVSCloseOpenUI pos = 
	(
	if mOVSFloater != undefined then CloseRolloutFloater mOVSFloater
	mOVSDefineUI()
	mOVSFloater = newRolloutFloater "maxfileOldVersionSaver v1.03" 310 154 pos.x pos.y
	addRollout mOVSRollout mOVSFloater
	)

fn mOVSDo = 
	(
	maxfileOldVersionSaver mOVSPathValue mOVSRecValue mOVSVersionValue
	if mOVSFloater != undefined then CloseRolloutFloater mOVSFloater
	)

fn mOVSApply = 
	(
	maxfileOldVersionSaver mOVSPathValue mOVSRecValue mOVSVersionValue
	)
	
fn mOVSHelp = 
	(
	sLibSSPrintHelp "maxfileOldVersionSaver"
	)
	
fn mOVSLoadDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	mOVSInputFilename = presetDir + "maxfileOldVersionSaver.ini"
	if (sLibFileExist mOVSInputFilename == true) then
		(
		mOVSPathValue = (getINISetting mOVSInputFilename "maxfileOldVersionSaver" "mOVSPathValue")
		mOVSRecValue = execute (getINISetting mOVSInputFilename "maxfileOldVersionSaver" "mOVSRecValue")
		mOVSVersionValue = execute (getINISetting mOVSInputFilename "maxfileOldVersionSaver" "mOVSVersionValue")
		mOVSPosValue = execute (getINISetting mOVSInputFilename "maxfileOldVersionSaver" "mOVSPosValue")
		
		if mOVSPathValue == OK then mOVSPathValue = ""
		if mOVSRecValue == OK then mOVSRecValue = true
		if mOVSVersionValue == OK then mOVSVersionValue = 5
		if mOVSPosValue == OK then mOVSPosValue = [400,400]
		)
	else
		(
		mOVSPathValue = ""
		mOVSRecValue = true
		mOVSVersionValue = 5
		mOVSPosValue = [400,400]
		)
	)
	
fn mOVSSaveDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	if (getDirectories presetDir).count == 0 then makeDir presetDir
	mOVSOutputFilename = presetDir + "maxfileOldVersionSaver.ini"
	if (sLibFileExist mOVSOutputFilename == true) then deleteFile mOVSOutputFilename
	setINISetting mOVSOutputFilename "maxfileOldVersionSaver" "mOVSPathValue" (mOVSPathValue as string)
	setINISetting mOVSOutputFilename "maxfileOldVersionSaver" "mOVSRecValue" (mOVSRecValue as string)
	setINISetting mOVSOutputFilename "maxfileOldVersionSaver" "mOVSVersionValue" (mOVSVersionValue as string)
	setINISetting mOVSOutputFilename "maxfileOldVersionSaver" "mOVSPosValue" (mOVSFloater.pos as string)
	)

-- UI

fn mOVSDefineUI = 
	(
	rollout mOVSRollout "maxfileOldVersionSaver"
		(
		edittext mOVSPathEditText "" fieldWidth:240 text:mOVSPathValue align:#left across:2
		button mOVSGetPathButton "F" width:20 toolTip:"Choose Path" align:#right offset:[0,-2]

		on mOVSPathEditText changed text do 
			(
			if text[text.count] != "\\" then text = text + "\\"
			mOVSPathValue = text
			mOVSPathEditText.text = text
			)
		on mOVSGetPathButton pressed do 
			(
			mypath = getSavePath()
			if mypath != undefined then 
				(
				if mypath[mypath.count] != "\\" then mypath = mypath + "\\"
				mOVSPathValue = mypath
				mOVSPathEditText.text = mypath
				)
			else 
				(
				mOVSPathValue = ""
				mOVSPathEditText.text = ""
				)
			)

		checkbox mOVSRecCheckbox "Recurse Subdirs:" checked:mOVSRecValue align:#left
		on mOVSRecCheckbox changed state do mOVSRecValue = state
			
		dropdownlist mOVSVersionDropdown "Convert To:" items:#("Current Version", "Max 2011", "Max 2012", "Max 2013", "Max 2014", "Max 2015", "Max 2016") selection:mOVSVersionValue width:120
		on mOVSVersionDropdown selected i do mOVSVersionValue = i

		button mOVSDoButton "Do" width:70 toolTip:"Do It and Close UI" pos:[5,98]
		on mOVSDoButton pressed do mOVSDo()
		button mOVSApplyButton "Apply" width:70 toolTip:"Do It and Keep UI Open" pos:[77,98]
		on mOVSApplyButton pressed do mOVSApply()
		button mOVSHelpButton "Help" width:70 toolTip:"Help" pos:[149,98]
		on mOVSHelpButton pressed do mOVSHelp()
		button mOVSSaveDefButton "SaveDef" width:70 toolTip:"Save Current Settings as Default" pos:[221,98]
		on mOVSSaveDefButton pressed do mOVSSaveDef()
		)
	)
)
-------------------------------------------------------------------------------