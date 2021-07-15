-------------------------------------------------------------------------------
-- objectDropper.ms
-- By Neil Blevins (info@neilblevins.com)
-- v 1.06
-- Created On: 11/06/05
-- Modified On: 02/28/19
-- tested using Max 2017
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Required Files:
-- sLib.ms
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Description:
-- Lets you drop objects onto another object. For example, will drop a bunch 
-- of rocks onto an uneven ground surface.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Tutorial:
-- Select one or more ground objects. Press "Add Sel To Ground Objs" button. 
-- Select the objects you want to drop, and place them above the ground object. 
-- Press "Do".
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Revision History:
--
-- v 1.01 Added some new code to more cleanly open and close the UI.
--
-- v 1.02 Now the script can consider a group of objects to be dropped as 
-- a single object.
--
-- v 1.03 Now you can align dropped objects with ground. Also, you can now
-- select an axis, to drop the objects in different directions.
--
-- v 1.04 Replaced the Close button with a Help button. Use the X button to 
-- Close the Floater.
--
-- v 1.05 You can now use multiple ground objects. Completely redid the UI.
--
-- v 1.06 Added a pick button. SO now you can select the object to drop to, hit 
-- add, and thens elect the objects you want to drop. Or you can do it backwards, 
-- select the objects you want to drop, then use Pick to choose the object you 
-- want to drop to.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
(
-- Globals

global objectDropper
global objectDropperDefaults
global objectDropperUI

global oDCloseOpenUI

global oDDo
global oDApply
global oDHelp
global oDLoadDef
global oDSaveDef

global oDDefineUI
global oDRollout
global oDFloater

-- Includes

include "$scripts\SoulburnScripts\lib\sLib.ms"

-- Variables

global oDGroundObjsList = #()

oDDirectionValue = 6
oDGroupsValue = true
oDAlignValue = true
oDPosValue = [400,400]

-- Functions

fn objectDropper oDDirection oDGroups oDAlign = 
	(
	undo "objectDropper" on
		(
		if oDGroundObjsList.count == 0 then (MessageBox "Please pick at least one ground object" title:"objectDropper")
		else
			(
			error = false
			for g in oDGroundObjsList do if isdeleted (getNodeByName g) == true then error = true
			if error == true then (MessageBox "At least one of your ground objects no longer seems to exist, please pick a new list of ground objects" title:"objectDropper")
			else
				(
				if selection.count == 0 then (MessageBox "Please select some object to be dropped" title:"objectDropper")
				else 
					(
					disableSceneRedraw()
					try
						(
						-- Prep
						progressStart "objectDropper"
						escapeEnable = false
						numOfItems = selection.count
						currentIteration = 0
						oDError = 0
						
						-- Calculate Highest and Lowest Point
						if oDDirection == 1 or oDDirection == 2 then
							(
							highestPoint = (sLibGetCollectionBBox geometry)[1].x + 100
							lowestPoint = (sLibGetCollectionBBox geometry)[2].x - 100
							)
						else if oDDirection == 3 or oDDirection == 4 then
							(
							highestPoint = (sLibGetCollectionBBox geometry)[1].y + 100
							lowestPoint = (sLibGetCollectionBBox geometry)[2].y - 100
							)
						else if oDDirection == 5 or oDDirection == 6 then
							(
							highestPoint = (sLibGetCollectionBBox geometry)[1].z + 100
							lowestPoint = (sLibGetCollectionBBox geometry)[2].z - 100
							)

						-- Start process
						for obj in selection do
							(
							if isgroupmember obj == true and oDGroups == true then continue
							else
								(
								if isgrouphead obj == true and oDGroups == false then continue
								else
									(
									-- Setup variables
									currentIteration += 1
									m = ((currentIteration as float)/(numOfItems as float))*100
									local rayPosition
									local r = undefined

									-- Choose Direction
									if oDDirection == 1 then
										(
										rayPosition = [lowestPoint, obj.pos.y, obj.pos.z]
										for g in oDGroundObjsList do
											(
											myray = intersectray (getNodeByName g) (ray rayPosition [1,0,0])
											if myray != undefined then if r == undefined then r = myray else if (myray.pos.x < r.pos.x) then r = myray
											)										
										)
									else if oDDirection == 2 then
										(
										rayPosition = [highestPoint, obj.pos.y, obj.pos.z]
										for g in oDGroundObjsList do
											(
											myray = intersectray (getNodeByName g) (ray rayPosition [-1,0,0])
											if myray != undefined then if r == undefined then r = myray else if (myray.pos.x > r.pos.x) then r = myray
											)
										)
									else if oDDirection == 3 then
										(
										rayPosition = [obj.pos.x, lowestPoint, obj.pos.z]
										for g in oDGroundObjsList do
											(
											myray = intersectray (getNodeByName g) (ray rayPosition [0,1,0])
											if myray != undefined then if r == undefined then r = myray else if (myray.pos.y < r.pos.y) then r = myray
											)
										)
									else if oDDirection == 4 then
										(
										rayPosition = [obj.pos.x, highestPoint, obj.pos.z]
										for g in oDGroundObjsList do
											(
											myray = intersectray (getNodeByName g) (ray rayPosition [0,-1,0])
											if myray != undefined then if r == undefined then r = myray else if (myray.pos.y > r.pos.y) then r = myray
											)
										)
									else if oDDirection == 5 then
										(
										rayPosition = [obj.pos.x, obj.pos.y, lowestPoint]
										for g in oDGroundObjsList do
											(
											myray = intersectray (getNodeByName g) (ray rayPosition [0,0,1])
											if myray != undefined then if r == undefined then r = myray else if (myray.pos.z < r.pos.z) then r = myray
											)
										)
									else if oDDirection == 6 then
										(
										rayPosition = [obj.pos.x, obj.pos.y, highestPoint]
										for g in oDGroundObjsList do
											(
											myray = intersectray (getNodeByName g) (ray rayPosition [0,0,-1])
											if myray != undefined then if r == undefined then r = myray else if (myray.pos.z > r.pos.z) then r = myray
											)
										)
									
									-- Change Position
									if r == undefined then oDError += 1 else 
										(
										-- Align
										if oDAlign == true then
											(
											tm = matrix3 1 
											tm = matrixFromNormal r.dir
											obj.rotation = inverse tm.rotationpart
											)
										-- Pos
										obj.pos = r.pos										
										)

									progressUpdate m
									)
								)
							)
						progressEnd()
						if oDError > 0 then 
							(
							to_print = (oDError as string) + " object(s) in your selection were not directly above or below the ground object, and their positions were not modified"
							MessageBox to_print title:"objectDropper"
							print to_print
							)
						)
					catch (MessageBox "An error has occured when trying to drop these objects. You may want to undo." title:"objectDropper")
					enableSceneRedraw()
					completeRedraw()
					)
				)
			)
		)
	)

fn objectDropperDefaults = 
	(
	oDLoadDef()
	objectDropper oDDirectionValue oDGroupsValue oDAlignValue
	)
	
fn objectDropperUI = 
	(
	oDLoadDef()
	oDCloseOpenUI oDPosValue
	)

fn oDCloseOpenUI pos = 
	(
	if oDFloater != undefined then CloseRolloutFloater oDFloater
	oDDefineUI()
	oDFloater = newRolloutFloater "objectDropper v1.06" 200 333 pos.x pos.y
	addRollout oDRollout oDFloater
	)

fn oDDo = 
	(
	objectDropper oDDirectionValue oDGroupsValue oDAlignValue
	if oDFloater != undefined then CloseRolloutFloater oDFloater
	)

fn oDApply = 
	(
	objectDropper oDDirectionValue oDGroupsValue oDAlignValue
	)
	
fn oDHelp = 
	(
	sLibSSPrintHelp "objectDropper"
	)
	
fn oDLoadDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	oDInputFilename = presetDir + "objectDropper.ini"
	if (sLibFileExist oDInputFilename == true) then
		(
		oDDirectionValue = execute (getINISetting oDInputFilename "objectDropper" "oDDirectionValue")
		oDGroupsValue = execute (getINISetting oDInputFilename "objectDropper" "oDGroupsValue")
		oDAlignValue = execute (getINISetting oDInputFilename "objectDropper" "oDAlignValue")
		oDPosValue = execute (getINISetting oDInputFilename "objectDropper" "oDPosValue")
		
		if oDDirectionValue == OK then oDDirectionValue = 6
		if oDGroupsValue == OK then oDGroupsValue = true
		if oDAlignValue == OK then oDAlignValue = false
		if oDPosValue == OK then oDPosValue = [400,400]
		)
	else
		(
		oDDirectionValue = 6
		oDGroupsValue = true
		oDAlignValue = false
		oDPosValue = [400,400]
		)
	)
	
fn oDSaveDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	if (getDirectories presetDir).count == 0 then makeDir presetDir
	oDOutputFilename = presetDir + "objectDropper.ini"
	if (sLibFileExist oDOutputFilename == true) then deleteFile oDOutputFilename
	setINISetting oDOutputFilename "objectDropper" "oDDirectionValue" (oDDirectionValue as string)
	setINISetting oDOutputFilename "objectDropper" "oDGroupsValue" (oDGroupsValue as string)
	setINISetting oDOutputFilename "objectDropper" "oDAlignValue" (oDAlignValue as string)
	setINISetting oDOutputFilename "objectDropper" "oDPosValue" (oDFloater.pos as string)
	)

-- UI

fn oDDefineUI = 
	(
	rollout oDRollout "objectDropper"
		(
		group "Ground Objects"
		(
		pickbutton oDAddGroundObjsListPick "Pick Ground Obj" width:160 toolTip:"Pick A Ground Object" align:#center
		button oDAddGroundObjsListButton "Add Sel To Ground Objs" toolTip:"Add Selection To Ground Objects" width:142 align:#left across:2
		button oDDelGroundObjsListButton "-" toolTip:"Delete Choosen Object From Ground Objects List" width:15 align:#right
		listbox oDGroundObjsListListbox "" items:oDGroundObjsList height:5
		)
		
		on oDAddGroundObjsListPick picked obj do 
			(
			oDGroundObjsList = #()
			if (sLibGeometryFilter obj) == false then (MessageBox "The object you picked is not a piece of geometry." title:"objectDropper")
			else append oDGroundObjsList obj.name
			curPos = oDFloater.pos
			oDCloseOpenUI curPos
			)
		on oDAddGroundObjsListButton pressed do 
			(
			oDGroundObjsList = #()
			error = false
			for i in selection do
				(
				if (sLibGeometryFilter i) == false then error = true
				else append oDGroundObjsList i.name
				)
			if error == true then (MessageBox "At least one object in your selection was not a piece of geometry and was removed from your ground objects list." title:"objectDropper")
			curPos = oDFloater.pos
			oDCloseOpenUI curPos
			)
		on oDDelGroundObjsListButton pressed do 
			(
			if oDGroundObjsList.count !=0 then
				(
				deleteItem oDGroundObjsList oDGroundObjsListListbox.selection
				curPos = oDFloater.pos
				oDCloseOpenUI curPos
				)
			)
			
		group "Options"
		(
		checkbox oDGroupsCheckbox "Treat Group As 1 Obj" checked:oDGroupsValue align:#left
		label label1 "Drop Direction: " offset:[0,3] align:#left across:2
		dropdownlist oDDirectionDropdown "" items:#("+X (Right)", "-X (Left)", "+Y (Away)", "-Y (Towards)", "+Z (Up)", "-Z (Down)") selection:oDDirectionValue width:80 offset:[-3,0] align:#left
		checkbox oDAlignCheckbox "Align To Ground?" checked:oDAlignValue align:#left
		)

		on oDGroupsCheckbox changed state do oDGroupsValue = state
		on oDDirectionDropdown selected i do oDDirectionValue = i
		on oDAlignCheckbox changed state do oDAlignValue = state

		button oDDoButton "Do" width:70 toolTip:"Do It and Close UI" pos:[23,253]
		on oDDoButton pressed do oDDo()
		button oDApplyButton "Apply" width:70 toolTip:"Do It and Keep UI Open" pos:[95,253]
		on oDApplyButton pressed do oDApply()
		button oDHelpButton "Help" width:70 toolTip:"Help" pos:[23,277]
		on oDHelpButton pressed do oDHelp()
		button oDSaveDefButton "SaveDef" width:70 toolTip:"Save Current Settings as Default" pos:[95,277]
		on oDSaveDefButton pressed do oDSaveDef()
		)
	)
)
-------------------------------------------------------------------------------