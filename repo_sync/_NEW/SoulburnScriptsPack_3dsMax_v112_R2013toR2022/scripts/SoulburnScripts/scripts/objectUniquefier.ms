-------------------------------------------------------------------------------
-- objectUniquefier.ms
-- By Neil Blevins (info@neilblevins.com)
-- v 1.11
-- Created On: 04/20/05
-- Modified On: 02/23/15
-- tested using Max 2014
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Required Files:
-- sLib.ms
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Description:
-- Takes any selected instanced / referenced geometry and makes it unique.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Tutorial:
-- Select an object that has an instance in the scene. Run the UI version of the 
-- script. Hit Do. It is now not an instance of that other object.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Revision History:
--
-- v 1.01 Fixed a bug that would sometimes cause multiple group warnings to 
-- appear instead of just one.
--
-- v 1.02 Defined ui as new function.
--
-- v 1.03 Added option for ungrouping objects when performing the script.
--
-- v 1.04 Added some new code to more cleanly open and close the UI.
--
-- v 1.05 Changed the make unique algorithm to be much more compatible with 
-- groups and selection sets.
--
-- v 1.06 Fixed a number of issues that stopped instanced objects with
-- instanced modifiers from becoming unique properly. These functions only work
-- in max 2008 and above.
--
-- v 1.07 Added options for refining what you want to make unique. Works on
-- instanced controllers now.
--
-- v 1.08 Replaced the Close button with a Help button. Use the X button to 
-- Close the Floater.
--
-- v 1.09 Fixed an issue that caused objects that are instanced with modifiers
-- to not be made unique. Unfortunately the fix only works for max 2008 and 
-- above. The mOUModifiers variable now does nothing, but is left in for
-- backwards compatability.
--
-- v 1.10 Changed name of script to objectUniquefier.
--
-- v 1.11 Fixed a bug that I introduced last version that caused the script to
-- not function.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Known Issues:
-- A max bug prevents all controllers from getting uninstanced, but it does work
-- on most controllers. Objects that are instanced with modifiers will only
-- be made unique in max 2008 and above.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
(
-- Globals

global objectUniquefier
global objectUniquefierDefaults
global objectUniquefierUI

global mOUCloseOpenUI

global mOUCollectObjects
global mOUConvertObjects

global mOUDo
global mOUApply
global mOUHelp
global mOULoadDef
global mOUSaveDef

global mOUDefineUI
global mOURollout
global mOUFloater

-- Includes

include "$scripts\SoulburnScripts\lib\sLib.ms"

-- Variables

mOUBaseObjectsValue = true
mOUModifiersValue = true
mOUControllersValue = true
mOUSkipNonInstancedValue = false
mOUShowWarningValue = false
mOUUngroupValue = false
mOUPosValue = [400,400]

-- Functions

fn objectUniquefier mOUBaseObjects mOUModifiers mOUControllers mOUSkipNonInstanced mOUShowWarning mOUUngroup = 
	(
	undo "objectUniquefier" on
		(
		if mOUShowWarning == true then
			(
			if (queryBox "Make All Selected Objects Unique?" title:"objectUniquefier") == true then 
				(
				theObjs = mOUCollectObjects mOUSkipNonInstanced mOUUngroup
				mOUConvertObjects theObjs mOUBaseObjects mOUModifiers mOUControllers
				)
			)
		else 
			(
			theObjs = mOUCollectObjects mOUSkipNonInstanced mOUUngroup
			mOUConvertObjects theObjs mOUBaseObjects mOUModifiers mOUControllers
			)
		)
	)

fn objectUniquefierDefaults = 
	(
	mOULoadDef()
	objectUniquefier mOUBaseObjectsValue mOUModifiersValue mOUControllersValue mOUSkipNonInstancedValue mOUShowWarningValue mOUUngroupValue
	)
	
fn objectUniquefierUI = 
	(
	mOULoadDef()
	mOUCloseOpenUI mOUPosValue
	)

fn mOUCloseOpenUI pos = 
	(
	if mOUFloater != undefined then CloseRolloutFloater mOUFloater
	mOUDefineUI()
	mOUFloater = newRolloutFloater "objectUniquefier v1.11" 310 215 pos.x pos.y
	addRollout mOURollout mOUFloater
	)
	
fn mOUCollectObjects mOUSkipNonInstanced mOUUngroup = 
	(
	oldObjs = #()
	sel = #()
	if mOUSkipNonInstanced == true then sel = sLibRemoveUniqueObjectsFromArray selection 
	else sel = selection
	error = false
	for i in sel do 
		(
		if mOUUngroup == true then 
			(
			if isgroupmember i == true or isgrouphead i == true then setGroupmember i false
			append oldObjs i
			)
		else
			(
			if isgroupmember i == false and isgrouphead i == false then append oldObjs i
			else error = true
			)
		)
	if error == true then MessageBox "At least one object in your selection is a group and cannot be affected by this script. objectUniquefier will still convert selected non grouped objects." title:"objectUniquefier"
	return oldObjs
	)
	
fn mOUConvertObjects Objs mOUBaseObjects mOUModifiers mOUControllers = 
	(
	disableSceneRedraw()
	try
		(
		-- setup progress bar
		progressStart "Make Unique"
		escapeEnable = false
		numOfItems = Objs.count
				
		currentIteration = 0
		for obj in Objs do
			(
			currentIteration += 1
			m = ((currentIteration as float)/(numOfItems as float))*100
			
			-- Baseobjects and Modifiers
			if mOUBaseObjects == true then 
				(
				if sLibMaxVer() < 10 then obj.baseObject = copy obj.baseObject
				else if (InstanceMgr.CanMakeObjectsUnique obj) == true then InstanceMgr.MakeObjectsUnique obj #individual
				)				

			-- Controllers
			if mOUControllers == true then
				(
				a = #()
				sLibGetAllControllersOnObj obj a
				for i in a do
					(
					if (InstanceMgr.CanMakeControllersUnique obj i) == true then InstanceMgr.MakeControllersUnique obj i #individual
					)
				)

			progressUpdate m
			)
		progressEnd()
		)
	catch ()
	enableSceneRedraw()
	completeRedraw()
	)

fn mOUDo = 
	(
	objectUniquefier mOUBaseObjectsValue mOUModifiersValue mOUControllersValue mOUSkipNonInstancedValue mOUShowWarningValue mOUUngroupValue
	if mOUFloater != undefined then CloseRolloutFloater mOUFloater
	)

fn mOUApply = 
	(
	objectUniquefier mOUBaseObjectsValue mOUModifiersValue mOUControllersValue mOUSkipNonInstancedValue mOUShowWarningValue mOUUngroupValue
	)
	
fn mOUHelp = 
	(
	sLibSSPrintHelp "objectUniquefier"
	)
	
fn mOULoadDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	mOUInputFilename = presetDir + "objectUniquefier.ini"
	if (sLibFileExist mOUInputFilename == true) then
		(
		mOUBaseObjectsValue = execute (getINISetting mOUInputFilename "objectUniquefier" "mOUBaseObjectsValue")
		mOUModifiersValue = execute (getINISetting mOUInputFilename "objectUniquefier" "mOUModifiersValue")
		mOUControllersValue = execute (getINISetting mOUInputFilename "objectUniquefier" "mOUControllersValue")
		mOUSkipNonInstancedValue = execute (getINISetting mOUInputFilename "objectUniquefier" "mOUSkipNonInstancedValue")
		mOUShowWarningValue = execute (getINISetting mOUInputFilename "objectUniquefier" "mOUShowWarningValue")
		mOUUngroupValue = execute (getINISetting mOUInputFilename "objectUniquefier" "mOUUngroupValue")
		mOUPosValue = execute (getINISetting mOUInputFilename "objectUniquefier" "mOUPosValue")
		
		if mOUBaseObjectsValue == OK then mOUBaseObjectsValue = true
		if mOUModifiersValue == OK then mOUModifiersValue = true
		if mOUControllersValue == OK then mOUControllersValue = true
		if mOUSkipNonInstancedValue == OK then mOUSkipNonInstancedValue = false
		if mOUShowWarningValue == OK then mOUShowWarningValue = false
		if mOUUngroupValue == OK then mOUUngroupValue = false
		if mOUPosValue == OK then mOUPosValue = [400,400]
		)
	else
		(
		mOUBaseObjectsValue = true
		mOUModifiersValue = true
		mOUControllersValue = true
		mOUSkipNonInstancedValue = false
		mOUShowWarningValue = false
		mOUUngroupValue = false
		mOUPosValue = [400,400]
		)
	)
	
fn mOUSaveDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	if (getDirectories presetDir).count == 0 then makeDir presetDir
	mOUOutputFilename = presetDir + "objectUniquefier.ini"
	if (sLibFileExist mOUOutputFilename == true) then deleteFile mOUOutputFilename
	setINISetting mOUOutputFilename "objectUniquefier" "mOUBaseObjectsValue" (mOUBaseObjectsValue as string)
	setINISetting mOUOutputFilename "objectUniquefier" "mOUModifiersValue" (mOUModifiersValue as string)
	setINISetting mOUOutputFilename "objectUniquefier" "mOUControllersValue" (mOUControllersValue as string)
	setINISetting mOUOutputFilename "objectUniquefier" "mOUSkipNonInstancedValue" (mOUSkipNonInstancedValue as string)
	setINISetting mOUOutputFilename "objectUniquefier" "mOUShowWarningValue" (mOUShowWarningValue as string)
	setINISetting mOUOutputFilename "objectUniquefier" "mOUUngroupValue" (mOUUngroupValue as string)
	setINISetting mOUOutputFilename "objectUniquefier" "mOUPosValue" (mOUFloater.pos as string)
	)

-- UI

fn mOUDefineUI = 
	(
	rollout mOURollout "objectUniquefier"
		(
		group "Tasks"
		(
		checkbox mOUBaseObjectsCheckbox "Make Base Objects and Modifiers Unique?" checked:mOUBaseObjectsValue align:#left
		checkbox mOUControllersCheckbox "Make Controllers Unique?" checked:mOUControllersValue align:#left
		)

		on mOUBaseObjectsCheckbox changed state do mOUBaseObjectsValue = state
		on mOUControllersCheckbox changed state do mOUControllersValue = state

		group "Options"
		(
		checkbox mOUSkipNonInstancedCheckbox "Skip Non-Instanced/Referenced Objects?" checked:mOUSkipNonInstancedValue align:#left
		checkbox mOUShowWarningCheckbox "Show Warning?" checked:mOUShowWarningValue align:#left
		checkbox mOUUngroupCheckbox "Ungroup Objects Before Making Them Unique?" checked:mOUUngroupValue align:#left
		)

		on mOUSkipNonInstancedCheckbox changed state do mOUSkipNonInstancedValue = state
		on mOUShowWarningCheckbox changed state do mOUShowWarningValue = state
		on mOUUngroupCheckbox changed state do mOUUngroupValue = state

		button mOUDoButton "Do" width:70 toolTip:"Do It and Close UI" pos:[5,158]
		on mOUDoButton pressed do mOUDo()
		button mOUApplyButton "Apply" width:70 toolTip:"Do It and Keep UI Open" pos:[77,158]
		on mOUApplyButton pressed do mOUApply()
		button mOUHelpButton "Help" width:70 toolTip:"Help" pos:[149,158]
		on mOUHelpButton pressed do mOUHelp()
		button mOUSaveDefButton "SaveDef" width:70 toolTip:"Save Current Settings as Default" pos:[221,158]
		on mOUSaveDefButton pressed do mOUSaveDef()
		)
	)
)
-------------------------------------------------------------------------------