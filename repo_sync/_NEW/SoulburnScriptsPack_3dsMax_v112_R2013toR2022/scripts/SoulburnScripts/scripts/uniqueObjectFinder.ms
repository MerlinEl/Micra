-------------------------------------------------------------------------------
-- uniqueObjectFinder.ms
-- By Neil Blevins (info@neilblevins.com)
-- v 1.02
-- Created On: 03/08/08
-- Modified On: 01/28/15
-- tested using Max 8.0
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Required Files:
-- sLib.ms
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Description:
-- Finds objects in your selection that are unique, ie, that don't have any
-- instances of themselves, and then does various things to them such as 
-- selecting them, printing their names, isolating them, etc.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Tutorial:
-- Make an object. Instance it 5 times. Copy it once. Select all the objects. 
-- Run the script in UI mode. Hit Do. Now you have only the object you copied
-- selected, since the other 5 are instances of each other.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Revision History:
--
-- v 1.01 Replaced the Close button with a Help button. Use the X button to 
-- Close the Floater.
--
-- v 1.02 Changed name of script to uniqueObjectFinder.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
(
-- Globals

global uniqueObjectFinder
global uniqueObjectFinderDefaults
global uniqueObjectFinderUI

global fUOCloseOpenUI

global fUODo
global fUOApply
global fUOHelp
global fUOLoadDef
global fUOSaveDef

global fUODefineUI
global fUORollout
global fUOFloater

-- Includes

include "$scripts\SoulburnScripts\lib\sLib.ms"

-- Variables

fUOActionValue = 1
fUOPosValue = [400,400]

-- Functions

fn uniqueObjectFinder fUOAction = 
	(
	undo "uniqueObjectFinder" on
		(
		a = #()
		for obj in selection do
			(
			theInst = sLibGetInstancesOfObject obj
			if theInst.count == 0 then append a obj
			)

		if a.count != 0 then
				(
			-- Select
			if fUOAction == 1 then
				(
				select a
				)
			-- Print
			else if fUOAction == 2 then
				(
				mainText = ""
				qsort a sLibNameCompareCaseInsensitive
				print ("Objects in Selection That Are Unique: ")
				if a.count != 0 then
					(
					for i = 1 to a.count do
						(
						mainText += a[i].name as string
						if i != a.count then mainText += ", "
						)
					)
				print mainText
				)
			-- List
			else if fUOAction == 3 then
				(
				mainText = ""
				qsort a sLibNameCompareCaseInsensitive
				for i in a do
					(
					mainText += i.name as string
					mainText += "\n"
					)
				mainTitle = "Objects in Selection That Are Unique"
				MessageBox mainText title:mainTitle
				)
			-- Isolate
			else if fUOAction == 4 then
				(
				for i in a do i.isHidden = false
				select a
				max hide inv
				)
			)
		)
	)
	
fn uniqueObjectFinderDefaults = 
	(
	fUOLoadDef()
	uniqueObjectFinder fUOActionValue
	)
	
fn uniqueObjectFinderUI = 
	(
	fUOLoadDef()
	fUOCloseOpenUI fUOPosValue
	)

fn fUOCloseOpenUI pos = 
	(
	if fUOFloater != undefined then CloseRolloutFloater fUOFloater
	fUODefineUI()
	fUOFloater = newRolloutFloater "uniqueObjectFinder v1.02" 310 91 pos.x pos.y
	addRollout fUORollout fUOFloater
	)

fn fUODo = 
	(
	uniqueObjectFinder fUOActionValue
	if fUOFloater != undefined then CloseRolloutFloater fUOFloater
	)

fn fUOApply = 
	(
	uniqueObjectFinder fUOActionValue
	)
	
fn fUOHelp = 
	(
	sLibSSPrintHelp "uniqueObjectFinder"
	)
	
fn fUOLoadDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	fUOInputFilename = presetDir + "uniqueObjectFinder.ini"
	if (sLibFileExist fUOInputFilename == true) then
		(
		fUOActionValue = execute (getINISetting fUOInputFilename "uniqueObjectFinder" "fUOActionValue")
		fUOPosValue = execute (getINISetting fUOInputFilename "uniqueObjectFinder" "fUOPosValue")
		
		if fUOActionValue == OK then fUOActionValue = 1
		if fUOPosValue == OK then fUOPosValue = [400,400]
		)
	else
		(
		fUOActionValue = 1
		fUOPosValue = [400,400]
		)
	)
	
fn fUOSaveDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	if (getDirectories presetDir).count == 0 then makeDir presetDir
	fUOOutputFilename = presetDir + "uniqueObjectFinder.ini"
	if (sLibFileExist fUOOutputFilename == true) then deleteFile fUOOutputFilename
	setINISetting fUOOutputFilename "uniqueObjectFinder" "fUOActionValue" (fUOActionValue as string)
	setINISetting fUOOutputFilename "uniqueObjectFinder" "fUOPosValue" (fUOFloater.pos as string)
	)

-- UI

fn fUODefineUI = 
	(
	rollout fUORollout "uniqueObjectFinder"
		(
		label label1 "Action:" pos:[10,10]
		dropdownlist fUOActionDropdown "" items:#("Select", "Print", "List", "Isolate") selection:fUOActionValue pos:[50,7] width:237
		on fUOActionDropdown selected i do fUOActionValue = i

		button fUODoButton "Do" width:70 toolTip:"Do It and Close UI" pos:[5,34]
		on fUODoButton pressed do fUODo()
		button fUOApplyButton "Apply" width:70 toolTip:"Do It and Keep UI Open" pos:[77,34]
		on fUOApplyButton pressed do fUOApply()
		button fUOHelpButton "Help" width:70 toolTip:"Help" pos:[149,34]
		on fUOHelpButton pressed do fUOHelp()
		button fUOSaveDefButton "SaveDef" width:70 toolTip:"Save Current Settings as Default" pos:[221,34]
		on fUOSaveDefButton pressed do fUOSaveDef()
		)
	)
)
-------------------------------------------------------------------------------