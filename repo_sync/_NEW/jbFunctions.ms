---------------------------------------------------------------------
-- jbFunctions.ms
--
-- copyright 1999-2001            John Burnett, foo@footools.com
---------------------------------------------------------------------
-- INSTALLATION:
-- Simply place this file in one of your Max plugin paths (i.e.
-- "c:\3dsmax4\plugins\") and restart Max.
--
-- This script only contains support functions for other scripts,
-- and does nothing useful in and of itself.
---------------------------------------------------------------------
-- REQUIRED PLUGINS:
-- avg_dlx.dlx
---------------------------------------------------------------------
-- DISCLAIMER AND DISTRIBUTION:
--
-- This script is provided as FREEWARE, and cannot be sold. This
-- script cannot be bundled with any commercial package without
-- express written permission from the author.  You MAY distribute
-- this script provided that it is complete with all files in the
-- original archive, and no profit is made from the distribution.
--
-- You MAY take portions of this script and include them in your
-- own script.  Credit to the original author would be appreciated.
--
-- While this script has been used heavily in a production environment,
-- and should be reasonably bug free, there may (read: ARE) still be
-- bugs present.  By using this product, you agree to exempt the author
-- from any responsibility for the damages your computer or your data
-- may incur through the use of this script.
--
-- This is an unsupported product so use it at your own risk!
--
-- Lastly, suggestions and bug reports are welcome.  Please use the
-- contact info above.
---------------------------------------------------------------------
 
---------------------------------------------------------------------
-- All available functions are declared here at the top.
---------------------------------------------------------------------
 
fn jbFunctionsCurrentVersion = (
	-- slight workaround for R4.0 bug
	(18 - 0)
)
 
-- Check that required extensions are installed.  Takes an array of arrays, where
-- each array has two elements: the extension name, and the required version.
-- Returns true if all required extensions are installed, otherwise false.
fn jbFunctionsVersionCheck vers =
(
--#("3dsmax 3.1",0) -- force 3.1, exclude 4.0
--#("jbFunctions",)
--#("jbLib",)
--#("avg_dlx",2.09)
--#("ctrlLib",2.2)
--#("mouseTrack",0)
--#("bind",0)
--#("ish_MorpherCtrl",0)
	local resAr = for ver in vers collect
	(
		case ver[1] of (
			"3dsmax 3.1": ( try (((MaxVersion())[1] == 3100)) catch (FALSE) )
			"jbFunctions": ( try (ver[2] <= jbFunctionsCurrentVersion()) catch (FALSE) )
			"jbLib": ( try (ver[2] <= jbLibVersion) catch (FALSE) )
			"avg_dlx": ( try (((MaxVersion())[1] >= 4000) OR ver[2] <= (avguard_dlx_ver as float)) catch (FALSE) )
			"ctrlLib": ( try (((MaxVersion())[1] >= 4000) OR ver[2] <= ctrllib.version) catch (FALSE) )
			"mouseTrack": ( try (mouseTrack != undefined) catch (FALSE) )
			"bind": ( try (bindOps != undefined) catch (FALSE) )
			"ish_MorpherCtrl": ( try (IsValidMorpherMod != undefined) catch (FALSE) )
			default: ( FALSE )
		)
	)
 
	local failed = FALSE
	local str = "The following required extensions are not installed or are out of date:\n\n"
	for i in 1 to resAr.count where NOT resAr[i] do
	(
		failed = TRUE
		str += (vers[i][1] + "\n")
	)
 
	if failed then (
		str += "\nYou can get the latest versions at http://www.footools.com/.\n\nWould you like to connect there now?"
		if (QueryBox str title:"Error") then ( try (ShellLaunch "http://www.footools.com/" "") catch () )
		return FALSE
	)
 
	TRUE
)
 
-- Array Declarations -----------------------------------------------
global \
BitFirstSet,
BitHasSet,
BitNumberSet,
DeleteItems,
GetArrayValue,
GetNormArrayValue,
InsertAfter,
ItemFound,
MaxValueIndex,
MinValueIndex,
ReverseArray,
ScaleArray,
ScrambleArray,
TrimDuplicates
 
-- Atmospherics And Effects Declarations ----------------------------
global \
PopAtmosphericNames,
PopEffectNames,
PopSpecialFXNames,
PushAtmosphericNames,
PushEffectNames,
PushSpecialFXNames
 
-- BitmapAndColor Declarations --------------------------------------
global \
ClampColor,
DrawCrosshair,
GetCroppedBitmap,
GetHue,
HSVtoRGB,
InvertColor,
Noise3bmp,
Noise4bmp,
OpenBitmapNoGamma
 
-- BFDtools Declarations --------------------------------------------
global BFDtool, _BFDman, BFDman
 
-- Controller Declarations ------------------------------------------
global \
GetAnimatedSubAnims,
GetControllers
 
-- File Declarations ------------------------------------------------
global \
FileExists,
FixFilename,
GetIFLfiles,
GetParentDir,
GetSequenceFilenameBase,
GetSequences,
GetSubDirs,
IsBitmapFile,
IsFileCreateNewer,
IsFileModNewer,
IsFileType,
IsSequenceFile,
IsUNCpath,
IsValidFilename,
MakeIFL,
SortINISection
 
-- FuncAlias Declarations -------------------------------------------
global \
co,
sco,
gpn,
sp,
spm,
spv,
spmv
 
-- Hierarchy Declarations -------------------------------------------
global \
CopyHierarchy,
DupHierarchy,
GetChildren,
GetDepth,
GetHierarchy,
GetHierarchyRoot,
GetParentChain,
InstanceHierarchy,
ReferenceHierarchy,
SafeDelete
 
-- Material Declarations --------------------------------------------
global \
DeleteUnusedSubMaterials,
GetBitmapTextures,
GetObjectMaterials,
GetObjectStandardMaterials,
GetStandardSubMaterials,
GetSubMaterials,
GetSubTextures,
GetUsedMatIDs,
ReduceSubMaterials,
RemapMeshMaterials
 
-- Math Declarations ------------------------------------------------
global \
Bias,
ClampPnt2,
fMin,
fMax,
fClamp,
Gain,
GetClosestPoints,
Round,
Smoothstep
 
-- Mesh Declarations ------------------------------------------------
global \
BuildQuad,
CleanIsoVerts,
DetachMeshFaces,
ExplodeMeshElements,
GetAllMeshElements,
GetAllPolygons,
GetAllPolygonsProgress,
GetClosestVert,
GetFaceAsArray,
GetFacesByNormal,
GetMeshElement,
GetVertFaceCache,
MeshOKtoModify
 
-- Miscellaneous Declarations ---------------------------------------
global \
GetClassTree,
PrintClassTree
 
-- Modifier Declarations --------------------------------------------
global \
GetAllModifiers,
GetModifiersOfClass
 
-- Object Declarations ----------------------------------------------
global \
CopyNodeProps,
DupNodeProps,
GetBipedObjects,
GetInstances,
InstanceNodeProps,
IsBipedObject,
IsInstance,
ObjectExists,
SelectAndShow,
TrimInvalidObjects
 
-- Spline Declarations ----------------------------------------------
global \
AverageShapes,
BuildSpline,
CreateSplineFromArray,
DetachSpline,
ExplodeShape,
GetRequiredSteps,
GetShapeRoots,
KnotLengthParam,
ShapeToRibbon,
ShapeToString,
SmoothShape
 
-- String Declarations ----------------------------------------------
global \
Capitalize,
ColumnFormat,
DateAsPoint3,
DateAsSeconds,
DoubleSlash,
FindString2,
GetPadNum,
GetTag,
GetValidFilename,
IsCharInt,
PrintColor,
ReplaceTags,
SearchReplace,
SnipString,
StringCount,
ToLower2,
ToUpper2,
Trunc
 
-- System Declarations ----------------------------------------------
global \
GetDriveFreeSpace,
GetProcessorName,
GetSysInfo,
GetSysInfoFromFile,
GetSysInfoPhysicalMemory,
GetSysInfoProcessors,
MakeSysInfoFile,
PrintMachineStats,
ServerInfo,
ServerStats
 
-- Time Declarations ------------------------------------------------
global \
GetCurrentMilitaryTime,
GetFormattedTime,
IsDateNewer,
LapTimer,
TimeIt
 
-- UI Declarations --------------------------------------------------
global \
IntersectPickPoint,
PopCommandPanelTaskMode,
PushCommandPanelTaskMode,
ValidListboxSel
 
 
---------------------------------------------------------------------
---------------------------------------------------------------------
---------------------------------------------------------------------
-- All functions are defined below.
---------------------------------------------------------------------
---------------------------------------------------------------------
---------------------------------------------------------------------
 
 
---------------------------------------------------------------------
-- Array Definitions
---------------------------------------------------------------------
 
fn ScrambleArray anArray passes:1 lowerBound:1 upperBound:-1 seedVal:1 = (
	-- make the bounds floats (workaround for silly random() bug)
	local lBound = lowerBound as float
	local uBound
	if (upperBound == -1) then (
		uBound = anArray.count as float
	) else (
		uBound = upperBound as float
	)
 
	seed seedVal
 
	local targIdx
	for i in 1 to passes do (
		for srcIdx in lBound to uBound do (
			do (targIdx = random lBound uBound) while (targIdx == srcIdx)
			swap anArray[srcIdx] anArray[targIdx]
		)
	)
 
	anArray
)
 
fn InsertAfter anArray item idx = (
	if (idx >= 1) AND (idx <= anArray.count) then (
		append anArray item
		for i in anArray.count to (idx+2) by -1 do (
			swap anArray[i] anArray[i-1]
		)
		true
	)
	false
)
 
fn ReverseArray anArray = (
	for i in 1 to (anArray.count/2) do (
		swap anArray[i] anArray[(anArray.count-(i-1))]
	)
 
	anArray
)
 
fn TrimDuplicates anArray = (
	local idx
	for i in anArray.count to 1 by -1 do (
		idx = findItem anArray anArray[i]
		if (idx != 0) AND (idx != i) do deleteItem anArray i
	)
 
	anArray
)
 
fn ItemFound anArray anItem = (
	((findItem anArray anItem) != 0)
)
 
fn DeleteItems anArray ba = (
	if ba.count != anArray.count then (
		false
	) else (
		for i in ba.count to 1 do (
			deleteItem anArray i
		)
		true
	)
)
 
fn GetArrayValue anArray f = (
	if (f <= 1) then (
		anArray[1]
	) else if (f >= anArray.count) then (
		anArray[anArray.count]
	) else (
		local perc = f - (f as integer)
		if (0.0 == perc) then (
			anArray[f]
		) else (
			local a = anArray[f]
			local b = anArray[f+1]
			((1-perc)*a) + (perc*b)
		)
	)
)
 
fn GetNormArrayValue anArray nf = (
	GetArrayValue anArray (nf * (anArray.count-1) + 1)
)
 
fn ScaleArray anArray newCount = (
	local newArray = #()
	newArray.count = newCount
 
	for i in 1 to newCount do (
		newArray[i] = GetNormArrayValue anArray ((i-1.0)/(newCount-1))
	)
 
	newArray
)
 
fn MinValueIndex anArray = (
	local minVal = anArray[1]
	local idx = 1
	for i in 2 to anArray.count do (
		if anArray[i] < minVal then (
			minVal = anArray[i]
			idx = i
		)
	)
	idx
)
 
fn MaxValueIndex anArray = (
	local maxVal = anArray[1]
	local idx = 1
	for i in 2 to anArray.count do (
		if anArray[i] > maxVal then (
			maxVal = anArray[i]
			idx = i
		)
	)
	idx
)
 
fn BitNumberSet bitAr = (
	local cnt = 0
	for i in bitAr do cnt += 1
	cnt
)
 
fn BitFirstSet bitAr = (
	for i in bitAr do return i
	0
)
 
fn BitHasSet bitar = (
	for i in 1 to bitar.count do if bitar[i] do return TRUE
	FALSE
)
 
---------------------------------------------------------------------
-- Atmospherics And Effects Definitions
---------------------------------------------------------------------
 
-- Don't use the following two functions directly -------------------
fn _PushSpecialFXNames GetSFX sfxCount sfxStack =
(
	try (
		local nameArray = for i in 1 to sfxCount collect (GetSFX i).name
		Append sfxStack nameArray
 
		TRUE
	) catch ( FALSE )
)
 
fn _PopSpecialFXNames GetSFX sfxCount sfxStack =
(
	try (
		local curIdx = sfxStack.count
		if (curIdx == 0) then return FALSE
 
		local savedCnt = sfxStack[curIdx].count
		local maxCnt = if (sfxCount > savedCnt) then savedCnt else sfxCount
 
		for	i in 1 to maxCnt do (
			(GetSFX i).name = sfxStack[curIdx][i]
		)
		DeleteItem sfxStack curIdx
 
		TRUE
	) catch ( FALSE )
)
-- Don't use the above two functions directly -----------------------
 
global jbSavedAtmosphericNameStack = #()
global jbSavedEffectsNameStack = #()
 
fn SaveAtmosphericNames =
(
	_PushSpecialFXNames GetAtmospheric numAtmospherics jbSavedAtmosphericNameStack
)
fn RestoreAtmosphericNames =
(
	_PopSpecialFXNames GetAtmospheric numAtmospherics jbSavedAtmosphericNameStack
)
 
fn SaveEffectNames =
(
	_PushSpecialFXNames GetEffect numEffects jbSavedEffectsNameStack
)
fn RestoreEffectNames =
(
	_PopSpecialFXNames GetEffect numEffects jbSavedEffectsNameStack
)
 
fn SaveSpecialFXNames =
(
	(SaveAtmosphericNames() AND SaveEffectNames())
)
fn RestoreSpecialFXNames =
(
	(RestoreAtmosphericNames() AND RestoreEffectNames())
)
 
---------------------------------------------------------------------
-- BitmapAndColor Definitions
---------------------------------------------------------------------
 
fn Noise3bmp resX resY scale =
(
	local bmp = Bitmap resX resY
	local s = 1./scale
	local dx = s / resX
	local dy = s / resY
	local row = 0
	local buf
	for y in dy to s by dy do
	(
		buf = for x in dx to s by dx collect (
			white * (((Noise3 [x,y,0]) + 1.0) * 0.5)
		)
 
		SetPixels bmp [0,row] buf
		row += 1
	)
 
	bmp
)
 
fn Noise4bmp resX resY scale phase =
(
	local bmp = Bitmap resX resY
	local s = 1./scale
	local dx = s / resX
	local dy = s / resY
	local row = 0
	local buf
	for y in dy to s by dy do
	(
		buf = for x in dx to s by dx collect (
			white * (((Noise4 [x,y,0] phase) + 1.0) * 0.5)
		)
 
		SetPixels bmp [0,row] buf
		row += 1
	)
 
	bmp
)
 
mapped fn ClampColor col = (
	col.r = if col.r > 255 then 255 else if col.r < 0 then 0 else col.r
	col.g = if col.g > 255 then 255 else if col.g < 0 then 0 else col.g
	col.b = if col.b > 255 then 255 else if col.b < 0 then 0 else col.b
	col.a = if col.a > 255 then 255 else if col.a < 0 then 0 else col.a
 
	col
)
 
-- backwards compatibility
ClampCol = ClampColor
 
fn InvertColor col = (
	color (abs (col.r-255)) (abs (col.g-255)) (abs (col.b-255))
)
 
fn OpenBitmapNoGamma str = (
	local bmp, bmpNoGamma, row
	try (
		bmp = openBitmap str
		bmpNoGamma = bitmap bmp.width bmp.height	\
							filename:bmp.filename	\
							gamma:1.0				\
							pixelAspect:bmp.aspect
		for y = 0 to (bmp.height-1) do (
			row = getPixels bmp [0,y] bmp.width
			setPixels bmpNoGamma [0,y] row
		)
		return bmpNoGamma
	) catch (
		return undefined
	)
)
 
fn GetHue hue = (
	hue = if (hue < 0) then 0. else if (hue > 1) then 1. else (hue as float)
	local col = case of (
		(hue <= 0.166667): (
			[1, (hue/0.166667), 0]
		)
		(hue <= 0.333333): (
			[(1.-((hue-0.166667)/0.166667)), 1, 0]
		)
		(hue <= 0.5): (
			[0, 1, ((hue-0.333333)/0.166667)]
		)
		(hue <= 0.666667): (
			[0, (1.-((hue-0.5)/0.166667)), 1]
		)
		(hue <= 0.833333): (
			[((hue-0.666667)/0.166667), 0, 1]
		)
		(hue <= (1.)): (
			[1, 0, (1.-((hue-0.833333)/0.166667))]
		)
	)
	col *= 255
	col = clampColor (col as color)
	col.alpha = 255
 
	col
)
 
fn HSVtoRGB hue sat val = (
	local col = getHue hue
	col *= val
	col = (col * (1.-sat) + (col.value * sat))
	col.alpha = 255
 
	col
)
 
fn DrawCrosshair bmp nCrossPos crossSize:10 = (
 
	crossPos = [(bmp.width-1),(bmp.height-1)] * nCrossPos
 
	local halfCross = crossSize/2
	hLine = [crossPos.x-halfCross,crossPos.x+halfCross]
	vLine = [crossPos.y-halfCross,crossPos.y+halfCross]
	hLine = ClampPnt2 hLine 0 (bmp.width-1)
	vLine = ClampPnt2 vLine 0 (bmp.height-1)
 
	local crossColor
	-- draw top horizontal line
	if (vLine.x >= 0) AND (vLine.x < bmp.height) then (
		for x in hLine.x to hLine.y do (
			crossColor = InvertColor (getPixels bmp [x,vLine.x] 1)[1]
			setPixels bmp [x,vLine.x] #(crossColor)
		)
	)
	-- draw middle horizontal line
	if (crossPos.y >= 0) AND (crossPos.y < bmp.height) then (
		for x in hLine.x to hLine.y do (
			crossColor = InvertColor (getPixels bmp [x,crossPos.y] 1)[1]
			setPixels bmp [x,crossPos.y] #(crossColor)
		)
	)
	-- draw lower horizontal line
	if (vLine.y >= 0) AND (vLine.y < bmp.height) then (
		for x in hLine.x to hLine.y do (
			crossColor = InvertColor (getPixels bmp [x,vLine.y] 1)[1]
			setPixels bmp [x,vLine.y] #(crossColor)
		)
	)
	-- draw left vertical line
	if (hLine.x >= 0) AND (hLine.x < bmp.width) then (
		for y in vLine.x to vLine.y do (
			crossColor = InvertColor (getPixels bmp [hLine.x,y] 1)[1]
			setPixels bmp [hLine.x,y] #(crossColor)
		)
	)
	-- draw middle vertical line
	if (crossPos.x >= 0) AND (crossPos.x < bmp.width) then (
		for y in vLine.x to vLine.y do (
			crossColor = InvertColor (getPixels bmp [crossPos.x,y] 1)[1]
			setPixels bmp [crossPos.x,y] #(crossColor)
		)
	)
	-- draw right vertical line
	if (hLine.y >= 0) AND (hLine.y < bmp.width) then (
		for y in vLine.x to vLine.y do (
			crossColor = InvertColor (getPixels bmp [hLine.y,y] 1)[1]
			setPixels bmp [hLine.y,y] #(crossColor)
		)
	)
 
	bmp
)
 
fn GetCroppedBitmap bmp tl br =
(
	if (tl.x >= 0 AND tl.x <= br.x AND
		tl.y >= 0 AND tl.y <= br.y AND
		br.x < bmp.width AND br.y < bmp.height) then
	(
		local w = br.x - tl.x + 1
		local h = br.y - tl.y + 1
		local newBmp = bitmap w h
		local thisY = 0
		for y in tl.y to br.y do
		(
			local row = GetPixels bmp [tl.x, y] w
			SetPixels newBmp [0,thisY] row
			thisY += 1
		)
		return newBmp
	) else (
		return undefined
	)
)
 
---------------------------------------------------------------------
-- BFDtools Definitions
---------------------------------------------------------------------
 
------------------------------------------------------------------------------------
-- Contents:
--		struct BFDtool - A struct containing the definition of any BFDtool
--		struct _BFDman - A struct containing the definition for the global
--						"BFDman" instance, which manages any BFDtools
--
-- History:
--		11.1.1999 - Created (or there abouts)
--		4.12.2000 - If version is increased, floater geometry isn't loaded from INI
------------------------------------------------------------------------------------
 
------------------------------------------------------------------------------------
--BFDtool structure
------------------------------------------------------------------------------------
--BFDtool Variables:
--	listed in the form:
--	variableName (variable type, default value)
------------------------------------------------------------------------------------
--	toolName (string, undefined)
--		This is the only variable you MUST define for each tool.  It should be a
--		unique, identifying name, since it's used to both identify the tool
--		internally, and as the tool's floater name.  It should be short	and simple,
--		and remain constant between different versions of the tool.
--		(i.e. use "particleTrack", and NOT "The Particle Tracker, v1.53")
--	author (string, "unsupplied")
--		Name of the tool's author
--	createDate (point3, [yyyy,mm,dd])
--		Date the tool was initially created, in [month,day,year] format.
--		Note: Use full four digit year (1999 instead of 99)
--	modifyDate (point3, [yyyy,mm,dd])
--		Date the tool was last modified.  Update every time you change the version.
--	version (integer, 1)
--		Version of the tool.  Increase by 1 EVERY time you change something.
--	defFloaterSize (point2, [250,250])
--		Default size of the floater
--	defFloaterPos (point2, undefined)
--		Default position of the floater.  If undefined, the floater will be centered.
--	autoLoadRolloutStates (bool, true)
--		Whether to automatically save/load the rollout states on open and close
--	autoLoadFloaterSize (bool, true)
--		Whether to automatically save/load the rollout size on open and close
--	ops (array, #())
--		Array of script variables
------------------------------------------------------------------------------------
--BFDtool Functions:
------------------------------------------------------------------------------------
--	getFloater
--		returns the tool's floater, undefined if it doesn't exist right now
--	getINIFilename
--		INI file to save info to, defaults to ".\plugcfg\BFDtools.ini"
--	setINIFilename
--		Sets the INI file to save info to
--	addRoll r rolledUp:false
--		Add rollout r to list of rollouts to be added to floater
--		r can be an array of rollouts or just a single rollout
--		The optional rolledUp parameter controls the state of the rollout
--		when it's added.  It can be a single boolean or an array as well.
--	delRoll i
--		Remove rollout at index i from list of rollouts
--		If i == 0, the all rollouts are removed
--	getRoll i
--		Returns the i'th rollout
--	numRolls
--		Returns the number of current rollouts
--	openTool
--		Create floater of default size, add rollouts, restore saved geometry
--	closeTool
--		Close floater, save geometry
--	saveFloaterGeom/loadFloaterGeom
--		Save/Load floater geometry to current INI file
--		This is done automatically on openTool/closeTool
--	saveRolloutStates/loadRolloutStates
--		Save/Load the rollout position and open/close states of the current
--		rollouts to INI file
--		if autoLoadRolloutStates == true then this is done automatically on
--		openTool/closeTool
--	updateUI rollIdx
--		Calls a function named "updateUI" in rollout index rollIdx
--		Passing 0 is equivalent to calling updateAllUI()
--	updateAllUI
--		Calls "updateUI" in all rollouts
--	getFloaterSize / setFloaterSize point2
--		Gets and sets the size of the floater
------------------------------------------------------------------------------------
struct BFDtool (
	-- Public
	toolName = undefined,
	author = "unsupplied",
	createDate = [0,0,0],
	modifyDate = [0,0,0],
	version = 1,
	defFloaterSize = [250,250],
	defFloaterPos = undefined,
	version = 1,
	autoLoadRolloutStates = true,
	autoLoadFloaterSize = true,
	ops = #(),
	------------------------------------------------------------------------------------------
	-- Start Private stuff, subject to change at any time.  Don't rely on this.
	------------------------------------------------------------------------------------------
	floater = undefined,
	rollouts = #(),
	rolloutRolledUp = #(),
	-- floaterClosing is used in case closeTool is called multiple times while a
	-- floater is closing (which happens if it's in the close handler of multiple rollouts
	-- ...prevents nasty recursive infinite loops.
	floaterClosing = false,
	-- Should be undefined, unless it's over-riden by a call to setINIFilename
	INIFilename = undefined,
	------------------------------------------------------------------------------------------
	-- End Private stuff
	------------------------------------------------------------------------------------------
	fn updateUI rollIdx = (
		if rollIdx == 0 then (
			for i in 1 to rollouts.count do try (rollouts[i].updateUI()) catch ()
		) else (
			if (rollIdx >= 1) AND (rollIdx <= rollouts.count) then (
				try (rollouts[rollIdx].updateUI()) catch ()
			)
		)
	),
	fn updateAllUI = (
		updateUI 0
	),
	fn getFloater = (
		return floater
	),
	fn getINIFilename = (
		if INIFilename == undefined then (
			return (GetDir #plugcfg + "\\BFDtools.ini")
		) else (
			return INIFilename
		)
	),
	fn setINIFilename str = (
		-- TODO: Should do some more checking here
		INIFilename = str
		return true
	),
	fn addRoll r rolledUp:false = (
		try (
			if toolName == undefined then return false
 
			if classOf r != array then ( r = #(r) )
			if classOf rolledUp != array then ( rolledUp = #(rolledUp) )
 
			if rolledUp.count < r.count then (
				for i in (rolledUp.count+1) to r.count do (
					rolledUp[i] = rolledUp[i-1]
				)
			)
 
			for i in 1 to r.count do (
				if (findItem rollouts r[i]) == 0 then (
					append rollouts r[i]
					append rolloutRolledUp rolledUp[i]
 
					if floater != undefined then (
						addRollout r[i] floater rolledUp:rolledUp[i]
					)
				)
			)
		) catch ( return false )
	),
	fn delRoll idx = (
		try (
			local s, e
			if (idx == 0) then (
				s = rollouts.count
				e = 1
			) else (
				s = e = idx
			)
 
			for i in s to e by -1 do (
				removeRollout rollouts[i] floater
				deleteItem rollouts i
				deleteItem rolloutRolledUp i
			)
			return true
		) catch ( return false )
	),
	fn numRolls = (
		return rollouts.count
	),
	fn getRoll i = (
		if (i >= 1) AND (i <= rollouts.count) then return rollouts[i] else return undefined
	),
	fn saveToolVersion = (
		try (
			local res = setINISetting (getINIFilename()) toolName "Version" (version as string)
			return res
		) catch ( return false )
	),
	fn loadToolVersion = (
		try (
			local v = (getINISetting (getINIFilename()) toolname "Version") as integer
			if v != 0 then return v else return undefined
		) catch ( return undefined )
	),
	fn saveFloaterGeom = (
		if	(floater == undefined) OR (classOf floater != RolloutFloater) OR
			(toolName == undefined) OR (classOf toolName != String) then return false
 
		local res = TRUE
 
		res = res AND (setINISetting (getINIFilename()) toolName "Pos" (floater.pos as string))
		if autoLoadFloaterSize then (
			res = res AND (setINISetting (getINIFilename()) toolName "Size" (floater.size as string))
		)
 
		return res
	),
	fn loadFloaterGeom = (
		if	(floater == undefined) OR (classOf floater != RolloutFloater) OR
			(toolName == undefined) OR (classOf toolName != String) then return false
 
		local res = FALSE
 
		local tmp = execute (getINISetting (getINIFilename()) toolName "Pos")
		if (classOf tmp) == point2 then ( floater.pos = tmp ) else ( res = FALSE )
		if autoLoadFloaterSize AND (version == loadToolVersion()) then (
			tmp = execute (getINISetting (getINIFilename()) toolName "Size")
			if (classOf tmp) == point2 then ( floater.size = tmp ) else ( res = FALSE )
		)
 
		return res
	),
	fn saveRolloutStates = (
		try (
			local rollStates = #()
			for r in rollouts do append rollStates (NOT r.open)
			local sp = try ( rollouts[1].scrollPos ) catch ( 0 )
			if sp == undefined then sp = 0
 
			local res = ( setINISetting (getINIFilename()) toolName "RolloutRolledUp" (rollStates as string) ) AND
						( setINISetting (getINIFilename()) toolName "ScrollPos" (sp as string) )
			return res
		) catch ( return false )
	),
	fn loadRolloutStates = (
		try (
			local rollStates = execute (getINISetting (getINIFilename()) toolName "RolloutRolledUp")
			if rollStates == OK then (
				rollStates = rolloutRolledUp
				for i in 1 to rollStates do rollStates[i] = rollStates[i]
			)
			for i in 1 to rollouts.count do (
				local tmp = rollStates[i]
				if tmp == undefined then tmp = false
				rollouts[i].open = NOT tmp
			)
			rollouts[1].scrollPos = (getINISetting (getINIFilename()) toolName "ScrollPos") as integer
 
			return true
		) catch ( return false )
	),
	fn openTool this = (
		try (
			-- Maxscript Bug: copy of toolName must be made
			local str = toolName
			if str == undefined then return false
 
			if (BFDman.toolInUse str) then (
				BFDman.closeTool str
				return false
			) else (
				BFDman.addTool this
 
				if (defFloaterPos == undefined) OR (classOf defFloaterPos != point2) then (
					floater = newRolloutFloater toolName defFloaterSize.x defFloaterSize.y
				) else (
					floater = newRolloutFloater toolName defFloaterSize.x defFloaterSize.y defFloaterPos.x defFloaterPos.y
				)
 
				loadFloaterGeom()
				for i in 1 to rollouts.count do (
					addRollout rollouts[i] floater rolledUp:rolloutRolledUp[i]
				)
				if autoLoadRolloutStates then loadRolloutStates()
				floaterClosing = false
 
				return true
			)
		) catch ( return false )
	),
	fn closeTool = (
		try (
			if NOT floaterClosing then (
				-- Maxscript Bug: copy of toolName must be made
				local str = toolName
				BFDman.delTool str
 
				saveFloaterGeom()
				saveToolVersion()
				if autoLoadRolloutStates then saveRolloutStates()
				floaterClosing = true
				try ( closeRolloutFloater floater ) catch ()
			)
 
			return true
		) catch ( return false )
	),
	fn getFloaterSize = (
		local f = getFloater()
		if f != undefined then (
			return f.size
		) else (
			return undefined
		)
	),
	fn setFloaterSize fSize = (
		local f = getFloater()
		if f != undefined then (
			try ( f.size = fSize ) catch ( return false )
			return true
		) else (
			return false
		)
	)
--	fn saveSettings = (
--		saveFloaterGeom()
--
--		setINISetting INIFile toolName "VERSION" (version as string)
--		for i in 1 to ops.count do (
--			--Do a massive case here to convert values to strings
--			try (
--				setINISetting INIFile toolName (i as string) (ops[i] as string)
--			) catch ()
--		)
--	),
--	fn loadSettings = (
--		loadFloaterGeom()
--	)
)
 
------------------------------------------------------------------------------------
--global _BFDman structure
------------------------------------------------------------------------------------
--Variables:
------------------------------------------------------------------------------------
--	version (integer, 2)
--		current version of BFDtools core
--		version 1: initial version
--		version 2: usage tracking added
--	usageFile (string, "")
--		file to record usage information on tools as they are opened
--		if this a filename is supplied here, each time a tool is opened,
--		its name is recorded along with the number of times it has been opened.
------------------------------------------------------------------------------------
--Functions:
------------------------------------------------------------------------------------
--	getRoot
--		returns the current root of BFDtools
--	addTool aTool
--		add aTool to list of current tools
--	getTool param
--		get an active tool
--		param can be either a tool name or tool index
--	closeTool param
--		call the closeTool function on specified tool
--		param can be either a tool name or tool index
--	closeAllTools
--		call the closeTool function on all open tools
--	delTool param
--		remove tool from the list of active tools, without closing
--		param can be either a tool name or tool index
--	numTools
--		see how many tools are currently active
--	toolInUse toolName
--		check if a tool with the name "toolName" is currently active
--	getToolIndex param
--		returns the specified tool's index
--		param must be the tool's name
------------------------------------------------------------------------------------
struct _BFDman (
	--------------------------------------------------------------------------------
	-- Start Private stuff, subject to change at any time.  Don't rely on this.
	--------------------------------------------------------------------------------
	activeTools = #(),
	--------------------------------------------------------------------------------
	-- End Private stuff, subject to change at any time.  Don't rely on this.
	--------------------------------------------------------------------------------
	version = 2,
	usageFile = "",
	fn getToolIndex param = (
		case (classOf param) of (
			string: (
				local toolName = param
				for i in activeTools.count to 1 by -1 do (
					if activeTools[i].toolName == toolName then return i
				)
				return undefined
			)
		)
	),
	fn getTool param = (
		case (classOf param) of (
			integer: (
				local i = param
				if (i >= 1) AND (i <= activeTools.count) then (
					return activeTools[i]
				)
			)
			string: (
				local toolName = param
				local i = getToolIndex toolName
				if (i != undefined) then return activeTools[i]
			)
		)
		return undefined
	),
	fn toolInUse toolName = (
		if ((getTool toolName) == undefined) then return false else return true
	),
	fn addTool aTool = (
		if NOT (toolInUse aTool.toolName) then (
			append activeTools aTool
			if (usageFile != "") then (
				try (
					local cnt = try ((GetINISetting usageFile "Usage" aTool.toolName) as integer) catch (0)
					cnt += 1
					SetINISetting usageFile "Usage" aTool.toolName (cnt as string)
				) catch ()
			)
			return true
		) else ( return false )
	),
	fn delTool param = (
		case (classOf param) of (
			integer: (
				local i = param
				if (i <= activeTools.count) AND (i >= 1) then (
					deleteItem activeTools i
					return true
				)
			)
			string: (
				local toolName = param
				local idx = getToolIndex toolName
				if (delTool idx) then return true
			)
		)
		return false
	),
	fn numTools = (
		return activeTools.count
	),
	fn closeTool param = (
		local t = getTool param
		if t != undefined then (
			try (t.closeTool()) catch (return false)
			return true
		) else (
			return false
		)
	),
	fn closeAllTools = (
		for i in numTools() to 1 by -1 do closeTool i
	)
)
 
if (masterMaxDir != undefined) then
(
	BFDman = _BFDman usageFile:(masterMaxDir + "\\Logs\\BFDtoolsUsage.ini")
) else (
	BFDman = _BFDman()
)
 
---------------------------------------------------------------------
-- Controller Definitions
---------------------------------------------------------------------
 
fn GetControllers anim depth:-1 ctrlArray:undefined = (
	if ctrlArray == undefined then ctrlArray = #()
	if depth == 0 then return() else depth -= 1
 
	for i in 1 to anim.numSubs do (
		if	(anim[i].controller != undefined) AND
			(ClassOf anim[i].controller != undefined) then
		(
			append ctrlArray anim[i].controller
--			for i in depth to -3 do format "\t"
--			format "% : %\n" anim[i] anim[i].controller
		)
		GetControllers anim[i] depth:depth ctrlArray:ctrlArray
	)
 
	ctrlArray
)
 
fn GetAnimatedSubAnims anim depth:-1 saArray:undefined = (
	if saArray == undefined then saArray = #()
	if depth == 0 then return() else depth -= 1
 
	for i in 1 to anim.numSubs do (
		if	(anim[i].controller != undefined) AND
			(ClassOf anim[i].controller != undefined) then
		(
			append saArray anim[i]
--			for i in depth to -3 do format "\t"
--			format "%\n" anim[i]
		)
		GetAnimatedSubAnims anim[i] depth:depth saArray:saArray
	)
 
	saArray
)
 
---------------------------------------------------------------------
-- File Definitions
---------------------------------------------------------------------
 
fn FileExists fName = (
	(getFiles fName).count != 0
)
 
fn FixFilename fName = (
	local strArray = filterString fName "\\"
	local fixedName = if (isUNCpath fName) then "\\\\" else ""
	for i in 1 to (strArray.count-1) do fixedName += (strArray[i] + "\\")
	fixedName += strArray[strArray.count]
	return fixedName
)
 
fn GetIFLfiles IFLfile = (
	if (fileExists IFLfile) then (
		local f = openfile IFLfile
		local IFLpath = getFilenamePath IFLfile
		local files = #()
 
		while (true) do (
			if (eof f) then exit()
 
			local str = readLine f
			str = filenameFromPath str
			str = IFLpath + str
 
			if (fileExists str) do append files str
		)
 
		close f
		return files
	)
 
	return undefined
)
 
fn GetParentDir fName = (
	if (filenameFromPath fName) != "" do fName = getFilenamePath fName
	local strArray = filterString fName "\\"
	local pDir = if (isUNCpath fName) then "\\\\" else ""
	for i in 1 to (strArray.count-1) do pDir += (strArray[i] + "\\")
	return pDir
)
 
fn GetSequences fDir = (
	local seqArray = #()
	local fDirWild = fixFilename (fDir + "\\*.*")
	local fNames = getFiles fDirWild
 
	-- go through all files in dir
	while (fNames.count != 0) do (
		local fName = fNames[1]
		-- if file is part of sequence
		if (isSequenceFile fName) then (
			-- grab the sequence base name
			local seqBase =	(getFilenamePath fName) +
							(getSequenceFilenameBase fName) + "*" +
							(getFilenameType fName)
			-- get all files that are part of sequence (potential bug here)
			local seq = getFiles seqBase
			if (seq.count >= 2) then (
				sort seq
				-- add sequence to array of sequences
				append seqArray seq
 
				-- remove all files in found sequence from pool of names to check
				for seqName in seq do (
					local idx = findItem fNames seqName
					if (idx != 0) then deleteItem fNames idx
				)
			) else (
				deleteItem fNames 1
			)
		) else (
			-- remove fName from list of files to check
			deleteItem fNames 1
		)
	)
 
	return seqArray
)
 
fn GetSequenceFilenameBase fName = (
	local ints = #("0","1","2","3","4","5","6","7","8","9")
	local str = ""
	local baseName = fName
	fName = getFilenameFile fName
 
	local endIdx = fName.count
	local foundAlpha = false
 
	while (endIdx >= 2) AND NOT foundAlpha do (
		if ((findItem ints fName[endIdx]) != 0) then
			endIdx -= 1
		else
			foundAlpha = true
	)
 
	if	(endIdx >= 1) AND
		(endIdx != fName.count) do (
		baseName = subString fName 1 endIdx
	)
 
	return baseName
)
 
fn GetSubDirs fDir depth:-1 subDirs:undefined = (
	if subDirs == undefined then subDirs = #()
	if depth == 0 then return() else depth -= 1
 
	local dirs = getDirectories (fDir + "\\*")
	for i in 1 to dirs.count do dirs[i] = fixFilename dirs[i]
 
	for subDir in dirs do (
		append subDirs subDir
		getSubDirs subDir subDirs:subDirs depth:depth
	)
	return subDirs
)
 
fn IsBitmapFile fName = (
	try (
		close (openBitmap fName)
		return TRUE
	) catch (
		return FALSE
	)
)
 
fn IsFileType fName fType = (
	local n = (getFilenameType fName) as name
	n == (("." + fType) as name)
)
 
fn IsSequenceFile fName = (
	return NOT (fName == getSequenceFilenameBase fName)
)
 
fn IsUNCpath fPath = (
	if	(classOf fPath == string) AND
		(fPath.count >= 2) AND
		(fPath[1] == "\\") AND
		(fPath[2] == "\\") then TRUE else FALSE
)
 
fn MakeIFL fArray filename:undefined includePath:false createInParent:false = (
	sort fArray
 
	if createInParent then (
		if (filename == undefined) then (
			filename =	(getParentDir (getFilenamePath fArray[1])) +
						(getFilenameFile fArray[1]) + ".IFL"
		) else (
			filename =	(getParentDir fArray[1]) +
						(getFilenameFile filename) + ".IFL"
		)
	) else (
		if filename == undefined do (
			filename =	(getFilenamePath fArray[1]) +
						(getFilenameFile fArray[1]) + ".IFL"
		)
	)
	local iflFile = createFile filename
	if iflFile == undefined then return undefined
 
	if includePath then (
		for f in fArray do format "%\n" f to:iflFile
	) else (
		if createInParent then (
			local rPath = getFilenamePath fArray[1]
			rPath = filterString rPath "\\"
			rPath = ".\\" + rPath[rPath.count] + "\\"
			for f in fArray do format "%\n" (rPath + (filenameFromPath f)) to:iflFile
		) else (
			for f in fArray do format "%\n" (filenameFromPath f) to:iflFile
		)
	)
 
	close iflFile
	return filename
)
 
fn IsFileModNewer fPathA fPathB =
(
	local dateStrA = try (GetFileModDate fPathA) catch (return undefined)
	local dateStrB = try (GetFileModDate fPathB) catch (return undefined)
 
	IsDateNewer dateStrA dateStrB
)
 
fn IsFileCreateNewer fPathA fPathB =
(
	local dateStrA = try (GetFileCreateDate fPathA) catch (return undefined)
	local dateStrB = try (GetFileCreateDate fPathB) catch (return undefined)
 
	IsDateNewer dateStrA dateStrB
)
 
fn IsValidFilename filename = (
	local badChars = #("\\","/",":","*","?","\"","<",">","|")
	local str = GetFilenameFile filename
 
	local res = true
	res = res AND (str.count != 0)
	res = res AND (str.count <= 215)
	for i in 1 to str.count do res = res AND ((findItem badChars str[i]) == 0)
	res
)
 
fn SortINISection INIfile sectionName keyNameBase count =
(
	if (FileExists INIfile) then (
		keyValues = for i in 1 to count collect (
			GetINISetting INIfile sectionName (keyNameBase+(i as string))
		)
		Sort keyValues
		for i in 1 to count do (
			SetINISetting INIfile sectionName (keyNameBase+(i as string)) keyValues[i]
		)
		TRUE
	) else (
		FALSE
	)
)
 
fn UniqueFileName fName padSize:4 =
(
	local newName = ""
	if (FileExists fName) then
	(
		local fBase = ""
		if (IsSequenceFile fName) then
		(
			fBase = (GetFilenamePath fName) + (GetSequenceFilenameBase fName)
		) else (
			fBase = (GetFilenamePath fName) + (GetFilenameFile fName)
		)
		local fType = GetFilenameType fName
 
		local i = 0
		do (i += 1) while
		(
			newName = fBase + (GetPadNum i padSize) + fType
			FileExists newName
		)
	) else (
		newName = fName
	)
 
	newName
)
 
---------------------------------------------------------------------
-- FuncAlias Definitions
---------------------------------------------------------------------
 
co = ClassOf
sco = SuperClassOf
gpn = GetPropNames
pct = PrintClassTree
gct = GetClassTree
-- ShowProperties
if ((MaxVersion())[1] >= 4000) then
(
	mapped fn sp obj = (
		try (
			if (ClassOf obj == Interface OR ClassOf obj == MixinInterface) then
			(
				format "%\n" obj
				ShowInterface obj
			) else (
				format "%\n" obj
				ShowProperties obj
			)
		) catch ( undefined )
		OK
	)
) else (
	mapped fn sp obj = (
		try (
			format "%\n" obj
			ShowProperties obj
			format "\n"
		) catch ( undefined )
		OK
	)
)
-- ShowPropertiesModifier
mapped fn spm obj i = (
	try (
		format "$%.modifiers[%] -> %\n" obj.name i obj.modifiers[i]
		showproperties obj.modifiers[i]
		format "\n"
	) catch ( undefined )
)
-- ShowPropertiesValue
mapped fn spv obj = (
	try (
		format "%\n" obj
		for prop in (gpn obj) do (
			format "  .%: %\n" (prop as string) (getProperty obj prop)
		)
		format "\n"
	) catch ( undefined )
)
-- ShowPropertiesModifierValue
mapped fn spmv obj i = (
	try (
		format "$%.modifiers[%] -> %\n" obj.name i obj.modifiers[i]
		local m = obj.modifiers[i]
		for prop in (gpn m) do (
			format "  .%: %\n" (prop as string) (getProperty m prop)
		)
		format "\n"
	) catch ( undefined )
)
 
---------------------------------------------------------------------
-- Hierarchy Definitions
---------------------------------------------------------------------
 
fn GetChildren parent depth:-1 objArray:undefined = (
	if objArray == undefined then objArray = #()
	if depth == 0 then return() else depth -= 1
	for child in parent.children do (
		append objArray child
		getChildren child objArray:objArray depth:depth
	)
	return objArray
)
 
fn GetDepth obj cnt:0 = (
	if obj.parent == undefined then (
		return cnt
	) else (
		cnt+=1
		getDepth obj.parent cnt:cnt
	)
)
 
fn DupHierarchy parentObj dupFunc instanceAnimation:false = (
	-- Grab the children to copy
	local srcObjs = #(parentObj) + (getChildren parentObj)
 
	-- Unlink everything
	local srcObjsParents = for obj in srcObjs collect obj.parent
	for obj in srcObjs do obj.parent = undefined
 
	-- Duplicate the objects
	local dupObjs = for obj in srcObjs collect dupFunc obj
 
	-- Relink everything
	for i in 1 to srcObjs.count do srcObjs[i].parent = srcObjsParents[i]
 
	-- Sync up the parenting of the copies
	for i in 1 to dupObjs.count do (
		local parentIndex = findItem srcObjs srcObjs[i].parent
		if parentIndex != 0 then (
			dupObjs[i].parent = dupObjs[parentIndex]
		)
	)
 
	animate off at time 0 (
		if (dupFunc == instance) OR (dupFunc == reference) then (
			for i in 1 to dupObjs.count do instanceNodeProps srcObjs[i] dupObjs[i]
		) else (
			for i in 1 to dupObjs.count do copyNodeProps srcObjs[i] dupObjs[i]
		)
	)
 
	-- Instance the controllers
	if instanceAnimation then (
		for i in 2 to dupObjs.count do (
			--dupObjs[i].parent = srcObjs[i].parent
			dupObjs[i].pos.controller = srcObjs[i].pos.controller
			dupObjs[i].rotation.controller = srcObjs[i].rotation.controller
			dupObjs[i].scale.controller = srcObjs[i].scale.controller
		)
	)
 
	return dupObjs
)
 
fn CopyHierarchy parentObj = (
	return (dupHierarchy parentObj copy)
)
 
fn InstanceHierarchy parentObj instanceAnimation:false = (
	return (dupHierarchy parentObj instance instanceAnimation:instanceAnimation)
)
 
fn ReferenceHierarchy parentObj instanceAnimation:false = (
	return (dupHierarchy parentObj reference instanceAnimation:instanceAnimation)
)
 
-- Delete only objects that have no children, and
-- recurse until you can't delete any more.
fn SafeDelete objs lastSize:-1 = (
	if (classOf objs != Array) do return undefined
	if (lastSize == -1) do lastSize = objs.count
 
	for i in objs.count to 1 by -1 do (
		if (objs[i].children.count == 0) do (
			delete objs[i]
			deleteItem objs i
		)
	)
	if (lastSize == objs.count) then (
		return objs
	) else (
		safeDelete objs lastSize:(objs.count)
	)
)
 
fn GetHierarchyRoot obj = (
	local theParent = obj
	while theParent.parent != undefined do theParent = theParent.parent
 
	theParent
)
 
fn GetHierarchy obj = (
	local rootObj = getHierarchyRoot obj
	local kids = getChildren rootObj
 
	(#(rootObj) + kids)
)
 
fn GetParentChain obj = (
	local pChain = #(obj)
	local theParent = obj
	while theParent.parent != undefined do (
		theParent = theParent.parent
		append pChain theParent
	)
 
	(reverseArray pChain)
)
 
---------------------------------------------------------------------
-- Material Definitions
---------------------------------------------------------------------
 
fn DefaultMaterialFilter mat = ( true )
fn DefaultTextureFilter mat = ( true )
 
fn GetSubMaterials mat MaterialFilter:DefaultMaterialFilter = (
	-- all the submaterials we find at this level
	local matArray = #()
 
	if (mat == undefined) then return #()
 
	-- grab passed material, if it is indeed a material, and one that passes the filter
	if (SuperClassOf mat == material) AND (MaterialFilter mat) then ( append matArray mat )
 
	-- run through material's subAnims
	for i in 1 to mat.numSubs do
	(
		-- get subAnim
		local subAn = GetSubAnim mat i
		-- Different materials seem to expose their submaterials to maxscript differently.
		-- this case tries to see if "subAn" is really a material, or
		-- is a subAnim _holding_ a material, or simply something we're not interested in
--		local subMat = case of
--		(
--			(SuperClassOf subAn == material): subAn
--			((ClassOf subAn == subAnim) AND (SuperClassOf subAn.object == material)): subAn.object
--			default: undefined
--		)
		local subMat = if (ClassOf subAn == subAnim) then subAn.object else subAn
 
		-- if subMat turned out to be a material, recurse (which will return an array
		-- containing subMat and any subMaterials found in it)
		if (subMat != undefined) then matArray += GetSubMaterials subMat MaterialFilter:MaterialFilter
	)
 
	-- return array of all submaterials for given level
	matArray
)
 
fn GetStandardSubMaterials mat = (
	local StdFilter
	fn StdFilter mat = ( ClassOf mat == standardMaterial )
 
	GetSubMaterials mat MaterialFilter:StdFilter
)
 
fn GetObjectMaterials obj MaterialFilter:DefaultMaterialFilter = (
	if (obj.material == undefined) then (
		#()
	) else (
		GetSubMaterials obj.material MaterialFilter:MaterialFilter
	)
)
 
fn GetObjectStandardMaterials obj = (
	local StdFilter
	fn StdFilter mat = ( ClassOf mat == standardMaterial )
 
	if (obj.material == undefined) then (
		#()
	) else (
		GetSubMaterials obj.material MaterialFilter:StdFilter
	)
)
 
fn GetSubTextures mat TextureFilter:DefaultTextureFilter = (
	local texArray = #()
 
	if (mat == undefined) then return #()
 
	if (SuperClassOf mat == textureMap) AND (TextureFilter mat) do append texArray mat
 
	for i in 1 to mat.numSubs do
	(
		local subAn = GetSubAnim mat i
		local subTex = if ((ClassOf subAn == subAnim) AND (SuperClassOf subAn.object == textureMap)) then (
			subAn.object
		) else (
			subAn
		)
 
		if (subTex != undefined) then texArray += GetSubTextures subTex TextureFilter:TextureFilter
	)
 
	texArray
)
 
fn GetBitmapTextures mat TextureFilter:DefaultTextureFilter = (
	local BitmapFilter
	fn BitmapFilter mat = ( ClassOf mat == Bitmaptexture )
 
	GetSubTextures mat TextureFilter:BitmapFilter
)
 
fn ReduceSubMaterials mat compareFunc:undefined = (
	local newSO = MultiMaterial name:mat.name
	newSO.materialList.count = 0
 
	local oldArray = mat.materialList
	-- local newArray = newSO.materialList
	-- Collecting materials into an array first now since sometimes
	-- "FindItem" fails finding instances in the materialList property
	local newArray = #()
	local remapArray = for i in 1 to mat.materialList.count collect i
 
	for mIdx in 1 to oldArray.count do (
		local m = oldArray[mIdx]
 
		local fIdx = 0
		if (compareFunc == undefined) then (
			fIdx = findItem newArray m
		) else (
			for i in 1 to newArray.count do (
				if (compareFunc m newArray[i]) then (
					fIdx = i
					format "found %: %\n" m.name i
					break
				)
			)
		)
		if (fIdx == 0) then (
			local newIdx = newArray.count + 1
			newArray[newIdx] = m
			remapArray[mIdx] = newIdx
		) else (
			remapArray[mIdx] = fIdx
		)
	)
 
	-- now collect the new submaterials a stuff them in
	-- the new multi/SO
	newSO.materialList.count = newArray.count
	for i in 1 to newArray.count do newSO.materialList[i] = newArray[i]
 
	#(newSO,remapArray)
)
 
fn DeleteUnusedSubMaterials obj = (
	local oldSO = obj.material
	if (ClassOf oldSO != MultiMaterial) then return undefined
 
	local newSO = MultiMaterial name:oldSO.name
	newSO.materialList.count = 0
 
	local oldArray = oldSO.materialList
	local newArray = newSO.materialList
	local remapArray = for i in 1 to oldArray.count collect i
 
	local usedMatIDs = GetUsedMatIDs obj
 
	for mIdx in 1 to oldArray.count do (
		local fIdx = FindItem usedMatIDs mIdx
 
		if (fIdx != 0) then (
			local newIdx = newArray.count + 1
			newArray[newIdx] = oldArray[mIdx]
			remapArray[mIdx] = newIdx
		)
	)
 
	#(newSO,remapArray)
)
 
fn RemapMeshMaterials obj remapArray = (
	local raCnt = remapArray.count
	for fIdx in 1 to obj.numFaces do (
		local fID = GetFaceMatID obj fIdx
		fID = if (fID > raCnt) then (mod fID raCnt) else fID
		SetFaceMatID obj fIdx remapArray[fID]
	)
	Update obj
)
 
fn GetUsedMatIDs obj =
(
	local matIDs = #()
	local id
	for i in 1 to obj.mesh.numFaces do (
		id = GetFaceMatID obj.mesh i
		if (FindItem matIDs id)==0 then Append matIDs id
	)
	matIDs = sort matIDs
 
	matIDs
)
 
---------------------------------------------------------------------
-- Math Definitions
---------------------------------------------------------------------
 
fn fMin a b = ( if a > b then b else a )
 
fn fMax a b = ( if a > b then a else b )
 
fn fClamp x a b = (
	if x < a then a else
	if x > b then b else x
)
 
Clamp = fClamp
 
fn ClampPnt2 num minVal maxVal = (
	[(Clamp num.x minVal maxVal), (Clamp num.y minVal maxVal)]
)
 
fn ClampPnt3 num minVal maxVal = (
	[(Clamp num.x minVal maxVal), (Clamp num.y minVal maxVal), (Clamp num.z minVal maxVal)]
)
 
fn Bias x b = ( pow x (log b/log 0.5) )
 
fn Gain x g = (
	if x < 0.5 then ((bias (1-g) (2*x))/2) else
	(1 - ((bias (1-g) (2-2*x))/2))
)
 
fn Smoothstep x a b = (
	if x < a then return 0
	if x >= b then return 1
	x = (x-a)/(b-a)
	x*x*(3-2*x)
)
 
fn Round n prec = (
	case (classOf n) of (
		Integer: (
			(Round (n as float) prec) as integer
		)
		Float: (
			local mult = pow 10 prec
			n *= mult
			if n < 0 then n -= 0.5 else n += 0.5
			return ((n as integer) / mult)
		)
		Point2: (
			Point2 (round n.x prec) (round n.y prec)
		)
		Point3: (
			Point3 (round n.x prec) (round n.y prec) (round n.z prec)
		)
	)
)
 
fn GetClosestPoints thisP posArray = (
	--fn CompVal a b valArray: = (
	--	valArray[a]-valArray[b]
	--)
	--workaround for qsort not using CompVal return value as a float
	fn CompVal a b valArray: = (
		if valArray[a] < valArray[b] then -1
		else
		if valArray[a] > valArray[b] then 1
		else
			0
	)
 
	local dist = for p in posArray collect (distance thisP p)
	local distIdx = for i in 1 to dist.count collect i
	qsort distIdx CompVal valArray:dist
	#(distIdx, for i in 1 to posArray.count collect dist[distIdx[i]])
)
 
---------------------------------------------------------------------
-- Mesh Definitions
---------------------------------------------------------------------
 
fn GetVertFaceCache obj = (
	local vertFaces = for i in 1 to obj.numVerts collect #()
	for i in 1 to obj.numFaces do (
		local f = getFace obj i
		append vertFaces[f.x] i
		append vertFaces[f.y] i
		append vertFaces[f.z] i
	)
 
	return vertFaces
)
 
fn GetMeshElement obj faceIdx vertFaceCache = (
	local meshElement = #{}
	local faceVerts, faces, f, curFace
	-- put the passed face onto a stack
	local faceStack = #(faceIdx)
 
	-- while we still have faces to look through
	while faceStack.count != 0 do (
		-- grab the verts used by the face at the top of the stack
		curFace = faceStack[faceStack.count]
		faceVerts = getFace obj curFace
		-- note that we've visited current face, and remove it from the stack
		meshElement[curFace] = true
		deleteItem faceStack faceStack.count
 
		-- gather all the faces referenced by the current face's verts
		faces = vertFaceCache[faceVerts.x]
		faces += vertFaceCache[faceVerts.y]
		faces += vertFaceCache[faceVerts.z]
		-- for each face, if it's not already visited, put it on the stack
		for i in 1 to faces.count do (
			f = faces[i]
			if NOT meshElement[f] then (
				meshElement[f] = true
				append faceStack f
			)
		)
	)
 
	return meshElement
)
 
fn GetAllMeshElements obj vertFaceCache = (
	local usedFaces = #{}
	local meshElements = #()
 
	local i = 1
	while i <= obj.numFaces do (
		-- grab an element
		meshElement = (getMeshElement obj i vertFaceCache)
		-- note faces that are used
		usedFaces += meshElement
		-- save into the array of elements
		append meshElements meshElement
 
		-- find the next face that hasn't been flagged as
		-- part of an element yet
		while usedFaces[i] do i += 1
	)
 
	return meshElements
)
 
fn DetachMeshFaces obj faces = (
	local cObj = copy obj
	for i in obj.numFaces to 1 by -1 do (
		if faces[i] then
			deleteFace obj i
		else
			deleteFace cObj i
	)
	update obj
	update cObj
 
	return cObj
)
 
fn CleanIsoVerts obj = (
	local verts = #{1..obj.numVerts}
	for i in 1 to obj.numFaces do (
		local f = getFace obj i
		verts[f.x] = verts[f.y] = verts[f.z] = false
	)
	for i in verts.count to 1 by -1 do (
		if verts[i] do deleteVert obj i
	)
 
	OK
)
 
fn ExplodeMeshElements obj = (
	local newObjs = #()
 
	format "Building cache...\n"
	local elements = getAllMeshElements obj (getVertFaceCache obj)
	for eIdx in 1 to elements.count do (
		format "Detaching % of %\n" eIdx elements.count
		local mapVerts = #(); mapVerts[obj.numVerts] = undefined
		local verts = #()
		local faces = #()
		local edgeVis = #()
		local smoothGroup = #()
		local matID = #()
 
		-- loop through all faces
		for fIdx in 1 to elements[eIdx].count do (
			if elements[eIdx][fIdx] then (
				-- get the used face
				local f = getFace obj fIdx
				append faces f
				edgeVis += #((getEdgeVis obj fIdx 1),(getEdgeVis obj fIdx 2),(getEdgeVis obj fIdx 3))
				append smoothGroup (getFaceSmoothGroup obj fIdx)
				append matID (getFaceMatID obj fIdx)
				-- grab the position of each vertex, and note which
				-- vertex in old mesh maps to the vertex in the new mesh
				for v in 1 to 3 do (
					case v of (
						1: v = f.x
						2: v = f.y
						3: v = f.z
					)
					if mapVerts[v] == undefined then (
						append verts (getVert obj v)
						mapVerts[v] = verts.count
					)
				)
			)
		)
		local cObj = mesh numVerts:verts.count numFaces:faces.count
		cObj.name = uniqueName (obj.name + "_ELEMENT")
		cObj.transform = obj.transform
		for i in 1 to verts.count do setVert cObj i verts[i]
		for i in 1 to faces.count do (
			setFace cObj i mapVerts[(faces[i].x)] mapVerts[(faces[i].y)] mapVerts[(faces[i].z)]
		)
		local cnt = 0
		for i in 1 to faces.count do (
			setEdgeVis cObj i 1 edgeVis[cnt+=1]
			setEdgeVis cObj i 2 edgeVis[cnt+=1]
			setEdgeVis cObj i 3 edgeVis[cnt+=1]
			setFaceSmoothGroup cObj i smoothGroup[i]
			setFaceMatID cObj i matID[i]
		)
		update cObj
 
		append newObjs cObj
		gc()
	)
 
	return newObjs
)
 
fn GetFacesByNormal obj vec angThresh = (
	if	(classOf obj == editable_mesh) AND
		(obj.modifiers.count == 0) then (
			local selFaces = #{1..obj.numFaces}
			local n, d, ang
			vec = normalize (-vec)
			for i in 1 to obj.numFaces do (
				n = getFaceNormal obj i
				d = dot n vec
				ang = if (d > 0.0) then (acos d) else (90 + (acos d))
				selFaces[i] = (acos d) < angThresh
			)
			return selFaces
	) else (
		return undefined
	)
)
 
fn GetAllPolygons obj = (
	-- faces left to consider for polygons
	local faces = #{1..(obj.numFaces+1)}
	-- array of bitarrays, one for each poly
	local polys = #()
	local cnt = 1
	while (cnt < faces.count) do (
		-- grab poly from next face
		append polys (meshop.getPolysUsingFace obj cnt threshhold:180)
		-- remove faces used by poly from pool of remaining faces
		faces -= polys[polys.count]
		-- zip ahead to next unused face
		while NOT faces[cnt] do cnt += 1
	)
	return polys
)
 
fn GetAllPolygonsProgress obj = (
	local oldSOmode = subObjectLevel
	progressStart "Gathering Polygons..."
	-- faces left to consider for polygons
	local faces = #{1..(obj.numFaces+1)}
	-- array of bitarrays, one for each poly
	local polys = #()
	local cnt = 1
	while (cnt < faces.count) do (
		-- grab poly from next face
		append polys (meshop.getPolysUsingFace obj cnt threshhold:180)
		-- remove faces used by poly from pool of remaining faces
		faces -= polys[polys.count]
		-- zip ahead to next unused face
		while NOT faces[cnt] do cnt += 1
		progressUpdate (cnt as float / faces.count * 100.)
	)
	progressEnd()
	if oldSOmode != undefined do subObjectLevel = oldSOmode
	return polys
)
 
fn MeshOKtoModify obj = (
	if	(classOf obj == Editable_mesh) AND
		(obj.modifiers.count == 0) then true else false
)
 
fn GetClosestVert meshObj pnt vertMask:undefined =
(
	case of (
		(#selection == vertMask): (
			vertMask = GetVertSelection meshObj
		)
		(undefined == vertMask): (
			vertMask = #{1..meshObj.numVerts}
		)
	)
 
	local closest = 999999999
	local closestIdx
	local dist
 
	for i in vertMask do (
		dist = distance pnt (GetVert meshObj i)
		case of (
			(dist == 0.0): return i
			(dist < closest): (
				closest = dist
				closestIdx = i
			)
		)
	)
 
	return closestIdx
)
 
fn GetClosestVerts meshObj pnt vertMask:undefined =
(
	case of (
		(#selection == vertMask): (
			vertMask = GetVertSelection meshObj
		)
		(undefined == vertMask): (
			vertMask = #{1..meshObj.numVerts}
		)
	)
 
	local posArray = for i in vertMask collect (GetVert meshObj i)
	local origIndex = for i in vertMask collect i
 
	local res = GetClosestPoints pnt posArray
 
	local idxArray = for i in 1 to res[1].count collect origIndex[res[1][i]]
 
	return #(idxArray, res[2])
)
 
fn GetFaceAsArray meshObj faceIndex =
(
	local f = GetFace meshObj faceIndex
	#(f.x, f.y, f.z)
)
 
---------------------------------------------------------------------
-- Miscellaneous Definitions
---------------------------------------------------------------------
 
fn GetClassTree val =
(
	local c = ClassOf val
 
	local classAr = #(c)
	while (c != ClassOf c) do (c = ClassOf c; Append classAr c)
 
	ReverseArray classAr
)
 
fn PrintClassTree val =
(
	local classAr = GetClassTree val
 
	format "__%\n" classAr[1]
	local formatStr = "|__%\n"
	for i in 2 to classAr.count do
	(
		format formatStr classAr[i]
		formatStr = " " + formatStr
	)
 
	OK
)
 
---------------------------------------------------------------------
-- Modifier Definitions
---------------------------------------------------------------------
 
fn GetAllModifiers = (
	local ss = stringstream ""
	showclass "*:mod*" to:ss
 
	local sa = filterString (ss as string) ":\n"
 
	local classes = for i in 1 to sa.count by 2 collect (
		-- capitalize first letter and remove trailing space
		(toUpper2 sa[i][1]) + (subString sa[i] 2 (sa[i].count-2))
	)
	sort classes
 
	return classes
)
 
fn GetModifiersOfClass obj modClass =
(
	local objArray
	try(objArray = obj as array) catch (objArray = #(obj))
 
	local mods = #()
	for obj in objArray do (
		mods += (for m in obj.modifiers where (ClassOf m == modClass) collect m)
	)
	mods
)
 
---------------------------------------------------------------------
-- Object Definitions
---------------------------------------------------------------------
 
fn IsInstance objA objB = (
	(isKindOf objA node) AND
	(isKindOf objB node) AND
	(objA.baseObject == objB.baseObject)
)
 
fn GetInstances obj = (
	local objs
 
	local bObj = obj.baseObject
	local rObjs = refs.dependents bObj
	objs = for rObj in rObjs where ( (isKindOf rObj node) AND
									(bObj == rObj.baseObject) AND
									(obj != rObj) ) collect rObj
 
	return objs
)
 
fn DupNodeProps sourceObj targetObj instanceControllers:false = (
	animate off at time 0 (
		local props = #(#renderable,#castShadows,#ishidden,#boxmode,#alledges,#backfacecull,
			#receiveshadows,#gbufferchannel,#motionblur,#imageMotionBlurMultiplier,
			#showLinks,#showLinksOnly,#isfrozen,#showTrajectory,#showVertexColors,
			#vertexColorsShaded,#inheritVisibility,#xray,#ignoreExtents,#renderOccluded,
			#motionBlurOn,#rcvCaustics,#generateCaustics,#rcvGlobalIllum,#generateGlobalIllum,
			#primaryVisibility,#secondaryVisibility)
 
		for prop in props do (
			local val = getProperty sourceObj prop
			if val != undefined do setProperty targetObj prop val
		)
 
		try (
			if instanceControllers then (
				targetObj.imageMotionBlurMultiplier.controller = sourceObj.imageMotionBlurMultiplier.controller
			) else (
				targetObj.imageMotionBlurMultiplier.controller = copy sourceObj.imageMotionBlurMultiplier.controller
			)
		) catch ()
--		try (
--			targetObj.motionBlurOnController = copy sourceObj.motionBlurOnController
--		) catch ()
	)
)
 
fn InstanceNodeProps sourceObj targetObj = (
	try (
		dupNodeProps sourceObj targetObj instanceControllers:true
		true
	) catch ( false )
)
 
fn CopyNodeProps sourceObj targetObj = (
	try (
		dupNodeProps sourceObj targetObj
		true
	) catch ( false )
)
 
--fn getDependentObjects obj = (
--	for dep in (refs.dependents obj) where \
--		(isKindOf dep node) AND
--		(dep.baseObject != obj.baseObject) collect dep
--)
 
fn ObjectExists obj = (
	NOT (try ((isDeleted obj) OR (obj == undefined)) catch (true))
)
 
fn IsBipedObject obj = (
	(classOf obj == Biped_Object) OR
	(	(classOf obj == Dummy) AND
		(classOf obj.controller == BipSlave_Control)
	)
)
 
fn TrimInvalidObjects objArray = (
	for i in objArray.count to 1 by -1 do (
		if NOT (objectExists objArray[i]) do (deleteItem objArray i)
	)
	objArray
)
 
fn SelectAndShow objArray keepSel:FALSE prompt:TRUE =
(
	undo on (
		local badObjs = for obj in objArray where obj.isHidden OR obj.isFrozen collect obj
 
		if (prompt AND badObjs.count != 0) then (
			local str = "This selection contains hidden and/or frozen objects.
Do you want these objects to be unhidden and unfrozen?
(Choosing \"No\" means that the hidden/frozen objects will become selected!)"
 
			if (QueryBox str title:"3D Studio MAX") then
				for obj in badObjs do ( obj.isHidden = obj.isFrozen = false )
		)
 
		if (keepSel == true) then
			selectMore objArray
		else
			select objArray
	)
 
	OK
)
 
fn GetBipedObjects bipObj =
(
	if NOT (IsBipedObject bipObj) then return #()
	local hier = GetHierarchy bipObj
	for obj in hier where (IsBipedObject obj) collect obj
)
 
---------------------------------------------------------------------
-- Spline Definitions
---------------------------------------------------------------------
 
fn GetRequiredSteps shp splineIndex lengthParam =
(
	ResetLengthInterp()
	local len = CurveLength shp splineIndex
	local reqAccuracy = (len * lengthParam) * 0.05 --0.25 -- fudge to be a bit more accurate
	(len * (1.0 / reqAccuracy)) as integer
)
 
fn SmoothShape shp splineIndex
	knotCount:undefined
	segmentLength:undefined
	numSamples:9 =
(
	local numPnts
	if (knotCount != undefined) then (
		numPnts = knotCount
	) else if (segmentLength != undefined) then (
		local splLen = CurveLength shp splineIndex
		numPnts = (splLen / segLen) + 1
	) else (
		return undefined
	)
 
	local d = 1.0 / (numPnts-1)
 
	local tmpShp = copy shp
	ConvertToSplineShape tmpShp
 
	local sD = d / (numSamples-1)
 
	local smoothShp = SplineShape()
	smoothShp.name = shp.name + "_Smoothed"
	smoothShp.wireColor = shp.wireColor
	AddNewSpline smoothShp
	AddKnot smoothShp 1 #smooth #curve (GetKnotPoint tmpShp splineIndex 1)
 
	local steps = GetRequiredSteps shp splineIndex sD
	for iP in 2 to (numPnts-1) do (
		local curD = ((iP-1.0) / (numPnts-1.0)) - (d / 2.0)
 
		local p = [0,0,0]
		local thisNumSamples = numSamples
		for iS in 1 to numSamples do (
			if (curD < 0.0 OR curD > 1.0) then (thisNumSamples -= 1; continue())
			p +=	if ((curD-1.0) > -0.00001) then -- workaround for LengthInterp giving bad values at spline ends
						PathInterp tmpShp splineIndex curD steps:steps
					else
						LengthInterp tmpShp splineIndex curD steps:steps
			curD += sD
		)
		p /= numSamples
 
		AddKnot smoothShp 1 #smooth #curve p
	)
	AddKnot smoothShp 1 #smooth #curve (GetKnotPoint tmpShp splineIndex (NumKnots tmpShp splineIndex))
	if (IsClosed tmpShp splineIndex) then Close smoothShp 1
 
	delete tmpShp
 
	UpdateShape smoothShp
	smoothShp
)
 
fn ShapeToString shp splineIndex extraRootVertex:false = (
	local numVerts = NumKnots shp splineIndex
	local numFaces = NumSegments shp splineIndex
 
	if extraRootVertex then (
		numVerts += 1
		numFaces += 1
	)
 
	local msh = mesh numVerts:numVerts numFaces:numFaces
	msh.name = shp.name + "_MeshString"
	msh.wireColor = shp.wireColor
 
	if extraRootVertex then (
		local p1 = GetKnotPoint shp splineIndex 1
		local p2 = GetKnotPoint shp splineIndex 2
		local n = -(p2-p1)
		SetVert msh 1 (p1+n)
	)
 
	local kIdx = 0
	local startVIdx = if extraRootVertex then 2 else 1
	for vIdx in startVIdx to numVerts do (
		kIdx += 1
		SetVert msh vIdx (GetKnotPoint shp splineIndex kIdx)
	)
	for fIdx in 1 to numFaces do (
		local a = fIdx
		local b = if (fIdx < numVerts) then (fIdx+1) else 1
		SetFace msh fIdx [a,a,b]
 
		for eIdx in 1 to 3 do SetEdgeVis msh fIdx eIdx true
	)
 
	Update msh
	msh
)
 
fn ShapeToRibbon shp splineIndex segmentCount width:#auto widthScale:1.0 contourMesh:undefined center:false mapping:false = (
	fn BuildQuad msh a b c d = (
		SetFace msh a [a,d,b]
		SetFace msh (a+1) [a,c,d]
		SetEdgeVis msh a 2 true
		SetEdgeVis msh a 3 true
		SetEdgeVis msh (a+1) 1 true
		SetEdgeVis msh (a+1) 2 true
		OK
	)
 
	fn GetContourNormal p contourMesh = (
		local res = GetClosestVerts contourMesh p
 
		local n = [0,0,0]
		if (res[1].count >= 4) then (
			local weights = for i in 1 to 4 collect res[2][i]
			for i in 1 to 4 do weights[i] = 1.0 - (weights[i] / weights[4])
 
			for i in 1 to 3 do (
				n += (GetNormal contourMesh res[1][i]) * weights[i]
			)
			if (Length n == 0) then
				n = [0,0,1]
			else
				n = Normalize n
		)
 
		n
	)
 
	local numVerts = (segmentCount * 2) + 2
	local numFaces = if (IsClosed shp splineIndex) then numVerts else (numVerts-2)
	local d = 1.0 / (segmentCount as float)
 
	local steps = GetRequiredSteps shp splineIndex d
 
	if (width == #auto) then (
		width = (CurveLength shp splineIndex steps:steps) / (segmentCount as float) * widthScale
	) else if (width == #flip) then (
		width = -(CurveLength shp splineIndex steps:steps) / (segmentCount as float) * widthScale
	)
 
	local msh = mesh numVerts:numVerts numFaces:numFaces
	msh.name = shp.name + "_Ribbon"
	msh.wireColor = shp.wireColor
	if (mapping) then (
		SetNumTVerts msh numVerts
		BuildTVFaces msh
	)
 
	local curD = 0.0
	for vIdx in 1 to numVerts by 2 do (
		local p = LengthInterp shp splineIndex curD steps:steps
		local t = if ((curD-1.0) > -0.00001) then -- workaround for LengthTangent giving bad values at spline ends
					PathTangent shp splineIndex curD
				else
					LengthTangent shp splineIndex curD steps:steps
 
		local n
		if (contourMesh != undefined) then
			n = GetContourNormal p contourMesh
		else
			n = [0,0,1]
 
		local u = Normalize (Cross n t)
		local extrudeVec = u * width
 
--handy while debugging
--null pos:p nullshape:5 xscale:10 mixWireColor:true dir:t name:("T"+vIdx as string) wireColor:red
--null pos:p nullshape:5 xscale:10 mixWireColor:true dir:n name:("N"+vIdx as string) wireColor:green
--null pos:p nullshape:5 xscale:10 mixWireColor:true dir:u name:("U"+vIdx as string) wireColor:blue
 
		if (center) then p -= (extrudeVec/2.0)
 
		SetVert msh vIdx p
		SetVert msh (vIdx+1) (p+extrudeVec)
 
		if (mapping) then (
			SetTVert msh vIdx     [0.0,curD,0.0]
			SetTVert msh (vIdx+1) [1.0,curD,0.0]
		)
 
		curD += d
		curD = fClamp curD 0.0 1.0
	)
 
	for fIdx in 1 to numFaces by 2 do (
		local a = fIdx
		local b = fIdx + 1
		local c = if (fIdx+2 <= numVerts) then (fIdx+2) else 1
		local d = if (fIdx+3 <= numVerts) then (fIdx+3) else 2
		BuildQuad msh a b c d
 
		if (mapping) then (
			SetTVFace msh a [a,d,b]
			SetTVFace msh b [a,c,d]
		)
	)
 
	Update msh
	msh
)
 
--	local weights = #(); weights[splineCount] = undefined
--	if (basePoint != undefined) then (
--		local roots = GetShapeRoots shapeArray
--		local closestRes = GetClosestPoints basePoint roots
--		local idxArray = closestRes[1]
--		local distArray = closestRes[2]
--
--		local minDist = distArray[idxArray[1]]
--		local maxDist = distArray[idxArray[idxArray.count]]
--		local totDist = 0.0; for dist in distArray do totDist += dist
--		local center = totDist / distArray.count
--
--		for i in 1 to splineCount do (
--			local thisDist = distArray[i]
--
--			if (center - roots[i]) < thisDistw
--		)
--
--		local n = minDist / maxDist
--		local maxWeight = 1.0
--		for i in 1 to splineCount do (
--			local thisDist = distArray[i]
--			local nw = 1.0 - (thisDist - minDist) / maxDist
--			local w = 1.0 - ((distArray[i]-minDist) / maxDist) --) / splineCount
--			w *= maxWeight
--			weights[idxArray[i]] = w
--			maxWeight -= w
--		)
--		print weights
--	) else (
--		w = 1.0 / splineCount
--		for i in 1 to splineCount do weights[i] = w
--	)
fn AverageShapes shapeArray knotCount:0 whichSplines:undefined = (
	local splineCount = 0.0
	local splineArray = #()	-- contains a #(shape,splineIndex) for each spline in all the shapes,
							-- for easy iterating over
	for shp in shapeArray do (
		splineCount += NumSplines shp
		for si in 1 to (NumSplines shp) do (
			append splineArray #(shp,si)
		)
	)
 
	if (whichSplines == undefined) then (whichSplines = #{1..splineCount})
 
	local numUsedSplines = BitNumberSet whichSplines
	if (numUsedSplines == 0) then (return undefined)
 
	if (knotCount == 0) then (
		for shp in shapeArray do (
			for i in 1 to (NumSplines shp) do (
				local cnt = NumKnots shp i
				if (cnt > knotCount) then knotCount = cnt
			)
		)
	)
 
	local aveShp = SplineShape name:(UniqueName "AverageShape")
	AddNewSpline aveShp
	for i in 1 to knotCount do (
		local np = (i - 1) / (knotCount - 1.0)
 
		local p = [0,0,0]
 
		for i in whichSplines do (
			local shp = splineArray[i][1]
			local sIdx = splineArray[i][2]
			p += (LengthInterp shp sIdx np) --* weights[splIdx]
		)
		p /= numUsedSplines
 
		AddKnot aveShp 1 #smooth #curve p
	)
 
	UpdateShape aveShp
	aveShp
)
 
fn ExplodeShape shp origin:#world = (
	splArray = #()
	for si in 1 to (NumSplines shp) do (
		local spl = BuildSpline shp si
		append splArray spl
	)
	splArray
)
 
fn BuildSpline shp splineIndex origin:#world = (
	local spl = SplineShape name:(shp.name + "_Spline" + (GetPadNum splineIndex 2))
 
	case origin of
	(
		#world: (
			spl.transform = Matrix3 1
		)
		#original: (
			spl.transform = shp.transform
		)
		#spline: (
			spl.pos = GetKnotPoint shp splineIndex 1
			spl.dir = PathTangent shp splineIndex 0.0
		)
	)
 
	AddNewSpline spl
	for ki in 1 to (NumKnots shp splineIndex) do (
		AddKnot spl 1 #corner #line (GetKnotPoint shp splineIndex ki)
	)
	if (IsClosed shp splineIndex) then close spl 1
	for i in 1 to (NumSegments shp splineIndex) do (
		SetSegmentType spl 1 i (GetSegmentType shp splineIndex i)
	)
	for ki in 1 to (NumKnots shp splineIndex) do (
		SetKnotType spl 1 ki (GetKnotType shp splineIndex ki)
		SetInVec spl 1 ki (GetInVec shp splineIndex ki)
		SetOutVec spl 1 ki (GetOutVec shp splineIndex ki)
	)
	UpdateShape spl
	spl
)
 
fn DetachSpline shp splineIndex origin:#world = (
	local spl = BuildSpline shp splineIndex
	DeleteSpline shp splineIndex
	UpdateShape shp
	spl
)
 
-- Get the root positions of all the passed shapes
fn GetShapeRoots shapeArray = (
	local rootArray = #()
	for shp in shapeArray do (
		for i in 1 to (NumSplines shp) do (
			append rootArray (GetKnotPoint shp i 1)
		)
	)
	rootArray
)
 
fn KnotLengthParam shp splineIndex kIdx =
(
	PathToLengthParam shp splineIndex ((kIdx-1) / ((NumKnots shp splineIndex) - 1.0))
)
 
fn CreateShapeInstance shp =
(
	iShp = CreateInstance SplineShape
 
	for si in 1 to (NumSplines shp) do
	(
		AddNewSpline iShp
 
		for ki in 1 to (NumKnots shp si) do
		(
			AddKnot iShp si #smooth #curve (GetKnotPoint shp si ki)
			SetKnotType iShp si ki (GetKnotType shp si ki)
			SetInVec iShp si ki (GetInVec iShp si ki)
			SetOutVec iShp si ki (GetOutVec iShp si ki)
		)
 
		if (IsClosed shp) then Close iShp
 
		for i in 1 to (NumSegments shp si) do
		(
			SetSegmentType iShp si i (GetSegmentType shp si i)
		)
	)
 
	iShp
)
 
fn CreateSplineFromArray pointArray shapeObj:undefined knotType:#corner closed:FALSE =
(
	local shp
	if (shapeObj == undefined) then
	(
		shp = SplineShape()
		shp.name = UniqueName "Shape"
	) else
		shp = shapeObj
 
	-- don't set bezier types initially (avoid manually creating tangents)
	local kt = if (
					knotType == #bezier OR
					knotType == #beziercorner
				) then
					#smooth
				else
					knotType
 
	AddNewSpline shp
	local splineIndex = NumSplines shp
	for pnt in pointArray do (
		AddKnot shp splineIndex kt #curve pnt
	)
 
	-- go back and set bezier knot types, let max figure out the tangents
	if (knotType == #bezier OR
		knotType == #beziercorner) then
	(
		for i in 1 to (NumKnots shp splineIndex) do SetKnotType shp splineIndex i knotType
	)
 
	if (closed) then Close shp splineIndex
 
	UpdateShape shp
	shp
)
 
---------------------------------------------------------------------
-- String Definitions
---------------------------------------------------------------------
 
fn Truncate str n = (
	if n == 0 then return ""
	substring str 1 n
)
 
fn SnipString str n = (
	if n <= 1 then (return substring str 1 1)
	local ln = str.count as integer
	if ln <= n then (return str)
	else (
		local half = n / 2.0
		(substring str 1 half) + "~" + (substring str (ln-(half-2)) (half-0.5))
	)
)
 
-- Takes a string with single \'s and returns one with \\'s
fn DoubleSlash str = (
	for i = str.count to 1 by -1 do (
		if str[i] == "\\" then (
			str = replace str i 1 "\\\\"
		)
	)
	return str
)
 
fn ToUpper2 str = (
	try (
		str = copy str
		local lowerLetters = #("a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z")
		local upperLetters = #("A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z")
		for i = 1 to str.count do (
			str[i] = try ( upperLetters[(findItem lowerLetters str[i])] ) catch ( str[i] )
		)
		str
	) catch ( undefined )
)
 
fn ToLower2 str = (
	try (
		str = copy str
		local lowerLetters = #("a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z")
		local upperLetters = #("A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z")
		for i = 1 to str.count do (
			str[i] = try ( lowerLetters[(findItem upperLetters str[i])] ) catch ( str[i] )
		)
		str
	) catch ( undefined )
)
 
fn FindString2 str searchString fromIndex:1 lengthIndex:0 caseSensitive:false = (
	if fromIndex > str.count then return undefined
	if lengthIndex == 0 then lengthIndex = (str.count - fromIndex + 1)
	if not caseSensitive then (
		str = toUpper2 str
		searchString = toUpper2 searchString
	)
	for i in fromIndex to (fromIndex + lengthIndex) do
	(
		if str[i] == searchString[1] then
		(
			for j in 0 to (searchString.count-1) do
			(
				if str[i+j] != searchString[j+1] then
					exit
				else
				(
					if (j == (searchString.count-1)) then return i
				)
			)
		)
	)
 
	undefined
)
 
fn SearchReplace str searchText replaceText fromIndex:1 lengthIndex:0 caseSensitive:false =
(
	if str == "" then return str
	if fromIndex > str.count then return undefined
	if lengthIndex == 0 then lengthIndex = (str.count - fromIndex + 1)
	local newStr = copy str
	local x = fromIndex
	local y = lengthIndex
	while (idx = findString2 newStr searchText fromIndex:x lengthIndex:y caseSensitive:caseSensitive) != undefined do (
		newStr = replace newStr idx searchText.count replaceText
		x = idx + replaceText.count
		y -= (replaceText.count - searchText.count)
	)
	return newStr
)
 
fn DateAsPoint3 dateStr = (
	try (
		local ar = filterString dateStr "/ "
		local pnt3 = [0,0,0]
		if (classOf ar == array) then (
			pnt3.x = ar[3] as integer
			pnt3.y = ar[1] as integer
			pnt3.z = ar[2] as integer
 
			-- Workaround for NT/W2K difference in localTime string
			if (pnt3.x < 2000) then pnt3.x += 2000
 
			return pnt3
		) else (
			return undefined
		)
	) catch ( undefined )
)
 
fn DateAsSeconds dateStr = (
	try (
		local strAr = Filterstring dateStr " "
		local timeAr = FilterString strAr[2] ":"
 
		for i in 1 to timeAr.count do timeAr[i] = timeAr[i] as integer
 
		if strAr[strAr.count] == "PM" then timeAr[1] += 12
 
		( (timeAr[1] * 3600) + (timeAr[2] * 60) + (timeAr[3]) )
	) catch ( undefined )
)
 
fn GetTag str start = (
	ret = #(0,0,"")
	for i = start to str.count do (
		if (str[i] == "<") and (str[i+1] == "*") then (
			ret[1] = i
			for j = (i+2) to str.count do (
				if str[j] == "*" and str[j+1] == ">" then (
					ret[2] = j-i+2
					exit
				)
				ret[3] += str[j]
			)
		)
		if ret[1] != 0 then exit
	)
	if ret[1] == 0 then return undefined
	return ret
)
 
fn ReplaceTags str tags tagVals = (
	local lastIdx = 1
	local aTag, tagIdx, tagVal
	while ((aTag = getTag str lastIdx) != undefined) do (
		lastIdx = aTag[1]
		tagIdx = findItem tags (aTag[3] as name)
		tagVal = if tagIdx != 0 then (tagVals[tagIdx] as string) else "UNKNOWNTAG"
		str = replace str aTag[1] aTag[2] tagVal
	)
	return str
)
 
fn GetPadNum num minSize = (
	try (
		local pad = ""
		local numStr = num as string
		local diff = minSize - numStr.count
 
		if diff > 0 then (
			for i in 1 to diff do ( pad += "0" )
		)
 
		return ( pad + numStr )
	) catch ( return "" )
)
 
fn PrintColor str col = (
	local oldCol = outputTextColor
	outputTextColor = col
	print str
	outputTextColor = oldCol
	return str
)
 
fn IsCharInt char = (
	return ((findItem #("1","2","3","4","5","6","7","8","9","0") char) != 0)
)
 
fn Capitalize str =
(
	(ToUpper2 str[1]) + (SubString str 2 (str.count-1))
)
 
fn StringCount str findStr = (
	local cnt = 0
	local idx = 1
	while ((idx = FindString2 str findStr fromIndex:idx) != undefined) do (
		idx += 1
		cnt += 1
	)
	cnt
)
 
fn ColumnFormat fmtStr args argsLen = (
	-- convert all args to strings
	local sargs = for arg in args collect (arg as string)
 
	-- count wildcards in format string, fail if count doesn't match argument count
	local wildCnt = StringCount fmtStr "%"
	if (wildCnt != sargs.count) OR (wildCnt != argsLen.count) then throw "Argument arrays not the proper size\n"
 
	-- loop through wildcards, replacing with args[x] string (snipped to argsLen[x] length)
	local tmpStr = copy fmtStr
	for i in 1 to wildCnt do (
		local wildIdx = FindString tmpStr "%"
		argStr = SubString sargs[i] 1 argsLen[i]
		if (argStr.count < argsLen[i]) do (
			for i = 1 to (argsLen[i] - argStr.count) do argStr += " "
		)
		tmpStr = Replace tmpStr wildIdx 1 argStr
	)
	format "%" tmpStr
)
 
fn GetValidFilename str allowSpaces:FALSE replaceCharacter:"_" =
(
	local validChars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890-_{}[]`~,.+"
	if allowSpaces do validChars += " "
 
	local outStr = copy str
	for i in 1 to outStr.count do
		outStr[i] = if ((FindString validChars str[i]) == undefined) then
			replaceCharacter
		else
			str[i]
 
	outStr
)
 
---------------------------------------------------------------------
-- System Definitions
---------------------------------------------------------------------
 
fn GetDriveFreeSpace driveLetter = (
	local freeSpace = undefined
 
	local fName = driveLetter + ":\\DskCheck.tmp"
	dosCommand ("dir " + driveLetter + ":>" + fName)
	local f = openFile fName
	if (f != undefined) do (
		local sizeStr
		while not eof f do sizeStr = readLine f
		if (findString sizeStr "free") != undefined do (
			local strArray = filterString sizeStr ", "
			if (strArray.count < 2) do return undefined
			-- delete "X Dir(s)" part in Win2K
			if (strArray[2] == "Dir(s)") do (
				deleteItem strArray 1
				deleteItem strArray 1
			)
			if (strArray[1] as integer) != undefined do (
				local i = 1
				freeSpace = ""
				while (strArray[i] as integer) != undefined do (
					freeSpace += strArray[i]
					i += 1
				)
			)
		)
		close f
	)
	deleteFile fName
 
	return freeSpace
)
 
fn MakeSysInfoFile =
(
	local MAXTRIES = 60
	local BASEPATH = "R:\\MAX3master\\Util\\WinMSD\\"
 
	local tries = 0
	local si = SystemInfo()
 
	local WinMSD =
	local fileName = BASEPATH + (si.computerName) + ".TXT"
 
	local dateA = try (GetFileModDate fileName) catch (undefined)
	if (dateA == undefined) then dateA = "1/1/1970  1:23:45 AM"
 
	local dateB = undefined
 
	ShellLaunch (BASEPATH + "WinMSD.exe") "/s"
 
	while	((IsDateNewer dateB dateA) != true) AND
			(tries < MAXTRIES) do
	(
		sleep 1
		dateB = try (GetFileModDate fileName) catch (undefined)
		tries += 1
	)
 
	if (tries == MAXTRIES) then
	(
		return undefined
	) else (
		return fileName
	)
)
 
fn GetSysInfoProcessors f =
(
	try
	(
		local procs = #() -- array of processors
 
		seek f 0
		skipToString f "Processor list"
		skipToNextLine f
		local str = ""
 
		while ( (str = readLine f)[1] != "-" ) do
		(
			local strAr = filterString str " :~"
			local proc = #()
 
			--speed
			append proc (strAr[(findItem strAr "Mhz")-1] as integer)
			--family
			append proc (strAr[(findItem strAr "Family")+1] as integer)
			--model
			append proc (strAr[(findItem strAr "Model")+1] as integer)
			--stepping
			append proc (strAr[(findItem strAr "Stepping")+1] as integer)
 
			append procs proc
 
			procs
		)
	) catch ( #() )
)
 
fn GetSysInfoPhysicalMemory f =
(
	try
	(
		seek f 0
		skipToString f "Memory Report"
		skipToString f "Physical Memory"
		skipToNextLine f
 
		local str = readLine f
 
		local memAr = filterString str " Total:,"
 
		local mem = ""
		--for i in 1 to (memAr.count-1) do mem += memAr[i]
		for m in memAr do mem += m
 
		mem as integer
	) catch ( 0 )
)
 
fn GetSysInfoFromFile fPath =
(
	local f
	try
	(
		if (fPath != undefined) then
		(
			f = OpenFile fPath
 
			if (f != undefined) then
			(
				local sysInfo = #()
 
				append sysInfo ((SystemInfo()).computerName)
				append sysInfo (GetSysInfoProcessors f)
				append sysInfo (GetSysInfoPhysicalMemory f)
 
				close f
				return sysInfo
			)
		)
 
		return undefined
	) catch ( close f )
)
 
fn GetSysInfo =
(
	local sysInfoFile = MakeSysInfoFile()
 
	if (sysInfoFile != undefined) then
	(
		GetSysInfoFromFile sysInfoFile
	) else (
		undefined
	)
)
 
fn GetProcessorName procCount procFamily procModel =
(
	local procName = case procCount of (
		1: ""
		2: "Dual "
		4: "Quad "
		8: "8 Proc "
		16: "16 Proc "
		default: ""
	)
 
	-- Note: these names are very roughly chosen
	procName += case procFamily of (
		5: (
			"Pentium"
		)
		6: (
			case of (
				(procModel <= 1):		"Pentium Pro"
				(procModel <= 5):		"Pentium 2"
				(procModel == 6):		"Celeron"
				default:				"Pentium 3"
			)
		)
		15: (
			"Pentium 4"
		)
		default: "Unknown Processor"
	)
)
 
struct ServerInfo (
	serverName = "",
	infoVersion = 0,
	numProcessors = 0,
	processorSpeed = 0,
	processorFamily = 0,
	processorModel = 0,
	physicalMemory = 0,
	lockid = 0
)
 
-----------------------------------------------------------------------------------------------------
-- Non-cached ServerStats... original implementation
-----------------------------------------------------------------------------------------------------
struct ServerStats_NoCache (
	serverStatsFile = "R:\\MAX3master\\ServerStats.ini",
	fn GetMasterInfoVersion = (
		local ver = GetINISetting serverStatsFile "ServerStats" "MasterInfoVersion"
		ver as integer
	),
	fn GetServerCount = (
		local cnt = GetINISetting serverStatsFile "ServerStats" "ServerCount"
		cnt as integer
	),
	fn SetServerCount cnt = (
		SetINISetting serverStatsFile "ServerStats" "ServerCount" (cnt as string)
	),
	fn GetServerName idx = (
		local str = GetINISetting serverStatsFile "ServerStats" ("Server" + (idx as string))
		if (str == "") then undefined else str
	),
	fn AddServer serverName = (
		local serverCount = GetServerCount() + 1
		SetServerCount serverCount
		SetINISetting serverStatsFile "ServerStats" ("Server" +  (serverCount as string)) serverName
	),
	fn GetServerInfo serverName = (
		local si = ServerInfo()
 
		-- see if server is in the list
		local serverIdx = 0
		for i in 1 to (GetServerCount()) do (
			if ((GetServerName i) == serverName) then (serverIdx = i; exit)
		)
		-- if not, add it and return empty serverInfo struct
		if (serverIdx == 0) then (
			AddServer serverName
		) else (
		-- otherwise get its info
			si.serverName = serverName
			si.infoVersion = (GetINISetting serverStatsFile serverName "InfoVersion") as integer
			si.numProcessors = (GetINISetting serverStatsFile serverName "NumProcessors") as integer
			si.processorSpeed = (GetINISetting serverStatsFile serverName "ProcessorSpeed") as integer
			si.processorFamily = (GetINISetting serverStatsFile serverName "ProcessorFamily") as integer
			si.processorModel = (GetINISetting serverStatsFile serverName "ProcessorModel") as integer
			si.physicalMemory = (GetINISetting serverStatsFile serverName "PhysicalMemory") as integer
			si.lockid = (GetINISetting serverStatsFile serverName "LockID") as integer
		)
		si
	),
	fn UpdateServerInfo serverName = (
		local servInfo = GetServerInfo serverName
 
		if (servInfo.infoVersion < (GetMasterInfoVersion())) then (
			local sysInfo = GetSysInfo()
			if (sysInfo != undefined) then (
				SetINISetting serverStatsFile serverName "InfoVersion" (GetMasterInfoVersion() as string)
				SetINISetting serverStatsFile serverName "NumProcessors" (sysInfo[2].count as string)
				SetINISetting serverStatsFile serverName "ProcessorSpeed" (sysInfo[2][1][1] as string)
				SetINISetting serverStatsFile serverName "ProcessorFamily" (sysInfo[2][1][2] as string)
				SetINISetting serverStatsFile serverName "ProcessorModel" (sysInfo[2][1][3] as string)
				SetINISetting serverStatsFile serverName "PhysicalMemory" ((sysInfo[3]/1023) as string)
				SetINISetting serverStatsFile serverName "LockID" (hardwareLockID as string)
				SetINISetting serverStatsFile serverName "LastUpdateFailed" "0"
 
				return true
			) else (
				SetINISetting serverStatsFile serverName "LastUpdateFailed" "1"
			)
		)
 
		return false
	)
)
 
-----------------------------------------------------------------------------------------------------
-- Moderate cached ServerStats... just caches the server stats name list
-----------------------------------------------------------------------------------------------------
struct ServerStats_ModerateCache (
	serverStatsFile = "R:\\MAX3master\\ServerStats.ini",
	serverNameCache = #(),
	fn GetMasterInfoVersion = (
		local ver = GetINISetting serverStatsFile "ServerStats" "MasterInfoVersion"
		ver as integer
	),
	fn GetServerCount = (
		local cnt = GetINISetting serverStatsFile "ServerStats" "ServerCount"
		cnt as integer
	),
	fn SetServerCount cnt = (
		SetINISetting serverStatsFile "ServerStats" "ServerCount" (cnt as string)
	),
	fn GetServerName idx = (
		local str = GetINISetting serverStatsFile "ServerStats" ("Server" + (idx as string))
		if (str == "") then undefined else str
	),
	fn UpdateNameCache = (
		local serverCount = GetServerCount()
		serverNameCache = for i in 1 to serverCount collect (GetServerName i)
 
		OK
	),
	fn AddServer serverName = (
		local serverCount = GetServerCount() + 1
		SetServerCount serverCount
		SetINISetting serverStatsFile "ServerStats" ("Server" +  (serverCount as string)) serverName
	),
	fn GetServerInfo serverName = (
		local si = ServerInfo()
 
		if (serverNameCache.count == 0) then UpdateNameCache()
 
		-- see if server is in the list
		local serverIdx = 0
		local serverCount = GetServerCount()
		for i in 1 to serverCount do (
			if (serverNameCache[i] == serverName) then (serverIdx = i; exit)
		)
		-- if not, add it and return empty serverInfo struct
		if (serverIdx == 0) then (
			AddServer serverName
		) else (
		-- otherwise get its info
			si.serverName = serverName
			si.infoVersion = (GetINISetting serverStatsFile serverName "InfoVersion") as integer
			si.numProcessors = (GetINISetting serverStatsFile serverName "NumProcessors") as integer
			si.processorSpeed = (GetINISetting serverStatsFile serverName "ProcessorSpeed") as integer
			si.processorFamily = (GetINISetting serverStatsFile serverName "ProcessorFamily") as integer
			si.processorModel = (GetINISetting serverStatsFile serverName "ProcessorModel") as integer
			si.physicalMemory = (GetINISetting serverStatsFile serverName "PhysicalMemory") as integer
			si.lockid = (GetINISetting serverStatsFile serverName "LockID") as integer
		)
		si
	),
	fn UpdateServerInfo serverName = (
		local servInfo = GetServerInfo serverName
 
		if (servInfo.infoVersion < (GetMasterInfoVersion())) then (
			local sysInfo = GetSysInfo()
			if (sysInfo != undefined) then (
				SetINISetting serverStatsFile serverName "InfoVersion" (GetMasterInfoVersion() as string)
				SetINISetting serverStatsFile serverName "NumProcessors" (sysInfo[2].count as string)
				SetINISetting serverStatsFile serverName "ProcessorSpeed" (sysInfo[2][1][1] as string)
				SetINISetting serverStatsFile serverName "ProcessorFamily" (sysInfo[2][1][2] as string)
				SetINISetting serverStatsFile serverName "ProcessorModel" (sysInfo[2][1][3] as string)
				SetINISetting serverStatsFile serverName "PhysicalMemory" ((sysInfo[3]/1023) as string)
				SetINISetting serverStatsFile serverName "LockID" (hardwareLockID as string)
				SetINISetting serverStatsFile serverName "LastUpdateFailed" "0"
 
				return true
			) else (
				SetINISetting serverStatsFile serverName "LastUpdateFailed" "1"
			)
		)
 
		return false
	)
)
 
-----------------------------------------------------------------------------------------------------
-- Aggressive cached ServerStats... copies serverStatsFile local + server name cache
-----------------------------------------------------------------------------------------------------
struct ServerStats_HeavyCache (
	masterServerStatsFile = "R:\\MAX3master\\ServerStats.ini",
	localServerStatsFile = (GetDir #plugcfg) + "\\ServerStats.ini",
	serverNameCache = #(),
	fn IncrementUpdateNumber = (
		local ver = (GetINISetting masterServerStatsFile "UpdateNumber" "UpdateNumber") as integer
		ver += 1
		SetINISetting masterServerStatsFile "UpdateNumber" "UpdateNumber" (ver as string)
	),
	fn GetMasterInfoVersion = (
		local ver = GetINISetting masterServerStatsFile "ServerStats" "MasterInfoVersion"
		ver as integer
	),
	fn GetServerCount = (
		local cnt = GetINISetting masterServerStatsFile "ServerStats" "ServerCount"
		cnt as integer
	),
	fn SetServerCount cnt = (
		SetINISetting masterServerStatsFile "ServerStats" "ServerCount" (cnt as string)
		IncrementUpdateNumber()
	),
	fn GetServerName idx = (
		local str = GetINISetting localServerStatsFile "ServerStats" ("Server" + (idx as string))
		if (str == "") then undefined else str
	),
	fn UpdateNameCache = (
		local serverCount = GetServerCount()
		serverNameCache = for i in 1 to serverCount collect (GetServerName i)
 
		OK
	),
	fn AddServer serverName = (
		local serverCount = GetServerCount() + 1
		SetServerCount serverCount
		SetINISetting masterServerStatsFile "ServerStats" ("Server" +  (serverCount as string)) serverName
		IncrementUpdateNumber()
	),
	fn GetServerInfo serverName = (
		local si = ServerInfo()
 
		if (serverNameCache.count == 0) then UpdateNameCache()
 
		-- see if server is in the list
		local serverIdx = 0
		local serverCount = GetServerCount()
		for i in 1 to serverCount do (
			if (serverNameCache[i] == serverName) then (serverIdx = i; exit)
		)
		-- if not, add it and return empty serverInfo struct
		if (serverIdx == 0) then (
			AddServer serverName
		) else (
		-- otherwise get its info
			si.serverName = serverName
			si.infoVersion = (GetINISetting localServerStatsFile serverName "InfoVersion") as integer
			si.numProcessors = (GetINISetting localServerStatsFile serverName "NumProcessors") as integer
			si.processorSpeed = (GetINISetting localServerStatsFile serverName "ProcessorSpeed") as integer
			si.processorFamily = (GetINISetting localServerStatsFile serverName "ProcessorFamily") as integer
			si.processorModel = (GetINISetting localServerStatsFile serverName "ProcessorModel") as integer
			si.physicalMemory = (GetINISetting localServerStatsFile serverName "PhysicalMemory") as integer
			si.lockid = (GetINISetting localServerStatsFile serverName "LockID") as integer
		)
		si
	),
	fn SyncServerStatsFile = (
		local localVer = (GetINISetting localServerStatsFile "UpdateNumber" "UpdateNumber") as integer
		local masterVer = (GetINISetting masterServerStatsFile "UpdateNumber" "UpdateNumber") as integer
		if (localVer != masterVer) then
		(
			DeleteFile localServerStatsFile
			local res = CopyFile masterServerStatsFile localServerStatsFile
			if (NOT res) then
			(
				MessageBox "Something fucked up in Sync'ing local stats file.\n\nComplain to John B." title:"Error"
			)
		)
 
		OK
	),
	fn UpdateServerInfo serverName = (
		-- Sync cached stat file (GetServerInfo below uses it)
		SyncServerStatsFile()
 
		-- Check if stat info is out of date, and needs to be updated
		local servInfo = GetServerInfo serverName
 
		local res = TRUE
		if (servInfo.infoVersion < (GetMasterInfoVersion())) then
		(
			local sysInfo = GetSysInfo()
			res = if (sysInfo != undefined) then
			(
				SetINISetting masterServerStatsFile serverName "InfoVersion" (GetMasterInfoVersion() as string)
				SetINISetting masterServerStatsFile serverName "NumProcessors" (sysInfo[2].count as string)
				SetINISetting masterServerStatsFile serverName "ProcessorSpeed" (sysInfo[2][1][1] as string)
				SetINISetting masterServerStatsFile serverName "ProcessorFamily" (sysInfo[2][1][2] as string)
				SetINISetting masterServerStatsFile serverName "ProcessorModel" (sysInfo[2][1][3] as string)
				SetINISetting masterServerStatsFile serverName "PhysicalMemory" ((sysInfo[3]/1023) as string)
				SetINISetting masterServerStatsFile serverName "LockID" (hardwareLockID as string)
				SetINISetting masterServerStatsFile serverName "LastUpdateFailed" "0"
 
				TRUE
			) else (
				SetINISetting masterServerStatsFile serverName "LastUpdateFailed" "1"
				FALSE
			)
 
			-- We've written to the master, update the UpdateNumber
			IncrementUpdateNumber()
		)
 
		-- Re-sync cached stat file, in case something above changed
		SyncServerStatsFile()
 
		return res
	)
)
 
--ServerStats = ServerStats_NoCache
--ServerStats = ServerStats_ModerateCache
ServerStats = ServerStats_HeavyCache
 
fn PrintMachineStats_SortServerInfo a b sortKey: = (
	local ap = GetProperty a sortKey
	local bp = GetProperty b sortKey
	return (
		if (ap == bp) then 0
		else if (ap < bp) then -1
		else 1
	)
)
 
fn PrintMachineStats sortBy:#serverName = (
 
	local ss = ServerStats()
 
	local masterVersion = ss.GetMasterInfoVersion()
 
	local servers = for i in 1 to ss.GetServerCount() collect
	(
		local sName = ss.GetServerName i
		ss.GetServerInfo sName
	)
 
	qSort servers PrintMachineStats_SortServerInfo sortKey:sortBy
 
	Format " Name                Type                Speed  Memory    LockID    \n"
	for si in servers do (
		local fmtStr = if (si.infoVersion < masterVersion) then "*%%%%%\n" else " %%%%%\n"
		ColumnFormat fmtStr #(	si.serverName,
								(GetProcessorName si.numProcessors si.processorFamily si.processorModel),
								si.processorSpeed,
								si.physicalMemory,
								si.lockid) #(20,20,7,10,10)
	)
	OK
)
 
---------------------------------------------------------------------
-- Time Definitions
---------------------------------------------------------------------
 
fn GetFormattedTime totSec = (
	local tmp, h, m, s
 
	h = (totSec / 3600) as integer
	tmp = mod totSec 3600
	m = (tmp / 60) as integer
	s = (mod tmp 60) as integer
 
	return ( (h as string) + "h:" + (m as string) + "m:" + (s as string) + "s" )
)
 
struct LapTimer (
	lapTimes = #(),
	totTime = 0,
	days = 0,
	startTime = undefined,
	endTime = undefined,
 
	fn Reset = (
		lapTimes = #()
		totTime = 0
		days = 0
		startTime = undefined
		endTime = undefined
	),
 
	fn Start = (
		startTime = TimeStamp()
	),
 
	fn CleanStart = (
		gc()
		Start()
	),
 
	fn GetLastTime = (
		if (lapTimes.count >= 1) then (
			lapTimes[lapTimes.count]
		) else (
			-1
		)
	),
 
	fn GetLapTime n = (
		if (n >= 1) AND (n <= lapTimes.count) then (
			lapTimes[n]
		) else (
			-1
		)
	),
 
	fn GetAllTimes = (
		lapTimes
	),
 
	fn GetNumLaps = (
		lapTimes.count
	),
 
	fn GetTotalTime = (
		totTime
	),
 
	fn Lap = (
		if (startTime != undefined) then
		(
			endTime = TimeStamp()
 
			-- see if we've timed over midnight
			if (endTime < startTime) then (
				days += 1
				endTime += days * 86400000
			)
			local lastTime = ((endTime - startTime) / 1000.0) - totTime
			append lapTimes lastTime
			totTime += lastTime
 
			lastTime
		) else (
			0
		)
	),
 
	fn Stop = (
		Lap()
		startTime = undefined
		GetTotalTime()
	)
)
 
fn IsDateNewer dateStrA dateStrB =
(
	try
	(
		local dateA = DateAsPoint3 dateStrA
		local dateB = DateAsPoint3 dateStrB
 
		-- check for same date
		if (dateA == dateB) then
		(
			-- if same, compare seconds
			local secA = DateAsSeconds dateStrA
			local secB = DateAsSeconds dateStrB
 
			return (secA > secB)
		) else (
			-- if different, see which has the newer date
			if (dateA.x == dateA.x) then (
				if (dateA.y == dateA.y) then (
					return (dateA.z > dateB.z)
				) else (
					return (dateA.y > dateB.y)
				)
			) else (
				return (dateA.x > dateB.x)
			)
		)
	) catch ( undefined )
)
 
fn GetCurrentMilitaryTime =
(
	try (
		local ar = FilterString localTime " "
		local isPM = ar[3] == "PM"
		ar = FilterString ar[2] ":"
 
		for i in 1 to ar.count do ar[i] = ar[i] as integer
		if (isPM) then ar[1] += 12
 
		ar
	) catch (
		undefined
	)
)
 
fn TimeIt expr iter runs:3 =
(
	local lt = LapTimer()
	local runTimes = for ri in 1 to runs collect
	(
		lt.CleanStart()
		for i in 1 to iter do expr
		local t = lt.Stop()
		format "Run %: %\n" ri t
		t
	)
 
	local aveTime = 0.
	for t in runTimes do aveTime += t
	aveTime /= runs
	format "Average: %\n" aveTime
 
	runTimes
)
 
---------------------------------------------------------------------
-- UI Definitions
---------------------------------------------------------------------
 
fn ValidListboxSel lb = (
	(lb.selection >= 1) AND
	(lb.selection <= lb.items.count)
)
 
global jbCommandPanelTaskModeStack = #()
 
fn PushCommandPanelTaskMode panelMode =
(
	local panelState = GetCommandPanelTaskMode()
	append jbCommandPanelTaskModeStack panelState
	if (panelState != panelMode) then (
		SetCommandPanelTaskMode mode:panelMode
		return TRUE
	)
	FALSE
)
 
fn PopCommandPanelTaskMode =
(
	local stackCount = jbCommandPanelTaskModeStack.count
	if (stackCount != 0) then (
		local stackState = jbCommandPanelTaskModeStack[stackCount]
		local panelState = GetCommandPanelTaskMode()
		if (stackState != panelState) then
			SetCommandPanelTaskMode mode:stackState
		DeleteItem jbCommandPanelTaskModeStack stackCount
		return TRUE
	)
	FALSE
)
 
fn IntersectPickPoint obj pnt = (
	local r = Ray [0,0,0] [1,0,0]
 
	if (gw.IsPerspView()) then (
		local viewPos = (Inverse(getViewTM())).row4
		r.pos = viewPos
		r.dir = Normalize (pnt-viewPos)
	) else (
	   local coordSysTM = Inverse(getViewTM())
	   local viewDir = coordSysTM.row3
	   r.pos = pnt + (viewDir * 9999999)
	   r.dir = -viewDir
	)
 
	IntersectRay obj r
)
 
-- EOF ------------------------------------ Thanks For Visiting... --