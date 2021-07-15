-------------------------------------------------------------------------------
-- subdivisionAutomator.ms
-- By Neil Blevins (info@neilblevins.com)
-- v 1.09
-- Created On: 01/15/08
-- Modified On: 11/11/16
-- tested using Max 2017
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Required Files:
-- sLib.ms
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Description:
-- Quickly assigns a subdiv modifier (meshsmooth, turbosmooth or opensubdiv) to 
-- all scene or selected objects. This is good if say you want to have all 
-- objects in your scene converted into subdivs at rendertime without the need 
-- to constantly select objects, find the right modifier, assign the modifier, 
-- etc. Has 4 modes, "Manual On" will add the subdiv modifier to all objects.
-- "Manual Off" will remove that modifier from all objects. "Auto Interactive 
-- Render On" will apply the subdiv modifier only at rendertime. And "Auto 
-- Interactive Render Off" will remove the rendertime function, so rendering 
-- will no longer apply the modifier.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Tutorial:
-- Add some scene objects. Run the script. Hit Do. Now render your scene. An 
-- Opensubdiv modifier will be applied to all of the scene objects, the render
-- will happen, then all of the opensubdiv modifiers will be removed, leaving
-- your scene as you started with.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Revision History:
--
-- v 1.01 Added automatic render modes. Fixed a number of bugs and added various
-- enhancements.
--
-- v 1.02 Moved the modifier remove code out into sLib.
--
-- v 1.03 Added feature to allow certain objects to be skipped from Auto Render
-- processing. This is useful if say you want to apply the subdiv to everything
-- in your scene except for 1 or 2 objects.
--
-- v 1.04 Replaced the Close button with a Help button. Use the X button to 
-- Close the Floater.
--
-- v 1.05 Now when performing the function on the scene, only affects visible 
-- objects. This speeds things up a lot for complex scenes. Also performs
-- some selection magic to speed up removing the modifier at the end of a render.
--
-- v 1.06 Added a new button to select all the scene objects with a skip tag.
-- Good for quickly seeing which objects in your scene will be skipped by
-- the script.
--
-- v 1.07 Fixed a bug that caused selection mode not to work.
--
-- v 1.08 Added OpenSubdiv Support.
--
-- v 1.09 Added UV boundry controls for Opensubdiv. Now will always place the 
-- subdiv modifier under the data modifier in the stack.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Known Issues:
-- The auto interactive render mode only works with regular renders, not 
-- netrenders. To do netrenders, use the manual mode.
--
-- If you try and apply this script to a spline that's being used as a path
-- deform control spline, the spline will not accept the subdiv modifier. 
-- However, if you delete the modifier, then run the script, the script will
-- not update that the spline can now be safely subdivided. You need to reload 
-- the scene to update the state of the spline. This is due to a maxscript bug
-- that needs to be fixed by Autodesk.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
(
-- Globals

global subdivisionAutomator
global subdivisionAutomatorDefaults
global subdivisionAutomatorUI

global sACloseOpenUI

global sAPrepObjects
global sAAdd
global SACallbackOn
global SACallbackOff
global SAApplySubdiv

global sAHelp
global sALoadDef
global sASaveDef

global sADefineUI
global sARollout
global sAFloater

-- Includes

include "$scripts\SoulburnScripts\lib\sLib.ms"

-- Variables

global validObjs = #()

global sAModeValue = 3
global sAModModeValue = 3
global sAObjsValue = 1
global sABelowDataValue = true
global sADisplayItersValue = 0
global sARenderItersValue = 2
global sAUVBoundValue = 4

sAPosValue = [400,400]

-- Functions

fn subdivisionAutomator sAMode sAModMode sAObjs sABelowData sADisplayIters sARenderIters sAUVBound = 
	(
	undo "subdivisionAutomator" on
		(
		disableSceneRedraw()
		try
			(
			-- save selected
			currentlySelected = #()
			if selection.count != 0 then currentlySelected = for k in selection collect k
			max select none
			
			sAPrepObjects sAObjs currentlySelected

			if sAMode == 1 then
				(
				sLibRemoveModifiersByName validObjs "subdivAuto"
				sAAdd validObjs sAModMode sABelowData sADisplayIters sARenderIters sAUVBound
				)
			else if sAMode == 2 then
				(
				sLibRemoveModifiersByName validObjs "subdivAuto"
				)
			else if sAMode == 3 then
				(
				sLibRemoveModifiersByName validObjs "subdivAuto"
				SACallbackOff()
				SACallbackOn()
				)
			else if sAMode == 4 then
				(
				SACallbackOff()
				)

			validObjs = #()
			-- reselect objects
			if currentlySelected.count == 0 then deselect selection
			else select currentlySelected
			)
		catch ()
		enableSceneRedraw()
		completeRedraw()		
		)
	)
	
fn subdivisionAutomatorDefaults = 
	(
	sALoadDef()
	subdivisionAutomator sAModeValue sAModModeValue sAObjsValue sABelowDataValue sADisplayItersValue sARenderItersValue sAUVBoundValue
	)

fn subdivisionAutomatorUI = 
	(
	sALoadDef()
	sACloseOpenUI sAPosValue
	)
	
fn sACloseOpenUI pos = 
	(
	if sAFloater != undefined then CloseRolloutFloater sAFloater
	sADefineUI()
	sAFloater = newRolloutFloater "subdivisionAutomator v1.09" 200 414 pos.x pos.y
	addRollout sARollout sAFloater
	)

fn sAPrepObjects sAObjs sACurrentlySelected = 
	(
	validObjs = #()
	if sAObjs == 1 then 
		(
		for obj in $* do if (SAApplySubdiv obj) == true and obj.isHidden == false then append validObjs obj
		)
	else if sAObjs == 2 then 
		(
		for obj in sACurrentlySelected do 
			(
			if (SAApplySubdiv obj) == true then append validObjs obj
			)
		)
	)

fn sAAdd validObjs sAModMode sABelowData sADisplayIters sARenderIters sAUVBound = 
	(
	for obj in ValidObjs do
		(
		if sAModMode == 1 then theMod = (execute "turbosmooth()")
		else if sAModMode == 2 then theMod = (execute "meshsmooth()")
		else theMod = (execute "OpenSubdiv()")
		
		-- data modifiers?
		dataposition = 0
		if sABelowData == true then
			(
			for j = 1 to obj.modifiers.count do
				(
				if (classof obj.modifiers[j]) == Data_Channel then dataposition = j
				)
			)
		
		addmodifier obj theMod before:dataposition
		obj.modifiers[dataposition+1].name = "subdivAuto"
		obj.modifiers[dataposition+1].iterations = sADisplayIters
		obj.modifiers[dataposition+1].useRenderIterations = on
		obj.modifiers[dataposition+1].renderIterations = sARenderIters
		if sAModMode == 3 then (obj.modifiers[dataposition+1].fvarboundary = (sAUVBound-1))
		)
	)
	
fn SACallbackOn = 
	(
	callbacks.addScript #preRender "subdivisionAutomator 1 sAModModeValue 1 sABelowDataValue sADisplayItersValue sARenderItersValue sAUVBoundValue" id:#subdivAutoOn
	callbacks.addScript #postRender "subdivisionAutomator 2 sAModModeValue 1 sABelowDataValue sADisplayItersValue sARenderItersValue sAUVBoundValue" id:#subdivAutoOff
	callbacks.addScript #filePostOpen "SACallbackOff()" id:#subdivAutoRemove1
	callbacks.addScript #systemPostNew "SACallbackOff()" id:#subdivAutoRemove2
	callbacks.addScript #systemPostReset "SACallbackOff()" id:#subdivAutoRemove3
	)
	
fn SACallbackOff = 
	(
	callbacks.removeScripts #preRender id:#subdivAutoOn
	callbacks.removeScripts #postRender id:#subdivAutoOff
	callbacks.removeScripts #filePostOpen id:#subdivAutoRemove1
	callbacks.removeScripts #systemPostNew id:#subdivAutoRemove2
	callbacks.removeScripts #systemPostReset id:#subdivAutoRemove3
	)
	
fn SAApplySubdiv obj =
	(
	subApply = true
	if validModifier obj (turbosmooth ()) then
		(
		if superclassof obj == shape then 
			(
			if obj.baseobject.renderable == true then
				(
				deform = false
				for i in (refs.dependents obj) do 
					(
					if (classof i) == SpacePathDeform or (classof i) == PathDeform then 
						(
						deform = true
						exit
						)
					)
				if deform == true then subApply = false
				)
			else subApply = false
			)
		if (getUserProp obj "SASkipTag") == true then subApply = false
		)
	else subApply = false
	return subApply
	)
	
fn sADo = 
	(
	subdivisionAutomator sAModeValue sAModModeValue sAObjsValue sABelowDataValue sADisplayItersValue sARenderItersValue sAUVBoundValue
	if sAFloater != undefined then CloseRolloutFloater sAFloater
	)

fn sAApply = 
	(
	subdivisionAutomator sAModeValue sAModModeValue sAObjsValue sABelowDataValue sADisplayItersValue sARenderItersValue sAUVBoundValue
	)
	
fn sAHelp = 
	(
	sLibSSPrintHelp "subdivisionAutomator"
	)
	
fn sALoadDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	sAInputFilename = presetDir + "subdivisionAutomator.ini"
	if (sLibFileExist sAInputFilename == true) then
		(
		sAModeValue = execute (getINISetting sAInputFilename "subdivisionAutomator" "sAModeValue")
		sAModModeValue = execute (getINISetting sAInputFilename "subdivisionAutomator" "sAModModeValue")
		sAObjsValue = execute (getINISetting sAInputFilename "subdivisionAutomator" "sAObjsValue")
		sABelowDataValue = execute (getINISetting sAInputFilename "subdivisionAutomator" "sABelowDataValue")
		sADisplayItersValue = execute (getINISetting sAInputFilename "subdivisionAutomator" "sADisplayItersValue")
		sARenderItersValue = execute (getINISetting sAInputFilename "subdivisionAutomator" "sARenderItersValue")
		sAUVBoundValue = execute (getINISetting sAInputFilename "subdivisionAutomator" "sAUVBoundValue")
		sAPosValue = execute (getINISetting sAInputFilename "subdivisionAutomator" "sAPosValue")
		
		if sAModeValue == OK then sAModeValue = 3
		if sAModModeValue == OK then sAModModeValue = 3
		if sAObjsValue == OK then sAObjsValue = 1
		if sABelowDataValue == OK then sABelowDataValue = true
		if sADisplayItersValue == OK then sADisplayItersValue = 0
		if sARenderItersValue == OK then sARenderItersValue = 2
		if sAUVBoundValue == OK then sAUVBoundValue = 4
		if sAPosValue == OK then sAPosValue = [400,400]
		)
	else
		(
		sAModeValue = 3
		sAModModeValue = 3
		sAObjsValue = 1
		sABelowDataValue = true
		sADisplayItersValue = 0
		sARenderItersValue = 2
		sAUVBoundValue = 4
		sAPosValue = [400,400]
		)
	)
	
fn sASaveDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	if (getDirectories presetDir).count == 0 then makeDir presetDir
	sAOutputFilename = presetDir + "subdivisionAutomator.ini"
	if (sLibFileExist sAOutputFilename == true) then deleteFile sAOutputFilename
	setINISetting sAOutputFilename "subdivisionAutomator" "sAModeValue" (sAModeValue as string)
	setINISetting sAOutputFilename "subdivisionAutomator" "sAModModeValue" (sAModModeValue as string)
	setINISetting sAOutputFilename "subdivisionAutomator" "sAObjsValue" (sAObjsValue as string)
	setINISetting sAOutputFilename "subdivisionAutomator" "sABelowDataValue" (sABelowDataValue as string)
	setINISetting sAOutputFilename "subdivisionAutomator" "sADisplayItersValue" (sADisplayItersValue as string)
	setINISetting sAOutputFilename "subdivisionAutomator" "sARenderItersValue" (sARenderItersValue as string)
	setINISetting sAOutputFilename "subdivisionAutomator" "sAUVBoundValue" (sAUVBoundValue as string)
	setINISetting sAOutputFilename "subdivisionAutomator" "sAPosValue" (sAFloater.pos as string)
	)

-- UI

fn sADefineUI = 
	(
	rollout sARollout "subdivisionAutomator"
		(
		Group "Control"
		(
		dropdownlist sAModeDropdown "" items:#("Manual On", "Manual Off", "Auto Interactive Render On", "Auto Interactive Render Off") selection:sAModeValue width:160 align:#center
		dropdownlist sAModModeDropdown "" items:#("Turbosmooth", "Meshsmooth", "OpenSubdiv") selection:sAModModeValue width:160 align:#center
		dropdownlist sAObjsDropdown "" items:#("Scene", "Selection") selection:sAObjsValue width:160 align:#center
		checkbox sABelowDataCheckbox "Place Below Data Mod" checked:sABelowDataValue
		)
		
		on sAModeDropdown selected i do 
			(
			sAModeValue = i
			if i == 3 or i == 4 then
				(
				sAObjsDropdown.selection = 1
				sAObjsValue = 1
				sAObjsDropdown.enabled = false
				)
			else sAObjsDropdown.enabled = true
			)
		on sAModModeDropdown selected i do sAModModeValue = i
		on sAObjsDropdown selected i do sAObjsValue = i
		on sABelowDataCheckbox changed state do sABelowDataValue = state
		
		Group "Parameters"
		(
		spinner sADisplayItersSpinner "Display Iters: " range:[0,20,sADisplayItersValue] fieldWidth:50 type:#integer
		spinner sARenderItersSpinner "Render Iters: " range:[0,20,sARenderItersValue] fieldWidth:50 type:#integer
		dropdownlist sAUVBoundDropdown "" items:#("UV Bilinear None", "UV Smooth Edge Only", "UV Smooth Edge & Corner", "UV Smooth Always Sharp") selection:sAUVBoundValue width:160 align:#center
		)

		on sADisplayItersSpinner changed val do sADisplayItersValue = val
		on sARenderItersSpinner changed val do sARenderItersValue = val
		on sAUVBoundDropdown selected i do sAUVBoundValue = i

		Group "Tools"
		(
		button sASkipButton "Add Skip Tag To Sel" width:150 align:#center toolTip:"Add Skip Tag To Selected Objects. This will apply a tag to the object so that the Auto Render mode will not process the object."
		button sASkipUndoButton "Delete Skip Tag From Sel" width:150 align:#center toolTip:"Delete Skip Tag From Selected Objects. The Auto Render mode will no longer ignore the object."
		button sASkipSelectButton "Select Objs With Skip Tag" width:150 align:#center toolTip:"Selects all scene objects that have a Skip Tag."
		)
		
		on sASkipButton pressed do 
			(
			for obj in selection do
				(
				setUserProp obj "SASkipTag" true
				)
			)
		on sASkipUndoButton pressed do 
			(
			for obj in selection do
				(
				setUserProp obj "SASkipTag" false
				)
			)
		on sASkipSelectButton pressed do 
			(
			a = #()
			for obj in $* do
				(
				if (getUserProp obj "SASkipTag") == true then append a obj
				)
			select a
			)

		button sADoButton "Do" width:70 toolTip:"Do It and Close UI" pos:[21,332]
		on sADoButton pressed do sADo()
		button sAApplyButton "Apply" width:70 toolTip:"Do It and Keep UI Open" pos:[93,332]
		on sAApplyButton pressed do sAApply()
		button sAHelpButton "Help" width:70 toolTip:"Help" pos:[21,358]
		on sAHelpButton pressed do sAHelp()
		button sASaveDefButton "SaveDef" width:70 toolTip:"Save Current Settings as Default" pos:[93,358]
		on sASaveDefButton pressed do sASaveDef()

		on sARollout open do
			(
			if sAModeValue == 3 or sAModeValue == 4 then
				(
				sAObjsDropdown.selection = 1
				sAObjsValue = 1
				sAObjsDropdown.enabled = false
				)
			else sAObjsDropdown.enabled = true
			)
		)
	)
)
-------------------------------------------------------------------------------