-- mbFracture v0.1a for 3ds Max 9 - (c) Martin Breidt, 11.11.06
-- Macroscript that breaks the selected object into many volumetric pieces
--
-- Works best on closed, watertight meshes without selfintersections --> NO TEAPOTS!
-- No Undo possible!

(
	fn isEnabledFn = selection.count==1 and (canConvertTo selection[1] Editable_mesh)
	
	on isEnabled do isEnabledFn()

	fn explodeElements obj n = (
		if (classOf obj)!=Editable_mesh or obj.numfaces < 1 then (
			format "explodeElements: illegal mesh object\n"
			return undefined
		)
		
		local allFaces = #{1..obj.numFaces}
		local myFace = 1
		local myElementList = #()
		local myNewObjects = #()
		
		-- find all elements
		do (
			local myEl = meshOp.getElementsUsingFace obj #{1}
			if not myEl.isEmpty then (
				-- detach element
				local newMesh = meshOp.detachFaces obj myEl delete:true asMesh:true
				update obj 				--update the main mesh
				local emesh = Editable_mesh()	--create an empty Editable_mesh
				emesh.transform = obj.transform		-- more to original postion
				emesh.mesh = newMesh	--assign the detached faces to the new mesh
				update emesh			--update the new mesh
				centerPivot emesh
				emesh.name = (uniqueName ("frag_"+n+"_"))
				emesh.wirecolor = random (color 0 0 0) (color 255 255 255)
				append myNewObjects emesh
				
				newMesh = undefined		-- free menory
			)
		) while obj.numFaces > 1
		delete obj
		myNewObjects -- return list of exploded objects
	)

	fn randomizeCutter obj offset = (
		v = normalize (random [-1,-1,-1] [1,1,1])	-- random vector
		d = random 0.0 180.0						-- random angle
		in coordsys local obj.rotation = quat d v	-- randomized orientation
		
		in coordsys local move obj [0, 0, (random -offset offset)]
	)

	fn fragIt tObj planeSegs noiseScale noiseStrength gapWidth cutCount doGroup = (
		-- centerPivot tObj

		local o_dim = tObj.max - tObj.min				-- bounding box of cut object
--		local sLen = 1.2 * (amax o_dim.x o_dim.y o_dim.z)		-- length of cut object
		local sLen = length o_dim		-- length of cut object
		-- create cut object
		-- create a single reference object that will be copied later
		try(
			suspendEditing()
			with redraw off (
	
				local myShape = plane length:(1.2*sLen) width:(1.2*sLen) lengthsegs:planeSegs widthsegs:planeSegs pos:tObj.pos
				-- add Noise modifier
				local noiseMod = NoiseModifier scale:noiseScale strength:[0,0,noiseStrength]
				addModifier myShape noiseMod
				-- add Shell modifier
				if gapWidth > 0 then (
					local shellMod = Shell outerAmount:gapWidth
					addModifier myShape shellMod
				)
				randomizeCutter myShape (sLen/3.0)				-- randomize transformation
				local xShapes = #(myShape)
				for i = 2 to cutCount do (
					local n = copy xShapes[xShapes.count]		-- make copy of previous shape
					n.modifiers[#Noise].seed += 1				-- randomized noise
					n.pos = tObj.pos
				
					randomizeCutter n (sLen/3.0)				-- randomize transformation
					append xShapes n
				)
			) -- end: with redraw off
			resumeEditing()
		) catch (
			format "Try/catch error: %\n" (getCurrentException())
			resumeEditing()
		)
		resumeEditing() -- just in case...
		
		-- now create cutter object
		stockOutsideCutter = true
		stockInsideCutter = (gapWidth == 0)
		cutterOutsideStock = false
		autoExtractMesh = false
		explodeByElements = false
		try (
			ProCutter.createCutter xShapes 4 \
				stockOutsideCutter stockInsideCutter cutterOutsideStock \
				autoExtractMesh explodeByElements
				
			-- now CUT IT!
			local objname = tObj.name
			ProCutter.addStocks myShape tObj 4 2
			-- explode the elements
			ResetXForm myShape
			convertToMesh myShape
			no = explodeElements myShape objname
			if no!=undefined then (
				select no
				if doGroup then select (group no prefix:"fragmentGroup")
			)
		) catch (
			messageBox "Sorry, an error occurred during fragmentation; your results are most likely corrupt\nThis can be caused by an invalid object (try the Verify button) or by a ProCutter error." title:"mbFracture error" beep:true
			format "mbFracture error: %\n" (getCurrentException())
		)
	) -- end: fn fragIt


	rollout helpRO "Help" width:365 height:372
	(
		GroupBox grp1 "Parameters (and default values)" pos:[5,27] width:355 height:306
		button closeBtn "Close" pos:[116,340] width:136 height:24
		label lbl2 "mbFracture v0.1a by Martin Breidt" pos:[106,8] width:156 height:16 enabled:true
		label lbl3 "Number of cuts:" pos:[31,49] width:88 height:16
		label lbl4 "Gap Width:" pos:[31,75] width:88 height:16
		label lbl6 "Noise Scale:" pos:[31,101] width:88 height:16
		label lbl7 "Noise Strength:" pos:[31,127] width:88 height:16
		label lbl8 "Segments:" pos:[31,153] width:88 height:16
		label lbl9 "Group segments:" pos:[31,179] width:88 height:16
		label lbl11 "How often the object will be cut (5)" pos:[129,49] width:216 height:16
		label lbl12 "Amount of space between fragments (0.0)" pos:[129,75] width:216 height:16
		label lbl13 "Crack noise wavelength (2.0)" pos:[129,101] width:216 height:16
		label lbl14 "Amplitude of crack noise (15.0)" pos:[129,127] width:216 height:16
		label lbl15 "Resolution of crack polygons (5)" pos:[129,153] width:216 height:16
		label lbl16 "Group all fragments together after fragmentation (off)" pos:[129,179] width:216 height:29
		label lbl17 "Hold before fragmentation:" pos:[32,214] width:88 height:29
		label lbl18 "Perform a Hold operation before fragmentation; advisable for complex objects since there is no Undo! (off)" pos:[130,214] width:216 height:42
		label lbl31 "Fragment copy of object:" pos:[32,262] width:88 height:30
		label lbl32 "Create a copy of the selected object and fragment that" pos:[130,262] width:216 height:30
		label lbl87 "Verify Object" pos:[32,298] width:88 height:30
		label lbl88 "Check the selected object for geometric problems that can cause fragmentation errors" pos:[130,298] width:216 height:30
		on closeBtn pressed do
			destroyDialog helpRO
	)	
	
	rollout fragRO "mbFracture"
	(
		label l0 "v0.1a - © 2006 M. Breidt" pos:[26,7] width:111 height:13
		HyperLink h1 "martin@breidt.net" pos:[40,25] width:83 height:15 address:"mailto:martin@breidt.net"
		button helpBtn "  Help  " pos:[56,45] width:50 height:21 tooltip:"Show help on fragmentation parameters"
		spinner countSpn "Number of cuts: " pos:[9,71] width:140 height:16 range:[1,50,6] type:#integer fieldwidth:50
		spinner gapSpn "Gap Width: " pos:[30,92] width:119 height:16 range:[0,1000,0.0] type:#worldunits fieldwidth:50
		spinner scaleSpn "Noise Scale: " pos:[24,113] width:125 height:16 range:[0.01,100000,15.0] type:#float fieldwidth:50
		spinner strSpn "Noise Strength: " pos:[11,134] width:138 height:16 range:[0,10000,25] type:#worldunits fieldwidth:50
		spinner segSpn "Segments: " pos:[34,155] width:115 height:16 range:[1,500,16] type:#integer fieldwidth:50
		checkbox grpCheck "Group segments" pos:[13,176] width:101 height:15 checked:false
		checkbox holdCheck "Hold before fragmentation" pos:[13,196] width:146 height:15 checked:false
		checkbox copyCheck "Fragment copy of object" pos:[13,216] width:138 height:15 checked:true
		
		button checkBtn "Verify Object" pos:[41,236] width:81 height:21 tooltip:"Check the selected object for problems. Can be very slow on heavy objects!"
			
		button fragBtn "Fragment object" pos:[8,261] width:144 height:21 tooltip:"Break the selected object into pieces"
		button cancelBtn "Cancel" pos:[8,287] width:70 height:21 tooltip:"Close dialog without changes"
		button closeBtn "Close" pos:[82,287] width:70 height:21 tooltip:"Close dialog and save settings"

		fn saveINI = (
			-- save default values to .ini file
			ini_file = "$plugcfg\\mbFracture.ini"
			setINISetting ini_file "Defaults" "count" (countSpn.value as string)
			setINISetting ini_file "Defaults" "gap" (gapSpn.value as string)
			setINISetting ini_file "Defaults" "scale" (scaleSpn.value as string)
			setINISetting ini_file "Defaults" "strength" (strSpn.value  as string)
			setINISetting ini_file "Defaults" "segments" (segSpn.value  as string)
			setINISetting ini_file "Defaults" "group" (grpCheck.checked as string)
			setINISetting ini_file "Defaults" "hold" (holdCheck.checked as string)
			setINISetting ini_file "Defaults" "copy" (copyCheck.checked as string)
		)		
		
		on checkBtn pressed do (
			if isEnabledFn() then (
				local obj = selection[1]

				local res = true
				if obj.mesh.numFaces > 30000 then (
					res = (queryBox "This operation will be very slow for the selected object!\nContinue anyway?" title:"mbFracture warning" beep:true)
				)
				if res then (
					setWaitCursor()
					try (
						-- switch to Modify tab
						setCommandPanelTaskMode mode:#modify
						-- add Mesh Select modifier to clear face selection
						selmod = Mesh_Select()
						addModifier obj selmod
						setFaceSelection obj selMod #{}		-- clear face selection
						
						stlmod = STL_Check Selection_Type:4 Select_Faces:1 Check_Now:1
						addModifier obj stlmod
						local newFSel = obj.selectedFaces.count
						local numF = obj.numFaces
						
						deleteModifier obj 1
						deleteModifier obj 1
					) catch format "mbFracture error: %\n" (getCurrentException())
					
					setArrowCursor()
					if newFSel==0 then (
						if numF > 0 then
							messageBox "No errors found in object" title:"mbFracture" beep:false
						else
							messageBox "Object has no faces1" title:"mbFracture warning" beep:true
					) else (
						messageBox ("The selected object has " + (newFSel as string) + " faces with open edges, double faces, spikes or multiple edges!\nFragmentation might produce unexpected results, use with care!") title:"mbFracture warning" beep:true
					)
				) -- end: if res
			) else messageBox "Please select one geometric object" title:"mbFracture error" beep:true			
		)
		
		on fragBtn pressed do (
			if isEnabledFn() then (
				if holdCheck.checked then holdMaxFile()
				local obj = selection[1]
				if copyCheck.checked then obj = copy obj
				fragIt obj segSpn.value scaleSpn.value strSpn.value gapSpn.value countSpn.value grpCheck.checked
			) else messageBox "Please select one geometric object" title:"mbFracture error" beep:true
		)

		on closeBtn pressed do (
			destroyDialog fragRO
			saveINI()
		)
		on cancelBtn pressed do destroyDialog fragRO
		
		on helpBtn pressed do (
			createDialog helpRO 368 372
		)
		
		on fragRO open do (
			ini_file = "$plugcfg\\mbFracture.ini"
			if (doesFileExist ini_file) then (
				-- read default values from .ini file
				local t = getINISetting ini_file "Defaults" "count"
				if t.count>0 then countSpn.value = (t as integer)
				
				t = getINISetting ini_file "Defaults" "gap"
				if t.count>0 then gapSpn.value = (t as float)
				
				t = getINISetting ini_file "Defaults" "scale"
				if t.count>0 then scaleSpn.value = (t as float)
				
				t = getINISetting ini_file "Defaults" "strength"
				if t.count>0 then strSpn.value = (t as float)
				
				t = getINISetting ini_file "Defaults" "segments"
				if t.count>0 then segSpn.value = (t as integer)
				
				t = getINISetting ini_file "Defaults" "group"
				if t.count>0 then grpCheck.checked = (t =="true")
				
				t = getINISetting ini_file "Defaults" "hold"
				if t.count>0 then holdCheck.checked = (t =="true")
				
				t = getINISetting ini_file "Defaults" "copy"
				if t.count>0 then copyCheck.checked = (t =="true")
			) -- end: if
		) -- end: on fragRO open
	) -- end: rollout fragRO
	
	on execute do (
		if (maxversion())[1]>=9000 then createDialog fragRO 160 315 else messageBox "This script requires 3ds Max 9 or greater" title:"mbFracture error" beep:true
	) -- end: on execute
) -- end: macroscript
