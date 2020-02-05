
global gFaceAreaChecker = undefined
struct sFaceAreaChecker
(
	testedTexelDensity = 256,
	allowedDifference = 10,
	FaceAreaMode = 1,
	faceAreaDialog = undefined,
	InteractiveUpdates = true,
	iniFileName = (getDir #plugcfg + "\\FaceAreaXViewChecker.ini"),     -- ini file store last know location of the configuration dialog in an ini file
	resultColors = #(blue, blue + red, green, blue + green * 0.35, orange + red * 0.4),
	
	-----------------------Using mainly by rollouts
	infoDensity = 0,
	matCheckMode = 1,					-- 1 for check faces of all materials,   OR ID of material to check 
	usedMaterials = #(),				-- use for material dropdownmenu     -- need to fix to work for more than one object or unable material selection if user pick more than on object
	wholeObjectSelected = false,   	-- false - Custom face selection,      True - if whole object selected 
	faceResultToTransfer = #(),
	
	currentFaceSelection = #(),
	
	---------------------------------- For Xview to show more colors
	multiColor = #(#(), #(), #()),
	
	---------------------------------
	firstRun = True,
		
	
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---|												<:--			TEXEL DENSITY FUNCTIONS	 --:>													|----
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		
	fn facesSelection obj = (
	-- get face selection of selected object
		
		--------------------------------------PRE-CHeck because of rollout               				--hack 1.0
		
		if subobjectLevel != 4 or gFaceAreaChecker.firstRun == True then (
			numbFaces = polyOp.getNumFaces obj
			
			if (polyop.getfaceselection obj as array).count == numbFaces then (
				gFaceAreaChecker.wholeObjectSelected = True
			)else(
				gFaceAreaChecker.wholeObjectSelected = false	
			)
		---------------------------------------
			
			-- if user has no selection on object -> select all faces (check whole object)
			local arrFaces = #()
			
			if (polyop.getfaceselection obj as array).count != 0 then (
				
				arrFaces = polyOp.getFaceSelection obj as array
			) else (
				polyOp.setFaceSelection obj #all
				arrFaces = polyOp.getFaceSelection obj as array
			)
			gFaceAreaChecker.currentFaceSelection = arrFaces
		) else (
			arrFaces = gFaceAreaChecker.currentFaceSelection
			
		)
		gFaceAreaChecker.firstRun = false
		return arrFaces
	),
	--------------------------------------------------------------------------------------------------	
	
	fn getTextureSize obj = (
		--create array of sizes of all textrues used on object
		local texSizeLib = #()
		local mat = #()	--materials of object, can be multimaterial or standart
			
		------------------------
		free gFaceAreaChecker.usedMaterials												-- hack 2.0
		gFaceAreaChecker.usedMaterials[1] = "--ALL--"
		local matString = ""
		------------------------
		
		if classof obj.material == Standardmaterial or classof obj.material == LS3DMaterial or classof obj.material == DirectX_9_Shader then (
			mat[1] = obj.material
		)else (
			mat = obj.material
		)
			
		for i = 1 to mat.count do (
		------------------------
			matString = " " + i as string + " - " + mat[i] as string
			append gFaceAreaChecker.usedMaterials matString
		-------------------------
			
			matDiff = case classof mat[i] of 			-- check because of diffusemap     support: Standart, LS3D, DX
			(
				Standardmaterial: mat[i].diffuseMap
				LS3DMaterial: mat[i].diffuseMap
				DirectX_9_Shader: mat[i].renderMaterial.diffuseMap
			)
			
			
			if mat[i] != undefined and matDiff != undefined then (                   -- find material with diffuseMap 
			
				oneMap = openBitMap matDiff.filename   -- open bitmap in diffuse
				texSizeLib[i] = (oneMap.width * oneMap.height)
			)else(
				texSizeLib[i] = undefined
			)
		)
		
		return texSizeLib
	),
	--------------------------------------------------------------------------------------------------	
	
	fn getUvFaceSize arrWithPosOfUvPoints = (
	--from coordinates of uv points calculate size of UV face
	--http://www.mathopenref.com/coordpolygonarea.html
		
		local uVFaceArea = 0
		local vertArr = append arrWithPosOfUvPoints arrWithPosOfUvPoints[1] -- need to add firts item as last for calculation

		for i = 1 to (vertArr.count - 1) do (
			uVFaceArea = uVFaceArea + ((vertArr[i].x * vertArr[i + 1].y) - (vertArr[i].y * vertArr[i + 1].x))
			
		)
		
		uVFaceArea /= 2
		return abs(uVFaceArea) -- final size of UV face 
	),
	--------------------------------------------------------------------------------------------------
	
	fn densityForSelection obj objectFaces textureSizes = (
		
		
		local returnResult = #() --containig two arrays below
		local pixelDensity = #() -- problem with indexing of x view, array needs to have same indexing like object faces
		local avgDensity = #() -- for rollout to be able to show average density for selection
		
		local sizeOfSelection = 0
		local sizeOfUvSelection = 0
		local pixelDensityForSelection = 0
		local sizeOfUvFace = 0
		
		----------------------------												IF want to check faces of just certain material   0 -> check ALL material or ID of material
		local matCheck = gFaceAreaChecker.matCheckMode - 1	--default we cannot set matCheckMode = 0 beacuse of indexing of dropdown menu
		
		local numOfCheckFaces = 0						-- used for average density
		---------------------------
			
		for i = 1 to objectFaces.count do (
			
			--wrong result for standart material
			-- standrat -> textureSizes.coun = 1  -> faceMatID = 1
			---------------
			if textureSizes.count != 1 then (
				faceMatID = polyOp.getFaceMatID obj objectFaces[i]
			)
			else 
			(
				faceMatID = 1
			)
			
			
			if ((matCheck == 0) or (faceMatID == matCheck)) then ( -- check because of material 
				--preperation 
				sizeOfRealFace = polyop.getFaceArea obj objectFaces[i]
				faceUvVertsIndexes = polyOp.getMapFace obj 1 objectFaces[i]			--Returns the vertex indices of the specified map face as an array.
				faceUvVertsPosition = for j in 1 to faceUvVertsIndexes.count collect polyOp.getMapVert obj 1 faceUvVertsIndexes[j]		--Create array of point3s containing position of Verts of Face in UV
				
				sizeOfUvFace = getUvFaceSize faceUvVertsPosition
				
				--density
				if textureSizes[faceMatID] == undefined then(	
				-- face doesnt have material with texture			
					pixelsForFace = 0
				)
				else
				(
					pixelsForFace = sizeOfUvFace * textureSizes[faceMatID]
				)
				--------------	
				pixelsForOneUnit = pixelsForFace / sizeOfRealFace  --for one cm^2
				pixelForSquarMeter = pixelsForOneUnit * (10000) -- for one m^2
				pixelDensityforFace = sqrt(pixelForSquarMeter)  -- PIXEL density for face
				
				
				
				--counter for all faces and uvFaces
				pixelDensityForSelection += pixelDensityforFace
				pixelDensity[objectFaces[i]] = pixelDensityforFace
				
				numOfCheckFaces += 1
			)
		)
		
		-----------------------------				NO faces for certain material in current selection
		if numOfCheckFaces == 0 then (
			
			local error = #(#(0), #(0))
			messageBox "NO FACE For This material in current selection."
			return error
			
		)
		-----------------------------
		avgDensity[1] = pixelDensityForSelection /= numOfCheckFaces
					
		append returnResult pixelDensity
		append returnResult avgDensity
		
		return returnResult
	),
	
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--|													<:---			X-VIEW FUNCTIONS		  ---:>														 	 |---
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--http://docs.autodesk.com/3DSMAX/15/ENU/MAXScript-Help/index.html?url=files/GUID-C94469C6-19A5-427E-A16B-D46054B3AA1A.htm,topicNumber=d30e118083
	
	fn geomCheck theTime theNode theResults = (
		-- default xview function  ->  fill theResults array with indexes of faces for viewport color change
		-- limitions: theResults only works with one color for more color in the same time, you need multidimension array (but it has problem if you select more than one object)
		free theResults
		gFaceAreaChecker.multiColor = #(#(), #(), #())
		
		local theCount = gFaceAreaChecker.facesSelection theNode			-- number of selected faces of object
		local texSizes = gFaceAreaChecker.getTextureSize theNode  			-- check material (LS3D/DX/multimaterial) sizes of all diffuse textures diffuse
		local densityPlusAvg = gFaceAreaChecker.densityForSelection theNode theCount texSizes    --array of faces with pixel density - Multidiminsion array  - RETURNING TWO ARRAYS!!!
		
		local allowedMin = (gFaceAreaChecker.testedTexelDensity - ((gFaceAreaChecker.allowedDifference as float/100) * gFaceAreaChecker.testedTexelDensity)) as float 
		local allowedMax = (gFaceAreaChecker.testedTexelDensity + ((gFaceAreaChecker.allowedDifference as  float/100) * gFaceAreaChecker.testedTexelDensity)) as float
		
		local PixelDensity = densityPlusAvg[1] as array  -- pixel density of all faces (first array)
		gFaceAreaChecker.infoDensity = densityPlusAvg[2][1] as float--avg pixel density for selection  (second array)
		
		for f = 1 to PixelDensity.count do (
			case gFaceAreaChecker.FaceAreaMode of (	 -- rollout dropdown menu 
				default: ( -- need to use custom multidimension array, because we want to show more colors in a same time 
					if  ((PixelDensity[f] != undefined ) and ((PixelDensity[f] >= allowedMin) and (PixelDensity[f] <= allowedMax))) then append gFaceAreaChecker.multiColor[1] f
					if  ((PixelDensity[f] != undefined ) and (PixelDensity[f] < allowedMin)) then append gFaceAreaChecker.multiColor[2] f	
					if  ((PixelDensity[f] != undefined ) and (PixelDensity[f] > allowedMax)) then append gFaceAreaChecker.multiColor[3] f
				)
				
				
				2: if  ((PixelDensity[f] != undefined )and((PixelDensity[f] < allowedMin) or (PixelDensity[f] > allowedMax))) then append theResults f    	-- out of interval
				3: if  ((PixelDensity[f] != undefined ) and ((PixelDensity[f] >= allowedMin) and (PixelDensity[f] <= allowedMax))) then append theResults f		 	-- in interval
				4: if  ((PixelDensity[f] != undefined ) and (PixelDensity[f] < allowedMin)) then append theResults f																-- less than interval
				5: if  ((PixelDensity[f] != undefined ) and (PixelDensity[f] > allowedMax)) then append theResults f															-- higher than interval
				
			)
		)
		
		--------------------
		gFaceAreaChecker.faceResultToTransfer = theResults 	--store result of xviecheck (id of faces)
		--------------------
		
		if gFaceAreaChecker.faceAreaDialog != undefined then (
			gFaceAreaChecker.rollUpdate()
		)
		3
	),
	
	----------------------------------------------------------------------------------------------------------------------------------
	fn supportedCheck theNode = (
	--default xview functions to check a object before calculation    wrong object -> show unssuported object type
		((classof theNode == Editable_Poly) and (polyOp.getNumFaces theNode != 0) and theNode.material != undefined) --objects with no faces
	),		
	
	
	----------------------------------------------------------------------------------------------------------------------------------
	fn rollUpdate = (
	-- for update rollout after selection change	
		gFaceAreaChecker.faceAreaDialog.btn_selectResults.enabled = True
		gFaceAreaChecker.faceAreaDialog.btn_allFaces.enabled = True
		gFaceAreaChecker.faceAreaDialog.btn_transferResult.enabled = True
		
		gFaceAreaChecker.faceAreaDialog.ddl_materialCheckMode.items = gFaceAreaChecker.usedMaterials
		gFaceAreaChecker.faceAreaDialog.labNumDens.text = ""
		gFaceAreaChecker.faceAreaDialog.labNumDens.text += gFaceAreaChecker.infoDensity As String
		
		if gFaceAreaChecker.FaceAreaMode == 1 then (
			gFaceAreaChecker.faceAreaDialog.btn_transferResult.enabled = false
		)
		
		if selection.count > 1 then  (
			gFaceAreaChecker.faceAreaDialog.btn_selectResults.enabled = false
			
			gFaceAreaChecker.faceAreaDialog.labSel.text = "- MULTIPLE SELECTION -"
			gFaceAreaChecker.faceAreaDialog.warning_bar_1.enabled = True
			gFaceAreaChecker.faceAreaDialog.warning_bar_2.enabled = True
			gFaceAreaChecker.faceAreaDialog.labNumDens.text = "*"
			gFaceAreaChecker.faceAreaDialog.btn_transferResult.enabled = false
		)
		
		if (gFaceAreaChecker.wholeObjectSelected == True) and (selection.count == 1) then (
			gFaceAreaChecker.faceAreaDialog.labSel.text = "- ALL FACES SELECTED -"
			gFaceAreaChecker.faceAreaDialog.warning_bar_1.enabled = false
			gFaceAreaChecker.faceAreaDialog.warning_bar_2.enabled = True
		)
		
		if (gFaceAreaChecker.wholeObjectSelected == false) and (selection.count == 1) then (
			gFaceAreaChecker.faceAreaDialog.labSel.text = "- CUSTOM FACE SELECTION -"
			gFaceAreaChecker.faceAreaDialog.warning_bar_1.enabled = True
			gFaceAreaChecker.faceAreaDialog.warning_bar_2.enabled = false
		)
		
	),
	
	----------------------------------------------------------------------------------------------------------------------------------
	fn rollReset = (			-- if selection change click, not at objact but to empty space, callback from rollout
		
		gFaceAreaChecker.faceAreaDialog.btn_selectResults.enabled = false
		gFaceAreaChecker.faceAreaDialog.btn_allFaces.enabled = false
		gFaceAreaChecker.faceAreaDialog.btn_transferResult.enabled  = false
		
		if selection.count == 0 then (
			free gFaceAreaChecker.usedMaterials
			gFaceAreaChecker.faceAreaDialog.ddl_materialCheckMode.items = gFaceAreaChecker.usedMaterials
			gFaceAreaChecker.faceAreaDialog.labNumDens.text = ""
			gFaceAreaChecker.faceAreaDialog.warning_bar_1.enabled = false
			gFaceAreaChecker.faceAreaDialog.warning_bar_2.enabled = false
			gFaceAreaChecker.faceAreaDialog.labSel.text = ""
			gFaceAreaChecker.faceAreaDialog.btn_transferResult.enabled = false
		) else (
			gFaceAreaChecker.matCheckMode = 1
			gFaceAreaChecker.faceAreaDialog.ddl_materialCheckMode.items = gFaceAreaChecker.usedMaterials
		)
	),
			
	
	----------------------------------------------------------------------------------------------------------------------------------
	fn configDlg = (
	-- default xview function to create rollout after click on  "Click Here To Configure"

		try (destroyDialog gFaceAreaChecker.faceAreaDialog) catch()
		
		----------------------------------------------------------------------------------------------------------------------------------
		rollout faceAreaDialog "Texel Density"
		(	
			-----------------------------------Density
			groupBox group1 "Tested Density" pos:[4,5] width:150 height:70
			spinner spn_TestedDensity "Pixel Density(m):" tooltip:"Pixel density per METER" align:#Right range:[0, 10000, gFaceAreaChecker.testedTexelDensity] fieldwidth:35 offset:[-10, -55] type:#integer
			spinner spn_AllowedDiffr "Difference(%):" align:#Right range:[0, 100, gFaceAreaChecker.allowedDifference] fieldwidth:36 offset:[-10, 0] type:#integer
				
			-----------------------------------Result
			groupBox group2 "Show Faces:" pos:[4,80] width:150 height:100
			dropdownlist ddl_FaceAreaMode width:150 align:#left offset:[-9,-88] items:#("--OVERALL--", "WRONG tested density", "CORRECT tested density.","BELOW tested density","ABOVE tested density") selection:gFaceAreaChecker.FaceAreaMode across:2

			--------------------------------info LEGEND
			progressbar warning_color_help_1 align:#left value: 100 color:green width:20 height:10 offset:[-48, -60] enabled: true
			label labMaterial_colHelp_1 "CORRECT" align:#left offset:[50, -17]
				
			progressbar warning_color_help_2 align:#left value: 100 color:(blue+green*0.35) width:20 height:10 offset:[20, 1] enabled: true
			label labMaterial_colHelp_2 "BELOW" align:#left offset:[50, -15]
				
			progressbar warning_color_help_3 align:#left value: 100 color:(orange) width:20 height:10 offset:[20, 1] enabled: true
			label labMaterial_colHelp_3 "ABOVE" align:#left offset:[50, -15]

			----------------------------------Material
			groupBox group3 "Select Material to check:" pos:[4,190] width:150 height:50
			dropdownlist ddl_materialCheckMode tooltip:"Pick material to check" width:150 align:#left offset:[-9,-35] items:#("--ALL--") height:8 selection:gFaceAreaChecker.matCheckMode 

			-----------------------------------Selection
			label labSel "" style_sunkenedge: false height:17 align:#center offset:[0, 15]
			progressbar warning_bar_1 align:#left value: 100 color:[255,225,82] width:70 height:6 offset:[-7, 5] enabled: false
			progressbar warning_bar_2 align:#right value: 100 color:[84,165,255] width:70 height:6 offset:[0, -11] enabled: false
			button btn_selectResults "Custom" tooltip:"CHECK CUSTOM FACE SELECTION\nEditable poly -> pick faces -> press this button" align:#left width:70 height:40 offset:[-7,-5]
			button btn_allFaces "All Faces" tooltip:"CHECK THE WHOLE OBJECT" align:#right width:70 height:40 offset:[0,-45]

			-----------------------------------Average Pixel density
			label labInfoDens "Pixel Density Selection (Avg.)" align:#center offset:[0, 10]
			label labNumDens "" align:#center offset:[0, 2]
			
			-----------------------------------Transfer to Selection	
			button btn_transferResult "Result to Selection" tooltip:"Transfer currently result to face selection\n-Not for   --OVERALL--" align:#center width:140 height:30 offset:[0,15]
			
			-----------------------------------Continuos Update	
			checkbox chk_InteractiveUpdates "Continuous Update" checked:gFaceAreaChecker.InteractiveUpdates offset:[0, 25] across:2
			
			-----------------------------------Help	
			hyperLink help "- Help -" color:[84,165,255] hoverColor: [255,202,82] visitedColor:[25,25,25] address: "http://nov-home/display/~petr.capek/Texel+Density+tool+for+3Ds+Max" offset:[30,60]
			
			----------------------------------------------------------------------------------------------------------------------------------
			fn updateDisplay = (
				if gFaceAreaChecker.InteractiveUpdates == true then
				(
					XViewChecker.runCheck CurrentTime
					redrawViews()
				)
			)	
					
			----------------------------------------------------------------------------------------------------------------------------------
			on faceAreaDialog open do (
				callbacks.addScript #selectionSetChanged "gFaceAreaChecker.rollReset()" id:#Rollout_Update
				if selection.count != 0 and (gFaceAreaChecker.supportedCheck $ != false) then (
					gFaceAreaChecker.rollUpdate()
				)else(
					gFaceAreaChecker.rollReset()
				)
			)
			
			----------------------------------------------------------------------------------------------------------------------------------
			on faceAreaDialog close do(
				callbacks.removeScripts id:#Rollout_Update
			)
			
			----------------------------------------------------------------------------------------------------------------------------------
			on ddl_FaceAreaMode selected itm do (			
			-- faceArea mode when dropdown list selection changed					
			  gFaceAreaChecker.FaceAreaMode = itm
			  updateDisplay()
			)
			
			
			----------------------------------------------------------------------------------------------------------------------------------
			on ddl_materialCheckMode selected itm do (
			-- matCheckMode mode when dropdown list selection changed					
			  gFaceAreaChecker.matCheckMode = itm
			  updateDisplay()
			)
			
			----------------------------------------------------------------------------------------------------------------------------------
			on chk_InteractiveUpdates changed state do (
			--If the interactive mode was changed, we store the current state in the struct instance's property and update the display. 
			  gFaceAreaChecker.InteractiveUpdates = state
			  updateDisplay()
			)
			
			----------------------------------------------------------------------------------------------------------------------------------
			on spn_TestedDensity changed val do (
				gFaceAreaChecker.testedTexelDensity = val
				updateDisplay()
			) 
			
			----------------------------------------------------------------------------------------------------------------------------------
			on spn_AllowedDiffr changed val do (
				gFaceAreaChecker.allowedDifference = val
				updateDisplay()
			)

			----------------------------------------------------------------------------------------------------------------------------------
			on btn_selectResults pressed do (
				--XViewChecker.selectResults CurrentTime
				--max views redraw
				subobjectLevel = 0
				updateDisplay()
			) 
			
			----------------------------------------------------------------------------------------------------------------------------------
			on btn_allFaces pressed do (
													
				for obj in selection do (
					polyOp.setFaceSelection obj #all	
				)
				subobjectLevel = 0
				updateDisplay()
				
				if (warning_bar_1.enabled == True) and (warning_bar_2.enabled == True) then (
					warning_bar_1.enabled = false
				)
			) 
			
			----------------------------------------------------------------------------------------------------------------------------------
			on btn_transferResult pressed do (
				if selection.count != 0 then (
					polyOp.setFaceSelection $ gFaceAreaChecker.faceResultToTransfer
					subobjectLevel = 4
				)
				--updateDisplay()
			) 

			----------------------------------------------------------------------------------------------------------------------------------
			on faceAreaDialog moved pos do setIniSetting gFaceAreaChecker.iniFileName "Dialog" "Position" (pos as string)
			--If the user modes the configuration dialog, we store the new position in the INI file.
			
		) -- end of rollout
		
		local thePos = execute (getIniSetting gFaceAreaChecker.iniFileName "Dialog" "Position")
		if classof thePos != Point2 then thePos = mouse.screenpos
		createDialog faceAreaDialog 162 510 thePos.x thePos.y 
		gFaceAreaChecker.faceAreaDialog = faceAreaDialog
	),
	
	fn textOverride =
	-- default xview funciton for override green text on bottom of a screen
	(
	  case gFaceAreaChecker.FaceAreaMode of
	  (
		1: " --  OK: "+ gFaceAreaChecker.multiColor[1].count as string + "   BELOW: " + gFaceAreaChecker.multiColor[2].count as string + "   ABOVE: " + gFaceAreaChecker.multiColor[3].count as string + "  --"
		2: "--  OUT OF: "+ gFaceAreaChecker.faceResultToTransfer.count as string + "  --"
		3: "--  OK: "+ gFaceAreaChecker.faceResultToTransfer.count as string + "  --"
		4: "--  BELOW: "+ gFaceAreaChecker.faceResultToTransfer.count as string + "  --"
		5: "--  ABOVE: "+ gFaceAreaChecker.faceResultToTransfer.count as string + "  --"
	  )
	),
	
	fn dispOverride theTime theNode theHwnd theResults =
	-- default xview function for showing color in a viewport
	(
		local theColor = gFaceAreaChecker.resultColors[gFaceAreaChecker.FaceAreaMode]
		XViewChecker.displayResults theColor theTime theNode theHwnd 3 theResults--(for o in theResults collect o+1)
		
		if (gFaceAreaChecker.FaceAreaMode == 1) and (selection.count == 1) then ( 			-- can't displey MORE COLORS for multiple selection 
			
			XViewChecker.displayResults gFaceAreaChecker.resultColors[3] theTime theNode theHwnd 3 gFaceAreaChecker.multiColor[1]
			XViewChecker.displayResults gFaceAreaChecker.resultColors[4] theTime theNode theHwnd 3 gFaceAreaChecker.multiColor[2]
			XViewChecker.displayResults gFaceAreaChecker.resultColors[5] theTime theNode theHwnd 3 gFaceAreaChecker.multiColor[3]
		)
		
		if (gFaceAreaChecker.FaceAreaMode == 1) and (selection.count > 1) then ( 			-- can't displey MORE COLORS for multiple selection 
			
			XViewChecker.displayResults gray theTime theNode theHwnd 3 gFaceAreaChecker.multiColor[1]
			XViewChecker.displayResults gray theTime theNode theHwnd 3 gFaceAreaChecker.multiColor[2]
			XViewChecker.displayResults gray theTime theNode theHwnd 3 gFaceAreaChecker.multiColor[3]
		)	
	),
	
	fn Init =
	(
		XViewChecker.unRegisterChecker "Texel Density Checker"
		XViewChecker.registerChecker gFaceAreaChecker.geomCheck gFaceAreaChecker.supportedCheck #Faces "Texel Density Checker" gFaceAreaChecker.configDlg gFaceAreaChecker.textOverride gFaceAreaChecker.dispOverride
		
		try 
		(
			local menu = menuMan.findMenu "Views - General Viewport Label Menu"
			local xViewMenu = undefined
			for i = 1 to menu.numItems() do (
				local item = menu.getItem i
				if item.getTitle() == "xView" then xViewMenu = item.getSubMenu()
			)
			
			for i = 1 to xViewMenu.numItems() - 1 do (
				local xViewItem = xViewMenu.getItem i
				if xViewItem.getTitle() == "TexelDensity checker (Editable Poly))" then xViewMenu.removeItem xViewItem
			)

			local newItem = menuMan.createActionItem "TexelDensityChecker_EditPoly" "LS3D Engine"
			if newItem == undefined then throw "TexelDensityChecker_EditPoly macro not available"
			xViewMenu.addItem newItem 2
		) catch (			
			print( "Error in gFaceAreaChecker.Init(): " + GetCurrentException())
		)		
		
	)
	
)	-- end of struct


----------------------------------------------------------------------------
--MACRO SCRIPTS
----------------------------------------------------------------------------

macroScript TexelDensityChecker_EditPoly 
category:"LS3D Engine" 
tooltip:"TexelDensity checker (Editable Poly))" 
Icon:#("Patches", 1)
(	
	on isChecked return		
		xViewChecker.getCheckerName xViewChecker.activeIndex == "Texel Density Checker" and xViewChecker.on == true

	on execute do
	(
		if (xViewChecker.getCheckerName xViewChecker.activeIndex == "Texel Density Checker" and xViewChecker.on == true) then
			xViewChecker.on = false
		else
		( 
			local theIndex = 0
			for i = 1 to xViewChecker.getNumCheckers() do
				if xViewChecker.getCheckerName i == "Texel Density Checker" then theIndex = i
			if theIndex > 0 do  
			(
				xViewChecker.setActiveCheckerID(xViewChecker.getCheckerID theIndex)
				xViewChecker.on = true
			)
		)		
		
	)

)

if gFaceAreaChecker == undefined then (
	gFaceAreaChecker = sFaceAreaChecker()
	gFaceAreaChecker.Init()
)

