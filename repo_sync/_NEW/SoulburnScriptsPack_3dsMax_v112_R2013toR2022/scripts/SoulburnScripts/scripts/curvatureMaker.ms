-------------------------------------------------------------------------------
-- curvatureMaker.ms
-- By Neil Blevins (info@neilblevins.com)
-- v 1.16
-- Created On: 03/14/08
-- Modified On: 10/08/17
-- tested using Max 2018
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Required Files:
-- sLib.ms
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Description:
-- Selects edges of a mesh based on the angle between adjacent faces, and then 
-- converts them to a vertex map. For example, you can select all the corner 
-- edges of a mesh and then convert them to a vertex map for use with a bump 
-- map or a mask to blend between textures.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Tutorial:
-- Make a cube with segments set to 3 in all 3 directions. Collapse to Editable
-- Poly. Run the UI version of the script. Set low value to 80 degrees. Set 
-- high value to 90. Hit Do. All the vertexes along the sharp edges will now 
-- be black, and the rest white.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Known Issues:
-- Doesn't support Editpoly since editpoly can't affect the vertex color of 
-- your mesh.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Revision History:
--
-- v 1.01 Added a few new modes for capturing open border edges, or just 
-- selecting all edges. Replaced the Close button with a Help button. Use 
-- the X button to Close the Floater.
--
-- v 1.02 Fixed a bug that would cause the script to crash when working on
-- non Editable Poly objects.
--
-- v 1.10 Redid the interface. Can now select concave and convex edges 
-- seperately. Colors can now be defined per edge type.
--
-- v 1.11 Fixed a bug where the border edge color always defaulted to black. 
-- Added ability to turn off the base color.
--
-- v 1.12 Fixed a bug where polyOp.getEdgeFaces returns undefined on some
-- meshes and then crashes the script. Now the script will continue to 
-- function even if it runs into these situations. Set the defaults to
-- turn off the Border Edges by default. Can be turned back on if you wish.
--
-- v 1.13 Added better error messages.
--
-- v 1.14 Renamed script from cornerEdgeToVertexMap to curvatureMaker. Added
-- ability to create new max 2017 Data Channel Curvature.
--
-- v 1.15 Fixed a bug in the Vertex Color mode where it wouldn't display the
-- vertex color channel properly.
--
-- v 1.16 All of the maxscript names have been changed for the Data Modifier 
-- in max 2018, so added some code to make the script compatible.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
(
-- Globals

global curvatureMaker
global curvatureMakerDefaults
global curvatureMakerUI

global cMAKCloseOpenUI

global cMAKgetAngleBetweenFaces

global cMAKDo
global cMAKApply
global cMAKHelp
global cMAKLoadDef
global cMAKSaveDef

global cMAKDefineUI
global cMAKRollout
global cMAKFloater

-- Includes

include "$scripts\SoulburnScripts\lib\sLib.ms"

-- Variables

cMAKBaseValue = true
cMAKBaseColorValue = color 255 255 255

cMAKSelectBorderValue = false
cMAKSelectBorderColorValue = color 0 0 0

cMAKSelectByConvexAngleValue = true
cMAKConvexLowValue = 265
cMAKConvexHighValue = 275
cMAKSelectByConvexAngleColorValue = color 0 0 0

cMAKSelectByConcaveAngleValue = true
cMAKConcaveLowValue = 85
cMAKConcaveHighValue = 95
cMAKSelectByConcaveAngleColorValue = color 0 0 0

cMAKDisplayValue = true
cMAKModeValue = 2
cMAKCurveScaleValue = 10.0
cMAKMapChannelValue = 66
cMAKPosValue = [400,400]

-- Functions

fn curvatureMaker cMAKBase cMAKBaseColor cMAKSelectBorder cMAKSelectBorderColor cMAKSelectByConvexAngle cMAKConvexLow cMAKConvexHigh cMAKSelectByConvexAngleColor cMAKSelectByConcaveAngle cMAKConcaveLow cMAKConcaveHigh cMAKSelectByConcaveAngleColor cMAKDisplay cMAKMode cMAKCurveScale cMAKMapChannel = 
	(
	undo "curvatureMaker" on
		(
		-- swap high and low
		if cMAKConvexLow > cMAKConvexHigh then (ConvexLowVal = cMAKConvexHigh;ConvexHighVal = cMAKConvexLow)
		else (ConvexLowVal = cMAKConvexLow;ConvexHighVal = cMAKConvexHigh)
		if cMAKConcaveLow > cMAKConcaveHigh then (ConcaveLowVal = cMAKConcaveHigh;ConcaveHighVal = cMAKConcaveLow)
		else (ConcaveLowVal = cMAKConcaveLow;ConcaveHighVal = cMAKConcaveHigh)
		
		objs = for i in selection collect i
		setCommandPanelTaskMode #modify
		objectsIgnored = 0
		if cMAKMode == 1 then
			(
			for obj in objs do
				(
				if (classof obj.baseobject) == Editable_Poly then
					(
					-- Variables
					finalAllEdges = #()
					finalBorderEdges = #()
					finalConvexAngleEdges = #()
					finalConcaveAngleEdges = #()
					finalVerts = #()

					-- Base
					if cMAKBase == true then
						(
						numEdges = polyOp.getNumEdges obj.baseobject
						for i = 1 to numEdges do append finalAllEdges i
						)				
					polyOp.setEdgeSelection obj.baseobject (finalAllEdges as bitarray)
					obj.baseobject.ConvertSelection #Edge #Vertex
					finalVerts = (polyOp.getvertselection obj.baseobject) as array
					polyop.setVertColor obj.baseobject 0 (finalVerts as bitarray) cMAKBaseColor

					-- Border Edges
					if cMAKSelectBorder == true then
						(
						finalBorderEdges = (polyop.getOpenEdges obj.baseobject) as array
						)
					polyOp.setEdgeSelection obj.baseobject (finalBorderEdges as bitarray)
					obj.baseobject.ConvertSelection #Edge #Vertex
					finalVerts = (polyOp.getvertselection obj.baseobject) as array
					polyop.setVertColor obj.baseobject 0 (finalVerts as bitarray) cMAKSelectBorderColor

					-- Convex Edges
					if cMAKSelectByConvexAngle == true then
						(				
						numEdges = polyOp.getNumEdges obj.baseobject
						for i = 1 to numEdges do
							(
							a = polyOp.getEdgeFaces obj.baseobject i
							if a != undefined then
								(
								if a.count == 2 then
									(
									theAngle = cMAKgetAngleBetweenFaces (polyOp.getFaceNormal obj.baseobject a[1]) (polyOp.getFaceNormal obj.baseobject a[2]) (polyOp.getFaceCenter obj.baseobject a[1]) (polyOp.getFaceCenter obj.baseobject a[2])
									if theAngle >= (ConvexLowVal - 0.001) and theAngle <= (ConvexHighVal + 0.001) then append finalConvexAngleEdges i
									)
								)
							)
						)
					polyOp.setEdgeSelection obj.baseobject (finalConvexAngleEdges as bitarray)
					obj.baseobject.ConvertSelection #Edge #Vertex
					finalVerts = (polyOp.getvertselection obj.baseobject) as array
					polyop.setVertColor obj.baseobject 0 (finalVerts as bitarray) cMAKSelectByConvexAngleColor

					-- Concave Edges
					if cMAKSelectByConcaveAngle == true then
						(				
						numEdges = polyOp.getNumEdges obj.baseobject
						for i = 1 to numEdges do
							(
							a = polyOp.getEdgeFaces obj.baseobject i
							if a != undefined then
								(
								if a.count == 2 then
									(
									theAngle = cMAKgetAngleBetweenFaces (polyOp.getFaceNormal obj.baseobject a[1]) (polyOp.getFaceNormal obj.baseobject a[2]) (polyOp.getFaceCenter obj.baseobject a[1]) (polyOp.getFaceCenter obj.baseobject a[2])
									if theAngle >= (ConcaveLowVal - 0.001) and theAngle <= (ConcaveHighVal + 0.001) then append finalConcaveAngleEdges i
									)
								)
							)
						)
					polyOp.setEdgeSelection obj.baseobject (finalConcaveAngleEdges as bitarray)
					obj.baseobject.ConvertSelection #Edge #Vertex
					finalVerts = (polyOp.getvertselection obj.baseobject) as array
					polyop.setVertColor obj.baseobject 0 (finalVerts as bitarray) cMAKSelectByConcaveAngleColor

					-- display the vertex map
					if cMAKDisplay == true then 
						(
						obj.vertexColorType = 0
						obj.showVertexColors = true
						)
					)
				else objectsIgnored += 1
				)
			)
		else if cMAKMode == 2 then
			(
			if (classof Data_Channel) == UndefinedClass and (classof DataChannelModifier) == UndefinedClass then (MessageBox "Only works in max 2017 Ext 1 and above." title:"curvatureMaker")
			else
				(
				max modify mode

				if sLibMaxVer() <= 19.0 then
					(
					modPanel.addModToSelection (Data_Channel ()) ui:on
					(modPanel.getCurrentObject ()).name = "cMAK_Curvature"
					
					if cMAKSelectByConvexAngle == true then (modPanel.getCurrentObject ()).minColorWidget = cMAKSelectByConvexAngleColor
					if cMAKBase == true then (modPanel.getCurrentObject ()).midColorWidget = cMAKBaseColor
					if cMAKSelectByConcaveAngle == true then (modPanel.getCurrentObject ()).maxColorWidget = cMAKSelectByConcaveAngleColor
					
					(modPanel.getCurrentObject ()).AddOperator 236108612L 0L -1
					(modPanel.getCurrentObject ()).operators[1].scaleDoubleSpinBox = cMAKCurveScale
					
					(modPanel.getCurrentObject ()).AddOperator 2882382387L 0L -1 
					(modPanel.getCurrentObject ()).operators[2].outputComboBox = 2
					(modPanel.getCurrentObject ()).operators[2].channelNumSpinBox = cMAKMapChannel
					)
				else 
					(
					modPanel.addModToSelection (DataChannelModifier ()) ui:on
					(modPanel.getCurrentObject ()).name = "cMAK_Curvature"
					
					if cMAKSelectByConvexAngle == true then (modPanel.getCurrentObject ()).minColor = cMAKSelectByConvexAngleColor
					if cMAKBase == true then (modPanel.getCurrentObject ()).midColor = cMAKBaseColor
					if cMAKSelectByConcaveAngle == true then (modPanel.getCurrentObject ()).maxColor = cMAKSelectByConcaveAngleColor

					(modPanel.getCurrentObject ()).AddOperator 236108612L 0L -1
					(modPanel.getCurrentObject ()).AddOperator 2882382387L 0L -1 

					(modPanel.getCurrentObject ()).SelectStackOperator 1
					(modPanel.getCurrentObject ()).operators[1].scale = cMAKCurveScale
					(modPanel.getCurrentObject ()).SelectStackOperator 2
					(modPanel.getCurrentObject ()).operators[2].output = 2
					(modPanel.getCurrentObject ()).operators[2].channelNum = cMAKMapChannel
					)
				)
			)
		if objectsIgnored != 0 then 
			(
			mainText = "The curvatureMaker script set to Corner Edge To Vertex Map mode only works on Editable Poly objects. " + (objectsIgnored as string) + " object(s) were ignored."
			MessageBox mainText title:"curvatureMaker"
			)
		)
	)
	
fn curvatureMakerDefaults = 
	(
	cMAKLoadDef()
	curvatureMaker cMAKBaseValue cMAKBaseColorValue cMAKSelectBorderValue cMAKSelectBorderColorValue cMAKSelectByConvexAngleValue cMAKConvexLowValue cMAKConvexHighValue cMAKSelectByConvexAngleColorValue cMAKSelectByConcaveAngleValue cMAKConcaveLowValue cMAKConcaveHighValue cMAKSelectByConcaveAngleColorValue cMAKDisplayValue cMAKModeValue cMAKCurveScaleValue cMAKMapChannelValue 
	)
	
fn curvatureMakerUI = 
	(
	cMAKLoadDef()
	cMAKCloseOpenUI cMAKPosValue
	)

fn cMAKCloseOpenUI pos = 
	(
	if cMAKFloater != undefined then CloseRolloutFloater cMAKFloater
	cMAKDefineUI()
	cMAKFloater = newRolloutFloater "curvatureMaker v1.16" 400 357 pos.x pos.y
	addRollout cMAKRollout cMAKFloater
	)

fn cMAKgetAngleBetweenFaces normal1 normal2 center1 center2 =
	(
	local face1Matrix = translate (matrixFromNormal normal1) center1
	local face2Coord = (center2 * (inverse face1Matrix)).z
	local normAngle = acos(dot (normalize normal1) (normalize normal2))
	if face2Coord < 0 do normAngle = 360 - normAngle
	normAngle 
	)

fn cMAKDo = 
	(
	curvatureMaker cMAKBaseValue cMAKBaseColorValue cMAKSelectBorderValue cMAKSelectBorderColorValue cMAKSelectByConvexAngleValue cMAKConvexLowValue cMAKConvexHighValue cMAKSelectByConvexAngleColorValue cMAKSelectByConcaveAngleValue cMAKConcaveLowValue cMAKConcaveHighValue cMAKSelectByConcaveAngleColorValue cMAKDisplayValue cMAKModeValue cMAKCurveScaleValue cMAKMapChannelValue
	if cMAKFloater != undefined then CloseRolloutFloater cMAKFloater
	)

fn cMAKApply = 
	(
	curvatureMaker cMAKBaseValue cMAKBaseColorValue cMAKSelectBorderValue cMAKSelectBorderColorValue cMAKSelectByConvexAngleValue cMAKConvexLowValue cMAKConvexHighValue cMAKSelectByConvexAngleColorValue cMAKSelectByConcaveAngleValue cMAKConcaveLowValue cMAKConcaveHighValue cMAKSelectByConcaveAngleColorValue cMAKDisplayValue cMAKModeValue cMAKCurveScaleValue cMAKMapChannelValue
	)
	
fn cMAKHelp = 
	(
	sLibSSPrintHelp "curvatureMaker"
	)
	
fn cMAKLoadDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	cMAKInputFilename = presetDir + "curvatureMaker.ini"
	if (sLibFileExist cMAKInputFilename == true) then
		(
		cMAKBaseValue = execute (getINISetting cMAKInputFilename "curvatureMaker" "cMAKBaseValue")
		cMAKBaseColorValue = execute (getINISetting cMAKInputFilename "curvatureMaker" "cMAKBaseColorValue")
		cMAKSelectBorderValue = execute (getINISetting cMAKInputFilename "curvatureMaker" "cMAKSelectBorderValue")
		cMAKSelectBorderColorValue = execute (getINISetting cMAKInputFilename "curvatureMaker" "cMAKSelectBorderColorValue")
		cMAKSelectByConvexAngleValue = execute (getINISetting cMAKInputFilename "curvatureMaker" "cMAKSelectByConvexAngleValue")
		cMAKConvexLowValue = execute (getINISetting cMAKInputFilename "curvatureMaker" "cMAKConvexLowValue")
		cMAKConvexHighValue = execute (getINISetting cMAKInputFilename "curvatureMaker" "cMAKConvexHighValue")
		cMAKSelectByConvexAngleColorValue = execute (getINISetting cMAKInputFilename "curvatureMaker" "cMAKSelectByConvexAngleColorValue")
		cMAKSelectByConcaveAngleValue = execute (getINISetting cMAKInputFilename "curvatureMaker" "cMAKSelectByConcaveAngleValue")
		cMAKConcaveLowValue = execute (getINISetting cMAKInputFilename "curvatureMaker" "cMAKConcaveLowValue")
		cMAKConcaveHighValue = execute (getINISetting cMAKInputFilename "curvatureMaker" "cMAKConcaveHighValue")
		cMAKSelectByConcaveAngleColorValue = execute (getINISetting cMAKInputFilename "curvatureMaker" "cMAKSelectByConcaveAngleColorValue")
		cMAKDisplayValue = execute (getINISetting cMAKInputFilename "curvatureMaker" "cMAKDisplayValue")
		cMAKModeValue = execute (getINISetting cMAKInputFilename "curvatureMaker" "cMAKModeValue")
		cMAKCurveScaleValue = execute (getINISetting cMAKInputFilename "curvatureMaker" "cMAKCurveScaleValue")
		cMAKMapChannelValue = execute (getINISetting cMAKInputFilename "curvatureMaker" "cMAKMapChannelValue")
		cMAKPosValue = execute (getINISetting cMAKInputFilename "curvatureMaker" "cMAKPosValue")
		
		if cMAKBaseValue == OK then cMAKBaseValue = true
		if cMAKBaseColorValue == OK then cMAKBaseColorValue = color 255 255 255
		if cMAKSelectBorderValue == OK then cMAKSelectBorderValue = false
		if cMAKSelectBorderColorValue == OK then cMAKSelectBorderColorValue = color 0 0 0
		if cMAKSelectByConvexAngleValue == OK then cMAKSelectByConvexAngleValue = true
		if cMAKConvexLowValue == OK then cMAKConvexLowValue = 265
		if cMAKConvexHighValue == OK then cMAKConvexHighValue = 275
		if cMAKSelectByConvexAngleColorValue == OK then cMAKSelectByConvexAngleColorValue = color 0 0 0
		if cMAKSelectByConcaveAngleValue == OK then cMAKSelectByConcaveAngleValue = true
		if cMAKConcaveLowValue == OK then cMAKConcaveLowValue = 85
		if cMAKConcaveHighValue == OK then cMAKConcaveHighValue = 95
		if cMAKSelectByConcaveAngleColorValue == OK then cMAKSelectByConcaveAngleColorValue = color 0 0 0
		if cMAKDisplayValue == OK then cMAKDisplayValue = true
		if cMAKModeValue == OK then cMAKModeValue = 2
		if cMAKCurveScaleValue == OK then cMAKCurveScaleValue = 10.0
		if cMAKMapChannelValue == OK then cMAKMapChannelValue = 66
		if cMAKPosValue == OK then cMAKPosValue = [400,400]
		)
	else
		(
		cMAKBaseValue = true
		cMAKBaseColorValue = color 255 255 255
		cMAKSelectBorderValue = false
		cMAKSelectBorderColorValue = color 0 0 0
		cMAKSelectByConvexAngleValue = true
		cMAKConvexLowValue = 265
		cMAKConvexHighValue = 275
		cMAKSelectByConvexAngleColorValue = color 0 0 0
		cMAKSelectByConcaveAngleValue = true
		cMAKConcaveLowValue = 85
		cMAKConcaveHighValue = 95
		cMAKSelectByConcaveAngleColorValue = color 0 0 0
		cMAKDisplayValue = true
		cMAKModeValue = 2
		cMAKCurveScaleValue = 10.0
		cMAKMapChannelValue = 66
		cMAKPosValue = [400,400]
		)
	)
	
fn cMAKSaveDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	if (getDirectories presetDir).count == 0 then makeDir presetDir
	cMAKOutputFilename = presetDir + "curvatureMaker.ini"
	if (sLibFileExist cMAKOutputFilename == true) then deleteFile cMAKOutputFilename
	setINISetting cMAKOutputFilename "curvatureMaker" "cMAKBaseValue" (cMAKBaseValue as string)
	setINISetting cMAKOutputFilename "curvatureMaker" "cMAKBaseColorValue" (cMAKBaseColorValue as string)
	setINISetting cMAKOutputFilename "curvatureMaker" "cMAKSelectBorderValue" (cMAKSelectBorderValue as string)
	setINISetting cMAKOutputFilename "curvatureMaker" "cMAKSelectBorderColorValue" (cMAKSelectBorderColorValue as string)
	setINISetting cMAKOutputFilename "curvatureMaker" "cMAKSelectByConvexAngleValue" (cMAKSelectByConvexAngleValue as string)
	setINISetting cMAKOutputFilename "curvatureMaker" "cMAKConvexLowValue" (cMAKConvexLowValue as string)
	setINISetting cMAKOutputFilename "curvatureMaker" "cMAKConvexHighValue" (cMAKConvexHighValue as string)
	setINISetting cMAKOutputFilename "curvatureMaker" "cMAKSelectByConvexAngleColorValue" (cMAKSelectByConvexAngleColorValue as string)
	setINISetting cMAKOutputFilename "curvatureMaker" "cMAKSelectByConcaveAngleValue" (cMAKSelectByConcaveAngleValue as string)
	setINISetting cMAKOutputFilename "curvatureMaker" "cMAKConcaveLowValue" (cMAKConcaveLowValue as string)
	setINISetting cMAKOutputFilename "curvatureMaker" "cMAKConcaveHighValue" (cMAKConcaveHighValue as string)
	setINISetting cMAKOutputFilename "curvatureMaker" "cMAKSelectByConcaveAngleColorValue" (cMAKSelectByConcaveAngleColorValue as string)
	setINISetting cMAKOutputFilename "curvatureMaker" "cMAKDisplayValue" (cMAKDisplayValue as string)
	setINISetting cMAKOutputFilename "curvatureMaker" "cMAKModeValue" (cMAKModeValue as string)
	setINISetting cMAKOutputFilename "curvatureMaker" "cMAKCurveScaleValue" (cMAKCurveScaleValue as string)
	setINISetting cMAKOutputFilename "curvatureMaker" "cMAKMapChannelValue" (cMAKMapChannelValue as string)
	setINISetting cMAKOutputFilename "curvatureMaker" "cMAKPosValue" (cMAKFloater.pos as string)
	)

-- UI

fn cMAKDefineUI = 
	(
	rollout cMAKRollout "curvatureMaker"
		(
		dropdownlist cMAKModeDropdown "" items:#("Corner Edge To Vertex Map", "Data Channel") selection:cMAKModeValue
		on cMAKModeDropdown selected i do 
			(
			cMAKModeValue = i
			curPos = cMAKFloater.pos
			cMAKCloseOpenUI curPos
			)
		
		group "Base Color"
		(
		checkbox cMAKBaseCheckbox "Base Color:" align:#left across:2 checked:cMAKBaseValue
		colorpicker cMAKBaseColorPicker "Color:" color:cMAKBaseColorValue modal:false align:#left fieldwidth:40 height:15 offset:[-80,0]
		)
		on cMAKBaseCheckbox changed state do 
			(
			cMAKBaseValue = state
			cMAKBaseColorPicker.enabled = state
			)
		on cMAKBaseColorPicker changed val do cMAKBaseColorValue = val

		group "Convex Edges"
		(
		checkbox cMAKSelectByConvexAngleCheckbox "Convex Angle:" align:#left across:4 checked:cMAKSelectByConvexAngleValue
		colorpicker cMAKSelectByConvexAngleColorPicker "Color:" color:cMAKSelectByConvexAngleColorValue modal:false align:#left fieldwidth:40 height:15 offset:[10,0]
		spinner cMAKConvexLowSpinner "Low: " range:[0,360,cMAKConvexLowValue] fieldWidth:45 type:#float align:#right
		spinner cMAKConvexHighSpinner "High: " range:[0,360,cMAKConvexHighValue] fieldWidth:45 type:#float align:#right
		)
		on cMAKSelectByConvexAngleCheckbox changed state do 
			(
			if cMAKModeValue == 1 then
				(
				cMAKSelectByConvexAngleValue = state
				cMAKSelectByConvexAngleColorPicker.enabled = state
				cMAKConvexLowSpinner.enabled = state
				cMAKConvexHighSpinner.enabled = state
				)
			else if cMAKModeValue == 2 then
				(
				cMAKSelectByConvexAngleValue = state
				cMAKSelectByConvexAngleColorPicker.enabled = state
				cMAKConvexLowSpinner.enabled = false
				cMAKConvexHighSpinner.enabled = false
				)
			)
		on cMAKConvexLowSpinner changed val do cMAKConvexLowValue = val
		on cMAKConvexHighSpinner changed val do cMAKConvexHighValue = val
		on cMAKSelectByConvexAngleColorPicker changed val do cMAKSelectByConvexAngleColorValue = val

		group "Concave Edges"
		(
		checkbox cMAKSelectByConcaveAngleCheckbox "Concave Angle:" align:#left across:4 checked:cMAKSelectByConcaveAngleValue
		colorpicker cMAKSelectByConcaveAngleColorPicker "Color:" color:cMAKSelectByConcaveAngleColorValue modal:false align:#left fieldwidth:40 height:15 offset:[10,0]
		spinner cMAKConcaveLowSpinner "Low: " range:[0,360,cMAKConcaveLowValue] fieldWidth:45 type:#float align:#right
		spinner cMAKConcaveHighSpinner "High: " range:[0,360,cMAKConcaveHighValue] fieldWidth:45 type:#float align:#right
		)
		on cMAKSelectByConcaveAngleCheckbox changed state do 
			(
			if cMAKModeValue == 1 then
				(
				cMAKSelectByConcaveAngleValue = state
				cMAKSelectByConcaveAngleColorPicker.enabled = state
				cMAKConcaveLowSpinner.enabled = state
				cMAKConcaveHighSpinner.enabled = state
				)
			else if cMAKModeValue == 2 then
				(
				cMAKSelectByConcaveAngleValue = state
				cMAKSelectByConcaveAngleColorPicker.enabled = state
				cMAKConcaveLowSpinner.enabled = false
				cMAKConcaveHighSpinner.enabled = false				
				)
			)
		on cMAKConcaveLowSpinner changed val do cMAKConcaveLowValue = val
		on cMAKConcaveHighSpinner changed val do cMAKConcaveHighValue = val
		on cMAKSelectByConcaveAngleColorPicker changed val do cMAKSelectByConcaveAngleColorValue = val

		group "Corner Edge To Vertex Map"
		(
		checkbox cMAKSelectBorderCheckbox "Border Edges:" align:#left across:2 checked:cMAKSelectBorderValue
		colorpicker cMAKSelectBorderColorPicker "Color:" color:cMAKSelectBorderColorValue modal:false align:#left fieldwidth:40 height:15 offset:[-80,0]
		checkbox cMAKDisplayCheckbox "Display Vertex Colors?" align:#left checked:cMAKDisplayValue
		)
		on cMAKSelectBorderCheckbox changed state do 
			(
			cMAKSelectBorderValue = state
			cMAKSelectBorderColorPicker.enabled = state
			)
		on cMAKSelectBorderColorPicker changed val do cMAKSelectBorderColorValue = val
		on cMAKDisplayCheckbox changed state do cMAKDisplayValue = state

		group "Data Channel"
		(
		spinner cMAKCurveScaleSpinner "Curvature Scale: " range:[0,100,cMAKCurveScaleValue] fieldWidth:45 type:#float align:#left
		spinner cMAKMapChannelSpinner "Map Channel: " range:[-2,98,cMAKMapChannelValue] fieldWidth:45 type:#integer align:#left
		)
		on cMAKCurveScaleSpinner changed val do cMAKCurveScaleValue = val
		on cMAKMapChannelSpinner changed val do cMAKMapChannelValue = val

		button cMAKDoButton "Do" width:70 toolTip:"Do It and Close UI" pos:[50,305]
		on cMAKDoButton pressed do cMAKDo()
		button cMAKApplyButton "Apply" width:70 toolTip:"Do It and Keep UI Open" pos:[122,305]
		on cMAKApplyButton pressed do cMAKApply()
		button cMAKHelpButton "Help" width:70 toolTip:"Help" pos:[194,305]
		on cMAKHelpButton pressed do cMAKHelp()
		button cMAKSaveDefButton "SaveDef" width:70 toolTip:"Save Current Settings as Default" pos:[267,305]
		on cMAKSaveDefButton pressed do cMAKSaveDef()
		
		on cMAKRollout open do
			(
			if cMAKModeValue == 1 then
				(
				cMAKBaseColorPicker.enabled = cMAKBaseValue
			
				cMAKSelectByConvexAngleColorPicker.enabled = cMAKSelectByConvexAngleValue
				cMAKConvexLowSpinner.enabled = cMAKSelectByConvexAngleValue
				cMAKConvexHighSpinner.enabled = cMAKSelectByConvexAngleValue
			
				cMAKSelectByConcaveAngleColorPicker.enabled = cMAKSelectByConcaveAngleValue
				cMAKConcaveLowSpinner.enabled = cMAKSelectByConcaveAngleValue
				cMAKConcaveHighSpinner.enabled = cMAKSelectByConcaveAngleValue
			
				cMAKSelectBorderCheckbox.enabled = true
				cMAKSelectBorderColorPicker.enabled = cMAKSelectBorderValue
				cMAKDisplayCheckbox.enabled = true
				
				cMAKCurveScaleSpinner.enabled = false
				cMAKMapChannelSpinner.enabled = false
				)
			else if cMAKModeValue == 2 then
				(
				cMAKBaseColorPicker.enabled = cMAKBaseValue
			
				cMAKSelectByConvexAngleColorPicker.enabled = cMAKSelectByConvexAngleValue
				cMAKConvexLowSpinner.enabled = false
				cMAKConvexHighSpinner.enabled = false	
			
				cMAKSelectByConcaveAngleColorPicker.enabled = cMAKSelectByConcaveAngleValue
				cMAKConcaveLowSpinner.enabled = false
				cMAKConcaveHighSpinner.enabled = false
			
				cMAKSelectBorderCheckbox.enabled = false
				cMAKSelectBorderColorPicker.enabled = false
				cMAKDisplayCheckbox.enabled = false
				
				cMAKCurveScaleSpinner.enabled = true
				cMAKMapChannelSpinner.enabled = true
				)
			)
		)
	)
)
-------------------------------------------------------------------------------