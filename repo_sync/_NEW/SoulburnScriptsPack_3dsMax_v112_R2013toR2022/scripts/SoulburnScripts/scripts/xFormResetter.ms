-------------------------------------------------------------------------------
-- xFormResetter.ms
-- By Neil Blevins (info@neilblevins.com)
-- v 1.02
-- Created On: 02/23/15
-- Modified On: 11/05/15
-- tested using Max 2016
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Required Files:
-- sLib.ms
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Description:
-- Like the Reset Xform utility, but with a number of improvements. 
-- 1) Works on hierarchies without messing up the transformation.
-- 2) Automatically flips the normals of any object with negative scales.
-- 3) Can either turn instances to copies or references (like the Utility does)
-- 4) Can Collapse Mesh To Poly after reset
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Tutorial:
-- Select any objects or hierarchy (like for example a hard surface character),
-- run the script, hit do. Now all of the xforms of the objects will be properly
-- reset without affecting the hierarchy and with the normals facing the 
-- correct direction.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Revision History:
--
-- v 1.01 Added ability to collapse splines properly.
--
-- v 1.02 Temporarily removed the option to "Convert Instances To References"
-- until a nasty bug gets resolved. Now names the normal flip modifier something 
-- meaningful.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
(
-- Globals

global xFormResetter
global xFormResetterDefaults
global xFormResetterUI

global xFRCloseOpenUI

global xFRDo
global xFRApply
global xFRHelp
global xFRLoadDef
global xFRSaveDef

global xFRDefineUI
global xFRRollout
global xFRFloater

-- Includes

include "$scripts\SoulburnScripts\lib\sLib.ms"

-- Variables

xFRCollapseValue = false
xFRCopyOrRefValue = 1
xFRPosValue = [400,400]

-- Functions

fn xFormResetter xFRCollapse xFRCopyOrRef = 
	(
	undo "xFormResetter" on
		(
		if selection.count != 0 then
			(
			allObjects = #()
			rigarray = #()
			error = false

			-- Check if groups
			for obj in selection do
				(
				if isgroupmember obj == false and isgrouphead obj == false then
					(
					append allObjects obj
					)
				else error = true
				)
			if error == true then MessageBox "At least one object in your selection is a group and cannot be affected by this script. Please ungroup the objects." title:"xFormResetter"
			else
				(		
				--record hierarchy
				for obj in allObjects do
					(
					par = obj.parent
					kids = obj.children
					append rigarray #(obj, par, kids)
					)

				--dispose of hierarchy
				for obj in allObjects do
					(
					kids = obj.children
					obj.parent = undefined
					for i in kids do
						(
						i.parent = undefined
						)			
					)		

				if xFRCopyOrRef == 2 then
					(
					-- Convert To Reference
					a = #()
					for obj in allObjects do
						(
						if (sLibGetInstancesOfObject obj).count != 0 then append a obj
						)
					while a.count !=0 do
						(
						b = (sLibGetInstancesOfObject a[1]) + a[1]
						sLibConvertsInstancesToReferences b
						a = sLibRemoveItemsFromArray a b				
						)
					)
				else
					(
					-- Uninstance
					for obj in allObjects do 
						(
						if (InstanceMgr.CanMakeObjectsUnique obj) == true then InstanceMgr.MakeObjectsUnique obj #individual
						)
					)

				-- Reset Xform
				for obj in allObjects do 
					(
					flipme = false
					
					-- Reset				
					if obj.scale.x < 0 or obj.scale.y < 0 or obj.scale.z < 0 then flipme = true
					sLibResetXForm obj
					if flipme == true then 
						(
						local normalMod = Normalmodifier()
						addmodifier obj normalMod
						normalMod.name = ("xFR_NormalFlip")
						normalMod.flip = on
						)
					if xFRCollapse == true then 
						(
						if ((canConvertTo obj SplineShape) == true) and (obj.baseobject.DisplayRenderMesh != true) then 
							(
							convertTo obj SplineShape
							)
						else 
							(
							convertTo obj PolyMeshObject
							)
						)
					)

				-- Pur Hierarchy Back
				for i in rigarray do
					(
					i[1].parent = i[2]
					for w in i[3] do
						(
						w.parent = i[1]
						)	
					)
				)
			)
		)
	)
	
fn xFormResetterDefaults = 
	(
	xFRLoadDef()
	xFormResetter xFRCollapseValue xFRCopyOrRefValue
	)
	
fn xFormResetterUI = 
	(
	xFRLoadDef()
	xFRCloseOpenUI xFRPosValue
	)

fn xFRCloseOpenUI pos = 
	(
	if xFRFloater != undefined then CloseRolloutFloater xFRFloater
	xFRDefineUI()
	xFRFloater = newRolloutFloater "xFormResetter v1.02" 310 111 pos.x pos.y
	addRollout xFRRollout xFRFloater
	)

fn xFRDo = 
	(
	xFormResetter xFRCollapseValue xFRCopyOrRefValue
	if xFRFloater != undefined then CloseRolloutFloater xFRFloater
	)

fn xFRApply = 
	(
	xFormResetter xFRCollapseValue xFRCopyOrRefValue
	)
	
fn xFRHelp = 
	(
	sLibSSPrintHelp "xFormResetter"
	)
	
fn xFRLoadDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	xFRInputFilename = presetDir + "xFormResetter.ini"
	if (sLibFileExist xFRInputFilename == true) then
		(
		xFRCollapseValue = execute (getINISetting xFRInputFilename "xFormResetter" "xFRCollapseValue")
		xFRCopyOrRefValue = execute (getINISetting xFRInputFilename "xFormResetter" "xFRCopyOrRefValue")
		xFRPosValue = execute (getINISetting xFRInputFilename "xFormResetter" "xFRPosValue")
		
		if xFRCollapseValue == OK then xFRCollapseValue = false
		if xFRCopyOrRefValue == OK then xFRCopyOrRefValue = 1
		if xFRPosValue == OK then xFRPosValue = [400,400]
		)
	else
		(
		xFRCollapseValue = false
		xFRCopyOrRefValue = 1
		xFRPosValue = [400,400]
		)
	)
	
fn xFRSaveDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	if (getDirectories presetDir).count == 0 then makeDir presetDir
	xFROutputFilename = presetDir + "xFormResetter.ini"
	if (sLibFileExist xFROutputFilename == true) then deleteFile xFROutputFilename
	setINISetting xFROutputFilename "xFormResetter" "xFRCollapseValue" (xFRCollapseValue as string)
	setINISetting xFROutputFilename "xFormResetter" "xFRCopyOrRefValue" (xFRCopyOrRefValue as string)
	setINISetting xFROutputFilename "xFormResetter" "xFRPosValue" (xFRFloater.pos as string)
	)

-- UI

fn xFRDefineUI = 
	(
	rollout xFRRollout "xFormResetter"
		(
		dropdownlist xFRCopyOrRefDropdown "" items:#("De-instance Instances (Make Unique)", "Convert Instances To References") selection:xFRCopyOrRefValue width:220 enabled:false
		checkbox xFRCollapseCheckbox "Collapse Stack After Reset?" checked:xFRCollapseValue
		
		on xFRCopyOrRefDropdown selected i do xFRCopyOrRefValue = i
		on xFRCollapseCheckbox changed state do xFRCollapseValue = state

		button xFRDoButton "Do" width:70 toolTip:"Do It and Close UI" pos:[5,54]
		on xFRDoButton pressed do xFRDo()
		button xFRApplyButton "Apply" width:70 toolTip:"Do It and Keep UI Open" pos:[77,54]
		on xFRApplyButton pressed do xFRApply()
		button xFRHelpButton "Help" width:70 toolTip:"Help" pos:[149,54]
		on xFRHelpButton pressed do xFRHelp()
		button xFRSaveDefButton "SaveDef" width:70 toolTip:"Save Current Settings as Default" pos:[221,54]
		on xFRSaveDefButton pressed do xFRSaveDef()
		)
	)
)
-------------------------------------------------------------------------------