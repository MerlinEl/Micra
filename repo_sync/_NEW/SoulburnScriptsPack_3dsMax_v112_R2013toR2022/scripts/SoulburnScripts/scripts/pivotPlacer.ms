-------------------------------------------------------------------------------
-- pivotPlacer.ms
-- By Neil Blevins (info@neilblevins.com)
-- v 1.10
-- Created On: 04/28/05
-- Modified On: 01/28/15
-- tested using Max 2014
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Required Files:
-- sLib.ms
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Description:
-- Places the pivot of the selected objects in one of 27 spots such as center, 
-- bottom, top, high left side, etc. You can also align pivot to currently 
-- selected vert, edge or face.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Tutorial:
-- Select an object (or many). Run the UI version of the script. Click on one
-- of the colored dots to move the pivot to that spot.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Known Issues:
-- If you're running anything except the standard Windows XP UI mode (like if
-- you're running in classic mode), adjust the UI Y Offset spinner up or down
-- until the target regions on the pivot place picture match the picture. Then 
-- hit "SaveDef" to lock that offset to your defaults ini file.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Revision History:
--
-- v 1.01 Fixed a typo that stopped the buttons at the bottom of the interface 
-- from working.
--
-- v 1.02 Defined ui as new function.
--
-- v 1.03 Added some new code to more cleanly open and close the UI.
--
-- v 1.04 Fixed a bug where groups's pivot could possibly be affected even when 
-- you don't want them to be.
--
-- v 1.05 Added Expert mode.
--
-- v 1.06 Replaced the Close button with a Help button. Use the X button to 
-- Close the Floater.
--
-- v 1.07 Fixed a bug that caused groups not to work properly.
--
-- v 1.08 Fixed a bug where one of the default values wouldn't be saved when 
-- you saved defaults.
--
-- v 1.09 Added option to also align pivot to currently selected vert, edge 
-- or face.
--
-- v 1.10 Changed name of script to pivotPlacer.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
(
-- Globals

global pivotPlacer
global pivotPlacerDefaults
global pivotPlacerUI
global pivotPlacerExpertMode

global pPCloseOpenUI

global pPCalcMinMax
global pPGetSelectedVertexesEditablePoly
global pPGetSelectedEdgesEditablePoly
global pPGetSelectedFacesEditablePoly

global pPDo
global pPApply
global pPHelp
global pPLoadDef
global pPSaveDef

global pPDefineUI
global pPDefineEMUI
global pPRollout
global pPEMRollout
global pPFloater

-- Includes

include "$scripts\SoulburnScripts\lib\sLib.ms"

-- Variables

pPPlaceValue = 1
pPTypeValue = 1
pPGroupsValue = true
pPUIYOffsetValue = 0
pPAlignToValue = 1
pPPosValue = [400,400]

pPBitmap = openbitmap ((getdir #scripts) + "\\SoulburnScripts\\images\\" + "pivotPlacer.bmp")

-- Functions

fn pivotPlacer pPPlace pPType pPGroups pPAlignTo = 
	(
	undo "pivotPlacer" on
		(
		for obj in selection do
			(
			if isgroupmember obj == true and pPGroups == true then continue
			else
				(
				if isgrouphead obj == true and pPGroups == false then continue
				else
					(
					if (sLibGeometryFilter obj) or (sLibShapeFilter obj) or (sLibHelperFilter obj) then
						(
						error = 0
						try	
							(
							if pPAlignTo == 1 then
								(
								-- if using local space, calculate center and rotation and then reset the rotation
								if pPType == 1 then
									(
									minmax = pPCalcMinMax obj
									originalCenter = [(minmax[1].x+minmax[2].x)/2, (minmax[1].y+minmax[2].y)/2, (minmax[1].z+minmax[2].z)/2]
									originalRotation = coordsys world obj.rotation
									obj.rotation = quat 0 0 0 1
									)

								-- place the pivot
								minmax = pPCalcMinMax obj
								if pPPlace == 1 then obj.pivot = [minmax[2].x, minmax[2].y, minmax[1].z]
								if pPPlace == 2 then obj.pivot = [minmax[2].x, minmax[2].y, (minmax[1].z+minmax[2].z)/2]
								if pPPlace == 3 then obj.pivot = [minmax[2].x, minmax[2].y, minmax[2].z]
								if pPPlace == 4 then obj.pivot = [(minmax[1].x+minmax[2].x)/2, minmax[2].y, minmax[1].z]
								if pPPlace == 5 then obj.pivot = [(minmax[1].x+minmax[2].x)/2, minmax[2].y, (minmax[1].z+minmax[2].z)/2]
								if pPPlace == 6 then obj.pivot = [(minmax[1].x+minmax[2].x)/2, minmax[2].y, minmax[2].z]
								if pPPlace == 7 then obj.pivot = [minmax[1].x, minmax[2].y, minmax[1].z]
								if pPPlace == 8 then obj.pivot = [minmax[1].x, minmax[2].y, (minmax[1].z+minmax[2].z)/2]
								if pPPlace == 9 then obj.pivot = [minmax[1].x, minmax[2].y, minmax[2].z]

								if pPPlace == 10 then obj.pivot = [minmax[2].x, (minmax[1].y+minmax[2].y)/2, minmax[1].z]
								if pPPlace == 11 then obj.pivot = [minmax[2].x, (minmax[1].y+minmax[2].y)/2, (minmax[1].z+minmax[2].z)/2]
								if pPPlace == 12 then obj.pivot = [minmax[2].x, (minmax[1].y+minmax[2].y)/2, minmax[2].z]
								if pPPlace == 13 then obj.pivot = [(minmax[1].x+minmax[2].x)/2, (minmax[1].y+minmax[2].y)/2, minmax[1].z]

								if pPPlace == 14 then obj.pivot = [(minmax[1].x+minmax[2].x)/2, (minmax[1].y+minmax[2].y)/2, (minmax[1].z+minmax[2].z)/2]

								if pPPlace == 15 then obj.pivot = [(minmax[1].x+minmax[2].x)/2, (minmax[1].y+minmax[2].y)/2, minmax[2].z]
								if pPPlace == 16 then obj.pivot = [minmax[1].x, (minmax[1].y+minmax[2].y)/2, minmax[1].z]
								if pPPlace == 17 then obj.pivot = [minmax[1].x, (minmax[1].y+minmax[2].y)/2, (minmax[1].z+minmax[2].z)/2]
								if pPPlace == 18 then obj.pivot = [minmax[1].x, (minmax[1].y+minmax[2].y)/2, minmax[2].z]

								if pPPlace == 19 then obj.pivot = [minmax[2].x, minmax[1].y, minmax[1].z]
								if pPPlace == 20 then obj.pivot = [minmax[2].x, minmax[1].y, (minmax[1].z+minmax[2].z)/2]
								if pPPlace == 21 then obj.pivot = [minmax[2].x, minmax[1].y, minmax[2].z]
								if pPPlace == 22 then obj.pivot = [(minmax[1].x+minmax[2].x)/2, minmax[1].y, minmax[1].z]
								if pPPlace == 23 then obj.pivot = [(minmax[1].x+minmax[2].x)/2, minmax[1].y, (minmax[1].z+minmax[2].z)/2]
								if pPPlace == 24 then obj.pivot = [(minmax[1].x+minmax[2].x)/2, minmax[1].y, minmax[2].z]
								if pPPlace == 25 then obj.pivot = [minmax[1].x, minmax[1].y, minmax[1].z]
								if pPPlace == 26 then obj.pivot = [minmax[1].x, minmax[1].y, (minmax[1].z+minmax[2].z)/2]
								if pPPlace == 27 then obj.pivot = [minmax[1].x, minmax[1].y, minmax[2].z]

								-- if using local space, rotate the object back
								if pPType == 1 then
									(
									obj.rotation = originalRotation
									midPivot = obj.pivot
									minmax = pPCalcMinMax obj
									obj.pivot = [(minmax[1].x+minmax[2].x)/2, (minmax[1].y+minmax[2].y)/2, (minmax[1].z+minmax[2].z)/2]
									midPosition = obj.pos
									obj.pos = originalCenter
									changeInPosition = obj.pos - midPosition
									obj.pivot = midPivot + changeInPosition
									)
								)
							else if pPAlignTo == 2 then
								(
								Verts = (pPGetSelectedVertexesEditablePoly obj)
								if Verts.count != 0 then
									(
									pPAllXValues = #()
									pPAllYValues = #()
									pPAllZValues = #()
									for i in Verts do append pPAllXValues (polyop.getvert obj i).x
									pPAverageX = sLibAverageMinMaxOfArray pPAllXValues	
									for i in Verts do append pPAllYValues (polyop.getvert obj i).y
									pPAverageY = sLibAverageMinMaxOfArray pPAllYValues	
									for i in Verts do append pPAllZValues (polyop.getvert obj i).z
									pPAverageZ = sLibAverageMinMaxOfArray pPAllZValues
									obj.pivot = [pPAverageX,pPAverageY,pPAverageZ]
									)
								)
							else if pPAlignTo == 3 then
								(
								Edges = (pPGetSelectedEdgesEditablePoly obj)
								if Edges.count != 0 then
									(
									pPAllXValues = #()
									pPAllYValues = #()
									pPAllZValues = #()
									for i in Edges do 
										(
										e = polyop.getVertsUsingEdge obj i
										for w in e do (append pPAllXValues (polyop.getvert obj w).x)
										)
									pPAverageX = sLibAverageMinMaxOfArray pPAllXValues	
									for i in Edges do
										(
										e = polyop.getVertsUsingEdge obj i
										for w in e do (append pPAllYValues (polyop.getvert obj w).y)
										)
									pPAverageY = sLibAverageMinMaxOfArray pPAllYValues	
									for i in Edges do
										(
										e = polyop.getVertsUsingEdge obj i
										for w in e do (append pPAllZValues (polyop.getvert obj w).z)
										)
									pPAverageZ = sLibAverageMinMaxOfArray pPAllZValues
									obj.pivot = [pPAverageX,pPAverageY,pPAverageZ]
									)
								)
							else if pPAlignTo == 4 then
								(
								Faces = (pPGetSelectedFacesEditablePoly obj)
								if Faces.count != 0 then
									(
									pPAllXValues = #()
									pPAllYValues = #()
									pPAllZValues = #()
									for i in Faces do append pPAllXValues (polyop.getFaceCenter obj i).x
									pPAverageX = sLibAverageMinMaxOfArray pPAllXValues	
									for i in Faces do append pPAllYValues (polyop.getFaceCenter obj i).y
									pPAverageY = sLibAverageMinMaxOfArray pPAllYValues	
									for i in Faces do append pPAllZValues (polyop.getFaceCenter obj i).z
									pPAverageZ = sLibAverageMinMaxOfArray pPAllZValues
									obj.pivot = [pPAverageX,pPAverageY,pPAverageZ]
									)
								)
							)
						catch (error = 1)
						)
					)
				)
			)
		if error == 1 then MessageBox "At least one object in your selection has a pivot that could not be changed." title:"pivotPlacer"
		)
	)

fn pivotPlacerDefaults = 
	(
	pPLoadDef()
	pivotPlacer pPPlaceValue pPTypeValue pPGroupsValue pPAlignToValue
	)

fn pivotPlacerUI = 
	(
	pPLoadDef()
	pPCloseOpenUI pPPosValue
	)
	
fn pivotPlacerExpertMode = 
	(
	pPLoadDef()
	if pPEMRollout != undefined then destroydialog pPEMRollout
	pPDefineEMUI()
	createDialog pPEMRollout style:#(#style_titlebar, #style_sysmenu) bitmap:pPBitmap model:false width:210 height:210 pos:[pPPosValue.x,pPPosValue.y]
	)

fn pPCloseOpenUI pos = 
	(
	if pPFloater != undefined then CloseRolloutFloater pPFloater
	pPDefineUI()
	pPFloater = newRolloutFloater "pivotPlacer v1.10" 230 413 pos.x pos.y
	addRollout pPRollout pPFloater
	)
	
fn pPCalcMinMax obj = 
	(
	mymax = obj.max
	mymin = obj.min
	if isgrouphead obj == true then
		(
		objs = #()
		for i in obj.children do
			(
			if isGroupMember i == true then append objs i
			)
		a = sLibGetCollectionBBox objs
		mymax = a[1]
		mymin = a[2]
		)
	return #(mymax, mymin)
	)

fn pPGetSelectedVertexesEditablePoly obj = 
	(
	Verts = #{}
	if classof (modPanel.getCurrentObject ()) == Editable_Poly then Verts = getvertselection obj
	return Verts
	)
	
fn pPGetSelectedEdgesEditablePoly obj = 
	(
	Edges = #{}
	if classof (modPanel.getCurrentObject ()) == Editable_Poly then Edges = getedgeselection obj
	return Edges
	)
	
fn pPGetSelectedFacesEditablePoly obj = 
	(
	Faces = #{}
	if classof (modPanel.getCurrentObject ()) == Editable_Poly then Faces = getfaceselection obj
	return Faces
	)

fn pPDo = 
	(
	pivotPlacer pPPlaceValue pPTypeValue pPGroupsValue pPAlignToValue
	if pPFloater != undefined then CloseRolloutFloater pPFloater
	)

fn pPApply = 
	(
	pivotPlacer pPPlaceValue pPTypeValue pPGroupsValue pPAlignToValue
	)
	
fn pPHelp = 
	(
	sLibSSPrintHelp "pivotPlacer"
	)
	
fn pPLoadDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	pPInputFilename = presetDir + "pivotPlacer.ini"
	if (sLibFileExist pPInputFilename == true) then
		(
		pPPlaceValue = execute (getINISetting pPInputFilename "pivotPlacer" "pPPlaceValue")
		pPTypeValue = execute (getINISetting pPInputFilename "pivotPlacer" "pPTypeValue")
		pPGroupsValue = execute (getINISetting pPInputFilename "pivotPlacer" "pPGroupsValue")
		pPUIYOffsetValue = execute (getINISetting pPInputFilename "pivotPlacer" "pPUIYOffsetValue")
		pPAlignToValue = execute (getINISetting pPInputFilename "pivotPlacer" "pPAlignToValue")
		pPPosValue = execute (getINISetting pPInputFilename "pivotPlacer" "pPPosValue")
		
		if pPPlaceValue == OK then pPPlaceValue = 1
		if pPTypeValue == OK then pPTypeValue = 1
		if pPGroupsValue == OK then pPGroupsValue = true
		if pPUIYOffsetValue == OK then pPUIYOffsetValue = 0
		if pPAlignToValue == OK then pPAlignToValue = 0
		if pPPosValue == OK then pPPosValue = [400,400]
		)
	else
		(
		pPPlaceValue = 1
		pPTypeValue = 1
		pPGroupsValue = true
		pPUIYOffsetValue = 0
		pPAlignToValue = 1
		pPPosValue = [400,400]
		)
	)
	
fn pPSaveDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	if (getDirectories presetDir).count == 0 then makeDir presetDir
	pPOutputFilename = presetDir + "pivotPlacer.ini"
	if (sLibFileExist pPOutputFilename == true) then deleteFile pPOutputFilename
	setINISetting pPOutputFilename "pivotPlacer" "pPPlaceValue" (pPPlaceValue as string)
	setINISetting pPOutputFilename "pivotPlacer" "pPTypeValue" (pPTypeValue as string)
	setINISetting pPOutputFilename "pivotPlacer" "pPGroupsValue" (pPGroupsValue as string)
	setINISetting pPOutputFilename "pivotPlacer" "pPUIYOffsetValue" (pPUIYOffsetValue as string)
	setINISetting pPOutputFilename "pivotPlacer" "pPAlignToValue" (pPAlignToValue as string)
	setINISetting pPOutputFilename "pivotPlacer" "pPPosValue" (pPFloater.pos as string)
	)

-- UI

fn pPDefineUI = 
	(
	rollout pPRollout "pivotPlacer"
		(
		imgTag pPImgTag bitmap:pPBitmap align:#center
		spinner pPPlaceSpinner "Place:" range:[1,27,pPPlaceValue] fieldWidth:37 type:#integer align:#left offset:[25,4]
		dropdownlist pPTypeDropDownList "" items:#("Local", "World") selection:pPTypeValue width:100 align:#left offset:[25,0]
		checkbox pPGroupsCheckbox "Treat Group As One Obj" checked:pPGroupsValue align:#left offset:[25,0]
		spinner pPUIYOffsetSpinner "UI Y Offset:" range:[-20,50,pPUIYOffsetValue] fieldWidth:37 type:#integer align:#left offset:[25,0]
		dropdownlist pPAlignToDropDownList "" items:#("Diagram", "Selected Vert", "Selected Edge", "Selected Face") selection:pPAlignToValue width:120 align:#left offset:[25,0]

		on pPImgTag click do 
			(
			pPMX = mouse.screenpos.x
			pPMY = mouse.screenpos.y
			pPFX = pPFloater.pos.x
			pPFY = pPFloater.pos.y
			pPUY = pPUIYOffsetValue
			if pPMX > pPFX+30 and pPMX < pPFX+43 and pPMY > pPFY+pPUY+107 and pPMY < pPFY+pPUY+119 then (pivotPlacer 1 pPTypeValue pPGroupsValue pPAlignToValue; pPPlaceValue = 1; pPPlaceSpinner.value = 1)
			if pPMX > pPFX+30 and pPMX < pPFX+43 and pPMY > pPFY+pPUY+162 and pPMY < pPFY+pPUY+177 then (pivotPlacer 2 pPTypeValue pPGroupsValue pPAlignToValue; pPPlaceValue = 2; pPPlaceSpinner.value = 2)
			if pPMX > pPFX+30 and pPMX < pPFX+43 and pPMY > pPFY+pPUY+220 and pPMY < pPFY+pPUY+234 then (pivotPlacer 3 pPTypeValue pPGroupsValue pPAlignToValue; pPPlaceValue = 3; pPPlaceSpinner.value = 3)
			if pPMX > pPFX+80 and pPMX < pPFX+96 and pPMY > pPFY+pPUY+114 and pPMY < pPFY+pPUY+130 then (pivotPlacer 4 pPTypeValue pPGroupsValue pPAlignToValue; pPPlaceValue = 4; pPPlaceSpinner.value = 4)
			if pPMX > pPFX+80 and pPMX < pPFX+96 and pPMY > pPFY+pPUY+170 and pPMY < pPFY+pPUY+188 then (pivotPlacer 5 pPTypeValue pPGroupsValue pPAlignToValue; pPPlaceValue = 5; pPPlaceSpinner.value = 5)
			if pPMX > pPFX+80 and pPMX < pPFX+96 and pPMY > pPFY+pPUY+228 and pPMY < pPFY+pPUY+246 then (pivotPlacer 6 pPTypeValue pPGroupsValue pPAlignToValue; pPPlaceValue = 6; pPPlaceSpinner.value = 6)
			if pPMX > pPFX+132 and pPMX < pPFX+149 and pPMY > pPFY+pPUY+124 and pPMY < pPFY+pPUY+142 then (pivotPlacer 7 pPTypeValue pPGroupsValue pPAlignToValue; pPPlaceValue = 7; pPPlaceSpinner.value = 7)
			if pPMX > pPFX+132 and pPMX < pPFX+149 and pPMY > pPFY+pPUY+182 and pPMY < pPFY+pPUY+198 then (pivotPlacer 8 pPTypeValue pPGroupsValue pPAlignToValue; pPPlaceValue = 8; pPPlaceSpinner.value = 8)
			if pPMX > pPFX+132 and pPMX < pPFX+149 and pPMY > pPFY+pPUY+238 and pPMY < pPFY+pPUY+252 then (pivotPlacer 9 pPTypeValue pPGroupsValue pPAlignToValue; pPPlaceValue = 9; pPPlaceSpinner.value = 9)

			if pPMX > pPFX+60 and pPMX < pPFX+76 and pPMY > pPFY+pPUY+86 and pPMY < pPFY+pPUY+102 then (pivotPlacer 10 pPTypeValue pPGroupsValue pPAlignToValue; pPPlaceValue = 10; pPPlaceSpinner.value = 10)
			if pPMX > pPFX+60 and pPMX < pPFX+76 and pPMY > pPFY+pPUY+142 and pPMY < pPFY+pPUY+160 then (pivotPlacer 11 pPTypeValue pPGroupsValue pPAlignToValue; pPPlaceValue = 11; pPPlaceSpinner.value = 11)
			if pPMX > pPFX+60 and pPMX < pPFX+76 and pPMY > pPFY+pPUY+200 and pPMY < pPFY+pPUY+216 then (pivotPlacer 12 pPTypeValue pPGroupsValue pPAlignToValue; pPPlaceValue = 12; pPPlaceSpinner.value = 12)
			if pPMX > pPFX+112 and pPMX < pPFX+128 and pPMY > pPFY+pPUY+96 and pPMY < pPFY+pPUY+114 then (pivotPlacer 13 pPTypeValue pPGroupsValue pPAlignToValue; pPPlaceValue = 13; pPPlaceSpinner.value = 13)

			if pPMX > pPFX+108 and pPMX < pPFX+132 and pPMY > pPFY+pPUY+150 and pPMY < pPFY+pPUY+174 then (pivotPlacer 14 pPTypeValue pPGroupsValue pPAlignToValue; pPPlaceValue = 14; pPPlaceSpinner.value = 14)

			if pPMX > pPFX+112 and pPMX < pPFX+128 and pPMY > pPFY+pPUY+212 and pPMY < pPFY+pPUY+228 then (pivotPlacer 15 pPTypeValue pPGroupsValue pPAlignToValue; pPPlaceValue = 15; pPPlaceSpinner.value = 15)
			if pPMX > pPFX+164 and pPMX < pPFX+180 and pPMY > pPFY+pPUY+108 and pPMY < pPFY+pPUY+124 then (pivotPlacer 16 pPTypeValue pPGroupsValue pPAlignToValue; pPPlaceValue = 16; pPPlaceSpinner.value = 16)
			if pPMX > pPFX+164 and pPMX < pPFX+180 and pPMY > pPFY+pPUY+164 and pPMY < pPFY+pPUY+180 then (pivotPlacer 17 pPTypeValue pPGroupsValue pPAlignToValue; pPPlaceValue = 17; pPPlaceSpinner.value = 17)
			if pPMX > pPFX+164 and pPMX < pPFX+180 and pPMY > pPFY+pPUY+222 and pPMY < pPFY+pPUY+238 then (pivotPlacer 18 pPTypeValue pPGroupsValue pPAlignToValue; pPPlaceValue = 18; pPPlaceSpinner.value = 18)

			if pPMX > pPFX+93 and pPMX < pPFX+110 and pPMY > pPFY+pPUY+68 and pPMY < pPFY+pPUY+86 then (pivotPlacer 19 pPTypeValue pPGroupsValue pPAlignToValue; pPPlaceValue = 19; pPPlaceSpinner.value = 19)
			if pPMX > pPFX+93 and pPMX < pPFX+110 and pPMY > pPFY+pPUY+125 and pPMY < pPFY+pPUY+142 then (pivotPlacer 20 pPTypeValue pPGroupsValue pPAlignToValue; pPPlaceValue = 20; pPPlaceSpinner.value = 20)
			if pPMX > pPFX+93 and pPMX < pPFX+110 and pPMY > pPFY+pPUY+184 and pPMY < pPFY+pPUY+200 then (pivotPlacer 21 pPTypeValue pPGroupsValue pPAlignToValue; pPPlaceValue = 21; pPPlaceSpinner.value = 21)
			if pPMX > pPFX+145 and pPMX < pPFX+162 and pPMY > pPFY+pPUY+80 and pPMY < pPFY+pPUY+96 then (pivotPlacer 22 pPTypeValue pPGroupsValue pPAlignToValue; pPPlaceValue = 22; pPPlaceSpinner.value = 22)
			if pPMX > pPFX+145 and pPMX < pPFX+162 and pPMY > pPFY+pPUY+136 and pPMY < pPFY+pPUY+153 then (pivotPlacer 23 pPTypeValue pPGroupsValue pPAlignToValue; pPPlaceValue = 23; pPPlaceSpinner.value = 23)
			if pPMX > pPFX+145 and pPMX < pPFX+162 and pPMY > pPFY+pPUY+194 and pPMY < pPFY+pPUY+210 then (pivotPlacer 24 pPTypeValue pPGroupsValue pPAlignToValue; pPPlaceValue = 24; pPPlaceSpinner.value = 24)
			if pPMX > pPFX+196 and pPMX < pPFX+212 and pPMY > pPFY+pPUY+90 and pPMY < pPFY+pPUY+107 then (pivotPlacer 25 pPTypeValue pPGroupsValue pPAlignToValue; pPPlaceValue = 25; pPPlaceSpinner.value = 25)
			if pPMX > pPFX+196 and pPMX < pPFX+212 and pPMY > pPFY+pPUY+147 and pPMY < pPFY+pPUY+164 then (pivotPlacer 26 pPTypeValue pPGroupsValue pPAlignToValue; pPPlaceValue = 26; pPPlaceSpinner.value = 26)
			if pPMX > pPFX+196 and pPMX < pPFX+212 and pPMY > pPFY+pPUY+204 and pPMY < pPFY+pPUY+220 then (pivotPlacer 27 pPTypeValue pPGroupsValue pPAlignToValue; pPPlaceValue = 27; pPPlaceSpinner.value = 27)
			)
		on pPPlaceSpinner changed val do pPPlaceValue = val
		on pPTypeDropDownList selected i do pPTypeValue = i
		on pPGroupsCheckbox changed state do pPGroupsValue = state
		on pPUIYOffsetSpinner changed val do pPUIYOffsetValue = val
		on pPAlignToDropDownList selected i do pPAlignToValue = i

		button pPDoButton "Do" width:70 toolTip:"Do It and Close UI" pos:[35,332]
		on pPDoButton pressed do pPDo()
		button pPApplyButton "Apply" width:70 toolTip:"Do It and Keep UI Open" pos:[107,332]
		on pPApplyButton pressed do pPApply()
		button pPHelpButton "Help" width:70 toolTip:"Help" pos:[35,356]
		on pPHelpButton pressed do pPHelp()
		button pPSaveDefButton "SaveDef" width:70 toolTip:"Save Current Settings as Default" pos:[107,356]
		on pPSaveDefButton pressed do pPSaveDef()
		)
	)
	
fn pPDefineEMUI = 
	(
	rollout pPEMRollout "pivotPlacer"
		(
		on pPEMRollout lbuttondown clickPos do 
			(
			pPMX = clickPos.x
			pPMY = clickPos.y
			if pPMX > 20 and pPMX < 33 and pPMY > 49 and pPMY < 61 then pivotPlacer 1 pPTypeValue pPGroupsValue pPAlignToValue
			if pPMX > 20 and pPMX < 33 and pPMY > 104 and pPMY < 119 then pivotPlacer 2 pPTypeValue pPGroupsValue pPAlignToValue
			if pPMX > 20 and pPMX < 33 and pPMY > 162 and pPMY < 176 then pivotPlacer 3 pPTypeValue pPGroupsValue pPAlignToValue
			if pPMX > 70 and pPMX < 86 and pPMY > 56 and pPMY < 72 then pivotPlacer 4 pPTypeValue pPGroupsValue pPAlignToValue
			if pPMX > 70 and pPMX < 86 and pPMY > 112 and pPMY < 130 then pivotPlacer 5 pPTypeValue pPGroupsValue pPAlignToValue
			if pPMX > 70 and pPMX < 86 and pPMY > 170 and pPMY < 188 then pivotPlacer 6 pPTypeValue pPGroupsValue pPAlignToValue
			if pPMX > 122 and pPMX < 139 and pPMY > 66 and pPMY < 84 then pivotPlacer 7 pPTypeValue pPGroupsValue pPAlignToValue
			if pPMX > 122 and pPMX < 139 and pPMY > 124 and pPMY < 140 then pivotPlacer 8 pPTypeValue pPGroupsValue pPAlignToValue
			if pPMX > 122 and pPMX < 139 and pPMY > 180 and pPMY < 194 then pivotPlacer 9 pPTypeValue pPGroupsValue pPAlignToValue

			if pPMX > 50 and pPMX < 66 and pPMY > 28 and pPMY < 44 then pivotPlacer 10 pPTypeValue pPGroupsValue pPAlignToValue
			if pPMX > 50 and pPMX < 66 and pPMY > 84 and pPMY < 102 then pivotPlacer 11 pPTypeValue pPGroupsValue pPAlignToValue
			if pPMX > 50 and pPMX < 66 and pPMY > 142 and pPMY < 158 then pivotPlacer 12 pPTypeValue pPGroupsValue pPAlignToValue
			if pPMX > 102 and pPMX < 118 and pPMY > 38 and pPMY < 56 then pivotPlacer 13 pPTypeValue pPGroupsValue pPAlignToValue

			if pPMX > 98 and pPMX < 122 and pPMY > 92 and pPMY < 116 then pivotPlacer 14 pPTypeValue pPGroupsValue pPAlignToValue

			if pPMX > 102 and pPMX < 118 and pPMY > 154 and pPMY < 170 then pivotPlacer 15 pPTypeValue pPGroupsValue pPAlignToValue
			if pPMX > 154 and pPMX < 170 and pPMY > 50 and pPMY < 66 then pivotPlacer 16 pPTypeValue pPGroupsValue pPAlignToValue
			if pPMX > 154 and pPMX < 170 and pPMY > 106 and pPMY < 122 then pivotPlacer 17 pPTypeValue pPGroupsValue pPAlignToValue
			if pPMX > 154 and pPMX < 170 and pPMY > 164 and pPMY < 180 then pivotPlacer 18 pPTypeValue pPGroupsValue pPAlignToValue

			if pPMX > 83 and pPMX < 100 and pPMY > 10 and pPMY < 28 then pivotPlacer 19 pPTypeValue pPGroupsValue pPAlignToValue
			if pPMX > 83 and pPMX < 100 and pPMY > 67 and pPMY < 84 then pivotPlacer 20 pPTypeValue pPGroupsValue pPAlignToValue
			if pPMX > 83 and pPMX < 100 and pPMY > 126 and pPMY < 142 then pivotPlacer 21 pPTypeValue pPGroupsValue pPAlignToValue
			if pPMX > 135 and pPMX < 152 and pPMY > 22 and pPMY < 38 then pivotPlacer 22 pPTypeValue pPGroupsValue pPAlignToValue
			if pPMX > 135 and pPMX < 152 and pPMY > 78 and pPMY < 95 then pivotPlacer 23 pPTypeValue pPGroupsValue pPAlignToValue
			if pPMX > 135 and pPMX < 152 and pPMY > 136 and pPMY < 152 then pivotPlacer 24 pPTypeValue pPGroupsValue pPAlignToValue
			if pPMX > 186 and pPMX < 202 and pPMY > 32 and pPMY < 49 then pivotPlacer 25 pPTypeValue pPGroupsValue pPAlignToValue
			if pPMX > 186 and pPMX < 202 and pPMY > 89 and pPMY < 106 then pivotPlacer 26 pPTypeValue pPGroupsValue pPAlignToValue
			if pPMX > 186 and pPMX < 202 and pPMY > 146 and pPMY < 162 then pivotPlacer 27 pPTypeValue pPGroupsValue pPAlignToValue
			)
		)
	)
)
-------------------------------------------------------------------------------