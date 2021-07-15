-------------------------------------------------------------------------------
-- vertSelectionToObject.ms
-- By Neil Blevins (info@neilblevins.com)
-- v 1.01
-- Created On: 03/02/08
-- Modified On: 04/18/08
-- tested using Max 8.0
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Required Files:
-- sLib.ms
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Description:
-- Places objects at the positions of the currently selected vertexes.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Tutorial:
-- Select a vertex on an object. Run the UI version of the script. Hit Do. Now
-- you have a point object where your selected vert is.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Revision History:
--
-- v 1.01 Replaced the Close button with a Help button. Use the X button to 
-- Close the Floater.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
(
-- Globals

global vertSelectionToObject
global vertSelectionToObjectDefaults
global vertSelectionToObjectUI

global vSTOCloseOpenUI

global vSTODo
global vSTOApply
global vSTOHelp
global vSTOLoadDef
global vSTOSaveDef

global vSTODefineUI
global vSTORollout
global vSTOFloater

-- Includes

include "$scripts\SoulburnScripts\lib\sLib.ms"

-- Variables

vSTOObjTypeValue = 2
vSTOSizeValue = 30
vSTOInstanceValue = true
vSTOPosValue = [400,400]

-- Functions

fn vertSelectionToObject vSTOObjType vSTOSize vSTOInstance = 
	(
	undo "vertSelectionToObject" on
		(
		if selection.count != 1 then (MessageBox "Please select one Object." title:"vertSelectionToObject")
		else
			(
			if superclassof $ != GeometryClass then (MessageBox "Please select a piece of Geometry." title:"vertSelectionToObject")
			else
				(
				-- Create Object
				if vSTOObjType == 1 then obj = Sphere radius:(vSTOSize/2) recenter:off
				else if vSTOObjType == 2 then obj = Point size:vSTOSize Box:on
				else obj = Box lengthsegs:1 widthsegs:1 heightsegs:1 length:vSTOSize width:vSTOSize height:vSTOSize
				
				-- Prep Geometry
				copyOfObject = copy $
				convertToPoly copyOfObject
				
				-- Get Selected Vertexes
				selectedVerts = (getvertselection copyOfObject) as array

				-- Place The Objects
				for v in selectedVerts do
					(
					-- Create New Object
					if vSTOInstance == true then newObj = instance obj
					else newObj = copy obj
					newObj.wirecolor = color 154 185 229
				
					-- Place
					selectedVertPos = polyOp.getVert copyOfObject v
					if vSTOObjType == 1 then newObj.pos = selectedVertPos
					else if vSTOObjType == 2 then newObj.pos = selectedVertPos
					else newObj.pos = [selectedVertPos.x,selectedVertPos.y,selectedVertPos.z-(vSTOSize/2)]
					)

				-- put scene back to normal
				delete copyOfObject
				delete obj
				)
			)
		)
	)

fn vertSelectionToObjectDefaults = 
	(
	vSTOLoadDef()
	vertSelectionToObject vSTOObjTypeValue vSTOSizeValue vSTOInstanceValue
	)
	
fn vertSelectionToObjectUI = 
	(
	vSTOLoadDef()
	vSTOCloseOpenUI vSTOPosValue
	)

fn vSTOCloseOpenUI pos = 
	(
	if vSTOFloater != undefined then CloseRolloutFloater vSTOFloater
	vSTODefineUI()
	vSTOFloater = newRolloutFloater "vertSelectionToObject v1.01" 310 114 pos.x pos.y
	addRollout vSTORollout vSTOFloater
	)

fn vSTODo = 
	(
	vertSelectionToObject vSTOObjTypeValue vSTOSizeValue vSTOInstanceValue
	if vSTOFloater != undefined then CloseRolloutFloater vSTOFloater
	)

fn vSTOApply = 
	(
	vertSelectionToObject vSTOObjTypeValue vSTOSizeValue vSTOInstanceValue
	)
	
fn vSTOHelp = 
	(
	sLibSSPrintHelp "vertSelectionToObject"
	)
	
fn vSTOLoadDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	vSTOInputFilename = presetDir + "vertSelectionToObject.ini"
	if (sLibFileExist vSTOInputFilename == true) then
		(
		vSTOObjTypeValue = execute (getINISetting vSTOInputFilename "splineKnotToObject" "vSTOObjTypeValue")
		vSTOSizeValue = execute (getINISetting vSTOInputFilename "splineKnotToObject" "vSTOSizeValue")
		vSTOInstanceValue = execute (getINISetting vSTOInputFilename "splineKnotToObject" "vSTOInstanceValue")
		vSTOPosValue = execute (getINISetting vSTOInputFilename "splineKnotToObject" "vSTOPosValue")
		
		if vSTOObjTypeValue == OK then vSTOObjTypeValue = 2
		if vSTOSizeValue == OK then vSTOSizeValue = 30
		if vSTOInstanceValue == OK then vSTOInstanceValue = true
		if vSTOPosValue == OK then vSTOPosValue = [400,400]
		)
	else
		(
		vSTOObjTypeValue = 2
		vSTOSizeValue = 30
		vSTOInstanceValue = true
		vSTOPosValue = [400,400]
		)
	)
	
fn vSTOSaveDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	if (getDirectories presetDir).count == 0 then makeDir presetDir
	vSTOOutputFilename = presetDir + "vertSelectionToObject.ini"
	if (sLibFileExist vSTOOutputFilename == true) then deleteFile vSTOOutputFilename
	setINISetting vSTOOutputFilename "splineKnotToObject" "vSTOObjTypeValue" (vSTOObjTypeValue as string)
	setINISetting vSTOOutputFilename "splineKnotToObject" "vSTOSizeValue" (vSTOSizeValue as string)
	setINISetting vSTOOutputFilename "splineKnotToObject" "vSTOInstanceValue" (vSTOInstanceValue as string)
	setINISetting vSTOOutputFilename "splineKnotToObject" "vSTOPosValue" (vSTOFloater.pos as string)
	)

-- UI

fn vSTODefineUI = 
	(
	rollout vSTORollout "vertSelectionToObject"
		(
		label label1 "Obj Type:" pos:[10,10]
		dropdownlist vSTOObjTypeDropdown "" items:#("Sphere", "Point", "Box") selection:vSTOObjTypeValue pos:[60,7] width:120
		spinner vSTOSizeSpinner "Size: " range:[0,99999999,vSTOSizeValue] fieldWidth:55 type:#float pos:[190,9]
		checkbox vSTOInstanceCheckbox "Instance Objects? " checked:vSTOInstanceValue align:#left across:2 offset:[0,4]

		on vSTOObjTypeDropdown selected i do vSTOObjTypeValue = i
		on vSTOSizeSpinner changed val do vSTOSizeValue = val
		on vSTOInstanceCheckbox changed state do vSTOInstanceValue = state

		button vSTODoButton "Do" width:70 toolTip:"Do It and Close UI" pos:[5,57]
		on vSTODoButton pressed do vSTODo()
		button vSTOApplyButton "Apply" width:70 toolTip:"Do It and Keep UI Open" pos:[77,57]
		on vSTOApplyButton pressed do vSTOApply()
		button vSTOHelpButton "Help" width:70 toolTip:"Help" pos:[149,57]
		on vSTOHelpButton pressed do vSTOHelp()
		button vSTOSaveDefButton "SaveDef" width:70 toolTip:"Save Current Settings as Default" pos:[221,57]
		on vSTOSaveDefButton pressed do vSTOSaveDef()
		)
	)
)
-------------------------------------------------------------------------------