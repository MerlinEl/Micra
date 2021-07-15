-------------------------------------------------------------------------------
-- instanceFinder.ms
-- By Neil Blevins (info@neilblevins.com)
-- v 1.08
-- Created On: 03/23/05
-- Modified On: 04/07/18
-- tested using Max 2017
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Required Files:
-- sLib.ms
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Description:
-- Finds instances of the selected object and does various things to them such 
-- as selecting them, printing their names, isolating them, etc.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Tutorial:
-- Make an object. Instance it 5 times. Select the first object. Run the script
-- in UI mode. Hit Do. Now you have both the original object and the 5 instances
-- of the object selected.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Revision History:
--
-- v 1.01 Fixed a bug where hidden instances would remain hidden even after
-- isolate was run.
--
-- v 1.02 Defined ui as new function.
--
-- v 1.03 Added some new code to more cleanly open and close the UI.\
--
-- v 1.04 Allowed it to work with multiple objects.
--
-- v 1.05 Replaced the Close button with a Help button. Use the X button to 
-- Close the Floater.
--
-- v 1.06 Added ability to work on all or visible objects.
--
-- v 1.07 Changed name of script to instanceFinder.
--
-- v 1.08 Modified the code and interface a bit, no new functionality.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
(
-- Globals

global instanceFinder
global instanceFinderDefaults
global instanceFinderUI

global fICloseOpenUI

global fIDo
global fIApply
global fIHelp
global fILoadDef
global fISaveDef

global fIDefineUI
global fIRollout
global fIFloater

-- Includes

include "$scripts\SoulburnScripts\lib\sLib.ms"

-- Variables

fIActionValue = 1
fIVisibleValue = 1
fIPosValue = [400,400]

-- Functions

fn instanceFinder fIAction fIVisible = 
	(
	undo "instanceFinder" on
		(
		-- Prep Arrays
		mainText = ""
		all = #()
		a = #()
		s = for i in selection collect i
		for obj in s do 
			(
			inst = (sLibGetInstancesOfObject obj)
			for i in inst do 
				(
				if (finditem all i) == 0 then append all i
				)
			)
		qsort all sLibNameCompareCaseInsensitive
		
		if fIVisible == 1 then a = all
		else if fIVisible == 2 then
			(
			for i in all do
				(
				if i.ishidden == false then append a i
				)
			)
		
		-- Select
		if fIAction == 1 then
			(
			for i in s do if (finditem a i) == 0 then append a i
			if a.count == 1 then print "There are no instances of this object"
			else select a
			)
		-- Print
		else if fIAction == 2 then
			(
			b = sLibRemoveItemsFromArray a s
			if selection.count == 1 then print ("Instances of " + s[1].name + " : ")
			else print ("Instances of Selection: ")
			if b.count != 0 then
				(
				for i = 1 to b.count do
					(
					mainText += b[i].name as string
					if i != b.count then mainText += ", "
					)
				)
			print mainText
			)
		-- List
		else if fIAction == 3 then
			(
			b = sLibRemoveItemsFromArray a s
			if b.count == 0 then mainText = "None"
			else
				(
				for i in b do
					(
					mainText += i.name as string
					mainText += "\n"
					)
				)
			if selection.count == 1 then mainTitle = "Instances of " + s[1].name
			else mainTitle = "Instances of Selection"
			MessageBox mainText title:mainTitle
			)
		-- Isolate
		else if fIAction == 4 then
			(
			for i in s do if (finditem a i) == 0 then append a i
			for i in a do i.isHidden = false
			select a
			max hide inv
			select s
			)
		)
	)
	
fn instanceFinderDefaults = 
	(
	fILoadDef()
	instanceFinder fIActionValue fIVisibleValue
	)
	
fn instanceFinderUI = 
	(
	fILoadDef()
	fICloseOpenUI fIPosValue
	)

fn fICloseOpenUI pos = 
	(
	if fIFloater != undefined then CloseRolloutFloater fIFloater
	fIDefineUI()
	fIFloater = newRolloutFloater "instanceFinder v1.08" 310 95 pos.x pos.y
	addRollout fIRollout fIFloater
	)

fn fIDo = 
	(
	instanceFinder fIActionValue fIVisibleValue
	if fIFloater != undefined then CloseRolloutFloater fIFloater
	)

fn fIApply = 
	(
	instanceFinder fIActionValue fIVisibleValue
	)
	
fn fIHelp = 
	(
	sLibSSPrintHelp "instanceFinder"
	)
	
fn fILoadDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	fIInputFilename = presetDir + "instanceFinder.ini"
	if (sLibFileExist fIInputFilename == true) then
		(
		fIActionValue = execute (getINISetting fIInputFilename "instanceFinder" "fIActionValue")
		fIVisibleValue = execute (getINISetting fIInputFilename "instanceFinder" "fIVisibleValue")
		fIPosValue = execute (getINISetting fIInputFilename "instanceFinder" "fIPosValue")
		
		if fIActionValue == OK then fIActionValue = 1
		if fIVisibleValue == OK then fIVisibleValue = 1
		if fIPosValue == OK then fIPosValue = [400,400]
		)
	else
		(
		fIActionValue = 1
		fIVisibleValue = 1
		fIPosValue = [400,400]
		)
	)
	
fn fISaveDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	if (getDirectories presetDir).count == 0 then makeDir presetDir
	fIOutputFilename = presetDir + "instanceFinder.ini"
	if (sLibFileExist fIOutputFilename == true) then deleteFile fIOutputFilename
	setINISetting fIOutputFilename "instanceFinder" "fIActionValue" (fIActionValue as string)
	setINISetting fIOutputFilename "instanceFinder" "fIVisibleValue" (fIVisibleValue as string)
	setINISetting fIOutputFilename "instanceFinder" "fIPosValue" (fIFloater.pos as string)
	)

-- UI

fn fIDefineUI = 
	(
	rollout fIRollout "instanceFinder"
		(
		dropdownlist fIActionDropdown "" items:#("Select", "Print", "List", "Isolate") selection:fIActionValue width:130 align:#center across:2
		dropdownlist fIVisibleDropdown "" items:#("Scene", "Scene Visible") selection:fIVisibleValue width:130
		on fIActionDropdown selected i do fIActionValue = i
		on fIVisibleDropdown selected i do fIVisibleValue = i

		button fIDoButton "Do" width:70 toolTip:"Do It and Close UI" pos:[5,39]
		on fIDoButton pressed do fIDo()
		button fIApplyButton "Apply" width:70 toolTip:"Do It and Keep UI Open" pos:[77,39]
		on fIApplyButton pressed do fIApply()
		button fIHelpButton "Help" width:70 toolTip:"Help" pos:[149,39]
		on fIHelpButton pressed do fIHelp()
		button fISaveDefButton "SaveDef" width:70 toolTip:"Save Current Settings as Default" pos:[221,39]
		on fISaveDefButton pressed do fISaveDef()
		)
	)
)
-------------------------------------------------------------------------------