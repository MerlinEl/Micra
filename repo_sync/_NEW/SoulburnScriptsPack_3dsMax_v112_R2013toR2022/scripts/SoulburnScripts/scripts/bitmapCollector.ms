-------------------------------------------------------------------------------
-- bitmapCollector.ms
-- By Neil Blevins (info@neilblevins.com)
-- v 1.08
-- Created On: 02/15/08
-- Modified On: 10/13/17
-- tested using Max 2018
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Required Files:
-- sLib.ms
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Description:
-- Collects all the scene bitmaps and places them into a single directory, 
-- updating your scene to point to their new home.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Tutorial:
-- Open a scene that contains a lot of bitmaps. Run the UI version of the 
-- script. Choose a Directory. Hit Do. All the bitmaps you choosed will be copied
-- to the directory you specified, and now all the scene materials point
-- to that directory.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Known Issues:
-- Does not currently work if your bitmap is an ifl. Does not capture darktree
-- maps.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Revision History:
--
-- v 1.01 Replaced the Close button with a Help button. Use the X button to 
-- Close the Floater.
--
-- v 1.02 Now searches your mappaths and local maxdir for missing bitmaps.
--
-- v 1.03 Now gets maps associated with UnwrapUVW modifiers.
--
-- v 1.04 Added Extra Copy Path value. If you want to copy the maps to more 
-- than one directory, add the extra paths in here, with a , between each path. 
-- For example, add this line...
--
-- c:\temp,d:\temp
--
-- if you want to also copy the maps to the 2 temp directories on your c and d 
-- drive. Two notes. First, if you set the script to "move" mode, it will move 
-- the bitmaps to the main directory, but will still only copy the bitmaps to 
-- the Extra paths. Second, The max file will update the maps in the scene to 
-- point at the main directory, it will not update the file to look at the 
-- extra paths. So think of extra paths as a simple copying of all collected 
-- maps to multiple extra directories.
--
-- v 1.05 Fixd a bug that would cause the script to crash if you choose 
-- an improper directory.
-- 
-- v 1.06 This script now uses sLibFilenameFromPath to replace filenameFromPath 
-- that no longer works properly in max 2010.
-- 
-- v 1.07 Fixed a crash bug when it tried to process a blank bitmap map.
-- 
-- v 1.08 Added vray bitmap support.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
(
-- Globals

global bitmapCollector
global bitmapCollectorDefaults
global bitmapCollectorUI

global bCCloseOpenUI

global bCCollect
global bCFindMissingFile

global bCDo
global bCApply
global bCHelp
global bCLoadDef
global bCSaveDef

global bCDefineUI
global bCRollout
global bCFloater

-- Includes

include "$scripts\SoulburnScripts\lib\sLib.ms"

-- Variables

bCPathValue = ""
bCMapType1Value = false
bCMapType2Value = true
bCMapType3Value = false
bCMapType4Value = true
bCMapType5Value = true
bCMapType6Value = true
bCMapType7Value = true
bCMapType8Value = true
bCMapType9Value = true
bCMapType10Value = true
bCMapType11Value = true
bCActionValue = 1
bCUpdateMatsValue = true
bCOverwriteValue = true
bCExtraPathValue = ""
bCPosValue = [400,400]

-- Functions

fn bitmapCollector bCPath bCMapType1 bCMapType2 bCMapType3 bCMapType4 bCMapType5 bCMapType6 bCMapType7 bCMapType8 bCMapType9 bCMapType10 bCMapType11 bCAction bCUpdateMats bCOverwrite bCExtraPathValue = 
	(
	if bCPath != "" then 
		(
		if bCAction == 2 then 
			(
			if (queryBox "Are you SURE you want to move the maps, and not just copy them?" title:"bitmapCollector") == true then 
				(
				bCCollect bCPath bCMapType1 bCMapType2 bCMapType3 bCMapType4 bCMapType5 bCMapType6 bCMapType7 bCMapType8 bCMapType9 bCMapType10 bCMapType11 bCAction bCUpdateMats bCOverwrite
				)
			)
		else bCCollect bCPath bCMapType1 bCMapType2 bCMapType3 bCMapType4 bCMapType5 bCMapType6 bCMapType7 bCMapType8 bCMapType9 bCMapType10 bCMapType11 bCAction bCUpdateMats bCOverwrite
		)
	else (MessageBox "Please pick a valid path" title:"bitmapCollector")
	)
	
fn bCCollect bCPath bCMapType1 bCMapType2 bCMapType3 bCMapType4 bCMapType5 bCMapType6 bCMapType7 bCMapType8 bCMapType9 bCMapType10 bCMapType11 bCAction bCUpdateMats bCOverwrite = 
	(		
	-- setup variables
	bCMapType1Array = #()
	bCMapType2Array = #()
	bCMapType3Array = #()
	bCMapType4Array = #()
	bCMapType5Array = #()
	bCMapType6Array = #()
	bCMapType7Array = #()
	bCMapType8Array = #()
	bCMapType9Array = #()
	bCMapType10Array = #()
	bCMapType11Array = #()
	allMaps = #()
	allBitMaps = #()
	filesCopied = 0
	
	-- collect bitmap info
	if bCMapType1 == true then bCMapType1Array = sLibGetAllMapsFromSelectedObjects()
	if bCMapType2 == true then bCMapType2Array = sLibGetAllSceneMaps()
	if bCMapType3 == true then bCMapType3Array = sLibGetAllMeditMaps()
	if bCMapType4 == true then bCMapType4Array = sLibGetAllEnvironmentMaps()
	if bCMapType5 == true then bCMapType5Array = sLibGetAllDisplaceModMaps()
	if bCMapType6 == true then bCMapType6Array = sLibGetAllDisplaceSWMaps()
	if bCMapType7 == true then bCMapType7Array = sLibGetAllFogMaps()
	if bCMapType8 == true then bCMapType8Array = sLibGetAllBlurEffectMaps()
	if bCMapType9 == true then bCMapType9Array = sLibGetAllProjectorLightMaps()
	if bCMapType10 == true then bCMapType10Array = sLibGetAllBrazilSkylightMaps()
	if bCMapType11 == true then bCMapType11Array = sLibGetAllUnwrapUVWMaps()
	
	allMaps = bCMapType1Array + bCMapType2Array + bCMapType3Array + bCMapType4Array + bCMapType5Array + bCMapType6Array + bCMapType7Array + bCMapType8Array + bCMapType9Array + bCMapType10Array + bCMapType11Array
	allBitMaps = (sLibGetBitmapsFromMaps allMaps) + (sLibGetVrayBitmapsFromMaps allMaps)
	
	sLibTrimDups allBitMaps
	
	-- collect bitmaps
	progressStart "bitmapCollector"
	escapeEnable = false
	donesearch = false
	
	-- prep extra dirs
	extraDirs = #()
	extraDirsTemp = filterString bCExtraPathValue ","
	for e in extraDirsTemp do
		(
		if e[e.count] != "\\" then append extraDirs (e + "\\")
		)
	
	for i = 1 to allBitMaps.count do
		(
		m = ((i as float)/(allBitMaps.count as float))*100
		
		if (classof allBitMaps[i]) == Bitmaptexture then bitmapFileIn = allBitMaps[i].filename
		else if (classof allBitMaps[i]) == VRayHDRI then bitmapFileIn = allBitMaps[i].HDRIMapName
		
		if bitmapFileIn != "" and bitmapFileIn != undefined then
			(
			bitmapFileOut = (bCPath + (sLibFilenameFromPath bitmapFileIn))
		
			if bCOverwrite == true then
				(
				if (sLibFileExist bitmapFileIn) == false then
					(
					donesearch = true
					foundfile = bCFindMissingFile bitmapFileIn
					if foundfile != "" then bitmapFileIn = foundfile
					)
				copyfile bitmapFileIn bitmapFileOut
				
				-- extra dirs
				for e in extraDirs do
					(
					copyfile bitmapFileIn (e + (sLibFilenameFromPath bitmapFileIn))
					)
				
				filesCopied += 1
				)
			else 
				(
				if (sLibFileExist bitmapFileOut) == false then 
					(
					if (sLibFileExist bitmapFileIn) == false then
						(
						donesearch = true
						foundfile = bCFindMissingFile bitmapFileIn
						if foundfile != "" then bitmapFileIn = foundfile
						)
					copyfile bitmapFileIn bitmapFileOut
					
					-- extra dirs
					for e in extraDirs do
						(
						copyfile bitmapFileIn (e + (sLibFilenameFromPath bitmapFileIn))
						)
									
					filesCopied += 1
					)
				)
			if bCUpdateMats == true then 
				(
				if (classof allBitMaps[i]) == Bitmaptexture then allBitMaps[i].filename = bitmapFileOut
				else if (classof allBitMaps[i]) == VRayHDRI then allBitMaps[i].HDRIMapName = bitmapFileOut			
				)
			if bCAction == 2 then deletefile bitmapFileIn
			)
		progressUpdate m
		)
		
	progressEnd()
	
	print "bitmapCollector Results:"
	print ("Bitmaps Copied: " + (filesCopied as string))
	if donesearch == true then print "At least one bitmap required a search of your map paths and maxfile dir in order to copy properly"
	)

fn bCFindMissingFile myfile = 
	(
	foundfile = ""
	-- first look in maxfile directory
	if (maxFilePath != "") then 
		(
		curfile = (maxFilePath + (sLibFilenameFromPath myfile))
		if (sLibFileExist curfile) == true then foundfile = curfile
		)
	if foundfile == "" then
		(
		-- look in map paths
		curfile = (sLibFindBitmapInMapPaths (sLibFilenameFromPath myfile))
		if curfile != false then foundfile = curfile
		)
	if foundfile == "" then
		(
		-- look in subfolders of maxfile directory
		if (maxFilePath != "") then 
			(
			mytype = (getFilenameType myfile)
			a = sLibGetAllFilesInDir maxFilePath true (substring mytype 2 (mytype.count - 1))
			curfile = ""
			if a.count != 0 then
				(
				for i = 1 to a.count do
					(
					if (sLibFilenameFromPath a[i]) == (sLibFilenameFromPath myfile) then (curfile = a[i];exit)
					)
				)
			if curfile != "" then foundfile = curfile
			)
		)
	return foundfile
	)
	
fn bitmapCollectorDefaults = 
	(
	bCLoadDef()
	bitmapCollector bCPathValue bCMapType1Value bCMapType2Value bCMapType3Value bCMapType4Value bCMapType5Value bCMapType6Value bCMapType7Value bCMapType8Value bCMapType9Value bCMapType10Value bCMapType11Value bCActionValue bCUpdateMatsValue bCOverwriteValue bCExtraPathValue
	)
	
fn bitmapCollectorUI = 
	(
	bCLoadDef()
	bCCloseOpenUI bCPosValue
	)

fn bCCloseOpenUI pos = 
	(
	if bCFloater != undefined then CloseRolloutFloater bCFloater
	bCDefineUI()
	bCFloater = newRolloutFloater "bitmapCollector v1.08" 310 499 pos.x pos.y
	addRollout bCRollout bCFloater
	)

fn bCDo = 
	(
	bitmapCollector bCPathValue bCMapType1Value bCMapType2Value bCMapType3Value bCMapType4Value bCMapType5Value bCMapType6Value bCMapType7Value bCMapType8Value bCMapType9Value bCMapType10Value bCMapType11Value bCActionValue bCUpdateMatsValue bCOverwriteValue bCExtraPathValue
	if bCFloater != undefined then CloseRolloutFloater bCFloater
	)

fn bCApply = 
	(
	bitmapCollector bCPathValue bCMapType1Value bCMapType2Value bCMapType3Value bCMapType4Value bCMapType5Value bCMapType6Value bCMapType7Value bCMapType8Value bCMapType9Value bCMapType10Value bCMapType11Value bCActionValue bCUpdateMatsValue bCOverwriteValue bCExtraPathValue
	)
	
fn bCHelp = 
	(
	sLibSSPrintHelp "bitmapCollector"
	)
	
fn bCLoadDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	bCInputFilename = presetDir + "bitmapCollector.ini"
	if (sLibFileExist bCInputFilename == true) then
		(
		bCPathValue = (getINISetting bCInputFilename "bitmapCollector" "bCPathValue")
		bCMapType1Value = execute (getINISetting bCInputFilename "bitmapCollector" "bCMapType1Value")
		bCMapType2Value = execute (getINISetting bCInputFilename "bitmapCollector" "bCMapType2Value")
		bCMapType3Value = execute (getINISetting bCInputFilename "bitmapCollector" "bCMapType3Value")
		bCMapType4Value = execute (getINISetting bCInputFilename "bitmapCollector" "bCMapType4Value")
		bCMapType5Value = execute (getINISetting bCInputFilename "bitmapCollector" "bCMapType5Value")
		bCMapType6Value = execute (getINISetting bCInputFilename "bitmapCollector" "bCMapType6Value")
		bCMapType7Value = execute (getINISetting bCInputFilename "bitmapCollector" "bCMapType7Value")
		bCMapType8Value = execute (getINISetting bCInputFilename "bitmapCollector" "bCMapType8Value")
		bCMapType9Value = execute (getINISetting bCInputFilename "bitmapCollector" "bCMapType9Value")
		bCMapType10Value = execute (getINISetting bCInputFilename "bitmapCollector" "bCMapType10Value")
		bCMapType11Value = execute (getINISetting bCInputFilename "bitmapCollector" "bCMapType11Value")
		bCActionValue = execute (getINISetting bCInputFilename "bitmapCollector" "bCActionValue")
		bCUpdateMatsValue = execute (getINISetting bCInputFilename "bitmapCollector" "bCUpdateMatsValue")
		bCOverwriteValue = execute (getINISetting bCInputFilename "bitmapCollector" "bCOverwriteValue")
		bCExtraPathValue = (getINISetting bCInputFilename "bitmapCollector" "bCExtraPathValue")
		bCPosValue = execute (getINISetting bCInputFilename "bitmapCollector" "bCPosValue")
		
		if bCPathValue == OK then bCPathValue = ""
		if bCMapType1Value == OK then bCMapType1Value = false
		if bCMapType2Value == OK then bCMapType2Value = true
		if bCMapType3Value == OK then bCMapType3Value = false
		if bCMapType4Value == OK then bCMapType4Value = true
		if bCMapType5Value == OK then bCMapType5Value = true
		if bCMapType6Value == OK then bCMapType6Value = true
		if bCMapType7Value == OK then bCMapType7Value = true
		if bCMapType8Value == OK then bCMapType8Value = true
		if bCMapType9Value == OK then bCMapType9Value = true
		if bCMapType10Value == OK then bCMapType10Value = true
		if bCMapType11Value == OK then bCMapType11Value = true
		if bCActionValue == OK then bCActionValue = 1
		if bCUpdateMatsValue == OK then bCUpdateMatsValue = true
		if bCOverwriteValue == OK then bCOverwriteValue = true
		if bCExtraPathValue == OK then bCExtraPathValue = ""
		if bCPosValue == OK then bCPosValue = [400,400]
		)
	else
		(
		bCPathValue = ""
		bCMapType1Value = false
		bCMapType2Value = true
		bCMapType3Value = false
		bCMapType4Value = true
		bCMapType5Value = true
		bCMapType6Value = true
		bCMapType7Value = true
		bCMapType8Value = true
		bCMapType9Value = true
		bCMapType10Value = true
		bCMapType11Value = true
		bCActionValue = 1
		bCUpdateMatsValue = true
		bCOverwriteValue = true
		bCExtraPathValue = ""
		bCPosValue = [400,400]
		)
	)
	
fn bCSaveDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	if (getDirectories presetDir).count == 0 then makeDir presetDir
	bCOutputFilename = presetDir + "bitmapCollector.ini"
	if (sLibFileExist bCOutputFilename == true) then deleteFile bCOutputFilename
	setINISetting bCOutputFilename "bitmapCollector" "bCPathValue" (bCPathValue as string)
	setINISetting bCOutputFilename "bitmapCollector" "bCMapType1Value" (bCMapType1Value as string)
	setINISetting bCOutputFilename "bitmapCollector" "bCMapType2Value" (bCMapType2Value as string)
	setINISetting bCOutputFilename "bitmapCollector" "bCMapType3Value" (bCMapType3Value as string)
	setINISetting bCOutputFilename "bitmapCollector" "bCMapType4Value" (bCMapType4Value as string)
	setINISetting bCOutputFilename "bitmapCollector" "bCMapType5Value" (bCMapType5Value as string)
	setINISetting bCOutputFilename "bitmapCollector" "bCMapType6Value" (bCMapType6Value as string)
	setINISetting bCOutputFilename "bitmapCollector" "bCMapType7Value" (bCMapType7Value as string)
	setINISetting bCOutputFilename "bitmapCollector" "bCMapType8Value" (bCMapType8Value as string)
	setINISetting bCOutputFilename "bitmapCollector" "bCMapType9Value" (bCMapType9Value as string)
	setINISetting bCOutputFilename "bitmapCollector" "bCMapType10Value" (bCMapType10Value as string)
	setINISetting bCOutputFilename "bitmapCollector" "bCMapType11Value" (bCMapType11Value as string)
	setINISetting bCOutputFilename "bitmapCollector" "bCActionValue" (bCActionValue as string)
	setINISetting bCOutputFilename "bitmapCollector" "bCUpdateMatsValue" (bCUpdateMatsValue as string)
	setINISetting bCOutputFilename "bitmapCollector" "bCOverwriteValue" (bCOverwriteValue as string)
	setINISetting bCOutputFilename "bitmapCollector" "bCExtraPathValue" (bCExtraPathValue as string)
	setINISetting bCOutputFilename "bitmapCollector" "bCPosValue" (bCFloater.pos as string)
	)

-- UI

fn bCDefineUI = 
	(
	rollout bCRollout "bitmapCollector"
		(
		group "Path To Collect Maps To"
		(
		edittext bCPathEditText "" fieldWidth:240 text:bCPathValue align:#left across:2
		button bCGetPathButton "F" width:20 toolTip:"Choose Path" align:#right offset:[0,-2]
		)

		on bCPathEditText changed text do 
			(
			if text[text.count] != "\\" then text = text + "\\"
			bCPathValue = text
			bCPathEditText.text = text
			)
		on bCGetPathButton pressed do 
			(
			mypath = getSavePath()
			if mypath != undefined then 
				(
				if mypath[mypath.count] != "\\" then mypath = mypath + "\\"
				bCPathValue = mypath
				bCPathEditText.text = mypath
				)
			else 
				(
				bCPathValue = ""
				bCPathEditText.text = ""
				)
			)
			
		group "Bitmaps To Collect"
		(
		checkbox bCMapType1Checkbox "Maps Applied to Selected Objects" checked:bCMapType1Value align:#left
		checkbox bCMapType2Checkbox "Maps Applied To All Scene Objects" checked:bCMapType2Value align:#left
		checkbox bCMapType3Checkbox "Material Editor" checked:bCMapType3Value align:#left
		checkbox bCMapType4Checkbox "Environment" checked:bCMapType4Value align:#left
		checkbox bCMapType5Checkbox "Displace Modifiers" checked:bCMapType5Value align:#left
		checkbox bCMapType6Checkbox "Displace Spacewarps" checked:bCMapType6Value align:#left
		checkbox bCMapType7Checkbox "Fog Atmospheric" checked:bCMapType7Value align:#left
		checkbox bCMapType8Checkbox "Blur Render Effects" checked:bCMapType8Value align:#left
		checkbox bCMapType9Checkbox "Projector Lights (Standard, Brazil 1 + 2)" checked:bCMapType9Value align:#left
		checkbox bCMapType10Checkbox "Brazil Skylight (Brazil 1 + 2)" checked:bCMapType10Value align:#left
		checkbox bCMapType11Checkbox "Unwrap UVW Modifiers" checked:bCMapType11Value align:#left
		)

		on bCMapType1Checkbox changed state do bCMapType1Value = state
		on bCMapType2Checkbox changed state do bCMapType2Value = state
		on bCMapType3Checkbox changed state do bCMapType3Value = state
		on bCMapType4Checkbox changed state do bCMapType4Value = state
		on bCMapType5Checkbox changed state do bCMapType5Value = state
		on bCMapType6Checkbox changed state do bCMapType6Value = state
		on bCMapType7Checkbox changed state do bCMapType7Value = state
		on bCMapType8Checkbox changed state do bCMapType8Value = state
		on bCMapType9Checkbox changed state do bCMapType9Value = state
		on bCMapType10Checkbox changed state do bCMapType10Value = state
		on bCMapType11Checkbox changed state do bCMapType11Value = state
		
		group "Options"
		(
		dropdownlist bCActionDropdown "" items:#("Copy Bitmaps", "Move Bitmaps") selection:bCActionValue width:120
		checkbox bCUpdateMatsCheckbox "Update Scene" checked:bCUpdateMatsValue
		checkbox bCOverwriteCheckbox "Overwrite Existing Bitmaps" checked:bCOverwriteValue
		)
		
		on bCActionDropdown selected i do bCActionValue = i
		on bCUpdateMatsCheckbox changed state do bCUpdateMatsValue = state
		on bCOverwriteCheckbox changed state do bCOverwriteValue = state

		group "Extra Copy Paths"
		(
		edittext bCExtraPathEditText "" fieldWidth:262 text:bCExtraPathValue align:#left
		)
		on bCExtraPathEditText changed text do bCExtraPathValue = text

		button bCDoButton "Do" width:70 toolTip:"Do It and Close UI" pos:[5,440]
		on bCDoButton pressed do bCDo()
		button bCApplyButton "Apply" width:70 toolTip:"Do It and Keep UI Open" pos:[77,440]
		on bCApplyButton pressed do bCApply()
		button bCHelpButton "Help" width:70 toolTip:"Help" pos:[149,440]
		on bCHelpButton pressed do bCHelp()
		button bCSaveDefButton "SaveDef" width:70 toolTip:"Save Current Settings as Default" pos:[221,440]
		on bCSaveDefButton pressed do bCSaveDef()
		)
	)
)
-------------------------------------------------------------------------------