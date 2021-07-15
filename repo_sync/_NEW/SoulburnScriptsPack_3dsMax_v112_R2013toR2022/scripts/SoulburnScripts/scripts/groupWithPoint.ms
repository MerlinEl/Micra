-------------------------------------------------------------------------------
-- groupWithPoint.ms
-- By Neil Blevins (info@neilblevins.com)
-- v 1.09
-- Created On: 10/15/05
-- Modified On: 02/13/19
-- tested using Max 2017
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Required Files:
-- sLib.ms
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Description:
-- Takes selected objects and groups or ungroups them by linking them to a 
-- point helper instead of using the max group method. Very similar to the way
-- maya handles grouping.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Tutorial:
-- Select a bunch of objects. Run the UI version of the script. Hit Do. Your objects
-- are now linked to a dummy that is placed at the center of your objects.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Revision History:
--
-- v 1.01 Added some new code to more cleanly open and close the UI.
--
-- v 1.02 Added a spinner to make the point size some percentage of the 
-- max boundingbox of your selection.
--
-- v 1.03 Replaced the Close button with a Help button. Use the X button to 
-- Close the Floater.
--
-- v 1.04 Fixed an issue where the script did the wrong thing if you tried to Group
-- a Group. And tries to be a little smarter about grouping inside a 
-- hierarchy.
--
-- v 1.05 The Hierarchy smarts mentionned in my last fix ended up causing a lot of 
-- problems so I've simplified the functionality so at least it returns
-- consistent results.
--
-- v 1.06 Added option to not select the resulting point helper. Added some
-- options on what to do if your selected objects have existing hierarchy.
-- Cleaned up a lot of code.
--
-- v 1.07 Added option to have it not size the point based on bounding box
-- size. The point will be of whatever default size you last chose. Added
-- option to use a dummy instead of a point, which helps when exporting the scene
-- as fbx to maya. Point is still default.
--
-- v 1.08 Added ability to place the point at the lowest point instead of centered.
-- This can be helpful when the object is sitting on the floor and you want
-- to have the pivot point on the floor as well.
--
-- v 1.09 Added ability to place the point at the origin.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
(
-- Globals

global groupWithPoint
global groupWithPointDefaults
global groupWithPointUI

global gWPCloseOpenUI

global gWPDo
global gWPApply
global gWPHelp
global gWPLoadDef
global gWPSaveDef

global gWPDefineUI
global gWPRollout
global gWPFloater

-- Includes

include "$scripts\SoulburnScripts\lib\sLib.ms"

-- Variables

gWPModeValue = 1
gWPTypeValue = 1
gWPResizePointValue = true
gWPSizePercentageValue = 100
gWPSelectGroupValue = true
gWPHierarchyValue = 1
gWPPivotPlaceValue = 1
gWPPosValue = [400,400]

-- Functions

fn groupWithPoint gWPMode gWPType gWPResizePoint gWPSizePercentage gWPSelectGroup gWPHierarchy gWPPivotPlace = 
	(
	gWPPoint = #()	
	
	undo "groupWithPoint" on
		(
		-- Group
		if gWPMode == 1 then
			(
			if selection.count < 1 then MessageBox "Please select at least 1 object." title:"groupWithPoint"
			else
				(
				-- select objects
				objs = for i in selection collect i

				-- setup point
				if gWPType == 1 then
					(
					myLocator = Point box:on cross_radius:10 name:(uniquename "groupWithPoint")
					)
				else 
					(
					myLocator = Dummy name:(uniquename "groupWithPoint")
					)
				select objs
				
				-- point size
				if gWPType == 1 then
					(
					if gWPResizePoint == true then
						(
						bBoxSize = sLibGetCollectionBBox objs
						sizeX = abs (bBoxSize[2].x - bBoxSize[1].x)
						sizeY = abs (bBoxSize[2].y - bBoxSize[1].y)
						sizeZ = abs (bBoxSize[2].z - bBoxSize[1].z)
						myLocator.size = abs (2*(amax #(sizeX, sizeY, sizeZ))*(gWPSizePercentage*0.01))
						)
					)
				
				-- point position
				if gWPPivotPlace == 1 then
					(
					bBoxCenter = sLibGetCollectionBBoxCenter objs
					myLocator.pos = bBoxCenter
					)
				else if gWPPivotPlace == 2 then
					(
					bBoxCenter = sLibGetCollectionBBoxCenter objs
					bBox = sLibGetCollectionBBox objs
					myLocator.pos = [bBoxCenter.x, bBoxCenter.y, bBox[2].z]
					)
				else
					(
					myLocator.pos = [0,0,0]
					)
				
				-- remove group members
				objsNoGroup = #()
				for i in objs do (if isGroupMember i == false then append objsNoGroup i)

				-- parenting
				if gWPHierarchy == 1 then 
					(
					for i in objsNoGroup do i.parent = myLocator
					)
				else if gWPHierarchy == 2 then 
					(
					for i in (sLibFindParentsInObjs objsNoGroup) do i.parent = myLocator
					)
				else if gWPHierarchy == 3 then 
					(
					for i in (sLibFindParentsOfObjs objsNoGroup) do i.parent = myLocator
					)

				-- select point
				if gWPSelectGroup == true then (select myLocator)
				gWPPoint = myLocator
				)
			)
		-- Ungroup
		else
			(
			if selection.count == 1 then
				(
				if classof $ == point or classof $ == dummy then
					(
					for i in $.children do
						(
						if classof $ == point or classof $ == dummy then i.parent = $.parent else
						i.parent == undefined						
						)
					delete $
					)
				)
			)
		)
	return #(gWPPoint)
	)

fn groupWithPointDefaults = 
	(
	gWPLoadDef()
	groupWithPoint gWPModeValue gWPTypeValue gWPResizePointValue gWPSizePercentageValue gWPSelectGroupValue gWPHierarchyValue gWPPivotPlaceValue
	)
	
fn groupWithPointUI = 
	(
	gWPLoadDef()
	gWPCloseOpenUI gWPPosValue
	)

fn gWPCloseOpenUI pos = 
	(
	if gWPFloater != undefined then CloseRolloutFloater gWPFloater
	gWPDefineUI()
	gWPFloater = newRolloutFloater "groupWithPoint v1.09" 166 256 pos.x pos.y
	addRollout gWPRollout gWPFloater
	)

fn gWPDo = 
	(
	groupWithPoint gWPModeValue gWPTypeValue gWPResizePointValue gWPSizePercentageValue gWPSelectGroupValue gWPHierarchyValue gWPPivotPlaceValue
	if gWPFloater != undefined then CloseRolloutFloater gWPFloater
	)

fn gWPApply = 
	(
	groupWithPoint gWPModeValue gWPTypeValue gWPResizePointValue gWPSizePercentageValue gWPSelectGroupValue gWPHierarchyValue gWPPivotPlaceValue
	)
	
fn gWPHelp = 
	(
	sLibSSPrintHelp "groupWithPoint"
	)
	
fn gWPLoadDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	gWPInputFilename = presetDir + "groupWithPoint.ini"
	if (sLibFileExist gWPInputFilename == true) then
		(
		gWPModeValue = execute (getINISetting gWPInputFilename "groupWithPoint" "gWPModeValue")
		gWPTypeValue = execute (getINISetting gWPInputFilename "groupWithPoint" "gWPTypeValue")
		gWPResizePointValue = execute (getINISetting gWPInputFilename "groupWithPoint" "gWPResizePointValue")
		gWPSizePercentageValue = execute (getINISetting gWPInputFilename "groupWithPoint" "gWPSizePercentageValue")
		gWPSelectGroupValue = execute (getINISetting gWPInputFilename "groupWithPoint" "gWPSelectGroupValue")
		gWPHierarchyValue = execute (getINISetting gWPInputFilename "groupWithPoint" "gWPHierarchyValue")
		gWPPivotPlaceValue = execute (getINISetting gWPInputFilename "groupWithPoint" "gWPPivotPlaceValue")
		gWPPosValue = execute (getINISetting gWPInputFilename "groupWithPoint" "gWPPosValue")
		
		if gWPModeValue == OK then gWPModeValue = 1
		if gWPTypeValue == OK then gWPTypeValue = 1
		if gWPResizePointValue == OK then gWPResizePointValue = true
		if gWPSizePercentageValue == OK then gWPSizePercentageValue = 100
		if gWPSelectGroupValue == OK then gWPSelectGroupValue = true
		if gWPHierarchyValue == OK then gWPHierarchyValue = 1
		if gWPPivotPlaceValue == OK then gWPPivotPlaceValue = 1
		if gWPPosValue == OK then gWPPosValue = [400,400]
		)
	else
		(
		gWPModeValue = 1
		gWPTypeValue = 1
		gWPResizePointValue = true
		gWPSizePercentageValue = 100
		gWPSelectGroupValue = true
		gWPHierarchyValue = 1
		gWPPivotPlaceValue = 1
		gWPPosValue = [400,400]
		)
	)
	
fn gWPSaveDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	if (getDirectories presetDir).count == 0 then makeDir presetDir
	gWPOutputFilename = presetDir + "groupWithPoint.ini"
	if (sLibFileExist gWPOutputFilename == true) then deleteFile gWPOutputFilename
	setINISetting gWPOutputFilename "groupWithPoint" "gWPModeValue" (gWPModeValue as string)
	setINISetting gWPOutputFilename "groupWithPoint" "gWPTypeValue" (gWPTypeValue as string)
	setINISetting gWPOutputFilename "groupWithPoint" "gWPResizePointValue" (gWPResizePointValue as string)
	setINISetting gWPOutputFilename "groupWithPoint" "gWPSizePercentageValue" (gWPSizePercentageValue as string)
	setINISetting gWPOutputFilename "groupWithPoint" "gWPSelectGroupValue" (gWPSelectGroupValue as string)
	setINISetting gWPOutputFilename "groupWithPoint" "gWPHierarchyValue" (gWPHierarchyValue as string)
	setINISetting gWPOutputFilename "groupWithPoint" "gWPPivotPlaceValue" (gWPPivotPlaceValue as string)
	setINISetting gWPOutputFilename "groupWithPoint" "gWPPosValue" (gWPFloater.pos as string)
	)

-- UI

fn gWPDefineUI = 
	(
	rollout gWPRollout "groupWithPoint"
		(
		dropdownlist gWPModeDropdown "" items:#("Group", "UnGroup") selection:gWPModeValue width:130
		dropdownlist gWPTypeDropdown "" items:#("Point", "Dummy") selection:gWPTypeValue width:130
		checkbox gWPResizePointCheckbox "Resize Point Object?" checked:gWPResizePointValue
		spinner gWPSizePercentageSpinner "Size %: " range:[0,10000,gWPSizePercentageValue] fieldWidth:50 type:#integer align:#left
		checkbox gWPSelectGroupCheckbox "Select Point Helper?" checked:gWPSelectGroupValue
		dropdownlist gWPHierarchyDropdown "" items:#("Remove Hierarchy", "Keep Hierarchy in Selection", "Keep All Hierarchy") selection:gWPHierarchyValue width:130
		dropdownlist gWPPivotPlaceDropdown "" items:#("Centered", "Bottom Middle", "World Origin") selection:gWPPivotPlaceValue width:130

		on gWPModeDropdown selected i do gWPModeValue = i
		on gWPTypeDropdown selected i do 
			(
			gWPTypeValue = i
			if gWPTypeValue == 1 then
				(
				gWPResizePointCheckbox.enabled = true
				gWPSizePercentageSpinner.enabled = true
				)
			else 
				(
				gWPResizePointCheckbox.enabled = false
				gWPSizePercentageSpinner.enabled = false
				)			
			)
		on gWPResizePointCheckbox changed state do 
			(
			gWPResizePointValue = state
			gWPSizePercentageSpinner.enabled = state
			)
		on gWPSizePercentageSpinner changed val do gWPSizePercentageValue = val
		on gWPSelectGroupCheckbox changed state do gWPSelectGroupValue = state	
		on gWPHierarchyDropdown selected i do gWPHierarchyValue = i
		on gWPPivotPlaceDropdown selected i do gWPPivotPlaceValue = i

		button gWPDoButton "Do" width:70 toolTip:"Do It and Close UI" pos:[5,176]
		on gWPDoButton pressed do gWPDo()
		button gWPApplyButton "Apply" width:70 toolTip:"Do It and Keep UI Open" pos:[77,176]
		on gWPApplyButton pressed do gWPApply()
		button gWPHelpButton "Help" width:70 toolTip:"Help" pos:[5,200]
		on gWPHelpButton pressed do gWPHelp()
		button gWPSaveDefButton "SaveDef" width:70 toolTip:"Save Current Settings as Default" pos:[77,200]
		on gWPSaveDefButton pressed do gWPSaveDef()
		
		on gWPRollout open do
			(
			if gWPTypeValue == 1 then
				(
				gWPResizePointCheckbox.enabled = true
				gWPSizePercentageSpinner.enabled = true
				)
			else 
				(
				gWPResizePointCheckbox.enabled = false
				gWPSizePercentageSpinner.enabled = false
				)
			gWPSizePercentageSpinner.enabled = gWPResizePointValue
			)
		)
	)
)
-------------------------------------------------------------------------------