-------------------------------------------------------------------------------
-- wireMaker.ms
-- By Neil Blevins (info@neilblevins.com)
-- v 1.33
-- Created On: 06/05/05
-- Modified On: 09/08/16
-- tested using Max 2009
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Required Files:
-- sLib.ms
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Description:
-- Creates a number of wires that travel through various target objects. Useful 
-- for making bundles of wires for robots or other mechanical devices in a few 
-- simple clicks.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Tutorial:
-- Make 3 spheres anywhere in the viewport. Select all 3 spheres. Run the UI 
-- version of the script. In the wireMaker interface, click on "Add select 
-- to target list". Click Apply. It will make 10 splines, each the vertex of 
-- each spline will exist inside one of the 3 spheres. Play with the settings 
-- to get different effects.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Known Issues:
-- This script misbehaves if used on scenes that have duplicate object
-- names. If the script refuses to paint even though you have everything setup 
-- correctly, check to see if any objects in your scene have duplicate names. 
-- Fixing the names will allow the script to function properly.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Revision History:
--
-- v 1.10 Added the path deform code to the appearance section. Added a new
-- target interp value of center, which always goes through the center of the
-- target object.
--
-- v 1.11 Defined ui as new function.
--
-- v 1.20 HideT button now hides and unhides targets. Added new mode called Vert
-- to Vert, which runs wires through the same vertex of each object. Only
-- works if all targets have the same vertex count. ADded ability to perform
-- script on preexisting splines. Rearranged the UI some. Added ability to 
-- jitter the knot position when creating new splines.
--
-- v 1.21 Added a taper mode to the path deform appearance mode.
--
-- v 1.22 Added option to link path deformed meshes to the splines. Added 
-- option to match the wirecolor of the path deformed meshes to the splines.
--
-- v 1.23 Resets the xform on any deformed objects, and a bias control to the
-- spline size, so you can have more smaller or more larger wires. Added delete 
-- buttons to remove items from the all the lists.
--
-- v 1.24 Now when doing Vert To Vert, script guarantees it won't
-- pick the same vert twice.
--
-- v 1.25 Fixed a bug when trying to remove objects from the various lists. Added 
-- weights to deform objects. Increase the weight of an object to have it chosen 
-- more frequently.
--
-- v 1.26 Replaced the Close button with a Help button. Use the X button to 
-- Close the Floater.
--
-- v 1.27 Fixed Crash Bug.
--
-- v 1.28 Will now match material applied to existing splines. Added a new 
-- Appearance Type, SplineMesher.
-- 
-- v 1.29 Modified the parameters of SplineMesher to create more consistent 
-- results.
--
-- v 1.30 Moved the reset x-form code into slib.
--
-- v 1.31 Fixed a bug where hitting the "Add Sel To Deform List" button
-- repeatedly would keep adding the same objects. Fixed a bug where duplicate
-- named nodes would cause the script to crash.
--
-- v 1.32 Changed name of script to wireMaker.
--
-- v 1.33 Fixed an issue where not having SplineMesher installed causes
-- tons of error dialogs.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
(
-- Globals

global wireMaker
global wireMakerDefaults
global wireMakerUI

global wBCloseOpenUI

global wBTargetsTest
global wBSplinesTest
global wBDeformableTest
global wBAllObjectsHaveSameVertCount
global wBChooseAPointOnTarget
global wBCreateSplineKnots
global wBAppearance
global wBSetTargetVisibility
global wBUniqueNodeNamesTest

global wBDo
global wBApply
global wBHelp
global wBLoadDef
global wBSaveDef

global wBDefineUI
global wBRolloutMain
global wBRolloutNS
global wBRolloutES
global wBRolloutRS
global wBRolloutPD
global wBRolloutSM
global wBRolloutTools
global wBFloater

-- Includes

include "$scripts\SoulburnScripts\lib\sLib.ms"

-- Variables

global wBVertToVertList = #()
global wBTargetList = #()
global wBExistingSplinesList = #()
global wBPolyTargetList = #()
global wBDeformList = #()
global wBDeformListNames = #()
global wBLastWireBundle = #()

wBWireTypeValue = 1
wBNumWiresValue = 10
wBStepsValue = 12
wBJitterKnotPosValue = false
wBJitterXValue = 0.0
wBJitterYValue = 0.0
wBJitterZValue = 0.0
wBJitterMiddleOnlyValue = false
wBTargetInterpTypeValue = 3
wBAppearanceTypeValue = 2
wBMinThicknessValue = 1
wBMaxThicknessValue = 2
wBThicknessBiasValue = 0.5
wBSidesValue = 12
wBRenderableValue = true
wBMappingValue = true
wBDisplayRenderMeshValue = true
wBPDMinThicknessValue = 0.5
wBPDMaxThicknessValue = 1.5
wBPDThicknessBiasValue = 0.5
wBPDStretchPerValue = 100
wBPDRandomRotationValue = true
wBPDTwistMinValue = 0
wBPDTwistMaxValue = 0
wBPDTaperValue = false
wBPDTaperAmountValue = -0.7
wBPDPrimaryAxisValue = 3
wBPDNormalizeValue = false
wBPDNormalizeFactorValue = 20
wBPDMatchColorValue = true
wBPDMatchMatValue = false
wBPDLinkMeshValue = true
wBPDResetXformValue = true
wBSMInitialThicknessValue = 5.0
wBSMFinalThicknessValue = 1.0
wBSMSmoothedValue = false
wBTargetsNoRenderValue = true
wBPosValue = [85,40]

-- Functions

fn wireMaker wBWireType wBNumWires wBSteps wBJitterKnotPos wBJitterX wBJitterY wBJitterZ wBJitterMiddleOnly wBTargetInterpType wBAppearanceType wBMinThickness wBMaxThickness wBThicknessBias wBSides wBRenderable wBMapping wBDisplayRenderMesh wBPDMinThickness wBPDMaxThickness wBPDThicknessBias wBPDStretchPer wBPDRandomRotation wBPDTwistMin wBPDTwistMax wBPDTaper wBPDTaperAmount wBPDPrimaryAxis wBPDNormalize wBPDNormalizeFactor wBPDMatchColor wBPDMatchMat wBPDLinkMesh wBPDResetXform wBSMInitialThickness wBSMFinalThickness wBSMSmoothed wBTargetsNoRender = 
	(
	wBLastWireBundle = #()
	wBPolyTargetList = #()
	undo "wireMaker" on
		(
		-- Clear
		gc()
		
		-- Tests
		if (wBTargetsTest wBWireType) == true then
			(
			if (wBSplinesTest wBWireType) == true then
				(
				if (wBDeformableTest wBAppearanceType) == true then
					(
					if wBAppearanceType == 4 and sLibSplineMesherTest() == false then (MessageBox "Please install the Grant Adam Plugin called SplineMesher" title:"WireMaker")
					else 
						(
						-- make copies of target objects
						if wBWireType == 1 then
							(
							for i in wBTargetList do
								(
								newObj = copy (getNodeByName i)
								convertTo newObj (Editable_Poly)
								append wBPolyTargetList newObj
								)
							)
						-- Do all targets have the same vert count
						if wBWireType == 1 and wBTargetInterpType == 5 and (wBAllObjectsHaveSameVertCount wBPolyTargetList) == false then 
							(
							MessageBox "Your targets don't all have the same vertex count, please select targets that all have the same number of vertexes, or don't use Vert To Vert target Interpolation." title:"WireBundle"
							for i in wBPolyTargetList do delete i
							)
						else
							(
							-- Setup Variables
							wBLastWireBundle = #()
							if wBWireType == 1 and wBTargetInterpType == 5 then (wBVertToVertList = (for i = 1 to (wBPolyTargetList[1].numverts) collect i))

							-- Switch To Create Mode
							if getCommandPanelTaskMode() == #modify then max create mode
							disableSceneRedraw()
							try
								(
								-- do the bundle
								if wBWireType == 1 then wBNumberOfWires = wBNumWires
								else if wBWireType == 2 then wBNumberOfWires = wBExistingSplinesList.count
								for i = 1 to wBNumberOfWires do
									(
									if wBWireType == 1 then
										(
										s = line pos:[0,0,0]
										attempt = wBCreateSplineKnots s wBJitterKnotPos wBJitterX wBJitterY wBJitterZ wBJitterMiddleOnly wBTargetInterpType
										if attempt == false then 
											(
											delete s
											exit
											)
										s.steps = wBSteps
										s.name = uniqueName "WireBundle"
										)
									else if wBWireType == 2 then
										(
										if wBAppearanceType == 3 then
											(
											s = copy (getNodeByName wBExistingSplinesList[i])
											sLibResetXForm s
											convertTo s SplineShape
											)
										else
											(
											s = getNodeByName wBExistingSplinesList[i]
											)
										)
									wBAppearance s wBAppearanceType wBMinThickness wBMaxThickness wBThicknessBias wBSides wBRenderable wBMapping wBDisplayRenderMesh wBPDMinThickness wBPDMaxThickness wBPDThicknessBias wBPDStretchPer wBPDRandomRotation wBPDTwistMin wBPDTwistMax wBPDTaper wBPDTaperAmount wBPDPrimaryAxisValue wBPDNormalize wBPDNormalizeFactor wBPDMatchColor wBPDMatchMat wBPDLinkMesh wBPDResetXform wBSMInitialThickness wBSMFinalThickness wBSMSmoothed

									if wBWireType == 2 then 
										(
										if wBAppearanceType == 3 then append wBLastWireBundle s
										)
									else append wBLastWireBundle s
									)
								if wBWireType == 1 then wBSetTargetVisibility wBTargetList wBTargetsNoRender
								)
							catch ()
							-- Delete poly target objects
							if wBWireType == 1 then for i in wBPolyTargetList do delete i
							wBVertToVertList = #()
							enableSceneRedraw()
							completeRedraw()
							)
						)
					)
				)
			)
		)
	)

fn wireMakerDefaults = 
	(
	wBLoadDef()
	wireMaker wBWireTypeValue wBNumWiresValue wBStepsValue wBJitterKnotPosValue wBJitterXValue wBJitterYValue wBJitterZValue wBJitterMiddleOnlyValue wBTargetInterpTypeValue wBAppearanceTypeValue wBMinThicknessValue wBMaxThicknessValue wBThicknessBiasValue wBSidesValue wBRenderableValue wBMappingValue wBDisplayRenderMeshValue wBPDMinThicknessValue wBPDMaxThicknessValue wBPDThicknessBiasValue wBPDStretchPerValue wBPDRandomRotationValue wBPDTwistMinValue wBPDTwistMaxValue wBPDTaperValue wBPDTaperAmountValue wBPDPrimaryAxisValue wBPDNormalizeValue wBPDNormalizeFactorValue wBPDMatchColorValue wBPDMatchMatValue wBPDLinkMeshValue wBPDResetXformValue wBSMInitialThicknessValue wBSMFinalThicknessValue wBSMSmoothedValue wBTargetsNoRenderValue
	)
	
fn wireMakerUI = 
	(
	wBLoadDef()
	wBCloseOpenUI wBPosValue wBWireTypeValue wBAppearanceTypeValue
	)
	
fn wBCloseOpenUI pos wBWireType wBAppearanceType = 
	(
	if wBFloater != undefined then CloseRolloutFloater wBFloater
	wBDefineUI()
	
	-- define floater length
	local floaterLength = 296
	if wBWireType == 1 then floaterLength += 332
	else if wBWireType == 2 then floaterLength += 176
	if wBAppearanceType == 2 then floaterLength += 201
	else if wBAppearanceType == 3 then floaterLength += 505
	else if wBAppearanceType == 4 then floaterLength += 118
	
	-- create floater	
	wBFloater = newRolloutFloater "wireMaker v1.33" 200 floaterLength pos.x pos.y
	
	-- add rollouts
	addRollout wBRolloutMain wBFloater
	if wBWireType == 1 then addRollout wBRolloutNS wBFloater
	else if wBWireType == 2 then addRollout wBRolloutES wBFloater
	if wBAppearanceType == 2 then addRollout wBRolloutRS wBFloater
	else if wBAppearanceType == 3 then addRollout wBRolloutPD wBFloater
	else if wBAppearanceType == 4 then addRollout wBRolloutSM wBFloater
	addRollout wBRolloutTools wBFloater
	)

fn wBTargetsTest wBWireType =
	(
	local okToProceed = true
	if wBWireType == 1 then
		(
		-- Check if there are duplicate node names
		if (wBUniqueNodeNamesTest wBTargetList) == false then okToProceed = false
		if okToProceed == false then MessageBox "At least one object in your Targets List has a duplicate named object in the scene. You must fix this conflict before the script will work." title:"wireMaker"
		else
			(
			-- Check if user has chosen at least 2 targets
			if wBTargetList.count < 2 then okToProceed = false
			if okToProceed == false then MessageBox "Please pick at least two targets" title:"wireMaker"
			else 
				(
				-- Check if targets still exist
				for i in wBTargetList do if (getNodeByName i) == undefined then okToProceed = false
				if okToProceed == false then MessageBox "At least one of your targets no longer exists." title:"wireMaker"
				)
			)
		)
	return okToProceed
	)
	
fn wBSplinesTest wBWireType = 
	(
	local okToProceed = true
	if wBWireType == 2 then 
		(
		-- Check if there are duplicate node names
		if (wBUniqueNodeNamesTest wBExistingSplinesList) == false then okToProceed = false
		if okToProceed == false then MessageBox "At least one object in your Existing Splines List has a duplicate named object in the scene. You must fix this conflict before the script will work." title:"wireMaker"
		else
			(
			-- Check if user has chosen at least 1 existing spline
			if wBExistingSplinesList.count < 1 then okToProceed = false
			if okToProceed == false then MessageBox "Please pick some preexisting splines if you want to use the existing splines option." title:"wireMaker"
			else
				(
				-- Check if existing splines still exist
				for i in wBExistingSplinesList do if (getNodeByName i) == undefined then okToProceed = false
				if okToProceed == false then MessageBox "At least one of your existing splines no longer exists." title:"wireMaker"
				)
			)
		)
	return okToProceed
	)
	
fn wBDeformableTest wBAppearanceType =
	(
	local okToProceed = true
	if wBAppearanceType == 3 then 
		(
		-- Check if there are duplicate node names
		wBDeformListNamesOnly = #()
		for i in wBDeformList do append wBDeformListNamesOnly i[1]
		if (wBUniqueNodeNamesTest wBDeformListNamesOnly) == false then okToProceed = false
		if okToProceed == false then MessageBox "At least one object in your Deform List has a duplicate named object in the scene. You must fix this conflict before the script will work." title:"wireMaker"
		else
			(
			-- Check if user has chosen at least 1 deformed object
			if wBDeformList.count < 1 then okToProceed = false
			if okToProceed == false then MessageBox "Please pick some deform objects if you want to use the path deform option." title:"wireMaker"
			else
				(
				-- Check if deformed objects still exist
				for i in wBDeformList do if (getNodeByName i[1]) == undefined then okToProceed = false
				if okToProceed == false then MessageBox "At least one of your objects in the deform list no longer exists." title:"wireMaker"
				)
			)
		)
	return okToProceed
	)

fn wBAllObjectsHaveSameVertCount a = 
	(
	answer = true
	for i = 2 to a.count do
		(
		if a[i].numverts != a[1].numverts then answer = false
		)
	return answer
	)

fn wBChooseAPointOnTarget obj type value =
	(
	-- Bounding Box
	if type == 1 then
		(
		return [(random obj.max.x obj.min.x), (random obj.max.y obj.min.y), (random obj.max.z obj.min.z)]
		)

	-- Face Center
	if type == 2 then
		(
		faceIndex = random 1 (polyOp.getNumFaces obj)
		facePos = polyOp.getFaceCenter obj faceIndex
		return [facePos.x, facePos.y, facePos.z]
		)

	-- Vertex
	if type == 3 then
		(
		vertIndex = random 1 (polyOp.getNumVerts obj)
		vertPos = (obj.getVertex vertIndex) * obj.objectTransform
		return [vertPos.x, vertPos.y, vertPos.z]
		)
	-- Obj Center
	if type == 4 then
		(
		return [obj.center.x, obj.center.y, obj.center.z]
		)
	-- Vert To Vert
	if type == 5 then
		(
		vertPos = (obj.getVertex value) * obj.objectTransform
		return [vertPos.x, vertPos.y, vertPos.z]
		)
	)
	
fn wBCreateSplineKnots s wBJitterKnotPos wBJitterX wBJitterY wBJitterZ wBJitterMiddleOnly wBTargetInterpType = 
	(
	-- If Vert To Vert, choose a vert
	if wBTargetInterpType == 5 then
		(
		if wBVertToVertList.count == 0 then return false
		else
			(
			index = random 1 wBVertToVertList.count
			value = wBVertToVertList[index]
			deleteitem wBVertToVertList index
			)
		)
	else value = 0
	newS = addnewspline s
	for i = 1 to wBPolyTargetList.count do
		(
		knotpos = (wBChooseAPointOnTarget wBPolyTargetList[i] wBTargetInterpType value)
		if wBJitterKnotPos == true then
			(
			Jitx = random -wBJitterX wBJitterX
			Jity = random -wBJitterY wBJitterY
			Jitz = random -wBJitterZ wBJitterZ
			if wBJitterMiddleOnly == false then
				(
				knotpos += [Jitx, Jity, Jitz]
				)
			else
				(
				if i!=1 and i!=wBPolyTargetList.count then knotpos += [Jitx, Jity, Jitz]
				)
			)
		addknot s newS #smooth #curve knotpos
		)
	updateshape s
	return true
	)
	
fn wBAppearance s wBAppearanceType wBMinThickness wBMaxThickness wBThicknessBias wBSides wBRenderable wBMapping wBDisplayRenderMesh wBPDMinThickness wBPDMaxThickness wBPDThicknessBias wBPDStretchPer wBPDRandomRotation wBPDTwistMin wBPDTwistMax wBPDTaper wBPDTaperAmount wBPDPrimaryAxis wBPDNormalize wBPDNormalizeFactor wBPDMatchColor wBPDMatchMat wBPDLinkMesh wBPDResetXform wBSMInitialThickness wBSMFinalThickness wBSMSmoothed = 
	(
	if wBAppearanceType == 1 then
		(
		s.baseobject.renderable = false
		)
	else if wBAppearanceType == 2 then
		(
		s.thickness = sLibRandomWithBias (wBMinThickness as float) (wBMaxThickness as float) wBThicknessBias
		s.sides = wBSides
		s.baseobject.renderable = wBRenderable
		s.mapCoords = wBMapping
		s.DisplayRenderMesh = wBDisplayRenderMesh		
		)
	else if wBAppearanceType == 3 then
		(
		-- setup
		s.baseobject.renderable = false
		s.DisplayRenderMesh = false
		
		-- create new array
		wBDeformListFinal = #()
		for i in wBDeformList do
			(
			for v = 1 to i[2] do append wBDeformListFinal i[1]
			)
			
		-- variables
		deformObj = copy (getNodeByName (wBDeformListFinal[(random 1 wBDeformListFinal.count)]))
		if wBPDResetXform == true then sLibResetXForm deformObj
		deformMod = SpacePathDeform()
		pathLength = curveLength s 1
		objLength = deformObj.max.z - deformObj.min.z

		-- normalize
		if wBPDNormalize == true then
			(
			nMod = Normalize_Spl()
			addmodifier s nMod
			nMod.length = pathLength / wBPDNormalizeFactor
			)
		
		-- adjust thickness
		xMod = xform()
		addmodifier deformObj xMod
		xMod.name = "Random Scale Xform"
		objThick = sLibRandomWithBias (wBPDMinThickness as float) (wBPDMaxThickness as float) wBPDThicknessBias
		if wBPDPrimaryAxisValue == 1 then xMod.gizmo.scale = [1,objThick,objThick]
		else if wBPDPrimaryAxisValue == 2 then xMod.gizmo.scale = [objThick,1,objThick]
		else if wBPDPrimaryAxisValue == 3 then xMod.gizmo.scale = [objThick,objThick,1]

		-- taper
		if wBPDTaper == true then
			(
			tMod = taper()
			addmodifier deformObj tMod
			tMod.amount = wBPDTaperAmount
			tMod.primaryaxis = wBPDPrimaryAxisValue - 1
			)
			
		-- deform
		addModifier deformObj deformMod
		deformMod.path = s
		deformObj.transform = s.transform
		deformMod.stretch = (pathLength / objLength) * (wBPDStretchPer * 0.01)
		if wBPDRandomRotation == true then deformMod.rotation = random 0 359
		deformMod.axis = wBPDPrimaryAxis - 1
		
		-- twist
		objTwist = random wBPDTwistMin wBPDTwistMax
		deformMod.Twist = objTwist
		
		-- match color
		if wBPDMatchColor == true then deformObj.wirecolor = s.wirecolor
		
		-- match material
		if wBPDMatchMat == true then deformObj.material = s.material
		
		-- linking
		if wBPDLinkMesh == true then deformObj.parent = s
		
		-- end
		append wBLastWireBundle deformObj
		)
	else if wBAppearanceType == 4 then
		(
		if (validModifier s (SplineMesher())) == true then
			(
			doesModExist = false
			if s.modifiers.count != 0 then
				(
				for j = 1 to s.modifiers.count do
					(
					if classof s.modifiers[j] == SplineMesher then doesModExist = true
					)
				)
			if doesModExist == false then
				(
				addmodifier s (SplineMesher ())

				s.modifiers[#SplineMesher].LengthSegments = 16
				s.modifiers[#SplineMesher].sides = 4
				s.modifiers[#SplineMesher].shape = 1
				s.modifiers[#SplineMesher].ShapeTip = 1
				s.modifiers[#SplineMesher].TipBlendPoint = 0.75
				s.modifiers[#SplineMesher].TipBlendRange = 0.5

				s.modifiers[#SplineMesher].Growth = 100.0
				s.modifiers[#SplineMesher].Twist = 0
				s.modifiers[#SplineMesher].rotation = 0

				s.modifiers[#SplineMesher].MappingStyle = 0
				s.modifiers[#SplineMesher].InterpolationType = 1
				s.modifiers[#SplineMesher].RadiusMultiplier = wBSMInitialThickness
				s.modifiers[#SplineMesher].GrowStyle = 1
				s.modifiers[#SplineMesher].TipRadiusMultiplier = wBSMFinalThickness

				if wBSMSmoothed == false then
					(
					addmodifier s (Smooth ())
					s.modifiers[#Smooth].autosmooth = off
					)
				)
			)
		)
	)
	
fn wBSetTargetVisibility a value = 
	(
	for i in a do
		(
		(getNodeByName i).renderable = not value
		)
	)

fn wBUniqueNodeNamesTest a = 
	(
	for i in a do
		(
		a2 = getNodeByName i all:true
		if a2.count != 1 then return false
		)
	return true
	)
	
fn wBDo = 
	(
	wireMaker wBWireTypeValue wBNumWiresValue wBStepsValue wBJitterKnotPosValue wBJitterXValue wBJitterYValue wBJitterZValue wBJitterMiddleOnlyValue wBTargetInterpTypeValue wBAppearanceTypeValue wBMinThicknessValue wBMaxThicknessValue wBThicknessBiasValue wBSidesValue wBRenderableValue wBMappingValue wBDisplayRenderMeshValue wBPDMinThicknessValue wBPDMaxThicknessValue wBPDThicknessBiasValue wBPDStretchPerValue wBPDRandomRotationValue wBPDTwistMinValue wBPDTwistMaxValue wBPDTaperValue wBPDTaperAmountValue wBPDPrimaryAxisValue wBPDNormalizeValue wBPDNormalizeFactorValue wBPDMatchColorValue wBPDMatchMatValue wBPDLinkMeshValue wBPDResetXformValue wBSMInitialThicknessValue wBSMFinalThicknessValue wBSMSmoothedValue wBTargetsNoRenderValue
	if wBFloater != undefined then CloseRolloutFloater wBFloater
	)

fn wBApply = 
	(
	wireMaker wBWireTypeValue wBNumWiresValue wBStepsValue wBJitterKnotPosValue wBJitterXValue wBJitterYValue wBJitterZValue wBJitterMiddleOnlyValue wBTargetInterpTypeValue wBAppearanceTypeValue wBMinThicknessValue wBMaxThicknessValue wBThicknessBiasValue wBSidesValue wBRenderableValue wBMappingValue wBDisplayRenderMeshValue wBPDMinThicknessValue wBPDMaxThicknessValue wBPDThicknessBiasValue wBPDStretchPerValue wBPDRandomRotationValue wBPDTwistMinValue wBPDTwistMaxValue wBPDTaperValue wBPDTaperAmountValue wBPDPrimaryAxisValue wBPDNormalizeValue wBPDNormalizeFactorValue wBPDMatchColorValue wBPDMatchMatValue wBPDLinkMeshValue wBPDResetXformValue wBSMInitialThicknessValue wBSMFinalThicknessValue wBSMSmoothedValue wBTargetsNoRenderValue
	)
	
fn wBHelp = 
	(
	sLibSSPrintHelp "wireMaker"
	)
	
fn wBLoadDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	wBInputFilename = presetDir + "wireMaker.ini"
	if (sLibFileExist wBInputFilename == true) then
		(
		wBWireTypeValue = execute (getINISetting wBInputFilename "wireMaker" "wBWireTypeValue")
		wBNumWiresValue = execute (getINISetting wBInputFilename "wireMaker" "wBNumWiresValue")
		wBStepsValue = execute (getINISetting wBInputFilename "wireMaker" "wBStepsValue")
		wBJitterKnotPosValue = execute (getINISetting wBInputFilename "wireMaker" "wBJitterKnotPosValue")
		wBJitterXValue = execute (getINISetting wBInputFilename "wireMaker" "wBJitterXValue")
		wBJitterYValue = execute (getINISetting wBInputFilename "wireMaker" "wBJitterYValue")
		wBJitterZValue = execute (getINISetting wBInputFilename "wireMaker" "wBJitterZValue")
		wBJitterMiddleOnlyValue = execute (getINISetting wBInputFilename "wireMaker" "wBJitterMiddleOnlyValue")
		wBTargetInterpTypeValue = execute (getINISetting wBInputFilename "wireMaker" "wBTargetInterpTypeValue")
		wBAppearanceTypeValue = execute (getINISetting wBInputFilename "wireMaker" "wBAppearanceTypeValue")
		wBMinThicknessValue = execute (getINISetting wBInputFilename "wireMaker" "wBMinThicknessValue")
		wBMaxThicknessValue = execute (getINISetting wBInputFilename "wireMaker" "wBMaxThicknessValue")
		wBThicknessBiasValue = execute (getINISetting wBInputFilename "wireMaker" "wBThicknessBiasValue")
		wBSidesValue = execute (getINISetting wBInputFilename "wireMaker" "wBSidesValue")
		wBRenderableValue = execute (getINISetting wBInputFilename "wireMaker" "wBRenderableValue")
		wBMappingValue = execute (getINISetting wBInputFilename "wireMaker" "wBMappingValue")
		wBDisplayRenderMeshValue = execute (getINISetting wBInputFilename "wireMaker" "wBDisplayRenderMeshValue")
		wBPDMinThicknessValue = execute (getINISetting wBInputFilename "wireMaker" "wBPDMinThicknessValue")
		wBPDMaxThicknessValue = execute (getINISetting wBInputFilename "wireMaker" "wBPDMaxThicknessValue")
		wBPDStretchPerValue = execute (getINISetting wBInputFilename "wireMaker" "wBPDStretchPerValue")
		wBPDRandomRotationValue = execute (getINISetting wBInputFilename "wireMaker" "wBPDRandomRotationValue")
		wBPDTwistMinValue = execute (getINISetting wBInputFilename "wireMaker" "wBPDTwistMinValue")
		wBPDTwistMaxValue = execute (getINISetting wBInputFilename "wireMaker" "wBPDTwistMaxValue")
		wBPDTaperValue = execute (getINISetting wBInputFilename "wireMaker" "wBPDTaperValue")
		wBPDTaperAmountValue = execute (getINISetting wBInputFilename "wireMaker" "wBPDTaperAmountValue")
		wBPDPrimaryAxisValue = execute (getINISetting wBInputFilename "wireMaker" "wBPDPrimaryAxisValue")
		wBPDNormalizeValue = execute (getINISetting wBInputFilename "wireMaker" "wBPDNormalizeValue")
		wBPDNormalizeFactorValue = execute (getINISetting wBInputFilename "wireMaker" "wBPDNormalizeFactorValue")
		wBPDMatchColorValue =  execute (getINISetting wBInputFilename "wireMaker" "wBPDMatchColorValue")
		wBPDMatchMatValue =  execute (getINISetting wBInputFilename "wireMaker" "wBPDMatchMatValue")
		wBPDLinkMeshValue =  execute (getINISetting wBInputFilename "wireMaker" "wBPDLinkMeshValue")
		wBPDResetXformValue =  execute (getINISetting wBInputFilename "wireMaker" "wBPDResetXformValue")
		wBSMInitialThicknessValue =  execute (getINISetting wBInputFilename "wireMaker" "wBSMInitialThicknessValue")
		wBSMFinalThicknessValue =  execute (getINISetting wBInputFilename "wireMaker" "wBSMFinalThicknessValue")
		wBSMSmoothedValue =  execute (getINISetting wBInputFilename "wireMaker" "wBSMSmoothedValue")
		wBTargetsNoRenderValue = execute (getINISetting wBInputFilename "wireMaker" "wBTargetsNoRenderValue")
		wBPosValue = execute (getINISetting wBInputFilename "wireMaker" "wBPosValue")

		if wBWireTypeValue == OK then wBWireTypeValue = 1
		if wBNumWiresValue == OK then wBNumWiresValue = 10
		if wBStepsValue == OK then wBStepsValue = 12
		if wBJitterKnotPosValue == OK then wBJitterKnotPosValue = false
		if wBJitterXValue == OK then wBJitterXValue = 0.0
		if wBJitterYValue == OK then wBJitterYValue = 0.0
		if wBJitterZValue == OK then wBJitterZValue = 0.0
		if wBJitterMiddleOnlyValue == OK then wBJitterMiddleOnlyValue = false
		if wBTargetInterpTypeValue == OK then wBTargetInterpTypeValue = 3
		if wBAppearanceTypeValue == OK then wBAppearanceTypeValue = 2
		if wBMinThicknessValue == OK then wBMinThicknessValue = 1
		if wBMaxThicknessValue == OK then wBMaxThicknessValue = 2
		if wBThicknessBiasValue == OK then wBThicknessBiasValue = 0.5
		if wBSidesValue == OK then wBSidesValue = 12
		if wBRenderableValue == OK then wBRenderableValue = true
		if wBMappingValue == OK then wBMappingValue = true
		if wBDisplayRenderMeshValue == OK then wBDisplayRenderMeshValue = true
		if wBPDMinThicknessValue == OK then wBPDMinThicknessValue = 0.5
		if wBPDMaxThicknessValue == OK then wBPDMaxThicknessValue = 1.5
		if wBPDThicknessBiasValue == OK then wBPDThicknessBiasValue = 0.5
		if wBPDStretchPerValue == OK then wBPDStretchPerValue = 100
		if wBPDRandomRotationValue == OK then wBPDRandomRotationValue = true
		if wBPDTwistMinValue == OK then wBPDTwistMinValue = 0
		if wBPDTwistMaxValue == OK then wBPDTwistMaxValue = 0
		if wBPDTaperValue == OK then wBPDTaperValue = false
		if wBPDTaperAmountValue == OK then wBPDTaperAmountValue = -0.7
		if wBPDPrimaryAxisValue == OK then wBPDPrimaryAxisValue = 3
		if wBPDNormalizeValue == OK then wBPDNormalizeValue = false
		if wBPDNormalizeFactorValue == OK then wBPDNormalizeFactorValue = 20
		if wBPDMatchColorValue == OK then wBPDMatchColorValue = true
		if wBPDMatchMatValue == OK then wBPDMatchMatValue = false
		if wBPDLinkMeshValue == OK then wBPDLinkMeshValue = true
		if wBPDResetXformValue == OK then wBPDResetXformValue = true
		if wBSMInitialThicknessValue == OK then wBSMInitialThicknessValue = 5.0
		if wBSMFinalThicknessValue == OK then wBSMFinalThicknessValue = 1.0
		if wBSMSmoothedValue == OK then wBSMSmoothedValue = false
		if wBTargetsNoRenderValue == OK then wBTargetsNoRenderValue = true
		if wBPosValue == OK then wBPosValue = [85,40]
		)
	else
		(
		wBWireTypeValue = 1
		wBNumWiresValue = 10
		wBStepsValue = 12
		wBJitterKnotPosValue = false
		wBJitterXValue = 0.0
		wBJitterYValue = 0.0
		wBJitterZValue = 0.0
		wBJitterMiddleOnlyValue = false
		wBTargetInterpTypeValue = 3
		wBAppearanceTypeValue = 2
		wBMinThicknessValue = 1
		wBMaxThicknessValue = 2
		wBThicknessBiasValue = 0.5
		wBSidesValue = 12
		wBRenderableValue = true
		wBMappingValue = true
		wBDisplayRenderMeshValue = true
		wBPDMinThicknessValue = 0.5
		wBPDMaxThicknessValue = 1.5
		wBPDThicknessBiasValue = 0.5
		wBPDStretchPerValue = 100
		wBPDRandomRotationValue = true
		wBPDTwistMinValue = 0
		wBPDTwistMaxValue = 0
		wBPDTaperValue = false
		wBPDTaperAmountValue = -0.7
		wBPDPrimaryAxisValue = 3
		wBPDNormalizeValue = false
		wBPDNormalizeFactorValue = 20
		wBPDMatchColorValue = true
		wBPDMatchMatValue = false
		wBPDLinkMeshValue = true
		wBPDResetXformValue = true
		wBSMInitialThicknessValue = 5.0
		wBSMFinalThicknessValue = 1.0
		wBSMSmoothedValue = false	
		wBTargetsNoRenderValue = true
		wBPosValue = [85,40]
		)
	)
	
fn wBSaveDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	if (getDirectories presetDir).count == 0 then makeDir presetDir
	wBOutputFilename = presetDir + "wireMaker.ini"
	if (sLibFileExist wBOutputFilename == true) then deleteFile wBOutputFilename
	setINISetting wBOutputFilename "wireMaker" "wBWireTypeValue" (wBWireTypeValue as string)
	setINISetting wBOutputFilename "wireMaker" "wBNumWiresValue" (wBNumWiresValue as string)
	setINISetting wBOutputFilename "wireMaker" "wBStepsValue" (wBStepsValue as string)
	setINISetting wBOutputFilename "wireMaker" "wBJitterKnotPosValue" (wBJitterKnotPosValue as string)	
	setINISetting wBOutputFilename "wireMaker" "wBJitterXValue" (wBJitterXValue as string)	
	setINISetting wBOutputFilename "wireMaker" "wBJitterYValue" (wBJitterYValue as string)	
	setINISetting wBOutputFilename "wireMaker" "wBJitterZValue" (wBJitterZValue as string)	
	setINISetting wBOutputFilename "wireMaker" "wBJitterMiddleOnlyValue" (wBJitterMiddleOnlyValue as string)	
	setINISetting wBOutputFilename "wireMaker" "wBTargetInterpTypeValue" (wBTargetInterpTypeValue as string)
	setINISetting wBOutputFilename "wireMaker" "wBAppearanceTypeValue" (wBAppearanceTypeValue as string)
	setINISetting wBOutputFilename "wireMaker" "wBMinThicknessValue" (wBMinThicknessValue as string)
	setINISetting wBOutputFilename "wireMaker" "wBMaxThicknessValue" (wBMaxThicknessValue as string)
	setINISetting wBOutputFilename "wireMaker" "wBThicknessBiasValue" (wBThicknessBiasValue as string)
	setINISetting wBOutputFilename "wireMaker" "wBSidesValue" (wBSidesValue as string)
	setINISetting wBOutputFilename "wireMaker" "wBRenderableValue" (wBRenderableValue as string)
	setINISetting wBOutputFilename "wireMaker" "wBMappingValue" (wBMappingValue as string)
	setINISetting wBOutputFilename "wireMaker" "wBDisplayRenderMeshValue" (wBDisplayRenderMeshValue as string)
	setINISetting wBOutputFilename "wireMaker" "wBPDMinThicknessValue" (wBPDMinThicknessValue as string)
	setINISetting wBOutputFilename "wireMaker" "wBPDMaxThicknessValue" (wBPDMaxThicknessValue as string)
	setINISetting wBOutputFilename "wireMaker" "wBPDThicknessBiasValue" (wBPDThicknessBiasValue as string)
	setINISetting wBOutputFilename "wireMaker" "wBPDStretchPerValue" (wBPDStretchPerValue as string)	
	setINISetting wBOutputFilename "wireMaker" "wBPDRandomRotationValue" (wBPDRandomRotationValue as string)
	setINISetting wBOutputFilename "wireMaker" "wBPDTwistMinValue" (wBPDTwistMinValue as string)
	setINISetting wBOutputFilename "wireMaker" "wBPDTwistMaxValue" (wBPDTwistMaxValue as string)
	setINISetting wBOutputFilename "wireMaker" "wBPDTaperValue" (wBPDTaperValue as string)
	setINISetting wBOutputFilename "wireMaker" "wBPDTaperAmountValue" (wBPDTaperAmountValue as string)
	setINISetting wBOutputFilename "wireMaker" "wBPDPrimaryAxisValue" (wBPDPrimaryAxisValue as string)
	setINISetting wBOutputFilename "wireMaker" "wBPDNormalizeValue" (wBPDNormalizeValue as string)
	setINISetting wBOutputFilename "wireMaker" "wBPDNormalizeFactorValue" (wBPDNormalizeFactorValue as string)
	setINISetting wBOutputFilename "wireMaker" "wBPDMatchColorValue" (wBPDMatchColorValue as string)
	setINISetting wBOutputFilename "wireMaker" "wBPDMatchMatValue" (wBPDMatchMatValue as string)
	setINISetting wBOutputFilename "wireMaker" "wBPDLinkMeshValue" (wBPDLinkMeshValue as string)
	setINISetting wBOutputFilename "wireMaker" "wBPDResetXformValue" (wBPDResetXformValue as string)
	setINISetting wBOutputFilename "wireMaker" "wBSMInitialThicknessValue" (wBSMInitialThicknessValue as string)
	setINISetting wBOutputFilename "wireMaker" "wBSMFinalThicknessValue" (wBSMFinalThicknessValue as string)
	setINISetting wBOutputFilename "wireMaker" "wBSMSmoothedValue" (wBSMSmoothedValue as string)
	setINISetting wBOutputFilename "wireMaker" "wBTargetsNoRenderValue" (wBTargetsNoRenderValue as string)
	setINISetting wBOutputFilename "wireMaker" "wBPosValue" (wBFloater.pos as string)
	)

-- UI

fn wBDefineUI = 
	(
	rollout wBRolloutMain "wireMaker Main"
		(
		group "Wire Type"
		(
		dropdownlist wBWireTypeDropdown "" items:#("Create New Splines", "Use Existing Splines") selection:wBWireTypeValue
		)
		on wBWireTypeDropdown selected i do 
			(
			wBWireTypeValue = i
			curPos = wBFloater.pos
			wBCloseOpenUI curPos wBWireTypeValue wBAppearanceTypeValue
			)		
		
		group "Wire Appearance"
		(
		dropdownlist wBAppearanceTypeDropdown "" items:#("None", "Renderable Spline", "Path Deform", "SplineMesher") selection:wBAppearanceTypeValue
		)
		on wBAppearanceTypeDropdown selected i do 
			(
			wBAppearanceTypeValue = i
			curPos = wBFloater.pos
			wBCloseOpenUI curPos wBWireTypeValue wBAppearanceTypeValue
			)
		)
		
	rollout wBRolloutNS "Wire Type"
		(
		group "Create New Splines"
		(
		spinner wBNumWiresSpinner "Number Of Wires: " range:[1,9999999,wBNumWiresValue] fieldWidth:60 type:#integer align:#right
		spinner wBStepsSpinner "Steps: " range:[0,1000,wBStepsValue] fieldWidth:60 type:#integer align:#right
		
		checkbox wBJitterKnotPosCheckbox "Jitter Knot Position?" checked:wBJitterKnotPosValue align:#left
		spinner wBJitterXSpinner "Pos:" range:[0,9999999,wBJitterXValue] fieldWidth:35 type:#float across:3 offset:[13,0]
		spinner wBJitterYSpinner "" range:[0,9999999,wBJitterYValue] fieldWidth:35 type:#float offset:[9,0]
		spinner wBJitterZSpinner "" range:[0,9999999,wBJitterZValue] fieldWidth:35 type:#float offset:[4,0]
		checkbox wBJitterMiddleOnlyCheckbox "Jitter Middle Targets Only?" checked:wBJitterMiddleOnlyValue align:#left
		
		label label1 "Target Interp: " offset:[-7,3] across:2
		dropdownlist wBTargetInterpTypeDropdown "" items:#("Bounding Box", "Face Center", "Vertex", "Obj Center", "Vert To Vert") width:95 selection:wBTargetInterpTypeValue offset:[-11,0]
		button wBAddTargetsButton "Move Sel To Target List" toolTip:"Move Selected Objects To Target List" width:142 align:#left across:2
		button wBAddTargetsDelButton "-" toolTip:"Delete Choosen Object From Target List" width:15 align:#right
		listbox wBTargetsListbox "Targets:" items:wBTargetList height:5
		button wBMoveTargetUpButton "Up" toolTip:"Move Selected Target Up" across:2 width:77
		button wBMoveTargetDownButton "Down" toolTip:"Move Selected Target Down" width:77
		)
		on wBNumWiresSpinner changed val do wBNumWiresValue = val	
		on wBStepsSpinner changed val do wBStepsValue = val
		
		on wBJitterKnotPosCheckbox changed state do 
			(
			wBJitterKnotPosValue = state
			wBJitterXSpinner.enabled = state
			wBJitterYSpinner.enabled = state
			wBJitterZSpinner.enabled = state
			wBJitterMiddleOnlyCheckbox.enabled = state
			)
		on wBJitterXSpinner changed val do wBJitterXValue = val
		on wBJitterYSpinner changed val do wBJitterYValue = val
		on wBJitterZSpinner changed val do wBJitterZValue = val
		on wBJitterMiddleOnlyCheckbox changed state do wBJitterMiddleOnlyValue = state
		
		on wBTargetInterpTypeDropdown selected i do wBTargetInterpTypeValue = i
		on wBAddTargetsButton pressed do 
			(
			wBTargetList = #()
			error = false
			for i in selection do
				(
				if (sLibGeometryFilter i) == false then error = true
				else append wBTargetList i.name
				)
			if error == true then (MessageBox "At least one object in your selection was not a piece of geometry and was removed from from your target list." title:"WireBundle")
			curPos = wBFloater.pos
			wBCloseOpenUI curPos wBWireTypeValue wBAppearanceTypeValue
			)
		on wBAddTargetsDelButton pressed do 
			(
			if wBTargetList.count != 0 then
				(
				deleteItem wBTargetList wBTargetsListbox.selection
				curPos = wBFloater.pos
				wBCloseOpenUI curPos wBWireTypeValue wBAppearanceTypeValue
				)
			)
		on wBMoveTargetUpButton pressed do 
			(
			if wBTargetList.count != 0 then
				(
				curTarget = wBTargetsListbox.selection
				wBTargetList = sLibMoveIndexUpInArray wBTargetList wBTargetsListbox.selection
				curPos = wBFloater.pos
				wBCloseOpenUI curPos wBWireTypeValue wBAppearanceTypeValue
				if curTarget != 1 then wBTargetsListbox.selection = curTarget - 1 else wBTargetsListbox.selection = curTarget
				)
			)
		on wBMoveTargetDownButton pressed do 
			(
			if wBTargetList.count != 0 then
				(
				curTarget = wBTargetsListbox.selection
				wBTargetList = sLibMoveIndexDownInArray wBTargetList wBTargetsListbox.selection
				curPos = wBFloater.pos
				wBCloseOpenUI curPos wBWireTypeValue wBAppearanceTypeValue
				if curTarget != wBTargetList.count then wBTargetsListbox.selection = curTarget + 1 else wBTargetsListbox.selection = curTarget
				)
			)
		on wBRolloutNS open do
			(
			wBJitterXSpinner.enabled = wBJitterKnotPosValue
			wBJitterYSpinner.enabled = wBJitterKnotPosValue
			wBJitterZSpinner.enabled = wBJitterKnotPosValue
			wBJitterMiddleOnlyCheckbox.enabled = wBJitterKnotPosValue
			)
		)

	rollout wBRolloutES "Wire Type"
		(
		group "Use Existing Splines"
		(
		button wBAddExistingSplinesButton "Move Sel To Spline List" toolTip:"Move Selection To Existing Splines List" width:142 align:#left across:2
		button wBAddExistingSplinesDelButton "-" toolTip:"Delete Choosen Object From Existing Spline List" width:15 align:#right
		listbox wBExistingSplinesListbox "Splines:" items:wBExistingSplinesList height:5
		)
		on wBAddExistingSplinesButton pressed do 
			(
			wBExistingSplinesList = #()
			error = false
			for i in selection do
				(
				if (sLibShapeFilter i) == false then error = true
				else append wBExistingSplinesList i.name
				)
			if error == true then (MessageBox "At least one object in your selection was not a spline and was removed from your existing splines list." title:"WireBundle")
			curPos = wBFloater.pos
			wBCloseOpenUI curPos wBWireTypeValue wBAppearanceTypeValue
			)
		on wBAddExistingSplinesDelButton pressed do 
			(
			if wBExistingSplinesList.count !=0 then
				(
				deleteItem wBExistingSplinesList wBExistingSplinesListbox.selection
				curPos = wBFloater.pos
				wBCloseOpenUI curPos wBWireTypeValue wBAppearanceTypeValue
				)
			)
		)
	
	rollout wBRolloutRS "Wire Appearance"
		(
		group "Renderable Spline"
		(
		spinner wBMinThicknessSpinner "Min Thickness: " range:[0,99999,wBMinThicknessValue] type:#float fieldWidth:60 align:#right
		spinner wBMaxThicknessSpinner "Max Thickness: " range:[0,99999,wBMaxThicknessValue] type:#float fieldWidth:60 align:#right
		spinner wBThicknessBiasSpinner "Thickness Bias: " range:[0.001,0.999,wBThicknessBiasValue] type:#float fieldWidth:40 align:#right
		spinner wBSidesSpinner "Sides: " range:[3,9999,wBSidesValue] type:#integer fieldWidth:60 align:#right	
		checkbox wBRenderableCheckbox "Renderable?" checked:wBRenderableValue align:#left
		checkbox wBMappingCheckbox "Generate Mapping Coords?" checked:wBMappingValue align:#left
		checkbox wBDisplayRenderMeshCheckbox "Display Render Mesh?" checked:wBDisplayRenderMeshValue align:#left
		)
		on wBMinThicknessSpinner changed val do wBMinThicknessValue = val
		on wBMaxThicknessSpinner changed val do wBMaxThicknessValue = val
		on wBThicknessBiasSpinner changed val do wBThicknessBiasValue = val
		on wBSidesSpinner changed val do wBSidesValue = val
		on wBRenderableCheckbox changed state do wBRenderableValue = state
		on wBMappingCheckbox changed state do wBMappingValue = state
		on wBDisplayRenderMeshCheckbox changed state do wBDisplayRenderMeshValue = state
		)
		
	rollout wBRolloutPD "Wire Appearance"
		(
		group "Path Deform"
		(
		spinner wBPDMinThicknessSpinner "Min Thickness: " range:[0,999999,wBPDMinThicknessValue] type:#float fieldWidth:60 align:#right
		spinner wBPDMaxThicknessSpinner "Max Thickness: " range:[0,999999,wBPDMaxThicknessValue] type:#float fieldWidth:60 align:#right
		spinner wBPDThicknessBiasSpinner "Thickness Bias: " range:[0.001,0.999,wBPDThicknessBiasValue] type:#float fieldWidth:40 align:#right
		spinner wBPDStretchPerSpinner "Stretch %: " range:[0,999999,wBPDStretchPerValue] type:#float fieldWidth:60 align:#right
		checkbox wBPDRandomRotationCheckbox "Random Rotation?" checked:wBPDRandomRotationValue align:#left
		spinner wBPDTwistMinSpinner "Twist Min: " range:[0,999999,wBPDTwistMinValue] type:#float fieldWidth:60 align:#right
		spinner wBPDTwistMaxSpinner "Twist Max: " range:[0,999999,wBPDTwistMaxValue] type:#float fieldWidth:60 align:#right
		checkbox wBPDTaperCheckbox "Taper?" checked:wBPDTaperValue align:#left across:2 offset:[0,-1]
		spinner wBPDTaperAmountSpinner "Amount: " range:[-10,10,wBPDTaperAmountValue] type:#float fieldWidth:40 align:#right
		label label2 "Primary Axis: " offset:[-7,3] across:2
		dropdownlist wBPDPrimaryAxisDropdown "" items:#("X", "Y", "Z") width:95 selection:wBPDPrimaryAxisValue offset:[-12,0]
		checkbox wBPDNormalizeCheckbox "Normalize?" checked:wBPDNormalizeValue across:2
		spinner wBPDNormalizeFactorSpinner "Factor: " range:[1,999999,wBPDNormalizeFactorValue] type:#float fieldWidth:35
		checkbox wBPDMatchColorCheckbox "Copy Spline Color To Mesh?" checked:wBPDMatchColorValue
		checkbox wBPDMatchMatCheckbox "Copy Spline Material To Mesh?" checked:wBPDMatchMatValue
		checkbox wBPDLinkMeshCheckbox "Link Mesh to Spline?" checked:wBPDLinkMeshValue
		checkbox wBPDResetXformCheckbox "Reset Xform on Deform Mesh?" checked:wBPDResetXformValue
		button wBAddDeformButton "Move Sel To Deform List" toolTip:"Move Selection To Deform List" width:142 align:#left across:2
		button wBAddDeformDelButton "-" toolTip:"Delete Choosen Object From Deform List" width:15 align:#right		
		listbox wBDeformListbox "Deform List:" items:wBDeformListNames height:6
		spinner wBDeformWeightSpinner "Weight: " range:[1,999,1] fieldWidth:40 type:#integer align:#right
		)
		on wBPDMinThicknessSpinner changed val do wBPDMinThicknessValue = val
		on wBPDMaxThicknessSpinner changed val do wBPDMaxThicknessValue = val
		on wBPDThicknessBiasSpinner changed val do wBPDThicknessBiasValue = val
		on wBPDStretchPerSpinner changed val do wBPDStretchPerValue = val
		on wBPDRandomRotationCheckbox changed state do wBPDRandomRotationValue = state
		on wBPDTwistMinSpinner changed val do wBPDTwistMinValue = val
		on wBPDTwistMaxSpinner changed val do wBPDTwistMaxValue = val
		on wBPDTaperCheckbox changed state do 
			(
			wBPDTaperValue = state
			wBPDTaperAmountSpinner.enabled = state
			)
		on wBPDTaperAmountSpinner changed val do wBPDTaperAmountValue = val
		on wBPDPrimaryAxisDropdown selected i do wBPDPrimaryAxisValue = i
		on wBPDNormalizeCheckbox changed state do 
			(
			wBPDNormalizeValue = state
			wBPDNormalizeFactorSpinner.enabled = state
			)
		on wBPDNormalizeFactorSpinner changed val do wBPDNormalizeFactorValue = val
		on wBPDMatchColorCheckbox changed state do wBPDMatchColorValue = state
		on wBPDMatchMatCheckbox changed state do wBPDMatchMatValue = state
		on wBPDLinkMeshCheckbox changed state do wBPDLinkMeshValue = state
		on wBPDResetXformCheckbox changed state do wBPDResetXformValue = state
		on wBAddDeformButton pressed do 
			(
			wBDeformList = #()
			wBDeformListNames = #()
			error = false
			for i in selection do
				(
				if (sLibGeometryFilter i) == false then error = true
				else 
					(
					append wBDeformList #(i.name,1)
					append wBDeformListNames (i.name + " (1)")
					)
				)
			if error == true then (MessageBox "One of your objects to be deformed is not a piece of geometry and was removed from your deform list." title:"WireBundle")
			curPos = wBFloater.pos
			wBCloseOpenUI curPos wBWireTypeValue wBAppearanceTypeValue
			)
		on wBAddDeformDelButton pressed do 
			(
			if wBDeformList.count != 0 then
				(
				deleteItem wBDeformList wBDeformListbox.selection
				deleteItem wBDeformListNames wBDeformListbox.selection
				curPos = wBFloater.pos
				wBCloseOpenUI curPos wBWireTypeValue wBAppearanceTypeValue
				)
			)
		on wBDeformListbox selected item do 
			(
			wBDeformWeightSpinner.value = wBDeformList[wBDeformListbox.selection][2]
			)
		on wBDeformWeightSpinner changed val do 
			(
			curSel = wBDeformListbox.selection
			wBDeformList[curSel][2] = val
			wBDeformWeightSpinner.value = val
			wBDeformListNames[curSel] = (wBDeformList[curSel][1] + " (" + (wBDeformList[curSel][2] as string) +")")
			wBDeformListbox.items = wBDeformListNames
			)
			
		on wBRolloutPD open do
			(
			if wBDeformList.count == 0 then wBDeformWeightSpinner.value = 1 else wBDeformWeightSpinner.value = wBDeformList[wBDeformListbox.selection][2]
			if wBPDNormalizeValue == true then wBPDNormalizeFactorSpinner.enabled = true else wBPDNormalizeFactorSpinner.enabled = false
			if wBPDTaperValue == true then wBPDTaperAmountSpinner.enabled = true else wBPDTaperAmountSpinner.enabled = false
			)
		)

	rollout wBRolloutSM "Wire Appearance"
		(
		group "SplineMesher"
		(
		spinner wBSMInitialThicknessSpinner "Initial Thickness: " range:[0.000001,9999999,wBSMInitialThicknessValue] fieldWidth:50 type:#float
		spinner wBSMFinalThicknessSpinner "Final Thickness: " range:[0.000001,9999999,wBSMFinalThicknessValue] fieldWidth:50 type:#float
		checkbox wBSMSmoothedCheckbox "Smooth?" checked:wBSMSmoothedValue align:#right
		)

		on wBSMInitialThicknessSpinner changed val do wBSMInitialThicknessValue = val
		on wBSMFinalThicknessSpinner changed val do wBSMFinalThicknessValue = val
		on wBSMSmoothedCheckbox changed state do wBSMSmoothedValue = state
		)
	
	rollout wBRolloutTools "wireMaker Tools"
		(
		group "Wire Tools"
		(
		checkbox wBTargetsNoRenderCheckbox "Targets Non Renderable?" align:#center checked:wBTargetsNoRenderValue
		button wBHideTargetsButton "Hide Ts" width:52 align:#center toolTip:"Hide / Unhide Targets" across:3
		button wBSelectWiresButton "Select" width:52 align:#center toolTip:"Select Previous WireBundle"
		button wBDeleteWiresButton "Delete" width:52 align:#center toolTip:"Delete Previous WireBundle"
		)
		on wBTargetsNoRenderCheckbox changed state do wBTargetsNoRenderValue = state
		on wBHideTargetsButton pressed do 
			(
			undo "wireMaker" on
				(
				-- If targets are hidden, unhide them, otherwise hide them
				allHidden = true
				okToProceed = true
				if (wBUniqueNodeNamesTest wBTargetList) == false then okToProceed = false
				if okToProceed == false then MessageBox "At least one object in your Targets List has a duplicate named object in the scene. You must fix this conflict before the script will work." title:"wireMaker"
				else
					(
					for i in wBTargetList do
						(
						if (getNodeByName i).ishidden == false then allHidden = false
						)
					if allHidden == false then for i in wBTargetList do (getNodeByName i).ishidden = true
					else for i in wBTargetList do (getNodeByName i).ishidden = false
					)
				)
			)
		on wBSelectWiresButton pressed do 
			(
			try
				(
				undo "wireMaker" on
					(
					select wBLastWireBundle
					)
				)
			catch (MessageBox "This operation has failed. The previous WireBundle either no longer exists, or you've closed the script floater since it was made." title:"WireBundle")
			)
		on wBDeleteWiresButton pressed do 
			(
			try
				(
				undo "wireMaker" on
					(
					for i in wBLastWireBundle do delete i
					)
				)
			catch (MessageBox "This operation has failed. The previous WireBundle either no longer exists, or you've closed the script floater since it was made." title:"WireBundle")
			)

		button wBDoButton "Do" width:70 toolTip:"Do It and Close UI" pos:[23,79]
		on wBDoButton pressed do wBDo()
		button wBApplyButton "Apply" width:70 toolTip:"Do It and Keep UI Open" pos:[95,79]
		on wBApplyButton pressed do wBApply()
		button wBHelpButton "Help" width:70 toolTip:"Help" pos:[23,103]
		on wBHelpButton pressed do wBHelp()
		button wBSaveDefButton "SaveDef" width:70 toolTip:"Save Current Settings as Default" pos:[95,103]
		on wBSaveDefButton pressed do wBSaveDef()
		)
	)
)
-------------------------------------------------------------------------------