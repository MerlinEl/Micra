-------------------------------------------------------------------------------
-- materialMover.ms
-- By Neil Blevins (neil@soulburn3d.com)
-- v 1.07
-- Created On: 02/28/08
-- Modified On: 01/19/21
-- tested using Max 2017
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Required Files:
-- sLib.ms
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Description:
-- Lets you move materials from one place to another. Some common uses: apply 
-- a flat grey material (standard, Raytrace, Brazil, mentalray, etc) to all 
-- scene objects in one button press. Clear out your material editor with 
-- blank materials. Move all the scene materials into the material editor. 
-- Move all scene materials to a matlib. Assign a random material from the
-- material editor to a set of scene objects.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Tutorial:
-- Select a set of objects that have materials. Run the UI version of the 
-- script. Set the From to "Scene Selection Materials". Set to To to "Medit".
-- Hit Do. All the materials on your selected objects will be placed in the 
-- material editor. The From Start and End fields lets you specify a subrange to
-- get. Like, if your have 10 materials in your scene, setting the Start to 5 
-- and the End to 10 will get the second 5 materials only. Setting the start
-- in the To area will say where to start moving the materials to. For example,
-- if you set this to 5, and set the To to Medit, it will start placing the
-- materials at slot #5 in the material editor. The order dropdown has 3 modes.
-- 1 to 1 means that it applies the materials in the From area and then stops.
-- So if you have 4 objects selected, but only 3 materials to apply, it will
-- apply the 3 materials and then stop. Repeat will repeat the materials,
-- so the first 3 objects will get the 3 materials, and then the 4th object 
-- will get material 1 again. Random will apply the materials randomly. So if 
-- you have 4 objects and 3 materials, each object will receive a random 
-- material of those 3. Sort alphabetically sorts the From materials before
-- applying them. So if you move the scene materials to the medit, and this is
-- checked, the materials will appear in the medit in alphabetical order.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Revision History:
--
-- v 1.01 Added an Unused mode, so you can, for example, only move materials
-- to the material editor slots that don't currently contain scene materials. Or
-- you can apply materials from your Material Library to only scene objects that
-- do not currently have a material.
--
-- v 1.02 Replaced the Close button with a Help button. Use the X button to 
-- Close the Floater.
--
-- v 1.03 Fixed a bug found by a user that stopped the script from using the 
-- mentalray preset.
--
-- v 1.04 Added Vray support.
--
-- v 1.05 Material were not being sorted properly if you used a Specific Range
-- in the From field. Now the sorting occurs correctly.
--
-- v 1.06 Added an option to clear the medit before moving materials to the medit.
--
-- v 1.07 Fixed a bug where the alphebetizing happens before the range
-- is selected.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
(
-- Globals

global materialMover
global materialMoverDefaults
global materialMoverUI

global mMOCloseOpenUI

global mMODo
global mMOApply
global mMOHelp
global mMOLoadDef
global mMOSaveDef

global mMODefineUI
global mMORollout
global mMOFloater

-- Includes

include "$scripts\SoulburnScripts\lib\sLib.ms"

-- Variables

global matArray = #()
global matToArray = #()

mMOFromTypeValue = 1
mMOFromRangeValue = 1
mMOFromRangeStartValue = 1
mMOFromRangeEndValue = 24
mMOPresetsValue = 1
mMOSortAlphaValue = true
mMOOrderValue = 1
mMOToTypeValue = 3
mMOToRangeStartValue = 1
mMOPosValue = [400,400]

-- Functions

fn materialMover mMOFromType mMOFromRange mMOFromRangeStart mMOFromRangeEnd mMOPresets mMOSortAlpha mMOOrder mMOToType mMOToRangeStart = 
	(
	-- Tests 1
	if mMOFromRangeStart > mMOFromRangeEnd and mMOFromRange == 2 then 
		(
		MessageBox "Your 'From' start value is larger than your end value. Please re-enter your start and end values." title:"materialMover"
		return false
		)
	if (mMOFromType == 5 or mMOFromType == 6) and mMOPresets == 3 and sLibBrazil1Test() == false then 
		(
		MessageBox "You need Brazil 1 installed on your system to use this option." title:"materialMover"
		return false
		)
	if (mMOFromType == 5 or mMOFromType == 6) and mMOPresets == 4 and sLibBrazil2Test() == false then 
		(
		MessageBox "You need Brazil 2 installed on your system to use this option." title:"materialMover"
		return false
		)
	if (mMOFromType == 5 or mMOFromType == 6) and mMOPresets == 5 and sLibMaxVer() < 10 then 
		(
		MessageBox "You need to have max 10 or up installed on your system to use the mentalray material." title:"materialMover"
		return false
		)
	if (mMOFromType == 5 or mMOFromType == 6) and mMOPresets == 6 and sLibVrayTest() == false then 
		(
		MessageBox "You need Vray installed on your system to use this option." title:"materialMover"
		return false
		)

	-- From
	matArray = #()
	if mMOFromType == 1 then matArray = sLibGetSceneMaterials()
	else if mMOFromType == 2 then matArray = sLibGetMaterialsOnSelectedObjects()
	else if mMOFromType == 3 then matArray = sLibGetMeditMaterials()
	else if mMOFromType == 4 then matArray = sLibGetMatLibMaterials()
	else if mMOFromType == 5 or mMOFromType == 6 then 
		(
		if mMOPresets == 1 then 
			(
			mMOStandMat = Standardmaterial ()
			mMOStandMat.name = "Standard"
			mMOStandMat.Diffuse = color 128 128 128
			mMOStandMat.specularlevel = 0
			mMOStandMat.Glossiness = 0
			matArray = #(mMOStandMat)
			)
		if mMOPresets == 2 then 
			(
			mMORayMat = RaytraceMaterial ()
			mMORayMat.name = "Raytrace"
			mMORayMat.Diffuse = color 128 128 128
			mMORayMat.Specular_Level = 0
			mMORayMat.Glossiness = 0
			matArray = #(mMORayMat)
			)
		if mMOPresets == 3 then 
			(
			mMOB1Mat = Brazil_Advanced ()
			mMOB1Mat.name = "Brazil1"
			mMOB1Mat.bmtl_Cs_color = color 128 128 128
			matArray = #(mMOB1Mat)
			)
		if mMOPresets == 4 then 
			(
			mMOB2Mat = Brazil2_Advanced_Material ()
			mMOB2Mat.name = "Brazil2"
			mMOB2Mat.bmtl_Cs_color = color 128 128 128
			matArray = #(mMOB2Mat)
			)
		if mMOPresets == 5 then 
			(
			mMOMRMat = Arch___Design__mi ()
			mMOMRMat.name = "MR"
			mMOMRMat.diff_color = color 128 128 128 255
			matArray = #(mMOMRMat)
			)
		if mMOPresets == 6 then 
			(
			mMOVMat = VRayMtl ()
			mMOVMat.name = "Vray"
			mMOVMat.Diffuse = color 128 128 128 255
			matArray = #(mMOVMat)
			)
		)
	mAC = matArray.count

	-- To
	matToArray = #()
	if mMOToType == 1 then 
		(
		if mMOOrderValue == 4 then 
			(
			temp = for i in $* collect i
			for i in temp do
				(
				if i.material == undefined then append matToArray i
				)
			)
		else matToArray = for i in $* collect i
		)
	else if mMOToType == 2 then 
		(
		if mMOOrderValue == 4 then 
			(
			temp = for i in selection collect i
			for i in temp do
				(
				if i.material == undefined then append matToArray i
				)
			)
		else matToArray = for i in selection collect i
		)
	else if mMOToType == 3 then 
		(
		if mMOOrderValue == 4 then 
			(
			temp = for i in $* collect i.material
			for i = 1 to 24 do
				(
				if finditem temp meditmaterials[i] == 0 then append matToArray i
				)
			)
		else matToArray = for i = 1 to 24 collect i
		)
	else if mMOToType == 4 then 
		(
		if mMOOrderValue == 4 then 
			(
			temp = for i in $* collect i.material
			for i = 1 to 24 do
				(
				if finditem temp meditmaterials[i] == 0 then append matToArray i
				)
			)
		else matToArray = for i = 1 to 24 collect i
		)
	else if mMOToType == 5 then matToArray = #()
	mTAC = matToArray.count

	-- Tests 2
	if mAC == 0 then 
		(
		MessageBox "There are no Materials To Copy From." title:"materialMover"
		return false
		)
	if mMOFromRange == 1 then (mMOFromRangeStart = 1;mMOFromRangeEnd = mAC)
	if (mMOFromRangeStart > mAC or mMOFromRangeEnd > mAC) then 
		(
		MessageBox "You seemed to have picked an improper 'From' range. Please reselect." title:"materialMover"
		return false
		)
	if mMOToType != 5 then
		(
		if mMOToRangeStart > mTAC then 
			(
			MessageBox "You seemed to have picked an improper 'To' start value. Please reselect." title:"materialMover"
			return false
			)
		-- Adjust Array To Match From Range
		matArray = sLibGetRangeFromArray matArray mMOFromRangeStart mMOFromRangeEnd
		mAC = matArray.count

		-- Adjust Array To Match To Range
		if mMOOrder == 1 then
			(
			valueOver = (mMOToRangeStart + mAC) - mTAC - 1
			if valueOver > 0 then 
				(
				matArray = sLibGetRangeFromArray matArray 1 (mAC - valueOver)
				mAC = matArray.count
				)
			)
		else if mMOOrder == 2 then
			(
			valueOver = (mMOToRangeStart + mAC) - mTAC - 1
			if valueOver > 0 then 
				(
				matArray = sLibGetRangeFromArray matArray 1 (mAC - valueOver)
				mAC = matArray.count
				)
			else if valueOver < 0 then 
				(
				for i = 1 to abs(valueOver) do
					(
					append matArray matArray[i]
					)
				mAC = matArray.count
				)
			)
		else if mMOOrder == 3 then
			(
			b = #()
			for i = 1 to (mTAC - mMOToRangeStart + 1) do
				(
				append b matArray[(random 1 mAC)] 
				)
			matArray = b
			mAC = matArray.count
			)
		else if mMOOrder == 4 then
			(
			valueOver = (mMOToRangeStart + mAC) - mTAC - 1
			if valueOver > 0 then 
				(
				matArray = sLibGetRangeFromArray matArray 1 (mAC - valueOver)
				mAC = matArray.count
				)
			)
		)

	-- Sort
	if mMOSortAlpha == true then qsort matArray sLibNameCompareCaseInsensitive

	-- Perform The Move
	if mMOToType == 1 then
		(
		-- Scene Materials
		for i = 1 to mAC do
			(
			if mMOFromType == 6 then matToArray[(mMOToRangeStart-1)+i].material = copy matArray[i]
			else matToArray[(mMOToRangeStart-1)+i].material = matArray[i]
			)
		)
	if mMOToType == 2 then
		(
		-- Scene Selection
		for i = 1 to mAC do
			(
			if mMOFromType == 6 then matToArray[(mMOToRangeStart-1)+i].material = copy matArray[i]
			else matToArray[(mMOToRangeStart-1)+i].material = matArray[i]
			)
		)
	if mMOToType == 3 then
		(
		-- Medit
		for i = 1 to mAC do
			(
			if mMOFromType == 6 then meditMaterials[matToArray[i+mMOToRangeStart-1]] = copy matArray[i]
			else meditMaterials[matToArray[i+mMOToRangeStart-1]] = matArray[i]
			)
		)
	if mMOToType == 4 then
		(
		-- Medit
		macros.run "Medit Tools" "clear_medit_slots"
		for i = 1 to mAC do
			(
			if mMOFromType == 6 then meditMaterials[matToArray[i+mMOToRangeStart-1]] = copy matArray[i]
			else meditMaterials[matToArray[i+mMOToRangeStart-1]] = matArray[i]
			)
		)
	if mMOToType == 5 then
		(
		-- MatLib
		for i = 1 to mAC do
			(
			append currentMaterialLibrary matArray[i]
			)
		)
	)
	
fn materialMoverDefaults = 
	(
	mMOLoadDef()
	materialMover mMOFromTypeValue mMOFromRangeValue mMOFromRangeStartValue mMOFromRangeEndValue mMOPresetsValue mMOSortAlphaValue mMOOrderValue mMOToTypeValue mMOToRangeStartValue
	)
	
fn materialMoverUI = 
	(
	mMOLoadDef()
	mMOCloseOpenUI mMOPosValue
	)

fn mMOCloseOpenUI pos = 
	(
	if mMOFloater != undefined then CloseRolloutFloater mMOFloater
	mMODefineUI()
	mMOFloater = newRolloutFloater "materialMover v1.07" 180 444 pos.x pos.y
	addRollout mMORollout mMOFloater
	)

fn mMODo = 
	(
	materialMover mMOFromTypeValue mMOFromRangeValue mMOFromRangeStartValue mMOFromRangeEndValue mMOPresetsValue mMOSortAlphaValue mMOOrderValue mMOToTypeValue mMOToRangeStartValue
	if mMOFloater != undefined then CloseRolloutFloater mMOFloater
	)

fn mMOApply = 
	(
	materialMover mMOFromTypeValue mMOFromRangeValue mMOFromRangeStartValue mMOFromRangeEndValue mMOPresetsValue mMOSortAlphaValue mMOOrderValue mMOToTypeValue mMOToRangeStartValue
	)
	
fn mMOHelp = 
	(
	sLibSSPrintHelp "materialMover"
	)
	
fn mMOLoadDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	mMOInputFilename = presetDir + "materialMover.ini"
	if (sLibFileExist mMOInputFilename == true) then
		(
		mMOFromTypeValue = execute (getINISetting mMOInputFilename "materialMover" "mMOFromTypeValue")
		mMOFromRangeValue = execute (getINISetting mMOInputFilename "materialMover" "mMOFromRangeValue")
		mMOFromRangeStartValue = execute (getINISetting mMOInputFilename "materialMover" "mMOFromRangeStartValue")
		mMOFromRangeEndValue = execute (getINISetting mMOInputFilename "materialMover" "mMOFromRangeEndValue")
		mMOPresetsValue = execute (getINISetting mMOInputFilename "materialMover" "mMOPresetsValue")
		mMOSortAlphaValue = execute (getINISetting mMOInputFilename "materialMover" "mMOSortAlphaValue")
		mMOOrderValue = execute (getINISetting mMOInputFilename "materialMover" "mMOOrderValue")
		mMOToTypeValue = execute (getINISetting mMOInputFilename "materialMover" "mMOToTypeValue")
		mMOToRangeStartValue = execute (getINISetting mMOInputFilename "materialMover" "mMOToRangeStartValue")
		mMOPosValue = execute (getINISetting mMOInputFilename "materialMover" "mMOPosValue")
		
		if mMOFromTypeValue == OK then mMOFromTypeValue = 1
		if mMOFromRangeValue == OK then mMOFromRangeValue = 1
		if mMOFromRangeStartValue == OK then mMOFromRangeStartValue = 1
		if mMOFromRangeEndValue == OK then mMOFromRangeEndValue = 24
		if mMOPresetsValue == OK then mMOPresetsValue = 1
		if mMOSortAlphaValue == OK then mMOSortAlphaValue = true
		if mMOOrderValue == OK then mMOOrderValue = 1
		if mMOToTypeValue == OK then mMOToTypeValue = 3
		if mMOToRangeStartValue == OK then mMOToRangeStartValue = 1
		if mMOPosValue == OK then mMOPosValue = [400,400]
		)
	else
		(
		mMOFromTypeValue = 1
		mMOFromRangeValue = 1
		mMOFromRangeStartValue = 1
		mMOFromRangeEndValue = 24
		mMOPresetsValue = 1
		mMOSortAlphaValue = true
		mMOOrderValue = 1
		mMOToTypeValue = 3
		mMOToRangeStartValue = 1
		mMOPosValue = [400,400]
		)
	)
	
fn mMOSaveDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	if (getDirectories presetDir).count == 0 then makeDir presetDir
	mMOOutputFilename = presetDir + "materialMover.ini"
	if (sLibFileExist mMOOutputFilename == true) then deleteFile mMOOutputFilename
	setINISetting mMOOutputFilename "materialMover" "mMOFromTypeValue" (mMOFromTypeValue as string)
	setINISetting mMOOutputFilename "materialMover" "mMOFromRangeValue" (mMOFromRangeValue as string)
	setINISetting mMOOutputFilename "materialMover" "mMOFromRangeStartValue" (mMOFromRangeStartValue as string)
	setINISetting mMOOutputFilename "materialMover" "mMOFromRangeEndValue" (mMOFromRangeEndValue as string)
	setINISetting mMOOutputFilename "materialMover" "mMOPresetsValue" (mMOPresetsValue as string)
	setINISetting mMOOutputFilename "materialMover" "mMOSortAlphaValue" (mMOSortAlphaValue as string)
	setINISetting mMOOutputFilename "materialMover" "mMOOrderValue" (mMOOrderValue as string)
	setINISetting mMOOutputFilename "materialMover" "mMOToTypeValue" (mMOToTypeValue as string)
	setINISetting mMOOutputFilename "materialMover" "mMOToRangeStartValue" (mMOToRangeStartValue as string)
	setINISetting mMOOutputFilename "materialMover" "mMOPosValue" (mMOFloater.pos as string)
	)

-- UI

fn mMODefineUI = 
	(
	rollout mMORollout "materialMover"
		(
		group "From:"
		(
		dropdownlist mMOFromTypeDropdown "" items:#("Scene Materials", "Scene Selection Materials", "Medit", "Material Library", "Preset Instances", "Preset Copies") selection:mMOFromTypeValue
		label label1 "Members:" across:2 align:#left
		label label2 "0" align:#right
		dropdownlist mMOFromRangeDropdown "" items:#("Full Range", "Specific Range") selection:mMOFromRangeValue width:110 align:#right
		spinner mMOFromRangeStartSpinner "Start: " range:[1,9999999,mMOFromRangeStartValue] type:#integer fieldWidth:40 align:#right
		spinner mMOFromRangeEndSpinner "End: " range:[1,9999999,mMOFromRangeEndValue] type:#integer fieldWidth:40 align:#right
		dropdownlist mMOPresetsDropdown "" items:#("Standard", "Raytrace", "Brazil 1", "Brazil 2", "mr A&D", "VrayMtl") selection:mMOPresetsValue
		)
		on mMOFromTypeDropdown selected i do 
			(
			if i == 1 then 
				(
				label2.text = ((sLibGetSceneMaterials()).count) as string
				mMOPresetsDropdown.enabled = false
				)
			else if i == 2 then 
				(
				label2.text = ((sLibGetMaterialsOnSelectedObjects()).count) as string
				mMOPresetsDropdown.enabled = false
				)
			else if i == 3 then 
				(
				label2.text = "24"
				mMOPresetsDropdown.enabled = false
				)
			else if i == 4 then 
				(
				label2.text = ((sLibGetMatLibMaterials()).count) as string
				mMOPresetsDropdown.enabled = false
				)
			else if i == 5 then 
				(
				label2.text = "1"
				mMOPresetsDropdown.enabled = true
				)
			else if i == 6 then 
				(
				label2.text = "1"
				mMOPresetsDropdown.enabled = true
				)
			mMOFromTypeValue = i
			)
		on mMOFromRangeDropdown selected i do 
			(
			mMOFromRangeValue = i
			if i == 1 then (mMOFromRangeStartSpinner.enabled = false;mMOFromRangeEndSpinner.enabled = false)
			else if i == 2 then (mMOFromRangeStartSpinner.enabled = true;mMOFromRangeEndSpinner.enabled = true)			
			)
		on mMOFromRangeStartSpinner changed val do mMOFromRangeStartValue = val
		on mMOFromRangeEndSpinner changed val do mMOFromRangeEndValue = val
		on mMOPresetsDropdown selected i do mMOPresetsValue = i
		
		group "To:"
		(
		dropdownlist mMOToTypeDropdown "" items:#("Scene Objects", "Selected Objects", "Medit", "Medit After Clear", "Material Library") selection:mMOToTypeValue
		label label3 "Members:" across:2 align:#left
		label label4 "0" align:#right
		dropdownlist mMOOrderDropdown "" items:#("1 to 1", "Repeat", "Random", "UnUsed") selection:mMOOrderValue width:110 align:#right
		spinner mMOToRangeStartSpinner "Start: " range:[1,9999999,mMOToRangeStartValue] type:#integer fieldWidth:40 align:#right
		)
		on mMOToTypeDropdown selected i do 
			(
			mMOToTypeValue = i
			if i == 1 then 
				(
				a = for i in $* collect i
				label4.text = (a.count) as string
				mMOToRangeStartSpinner.enabled = true
				)
			else if i == 2 then 
				(
				a = for i in selection collect i
				label4.text = (a.count) as string
				mMOToRangeStartSpinner.enabled = true
				)
			else if i == 3 then 
				(
				label4.text = "24"
				mMOToRangeStartSpinner.enabled = true
				)
			else if i == 4 then 
				(
				label4.text = "24"
				mMOToRangeStartSpinner.enabled = true
				)
			else if i == 5 then 
				(
				label4.text = ((sLibGetMatLibMaterials()).count) as string
				mMOToRangeStartSpinner.enabled = false
				)
			)
		on mMOOrderDropdown selected i do mMOOrderValue = i
		on mMOToRangeStartSpinner changed val do mMOToRangeStartValue = val

		group "Options:"
		(
		checkbox mMOSortAlphaCheckbox "Sort Mats Alphabetical" checked:mMOSortAlphaValue align:#left
		button mMORefreshButton "Refresh Members" toolTip:"Refresh Member Number" width:130
		)
		on mMOSortAlphaCheckbox changed state do mMOSortAlphaValue = state
		on mMORefreshButton pressed do 
			(
			curPos = mMOFloater.pos
			mMOCloseOpenUI curPos
			)

		button mMODoButton "Do" width:70 toolTip:"Do It and Close UI" pos:[11,363]
		on mMODoButton pressed do mMODo()
		button mMOApplyButton "Apply" width:70 toolTip:"Do It and Keep UI Open" pos:[83,363]
		on mMOApplyButton pressed do mMOApply()
		button mMOHelpButton "Help" width:70 toolTip:"Help" pos:[11,387]
		on mMOHelpButton pressed do mMOHelp()
		button mMOSaveDefButton "SaveDef" width:70 toolTip:"Save Current Settings as Default" pos:[83,387]
		on mMOSaveDefButton pressed do mMOSaveDef()
		
		on mMORollout open do
			(
			-- Update From
			if mMOFromTypeValue == 1 then 
				(
				label2.text = ((sLibGetSceneMaterials()).count) as string
				mMOPresetsDropdown.enabled = false
				)
			else if mMOFromTypeValue == 2 then 
				(
				label2.text = ((sLibGetMaterialsOnSelectedObjects()).count) as string
				mMOPresetsDropdown.enabled = false
				)
			else if mMOFromTypeValue == 3 then 
				(
				label2.text = "24"
				mMOPresetsDropdown.enabled = false
				)
			else if mMOFromTypeValue == 4 then 
				(
				label2.text = ((sLibGetMatLibMaterials()).count) as string
				mMOPresetsDropdown.enabled = false
				)
			else if mMOFromTypeValue == 5 then 
				(
				label2.text = "1"
				mMOPresetsDropdown.enabled = true
				)
			else if mMOFromTypeValue == 6 then 
				(
				label2.text = "1"
				mMOPresetsDropdown.enabled = true
				)
						
			-- Update Range
			if mMOFromRangeValue == 1 then (mMOFromRangeStartSpinner.enabled = false;mMOFromRangeEndSpinner.enabled = false)
			else if mMOFromRangeValue == 2 then (mMOFromRangeStartSpinner.enabled = true;mMOFromRangeEndSpinner.enabled = true)
			
			-- Update To
			if mMOToTypeValue == 1 then 
				(
				a = for i in $* collect i
				label4.text = (a.count) as string
				mMOToRangeStartSpinner.enabled = true
				)
			else if mMOToTypeValue == 2 then 
				(
				a = for i in selection collect i
				label4.text = (a.count) as string
				mMOToRangeStartSpinner.enabled = true
				)
			else if mMOToTypeValue == 3 then 
				(
				label4.text = "24"
				mMOToRangeStartSpinner.enabled = true
				)
			else if mMOToTypeValue == 4 then 
				(
				label4.text = "24"
				mMOToRangeStartSpinner.enabled = true
				)
			else if mMOToTypeValue == 5 then 
				(
				label4.text = ((sLibGetMatLibMaterials()).count) as string
				mMOToRangeStartSpinner.enabled = false
				)
			)
		)
	)
)
-------------------------------------------------------------------------------