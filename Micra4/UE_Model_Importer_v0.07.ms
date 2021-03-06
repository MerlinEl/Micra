
global AX_IMPORTER_VERSION = 15

-------------------------------------------------------------------------------
--	Global variables
-------------------------------------------------------------------------------

global g_seeThru
global g_skelOnly
global g_updateTime
global g_playAnim
global g_fixLooping
global g_lastDir1
global g_lastDir2
global g_texDir
global g_texRecurse
global g_texMissAction
global g_boneSize
global g_reposBones
global g_rotY
global g_rotP
global g_rotR
global g_meshScale
global g_reorientBones
global Anims
global MeshBones
global g_axImporterInited
global g_axImporterVersion


try destroyDialog mcUEToMaxImporter catch ()
rollout mcUEToMaxImporter "UE To 3DsMax Importer:" width:620 height:152
(
	--> local variables
	local export_dir, ini_file, package_file, all_dirs = #()
	local configFile = undefined
	local tmp_v  = undefined		-- global variable, helper for DoSetting() (required for execute() ...)
	local g_isLoading = true		-- DoSetting() mode
	
	--> interface
	label lbl1 "Packages:" pos:[12,28] width:68 height:16
	GroupBox grp1 "Paths..." pos:[4,4] width:612 height:144
	dropdownList ddl_packagepath "" pos:[84,24] width:460 height:21
	button btn_ad1 "+" pos:[552,24] width:28 height:20 toolTip:"Add Path"
	button btn_del1 "x" pos:[584,24] width:28 height:20 toolTip:"Remove Path"
	label lbl2 "Temp Export:" pos:[12,56] width:68 height:16
	dropdownList ddl_exportpath "" pos:[84,52] width:256 height:21
	button btn_ad2 "+" pos:[348,52] width:28 height:20 toolTip:"Add Path"
	button btn_del2 "x" pos:[380,52] width:28 height:20 toolTip:"Remove Path"
	label lbl3 "UE Model:" pos:[12,84] width:68 height:16
	dropdownList ddl_modelpath "" pos:[84,80] width:460 height:21
	button btn_ad3 "+" pos:[552,80] width:28 height:20 toolTip:"Add Path"
	button btn_del3 "x" pos:[584,80] width:28 height:20 toolTip:"Remove Path"
	button btn_import "IMPORT" pos:[8,108] width:604 height:36
	button btn_delfiles "Delete Temporary Files" pos:[412,52] width:200 height:20 toolTip:"Remove Path"
	--> functions
	-------------------------------------------------------------------------------
	--	Default settings
	-------------------------------------------------------------------------------
	fn DefaultSettings =
	(
		-- defaults settings
		g_seeThru    = false
		g_skelOnly   = false
		g_updateTime = true
		g_playAnim   = false
		g_fixLooping = false
		g_lastDir1   = ""
		g_lastDir2   = ""
		g_texDir     = ""
		g_texRecurse = false
		g_texMissAction = 1
		g_boneSize   = 0.5
		g_reposBones = true
		g_rotY       = 0
		g_rotP       = 0
		g_rotR       = 0
		g_meshScale  = 1.0
		g_reorientBones = false
	)
	-------------------------------------------------------------------------------
	--	Configuration
	-------------------------------------------------------------------------------
	fn GetSetting name default =
	(
		local ret = getINISetting configFile "Main" name
		if ret == "" then ret = (default as string)
		ret
	)
	fn SetSetting name value =
	(
		setINISetting configFile "Main" name (value as string)
	)
	fn GetSettingBool  name default = (GetSetting name default) as BooleanClass
	fn GetSettingFloat name default = (GetSetting name default) as float
	fn DoSetting name var =
	(
		local default = execute var							-- value has the same type as var
		if g_isLoading then
		(
			try
			(
				-- loading value
				tmp_v = getINISetting configFile "Main" name	-- get from ini as string
				if (tmp_v != "") and (tmp_v != "undefined") then
				(
					local type = classOf default
	--				format "reading % (%) = %\n" var type tmp_v
					if (not isKindOf default String) then
						execute (var + "=tmp_v as " + (type as string))
					else
						execute (var + "=tmp_v")				-- no conversion
				)
			)
			catch
			(
				format "Reading %: %\n" name (getCurrentException())
			)
		)
		else
		(
			-- saving value
			setINISetting configFile "Main" name (default as string)
		)
	)
	fn SerializeSettings isLoading =
	(
		if isLoading then
		(
			if configFile == undefined then return undefined
			if not doesFileExist configFile then return undefined	-- no config file
		)
		g_isLoading = isLoading
		-- read/write settings
		DoSetting "LastUsedDir"   "g_lastDir1"
		DoSetting "LastUsedDir2"  "g_lastDir2"
		DoSetting "TexturesDir"   "g_texDir"
		DoSetting "TexRecurse"    "g_texRecurse"
		DoSetting "TexMissAction" "g_texMissAction"
		DoSetting "AutoPlayAnim"  "g_playAnim"
		DoSetting "UpdateTime"    "g_updateTime"
		DoSetting "FixLoopAnim"   "g_fixLooping"
		DoSetting "SeeThru"       "g_seeThru"
		DoSetting "SkelOnly"      "g_skelOnly"
		DoSetting "BoneSize"      "g_boneSize"
		DoSetting "ReposBones"    "g_reposBones"
		DoSetting "MeshYaw"       "g_rotY"
		DoSetting "MeshPitch"     "g_rotP"
		DoSetting "MeshRoll"      "g_rotR"
		DoSetting "MeshScale"     "g_meshScale"
		DoSetting "ReorientBones" "g_reorientBones"
	)

	-------------------------------------------------------------------------------
	--	Service functions
	-------------------------------------------------------------------------------
	fn ReadFixedString bstream fixedLen =
	(
		local str = ""
		local length = 0
		local finished = false
		for i = 1 to fixedLen do
		(
			local c = ReadByte bstream #unsigned
			if c == 0 then finished = true	-- end of line char
			if finished then continue		-- has end of line before - skip remaining chars
			-- not "finished" string
			str += bit.intAsChar(c)			-- append a character
			if c != 32 then length = i		-- position of last non-space char
		)
		substring str 1 length				-- return first "length" chars
	)

	fn ReadFVector bstream =
	(
		local v = [ 0, 0, 0 ]
		v.x = ReadFloat bstream
		v.y = ReadFloat bstream
		v.z = ReadFloat bstream
		v
	)

	fn ReadFQuat bstream =
	(
		local q = quat 0 0 0 0
		q.x = ReadFloat bstream
		q.y = ReadFloat bstream
		q.z = ReadFloat bstream
		q.w = ReadFloat bstream
		q
	)

	-- Function used to determine bone length
	fn FindFirstChild boneArray boneIndex =
	(
		for i = 1 to boneArray.count do
		(
			if (i != boneIndex) then
			(
				bn = boneArray[i]
				if bn.ParentIndex == boneIndex-1 then return bn
			)
		)
		return undefined
	)

	fn FixBoneNames boneArray =
	(
		-- Find and correct duplicate names
		for i = 1 to (boneArray.count-1) do
		(
			local n = boneArray[i].Name
			local dupCount = 1
			for j = (i+1) to boneArray.count do
			(
				local n2 = boneArray[j].Name
				if n == n2 then
				(
					dupCount += 1
					n2 = n + "_" + (dupCount as string)
					format "Duplicate bone name \"%\", renamed to \"%\"\n" n n2
					boneArray[j].Name = n2
				)
			)
		)
	)

	fn FindFile path filename recurse:false =
	(
		local check = path + "\\" + filename
		--format "filename:%\n" check
		if doesFileExist check then return check
		if recurse then
		(
			local dirs = getDirectories (path + "/*")
			for dir in dirs do
			(
				local ret = FindFile dir filename recurse:true
				if ret != undefined then return ret
			)
		)
		return undefined
	)

	fn GetRotationMatrix =
	(
		local angles = eulerAngles g_rotR -g_rotP -g_rotY
		return angles as matrix3
	)

	-------------------------------------------------------------------------------
	--	Actor X data structures
	-------------------------------------------------------------------------------
	struct VChunkHeader
	(
		ChunkID,
		TypeFlag,
		DataSize,
		DataCount
	)

	fn ReadChunkHeader bstream =
	(
		local hdr = VChunkHeader ()
		hdr.ChunkID   = ReadFixedString bstream 20
		hdr.TypeFlag  = ReadLong bstream #unsigned
		hdr.DataSize  = ReadLong bstream #unsigned
		hdr.DataCount = ReadLong bstream #unsigned
	--	format "Read chunk header: %\n" hdr
		hdr
	)

	fn LOAD_CHUNK bstream name =
	(
		hdr = ReadChunkHeader bstream
		if (hdr.ChunkID != name) then
		(
			local msg = ("ERROR: bad chunk header: \"" + name + "\" expected but \"" + hdr.ChunkID + "\" found\n")
			format "%\n" msg
			messageBox msg
			throw msg
		)
		hdr
	)

	struct VVertex
	(
		PointIndex,
		U, V,
		MatIndex,
		Reserved,
		Pad
	)

	fn ReadVVertex bstream =
	(
		local v = VVertex ()
		local pad
		v.PointIndex = ReadShort bstream #unsigned
		pad          = ReadShort bstream
		v.U          = ReadFloat bstream
		v.V          = ReadFloat bstream
		v.MatIndex   = ReadByte  bstream #unsigned
		v.Reserved   = ReadByte  bstream #unsigned
		v.Pad        = ReadShort bstream #unsigned
		v
	)

	struct VTriangle
	(
		Wedge0, Wedge1, Wedge2,
		MatIndex,
		AuxMatIndex,
		SmoothingGroups
	)

	fn ReadVTriangle bstream =
	(
		local v = VTriangle ()
		v.Wedge0          = ReadShort bstream #unsigned
		v.Wedge1          = ReadShort bstream #unsigned
		v.Wedge2          = ReadShort bstream #unsigned
		v.MatIndex        = ReadByte  bstream #unsigned
		v.AuxMatIndex     = ReadByte  bstream #unsigned
		v.SmoothingGroups = ReadLong  bstream #unsigned
		v
	)

	struct VMaterial
	(
		MaterialName,
		TextureIndex,
		PolyFlags,
		AuxMaterial,
		AuxFlags,
		LodBias,
		LodStyle
	)

	fn ReadVMaterial bstream =
	(
		local m = VMaterial ()
		m.MaterialName = ReadFixedString bstream 64
		m.TextureIndex = ReadLong bstream #unsigned
		m.PolyFlags    = ReadLong bstream #unsigned
		m.AuxMaterial  = ReadLong bstream #unsigned
		m.AuxFlags     = ReadLong bstream #unsigned
		m.LodBias      = ReadLong bstream
		m.LodStyle     = ReadLong bstream
		m
	)

	struct VBone
	(
		Name,
		Flags,
		NumChildren,
		ParentIndex,
		-- VJointPos
		Orientation,
		Position,
		Length,
		Size,
		-- Computed data
		Matrix
	)

	fn ReadVBone bstream =
	(
		local b = VBone ()
		b.Name        = ReadFixedString bstream 64
		b.Flags       = ReadLong    bstream #unsigned
		b.NumChildren = ReadLong    bstream
		b.ParentIndex = ReadLong    bstream
		b.Orientation = ReadFQuat   bstream
		b.Position    = ReadFVector bstream
		b.Length      = ReadFloat   bstream
		b.Size        = ReadFVector bstream
		b
	)


	struct VRawBoneInfluence
	(
		Weight,
		PointIndex,
		BoneIndex
	)

	fn ReadVRawBoneInfluence bstream =
	(
		local v = VRawBoneInfluence ()
		v.Weight     = ReadFloat bstream
		v.PointIndex = ReadLong bstream #unsigned
		v.BoneIndex  = ReadLong bstream #unsigned
		v
	)

	fn InfluenceSort v1 v2 =
	(
		local cmp = v1.PointIndex - v2.PointIndex
		if (cmp == 0) then cmp = v1.BoneIndex - v2.BoneIndex
		cmp
	)


	struct AnimInfoBinary
	(
		Name,
		Group,
		TotalBones,
		RootInclude,
		KeyCompressionStyle,
		KeyQuotum,
		KeyReduction,
		TrackTime,
		AnimRate,
		StartBone,
		FirstRawFrame,
		NumRawFrames
	)

	fn ReadAnimInfoBinary bstream =
	(
		v = AnimInfoBinary ()
		v.Name                = ReadFixedString bstream 64
		v.Group               = ReadFixedString bstream 64
		v.TotalBones          = ReadLong  bstream
		v.RootInclude         = ReadLong  bstream
		v.KeyCompressionStyle = ReadLong  bstream
		v.KeyQuotum           = ReadLong  bstream
		v.KeyReduction        = ReadFloat bstream
		v.TrackTime           = ReadFloat bstream
		v.AnimRate            = ReadFloat bstream
		v.StartBone           = ReadLong  bstream
		v.FirstRawFrame       = ReadLong  bstream
		v.NumRawFrames        = ReadLong  bstream
		v
	)


	struct VQuatAnimKey
	(
		Position,
		Orientation,
		Time
	)

	fn ReadVQuatAnimKey bstream =
	(
		local k = VQuatAnimKey ()
		k.Position    = ReadFVector bstream
		k.Orientation = ReadFQuat   bstream
		k.Time        = ReadFloat   bstream
		k
	)
	-------------------------------------------------------------------------------
	--	Loading materials
	-------------------------------------------------------------------------------
	fn ImportMaterial matName texDir =
	(
		local subMat = standardMaterial name:matName

		local texFilename
		local foundTex

		-- try to file material file
		texFilename = matName + ".mat"
		foundTex = FindFile texDir texFilename recurse:true
		--format "mat name:%\tfile name:%\ttext dir:%\nmaterial file:%\n" matName texFilename texDir foundTex
		if foundTex != undefined then
		(
			texFilename = foundTex
			format "Loading material %\n" texFilename
			local matFile = openFile texFilename
			while eof matFile == false do
			(
				local line = readline matFile
				local tok = filterString line " ="
	--			format "[%] = [%]\n" tok[1] tok[2]
				local parm = tok[1]
				local file = tok[2]
				foundTex = FindFile texDir (file + ".tga") recurse:true
				if foundTex == undefined then continue
				local bitmap = bitmapTexture name:foundTex fileName:foundTex
				if parm == "Normal" then
				(
					local normalMap = normal_bump name:foundTex normal_map:bitmap
					subMat.bumpMap = normalMap
					subMat.bumpMapAmount = 100		-- amount is set to 30 by default
				)
				else
				(
					if parm == "Diffuse"   then subMat.diffuseMap = bitmap
					if parm == "Specular"  then subMat.specularMap = bitmap
					if parm == "SpecPower" then subMat.specularLevelMap = bitmap
					if parm == "Opacity"   then subMat.opacityMap = bitmap
					if parm == "Emissive"  then subMat.selfIllumMap = bitmap
				)
			)
			close matFile
			return subMat
		)
		-- no material file found, try simple texture
		-- get texture filename
		texFilename = matName + ".tga"
		foundTex = FindFile texDir texFilename recurse:g_texRecurse
		if foundTex != undefined then
		(
			texFilename = foundTex
		)
		else
		(
			if g_texMissAction == 2 then			-- ask
			(
				local check = getOpenFileName caption:("Get texture for material " + matName) \
					types:"TGA files (*.tga)|*.tga|All (*.*)|*.*|" filename:texFilename
				if check != undefined then texFilename = check
			)
		)
		if not doesFileExist texFilename then format "Unable to find texture %\n" texFilename
		-- continue setup
		local bitmap = bitmapTexture name:texFilename fileName:texFilename
		subMat.diffuseMap = bitmap
		-- return
		subMat
	)
	-------------------------------------------------------------------------------
	--	Loading PSK file
	-------------------------------------------------------------------------------
	fn importPskFile filename skelOnly:false =
	(
		set coordsys world
	
		local OldMeshBones = MeshBones
	
		local Verts     = #()
		local Wedges    = #()
		local Tris      = #()
		local Materials = #()
			 MeshBones = #()		-- global for access to bind pose from outside
		local Infs      = #()
	
		--------- Read the file ---------
	
		try
		(
			file = fopen filename "rb"
			if file == undefined then return undefined
	print "A"
			-- Header --
			hdr = LOAD_CHUNK file "ACTRHEAD"
	print "B"
			-- Points --
			hdr = LOAD_CHUNK file "PNTS0000"
			numVerts = hdr.DataCount;
			Verts[numVerts] = [ 0, 0, 0 ]		-- preallocate
			for i = 1 to numVerts do Verts[i] = ReadFVector file
	print "C"
			-- Wedges --
			hdr = LOAD_CHUNK file "VTXW0000"
			numWedges = hdr.DataCount
			Wedges[numWedges] = VVertex ()		-- preallocate
			for i = 1 to numWedges do Wedges[i] = ReadVVertex file
	print "D"
			-- Faces --
			hdr = LOAD_CHUNK file "FACE0000"
			numTris = hdr.DataCount
			Tris[numTris] = VTriangle ()		-- preallocate
			for i = 1 to numTris do Tris[i] = ReadVTriangle file
	print "E"
			-- Materials --
			hdr = LOAD_CHUNK file "MATT0000"
			numMaterials = hdr.DataCount
			Materials[numMaterials] = VMaterial ()	-- preallocate
			for i = 1 to numMaterials do Materials[i] = ReadVMaterial file
	print "F"
			-- Bones --
			hdr = LOAD_CHUNK file "REFSKELT"
			numBones = hdr.DataCount
			if numBones > 0 then MeshBones[numBones] = VBone () -- preallocate
			for i = 1 to numBones do
			(
				MeshBones[i] = ReadVBone file
	--			format "Bone[%] = %\n" (i-1) MeshBones[i].Name
			)
			FixBoneNames MeshBones
	
			-- Weights --
			hdr = LOAD_CHUNK file "RAWWEIGHTS"
			numInfluences = hdr.DataCount
			if numInfluences > 0 then Infs[numInfluences] = VRawBoneInfluence () -- preallocate
			for i = 1 to numInfluences do Infs[i] = ReadVRawBoneInfluence file
		)
		catch
		(
			fclose file
			messageBox ("Error loading file " + filename)
			format "FATAL ERROR: %\n" (getCurrentException())
			return undefined
		)
	
		format "Read mesh: % verts, % wedges, % tris, % materials, % bones, % influences\n" \
			numVerts numWedges numTris numMaterials numBones numInfluences
		fclose file
	
		--------- File is completely read now ---------
	
		-- generate skeleton
		MaxBones = #()
		local rotMatrix = matrix3 1
		for i = 1 to numBones do
		(
			bn = MeshBones[i]
			-- build bone matrix
			q = bn.Orientation
			if (i == 1) then q = conjugate q
			mat = (normalize q) as matrix3
			mat.row4 = bn.Position * g_meshScale
			-- transform from parent bone coordinate space to world space
			if (i > 1) then
			(
				bn.Matrix = mat * MeshBones[bn.ParentIndex + 1].Matrix
			)
			else
			(
				bn.Matrix = mat
			)
	
			-- get bone length (just for visual appearance)
			childBone = FindFirstChild MeshBones i
			if (childBone != undefined) then
			(
				len = (length childBone.Position) * g_meshScale
			)
			else
			(
				len = 4		-- no children, default length; note: when len = 1 has bugs with these bones!
			)
			if len < 4 then len = 4
			-- create Max bone
			newBone = getNodeByName bn.Name exact:true ignoreCase:false
			if (newBone == undefined) then
			(
				if (g_reorientBones == false or childBone == undefined) then
				(
					newBone = bonesys.createbone	\
						  bn.Matrix.row4			\
						  (bn.Matrix.row4 + len * (normalize bn.Matrix.row1)) \
						  (normalize bn.Matrix.row3)
				)
				else
				(
					-- get world position of the child bone
					local childPos = childBone.Position * bn.Matrix * g_meshScale
					newBone = bonesys.createbone	\
						  bn.Matrix.row4			\
						  childPos					\
						  bn.Matrix.row3
				)
				newBone.name   = bn.Name
				newBone.width  = g_boneSize
				newBone.height = g_boneSize
				newBone.setBoneEnable false 0
				newBone.pos.controller      = TCB_position ()
				newBone.rotation.controller = TCB_rotation ()	-- required for correct animation
				-- setup parent
				if (i > 1) then
				(
					if (bn.ParentIndex >= i) then
					(
						format "Invalid parent % for bone % (%)" bn.ParentIndex (i-1) bn.Name
						return undefined
					)
					newBone.parent = MaxBones[bn.ParentIndex + 1]
				)
			)
			else
			(
				-- bone already exists
				if g_reposBones then newBone.transform = bn.Matrix
			)
			MaxBones[i] = newBone
		)
	
		-- generate mesh
		MaxFaces = #()
		MaxVerts = #()
		MaxFaces[numTris]   = [ 0, 0, 0 ]			-- preallocate
		MaxVerts[numWedges] = [ 0, 0, 0 ]			-- ...
		for i = 1 to numWedges do
		(
			MaxVerts[i] = Verts[Wedges[i].PointIndex + 1] * g_meshScale
		)
		for i = 1 to numTris do
		(
			tri = Tris[i]
			w0 = tri.Wedge0
			w1 = tri.Wedge1
			w2 = tri.Wedge2
			MaxFaces[i] = [ w1+1, w0+1, w2+1 ]		-- note: reversing vertex order
		)
		newMesh = mesh vertices:MaxVerts faces:MaxFaces name:(getFilenameFile filename)
		-- texturing
		newMesh.xray = g_seeThru
		meshop.setMapSupport newMesh 1 true			-- enable texturemap channel
		meshop.setNumMapVerts newMesh 1 numWedges	-- set number of texture vertices
		for i = 1 to numWedges do
		(
			w = Wedges[i]
			meshop.setMapVert newMesh 1 i [ w.U, 1-w.V, 1-w.V ]	-- V coordinate is flipped
		)
		for i = 1 to numTris do
		(
			tri = Tris[i]
			w0 = tri.Wedge0
			w1 = tri.Wedge1
			w2 = tri.Wedge2
			meshop.setMapFace newMesh 1 i [ w1+1, w0+1, w2+1 ]
			setFaceMatId newMesh i (tri.MatIndex+1)
		)
		newMat = multiMaterial numsubs:numMaterials
		if g_skelOnly then numMaterials = 0		-- do not load materials for this option
		local package_name = getFilenameFile package_file
		local texDir = export_dir + package_name
		--format "texture dir:%\n" texDir
		for i = 1 to numMaterials do
		(
			/*
			local texDir
			if g_texDir != "" then
			(
				texDir = g_texDir
			)
			else
			(
				texDir = getFilenamePath filename
			)
			*/
			local subMat = ImportMaterial Materials[i].MaterialName texDir
			newMat.materialList[i] = subMat
			showTextureMap subMat true
	--		format "Material[%] = %\n" i Materials[i].MaterialName
		)
		newMesh.material = newMat
	
		-- generate skin modifier
		max modify mode
		select newMesh
	
		skinMod = skin ()
		if numBones > 0 then
		(
			addModifier newMesh skinMod
			for i = 1 to numBones do
			(
				if i != numBones then
					skinOps.addBone skinMod MaxBones[i] 0
				else
					skinOps.addBone skinMod MaxBones[i] 1
			)
		)
		update newMesh
	
		if skelOnly then
		(
			delete newMesh		-- non-optimal way, may skip mesh creation
			return undefined
		)
		if numBones <= 0 then
		(
			return undefined
		)
	
	--	redrawViews()
	
		modPanel.setCurrentObject skinMod
	
		-- setup vertex influences (weights)
		qsort Infs InfluenceSort
	
	/*	for i = 1 to numInfluences-1 do
		(
			v1 = Infs[i]
			v2 = Infs[i+1]
			if (v1.PointIndex == v2.PointIndex) and (v1.BoneIndex == v2.BoneIndex) then
				format "Point % has multiple weights for bone %\n" v1.PointIndex MeshBones[v2.BoneIndex].Name
		) */
	
		-- build vertex to influence map
		vertInfStart = #()
		vertInfNum   = #()
		vertInfStart[numVerts] = 0		-- preallocate
		vertInfNum[numVerts]   = 0		-- ...
		count = 0
		for i = 1 to numInfluences do
		(
			v     = Infs[i]
			vert  = v.PointIndex+1
			count += 1
			if (i == numInfluences) or (Infs[i+1].PointIndex+1 != vert) then
			(
				-- flush
				vertInfStart[vert] = i - count + 1
				vertInfNum[vert]   = count
				count = 0
			)
		)
	
	--	progressStart "Setting weights ..."
		disableSceneRedraw()
		try
		(
			for wedge = 1 to numWedges do
			(
				vert    = Wedges[wedge].PointIndex+1
				start   = vertInfStart[vert]
				numInfs = vertInfNum[vert]
	/*
				-- This code uses SetVertexWeights; it is fast, but Max will automatically assign
				-- vertex weights to a nearest bone when creating mesh, and there is no simple
				-- way to erase them. SetVertexWeights will not erase extra weights.
				for i = 1 to numInfs do
				(
					v = Infs[start + i - 1]
	--				format "Inf %(%) % : %\n" wedge vert MeshBones[v.BoneIndex+1].Name v.Weight
					skinOps.SetVertexWeights skinMod wedge (v.BoneIndex+1) v.Weight
				) */
	
				-- This code uses ReplaceVertexWeights with arrays, a few times slower;
				-- it is still here in a case of bugs with SetVertexWeights path
				infBones   = #()
				infWeights = #()
				for i = 1 to numInfs do
				(
					v = Infs[start + i - 1]
					append infBones   (v.BoneIndex + 1)
					append infWeights v.Weight
				)
	--			format "W[%] V[%] % // %\n" wedge vert infBones infWeights
				skinOps.ReplaceVertexWeights skinMod wedge infBones infWeights
				-- NOTE: ReplaceVertexWeights will reset infBones and infWeights arrays, so we
				-- cannot reuse them
	--			progressUpdate (100.0 * wedge / numWedges)
			)
		)
		catch
		(
			enableSceneRedraw()
	--		progressEnd()
			throw()
		)
		enableSceneRedraw()
	--	progressEnd()
	
		-- apply mesh rotation
		if numBones >= 1 then
		(
			MaxBones[1].transform = MaxBones[1].transform * GetRotationMatrix()
		)
	
		-- combine with old skeleton for correct work of combined meshes
		format "... processing % OldMeshBones\n" OldMeshBones.count
		for i = 1 to OldMeshBones.count do
		(
			boneName = OldMeshBones[i].Name
			found = false
			-- find bone in MeshBones
			for j = 1 to MeshBones.count do
			(
				if MeshBones[j].Name == boneName then
				(
	--				format "..... found in MeshBones"
					found = true
					exit
				)
			)
			if not found then
			(
				-- bone already exists in MeshBones array
				-- find bone in Max scene
				if getNodeByName boneName exact:true ignoreCase:false != undefined then
				(
					-- bone still exists in Max scene, should add it to MeshBones array
					MeshBones[MeshBones.count+1] = OldMeshBones[i]
	--				format "... restored bone from old mesh: %\n" boneName
				)
			)
		)
	
		gc()
	)
	-----------------------------
	-----------------------------
	fn getClipboardTxt =
	(
		local clipboardClass = dotNetClass "System.Windows.Forms.Clipboard"
		if clipboardClass.containstext() then clipboardClass.getText() else ""
	)
	fn getMeshType p =
	(
		local mesh_type = (filterString p "'")[1]
		case mesh_type of
		(
			"StaticMesh"  :("StaticMesh" )
			"SkeletalMesh":("SkeletalMesh")
		)
	)
	fn correctPathSlashes path =
	(
		local path_array = filterString path "\/"
		format "pa1:%\n" path_array
		new_path  = ""
		for i=1 to path_array.count do 
		if i < path_array.count 
		then new_path += path_array[i]+"\\\\"
		else new_path += path_array[i]
		format "pa2:%\n" new_path
		return new_path
	)
	fn addPath ddl ini_key path:undefined =
	(
		if path == undefined do path = getSavePath caption:" Chose Dir..." initialDir:"C:\\Dev\\"
		if path != undefined do 
		(
			--dupplicate check
			if findItem ddl.items path == 1 do return false
			
			local dirs = #(path) + ddl.items
			ddl.items = dirs
			
			delIniSetting ini_file ini_key 
			for i in dirs do setIniSetting ini_file ini_key  i ""
		)	
	)
	fn delPath ddl ini_key = 
	(
		if ddl.items.count > 0 do 
		(	
			delIniSetting ini_file ini_key ddl.selected
			ddl.items = (deleteItem ddl.items 1)
		)
	)
	fn getModelFromPackage full_model_path export_dir package_path package_name model_name =
	(
		
		format "export_dir:%\n" export_dir
		print "getting.... Model From Package"
		--rem cesta out + cesta in + balik + nazev modelu = exportuje model
		--umodel -out=Export -path=Packages -export itm_cinema key01_obj_uni_ac

		local umod_file    = Micra.RootDir+"App\\umodel.exe"
		--cesta je jeste jednou zastringovana kvuli mezeram a dlouhym nazvum
		local cmd = "\"" +umod_file + "\"" +" -out="+export_dir +" -path="+package_path +" -export  -all "+ package_name +" "+ model_name + "\n"
		cmd = correctPathSlashes cmd
		DOSCommand cmd
		
		local mesh_type = getMeshType full_model_path
		if mesh_type ==undefined do return ""
		local extension = case mesh_type of
		(
			"StaticMesh"  :".pskx"
			"SkeletalMesh":".psk"
		)
		if extension == undefined do return "" --if unknow format converted
		local fpath = export_dir+package_name+"\\"+mesh_type+"\\"+model_name+extension
		return fpath
	)
	fn checkIniFile =
	(
		ini_file = GetDir #scripts + "\\UE_To_3DsMax_Importer.ini "
		if not doesFileExist ini_file do try 
		(
			local f = createFile ini_file
			close f
			
			setIniSetting ini_file "export_dirs" "C:\\Temp\\UE_Export\\" ""
			setIniSetting ini_file "packages_dirs" "C:\\Dev\\SilentHill\\SHGame\\Content\\Packages\\" ""
			setIniSetting ini_file "packages_dirs" "C:\\Dev\\D-Arms\\Game\\DAGame\\Content\\Packages\\" ""
		) 
		catch (return false)
		return true
	)
	fn loadSettings =
	(
		
		local packages_dirs = getIniSetting ini_file "packages_dirs"
		local export_dirs = getIniSetting ini_file "export_dirs"
		local models_paths = getIniSetting ini_file "models_paths"
		--load data from ini file if exist
		if packages_dirs.count  !=0 do ddl_packagepath.items = packages_dirs
		if export_dirs.count      !=0 do ddl_exportpath.items = export_dirs
		if models_paths.count  !=0 do ddl_modelpath.items = models_paths
		
		--full path = SkeletalMesh'itm_cinema.Meshes.key01_obj_uni_ac'
		full_model_path = getClipboardTxt()
		if getMeshType full_model_path != undefined do 
		(	
			addPath ddl_modelpath "models_paths" path:full_model_path
		)
		
		export_dir = ddl_exportpath.selected
	)
	fn inicializeData =
	(
		if doesFileExist export_dir do export_dir = "C:\\Temp\\UE_Export\\"
		if not doesFileExist export_dir do makeDir export_dir
		
		if getSourceFileName != undefined then	-- checking Max version (Max9+) ...
		(
			local s = getSourceFileName()
			configFile = (getFilenamePath s) + (getFilenameFile s) + ".ini"
		)
		
		if (g_axImporterInited != true) then
		(
			-- initialize plugin
			g_axImporterInited = true
			g_axImporterVersion = AX_IMPORTER_VERSION
			heapSize += 33554432	-- 32 Mb; will speedup most tasks
			Anims     = #()
			MeshBones = #()
			DefaultSettings()
			SerializeSettings(true)
		)

		if (g_axImporterVersion != AX_IMPORTER_VERSION) then
		(
			format "Actor X Importer were updated while 3ds Max is running.\nReloading config settings.\n"
			--?? used twice, make a separate function ?
			g_axImporterVersion = AX_IMPORTER_VERSION
			DefaultSettings()
			SerializeSettings(true)
		)
	)
	fn getDirsRecursive dir =
	(
		--format "\ndir:%\n" dir
		local dirs = getDirectories (dir+"*.*")	
		if dirs.count == 0 do return false
		--format "dirs:%\n" dirs	
		all_dirs += dirs
		for d in dirs do getDirsRecursive (d+"*.*")
	)
	fn mergeAllFilesIn dir = 
	(
		--collect all subdirs
		getDirsRecursive dir
		--collect all files
		local all_files = #()
		for d in all_dirs do all_files += getFiles (d+"\\*.*")
		--delete dupplicates in root dir
		local all_file_names = for f in all_files collect (filenameFromPath f)
		local root_files = getFiles (dir+"*.*")
		--format "all_files:%\n" all_files
		--format "all_file_names:%\n" all_file_names
		--format "root_files:%\n" root_files
		for f in root_files do
		(	
			local f_name = (filenameFromPath f)
			for n in all_file_names where f_name == n do
			(
				deleteFile f
				continue
			)
		)
		--copy all files to root dir
		for f in all_files do copyFile f (dir+"\\"+filenameFromPath f)
		--delete all dirs
		local root_dirs = getDirectories (dir+"\\*.*") 
		for d in root_dirs do DOSCommand ("RD "+d+" /s /q")
	)
	fn importUEModel =
	(
		--full path = SkeletalMesh'itm_cinema.Meshes.key01_obj_uni_ac'

		local full_model_path = ddl_modelpath.selected
		local full_model_path_array = filterString full_model_path "'."
		if full_model_path_array.count < 3 do return false 
		local package_name = full_model_path_array[2]
		local packages_dir = ddl_packagepath.selected
		package_file = FindFile packages_dir (package_name+".upk") recurse:true
		if package_file == undefined or not doesFileExist package_file do return false
		local package_path = getFilenamePath  package_file
		local model_name   = full_model_path_array[full_model_path_array.count] --last array item
		--format "Package file: %\n" package_file
		--format "Package is found?: %\n" (doesFileExist package_path)
		--get model from UE and check if is success
		local fpath =getModelFromPackage full_model_path (export_dir+package_name) package_path package_name model_name
		
		if fpath != "" do 
		(	
			--merge all imported files to one dir
			mergeAllFilesIn (export_dir+package_name)
			--import psk file to max
			fpath = (export_dir+package_name+"\\")+(filenameFromPath fpath)
			--format "importing file path:%\n" fpath
			--format "file path check:%\n" (doesFileExist fpath)
			if doesFileExist fpath do importPskFile fpath skelOnly:false
		)
	)
	fn deleteTemporaryFiles =
	(
		local temp_path = ddl_exportpath.selected	
		if not doesFileExist temp_path do return false
		if queryBox ("You want to delete all files in dir?\n"+temp_path+"") title: "Delete Files?" do 
		(	
			--del all dirs and files in dir
			DOSCommand ("RD "+temp_path+" /s /q")
		)
	)
	--> actions
	on mcUEToMaxImporter open do
	(
		if checkIniFile() 
		then (loadSettings())
		else (destroyDialog mcUEToMaxImporter)
	)
	
	on btn_ad1 pressed  do (addPath ddl_packagepath "packages_dirs" )
	on btn_ad2 pressed  do (addPath ddl_exportpath "export_dirs")
	on btn_ad3 pressed  do 
	(
		local full_model_path = getClipboardTxt()
		if getMeshType full_model_path != undefined do 
		(	
			addPath ddl_modelpath "models_paths" path:full_model_path
		)
	)
	
	on btn_del1 pressed  do (delPath ddl_packagepath "packages_dirs")
	on btn_del2 pressed  do (delPath ddl_exportpath "export_dirs")
	on btn_del3 pressed  do (delPath ddl_modelpath "models_paths" )
	
	on btn_delfiles pressed do (deleteTemporaryFiles())
	on btn_import pressed  do
	(
		inicializeData()
		importUEModel()
	)
)
createDialog mcUEToMaxImporter


/*
UMODEL (UE Viewer)
(c) Konstantin Nosov (Gildor), 2007-2011

Command line

umodel
    display short command line help

umodel -path=c:/games/ut2004 HumanMaleA
    list all packaged objects from HumanMaleA

umodel -path=c:/games/ut2004 HumanMaleA MercMaleD
    display mesh MercMaleD from package HumanMaleA

umodel -path=c:/games/ut2004 -export HumanMaleA MercMaleD
    export SkeletalMesh MercMaleD from HumanMaleA package as psk

umodel -path=c:/games/ut2004 -export -md5 HumanMaleA MercMaleD
    export SkeletalMesh MercMaleD from HumanMaleA package as md5mesh

umodel -path=c:/games/ut2004 -export -all HumanMaleA MercMaleD
    export SkeletalMesh MercMaleD and all used resources (animation, textures etc)

umodel -path=c:/games/ut2004 -export HumanMaleA BipedMaleA
    export animations (MeshAnimation) BipedMaleA from HumanMaleA package as psa

umodel -path=c:/games/ut2004 -export -md5 HumanMaleA BipedMaleA
    export animations (MeshAnimation) BipedMaleA from HumanMaleA package as md5anim

umodel -path=c:/games/ut2004 -export HumanMaleA
    export all supported objects from HumanMaleA package

umodel -path=c:/games/ut2004 -list HumanMaleA
    list contents of HumanMaleA package (object and class names)

umodel -path=c:/games/ut2004 -export 2K4_NvidiaIntro Intro2k4Skaarj MeshAnimation
umodel -path=c:/games/ut2004 -export 2K4_NvidiaIntro Intro2k4Skaarj SkeletalMesh
    export skaarj mesh and animations from package 2K4_NvidiaIntro (both objects has the same name, but different class names, so class name is specified)

umodel -list c:/games/unreal/music/QueenSong.umx
    list contents of QueenSong.umx package from Unreal1. Here is package name specified with full file path.
*/