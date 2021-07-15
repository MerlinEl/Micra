-------------------------------------------------------------------------------
-- uVAreaDisplayer.ms
-- By Neil Blevins (info@neilblevins.com)
-- v 1.00
-- Created On: 11/20/09
-- Modified On: 11/21/09
-- tested using Max 2009
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Required Files:
-- sLib.ms
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Description:
-- Prints the area of the currently selected UV faces. Thanks to Mark for the
-- suggestion.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Tutorial:
-- Select an object. Apply a Unwrap UVW modifier. Click "Edit" in the modifier.
-- Select some faces. Run the UI version of the script. Hit Do. It will print
-- the uv area of those faces in the maxscript editor.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
(
-- Globals

global uVAreaDisplayer
global uVAreaDisplayerDefaults
global uVAreaDisplayerUI

global uVADCloseOpenUI

global uVADDo
global uVADApply
global uVADHelp
global uVADLoadDef
global uVADSaveDef

global uVADDefineUI
global uVADRollout
global uVADFloater

-- Includes

include "$scripts\SoulburnScripts\lib\sLib.ms"

-- Variables

uVADWarningValue = true
vMDDisplayHowValue = 1
uVADPosValue = [400,400]

-- Functions

fn uVAreaDisplayer uVADWarning vMDDisplayHow = 
	(
	if classof (modPanel.getCurrentObject()) == Unwrap_UVW then
		(
		myfaces = (modPanel.getCurrentObject()).getSelectedPolygons()
		if myfaces.isEmpty == true then (MessageBox "Please select some faces." title:"uVAreaDisplayer")
		else
			(
			Message = ""
			(modPanel.getCurrentObject()).getArea myfaces &myx &myy &mywidth &myheight &myareaUVW &myareaGeom
			Message = "Area Of Currently Selected UV Faces: " + ((myareaUVW * 100) as string) + "%"
			if uVADWarning == true then
				(
				error = false
				if myx < -0.000001 then error = true
				if myx > 1.000001 then error = true
				if myy < -0.000001 then error = true
				if myy > 1.000001 then error = true
				if error == true then Message += " -- Some selected UVs are outside the range of 0 to 1."
				)
			if vMDDisplayHow == 1 then
				(
				Messagebox Message title:"uVAreaDisplayer"
				)
			else if vMDDisplayHow == 2 then
				(
				print Message
				)
			else if vMDDisplayHow == 3 then
				(
				pushPrompt Message
				)
			)
		)
	else (MessageBox "Please select some faces inside a Unwrap UVW modifier." title:"uVAreaDisplayer")
	)
	
fn uVAreaDisplayerDefaults = 
	(
	uVADLoadDef()
	uVAreaDisplayer uVADWarningValue vMDDisplayHowValue
	)
	
fn uVAreaDisplayerUI = 
	(
	uVADLoadDef()
	uVADCloseOpenUI uVADPosValue
	)

fn uVADCloseOpenUI pos = 
	(
	if uVADFloater != undefined then CloseRolloutFloater uVADFloater
	uVADDefineUI()
	uVADFloater = newRolloutFloater "uVAreaDisplayer v1.00" 310 111 pos.x pos.y
	addRollout uVADRollout uVADFloater
	)

fn uVADDo = 
	(
	uVAreaDisplayer uVADWarningValue vMDDisplayHowValue
	if uVADFloater != undefined then CloseRolloutFloater uVADFloater
	)

fn uVADApply = 
	(
	uVAreaDisplayer uVADWarningValue vMDDisplayHowValue
	)
	
fn uVADHelp = 
	(
	sLibSSPrintHelp "uVAreaDisplayer"
	)
	
fn uVADLoadDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	uVADInputFilename = presetDir + "uVAreaDisplayer.ini"
	if (sLibFileExist uVADInputFilename == true) then
		(
		uVADWarningValue = execute (getINISetting uVADInputFilename "uVAreaDisplayer" "uVADWarningValue")
		vMDDisplayHowValue = execute (getINISetting uVADInputFilename "uVAreaDisplayer" "vMDDisplayHowValue")
		uVADPosValue = execute (getINISetting uVADInputFilename "uVAreaDisplayer" "uVADPosValue")
		
		if uVADWarningValue == OK then uVADWarningValue = true
		if vMDDisplayHowValue == OK then vMDDisplayHowValue = 1
		if uVADPosValue == OK then uVADPosValue = [400,400]
		)
	else
		(
		uVADWarningValue = true
		vMDDisplayHowValue = 1
		uVADPosValue = [400,400]
		)
	)
	
fn uVADSaveDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	if (getDirectories presetDir).count == 0 then makeDir presetDir
	uVADOutputFilename = presetDir + "uVAreaDisplayer.ini"
	if (sLibFileExist uVADOutputFilename == true) then deleteFile uVADOutputFilename
	setINISetting uVADOutputFilename "uVAreaDisplayer" "uVADWarningValue" (uVADWarningValue as string)
	setINISetting uVADOutputFilename "uVAreaDisplayer" "vMDDisplayHowValue" (vMDDisplayHowValue as string)
	setINISetting uVADOutputFilename "uVAreaDisplayer" "uVADPosValue" (uVADFloater.pos as string)
	)

-- UI

fn uVADDefineUI = 
	(
	rollout uVADRollout "uVAreaDisplayer"
		(
		checkbox uVADWarningCheckbox "Give Warning If UVs Exist Outside of 0-1" checked:uVADWarningValue
		on uVADWarningCheckbox changed state do uVADWarningValue = state
		dropdownlist vMDDisplayHowDropdown "" items:#("Display In Message Box", "Display In Listener", "Display In Status Bar Prompt Line") selection:vMDDisplayHowValue width:200
		on vMDDisplayHowDropdown selected i do vMDDisplayHowValue = i

		button uVADDoButton "Do" width:70 toolTip:"Do It and Close UI" pos:[5,54]
		on uVADDoButton pressed do uVADDo()
		button uVADApplyButton "Apply" width:70 toolTip:"Do It and Keep UI Open" pos:[77,54]
		on uVADApplyButton pressed do uVADApply()
		button uVADHelpButton "Help" width:70 toolTip:"Help" pos:[149,54]
		on uVADHelpButton pressed do uVADHelp()
		button uVADSaveDefButton "SaveDef" width:70 toolTip:"Save Current Settings as Default" pos:[221,54]
		on uVADSaveDefButton pressed do uVADSaveDef()
		)
	)
)
-------------------------------------------------------------------------------