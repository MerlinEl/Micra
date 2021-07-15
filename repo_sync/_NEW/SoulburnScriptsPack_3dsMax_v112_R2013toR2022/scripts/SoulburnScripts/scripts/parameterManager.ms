-------------------------------------------------------------------------------
-- parameterManager.ms
-- By Neil Blevins (info@neilblevins.com)
-- v 1.10
-- Created On: 08/06/07
-- Modified On: 11/20/11
-- tested using Max 2011
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Required Files:
-- sLib.ms
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Description:
-- Allows you to change parameter values for all selected objects as a group.
-- For example, you can change the radius of a bunch of spheres together, even
-- though they're not instances of each other. Or you can change the bend value
-- for all selected objects that have a bend modifier. Thanks to Grant Adam for
-- a lot of useful code.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Tutorial:
-- Select 2 different spheres. Run the UI version of the script. Choose "Radius"
-- from the "Obj Param" list. Change the "Specific Value" to 50. Hit Do. The 
-- radii of both spheres will become a value of 50.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Revision History:
--
-- v 1.01 Added some extra code to stop the script from crashing when trying
-- to modify certain parameters. The script currently works only on any parameter
-- that is a Float, Integer or Boolean. I'll look into adding other parameter
-- types in the future.
--
-- v 1.02 Added a new mode for applying random checkbox values. Added color
-- support. Cleaned a lot of code.
--
-- v 1.03 Added support for Point3 values (such as the strength parameter for
-- the noise modifier.) Added material and map support.
--
-- v 1.04 Replaced the Close button with a Help button. Use the X button to 
-- Close the Floater.
--
-- v 1.05 Now handles the CastShadow property of lights.
--
-- v 1.06 Added a progress bar to startup, hopefully it'll build it's list a 
-- little faster, or at least you'll know it hasn't crashed. Fixed a couple of
-- crash bugs.
--
-- v 1.07 Fixed a crash bug that would crash then script when trying to autodetect
-- a list of maps. Now has a mode to modify the coordinates of maps. Redid the 
-- interface somewhat.
--
-- v 1.08 Fixed a bug where the wrong value got passed to relative mode. Thanks 
-- ZeBoxx for finding this one.
--
-- v 1.09 Fixed a bug where no checkboxes could be affected by the script.
--
-- v 1.10 Fixed a bug where the mapping coordinate mode wouldn't work.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Known Issues:
-- Doesn't current work with the parameters of Brazil 2 lights or some Brazil 
-- Material parameters.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
(
-- Globals

global parameterManager
global parameterManagerDefaults
global parameterManagerUI

global pMRefreshListObjs
global pMRefreshListMods
global pMRefreshListMats
global pMRefreshListMaps
global pMRefreshListMapCoords

global pMCloseOpenUI

global pMDo
global pMApply
global pMHelp
global pMLoadDef
global pMSaveDef

global pMDefineUI
global pMRolloutMain
global pMRolloutParam1
global pMRolloutParam2
global pMRolloutParam3
global pMRolloutParam4
global pMRolloutParam5
global pMRolloutValues
global pMRolloutTools
global pMFloater

-- Includes

include "$scripts\SoulburnScripts\lib\sLib.ms"

-- Variables

global pMObjsParamNamesList = #()
global pMModsNamesList = #()
global pMModsParamNamesList = #()
global pMMatsParamNamesList = #()
global pMMapsNamesList = #()
global pMMapsParamNamesList = #()
global pMMapCoordsNamesList = #()
global pMMapCoordsParamNamesList = #()

global pMObjsParamDropdownIndex = 1
global pMModsDropdownIndex = 1
global pMModsParamDropdownIndex = 1
global pMMatsParamDropdownIndex = 1
global pMMapsDropdownIndex = 1
global pMMapsParamDropdownIndex = 1
global pMMapCoordsDropdownIndex = 1
global pMMapCoordsParamDropdownIndex = 1

pMParameterModeValue = 1
pMModeValue = 1
pMValueTypeValue = 1
pMSpecificValueValue = 100
pMRandomLowValue = 1
pMRandomHighValue = 100
pMCheckboxValue = false
pMColorValue = [255,0,0]
pMP3XValue = 0.0
pMP3YValue = 0.0
pMP3ZValue = 0.0
pMP3RLXValue = 0.0
pMP3RLYValue = 0.0
pMP3RLZValue = 0.0
pMP3RHXValue = 1.0
pMP3RHYValue = 1.0
pMP3RHZValue = 1.0
pMAutodetectValuesValue = true
pMPosValue = [400,400]

-- Functions

fn parameterManager pMParameterMode pMMode pMValueType pMSpecificValue pMRandomLow pMRandomHigh pMCheckbox pMColor pMP3X pMP3Y pMP3Z pMP3RLX pMP3RLY pMP3RLZ pMP3RHX pMP3RHY pMP3RHZ pMObjsParam pMMods pMModsParam pMMatsParam pMMaps pMMapsParam pMMapCoords pMMapCoordsParam = 
	(
	undo "parameterManager" on
		(
		nodes = #()
		if pMParameterMode == 1 or pMParameterMode == 2 then nodes = for i in selection collect i
		else if pMParameterMode == 3 then nodes = sLibGetAllMaterialsOnSelectedObjects()
		else if pMParameterMode == 4 or pMParameterMode == 5 then nodes = sLibGetAllMapsFromSelectedObjects()

		for i in nodes do
			(
			-- Calculate the Value
			FinalValue = 0
			OldValue = 0
			if pMValueType == 1 then FinalValue = pMSpecificValue
			else if pMValueType == 2 then FinalValue = random pMRandomLow pMRandomHigh
			else if pMValueType == 3 then FinalValue = pMCheckbox
			else if pMValueType == 4 then (a = (random 0 1);if a == 0 then FinalValue = false else FinalValue = true)
			else if pMValueType == 5 then FinalValue = pMColor
			else if pMValueType == 6 then FinalValue = [(random 0 255),(random 0 255),(random 0 255)]
			else if pMValueType == 7 then FinalValue = [pMP3X,pMP3Y,pMP3Z]
			else if pMValueType == 8 then FinalValue = [(random pMP3RLX pMP3RHX),(random pMP3RLY pMP3RHY),(random pMP3RLZ pMP3RHZ)]
					
			-- Change Object Value
			if pMParameterMode == 1 then
				(
				if pMObjsParam != undefined then
					(
					try 
						(
						-- Relative mode only works on Floats, Integers and Point3s
						OldValue = getProperty i.baseobject pMObjsParam
						if (classof OldValue) == Float or (classof OldValue) == Integer or (classof OldValue) == Point3 then
							(
							if pMMode == 2 then setProperty i.baseobject pMObjsParam (FinalValue + OldValue)
							else setProperty i.baseobject pMObjsParam FinalValue
							)
						else if (classof OldValue) == Color or (classof OldValue) == BooleanClass then
							(
							setProperty i.baseobject pMObjsParam FinalValue
							)
						)
					catch ()
					)
				)
			-- Change Modifier Value
			else if pMParameterMode == 2 then
				(
				if pMMods != undefined and pMModsParam != undefined then
					(
					for j in i.modifiers do
						(
						try
							(
							if j.name == pMMods then 
								(
								OldValue = getProperty j pMModsParam
								-- Relative mode only works on Floats, Integers and Point3s
								if (classof OldValue) == Float or (classof OldValue) == Integer or (classof OldValue) == Point3 then
									(
									if pMMode == 2 then setProperty j pMModsParam (FinalValue + OldValue)
									else setProperty j pMModsParam FinalValue
									)
								else if (classof OldValue) == Color or (classof OldValue) == BooleanClass then
									(
									setProperty j pMModsParam FinalValue
									)
								)
							)
						catch ()					
						)
					)
				)
			-- Change Material Value
			else if pMParameterMode == 3 then
				(
				if pMMatsParam != undefined then
					(
					try 
						(
						OldValue = getProperty i pMMatsParam
						-- Relative mode only works on Floats, Integers and Point3s
						if (classof OldValue) == Float or (classof OldValue) == Integer or (classof OldValue) == Point3 then
							(
							if pMMode == 2 then setProperty i pMMatsParam (FinalValue + OldValue)
							else setProperty i pMMatsParam FinalValue
							)
						else if (classof OldValue) == Color or (classof OldValue) == BooleanClass then
							(
							setProperty i pMMatsParam FinalValue
							)
						)
					catch ()
					)
				)
			-- Change Map Value
			else if pMParameterMode == 4 then
				(
				if pMMaps != undefined and pMMapsParam != undefined then
					(
					try
						(
						if (classof i) == (execute pMMaps) then 
							(
							OldValue = getProperty i pMMapsParam
							-- Relative mode only works on Floats, Integers and Point3s
							if (classof OldValue) == Float or (classof OldValue) == Integer or (classof OldValue) == Point3 then
								(
								if pMMode == 2 then setProperty i pMMapsParam (FinalValue + OldValue)
								else setProperty i pMMapsParam FinalValue
								)
							else if (classof OldValue) == Color or (classof OldValue) == BooleanClass then
								(
								setProperty i pMMapsParam FinalValue
								)
							)
						)
					catch ()					
					)
				)
			-- Change MapCoords Value
			else if pMParameterMode == 5 then
				(
				if pMMapCoords != undefined and pMMapCoordsParam != undefined then
					(
					try
						(
						if (classof i) == (execute pMMapCoords) then 
							(
							OldValue = getProperty i.coordinates pMMapCoordsParam
							-- Relative mode only works on Floats, Integers and Point3s
							if (classof OldValue) == Float or (classof OldValue) == Integer or (classof OldValue) == Point3 then
								(
								if pMMode == 2 then setProperty i.coordinates pMMapCoordsParam (FinalValue + OldValue)
								else setProperty i.coordinates pMMapCoordsParam FinalValue
								)
							else if (classof OldValue) == Color or (classof OldValue) == BooleanClass then
								(
								setProperty i.coordinates pMMapCoordsParam FinalValue
								)
							)
						)
					catch ()					
					)
				)
			)
		)
	)
	
fn parameterManagerDefaults = 
	(
	pMLoadDef()
	parameterManager pMParameterModeValue pMModeValue pMValueTypeValue pMSpecificValueValue pMRandomLowValue pMRandomHighValue pMCheckboxValue pMColorValue pMP3XValue pMP3YValue pMP3ZValue pMP3RLXValue pMP3RLYValue pMP3RLZValue pMP3RHXValue pMP3RHYValue pMP3RHZValue pMObjsParamNamesList[pMObjsParamDropdownIndex] pMModsNamesList[pMModsDropdownIndex] (pMModsParamNamesList[pMModsDropdownIndex])[pMModsParamDropdownIndex] pMMatsParamNamesList[pMMatsParamDropdownIndex] pMMapsNamesList[pMMapsDropdownIndex] (pMMapsParamNamesList[pMMapsDropdownIndex])[pMMapsParamDropdownIndex] pMMapCoordsNamesList[pMMapCoordsDropdownIndex] (pMMapCoordsParamNamesList[pMMapCoordsDropdownIndex])[pMMapCoordsParamDropdownIndex]
	)

fn parameterManagerUI = 
	(
	pMLoadDef()
	pMCloseOpenUI pMPosValue
	)

fn pMRefreshListObjs =
	(
	-- Prep Progressbar
	progressStart "Updating Object Parameter List"
	escapeEnable = false
	numOfItems = selection.count
	currentIteration = 0
	
	-- Object Parameter List
	for i in selection do
		(
		if getProgressCancel() == true then exit
		currentIteration += 1
		m = ((currentIteration as float)/(numOfItems as float))*100
		pMPropList = (getpropnames i)
		for j in pMPropList do
			(
			if finditem pMObjsParamNamesList (j as string) == 0 then 
				(
				prop = (classof (getProperty i j))
				if prop == Float or prop == Integer or prop == BooleanClass or prop == color or prop == Point3 then
					(
					append pMObjsParamNamesList (j as string)
					)
				)
			)
		qsort pMObjsParamNamesList sLibCompareCaseInsensitive
		progressUpdate m
		)
	progressEnd()
	)

fn pMRefreshListMods = 
	(
	-- Prep Progressbar
	progressStart "Updating Modifier List"
	escapeEnable = false
	numOfItems = selection.count
	currentIteration = 0
	
	-- Modifier List
	for i in selection do
		(
		if getProgressCancel() == true then exit
		currentIteration += 1
		m = ((currentIteration as float)/(numOfItems as float))*100
		for j = 1 to i.modifiers.count do
			(
			if finditem pMModsNamesList (i.modifiers[j].name) == 0 then
				(
				ModProps = #()
				ModPropsArray = #()
				append pMModsNamesList i.modifiers[j].name
				ModProps = (getpropnames i.modifiers[j])
				for w in ModProps do
					(
					prop = (classof (getProperty i.modifiers[j] w))
					if prop == Float or prop == Integer or prop == BooleanClass or prop == color or prop == Point3 then
						(
						append ModPropsArray (w as string)
						)
					)
				qsort ModPropsArray sLibCompareCaseInsensitive
				append pMModsParamNamesList ModPropsArray
				)
			)
		progressUpdate m
		)
	progressEnd()
	)

fn pMRefreshListMats =
	(
	-- Prep Progressbar
	matlist = sLibGetAllMaterialsOnSelectedObjects()
	progressStart "Updating Material List"
	escapeEnable = false
	numOfItems = matlist.count
	currentIteration = 0
		
	-- Material List
	for i in matlist do
		(
		if getProgressCancel() == true then exit
		currentIteration += 1
		m = ((currentIteration as float)/(numOfItems as float))*100
		pMPropList = (getpropnames i)
		for j in pMPropList do
			(
			if finditem pMMatsParamNamesList (j as string) == 0 then 
				(
				prop = (classof (getProperty i j))
				if prop == Float or prop == Integer or prop == BooleanClass or prop == color or prop == Point3 then
					(
					append pMMatsParamNamesList (j as string)
					)
				)
			)
		qsort pMMatsParamNamesList sLibCompareCaseInsensitive
		progressUpdate m
		)
	progressEnd()
	)

fn pMRefreshListMaps = 
	(
	-- Prep Progressbar
	maplist = sLibGetAllMapsFromSelectedObjects()
	progressStart "Updating Map List"
	escapeEnable = false
	numOfItems = maplist.count
	currentIteration = 0
		
	-- Map List
	for i in maplist do
		(
		if getProgressCancel() == true then exit
		currentIteration += 1
		m = ((currentIteration as float)/(numOfItems as float))*100
		if finditem pMMapsNamesList ((classof i) as string) == 0 then
			(
			MapsProps = #()
			MapsPropsArray = #()
			append pMMapsNamesList ((classof i) as string)
			MapsProps = (getpropnames i)
			for w in MapsProps do
				(
				prop = (classof (getProperty i w))
				if prop == Float or prop == Integer or prop == BooleanClass or prop == color or prop == Point3 then
					(
					append MapsPropsArray (w as string)
					)
				)
			qsort MapsPropsArray sLibCompareCaseInsensitive
			append pMMapsParamNamesList MapsPropsArray
			)
		progressUpdate m
		)
	progressEnd()
	)

fn pMRefreshListMapCoords = 
	(
	-- Prep Progressbar
	maplist = sLibGetAllMapsFromSelectedObjects()
	progressStart "Updating Map List"
	escapeEnable = false
	numOfItems = maplist.count
	currentIteration = 0
		
	-- Map List
	for i in maplist do
		(
		if getProgressCancel() == true then exit
		currentIteration += 1
		m = ((currentIteration as float)/(numOfItems as float))*100
		if finditem pMMapCoordsNamesList ((classof i) as string) == 0 then
			(
			MapCoordsProps = #()
			MapCoordsPropsArray = #()
			append pMMapCoordsNamesList ((classof i) as string)
			MapCoordsProps = (getpropnames i.coordinates)
			for w in MapCoordsProps do
				(
				prop = (classof (getProperty i.coordinates w))
				if prop == Float or prop == Integer or prop == BooleanClass or prop == color or prop == Point3 then
					(
					append MapCoordsPropsArray (w as string)
					)
				)
			qsort MapCoordsPropsArray sLibCompareCaseInsensitive
			append pMMapCoordsParamNamesList MapCoordsPropsArray
			)
		progressUpdate m
		)
	progressEnd()
	)

fn pMCloseOpenUI pos = 
	(
	if pMFloater != undefined then CloseRolloutFloater pMFloater
	pMDefineUI()
	
	-- define floater length
	local floaterLength = 451
	if pMParameterModeValue == 1 then floaterLength += 59
	else if pMParameterModeValue == 2 then floaterLength += 86
	else if pMParameterModeValue == 3 then floaterLength += 59
	else if pMParameterModeValue == 4 then floaterLength += 86
	else if pMParameterModeValue == 5 then floaterLength += 86

	-- create floater	
	pMFloater = newRolloutFloater "parameterManager v1.10" 240 floaterLength pos.x pos.y

	-- add rollouts
	addRollout pMRolloutMain pMFloater
	if pMParameterModeValue == 1 then addRollout pMRolloutParam1 pMFloater
	else if pMParameterModeValue == 2 then addRollout pMRolloutParam2 pMFloater
	else if pMParameterModeValue == 3 then addRollout pMRolloutParam3 pMFloater
	else if pMParameterModeValue == 4 then addRollout pMRolloutParam4 pMFloater
	else if pMParameterModeValue == 5 then addRollout pMRolloutParam5 pMFloater
	addRollout pMRolloutValues pMFloater
	addRollout pMRolloutTools pMFloater
	)

fn pMDo = 
	(
	if (pMModsParamNamesList[pMModsDropdownIndex]) == undefined then currentModsParam = undefined else currentModsParam = (pMModsParamNamesList[pMModsDropdownIndex])[pMModsParamDropdownIndex]
	if (pMMapsParamNamesList[pMMapsDropdownIndex]) == undefined then currentMapsParam = undefined else currentMapsParam = (pMMapsParamNamesList[pMMapsDropdownIndex])[pMMapsParamDropdownIndex]
	if (pMMapCoordsParamNamesList[pMMapCoordsDropdownIndex]) == undefined then currentMapCoordsParam = undefined else currentMapCoordsParam = (pMMapCoordsParamNamesList[pMMapCoordsDropdownIndex])[pMMapCoordsParamDropdownIndex]
	parameterManager pMParameterModeValue pMModeValue pMValueTypeValue pMSpecificValueValue pMRandomLowValue pMRandomHighValue pMCheckboxValue pMColorValue pMP3XValue pMP3YValue pMP3ZValue pMP3RLXValue pMP3RLYValue pMP3RLZValue pMP3RHXValue pMP3RHYValue pMP3RHZValue pMObjsParamNamesList[pMObjsParamDropdownIndex] pMModsNamesList[pMModsDropdownIndex] currentModsParam pMMatsParamNamesList[pMMatsParamDropdownIndex] pMMapsNamesList[pMMapsDropdownIndex] currentMapsParam pMMapCoordsNamesList[pMMapCoordsDropdownIndex] currentMapCoordsParam
	if pMFloater != undefined then CloseRolloutFloater pMFloater
	)

fn pMApply = 
	(
	if (pMModsParamNamesList[pMModsDropdownIndex]) == undefined then currentModsParam = undefined else currentModsParam = (pMModsParamNamesList[pMModsDropdownIndex])[pMModsParamDropdownIndex]
	if (pMMapsParamNamesList[pMMapsDropdownIndex]) == undefined then currentMapsParam = undefined else currentMapsParam = (pMMapsParamNamesList[pMMapsDropdownIndex])[pMMapsParamDropdownIndex]
	if (pMMapCoordsParamNamesList[pMMapCoordsDropdownIndex]) == undefined then currentMapCoordsParam = undefined else currentMapCoordsParam = (pMMapCoordsParamNamesList[pMMapCoordsDropdownIndex])[pMMapCoordsParamDropdownIndex]
	parameterManager pMParameterModeValue pMModeValue pMValueTypeValue pMSpecificValueValue pMRandomLowValue pMRandomHighValue pMCheckboxValue pMColorValue pMP3XValue pMP3YValue pMP3ZValue pMP3RLXValue pMP3RLYValue pMP3RLZValue pMP3RHXValue pMP3RHYValue pMP3RHZValue pMObjsParamNamesList[pMObjsParamDropdownIndex] pMModsNamesList[pMModsDropdownIndex] currentModsParam pMMatsParamNamesList[pMMatsParamDropdownIndex] pMMapsNamesList[pMMapsDropdownIndex] currentMapsParam pMMapCoordsNamesList[pMMapCoordsDropdownIndex] currentMapCoordsParam
	)
	
fn pMHelp = 
	(
	sLibSSPrintHelp "parameterManager"
	)
	
fn pMLoadDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	pMInputFilename = presetDir + "parameterManager.ini"
	if (sLibFileExist pMInputFilename == true) then
		(
		pMParameterModeValue = execute (getINISetting pMInputFilename "parameterManager" "pMParameterModeValue")
		pMModeValue = execute (getINISetting pMInputFilename "parameterManager" "pMModeValue")
		pMValueTypeValue = execute (getINISetting pMInputFilename "parameterManager" "pMValueTypeValue")
		pMSpecificValueValue = execute (getINISetting pMInputFilename "parameterManager" "pMSpecificValueValue")
		pMRandomLowValue = execute (getINISetting pMInputFilename "parameterManager" "pMRandomLowValue")
		pMRandomHighValue = execute (getINISetting pMInputFilename "parameterManager" "pMRandomHighValue")
		pMCheckboxValue = execute (getINISetting pMInputFilename "parameterManager" "pMCheckboxValue")
		pMColorValue = execute (getINISetting pMInputFilename "parameterManager" "pMColorValue")
		pMP3XValue = execute (getINISetting pMInputFilename "parameterManager" "pMP3XValue")
		pMP3YValue = execute (getINISetting pMInputFilename "parameterManager" "pMP3YValue")
		pMP3ZValue = execute (getINISetting pMInputFilename "parameterManager" "pMP3ZValue")
		pMP3RLXValue = execute (getINISetting pMInputFilename "parameterManager" "pMP3RLXValue")
		pMP3RLYValue = execute (getINISetting pMInputFilename "parameterManager" "pMP3RLYValue")
		pMP3RLZValue = execute (getINISetting pMInputFilename "parameterManager" "pMP3RLZValue")
		pMP3RHXValue = execute (getINISetting pMInputFilename "parameterManager" "pMP3RHXValue")
		pMP3RHYValue = execute (getINISetting pMInputFilename "parameterManager" "pMP3RHYValue")
		pMP3RHZValue = execute (getINISetting pMInputFilename "parameterManager" "pMP3RHZValue")
		pMAutodetectValuesValue = execute (getINISetting pMInputFilename "parameterManager" "pMAutodetectValuesValue")
		pMPosValue = execute (getINISetting pMInputFilename "parameterManager" "pMPosValue")
		
		if pMParameterModeValue == OK then pMParameterModeValue = 1
		if pMModeValue == OK then pMModeValue = 1
		if pMValueTypeValue == OK then pMValueTypeValue = 1
		if pMSpecificValueValue == OK then pMSpecificValueValue = 100
		if pMRandomLowValue == OK then pMRandomLowValue = 1
		if pMRandomHighValue == OK then pMRandomHighValue = 100
		if pMCheckboxValue == OK then pMCheckboxValue = false
		if pMColorValue == OK then pMColorValue = [255,0,0]
		if pMP3XValue == OK then pMP3XValue = 0.0
		if pMP3YValue == OK then pMP3YValue = 0.0
		if pMP3ZValue == OK then pMP3ZValue = 0.0
		if pMP3RLXValue == OK then pMP3RLXValue = 0.0
		if pMP3RLYValue == OK then pMP3RLYValue = 0.0
		if pMP3RLZValue == OK then pMP3RLZValue = 0.0
		if pMP3RHXValue == OK then pMP3RHXValue = 1.0
		if pMP3RHYValue == OK then pMP3RHYValue = 1.0
		if pMP3RHZValue == OK then pMP3RHZValue = 1.0
		if pMAutodetectValuesValue == OK then pMAutodetectValuesValue = true
		if pMPosValue == OK then pMPosValue = [400,400]
		)
	else
		(
		pMParameterModeValue = 1
		pMModeValue = 1
		pMValueTypeValue = 1
		pMSpecificValueValue = 100
		pMRandomLowValue = 1
		pMRandomHighValue = 100
		pMCheckboxValue = false
		pMColorValue = [255,0,0]
		pMP3XValue = 0.0
		pMP3YValue = 0.0
		pMP3ZValue = 0.0
		pMP3RLXValue = 0.0
		pMP3RLYValue = 0.0
		pMP3RLZValue = 0.0
		pMP3RHXValue = 1.0
		pMP3RHYValue = 1.0
		pMP3RHZValue = 1.0
		pMAutodetectValuesValue = true
		pMPosValue = [400,400]
		)
	)
	
fn pMSaveDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	if (getDirectories presetDir).count == 0 then makeDir presetDir
	pMOutputFilename = presetDir + "parameterManager.ini"
	if (sLibFileExist pMOutputFilename == true) then deleteFile pMOutputFilename
	setINISetting pMOutputFilename "parameterManager" "pMParameterModeValue" (pMParameterModeValue as string)
	setINISetting pMOutputFilename "parameterManager" "pMModeValue" (pMModeValue as string)
	setINISetting pMOutputFilename "parameterManager" "pMValueTypeValue" (pMValueTypeValue as string)
	setINISetting pMOutputFilename "parameterManager" "pMSpecificValueValue" (pMSpecificValueValue as string)
	setINISetting pMOutputFilename "parameterManager" "pMRandomLowValue" (pMRandomLowValue as string)
	setINISetting pMOutputFilename "parameterManager" "pMRandomHighValue" (pMRandomHighValue as string)
	setINISetting pMOutputFilename "parameterManager" "pMCheckboxValue" (pMCheckboxValue as string)
	setINISetting pMOutputFilename "parameterManager" "pMColorValue" (pMColorValue as string)
	setINISetting pMOutputFilename "parameterManager" "pMP3XValue" (pMP3XValue as string)
	setINISetting pMOutputFilename "parameterManager" "pMP3YValue" (pMP3YValue as string)
	setINISetting pMOutputFilename "parameterManager" "pMP3ZValue" (pMP3ZValue as string)
	setINISetting pMOutputFilename "parameterManager" "pMP3RLXValue" (pMP3RLXValue as string)
	setINISetting pMOutputFilename "parameterManager" "pMP3RLYValue" (pMP3RLYValue as string)
	setINISetting pMOutputFilename "parameterManager" "pMP3RLZValue" (pMP3RLZValue as string)
	setINISetting pMOutputFilename "parameterManager" "pMP3RHXValue" (pMP3RHXValue as string)
	setINISetting pMOutputFilename "parameterManager" "pMP3RHYValue" (pMP3RHYValue as string)
	setINISetting pMOutputFilename "parameterManager" "pMP3RHZValue" (pMP3RHZValue as string)
	setINISetting pMOutputFilename "parameterManager" "pMAutodetectValuesValue" (pMAutodetectValuesValue as string)
	setINISetting pMOutputFilename "parameterManager" "pMPosValue" (pMFloater.pos as string)
	)

-- UI

fn pMDefineUI = 
	(
	rollout pMRolloutMain "parameterManagerMain"
		(
		label label1 "Parameter: " across:2 offset:[-20,3]
		dropdownlist pMParameterModeDropdown "" items:#("Object", "Modifier", "Materials On Sel Objects", "Maps In Sel Objects", "MapCoords In Sel Objects") selection:pMParameterModeValue width:145 offset:[-40,0]
		label label2 "Mode: " across:2 offset:[-11,3]
		dropdownlist pMModeDropdown "" items:#("Absolute", "Relative") selection:pMModeValue width:145 offset:[-40,0]
		label label3 "Value Type: " across:2 offset:[-24,3]
		dropdownlist pMValueTypeDropdown "" items:#("Float or Integer", "Random Float or Integer", "Checkbox", "Random Checkbox", "Color", "Random Color", "Point3", "Random Point3") selection:pMValueTypeValue width:145 offset:[-40,0]

		on pMParameterModeDropdown selected i do 
			(
			pMParameterModeValue = i
			curPos = pMFloater.pos
			pMCloseOpenUI curPos			
			)
		on pMModeDropdown selected i do pMModeValue = i
		on pMValueTypeDropdown selected i do 
			(
			pMValueTypeValue = i
			curPos = pMFloater.pos
			pMCloseOpenUI curPos
			)
			
		on pMRolloutMain open do 
			(
			-- Reset Lists
			pMObjsParamNamesList = #()
			pMModsNamesList = #()
			pMModsParamNamesList = #()
			pMMatsParamNamesList = #()
			pMMapsNamesList = #()
			pMMapsParamNamesList = #()
			pMMapCoordsNamesList = #()
			pMMapCoordsParamNamesList = #()

			-- Make Lists
			if pMParameterModeValue == 1 then pMRefreshListObjs()
			else if pMParameterModeValue == 2 then pMRefreshListMods()
			else if pMParameterModeValue == 3 then pMRefreshListMats()
			else if pMParameterModeValue == 4 then pMRefreshListMaps()
			else if pMParameterModeValue == 5 then pMRefreshListMapCoords()

			-- Fix Indexes
			if pMObjsParamDropdownIndex > pMObjsParamNamesList.count then pMObjsParamDropdownIndex = 1
			if pMModsDropdownIndex > pMModsNamesList.count then pMModsDropdownIndex = 1
			if pMModsParamNamesList.count == 0 then pMModsParamDropdownIndex = 1 else (if pMModsParamDropdownIndex > pMModsParamNamesList[pMModsDropdownIndex].count then pMModsParamDropdownIndex = 1)
			if pMMatsParamDropdownIndex > pMMatsParamNamesList.count then pMMatsDropdownIndex = 1
			if pMMapsDropdownIndex > pMMapsNamesList.count then pMMapsDropdownIndex = 1
			if pMMapsParamNamesList.count == 0 then pMMapsParamDropdownIndex = 1 else (if pMMapsParamDropdownIndex > pMMapsParamNamesList[pMMapsDropdownIndex].count then pMMapsParamDropdownIndex = 1)
			if pMMapCoordsDropdownIndex > pMMapCoordsNamesList.count then pMMapCoordsDropdownIndex = 1
			if pMMapCoordsParamNamesList.count == 0 then pMMapCoordsParamDropdownIndex = 1 else (if pMMapCoordsParamDropdownIndex > pMMapCoordsParamNamesList[pMMapCoordsDropdownIndex].count then pMMapCoordsParamDropdownIndex = 1)
			)
		)
		
	rollout pMRolloutParam1 "Parameters"
		(
		label label4 "Obj Param:" across:2 offset:[-21,3]
		dropdownlist pMObjsParamDropdown "" selection:pMObjsParamDropdownIndex width:145 offset:[-40,0]

		on pMObjsParamDropdown selected i do 
			(
			pMObjsParamDropdownIndex = i
			curPos = pMFloater.pos
			pMCloseOpenUI curPos
			)

		on pMRolloutParam1 open do 
			(
			pMObjsParamDropdown.items = pMObjsParamNamesList
			)
		)

	rollout pMRolloutParam2 "Parameters"
		(
		label label5 "Modifier:" across:2 offset:[-16,3]
		dropdownlist pMModsDropdown "" selection:pMModsDropdownIndex width:145 offset:[-40,0]
		label label6 "Mod Param:" across:2 offset:[-25,3]
		dropdownlist pMModsParamDropdown "" selection:pMModsParamDropdownIndex width:145 offset:[-40,0]

		on pMModsDropdown selected i do 
			(
			pMModsDropdownIndex = i
			pMModsParamDropdownIndex = 1
			curPos = pMFloater.pos
			pMCloseOpenUI curPos
			)
		on pMModsParamDropdown selected i do 
			(
			pMModsParamDropdownIndex = i
			curPos = pMFloater.pos
			pMCloseOpenUI curPos
			)

		on pMRolloutParam2 open do 
			(
			pMModsDropdown.items = pMModsNamesList
			if pMModsParamNamesList.count == 0 then pMModsParamDropdown.items = #() else pMModsParamDropdown.items = pMModsParamNamesList[pMModsDropdownIndex]
			)
		)

	rollout pMRolloutParam3 "Parameters"
		(
		label label7 "Mat Param:" across:2 offset:[-23,3]
		dropdownlist pMMatsParamDropdown "" selection:pMMatsParamDropdownIndex width:145 offset:[-40,0]

		on pMMatsParamDropdown selected i do 
			(
			pMMatsParamDropdownIndex = i
			curPos = pMFloater.pos
			pMCloseOpenUI curPos
			)

		on pMRolloutParam3 open do 
			(
			pMMatsParamDropdown.items = pMMatsParamNamesList
			)
		)
		
	rollout pMRolloutParam4 "Parameters"
		(
		label label8 "Map:" across:2 offset:[-8,3]
		dropdownlist pMMapsDropdown "" selection:pMMapsDropdownIndex width:145 offset:[-40,0]
		label label9 "Map Param:" across:2 offset:[-24,3]
		dropdownlist pMMapsParamDropdown "" selection:pMMapsParamDropdownIndex width:145 offset:[-40,0]

		on pMMapsDropdown selected i do 
			(
			pMMapsDropdownIndex = i
			pMMapsParamDropdownIndex = 1
			curPos = pMFloater.pos
			pMCloseOpenUI curPos
			)
		on pMMapsParamDropdown selected i do 
			(
			pMMapsParamDropdownIndex = i
			curPos = pMFloater.pos
			pMCloseOpenUI curPos
			)

		on pMRolloutParam4 open do 
			(
			pMMapsDropdown.items = pMMapsNamesList
			if pMMapsParamNamesList.count == 0 then pMMapsParamDropdown.items = #() else pMMapsParamDropdown.items = pMMapsParamNamesList[pMMapsDropdownIndex]
			)
		)

	rollout pMRolloutParam5 "Parameters"
		(
		label label10 "Map:" across:2 offset:[-8,3]
		dropdownlist pMMapCoordsDropdown "" selection:pMMapCoordsDropdownIndex width:145 offset:[-40,0]
		label label11 "Coord Param:" across:2 offset:[-24,3]
		dropdownlist pMMapCoordsParamDropdown "" selection:pMMapCoordsParamDropdownIndex width:145 offset:[-40,0]

		on pMMapCoordsDropdown selected i do 
			(
			pMMapCoordsDropdownIndex = i
			pMMapCoordsParamDropdownIndex = 1
			curPos = pMFloater.pos
			pMCloseOpenUI curPos
			)
		on pMMapCoordsParamDropdown selected i do 
			(
			pMMapCoordsParamDropdownIndex = i
			curPos = pMFloater.pos
			pMCloseOpenUI curPos
			)

		on pMRolloutParam5 open do 
			(
			pMMapCoordsDropdown.items = pMMapCoordsNamesList
			if pMMapCoordsParamNamesList.count == 0 then pMMapCoordsParamDropdown.items = #() else pMMapCoordsParamDropdown.items = pMMapCoordsParamNamesList[pMMapCoordsDropdownIndex]
			)
		)

	rollout pMRolloutValues "Values"
		(
		spinner pMSpecificValueSpinner "Float or Integer: " range:[-99999999,99999999,pMSpecificValueValue] fieldWidth:50
		spinner pMRandomLowSpinner "Rand Low Float or Integer: " range:[-99999999,99999999,pMRandomLowValue] fieldWidth:50
		spinner pMRandomHighSpinner "Rand High Float or Integer: " range:[-99999999,99999999,pMRandomHighValue] fieldWidth:50
		label label12 "Checkbox: " across:2 offset:[102,0];checkbox pMCheckboxCheckbox "" align:#right offset:[9,0] checked:pMCheckboxValue
		colorpicker pMColorPicker "Color:" color:pMColorValue modal:false align:#right fieldwidth:40 height:15
		label label13 "Point3: " across:4 offset:[33,0]
		spinner pMP3XSpinner "" range:[-99999999,99999999,pMP3XValue] fieldWidth:32 offset:[22,0]
		spinner pMP3YSpinner "" range:[-99999999,99999999,pMP3YValue] fieldWidth:32 offset:[14,0]
		spinner pMP3ZSpinner "" range:[-99999999,99999999,pMP3ZValue] fieldWidth:32 offset:[6,0]
		label label14 "R Low Point3: " across:4 offset:[16,0]
		spinner pMP3RLXSpinner "" range:[-99999999,99999999,pMP3RLXValue] fieldWidth:32 offset:[22,0]
		spinner pMP3RLYSpinner "" range:[-99999999,99999999,pMP3RLYValue] fieldWidth:32 offset:[14,0]
		spinner pMP3RLZSpinner "" range:[-99999999,99999999,pMP3RLZValue] fieldWidth:32 offset:[6,0]
		label label15 "R High Point3: " across:4 offset:[16,0]
		spinner pMP3RHXSpinner "" range:[-99999999,99999999,pMP3RHXValue] fieldWidth:32 offset:[22,0]
		spinner pMP3RHYSpinner "" range:[-99999999,99999999,pMP3RHYValue] fieldWidth:32 offset:[14,0]
		spinner pMP3RHZSpinner "" range:[-99999999,99999999,pMP3RHZValue] fieldWidth:32 offset:[6,0]
		
		on pMSpecificValueSpinner changed val do pMSpecificValueValue = val
		on pMRandomLowSpinner changed val do pMRandomLowValue = val
		on pMRandomHighSpinner changed val do pMRandomHighValue = val
		on pMCheckboxCheckbox changed state do pMCheckboxValue = pMCheckboxCheckbox.checked
		on pMColorPicker changed val do pMColorValue = val
		on pMP3XSpinner changed val do pMP3XValue = val
		on pMP3YSpinner changed val do pMP3YValue = val
		on pMP3ZSpinner changed val do pMP3ZValue = val
		on pMP3RLXSpinner changed val do pMP3RLXValue = val
		on pMP3RLYSpinner changed val do pMP3RLYValue = val
		on pMP3RLZSpinner changed val do pMP3RLZValue = val
		on pMP3RHXSpinner changed val do pMP3RHXValue = val
		on pMP3RHYSpinner changed val do pMP3RHYValue = val
		on pMP3RHZSpinner changed val do pMP3RHZValue = val
		
		on pMRolloutValues open do 
			(
			if pMValueTypeValue == 1 then 
				(
				pMSpecificValueSpinner.enabled = true
				pMRandomLowSpinner.enabled = false
				pMRandomHighSpinner.enabled = false
				label12.enabled = false
				pMCheckboxCheckbox.enabled = false
				pMColorPicker.enabled = false
				label13.enabled = false
				label14.enabled = false
				label15.enabled = false
				pMP3XSpinner.enabled = false
				pMP3YSpinner.enabled = false
				pMP3ZSpinner.enabled = false
				pMP3RLXSpinner.enabled = false
				pMP3RLYSpinner.enabled = false
				pMP3RLZSpinner.enabled = false
				pMP3RHXSpinner.enabled = false
				pMP3RHYSpinner.enabled = false
				pMP3RHZSpinner.enabled = false
				)
			else if pMValueTypeValue == 2 then 
				(
				pMSpecificValueSpinner.enabled = false
				pMRandomLowSpinner.enabled = true
				pMRandomHighSpinner.enabled = true
				label12.enabled = false
				pMCheckboxCheckbox.enabled = false
				pMColorPicker.enabled = false
				label13.enabled = false
				label14.enabled = false
				label15.enabled = false
				pMP3XSpinner.enabled = false
				pMP3YSpinner.enabled = false
				pMP3ZSpinner.enabled = false
				pMP3RLXSpinner.enabled = false
				pMP3RLYSpinner.enabled = false
				pMP3RLZSpinner.enabled = false
				pMP3RHXSpinner.enabled = false
				pMP3RHYSpinner.enabled = false
				pMP3RHZSpinner.enabled = false
				)
			else if pMValueTypeValue == 3 then 
				(
				pMSpecificValueSpinner.enabled = false
				pMRandomLowSpinner.enabled = false
				pMRandomHighSpinner.enabled = false
				label12.enabled = true
				pMCheckboxCheckbox.enabled = true
				pMColorPicker.enabled = false
				label13.enabled = false
				label14.enabled = false
				label15.enabled = false
				pMP3XSpinner.enabled = false
				pMP3YSpinner.enabled = false
				pMP3ZSpinner.enabled = false
				pMP3RLXSpinner.enabled = false
				pMP3RLYSpinner.enabled = false
				pMP3RLZSpinner.enabled = false
				pMP3RHXSpinner.enabled = false
				pMP3RHYSpinner.enabled = false
				pMP3RHZSpinner.enabled = false
				)
			else if pMValueTypeValue == 4 then 
				(
				pMSpecificValueSpinner.enabled = false
				pMRandomLowSpinner.enabled = false
				pMRandomHighSpinner.enabled = false
				label12.enabled = false
				pMCheckboxCheckbox.enabled = false
				pMColorPicker.enabled = false
				label13.enabled = false
				label14.enabled = false
				label15.enabled = false
				pMP3XSpinner.enabled = false
				pMP3YSpinner.enabled = false
				pMP3ZSpinner.enabled = false
				pMP3RLXSpinner.enabled = false
				pMP3RLYSpinner.enabled = false
				pMP3RLZSpinner.enabled = false
				pMP3RHXSpinner.enabled = false
				pMP3RHYSpinner.enabled = false
				pMP3RHZSpinner.enabled = false				
				)
			else if pMValueTypeValue == 5 then 
				(
				pMSpecificValueSpinner.enabled = false
				pMRandomLowSpinner.enabled = false
				pMRandomHighSpinner.enabled = false
				label12.enabled = false
				pMCheckboxCheckbox.enabled = false
				pMColorPicker.enabled = true
				label13.enabled = false
				label14.enabled = false
				label15.enabled = false
				pMP3XSpinner.enabled = false
				pMP3YSpinner.enabled = false
				pMP3ZSpinner.enabled = false
				pMP3RLXSpinner.enabled = false
				pMP3RLYSpinner.enabled = false
				pMP3RLZSpinner.enabled = false
				pMP3RHXSpinner.enabled = false
				pMP3RHYSpinner.enabled = false
				pMP3RHZSpinner.enabled = false
				)
			else if pMValueTypeValue == 6 then 
				(
				pMSpecificValueSpinner.enabled = false
				pMRandomLowSpinner.enabled = false
				pMRandomHighSpinner.enabled = false
				label12.enabled = false
				pMCheckboxCheckbox.enabled = false
				pMColorPicker.enabled = false
				label13.enabled = false
				label14.enabled = false
				label15.enabled = false
				pMP3XSpinner.enabled = false
				pMP3YSpinner.enabled = false
				pMP3ZSpinner.enabled = false
				pMP3RLXSpinner.enabled = false
				pMP3RLYSpinner.enabled = false
				pMP3RLZSpinner.enabled = false
				pMP3RHXSpinner.enabled = false
				pMP3RHYSpinner.enabled = false
				pMP3RHZSpinner.enabled = false
				)
			else if pMValueTypeValue == 7 then 
				(
				pMSpecificValueSpinner.enabled = false
				pMRandomLowSpinner.enabled = false
				pMRandomHighSpinner.enabled = false
				label12.enabled = false
				pMCheckboxCheckbox.enabled = false
				pMColorPicker.enabled = false
				label13.enabled = true
				label14.enabled = false
				label15.enabled = false
				pMP3XSpinner.enabled = true
				pMP3YSpinner.enabled = true
				pMP3ZSpinner.enabled = true
				pMP3RLXSpinner.enabled = false
				pMP3RLYSpinner.enabled = false
				pMP3RLZSpinner.enabled = false
				pMP3RHXSpinner.enabled = false
				pMP3RHYSpinner.enabled = false
				pMP3RHZSpinner.enabled = false
				)
			else if pMValueTypeValue == 8 then 
				(
				pMSpecificValueSpinner.enabled = false
				pMRandomLowSpinner.enabled = false
				pMRandomHighSpinner.enabled = false
				label12.enabled = false
				pMCheckboxCheckbox.enabled = false
				pMColorPicker.enabled = false
				label13.enabled = false
				label14.enabled = true
				label15.enabled = true
				pMP3XSpinner.enabled = false
				pMP3YSpinner.enabled = false
				pMP3ZSpinner.enabled = false
				pMP3RLXSpinner.enabled = true
				pMP3RLYSpinner.enabled = true
				pMP3RLZSpinner.enabled = true
				pMP3RHXSpinner.enabled = true
				pMP3RHYSpinner.enabled = true
				pMP3RHZSpinner.enabled = true
				)

			-- Autodetect Values
			if pMAutodetectValuesValue == true then
				(
				-- Calculate Current Value
				currentValue = pMSpecificValueValue
				if pMParameterModeValue == 1 then 
					(
					progressStart "Autodetecting Values"
					escapeEnable = false
					numOfItems = selection.count
					currentIteration = 0
					for obj in selection do
						(
						if getProgressCancel() == true then exit
						currentIteration += 1
						m = ((currentIteration as float)/(numOfItems as float))*100
						try 
							(
							currentValue = (getProperty obj pMObjsParamNamesList[pMObjsParamDropdownIndex])
							exit
							)
						catch()
						progressUpdate m
						)
					progressEnd()
					)
				else if pMParameterModeValue == 2 then 
					(
					progressStart "Autodetecting Values"
					escapeEnable = false
					numOfItems = selection.count
					currentIteration = 0
					for obj in selection do
						(
						if getProgressCancel() == true then exit
						currentIteration += 1
						m = ((currentIteration as float)/(numOfItems as float))*100
						try
							(
							if obj.modifiers.count != 0 then
								(
								for j in obj.modifiers do
									(
									if j.name == pMModsNamesList[pMModsDropdownIndex] then 
										(
										currentValue = (getProperty j (pMModsParamNamesList[pMModsDropdownIndex])[pMModsParamDropdownIndex])
										exit
										)
									)
								)
							)
						catch()
						progressUpdate m
						)
					progressEnd()
					)
				else if pMParameterModeValue == 3 then 
					(
					matlist = sLibGetAllMaterialsOnSelectedObjects()
					progressStart "Autodetecting Values"
					escapeEnable = false
					numOfItems = matlist.count
					currentIteration = 0
					for mat in matlist do
						(
						if getProgressCancel() == true then exit
						currentIteration += 1
						m = ((currentIteration as float)/(numOfItems as float))*100						
						try 
							(
							currentValue = (getProperty mat pMMatsParamNamesList[pMMatsParamDropdownIndex])
							exit
							)
						catch()
						progressUpdate m
						)
					progressEnd()
					)
				else if pMParameterModeValue == 4 then 
					(
					maplist = sLibGetAllMapsFromSelectedObjects()
					progressStart "Autodetecting Values"
					escapeEnable = false
					numOfItems = maplist.count
					currentIteration = 0
					for mapitems in maplist do
						(
						if getProgressCancel() == true then exit
						currentIteration += 1
						m = ((currentIteration as float)/(numOfItems as float))*100	
						try
							(
							if ((classof mapitems) as string) == pMMapsNamesList[pMMapsDropdownIndex] then 
								(
								currentValue = (getProperty mapitems (pMMapsParamNamesList[pMMapsDropdownIndex])[pMMapsParamDropdownIndex])
								exit
								)
							)
						catch()
						progressUpdate m
						)
					progressEnd()
					)
				else if pMParameterModeValue == 5 then 
					(
					maplist = sLibGetAllMapsFromSelectedObjects()
					progressStart "Autodetecting Values"
					escapeEnable = false
					numOfItems = maplist.count
					currentIteration = 0
					for mapitems in maplist do
						(
						if getProgressCancel() == true then exit
						currentIteration += 1
						m = ((currentIteration as float)/(numOfItems as float))*100	
						try
							(
							if ((classof mapitems) as string) == pMMapCoordsNamesList[pMMapCoordsDropdownIndex] then 
								(
								currentValue = (getProperty mapitems.coordinates (pMMapCoordsParamNamesList[pMMapCoordsDropdownIndex])[pMMapCoordsParamDropdownIndex])
								exit
								)
							)
						catch()
						progressUpdate m
						)
					progressEnd()
					)

				-- Add Value To Interface
				if (classof currentValue) == Float or (classof currentValue) == Integer then
					(
					pMSpecificValueValue = currentValue
					pMSpecificValueSpinner.value = currentValue
					if pMValueTypeValue != 1 and pMValueTypeValue != 2 then 
						(
						pMRolloutMain.pMValueTypeDropdown.selection = 1
						pMValueTypeValue = 1
						pMSpecificValueSpinner.enabled = true
						pMRandomLowSpinner.enabled = false
						pMRandomHighSpinner.enabled = false
						label12.enabled = false
						pMCheckboxCheckbox.enabled = false
						pMColorPicker.enabled = false
						label13.enabled = false
						label14.enabled = false
						label15.enabled = false
						pMP3XSpinner.enabled = false
						pMP3YSpinner.enabled = false
						pMP3ZSpinner.enabled = false
						pMP3RLXSpinner.enabled = false
						pMP3RLYSpinner.enabled = false
						pMP3RLZSpinner.enabled = false
						pMP3RHXSpinner.enabled = false
						pMP3RHYSpinner.enabled = false
						pMP3RHZSpinner.enabled = false
						)
					)
				else if (classof currentValue) == BooleanClass then
					(
					pMCheckboxValue = currentValue
					pMCheckboxCheckbox.checked = currentValue
					if pMValueTypeValue != 3 and pMValueTypeValue != 4 then 
						(
						pMRolloutMain.pMValueTypeDropdown.selection = 3
						pMValueTypeValue = 3
						pMSpecificValueSpinner.enabled = false
						pMRandomLowSpinner.enabled = false
						pMRandomHighSpinner.enabled = false
						label12.enabled = true
						pMCheckboxCheckbox.enabled = true
						pMColorPicker.enabled = false
						label13.enabled = false
						label14.enabled = false
						label15.enabled = false
						pMP3XSpinner.enabled = false
						pMP3YSpinner.enabled = false
						pMP3ZSpinner.enabled = false
						pMP3RLXSpinner.enabled = false
						pMP3RLYSpinner.enabled = false
						pMP3RLZSpinner.enabled = false
						pMP3RHXSpinner.enabled = false
						pMP3RHYSpinner.enabled = false
						pMP3RHZSpinner.enabled = false
						)
					)
				else if (classof currentValue) == Color then
					(
					pMColorValue = currentValue
					pMColorPicker.color = currentValue
					if pMValueTypeValue != 5 and pMValueTypeValue != 6 then 
						(
						pMRolloutMain.pMValueTypeDropdown.selection = 5
						pMValueTypeValue = 5
						pMSpecificValueSpinner.enabled = false
						pMRandomLowSpinner.enabled = false
						pMRandomHighSpinner.enabled = false
						label12.enabled = false
						pMCheckboxCheckbox.enabled = false
						pMColorPicker.enabled = true
						label13.enabled = false
						label14.enabled = false
						label15.enabled = false
						pMP3XSpinner.enabled = false
						pMP3YSpinner.enabled = false
						pMP3ZSpinner.enabled = false
						pMP3RLXSpinner.enabled = false
						pMP3RLYSpinner.enabled = false
						pMP3RLZSpinner.enabled = false
						pMP3RHXSpinner.enabled = false
						pMP3RHYSpinner.enabled = false
						pMP3RHZSpinner.enabled = false
						)
					)
				else if (classof currentValue) == Point3 then
					(
					pMP3XValue = currentValue.x
					pMP3YValue = currentValue.y
					pMP3ZValue = currentValue.z
					pMP3XSpinner.value = currentValue.x
					pMP3YSpinner.value = currentValue.y
					pMP3ZSpinner.value = currentValue.z
					if pMValueTypeValue != 7 and pMValueTypeValue != 8 then 
						(
						pMRolloutMain.pMValueTypeDropdown.selection = 7
						pMValueTypeValue = 7
						pMSpecificValueSpinner.enabled = false
						pMRandomLowSpinner.enabled = false
						pMRandomHighSpinner.enabled = false
						label12.enabled = false
						pMCheckboxCheckbox.enabled = false
						pMColorPicker.enabled = false
						label13.enabled = true
						label14.enabled = true
						label15.enabled = true
						pMP3XSpinner.enabled = true
						pMP3YSpinner.enabled = true
						pMP3ZSpinner.enabled = true
						pMP3RLXSpinner.enabled = false
						pMP3RLYSpinner.enabled = false
						pMP3RLZSpinner.enabled = false
						pMP3RHXSpinner.enabled = false
						pMP3RHYSpinner.enabled = false
						pMP3RHZSpinner.enabled = false
						)
					)
				)
			)
		)
		
	rollout pMRolloutTools "Tools"
		(
		group "Tools"
		(
		checkbox pMAutodetectValuesCheckbox "Autodetect Values?" checked:pMAutodetectValuesValue across:2 
		button pMRefreshButton "Refresh" width:76 align:#center toolTip:"Refresh Parameter Lists" offset:[9,-2]
		)
		
		on pMAutodetectValuesCheckbox changed state do 
			(
			pMAutodetectValuesValue = pMAutodetectValuesCheckbox.checked
			curPos = pMFloater.pos
			pMCloseOpenUI curPos
			)
		on pMRefreshButton pressed do 
			(
			pMObjsParamDropdownIndex = 1
			pMModsDropdownIndex = 1
			pMModsParamDropdownIndex = 1
			pMMatsParamDropdownIndex = 1
			pMMapsDropdownIndex = 1
			pMMapsParamDropdownIndex = 1
			pMMapCoordsDropdownIndex = 1
			pMMapCoordsParamDropdownIndex = 1
			curPos = pMFloater.pos
			pMCloseOpenUI curPos
			)
			
		button pMDoButton "Do" width:70 toolTip:"Do It and Close UI" pos:[40,60]
		on pMDoButton pressed do pMDo()
		button pMApplyButton "Apply" width:70 toolTip:"Do It and Keep UI Open" pos:[112,60]
		on pMApplyButton pressed do pMApply()
		button pMHelpButton "Help" width:70 toolTip:"Help" pos:[40,84]
		on pMHelpButton pressed do pMHelp()
		button pMSaveDefButton "SaveDef" width:70 toolTip:"Save Current Settings as Default" pos:[112,84]
		on pMSaveDefButton pressed do pMSaveDef()
		)		
	)
)
-------------------------------------------------------------------------------