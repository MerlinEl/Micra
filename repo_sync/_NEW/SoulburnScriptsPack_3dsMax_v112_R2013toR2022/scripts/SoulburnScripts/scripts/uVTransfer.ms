-------------------------------------------------------------------------------
-- uVTransfer.ms
-- By Neil Blevins (info@neilblevins.com)
-- v 1.00
-- Created On: 09/26/09
-- Modified On: 10/07/09
-- tested using Max 2009
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Required Files:
-- sLib.ms
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Description:
-- Transfers uvs from one object to the next. Useful if you have two identical 
-- meshes, but their vertex order is messed up (like perhaps in the situation 
-- where you exported the object to a seperate application for uving and that
-- application messed up the vertex order.) This script can transfer the uvs 
-- from the new object to your original object in max, even if the order is 
-- different.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Tutorial:
-- Select two objects that are identical, except each has been uv'd differently.
-- The first object should be the object whose uvs you want to copy, and the 
-- second should be where you'd like to paste the uvs to. Run the UI version of 
-- the script. Hit Do. Now check the Unwrap UVW modifier on your second object,
-- it will contain the uvs of the first object.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
(
-- Globals

global uVTransfer
global uVTransferDefaults
global uVTransferUI

global uVTRCloseOpenUI

global uVTRWorldPosTransfer
global uVTRIDTransfer

global uVTRDo
global uVTRApply
global uVTRHelp
global uVTRLoadDef
global uVTRSaveDef

global uVTRDefineUI
global uVTRRollout
global uVTRFloater

-- Includes

include "$scripts\SoulburnScripts\lib\sLib.ms"

-- Variables

uVTRActionValue = 1
uVTRFromChannelValue = 1
uVTRToChannelValue = 1
uVTRPositionToleranceValue = 0.001
uVTRPosValue = [400,400]

-- Functions

fn uVTransfer uVTRAction uVTRFromChannel uVTRToChannel uVTRPositionTolerance = 
	(
	myobjects = for i in selection collect i
	-- test for editpoly
	answer = true
	for i in myobjects do if (sLibEditablePolyFilter i) == false then answer = false
	if answer == false then (MessageBox "One of your objects isn't an EditablePoly. Please only select EditablePoly objects or EditablePoly Objects that have modifiers." title:"uVTransfer")
	else
		(
		if myobjects.count < 2 then (MessageBox "Please select at least 2 objects. First select the source object, then ctrl+Select the target object(s)." title:"uVTransfer")
		else
			(
			for i = 2 to myobjects.count do
				(
				if uVTRAction == 1 then
					(
					uVTRWorldPosTransfer myobjects[1] myobjects[i] uVTRFromChannel uVTRToChannel uVTRPositionTolerance
					)
				else 
					(
					uVTRIDTransfer myobjects[1] myobjects[i] uVTRFromChannel uVTRToChannel
					)
				)
			)
		)
	)
	
fn uVTransferDefaults = 
	(
	uVTRLoadDef()
	uVTransfer uVTRActionValue uVTRFromChannelValue uVTRToChannelValue uVTRPositionToleranceValue
	)
	
fn uVTransferUI = 
	(
	uVTRLoadDef()
	uVTRCloseOpenUI uVTRPosValue
	)

fn uVTRCloseOpenUI pos = 
	(
	if uVTRFloater != undefined then CloseRolloutFloater uVTRFloater
	uVTRDefineUI()
	uVTRFloater = newRolloutFloater "uVTransfer v1.00" 310 174 pos.x pos.y
	addRollout uVTRRollout uVTRFloater
	)

fn uVTRWorldPosTransfer o1 o2 uVTRFromChannel uVTRToChannel uVTRPositionTolerance = 
	(
	-- variables
	uvpos = #()
	commonfaces = false
	
	-- prep objects
	obj1 = copy o1
	convertToPoly obj1
	obj2 = o2

	-- add unwrap modifiers
	addmodifier obj1 (Unwrap_UVW())
	obj1.modifiers[1].setMapChannel uVTRFromChannel
	addmodifier obj2 (Unwrap_UVW())
	obj2.modifiers[1].setMapChannel uVTRToChannel

	-- number of faces
	numfaces1 = polyop.getNumFaces obj1
	numfaces2 = polyop.getNumFaces obj2

	if numfaces1 == 0 or numfaces2 == 0 then (MessageBox "One of your input objects contains 0 faces. Please select new objects." title:"uVTransfer")
	else
		(
		if numfaces1 != numfaces2 then (MessageBox "at least one object has a different number of faces from the source, and so can't be processed." title:"uVTransfer")
		else
			(
			-- Select first object and open uv editing
			select obj1
			max modify mode
			obj1.modifiers[1].unwrap.edit ()
			obj1.modifiers[1].unwrap.move ()
			
			-- test face positions
			for i = 1 to numfaces1 do
				(
				facecenter1 = polyop.getFaceCenter obj1 i
				for j = 1 to numfaces2 do
					(
					facecenter2 = polyop.getFaceCenter obj2 j
					if (sLibCoincidentPoints facecenter1 facecenter2 uVTRPositionTolerance) == true then
						(
						commonfaces = true
						-- store the uvs positions of all vertexes of the face
						sourceverts = polyop.getMapFace obj1 uVTRFromChannel i
						allUVPositions = #()
						for v1 in sourceverts do
							(
							append allUVPositions (obj1.modifiers[1].unwrap.getVertexPosition currenttime v1)
							)
						append uvpos #(i,j,allUVPositions)
						)
					)
				)
								
			-- Select second object and open uv editing...
			select obj2
			max modify mode
			obj2.modifiers[1].unwrap.edit ()
			obj2.modifiers[1].unwrap.move ()
			
			-- break all texture verts
			allverts = for i = 1 to (obj2.modifiers[1].numberVertices()) collect i
			obj2.modifiers[1].selectVertices (allverts as bitarray)
			obj2.modifiers[1].breakSelected()			
			
			
			-- apply source uv positions to target
			for myvert in uvpos do
				(
				targetverts = polyop.getMapFace obj2 uVTRToChannel myvert[2]
				for v2 = 1 to targetverts.count do
					(
					obj2.modifiers[1].setVertexPosition 1 targetverts[v2] myvert[3][v2]
					)
				)
			)
		)

	-- Cleanup
	allverts = for i = 1 to (obj2.modifiers[1].numberVertices()) collect i
	obj2.modifiers[1].selectVertices (allverts as bitarray)
	obj2.modifiers[1].weldSelected()
	obj2.modifiers[1].selectVertices #{}
	delete obj1
	if commonfaces == false then (MessageBox "Your objects must be occupying exactly the same World Space for the script to perform the transfer." title:"uVTransfer")
	)
	
fn uVTRIDTransfer o1 o2 uVTRFromChannel uVTRToChannel = 
	(
	-- variables
	uvpos = #()
	
	-- prep objects
	obj1 = copy o1
	convertToPoly obj1
	obj2 = o2

	-- add unwrap modifiers
	addmodifier obj1 (Unwrap_UVW())
	obj1.modifiers[1].setMapChannel uVTRFromChannel
	addmodifier obj2 (Unwrap_UVW())
	obj2.modifiers[1].setMapChannel uVTRToChannel

	-- number of faces
	numfaces1 = polyop.getNumFaces obj1
	numfaces2 = polyop.getNumFaces obj2

	if numfaces1 == 0 or numfaces2 == 0 then (MessageBox "One of your input objects contains 0 faces. Please select new objects." title:"uVTransfer")
	else
		(
		if numfaces1 != numfaces2 then (MessageBox "at least one object has a different number of faces from the source, and so can't be processed." title:"uVTransfer")
		else
			(
			-- Select first object and open uv editing
			select obj1
			max modify mode
			obj1.modifiers[1].unwrap.edit ()
			obj1.modifiers[1].unwrap.move ()
			
			-- store the uvs positions of all vertexes
			for i = 1 to numfaces1 do
				(
				sourceverts = polyop.getMapFace obj1 uVTRFromChannel i
				allUVPositions = #()
				for v1 in sourceverts do
					(
					append allUVPositions (obj1.modifiers[1].unwrap.getVertexPosition currenttime v1)
					)
				append uvpos #(i,allUVPositions)
				)
								
			-- Select second object and open uv editing...
			select obj2
			max modify mode
			obj2.modifiers[1].unwrap.edit ()
			obj2.modifiers[1].unwrap.move ()
			
			-- break all texture verts
			allverts = for i = 1 to (obj2.modifiers[1].numberVertices()) collect i
			obj2.modifiers[1].selectVertices (allverts as bitarray)
			obj2.modifiers[1].breakSelected()			
	
			-- apply source uv positions to target
			for myvert in uvpos do
				(
				targetverts = polyop.getMapFace obj2 uVTRToChannel myvert[1]
				for v2 = 1 to targetverts.count do
					(
					obj2.modifiers[1].setVertexPosition 1 targetverts[v2] myvert[2][v2]
					)
				)
			)
		)

	-- Cleanup
	allverts = for i = 1 to (obj2.modifiers[1].numberVertices()) collect i
	obj2.modifiers[1].selectVertices (allverts as bitarray)
	obj2.modifiers[1].weldSelected()
	obj2.modifiers[1].selectVertices #{}
	delete obj1
	)

fn uVTRDo = 
	(
	uVTransfer uVTRActionValue uVTRFromChannelValue uVTRToChannelValue uVTRPositionToleranceValue
	if uVTRFloater != undefined then CloseRolloutFloater uVTRFloater
	)

fn uVTRApply = 
	(
	uVTransfer uVTRActionValue uVTRFromChannelValue uVTRToChannelValue uVTRPositionToleranceValue
	)
	
fn uVTRHelp = 
	(
	sLibSSPrintHelp "uVTransfer"
	)
	
fn uVTRLoadDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	uVTRInputFilename = presetDir + "uVTransfer.ini"
	if (sLibFileExist uVTRInputFilename == true) then
		(
		uVTRActionValue = execute (getINISetting uVTRInputFilename "uVTransfer" "uVTRActionValue")
		uVTRFromChannelValue = execute (getINISetting uVTRInputFilename "uVTransfer" "uVTRFromChannelValue")
		uVTRToChannelValue = execute (getINISetting uVTRInputFilename "uVTransfer" "uVTRToChannelValue")
		uVTRPositionToleranceValue = execute (getINISetting uVTRInputFilename "uVTransfer" "uVTRPositionToleranceValue")
		uVTRPosValue = execute (getINISetting uVTRInputFilename "uVTransfer" "uVTRPosValue")
		
		if uVTRActionValue == OK then uVTRActionValue = 1
		if uVTRFromChannelValue == OK then uVTRFromChannelValue = 1
		if uVTRToChannelValue == OK then uVTRToChannelValue = 1
		if uVTRPositionToleranceValue == OK then uVTRPositionToleranceValue = 0.001
		if uVTRPosValue == OK then uVTRPosValue = [400,400]
		)
	else
		(
		uVTRActionValue = 1
		uVTRFromChannelValue = 1
		uVTRToChannelValue = 1
		uVTRPositionToleranceValue = 0.001
		uVTRPosValue = [400,400]
		)
	)
	
fn uVTRSaveDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	if (getDirectories presetDir).count == 0 then makeDir presetDir
	uVTROutputFilename = presetDir + "uVTransfer.ini"
	if (sLibFileExist uVTROutputFilename == true) then deleteFile uVTROutputFilename
	setINISetting uVTROutputFilename "uVTransfer" "uVTRActionValue" (uVTRActionValue as string)
	setINISetting uVTROutputFilename "uVTransfer" "uVTRFromChannelValue" (uVTRFromChannelValue as string)
	setINISetting uVTROutputFilename "uVTransfer" "uVTRToChannelValue" (uVTRToChannelValue as string)
	setINISetting uVTROutputFilename "uVTransfer" "uVTRPositionToleranceValue" (uVTRPositionToleranceValue as string)
	setINISetting uVTROutputFilename "uVTransfer" "uVTRPosValue" (uVTRFloater.pos as string)
	)

-- UI

fn uVTRDefineUI = 
	(
	rollout uVTRRollout "uVTransfer"
		(
		label label2 "Select Source then Ctrl+Select Target" align:#right		
		
		label label1 "Action:" pos:[47,30]
		dropdownlist uVTRActionDropdown "" items:#("Transfer By Vertex World Position", "Transfer By Vertex ID") selection:uVTRActionValue pos:[87,27] width:200
		spinner uVTRFromChannelSpinner "MapChannel From:" range:[1,9999,uVTRFromChannelValue] fieldWidth:50 type:#integer
		spinner uVTRToChannelSpinner "MapChannel To:" range:[1,9999,uVTRFromChannelValue] fieldWidth:50 type:#integer
		spinner uVTRPositionToleranceSpinner "Position Tolerance:" range:[0,9999,uVTRPositionToleranceValue] fieldWidth:50 type:#float
		
		on uVTRActionDropdown selected i do 
			(
			uVTRActionValue = i
			if i == 1 then uVTRPositionToleranceSpinner.enabled = true else uVTRPositionToleranceSpinner.enabled = false
			)
		on uVTRFromChannelSpinner changed val do uVTRFromChannelValue = val
		on uVTRToChannelSpinner changed val do uVTRToChannelValue = val
		on uVTRPositionToleranceSpinner changed val do uVTRPositionToleranceValue = val
		
		button uVTRDoButton "Do" width:70 toolTip:"Do It and Close UI" pos:[5,118]
		on uVTRDoButton pressed do uVTRDo()
		button uVTRApplyButton "Apply" width:70 toolTip:"Do It and Keep UI Open" pos:[77,118]
		on uVTRApplyButton pressed do uVTRApply()
		button uVTRHelpButton "Help" width:70 toolTip:"Help" pos:[149,118]
		on uVTRHelpButton pressed do uVTRHelp()
		button uVTRSaveDefButton "SaveDef" width:70 toolTip:"Save Current Settings as Default" pos:[221,118]
		on uVTRSaveDefButton pressed do uVTRSaveDef()
		
		on uVTRRollout open do
			(
			if uVTRActionValue == 1 then uVTRPositionToleranceSpinner.enabled = true else uVTRPositionToleranceSpinner.enabled = false
			)
		)
	)
)
-------------------------------------------------------------------------------