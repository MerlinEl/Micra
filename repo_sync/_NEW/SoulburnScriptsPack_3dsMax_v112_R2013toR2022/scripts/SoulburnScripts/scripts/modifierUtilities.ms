-------------------------------------------------------------------------------
-- modifierUtilities.ms
-- By Neil Blevins (info@neilblevins.com)
-- v 1.16
-- Created On: 06/20/05
-- Modified On: 10/18/20
-- tested using Max 2017
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Required Files:
-- sLib.ms
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Description:
-- Lets you perform various modifier related tasks on a set of selected objects.
-- For example, takes all the selected objects and adds / removes seperate 
-- instances of a specific modifier. Or lets you find any objects in the current
-- selection that contains a specific modifier. Add modifiers to your Favorites 
-- area for faster access. Also this script allows you to copy a modifier from 
-- 1 object and paste it to a selection of objects.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Tutorial:
-- Choose a modifier from the main list, and then hit Do or Apply to perform
-- the desired function on the selected objects. Use the "A" and "R" buttons 
-- to add and remove modifiers to and from the favorite box. Double click
-- on a modifier in the favorite box to perform the desired function on
-- the selected objects using that modifier.
--
-- To Copy Paste: Display the modifier you want to copy in the modifier panel, 
-- hit Copy. Select the objects you want to paste to, hit paste. Now the objects 
-- have copies of the original modifier.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Revision History:
--
-- v 1.01 Added 2 new modes for deleting modifiers with a specific name, and 
-- deleting uVWMapping Modifiers with a specific map channel.
--
-- v 1.02 Added a new mode for selection objects with no modifiers. Added
-- ability to place the modifier at a specific spot.
--
-- v 1.03 Fixed a Defaults Loading bug.
--
-- v 1.04 Replaced the Close button with a Help button. Use the X button to 
-- Close the Floater.
--
-- v 1.05 Added ability to turn on or off or toggle modifiers.
--
-- v 1.06 Added a new mode for selecting objects with uVWMapping Modifiers with 
-- a specific map channel.
--
-- v 1.07 Changed the default modifiers. You can get the old set back by making 
-- your own custom set of default modifiers.
--
-- v 1.08 Added a new mode, "Select Objects with Material Modifier By ID"
--
-- v 1.09 Fixed a bug I introduced with the last update, now favorites should 
-- be working again.
--
-- v 1.10 Added Select with Mod by Name Mode.
--
-- v 1.11 Added Option to unignore instanced objects. Useful if you want to add
-- modifiers to a set of references. See "Known Issues" note.
--
-- v 1.12 Added ability to turn on or off or toggle modifiers based on Name.
--
-- v 1.13 Added ability to copy a modifier from 1 object and paste it to a 
-- selection of objects.
--
-- v 1.14 Added ability to select objects that have a missing modifier 
-- (ie, Missing_OSM)
--
-- v 1.15 Adjusted preset modifiers a bit. Added "Collapse To Modifier By Type"
-- and "Collapse To Modifier By Name"
--
-- v 1.16 Added ability to remove just space warp modifiers.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Known Issues:
-- The script can't tell the difference between an instance or a reference of 
-- an object. So say you have a sphere, and 2 references of the sphere. And you
-- want to add a seperate Bend modifier to each. If you add a bend modifier to 
-- the first sphere, then all the spheres get the bend modifier (since they 
-- are references). Then the script ignores the other two spheres, because as far
-- as it knows, they are instances of the first object, and so don't need another
-- bend modifier. To get around this issue, uncheck the "Ignore Instances" 
-- checkbox under Options. This will add a bend modifier to each object, however,
-- make sure you only have references selected and no instances of your object,
-- otherwise you may get more bend modifiers than you intended.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
(
-- Globals

global modifierUtilities
global modifierUtilitiesDefaults
global modifierUtilitiesUI

global mUCloseOpenUI

global mUCopy
global mUPasteCopy
global mUPasteInstance

global mUDo
global mUApply
global mUHelp
global mULoadDef
global mUSaveDef

global mUDefineUI
global mURollout
global mUCopyPasteRollout
global mUFloater

-- Includes

include "$scripts\SoulburnScripts\lib\sLib.ms"

-- Variables

global mUModifierNameList = #()
global mUModifierFavNameList = #()
global mCOPTheModifier

mUModeValue = 1
mUModifierValue = ""
mUModNameValue = ""
mUMapChannelValue = 1
mUMatIDValue = 1
mUAddWhereValue = 1
mUAddWhereSpecificValue = 1
mUIgnoreInstValue = true
mUFavoritesValue = "Bend~Extrude~FFD_2x2x2~Materialmodifier~Noisemodifier~OpenSubdiv~Shell~smooth~TurboSmooth~Uvwmap"
mUPosValue = [400,400]

-- Functions

fn modifierUtilities mUMode mUModifier mUModName mUMapChannel mUMatID mUAddWhere mUAddWhereSpecific mUIgnoreInst = 
	(
	modNumberKilled = 0
	undo "modifierUtilities" on
		(
		if (findItem mUModifierNameList mUModifier) != 0 then
			(
			disableSceneRedraw()
			try
				(
				if mUMode == 1 then 
					(
					if mUIgnoreInst == true then a = sLibRemoveUnneededInstancesFromArray selection
					else a = selection
					)
				else a = selection
				
				-- Add Modifier
				if mUMode == 1 then
					(
					for obj in a do
						(
						theMod = (execute (mUModifier + "()"))
						if validModifier obj theMod then 
							(
							if mUAddWhere == 1 then	
								(
								addmodifier obj theMod
								)
							else if mUAddWhere == 2 then
								(
								numMods = obj.modifiers.count
								addmodifier obj theMod before:numMods
								)
							else 
								(
								WherePut = (mUAddWhereSpecific - 1)
								if WherePut > obj.modifiers.count then WherePut = obj.modifiers.count
								addmodifier obj theMod before:WherePut
								)
							)
						)
					)
					
				-- Remove Modifier
				else if mUMode == 2 then
					(
					for i in a do
						(
						theMod = (execute mUModifier)
						modsToKill = #()
						if i.modifiers.count != 0 then
							(
							for j = 1 to i.modifiers.count do
								(
								if classof i.modifiers[j] == theMod then append modsToKill j 
								)
							)
						if modsToKill.count != 0 then
							(
							modsToKill = (sLibSortDecending modsToKill)
							for k = 1 to modsToKill.count do
								(
								deleteModifier i i.modifiers[modsToKill[k]]
								)
							modNumberKilled += modsToKill.count
							)
						)
					print ("Number Of Modifiers Removed: " + (modNumberKilled as string))
					)

				-- Remove Modifier By Name
				else if mUMode == 3 then
					(
					modNumberKilled = sLibRemoveModifiersByName a mUModName
					print ("Number Of Modifiers Removed: " + (modNumberKilled as string))
					)

				-- Remove UVWMapping Modifier By Channel
				else if mUMode == 4 then
					(
					for i in a do
						(
						modsToKill = #()
						if i.modifiers.count != 0 then
							(
							for j = 1 to i.modifiers.count do
								(
								if classof i.modifiers[j] == Uvwmap then 
									(
									if i.modifiers[j].mapChannel == mUMapChannel then append modsToKill j
									)
								)
							)
						if modsToKill.count != 0 then
							(
							modsToKill = (sLibSortDecending modsToKill)
							for k = 1 to modsToKill.count do
								(
								deleteModifier i i.modifiers[modsToKill[k]]
								)
							modNumberKilled += modsToKill.count
							)
						)
					print ("Number Of Modifiers Removed: " + (modNumberKilled as string))
					)
					
				-- Remove All Modifiers
				else if mUMode == 5 then
					(
					for i in a do
						(
						modNumber = i.modifiers.count
						if modNumber != 0 then 
							(
							for j = modNumber to 1 by -1 do
								(
								deleteModifier i i.modifiers[j]
								)
							modNumberKilled += modNumber
							)
						)
					print ("Number Of Modifiers Removed: " + (modNumberKilled as string))
					)
					
				-- Select with Mod
				else if mUMode == 6 then
					(
					objsWithMods = #()
					for i in a do
						(
						theMod = (execute mUModifier)
						if i.modifiers.count != 0 then
							(
							for j = 1 to i.modifiers.count do
								(
								if classof i.modifiers[j] == theMod then append objsWithMods i 
								)
							)
						)
					if objsWithMods.count != 0 then select objsWithMods else max select none
					)
					
				-- Print with Mod
				else if mUMode == 7 then
					(
					objsWithMods = #()
					for i in a do
						(
						theMod = (execute mUModifier)
						if i.modifiers.count != 0 then
							(
							for j = 1 to i.modifiers.count do
								(
								if classof i.modifiers[j] == theMod then 
									(
									if findItem objsWithMods i == 0 then append objsWithMods i 
									)
								)
							)
						)
					mainText = ""
					qsort objsWithMods sLibNameCompareCaseInsensitive
					print ("Objects That Contain the " + mUModifier + " Modifier : ")
					if objsWithMods.count != 0 then
						(
						for i = 1 to objsWithMods.count do
							(
							mainText += objsWithMods[i].name as string
							if i != objsWithMods.count then mainText += ", "
							)
						)
					print mainText
					)
					
				-- List with Mod
				else if mUMode == 8 then
					(
					objsWithMods = #()
					for i in a do
						(
						theMod = (execute mUModifier)
						if i.modifiers.count != 0 then
							(
							for j = 1 to i.modifiers.count do
								(
								if classof i.modifiers[j] == theMod then 
									(
									if findItem objsWithMods i == 0 then append objsWithMods i 
									)
								)
							)
						)
					mainText = ""
					qsort objsWithMods sLibNameCompareCaseInsensitive
					if objsWithMods.count != 0 then
						(
						for i = 1 to objsWithMods.count do
							(
							mainText += objsWithMods[i].name as string
							if i != objsWithMods.count then mainText += ", "
							)
						)
					mainTitle = "Objects That Contain the " + mUModifier + " Modifier : "
					MessageBox mainText title:mainTitle
					)
					
				-- Isolate with Mod
				else if mUMode == 9 then
					(
					objsWithMods = #()
					for i in a do
						(
						theMod = (execute mUModifier)
						if i.modifiers.count != 0 then
							(
							for j = 1 to i.modifiers.count do
								(
								if classof i.modifiers[j] == theMod then append objsWithMods i 
								)
							)
						)
					if objsWithMods.count != 0 then 
						(
						for i in objsWithMods do i.isHidden = false
						select objsWithMods
						max hide inv
						)
					)
				-- Select Objects With No Modifiers
				else if mUMode == 10 then
					(
					objsWithoutMods = #()
					for i in a do
						(
						if i.modifiers.count == 0 then append objsWithoutMods i
						)
					if objsWithoutMods.count != 0 then select objsWithoutMods else max select none
					)

				-- Select Objects with UVWMapping Modifier By Channel
				else if mUMode == 11 then
					(
					objs = #()
					for i in a do
						(
						if i.modifiers.count != 0 then
							(
							for j = 1 to i.modifiers.count do
								(
								if classof i.modifiers[j] == Uvwmap then 
									(
									if i.modifiers[j].mapChannel == mUMapChannel then append objs i
									)
								)
							)
						)
					if objs.count != 0 then select objs else max select none
					)
					
				-- Turn On Modifier By Type
				else if mUMode == 12 then
					(
					for i in a do
						(
						theMod = (execute mUModifier)
						if i.modifiers.count != 0 then
							(
							for j = 1 to i.modifiers.count do
								(
								if classof i.modifiers[j] == theMod then i.modifiers[j].enabled = true
								)
							)
						)
					)

				-- Turn Off Modifier By Type
				else if mUMode == 13 then
					(
					for i in a do
						(
						theMod = (execute mUModifier)
						if i.modifiers.count != 0 then
							(
							for j = 1 to i.modifiers.count do
								(
								if classof i.modifiers[j] == theMod then i.modifiers[j].enabled = false
								)
							)
						)
					)
					
				-- Toggle Modifier On or Off By Type
				else if mUMode == 14 then
					(
					for i in a do
						(
						theMod = (execute mUModifier)
						if i.modifiers.count != 0 then
							(
							for j = 1 to i.modifiers.count do
								(
								if classof i.modifiers[j] == theMod then
									(
									if i.modifiers[j].enabled == true then i.modifiers[j].enabled = false
									else i.modifiers[j].enabled = true
									)
								)
							)
						)
					)
				-- Turn On Modifier By Name
				else if mUMode == 15 then
					(
					for i in a do
						(
						if i.modifiers.count != 0 then
							(
							for j = 1 to i.modifiers.count do
								(
								if i.modifiers[j].name == mUModName then i.modifiers[j].enabled = true
								)
							)
						)
					)

				-- Turn Off Modifier By Name
				else if mUMode == 16 then
					(
					for i in a do
						(
						if i.modifiers.count != 0 then
							(
							for j = 1 to i.modifiers.count do
								(
								if i.modifiers[j].name == mUModName then i.modifiers[j].enabled = false
								)
							)
						)
					)
					
				-- Toggle Modifier On or Off By Name
				else if mUMode == 17 then
					(
					for i in a do
						(
						if i.modifiers.count != 0 then
							(
							for j = 1 to i.modifiers.count do
								(
								if i.modifiers[j].name == mUModName then
									(
									if i.modifiers[j].enabled == true then i.modifiers[j].enabled = false
									else i.modifiers[j].enabled = true
									)
								)
							)
						)
					)
				-- Select Objects with Material Modifier By ID
				else if mUMode == 18 then
					(
					objs = #()
					for i in a do
						(
						if i.modifiers.count != 0 then
							(
							for j = 1 to i.modifiers.count do
								(
								if classof i.modifiers[j] == Materialmodifier then 
									(
									if i.modifiers[j].materialID == mUMatID then append objs i
									)
								)
							)
						)
					if objs.count != 0 then select objs else max select none
					)
					
				-- Select with Mod by Name
				else if mUMode == 19 then
					(
					objsWithMods = #()
					for i in a do
						(
						theMod = (execute mUModifier)
						if i.modifiers.count != 0 then
							(
							for j = 1 to i.modifiers.count do
								(
								if i.modifiers[j].name == mUModName then append objsWithMods i 
								)
							)
						)
					if objsWithMods.count != 0 then select objsWithMods else max select none
					)
				-- Select Objects With Missing Modifiers
				else if mUMode == 20 then
					(
					objsWithMods = #()
					for i in a do
						(
						if i.modifiers.count != 0 then
							(
							for j = 1 to i.modifiers.count do
								(
								if (classof i.modifiers[j]) == Missing_OSM then append objsWithMods i 
								)
							)
						)
					if objsWithMods.count != 0 then select objsWithMods else max select none
					)
				-- Collapse To Modifier By Type
				else if mUMode == 21 then
					(
					for i in a do
						(
						theMod = (execute mUModifier)
						if i.modifiers.count != 0 then
							(
							for j = 1 to i.modifiers.count do
								(
								if classof i.modifiers[j] == theMod then 
									(
									maxOps.CollapseNodeTo i j true
									)
								)
							)
						)
					)
				-- Collapse To Modifier By Name
				else if mUMode == 22 then
					(
					for i in a do
						(
						if i.modifiers.count != 0 then
							(
							for j = 1 to i.modifiers.count do
								(
								if i.modifiers[j].name == mUModName then 
									(
									maxOps.CollapseNodeTo i j true
									)
								)
							)
						)
					)
				-- Remove Spacewarp Modifiers
				else if mUMode == 23 then
					(
					for i in a do
						(
						modsToKill = #()
						if i.modifiers.count != 0 then
							(
							for j = 1 to i.modifiers.count do
								(
								if superclassof i.modifiers[j] == SpacewarpModifier then append modsToKill j 
								)
							)
						if modsToKill.count != 0 then
							(
							modsToKill = (sLibSortDecending modsToKill)
							for k = 1 to modsToKill.count do
								(
								deleteModifier i i.modifiers[modsToKill[k]]
								)
							modNumberKilled += modsToKill.count
							)
						)
					print ("Number Of Modifiers Removed: " + (modNumberKilled as string))
					)
				)
			catch ()
			enableSceneRedraw()
			completeRedraw()
			)
		else (MessageBox "The modifier you're trying to use does not seem to exist." title:"modifierUtilities")
		)
	)

fn modifierUtilitiesDefaults = 
	(
	mULoadDef()
	modifierUtilities mUModeValue mUModifierValue mUModNameValue mUMapChannelValue mUMatIDValue mUAddWhereValue mUAddWhereSpecificValue mUIgnoreInstValue
	)
	
fn modifierUtilitiesUI = 
	(
	mULoadDef()
	mUCloseOpenUI mUPosValue
	)

fn mUCloseOpenUI pos = 
	(
	if mUFloater != undefined then CloseRolloutFloater mUFloater
	mUDefineUI()
	mUFloater = newRolloutFloater "modifierUtilities v1.16" 196 489 pos.x pos.y
	addRollout mURollout mUFloater
	addRollout mUCopyPasteRollout mUFloater rolledUp:true
	)
	
fn mUCopy = 
	(
	mCOPTheModifier = modPanel.getCurrentObject ()
	if mCOPTheModifier == undefined then (MessageBox "Please have a modifier visible in the modify panel to copy." title:"modifierUtilities")
	)
	
fn mUPasteCopy = 
	(
	if mCOPTheModifier != undefined then
		(
		theModClass = classof mCOPTheModifier
		objs = for i in selection collect i
		for o in objs do
			(
			if validModifier o theModClass then addmodifier o (copy mCOPTheModifier)
			)
		)
	else (MessageBox "You don't seem to have a modifier copied. Please retry." title:"modifierUtilities")
	)
	
fn mUPasteInstance = 
	(
	if mCOPTheModifier != undefined then
		(
		theModClass = classof mCOPTheModifier
		objs = for i in selection collect i
		for o in objs do
			(
			if validModifier o theModClass then addmodifier o mCOPTheModifier
			)
		)
	else (MessageBox "You don't seem to have a modifier copied. Please retry." title:"modifierUtilities")
	)

fn mUDo = 
	(
	modifierUtilities mUModeValue mUModifierValue mUModNameValue mUMapChannelValue mUMatIDValue mUAddWhereValue mUAddWhereSpecificValue mUIgnoreInstValue
	if mUFloater != undefined then CloseRolloutFloater mUFloater
	)

fn mUApply = 
	(
	modifierUtilities mUModeValue mUModifierValue mUModNameValue mUMapChannelValue mUMatIDValue mUAddWhereValue mUAddWhereSpecificValue mUIgnoreInstValue
	)
	
fn mUHelp = 
	(
	sLibSSPrintHelp "modifierUtilities"
	)

fn mULoadDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	mUInputFilename = presetDir + "modifierUtilities.ini"
	if (sLibFileExist mUInputFilename == true) then
		(
		mUModeValue = execute (getINISetting mUInputFilename "modifierUtilities" "mUModeValue")
		mUModifierValue = getINISetting mUInputFilename "modifierUtilities" "mUModifierValue"
		mUModNameValue = getINISetting mUInputFilename "modifierUtilities" "mUModNameValue"
		mUMapChannelValue = execute (getINISetting mUInputFilename "modifierUtilities" "mUMapChannelValue")
		mUMatIDValue = execute (getINISetting mUInputFilename "modifierUtilities" "mUMatIDValue")
		mUAddWhereValue = execute (getINISetting mUInputFilename "modifierUtilities" "mUAddWhereValue")
		mUAddWhereSpecificValue = execute (getINISetting mUInputFilename "modifierUtilities" "mUAddWhereSpecificValue")
		mUIgnoreInstValue = execute (getINISetting mUInputFilename "modifierUtilities" "mUIgnoreInstValue")
		mUFavoritesValue = getINISetting mUInputFilename "modifierUtilities" "mUFavoritesValue"
		mUPosValue = execute (getINISetting mUInputFilename "modifierUtilities" "mUPosValue")
		
		if mUModeValue == OK then mUModeValue = 1
		if mUModifierValue == OK then mUModifierValue = ""
		if mUModNameValue == OK then mUModNameValue = ""
		if mUMapChannelValue == OK then mUMapChannelValue = 1
		if mUMatIDValue == OK then mUMatIDValue = 1
		if mUAddWhereValue == OK then mUAddWhereValue = 1
		if mUAddWhereSpecificValue == OK then mUAddWhereSpecificValue = 1
		if mUIgnoreInstValue == OK then mUIgnoreInstValue = true
		if mUFavoritesValue == OK then mUFavoritesValue = "Bend~Extrude~FFD_2x2x2~Materialmodifier~Noisemodifier~OpenSubdiv~Shell~smooth~TurboSmooth~Uvwmap"
		if mUPosValue == OK then mUPosValue = [400,400]
		)
	else
		(
		mUModeValue = 1
		mUModifierValue = ""
		mUModNameValue = ""
		mUMapChannelValue = 1
		mUMatIDValue = 1
		mUAddWhereValue = 1
		mUAddWhereSpecificValue = 1
		mUIgnoreInstValue = true
		mUFavoritesValue = "Bend~Extrude~FFD_2x2x2~Materialmodifier~Noisemodifier~OpenSubdiv~Shell~smooth~TurboSmooth~Uvwmap"
		mUPosValue = [400,400]
		)
	)
	
fn mUSaveDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	if (getDirectories presetDir).count == 0 then makeDir presetDir
	mUOutputFilename = presetDir + "modifierUtilities.ini"
	if (sLibFileExist mUOutputFilename == true) then deleteFile mUOutputFilename
	setINISetting mUOutputFilename "modifierUtilities" "mUModeValue" (mUModeValue as string)
	setINISetting mUOutputFilename "modifierUtilities" "mUModifierValue" (mUModifierValue as string)
	setINISetting mUOutputFilename "modifierUtilities" "mUModNameValue" (mUModNameValue as string)
	setINISetting mUOutputFilename "modifierUtilities" "mUMapChannelValue" (mUMapChannelValue as string)
	setINISetting mUOutputFilename "modifierUtilities" "mUMatIDValue" (mUMatIDValue as string)
	setINISetting mUOutputFilename "modifierUtilities" "mUAddWhereValue" (mUAddWhereValue as string)
	setINISetting mUOutputFilename "modifierUtilities" "mUAddWhereSpecificValue" (mUAddWhereSpecificValue as string)
	setINISetting mUOutputFilename "modifierUtilities" "mUIgnoreInstValue" (mUIgnoreInstValue as string)
	setINISetting mUOutputFilename "modifierUtilities" "mUFavoritesValue" (mUFavoritesValue as string)
	setINISetting mUOutputFilename "modifierUtilities" "mUPosValue" (mUFloater.pos as string)
	)

-- UI

fn mUDefineUI = 
	(
	rollout mURollout "modifierUtilities"
		(
		group "Mode"
		(
		dropdownlist mUModeDropdown "" items:#("Add Modifier By Type", "Remove Modifier By Type", "Remove Modifier By Name", "Remove UVWMapping Modifier By Channel", "Remove All Modifiers", "Select with Modifier By Type", "Print with Modifier By Type", "List with Modifier By Type", "Isolate with Modifier By Type", "Select Objects With No Modifiers", "Select Objects with UVWMapping Modifier By Channel", "Turn On Modifier By Type", "Turn Off Modifier By Type", "Toggle Modifier On or Off By Type", "Turn On Modifier By Name", "Turn Off Modifier By Name", "Toggle Modifier On or Off By Name", "Select Objects with Material Modifier By ID", "Select with Mod by Name", "Select Objects With Missing Modifiers", "Collapse To Modifier By Type", "Collapse To Modifier By Name", "Remove All Spacewarp Modifiers") height:30 width:157 align:#left selection:mUModeValue
		)

		group "Choose Modifier"
		(
		dropdownlist mUModifierListDropdown "" items:mUModifierNameList selection:1 height:30 width:157 align:#left 
		listbox mUFavListbox "" items:mUModifierFavNameList height:10 width:130 align:#left across:3
		button mUAddFavButton "A" width:22 height:66 toolTip:"Add Modifier To Favorites" offset:[67,-1]
		button mURemoveFavButton "R" width:22 height:66 toolTip:"Remove Modifier From Favorites" offset:[15,70]
		)

		group "Options"
		(
		edittext mUModNameEditText "Modifier Name:" fieldWidth:80 text:mUModNameValue align:#right
		spinner mUMapChannelSpinner "Map Channel: " range:[1,9999999,mUMapChannelValue] type:#integer fieldWidth:35 align:#right
		spinner mUMatIDSpinner "Mat ID: " range:[1,9999999,mUMatIDValue] type:#integer fieldWidth:35 align:#right
		dropdownlist mUAddWhereDropdown "" items:#("Top Of Stack", "Bottom Of Stack", "Specific (From Top)") selection:mUAddWhereValue height:30 width:120 align:#left across:2
		spinner mUAddWhereSpecificSpinner "" range:[1,9999,mUAddWhereSpecificValue] type:#integer fieldWidth:25 align:#right offset:[0,2]
		checkbox mUIgnoreInstCheckbox "Ignore Instances?" checked:mUIgnoreInstValue align:#right
		)

		on mUModeDropdown selected i do
			(
			mUModeValue = i
			if mUModeValue == 1 then
				(
				mUModifierListDropdown.enabled = true
				mUAddFavButton.enabled = true
				mURemoveFavButton.enabled = true
				mUFavListbox.enabled = true
				mUAddWhereDropdown.enabled = true
				mUAddWhereSpecificSpinner.enabled = true
				)
			else if mUModeValue == 3 or mUModeValue == 4 or mUModeValue == 5 or mUModeValue == 10 or mUModeValue == 11 or mUModeValue == 18 or mUModeValue == 19 or mUModeValue == 22 or mUModeValue == 23 then
				(
				mUModifierListDropdown.enabled = false
				mUAddFavButton.enabled = false
				mURemoveFavButton.enabled = false
				mUFavListbox.enabled = false
				mUAddWhereDropdown.enabled = false
				mUAddWhereSpecificSpinner.enabled = false
				)
			else 
				(
				mUModifierListDropdown.enabled = true
				mUAddFavButton.enabled = true
				mURemoveFavButton.enabled = true
				mUFavListbox.enabled = true
				mUAddWhereDropdown.enabled = false
				mUAddWhereSpecificSpinner.enabled = false
				)
			if mUModeValue == 3 or mUModeValue == 15 or mUModeValue == 16 or mUModeValue == 17 or mUModeValue == 19 or mUModeValue == 22 then mUModNameEditText.enabled = true else mUModNameEditText.enabled = false
			if mUModeValue == 4 or mUModeValue == 11 then mUMapChannelSpinner.enabled = true else mUMapChannelSpinner.enabled = false
			if mUModeValue == 18 then mUMatIDSpinner.enabled = true else mUMatIDSpinner.enabled = false
			)
			
		on mUModifierListDropdown selected i do mUModifierValue = mUModifierListDropdown.selected
		on mUFavListbox doubleClicked m do
			(
			modifierUtilities mUModeValue mUFavListbox.selected mUModNameValue mUMapChannelValue mUMatIDValue mUAddWhereValue mUAddWhereSpecificValue mUIgnoreInstValue
			)
		on mUAddFavButton pressed do 
			(
			-- add to array
			if (findItem mUModifierFavNameList mUModifierListDropdown.selected) == 0 then append mUModifierFavNameList mUModifierListDropdown.selected

			-- sort array
			qsort mUModifierFavNameList sLibCompareCaseInsensitive

			-- turn array into value
			mUFavoritesValue = sLibArrayAsArrayString mUModifierFavNameList "~"

			-- open and close dialog
			curPos = mUFloater.pos
			curFav = mUFavListbox.selected
			mUCloseOpenUI curPos
			findFav = (findItem mUModifierFavNameList curFav)
			if findFav != 0 then mUFavListbox.selection = findFav else mUFavListbox.selection = 1
			)
		on mURemoveFavButton pressed do 
			(
			-- find in list
			favPos = findItem mUModifierFavNameList mUFavListbox.selected

			-- remove from array
			if favPos != 0 then deleteItem mUModifierFavNameList favPos

			-- turn array into value
			mUFavoritesValue = sLibArrayAsArrayString mUModifierFavNameList "~"

			-- open and close dialog
			curPos = mUFloater.pos
			curFav = mUFavListbox.selected
			mUCloseOpenUI curPos
			findFav = (findItem mUModifierFavNameList curFav)
			if findFav != 0 then mUFavListbox.selection = findFav else mUFavListbox.selection = 1
			)
	
		on mUModNameEditText changed text do mUModNameValue = text
		on mUMapChannelSpinner changed val do mUMapChannelValue = val
		on mUMatIDSpinner changed val do mUMatIDValue = val
		on mUAddWhereDropdown selected i do 
			(
			mUAddWhereValue = i
			if mUAddWhereValue == 3 then mUAddWhereSpecificSpinner.enabled = true else mUAddWhereSpecificSpinner.enabled = false
			)
		on mUAddWhereSpecificSpinner changed val do mUAddWhereSpecificValue = val
		on mUIgnoreInstCheckbox changed state do mUIgnoreInstValue = state

		button mUDoButton "Do" width:70 toolTip:"Do It and Close UI" pos:[20,389]
		on mUDoButton pressed do mUDo()
		button mUApplyButton "Apply" width:70 toolTip:"Do It and Keep UI Open" pos:[92,389]
		on mUApplyButton pressed do mUApply()
		button mUHelpButton "Help" width:70 toolTip:"Help" pos:[20,413]
		on mUHelpButton pressed do mUHelp()
		button mUSaveDefButton "SaveDef" width:70 toolTip:"Save Current Settings as Default" pos:[92,413]
		on mUSaveDefButton pressed do mUSaveDef()

		on mURollout open do
			(
			-- make modifier list
			mUModifierNameList = #()
			mUModifierList = for c in modifier.classes where c.creatable collect c
			for i in mUModifierList do append mUModifierNameList (i as string)
			qsort mUModifierNameList sLibCompareCaseInsensitive
			mUModifierListDropdown.items = mUModifierNameList

			-- choose correct modifier from modifier list
			curMod = findItem mUModifierNameList mUModifierValue
			if curMod != 0 then mUModifierListDropdown.selection = curMod else mUModifierValue = mUModifierListDropdown.selected

			-- make favorite list
			mUModifierFavNameList = #()
			mUModifierFavNameList = sLibArrayStringAsArray mUFavoritesValue "~"
			qsort mUModifierFavNameList sLibCompareCaseInsensitive
			mUFavListbox.items = mUModifierFavNameList

			-- disable appropriate controls
			if mUModeValue == 1 then
				(
				mUModifierListDropdown.enabled = true
				mUAddFavButton.enabled = true
				mURemoveFavButton.enabled = true
				mUFavListbox.enabled = true
				mUAddWhereDropdown.enabled = true
				mUAddWhereSpecificSpinner.enabled = true
				)
			else if mUModeValue == 3 or mUModeValue == 4 or mUModeValue == 5 or mUModeValue == 10 or mUModeValue == 11 or mUModeValue == 18 or mUModeValue == 19 or mUModeValue == 22 or mUModeValue == 23 then
				(
				mUModifierListDropdown.enabled = false
				mUAddFavButton.enabled = false
				mURemoveFavButton.enabled = false
				mUFavListbox.enabled = false
				mUAddWhereDropdown.enabled = false
				mUAddWhereSpecificSpinner.enabled = false
				)
			else 
				(
				mUModifierListDropdown.enabled = true
				mUAddFavButton.enabled = true
				mURemoveFavButton.enabled = true
				mUFavListbox.enabled = true
				mUAddWhereDropdown.enabled = false
				mUAddWhereSpecificSpinner.enabled = false
				)
			if mUModeValue == 3 or mUModeValue == 15 or mUModeValue == 16 or mUModeValue == 17 or mUModeValue == 19 or mUModeValue == 22 then mUModNameEditText.enabled = true else mUModNameEditText.enabled = false
			if mUModeValue == 4 or mUModeValue == 11 then mUMapChannelSpinner.enabled = true else mUMapChannelSpinner.enabled = false
			if mUModeValue == 18 then mUMatIDSpinner.enabled = true else mUMatIDSpinner.enabled = false
			if mUAddWhereValue == 3 then mUAddWhereSpecificSpinner.enabled = true else mUAddWhereSpecificSpinner.enabled = false
			)
		)
	rollout mUCopyPasteRollout "modifierCopier"
		(
		button mUCopyButton "Copy" width:120 toolTip:"Copy Modifier From Current Object"
		on mUCopyButton pressed do mUCopy()
		button mUPaste1Button "Paste Copy" width:120 toolTip:"Paste Modifier From Current Object as Copy"
		on mUPaste1Button pressed do mUPasteCopy()
		button mUPaste2Button "Paste Instance" width:120 toolTip:"Paste Modifier From Current Object as Instance"
		on mUPaste2Button pressed do mUPasteInstance()
		)
	)
)
-------------------------------------------------------------------------------