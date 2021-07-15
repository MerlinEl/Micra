-------------------------------------------------------------------------------
-- layerCleaner.ms
-- By Neil Blevins (info@neilblevins.com)
-- v 1.01
-- Created On: 03/07/15
-- Modified On: 08/22/16
-- tested using Max 2017
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Required Files:
-- sLib.ms
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Description:
-- Deletes all empty layers from your scene.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Tutorial:
-- Open a file that contains empty layers. Run the UI version of the script. 
-- Hit Do. All empty layers are now gone.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Revision History:
--
-- v 1.01 Fixed a bug where it would not work in max2017 or higher.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
(
-- Globals

global layerCleaner
global layerCleanerDefaults
global layerCleanerUI

global lCCloseOpenUI

global lCRemoveEmptyLayers

global lCDo
global lCApply
global lCHelp
global lCLoadDef
global lCSaveDef

global lCDefineUI
global lCRollout
global lCFloater

-- Includes

include "$scripts\SoulburnScripts\lib\sLib.ms"

-- Variables

lCShowWarningValue = false
lCPosValue = [400,400]

-- Functions

fn layerCleaner lCShowWarning = 
	(
	undo "layerCleaner" on
		(
		if sLibMaxVer() < 18.0 then (MessageBox "This script only works in Max 2016 and above." title:"layerCleaner")
		else
			(
			if lCShowWarning == true then
				(
				if (queryBox "Delete All Empty Layers?" title:"layerCleaner") == true then 
					(
					lCRemoveEmptyLayers()
					)
				)
			else 
				(
				lCRemoveEmptyLayers()
				)
			)
		)
	)

fn layerCleanerDefaults = 
	(
	lCLoadDef()
	layerCleaner lCShowWarningValue
	)
	
fn layerCleanerUI = 
	(
	lCLoadDef()
	lCCloseOpenUI lCPosValue
	)

fn lCCloseOpenUI pos = 
	(
	if lCFloater != undefined then CloseRolloutFloater lCFloater
	lCDefineUI()
	lCFloater = newRolloutFloater "layerCleaner v1.01" 310 215 pos.x pos.y
	addRollout lCRollout lCFloater
	)
	
fn lCRemoveEmptyLayers =
    	(
    	-- adapted from code from Larry Minton
        local i = 0
        while i < layermanager.count do
    		(
        	local layer = layermanager.getLayer i
        	if not layermanager.doesLayerHierarchyContainNodes layer.name then
    			(
                	if sLibMaxVer() <= 18.0 then
                		(
                		if not layermanager.deleteLayerHierarchy layer.name forceDelete:true do i += 1
                		)
                	else 
                		(
                		if (layermanager.deleteLayerHierarchy layer.name forceDelete:true) == 0 then i += 1
                		)
    	        	)
            	else
    			(
    			i += 1
    			)
        	)
    	)
	
fn lCDo = 
	(
	layerCleaner lCShowWarningValue
	if lCFloater != undefined then CloseRolloutFloater lCFloater
	)

fn lCApply = 
	(
	layerCleaner lCShowWarningValue
	)
	
fn lCHelp = 
	(
	sLibSSPrintHelp "layerCleaner"
	)
	
fn lCLoadDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	lCInputFilename = presetDir + "layerCleaner.ini"
	if (sLibFileExist lCInputFilename == true) then
		(
		lCShowWarningValue = execute (getINISetting lCInputFilename "layerCleaner" "lCShowWarningValue")
		lCPosValue = execute (getINISetting lCInputFilename "layerCleaner" "lCPosValue")
		
		if lCShowWarningValue == OK then lCShowWarningValue = false
		if lCPosValue == OK then lCPosValue = [400,400]
		)
	else
		(
		lCShowWarningValue = false
		lCPosValue = [400,400]
		)
	)
	
fn lCSaveDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	if (getDirectories presetDir).count == 0 then makeDir presetDir
	lCOutputFilename = presetDir + "layerCleaner.ini"
	if (sLibFileExist lCOutputFilename == true) then deleteFile lCOutputFilename
	setINISetting lCOutputFilename "layerCleaner" "lCShowWarningValue" (lCShowWarningValue as string)
	setINISetting lCOutputFilename "layerCleaner" "lCPosValue" (lCFloater.pos as string)
	)

-- UI

fn lCDefineUI = 
	(
	rollout lCRollout "layerCleaner"
		(
		checkbox lCShowWarningCheckbox "Show Warning?" checked:lCShowWarningValue align:#left
		on lCShowWarningCheckbox changed state do lCShowWarningValue = state

		button lCDoButton "Do" width:70 toolTip:"Do It and Close UI" pos:[5,58]
		on lCDoButton pressed do lCDo()
		button lCApplyButton "Apply" width:70 toolTip:"Do It and Keep UI Open" pos:[77,58]
		on lCApplyButton pressed do lCApply()
		button lCHelpButton "Help" width:70 toolTip:"Help" pos:[149,58]
		on lCHelpButton pressed do lCHelp()
		button lCSaveDefButton "SaveDef" width:70 toolTip:"Save Current Settings as Default" pos:[221,58]
		on lCSaveDefButton pressed do lCSaveDef()
		)
	)
)
-------------------------------------------------------------------------------