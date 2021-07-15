-------------------------------------------------------------------------------
-- edgeSelectByAngle.ms
-- By Neil Blevins (info@neilblevins.com)
-- v 1.02
-- Created On: 08/27/07
-- Modified On: 04/18/08
-- tested using Max 8.0
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Required Files:
-- sLib.ms
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Description:
-- Selects edges of a mesh based on the angle between adjacent faces. For 
-- example, you can select all the edges of a mesh for chamfer by placing a 
-- value of 90.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Tutorial:
-- Make a cube with segments set to 3 in all 3 directions. Collapse to Editable
-- Poly. Run the UI version of the script. Set low value to 80 degrees. Set 
-- high value to 90. Hit Do. All the sharp edges will be selected.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Revision History:
--
-- v 1.01 Added sLibMaxVer test.
--
-- v 1.02 Replaced the Close button with a Help button. Use the X button to 
-- Close the Floater.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Known Issues:
-- Editpoly support is only in max9 and above, and this will not change due
-- to lack of editpoly maxscript support in earlier versions of max.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
(
-- Globals

global edgeSelectByAngle
global edgeSelectByAngleDefaults
global edgeSelectByAngleUI

global eSBACloseOpenUI

global eSBADo
global eSBAApply
global eSBAHelp
global eSBALoadDef
global eSBASaveDef

global eSBADefineUI
global eSBARollout
global eSBAFloater

-- Includes

include "$scripts\SoulburnScripts\lib\sLib.ms"

-- Variables

eSBALowValue = 80
eSBAHighValue = 90
eSBAPosValue = [400,400]

-- Functions

fn edgeSelectByAngle eSBALow eSBAHigh = 
	(
	undo "edgeSelectByAngle" on
		(
		if eSBALow > eSBAHigh then (LowVal = eSBAHigh;HighVal = eSBALow)
		else (LowVal = eSBALow;HighVal = eSBAHigh)
		if selection.count == 1 then
			(
			obj = selection[1]
			disableSceneRedraw()
			try
				(
				finalEdges = #()
				setCommandPanelTaskMode #modify
				if classof (modPanel.getCurrentObject ()) == Editable_Poly then 
					(
					numEdges = polyOp.getNumEdges obj
					for i = 1 to numEdges do
						(
						a = polyOp.getEdgeFaces obj i
						if a.count == 2 then
							(
							normal1 = polyOp.getFaceNormal obj a[1]
							normal2 = polyOp.getFaceNormal obj a[2]
							theAngle = acos(dot (normalize normal1) (normalize normal2))
							if theAngle >= (LowVal - 0.001) and theAngle <= (HighVal + 0.001) then append finalEdges i
							)
						)
					subobjectLevel = 2
					polyOp.setEdgeSelection obj (finalEdges as bitarray)
					)
				else if classof (modPanel.getCurrentObject ()) == Edit_Poly then 
					(
					if sLibMaxVer() < 9.0 then (MessageBox "To affect Edit Poly modifiers, please use this script in max9 or above." title:"edgeSelectByAngle")
					else
						(
						currentModIndex = (modPanel.getModifierIndex obj (modPanel.getCurrentObject()))
						myMod = obj.modifiers[currentModIndex]
						numEdges = myMod.getNumEdges()
						for i = 1 to numEdges do
							(
							a = #()
							append a (myMod.getEdgeFace i 1)
							append a (myMod.getEdgeFace i 2)
							if a.count == 2 then
								(
								normal1 = myMod.getFaceNormal a[1]
								normal2 = myMod.getFaceNormal a[2]
								theAngle = acos(dot (normalize normal1) (normalize normal2))
								if theAngle >= (LowVal - 0.001) and theAngle <= (HighVal + 0.001) then append finalEdges i
								)
							)
						myMod.SetEPolySelLevel #edge
						myMod.Select #Edge (finalEdges as bitarray)
						)
					)
				else (MessageBox "This script only works on Editable Poly objects or in Edit Poly modifiers." title:"edgeSelectByAngle")
				)
			catch ()
			enableSceneRedraw()
			completeRedraw()	
			)
		)
	)
	
fn edgeSelectByAngleDefaults = 
	(
	eSBALoadDef()
	edgeSelectByAngle eSBALowValue eSBAHighValue
	)
	
fn edgeSelectByAngleUI = 
	(
	eSBALoadDef()
	eSBACloseOpenUI eSBAPosValue
	)

fn eSBACloseOpenUI pos = 
	(
	if eSBAFloater != undefined then CloseRolloutFloater eSBAFloater
	eSBADefineUI()
	eSBAFloater = newRolloutFloater "edgeSelectByAngle v1.02" 310 91 pos.x pos.y
	addRollout eSBARollout eSBAFloater
	)

fn eSBADo = 
	(
	edgeSelectByAngle eSBALowValue eSBAHighValue
	if eSBAFloater != undefined then CloseRolloutFloater eSBAFloater
	)

fn eSBAApply = 
	(
	edgeSelectByAngle eSBALowValue eSBAHighValue
	)
	
fn eSBAHelp = 
	(
	sLibSSPrintHelp "edgeSelectByAngle"
	)
	
fn eSBALoadDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	eSBAInputFilename = presetDir + "edgeSelectByAngle.ini"
	if (sLibFileExist eSBAInputFilename == true) then
		(
		eSBALowValue = execute (getINISetting eSBAInputFilename "edgeSelectByAngle" "eSBALowValue")
		eSBAHighValue = execute (getINISetting eSBAInputFilename "edgeSelectByAngle" "eSBAHighValue")
		eSBAPosValue = execute (getINISetting eSBAInputFilename "edgeSelectByAngle" "eSBAPosValue")
		
		if eSBALowValue == OK then eSBALowValue = 80
		if eSBAHighValue == OK then eSBAHighValue = 90
		if eSBAPosValue == OK then eSBAPosValue = [400,400]
		)
	else
		(
		eSBALowValue = 80
		eSBAHighValue = 90
		eSBAPosValue = [400,400]
		)
	)
	
fn eSBASaveDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	if (getDirectories presetDir).count == 0 then makeDir presetDir
	eSBAOutputFilename = presetDir + "edgeSelectByAngle.ini"
	if (sLibFileExist eSBAOutputFilename == true) then deleteFile eSBAOutputFilename
	setINISetting eSBAOutputFilename "edgeSelectByAngle" "eSBALowValue" (eSBALowValue as string)
	setINISetting eSBAOutputFilename "edgeSelectByAngle" "eSBAHighValue" (eSBAHighValue as string)
	setINISetting eSBAOutputFilename "edgeSelectByAngle" "eSBAPosValue" (eSBAFloater.pos as string)
	)

-- UI

fn eSBADefineUI = 
	(
	rollout eSBARollout "edgeSelectByAngle"
		(
		spinner eSBALowSpinner "Low: " range:[0,360,eSBALowValue] fieldWidth:55 type:#float across:2 align:#center
		spinner eSBAHighSpinner "High: " range:[0,360,eSBAHighValue] fieldWidth:55 type:#float align:#center
		on eSBALowSpinner changed val do eSBALowValue = val
		on eSBAHighSpinner changed val do eSBAHighValue = val

		button eSBADoButton "Do" width:70 toolTip:"Do It and Close UI" pos:[5,34]
		on eSBADoButton pressed do eSBADo()
		button eSBAApplyButton "Apply" width:70 toolTip:"Do It and Keep UI Open" pos:[77,34]
		on eSBAApplyButton pressed do eSBAApply()
		button eSBAHelpButton "Help" width:70 toolTip:"Help" pos:[149,34]
		on eSBAHelpButton pressed do eSBAHelp()
		button eSBASaveDefButton "SaveDef" width:70 toolTip:"Save Current Settings as Default" pos:[221,34]
		on eSBASaveDefButton pressed do eSBASaveDef()
		)
	)
)
-------------------------------------------------------------------------------