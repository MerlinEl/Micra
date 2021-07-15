-------------------------------------------------------------------------------
-- vertexEdgeFaceSelectByNormal.ms
-- By Neil Blevins (info@neilblevins.com)
-- v 1.00
-- Created On: 03/10/15
-- Modified On: 03/10/15
-- tested using Max 2014
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Required Files:
-- sLib.ms
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Description:
-- Selects verts, edges or faces of a Editable Poly based on an angle 
-- threshhold. This is identical to the tool on the Modeling Ribbon, but now
-- accessible as a macroscript since the one in the ribbon didn't have a 
-- macroscript available.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Tutorial:
-- Select an Editable Poly. Go into Face mode. Run the UI version of the script. 
-- Hit Do. It will select a bunch of faces based on your values you gave it.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
(
-- Globals

global vertexEdgeFaceSelectByNormal
global vertexEdgeFaceSelectByNormalDefaults
global vertexEdgeFaceSelectByNormalUI

global vEFSBNCloseOpenUI

global vEFSBNDo
global vEFSBNApply
global vEFSBNHelp
global vEFSBNLoadDef
global vEFSBNSaveDef

global vEFSBNDefineUI
global vEFSBNRollout
global vEFSBNFloater

-- Includes

include "$scripts\SoulburnScripts\lib\sLib.ms"

-- Variables

vEFSBNAxisValue = 1
vEFSBNInvertValue = false
vEFSBNAngleValue = 20
vEFSBNPosValue = [400,400]

-- Functions

fn vertexEdgeFaceSelectByNormal axis invert amount = 
	(
	PolyToolsSelect.Normal axis amount invert
	)
	
fn vertexEdgeFaceSelectByNormalDefaults = 
	(
	vEFSBNLoadDef()
	vertexEdgeFaceSelectByNormal vEFSBNAxisValue vEFSBNInvertValue vEFSBNAngleValue
	)
	
fn vertexEdgeFaceSelectByNormalUI = 
	(
	vEFSBNLoadDef()
	vEFSBNCloseOpenUI vEFSBNPosValue
	)

fn vEFSBNCloseOpenUI pos = 
	(
	if vEFSBNFloater != undefined then CloseRolloutFloater vEFSBNFloater
	vEFSBNDefineUI()
	vEFSBNFloater = newRolloutFloater "vertexEdgeFaceSelectByNormal v1.00" 310 91 pos.x pos.y
	addRollout vEFSBNRollout vEFSBNFloater
	)

fn vEFSBNDo = 
	(
	vertexEdgeFaceSelectByNormal vEFSBNAxisValue vEFSBNInvertValue vEFSBNAngleValue
	if vEFSBNFloater != undefined then CloseRolloutFloater vEFSBNFloater
	)

fn vEFSBNApply = 
	(
	vertexEdgeFaceSelectByNormal vEFSBNAxisValue vEFSBNInvertValue vEFSBNAngleValue
	)
	
fn vEFSBNHelp = 
	(
	sLibSSPrintHelp "vertexEdgeFaceSelectByNormal"
	)
	
fn vEFSBNLoadDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	vEFSBNInputFilename = presetDir + "vertexEdgeFaceSelectByNormal.ini"
	if (sLibFileExist vEFSBNInputFilename == true) then
		(
		vEFSBNAxisValue = execute (getINISetting vEFSBNInputFilename "vertexEdgeFaceSelectByNormal" "vEFSBNAxisValue")
		vEFSBNInvertValue = execute (getINISetting vEFSBNInputFilename "vertexEdgeFaceSelectByNormal" "vEFSBNInvertValue")
		vEFSBNAngleValue = execute (getINISetting vEFSBNInputFilename "vertexEdgeFaceSelectByNormal" "vEFSBNAngleValue")
		vEFSBNPosValue = execute (getINISetting vEFSBNInputFilename "vertexEdgeFaceSelectByNormal" "vEFSBNPosValue")
		
		if vEFSBNAxisValue == OK then vEFSBNAxisValue = 1
		if vEFSBNInvertValue == OK then vEFSBNInvertValue = false
		if vEFSBNAngleValue == OK then vEFSBNAngleValue = 20
		if vEFSBNPosValue == OK then vEFSBNPosValue = [400,400]
		)
	else
		(
		vEFSBNAxisValue = 1
		vEFSBNInvertValue = false
		vEFSBNAngleValue = 20
		vEFSBNPosValue = [400,400]
		)
	)
	
fn vEFSBNSaveDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	if (getDirectories presetDir).count == 0 then makeDir presetDir
	vEFSBNOutputFilename = presetDir + "vertexEdgeFaceSelectByNormal.ini"
	if (sLibFileExist vEFSBNOutputFilename == true) then deleteFile vEFSBNOutputFilename
	setINISetting vEFSBNOutputFilename "vertexEdgeFaceSelectByNormal" "vEFSBNAxisValue" (vEFSBNAxisValue as string)
	setINISetting vEFSBNOutputFilename "vertexEdgeFaceSelectByNormal" "vEFSBNInvertValue" (vEFSBNInvertValue as string)
	setINISetting vEFSBNOutputFilename "vertexEdgeFaceSelectByNormal" "vEFSBNAngleValue" (vEFSBNAngleValue as string)
	setINISetting vEFSBNOutputFilename "vertexEdgeFaceSelectByNormal" "vEFSBNPosValue" (vEFSBNFloater.pos as string)
	)

-- UI

fn vEFSBNDefineUI = 
	(
	rollout vEFSBNRollout "vertexEdgeFaceSelectByNormal"
		(
		label label1 "Axis:" pos:[10,10]
		dropdownlist vEFSBNAxisDropdown "" items:#("X", "Y", "Z") selection:vEFSBNAxisValue pos:[40,7] width:60
		checkbox vEFSBNInvertCheckbox "Invert?" checked:vEFSBNInvertValue align:#left pos:[110,10]
		spinner vEFSBNAngleSpinner "Angle: " range:[0,10000,vEFSBNAngleValue] fieldWidth:55 type:#integer pos:[186,10]
		
		on vEFSBNAxisDropdown selected i do vEFSBNAxisValue = i
		on vEFSBNInvertCheckbox changed state do vEFSBNInvertValue = state
		on vEFSBNAngleSpinner changed val do vEFSBNAngleValue = val

		button vEFSBNDoButton "Do" width:70 toolTip:"Do It and Close UI" pos:[5,34]
		on vEFSBNDoButton pressed do vEFSBNDo()
		button vEFSBNApplyButton "Apply" width:70 toolTip:"Do It and Keep UI Open" pos:[77,34]
		on vEFSBNApplyButton pressed do vEFSBNApply()
		button vEFSBNHelpButton "Help" width:70 toolTip:"Help" pos:[149,34]
		on vEFSBNHelpButton pressed do vEFSBNHelp()
		button vEFSBNSaveDefButton "SaveDef" width:70 toolTip:"Save Current Settings as Default" pos:[221,34]
		on vEFSBNSaveDefButton pressed do vEFSBNSaveDef()
		)
	)
)
-------------------------------------------------------------------------------