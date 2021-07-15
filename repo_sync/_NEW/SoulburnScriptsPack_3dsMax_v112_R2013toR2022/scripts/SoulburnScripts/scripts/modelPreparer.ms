-------------------------------------------------------------------------------
-- modelPreparer.ms
-- By Neil Blevins (info@neilblevins.com)
-- v 1.13
-- Created On: 10/19/15
-- Modified On: 10/15/19
-- tested using Max 2017
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Required Files:
-- sLib.ms
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Description:
-- Sets up your model to have materials applied to it from the Soulburn 
-- MaterialAssetPacks using SAL.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Tutorial:
-- Select a number of objects. Run the UI version of the script. Hit Do. it
-- will perform all of the setup operations you have checkmarked in the
-- script.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Revision History:
--
-- v 1.01 Added high and low values to the curvature feature because this is a 
-- value users may want to adjust on a more frequent basis. Decreasing the low 
-- and increasing the high will capture more edges on a more subtly curved 
-- surface.
--
-- v 1.10 You can now render your projections with max's BlendedBoxMap map.
--
-- v 1.11 Now turns concave areas black when creating curvature.
--
-- v 1.12 Updated GroupWithPoint function to fix crash bug.
--
-- v 1.13 Newer versions of vray no longer compatible with Standard Materials,
-- so now it uses vray materials if vray is selected as your renderer.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
(
-- Globals

global modelPreparer
global modelPreparerDefaults
global modelPreparerUI

global mPRECloseOpenUI

global mPREDo
global mPREApply
global mPREHelp
global mPRELoadDef
global mPRESaveDef

global mPREDefineUI
global mPRERollout
global mPREFloater

-- Includes

include "$scripts\SoulburnScripts\lib\sLib.ms"
include "$scripts\\SoulburnScripts\\scripts\\iDSetter.ms"
include "$scripts\\SoulburnScripts\\scripts\\xFormResetter.ms"
include "$scripts\\SoulburnScripts\\scripts\\groupWithPoint.ms"
include "$scripts\\SoulburnScripts\\scripts\\curvatureMaker.ms"
include "$scripts\\SoulburnScripts\\scripts\\blendedCubeProjectionMaker.ms"
include "$scripts\\SoulburnScripts\\scripts\\cameraMapTemplateRenderer.ms"

-- Variables

mPREConvertBaseValue = true
mPREiDSetValue = true
mPRExFormSetValue = true
mPRExFormSetCollapseValue = false
mPRELinkHelperValue = true
mPRECurveSetValue = true
mPRECurveTypeValue = 2
mPRECurveLowValue = 265
mPRECurveHighValue = 275
mPRECurveScaleValue = 10.0
mPREBCPValue = true
mPREBCPTypeValue = 2
mPREBCPSizeValue = 1024
mPREBCPLightValue = true
mPREBCPShadowsValue = true
mPREBCPDirValue = "D:\\"
mPREPosValue = [400,400]

-- Functions

fn modelPreparer mPREConvertBase mPREiDSet mPRExFormSet mPRExFormSetCollapse mPRELinkHelper mPRECurveSet mPRECurveType mPRECurveLow mPRECurveHigh mPRECurveScale mPREBCP mPREBCPType mPREBCPSize mPREBCPLight mPREBCPShadows mPREBCPDir = 
	(
	allgeom = #()
	for i in selection do (if superclassof i == GeometryClass then append allgeom i)
	select allgeom

	g = undefined
	bc = undefined
	
	if mPREConvertBase == true then
		(
		cb = sLibRemoveUnneededInstancesFromArray allgeom
		for i in cb do sLibConvertBaseObjectToPoly i
		)
	if mPREiDSet == true then
		(
		iDSetter 1 "ColorID" 3 1 1 10 "1,3,4,5" false
		)
	if mPRExFormSet == true then
		(
		xFormResetter mPRExFormSetCollapse 1
		)
	if mPRELinkHelper == true then
		(
		g = groupWithPoint 1 1 true 150 false 2 1
		)
	if mPRECurveSet == true then
		(
		if mPRECurveType == 1 then mymode = 1 else mymode = 2
		curvatureMaker true (color 255 255 255) true (color 0 0 0) true mPRECurveLow mPRECurveHigh (color 0 0 0) true 85 95 (color 0 0 0) false mymode mPRECurveScale 66
		)
	if mPREBCP == true then
		(
		select allgeom
		if mPREBCPType == 1 then
			(
			bc = bCPMDoMappingFunction undefined false 1 true 1 "" "" "" "" "" "" 1 1 5 8 6 9 7 10 false "" true 100 2.0
			if mPREBCPDir == undefined or mPREBCPDir == "" then (MessageBox "Please select a path to save rendered files" title:"modelPreparer")
			else
				(
				select bc[1]
				cMTROnWhatValue = #()
				for c in selection do (if superclassof c == camera then append cMTROnWhatValue c)
				cMTRPrepRender 1 mPREBCPSize mPREBCPSize 100 true true false mPREBCPDir
				if g != undefined then bc[2].parent = g[1]
				select allgeom
				)
			)
		else if mPREBCPType == 2 then
			(
			if (classof BlendedBoxMap) == UndefinedClass then (MessageBox "Only works in max 2017 Ext 1 and above." title:"modelPreparer")
			else
				(
				-- Make Material
				inputmap = bCPMDoMapFunction true 3 true 3 "" "" "" "" "" "" 4 1 5 8 6 9 7 10 false "" true 100 2.0
				if sLibWhatsCurrentRenderer() == "vray" then
					(
					newMaterial = VRayMtl()
					newMaterial.texmap_diffuse = inputmap
					)
				else
					(
					newMaterial = Standard()
					newMaterial.specularlevel = 0
					newMaterial.Glossiness = 0
					newMaterial.useSelfIllumColor = off
					newMaterial.selfIllumAmount = 0
					newMaterial.Ambient = color 0 0 0
					newMaterial.diffuse = color 128 128 128
					newMaterial.specular = color 0 0 0
					newMaterial.diffuseMap = inputmap
					)
								
				for i in allgeom do i.material = newMaterial
				result = bCPMDoMappingFunction inputmap true 3 true 3 "" "" "" "" "" "" 4 1 5 8 6 9 7 10 false "" true 100 2.0
				
				if g != undefined then result[2].parent = g[1]
				newMaterial.diffuseMap.renderResolution = mPREBCPSize
				cMTROnWhatValue = newMaterial.diffuseMap
				cMTRPrepRender 3 mPREBCPSize mPREBCPSize 100 false false false mPREBCPDir
				outname = mPREBCPDir + "cMTR.tif"
				cMTROnWhatValue.SetBaseFilename outname
				cMTROnWhatValue.renderResolution = mPREBCPSize
				)
			)
		)
	MessageBox "The model has been prepared." title:"modelPreparer"
	)
	
fn modelPreparerDefaults = 
	(
	mPRELoadDef()
	modelPreparer mPREConvertBaseValue mPREiDSetValue mPRExFormSetValue mPRExFormSetCollapseValue mPRELinkHelperValue mPRECurveSetValue mPRECurveTypeValue mPRECurveLowValue mPRECurveHighValue mPRECurveScaleValue mPREBCPValue mPREBCPTypeValue mPREBCPSizeValue mPREBCPLightValue mPREBCPShadowsValue mPREBCPDirValue
	)
	
fn modelPreparerUI = 
	(
	mPRELoadDef()
	mPRECloseOpenUI mPREPosValue
	)

fn mPRECloseOpenUI pos = 
	(
	if mPREFloater != undefined then CloseRolloutFloater mPREFloater
	mPREDefineUI()
	mPREFloater = newRolloutFloater "modelPreparer v1.13" 310 508 pos.x pos.y
	addRollout mPRERollout mPREFloater
	)

fn mPREDo = 
	(
	modelPreparer mPREConvertBaseValue mPREiDSetValue mPRExFormSetValue mPRExFormSetCollapseValue mPRELinkHelperValue mPRECurveSetValue mPRECurveTypeValue mPRECurveLowValue mPRECurveHighValue mPRECurveScaleValue mPREBCPValue mPREBCPTypeValue mPREBCPSizeValue mPREBCPLightValue mPREBCPShadowsValue mPREBCPDirValue
	if mPREFloater != undefined then CloseRolloutFloater mPREFloater
	)

fn mPREApply = 
	(
	modelPreparer mPREConvertBaseValue mPREiDSetValue mPRExFormSetValue mPRExFormSetCollapseValue mPRELinkHelperValue mPRECurveSetValue mPRECurveTypeValue mPRECurveLowValue mPRECurveHighValue mPRECurveScaleValue mPREBCPValue mPREBCPTypeValue mPREBCPSizeValue mPREBCPLightValue mPREBCPShadowsValue mPREBCPDirValue
	)
	
fn mPREHelp = 
	(
	sLibSSPrintHelp "modelPreparer"
	)
	
fn mPRELoadDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	mPREInputFilename = presetDir + "modelPreparer.ini"
	if (sLibFileExist mPREInputFilename == true) then
		(
		mPREConvertBaseValue = execute (getINISetting mPREInputFilename "modelPreparer" "mPREConvertBaseValue")
		mPREiDSetValue = execute (getINISetting mPREInputFilename "modelPreparer" "mPREiDSetValue")
		mPRExFormSetValue = execute (getINISetting mPREInputFilename "modelPreparer" "mPRExFormSetValue")
		mPRExFormSetCollapseValue = execute (getINISetting mPREInputFilename "modelPreparer" "mPRExFormSetCollapseValue")
		mPRELinkHelperValue = execute (getINISetting mPREInputFilename "modelPreparer" "mPRELinkHelperValue")
		mPRECurveSetValue = execute (getINISetting mPREInputFilename "modelPreparer" "mPRECurveSetValue")
		mPRECurveTypeValue = execute (getINISetting mPREInputFilename "modelPreparer" "mPRECurveTypeValue")
		mPRECurveLowValue = execute (getINISetting mPREInputFilename "modelPreparer" "mPRECurveLowValue")
		mPRECurveHighValue = execute (getINISetting mPREInputFilename "modelPreparer" "mPRECurveHighValue")
		mPRECurveScaleValue = execute (getINISetting mPREInputFilename "modelPreparer" "mPRECurveScaleValue")
		mPREBCPValue = execute (getINISetting mPREInputFilename "modelPreparer" "mPREBCPValue")
		mPREBCPTypeValue = execute (getINISetting mPREInputFilename "modelPreparer" "mPREBCPTypeValue")
		mPREBCPSizeValue = execute (getINISetting mPREInputFilename "modelPreparer" "mPREBCPSizeValue")
		mPREBCPLightValue = execute (getINISetting mPREInputFilename "modelPreparer" "mPREBCPLightValue")
		mPREBCPShadowsValue = execute (getINISetting mPREInputFilename "modelPreparer" "mPREBCPShadowsValue")
		mPREBCPDirValue = getINISetting mPREInputFilename "modelPreparer" "mPREBCPDirValue"
		mPREPosValue = execute (getINISetting mPREInputFilename "modelPreparer" "mPREPosValue")
		
		if mPREConvertBaseValue == OK then mPREConvertBaseValue = true
		if mPREiDSetValue == OK then mPREiDSetValue = true
		if mPRExFormSetValue == OK then mPRExFormSetValue = true
		if mPRExFormSetCollapseValue == OK then mPRExFormSetCollapseValue = false
		if mPRELinkHelperValue == OK then mPRELinkHelperValue = true
		if mPRECurveSetValue == OK then mPRECurveSetValue = true
		if mPRECurveTypeValue == OK then mPRECurveTypeValue = 2
		if mPRECurveLowValue == OK then mPRECurveLowValue = 265
		if mPRECurveHighValue == OK then mPRECurveHighValue = 275
		if mPRECurveScaleValue == OK then mPRECurveScaleValue = 10.0
		if mPREBCPValue == OK then mPREBCPValue = true
		if mPREBCPTypeValue == OK then mPREBCPTypeValue = 2
		if mPREBCPSizeValue == OK then mPREBCPSizeValue = 1024
		if mPREBCPLightValue == OK then mPREBCPLightValue = true
		if mPREBCPShadowsValue == OK then mPREBCPShadowsValue = true
		if mPREBCPDirValue == OK then mPREBCPDirValue = "D:\\"
		if mPREPosValue == OK then mPREPosValue = [400,400]
		)
	else
		(
		mPREConvertBaseValue = true
		mPREiDSetValue = true
		mPRExFormSetValue = true
		mPRExFormSetCollapseValue = false
		mPRELinkHelperValue = true
		mPRECurveSetValue = true
		mPRECurveTypeValue = 2
		mPRECurveLowValue = 265
		mPRECurveHighValue = 275
		mPRECurveScaleValue = 10.0
		mPREBCPValue = true
		mPREBCPTypeValue = 2
		mPREBCPSizeValue = 1024
		mPREBCPLightValue = true
		mPREBCPShadowsValue = true
		mPREBCPDirValue = "D:\\"
		mPREPosValue = [400,400]
		)
	)
	
fn mPRESaveDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	if (getDirectories presetDir).count == 0 then makeDir presetDir
	mPREOutputFilename = presetDir + "modelPreparer.ini"
	if (sLibFileExist mPREOutputFilename == true) then deleteFile mPREOutputFilename
	setINISetting mPREOutputFilename "modelPreparer" "mPREConvertBaseValue" (mPREConvertBaseValue as string)
	setINISetting mPREOutputFilename "modelPreparer" "mPREiDSetValue" (mPREiDSetValue as string)
	setINISetting mPREOutputFilename "modelPreparer" "mPRExFormSetValue" (mPRExFormSetValue as string)
	setINISetting mPREOutputFilename "modelPreparer" "mPRExFormSetCollapseValue" (mPRExFormSetCollapseValue as string)
	setINISetting mPREOutputFilename "modelPreparer" "mPRELinkHelperValue" (mPRELinkHelperValue as string)
	setINISetting mPREOutputFilename "modelPreparer" "mPRECurveSetValue" (mPRECurveSetValue as string)
	setINISetting mPREOutputFilename "modelPreparer" "mPRECurveTypeValue" (mPRECurveTypeValue as string)
	setINISetting mPREOutputFilename "modelPreparer" "mPRECurveLowValue" (mPRECurveLowValue as string)
	setINISetting mPREOutputFilename "modelPreparer" "mPRECurveHighValue" (mPRECurveHighValue as string)
	setINISetting mPREOutputFilename "modelPreparer" "mPRECurveScaleValue" (mPRECurveScaleValue as string)
	setINISetting mPREOutputFilename "modelPreparer" "mPREBCPValue" (mPREBCPValue as string)
	setINISetting mPREOutputFilename "modelPreparer" "mPREBCPTypeValue" (mPREBCPTypeValue as string)
	setINISetting mPREOutputFilename "modelPreparer" "mPREBCPSizeValue" (mPREBCPSizeValue as string)
	setINISetting mPREOutputFilename "modelPreparer" "mPREBCPLightValue" (mPREBCPLightValue as string)
	setINISetting mPREOutputFilename "modelPreparer" "mPREBCPShadowsValue" (mPREBCPShadowsValue as string)
	setINISetting mPREOutputFilename "modelPreparer" "mPREBCPDirValue" (mPREBCPDirValue as string)
	setINISetting mPREOutputFilename "modelPreparer" "mPREPosValue" (mPREFloater.pos as string)
	)

-- UI

fn mPREDefineUI = 
	(
	rollout mPRERollout "modelPreparer"
		(
		group ""
		(
		checkbox mPREConvertBaseCheckbox "Convert Base Objects To Poly?" checked:mPREConvertBaseValue
		)
		on mPREConvertBaseCheckbox changed state do mPREConvertBaseValue = state

		group ""
		(		
		checkbox mPREiDSetCheckbox "Set All Mat IDs to 1?" checked:mPREiDSetValue
		)
		on mPREiDSetCheckbox changed state do mPREiDSetValue = state

		group ""
		(
		checkbox mPRExFormSetCheckbox "Reset Xform?" checked:mPRExFormSetValue
		checkbox mPRExFormSetCollapseCheckbox "Collapse Stack After Reset?" checked:mPRExFormSetCollapseValue offset:[18,0]
		)
		
		on mPRExFormSetCheckbox changed state do 
			(
			mPRExFormSetValue = state
			mPRExFormSetCollapseCheckbox.enabled = state
			)
		on mPRExFormSetCollapseCheckbox changed state do mPRExFormSetCollapseValue = state

		group ""
		(		
		checkbox mPRELinkHelperCheckbox "Link Selected Models To Point Helper?" checked:mPRELinkHelperValue
		)
		on mPRELinkHelperCheckbox changed state do mPRELinkHelperValue = state
		
		group ""
		(
		checkbox mPRECurveSetCheckbox "Bake Curavture?" checked:mPRECurveSetValue
		dropdownlist mPRECurveTypeDropdown "" items:#("Corner Edge To Vertex Map", "Data Channel") selection:mPRECurveTypeValue width:200 align:#left offset:[18,0]
		spinner mPRECurveLowSpinner "Low Angle: " range:[0,360,mPRECurveLowValue] fieldWidth:55 type:#float align:#left offset:[18,0] enabled:mPRECurveSetValue
		spinner mPRECurveHighSpinner "High Angle: " range:[0,360,mPRECurveHighValue] fieldWidth:55 type:#float align:#left offset:[18,0] enabled:mPRECurveSetValue
		spinner mPRECurveScaleSpinner "Scale Value: " range:[0.0,100.0,mPRECurveScaleValue] fieldWidth:55 type:#float align:#left offset:[18,0] enabled:mPRECurveSetValue
		)
		on mPRECurveSetCheckbox changed state do 
			(
			mPRECurveSetValue = state
			mPRECurveTypeDropdown.enabled = state
			if mPRECurveTypeValue == 1 then
				(
				mPRECurveLowSpinner.enabled = state
				mPRECurveHighSpinner.enabled = state
				mPRECurveScaleSpinner.enabled = false
				)
			else
				(
				mPRECurveLowSpinner.enabled = false
				mPRECurveHighSpinner.enabled = false
				mPRECurveScaleSpinner.enabled = state
				)
			)
		on mPRECurveTypeDropdown selected i do 
			(
			mPRECurveTypeValue = i
			if mPRECurveTypeValue == 1 then
				(
				mPRECurveLowSpinner.enabled = mPRECurveSetValue
				mPRECurveHighSpinner.enabled = mPRECurveSetValue
				mPRECurveScaleSpinner.enabled = false				
				)
			else
				(
				mPRECurveLowSpinner.enabled = false
				mPRECurveHighSpinner.enabled = false
				mPRECurveScaleSpinner.enabled = mPRECurveSetValue
				)			
			)
		on mPRECurveLowSpinner changed val do mPRECurveLowValue = val
		on mPRECurveHighSpinner changed val do mPRECurveHighValue = val
		on mPRECurveScaleSpinner changed val do mPRECurveScaleValue = val

		group ""
		(
		checkbox mPREBCPCheckbox "Prep For Blended Cube Projection?" checked:mPREBCPValue
		dropdownlist mPREBCPTypeDropdown "" items:#("UVW Mapping Method", "Max's BlendedBoxMap") selection:mPREBCPTypeValue width:200 align:#left offset:[18,0]
		spinner mPREBCPSizeSpinner "Width: " range:[1,99999,mPREBCPSizeValue] fieldWidth:50 type:#integer align:#left offset:[18,0] enabled:mPREBCPValue
		--checkbox mPREBCPLightCheckbox "Temporary Dome Light?" checked:mPREBCPLightValue offset:[18,0] enabled:mPREBCPValue
		--checkbox mPREBCPShadowsCheckbox "Shadows?" checked:mPREBCPShadowsValue offset:[18,0] enabled:mPREBCPValue
		edittext mPREBCPDirEditText "" fieldWidth:230 text:mPREBCPDirValue align:#left across:2 offset:[12,0] enabled:mPREBCPValue
		button mPREBCPDirButton "F" width:20 toolTip:"Choose Path" align:#right offset:[0,-2] enabled:mPREBCPValue
		)
		
		on mPREBCPCheckbox changed state do 
			(
			mPREBCPValue = state
			mPREBCPTypeDropdown.enabled = state
			mPREBCPSizeSpinner.enabled = state
			--mPREBCPLightCheckbox.enabled = state
			--mPREBCPShadowsCheckbox.enabled = state
			mPREBCPDirEditText.enabled = state
			mPREBCPDirButton.enabled = state
			)
		on mPREBCPTypeDropdown selected i do mPREBCPTypeValue = i
		on mPREBCPSizeSpinner changed val do mPREBCPSizeValue = val
		on mPREBCPDirEditText changed text do 
			(
			if text[text.count] != "\\" then text = text + "\\"
			mPREBCPDirValue = text
			mPREBCPDirEditText.text = text
			)
		on mPREBCPDirButton pressed do 
			(
			mypath = getSavePath()
			if mypath != undefined then 
				(
				if mypath[mypath.count] != "\\" then mypath = mypath + "\\"
				mPREBCPDirValue = mypath
				mPREBCPDirEditText.text = mypath
				)
			else 
				(
				mPREBCPDirValue = ""
				mPREBCPDirEditText.text = ""
				)
			)
		--on mPREBCPLightCheckbox changed state do mPREBCPLightValue = state
		--on mPREBCPShadowsCheckbox changed state do mPREBCPShadowsValue = state
		
		on mPRERollout open do
			(
			mPRExFormSetCollapseCheckbox.enabled = mPRExFormSetValue
			mPRECurveTypeDropdown.enabled = mPRECurveSetValue
			if mPRECurveTypeValue == 1 then
				(
				mPRECurveLowSpinner.enabled = mPRECurveSetValue
				mPRECurveHighSpinner.enabled = mPRECurveSetValue
				mPRECurveScaleSpinner.enabled = false
				)
			else
				(
				mPRECurveLowSpinner.enabled = false
				mPRECurveHighSpinner.enabled = false
				mPRECurveScaleSpinner.enabled = mPRECurveSetValue	
				)
			mPREBCPTypeDropdown.enabled = mPREBCPValue
			mPREBCPSizeSpinner.enabled = mPREBCPValue
			--mPREBCPLightCheckbox.enabled = mPREBCPValue
			--mPREBCPShadowsCheckbox.enabled = mPREBCPValue
			mPREBCPDirEditText.enabled = mPREBCPValue
			mPREBCPDirButton.enabled = mPREBCPValue			
			)
		
		button mPREDoButton "Do" width:70 toolTip:"Do It and Close UI" pos:[5,457]
		on mPREDoButton pressed do mPREDo()
		button mPREApplyButton "Apply" width:70 toolTip:"Do It and Keep UI Open" pos:[77,457]
		on mPREApplyButton pressed do mPREApply()
		button mPREHelpButton "Help" width:70 toolTip:"Help" pos:[149,457]
		on mPREHelpButton pressed do mPREHelp()
		button mPRESaveDefButton "SaveDef" width:70 toolTip:"Save Current Settings as Default" pos:[221,457]
		on mPRESaveDefButton pressed do mPRESaveDef()
		)
	)
)
-------------------------------------------------------------------------------