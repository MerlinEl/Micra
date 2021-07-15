-------------------------------------------------------------------------------
-- objectReplacer.ms
-- By Neil Blevins (info@neilblevins.com)
-- v 1.15
-- Created On: 01/05/06
-- Modified On: 08/06/18
-- tested using Max 2017
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Required Files:
-- sLib.ms
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Description:
-- Replaces a selection of objects with a new object, or randomly from a set of
-- objects.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Tutorial:
-- Run the UI version of the script. Select some objects you want replaced. 
-- Set the script to "Single Object" Replacer Type, click the "Pick The Obj To 
-- Replace With" button. Click the object you want the other objects to be 
-- replaced with. Now that object's name appears as your Single Object Replacer.
-- Hit "Do" and your selected objects will be replaced by that object. Choose 
-- "SelectionSet" instead of Single Object and choose a Selection set from the 
-- list (assuming you already have some selection sets in your scene), hit "Do" 
-- and your current selection will be randomly replaced by an object from your 
-- chosen Selection Set.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Revision History:
--
-- v 1.01 Added ability to retain the parent of the objects you're replacing.
--
-- v 1.02 Fixed a few issues that may stop objects from aligning properly.
--
-- v 1.03 Now if you select a group as your replacer, the script won't
-- wig out.
--
-- v 1.04 You can now copy the selectionsets and layers of your objects.
--
-- v 1.05 Fixed a bug I introduced last version that stopped the selection set
-- function from working.
--
-- v 1.06 Added a new mode to select multiple items.
--
-- v 1.07 Fixed a bug when trying to remove objects from a blank replacer list.
--
-- v 1.08 Replaced the Close button with a Help button. Use the X button to 
-- Close the Floater.
--
-- v 1.09 Now retains child info as well.
--
-- v 1.10 Now retains Display Properties.
--
-- v 1.11 Now the script won't crash if you are using max 2010's containers.
--
-- v 1.12 Now you can replace a group with a single object, just keep
-- "Treat Sel Groups as 1 Object?" checked.
--
-- v 1.13 Added ability to copy transform and visibility controllers. Use if 
-- the object you're replacing has an animated transform and you want to 
-- keep the animation.
--
-- v 1.14 Improved the copying capability of position Controllers to work
-- with more complex hierarchies.
--
-- v 1.15 Now you can keep your user properties as well when copying.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
(
-- Globals

global objectReplacer
global objectReplacerDefaults
global objectReplacerUI

global oRCloseOpenUI

global oRDo
global oRApply
global oRHelp
global oRLoadDef
global oRSaveDef

global oRDefineUI
global oRRollout
global oRFloater

-- Includes

include "$scripts\SoulburnScripts\lib\sLib.ms"

-- Variables

global oRSelectionSetNames = #()
global oRReplacerObject = undefined
global oRReplacerObjectsList = #()

oRReplacerTypeValue = 1
oRWhichSelectionSetValue = 1

oRKeepPositionValue = true
oRKeepRotationValue = true
oRKeepScaleValue = true
oRKeepTransValue = false
oRKeepVisValue = false
oRKeepNameValue = true
oRKeepMaterialValue = true
oRKeepWireColorValue = true
oRKeepParentValue = true
oRKeepChildrenValue = true
oRKeepSelectionSetsValue = true
oRKeepLayersValue = true
oRKeepDisplayPropsValue = true
oRKeepUserPropsValue = false

oRReplaceModeValue = 2
oRDeleteOriginalsValue = true
oRKeepGroupsAsOneValue = true

oRPosValue = [400,400]

-- Functions

fn objectReplacer oRReplacerType oRWhichSelectionSet oRKeepPosition oRKeepRotation oRKeepScale oRKeepTrans oRKeepVis oRKeepName oRKeepMaterial oRKeepWireColor oRKeepParent oRKeepChildren oRKeepSelectionSets oRKeepLayers oRKeepDisplayProps oRKeepUserProps oRReplaceMode oRDeleteOriginals oRKeepGroupsAsOne = 
	(
	undo "objectReplacer" on
		(
		oRReplacerObjects = #()
		if oRReplacerType == 1 then
			(
			if oRReplacerObject == undefined then 
				(
				MessageBox "Please pick a replacer" title:"objectReplacer"
				oRReplacerObjects = #()
				)
			else
				(
				if isdeleted oRReplacerObject == true then 
					(
					MessageBox "Your replacer object no longer seems to exist, please pick a new object" title:"objectReplacer"
					oRReplacerObjects = #()
					)
				else oRReplacerObjects = #(oRReplacerObject)
				)
			)
		else if oRReplacerType == 2 then
			(
			if oRSelectionSetNames.count == 0 then 
				(
				MessageBox "Please pick a valid selectionset" title:"objectReplacer"
				oRReplacerObjects = #()
				)
			else oRReplacerObjects = selectionSets[oRSelectionSetNames[oRWhichSelectionSet]]
			)
		else
			(
			if oRReplacerObjectsList.count == 0 then
				(
				MessageBox "Please add some objects to the Multiple Objects List" title:"objectReplacer"
				oRReplacerObjects = #()
				)
			else oRReplacerObjects = for i in oRReplacerObjectsList collect (getNodeByName i)
			)
			
		if oRReplacerObjects.count !=0 then
			(
			if selection.count == 0 then (MessageBox "Please select some objects to be replaced" title:"objectReplacer")
			else 
				(
				disableSceneRedraw()
				try
					(
					aToDelete = #()
					aToSelect = #()

					for i in selection do
						(
						if (isGroupMember i) == true and oRKeepGroupsAsOne == true then 
							(
							if oRDeleteOriginals == true then append aToDelete i
							continue
							)

						oRCurrentReplacerObject = oRReplacerObjects[random 1 oRReplacerObjects.count]
							
						-- If Replacer is a Group or Container
						if (isGroupHead oRCurrentReplacerObject) == true or classof oRCurrentReplacerObject == Container then 
							(
							if oRReplaceMode == 1 then maxops.clonenodes oRCurrentReplacerObject cloneType:#copy actualNodeList:&Origobj newNodes:&Newobj
							else if oRReplaceMode == 2 then maxops.clonenodes oRCurrentReplacerObject cloneType:#instance actualNodeList:&Origobj newNodes:&Newobj
							else if oRReplaceMode == 3 then maxops.clonenodes oRCurrentReplacerObject cloneType:#reference actualNodeList:&Origobj newNodes:&Newobj

							myindex = findItem Origobj oRCurrentReplacerObject
							obj = Newobj[myindex]

							if oRKeepTrans == true then
								(
								theparent = undefined
								if i.parent != undefined then 
									(
									theparent = i.parent
									i.parent = undefined
									)
								obj.transform.controller = copy i.transform.controller
								if theparent != undefined then i.parent = theparent
								)
							else 
								(
								if oRKeepRotation == true and oRKeepScale == true and oRKeepPosition == true then obj.transform = i.transform
								else 
									(
									if oRKeepScale == true then obj.scale.controller.value = i.scale.controller.value
									if oRKeepRotation == true then obj.rotation = i.rotation
									if oRKeepPosition == true then obj.pos = i.pos
									)
								)
							if oRKeepVis == true then 
								(
								obj.visibility = bezier_float() 
								obj.visibility.controller = copy i.visibility.controller
								)
							if oRKeepName == true then obj.name = i.name
							if oRKeepParent == true then obj.parent = i.parent
							if oRKeepChildren == true then for ch in i.children do (append obj.children ch)
							if oRKeepSelectionSets == true then sLibCopyAndPasteSelectionSetsFromNodeToNode i obj
							if oRKeepLayers == true then sLibCopyAndPasteLayerFromNodeToNode i obj
							)

						-- If Replacer is an Object
						else
							(
							if oRReplaceMode == 1 then obj = copy oRCurrentReplacerObject
							else if oRReplaceMode == 2 then obj = instance oRCurrentReplacerObject
							else if oRReplaceMode == 3 then obj = reference oRCurrentReplacerObject

							if oRKeepTrans == true then
								(
								theparent = undefined
								if i.parent != undefined then 
									(
									theparent = i.parent
									i.parent = undefined
									)
								obj.transform.controller = copy i.transform.controller
								if theparent != undefined then i.parent = theparent
								)
							else 
								(
								if oRKeepRotation == true and oRKeepScale == true and oRKeepPosition == true then obj.transform = i.transform
								else 
									(
									if oRKeepScale == true then obj.scale.controller.value = i.scale.controller.value
									if oRKeepRotation == true then obj.rotation = i.rotation
									if oRKeepPosition == true then obj.pos = i.pos
									)
								)
							if oRKeepVis == true then 
								(
								obj.visibility = bezier_float() 
								obj.visibility.controller = copy i.visibility.controller
								)
							if oRKeepName == true then obj.name = i.name
							if oRKeepMaterial == true then obj.material = i.material
							if oRKeepWireColor == true then obj.wirecolor = i.wirecolor
							if oRKeepParent == true then obj.parent = i.parent
							if oRKeepChildren == true then for ch in i.children do (append obj.children ch)
							if oRKeepSelectionSets == true then sLibCopyAndPasteSelectionSetsFromNodeToNode i obj
							if oRKeepLayers == true then sLibCopyAndPasteLayerFromNodeToNode i obj
							if oRKeepDisplayProps == true then
								(
								obj.xray = i.xray
								obj.boxMode = i.boxMode
								obj.backFaceCull = i.backFaceCull
								obj.allEdges = i.allEdges
								obj.vertexTicks = i.vertexTicks
								obj.showTrajectory = i.showTrajectory
								obj.ignoreExtents = i.ignoreExtents
								obj.showFrozenInGray = i.showFrozenInGray
								if sLibMaxVer() > 9.0 then obj.NeverDegrade = i.NeverDegrade
								obj.showVertexColors = i.showVertexColors
								obj.vertexColorType = i.vertexColorType
								obj.vertexColorsShaded = i.vertexColorsShaded
								obj.vertexColorMapChannel = i.vertexColorMapChannel
								)
							if oRKeepUserProps == true then
								(
								a = getUserPropBuffer i
								setUserPropBuffer obj a
								)
							else
								(
								a = getUserPropBuffer oRCurrentReplacerObject
								setUserPropBuffer obj a
								)
							)
						
						if oRDeleteOriginals == true then append aToDelete i
						append aToSelect obj
						)
		
					if aToDelete.count != 0 then delete aToDelete
					select aToSelect
					)
				catch ()
				enableSceneRedraw()
				redrawViews()
				)
			)
		)
	)

fn objectReplacerDefaults = 
	(
	oRLoadDef()
	objectReplacer oRReplacerTypeValue oRWhichSelectionSetValue oRKeepPositionValue oRKeepRotationValue oRKeepScaleValue oRKeepTransValue oRKeepVisValue oRKeepNameValue oRKeepMaterialValue oRKeepWireColorValue oRKeepParentValue oRKeepChildrenValue oRKeepSelectionSetsValue oRKeepLayersValue oRKeepDisplayPropsValue oRKeepUserPropsValue oRReplaceModeValue oRDeleteOriginalsValue oRKeepGroupsAsOneValue
	)
	
fn objectReplacerUI = 
	(
	oRLoadDef()
	oRCloseOpenUI oRPosValue
	)

fn oRCloseOpenUI pos = 
	(
	if oRFloater != undefined then CloseRolloutFloater oRFloater
	oRDefineUI()
	oRFloater = newRolloutFloater "objectReplacer v1.15" 200 829 pos.x pos.y
	addRollout oRRollout oRFloater
	)

fn oRDo = 
	(
	objectReplacer oRReplacerTypeValue oRWhichSelectionSetValue oRKeepPositionValue oRKeepRotationValue oRKeepScaleValue oRKeepTransValue oRKeepVisValue oRKeepNameValue oRKeepMaterialValue oRKeepWireColorValue oRKeepParentValue oRKeepChildrenValue oRKeepSelectionSetsValue oRKeepLayersValue oRKeepDisplayPropsValue oRKeepUserPropsValue oRReplaceModeValue oRDeleteOriginalsValue oRKeepGroupsAsOneValue
	if oRFloater != undefined then CloseRolloutFloater oRFloater
	)

fn oRApply = 
	(
	objectReplacer oRReplacerTypeValue oRWhichSelectionSetValue oRKeepPositionValue oRKeepRotationValue oRKeepScaleValue oRKeepTransValue oRKeepVisValue oRKeepNameValue oRKeepMaterialValue oRKeepWireColorValue oRKeepParentValue oRKeepChildrenValue oRKeepSelectionSetsValue oRKeepLayersValue oRKeepDisplayPropsValue oRKeepUserPropsValue oRReplaceModeValue oRDeleteOriginalsValue oRKeepGroupsAsOneValue
	)
	
fn oRHelp = 
	(
	sLibSSPrintHelp "objectReplacer"
	)
	
fn oRLoadDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	oRInputFilename = presetDir + "objectReplacer.ini"
	if (sLibFileExist oRInputFilename == true) then
		(
		oRReplacerTypeValue = execute (getINISetting oRInputFilename "objectReplacer" "oRReplacerTypeValue")
		oRWhichSelectionSetValue = execute (getINISetting oRInputFilename "objectReplacer" "oRWhichSelectionSetValue")
		oRKeepPositionValue = execute (getINISetting oRInputFilename "objectReplacer" "oRKeepPositionValue")
		oRKeepRotationValue = execute (getINISetting oRInputFilename "objectReplacer" "oRKeepRotationValue")
		oRKeepScaleValue = execute (getINISetting oRInputFilename "objectReplacer" "oRKeepScaleValue")
		oRKeepTransValue = execute (getINISetting oRInputFilename "objectReplacer" "oRKeepTransValue")
		oRKeepVisValue = execute (getINISetting oRInputFilename "objectReplacer" "oRKeepVisValue")
		oRKeepNameValue = execute (getINISetting oRInputFilename "objectReplacer" "oRKeepNameValue")
		oRKeepMaterialValue = execute (getINISetting oRInputFilename "objectReplacer" "oRKeepMaterialValue")
		oRKeepWireColorValue = execute (getINISetting oRInputFilename "objectReplacer" "oRKeepWireColorValue")
		oRKeepParentValue = execute (getINISetting oRInputFilename "objectReplacer" "oRKeepParentValue")
		oRKeepChildrenValue = execute (getINISetting oRInputFilename "objectReplacer" "oRKeepChildrenValue")
		oRKeepSelectionSetsValue = execute (getINISetting oRInputFilename "objectReplacer" "oRKeepSelectionSetsValue")
		oRKeepLayersValue = execute (getINISetting oRInputFilename "objectReplacer" "oRKeepLayersValue")
		oRKeepDisplayPropsValue = execute (getINISetting oRInputFilename "objectReplacer" "oRKeepDisplayPropsValue")
		oRKeepUserPropsValue = execute (getINISetting oRInputFilename "objectReplacer" "oRKeepUserPropsValue")
		oRReplaceModeValue = execute (getINISetting oRInputFilename "objectReplacer" "oRReplaceModeValue")
		oRDeleteOriginalsValue = execute (getINISetting oRInputFilename "objectReplacer" "oRDeleteOriginalsValue")
		oRKeepGroupsAsOneValue = execute (getINISetting oRInputFilename "objectReplacer" "oRKeepGroupsAsOneValue")
		oRPosValue = execute (getINISetting oRInputFilename "objectReplacer" "oRPosValue")
		
		if oRReplacerTypeValue == OK then oRReplacerTypeValue = 1
		if oRWhichSelectionSetValue == OK then oRWhichSelectionSetValue = 1
		if oRKeepPositionValue == OK then oRKeepPositionValue = true
		if oRKeepRotationValue == OK then oRKeepRotationValue = true
		if oRKeepScaleValue == OK then oRKeepScaleValue = true
		if oRKeepTransValue == OK then oRKeepTransValue = true
		if oRKeepVisValue == OK then oRKeepVisValue = true
		if oRKeepNameValue == OK then oRKeepNameValue = true
		if oRKeepMaterialValue == OK then oRKeepMaterialValue = true
		if oRKeepWireColorValue == OK then oRKeepWireColorValue = true
		if oRKeepParentValue == OK then oRKeepParentValue = true
		if oRKeepChildrenValue == OK then oRKeepChildrenValue = true
		if oRKeepSelectionSetsValue == OK then oRKeepSelectionSetsValue = true
		if oRKeepLayersValue == OK then oRKeepLayersValue = true
		if oRKeepDisplayPropsValue == OK then oRKeepDisplayPropsValue = true
		if oRKeepUserPropsValue == OK then oRKeepUserPropsValue = false
		if oRReplaceModeValue == OK then oRReplaceModeValue = 2
		if oRDeleteOriginalsValue == OK then oRDeleteOriginalsValue = true
		if oRKeepGroupsAsOneValue == OK then oRKeepGroupsAsOneValue = true
		if oRPosValue == OK then oRPosValue = [400,400]
		)
	else
		(
		oRReplacerTypeValue = 1
		oRWhichSelectionSetValue = 1
		oRKeepPositionValue = true
		oRKeepRotationValue = true
		oRKeepScaleValue = true
		oRKeepTransValue = false
		oRKeepVisValue = false
		oRKeepNameValue = true
		oRKeepMaterialValue = true
		oRKeepWireColorValue = true
		oRKeepParentValue = true
		oRKeepChildrenValue = true
		oRKeepSelectionSetsValue = true
		oRKeepLayersValue = true
		oRKeepDisplayPropsValue = true
		oRKeepUserPropsValue = false
		oRReplaceModeValue = 2
		oRDeleteOriginalsValue = true
		oRKeepGroupsAsOneValue = true
		oRPosValue = [400,400]
		)
	)
	
fn oRSaveDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	if (getDirectories presetDir).count == 0 then makeDir presetDir
	oROutputFilename = presetDir + "objectReplacer.ini"
	if (sLibFileExist oROutputFilename == true) then deleteFile oROutputFilename
	setINISetting oROutputFilename "objectReplacer" "oRReplacerTypeValue" (oRReplacerTypeValue as string)
	setINISetting oROutputFilename "objectReplacer" "oRWhichSelectionSetValue" (oRWhichSelectionSetValue as string)
	setINISetting oROutputFilename "objectReplacer" "oRKeepPositionValue" (oRKeepPositionValue as string)
	setINISetting oROutputFilename "objectReplacer" "oRKeepRotationValue" (oRKeepRotationValue as string)
	setINISetting oROutputFilename "objectReplacer" "oRKeepScaleValue" (oRKeepScaleValue as string)
	setINISetting oROutputFilename "objectReplacer" "oRKeepTransValue" (oRKeepTransValue as string)
	setINISetting oROutputFilename "objectReplacer" "oRKeepVisValue" (oRKeepVisValue as string)
	setINISetting oROutputFilename "objectReplacer" "oRKeepNameValue" (oRKeepNameValue as string)
	setINISetting oROutputFilename "objectReplacer" "oRKeepMaterialValue" (oRKeepMaterialValue as string)
	setINISetting oROutputFilename "objectReplacer" "oRKeepWireColorValue" (oRKeepWireColorValue as string)
	setINISetting oROutputFilename "objectReplacer" "oRKeepParentValue" (oRKeepParentValue as string)
	setINISetting oROutputFilename "objectReplacer" "oRKeepChildrenValue" (oRKeepChildrenValue as string)
	setINISetting oROutputFilename "objectReplacer" "oRKeepSelectionSetsValue" (oRKeepSelectionSetsValue as string)
	setINISetting oROutputFilename "objectReplacer" "oRKeepLayersValue" (oRKeepLayersValue as string)
	setINISetting oROutputFilename "objectReplacer" "oRKeepDisplayPropsValue" (oRKeepDisplayPropsValue as string)
	setINISetting oROutputFilename "objectReplacer" "oRKeepUserPropsValue" (oRKeepUserPropsValue as string)
	setINISetting oROutputFilename "objectReplacer" "oRReplaceModeValue" (oRReplaceModeValue as string)
	setINISetting oROutputFilename "objectReplacer" "oRDeleteOriginalsValue" (oRDeleteOriginalsValue as string)
	setINISetting oROutputFilename "objectReplacer" "oRKeepGroupsAsOneValue" (oRKeepGroupsAsOneValue as string)
	setINISetting oROutputFilename "objectReplacer" "oRPosValue" (oRFloater.pos as string)
	)

-- UI

fn oRDefineUI = 
	(
	oRSelectionSetNames = sLibGetSceneSelectionSetsNames()
	sort oRSelectionSetNames

	rollout oRRollout "objectReplacer"
		(
		group "Replacer Type:"
		(
		dropdownlist oRReplacerType "" items:#("Single Object", "SelectionSet", "Multiple Objects") selection:oRReplacerTypeValue
		)
		on oRReplacerType selected i do 
			(
			oRReplacerTypeValue = i
			curPos = oRFloater.pos
			oRCloseOpenUI curPos
			)

		group "Single Object:"
		(
		label oRObjectLabel "None" align:#center
		pickbutton oRPickObject "Pick The Obj To Replace With" width:164 toolTip:"Pick The Object To Replace With" align:#center
		)
		on oRPickObject picked obj do 
			(
			oRReplacerObject = obj
			oRObjectLabel.text = obj.name
			)
		
		group "Selection Set:"
		(
		dropdownlist oRWhichSelectionSetDropdown "" items:oRSelectionSetNames enabled:false selection:1
		)
		on oRWhichSelectionSetDropdown selected i do oRWhichSelectionSetValue = i

		group "Multiple Objects:"
		(
		button oRAddReplacerObjectsButton "Add Sel To Replacer List" toolTip:"Add Selection To Replacer List" width:142 align:#left across:2
		button oRAddReplacerObjectsDelButton "-" toolTip:"Delete Choosen Object From Replacer List" width:15 align:#right
		listbox oRReplacerObjectsListbox "Replacer Object List:" items:oRReplacerObjectsList height:5
		)
		on oRAddReplacerObjectsButton pressed do 
			(
			oRReplacerObjectsList = #()
			for i in selection do append oRReplacerObjectsList i.name
			curPos = oRFloater.pos
			oRCloseOpenUI curPos
			)
		on oRAddReplacerObjectsDelButton pressed do 
			(
			if oRReplacerObjectsList.count != 0 then 
				(
				deleteItem oRReplacerObjectsList oRReplacerObjectsListbox.selection
				curPos = oRFloater.pos
				oRCloseOpenUI curPos
				)
			)

		group "Selection Attributes To Keep"
		(
		checkbox oRKeepPositionCheckbox "Position?" checked:oRKeepPositionValue
		checkbox oRKeepRotationCheckbox "Rotation?" checked:oRKeepRotationValue
		checkbox oRKeepScaleCheckbox "Scale?" checked:oRKeepScaleValue
		checkbox oRKeepNameCheckbox "Name?" checked:oRKeepNameValue
		checkbox oRKeepMaterialCheckbox "Material?" checked:oRKeepMaterialValue
		checkbox oRKeepWireColorCheckbox "Wire Color?" checked:oRKeepWireColorValue
		checkbox oRKeepParentCheckbox "Parent?" checked:oRKeepParentValue
		checkbox oRKeepChildrenCheckbox "Children?" checked:oRKeepChildrenValue
		checkbox oRKeepSelectionSetsCheckbox "Selection Sets?" checked:oRKeepSelectionSetsValue
		checkbox oRKeepLayersCheckbox "Layer?" checked:oRKeepLayersValue
		checkbox oRKeepDisplayPropsCheckbox "Display Properties?" checked:oRKeepDisplayPropsValue
		checkbox oRKeepUserPropsCheckbox "User Properties?" checked:oRKeepUserPropsValue
		)

		on oRKeepPositionCheckbox changed state do oRKeepPositionValue = state
		on oRKeepRotationCheckbox changed state do oRKeepRotationValue = state
		on oRKeepScaleCheckbox changed state do oRKeepScaleValue = state
		on oRKeepNameCheckbox changed state do oRKeepNameValue = state
		on oRKeepMaterialCheckbox changed state do oRKeepMaterialValue = state
		on oRKeepWireColorCheckbox changed state do oRKeepWireColorValue = state
		on oRKeepParentCheckbox changed state do oRKeepParentValue = state
		on oRKeepChildrenCheckbox changed state do oRKeepChildrenValue = state
		on oRKeepSelectionSetsCheckbox changed state do oRKeepSelectionSetsValue = state
		on oRKeepLayersCheckbox changed state do oRKeepLayersValue = state
		on oRKeepDisplayPropsCheckbox changed state do oRKeepDisplayPropsValue = state
		on oRKeepUserPropsCheckbox changed state do oRKeepUserPropsValue = state

		group "Selection Controllers To Keep"
		(
		checkbox oRKeepTransCheckbox "Transform Controller" checked:oRKeepTransValue
		checkbox oRKeepVisCheckbox "Visibility Controller" checked:oRKeepVisValue
		)

		on oRKeepTransCheckbox changed state do 
			(
			oRKeepTransValue = state
			curPos = oRFloater.pos
			oRCloseOpenUI curPos
			)
		on oRKeepVisCheckbox changed state do oRKeepVisValue = state

		group "Options"
		(
		dropdownlist oRReplaceModeDropdown "" items:#("Copy", "Instance", "Reference") selection:oRReplaceModeValue
		checkbox oRDeleteOriginalsCheckbox "Delete Originals?" checked:oRDeleteOriginalsValue
		checkbox oRKeepGroupsAsOneCheckbox "Treat Sel Groups as 1 Object?" checked:oRKeepGroupsAsOneValue
		)
		on oRReplaceModeDropdown selected i do oRReplaceModeValue = i
		on oRDeleteOriginalsCheckbox changed state do oRDeleteOriginalsValue = state
		on oRKeepGroupsAsOneCheckbox changed state do oRKeepGroupsAsOneValue = state

		button oRDoButton "Do" width:70 toolTip:"Do It and Close UI" pos:[23,747]
		on oRDoButton pressed do oRDo()
		button oRApplyButton "Apply" width:70 toolTip:"Do It and Keep UI Open" pos:[95,747]
		on oRApplyButton pressed do oRApply()
		button oRHelpButton "Help" width:70 toolTip:"Help" pos:[23,771]
		on oRHelpButton pressed do oRHelp()
		button oRSaveDefButton "SaveDef" width:70 toolTip:"Save Current Settings as Default" pos:[95,771]
		on oRSaveDefButton pressed do oRSaveDef()
		
		on oRRollout open do
			(
			if oRReplacerObject != undefined then oRObjectLabel.text = oRReplacerObject.name
			if oRReplacerTypeValue == 1 then 
				(
				oRObjectLabel.enabled = true
				oRPickObject.enabled = true
				oRWhichSelectionSetDropdown.enabled = false
				oRAddReplacerObjectsButton.enabled = false
				oRAddReplacerObjectsDelButton.enabled = false
				oRReplacerObjectsListbox.enabled = false
				)
			else if oRReplacerTypeValue == 2 then 
				(
				oRObjectLabel.enabled = false
				oRPickObject.enabled = false
				oRWhichSelectionSetDropdown.enabled = true
				oRAddReplacerObjectsButton.enabled = false
				oRAddReplacerObjectsDelButton.enabled = false
				oRReplacerObjectsListbox.enabled = false
				)
			else if oRReplacerTypeValue == 3 then 
				(
				oRObjectLabel.enabled = false
				oRPickObject.enabled = false
				oRWhichSelectionSetDropdown.enabled = false
				oRAddReplacerObjectsButton.enabled = true
				oRAddReplacerObjectsDelButton.enabled = true
				oRReplacerObjectsListbox.enabled = true
				)
			if oRKeepTransValue == true then
				(
				oRKeepPositionCheckbox.enabled = false
				oRKeepRotationCheckbox.enabled = false
				oRKeepScaleCheckbox.enabled = false
				)
			)
		)
	)
)
-------------------------------------------------------------------------------