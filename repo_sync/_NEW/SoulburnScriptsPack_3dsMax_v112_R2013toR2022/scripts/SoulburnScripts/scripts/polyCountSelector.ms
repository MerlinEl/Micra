-------------------------------------------------------------------------------
-- polyCountSelector.ms
-- By Neil Blevins (info@neilblevins.com)
-- v 1.01
-- Created On: 06/30/08
-- Modified On: 04/09/15
-- tested using Max 2014
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Required Files:
-- sLib.ms
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Description:
-- Selects objects based on their facecount.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Tutorial:
-- Make a bunch of objects. Select them all. Open the UI of the script. Hit 
-- Apply. Any object that fits the face criteria in the interface will now be
-- selected.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Revision History:
--
-- v 1.01 Added ability to get the facecount of the currently selected object.
-- Also can now select objects either in the scene or current selection.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
(
-- Globals

global polyCountSelector
global polyCountSelectorDefaults
global polyCountSelectorUI

global pCSCloseOpenUI

global pCSDo
global pCSApply
global pCSHelp
global pCSLoadDef
global pCSSaveDef

global pCSDefineUI
global pCSRollout
global pCSFloater

-- Includes

include "$scripts\SoulburnScripts\lib\sLib.ms"

-- Variables

pCSWhereValue = 1
pCSModeValue = 2
pCSPolyCountValue = 12
pCSPosValue = [400,400]

-- Functions

fn polyCountSelector pCSWhere pCSMode pCSPolyCount = 
	(
	undo "polyCountSelector" on
		(
		objs = #()
		a = #()
		
		if pCSWhere == 1 then objs = for i in $* collect i
		else objs = for i in selection collect i
		
		for i in objs do
			(
			if pCSMode == 1 then
				(
				if (getPolygonCount i)[1] < pCSPolyCount then append a i
				)
			else if pCSMode == 2 then
				(
				if (getPolygonCount i)[1] == pCSPolyCount then append a i
				)
			else if pCSMode == 3 then
				(
				if (getPolygonCount i)[1] > pCSPolyCount then append a i
				)
			)
		deselect selection
		select a
		)
	)
	
fn polyCountSelectorDefaults = 
	(
	pCSLoadDef()
	polyCountSelector pCSWhereValue pCSModeValue pCSPolyCountValue
	)
	
fn polyCountSelectorUI = 
	(
	pCSLoadDef()
	pCSCloseOpenUI pCSPosValue
	)

fn pCSCloseOpenUI pos = 
	(
	if pCSFloater != undefined then CloseRolloutFloater pCSFloater
	pCSDefineUI()
	pCSFloater = newRolloutFloater "polyCountSelector v1.01" 390 97 pos.x pos.y
	addRollout pCSRollout pCSFloater
	)

fn pCSDo = 
	(
	polyCountSelector pCSWhereValue pCSModeValue pCSPolyCountValue
	if pCSFloater != undefined then CloseRolloutFloater pCSFloater
	)

fn pCSApply = 
	(
	polyCountSelector pCSWhereValue pCSModeValue pCSPolyCountValue
	)
	
fn pCSHelp = 
	(
	sLibSSPrintHelp "polyCountSelector"
	)
	
fn pCSLoadDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	pCSInputFilename = presetDir + "polyCountSelector.ini"
	if (sLibFileExist pCSInputFilename == true) then
		(
		pCSWhereValue = execute (getINISetting pCSInputFilename "polyCountSelector" "pCSWhereValue")
		pCSModeValue = execute (getINISetting pCSInputFilename "polyCountSelector" "pCSModeValue")
		pCSPolyCountValue = execute (getINISetting pCSInputFilename "polyCountSelector" "pCSPolyCountValue")
		pCSPosValue = execute (getINISetting pCSInputFilename "polyCountSelector" "pCSPosValue")
		
		if pCSWhereValue == OK then pCSWhereValue = 1
		if pCSModeValue == OK then pCSModeValue = 2
		if pCSPolyCountValue == OK then pCSPolyCountValue = 12
		if pCSPosValue == OK then pCSPosValue = [400,400]
		)
	else
		(
		pCSWhereValue = 1
		pCSModeValue = 2
		pCSPolyCountValue = 12
		pCSPosValue = [400,400]
		)
	)
	
fn pCSSaveDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	if (getDirectories presetDir).count == 0 then makeDir presetDir
	pCSOutputFilename = presetDir + "polyCountSelector.ini"
	if (sLibFileExist pCSOutputFilename == true) then deleteFile pCSOutputFilename
	setINISetting pCSOutputFilename "polyCountSelector" "pCSWhereValue" (pCSWhereValue as string)
	setINISetting pCSOutputFilename "polyCountSelector" "pCSModeValue" (pCSModeValue as string)
	setINISetting pCSOutputFilename "polyCountSelector" "pCSPolyCountValue" (pCSPolyCountValue as string)
	setINISetting pCSOutputFilename "polyCountSelector" "pCSPosValue" (pCSFloater.pos as string)
	)

-- UI

fn pCSDefineUI = 
	(
	rollout pCSRollout "polyCountSelector"
		(
		dropdownlist pCSWhereDropdown "" items:#("In Scene", "In Selection") selection:pCSWhereValue width:80 across:4
		dropdownlist pCSModeDropdown "" items:#("Less Than <", "Equal To =", "Greater Than >") selection:pCSModeValue width:100 across:3
		button pCSGetButton "Get" width:36 toolTip:"Get Polycount From Selected Object" offset:[-9,0]
		spinner pCSPolyCountSpinner "Poly Count: " range:[0,9999999,pCSPolyCountValue] fieldWidth:50 type:#integer offset:[4,4]
		
		on pCSWhereDropdown selected i do pCSWhereValue = i
		on pCSModeDropdown selected i do pCSModeValue = i
		on pCSGetButton pressed do 
			(
			if selection.count == 1 then
				(
				val = (getPolygonCount selection[1])[1]
				pCSPolyCountValue = val
				)
			curPos = pCSFloater.pos
			pCSCloseOpenUI curPos
			)
		on pCSPolyCountSpinner changed val do pCSPolyCountValue = val

		button pCSDoButton "Do" width:70 toolTip:"Do It and Close UI" pos:[45,39]
		on pCSDoButton pressed do pCSDo()
		button pCSApplyButton "Apply" width:70 toolTip:"Do It and Keep UI Open" pos:[117,39]
		on pCSApplyButton pressed do pCSApply()
		button pCSHelpButton "Help" width:70 toolTip:"Help" pos:[189,39]
		on pCSHelpButton pressed do pCSHelp()
		button pCSSaveDefButton "SaveDef" width:70 toolTip:"Save Current Settings as Default" pos:[261,39]
		on pCSSaveDefButton pressed do pCSSaveDef()
		)
	)
)
-------------------------------------------------------------------------------