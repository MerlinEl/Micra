-------------------------------------------------------------------------------
-- nameManager.ms
-- By Neil Blevins (info@neilblevins.com)
-- v 1.14
-- Created On: 08/16/07
-- Modified On: 06/22/14
-- tested using Max 2014
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Required Files:
-- sLib.ms
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Description:
-- Lets you rename various things in your scene using a variety of functions.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Tutorial:
-- Select a bunch of objects. Run the UI version of the script. Set it to
-- "Rename + Append Number". Put the word "Rock" in the Base editbox. Hit Do.
-- All your objects will be named "Rock01", "Rock02", etc.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Revision History:
--
-- v 1.01 Added a append number pad. Added new mode Strip + Append Number. Added
-- a new Order mode. Currently, the objects will be renamed in the order they're
-- selected. If you change to alphabetical, it will first sort the selection 
-- alphabetically, then perform the rename. Good for keeping sequences of
-- objects numbered the same.
--
-- v 1.02 Switches away from modifier panel in order to operate faster.
--
-- v 1.03 Added Material And Map Support.
--
-- v 1.04 Added UpperCamelCase and lowerCamelCase.
--
-- v 1.05 Replaced the Close button with a Help button. Use the X button to 
-- Close the Floater.
--
-- v 1.06 Added several new modes, a mode to name objects based off material 
-- names, and a strip function and a uniquify name function. Also reordered
-- a number of functions, so please be careful when starting the script
-- that the function you've previously chosen hasn't changed to a new one
-- before executing it. You can also just go to your 
-- scripts\SoulburnScripts\presets directory and delete any file named
-- nameManager.ini, then you should be safe.
--
-- v 1.07 Added a new mode for renaming maps, not just bitmap maps.
--
-- v 1.08 Added a new mode for renaming all materials and submaterials on
-- selected objects.
--
-- v 1.09 Fixed a mistake in the pad value.
--
-- v 1.10 added ability to rename bitmaps themselves inside bitmap maps.
--
-- v 1.11 Added support for max2011's Slate Material Editor.
--
-- v 1.12 Added ability to pre-pend as well as append numbers.
--
-- v 1.13 Changed Padding to 3 to be in line with newer copies of max. Fixed a bug
-- where it wouldn't rename the object if it had no material assigned. Fixed an 
-- issue that could occur when applying a unique name to your objects.
--
-- v 1.14 Added support for vray bitmaps.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
(
-- Globals

global nameManager
global nameManagerDefaults
global nameManagerUI

global nMCloseOpenUI

global nMDo
global nMApply
global nMHelp
global nMLoadDef
global nMSaveDef

global nMDefineUI
global nMRollout1
global nMRollout2
global nMRollout3
global nMRollout4
global nMFloater

-- Includes

include "$scripts\SoulburnScripts\lib\sLib.ms"

-- Variables

nMPreValue = ""
nMBaseValue = ""
nMPostValue = ""
nMAppendStartValue = 1
nMAppendStepValue = 1
nMAppendPadValue = 3
nMAppendAutoPadValue = false
nMFindValue = ""
nMReplaceValue = ""
nMGroupMembersValue = true
nMFunctionValue = 2
nMItemsValue = 1
nMOrderValue = 1
nMMeditModeValue = 1
nMPosValue = [400,400]

-- Functions

fn nameManager nMPre nMBase nMPost nMAppendStart nMAppendStep nMAppendPad nMAppendAutoPad nMFind nMReplace nMGroupMembers nMFunction nMItems nMOrder nMMeditMode = 
	(
	undo "nameManager" on
		(
		if ((nMFunction == 12 or nMFunction == 13) and nMItems != 1) then (MessageBox "The Obj Name Based On Mat Name functions only work if you use All Selected Objects Mode" title:"nameManager")
		else
			(
			-- Switches away from the modify panel in order to operate faster
			if getCommandPanelTaskMode() == #modify then setCommandPanelTaskMode #create

			-- Setup Variables
			inc = 0
			items = #()
			itemsNames = #()
			newItemsNames = #()

			-- Prep items

			-- All Selected Objects
			if nMItems == 1 then
				(
				for i in selection do
					(
					if isgroupmember i == true and nMGroupMembers == true then continue
					else append items i
					)
				)
			-- All Scene Objects
			else if nMItems == 2 then
				(
				for i in $* do
					(
					if isgroupmember i == true and nMGroupMembers == true then continue
					else append items i
					)
				)
			-- All Medit Slots
			else if nMItems == 3 then
				(
				items = sLibGetMeditMaterials()
				)
			-- Materials On Selected Objects
			else if nMItems == 4 then
				(
				items = sLibGetMaterialsOnSelectedObjects()
				)
			-- Maps On Selected Objects
			else if nMItems == 5 then
				(
				items = sLibGetAllMapsFromSelectedObjects()
				)
			-- Bitmap Maps On Selected Objects
			else if nMItems == 6 then
				(
				allMaps = sLibGetAllMapsFromSelectedObjects()
				items = sLibGetBitmapsFromMaps allMaps
				)
			-- Sub Materials in Active Medit Slot
			else if nMItems == 7 then
				(
				if nMMeditMode == 2 then
					(
					if sLibMaxVer() < 13.0 then (MessageBox "Slate Medit Mode only works with Max 2011 and up, please change to mode to: Use Classic Mat Editor" title:"materialInfoDisplayer";mat = undefined)
					else (mat = sme.GetMtlInParamEditor())
					)
				else (mat = (medit.GetCurMtl()))
				items = sLibGetAllMaterials mat
				deleteItem items 1
				)
			-- Materials And Sub Mats On Sel Objects
			else if nMItems == 8 then
				(
				items = #()
				mats = sLibGetMaterialsOnSelectedObjects()
				for i in mats do
					(
					allmats = sLibGetAllMaterials i
					join items allmats
					)
				)
			-- Bitmaps On Selected Objects
			else if nMItems == 9 then
				(
				allMaps = sLibGetAllMapsFromSelectedObjects()
				items1 = sLibGetBitmapsFromMaps allMaps
				items2 = sLibGetVrayBitmapsFromMaps allMaps
				items = items1 + items2
				)
				
			if nMOrder == 2 then qsort items sLibNameCompareCaseInsensitive
			if nMItems <= 8 then 
				(
				for j in items do append itemsNames j.name
				)
			else if nMItems == 9 then 
				(
				for j in items do 
					(
					if classof j == Bitmaptexture then append itemsNames j.filename
					else if classof j == VRayHDRI then append itemsNames j.HDRIMapName
					)
				)

			-- Rename
			if items.count != 0 then
				(
				for i = 1 to itemsNames.count do
					(
					-- Rename
					if nMFunction == 1 then
						(
						if nMBase == "" then myName = nMPre + itemsNames[i] + nMPost
						else myName = nMPre + nMBase + nMPost
						finalName = myName
						append newItemsNames finalName
						)

					-- Rename + Append Number
					else if nMFunction == 2 then
						(
						-- Number
						digits = (((nMAppendStart+((nMAppendStep*items.count)-nMAppendStep)) as string).count)
						if nMAppendAutoPad == false then num = sLibPadValue (nMAppendStart + inc) nMAppendPad
						else num = sLibPadValue (nMAppendStart + inc) digits
						-- Text
						if nMBase == "" then myName = nMPre + itemsNames[i] + nMPost
						else myName = nMPre + nMBase + nMPost
						-- Rename
						inc += (1 * nMAppendStep)
						finalName = myName + num
						append newItemsNames finalName
						)

					-- Find + Replace
					else if nMFunction == 3 then
						(
						finalName = sLibFindAndReplaceInString itemsNames[i] nMFind nMReplace
						append newItemsNames finalName
						)

					-- Strip
					else if nMFunction == 4 then
						(
						-- Text
						myName = sLibRemoveTailNumbers itemsNames[i]
						-- Rename
						append newItemsNames myName
						)

					-- Strip + Append Number
					else if nMFunction == 5 then
						(
						-- Num
						digits = (((nMAppendStart+((nMAppendStep*items.count)-nMAppendStep)) as string).count)
						if nMAppendAutoPad == false then num = sLibPadValue (nMAppendStart + inc) nMAppendPad
						else num = sLibPadValue (nMAppendStart + inc) digits
						-- Text
						myName = sLibRemoveTailNumbers itemsNames[i]
						-- Rename
						inc += (1 * nMAppendStep)
						finalName = myName + num
						append newItemsNames finalName
						)

					-- UniqueName
					else if nMFunction == 6 then
						(
						append newItemsNames itemsNames[i]
						)				

					-- All Uppercase
					else if nMFunction == 7 then
						(
						finalName = (sLibMakeStringUppercase itemsNames[i])
						append newItemsNames finalName
						)

					-- All Lowercase
					else if nMFunction == 8 then
						(
						finalName = (sLibMakeStringLowercase itemsNames[i])
						append newItemsNames finalName
						)

					-- TitleCase
					else if nMFunction == 9 then
						(
						Myname1 = (sLibMakeStringLowercase itemsNames[i])
						Myname2 = (sLibMakeStringUppercase Myname1[1]) + (substring Myname1 2 Myname1.count)
						finalName = Myname2
						append newItemsNames finalName
						)

					-- UpperCamelCase
					else if nMFunction == 10 then
						(
						a = filterString itemsNames[i] "_ "
						finalName = ""
						for i in a do
							(
							word = (sLibMakeStringUppercase i[1]) + (substring i 2 i.count)
							append finalName word
							)
						append newItemsNames finalName
						)

					-- lowerCamelCase
					else if nMFunction == 11 then
						(
						a = filterString itemsNames[i] "_ "
						almostFinalName = ""
						for i in a do
							(
							word = (sLibMakeStringUppercase i[1]) + (substring i 2 i.count)
							append almostFinalName word
							)
						finalName = (sLibMakeStringLowercase almostFinalName[1]) + (substring almostFinalName 2 almostFinalName.count)
						append newItemsNames finalName
						)

					-- Obj Name Based On Material Name
					else if nMFunction == 12 then
						(
						if items[i].material != undefined then 
							(
							finalName = (items[i].material).name
							append newItemsNames finalName
							)
						else
							(
							finalName = "NoMaterial"
							append newItemsNames finalName							
							)
						)

					-- Unique Obj Name Based On Material Name
					else if nMFunction == 13 then
						(
						if items[i].material != undefined then 
							(
							finalName = (items[i].material).name
							append newItemsNames finalName
							)
						else
							(
							finalName = uniqueName "NoMaterial"
							append newItemsNames finalName							
							)
						)
						
					-- Rename + Prepend Number
					else if nMFunction == 14 then
						(
						-- Number
						digits = (((nMAppendStart+((nMAppendStep*items.count)-nMAppendStep)) as string).count)
						if nMAppendAutoPad == false then num = sLibPadValue (nMAppendStart + inc) nMAppendPad
						else num = sLibPadValue (nMAppendStart + inc) digits
						-- Text
						if nMBase == "" then myName = nMPre + itemsNames[i] + nMPost
						else myName = nMPre + nMBase + nMPost
						-- Rename
						inc += (1 * nMAppendStep)
						finalName = num + myName
						append newItemsNames finalName
						)
					)

				-- Apply to Items
				if nMFunction == 6 or nMFunction == 13 then 
					(
					if nMItems <= 8 then
						(
						for i = 1 to newItemsNames.count do items[i].name = uniqueName newItemsNames[i]
						)
					else if nMItems == 9 then
						(
						for i = 1 to newItemsNames.count do 
							(
							if classof items[i] == Bitmaptexture then items[i].filename = uniqueName newItemsNames[i]
							else if classof items[i] == VRayHDRI then items[i].HDRIMapName = uniqueName newItemsNames[i]
							)
						)
					)
				else
					(
					if nMItems <= 8 then
						(
						for i = 1 to newItemsNames.count do items[i].name = newItemsNames[i]
						)
					else if nMItems == 9 then
						(
						for i = 1 to newItemsNames.count do 
							(
							if classof items[i] == Bitmaptexture then items[i].filename = newItemsNames[i]
							else if classof items[i] == VRayHDRI then items[i].HDRIMapName = newItemsNames[i]
							)
						)					
					)
				)
			)
		)
	)
	
fn nameManagerDefaults = 
	(
	nMLoadDef()
	nameManager nMPreValue nMBaseValue nMPostValue nMAppendStartValue nMAppendStepValue nMAppendPadValue nMAppendAutoPadValue nMFindValue nMReplaceValue nMGroupMembersValue nMFunctionValue nMItemsValue nMOrderValue nMMeditModeValue
	)
	
fn nameManagerUI = 
	(
	nMLoadDef()
	nMCloseOpenUI nMPosValue
	)

fn nMCloseOpenUI pos = 
	(
	if nMFloater != undefined then CloseRolloutFloater nMFloater
	nMDefineUI()
	
	-- define floater length
	local floaterLength = 175
	if nMFunctionValue == 1 or nMFunctionValue == 2 or nMFunctionValue == 14 then floaterLength += 55
	if nMFunctionValue == 2 or nMFunctionValue == 5 or nMFunctionValue == 14 then floaterLength += 52
	if nMFunctionValue == 3 then floaterLength += 54
	
	-- create floater	
	nMFloater = newRolloutFloater "nameManager v1.14" 370 floaterLength pos.x pos.y
	
	-- add rollouts
	if nMFunctionValue == 1 or nMFunctionValue == 2 or nMFunctionValue == 14 then addRollout nMRollout1 nMFloater
	if nMFunctionValue == 2 or nMFunctionValue == 5 or nMFunctionValue == 14 then addRollout nMRollout2 nMFloater
	if nMFunctionValue == 3 then addRollout nMRollout3 nMFloater
	addRollout nMRollout4 nMFloater
	)

fn nMDo = 
	(
	nameManager nMPreValue nMBaseValue nMPostValue nMAppendStartValue nMAppendStepValue nMAppendPadValue nMAppendAutoPadValue nMFindValue nMReplaceValue nMGroupMembersValue nMFunctionValue nMItemsValue nMOrderValue nMMeditModeValue
	if nMFloater != undefined then CloseRolloutFloater nMFloater
	)

fn nMApply = 
	(
	nameManager nMPreValue nMBaseValue nMPostValue nMAppendStartValue nMAppendStepValue nMAppendPadValue nMAppendAutoPadValue nMFindValue nMReplaceValue nMGroupMembersValue nMFunctionValue nMItemsValue nMOrderValue nMMeditModeValue
	)
	
fn nMHelp = 
	(
	sLibSSPrintHelp "nameManager"
	)
	
fn nMLoadDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	nMInputFilename = presetDir + "nameManager.ini"
	if (sLibFileExist nMInputFilename == true) then
		(
		nMPreValue = getINISetting nMInputFilename "nameManager" "nMPreValue"
		nMBaseValue = getINISetting nMInputFilename "nameManager" "nMBaseValue"
		nMPostValue = getINISetting nMInputFilename "nameManager" "nMPostValue"
		nMAppendStartValue = execute (getINISetting nMInputFilename "nameManager" "nMAppendStartValue")
		nMAppendStepValue = execute (getINISetting nMInputFilename "nameManager" "nMAppendStepValue")
		nMAppendPadValue = execute (getINISetting nMInputFilename "nameManager" "nMAppendPadValue")
		nMAppendAutoPadValue = execute (getINISetting nMInputFilename "nameManager" "nMAppendAutoPadValue")
		nMFindValue = getINISetting nMInputFilename "nameManager" "nMFindValue"
		nMReplaceValue = getINISetting nMInputFilename "nameManager" "nMReplaceValue"
		nMGroupMembersValue = execute (getINISetting nMInputFilename "nameManager" "nMGroupMembersValue")
		nMFunctionValue = execute (getINISetting nMInputFilename "nameManager" "nMFunctionValue")
		nMItemsValue = execute (getINISetting nMInputFilename "nameManager" "nMItemsValue")
		nMOrderValue = execute (getINISetting nMInputFilename "nameManager" "nMOrderValue")
		nMMeditModeValue = execute (getINISetting nMInputFilename "nameManager" "nMMeditModeValue")
		nMPosValue = execute (getINISetting nMInputFilename "nameManager" "nMPosValue")
		
		if nMPreValue == OK then nMPreValue = ""
		if nMBaseValue == OK then nMBaseValue = ""
		if nMPostValue == OK then nMPostValue = ""
		if nMAppendStartValue == OK then nMAppendStartValue = 1
		if nMAppendStepValue == OK then nMAppendStepValue = 1
		if nMAppendPadValue == OK then nMAppendPadValue = 3
		if nMAppendAutoPadValue == OK then nMAppendAutoPadValue = 1
		if nMFindValue == OK then nMFindValue = ""
		if nMReplaceValue == OK then nMReplaceValue = ""
		if nMGroupMembersValue == OK then nMGroupMembersValue = true
		if nMFunctionValue == OK then nMFunctionValue = 2
		if nMItemsValue == OK then nMItemsValue = 1
		if nMOrderValue == OK then nMOrderValue = 1
		if nMMeditModeValue == OK then nMMeditModeValue = 1
		if nMPosValue == OK then nMPosValue = [400,400]
		)
	else
		(
		nMPreValue = ""
		nMBaseValue = ""
		nMPostValue = ""
		nMAppendStartValue = 1
		nMAppendStepValue = 1
		nMAppendPadValue = 3
		nMAppendAutoPadValue = false
		nMFindValue = ""
		nMReplaceValue = ""
		nMGroupMembersValue = true
		nMFunctionValue = 2
		nMItemsValue = 1
		nMOrderValue = 1
		nMMeditModeValue = 1
		nMPosValue = [400,400]
		)
	)
	
fn nMSaveDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	if (getDirectories presetDir).count == 0 then makeDir presetDir
	nMOutputFilename = presetDir + "nameManager.ini"
	if (sLibFileExist nMOutputFilename == true) then deleteFile nMOutputFilename
	setINISetting nMOutputFilename "nameManager" "nMPreValue" (nMPreValue as string)
	setINISetting nMOutputFilename "nameManager" "nMBaseValue" (nMBaseValue as string)
	setINISetting nMOutputFilename "nameManager" "nMPostValue" (nMPostValue as string)
	setINISetting nMOutputFilename "nameManager" "nMAppendStartValue" (nMAppendStartValue as string)
	setINISetting nMOutputFilename "nameManager" "nMAppendStepValue" (nMAppendStepValue as string)
	setINISetting nMOutputFilename "nameManager" "nMAppendPadValue" (nMAppendPadValue as string)
	setINISetting nMOutputFilename "nameManager" "nMAppendAutoPadValue" (nMAppendAutoPadValue as string)
	setINISetting nMOutputFilename "nameManager" "nMFindValue" (nMFindValue as string)
	setINISetting nMOutputFilename "nameManager" "nMReplaceValue" (nMReplaceValue as string)
	setINISetting nMOutputFilename "nameManager" "nMGroupMembersValue" (nMGroupMembersValue as string)
	setINISetting nMOutputFilename "nameManager" "nMFunctionValue" (nMFunctionValue as string)
	setINISetting nMOutputFilename "nameManager" "nMItemsValue" (nMItemsValue as string)
	setINISetting nMOutputFilename "nameManager" "nMOrderValue" (nMOrderValue as string)
	setINISetting nMOutputFilename "nameManager" "nMMeditModeValue" (nMMeditModeValue as string)
	setINISetting nMOutputFilename "nameManager" "nMPosValue" (nMFloater.pos as string)
	)

-- UI

fn nMDefineUI = 
	(
	rollout nMRollout1 "Rename"
		(
		edittext nMPreEditText "Pre:" fieldWidth:50 text:nMPreValue across:3
		edittext nMBaseEditText "Base:" fieldWidth:139 text:nMBaseValue offset:[-32,0] 
		edittext nMPostEditText "Post:" fieldWidth:50 text:nMPostValue offset:[33,0] 
		
		on nMPreEditText changed text do nMPreValue = nMPreEditText.text
		on nMBaseEditText changed text do nMBaseValue = nMBaseEditText.text
		on nMPostEditText changed text do nMPostValue = nMPostEditText.text
		)
		
	rollout nMRollout2 "Append / Prepend Number"
		(
		spinner nMAppendStartSpinner "Start: " range:[0,9999999,nMAppendStartValue] type:#integer fieldWidth:45 across:4 align:#center offset:[-5,0] 
		spinner nMAppendStepSpinner "Step: " range:[0,9999999,nMAppendStepValue] type:#integer fieldWidth:45 align:#center offset:[10,0] 
		spinner nMAppendPadSpinner "Pad: " range:[1,10,nMAppendPadValue] type:#integer fieldWidth:30 align:#center offset:[15,0] 
		checkbox nMAppendAutoPadCheckbox "AutoPad" checked:nMAppendAutoPadValue align:#center offset:[15,0] 
		
		on nMAppendStartSpinner changed val do nMAppendStartValue = val
		on nMAppendStepSpinner changed val do nMAppendStepValue = val
		on nMAppendPadSpinner changed val do nMAppendPadValue = val
		on nMAppendAutoPadCheckbox changed state do 
			(
			nMAppendAutoPadValue = state
			nMAppendPadSpinner.enabled = not state
			)
			
		on nMRollout2 open do
			(
			if nMAppendAutoPadValue == false then nMAppendPadSpinner.enabled = true
			else nMAppendPadSpinner.enabled = false
			)
		)
		
	rollout nMRollout3 "Find + Replace"
		(
		edittext nMFindEditText "Find:" fieldWidth:125 text:nMFindValue across:2
		edittext nMReplaceEditText "Replace:" fieldWidth:125 text:nMReplaceValue offset:[-5,0] 
	
		on nMFindEditText changed text do nMFindValue = nMFindEditText.text
		on nMReplaceEditText changed text do nMReplaceValue = nMReplaceEditText.text
		)
	
	rollout nMRollout4 "Tools"
		(
		Label label3 "Function:" across:4 align:#left offset:[-5,2]
		dropdownlist nMFunctionDropdown "" offset:[-37,0] items:#("Rename", "Rename + Append Number", "Find + Replace", "Strip", "Strip + Append Number", "Uniquify Name", "UPPERCASE", "lowercase", "Titlecase", "UpperCamelCase", "lowerCamelCase", "Obj Name Based On Mat Name", "Unique Obj Name Based On Mat Name", "Rename + Prepend Number") selection:nMFunctionValue width:180 height:20
		Label label1 "Members:" across:4 offset:[50,4]
		Label label2 "0" offset:[38,4] 

		Label label4 "Item:" across:3 align:#left offset:[-5,2]
		dropdownlist nMItemsDropdown "" items:#("All Selected Objects", "All Scene Objects", "All Medit Slots", "Materials On Sel Objects", "Maps On Sel Objects", "Bitmap Maps On Sel Objects", "Sub Mats in Active Medit Slot", "Materials And Sub Mats On Sel Objects", "Bitmaps On Selected Objects") selection:nMItemsValue width:180 offset:[-65,0] 
		button nMMemberRefreshButton "Refresh Members" width:98 toolTip:"Refresh Member Number" align:#right

		Label label5 "Order:" across:3 align:#left offset:[-5,2]
		dropdownlist nMOrderDropdown "" items:#("Original Order", "Alphebetical") selection:nMOrderValue width:120 offset:[-65,0]
		checkbox nMGroupMembersCheckbox "Don't Rename Grp Members" checked:nMGroupMembersValue offset:[-43,2] 

		Label label6 "Medit:" across:2 align:#left offset:[-5,2]
		dropdownlist nMMeditModeDropdown "" items:#("Use Classic Mat Editor", "Use Slate Mat Editor") selection:nMMeditModeValue width:150 offset:[-120,0]

		on nMFunctionDropdown selected i do 
			(
			nMFunctionValue = i
			curPos = nMFloater.pos
			nMCloseOpenUI curPos
			)
		on nMItemsDropdown selected i do
			(
			nMItemsValue = i
			curPos = nMFloater.pos
			nMCloseOpenUI curPos
			)
		on nMOrderDropdown selected i do nMOrderValue = i
		on nMMemberRefreshButton pressed do 
			(
			curPos = nMFloater.pos
			nMCloseOpenUI curPos
			)
		on nMGroupMembersCheckbox changed state do nMGroupMembersValue = state
		on nMMeditModeDropdown selected i do nMMeditModeValue = i
		
		button nMDoButton "Do" width:70 toolTip:"Do It and Close UI" pos:[35,119]
		on nMDoButton pressed do nMDo()
		button nMApplyButton "Apply" width:70 toolTip:"Do It and Keep UI Open" pos:[107,119]
		on nMApplyButton pressed do nMApply()
		button nMHelpButton "Help" width:70 toolTip:"Help" pos:[179,119]
		on nMHelpButton pressed do nMHelp()
		button nMSaveDefButton "SaveDef" width:70 toolTip:"Save Current Settings as Default" pos:[251,119]
		on nMSaveDefButton pressed do nMSaveDef()

		on nMRollout4 open do 
			(
			if nMItemsValue == 1 then label2.text = (selection.count as string)
			else if nMItemsValue == 1 then label2.text = ($*.count as string)
			else if nMItemsValue == 3 then label2.text = "24"
			else if nMItemsValue == 4 then label2.text = (sLibGetMaterialsOnSelectedObjects()).count as string
			else if nMItemsValue == 5 then 
				(
				allMaps = sLibGetAllMapsFromSelectedObjects()
				label2.text = allMaps.count as string
				)
			else if nMItemsValue == 6 or nMItemsValue == 9 then 
				(
				allMaps = sLibGetAllMapsFromSelectedObjects()
				items = sLibGetBitmapsFromMaps allMaps
				label2.text = items.count as string
				)
			else if nMItemsValue == 7 then 
				(
				if nMMeditModeValue == 2 then
					(
					if sLibMaxVer() < 13.0 then (MessageBox "Slate Medit Mode only works with Max 2011 and up, please change to mode to: Use Classic Mat Editor" title:"materialInfoDisplayer";mat = undefined)
					else (mat = sme.GetMtlInParamEditor())
					)
				else (mat = (medit.GetCurMtl()))
				if mat != undefined then label2.text = ((sLibGetAllMaterials mat).count - 1) as string
				else label2.text = "0"
				)
			else if nMItemsValue == 8 then 
				(
				items = #()
				mats = sLibGetMaterialsOnSelectedObjects()
				for i in mats do
					(
					allmats = sLibGetAllMaterials i
					join items allmats
					)
				label2.text = items.count as string
				)
			)
		)
	)
)
-------------------------------------------------------------------------------