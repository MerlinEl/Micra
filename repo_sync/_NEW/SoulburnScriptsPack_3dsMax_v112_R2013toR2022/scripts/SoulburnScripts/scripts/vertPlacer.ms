-------------------------------------------------------------------------------
-- vertPlacer.ms
-- By Neil Blevins (info@neilblevins.com)
-- v 1.07
-- Created On: 08/01/07
-- Modified On: 02/09/19
-- tested using Max 2017
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Required Files:
-- sLib.ms
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Description:
-- Allows you to move the vertexes in an object or the knots in a spline to
-- a single value, either the average of the current values, or a specific 
-- value. Good for flattening out groups of vertexes.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Tutorial:
-- Select an object. Select several vertexes. Run the UI version of the script.
-- Press the Z button. Choose average. Hit Do. All the vertexes snap the the 
-- average Z value of the selected vertexes.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Revision History:
--
-- v 1.01 Added single and all axis mode.
--
-- v 1.02 Now when you have multiple knots selected in multiple shapes in a 
-- single spline, they get averaged properly.
--
-- v 1.03 Reorganized the way it determines what sorts of objects it can and
-- cannot modify. Now works with EditPoly in max9.
--
-- v 1.04 Added sLibMaxVer test.
--
-- v 1.05 Replaced the Close button with a Help button. Use the X button to 
-- Close the Floater.
--
-- v 1.06 You can now choose where it places the vertex by clicking the mouse
-- in the viewport.
--
-- v 1.07 Added ability to place verts at Min or Max, not just Average.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Known Issues:
-- Editpoly support is only in max9 and above, and this will not change due
-- to lack of editpoly maxscript support in earlier versions of max. Currently 
-- doesn't work with editmesh or editspline modifiers, as neither are accessible
-- to maxscript.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
(
-- Globals

global vertPlacer
global vertPlacerDefaults
global vertPlacerUI

global vPCloseOpenUI

global vPGetSelectedVertexesEditableMesh
global vPGetSelectedVertexesEditablePoly
global vPGetSelectedVertexesEditPoly
global vPGetSelectedVertexesEditableSpline

global vPPlaceVertexesEditableMesh
global vPPlaceVertexesEditablePoly
global vPPlaceVertexesEditPoly
global vPPlaceVertexesEditableSpline

global vPDo
global vPApply
global vPHelp
global vPLoadDef
global vPSaveDef

global vPDefineUI
global vPRollout
global vPFloater

global vPAverageX = 0.00
global vPAverageY = 0.00
global vPAverageZ = 0.00
global vPMousePickX = 0.00
global vPMousePickY = 0.00
global vPMousePickZ = 0.00

-- Includes

include "$scripts\SoulburnScripts\lib\sLib.ms"

-- Variables

vPModifyXValue = false
vPModifyYValue = false
vPModifyZValue = true
vPActionValue = 1
vPPlaceValue = 0.00
vPModeValue = 1
vPPosValue = [400,400]

-- Functions

fn vertPlacer vPModifyX vPModifyY vPModifyZ vPAction vPPlace = 
	(
	undo "vertPlacer" on
		(
		if selection.count != 1 then (MessageBox "Please select only one object." title:"VertPlacer")
		else 
			(
			obj = selection[1]
			disableSceneRedraw()
			try
				(
				objType = 0
				-- Determine Object Type
				
				-- Editable Mesh
				if classof (modPanel.getCurrentObject ()) == Editable_mesh then objType = 1
				-- Edit Mesh
				else if classof (modPanel.getCurrentObject ()) == Edit_Mesh then objType = 2
				-- Editable Poly
				else if classof (modPanel.getCurrentObject ()) == Editable_Poly then objType = 3
				-- Edit Poly
				else if classof (modPanel.getCurrentObject ()) == Edit_Poly then objType = 4				
				-- Editable Spline
				else if classof (modPanel.getCurrentObject ()) == line or classof (modPanel.getCurrentObject ()) == SplineShape then objType = 5
				-- Edit Spline
				else if classof (modPanel.getCurrentObject ()) == Edit_Spline then objType = 6
				
				-- Do Proper Function
				
				if objType == 1 then 
					(
					vPPlaceVertexesEditableMesh obj vPModifyX vPModifyY vPModifyZ vPAction vPPlace
					)
				else if objType == 2 then 
					(
					MessageBox "This script doesn't work with edit mesh modifiers." title:"VertPlacer"
					)
				else if objType == 3 then 
					(
					vPPlaceVertexesEditablePoly obj vPModifyX vPModifyY vPModifyZ vPAction vPPlace
					)
				else if objType == 4 then 
					(
					if sLibMaxVer() < 9.0 then (MessageBox "This script doesn't work with edit poly modifiers in max8 or below. Please use max 9 or above." title:"VertPlacer")
					else vPPlaceVertexesEditPoly obj vPModifyX vPModifyY vPModifyZ vPAction vPPlace
					)
				else if objType == 5 then 
					(
					vPPlaceVertexesEditableSpline obj vPModifyX vPModifyY vPModifyZ vPAction vPPlace
					)
				else if objType == 6 then 
					(
					MessageBox "This script doesn't work with edit spline modifiers." title:"VertPlacer"
					)
				else (MessageBox "The object type you have selected cannot be affected by this script" title:"VertPlacer")
				)
			catch ()
			enableSceneRedraw()
			completeRedraw()
			)
		)
	)
	
fn vertPlacerDefaults = 
	(
	vPLoadDef()
	vertPlacer vPModifyXValue vPModifyYValue vPModifyZValue vPActionValue vPPlaceValue
	)
	
fn vertPlacerUI = 
	(
	vPLoadDef()
	vPCloseOpenUI vPPosValue
	)

fn vPCloseOpenUI pos = 
	(
	if vPFloater != undefined then CloseRolloutFloater vPFloater
	vPDefineUI()
	vPFloater = newRolloutFloater "vertPlacer v1.07" 340 120 pos.x pos.y
	addRollout vPRollout vPFloater
	)
	
fn vPGetSelectedVertexesEditableMesh obj = 
	(
	Verts = #{}
	if classof (modPanel.getCurrentObject ()) == Editable_mesh then Verts = getvertselection obj
	return Verts
	)
	
fn vPGetSelectedVertexesEditablePoly obj = 
	(
	Verts = #{}
	if classof (modPanel.getCurrentObject ()) == Editable_Poly then Verts = getvertselection obj
	return Verts
	)

fn vPGetSelectedVertexesEditPoly obj = 
	(
	Verts = #{}
	if classof (modPanel.getCurrentObject ()) == Edit_Poly then 
		(
		currentModIndex = (modPanel.getModifierIndex obj (modPanel.getCurrentObject()))
		myMod = obj.modifiers[currentModIndex]
		Verts = myMod.GetSelection #Vertex
		)
	return Verts
	)

fn vPGetSelectedVertexesEditableSpline obj thespline = 
	(
	Verts = #{}
	if classof (modPanel.getCurrentObject ()) == line or classof (modPanel.getCurrentObject ()) == SplineShape then Verts = getKnotSelection obj thespline
	return Verts
	)
	
fn vPPlaceVertexesEditableMesh obj vPModifyX vPModifyY vPModifyZ vPAction vPPlace = 
	(
	Verts = (vPGetSelectedVertexesEditableMesh obj)
	if Verts.count != 0 then
		(
		vPAllXValues = #()
		vPAllYValues = #()
		vPAllZValues = #()

		-- Calculate Averages
		if vPAction == 1 or vPAction == 4 or vPAction == 5 then
			(
			if vPModifyX == true then 
				(
				for i in Verts do append vPAllXValues (meshop.getvert obj i).x
				vPAverageX = sLibAverageMinMaxOfArray vPAllXValues
				vPMinX = amin vPAllXValues
				vPMaxX = amax vPAllXValues
				)
			if vPModifyY == true then 
				(
				for i in Verts do append vPAllYValues (meshop.getvert obj i).y
				vPAverageY = sLibAverageMinMaxOfArray vPAllYValues
				vPMinY = amin vPAllYValues
				vPMaxY = amax vPAllYValues
				)
			if vPModifyZ == true then 
				(
				for i in Verts do append vPAllZValues (meshop.getvert obj i).z
				vPAverageZ = sLibAverageMinMaxOfArray vPAllZValues
				vPMinZ = amin vPAllZValues
				vPMaxZ = amax vPAllZValues
				)
			)

		-- Do Mouse Click		
		if vPAction == 3 then
			(
			tool vPMouseClick (on mousePoint clickno do (vPMousePickX = worldPoint.x;vPMousePickY = worldPoint.y;vPMousePickZ = worldPoint.z;#stop))
			startTool vPMouseClick snap:#3D
			)

		-- Modify Verts
		for i in Verts do 
			(
			vPFinalX = (meshop.getvert obj i).x
			vPFinalY = (meshop.getvert obj i).y
			vPFinalZ = (meshop.getvert obj i).z
			if vPModifyX == true then 
				( 
				if vPAction == 1 then vPFinalX = vPAverageX
				else if vPAction == 2 then vPFinalX = vPPlace
				else if vPAction == 3 then vPFinalX = vPMousePickX
				else if vPAction == 4 then vPFinalX = vPMinX
				else if vPAction == 5 then vPFinalX = vPMaxX
				)
			if vPModifyY == true then 
				( 
				if vPAction == 1 then vPFinalY = vPAverageY
				else if vPAction == 2 then vPFinalY = vPPlace
				else if vPAction == 3 then vPFinalY = vPMousePickY
				else if vPAction == 4 then vPFinalY = vPMinY
				else if vPAction == 5 then vPFinalY = vPMaxY
				)
			if vPModifyZ == true then 
				( 
				if vPAction == 1 then vPFinalZ = vPAverageZ
				else if vPAction == 2 then vPFinalZ = vPPlace
				else if vPAction == 3 then vPFinalZ = vPMousePickZ
				else if vPAction == 4 then vPFinalZ = vPMinZ
				else if vPAction == 5 then vPFinalZ = vPMaxZ
				)
			meshop.setvert obj i [vPFinalX,vPFinalY,vPFinalZ]
			)
		)
	)

fn vPPlaceVertexesEditablePoly obj vPModifyX vPModifyY vPModifyZ vPAction vPPlace = 
	(
	Verts = (vPGetSelectedVertexesEditablePoly obj)
	if Verts.count != 0 then
		(
		vPAllXValues = #()
		vPAllYValues = #()
		vPAllZValues = #()

		-- Calculate Averages
		if vPAction == 1 or vPAction == 4 or vPAction == 5 then
			(
			if vPModifyX == true then 
				(
				for i in Verts do append vPAllXValues (polyop.getvert obj i).x
				vPAverageX = sLibAverageMinMaxOfArray vPAllXValues
				vPMinX = amin vPAllXValues
				vPMaxX = amax vPAllXValues
				)
			if vPModifyY == true then 
				(
				for i in Verts do append vPAllYValues (polyop.getvert obj i).y
				vPAverageY = sLibAverageMinMaxOfArray vPAllYValues	
				vPMinY = amin vPAllYValues
				vPMaxY = amax vPAllYValues
				)
			if vPModifyZ == true then 
				(
				for i in Verts do append vPAllZValues (polyop.getvert obj i).z
				vPAverageZ = sLibAverageMinMaxOfArray vPAllZValues	
				vPMinZ = amin vPAllZValues
				vPMaxZ = amax vPAllZValues
				)
			)
		
		-- Do Mouse Click
		if vPAction == 3 then
			(
			tool vPMouseClick (on mousePoint clickno do (vPMousePickX = worldPoint.x;vPMousePickY = worldPoint.y;vPMousePickZ = worldPoint.z;#stop))
			startTool vPMouseClick snap:#3D
			)

		-- Modify Verts
		for i in Verts do 
			(
			vPFinalX = (polyop.getvert obj i).x
			vPFinalY = (polyop.getvert obj i).y
			vPFinalZ = (polyop.getvert obj i).z
			if vPModifyX == true then 
				( 
				if vPAction == 1 then vPFinalX = vPAverageX
				else if vPAction == 2 then vPFinalX = vPPlace
				else if vPAction == 3 then vPFinalX = vPMousePickX
				else if vPAction == 4 then vPFinalX = vPMinX
				else if vPAction == 5 then vPFinalX = vPMaxX
				)
			if vPModifyY == true then 
				( 
				if vPAction == 1 then vPFinalY = vPAverageY
				else if vPAction == 2 then vPFinalY = vPPlace
				else if vPAction == 3 then vPFinalY = vPMousePickY
				else if vPAction == 4 then vPFinalY = vPMinY
				else if vPAction == 5 then vPFinalY = vPMaxY
				)
			if vPModifyZ == true then 
				( 
				if vPAction == 1 then vPFinalZ = vPAverageZ
				else if vPAction == 2 then vPFinalZ = vPPlace
				else if vPAction == 3 then vPFinalZ = vPMousePickZ
				else if vPAction == 4 then vPFinalZ = vPMinZ
				else if vPAction == 5 then vPFinalZ = vPMaxZ
				)
			polyop.setvert obj i [vPFinalX,vPFinalY,vPFinalZ]
			)
		)
	)

fn vPPlaceVertexesEditPoly obj vPModifyX vPModifyY vPModifyZ vPAction vPPlace = 
	(
	Verts = (vPGetSelectedVertexesEditPoly obj)
	if Verts.count != 0 then
		(
		vPAllXValues = #()
		vPAllYValues = #()
		vPAllZValues = #()
		currentModIndex = (modPanel.getModifierIndex obj (modPanel.getCurrentObject()))
		myMod = obj.modifiers[currentModIndex]
		
		-- Calculate Averages
		if vPAction == 1 or vPAction == 4 or vPAction == 5 then
			(
			if vPModifyX == true then 
				(
				for i in Verts do append vPAllXValues (myMod.GetVertex i).x
				vPAverageX = sLibAverageMinMaxOfArray vPAllXValues
				vPMinX = amin vPAllXValues
				vPMaxX = amax vPAllXValues
				)
			if vPModifyY == true then 
				(
				for i in Verts do append vPAllYValues (myMod.GetVertex i).y
				vPAverageY = sLibAverageMinMaxOfArray vPAllYValues	
				vPMinY = amin vPAllYValues
				vPMaxY = amax vPAllYValues
				)
			if vPModifyZ == true then 
				(
				for i in Verts do append vPAllZValues (myMod.GetVertex i).z
				vPAverageZ = sLibAverageMinMaxOfArray vPAllZValues
				vPMinZ = amin vPAllZValues
				vPMaxZ = amax vPAllZValues
				)
			)

		-- Do Mouse Click		
		if vPAction == 3 then
			(
			tool vPMouseClick (on mousePoint clickno do (vPMousePickX = worldPoint.x;vPMousePickY = worldPoint.y;vPMousePickZ = worldPoint.z;#stop))
			startTool vPMouseClick snap:#3D
			)

		-- Modify Verts
		for i in Verts do 
			(
			vPFinalX = (myMod.GetVertex i).x
			vPFinalY = (myMod.GetVertex i).y
			vPFinalZ = (myMod.GetVertex i).z
			if vPModifyX == true then 
				( 
				if vPAction == 1 then vPFinalX = vPAverageX
				else if vPAction == 2 then vPFinalX = vPPlace
				else if vPAction == 3 then vPFinalX = vPMousePickX
				else if vPAction == 4 then vPFinalX = vPMinX
				else if vPAction == 5 then vPFinalX = vPMaxX
				)
			if vPModifyY == true then 
				( 
				if vPAction == 1 then vPFinalY = vPAverageY
				else if vPAction == 2 then vPFinalY = vPPlace
				else if vPAction == 3 then vPFinalY = vPMousePickY
				else if vPAction == 4 then vPFinalY = vPMinY
				else if vPAction == 5 then vPFinalY = vPMaxY
				)
			if vPModifyZ == true then 
				( 
				if vPAction == 1 then vPFinalZ = vPAverageZ
				else if vPAction == 2 then vPFinalZ = vPPlace
				else if vPAction == 3 then vPFinalZ = vPMousePickZ
				else if vPAction == 4 then vPFinalZ = vPMinZ
				else if vPAction == 5 then vPFinalZ = vPMaxZ
				)
			myMod.SetVert #{i} [vPFinalX,vPFinalY,vPFinalZ]
			)
		)
	)
	
fn vPPlaceVertexesEditableSpline obj vPModifyX vPModifyY vPModifyZ vPAction vPPlace = 
	(
	numOfSplines = (numSplines obj)
	if numOfSplines != 0 then
		(
		MyKnots = #()
		for w = 1 to numOfSplines do
			(
			SplineKnots = (vPGetSelectedVertexesEditableSpline obj w)
			for i in SplineKnots do
				(
				append MyKnots #(w, i)
				)
			)
		if MyKnots.count != 0 then
			(
			vPAllXValues = #()
			vPAllYValues = #()
			vPAllZValues = #()

			-- Calculate Averages
			if vPAction == 1 or vPAction == 4 or vPAction == 5 then
				(
				if vPModifyX == true then 
					(
					for i = 1 to MyKnots.count do (append vPAllXValues (getKnotPoint obj MyKnots[i][1] MyKnots[i][2]).x)
					vPAverageX = sLibAverageMinMaxOfArray vPAllXValues
					vPMinX = amin vPAllXValues
					vPMaxX = amax vPAllXValues
					)
				if vPModifyY == true then 
					(
					for i = 1 to MyKnots.count do (append vPAllYValues (getKnotPoint obj MyKnots[i][1] MyKnots[i][2]).y)
					vPAverageY = sLibAverageMinMaxOfArray vPAllYValues
					vPMinY = amin vPAllYValues
					vPMaxY = amax vPAllYValues
					)
				if vPModifyZ == true then 
					(
					for i = 1 to MyKnots.count do (append vPAllZValues (getKnotPoint obj MyKnots[i][1] MyKnots[i][2]).z)
					vPAverageZ = sLibAverageMinMaxOfArray vPAllZValues
					vPMinZ = amin vPAllZValues
					vPMaxZ = amax vPAllZValues
					)
				)

			-- Do Mouse Click		
			if vPAction == 3 then
				(
				tool vPMouseClick (on mousePoint clickno do (vPMousePickX = worldPoint.x;vPMousePickY = worldPoint.y;vPMousePickZ = worldPoint.z;#stop))
				startTool vPMouseClick snap:#3D
				)

			-- Modify Verts
			for i = 1 to Myknots.count do 
				(
				vPFinalX = (getKnotPoint obj MyKnots[i][1] MyKnots[i][2]).x
				vPFinalY = (getKnotPoint obj MyKnots[i][1] MyKnots[i][2]).y
				vPFinalZ = (getKnotPoint obj MyKnots[i][1] MyKnots[i][2]).z
				if vPModifyX == true then 
					( 
					if vPAction == 1 then vPFinalX = vPAverageX
					else if vPAction == 2 then vPFinalX = vPPlace
					else if vPAction == 3 then vPFinalX = vPMousePickX
					else if vPAction == 4 then vPFinalX = vPMinX
					else if vPAction == 5 then vPFinalX = vPMaxX
					)
				if vPModifyY == true then 
					( 
					if vPAction == 1 then vPFinalY = vPAverageY
					else if vPAction == 2 then vPFinalY = vPPlace
					else if vPAction == 3 then vPFinalY = vPMousePickY
					else if vPAction == 4 then vPFinalY = vPMinY
					else if vPAction == 5 then vPFinalY = vPMaxY
					)
				if vPModifyZ == true then 
					( 
					if vPAction == 1 then vPFinalZ = vPAverageZ
					else if vPAction == 2 then vPFinalZ = vPPlace
					else if vPAction == 3 then vPFinalZ = vPMousePickZ
					else if vPAction == 4 then vPFinalZ = vPMinZ
					else if vPAction == 5 then vPFinalZ = vPMaxZ
					)
				setKnotPoint obj MyKnots[i][1] MyKnots[i][2] [vPFinalX,vPFinalY,vPFinalZ]
				)
			)
		)
	updateshape obj
	)
	
fn vPDo = 
	(
	vertPlacer vPModifyXValue vPModifyYValue vPModifyZValue vPActionValue vPPlaceValue
	if vPFloater != undefined then CloseRolloutFloater vPFloater
	)

fn vPApply = 
	(
	vertPlacer vPModifyXValue vPModifyYValue vPModifyZValue vPActionValue vPPlaceValue
	)
	
fn vPHelp = 
	(
	sLibSSPrintHelp "vertPlacer"
	)
	
fn vPLoadDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	vPInputFilename = presetDir + "vertPlacer.ini"
	if (sLibFileExist vPInputFilename == true) then
		(
		vPModifyXValue = execute (getINISetting vPInputFilename "vertPlacer" "vPModifyXValue")
		vPModifyYValue = execute (getINISetting vPInputFilename "vertPlacer" "vPModifyYValue")
		vPModifyZValue = execute (getINISetting vPInputFilename "vertPlacer" "vPModifyZValue")
		vPActionValue = execute (getINISetting vPInputFilename "vertPlacer" "vPActionValue")
		vPPlaceValue = execute (getINISetting vPInputFilename "vertPlacer" "vPPlaceValue")
		vPModeValue = execute (getINISetting vPInputFilename "vertPlacer" "vPModeValue")
		vPPosValue = execute (getINISetting vPInputFilename "vertPlacer" "vPPosValue")
		
		if vPModifyXValue == OK then vPModifyXValue = false
		if vPModifyYValue == OK then vPModifyYValue = false
		if vPModifyZValue == OK then vPModifyZValue = true
		if vPActionValue == OK then vPActionValue = 1
		if vPPlaceValue == OK then vPPlaceValue = 0.00
		if vPModeValue == OK then vPModeValue = 1
		if vPPosValue == OK then vPPosValue = [400,400]
		)
	else
		(
		vPModifyXValue = false
		vPModifyYValue = false
		vPModifyZValue = true
		vPActionValue = 1
		vPPlaceValue = 0.00
		vPModeValue = 1
		vPPosValue = [400,400]
		)
	)
	
fn vPSaveDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	if (getDirectories presetDir).count == 0 then makeDir presetDir
	vPOutputFilename = presetDir + "vertPlacer.ini"
	if (sLibFileExist vPOutputFilename == true) then deleteFile vPOutputFilename
	setINISetting vPOutputFilename "vertPlacer" "vPModifyXValue" (vPModifyXValue as string)
	setINISetting vPOutputFilename "vertPlacer" "vPModifyYValue" (vPModifyYValue as string)
	setINISetting vPOutputFilename "vertPlacer" "vPModifyZValue" (vPModifyZValue as string)
	setINISetting vPOutputFilename "vertPlacer" "vPActionValue" (vPActionValue as string)
	setINISetting vPOutputFilename "vertPlacer" "vPPlaceValue" (vPPlaceValue as string)
	setINISetting vPOutputFilename "vertPlacer" "vPModeValue" (vPModeValue as string)
	setINISetting vPOutputFilename "vertPlacer" "vPPosValue" (vPFloater.pos as string)
	)

-- UI

fn vPDefineUI = 
	(
	rollout vPRollout "vertPlacer"
		(
		checkbutton vPModifyXButton "X" checked:vPModifyXValue width:90 across:3
		checkbutton vPModifyYButton "Y" checked:vPModifyYValue width:90
		checkbutton vPModifyZButton "Z" checked:vPModifyZValue width:90
		label label1 "Action:" pos:[10,38]
		dropdownlist vPActionDropdown "" items:#("Average", "Place", "Mouse Click", "Minimum", "Maximum") selection:vPActionValue pos:[45,35] width:90
		spinner vPPlaceSpinner "" range:[-999999999,999999999,vPPlaceValue] fieldWidth:70 type:#float pos:[135,37]
		dropdownlist vPModeDropdown "" items:#("1 Axis Mode", "3 Axis Mode") selection:vPModeValue width:92 pos:[223,35]

		on vPModifyXButton changed state do 
			(
			if state == true then
				(
				if vPModeValue == 1 then (vPModifyXButton.checked = true;vPModifyYButton.checked = false;vPModifyZButton.checked = false;vPModifyXValue = true;vPModifyYValue = false;vPModifyZValue = false)
				else vPModifyXValue = state
				)
			else 
				(
				vPModifyXValue = state
				)
			)
		on vPModifyYButton changed state do 
			(
			if state == true then
				(
				if vPModeValue == 1 then (vPModifyXButton.checked = false;vPModifyYButton.checked = true;vPModifyZButton.checked = false;vPModifyXValue = false;vPModifyYValue = true;vPModifyZValue = false)
				else vPModifyYValue = state
				)
			else 
				(
				vPModifyYValue = state
				)
			)
		on vPModifyZButton changed state do 
			(
			if state == true then
				(
				if vPModeValue == 1 then (vPModifyXButton.checked = false;vPModifyYButton.checked = false;vPModifyZButton.checked = true;vPModifyXValue = false;vPModifyYValue = false;vPModifyZValue = true)
				else vPModifyZValue = state
				)
			else 
				(
				vPModifyZValue = state
				)
			)
		on vPActionDropdown selected i do 
			(
			if i == 2 then vPPlaceSpinner.enabled = true
			else vPPlaceSpinner.enabled = false
			vPActionValue = i
			)
		on vPPlaceSpinner changed val do vPPlaceValue = val
		on vPModeDropdown selected i do 
			(
			vPModeValue = i
			if vPModeValue == 1 then 
				(
				if vPModifyXValue == true then (vPModifyXButton.checked = true;vPModifyYButton.checked = false;vPModifyZButton.checked = false;vPModifyXValue = true;vPModifyYValue = false;vPModifyZValue = false)
				else if vPModifyYValue == true then (vPModifyXButton.checked = false;vPModifyYButton.checked = true;vPModifyZButton.checked = false;vPModifyXValue = false;vPModifyYValue = true;vPModifyZValue = false)
				else if vPModifyZValue == true then (vPModifyXButton.checked = false;vPModifyYButton.checked = false;vPModifyZButton.checked = true;vPModifyXValue = false;vPModifyYValue = false;vPModifyZValue = true)
				)
			)

		button vPDoButton "Do" width:70 toolTip:"Do It and Close UI" pos:[20,63]
		on vPDoButton pressed do vPDo()
		button vPApplyButton "Apply" width:70 toolTip:"Do It and Keep UI Open" pos:[92,63]
		on vPApplyButton pressed do vPApply()
		button vPHelpButton "Help" width:70 toolTip:"Help" pos:[164,63]
		on vPHelpButton pressed do vPHelp()
		button vPSaveDefButton "SaveDef" width:70 toolTip:"Save Current Settings as Default" pos:[236,63]
		on vPSaveDefButton pressed do vPSaveDef()

		on vPRollout open do
			(
			if vPActionValue == 1 then vPPlaceSpinner.enabled = false
			else vPPlaceSpinner.enabled = true
			)
		)
	)
)
-------------------------------------------------------------------------------