-------------------------------------------------------------------------------
-- vertexMapDisplayer.ms
-- By Neil Blevins (info@neilblevins.com)
-- v 1.00
-- Created On: 05/11/08
-- Modified On: 05/11/08
-- tested using Max 8.0
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Required Files:
-- sLib.ms
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Description:
-- Toggles or turns on or off the vertex map viewport display for all scene 
-- or selected objects.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Tutorial:
-- Select a bunch of objects that already have vertex maps. Run the UI version 
-- of the script. Choose "Selected". Hit Do. It will toggle the vertex map 
-- display in the viewport on or off.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
(
-- Globals

global vertexMapDisplayer
global vertexMapDisplayerDefaults
global vertexMapDisplayerUI

global vMDCloseOpenUI

global vMDDo
global vMDApply
global vMDHelp
global vMDLoadDef
global vMDSaveDef

global vMDDefineUI
global vMDRollout
global vMDFloater

-- Includes

include "$scripts\SoulburnScripts\lib\sLib.ms"

-- Variables

vMDActionValue = 1
vMDObjsValue = 1
vMDPosValue = [400,400]

-- Functions

fn vertexMapDisplayer vMDAction vMDObjs = 
	(
	objs = #()
	if vMDObjs == 1 then objs = for i in $* collect i
	else objs = for i in selection collect i
	for i in objs do
		(
		if vMDAction == 1 then
			(
			if i.showVertexColors == true then i.showVertexColors = false
			else i.showVertexColors = true
			)
		else if vMDAction == 2 then
			(
			i.showVertexColors = true
			)
		else if vMDAction == 3 then
			(
			i.showVertexColors = false
			)
		)
	)
	
fn vertexMapDisplayerDefaults = 
	(
	vMDLoadDef()
	vertexMapDisplayer vMDActionValue vMDObjsValue
	)
	
fn vertexMapDisplayerUI = 
	(
	vMDLoadDef()
	vMDCloseOpenUI vMDPosValue
	)

fn vMDCloseOpenUI pos = 
	(
	if vMDFloater != undefined then CloseRolloutFloater vMDFloater
	vMDDefineUI()
	vMDFloater = newRolloutFloater "vertexMapDisplayer v1.00" 187 146 pos.x pos.y
	addRollout vMDRollout vMDFloater
	)

fn vMDDo = 
	(
	vertexMapDisplayer vMDActionValue vMDObjsValue
	if vMDFloater != undefined then CloseRolloutFloater vMDFloater
	)

fn vMDApply = 
	(
	vertexMapDisplayer vMDActionValue vMDObjsValue
	)
	
fn vMDHelp = 
	(
	sLibSSPrintHelp "vertexMapDisplayer"
	)
	
fn vMDLoadDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	vMDInputFilename = presetDir + "vertexMapDisplayer.ini"
	if (sLibFileExist vMDInputFilename == true) then
		(
		vMDActionValue = execute (getINISetting vMDInputFilename "vertexMapDisplayer" "vMDActionValue")
		vMDObjsValue = execute (getINISetting vMDInputFilename "vertexMapDisplayer" "vMDObjsValue")
		vMDPosValue = execute (getINISetting vMDInputFilename "vertexMapDisplayer" "vMDPosValue")
		
		if vMDActionValue == OK then vMDActionValue = 1
		if vMDObjsValue == OK then vMDObjsValue = 1
		if vMDPosValue == OK then vMDPosValue = [400,400]
		)
	else
		(
		vMDActionValue = 1
		vMDObjsValue = 1
		vMDPosValue = [400,400]
		)
	)
	
fn vMDSaveDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	if (getDirectories presetDir).count == 0 then makeDir presetDir
	vMDOutputFilename = presetDir + "vertexMapDisplayer.ini"
	if (sLibFileExist vMDOutputFilename == true) then deleteFile vMDOutputFilename
	setINISetting vMDOutputFilename "vertexMapDisplayer" "vMDActionValue" (vMDActionValue as string)
	setINISetting vMDOutputFilename "vertexMapDisplayer" "vMDObjsValue" (vMDObjsValue as string)
	setINISetting vMDOutputFilename "vertexMapDisplayer" "vMDPosValue" (vMDFloater.pos as string)
	)

-- UI

fn vMDDefineUI = 
	(
	rollout vMDRollout "vertexMapDisplayer"
		(
		label label1 "Action:" across:2 align:#left offset:[0,3]
		dropdownlist vMDActionDropdown "" items:#("Toggle", "On", "Off") selection:vMDActionValue width:105 align:#right
		label label2 "Objects:" across:2 align:#left offset:[0,3]
		dropdownlist vMDObjsDropdown "" items:#("Scene", "Selection") selection:vMDObjsValue width:105 align:#right
		
		on vMDActionDropdown selected i do vMDActionValue = i
		on vMDObjsDropdown selected i do vMDObjsValue = i

		button vMDDoButton "Do" width:70 toolTip:"Do It and Close UI" pos:[15,65]
		on vMDDoButton pressed do vMDDo()
		button vMDApplyButton "Apply" width:70 toolTip:"Do It and Keep UI Open" pos:[87,65]
		on vMDApplyButton pressed do vMDApply()
		button vMDHelpButton "Help" width:70 toolTip:"Help" pos:[15,89]
		on vMDHelpButton pressed do vMDHelp()
		button vMDSaveDefButton "SaveDef" width:70 toolTip:"Save Current Settings as Default" pos:[87,89]
		on vMDSaveDefButton pressed do vMDSaveDef()
		)
	)
)
-------------------------------------------------------------------------------