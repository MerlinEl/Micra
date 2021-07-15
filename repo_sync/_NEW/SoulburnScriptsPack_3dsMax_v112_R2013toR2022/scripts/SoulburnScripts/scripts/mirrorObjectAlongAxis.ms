-------------------------------------------------------------------------------
-- mirrorObjectAlongAxis.ms
-- By Neil Blevins (info@neilblevins.com)
-- v 1.05
-- Created On: 06/05/05
-- Modified On: 10/09/09
-- tested using Max 2009
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Required Files:
-- sLib.ms
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Description:
-- Mirrors the selected object along the X, Y or Z world axis, with 
-- options for copy or instance. Like the mirror tool, but lets you do 
-- some common mirror operations with far fewer mouseclicks.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Tutorial:
-- Select an object. Run the UI version of the script. Hit Do. It mirrors the
-- object along the specified axis, each object an instance of the other.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Known Issues:
-- 1) Has a few issues with super complex hierarchies such as rigged 
-- characters with skin, etc. Best used on geometry or simple linked 
-- hierarchies.
-- 2) There is a maxscript bug where using the maxOps.CloneNodes function
-- (which this script does) causes not only the objects to be instanced,
-- but their transform controller as well, but only if you're cloning a 
-- hierarchy. So if you have say a sphere linked to a dummy, and run the
-- script, then move your sphere, the second sphere will move as well.
-- Hopefully autodesk will fix this bug in a new release, but until then,
-- check the "Uninstance Transform Controllers?" checkbox. This will
-- uninstance the transform controllers. However, this workaround has 
-- the side effect that if you actually meant to have the controllers
-- instanced, it will uninstance them, since the script can't tell whether
-- you meant to have them instanced, or whether they were just instanced
-- due to the maxscript bug.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Revision History:
--
-- v 1.01 Defined ui as new function.
--
-- v 1.02 Added some new code to more cleanly open and close the UI.
--
-- v 1.03 Replaced the Close button with a Help button. Use the X button to 
-- Close the Floater.
--
-- v 1.04 Added a "No Clone" method that just flips the objects.
--
-- v 1.05 There is a maxscript bug where using the maxOps.CloneNodes function
-- (which this script does) causes not only the objects to be instanced,
-- but their transform controller as well, but only if you're cloning a 
-- hierarchy. So if you have say a sphere linked to a dummy, and run the
-- script, then move your sphere, the second sphere will move as well.
-- Hopefully autodesk will fix this bug in a new release, but until then,
-- I added the "Uninstance Transform Controllers?" checkbox. This will
-- uninstance the transform controllers. However, this workaround has 
-- the side effect that if you actually meant to have the controllers
-- instanced, it will uninstance them, since the script can't tell whether
-- you meant to have them instanced, or whether they were just instanced
-- due to the maxscript bug.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
(
-- Globals

global mirrorObjectAlongAxis
global mirrorObjectAlongAxisDefaults
global mirrorObjectAlongAxisUI

global mOAACloseOpenUI

global mOAADo
global mOAAApply
global mOAAHelp
global mOAALoadDef
global mOAASaveDef

global mOAADefineUI
global mOAARollout
global mOAAFloater

-- Includes

include "$scripts\SoulburnScripts\lib\sLib.ms"

-- Variables

mOAAAxisValue = 1
mOAATypeValue = 2
mOAAUninstanceContValue = true
mOAAPosValue = [400,400]

-- Functions

fn mirrorObjectAlongAxis mOAAAxis mOAAType mOAAUninstanceCont = 
	(
	undo "mirrorObjectAlongAxis" on
		(
		If selection.count != 0 then 
			(
			-- setup
			oldNodes = #()
			newNodes = #()
			for i in selection do append oldNodes i
			
			-- copy the objects
			if mOAAType == 1 then maxOps.CloneNodes oldNodes clonetype:#copy newNodes:&newNodes
			else if mOAAType == 2 then maxOps.CloneNodes oldNodes clonetype:#instance newNodes:&newNodes
			else if mOAAType == 3 then for i in oldNodes do append newNodes i
			
			-- select parents
			mirrorNodes = #()
			for i in newNodes do
				(
				if i.parent == undefined then append mirrorNodes i
				else if (findItem newNodes i.parent) == 0 then append mirrorNodes i
				)
			
			-- mirror the objects
			if mOAAAxis == 1 then about [0,0,0] scale mirrorNodes [-1,1,1]
			else if mOAAAxis == 2 then about [0,0,0] scale mirrorNodes [1,-1,1]
			else if mOAAAxis == 3 then about [0,0,0] scale mirrorNodes [1,1,-1]
			
			-- fix maxOps.CloneNodes bug that instances transform controllers when instancing a heirarchy
			if mOAAUninstanceCont == true then
				(
				for obj in newNodes do InstanceMgr.MakeControllersUnique obj obj.transform.controller #individual
				)
			
			-- finish
			select oldNodes
			)
		)
	)

fn mirrorObjectAlongAxisDefaults = 
	(
	mOAALoadDef()
	mirrorObjectAlongAxis mOAAAxisValue mOAATypeValue mOAAUninstanceContValue
	)
	
fn mirrorObjectAlongAxisUI = 
	(
	mOAALoadDef()
	mOAACloseOpenUI mOAAPosValue
	)

fn mOAACloseOpenUI pos = 
	(
	if mOAAFloater != undefined then CloseRolloutFloater mOAAFloater
	mOAADefineUI()
	mOAAFloater = newRolloutFloater "mirrorObjectAlongAxis v1.05" 310 117 pos.x pos.y
	addRollout mOAARollout mOAAFloater
	)

fn mOAADo = 
	(
	mirrorObjectAlongAxis mOAAAxisValue mOAATypeValue mOAAUninstanceContValue
	if mOAAFloater != undefined then CloseRolloutFloater mOAAFloater
	)

fn mOAAApply = 
	(
	mirrorObjectAlongAxis mOAAAxisValue mOAATypeValue mOAAUninstanceContValue
	)
	
fn mOAAHelp = 
	(
	sLibSSPrintHelp "mirrorObjectAlongAxis"
	)
	
fn mOAALoadDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	mOAAInputFilename = presetDir + "mirrorObjectAlongAxis.ini"
	if (sLibFileExist mOAAInputFilename == true) then
		(
		mOAAAxisValue = execute (getINISetting mOAAInputFilename "mirrorObjectAlongAxis" "mOAAAxisValue")
		mOAATypeValue = execute (getINISetting mOAAInputFilename "mirrorObjectAlongAxis" "mOAATypeValue")
		mOAAUninstanceContValue = execute (getINISetting mOAAInputFilename "mirrorObjectAlongAxis" "mOAAUninstanceContValue")
		mOAAPosValue = execute (getINISetting mOAAInputFilename "mirrorObjectAlongAxis" "mOAAPosValue")
		
		if mOAAAxisValue == OK then mOAAAxisValue = 1
		if mOAATypeValue == OK then mOAATypeValue = 2
		if mOAAUninstanceContValue == OK then mOAAUninstanceContValue = true
		if mOAAPosValue == OK then mOAAPosValue = [400,400]
		)
	else
		(
		mOAAAxisValue = 1
		mOAATypeValue = 2
		mOAAUninstanceContValue = true
		mOAAPosValue = [400,400]
		)
	)
	
fn mOAASaveDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	if (getDirectories presetDir).count == 0 then makeDir presetDir
	mOAAOutputFilename = presetDir + "mirrorObjectAlongAxis.ini"
	if (sLibFileExist mOAAOutputFilename == true) then deleteFile mOAAOutputFilename
	setINISetting mOAAOutputFilename "mirrorObjectAlongAxis" "mOAAAxisValue" (mOAAAxisValue as string)
	setINISetting mOAAOutputFilename "mirrorObjectAlongAxis" "mOAATypeValue" (mOAATypeValue as string)
	setINISetting mOAAOutputFilename "mirrorObjectAlongAxis" "mOAAUninstanceContValue" (mOAAUninstanceContValue as string)
	setINISetting mOAAOutputFilename "mirrorObjectAlongAxis" "mOAAPosValue" (mOAAFloater.pos as string)
	)

-- UI

fn mOAADefineUI = 
	(
	rollout mOAARollout "mirrorObjectAlongAxis"
		(
		label label1 "Axis: " pos:[25,12]
		dropdownlist mOAAAxisDropdown "" items:#("X", "Y", "Z") selection:mOAAAxisValue across:2 width:70 pos:[55,8]
		label label2 "Type: " pos:[135,12]
		dropdownlist mOAATypeDropdown "" items:#("Copy", "Instance", "No Clone") selection:mOAATypeValue width:100 pos:[171,8]
		checkbox mOAAUninstanceContCheckbox "Uninstance Transform Controllers?" checked:mOAAUninstanceContValue align:#center
		
		on mOAAUninstanceContCheckbox changed state do mOAAUninstanceContValue = state
		on mOAAAxisDropdown selected i do mOAAAxisValue = i
		on mOAATypeDropdown selected i do mOAATypeValue = i

		button mOAADoButton "Do" width:70 toolTip:"Do It and Close UI" pos:[5,60]
		on mOAADoButton pressed do mOAADo()
		button mOAAApplyButton "Apply" width:70 toolTip:"Do It and Keep UI Open" pos:[77,60]
		on mOAAApplyButton pressed do mOAAApply()
		button mOAAHelpButton "Help" width:70 toolTip:"Help" pos:[149,60]
		on mOAAHelpButton pressed do mOAAHelp()
		button mOAASaveDefButton "SaveDef" width:70 toolTip:"Save Current Settings as Default" pos:[221,60]
		on mOAASaveDefButton pressed do mOAASaveDef()
		)
	)
)
-------------------------------------------------------------------------------