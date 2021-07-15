-------------------------------------------------------------------------------
-- soulburnScriptsLister.ms
-- By Neil Blevins (info@neilblevins.com)
-- v 1.08
-- Created On: 04/15/05
-- Modified On: 01/30/15
-- tested using Max 2014
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Required Files:
-- sLib.ms
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Description:
-- Lets you run any of the SoulburnScripts from a handy dropdownlist.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Tutorial:
-- Run the script in UI form, now select a soulburn script you'd like to run from 
-- the dropdown list. Hit Do. It will run that script.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Revision History:
--
-- v 1.01 Increased height of the dropdown list to accomidate more scripts.
--
-- v 1.02 Increased height of the dropdown list again. Defined ui as new 
-- function. Defined a new mode called Expert Mode.
--
-- v 1.03 Added some new code to more cleanly open and close the UI.
--
-- v 1.04 Replaced the Close button with a Help button. Use the X button to 
-- Close the Floater.
-- 
-- v 1.05 Fixed naming error in internal variables.
-- 
-- v 1.06 Fixed a bug that would cause the script to crash if you hadn't selected 
-- a script for soulburnScriptsLister to run.
-- 
-- v 1.07 This script now uses sLibFilenameFromPath to replace filenameFromPath 
-- that no longer works properly in max 2010.
-- 
-- v 1.08 Now has a script count to tell you how many scripts its loaded.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Known Issues:
-- Ignores mse scripts because they can't be opened with the openfile command.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
(
-- Globals

global soulburnScriptsLister
global soulburnScriptsListerDefaults
global soulburnScriptsListerUI

global sSLCloseOpenUI

global sSLGetScriptList
global sSLGetCurrentScriptIndex

global sSLDo
global sSLApply
global sSLHelp
global sSLLoadDef
global sSLSaveDef

global sSLDefineUI
global sSLRollout
global sSLFloater

-- Includes

include "$scripts\SoulburnScripts\lib\sLib.ms"

-- Variables

sSLCurrentScriptNameValue = ""
sSLTypeValue = 2
sSLPosValue = [400,400]

sSLScriptNames = #()
sSLCurrentScriptIndex = 1

-- Functions

fn soulburnScriptsLister sSLCurrentScriptName sSLType = 
	(
	if sSLCurrentScriptName != "" then
		(
		scriptfile = (openfile ((getdir #scripts) + "\\SoulburnScripts\\scripts\\" + sSLCurrentScriptName + ".ms"))	
		if scriptfile == undefined then	MessageBox "You have chosen an invalid script name. Please choose a new script name from the dropdown list in the UI version of this script." title:"soulburnScriptsLister"
		else
			(
			execute scriptfile
			if sSLType == 1 then
				(
				if (execute (sSLCurrentScriptName + "Defaults")) != undefined then execute (sSLCurrentScriptName + "Defaults()")
				)
			else if sSLType == 2 then
				(
				if (execute (sSLCurrentScriptName + "UI")) != undefined then execute (sSLCurrentScriptName + "UI()")
				)
			else if sSLType == 3 then
				(
				if (execute (sSLCurrentScriptName + "ExpertMode")) != undefined then execute (sSLCurrentScriptName + "ExpertMode()")
				)
			)
		)
	else MessageBox "You have not yet picked a script to execute. Please choose a script name from the dropdown list in the UI version of this script." title:"soulburnScriptsLister"
	)

fn soulburnScriptsListerDefaults = 
	(
	sSLLoadDef()
	soulburnScriptsLister sSLCurrentScriptNameValue sSLTypeValue
	)
	
fn soulburnScriptsListerUI = 
	(
	sSLLoadDef()
	sSLScriptNames = sSLGetScriptList()
	sSLCurrentScriptIndex = sSLGetCurrentScriptIndex sSLCurrentScriptNameValue
	sSLCloseOpenUI sSLPosValue
	)

fn sSLCloseOpenUI pos = 
	(
	if sSLFloater != undefined then CloseRolloutFloater sSLFloater
	sSLDefineUI()
	sSLFloater = newRolloutFloater "soulburnScriptsLister v1.08" 310 118 pos.x pos.y
	addRollout sSLRollout sSLFloater
	)

fn sSLGetScriptList = 
	(
	sNames = #()
	scriptFiles = (sLibGetAllFilesInDir ((getdir #scripts) + "\\SoulburnScripts\\scripts\\") false "ms")
	for i in scriptFiles do
		(
		name = sLibFilenameFromPath i
		append sNames (sLibStripFileExtension name)
		)
	sNames = sLibRemoveItemFromArray sNames "soulburnScriptsLister"
	return sNames
	)

fn sSLGetCurrentScriptIndex sSLCurrentScriptName = 
	(
	sIndex = 1
	if sSLCurrentScriptName != "" then
		(
		if sSLScriptNames.count != 0 then
			(
			for i = 1 to sSLScriptNames.count do
				(
				if (sSLScriptNames[i] as string) == sSLCurrentScriptName then sIndex = i
				)
			)
		)
	return sIndex
	)
	
fn sSLDo = 
	(
	soulburnScriptsLister sSLCurrentScriptNameValue sSLTypeValue
	if sSLFloater != undefined then CloseRolloutFloater sSLFloater
	)

fn sSLApply = 
	(
	soulburnScriptsLister sSLCurrentScriptNameValue sSLTypeValue
	)
	
fn sSLHelp = 
	(
	sLibSSPrintHelp "soulburnScriptsLister"
	)
	
fn sSLLoadDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	sSLInputFilename = presetDir + "soulburnScriptsLister.ini"
	if (sLibFileExist sSLInputFilename == true) then
		(
		sSLCurrentScriptNameValue = getINISetting sSLInputFilename "soulburnScriptsLister" "sSLCurrentScriptNameValue"
		sSLTypeValue = execute (getINISetting sSLInputFilename "soulburnScriptsLister" "sSLTypeValue")
		sSLPosValue = execute (getINISetting sSLInputFilename "soulburnScriptsLister" "sSLPosValue")
		
		if sSLCurrentScriptNameValue == OK then sSLCurrentScriptNameValue = ""
		if sSLTypeValue == OK then sSLTypeValue = 2
		if sSLPosValue == OK then sSLPosValue = [400,400]
		)
	else
		(
		sSLCurrentScriptNameValue = ""
		sSLTypeValue = 2
		sSLPosValue = [400,400]
		)
	)
	
fn sSLSaveDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	if (getDirectories presetDir).count == 0 then makeDir presetDir
	sSLOutputFilename = presetDir + "soulburnScriptsLister.ini"
	if (sLibFileExist sSLOutputFilename == true) then deleteFile sSLOutputFilename
	setINISetting sSLOutputFilename "soulburnScriptsLister" "sSLCurrentScriptNameValue" (sSLCurrentScriptNameValue as string)
	setINISetting sSLOutputFilename "soulburnScriptsLister" "sSLTypeValue" (sSLTypeValue as string)
	setINISetting sSLOutputFilename "soulburnScriptsLister" "sSLPosValue" (sSLFloater.pos as string)
	)

-- UI

fn sSLDefineUI = 
	(
	rollout sSLRollout "soulburnScriptsLister"
		(
		dropdownlist sSLScriptsDrowndown "" items:sSLScriptNames selection:sSLCurrentScriptIndex height:50
		on sSLScriptsDrowndown selected i do sSLCurrentScriptNameValue = sSLScriptsDrowndown.selected

		dropdownlist sSLTypeDropdown "" items:#("Run as Default", "Run as UI", "Run in Expert Mode") selection:sSLTypeValue width:150 align:#left across:2
		label label1 "Script Count: " align:#right offset:[0,2] 
		on sSLTypeDropdown selected i do sSLTypeValue = i

		button sSLDoButton "Do" width:70 toolTip:"Do It and Close UI" pos:[5,61]
		on sSLDoButton pressed do sSLDo()
		button sSLApplyButton "Apply" width:70 toolTip:"Do It and Keep UI Open" pos:[77,61]
		on sSLApplyButton pressed do sSLApply()
		button sSLHelpButton "Help" width:70 toolTip:"Help" pos:[149,61]
		on sSLHelpButton pressed do sSLHelp()
		button sSLSaveDefButton "SaveDef" width:70 toolTip:"Save Current Settings as Default" pos:[221,61]
		on sSLSaveDefButton pressed do sSLSaveDef()

		on sSLRollout open do 
			(
			label1.text = ("Script Count: " + ((sSLScriptNames.count+1) as string))
			sSLCurrentScriptNameValue = sSLScriptsDrowndown.selected
			)
		)
	)
)
-------------------------------------------------------------------------------