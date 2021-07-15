-------------------------------------------------------------------------------
-- sLib.ms
-- By Neil Blevins (neil@soulburn3d.com)
-- v 1.50
-- Created On: 04/08/05
-- Modified On: 10/13/17
-- tested using Max 2018
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Description:
-- A library of functions needed by the SoulburnScripts.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Revision History:
--
-- v 1.01 Added sLibSelectionAllGeometry and sLibSelectionAllShapes functions.
--
-- v 1.02 Added sLibRotateObjByAxis functions.
--
-- v 1.03 Added sLibMoveIndexDownInArray and sLibMoveIndexUpInArray functions.
--
-- v 1.04 Added sLibCompareCaseInsensitive and sLibCompareCaseSensitive 
-- functions.
--
-- v 1.05 Added sLibSortAscending, sLibSortDecending, sLibArrayAsArrayString
-- and sLibArrayStringAsArray functions.
--
-- v 1.06 Added sLibChooseUniqueValuesByNumber, sLibChooseUniqueValuesByPercentage,
-- and sLibChooseUniqueValuesByWeight functions.
--
-- v 1.07 Added sLibAllSameParent.
--
-- v 1.08 Added sLibGetCollectionBBox and sLibPadValue.
--
-- v 1.09 Added sLibGetMapsFromMaterial.
--
-- v 1.10 Added sLibGetSceneSelectionSetsNames.
--
-- v 1.11 Fixed Shape Filter to look at baseobject.
--
-- v 1.12 Added sLibCompareArrays. Added sLibBrazil2Test.
--
-- v 1.13 Added sLibAverageMinMaxOfArray.
--
-- v 1.14 Added sLibGetCollectionBBoxCenter.
--
-- v 1.15 Added sLibMakeStringUppercase and sLibFindAndReplaceInString.
--
-- v 1.16 Added sLibRemoveTailNumbers, sLibAddToSelectionSet and 
-- sLibGetSelectionSetsByNode.
--
-- v 1.17 Added sLibGetGroupHead. Thanks to Richard Annema for the code.
--
-- v 1.18 Added sLibCopyAndPasteLayerFromNodeToNode, sLibFindObjTopLevelParent,
-- and sLibCopyAndPasteSelectionSetsFromNodeToNode.
--
-- v 1.19 Added sLibMaxVer.
--
-- v 1.20 Added sLibTrimDups, sLibGetAllAtm, sLibGetAllEffects, 
-- sLibGetAllDisplaceModMaps, sLibGetAllDisplaceSWMaps, sLibGetAllEnvironmentMaps, 
-- sLibGetAllFogMaps, sLibGetAllMapsFromSelectedObjects, sLibGetAllMeditMaps, 
-- sLibGetAllProjectorLightMaps, sLibGetAllSceneMaps, sLibGetBitmapsFromMaps, 
-- sLibGetMapsFromMaxWrapperObject, sLibGetAllSceneMaterials, 
-- sLibGetAllMaterialsOnSelectedObjects, sLibGetAllMeditMaterials,
-- sLibGetAllMaterials, sLibGetSubMaterials, sLibGetAllBlurEffectMaps, 
-- sLibGetAllBrazilSkylightMaps.
--
-- v 1.21 Added sLibGetSceneMaterials, sLibGetMaterialsOnSelectedObjects, 
-- sLibGetMeditMaterials, sLibGetAllMatLibMaterials, sLibGetMatLibMaterials,
-- sLibGetRangeFromArray, sLibCreateBlankArray, sLibRandomizeArray, 
-- sLibRandomWithBias, sLibRemoveModifiersByName. Thanks to Dubbie for some help 
-- with sLibRandomWithBias.
--
-- v 1.22 Added sLibGetAllControllersOnObj.
--
-- v 1.23 Added sLibRemoveModifiersByNameFragment, sLibGetLengthOfFileRec, 
-- sLibGetLengthOfFile, sLibSSPrintHelp, sLibSSFindTextFragment and
-- sLibSSGetTextFragment.
--
-- v 1.24 Added sLibFindBitmapInMapPaths. sLibSSPrintHelp now includes printing 
-- the known limitations section.
--
-- v 1.25 Added sLibGetAllUnwrapUVWMaps.
--
-- v 1.26 Removed recursion from all functions (found out that recursive
-- functions can cause maxscript to crash max). Affected functions are:
-- sLibGetMapsFromMaxWrapperObject, sLibGetSubMaterials, sLibGetAllControllersOnObj,
-- sLibFindObjTopLevelParent, sLibRemoveUnneededInstancesFromArray, 
-- sLibGetAllFilesInDir, sLibGetLengthOfFile, sLibRemoveUnneededInstancesFromArray
-- and sLibSSGetTextFragment.
--
-- v 1.27 Added sLibSplineMesherTest.
--
-- v 1.28 Added sLibPowerNurbsFilter.
--
-- v 1.29 Added sLibResetXForm.
--
-- v 1.30 Added sLibFilenameFromPath to replace filenameFromPath that no longer
-- works properly in max 2010.
--
-- v 1.31 Added sLibCoincidentPoints.
--
-- v 1.32 Added more error handling to sLibGetAllMaterials.
--
-- v 1.33 Added sLibCameraMapGeminiMapTest software test.
--
-- v 1.34 Added sLibVrayTest software test.
--
-- v 1.35 Simpler sLibVrayTest (thanks Vlado).
--
-- v 1.36 Added sLibGetActiveMap.
--
-- v 1.37 Added sLibGetCollectionBBoxVolume.
--
-- v 1.38 Added sLibAddExtraBackslashesToFilename.
--
-- v 1.39 Added sLibResizeImageByPixelsNoFilter and 
-- sLibResizeImageByPixelsFilter.
--
-- v 1.40 Added sLibGammaChange.
--
-- v 1.41 Added sLibGetVrayBitmapsFromMaps.
--
-- v 1.42 Added sLibFileNameCompareCaseSensitive.
--
-- v 1.43 Added sLibConvertsInstancesToReferences.
--
-- v 1.44 Added sLibTrimDupsByName.
--
-- v 1.45 Fixed a bug in sLibGetAllFilesInDir where it would return unexpected
-- data if there was no directory specified to search.
--
-- v 1.46 Added ability to modify the gamma in the sLibResizeImageByPixelsFilter 
-- function.
--
-- v 1.47 Added sLibWhatsCurrentRenderer.
--
-- v 1.48 Did a more consistent job of adding returns in the various functions.
-- Added sLibFindParentsInObjs, sLibFindParentsOfObjs and 
-- sLibConvertBaseObjectToPoly.
--
-- v 1.49 Updated sLibResizeImageByPixelsFilter to allow for non-proportional 
-- rescaling. Removed sLibResizeImageByPixelsNoFilter as it was no longer 
-- needed. Added sLibGetImageBitDepth.
--
-- v 1.50 Added sLibGetMultitilesFromMaps.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Initialization Start
-------------------------------------------------------------------------------
global sLibInit
if sLibInit != true then
(
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Globals
-------------------------------------------------------------------------------

-- Arrays
global sLibArrayAsArrayString
global sLibArrayStringAsArray
global sLibAverageMinMaxOfArray 
global sLibChooseUniqueValuesByNumber
global sLibChooseUniqueValuesByPercentage
global sLibChooseUniqueValuesByWeight
global sLibCompareArrays
global sLibCopyArray
global sLibCreateBlankArray
global sLibGetRangeFromArray
global sLibMoveIndexDownInArray
global sLibMoveIndexUpInArray
global sLibRandomizeArray
global sLibRemoveIndexFromArray
global sLibRemoveIndexesFromArray
global sLibRemoveItemFromArray
global sLibRemoveItemsFromArray
global sLibSortAscending	
global sLibSortDecending
global sLibTrimDups
global sLibTrimDupsByName

-- Bounding Boxes
global sLibGetCollectionBBox
global sLibGetCollectionBBoxCenter
global sLibGetCollectionBBoxVolume

-- Coincident
global sLibCoincidentPoints

-- Collecting
global sLibGetAllAtm
global sLibGetAllControllersOnObj
global sLibGetAllEffects
global sLibGetHiddenObjects
global sLibGetUnhiddenObjects
global sLibSelectionAllGeometry
global sLibSelectionAllShapes

-- Files
global sLibAddExtraBackslashesToFilename
global sLibFileExist
global sLibFilenameFromPath
global sLibGetAllFilesInDir
global sLibGetLengthOfFile
global sLibStripFileExtension

-- Filters
global sLibBipedFilter
global sLibCameraFilter
global sLibEditablePolyFilter
global sLibGeometryFilter
global sLibHelperFilter
global sLibParticlesFilter
global sLibPowerNurbsFilter
global sLibPowerSolidsFilter
global sLibShapeFilter
global sLibStandardLightFilter
global sLibStandardParticleFilter

-- Groups
global sLibGetGroupHead

-- Images
global sLibGammaChange
global sLibGetImageBitDepth
global sLibResizeImageByPixelsFilter

-- Instances
global sLibConvertsInstancesToReferences
global sLibDoesArrayContainInstancesOfObj
global sLibGetInstancesOfObject
global sLibIsInstanceOf
global sLibRemoveInstancesOfObjFromArray
global sLibRemoveUniqueObjectsFromArray
global sLibRemoveUnneededInstancesFromArray
global sLibSelectionOfInstances

-- Layers
global sLibCopyAndPasteLayerFromNodeToNode

-- Maps Specific
global sLibGetAllBlurEffectMaps
global sLibGetAllBrazilSkylightMaps
global sLibGetAllDisplaceModMaps
global sLibGetAllDisplaceSWMaps
global sLibGetAllEnvironmentMaps
global sLibGetAllFogMaps
global sLibGetAllMapsFromSelectedObjects
global sLibGetAllMeditMaps
global sLibGetAllProjectorLightMaps
global sLibGetAllSceneMaps
global sLibGetAllUnwrapUVWMaps

-- Maps Utility
global sLibFindBitmapInMapPaths
global sLibGetActiveMap
global sLibGetBitmapsFromMaps
global sLibGetMapsFromMaxWrapperObject
global sLibGetMultitilesFromMaps
global sLibGetVrayBitmapsFromMaps

-- Materials Specific
global sLibGetAllSceneMaterials
global sLibGetAllMaterialsOnSelectedObjects
global sLibGetAllMatLibMaterials
global sLibGetAllMeditMaterials
global sLibGetSceneMaterials
global sLibGetMaterialsOnSelectedObjects
global sLibGetMatLibMaterials
global sLibGetMeditMaterials

-- Materials Utility
global sLibGetAllMaterials
global sLibGetSubMaterials

-- Modifier Stack
global sLibConvertBaseObjectToPoly
global sLibRemoveModifiersByName
global sLibRemoveModifiersByNameFragment

-- Parents
global sLibAllSameParent
global sLibFindObjTopLevelParent
global sLibFindParentsInObjs
global sLibFindParentsOfObjs

-- Selection Sets
global sLibAddToSelectionSet
global sLibCopyAndPasteSelectionSetsFromNodeToNode
global sLibGetSceneSelectionSetsNames
global sLibGetSelectionSetsByNode

-- Software Tests
global sLibBrazil1Test
global sLibBrazil2Test
global sLibVrayTest
global sLibCameraMapGeminiMapTest
global sLibMaxVer
global sLibSplineMesherTest
global sLibWhatsCurrentRenderer

-- SoulburnScripts
global sLibSSPrintHelp
global sLibSSFindTextFragment
global sLibSSGetTextFragment

-- Strings
global sLibCompareCaseInsensitive
global sLibCompareCaseSensitive
global sLibFileNameCompareCaseSensitive
global sLibFindAndReplaceInString
global sLibMakeStringLowercase
global sLibMakeStringUppercase
global sLibNameCompareCaseInsensitive
global sLibNameCompareCaseSensitive
global sLibPadValue
global sLibRemoveTailNumbers
global sLibReverseString

-- Transforms
global sLibResetXForm
global sLibRotateObjByAxis

-- Values
global sLibRandomWithBias

-------------------------------------------------------------------------------
-- Arrays
-------------------------------------------------------------------------------

fn sLibArrayAsArrayString a spacer = 
	(
	s = ""
	if a.count != 0 then
		(
		for i = 1 to a.count do
			(
			s += (a[i] as string)
			if i != a.count then s += (spacer as string)
			)
		)
	return s
	)
	
fn sLibArrayStringAsArray s spacer = 
	(
	a = filterString s spacer
	return a
	)
	
fn sLibAverageMinMaxOfArray a = 
	(
	a1 = amax a
	a2 = amin a
	return ((abs (((a1 as float) - (a2 as float)) / (2 as float))) + a2)
	)

fn sLibChooseUniqueValuesByNumber a number =
	(
	result = #()
	if number > 0 then 
		(
		local b = sLibCopyArray a
		if number < b.count then
			(
			for i = 1 to ((b.count) - number) do
				(
				deleteItem b (random 1 b.count)
				)
			)
		result = b
		)
	return result
	)

fn sLibChooseUniqueValuesByPercentage a percentage =
	(
	number = a.count * percentage * 0.01
	return (sLibChooseUniqueValuesByNumber a number)
	)
	
fn sLibChooseUniqueValuesByWeight a weight =
	(
	b = #()
	if a.count >= 1 then 
		(
		for i = 1 to a.count do
			(
			if ((random 1 99) + (weight - 50)) > 50 then append b a[i]
			)
		)
	return b
	)

fn sLibCompareArrays a b = 
	(
	if a.count != b.count then return false
	else
		(
		for i = 1 to a.count do
			(
			if a[i] != b[i] then return false
			)
		return true
		)
	)

fn sLibCopyArray a = 
	(
	b = #()
	if a.count != 0 then 
		(
		for i = 1 to a.count do
			(
			append b a[i]
			)
		)
	return b
	)

fn sLibCreateBlankArray size = 
	(
	b = #()
	for a = 1 to size do
		(
		append b undefined
		)
	return b
	)

fn sLibGetRangeFromArray a start end =
	(
	b = #()
	for i = start to end do
		(
		append b a[i]
		)
	return b
	)

fn sLibMoveIndexDownInArray a index = 
	(
	b = sLibCopyArray a
	if index < (a.count +1) then
		(
		if index != a.count then
			(
			b[index] = a[index + 1]
			b[index + 1] = a[index]
			)
		)
	return b
	)
	
fn sLibMoveIndexUpInArray a index = 
	(
	b = sLibCopyArray a
	if index < (a.count +1) then
		(
		if index != 1 then
			(
			b[index] = a[index - 1]
			b[index - 1] = a[index]
			)
		)
	return b
	)

fn sLibRandomizeArray a = 
	(
	b = #()
	for i = 1 to a.count do
		(
		toAdd = a[(random 1 a.count)]
		append b toAdd
		)
	return b
	)

fn sLibRemoveIndexFromArray a index =
	(
	a = sLibCopyArray a
	deleteitem a index
	return a
	)

fn sLibRemoveIndexesFromArray a indexes =
	(
	c = sLibCopyArray a
	b = sLibCopyArray indexes
	if b.count != 0 then
		(
		sort b
		for i = 1 to b.count do
			(
			deleteitem c b[i]
			for w = 1 to b.count do
				(
				b[w] -= 1
				)
			)
		)
	return c
	)
	
fn sLibRemoveItemFromArray a item =
	(
	b = sLibCopyArray a
	if b.count != 0 then
		(
		delete_array = #()
		for i = 1 to b.count do
			(
			if b[i] == item then append delete_array i
			)
		b = sLibRemoveIndexesFromArray b delete_array
		)
	return b
	)
	
fn sLibRemoveItemsFromArray a items =
	(
	c = sLibCopyArray a
	b = sLibCopyArray items
	if b.count != 0 then
		(
		for i in b do 
			(
			c = sLibRemoveItemFromArray c i
			)
		)
	return c
	)
	
fn sLibCopyArray a = 
	(
	b = #()
	if a.count != 0 then 
		(
		for i = 1 to a.count do
			(
			append b a[i]
			)
		)
	return b
	)
	
fn sLibSortAscending a = 
	(
	return (sort a)
	)
	
fn sLibSortDecending a =
	(
	b = #()
	sort a
	for w = 1 to a.count do
		(
		append b a[a.count]
		deleteitem a a.count
		)
	return b
	)

fn sLibTrimDups a = 
	(
	for i in a.count to 1 by -1 do 
		(
		idx = findItem a a[i]
		if (idx != 0) AND (idx != i) do deleteItem a i
		)
	return a
	)
	
fn sLibTrimDupsByName a = 
	(
	b = #()
	for i in a do 
		(
		found = false
		for w in b do
			(
			if w.name == i.name then found = true
			)
		if found == false then append b i
		)
	return b
	)
	
-------------------------------------------------------------------------------
-- Bounding Boxes
-------------------------------------------------------------------------------
	
fn sLibGetCollectionBBox collection = 
	(
	result = #([0,0,0],[0,0,0])
	if collection.count != 0 then 
		(
		max = [collection[1].max.x,collection[1].max.y,collection[1].max.z]
		min = [collection[1].min.x,collection[1].min.y,collection[1].min.z]
		for i in collection do 
			(
			if i.max.x > max.x then max.x = i.max.x
			if i.max.y > max.y then max.y = i.max.y
			if i.max.z > max.z then max.z = i.max.z
			if i.min.x < min.x then min.x = i.min.x
			if i.min.y < min.y then min.y = i.min.y
			if i.min.z < min.z then min.z = i.min.z
			)
		result = #([max.x,max.y,max.z],[min.x,min.y,min.z])
		)
	return result
	)
	
fn sLibGetCollectionBBoxCenter collection = 
	(
	a = sLibGetCollectionBBox collection
	return [(a[1][1]+a[2][1])/2, (a[1][2]+a[2][2])/2, (a[1][3]+a[2][3])/2]
	)
	
fn sLibGetCollectionBBoxVolume collection = 
	(
	result = #([0,0,0],[0,0,0])
	if collection.count != 0 then 
		(
		bBoxSize = sLibGetCollectionBBox collection
		result = ((bBoxSize[1][1]-bBoxSize[2][1])*(bBoxSize[1][2]-bBoxSize[2][2])*(bBoxSize[1][3]-bBoxSize[2][3]))
		)
	return result
	)

-------------------------------------------------------------------------------
-- Coincident
-------------------------------------------------------------------------------

fn sLibCoincidentPoints a b tolerance = 
(
	result = true
	if a.x > (b.x + tolerance) then result = false
	else if a.x < (b.x - tolerance) then result = false
	else if a.y > (b.y + tolerance) then result = false
	else if a.y < (b.y - tolerance) then result = false
	else if a.z > (b.z + tolerance) then result = false
	else if a.z < (b.z - tolerance) then result = false
	return result
)

-------------------------------------------------------------------------------
-- Collecting
-------------------------------------------------------------------------------

fn sLibGetAllAtm =
	(
	a = #()
	if numAtmospherics != 0 then
		(
		for i = 1 to numAtmospherics do
			(
			append a (getAtmospheric i)
			)
		)
	return a
	)

fn sLibGetAllControllersOnObj inputobj a = 
	(
	contToProcess = #(inputobj)
	for cont in contToProcess do
		(
		if cont.numsubs != 0 then
			(
			for i = 1 to cont.numsubs do
				(
				if cont[i] != undefined then
					(
					if cont[i].numsubs != 0 then
						(
						for j = 1 to cont[i].numsubs do
							(
							if cont[i][j] != undefined then
								(
								append a cont[i][j]
								)
							)
						)
					)
				append contToProcess cont[i]
				)
			)
		)
	return a
	)
	
fn sLibGetAllEffects =
	(
	a = #()
	if numEffects != 0 then
		(
		for i = 1 to numEffects do
			(
			append a (getEffect i)
			)
		)
	return a
	)

fn sLibGetHiddenObjects = 
	(
	a = #()
	for i in $* do
		(
		if i.ishidden == true then append a i
		)
	return a
	)

fn sLibGetUnhiddenObjects = 
	(
	a = #()
	for i in $* do
		(
		if i.ishidden == false then append a i
		)
	return a
	)

fn sLibSelectionAllGeometry a = 
	(
	result = true
	if a.count == 0 then result = false
	else
		(
		result = true
		for i in a do
			(
			if (sLibGeometryFilter i) == false then 
				(
				result = false
				exit
				)
			)
		)
	return result
	)
	
fn sLibSelectionAllShapes a = 
	(
	result = true
	if a.count == 0 then result = false
	else
		(
		result = true
		for i in a do
			(
			if (sLibShapeFilter i) == false then 
				(
				result = false
				exit
				)
			)
		)
	return result
	)
	
-------------------------------------------------------------------------------
-- Files
-------------------------------------------------------------------------------

fn sLibAddExtraBackslashesToFilename f = 
	(
	return (substituteString f "\\" "\\\\")
	)

fn sLibFileExist f = 
	(
	return ((getfiles f).count != 0)
	)

fn sLibFilenameFromPath f = 
	(
	result = undefined
	filteredString = filterString f "\\"
	if filteredString.count != 0 then result = filteredString[filteredString.count]
	return result
	)
	
fn sLibGetAllFilesInDir inputDir rec type = 
	(
	a = #()
	if inputDir != "" then
		(
		dirsToProcess = #(inputDir)
		for dir in dirsToProcess do
			(		
			currentFiles = getFiles (dir + "*." + (type as string))
			for i in currentFiles do append a i
			if rec == true then
				(
				subDirs = getDirectories (dir + "*.*")
				for i in subDirs do append dirsToProcess i
				)
			)
		)
	return a
	)

fn sLibGetLengthOfFile thefile = 
	(
	result = 0
	thefileOpen = openFile thefile
	if thefileOpen != undefined and (classof thefileOpen == FileStream) then 
		(
		while ((eof thefileOpen) == false) do
			(
			readLine thefileOpen
			result += 1
			)
		)
	close thefileOpen
	return result
	)
	
fn sLibStripFileExtension f = 
	(
	fileName = sLibReverseString f
	locationOfCut = findString fileName "."
	fileNameReversed = substring fileName (locationOfCut + 1) fileName.count
	return sLibReverseString fileNameReversed
	)
	
-------------------------------------------------------------------------------
-- Filters
-------------------------------------------------------------------------------

fn sLibBipedFilter o = 
	(
	return (classof o == Biped_Object)
	)

fn sLibCameraFilter o = 
	(
	return (superclassof o == camera)
	)
	
fn sLibEditablePolyFilter o = 
	(
	return (classof o.baseobject == Editable_Poly)
	)
	
fn sLibGeometryFilter o = 
	(
	return (superclassof o == GeometryClass)
	)

fn sLibHelperFilter o = 
	(
	return (superclassof o == helper)
	)

fn sLibParticlesFilter o =
	(
	result = false
	if \
	classof o.baseobject == SuperSpray or \
	classof o.baseobject == PArray or \
	classof o.baseobject == PCloud or \
	classof o.baseobject == Blizzard or \
	classof o.baseobject == Snow or \
	classof o.baseobject == Spray or \
	classof o.baseobject == ParticleStudio or \
	classof o.baseobject == Sand_Blaster or \
	classof o.baseobject == PF_Source or \
	classof o.baseobject == Particles \
	then result = true
	return result
	)

fn sLibPowerNurbsFilter o =
	(
	result = false
	if \
	classof o == Pwr_EditNRB or \
	classof o == Pwr_Join or \
    	classof o == Pwr_Extrude or \
	classof o == Pwr_Assembly or \
	classof o == Pwr_Boolean or \
	classof o == Pwr_Fillet or \
	classof o == Pwr_Shell or \
	classof o == Pwr_Planar or \
	classof o == Pwr_Revolve or \
	classof o == Pwr_Skin or \
	classof o == Pwr_Pipe or \
	classof o == Pwr_Sweep or \
	classof o == Pwr_Swung \
	then result = true
	return result
	)

fn sLibPowerSolidsFilter o =
	(
	result = false
	if \
	classof o == EditableBrep or \
	classof o == BrepJoin or \
    	classof o == BrepExtrude or \
	classof o == BrepAssembly or \
	classof o == BrepBoolean or \
	classof o == BrepFillet or \
	classof o == BrepShell or \
	classof o == BrepPlanar or \
	classof o == BrepRevolve or \
	classof o == BrepSkin or \
	classof o == BrepPipe or \
	classof o == BrepSweep or \
	classof o == BrepSwung \
	then result = true
	return result
	)

fn sLibShapeFilter o = 
	(
	return (superclassof o.baseobject == shape)
	)

fn sLibStandardLightFilter o = 
	(
	result = false
	if \
	classof o == targetSpot or \
	classof o == Omnilight or \
	classof o == TargetDirectionallight or \
	classof o == Directionallight or \
	classof o == freeSpot \
	then result = true
	return result
	)
	
fn sLibStandardParticleFilter o =
	(
	result = false
	if \
	classof o.baseobject == SuperSpray or \
	classof o.baseobject == PArray or \
	classof o.baseobject == PCloud or \
	classof o.baseobject == Blizzard \
	then result = true
	return result
	)

-------------------------------------------------------------------------------
-- Groups
-------------------------------------------------------------------------------

fn sLibGetGroupHead obj = 
	(
	result = undefined
	groupHeads = for o in objects where (isGroupHead o) collect o
	for o in groupHeads do 
		(
		if (findItem o.children obj != 0) then result = o
		)
	return result
	)

-------------------------------------------------------------------------------
-- Images
-------------------------------------------------------------------------------

fn sLibGammaChange bm val = 
	(
	-- bm must be sent to the function as an opened bitmap file
	nbm = bitmap (bm.width) (bm.height) color:black gamma:val
	pasteBitmap bm nbm [0,0] [0,0]
	return nbm
	)

fn sLibGetImageBitDepth i = 
	(
	result = 0
	try (result = (getBitmapInfo i)[5])
	catch()
	return result
	)

-- Adapted from code by Jorge Rodríguez
fn sLibResizeImageByPixelsFilter myimages outputdir outputprepend outputpostpend resizeMode newPixelWidth newPixelHeight imageType modifygamma =
	(
	for inputFileName in myimages do
		(
		sourceImg = (dotnetclass "System.Drawing.Image").FromFile inputFileName

		if resizeMode == 1 then
			(
			-- Keep Proportions
			factor = (newPixelWidth as float)/((sourceImg.Width) as float)
			imgWidth = (sourceImg.Width * factor) as integer
			imgHeight = (sourceImg.Height * factor) as integer
			)
		else 
			(
			--Rescale Image To Specific Width And Height
			imgWidth = newPixelWidth as integer
			imgHeight = newPixelHeight as integer
			)

		imgBits = sourceImg.PixelFormat

		destImg = dotnetobject "System.Drawing.Bitmap" imgWidth imgHeight imgBits
		graphic = (dotnetclass "System.Drawing.Graphics").fromImage destImg

		graphic.CompositingQuality = graphic.CompositingQuality.HighQuality
		graphic.SmoothingMode	  = graphic.SmoothingMode.HighQuality
		graphic.InterpolationMode  = graphic.InterpolationMode.HighQualityBicubic	

		rect = dotnetobject "System.Drawing.Rectangle" 0 0 imgWidth imgHeight
		graphic.DrawImage sourceImg rect

		tempFileName = outputdir + (getfilenameFile inputFileName) + "_Temp" + ".png"
		destImg.Save tempFileName

		sourceImg.Dispose()
		destImg.Dispose()
		graphic.Dispose()

		tempImg = openBitMap tempFileName
		tempImg2 = sLibGammaChange tempImg modifygamma
		close tempImg
		close tempImg2
		deleteFile tempFileName

		outputBitmap = copy tempImg2
		outputBitmap.filename = outputdir + outputprepend + (getfilenameFile inputFileName) + outputpostpend + "." + imageType

		save outputBitmap
		close outputBitmap
	
		freeSceneBitmaps()
		gc light:true
		)
	return undefined
	)

-------------------------------------------------------------------------------
-- Instances
-------------------------------------------------------------------------------

-- Code thanks to Denis Trofimov
-- variable instancearray should only contain instances of the same object
fn sLibConvertsInstancesToReferences instanceArray = 
	(
	instancereplace instanceArray instanceArray[1]
	instancemgr.makeobjectsunique instanceArray #individual
	temptarget = copy instanceArray[1]
	referencereplace instanceArray temptarget
	delete temptarget
	return undefined
	)

fn sLibDoesArrayContainInstancesOfObj a Obj = 
	(
	result = false
	if Obj != undefined then
		(
		if a != 0 then
			(
			if (refs.dependents Obj.baseobject).count != 0 then
				(
				r = #()
				for w = 1 to (refs.dependents Obj.baseobject).count do
					(
					if (refs.dependents Obj.baseobject)[w] != Obj then
						(
						if iskindof (refs.dependents Obj.baseobject)[w] (classof Obj) then
							(
							append r (refs.dependents Obj.baseobject)[w]
							)
						)
					)
				for i in a do
					(
					if (finditem r i) != 0 then 
						(
						result = true
						exit
						)
					)
				)
			)
		)
	return result
	)

fn sLibGetInstancesOfObject Obj = 
	(
	a = #()
	if (refs.dependents Obj.baseobject).count != 0 then
		(
		for i = 1 to (refs.dependents Obj.baseobject).count do
			(
			if (refs.dependents Obj.baseobject)[i] != Obj then
				(
				if iskindof (refs.dependents Obj.baseobject)[i] (classof Obj) then
					(
					append a (refs.dependents Obj.baseobject)[i]
					)
				)
			)
		)
	return a
	)

fn sLibIsInstanceOf Obj1 Obj2 = 
	(
	result = false
	a = sLibGetInstancesOfObject Obj1
	if (findItem a Obj2) != 0 then result = true
	return result
	)
	
fn sLibRemoveInstancesOfObjFromArray a Obj = 
	(
	b = sLibCopyArray a
	if Obj != undefined then
		(
		toRemove = sLibGetInstancesOfObject Obj
		b = sLibRemoveItemsFromArray a toRemove 
		)
	return b
	)
	
fn sLibRemoveUniqueObjectsFromArray a = 
	(
	b = sLibCopyArray a
	for i in b do
		(
		if ((sLibDoesArrayContainInstancesOfObj b i) == false) then
			(
			b = sLibRemoveItemFromArray b i
			)
		)
	return b
	)	
	
fn sLibRemoveUnneededInstancesFromArray objsToProcess = 
	(
	a = #()
	while objsToProcess.count != 0 do
		(
		append a objsToProcess[1]
		objsWithoutFirst = sLibRemoveItemFromArray objsToProcess objsToProcess[1]
		trimmedArray = sLibRemoveInstancesOfObjFromArray objsWithoutFirst objsToProcess[1]
		objsToProcess = sLibCopyArray trimmedArray
		)
	return a
	)

fn sLibSelectionOfInstances a =
	(
	result = true
	if a.count > 1 then 
		(
		for i = 2 to a.count do
			(
			if (sLibIsInstanceOf a[1] a[i]) == false then 
				(
				result = false
				exit
				)
			)
		)
	return result
	)

-------------------------------------------------------------------------------
-- Layers
-------------------------------------------------------------------------------

fn sLibCopyAndPasteLayerFromNodeToNode copyObj pasteObj = 
	(
	myLayerName = copyObj.layer.name
	myLayer = layermanager.getLayerFromName myLayerName
	myLayer.addnode pasteObj
	return udnefined
	)

-------------------------------------------------------------------------------
-- Maps Specific
-------------------------------------------------------------------------------

fn sLibGetAllBlurEffectMaps = 
	(
	b = #()
	for e in (sLibGetAllEffects()) do
		(
		if classof e == blur then
			(
			if e.selMaskMap != undefined then
				(			
				a = #()
				append a e.selMaskMap
				sLibGetMapsFromMaxWrapperObject e.selMaskMap a
				join b a
				)
			)
		)
	sLibTrimDups b
	return b
	)

fn sLibGetAllBrazilSkylightMaps = 
	(
	b = #()
	if sLibCompareArrays renderers.current.classid #(1387076610, 288174012) then
		(
		if renderers.current.flux_skylt_map != undefined then
			(
			a = #()
			append a renderers.current.flux_skylt_map
			sLibGetMapsFromMaxWrapperObject renderers.current.flux_skylt_map a
			join b a
			)
		)
	else if sLibCompareArrays renderers.current.classid #(95494396, 474502030) then
		(
		Brz = trackviewnodes.Brazil_r_s[renderers.current.renderer_no + 1]
		if Brz.Luma_Server_Parameter_Block_Holder.skylight_map != undefined then
			(
			a = #()
			append a Brz.Luma_Server_Parameter_Block_Holder.skylight_map
			sLibGetMapsFromMaxWrapperObject Brz.Luma_Server_Parameter_Block_Holder.skylight_map a
			join b a		
			)
		)
	sLibTrimDups b
	return b
	)

fn sLibGetAllDisplaceModMaps = 
	(
	b = #()
	for obj in geometry do 
		(
		for m in obj.modifiers do
			(
			if classof m == Displace then 
				(
				if m.map != undefined then 
					(
					a = #()
					append a m.map
					sLibGetMapsFromMaxWrapperObject m.map a
					join b a
					)
				)
			)
		)
	sLibTrimDups b
	return b
	)
	
fn sLibGetAllDisplaceSWMaps = 
	(
	b = #()
	for s in spacewarps do 
		(
		if classof s == Spacedisplace then if s.map != undefined then 
			(
			a = #()
			append a s.map
			sLibGetMapsFromMaxWrapperObject s.map a
			join b a
			)
		)
	sLibTrimDups b
	return b
	)

fn sLibGetAllEnvironmentMaps = 
	(
	b = #()
	if EnvironmentMap != undefined then 
		(
		a = #()
		append a EnvironmentMap
		sLibGetMapsFromMaxWrapperObject EnvironmentMap a
		join b a
		)
	return b
	)
	
fn sLibGetAllFogMaps = 
	(
	b = #()
	for f in (sLibGetAllAtm()) do
		(
		if classof f == fog then
			(
			a = #()
			sLibGetMapsFromMaxWrapperObject f a
			join b a
			)
		)
	sLibTrimDups b
	return b
	)
	
fn sLibGetAllMapsFromSelectedObjects = 
	(
	b = #()
	mats = sLibGetAllMaterialsOnSelectedObjects()
	for m in mats do
		(
		a = #()
		sLibGetMapsFromMaxWrapperObject m a
		join b a
		)
	sLibTrimDups b
	return b
	)

fn sLibGetAllMeditMaps = 
	(
	b = #()
	mats = sLibGetAllMeditMaterials()
	for m in mats do
		(
		a = #()
		sLibGetMapsFromMaxWrapperObject m a
		join b a
		)
	sLibTrimDups b
	return b
	)

fn sLibGetAllProjectorLightMaps = 
	(
	b = #()
	for l in lights do 
		(
		if superclassof l == light then 
			(
			if classof l == Brazil_Light then
				(
				if l.projector_map != undefined then 
					(
					a = #()
					append a l.projector_map
					sLibGetMapsFromMaxWrapperObject l.projector_map a
					join b a
					)
				)
			else if classof l == B2_Main_Light then
				(
				if l.base_parameters.feat_projector_on == true then
					(
					if l.projector_pb_holder.projector_map != undefined then
						(
						a = #()
						append a l.projector_pb_holder.projector_map
						sLibGetMapsFromMaxWrapperObject l.projector_pb_holder.projector_map a
						join b a
						)
					)
				)
			else if sLibStandardLightFilter l == true then
				(
				if l.projectorMap != undefined then 
					(
					a = #()
					append a l.projectorMap
					sLibGetMapsFromMaxWrapperObject l.projectorMap a
					join b a
					)
				)
			)
		)
	sLibTrimDups b
	return b
	)
	
fn sLibGetAllSceneMaps = 
	(
	b = #()
	mats = sLibGetAllSceneMaterials()
	for m in mats do
		(
		a = #()
		sLibGetMapsFromMaxWrapperObject m a
		join b a
		)
	sLibTrimDups b
	return b
	)
	
fn sLibGetAllUnwrapUVWMaps = 
	(
	b = #()
	for obj in geometry do 
		(
		for m in obj.modifiers do
			(
			if classof m == Unwrap_UVW then 
				(
				if m.texMapList != undefined then 
					(
					a = m.texMapList
					join b a
					)
				)
			)
		)
	sLibTrimDups b
	return b
	)

-------------------------------------------------------------------------------
-- Maps Utility
-------------------------------------------------------------------------------

fn sLibFindBitmapInMapPaths mymap =
	(
	result = false
	pathcount = mapPaths.count()
	if pathcount != 0 then
		(
		for i = 1 to pathcount do
			(
			currentpath = mapPaths.get i
			testbitmap = (currentpath + "\\" + mymap)
			if (sLibFileExist testbitmap) == true then 
				(
				result = testbitmap
				exit
				)
			)
		)
	return result
	)

fn sLibGetActiveMap meditMode = 
	(
	currentTexmap = undefined
	-- Choose Medit
	if meditMode == 2 then
		(
		if sLibMaxVer() < 13.0 then (MessageBox "Slate Medit Mode only works with Max 2011 and up, please change to mode to: Use Classic Mat Editor" title:"sLib";return currentTexmap)
		else (currentTexmap = sme.GetMtlInParamEditor())
		)
	else (currentTexmap = (medit.GetCurMtl()))

	-- Is result a Texturemap?
	if superclassof currentTexmap != textureMap then 
		(
		MessageBox "Please pick a slot that contains a texmap" title:"sLib"
		currentTexmap = undefined
		)
	return currentTexmap
	)

fn sLibGetBitmapsFromMaps a = 
	(
	b = #()
	for i in a do
		(
		if classof i == Bitmaptexture then append b i
		)
	return b
	)
	
fn sLibGetMapsFromMaxWrapperObject inputMat a =
	(
	matsToProcess = #(inputMat)
	for mat in matsToProcess do
		(
		if mat.numsubs != 0 then
			(
			for i = 1 to mat.numsubs do
				(
				if mat[i] != undefined then
					(
					if classof mat[i] == SubAnim then
						(
						if superclassof mat[i].object == textureMap then
							(
							if mat[i].object != undefined then append a mat[i].object
							)
						)
					append matsToProcess mat[i]
					)
				)
			)
		)
	return a
	)

fn sLibGetMultitilesFromMaps a = 
	(
	b = #()
	for i in a do
		(
		if classof i == MultiTile then append b i
		)
	return b
	)

fn sLibGetVrayBitmapsFromMaps a = 
	(
	b = #()
	for i in a do
		(
		if classof i == VRayHDRI then append b i
		)
	return b
	)

-------------------------------------------------------------------------------
-- Materials Specific
-------------------------------------------------------------------------------
	
fn sLibGetAllSceneMaterials = 
	(
	a = #()
	for i in $* do
		(
		if i.material != undefined then
			(
			for i in (sLibGetAllMaterials i.material) do
				(
				if (finditem a i) == 0 then append a i
				)
			)
		)
	return a
	)
	
fn sLibGetAllMaterialsOnSelectedObjects = 
	(
	a = #()
	for i in selection do
		(
		if i.material != undefined then
			(
			for i in (sLibGetAllMaterials i.material) do
				(
				if (finditem a i) == 0 then append a i
				)
			)
		)
	return a
	)

fn sLibGetAllMatLibMaterials = 
	(
	a = #()
	for i in currentMaterialLibrary do
		(
		if superclassof i == Material then 
			(
			for i in (sLibGetAllMaterials i) do
				(
				if (finditem a i) == 0 then append a i
				)
			)
		)
	return a
	)
	
fn sLibGetAllMeditMaterials = 
	(
	a = #()
	for i = 1 to 24 do
		(
		for i in (sLibGetAllMaterials meditmaterials[i]) do
			(
			if (finditem a i) == 0 then append a i
			)
		)
	return a
	)
	
fn sLibGetSceneMaterials = 
	(
	a = #()
	for i in $* do
		(
		if i.material != undefined then
			(
			if (finditem a i.material) == 0 then append a i.material
			)
		)
	return a
	)
	
fn sLibGetMaterialsOnSelectedObjects = 
	(
	a = #()
	for i in selection do
		(
		if i.material != undefined then
			(
			if (finditem a i.material) == 0 then append a i.material
			)
		)
	return a
	)
	
fn sLibGetMatLibMaterials = 
	(
	a = #()
	for i in currentMaterialLibrary do
		(
		if superclassof i == Material then 
			(
			if (finditem a i) == 0 then append a i
			)
		)
	return a
	)
	
fn sLibGetMeditMaterials = 
	(
	a = #()
	for i = 1 to 24 do
		(
		if (finditem a meditmaterials[i]) == 0 then append a meditmaterials[i]
		)
	return a
	)
	
-------------------------------------------------------------------------------
-- Materials Utility
-------------------------------------------------------------------------------

fn sLibGetAllMaterials mat = 
	(
	a = #()
	x = #()	
	if superclassof mat == material then
		(
		append a mat
		sLibGetSubMaterials mat x
		for i in x do
			(
			if finditem a i == 0 then append a i
			)
		)
	return a
	)	

fn sLibGetSubMaterials inputMat a = 
	(
	matsToProcess = #(inputMat)
	for mat in matsToProcess do	
		(
		if mat.numsubs != 0 then
			(
			for i = 1 to mat.numsubs do
				(
				if mat[i] != undefined then
					(
					if iskindof mat[i] material == true then 
						(
						if classof mat[i] == SubAnim then
							(
							if superclassof mat[i].object == material then 
								(
								if finditem a (mat[i].object) == 0 then append a (mat[i].object)
								)
							)
						if superclassof mat[i] == material then 
							(
							if finditem a (mat[i]) == 0 then append a (mat[i])
							)
						)
					append matsToProcess mat[i]
					)
				)
			)
		)
	return a
	)

-------------------------------------------------------------------------------
-- Modifier Stack
-------------------------------------------------------------------------------

fn sLibConvertBaseObjectToPoly obj = 
	(
	if (canConvertTo obj Polymeshobject) == true then
		(
		numMods = (obj.modifiers).count
		theMod = (execute ("Turn_to_Poly" + "()"))
		addmodifier obj theMod before:(numMods)
		maxOps.CollapseNodeTo obj (numMods+1) off
		return true
		)
	else return false
	)

fn sLibRemoveModifiersByName objs name = 
	(
	modNumberKilled = 0
	for i in objs do
		(
		modsToKill = #()
		if i.modifiers.count != 0 then
			(
			for j = 1 to i.modifiers.count do
				(
				if i.modifiers[j].name == name then append modsToKill j 
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
	return modNumberKilled
	)
	
fn sLibRemoveModifiersByNameFragment objs name = 
	(
	modNumberKilled = 0
	for i in objs do
		(
		modsToKill = #()
		if i.modifiers.count != 0 then
			(
			for j = 1 to i.modifiers.count do
				(
				modname = i.modifiers[j].name
				if (findString modname name) != undefined then append modsToKill j 
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
	return modNumberKilled
	)

-------------------------------------------------------------------------------
-- Parents
-------------------------------------------------------------------------------

fn sLibAllSameParent a = 
	(
	result = true
	if a.count > 1 then
		(
		testParent = a[1].parent
		for i in a do
			(
			if i.parent != testParent then result = false
			)
		)
	return result
	)

fn sLibFindObjTopLevelParent inputObj =
	(
	result = undefined
	objsToProcess = #(inputObj)
	for obj in objsToProcess do
		(
		if obj.parent == undefined then result = obj
		else append objsToProcess obj.parent
		)
	return result
	)

fn sLibFindParentsInObjs objs = 
	(
	objsToProcess = #()
	objsResult = #()
	for i in objs do 
		(
		if i.parent != undefined then 
			(
			if (finditem objs i.parent) != 0 then
				(
				if isGroupMember i == false then
					(
					append objsToProcess i
					)
				)
			)
		)
	for i in objs do if finditem objsToProcess i == 0 then append objsResult i
	return objsResult
	)

fn sLibFindParentsOfObjs objs = 
	(
	objsToProcess = #()
	objsResult = #()
	for i in objs do 
		(
		tParent = (sLibFindObjTopLevelParent i)
		if findItem objsResult tParent == 0 then append objsResult tParent
		)
	return objsResult
	)

-------------------------------------------------------------------------------
-- Selection Sets
-------------------------------------------------------------------------------

fn sLibAddToSelectionSet mySetName obj = 
	(
	a = #()
	mySet = SelectionSets[mySetName]
	for i in mySet do append a i
	append a obj
	selectionSets[mySetName] = a
	return undefined
	)

fn sLibCopyAndPasteSelectionSetsFromNodeToNode copyObj pasteObj = 
	(
	sets = sLibGetSelectionSetsByNode copyObj
	for s in sets do
		(
		sLibAddToSelectionSet s pasteObj
		)
	return undefined
	)

fn sLibGetSceneSelectionSetsNames = 
	(
	a = #()
	sSNum = getNumNamedSelSets()
	if sSNum != 0 then
		(
		for i = 1 to sSNum do
			(
			append a (getNamedSelSetName i)
			)
		)
	return a
	)

fn sLibGetSelectionSetsByNode obj = 
	(
	sSets = #()
	sSNum = getNumNamedSelSets()
	if sSNum != 0 then
		(
		for i = 1 to sSNum do
			(
			ItemNum = getNamedSelSetItemCount i
			if ItemNum != 0 then
				(
				for j = 1 to ItemNum do
					(
					if obj == (getNamedSelSetItem i j) then append sSets (getNamedSelSetName i)
					)
				)
			)
		)
	return sSets
	)

-------------------------------------------------------------------------------
-- Software Tests
-------------------------------------------------------------------------------

fn sLibBrazil1Test = 
	(
	result = false
	try (result = ((BzVersion())[1] == 1))
	catch ()
	return result
	)
	
fn sLibBrazil2Test = 
	(
	return (Brazil_Main_Renderer != undefined)
	)
	
fn sLibVrayTest = 
	(
	return (doVRayObjectProperties != undefined)	
	)

fn sLibCameraMapGeminiMapTest =
	(
	disableSceneRedraw()
	result = true
	s = for obj in selection collect obj
	try
		(
		testSphere = Sphere radius:10 pos:[0,0,0] isSelected:on
		addmodifier $ (CameraMapGeminiModifier ())
		)
	catch	
		(
		result = false
		)
	delete testSphere
	if s != #() then select s
	
	enableSceneRedraw()
	completeRedraw()

	return result	
	)

fn sLibMaxVer = 
	(
	return (maxVersion())[1] / 1000.0
	)

fn sLibSplineMesherTest = 
	(
	disableSceneRedraw()
	result = true
	s = for obj in selection collect obj
	try
		(
		testLine = Circle radius:10 pos:[0,0,0] isSelected:on
		addmodifier $ (SplineMesher ())
		)
	catch	
		(
		result = false
		)
	delete testLine
	if s != #() then select s
	
	enableSceneRedraw()
	completeRedraw()

	return result
	)
	
fn sLibWhatsCurrentRenderer = 
	(
	result = ""
	if sLibCompareArrays renderers.current.classid #(1, 0) then result = "Scanline"
	else if sLibCompareArrays renderers.current.classid #(1387076610, 288174012) then result = "Brazil1"
	else if sLibCompareArrays renderers.current.classid #(95494396, 474502030) then result = "Brazil2"
	else if sLibCompareArrays renderers.current.classid #(1492548972, 1338981315) then result = "mentalray"
	else if sLibCompareArrays renderers.current.classid #(1941615238, 2012806412) then result = "vray"
	else if sLibCompareArrays renderers.current.classid #(1655201228, 1379677700) then result = "Corona"
	return result
	)
	
-------------------------------------------------------------------------------
-- SoulburnScripts
-------------------------------------------------------------------------------

fn sLibSSPrintHelp myscript = 
	(
	myfile = ((getdir #scripts) + "\\SoulburnScripts\\scripts\\" + myscript + ".ms")
	aDesc = sLibSSFindTextFragment "-- Description:" myfile
	aTut = sLibSSFindTextFragment "-- Tutorial:" myfile
	aIssues = sLibSSFindTextFragment "-- Known Issues:" myfile
	mainText = ""
	if aDesc.count != 0 then
		(
		for i in aDesc do
			(
			newi = substring i 4 (i.count - 3)
			mainText += newi
			mainText += "\n"
			)
		)
	if aTut.count != 0 then
		(
		mainText += "\n"
		for i in aTut do
			(
			newi = substring i 4 (i.count - 3)
			mainText += newi
			mainText += "\n"
			)
		)		
	if aIssues.count != 0 then
		(
		mainText += "\n"
		for i in aIssues do
			(
			newi = substring i 4 (i.count - 3)
			mainText += newi
			mainText += "\n"
			)
		)
	mainTitle = "Help For " + (getFilenameFile myfile)
	MessageBox mainText title:mainTitle
	return undefined
	)

fn sLibSSFindTextFragment whichFrag myfile = 
	(
	aBuild = #()
	aFinal = #()
	if openFile myfile != undefined then
		(
		myfileOpen = openFile myfile
		numlines = sLibGetLengthOfFile myfile
		if numlines != 0 then
			(
			for i = 1 to numlines do
				(
				inputdata = readLine myfileOpen
				if inputdata == whichFrag then
					(
					aFinal = #(inputdata)
					join aFinal (sLibSSGetTextFragment myfileOpen aBuild)
					exit
					)
				)
			)
		close myfileOpen
		)
	return aFinal
	)
	
fn sLibSSGetTextFragment myfileOpen a = 
	(
	inputdata = undefined
	while inputdata != "-------------------------------------------------------------------------------" do
		(
		if inputdata != undefined then append a inputdata
		inputdata = readLine myfileOpen
		)
	return a
	)

-------------------------------------------------------------------------------
-- Strings
-------------------------------------------------------------------------------

fn sLibCompareCaseInsensitive s1 s2 = 
	(
	if (sLibMakeStringLowercase s1) < (sLibMakeStringLowercase s2) then return -1
	else if (sLibMakeStringLowercase s1) > (sLibMakeStringLowercase s2) then return 1
	else return 0
	)

fn sLibCompareCaseSensitive s1 s2 = 
	(
	if s1 < s2 then return -1
	else if s1 > s2 then return 1
	else return 0
	)

fn sLibFileNameCompareCaseSensitive s1 s2 = 
	(
	if sLibFilenameFromPath s1 < sLibFilenameFromPath s2 then return -1
	else if sLibFilenameFromPath s1 > sLibFilenameFromPath s2 then return 1
	else return 0	
	)

fn sLibFindAndReplaceInString s1 f r = 
	(
	InsertPoint = findString s1 f
	if InsertPoint != undefined then return (replace s1 InsertPoint f.count r)
	else return s1
	)

fn sLibMakeStringLowercase s1 =
	(
	upper = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
	lower = "abcdefghijklmnopqrstuvwxyz" 
	s2 = copy s1
	for i = 1 to s2.count do 
		(
		j = findString upper s2[i]
		if (j != undefined) do s2[i] = lower[j]
		)
	return s2
	)
	
fn sLibMakeStringUppercase s1 =
	(
	upper = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
	lower = "abcdefghijklmnopqrstuvwxyz" 
	s2 = copy s1
	for i = 1 to s2.count do 
		(
		j = findString lower s2[i]
		if (j != undefined) do s2[i] = upper[j]
		)
	return s2
	)
	
fn sLibNameCompareCaseInsensitive s1 s2 = 
	(
	if (sLibMakeStringLowercase s1.name) < (sLibMakeStringLowercase s2.name) then return -1
	else if (sLibMakeStringLowercase s1.name) > (sLibMakeStringLowercase s2.name) then return 1
	else return 0
	)

fn sLibNameCompareCaseSensitive s1 s2 = 
	(
	if s1.name < s2.name then return -1
	else if s1.name > s2.name then return 1
	else return 0
	)
	
fn sLibPadValue n pad =
	(
	local a = (n as string)
	for w = 1 to 99999 do
		(
		if a.count < pad then a = "0" + a
		else exit
		)
	return a
	)

fn sLibRemoveTailNumbers s =
	(
	result = s
	s2 = (sLibReverseString s)
	if s2.count != 0 then
		(
		nums = "01234567890" 
		for i = 1 to s2.count do
			(
			j = findString nums s2[i]
			if (j == undefined) do 
				(
				newS = sLibReverseString (substring s2 i s2.count)
				return newS
				)
			)
		)
	return s
	)
	
fn sLibReverseString s =
	(
	newS = ""
	if s.count != 0 then
		(
		for i = s.count to 1 by -1 do newS += s[i]
		)
	return newS
	)
	
-------------------------------------------------------------------------------
-- Transforms
-------------------------------------------------------------------------------

-- Code thanks To Larry Minton
fn sLibResetXForm obj = 
	(
	local ntm = obj.transform
	obj.transform=transMatrix obj.pos
	local piv=obj.objecttransform * inverse obj.transform
	obj.objectoffsetPos  = [0,0,0]
	obj.objectoffsetRot = (quat 0 0 0 1)
	obj.objectoffsetScale = [1,1,1]
	ntm.translation=[0,0,0]
	ntm = piv * ntm
	local xformMod=xform()
	addmodifier obj xformMod
	xformMod.gizmo.transform=ntm
	xformMod.name = "Reset Xform"
	return obj
	)

fn sLibRotateObjByAxis obj rot =  
	(
	-- borrowed from the maxscript help file
	local axis
	local objA = if classof obj == objectSet or classof obj == array then obj else #(obj)
	if getCoordCenter() != #local then
		(
		axis = getTransformAxis objA[1] 0
		for obj1 in objA do in coordsys axis about axis rotate obj1 rot
		)
	else
		(
		for obj1 in objA do
			(
			axis = getTransformAxis obj1 0
			in coordsys axis about axis rotate obj1 rot
			)
		)
	return obj
	)
	
-------------------------------------------------------------------------------
-- Values
-------------------------------------------------------------------------------

fn sLibRandomWithBias a b bias = 
	(
	a1 = a as float
	b1 = b as float
	randomNum = random 0.0 1.0
	--value = pow randomNum ((log bias)/(log 0.5))
	value = randomNum/((1/bias-2)*(1-randomNum)+1)
	remap = ((value)*(b1-a1)) + a1
	return remap
	)
	
-------------------------------------------------------------------------------
-- Initialization End
-------------------------------------------------------------------------------
Print "sLib v 1.50 has been loaded"
sLibInit = true
)
-------------------------------------------------------------------------------