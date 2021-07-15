-------------------------------------------------------------------------------
-- snapShoter.ms
-- By Neil Blevins (info@neilblevins.com)
-- v 1.02
-- Created On: 09/09/14
-- Modified On: 07/21/18
-- tested using Max 2017
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Required Files:
-- sLib.ms
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Description:
-- Like the snapshot command, except turns your mesh to an editablePoly when
-- done, and a couple of other goodies, like selecting the newly created objects.
-- Only for unanimated objects, does not let you produce an object per frame
-- like the max tool.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Tutorial:
-- Select some Geometry. Run the UI version of the script. Hit Do. It will make a
-- snapshot of your mesh that it will collapse all object space modifiers present, 
-- but then convert to EditablePoly.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Revision History:
--
-- v 1.01 Added ability to delete the original objects, defaulted to off.
--
-- v 1.02 Newly create objects remain on the layer their original started on.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
(
-- Globals

global snapShoter
global snapShoterDefaults
global snapShoterUI

global sSHOCloseOpenUI

global sSHODo
global sSHOApply
global sSHOHelp
global sSHOLoadDef
global sSHOSaveDef

global sSHODefineUI
global sSHORollout
global sSHOFloater

-- Includes

include "$scripts\SoulburnScripts\lib\sLib.ms"

-- Variables

sSHOActionValue = 1
sSHODeleteOldGeomValue = false
sSHOPosValue = [400,400]

-- Functions

fn snapShoter sSHOAction sSHODeleteOldGeom = 
	(
	if (queryBox "Snapshot works best on objects who've had their xforms reset. If you see strange results after the snapshot, an xform reset before snapshoting may be in order. Snapshot Now?" title:"snapShoter") == true then 
		(
		newObjs = #()
		oldObjs = for obj in selection collect obj
		for i in oldObjs do
			(
			handles = #()
			theNewObj = undefined
			for w in $* do (append handles w.inode.handle)
			if handles.count == 0 then myMaxhandle = 0 else myMaxhandle = (amax handles)
			snapshot i
			for o in $* do
				(
				if o.inode.handle > myMaxhandle then theNewObj = o
				)
			if sSHOAction == 1 then (convertToPoly theNewObj)
			theNewObj.pivot = [(theNewObj.max.x+theNewObj.min.x)/2, (theNewObj.max.y+theNewObj.min.y)/2, (theNewObj.max.z+theNewObj.min.z)/2]
			append newObjs theNewObj
			sLibCopyAndPasteLayerFromNodeToNode i theNewObj
			)
		select newObjs
		if sSHODeleteOldGeom == true then delete oldObjs
		)
	)
	
fn snapShoterDefaults = 
	(
	sSHOLoadDef()
	snapShoter sSHOActionValue sSHODeleteOldGeomValue
	)
	
fn snapShoterUI = 
	(
	sSHOLoadDef()
	sSHOCloseOpenUI sSHOPosValue
	)

fn sSHOCloseOpenUI pos = 
	(
	if sSHOFloater != undefined then CloseRolloutFloater sSHOFloater
	sSHODefineUI()
	sSHOFloater = newRolloutFloater "snapShoter v1.02" 310 111 pos.x pos.y
	addRollout sSHORollout sSHOFloater
	)

fn sSHODo = 
	(
	snapShoter sSHOActionValue
	if sSHOFloater != undefined then CloseRolloutFloater sSHOFloater
	)

fn sSHOApply = 
	(
	snapShoter sSHOActionValue sSHODeleteOldGeomValue
	)
	
fn sSHOHelp = 
	(
	sLibSSPrintHelp "snapShoter"
	)
	
fn sSHOLoadDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	sSHOInputFilename = presetDir + "snapShoter.ini"
	if (sLibFileExist sSHOInputFilename == true) then
		(
		sSHOActionValue = execute (getINISetting sSHOInputFilename "snapShoter" "sSHOActionValue")
		sSHODeleteOldGeomValue = execute (getINISetting sSHOInputFilename "snapShoter" "sSHODeleteOldGeomValue")
		sSHOPosValue = execute (getINISetting sSHOInputFilename "snapShoter" "sSHOPosValue")
		
		if sSHOActionValue == OK then sSHOActionValue = 1
		if sSHODeleteOldGeomValue == OK then sSHODeleteOldGeomValue = false
		if sSHOPosValue == OK then sSHOPosValue = [400,400]
		)
	else
		(
		sSHOActionValue = 1
		sSHODeleteOldGeomValue = false
		sSHOPosValue = [400,400]
		)
	)
	
fn sSHOSaveDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	if (getDirectories presetDir).count == 0 then makeDir presetDir
	sSHOOutputFilename = presetDir + "snapShoter.ini"
	if (sLibFileExist sSHOOutputFilename == true) then deleteFile sSHOOutputFilename
	setINISetting sSHOOutputFilename "snapShoter" "sSHOActionValue" (sSHOActionValue as string)
	setINISetting sSHOOutputFilename "snapShoter" "sSHODeleteOldGeomValue" (sSHODeleteOldGeomValue as string)
	setINISetting sSHOOutputFilename "snapShoter" "sSHOPosValue" (sSHOFloater.pos as string)
	)

-- UI

fn sSHODefineUI = 
	(
	rollout sSHORollout "snapShoter"
		(
		label label1 "Convert To:" pos:[10,10]
		dropdownlist sSHOActionDropdown "" items:#("EditablePoly", "EditableMesh") selection:sSHOActionValue pos:[73,7] width:210
		checkbox sSHODeleteOldGeomCheckbox "Delete Original Geometry?" checked:sSHODeleteOldGeomValue
		
		on sSHOActionDropdown selected i do sSHOActionValue = i
		on sSHODeleteOldGeomCheckbox changed state do sSHODeleteOldGeomValue = state

		button sSHODoButton "Do" width:70 toolTip:"Do It and Close UI" pos:[5,54]
		on sSHODoButton pressed do sSHODo()
		button sSHOApplyButton "Apply" width:70 toolTip:"Do It and Keep UI Open" pos:[77,54]
		on sSHOApplyButton pressed do sSHOApply()
		button sSHOHelpButton "Help" width:70 toolTip:"Help" pos:[149,54]
		on sSHOHelpButton pressed do sSHOHelp()
		button sSHOSaveDefButton "SaveDef" width:70 toolTip:"Save Current Settings as Default" pos:[221,54]
		on sSHOSaveDefButton pressed do sSHOSaveDef()
		)
	)
)
-------------------------------------------------------------------------------