/*****************************************************************************/
/********************************************** Paths to folders and files **/
/***************************************************************************/
/* Data */
global s_gozobjectpath          = "C:/Users/Public/Pixologic/GoZBrush/GoZ_ObjectPath.txt"
global s_gozobjectlist          = "C:/Users/Public/Pixologic/GoZBrush/GoZ_ObjectList.txt"
global s_gozmakeobjectpathapp   = "C:/Users/Public/Pixologic/GoZBrush/GoZMakeObjectPath.exe"
global s_gozbrushapp            = "C:/Users/Public/Pixologic/GoZApps/Max/GoZBrushFromMax.exe"
global s_gozinputfile           = "C:/Users/Public/Pixologic/GoZApps/Max/comZ2M.dat"



/*****************************************************************************/
/************************************************** Misc utility functions **/
/***************************************************************************/
/* Data */
global s_defaultFileTimeout = 200

global s_UVsAreVFlipped = true   -- see doFlipV_ZBrushTo3DS in GoZServer.cpp

global s_importExtraData = true    -- debug variable for speed testing
global s_importMaterial = true    -- debug variable for speed testing

global s_verbose = false
global s_verboseMaterial = false
global s_verboseModifierChg = false
global s_verboseChrono = false
global s_verboseMoveVtx = false
global s_verboseSubToolName = false
global s_verboseMenu = false

global s_forceMentalRay = true


-- ********* Path comparison ***********
function ComparePath path1 path2 =
(
	local result = false
	local asc1 = 0
	local asc2 = 0
	local size1 = path1.count
	local size2 = path2.count
	if (size1 == size2) then (
		result = true
		for i = 1 to size1 while (result) do
		(
			asc1 = (bit.charAsInt path1[i])
			asc2 = (bit.charAsInt path2[i])
			if (asc1 != asc2) then (
				result = false
				if ((asc1>=65) and (asc1<=90) and ((asc1+32)==asc2)) then (
					result = true
				)
				if ((asc2>=65) and (asc2<=90) and ((asc2+32)==asc1)) then (
					result = true
				)
				if ((asc1==47) and (asc2==92)) then (
					result = true
				)
				if ((asc2==47) and (asc1==92)) then (
					result = true
				)
			)
		)
	)
	result
)

-- ********** Timing *******************
global s_startTimeArray = undefined
function PrintCurrentTime preString postString =
(
	if (s_verboseChrono) then (
		curTimeArray = getLocalTime()
		format "CurTime % : % h % m % s % ms % \n" preString curTimeArray[5] curTimeArray[6] curTimeArray[7] curTimeArray[8] postString
	)
)

function StartChrono =
(
	if (s_verboseChrono) then (
		s_startTimeArray = getLocalTime()
		PrintCurrentTime "StartChrono" ""
	)
)

function StopChrono =
(
	if (s_verboseChrono) then (
		endTimeArray = getLocalTime()
		PrintCurrentTime "StopChrono" "" 

		hours = endTimeArray[5] - s_startTimeArray[5]
		minutes = endTimeArray[6] - s_startTimeArray[6]
		seconds = endTimeArray[7] - s_startTimeArray[7]
		miliseconds = endTimeArray[8] - s_startTimeArray[8]
		seconds = seconds + 60 * ( minutes + 60 * hours ) 
		format "chrono : % s % ms \n" miliseconds seconds
	)
)




/* Functions */
function safeOpenFileTimeout filename mode timeout =
(
	local file = fopen filename mode
	local end = timeStamp() + timeout
	while ((file==undefined) and (timeStamp()<end)) do
	(
		sleep 0.01
		file = fopen filename mode
	)
	file
)

function safeOpenFile filename mode =
(
    local file = safeOpenFileTimeout filename mode s_defaultFileTimeout
    file
)

function isEndOfFile file =
(
	local atEnd = false
	local pos = ftell file
	local size
	fseek file 0 #seek_end
	size = ftell file
	if (pos == size) then
		atEnd = true
	else
		fseek file pos #seek_set
	atEnd
)

function writePaddingData file size =
(
	local paddedSize = (4*Int((size+3)/4))-1
	local i
	for i = size to paddedSize do
		WriteByte file 0
	undefined
)

-- write a string into a file without the NULL car at the end !
function writeStringToFile file str =
(
    local size = str.count
    local asc = 0
	for i = 1 to size do
	(
		asc = (bit.charAsInt str[i])
	    WriteByte file asc
	)
	str
)

function readFileAsString file =
(
    local str = ""
    local size = 0
    local asc = 0
	fseek file 0 #seek_end
	size = ftell file
	fseek file 0 #seek_set
	for i = 1 to size do
	(
	    asc = ReadByte file
	    str = str + (bit.intAsChar asc)
	)
	str
)

function readPaddingData file size =
(
	local paddedSize = (4*Int((size+3)/4))-1
	local i
	for i = size to paddedSize do
		ReadByte file 0
	undefined
)

function getVersion = --return which version the user has, 11000 = max2009, 12000 = max 2010
(
	ver = maxversion()
	return ver[1]
)


/*****************************************************************************/
/********************************************************** Options Rollout */
/***************************************************************************/
 -- ... a remettre from deprecated....



/*****************************************************************************/
/************************************************************* GoZ objects **/
/***************************************************************************/
/* Structures */
struct ZBrushObject
(
    /* Data */
	m_subToolName,

    /* Functions */
	fn Clear =
	(
		m_subToolName = undefined
	),

	fn IsValid =
	(
		local ret = false
		if (m_subToolName != undefined) then
			ret = true
		ret
	),

    function GetShortName =
    (
        local str = ""
        local strArray = filterString m_subToolName "/\\"
        local i
        local n = strArray.count
        for i = 1 to n while (str.count == 0) do
        (
          str = copy strArray[1+n-i]
        )
if (s_verboseSubToolName) then format "Get short name for [%] = (%)\n" m_subToolName str
        str
    ),

    function CreateSubToolName nodeName =
    (
        local objectPath = undefined
if (s_verboseSubToolName) then format "CreateSubToolName called..."
		file = safeOpenFile s_gozobjectpath "w"
		if (file == undefined) then	(
		    m_subToolName = copy nodeName
if (s_verboseSubToolName) then format "\n   -> Error: cannot write the short name [%] in file [%]" nodeName s_gozobjectpath
		) else	(
			WriteString file nodeName
			fclose file
if (s_verboseSubToolName) then format "\n   -> Wrote the short name [%] in file [%]" nodeName s_gozobjectpath

            ShellLaunch s_gozmakeobjectpathapp ""
            Sleep 0.01
if (s_verboseSubToolName) then format "\n   -> Launched the application [%]" s_gozmakeobjectpathapp

            local idone = false
            local i
            m_subTooName = undefined
            for i = 1 to 100 while (idone==false) do
            (
			    Sleep 0.1
        		file = safeOpenFile s_gozobjectpath "r"
        		if (file == undefined) then
        		(
if (s_verboseSubToolName) then format "\n   -> Cannot open the file [%] for reading" s_gozobjectpath
                ) else (
        		    objectPath = readFileAsString file
        		    fclose file
if (s_verboseSubToolName) then format "\n   -> Read the object path [%] in file [%]" objectPath s_gozobjectpath

                    if (objectPath == undefined) then
                    (
if (s_verboseSubToolName) then format "\n    \-> The object path in file [%] is undefined" s_gozobjectpath
                    ) else (
                        if (objectPath == nodeName) then
                        (
if (s_verboseSubToolName) then format "\n    \-> The object path [%] in file [%] is same as node name [%]" objectPath s_gozobjectpath nodeName
                        ) else (
if (s_verboseSubToolName) then format "\n    \-> The object path [%] was successfully created\n" objectPath
                            m_subToolName = copy objectPath
            		        idone = true
            		    )
        		    )
        		)
        	)
        	if (m_subToolName == undefined) then
        	(
        	    m_subToolName = copy nodeName
        	)
		)
    )
)

struct GoZMaxObject
(
    /* Data */
	m_node,
	m_modifier, /* If undefined, then it means that m_node.baseObject is the right object */

    /* Functions */
	function Clear =
	(
		m_node = undefined
if (s_verboseModifierChg) then format "*** m_modifier:(Clear) % -> undefined \n" m_modifier
		m_modifier = undefined
	),

	function UpdateValidity =
	(
		/* If the node is not valid then de-references the node and its modifier */
		if (not (IsValidNode m_node)) then
		(
			m_node = undefined
if (s_verboseModifierChg) then format "*** m_modifier: % -> undefined (UpdateValidity) \n" m_modifier
			m_modifier = undefined
		)

		/* If the node is valid but does not contain the referenced modifier, then de-references the modifier */
		else if (m_modifier != undefined) then (
			local modifier = undefined
			--local modifier2 = undefined
			for modifier2 in m_node.modifiers while (modifier==undefined) do (
				if (modifier2 == m_modifier) then modifier = m_modifier
			)
			if (modifier != m_modifier) then (
if (s_verboseModifierChg) then format "*** m_modifier: % -> undefined (UpdateValidity) \n" m_modifier
				m_modifier = undefined
			)
		)
	),

	function IsValid =
	(
		local ret = false
		UpdateValidity()
		if (m_node != undefined) then
			ret = true
		ret
	),
	
	function IsAMesh =
	(
	    local ret = false
	    if (m_node!=undefined) and (isKindOf m_node GeometryClass) then
	        ret = true
	    ret
	)
)

struct GoZObject
(
	m_zbrushObject,
	m_maxObject,
    m_materialCreated,
    
	fn Clear =
	(
		m_zbrushObject.Clear()
		m_maxObject.Clear()
		m_materialCreated = false
	),

	fn IsValid =
	(
		local ret = false
		if ((m_zbrushObject!=undefined) and m_zbrushObject.IsValid() and (m_maxObject!=undefined) and m_maxObject.IsValid()) then
			ret = true
		ret
	),

	fn UpdateValidity =
	(
		if (m_maxObject != undefined) then
			m_maxObject.UpdateValidity()
	),

	fn IsMaxObject maxObj =
	(
		local result = false
		if (((m_maxObject==undefined) and (maxObj==undefined)) or
			((m_maxObject!=undefined) and (maxObj!=undefined) and (maxObj.m_node==m_maxObject.m_node))) then
		(
			result = true
		)
		result
	),

	fn IsZBrushObject zbrushObject =
	(
		local result = false
		if ((m_zbrushObject==undefined) and (zbrushObject==undefined)) then (
			result = true
		) else if ((m_zbrushObject!=undefined) and (zbrushObject!=undefined) and (ComparePath zbrushObject.m_subToolName m_zbrushObject.m_subToolName)) then (
			result = true
		)
		result
	)
/*
		) else if ((m_zbrushObject!=undefined) and (zbrushObject!=undefined) and (zbrushObject.m_subToolName==m_zbrushObject.m_subToolName)) then (
*/
)

/* Data */
global s_severalMaxObjects = GoZMaxObject()
s_severalMaxObjects.Clear()

/* Functions */
function GetSelectedMaxObject =
(
	max modify mode
	local maxObj = undefined
	local selObj = modPanel.getCurrentObject()
	if (selObj==undefined) then (
		local selArray = selection as array
		if ((selArray!=undefined) and (selArray.count>0)) then
			maxObj = s_severalMaxObjects
	) else (
		maxObj = GoZMaxObject()
		maxObj.m_node = $						-- $ is the selected node
		if (isKindOf selObj GeometryClass) then (
if (s_verboseModifierChg) then format "*** m_modifier: % -> undefined (GetSelectedMaxObject) \n" maxObj.m_modifier
			maxObj.m_modifier = undefined
		) else (
if (s_verboseModifierChg) then format "*** m_modifier: % -> % (GetSelectedMaxObject) \n" maxObj.m_modifier selObj
			maxObj.m_modifier = selObj
		)
	)
	maxObj
)

function SelectMaxObj maxObj =
(
	max modify mode
	if (maxObj == undefined) then
	(
		clearNodeSelection redraw:false
	)
	else
	(
		if (maxObj.m_modifier != undefined) then
			modPanel.setCurrentObject(maxObj.m_modifier)
		else
		(
			if (maxObj.m_node != undefined) then
				modPanel.setCurrentObject(maxObj.m_node.baseObject)
			else
				clearNodeSelection redraw:false
		)
	)
	undefined
)

function ExportSelectedMaxObject_3ds filename =
(
	exportFile filename selectedOnly:true
)

function ExportMaxObject_xmax fileName maxObj =
(
	file = safeOpenFile fileName "wb"

if (s_verbose AND file == undefined) then format "Cannot open (wb) : %" fileName
PrintCurrentTime "Start Export" ""
	if ((maxObj!=undefined) and (maxObj!=s_severalMaxObjects) and maxObj.IsAMesh()) then (
		local storedShowEndResult = showEndResult
		showEndResult = false

		local zeditMesh = snapshotAsMesh maxObj.m_node
		local vertexCount = getNumVerts zeditMesh
		local uvCount = getNumTVerts zeditMesh
		local faceCount = getNumFaces zeditMesh
		local indexCount = 3*faceCount
		local vertex = point3 0.1 0.1 0.1
		local uv
		local triangle = point3 1 2 3
		local materialId
		local smoothingGroup
		local i

		/* Writes vertices to the file. */
		WriteLong file 1
		WriteLong file vertexCount
		for i = 1 to vertexCount do
		(
			vertex = getVert zeditMesh i
			WriteFloat file vertex.x
			WriteFloat file vertex.y
			WriteFloat file vertex.z
		)

		/* Writes faces to the file. */
		WriteLong file 2
		WriteLong file indexCount
		for i = 1 to faceCount do
		(
			triangle = getFace zeditMesh i
			triangle = copy triangle
			triangle.x = triangle.x - 1
			triangle.y = triangle.y - 1
			triangle.z = triangle.z - 1
			WriteLong file triangle.x
			WriteLong file triangle.y
			WriteLong file triangle.z
		)

		/* Writes per-face edge-visibility to the file. */
		WriteLong file 3
		WriteLong file indexCount
		for i = 1 to faceCount do
		(
			visibility = getEdgeVis zeditMesh i 1
			if (visibility != false) then
				WriteByte file 1
			else
				WriteByte file 0
			visibility = getEdgeVis zeditMesh i 2
			if (visibility != false) then
				WriteByte file 1
			else
				WriteByte file 0
			visibility = getEdgeVis zeditMesh i 3
			if (visibility != false) then
				WriteByte file 1
			else
				WriteByte file 0
		)
		writePaddingData file (3*faceCount)
		/* Writes per-face material-id to the file. */
		WriteLong file 4
		WriteLong file faceCount
		for i = 1 to faceCount do
		(
			materialId = getFaceMatID zeditMesh i
			WriteShort file materialId
		)
		writePaddingData file (2*faceCount)

		/* Writes per-face smoothing-group to the file. */
		WriteLong file 5
		WriteLong file faceCount
		for i = 1 to faceCount do
		(
			smoothingGroup = getFaceSmoothGroup zeditMesh i
			WriteLong file smoothingGroup
		)

		/* Writes UVs if needed. */
		if (uvCount > 0) then
		(
			/* Writes UV-vertices to the file. */
			WriteLong file 6
			WriteLong file uvCount
			for i = 1 to uvCount do
			(
				uv = getTVert zeditMesh i
				WriteFloat file uv.x
				WriteFloat file uv.y
			)

			/* Writes UV-indices to the file. */
			WriteLong file 7
			WriteLong file indexCount
			for i = 1 to faceCount do
			(
				triangle = getTVFace zeditMesh i
				triangle = copy triangle
				triangle.x = triangle.x - 1
				triangle.y = triangle.y - 1
				triangle.z = triangle.z - 1
				WriteLong file triangle.x
				WriteLong file triangle.y
				WriteLong file triangle.z
			)

			--format "----- nodeMaterial = %\n" maxObj.m_node.material
			--format "nodeMaterial class = %\n" (classof maxObj.m_node.material)
			--showProperties maxObj.m_node.material
			
			local diffMapProp = undefined 
			if (isProperty maxObj.m_node.material "diffuseMap") then getProperty maxObj.m_node.material "diffuseMap"
			if (diffMapProp != undefined) then (
				WriteLong file 8
				local count = diffMapProp.count+1
				WriteLong file count
				WriteString file diffMapProp
				writePaddingData file count 
format "diffuseMap : % \n" maxObj.m_node.material.diffuseMap
			) else (
format "NO diffuseMap \n" 
			)
			
			/* NB: we think it is useless to transfer Bump And Displacement from 3DS to ZBrush !
			if (isProperty maxObj.m_node.material "bumpMap") then (
				local bumpMapFileName = undefined
				if (isProperty maxObj.m_node.material.bumpMap "normal_map") then (
					local normalMap = maxObj.m_node.material.bumpMap.normal_map
					bumpMapFileName = normalMap.fileName
				)
				
				if (bumpMapFileName != undefined) then (
					WriteLong file 9
					local count = bumpMapFileName.count + 1
					WriteLong file count
					WriteString file bumpMapFileName
					writePaddingData file count 
format "normalMap : % \n" bumpMapFileName
				)
			)*/
			
			/*   CODE not yet written but....
				10:  -- Displacement map 
				(
				    displacementFactor = ReadFloat file
				    local count = ReadLong file
				    displacementMap = ReadString file
				    readPaddingData file count
				)
			*/
				
		)
if (s_verbose) then format "xmax file Exported % vtx  % fac (%) ! \n" vertexCount faceCount fileName
		showEndResult = storedShowEndResult
	)
PrintCurrentTime "End Export" ""
	fclose file
	undefined
)

function ExportSelectedMaxObject_xmax fileName =
(
	local maxObj = GetSelectedMaxObject()
	ExportMaxObject_xmax fileName maxObj
	maxObj
)

-- NB ExportMaxObj is only called in processAction with [export] cmd -> NOT USED !!!!
function ExportMaxObj maxObj fileName =
(
    local step = 0
    break()
	local expObj
	local selObj = GetSelectedMaxObject()
	step = 1
    break()
	SelectMaxObj maxObj
    step = 2
    break()
    local extension3 = substring fileName (fileName.count-3) 3
    format " extension = %" extension3DS 
    if (extension3 == ".3ds") then 
    (
		ExportSelectedMaxObject_3ds fileName
		expObj = selObj;
	) 
	else 
	(
		expObj = ExportSelectedMaxObject_xmax fileName
	)
	
    step = 3
    break()
	SelectMaxObj selObj
    step = 4
    break()
	expObj
)



function MakeEmptyNode node =
(
	local facelist = #()
	local facecount
	facecount = (getNumFaces node)
	facelist.count = facecount
    for i = 1 to facecount do
    	facelist[i] = i
	if (classof node.baseObject == Editable_Poly) then
	  polyop.deleteFaces node facelist
	if (classof node.baseObject == Editable_Mesh) then
	  meshop.deleteFaces node facelist
	update node
/*
	subobjectLevel = 4  -- select faces mode
	max select all
	if (classof node.baseObject == Editable_Poly) then
	  polyop.deleteFaces node
	if (classof node.baseObject == Editable_Mesh) then
	  meshop.deleteFaces node
*/
)
	    	

global s_nodeCreationCase FALSE    -- a return of ImportObject_obj
function ImportObject_obj gozObj fileName =
(
	s_nodeCreationCase = FALSE
	local maxObj = gozObj.m_maxObject
	/*  A MODIFIER ET METTRE plus bas dans LES 3 cases....
	if ((maxObj!=undefined) AND (maxObj!=s_severalMaxObjects)) then
	(
		-- First, select the right modifier it can modify. 
		if (maxObj.m_modifier != undefined) then (
		    local message = "GoZ cannot replace the modifier " + maxObj.m_modifier.name + "!\nDo you want to create a new object?"
		    if (queryBox message beep:false) then
	        (
if (s_verbose) then print "Cannot replace modifier: create a new object\n"
	            maxObj.m_node = undefined
if (s_verboseModifierChg) then format "*** m_modifier: % -> undefined (ImportObject_obj) (because user answered yes to queryBox)\n" m_modifier
	            maxObj.m_modifier = undefined
	        )
    		else
    		(
	    	    maxObj = undefined
if (s_verbose) then print "Modifier set to undefined in ImportObjFile because user answered no to queryBox"
	    	)
		)
    )*/

	if ((maxObj != undefined) AND (maxObj != s_severalMaxObjects)) then
	(
		if (maxObj.m_node != undefined) then
		(
			local modIndex = "BASE"
			if (maxObj.m_modifier != undefined) then
				modIndex = modPanel.getModifierIndex maxObj.m_node maxObj.m_modifier
if (s_verbose) then format "  ZB -> 3DS on node:%  modifier[%]:% (class: %)" (maxObj.m_node.name) modIndex maxObj.m_modifier (classof maxObj.m_modifier)
		)

		/* *********** Import the Obj File ************** */
		local theIniName = undefined
		local saveUseLog = undefined
		local savePreset = undefined
		local saveResetScene = undefined
		local saveSingleMesh = undefined
		local saveAsEditablePoly = undefined
		local saveRetriangulate = undefined
		local saveFlipZY = undefined
		local saveTextureCoords = undefined
		local saveSmoothingGroups = undefined
		local saveFlipNormals = undefined
		local saveNormalsType = undefined
		local saveSmoothAngle = undefined
		local saveConvert = undefined
		local saveObjectScale = undefined
		local saveImportMaterials = undefined
		local theIniName = undefined
		
		local ver = getVersion()
		if (ver >= 12000) then ( -- not available in Max 2009
			theIniName = objImp.getIniName()

			saveUseLog = getIniSetting theIniName "General" "UseLogging"
			savePreset = getIniSetting theIniName "General" "Preset"
			saveResetScene = getIniSetting theIniName "Objects" "ResetScene"
			saveSingleMesh = getIniSetting theIniName "Objects" "SingleMesh"
			saveAsEditablePoly = getIniSetting theIniName "Objects" "AsEditablePoly"
			saveRetriangulate = getIniSetting theIniName "Objects" "Retriangulate"
			saveFlipZY = getIniSetting theIniName "Geometry" "FlipZyAxis"
			saveTextureCoords = getIniSetting theIniName "Geometry" "TextureCoords"
			saveSmoothingGroups = getIniSetting theIniName "Geometry" "SmoothingGroups"
			saveFlipNormals = getIniSetting theIniName "Geometry" "FlipNormals"
			saveNormalsType = getIniSetting theIniName "Geometry" "NormalsType"
			saveSmoothAngle = getIniSetting theIniName "Geometry" "SmoothAngle"
			saveConvert = getIniSetting theIniName "Units/Scale" "Convert"
			saveObjectScale = getIniSetting theIniName "Units/Scale" "ObjScale"
			saveImportMaterials = getIniSetting theIniName "Material" "ImportMaterials"

			setIniSetting theIniName "General" "UseLogging" "0"
			setIniSetting theIniName "General" "Preset" ""
			setIniSetting theIniName "Objects" "ResetScene" "0"
			setIniSetting theIniName "Objects" "SingleMesh" "1"
			setIniSetting theIniName "Objects" "AsEditablePoly" "1"
			setIniSetting theIniName "Objects" "Retriangulate" "0"
			setIniSetting theIniName "Geometry" "FlipZyAxis" "1" 
			setIniSetting theIniName "Geometry" "TextureCoords" "1" 
			setIniSetting theIniName "Geometry" "SmoothingGroups" "1" 
			setIniSetting theIniName "Geometry" "FlipNormals" "0" 
			setIniSetting theIniName "Geometry" "NormalsType" "2" 
			setIniSetting theIniName "Geometry" "SmoothAngle" "60" 
			setIniSetting theIniName "Units/Scale" "Convert" "0" 
			setIniSetting theIniName "Units/Scale" "ObjScale" "1.0" 
			setIniSetting theIniName "Material" "ImportMaterials" "0" 

			--setIniSetting theIniName "Geometry" "CenterPivots" "0"
			--setIniSetting theIniName "Geometry" "Shapes" "0"
			--setIniSetting theIniName "Geometry" "FlipNormals" "0"
			--setIniSetting theIniName "Units/Scale" "Convert" "0"
			--setIniSetting theIniName "Material" "UniqueWireColor" "1"
			--setIniSetting theIniName "Material" "ImportMaterials" "0"
		)
			
-- NOtes problem obj reorder			...
--fallait exporter depuis Max en OBJ sans optims, réimporter en OBJ dans max, convertir en edit poly et re exporter en OBj sans optim

if (s_verbose) then format " control pressed = %\n" (keyboard.controlPressed)
		importFile fileName #noPrompt
		local importedObj = $
if (s_verbose) then format " \n ** ImportObj : classof importedObj = % \n" (classof importedObj)

		if (ver >= 12000) then ( -- not available in Max 2009
			setIniSetting theIniName "General" "UseLogging" saveUseLog
			setIniSetting theIniName "Objects" "ResetScene" saveResetScene
			setIniSetting theIniName "General" "Preset" savePreset
			setIniSetting theIniName "Objects" "SingleMesh" saveSingleMesh
			setIniSetting theIniName "Objects" "AsEditablePoly" saveAsEditablePoly
			setIniSetting theIniName "Objects" "Retriangulate" saveRetriangulate
			setIniSetting theIniName "Geometry" "FlipZyAxis" saveFlipZY
			setIniSetting theIniName "Geometry" "TextureCoords" saveTextureCoords 
			setIniSetting theIniName "Geometry" "SmoothingGroups" saveSmoothingGroups
			setIniSetting theIniName "Geometry" "FlipNormals" saveFlipNormals
			setIniSetting theIniName "Geometry" "NormalsType" saveNormalsType 
			setIniSetting theIniName "Geometry" "SmoothAngle" saveSmoothAngle
			setIniSetting theIniName "Units/Scale" "Convert" saveConvert 
			setIniSetting theIniName "Units/Scale" "ObjScale" saveObjectScale
			setIniSetting theIniName "Material" "ImportMaterials" saveImportMaterials
		)
		
		/* ********* Creates/updates the mesh ********** */
		if (maxObj.m_node == undefined) then (
		
if (s_verbose) then format "  First transfer for this mesh : just rename the newly created mesh.\n" 		
			convertTo importedObj Editable_Poly
			importedObj.name = gozObj.m_zbrushObject.GetShortName()
			maxObj.m_node = importedObj
if (s_verboseModifierChg) then format "*** m_modifier: % -> undefined (ImportObject_obj: maxObj.m_node == undefined case) \n" maxObj.m_modifier
			maxObj.m_modifier = undefined
			s_nodeCreationCase = TRUE

		) else (									 -- (maxObj.m_node != undefined)

			/* 3 cases :
			. A. Same NumVertex, on an Edit_Poly modifier -> tries to MovePoints
			. B. Same Topology, (on an unhandled modifier, or baseMesh) -> collapseTo + transfer geometry (except SmoothingGroups if it exists)
					il faut demander : collapseTo ou creer un nouveau mesh...
			. C. ELSE : Modified Topo, on anything : Delete the old one, Keep and Rename the importedObj.
					il faudrait demander : est ce qu'on creer un nouveau mesh, est ce qu'on efface le mesh et garde le mesh importé OU est ce qu'on fait un collapseTo
			*/
			local processed = FALSE
			local isEditMeshOrPoly = ((isKindOf maxObj.m_modifier Edit_Poly) OR (isKindOf maxObj.m_modifier Edit_Mesh))
			local isEditableMeshOrPoly = ((isKindOf maxObj.m_node Editable_Poly) OR (isKindOf maxObj.m_node Editable_Mesh))
			local newNumVtx = getNumVerts importedObj
			local oldNumVtx = 0
			if (isEditMeshOrPoly) then (
				oldNumVtx = getNumVerts maxObj.m_node
if (s_verboseMoveVtx) then format "oldNumVtx = %  (is EditMeshOrPoly case)" oldNumVtx
			)
			if (isEditableMeshOrPoly) then (
				oldNumVtx = getNumVerts maxObj.m_node
				--oldNumVtx = maxObj.m_modifier.numverts
if (s_verboseMoveVtx) then format "oldNumVtx = %  (is EditableMeshOrPoly case)" oldNumVtx
			)
			local newNumFac = 0
			local oldNumFac = 0
if (s_verbose) then format "  Existing Node case: nodeClass=%  modifierClass=% (% vtx -> %vtx) \n" (classof maxObj.m_node) (classof maxObj.m_modifier) oldNumVtx newNumVtx
				
			-- *** CASE A. ***  (first ask if we want caseA)
			local doVertexMove = 0
			if ((newNumVtx == oldNumVtx) AND isEditMeshOrPoly) then doVertexMove = 1
			--doVertexMove = ((newNumVtx == oldNumVtx) AND (newNumFac == oldNumFac) AND isEditMeshOrPoly)
			if (doVertexMove == 1) then (
if (s_verboseMoveVtx) then format "Edit_Poly modifier case: VTX : % -> %    FAC % -> % \n ASKING ... collapseTo ?" oldNumVtx newNumVtx oldNumFac newNumFac 
				local messageText = "The current transfer target mesh is in the middle of a modifier stack. You have 2 choices:\n"
				messageText = messageText + " 1-(YES): Collapse the stack below the target modifier (=collapseTo) (fast process)\n"
				messageText = messageText + " 2-(NO): Keep the whole modifier stack (very slow process)\n"
				messageText = messageText + "Do you want to do a collapseTo ?"
				--local doCollapseTo = queryBox messageText "Modifier Stack Option" beep:true
				local doCollapseTo = queryBox messageText
				if (doCollapseTo) then doVertexMove = 0
			) 
			
			if (doVertexMove == 1) then (

				local theModifier = maxObj.m_modifier
				local numVtxMoved = 0

				select maxObj.m_node
				max modify mode
				modPanel.setCurrentObject theModifier
				theModifier.SetOperation #Transform
				subobjectLevel = 1

				disableSceneRedraw()
				with redraw off
				undo off (
					local nv = oldNumVtx
					for i = 1 to nv do	(	
						local vtx1 = theModifier.GetVertex i
						local vtx2 = importedObj.GetVertex i
						if (vtx1 != vtx2) then (
							numVtxMoved = numVtxMoved + 1
							local moveVec = vtx2 - vtx1
							theModifier.SetSelection #Vertex #{}
							theModifier.Select #Vertex #{i}
							theModifier.MoveSelection moveVec
 							theModifier.Commit ()         -- Notes : il faut absolument faire le commit ici sinon seulement le dernier point est déplacé!
 						)
					)
				)
				--theModifier.Commit ()
				enableSceneRedraw()
if (s_verboseMoveVtx) then format "    numVtxMoved = %  /  Total NV = % \n" numVtxMoved nv
								
				-- remove the importedObj
				select importedObj 
				max delete
				importedObj = undefined
				select maxObj.m_node
				modPanel.setCurrentObject maxObj.m_modifier
				subobjectLevel = 0
				
				processed = TRUE
			)
			
			-- now when need numFaces 
			if (processed == FALSE) then (
				newNumFac = getNumFaces importedObj
				if (isEditMeshOrPoly) then oldNumFac = getNumFaces maxObj.m_node
				if (isEditableMeshOrPoly) then oldNumFac = getNumFaces maxObj.m_node   -- return numTri or numPolygon depending on Mesh of Poly 
if (s_verbose) then format "comvertToEditablePoly  puis ... FAC % -> % \n" oldNumFac newNumFac 
			)
			local sameTopo = ((newNumFac == oldNumFac) AND (oldNumFac != 0) AND (newNumVtx == oldNumVtx))
			
			-- *** CASE B. (Same Topo, on unhandled modifier or BaseMesh) ***
			if ((processed == FALSE) AND (sameTopo == TRUE) ) then (
				-- collapseTo + transfer mesh + keep SmoothGroups
if (s_verbose) then (
	if (maxObj.m_modifier != undefined) then print "on an unhandled modifier (Same Topo) -> collapseTo + transferGeom."
	else print "on a baseMesh (Same Topo) -> transferGeom."
)	
				
				-- collapseTo
				if (maxObj.m_modifier != undefined) then (
					select maxObj.m_node
					max modify mode				-- open mod panel
					local modifierIndex = modPanel.getModifierIndex maxObj.m_node maxObj.m_modifier
					local collapseOK = maxOps.CollapseNodeTo maxObj.m_node modifierIndex true			-- ca fait un CollapseTo
if (s_verbose) then format "CollapseNodeTo node modIndex=% -> %\n" modifierIndex collapseOK
if (s_verboseModifierChg) then format "*** m_modifier: % -> undefined (ImportObject_obj: collapseTo) \n" maxObj.m_modifier
					maxObj.m_modifier = undefined
					modPanel.setCurrentObject $.baseObject  -- select the baseObject (CollapseTo automatically select the top level)
				)
				
				-- transfer MeshData
				local saveMaterial = maxObj.m_node.material   -- because .attach modifies the material type -> MultiMaterial ...
				MakeEmptyNode maxObj.m_node
				if (classof maxObj.m_node.baseObject == Editable_Poly) then polyop.attach maxObj.m_node importedObj
				if (classof maxObj.m_node.baseObject == Editable_Mesh) then	meshop.attach maxObj.m_node importedObj
				maxObj.m_node.material = saveMaterial
				
				processed = TRUE
			)
			
			-- *** CASE C. ***
			if (processed == FALSE) then
			(
if (s_verbose) then print "more general case: remove the old one + rename the new one."
				-- remove the importedObj
				local prevName = maxObj.m_node.name
				select maxObj.m_node 
				local deleteOK = max delete
if (s_verbose) then format "CollapseNodeTo node modIndex=% -> %\n" modifierIndex collapseOK

				select importedObj
				importedObj.name = prevName
				convertTo importedObj Editable_Poly
				maxObj.m_node = importedObj
if (s_verboseModifierChg) then format "*** m_modifier: % -> undefined (ImportObject_obj: replace by importObjFile case) \n" maxObj.m_modifier
				maxObj.m_modifier = undefined
			)
		)
	)
	maxObj
)


function ImportMaterial_xmax gozObj matFilename nodeCreationCase =
(
--print "--- ImportMaterial_xmax  ---"
	local maxObj = gozObj.m_maxObject
	if ((maxObj!=undefined) and (maxObj!=s_severalMaxObjects)) then
	(
		matfile = safeOpenFile matFilename "rb"
		
		-- Parses the file. 
		local textureMap = undefined
		local normalMap = undefined
		local displacementMap = undefined
		local displacementFactor = 0.1
		local i, j, k
		while (not isEndOfFile matfile) do (
			item = ReadLong matfile
			case item of (
				8:  -- Texture map 
				(
				    local count = ReadLong matfile
				    textureMap = ReadString matfile
				    readPaddingData matfile count
if (s_verbose) then format "Texture map read = %\n" textureMap
				)

				9:  -- Normal map 
				(
				    local count = ReadLong matfile
				    normalMap = ReadString matfile
				    readPaddingData matfile count
if (s_verbose) then format "Normal map read = %\n" normalMap
				)

				10:  -- Displacement map 
				(
				    displacementFactor = ReadFloat matfile
				    local count = ReadLong matfile
				    displacementMap = ReadString matfile
				    readPaddingData matfile count
if (s_verbose) then format "Displacement map read = %\n" displacementMap
				)
			)
		)

		-- Activates Mental-Ray as current renderer
		if (s_forceMentalRay) then (
			mental_ray_Preferences.mrExtensionsActive = true
			if ((classof renderers.current) != mental_ray_renderer) then
				renderers.current = mental_ray_renderer()
		)

		if (nodeCreationCase) then (
			-- Creates the shader 
			local goz_shader = standard()
if (s_verboseMaterial) then format " creation of shader ! % \n" (classof goz_shader)
    		--local mray_material = mental_ray()
			goz_shader.showInViewport = true
			goz_shader.specularLevel = 35
    		goz_shader.glossiness = 25

			-- Diffuse map 
			if (textureMap != undefined) then (
if (s_verboseMaterial) then format " setting texture map \n"
				local bmap = BitmapTexture filename:textureMap
				if (s_UVsAreVFlipped == false) then bmap.coords.V_Tiling = -1		
	    		bmap.coords.Blur = 0.01
    			goz_shader.diffuseMap = bmap
			)

			-- Normal map 
    		if (normalMap != undefined) then (
if (s_verboseMaterial) then format " setting normal map \n"
				local bmap = BitmapTexture filename:normalMap
	    		if (s_UVsAreVFlipped == false) then bmap.coords.V_Tiling = -1    
    			bmap.coords.Blur = 0.01
				-- goz_shader.bumpMap = Normal_Bump normal_map:bmap flipgreen:true
				goz_shader.bumpMap = Normal_Bump normal_map:bmap
				goz_shader.bumpMapAmount = 100.0
			)
			maxObj.m_node.material = goz_shader

    		-- Displacement map 
			if (displacementMap != undefined) then (
if (s_verboseMaterial) then format " setting displacement map \n"
    			local bmap = BitmapTexture filename:displacementMap
				if (s_UVsAreVFlipped == false) then bmap.coords.V_Tiling = -1 
				bmap.coords.Blur = 0.01
	    		local hmap = max_HeightMapDisplacement()
    			hmap.minHeight = -(displacementFactor/2.0)
				hmap.maxHeight = (displacementFactor/2.0)
				hmap.heightMap = bmap
	    		local prevMat = meditMaterials[1]
    			meditMaterials[1] = maxObj.m_node.material
    			if (s_forceMentalRay) then (
						meditMaterials[1].mental_ray__material_custom_attribute.DisplacementLocked = false
	    			meditMaterials[1].mental_ray__material_custom_attribute.Displacement = hmap
    				meditMaterials[1] = prevMat
    			)
			)

		) else (  -- (maxObj.m_node != undefined)
	
			-- Gets the shader 
			local goz_shader = maxObj.m_node.material
			if (goz_shader == undefined) then (
if (s_verboseMaterial) then format " no shader in the node ! \n"
			)
			if (goz_shader != undefined) then (
if (s_verboseMaterial) then format " Existing shader ! % \n" (classof goz_shader)
    			-- Diffuse map 
    			if (textureMap != undefined) then (
        			if (goz_shader.diffuseMap == undefined) then (
       		    		local bmap = BitmapTexture filename:textureMap
	    				if (s_UVsAreVFlipped == false) then bmap.coords.V_Tiling = -1     
		        		bmap.coords.Blur = 0.01
        	    		goz_shader.diffuseMap = bmap
        			) else (
        				goz_shader.diffuseMap.filename = textureMap
        				goz_shader.diffuseMap.reload()
					)
	    		)

				-- Normal map 
	    		if (normalMap != undefined) then (
if (s_verboseMaterial) then format "a normal map is defined %\n" normalMap
        			if (goz_shader.bumpMap == undefined) then (
if (s_verboseMaterial) then format "there were no bump-map: creates a new bump-map %\n" normalMap
		    			local bmap = BitmapTexture filename:normalMap
    	        		if (s_UVsAreVFlipped == false) then bmap.coords.V_Tiling = -1        
        				bmap.coords.Blur = 0.01
    	    			-- goz_shader.bumpMap = Normal_Bump normal_map:bmap flipgreen:true
    	    			goz_shader.bumpMap = Normal_Bump normal_map:bmap
    					goz_shader.bumpMapAmount = 100.0
    				) else (
if (s_verboseMaterial) then format "there were already a bump-map: updates it %\n" normalMap
    					goz_shader.bumpMap.normal_map.filename = normalMap
    					goz_shader.bumpMap.normal_map.reload()
    				)
				)

    			-- Displacement map 
    			if (displacementMap != undefined) then (
if (s_verboseMaterial) then format "Displacement map found: updates the material... % \n" displacementMap
	    			local prevMat = meditMaterials[1]
	    			meditMaterials[1] = maxObj.m_node.material
	    			if (s_forceMentalRay) then (
    					meditMaterials[1].mental_ray__material_custom_attribute.DisplacementLocked = false
    					if (meditMaterials[1].mental_ray__material_custom_attribute.Displacement == undefined) then (
if (s_verboseMaterial) then format "No previous displacement map: creates a new one... % \n" displacementMap
	        				local bmap = BitmapTexture filename:displacementMap
		    				if (s_UVsAreVFlipped == false) then bmap.coords.V_Tiling = -1   
								bmap.coords.Blur = 0.01
		        		local hmap = max_HeightMapDisplacement()
            		hmap.minHeight = -(displacementFactor/2.0)
    	    			hmap.maxHeight = (displacementFactor/2.0)
								hmap.heightMap = bmap
		        		meditMaterials[1].mental_ray__material_custom_attribute.Displacement = hmap
		        	)
					) else (
						if (s_forceMentalRay) then (
if (s_verboseMaterial) then format "Previous displacement map found: just updates the filename and displacement factor... % \n" displacementMap
            			meditMaterials[1].mental_ray__material_custom_attribute.Displacement.minHeight = -(displacementFactor/2.0)
    	    			meditMaterials[1].mental_ray__material_custom_attribute.Displacement.maxHeight = (displacementFactor/2.0)
		        		meditMaterials[1].mental_ray__material_custom_attribute.Displacement.heightMap.filename = displacementMap
		        		meditMaterials[1].mental_ray__material_custom_attribute.Displacement.heightMap.reload()
		        	)
					)
 	    		meditMaterials[1] = prevMat
				)
			)
		)
		
		fclose matfile
	)
	undefined
)

-- parameters read in the xmax file
global s_textureMapFile = undefined
global s_normalMapFile = undefined
global s_displacementMapFile = undefined
global s_displacementFactor = 0.1

-- inputs for updateMaterials functions 
global s_materialToUpdate = undefined
global s_materialToUpdate_justReload = false


-- ---------------------------- Standard Material ------------------------------
function setupStandardMaterial gozObj =  -- updates s_viewportMaterial from loaded Maps
(
	if (s_verboseMaterial) then format "setupStandardMaterial called!\n"
	local theMaterial = s_materialToUpdate
	
	if ((IsKindOf theMaterial standard) == false) then (
		if (s_verboseMaterial) then format "updateStandardMaterial: bad material type (%)\n" (classof theMaterial)
	)
	
	if (isKindOf theMaterial Standard) then (   -- good material type

		theMaterial.showInViewport = true
		theMaterial.specularLevel = 35
		theMaterial.glossiness = 25
		-- diffuse map
		if ((s_textureMapFile != undefined) AND (doesFileExist s_textureMapFile)) then (
			if (s_materialToUpdate_justReload) then (
	 			if (IsKindOf theMaterial.diffuseMap BitmapTexture) then (
					if (s_verboseMaterial) then format " diffuseMap : just rename and reload texture file\n"
					theMaterial.diffuseMap.filename = s_textureMapFile
					theMaterial.diffuseMap.reload()
				) else (
					if (s_verboseMaterial) then format " diffuseMap : cannot just_reload \n"
				)
			) else (										-- create the textures
				if (s_verboseMaterial) then format " create BitmapTexture for diffuseMap\n"
				theMaterial.diffuseMap = BitmapTexture()
				theMaterial.diffuseMap.filename = s_textureMapFile
				if (s_UVsAreVFlipped == false) then theMaterial.diffuseMap.coords.V_Tiling = -1     
				theMaterial.diffuseMap.coords.Blur = 0.01
			)
		)
		
		-- normal map
		if ((s_normalMapFile != undefined) AND (doesFileExist s_normalMapFile)) then (
			if (s_materialToUpdate_justReload) then (
				if ((IsKindOf theMaterial.bumpMap Normal_Bump) AND (IsKindOf theMaterial.bumpMap.normal_map BitmapTexture)) then (
					if (s_verboseMaterial) then format " normalMap : just rename and reload texture file\n"
					theMaterial.bumpMap.normal_map.filename = s_normalMapFile
					theMaterial.bumpMap.normal_map.reload()
				) else (
					if (s_verboseMaterial) then format "normalMap : cannot just_reload \n"
				)
			) else (										-- create the textures
				if (s_verboseMaterial) then format " create BitmapTexture for normal\n"
				local bmap = BitmapTexture filename:s_normalMapFile
				bmap.coords.Blur = 0.01
	    		if (s_UVsAreVFlipped == false) then bmap.coords.V_Tiling = -1	
				-- theMaterial.bumpMap = Normal_Bump normal_map:bmap flipgreen:true
				theMaterial.bumpMap = Normal_Bump normal_map:bmap
				theMaterial.bumpMapAmount = 100.0
			)
		)
		
		-- Displacement map : la il faut passer par le slot pour acceder au champs "mental ray connection"
		if ((s_displacementMapFile != undefined) AND (doesFileExist s_displacementMapFile)) then (
			if (s_materialToUpdate_justReload) then (
				local prevMat = meditMaterials[1]
				meditMaterials[1] = s_materialToUpdate
				if (s_forceMentalRay) then (
					meditMaterials[1].mental_ray__material_custom_attribute.DisplacementLocked = false
					local hmap = meditMaterials[1].mental_ray__material_custom_attribute.Displacement
					if (IsKindOf hmap max_HeightMapDisplacement) then (
						if (IsKindOf hmap.heightMap BitmapTexture) then (
							hmap.heightMap.filename = s_displacementMapFile
							hmap.heightMap.reload()
						)
					)
				)
				meditMaterials[1] = prevMat
			) else (
				if (s_verboseMaterial) then format "create BitmapTexture, HMap and use(swap) slot[1] for Displacement\n"
				local bmap = BitmapTexture filename:s_displacementMapFile
				if (s_UVsAreVFlipped == false) then bmap.coords.V_Tiling = -1 
				bmap.coords.Blur = 0.01
				local hmap = max_HeightMapDisplacement()
				hmap.minHeight = -(s_displacementFactor/2.0)
				hmap.maxHeight = (s_displacementFactor/2.0)
				hmap.heightMap = bmap
				local prevMat = meditMaterials[1]
				meditMaterials[1] = s_materialToUpdate
				if (s_forceMentalRay) then (
					meditMaterials[1].mental_ray__material_custom_attribute.DisplacementLocked = false
					meditMaterials[1].mental_ray__material_custom_attribute.Displacement = hmap
				)
				meditMaterials[1] = prevMat
			)
		)
	)
)

-- ---------------------------- Mental Ray Material ------------------------------
function setupMentalRayMaterial gozObj = 
(
	if (s_verboseMaterial) then format "setupMentalRayMaterial called!\n"
	local theMaterial = s_materialToUpdate
	if ((IsKindOf theMaterial mental_ray) == false) then (
		if (s_verboseMaterial) then format "setupMentalRayMaterial: bad material type (%)\n" (classof theMaterial)
	)

	if (s_textureMapFile != undefined) then (
		theMaterial.Surface = BitmapTexture filename:s_textureMapFile
		if (s_UVsAreVFlipped == false) then theMaterial.Surface.coords.V_Tiling = -1
		theMaterial.Surface.coords.Blur = 0.01
	)
	
	if (s_normalMapFile != undefined) then (
		if (getVersion() > 12000) then ( --this one does not work, but at least it doesnt crash :/  //This has to be >12000 (Above 3dsMax 2010) instead of >=12000
			theMaterial.Bump = Normals_Make_Normal ()
			-- theMaterial.Bump.Color_shader  = Normal_Bump flipgreen:true
			theMaterial.Bump.Color_shader  = Normal_Bump
			theMaterial.Bump.Color_shader.normal_map = BitmapTexture filename: s_normalMapFile
		) else (
			theMaterial.Bump = max_Bump() -- this is the one for version bellow 13000
			-- theMaterial.Bump.Map = Normal_Bump flipgreen:true
			theMaterial.Bump.Map = Normal_Bump
			theMaterial.Bump.Map.normal_map = BitmapTexture filename: s_normalMapFile
		)										
	)
	
	if (s_displacementMapFile != undefined) then (
		theMaterial.Displacement = max_HeightMapDisplacement()
		theMaterial.Displacement.heightMap = BitmapTexture filename: s_displacementMapFile
		theMaterial.Displacement.maxHeight = s_displacementFactor / 2
		theMaterial.Displacement.minHeight = -(s_displacementFactor / 2)
	)								
)

-- ---------------------------- DirectX9 Material ------------------------------

function setupDirectX9Material gozObj = 
(
	if (s_verboseMaterial) then format "setupDirectX9Material called!\n"
	local theMaterial = s_materialToUpdate
	if ((IsKindOf theMaterial DirectX_9_Shader) == false) then (
		if (s_verboseMaterial) then format "setupDirectX9Material: bad material type (%)\n" (classof theMaterial)
	)

	if (IsKindOf theMaterial DirectX_9_Shader) then (
	
		if (s_materialToUpdate_justReload) then (						-- update case : just update textures
			if ((findString theMaterial.effectFile "StandardFX.fx") != undefined) then (
				if (theMaterial.g_TopDiffuseEnable) then (
					theMaterial.g_TopTexture = openbitmap s_textureMapFile
					if (s_verboseMaterial) then format " reset the diffuseMap filename (openbitmap)\n"
				)
				if (theMaterial.g_NormalEnable) then (
					theMaterial.g_NormalTexture = openbitmap s_normalMapFile
					if (s_verboseMaterial) then format " reset the normal Map filename (openbitmap)\n"
				)
			)
			
		) else (														-- creation case: set everything we want
			theMaterial.effectFile = "$maps\\fx\\StandardFX.fx"
			theMaterial.renderMaterial = undefined
			theMaterial.technique = 0
			theMaterial.n = 50
			theMaterial.k_s = (color 64 64 64)
			theMaterial.k_d = (color 160 160 160)
			theMaterial.k_a = (color 0 0 0)

			if (s_textureMapFile != undefined) then (
				theMaterial.g_TopDiffuseEnable = true
				theMaterial.g_TopTexture = openbitmap s_textureMapFile
			) else (
				theMaterial.g_TopDiffuseEnable = false
			)

			if (s_normalMapFile != undefined) then (
				theMaterial.g_NormalEnable = true
				theMaterial.g_NormalTexture = openbitmap s_normalMapFile
			) else (
				theMaterial.g_NormalEnable = false
			)
		)
	)
)


--------------------------- ImportMaterial from xmax file -> ShellMaterial ---------------------------
function ImportMaterial_xmax_Shell gozObj matFilename nodeCreationCase =
(
--print "--- ImportMaterial_xmax_Shell  ---"
	local maxObj = gozObj.m_maxObject
	if ((maxObj!=undefined) and (maxObj!=s_severalMaxObjects)) then
	(
		matfile = safeOpenFile matFilename "rb"
		
		-- Parses the file. 
		s_textureMapFile = undefined
		s_normalMapFile = undefined
		s_displacementMapFile = undefined
		s_displacementFactor = 0.1
		local i, j, k
		while (not isEndOfFile matfile) do (
			item = ReadLong matfile
			case item of (
				8:  -- Texture map 
				(
				    local count = ReadLong matfile
				    s_textureMapFile = ReadString matfile
				    readPaddingData matfile count
if (s_verbose) then format "Texture map read = %\n" s_textureMapFile
				)

				9:  -- Normal map 
				(
				    local count = ReadLong matfile
				    s_normalMapFile = ReadString matfile
				    readPaddingData matfile count
if (s_verbose) then format "Normal map read = %\n" s_normalMapFile
				)

				10:  -- Displacement map 
				(
				    s_displacementFactor = ReadFloat matfile
				    local count = ReadLong matfile
				    s_displacementMapFile = ReadString matfile
				    readPaddingData matfile count
if (s_verbose) then format "Displacement map read = %\n" s_displacementMapFile
				)
			)
		)
		fclose matfile

		-- Activates Mental-Ray as current renderer 
		if (s_forceMentalRay) then (
			mental_ray_Preferences.mrExtensionsActive = true
			if ((classof renderers.current) != mental_ray_renderer) then
				renderers.current = mental_ray_renderer()
		)

		-- Creates or updates the material ?
		local goz_shader = maxObj.m_node.material
		local viewportMaterial = undefined
		local renderMaterial = undefined
		
		if (s_verboseMaterial) then format "nodeCreationCase = %\n" nodeCreationCase
		local createMaterial = false
		if (nodeCreationCase) then (
			createMaterial = true
		) else if (gozObj.m_materialCreated == false) then (
			if (IsKindOf gozObj.m_node.material standard) then (
				if (s_verboseMaterial) then format "createMaterial -> true (1er passage ZB -> 3DS et material = standard)\n"
				createMaterial = true		
			)
		)
		if (createMaterial == true) then (
			s_materialToUpdate_justReload = false
			local viewportShaderType = 1  -- 0:standard   1:DirectX   2:mentalRay
			local renderShaderType = 0
			if (globalDXDisplayManager.isDXActive() == false) then (
				format "isDXActive() == false -> use standard material only! \n"
				viewportShaderType = 0
			)

			local createShellMaterial = true
			if (viewportShaderType == renderShaderType) then createShellMaterial = false

			if (s_verboseMaterial) then format "viewportShaderType=%    renderShaderType=%   createShellMaterial=%\n" viewportShaderType renderShaderType createShellMaterial
			if (viewportShaderType == 1) then viewportMaterial = DirectX_9_Shader()
  			else viewportMaterial = standard()
			  
			if (createShellMaterial == true) then (
				if (renderShaderType == 2) then (
					if (s_forceMentalRay) then renderMaterial = mental_ray()
				) else renderMaterial = standard()
			)
			  
			if (createShellMaterial == true) then (
				if (s_verboseMaterial) then format "Creating a Shell_Material! \n"
				goz_shader = Shell_Material viewportMtlIndex: 0 renderMtlIndex: 1 name:"My_ShellMaterial"
				goz_shader.originalMaterial = viewportMaterial 
				goz_shader.bakedMaterial = renderMaterial
			) else (
				goz_shader = viewportMaterial
			)
			goz_shader.showInViewport = true
			maxObj.m_node.material = goz_shader
			gozObj.m_materialCreated = true
						
		) else ( 			-- the material already exists in the node, check if we can update this material (just reload)
			s_materialToUpdate_justReload = true
			if (IsKindOf maxObj.m_node.material Shell_Material) then (
				viewportMaterial = maxObj.m_node.material.originalMaterial
				renderMaterial = maxObj.m_node.material.bakedMaterial
				if (s_verboseMaterial) then format " JustReload case: Shell_Material found !\n"
			) else if (IsKindOf maxObj.m_node.material Standard) then (
				viewportMaterial = maxObj.m_node.material
				if (s_verboseMaterial) then format " JustReload case: Standard material found !\n"
			) else if (IsKindOf maxObj.m_node.material DirectX_9_Shader) then (
				viewportMaterial = maxObj.m_node.material
				if (s_verboseMaterial) then format " JustReload case: DirectX_9_Shader found !\n"
			)
		)
		
		-- set up viewport Material
		if (isKindOf viewportMaterial standard) then (
			s_materialToUpdate = viewportMaterial
			setupStandardMaterial gozObj
		) else if (isKindOf viewportMaterial DirectX_9_Shader) then (
			s_materialToUpdate = viewportMaterial
			setupDirectX9Material gozObj
		)
		
		-- set up render Material (only if different from viewport material)
		if ((renderMaterial != undefined) AND (renderMaterial != viewportMaterial)) then (
			if (isKindOf renderMaterial standard) then (
				s_materialToUpdate = renderMaterial
				setupStandardMaterial gozObj 
			) else if (isKindOf renderMaterial mental_ray) then (
				s_materialToUpdate = renderMaterial
				setupMentalRayMaterial gozObj
			)
		)

		-- sinon pour copier un fichier (texture) : DosCommand "copy " + 
	)
	undefined
)



function ImportObject gozObj fileName =
(
	local retObj = undefined
    local extension3 = substring fileName (fileName.count-3) 4
    local extension4 = substring fileName (fileName.count-4) 5
	if (extension3 == ".3ds") then(
		retObj = gozObj.m_maxObject
		importFile fileName #noPrompt
	) 
	if (extension3 == ".obj") then (
		retObj = ImportObject_obj gozObj fileName
		
		local matFileName = (substring fileName 1 (fileName.count-4)) + ".xmax"
		-- NEW : use Shell Material
		--ImportMaterial_xmax gozObj matFileName s_nodeCreationCase       -- NB: s_nodeCreationCase is set in ImportObject_obj
		ImportMaterial_xmax_Shell gozObj matFileName s_nodeCreationCase       -- NB: s_nodeCreationCase is set in ImportObject_obj
	) 
	if (extension4 == ".xmax") then (
    	local file = safeOpenFile fileName "rb"
		-- in deprected ms file: retObj = ImportObject_xmax gozObj file
		fclose file
	)
	retObj
)




/*****************************************************************************/
/************************************************************** GoZ server **/
/***************************************************************************/
struct GoZServer
(
    /* Data */
	m_objects,

    /* Functions */
	fn Clear =
	(
		m_objects = #()
		undefined
	),

	fn FindGoZObject_fromMaxObject maxObj =
	(
		local gozObj = undefined
		if ((maxObj!=undefined) and (maxObj!=s_severalMaxObjects)) then (
			for obj in m_objects while (gozObj==undefined) do (
				if (obj.isMaxObject(maxObj)) then
					gozObj = obj
			)
		)
		gozObj
	),

	fn FindGoZObject_fromZBrushObject zbrushObj =
	(
		local gozObj = undefined
		if (zbrushObj != undefined) then (
			for obj in m_objects while (gozObj==undefined) do (
				if (obj.isZBrushObject(zbrushObj)) then
					gozObj = obj
			)
		)
		gozObj
	),

	fn CreateGoZObject_fromMaxObject maxObj =
	(
		local gozObj = undefined
		if ((maxObj!=undefined) and (maxObj!=s_severalMaxObjects) and maxObj.IsAMesh()) then
		(
			gozObj = GoZObject()
if (s_verboseModifierChg) then format "*** m_modifier: ref maxObj in gozObj (%) \n" maxObj.m_modifier
			gozObj.m_materialCreated = false
			gozObj.m_maxObject = maxObj
			gozObj.m_zbrushObject = ZBrushObject()
			gozObj.m_zbrushObject.CreateSubToolName maxObj.m_node.name
			append m_objects gozObj
if (s_verbose) then format "append new gozObj (from selected	maxObj) -> m_objects.count=% \n" m_objects.count						
		)
		gozObj
	),

	fn UpdateGoZObjectModifier_fromMaxObject gozObj maxObj =
	(
		if (gozObj.m_maxObject != undefined) then (
			gozObj.m_maxObject.m_modifier = maxObj.m_modifier
if (s_verboseModifierChg) then format "GoZObject modifier updated! -> % \n" maxObj.m_modifier
		)
		undefined
	),
	
	fn processAction actionStr =
	(
		local strArray
		local strArray2
		local strArray3
		local token
		local subToolName
		local fileName
		local file
		local zbrushObj
		local maxObj
		local gozObj
		local i
		local result = 0

if (s_verbose) then format "Processing action: % \n" actionStr
PrintCurrentTime "Start Action" ""

		/* Gets the description of an action as an array of tokens = [command, param1, param2, ..., lastParam] */
		strArray = #()
		strArray2 = filterString actionStr "[]"
		for i = 1 to strArray2.count do
		(
if (s_verbose) then format "     % \n" strArray2[i]
			strArray3 = filterString strArray2[i] " \t"
			if (strArray3.count > 0) then
				append strArray strArray2[i]
		)

		/* An action must have at least one token: the command! */
if (s_verbose) then format "  strArrayCount=% \n" strArray.count
		if (strArray.count > 0) then
		(
			token = toLower strArray[1]
			if ((findString token ",") != undefined) then (
				token = trimRight token ","
				result = 1
			)
if (s_verbose) then format "  token=% \n" token

			/* ************************ Command 'import' ******************************** */
			if (token == "import" or token == "import3ds" or token == "importobj") then (
if (s_verbose) then format "Import is called...\n"
				maxObj = undefined
				if (strArray.count == 3) then (
					subToolName = strArray[2]
					fileName = strArray[3]
					zbrushObj = ZBrushObject()
					zbrushObj.m_subToolName = copy subToolName
					gozObj = FindGoZObject_fromZBrushObject zbrushObj
					if (gozObj == undefined) then (
						gozObj = GoZObject()
						gozObj.m_materialCreated = false
						gozObj.m_zbrushObject = zbrushObj
						gozObj.m_maxObject = GoZMaxObject()
						gozObj.m_maxObject.Clear()
						append m_objects gozObj
if (s_verbose) then format "append new gozObj -> m_objects.count=% \n" m_objects.count						
					) else (
						gozObj.UpdateValidity()
					)
--					format "   ... will call ImportObject on filename %\n" fileName
					maxObj = ImportObject gozObj fileName
					fclose file
				) else (
					paramsStr = "params = "
					for i = 2 to strArray.count do
					(
						paramsStr = paramsStr + "<" + i as String + "= "+ strArray[i] + "> "
					)
--					format "Error: [IMPORT] command, bad number of arguments!\n[IMPORT] command requires 2 arguments: the [SubToolName] and the [FileName].\nError occured in following command: %\n%\n" actionStr paramsStr
				)
				
			/* Unknown command... */
			) else (
--				format "Unknown token [%] in action %\n" token actionStr
			)
		) else (
--			format "Unknown action required is %\n" actionStr
		)

PrintCurrentTime "End Action" "" 

		result
	),

	
    fn GoZBrush_Old =
    (
if (s_verbose) then print "GoZBrush_Single called"
        local result = false
        local maxObj = GetSelectedMaxObject()
        local gozObj = FindGoZObject_fromMaxObject maxObj
        if (gozObj == undefined) then (
            gozObj = CreateGoZObject_fromMaxObject maxObj
if (s_verbose) then format "CreateGoZObject_fromMaxObject : maxObj=% \n" maxObj.m_node            
        ) else (
            UpdateGoZObjectModifier_fromMaxObject gozObj maxObj
        )

        if (gozObj == undefined) then (
            if (maxObj == undefined) then (
                messageBox "No object is selected!\nPlease, select one and only one mesh then try again." title:"Cannot Edit in ZBrush"
            ) else (
                if (maxObj == s_severalMaxObjects) then
                    messageBox "Several objects are selected!\nPlease, select one and only one mesh then try again." title:"Cannot Edit in ZBrush"
                else
                    messageBox "The selected object is not a valid mesh!\nPlease, select one and only one mesh then try again." title:"Cannot Edit in ZBrush"
            )

        ) else  (
        
            local subToolName = gozObj.m_zbrushObject.m_subToolName
if (s_verbose) then format "write GoZ_ObjectPath.txt : %\n" subToolName            
            local maxFileName = subToolName + ".xmax"
            local file = undefined

            file = safeOpenFile s_gozobjectpath "wb"
            if (file != undefined) then (
                WriteString file subToolName
                fclose file
            )

  			ExportSelectedMaxObject_xmax maxFileName

		    local str = "[IMPORT] [" + subToolName + "] [" + maxFileName + "]"
            ShellLaunch s_gozbrushapp str
        )
-- if (not result) then  format "Did not manage to communicate with ZBrush window\n"
        result
    ),
    
    -- 2 new GoZBrush : 
    -- Single (same as OLD but uses fills s_gozobjectlist instead of s_gozobjectpath + No More 'str' command in ShellLaunch)
    -- Multi : new for multi sub tools support
    fn GoToZBrushSingle =
    (
if (s_verbose) then print "GoZBrush_Single called"
        local result = false
        local maxObj = GetSelectedMaxObject()
        local gozObj = FindGoZObject_fromMaxObject maxObj
        if (gozObj == undefined) then (
            gozObj = CreateGoZObject_fromMaxObject maxObj
if (s_verbose) then format "CreateGoZObject_fromMaxObject : maxObj=% \n" maxObj.m_node            
        ) else (
            UpdateGoZObjectModifier_fromMaxObject gozObj maxObj
        )

        if (gozObj == undefined) then (
            if (maxObj == undefined) then (
                messageBox "No object is selected!\nPlease, select one and only one mesh then try again." title:"Cannot Edit in ZBrush"
            ) else (
                if (maxObj == s_severalMaxObjects) then
                    messageBox "Several objects are selected!\nPlease, select one and only one mesh then try again." title:"Cannot Edit in ZBrush"
                else
                    messageBox "The selected object is not a valid mesh!\nPlease, select one and only one mesh then try again." title:"Cannot Edit in ZBrush"
            )

        ) else  (
        
            local subToolName = gozObj.m_zbrushObject.m_subToolName
if (s_verbose) then format "write GoZ_ObjectList.txt : %\n" subToolName            
            local maxFileName = subToolName + ".xmax"

            local objectListFile = safeOpenFile s_gozobjectlist "wb"
if (s_verbose AND (objectListFile == undefined)) then print "Error: cannot open GoZ_ObjectList.txt for writing!"

            if (objectListFile != undefined) then (
if (s_verbose) then format "add line in % : %\n" s_gozobjectlist subToolName            
				writeStringToFile objectListFile subToolName
				writeStringToFile objectListFile "\n"
                fclose objectListFile
            )

  			ExportSelectedMaxObject_xmax maxFileName

            ShellLaunch s_gozbrushapp "UseObjectList"
        )
-- if (not result) then  format "Did not manage to communicate with ZBrush window\n"
        result
    ),
    

    fn GoToZBrushMulti =
    (
if (s_verbose) then print "GoZBrushMulti called"
		local selArray = selection as array
		local gozObjArray = #()
		local numSelNode = 0
		if (selArray!=undefined) then numSelNode = selArray.count
		
		local objectListFile = safeOpenFile s_gozobjectlist "wb"
if (s_verbose AND objectListFile == undefined) then print "Error: cannot open GoZ_ObjectList.txt for writing!"
		for i=1 to numSelNode do (
			maxObj = GoZMaxObject()
			maxObj.m_node = selArray[i]
			if ((maxObj.m_node.modifiers != undefined) AND (maxObj.m_node.modifiers.count != 0)) then (
				maxObj.m_modifier = maxObj.m_node.modifiers[ maxObj.m_node.modifiers.count ]
			) else (
				maxObj.m_modifier = undefined
			)

			-- get corresponding gozObject, create if not existing, update if existing:
            local gozObj = FindGoZObject_fromMaxObject maxObj
	        if (gozObj == undefined) then (
		        gozObj = CreateGoZObject_fromMaxObject maxObj
if (s_verbose) then format "CreateGoZObject_fromMaxObject : maxObj=% \n" maxObj.m_node            
			) else (
				UpdateGoZObjectModifier_fromMaxObject gozObj maxObj
			)

			-- write a line into GoZ_ObjectList.txt
	        if (gozObj != undefined) then  (
	            local subToolName = gozObj.m_zbrushObject.m_subToolName
if (s_verbose) then format "add line in GoZ_ObjectsList.txt : %\n" subToolName            
				local xmaxFileName = subToolName + ".xmax"

				if (objectListFile != undefined) then (
					writeStringToFile objectListFile subToolName
					writeStringToFile objectListFile "\n"
				)

  				ExportMaxObject_xmax xmaxFileName maxObj
			)
        )
        fclose objectListFile
        
		ShellLaunch s_gozbrushapp "UseObjectList"
		
        result
    ),


    fn GoToZBrush =
    (
		local result = false
        local maxObj = GetSelectedMaxObject()
        if (maxObj == s_severalMaxObjects) then (
			result = GoToZBrushMulti()
		) else (
			result = GoToZBrushSingle()
		)
		result
    )
)

/* Data */
global s_GoZServer = GoZServer()
s_GoZServer.clear()





/* Macros */
macroScript GoZBrush
category:"GoZ"
tooltip:"Edit in ZBrush"
(
	try (
		if (s_verbose) then print "\n === 3DS -> ZBrush === "
		local result = s_gozServer.GoToZBrush()
	) catch ();
)

/* Macros */
/*macroScript GoZOptions
category:"GoZ"
tooltip:"Edit in ZBrush"
(
    createdialog GoZOptionsRollout
    undefined
)*/



function debugPrintStoredObjectsList = 
(
	if (s_GoZServer.m_objects == undefined) then (
		print " ==> m_objects == undefined"
	) else (
		format " ==> % GoZObjects stored! \n" s_GoZServer.m_objects.count
		local counter = 0
		for obj in s_GoZServer.m_objects do (
			counter = counter + 1
			if (obj == undefined) then (
				format " . undefined GoZ Objects (very strange!)\n"
			) else if (obj.m_maxObject == undefined) then (
				format " . GoZ object with undefined m_maxObject (very strange!)\n"
			) else (
				if (obj.m_maxObject.m_node == undefined) then (
					format " . GoZ object with undefined m_maxObject.m_node !\n"
				) else if ((IsValidNode obj.m_maxObject.m_node) == false) then (
					format " . GoZ object with INVALID node (maybe removed)\n"
				) else (
					format " . OK (node valid)\n"
				)
			)
		)
	)
	undefined
)


function updateFromZBrushCB =
(
	try (
		if (s_verbose) then print "\n === ZBrush -> 3DS ==="
		StartChrono()
		
		-- for debug : print GoZObject stack
		if (s_verbose) then debugPrintStoredObjectsList()
			
		/* Tests if there is a ZBrush command waiting to be processed. */
		file = safeOpenFile s_gozinputfile "rb"
		if (file != undefined) then
		(
		/* BEFORE MultiSubTools
			action = readString file
			fclose file

			if (action != undefined) then (
				-- clear the action file
				file = safeOpenFile s_gozinputfile "wb"
				fclose file

				-- process the action
				result = s_gozServer.processAction(action)
			)
		*/
			action = readString file
			while (action != "" AND action != undefined) do (
				s_gozServer.processAction(action)
				action = readString file
			)
			fclose file
			
			-- clear the action file
			file = safeOpenFile s_gozinputfile "wb"
			if (file != undefined) then fclose file

		)

		StopChrono()
	) catch ();
)


global s_ZBrushToMaxForm = undefined

function StartConnexion =
(
	if (s_ZBrushToMaxForm == undefined) then
	(
		if (is64bitApplication()) then (
if (s_verbose) then print "xxx StartConnexion (64bit) xxx"
			dotNet.loadAssembly ("C:\\Users\\Public\\Pixologic\\GoZApps\\Max\\SendEventToMax64.dll")
		) else (
if (s_verbose) then print "xxx StartConnexion (32bit) xxx"
			dotNet.loadAssembly ("C:\\Users\\Public\\Pixologic\\GoZApps\\Max\\SendEventToMax.dll")
		)
		s_ZBrushToMaxForm = dotNetObject "SendEventToMax.MyEventReceiver"
		dotNet.AddEventHandler s_ZBrushToMaxForm "MouseDown" updateFromZBrushCB 	
	)
)



macroScript ToggleImportExtraData
category:"GoZ"
tooltip:"ToggleImportExtraData"
(
	s_importExtraData = not s_importExtraData
format "importExtraData = % \n" s_importExtraData
)

macroScript ToggleImportMaterial
category:"GoZ"
tooltip:"ToggleImportMaterial"
(
	s_importMaterial = not s_importMaterial
format "importMaterial = % \n" s_importMaterial
)



macroScript Test_classof
category:"GoZ"
tooltip:"GoZ test1 classof"
(
--			for modifier in m_node.modifiers while (modifier!=m_modifier) do ()

	max modify mode
	local node = $
	local selObj = modPanel.getCurrentObject()
format "modPanel.getCurrentObject() isKindOf GeometryClass == %" (isKindOf selObj GeometryClass)
	
format "class of node : % \n" (classof node)
format "class of node.baseObject : % \n" (classof node.baseObject)
format "class of node.mesh : % \n" (classof node.mesh)
format "class of cur modifier : % \n" (classof selObj)
-- format "class of modifier.mesh : % \n" (classof selObj.mesh) -> TriMesh sur le baseObject

    -- Test sur EditPoly
	if (isKindOf selObj Edit_Poly) then
	(
		print "modifier is Edit_Poly -> test interface:"
		local var = selObj.GetNumVertices()
		format "   % vertices \n" var
	)
	
	print " -- Node Properties"
format "classof node = %" (classof node)
showProperties node
	--print " -- Node Methods"
--showMethods node

	if (selObj != undefined) then (
		print " -- Modifier Properties"
		format "classof modPanel.getCurrentObject() = %" (classof selObj)
		showProperties selObj
		--print " -- Modifier Methods"
		--showMethods selObj
	) else (
		print " -- BaseObject Properties"
		format "classof node.baseObject = %" (classof node.baseObject)
		showProperties node.baseObject
		print " -- BaseObject Methods"
		showMethods node.baseObject
	)
	
	print " -- Mesh Properties"
	format "classof node.mesh = %" (classof node.mesh)
	showProperties node.mesh
	--print " -- Node Methods"
--showMethods node.mesh

    
)


macroScript Test_polyop
category:"GoZ"
tooltip:"GoZ test2 (polyop)"
(
-- Try polyop operations

	max modify mode -- go to modify panel
	local node = $
	local selObj = modPanel.getCurrentObject()
)

macroScript Test_move
category:"GoZ"
tooltip:"GoZ test3 (move)"
(
	max modify mode
	local node = $
	local modifier = modPanel.getCurrentObject()
	
	format " +++ test move : node = % (class = %)\n" node (classof node)
	if (modifier != undefined) then 
		format "    modifier = % (class = %)\n" modifier (classof modifier)
	else
		format "    modifier = undefined\n" 
	
	if (modifier != undefined) then (
/*
		--modifier.SetEPolySelLevel #Vertex
		subobjectLevel = 1
		modifier.SetOperation #Transform

	PrintCurrentTime "Before MoveSelection" ""
		--disableSceneRedraw()
		--with redraw off
		--undo off (
			local nv = modifier.GetNumVertices()
			local numMoved = 0
			local moveVec = [1, 1, 1]
			local moveVec2 = [2, 0, 0]
			for i = 1 to nv do	
			(
				if (i < 20) then (
					modifier.SetSelection #Vertex #{}
					modifier.Select #Vertex #{i}
					if (i < 10) then (
						modifier.MoveSelection moveVec
					) else (
						modifier.MoveSelection moveVec2
					)
					modifier.Commit ()
					
					numMoved = numMoved + 1
				)
			)
			--modifier.Commit ()
		--)
		--enableSceneRedraw()
format "% / % vertices moved ! \n" numMoved nv	
PrintCurrentTime "After MoveSelection" ""
*/
	)

	-- test move:
	/* polyop.setVert ne marche que sur un EditablePoly ou un baseMesh mais pas sur un EditPoly!!!!!
	subobjectLevel = 1
	local myVertexList = #{1, 2, 3, 4, 5, 6}
	local myPointArray = #()
	
	local point1 = [0, 0, 1]
	append myPointArray point1
	append myPointArray point1
	append myPointArray point1
print "coucou1"	
	--local point2 = polyop.getVert modifier 7
	local point2 = [1, 0, 1]
print "coucou2"	
	append myPointArray point2
	append myPointArray point2
	append myPointArray point2
	format "vtxList = %\n" myVertexList
print "coucou3"	
	polyop.setVert modifier myVertexList myPointArray node:$
print "coucou4"	
*/
)

macroScript Test4
category:"GoZ"
tooltip:"GoZ test4"
(
)

macroScript Add2EPoly
category:"GoZ"
tooltip:"GoZ Add2EPoly"
(
	max modify mode
	addModifier $ (Edit_Poly())
	addModifier $ (Edit_Poly())
)








/* Creates the menu */
/* INITIAL CODE
if (menuMan.registerMenuContext 0x47ef18fb) then
(
	main_menubar = menuMan.getMainMenuBar()
	goz_menu = menuMan.createMenu "GoZ"
	goz_item = menuMan.createActionItem "GoZBrush" "GoZ"
	goz_menu.addItem goz_item -1

	goz_menu_item = menuMan.createSubMenuItem "GoZ" goz_menu
	main_menubar.addItem goz_menu_item -1
	menuMan.updateMenuBar()
)
*/


main_menubar = menuMan.getMainMenuBar()

global goz_menu = undefined   -- pool
global goz_menu_item = undefined


-- find the GoZ menu item -- NB if the menuItem exist then the goz_menu exists
numMenu = main_menubar.numItems()
for i = 1 to numMenu do (
	local menuItem = main_menubar.getItem(i)
	if (menuItem != undefined) then (
		local s = (menuItem.getTitle())
		if (s == "GoZ") then (
			goz_menu_item = menuItem;
			goz_menu = menuItem.getSubMenu()
		)
	) 
)

-- find the GoZ menu (in menu pool) --
if (goz_menu == undefined) then (
	goz_menu = menuMan.findMenu "GoZ"
	
	-- check if menu is OK
	if (goz_menu != undefined) then (
		local item1 = goz_menu.getItem 1
		local item2 = goz_menu.getItem 2
		if (s_verboseMenu) then format "menu item1 %\n" item21getTitle()
		if (s_verboseMenu) then format "menu item2 %\n" item2.getTitle()
		local menuOK = false
		/*if (item1 != undefined AND item2 != undefined) then (
			if (item1.getTitle() == "GoZBrush" AND item2.getTitle == "GoZOptions") then menuOK = true
		)*/
		if (item1 != undefined) then (
			if (item1.getTitle() == "GoZBrush") then menuOK = true
		)
		if (menuOK == false) then (
			menuMan.unregisterMenu goz_menu
			goz_menu = undefined
			if (s_verboseMenu) then format "goz_menu created (not found in pool) \n"
		)
	)
	
	if (goz_menu == undefined) then (
		goz_menu = menuMan.createMenu "GoZ"
		local goz_action_item = menuMan.createActionItem "GoZBrush" "GoZ"  -- creates a menu item that execute the macroscript "GoZBrush" category = "GoZ"
		goz_menu.addItem goz_action_item -1

		--local goz_options_action_item = menuMan.createActionItem "GoZOptions" "GoZ"  -- creates a menu item that execute the macroscript "GoZOptions" category = "GoZ"
		--goz_menu.addItem goz_options_action_item -1
		
		if (s_verboseMenu) then format "goz_menu created (not found in pool) \n"
	) else (
		if (s_verboseMenu) then format "goz_menu already exists (in menu pool) \n"
	)
)

-- find or create the goz sub menu in mainMenu --
if (goz_menu_item == undefined) then (
	if (s_verboseMenu) then format "createSubMenu in mainMenu\n"
	goz_menu_item = menuMan.createSubMenuItem "GoZ" goz_menu
	main_menubar.addItem goz_menu_item -1
	menuMan.updateMenuBar()
)



StartConnexion()

















/* TEST COPY or REFERENCE !
 	m_var1,
	m_var2,
	m_class1,

	fn testParams a =
	(
		a = 23
		m_var1
	),

	fn testParams2 a =
	(
		a.m_data1 = "testParamsA"
		m_class1
	),


   -- test
    m_var1 = 1
    m_var2 = 2
    m_var1 = m_var2
    m_var2 = 3
    format "var1=% var2=% \n" m_var1 m_var2  -- -> var1=2 var2=3 
-- DONC Pour les types basique : par copy !
    
    local a = 0
    local b = testParams a
    m_var1 = 4
    format "var1=% a=%  b=% \n" m_var1 a b  -- -> var1=4 a=0  b=2
-- DONC les param en entrée des fonctions ET les retours sont passés par COPY !!!!    

-- MAINTENANT AVEC DES OBJETS
    m_var1 = MyClass()
    m_var2 = MyClass()
    m_var1.m_data1 = "empty"
    m_var2.m_data1 = "coucou"
    m_var1 = m_var2
    m_var2.m_data1 = "modif"
    format "var1=% var2=% \n" m_var1 m_var2  -- -> var1=(MyClass m_data1:"modif") var2=(MyClass m_data1:"modif") 
-- PAR CONTRE POUR LES OBJECTS : C'est par reference (voir la doc) !!
    
    m_class1 = MyClass()
    local a = MyClass()
    a.m_data1 = "empty"
    local b = testParams2 a
    m_class1.m_data1 = "erase"
    format "m_class1=% a=%  b=% \n" m_class1 a b   -- -> m_class1=(MyClass m_data1:"erase") a=(MyClass m_data1:"testParamsA")  b=(MyClass m_data1:"erase") 
-- DONC InputParam AND Outputs are by REFERENCE !!!!!
*/