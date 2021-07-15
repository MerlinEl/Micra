-------------------------------------------------------------------------------
-- uVFlattener.ms
-- By Neil Blevins (info@neilblevins.com)
-- v 1.01
-- Created On: 06/01/09
-- Modified On: 10/27/09
-- tested using Max 2009
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Required Files:
-- sLib.ms
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Description:
-- Lets you flatten a selection of UVs, or in other words aligns all selected
-- UVs horizontally or vertically. The advantage of using this tool over the one
-- provided in the Unwrap UVW editor is you can choose to align the UVs to the
-- average, the min or the max.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Tutorial:
-- Select a polygonal object, apply a UVWUnwrap modifier to it, edit the uvs
-- using the modifier, select some uvs (either in vertex or edge mode). Run the 
-- UI version of the script, and click the "Min U" button. Now all the U values
-- of the selected UVs will align with the lowest value.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Revision History:
--
-- v 1.01 Cleaned up some code. Fixed an issue that would happen when trying to
-- flatten a uvwunwrap that spans multiple objects. Thanks to Titov Mykhaylo 
-- (ashim@rambler.ru) for the code.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
(
-- Globals

global uVFlattener
global uVFlattenerDefaults
global uVFlattenerUI

global uVFCloseOpenUI

global uVFHelp
global uVFLoadDef
global uVFSaveDef

global uVFDefineUI
global uVFRollout
global uVFFloater

-- Includes

include "$scripts\SoulburnScripts\lib\sLib.ms"

-- Variables

uVFModeValue = 1
uVFAxisValue = 1
uVFPosValue = [400,400]

uVFBitmapUMin = openbitmap ((getdir #scripts) + "\\SoulburnScripts\\images\\" + "uVFlattenerUMin.bmp")
uVFBitmapUAv = openbitmap ((getdir #scripts) + "\\SoulburnScripts\\images\\" + "uVFlattenerUAv.bmp")
uVFBitmapUMax = openbitmap ((getdir #scripts) + "\\SoulburnScripts\\images\\" + "uVFlattenerUMax.bmp")
uVFBitmapVMin = openbitmap ((getdir #scripts) + "\\SoulburnScripts\\images\\" + "uVFlattenerVMin.bmp")
uVFBitmapVAv = openbitmap ((getdir #scripts) + "\\SoulburnScripts\\images\\" + "uVFlattenerVAv.bmp")
uVFBitmapVMax = openbitmap ((getdir #scripts) + "\\SoulburnScripts\\images\\" + "uVFlattenerVMax.bmp")

-- Functions

fn uVFlattener uVFMode uVFAxis = 
	(
	undo "uVFlattener" on
		(
		if classof (modPanel.getCurrentObject()) == Unwrap_UVW then
			(
			-- change uvs
			if (modPanel.getCurrentObject()).getTVSubObjectMode() == 2 then (modPanel.getCurrentObject()).edgeToVertSelect()
			SelectedObjects = $selection as array
			Verts = for obj in SelectedObjects collect (modPanel.getCurrentObject()).unwrap6.getSelectedVerticesbyNode obj
			vertsCount = 0
			for v in Verts do vertsCount += v.count

			if vertsCount !=0 then
				(
				if uVFAxis == 1 then 
					(
					vPAverageU = 0
					vPAllUValues = #()
					for i = 1 to SelectedObjects.count do
						(
						for v in Verts[i] do
							(
							append vPAllUValues ((modPanel.getCurrentObject()).unwrap6.getVertexPositionByNode currenttime v SelectedObjects[i]).x
							)
						)					
					if uVFMode == 1 then (modPanel.getCurrentObject()).unwrap.moveX (amin vPAllUValues)
					else if uVFMode == 2 then (modPanel.getCurrentObject()).unwrap.moveX (sLibAverageMinMaxOfArray vPAllUValues)
					else if uVFMode == 3 then (modPanel.getCurrentObject()).unwrap.moveX (amax vPAllUValues)
					)
				else if uVFAxis == 2 then 
					(
					vPAverageV = 0
					vPAllVValues = #()
					for i = 1 to SelectedObjects.count do
						(
						for v in Verts[i] do
							(
							append vPAllVValues ((modPanel.getCurrentObject()).unwrap6.getVertexPositionByNode currenttime v SelectedObjects[i]).y
							)
						)
					if uVFMode == 1 then (modPanel.getCurrentObject()).unwrap.moveY (amin vPAllVValues)
					else if uVFMode == 2 then (modPanel.getCurrentObject()).unwrap.moveY (sLibAverageMinMaxOfArray vPAllVValues)
					else if uVFMode == 3 then (modPanel.getCurrentObject()).unwrap.moveY (amax vPAllVValues)
					)
				)
			)
		)
	)
	
fn uVFlattenerDefaults = 
	(
	uVFLoadDef()
	uVFlattener uVFModeValue uVFAxisValue
	)

fn uVFlattenerUI = 
	(
	uVFLoadDef()
	uVFCloseOpenUI uVFPosValue
	)
	
fn uVFCloseOpenUI pos = 
	(
	if uVFFloater != undefined then CloseRolloutFloater uVFFloater
	uVFDefineUI()
	uVFFloater = newRolloutFloater "uVFlattener v1.01" 164 147 pos.x pos.y
	addRollout uVFRollout uVFFloater
	)
	
fn uVFHelp = 
	(
	sLibSSPrintHelp "uVFlattener"
	)
	
fn uVFLoadDef = 
	(
	uVFInputFilename = ((getdir #scripts) + "\\SoulburnScripts\\presets\\" + "uVFlattener.ini")
	if (sLibFileExist uVFInputFilename == true) then
		(
		uVFModeValue = execute (getINISetting uVFInputFilename "uVFlattener" "uVFModeValue")
		uVFAxisValue = execute (getINISetting uVFInputFilename "uVFlattener" "uVFAxisValue")
		uVFPosValue = execute (getINISetting uVFInputFilename "uVFlattener" "uVFPosValue")
		
		if uVFModeValue == OK then uVFModeValue = 1
		if uVFAxisValue == OK then uVFAxisValue = 1
		if uVFPosValue == OK then uVFPosValue = [400,400]
		)
	else
		(
		uVFModeValue = 1
		uVFAxisValue = 1
		uVFPosValue = [400,400]
		)
	)
	
fn uVFSaveDef = 
	(
	uVFOutputFilename = ((getdir #scripts) + "\\SoulburnScripts\\presets\\" + "uVFlattener.ini")
	if (sLibFileExist uVFOutputFilename == true) then deleteFile uVFOutputFilename
	setINISetting uVFOutputFilename "uVFlattener" "uVFModeValue" (uVFModeValue as string)
	setINISetting uVFOutputFilename "uVFlattener" "uVFAxisValue" (uVFAxisValue as string)
	setINISetting uVFOutputFilename "uVFlattener" "uVFPosValue" (uVFFloater.pos as string)
	)

-- UI

fn uVFDefineUI = 
	(
	rollout uVFRollout "uVFlattener"
		(
		button uVFDoUMinButton "Min U" width:37 height:37 toolTip:"Min U" across:3 align:#left images:#(uVFBitmapUMin, undefined, 1, 1, 1, 1, 1)
		button uVFDoUAverageButton "Average U" width:37 height:37 toolTip:"Average U" align:#center images:#(uVFBitmapUAv, undefined, 1, 1, 1, 1, 1)
		button uVFDoUMaxButton "Max U" width:37 height:37 toolTip:"Max U" align:#right images:#(uVFBitmapUMax, undefined, 1, 1, 1, 1, 1)
		button uVFDoVMinButton "Min V" width:37 height:37 toolTip:"Min V" across:3 align:#left images:#(uVFBitmapVMin, undefined, 1, 1, 1, 1, 1)
		button uVFDoVAverageButton "Average V" width:37 height:37 toolTip:"Average V" align:#center images:#(uVFBitmapVAv, undefined, 1, 1, 1, 1, 1)
		button uVFDoVMaxButton "Max V" width:37 height:37 toolTip:"Max V" align:#right images:#(uVFBitmapVMax, undefined, 1, 1, 1, 1, 1)
		
		on uVFDoUMinButton pressed do uVFlattener 1 1
		on uVFDoUAverageButton pressed do uVFlattener 2 1
		on uVFDoUMaxButton pressed do uVFlattener 3 1
		on uVFDoVMinButton pressed do uVFlattener 1 2
		on uVFDoVAverageButton pressed do uVFlattener 2 2
		on uVFDoVMaxButton pressed do uVFlattener 3 2
	
		button uVFHelpButton "Help" width:70 toolTip:"Help" pos:[4,91]
		on uVFHelpButton pressed do uVFHelp()
		button uVFSaveDefButton "SaveDef" width:70 toolTip:"Save Current Settings as Default" pos:[76,91]
		on uVFSaveDefButton pressed do uVFSaveDef()
		)
	)
)
-------------------------------------------------------------------------------