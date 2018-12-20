macroScript Bake
category:"BFDtools"
buttontext:"Bake"
tooltip:"Bake - Bake a selection of objects"
icon:#("BFDtools-Icons",2)
(
 
------------------------------------------------------------------------------------------
-- Contents:
--		Bake - Bakes a selection of object properties (mesh, transform, ...)
--
-- Requires:
--		Avg_dlx.dlx, v2.02
--		jbFunctions.ms
------------------------------------------------------------------------------------------
--To add a new bake type:
--	Define a new rollout immediately beneath the other bake type rollouts
--	Append the rolloutNameList and rolloutList arrays to register the bake type
--	Append the rolloutSizeList array with the vertical size of your rollout
--	In your rollout, define a function called bake that will actually do the baking
--		This function can reference the Bake local variables like start and end times, etc.
--		The bake function should obey all options in the main Bake rollout
--		It is passed two arguments:
--			An array of objects to bake
--			An empty array to be filled with the baked objects
--			The first array should be trimmed by the bake function to
--			remove any objects that were not baked for whatever reason.
--		It should RETURN true if success or false if it failed
------------------------------------------------------------------------------------------
-- TODO: step through with timeslider instead of sample at random time points,
--		for solutions that depend on solving from frame 0?
------------------------------------------------------------------------------------------
 
if (
	if (jbFunctionsCurrentVersion == undefined OR (jbFunctionsCurrentVersion() < 11)) then (
		local str = "This script requires jbFunctions to run properly.\n\nYou can get the latest version at http://www.johnburnett.com/.\n\nWould you like to connect there now?"
		if (QueryBox str title:"Error") then ( try (ShellLaunch "http://www.johnburnett.com/" "") catch () )
		FALSE
	) else (
		jbFunctionsVersionCheck #( #("jbFunctions",11), #("avg_dlx",2.02) )
	)
) then (
 
	-- Change this path to point to where the script is installed!
	local bakePath = (getDir #ui) + "\\macroscripts"
 
	local thisTool = BFDtool	toolName:"Bake" 			\
								author:"John Burnett"		\
								createDate:[11,11,1999]		\
								modifyDate:[5,21,2001]		\
								version:1					\
								defFloaterSize:[220,577]	\
								autoLoadRolloutStates:false	\
								autoLoadFloaterSize:false
								--defFloaterSize:[220,543]\
 
	
	local OORBitmap = try (openBitmap (bakePath + "\\Bake\\BFDtools-Bake_Buttons.bmp")) catch (bitmap 168 18 color:green)
	local OORTypeBitmaps = #()
	for btnIdx in 1 to 6 do (
		OORTypeBitmaps[btnIdx] = bitmap 28 18
		for y in 0 to 17 do (
			local row = getPixels OORBitmap [(btnIdx-1) * 28, y] 28
			setPixels OORTypeBitmaps[btnIdx] [0, y] row
		)
	)
 
 
	-- Local variables available to all bake types ------------------------------------
	local startTime = ((animationRange.start as float/ticksPerFrame) as integer)
	local endTime = ((animationRange.end as float/ticksPerFrame) as integer)
	local nthFrame = 1
	local delOrig = false
	local addSuffix = true
	local selBaked = true
	local bakeXRef = false
	local bakeSeparateFiles = true
	local useScenePath = true
	local bakeXRefPath = "" --maxFilePath
	local bakeType = 2
	local rolloutNameList, rolloutList, rolloutSizeList
	local InOORType = 1
	local OutOORType = 1
	local OORTypes = #("Constant","Cycle","Loop","PingPong","Linear","RelativeRepeat")
	-----------------------------------------------------------------------------------
 
	fn getValidMeshes objs = (
		local meshObjs = #()
		for obj in objs do (
			if (canConvertTo obj mesh) then append meshObjs obj
		)
		return meshObjs
	)
 
	fn defaultTransforms obj = (
		obj.transform.controller = prs()
		deleteKeys obj.transform.controller #allKeys
 
		obj.position.controller = bezier_position()
		deleteKeys obj.position.controller #allKeys
		setBeforeORT obj.position.controller #constant
		setAfterORT obj.position.controller #constant
 
		obj.rotation.controller = tcb_rotation()
		deleteKeys obj.rotation.controller #allKeys
		setBeforeORT obj.rotation.controller #constant
		setAfterORT obj.rotation.controller #constant
 
		obj.scale.controller = bezier_scale()
		deleteKeys obj.scale.controller #allKeys
		setBeforeORT obj.scale.controller #constant
		setAfterORT obj.scale.controller #constant
	)
 
	fn zeroObjTransforms obj = (
		defaultTransforms obj
		obj.objectOffsetScale = [1,1,1]
		obj.objectOffsetRot = quat 0 0 0 1
		obj.objectOffsetPos = [0,0,0]
		obj.transform = (matrix3 1)
	)
 
	-- Get an object snapshot in the specified coordSys space
	fn getBakeSnap obj snapSpace t = (
		local snap = copy obj
		snap.name = "Frame" + (getPadNum t 4) as string
		convertToMesh snap
		-- kill vertex animation on snap
		if (snap[4][1].keys.count != 0) do (DeleteKeys snap[4][1].controller #allKeys)
 
		case snapSpace of (
			#world: (
				snap.parent = undefined
				zeroObjTransforms snap
				snap.mesh = at time t snapshotAsMesh obj
			)
			#object: (
				snap.parent = obj.parent
				snap.mesh = at time t obj.mesh
			)
		)
 
		update snap
		return snap
	)
 
	fn killCloth objs = (
		local oldSel = selection as array
		local success = true
		local obj, m, failObj
		progressStart "Checking objects..."
		undo on (
			for i in 1 to objs.count do (
				if not (progressUpdate (i as float/objs.count*100)) then (
					max undo
					select oldSel
					return()
				)
				obj = objs[i]
				for j in obj.modifiers.count to 1 by -1 do (
					m = obj.modifiers[j]
					if (classOf m) == ClothReyes_3 then (
						try (
							deleteModifier obj j
						) catch (
							success = false
							failObj = obj
						)
						--format "obj: %, m:%, j:%, success:%\n" obj.name m j success
					)
				)
			)
		)
		progressEnd()
		select oldSel
		if success == false then (
			str = "Unexpected error occured while attempting to delete
cloth on object" + failObj.name + "
 
Without making any sudden movements, calmly go tell John."
			messageBox str title:"Oops"
		)
		return success
	)
 
	fn CollapsePointCache obj = (
		local idx = 0
		local pc = undefined
		for i in obj.modifiers.count to 1 by -1 do (
			local mc = ClassOf obj.modifiers[i]
			if (mc == Point_Cache_2 OR
				mc == Point_Cache_2SpacewarpModifier) then (
				idx = i
				pc = copy obj.modifiers[i]
				exit
			)
		)
 
		if (idx != 0) then (
			ConvertToMesh obj
			-- kill vertex animation on object
			if (obj[4][1].keys.count != 0) do (DeleteKeys obj[4][1].controller #allKeys)
 
			if (ClassOf pc == Point_Cache_2) then (
				AddModifier obj pc
			)
			return TRUE
		)
 
		return FALSE
	)
--------------------------------------------------------------------------------------------------
	rollout DLGmeshRollout "Mesh Animation" (
		local outputType
		local bakeSpace
		local bakeSpaces
		local subAnimList
 
		fn updateUI = (
			DLGmeshRollout.DLGbakeSpace.state = bakeSpace
			DLGmeshRollout.DLGoutputType.state = outputType
		)
 
		fn bake sourceObjs bakedObjs = (
			-- Grab valid bake objects
			local srcObjs = getValidMeshes sourceObjs
 
			-- Trim out any invalid bake objects
			for i in sourceObjs.count to 1 by -1 do (
				if (findItem srcObjs sourceObjs[i]) == 0 then deleteItem sourceObjs i
			)
 
			case outputType of (
				-- Morph Object
				1: (
					local morphObjs = #(); morphObjs.count = srcObjs.count
 
					-- Create initial morph objects
					for i in 1 to srcObjs.count do (
						local obj = srcObjs[i]
 
						morphObj = getBakeSnap obj bakeSpaces[bakeSpace] startTime
						morphObj.name = obj.name
						if addSuffix then morphObj.name += "_MESHBAKE"
 
						createMorphObject morphObj
						setMorphTargetName morphObj.morph 1 ("Frame" + (getPadNum startTime 4))
						addNewKey morphObj.morph startTime
 
						morphObjs[i] = morphObj
					)
 
					-- Add all snapshot targets to the base morph objects
					progressStart ("(Step 1/2) Gathering Snapshots")
					for t in (startTime + nthFrame) to endTime by nthFrame do (
						for i in 1 to srcObjs.count do (
							local snap = getBakeSnap srcObjs[i] bakeSpaces[bakeSpace] t
							addMorphTarget morphObjs[i].morph snap 3
							local numTargets = (getMKTargetNames morphObjs[i].morph).count
							setMorphTargetName morphObjs[i].morph numTargets ("Frame" + (getPadNum t 4))
						)
						progressUpdate ((t - startTime) as float/(endTime - startTime) * 100)
					)
					progressEnd()
 
					progressStart("(Step 2/2) Morphing")
					-- Get rid of morph keys made when the targets were added
					for obj in morphObjs do (
						deleteKeys obj.morph.controller #allKeys
					)
					-- Go through and add the final morph keys
					local targetIdx = 1
					for t in startTime to endTime by nthFrame do (
						for obj in morphObjs do (
							-- add a key and set the key value to the new target
							addNewKey obj.morph.controller t
							setMKWeight (getMKKey obj.morph.controller t) targetIdx 100 true
						)
						targetIdx += 1
						progressUpdate ((t - startTime) as float/(endTime - startTime) * 100)
					)
					for obj in morphObjs do (
						setBeforeORT obj.morph.controller (OORTypes[InOORType] as name)
						setAfterORT obj.morph.controller (OORTypes[OutOORType] as name)
					)
					progressEnd()
					bakedObjs.count = morphObjs.count
					for i in 1 to morphObjs.count do bakedObjs[i] = morphObjs[i]
				)
				-- Vertex Animation
				2: (
					for srcIdx in 1 to srcObjs.count do (
						local sourceObj = srcObjs[srcIdx]
 
						local targObj = snapshot sourceObj
						targObj.parent = sourceObj.parent
						targObj.transform.controller = sourceObj.transform.controller
 
						if addSuffix then targObj.name += "_VERTBAKE"
						animateVertex targObj #all
						local masterCtrl = targObj[4][1]	-- shortcut to vertex controllers
 
						-- assign OOR types
						for i in 1 to targObj.numVerts do (
							setBeforeORT masterCtrl[i].controller (OORTypes[InOORType] as name)
							setAfterORT masterCtrl[i].controller (OORTypes[OutOORType] as name)
						)
 
						progressStart ("Baking " + (srcIdx as string) + " of " + (srcObjs.count as string) + "...")
 
						for t in startTime to endTime by nthFrame do
						(
							local k								-- key added for each vert
 
							for i in 1 to targObj.numVerts do
							(
								k = addNewKey masterCtrl[i].controller t
								k.value = at time t in coordSys sourceObj getVert sourceObj i
							)
 
							local cont = progressUpdate ((t - startTime) as float/(endTime - startTime) * 100)
							if NOT cont then return true
						)
 
						progressEnd()
 
						append bakedObjs targObj
					)
				)
			)
			return true
		)
 
--			case outputType of (
--				-- Morph Object
--				1: (
--					-- loop through source objects and create base morph objects
--					local morphObjs = #()
--
--					for obj in srcObjs do (
--						-- Snapshot world state of the mesh
--						local msh = at time startTime snapshotAsMesh obj
--
--						-- Copy source to keep any extra props intact (materials, obj properties, etc)
--						local morphObj = copy obj
--						morphObj.name = if addSuffix then ( obj.name + "_MESHBAKE" ) else ( obj.name )
--						morphObj.parent = undefined
--						convertToMesh morphObj
--
--						-- Zero the transforms
--						zeroObjTransforms morphObj
--
--						-- Set the morph object's mesh to the world state mesh of the source
--						morphObj.mesh = msh
--						update morphObj
--
--						-- Convert to a morph object
--						createMorphObject morphObj
--						setMorphTargetName morphObj.morph 1 ("Frame" + (getPadNum startTime 4))
--						addNewKey morphObj.morph startTime
--
--						-- Add morph object to list of final morph objects
--						append morphObjs morphObj
--					)
--
--					progressStart ("(Step 1/2) Gathering Snapshots")
--					-- Add all snapshot targets to the base morph objects
--					local snap = mesh numVerts:0 numFaces:0 -- temp object for morph targets to fill with snapshot mesh
--					-- loop through time range and morph objects
--					for t in (startTime+nthFrame) to endTime by nthFrame do (
--						for i in 1 to srcObjs.count do (
--							-- grab mesh at time t
--							snap.mesh = at time t snapshotAsMesh srcObjs[i]
--							update snap
--							-- add it as a morph target, set the name
--							addMorphTarget morphObjs[i].morph snap 2
--							local numTargets = (getMKTargetNames morphObjs[i].morph).count
--							setMorphTargetName morphObjs[i].morph numTargets ("Frame" + (getPadNum t 4))
--						)
--						progressUpdate ((t - startTime) as float/(endTime - startTime) * 100)
--					)
--					delete snap
--					progressEnd()
--
--					progressStart("(Step 2/2) Morphing")
--					-- Get rid of morph keys made when the targets were added
--					for obj in morphObjs do (
--						deleteKeys obj.morph.controller #allKeys
--					)
--					-- Go through and add the final morph keys
--					local targetIdx = 1
--					for t in startTime to endTime by nthFrame do (
--						for obj in morphObjs do (
--							-- add a key and set the key value to the new target
--							addNewKey obj.morph.controller t
--							setMKWeight (getMKKey obj.morph.controller t) targetIdx 100 true
--						)
--						targetIdx += 1
--						progressUpdate ((t - startTime) as float/(endTime - startTime) * 100)
--					)
--					progressEnd()
--					bakedObjs = morphObjs
--				)
--				-- Separate objects
--				2: (
--					local numFrames = ((endTime - startTime) as float / nthFrame) as integer
--					progressStart ("Baking over " + numFrames as string + " frames...")
--					for t in startTime to endTime by nthFrame do (
--						for obj in srcObjs do (
--							progressUpdate ((t - startTime) as float / (endTime - startTime) * 100)
--							local snap = copy obj
--							convertToMesh snap
--							snap.parent = undefined
--							zeroObjTransforms snap
--							snap.mesh = at time t snapshotAsMesh obj
--							snap.name = obj.name + "_Frame" + (getPadNum t 4)
--							append bakedObjs snap
--						)
--					)
--					progressEnd()
--				)
--				-- Vertex List
--				3: (
--					--point pos:$.verts[1].pos
--					--point pos:((getVert $.mesh 1)*$.objectTransform)
--				)
--			)
--
--			if delOrig then delete srcObjs
--			return bakedObjs
--		)
 
		label DLGbakeSpaceLabel "Bake Space:" align:#left
		radiobuttons DLGbakeSpace labels:#("Object","World") columns:1 align:#left offset:[10,0] enabled:false
		label DLGoutputTypeLabel "Output To:" align:#left
		radiobuttons DLGoutputType labels:#("Morph Object","Vertex Animation") align:#left offset:[10,0]
 
		on DLGbakeSpace changed state do
		(
			bakeSpace = state
			updateUI()
		)
 
		on DLGoutputType changed state do
		(
			outputType = state
			-- temporary, since morphs only does world and vertex only does local for now
			bakeSpace = (3 - state)
 
			updateUI()
		)
 
		on DLGmeshRollout open do
		(
			outputType = 1
			bakeSpace = 2
			bakeSpaces = #(#object,#world)
			subAnimList = false
 
			updateUI()
		)
	)
 
--------------------------------------------------------------------------------------------------
	rollout DLGobjTransRollout "Object Transform" (
		local keyTypes
		local bakePos
		local bakeRot
		local bakeScale
		local posKeyType
		local rotKeyCont
		local scaleKeyType
		local unlink
 
		fn updateUI = (
			DLGobjTransRollout.DLGbakePos.checked = bakePos
			DLGobjTransRollout.DLGbakeRot.checked = bakeRot
			DLGobjTransRollout.DLGbakeScale.checked = bakeScale
			DLGobjTransRollout.DLGposKeyType.selection = posKeyType
			DLGobjTransRollout.DLGrotKeyCont.value = rotKeyCont
			DLGobjTransRollout.DLGscaleKeyType.selection = scaleKeyType
			DLGobjTransRollout.DLGunlink.checked = unlink
		)
 
		fn bake sourceObjs bakedObjs = (
			-- Trim any objects that are invalid for baking
			for i in sourceObjs.count to 1 by -1 do (
				local obj = sourceObjs[i]
				local trimIt = false
 
				--Biped objects and "finger dummies"
				trimIt = trimIt OR (classOf obj == Biped_Object)
				trimIt = trimIt OR ((classOf obj == Dummy) AND (obj.transform.controller == undefined))
				--Bone objects with IK controllers
				trimIt = trimIt OR ((classOf obj == Bone) AND (obj.transform.controller == IK_ControllerMatrix3Controller))
 
				if trimIt then deleteItem sourceObjs i
			)
 
			-- Create the bake objects
			bakedObjs[sourceObjs.count] = undefined
			for i in 1 to sourceObjs.count do (
				-- Set up initial baked objects
				bakedObjs[i] = copy sourceObjs[i]
				bakedObjs[i].name = sourceObjs[i].name
				if addSuffix then bakedObjs[i].name += "_TRANSBAKE"
 
				defaultTransforms bakedObjs[i]
			)
 
			-- Set up parenting
			for i in 1 to bakedObjs.count do (
				if unlink then (
					bakedObjs[i].parent = undefined
				) else (
					-- Get original parent
					local theParent = sourceObjs[i].parent
					-- See if parent is being baked as well
					local idx = findItem sourceObjs theParent
					-- If it is, then baked object should use the baked version as a parent
					if idx != 0 then theParent = bakedObjs[idx]
					bakedObjs[i].parent = theParent
				)
			)
 
			progressStart ("Baking Transforms...")
 
--			local lastRot = #()
--			for i in 1 to bakedObjs.count do lastRot[i] = quat 1
 
			for obj in bakedObjs do (
				addNewKey obj.position.controller startTime
				addNewKey obj.rotation.controller startTime
				addNewKey obj.scale.controller startTime
			)
 
			for t in startTime to endTime by nthFrame do (
				for i in 1 to bakedObjs.count do (
--					if bakeRot then (
----						local k = addNewKey bakedObjs[i].rotation.controller t
----						local aRot = at time t sourceObjs[i].rotation
----						local rRot = aRot - lastRot[i]
----						k.value = rRot as angleAxis
----						lastRot[i] = aRot
--					)
--					if bakePos then (
--						local k = addNewKey bakedObjs[i].pos.controller t
--						k.value = at time t sourceObjs[i].pos
--					)
--					if bakeScale then (
--						local k = addNewKey bakedObjs[i].scale.controller t
--						k.value = at time t sourceObjs[i].scale
--					)
					animate on at time t bakedObjs[i].transform = at time t sourceObjs[i].transform
				)
				progressUpdate ((t - startTime) as float/(endTime - startTime) * 100)
			)
			for obj in bakedObjs do (
				-- remove unwanted keys
				if NOT bakePos then (
					local savePos = at time startTime obj.pos
					deleteKeys obj.position.controller #allKeys
					at time startTime obj.pos = savePos
				)
				if NOT bakeRot then (
					local saveRot = at time startTime obj.rotation
					deleteKeys obj.rotation.controller #allKeys
					at time startTime obj.rotation = saveRot
				)
				if NOT bakeScale then (
					local saveScale = at time startTime obj.scale
					deleteKeys obj.scale.controller #allKeys
					at time startTime obj.scale = saveScale
				)
 
				-- Set Out Of Range types
				if bakePos then (
					setBeforeORT obj.position.controller (OORTypes[InOORType] as name)
					setAfterORT obj.position.controller (OORTypes[OutOORType] as name)
				)
				if bakeRot then (
					setBeforeORT obj.rotation.controller (OORTypes[InOORType] as name)
					setAfterORT obj.rotation.controller (OORTypes[OutOORType] as name)
				)
				if bakeScale then (
					setBeforeORT obj.scale.controller (OORTypes[InOORType] as name)
					setAfterORT obj.scale.controller (OORTypes[OutOORType] as name)
				)
 
				-- Set key tangents
				for k in obj.position.keys do (
					k.inTangentType = keyTypes[posKeyType] as name
					k.outTangentType = keyTypes[posKeyType] as name
				)
				for k in obj.rotation.keys do (
					--format "time: %, value: %, [t,c,b]: [%,%,%], in: %, out: %\n" k.time k.value k.tension k.continuity k.bias k.easeTo k.easeFrom
					--print k
					k.continuity = rotKeyCont
					--format "time: %, value: %, [t,c,b]: [%,%,%], in: %, out: %\n" k.time k.value k.tension k.continuity k.bias k.easeTo k.easeFrom
				)
				for k in obj.scale.keys do (
					k.inTangentType = keyTypes[scaleKeyType] as name
					k.outTangentType = keyTypes[scaleKeyType] as name
				)
			)
			progressEnd()
 
			return true
		)
 
		group "Bake" (
			checkbox DLGbakePos "Position" align:#left
			dropdownlist DLGposKeyType "" width:80 offset:[90,-24]
			checkbox DLGbakeRot "Rotation" align:#left
			spinner DLGrotKeyCont "Cont:" range:[0,50,25] type:#float width:70 offset:[22,-22]
			checkbox DLGbakeScale "Scale" align:#left offset:[0,5]
			dropdownlist DLGscaleKeyType "" width:80 offset:[90,-24]
		)
		group "Options" (
			checkbox DLGunlink "Unlink From Parent" align:#left
		)
		on DLGbakePos changed state do ( bakePos = state; updateUI() )
		on DLGposKeyType selected idx do ( posKeyType = idx; updateUI() )
		on DLGbakeRot changed state do ( bakeRot = state; updateUI() )
		on DLGbakeScale changed state do ( bakeScale = state; updateUI() )
		on DLGscaleKeyType selected idx do ( scaleKeyType = idx; updateUI() )
		on DLGunlink changed state do ( unlink = state; updateUI() )
 
		on DLGobjTransRollout open do (
			keyTypes = #("smooth","linear","step","fast","slow","custom")
			DLGposKeyType.items = keyTypes
			DLGscaleKeyType.items = keyTypes
			bakePos = true
			bakeRot = true
			bakeScale = false
			posKeyType = 2
			rotKeyCont = 0.0
			scaleKeyType = 2
			unlink = true
 
			updateUI()
		)
	)
 
--------------------------------------------------------------------------------------------------
	rollout DLGffdRollout "FFD Spacewarp Animation" (
		fn bake sourceObjs bakedObjs = (
			print "baking FFD"
		)
		label DLGnoneLabel "unfinished"
	)
 
--------------------------------------------------------------------------------------------------
	rollout DLGshapeRollout "Shape Animation" (
		fn bake sourceObjs bakedObjs = (
			local MASTER_IDX = if (MaxVersion())[1] >= 4000 then 4 else 1
 
			for i in sourceObjs.count to 1 by -1 do (
				local obj = sourceObjs[i]
				local trimIt = false
 
				--Can convert to a spline shape
				trimIt = trimIt OR NOT (canConvertTo obj splineShape)
 
				if trimIt then deleteItem sourceObjs i
			)
 
			for i in 1 to sourceObjs.count do (
				local shp = copy sourceObjs[i]
				shp.name = sourceObjs[i].name
				if addSuffix then shp.name += "_SHAPEBAKE"
				convertToSplineShape shp
				animateVertex shp #all
 
				local masterCtrl = shp[4][MASTER_IDX]
 
				-- assign OOR types
				for i in 1 to masterCtrl.numsubs do (
					setBeforeORT masterCtrl[i].controller (OORTypes[InOORType] as name)
					setAfterORT masterCtrl[i].controller (OORTypes[OutOORType] as name)
				)
 
				append bakedObjs shp
			)
 
			local numFrames = ((endTime-startTime)/NthFrame as float) as integer
			ProgressStart ("Baking " + (numFrames as string) + " Frames...")
 
			local totFrames = 0.0
 
			-- massive kludge for updating skin on object
			PushCommandPanelTaskMode #modify
			local oldSliderTime = sliderTime
 
			for t in startTime to endTime by NthFrame do (
				for i in 1 to bakedObjs.count do (
					local obj = bakedObjs[i]
 
					local tmpObj = copy sourceObjs[i]
					-- massive kludge for updating skin on object
					for m in tmpObj.modifiers do (
						if (ClassOf m == Skin) then modPanel.SetCurrentObject m
						sliderTime += 1
					)
					at time t collapseStack tmpObj
					animateVertex tmpObj #all
 
					for i in 1 to obj[4][MASTER_IDX].numsubs do (
						local k = addNewKey obj[4][MASTER_IDX][i].controller t
						k.value = tmpObj[4][MASTER_IDX][i].value
					)
 
					delete tmpObj
				)
				totFrames += 1
				if NOT (ProgressUpdate (totFrames/numFrames * 100)) then (
					if NOT (QueryBox "Keep What Been Baked So Far?" title:"Bake") then (
						delete bakedObjs
						for i in bakedObjs.count to 1 by -1 do ( deleteItem bakedObjs i )
					)
 
					for i in sourceObjs.count to 1 by -1 do ( deleteItem sourceObjs i )
					ProgressEnd()
 
					return false
				)
			)
 
			PopCommandPanelTaskMode()
			sliderTime = oldSliderTime
 
			ProgressEnd()
 
			true
		)
		label DLGnoneLabel "No Options"
	)
--------------------------------------------------------------------------------------------------
	rollout DLGpointCacheRollout "Point Cache" (
		local bakeSpace
		local doCollapse
		local outputPath
 
		fn updateUI = (
			DLGpointCacheRollout.DLGoutputPath.text = outputPath
			DLGpointCacheRollout.DLGdoCollapse.checked = doCollapse
			DLGpointCacheRollout.DLGbakeSpace.state = bakeSpace
		)
 
		fn bake sourceObjs bakedObjs = (
			-- kludge to remove trailing "\\"
			while (outputPath[outputPath.count] == "\\") do outputPath = SubString outputPath 1 (outputPath.count-1)
 
			if ((getDirectories outputPath).count != 0) then
			(
				local oldMode = GetCommandPanelTaskMode()
				if (oldMode != #modify) then SetCommandPanelTaskMode mode:#modify
 
				-- which modifier to use based on desired bake space
				local cacheMaster = if (bakeSpace == 1) then PointCache2 else PointCache2WSM
 
				-- strip out all but one instance of each object
				local tmpMod = cacheMaster()
				for srcObjIdx in 1 to sourceObjs.count do
				(
					local src = sourceObjs[srcObjIdx]
					--src might be undefined if array got shrunk from under it
					if (src != undefined) then (
						if (ValidModifier src tmpMod) then (
							for targObjIdx in sourceObjs.count to (srcObjIdx+1) by -1 do
							(
								local targ = sourceObjs[targObjIdx]
								if	(src == targ) OR
									(IsInstance src targ) then DeleteItem sourceObjs targObjIdx
							)
						) else (
							DeleteItem sourceObjs srcObjIdx
						)
					)
				)
				tmpMod = undefined
 
				local bail = false
				progressStart ("Caching " + (sourceObjs.count as string) + " Objects...")
				local cachesToDisable = #() -- caches that should have stacks disabled after baking
				for objIdx in 1 to sourceObjs.count do
				(
					local obj = sourceObjs[objIdx]
 
					local cache = cacheMaster()
					cache.cacheFile = outputPath + "\\" + obj.name + ".pc2"
					cache.recordStart = cache.playbackStart = startTime
					cache.recordEnd = cache.playbackEnd = endTime
					cache.sampleRate = nthFrame
 
					AddModifier obj cache
 
					if (obj.modifiers[1] == cache) then (
						-- if modifier is at top of stack, just select object
						select obj
					) else (
						-- otherwise try to SetCurrentObject
						local modIdx = modPanel.GetModifierIndex obj cache
						modPanel.SetCurrentObject obj.modifiers[modIdx]
					)
 
					-- Workaround for SetCurrentObject not working in some cases
					if (modPanel.GetCurrentObject() != cache) then (
 
						DeleteModifier obj modIdx
 
						local str = "Error:  The following object is causing problems with the currently baking object,\nand must probably be deleted before Bake can continue:\n\n"
 
						local col = (refs.dependents (modPanel.GetCurrentObject()))[1]
						if (IsKindOf col node) then
							str += col.name
						else
							str += "Unknown"
 
						MessageBox str title:"Bake"
						bail = true
					) else (
						cacheOps.RecordCache cache
 
						if doCollapse then (
							CollapsePointCache obj
						) else (
							append cachesToDisable #(obj,cache)
						)
					)
 
					local cont = ProgressUpdate(objIdx as float / sourceObjs.count * 100)
					if NOT cont OR bail then (
						local endIdx = objIdx + 1
						if (endIdx > sourceObjs.count) then endIdx = sourceObjs.count
						for i in sourceObjs.count to endIdx do DeleteItem sourceObjs i
						exit
					)
				)
 
				-- Disable stacks below baked caches
				for tmp in cachesToDisable do (
					local obj = tmp[1]
					local cache = tmp[2]
					if (obj.modifiers[1] == cache) then (
						select obj
						cacheOps.DisableBelow cache
					) else (
						local modIdx = modPanel.GetModifierIndex obj cache
						modPanel.SetCurrentObject obj.modifiers[modIdx]
						if (modPanel.GetCurrentObject() == obj.modifiers[modIdx]) then (
							cacheOps.DisableBelow cache
						)
					)
				)
 
				progressEnd()
 
				if (oldMode != #modify) then SetCommandPanelTaskMode mode:oldMode
 
				return true
			) else (
				messageBox "Please Select A Valid Output Path For Cache Files" title:"Point Cache"
			)
		)
 
		label DLGbakeSpaceLabel "Bake Space:" align:#left
		radiobuttons DLGbakeSpace labels:#("Object","World") columns:1 align:#left offset:[10,0]
		checkbox DLGdoCollapse "Collapse Stack" checked:false align:#left
		button DLGbrowsePath "Browse" align:#right height:18
		label DLGoutputPathLabel "Output Path:" align:#left offset:[0,-20]
		edittext DLGoutputPath ""
 
		on DLGbakeSpace changed state do
		(
			bakeSpace = state
			UpdateUI()
		)
 
		on DLGdoCollapse changed state do (
			doCollapse = state
			UpdateUI()
		)
 
		on DLGbrowsePath pressed do
		(
			local str = GetSavePath caption:"Pick Output Directory"
			outputPath = if (str == undefined) then "" else str
			UpdateUI()
		)
 
		on DLGoutputPath entered str do (
			if (str[str.count] != "\\") do str += "\\"
			outputPath = GetFilenamePath str
			UpdateUI()
		)
 
		on DLGpointCacheRollout open do (
			bakeSpace = 1
			doCollapse = false
			outputPath = ""
 
			UpdateUI()
		)
	)
--------------------------------------------------------------------------------------------------
 
	rolloutNameList = #(
		"Mesh Animation",
		"Object Transform",
		"Shape Animation",
		"Point Cache")
--		"FFD Spacewarp Animation")
 
	rolloutList = #(
		DLGmeshRollout,
		DLGobjTransRollout,
		DLGshapeRollout,
		DLGpointCacheRollout,
		DLGffdRollout )
 
	rolloutSizeList = #(
		138,
		172,
		50,
		148,
		46 )
 
	rollout DLGaboutRollout "About" (
		label DLGAbout01 ""
		label DLGAbout02 ""
		label DLGAbout03 ""
 
		on DLGaboutRollout open do (
			DLGabout01.text = thisTool.toolName
			DLGabout02.text = thisTool.author
			DLGabout03.text =	(thisTool.modifyDate.x as integer) as string + "." +
								(thisTool.modifyDate.y as integer) as string + "." +
								(thisTool.modifyDate.z as integer) as string
		)
 
		on DLGaboutRollout close do ( thisTool.closeTool() )
	)
 
	rollout DLGbakeUtilRollout "Bake Utilities" (
		button DLGmakeMorph "Make Morph From Selection" width:170 enabled:false
		button DLGcollapseToPointCache "Collapse To PointCache" width:170
		group "Remove ClothReyes From:" (
			button DLGremoveClothSel "All Objects" width:170
			button DLGremoveClothAll "Selected Objects" width:170 offset:[-1,0]
		)
 
		on DLGmakeMorph pressed do (
			MakeMorphFromObjs selection
		)
		on DLGcollapseToPointCache pressed do (
			local objs = selection as array
			for obj in objs do try (CollapsePointCache obj) catch ()
		)
		on DLGremoveClothAll pressed do ( killCloth objects )
		on DLGremoveClothSel pressed do ( killCloth selection )
	)
 
	rollout DLGbakeRollout "Bake" (
		fn updateUI = (
			DLGbakeRollout.DLGstartTime.value = startTime
			DLGbakeRollout.DLGendTime.value = endTime
			DLGbakeRollout.DLGnthFrame.value = nthFrame
			DLGbakeRollout.DLGdelOrig.checked = delOrig
			DLGbakeRollout.DLGaddSuffix.checked = addSuffix
			DLGbakeRollout.DLGselBaked.checked = selBaked
			DLGbakeRollout.DLGInOORType.selection = InOORType
			DLGbakeRollout.DLGOutOORType.selection = OutOORType
 
			DLGbakeRollout.DLGdelOrig.enabled =
				DLGbakeRollout.DLGaddSuffix.enabled =
				DLGbakeRollout.DLGselBaked.enabled = (bakeType != 4)
		)
 
		group "Time Sampling" (
			spinner DLGstartTime "Start" range:[-105214,105214,startTime] type:#integer fieldWidth:50 across:2
			spinner DLGendTime "End" range:[-105214,105214,endTime] type:#integer fieldWidth:50
			spinner DLGnthFrame "Every Nth Frame" range:[1,999999,nthFrame] type:#integer fieldWidth:50 offset:[-1,0]
		)
		group "Options" (
			label DLGbakeTypeLabel "Bake:" offset:[-69,2]
			dropdownlist DLGbakeType "" width:133 offset:[34,-22]
			checkbox DLGdelOrig "Delete Original" checked:delOrig
			checkbox DLGaddSuffix "Add Suffix" checked:addSuffix
			checkbox DLGselBaked "Select Baked Objects" checked:selBaked
		)
		group "Out Of Range" (
			label DLGInOORTypeLabel "In:" align:#left offset:[0,4]
			dropdownlist DLGInOORType items:OORTypes width:100 offset:[25,-22]
			bitmap DLGInOORTypeImage bitmap:OORTypeBitmaps[1] width:28 height:20 offset:[65,-26]
			label DLGOutOORTypeLabel "Out:" align:#left offset:[0,4]
			dropdownlist DLGOutOORType items:OORTypes width:100 offset:[25,-22]
			bitmap DLGOutOORTypeImage bitmap:OORTypeBitmaps[1] width:28 height:20 offset:[65,-26]
		)
--		group "External Bake Options" (
--			checkbox DLGbakeXRef "Bake To External File" checked:bakeXRef enabled:false
--			checkbox DLGbakeSeparateFiles "Separate File For Each Object" checked:bakeSeparateFiles enabled:bakeXRef
--			label DLGbakeXRefPathLabel "Base Path:" align:#left
--			checkbox DLGuseScenePath "Use Current Scene Path" checked:useScenePath enabled:bakeXRef
--			edittext DLGbakeXRefPath "Path" text:bakeXRefPath enabled:(bakeXRef AND NOT useScenePath)
--		)
		button DLGbake "BAKE" width:80 height:30
 
		on DLGstartTime changed val do (
			startTime = val
			if startTime >= endTime then ( endTime = startTime )
			DLGendTime.value = endTime
		)
		on DLGendTime changed val do (
			endTime = val
			if endTime <= startTime then ( startTime = endTime )
			DLGstartTime.value = startTime
		)
		on DLGnthFrame changed val do ( nthFrame = val )
 
		on DLGbakeType selected idx do (
			if idx != bakeType do (
				local f = thisTool.getFloater()
				if f != undefined then (
					local oldSize = rolloutSizeList[bakeType]
					local newSize = rolloutSizeList[idx]
					f.size.y += ( newSize - oldSize )
				)
				bakeType = idx
				thisTool.delRoll (thisTool.numRolls())
				thisTool.addRoll rolloutList[bakeType]
			)
			UpdateUI()
		)
		on DLGdelOrig changed state do ( delOrig = state; updateUI() )
		on DLGaddSuffix changed state do ( addSuffix = state; updateUI() )
		on DLGselBaked changed state do ( selBaked = state; updateUI() )
 
		on DLGInOORType selected idx do (
			DLGInOORTypeImage.bitmap = OORTypeBitmaps[idx]
			InOORType = idx
			updateUI()
		)
		on DLGOutOORType selected idx do (
			DLGOutOORTypeImage.bitmap = OORTypeBitmaps[idx]
			OutOORType = idx
			updateUI()
		)
 
		on DLGbakeXRef changed state do (
			bakeXRef =
				DLGbakeSeparateFiles.enabled =
				DLGuseScenePath.enabled = state
			DLGbakeXRefPath.enabled = bakeXRef AND NOT useScenePath
		)
		on DLGbakeSeparateFiles changed state do ( bakeSeparateFiles = state )
		on DLGuseScenePath changed state do (
			useScenePath = state
			DLGbakeXRefPath.enabled = bakeXRef AND NOT useScenePath
			DLGbakeXRefPath.text = if useScenePath then "" else maxFilePath
		)
		on DLGbakeXRefPath entered text do (
			--check for validity
		)
 
		on DLGbake pressed do (
			if selection.count != 0 then (
				local comMode = getCommandPanelTaskMode()
				if comMode == #modify then setCommandPanelTaskMode mode:#create
 
				local origSelection = selection as array
				local sourceObjs = selection as array
				local bakedObjs = #()
 
				try ( rolloutList[bakeType].bake sourceObjs bakedObjs ) catch (format "fail")
 
				if delOrig then undo on ( delete sourceObjs )
				if selBaked then (
					select bakedObjs
				) else (
					clearSelection()
					for obj in origSelection do if NOT isDeleted obj then selectMore obj
				)
 
				setCommandPanelTaskMode mode:comMode
			)
		)
 
		on DLGbakeRollout open do (
			DLGbakeType.items = rolloutNameList
			DLGbakeType.selection = bakeType
			UpdateUI()
		)
--		on DLGbakeRollout close do (
--			if bakeType != 1 then (
--				DLGbakeType.selected 1
--			)
--		)
	)
 
	thisTool.addRoll #(DLGaboutRollout, DLGbakeUtilRollout, DLGbakeRollout, rolloutList[bakeType]) rolledUp:#(true, true, false)
	thisTool.openTool thisTool
)
)