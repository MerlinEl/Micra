-------------------------------------------------------------------------------
-- parentSelector.ms
-- By Neil Blevins (info@neilblevins.com)
-- v 1.02
-- Created On: 11/21/07
-- Modified On: 10/21/15
-- tested using Max 2016
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Required Files:
-- sLib.ms
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Description:
-- Selects any objects that are not parented to anything. This is really useful
-- if you want to select all the top level parents in your scene or selection,
-- maybe to later link them to a master dummy object.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Tutorial:
-- Start with any scene that has hierarchy. Run the UI version of the script. 
-- Action should read In Scene. Hit Do. It will now only select the top level 
-- nodes of the scene hierarchy. The script has 3 modes: "In Scene" means all the
-- top level nodes in the scene, regardless of selection. "In Selection" will 
-- select the top level nodes of the current selection. So if you have a node 
-- that's parented to another object, but that object is not currently selected, 
-- it will not be picked. "Of Selection" is similar to "In Selection", but it
-- will select all top level parents of your current selection, regardless of 
-- whether those parents are selected or not.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Revision History:
--
-- v 1.01 Replaced the Close button with a Help button. Use the X button to 
-- Close the Floater.
--
-- v 1.02 Cleaned up a lot of code.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
(
-- Globals

global parentSelector
global parentSelectorDefaults
global parentSelectorUI

global pSCloseOpenUI

global pSDo
global pSApply
global pSHelp
global pSLoadDef
global pSSaveDef

global pSDefineUI
global pSRollout
global pSFloater

-- Includes

include "$scripts\SoulburnScripts\lib\sLib.ms"

-- Variables

pSActionValue = 3
pSPosValue = [400,400]

-- Functions

fn parentSelector pSAction = 
	(
	undo "parentSelector" on
		(
		-- In Selected
		if pSAction == 1 then 
			(
			objs = for i in selection collect i
			objsFinal = sLibFindParentsInObjs objs
			)
		
		-- Of Selected
		else if pSAction == 2 then
			(
			objs = for i in selection collect i
			objsFinal = sLibFindParentsOfObjs objs
			)
		
		-- In Scene
		else if pSAction == 3 then
			(
			objs = for i in $* collect i
			objsFinal = sLibFindParentsInObjs objs
			)
		select objsFinal
		)
	)
	
fn parentSelectorDefaults = 
	(
	pSLoadDef()
	parentSelector pSActionValue
	)
	
fn parentSelectorUI = 
	(
	pSLoadDef()
	pSCloseOpenUI pSPosValue
	)
	
fn pSCloseOpenUI pos = 
	(
	if pSFloater != undefined then CloseRolloutFloater pSFloater
	pSDefineUI()
	pSFloater = newRolloutFloater "parentSelector v1.02" 310 91 pos.x pos.y
	addRollout pSRollout pSFloater
	)

fn pSDo = 
	(
	parentSelector pSActionValue
	if pSFloater != undefined then CloseRolloutFloater pSFloater
	)

fn pSApply = 
	(
	parentSelector pSActionValue
	)
	
fn pSHelp = 
	(
	sLibSSPrintHelp "parentSelector"
	)
	
fn pSLoadDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	pSInputFilename = presetDir + "parentSelector.ini"
	if (sLibFileExist pSInputFilename == true) then
		(
		pSActionValue = execute (getINISetting pSInputFilename "parentSelector" "pSActionValue")
		pSPosValue = execute (getINISetting pSInputFilename "parentSelector" "pSPosValue")
		
		if pSActionValue == OK then pSActionValue = 3
		if pSPosValue == OK then pSPosValue = [400,400]
		)
	else
		(
		pSActionValue = 3
		pSPosValue = [400,400]
		)
	)
	
fn pSSaveDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	if (getDirectories presetDir).count == 0 then makeDir presetDir
	pSOutputFilename = presetDir + "parentSelector.ini"
	if (sLibFileExist pSOutputFilename == true) then deleteFile pSOutputFilename
	setINISetting pSOutputFilename "parentSelector" "pSActionValue" (pSActionValue as string)
	setINISetting pSOutputFilename "parentSelector" "pSPosValue" (pSFloater.pos as string)
	)

-- UI

fn pSDefineUI = 
	(
	rollout pSRollout "parentSelector"
		(
		label label1 "Action:" pos:[10,10]
		dropdownlist pSActionDropdown "" items:#("In Selection", "Of Selected", "In Scene") selection:pSActionValue pos:[50,7] width:237
		on pSActionDropdown selected i do pSActionValue = i

		button pSDoButton "Do" width:70 toolTip:"Do It and Close UI" pos:[5,34]
		on pSDoButton pressed do pSDo()
		button pSApplyButton "Apply" width:70 toolTip:"Do It and Keep UI Open" pos:[77,34]
		on pSApplyButton pressed do pSApply()
		button pSHelpButton "Help" width:70 toolTip:"Help" pos:[149,34]
		on pSHelpButton pressed do pSHelp()
		button pSSaveDefButton "SaveDef" width:70 toolTip:"Save Current Settings as Default" pos:[221,34]
		on pSSaveDefButton pressed do pSSaveDef()
		)
	)
)
-------------------------------------------------------------------------------