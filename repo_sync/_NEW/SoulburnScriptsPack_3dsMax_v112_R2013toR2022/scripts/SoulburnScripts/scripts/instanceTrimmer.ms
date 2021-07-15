-------------------------------------------------------------------------------
-- instanceTrimmer.ms
-- By Neil Blevins (info@neilblevins.com)
-- v 1.00
-- Created On: 05/15/08
-- Modified On: 05/15/08
-- tested using Max 8.0
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Required Files:
-- sLib.ms
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Description:
-- Takes a selection and reduces the selection to include only a single
-- instance from each set of instances.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Tutorial:
-- Make a sphere and instance it once. Make a 3rd sphere, copy it once. Select 
-- all 4 spheres. Run the script in UI mode. Hit Do. Now your 3rd, 4th and either 
-- the 1st or 2nd sphere is selected.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
(
-- Globals

global instanceTrimmer
global instanceTrimmerDefaults
global instanceTrimmerUI

global iTCloseOpenUI

global iTDo
global iTApply
global iTHelp
global iTLoadDef
global iTSaveDef

global iTDefineUI
global iTRollout
global iTFloater

-- Includes

include "$scripts\SoulburnScripts\lib\sLib.ms"

-- Variables

iTIncludeNonInstanceValue = true
iTPosValue = [400,400]

-- Functions

fn instanceTrimmer iTIncludeNonInstance = 
	(
	undo "instanceTrimmer" on
		(
		if selection.count !=0 then
			(
			s = for i in selection collect i
			for obj in $ do 
				(
				if (finditem s obj) != 0 then
					(
					inst = (sLibGetInstancesOfObject obj)
					if inst.count == 0 then
						(
						if iTIncludeNonInstance == false then
							(
							objPos = (finditem s obj)
							deleteItem s objPos
							)
						)
					else
						(
						for i in inst do 
							(
							objPos = (finditem s i)
							if objPos != 0 then deleteItem s objPos
							)
						)
					)
				)
			if s.count !=0 then select s
			)
		)
	)
	
fn instanceTrimmerDefaults = 
	(
	iTLoadDef()
	instanceTrimmer iTIncludeNonInstanceValue
	)
	
fn instanceTrimmerUI = 
	(
	iTLoadDef()
	iTCloseOpenUI iTPosValue
	)

fn iTCloseOpenUI pos = 
	(
	if iTFloater != undefined then CloseRolloutFloater iTFloater
	iTDefineUI()
	iTFloater = newRolloutFloater "instanceTrimmer v1.00" 310 91 pos.x pos.y
	addRollout iTRollout iTFloater
	)

fn iTDo = 
	(
	instanceTrimmer iTIncludeNonInstanceValue
	if iTFloater != undefined then CloseRolloutFloater iTFloater
	)

fn iTApply = 
	(
	instanceTrimmer iTIncludeNonInstanceValue
	)
	
fn iTHelp = 
	(
	sLibSSPrintHelp "instanceTrimmer"
	)
	
fn iTLoadDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	iTInputFilename = presetDir + "instanceTrimmer.ini"
	if (sLibFileExist iTInputFilename == true) then
		(
		iTIncludeNonInstanceValue = execute (getINISetting iTInputFilename "instanceTrimmer" "iTIncludeNonInstanceValue")
		iTPosValue = execute (getINISetting iTInputFilename "instanceTrimmer" "iTPosValue")
		
		if iTIncludeNonInstanceValue == OK then iTIncludeNonInstanceValue = true
		if iTPosValue == OK then iTPosValue = [400,400]
		)
	else
		(
		iTIncludeNonInstanceValue = true
		iTPosValue = [400,400]
		)
	)
	
fn iTSaveDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	if (getDirectories presetDir).count == 0 then makeDir presetDir
	iTOutputFilename = presetDir + "instanceTrimmer.ini"
	if (sLibFileExist iTOutputFilename == true) then deleteFile iTOutputFilename
	setINISetting iTOutputFilename "instanceTrimmer" "iTIncludeNonInstanceValue" (iTIncludeNonInstanceValue as string)
	setINISetting iTOutputFilename "instanceTrimmer" "iTPosValue" (iTFloater.pos as string)
	)

-- UI

fn iTDefineUI = 
	(
	rollout iTRollout "instanceTrimmer"
		(
		checkbox iTIncludeNonInstanceCheckbox "Include Non Instanced Objects?" checked:iTIncludeNonInstanceValue
		on iTIncludeNonInstanceCheckbox changed state do iTIncludeNonInstanceValue = state

		button iTDoButton "Do" width:70 toolTip:"Do It and Close UI" pos:[5,34]
		on iTDoButton pressed do iTDo()
		button iTApplyButton "Apply" width:70 toolTip:"Do It and Keep UI Open" pos:[77,34]
		on iTApplyButton pressed do iTApply()
		button iTHelpButton "Help" width:70 toolTip:"Help" pos:[149,34]
		on iTHelpButton pressed do iTHelp()
		button iTSaveDefButton "SaveDef" width:70 toolTip:"Save Current Settings as Default" pos:[221,34]
		on iTSaveDefButton pressed do iTSaveDef()
		)
	)
)
-------------------------------------------------------------------------------