-------------------------------------------------------------------------------
-- materialInfoDisplayer.ms
-- By Neil Blevins (info@neilblevins.com)
-- v 1.13
-- Created On: 11/29/05
-- Modified On: 03/05/19
-- tested using Max 2017
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Required Files:
-- sLib.ms
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Description:
-- Displays various pieces of information regarding materials in your scene.
-- 1) Materials On Selected Objects
-- 2) Used MatIDs on Selected Object
-- 3) Required Map Channels Of Active Material
-- 4) Number Of Maps In Active Material
-- 5) Objects That Have The Active Material Assigned
-- 6) Materials In Scene That Contain A Map Type Based On A Search String
-- 7) Materials In Scene That Contain A Bitmap Based On A Search String
-- 8) Number Of Times A Map Type Appears In A Scene
-- 9) Top Level Materials On Selected Objects
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Tutorial:
-- Select an object that has a material assigned. Run the UI version of the 
-- script. Hit Do. A dialog opens that shows you the name of the material 
-- assigned to the object.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Revision History:
--
-- v 1.01 Added some new code to more cleanly open and close the UI.
--
-- v 1.02 Fixed a bug where if you had no object selected, the script would 
-- error out.
--
-- v 1.03 Replaced sLibGetMapsFromMaterial function with 
-- sLibGetMapsFromMaxWrapperObject. Added "Number Of Maps In Active Material" 
-- function.
--
-- v 1.04 Replaced the Close button with a Help button. Use the X button to 
-- Close the Floater.
--
-- v 1.05 Added support for max2011's Slate Material Editor.
--
-- v 1.10 Added several new tests including "Objects That Have The Active 
-- Material Assigned", "Materials In Scene That Contain A Map Type Based On 
-- A Search String", Cleanup up a lot of code.
--
-- v 1.11 Now removes duplicate entries from the "Objects That Have The Active 
-- Material Assigned" and "Materials In Scene That Contain A Map Type Based On 
-- A Search String" lists.
--
-- v 1.12 Added a test to display "Number Of Times A Map Type Appears In A Scene".
--
-- v 1.13 Added "Top Level Materials On Selected Objects" function. So if you
-- choose "Materials On Selected Objects" and you have a multi Subobject material
-- you will get that material and all submaterials. If you use "Top Level 
-- Materials On Selected Objects", you will only get the material assigned to 
-- the object itself, no submaterials.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
(
-- Globals

global materialInfoDisplayer
global materialInfoDisplayerDefaults
global materialInfoDisplayerUI

global mIDCloseOpenUI

global mIDChooseInfo

global mIDDo
global mIDApply
global mIDHelp
global mIDLoadDef
global mIDSaveDef

global mIDDefineUI
global mIDRollout
global mIDFloater

-- Includes

include "$scripts\SoulburnScripts\lib\sLib.ms"

-- Variables

mIDInfoValue = 9
mIDMeditModeValue = 1
mIDTextInputValue = ""
mIDPosValue = [400,400]

-- Functions

fn materialInfoDisplayer mIDInfo mIDMeditMode mIDTextInput = 
	(
	undo "materialInfoDisplayer" on
		(
		mIDChooseInfo mIDInfo mIDMeditMode mIDTextInput
		)
	)
	
fn materialInfoDisplayerDefaults = 
	(
	mIDLoadDef()
	materialInfoDisplayer mIDInfoValue mIDMeditModeValue mIDTextInputValue
	)
	
fn materialInfoDisplayerUI = 
	(
	mIDLoadDef()
	mIDCloseOpenUI mIDPosValue
	)

fn mIDCloseOpenUI pos = 
	(
	if mIDFloater != undefined then CloseRolloutFloater mIDFloater
	mIDDefineUI()
	mIDFloater = newRolloutFloater "materialInfoDisplayer v1.13" 406 143 pos.x pos.y
	addRollout mIDRollout mIDFloater
	)

fn mIDChooseInfo mIDInfo mIDMeditMode mIDTextInput = 
	(
	-- Materials On Selected Objects
	if mIDInfo == 1 then
		(
		if selection.count != 0 then
			(
			mainText = "Materials On Selected Objects: "
			a = sLibGetAllMaterialsOnSelectedObjects()
			for i = 1 to a.count do
				(
				mainText += a[i].name as string
				if i != a.count then mainText += ", "
				)
			MessageBox mainText title:"materialInfoDisplayer"
			print mainText
			)
		)

	-- Used MatIDs on Selected Object
	else if mIDInfo == 2 then
		(
		if selection.count != 1 then MessageBox "Please select only one object." title:"materialInfoDisplayer"
		else
			(
			a = #()
			obj = selection[1]
			if classof obj == Editable_mesh or classof obj == Editable_Poly then
				(
				for i = 1 to (getNumFaces obj) do 
					(
					if classof obj == Editable_mesh then aFaceID = getFaceMatID obj i
					else aFaceID = polyop.getFaceMatID obj i
					if finditem a (aFaceID as integer) == 0 then append a (aFaceID as integer)
					)
				)
			else MessageBox "Please choose either an Editable Mesh or an Editable Poly object." title:"materialInfoDisplayer"
			if a.count != 0 then
				(
				sort a
				mainText = "Used Material IDs: "
				for i = 1 to a.count do
					(
					mainText += a[i] as string
					if i != a.count then mainText += ", "
					)
				MessageBox mainText title:"materialInfoDisplayer"
				print mainText
				)
			)
		)

	-- Required Map Channels Of Active Material
	else if mIDInfo == 3 then
		(
		if mIDMeditMode == 2 then
			(
			if sLibMaxVer() < 13.0 then (MessageBox "Slate Medit Mode only works with Max 2011 and up, please change to mode to: Use Classic Mat Editor" title:"materialInfoDisplayer";mat = undefined)
			else (mat = sme.GetMtlInParamEditor())
			)
		else (mat = (medit.GetCurMtl()))
		if superclassof mat == material then
			(
			error = false
			mapsInMaterial = #()
			m = #()
			sLibGetMapsFromMaxWrapperObject mat mapsInMaterial
			for i in mapsInMaterial do
				(
				try
					(
					if classof i.coords == StandardUVGen then
						(
						if i.coords.mappingType == 0 and i.coords.mapping == 0 then
							(
							if finditem m i.coords.mapChannel == 0 then append m i.coords.mapChannel
							)
						)
					else if classof i.coords == StandardXYZGen then
						(
						if i.coords.coordType == 2 then
							(
							if finditem m i.coords.mapChannel == 0 then append m i.coords.mapChannel
							)
						)
					)
				catch
					(
					error = true
					)
				)
			mainText = ""
			sort m
			if m.count == 0 then mainText += "No Map Channels are being used by this material."
			else 
				(
				mainText += "Required Map Channels Of Active Material: "
				for i = 1 to m.count do
					(
					mainText += m[i] as string
					if i != m.count then mainText += ", "
					)
				)
			if error == true then mainText += " Note: This material has maps that are not maxscript readable, and so there may be additional map channels used that this script can't access."
			MessageBox mainText title:"materialInfoDisplayer"
			print mainText
			)
		else (MessageBox "Please pick a material in the Medit" title:"materialInfoDisplayer")
		)

	-- Number Of Maps In Active Material
	else if mIDInfo == 4 then
		(
		b = #()
		if mIDMeditMode == 2 then
			(
			if sLibMaxVer() < 13.0 then (MessageBox "Slate Medit Mode only works with Max 2011 and up, please change to mode to: Use Classic Mat Editor" title:"materialInfoDisplayer";mat = undefined)
			else (mat = sme.GetMtlInParamEditor())
			)
		else (mat = (medit.GetCurMtl()))

		if superclassof mat == material then
			(
			mats = sLibGetAllMaterials mat
			for m in mats do
				(
				a = #()
				sLibGetMapsFromMaxWrapperObject m a
				join b a
				)
			sLibTrimDups b
			mainText = "Number Of Maps In Active Material: " + (b.count) as string
			MessageBox mainText title:"materialInfoDisplayer"
			print mainText
			)
		else (MessageBox "Please pick a material in the Medit" title:"materialInfoDisplayer")
		)

	-- Objects That Have The Active Material Assigned
	else if mIDInfo == 5 then
		(
		if mIDMeditMode == 2 then
			(
			if sLibMaxVer() < 13.0 then (MessageBox "Slate Medit Mode only works with Max 2011 and up, please change to mode to: Use Classic Mat Editor" title:"materialInfoDisplayer";mat = undefined)
			else (mat = sme.GetMtlInParamEditor())
			)
		else (mat = (medit.GetCurMtl()))
		if mat != undefined then
			(
			a = #()
			for i in $* do if i.material == mat then append a i
			mainText = "Objects That Have The Active Material Assigned: "
			qsort a sLibNameCompareCaseInsensitive
			if a.count != 0 then
				(
				for i = 1 to a.count do
					(
					mainText += a[i].name as string
					if i != a.count then mainText += ", "
					)
				)
			MessageBox mainText title:"materialInfoDisplayer"
			print mainText
			)
		)

	-- Materials In Scene That Contain A Map Type Based On A Search String
	else if mIDInfo == 6 then
		(
		if mIDTextInput == "" then (MessageBox "Please give some input text" title:"materialInfoDisplayer")
		else
			(
			a = sLibGetAllSceneMaterials()
			finalMaterials = #()
			for i in a do
				(
				b = #()
				sLibGetMapsFromMaxWrapperObject i b
				for w in b do
					(
					if (findString ((classof w) as string) mIDTextInput) != undefined then 
						(
						append finalMaterials i
						)
					)
				)
			sLibTrimDups finalMaterials
			if finalMaterials.count != 0 then
				(
				mainText = "The Material That Contains Map Types Similar To The Text Input Are: "
				for i = 1 to finalMaterials.count do
					(
					mainText += finalMaterials[i].name as string
					if i != finalMaterials.count then mainText += ", "
					)
				)
			else mainText = "No Materials Found"
			MessageBox mainText title:"materialInfoDisplayer"
			print mainText
			)
		)
		
	-- Materials In Scene That Contain A Bitmap Based On A Search String
	else if mIDInfo == 7 then
		(
		if mIDTextInput == "" then (MessageBox "Please give some input text" title:"materialInfoDisplayer")
		else
			(
			a = sLibGetAllSceneMaterials()
			finalMaterials = #()
			for i in a do
				(
				b = #()
				items = #()
				itemsNames = #()
				sLibGetMapsFromMaxWrapperObject i b
				items1 = sLibGetBitmapsFromMaps b
				items2 = sLibGetVrayBitmapsFromMaps b
				items = items1 + items2
				for j in items do 
					(
					if classof j == Bitmaptexture then append itemsNames j.filename
					else if classof j == VRayHDRI then append itemsNames j.HDRIMapName
					)
				for w in itemsNames do
					(
					if (findString (w as string) mIDTextInput) != undefined then 
						(
						append finalMaterials i
						)
					)
				)
			sLibTrimDups finalMaterials
			if finalMaterials.count != 0 then
				(
				mainText = "The Material That Contains Bitmaps Similar To The Text Input Are: "
				for i = 1 to finalMaterials.count do
					(
					mainText += finalMaterials[i].name as string
					if i != finalMaterials.count then mainText += ", "
					)
				)
			else mainText = "No Materials Found"
			MessageBox mainText title:"materialInfoDisplayer"
			print mainText
			)
		)
		
	-- Number Of Times A Map Type Appears In A Scene
	else if mIDInfo == 8 then
		(
		if mIDTextInput == "" then (MessageBox "Please give some input text" title:"materialInfoDisplayer")
		else
			(
			a = sLibGetAllSceneMaterials()
			finalMaps = #()
			for i in a do
				(
				b = #()
				sLibGetMapsFromMaxWrapperObject i b
				for w in b do
					(
					if (findString ((classof w) as string) mIDTextInput) != undefined then 
						(
						append finalMaps w
						)
					)
				)
			sLibTrimDups finalMaps
			if finalMaps.count != 0 then
				(
				mainText = "There are " + (finalMaps.count as string) + " " + (mIDTextInput) + " maps in the scene."
				)
			else mainText = "No Maps Found"
			MessageBox mainText title:"materialInfoDisplayer"
			print mainText
			)
		)
		
	-- Top Level Materials On Selected Objects
	if mIDInfo == 9 then
		(
		if selection.count != 0 then
			(
			mainText = "Top Level Materials On Selected Objects: "
			a = sLibGetMaterialsOnSelectedObjects()
			for i = 1 to a.count do
				(
				mainText += a[i].name as string
				if i != a.count then mainText += ", "
				)
			MessageBox mainText title:"materialInfoDisplayer"
			print mainText
			)
		)
	)

fn mIDDo = 
	(
	materialInfoDisplayer mIDInfoValue mIDMeditModeValue mIDTextInputValue
	if mIDFloater != undefined then CloseRolloutFloater mIDFloater
	)

fn mIDApply = 
	(
	materialInfoDisplayer mIDInfoValue mIDMeditModeValue mIDTextInputValue
	)
	
fn mIDHelp = 
	(
	sLibSSPrintHelp "materialInfoDisplayer"
	)
	
fn mIDLoadDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	mIDInputFilename = presetDir + "materialInfoDisplayer.ini"
	if (sLibFileExist mIDInputFilename == true) then
		(
		mIDInfoValue = execute (getINISetting mIDInputFilename "materialInfoDisplayer" "mIDInfoValue")
		mIDMeditModeValue = execute (getINISetting mIDInputFilename "materialInfoDisplayer" "mIDMeditModeValue")
		mIDTextInputValue = execute (getINISetting mIDInputFilename "materialInfoDisplayer" "mIDTextInputValue")
		mIDPosValue = execute (getINISetting mIDInputFilename "materialInfoDisplayer" "mIDPosValue")
		
		if mIDInfoValue == OK then mIDInfoValue = 9
		if mIDMeditModeValue == OK then mIDMeditModeValue = 1
		if mIDTextInputValue == OK then mIDTextInputValue = 1
		if mIDPosValue == OK then mIDPosValue = [400,400]
		)
	else
		(
		mIDInfoValue = 9
		mIDMeditModeValue = 1
		mIDTextInputValue = ""
		mIDPosValue = [400,400]
		)
	)
	
fn mIDSaveDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	if (getDirectories presetDir).count == 0 then makeDir presetDir
	mIDOutputFilename = presetDir + "materialInfoDisplayer.ini"
	if (sLibFileExist mIDOutputFilename == true) then deleteFile mIDOutputFilename
	setINISetting mIDOutputFilename "materialInfoDisplayer" "mIDInfoValue" (mIDInfoValue as string)
	setINISetting mIDOutputFilename "materialInfoDisplayer" "mIDMeditModeValue" (mIDMeditModeValue as string)
	setINISetting mIDOutputFilename "materialInfoDisplayer" "mIDTextInputValue" (mIDTextInputValue as string)
	setINISetting mIDOutputFilename "materialInfoDisplayer" "mIDPosValue" (mIDFloater.pos as string)
	)

-- UI

fn mIDDefineUI = 
	(
	rollout mIDRollout "materialInfoDisplayer"
		(
		label label1 "Info:" pos:[10,10]
		dropdownlist mIDInfoDropdown "" items:#("Materials On Selected Objects", "Used MatIDs on Selected Object", "Required Map Channels Of Active Material", "Number Of Maps In Active Material", "Objects That Have The Active Material Assigned", "Materials In Scene That Contain A Map Type Based On A Search String", "Materials In Scene That Contain A Bitmap Based On A Search String", "Number Of Times A Map Type Appears In A Scene", "Top Level Materials On Selected Objects") selection:mIDInfoValue pos:[40,7] width:340
		dropdownlist mIDMeditModeDropdown "" items:#("Use Classic Mat Editor", "Use Slate Mat Editor") selection:mIDMeditModeValue width:150 align:#right
		edittext mIDTextInputEditText "Text Input:" fieldWidth:200 text:mIDTextInputValue align:#right

		on mIDInfoDropdown selected i do 
			(
			mIDInfoValue = i
			if mIDInfoValue == 6 or mIDInfoValue == 7 or mIDInfoValue == 8 then mIDTextInputEditText.enabled = true else mIDTextInputEditText.enabled = false
			)
		on mIDMeditModeDropdown selected i do mIDMeditModeValue = i
		on mIDTextInputEditText changed text do mIDTextInputValue = text

		button mIDDoButton "Do" width:70 toolTip:"Do It and Close UI" pos:[96,87]
		on mIDDoButton pressed do mIDDo()
		button mIDApplyButton "Apply" width:70 toolTip:"Do It and Keep UI Open" pos:[168,87]
		on mIDApplyButton pressed do mIDApply()
		button mIDHelpButton "Help" width:70 toolTip:"Help" pos:[240,87]
		on mIDHelpButton pressed do mIDHelp()
		button mIDSaveDefButton "SaveDef" width:70 toolTip:"Save Current Settings as Default" pos:[312,87]
		on mIDSaveDefButton pressed do mIDSaveDef()

		on mIDRollout open do
			(
			if mIDInfoValue == 6 or mIDInfoValue == 7 or mIDInfoValue == 8 then mIDTextInputEditText.enabled = true else mIDTextInputEditText.enabled = false
			)
		)
	)
)
-------------------------------------------------------------------------------