------------------------------------------------------------------------------
-- GLOBALS
------------------------------------------------------------------------------

global gTerrainStitcher = undefined
global gTerrainStitcherUI = undefined

------------------------------------------------------------------------------------------------------------------------------------------------------------
--|	>						 STRUCTURE	for BORDERs SELECTION						  			
------------------------------------------------------------------------------------------------------------------------------------------------------------ 		 			

global gBordersSelection = undefined
struct sBordersSelection (
	
	finalSourceBorder = #(),					-- array of all edges for final sourceBorder
	finalDestinationBorder = #(), 			-- array of all edges for final destinationBorder
	
	sourceBorderOneDirection = #(), 			--after user click on a button again it s going to change to other direction and last value is safed in finalBorder
	sourceBorderSecondDirection = #(),
	
	destinationBorderOneDirection = #(),
	destinationBorderSecondDirection = #(),
	
	sourceObject = 0,
	destinationObject = 0,
	
	
	sourceBorderStatus = "",			-- for  OK if border is fine or error messeges if selection of Verts is wrong
	destinationBorderStatus = "",		-- same as previus
	
------------------------------------------------------------------------------ 				--<<< GetOpenEdgesByVert >>> --	--------------------------------------
	fn getOpenEdgesByVert indexOfVert openEdgesOfObj vertsForOpenEdges  = (			
	-- find two open edges which are using vert with certain index
		local twoEdges= #()
		local count = vertsForOpenEdges.count
			
		for i = 1 to count do(
			for j = 1 to 2 do(			-- only two items in subArray   1 edge => 2 vertex
				if vertsForOpenEdges [i][j] == indexOfVert then(
					append twoEdges openEdgesOfObj[i]  		-- edge by index  both arrays  openEdgesOfObj and vertsForOpenEdges have same number of items and same indexing
				)
			)
		)
		twoEdges
	),
	
-------------------------------------------------------------------------------				-<<< getPath >>> --		------------------------------------------------------ 
	fn getPath obj openEdgesOfObj vertsForOpenEdges currentEdge startVertIndex= (		
	-- fing path in one direction
	-- Result array of edges sorted in one direction

		local sortedEdges = #()
		local verstForEdge = #() 			-- verts for certain edge
		local nextVert = 0 					--next vert on a path
		local openEdgesForNextVert = #() 	-- open edges for certain vert
		local nextEdge = 0							-- next edge on a path

		local start = startVertIndex 				-- starting point for loop
		do
		(
			append sortedEdges currentEdge
			
			verstForEdge = polyOp.getVertsUsingEdge obj currentEdge as array
			if verstForEdge[1] != startVertIndex then (
				nextVert = verstForEdge[1]
			)else(
				nextVert = verstForEdge[2]
			)
			
			openEdgesForNextVert = gBordersSelection.getOpenEdgesByVert nextVert openEdgesOfObj vertsForOpenEdges
			if openEdgesForNextVert[1] != currentEdge then (
				nextEdge = openEdgesForNextVert[1]
			)else(
				nextEdge = openEdgesForNextVert[2]
			)
			
			currentEdge = nextEdge
			startVertIndex = nextVert
			
		)while startVertIndex != start 			-- end of loop in one direction
		
		sortedEdges
	),
	
-------------------------------------------------------------------------------				-<<< getBorderEdgesBetween >>> --		------------------------------------
	fn getBorderEdgesBetween endPos arrForOneDir =(
	-- goes trought array from first position (in array) to end position (in array) and place all edges on a path to new array
		local edgesBetwPos = #()	-- result array for edges on a path between two verts for certain diraction
		
		for i = 1 to endPos do(		-- 1 because path loops for both directions starting from first pos (starting Vert)
			edgesBetwPos[i] = arrForOneDir[i]
		)
		edgesBetwPos
	),
	
-------------------------------------------------------------------------------				-<<< borderChange  >>> --		-------------------------------------------------
	fn borderChange border arrayForFirstDir arrayForSecondDir statusMessege obj =(				
	--border: 1 for sourceBorder, 2 for destinationBorder
		
		if border == 1 then(			-- of source border
			gBordersSelection.sourceBorderOneDirection = arrayForFirstDir
			gBordersSelection.sourceBorderSecondDirection = arrayForSecondDir
			gBordersSelection.sourceBorderStatus = statusMessege
			gBordersSelection.sourceObject = obj
			
		)else(								-- of destination border			
			gBordersSelection.destinationBorderOneDirection = arrayForFirstDir
			gBordersSelection.destinationBorderSecondDirection = arrayForSecondDir
			gBordersSelection.destinationBorderStatus = statusMessege
			gBordersSelection.destinationObject = obj
		)
	),
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------	
-------------------------------------------------------------------------------				-<<< main >>> --		------------------------------------------------------ 
	fn main border =(
		--clearlistener()	
		
		local selectedVerts = #()
		
		local startVertIndex = 0						-- index of starting vertex
		gOpenEdges = #()				-- array for all open edges
		gVertsForOpenEdges = #() 	-- array of verts of open edges
		
		gSortedEdgesByOneDir = #() 	-- array of border edges sorted One diraction
		gSortedEdgesBySecDir = #()	-- array of border edges sorted Second diraction
		
		local startingEdges = #()
		local endindEdges = #()
		
		local startVertPos = 0		
		local endtVertPosFirst = 0			-- ONE direction
		local endtVertPosSecond = 0 		-- SECOND direction
		
		local helpCom1= 0					-- for compering which ending edge is closer to starting point in certain direction
		local helpCom2 = 0 
		
		local borEdgBTwoVerFirstDir = #()		-- all edges between two selected vertexes FIRST DIRECTION
		local borEdgBTwoVerSecondDir #()		-- all edges between two selected vertexes SECOND DIRECTION
		
		---------------------------
		local statusMsg = ""						--rerurn msg for certain border status
		local errorArr = #()							--return value for error
		---------------------------
		free VertsFofOpenEdges
		
		
		
		local obj = selection[1]
		
		if obj != undefined and classof obj == Editable_Poly then(
		--|| Object is not editable poly or user selected nothing ||--
			
			selectedVerts = polyOp.getVertSelection obj as array
			
			if selectedVerts.count == 2 then(
			--|| Check if user selected TWO Vertexes ||--
				
				gOpenEdges = polyOp.getOpenEdges obj as array				-- get all open edges of a object
					
				count_gOpenEdges = gOpenEdges.count							-- count of open edges
				vertsForEdge = polyOp.getVertsUsingEdge						-- method to get vers of certain edge
				
				gVertsForOpenEdges = for i in 1 to count_gOpenEdges collect vertsForEdge obj gOpenEdges[i] as array -- collect verts for open edges
				
				
				----------------------------
				----------------------------
				startVertIndex = selectedVerts[1]			-- starting vertex (starting point for a path)
				endVertIndex = selectedVerts[2]			-- end vertex (end point for a path)
				----------------------------
				----------------------------
				
				startingEdges = gBordersSelection.getOpenEdgesByVert startVertIndex gOpenEdges gVertsForOpenEdges		-- get open edges for certain vertex
				endindEdges = gBordersSelection.getOpenEdgesByVert endVertIndex gOpenEdges gVertsForOpenEdges
						
				if startingEdges.count != 0 and endindEdges.count !=0  then (
				--||  Are Vertexes On The Border (open edge) ?  vertex is not used on any open edge	||--
					
					local FirtsDirEdge = startingEdges[1]
					local secondDirEdge = startingEdges[2]
					-----------------Firts direction--------------------
					gSortedEdgesByOneDir = gBordersSelection.getPath obj gOpenEdges gVertsForOpenEdges FirtsDirEdge startVertIndex		-- edges sorted in one direction
					-----------------Second direction--------------------
					gSortedEdgesBySecDir = gBordersSelection.getPath obj gOpenEdges gVertsForOpenEdges secondDirEdge startVertIndex		-- edges sorted in other direction
					
					
					if findItem gSortedEdgesByOneDir endindEdges[1] != 0 then(
					--||  check if are vertex on the same border	||--	
						
						startVertPos = findItem gSortedEdgesByOneDir FirtsDirEdge			--It's a same for both direction 1st position
						
						helpCom1 = findItem gSortedEdgesByOneDir endindEdges[1]				-- ONE DIRECTION
						helpCom2 = findItem gSortedEdgesByOneDir endindEdges[2]
						if (helpCom1 - startVertPos) < (helpCom2 - startVertPos) then (
							endtVertPosFirst = helpCom1
						)else(
							endtVertPosFirst = helpCom2
						)
						
						helpCom1 = findItem gSortedEdgesBySecDir endindEdges[1]				-- SECOND DIRECTION
						helpCom2 = findItem gSortedEdgesBySecDir endindEdges[2]
						if (helpCom1 - startVertPos) < (helpCom2 - startVertPos) then (
							endtVertPosSecond = helpCom1
						)else(
							endtVertPosSecond = helpCom2
						)
						
						------Final Edge arrays foir Both direction for one border---
						borEdgBTwoVerFirstDir = gBordersSelection.getBorderEdgesBetween endtVertPosFirst gSortedEdgesByOneDir
						borEdgBTwoVerSecondDir = gBordersSelection.getBorderEdgesBetween endtVertPosSecond gSortedEdgesBySecDir						
						---------------------------------------------------
						
						
						----save result to certain Border--------------
						statusMsg = "Border selection is OK"
						
						gBordersSelection.borderChange border borEdgBTwoVerFirstDir borEdgBTwoVerSecondDir statusMsg obj		-- for border's both directions
							
						--------------------------------------------------------------------
					)else(
						statusMsg = "Vertices are not on the same Border."
						gBordersSelection.borderChange border errorArr errorArr statusMsg obj
					)
					
				)else(	
					statusMsg = "Select Both Vertices on the Border."
					gBordersSelection.borderChange border errorArr errorArr statusMsg obj					
				)
			)else(
				statusMsg = "Select TWO Border vertices."
				gBordersSelection.borderChange border errorArr errorArr statusMsg obj	
			)
		)else(
			statusMsg = "Select Editable Poly Object."
			gBordersSelection.borderChange border errorArr errorArr statusMsg obj											
		)		
	)
) -- END of border selection struct
----------------------------------------------------------------------------------------------------------------------------------
if gBordersSelection == undefined then (
	gBordersSelection = sBordersSelection()
	--gFaceAreaChecker.Init()
)
----------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------
--|	>						 STRUCTURE	for STITCHING						  			
------------------------------------------------------------------------------------------------------------------------------------------------------------
global gStitching = undefined
struct sStitching (
		
	fn createSpline obj finalBorder borderName = (
	-- create spline for finalBorder of a object
		local createdSpline = 0 		
		finalBorderBitArr = finalBorder as bitArray
		
		obj.EditablePoly.SetSelection #Edge finalBorderBitArr
		obj.EditablePoly.createShape borderName off obj
		
		createdSpline = execute ("$'"+borderName + "'")
	),
	
	fn getSplineKnots spline = (
	--return array of knots pos (point3) of certain spline	
		local splineKnotsPos = #()	-- array of Point3 - pos of each 
		local numOfKnots = numKnots spline 1
		
		for i = 1 to numOfKnots do(
			splineKnotsPos[i] = getKnotPoint spline 1 i
		)
		splineKnotsPos
	),
	
	fn createFinalSpline sourceSpline destinationSpline =(
	--create one spline from two support splines sourceSpline and destinationSpline
		local knotsForCreation = #()
		
		local knotsSourceSpline = #()				-- Knots positions on Source spline
		local knotsDestinationSpline = #()			-- Knots positions on Destination spline
		local numbKnotSourceSpline = 0
		local numbKnotDestinationSpline = 0
		--local numallKnots = 0
		
		--------------------------------------------------------------------------------- to create new object to same Layer as Source Object
		sourceObjectLayerName = gBordersSelection.sourceObject.layer.name
		layer = LayerManager.getLayerFromName sourceObjectLayerName
		layer.current = True
		--------------------------------------------------------------------------------
		
		knotsSourceSpline = getSplineKnots sourceSpline
		knotsDestinationSpline = getSplineKnots DestinationSpline
		
		numbKnotSourceSpline = knotsSourceSpline.count
		numbKnotDestinationSpline = knotsDestinationSpline.count
		
		for i = 1 to numbKnotDestinationSpline do(								-- create one array with all knots postions, after that we create final spline from this array
			knotsSourceSpline[i+numbKnotSourceSpline] = knotsDestinationSpline[i]
			
		)
		
		numallKnots = numbKnotSourceSpline + numbKnotDestinationSpline
		knotsForCreation = knotsSourceSpline
		
		-----------Delete Support Splines--------------------------------------------------------------
		delete sourceSpline
		delete destinationSpline
		
		-----------Create Final Spline-------------------------------------------------------------------
 	
		local sp = splineShape()
		addnewSpline sp
		for i = 1 to numallKnots do(
			
			addKnot sp 1 #corner #line knotsForCreation[i]
		
		)
		close sp 1
		sp.name = uniquename "-> TerrainStich_FinalBorder <- ID: "
		
		addModifier sp (subdivideSpacewarpModifier ())		-- add SUBDIVIDE modifier on spline
		--sp.modifiers[#Subdivide].size = 1007

		select sp
			
	),
	
	fn main = (
	--crate Final spline according two help splines and Add Subdivide modifier
		local sourceBorderSplineName = "Source_Spline_TerrainSticher"
		local sourceSpline = 0 			-- shape path
	
		local destinationBorderSplineName = "Destination_Spline_TerrainSticher"
		local destinationSpline = 0 	-- shape path
	
		sourceSpline = createSpline gBordersSelection.sourceObject gBordersSelection.finalSourceBorder sourceBorderSplineName
		destinationSpline = createSpline gBordersSelection.destinationObject gBordersSelection.finalDestinationBorder destinationBorderSplineName
	
		createFinalSpline sourceSpline destinationSpline
	)
	
) -- END of Stitiching structure
----------------------------------------------------------------------------------------------------------------------------------
if gStitching == undefined then (
	gStitching = sStitching()
)
----------------------------------------------------------------------------------------------------------------------------------

-- gbordersSelection.main 1

-- clearlistener()
-- format "%\n%\n\n" gBordersSelection.sourceBorderOneDirection gBordersSelection.sourceBorderSecondDirection
-- format "%\n%\n\n" gBordersSelection.destinationBorderOneDirection gBordersSelection.destinationBorderSecondDirection
-- format "%\n%\n\n" gBordersSelection.sourceBorderStatus gBordersSelection.destinationBorderStatus

-- 						polyOp.setEdgeSelection obj borEdgBTwoVerFirstDir
-- 						polyOp.setEdgeSelection obj borEdgBTwoVerSecondDir
-- 						
-- 						subobjectLevel = 2

------------------------------------------------------------------------------------------------------------------------------------------------------------ 
--|	>						 ROLLOUT	DIALOG							  			
------------------------------------------------------------------------------------------------------------------------------------------------------------ 
---------------------------------------
sourceBorderSelected = 0 		--help for rollOut To KNOW which direction is currently selected for source border
destinationBorderSelected = 0	
---------------------------------------
try (destroyDialog dlg_terrain_sticher)catch()
	
rollout dlg_terrain_sticher "Terain Sticher"
(
	-- BORDER I ------------------------------
	groupBox gb_group1 " - Borders Selection" pos:[4,5] width:150 height:180	
	button btn_border_I "Source Border" tooltip:"Select Two Vertexes for Source Border" align:#center width:146 height:30 offset:[-2,-160]
	progressbar pb_border_I_Warning align:#left value: 100 color:[255,88,78] width:146 height:2.5 offset:[-7, -3] enabled: false		-- [66,204, 72] green
	label lb_border_I_info "Select 2 Verticess of      First Object" width:120 height:30 offset:[20, 0]
	
	-- BORDER II ------------------------------
	button btn_border_II "Destination Border" tooltip:"Select Two Vertexes for Destination Border" align:#center width:145 height:30 offset:[-2,2]
	progressbar pb_btn_border_II_Warning align:#left value: 100 color:[255,88,78] width:146 height:2.5 offset:[-7, -3] enabled: false		-- [66,204, 72] green
	label lb_border_II_info "Select 2 Vertices of Second Object" width:120 height:30 offset:[20, 0]
	

	-- STICHING ----------------
	groupBox gb_group2 " - Stiching" width:150 height:120 offset:[-8, 15]
	button btn_stich "STITCH BORDERS" tooltip:"Stich source and destination border\n\nRECALCULATION -> select object created by Stitcher and press this button" align:#center width:130 height:30 offset:[-2,-90] enabled: false
	spinner spn_stich_size "Size:" align:#center range:[2500, 20000, 100] fieldwidth:55 offset:[0, 10] type:#worldunits enabled:false
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	on dlg_terrain_sticher close do
	(
		gTerrainStitcherUI = undefined
	)
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	
	on btn_border_I pressed do (
		
		gbordersSelection.main 1				-- call function for source border
		
		if gBordersSelection.sourceBorderOneDirection.count != 0 then(		-- Vertexes has a correct border between theme
			if sourceBorderSelected != 1 then (
				gBordersSelection.finalSourceBorder = gBordersSelection.sourceBorderOneDirection
				sourceBorderSelected = 1 		-- First Direction selected
			)else(
				gBordersSelection.finalSourceBorder = gBordersSelection.sourceBorderSecondDirection
				sourceBorderSelected = 2			-- Second Direction selected
			)
			
			lb_border_I_info.text = gBordersSelection.sourceBorderStatus
			pb_border_I_Warning.enabled = True
			pb_border_I_Warning.color = color 66 204 72
			
			polyOp.setEdgeSelection $ gBordersSelection.finalSourceBorder
			subobjectLevel = 2
			redrawViews()
			
		)else(																				-- ERROR Vertexes don't have correct border between theme
			lb_border_I_info.text = gBordersSelection.sourceBorderStatus
			pb_border_I_Warning.enabled = True
			pb_border_I_Warning.color = color 255 88 78
		)
		
		format "%\n%\n" gBordersSelection.finalSourceBorder gBordersSelection.sourceObject
		
		if pb_border_I_Warning.color == (color 66 204 72) and pb_btn_border_II_Warning.color == (color 66 204 72) then (
			btn_stich.enabled = True
			spn_stich_size.enabled = True
		)else(
			btn_stich.enabled = false
			spn_stich_size.enabled = false			
		)

	)
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------	
	on btn_border_II pressed do (
		
		gbordersSelection.main 2				-- call function for destination border
		
		if gBordersSelection.destinationBorderOneDirection.count != 0 then(		-- Vertexes has a correct border between theme
			if destinationBorderSelected != 1 then (
				gBordersSelection.finalDestinationBorder = gBordersSelection.destinationBorderOneDirection
				destinationBorderSelected = 1 		-- First Direction selected
			)else(
				gBordersSelection.finalDestinationBorder = gBordersSelection.destinationBorderSecondDirection
				destinationBorderSelected = 2			-- Second Direction selected
			)
			
			lb_border_II_info.text = gBordersSelection.destinationBorderStatus
			pb_btn_border_II_Warning.enabled = True
			pb_btn_border_II_Warning.color = color 66 204 72
			
			polyOp.setEdgeSelection $ gBordersSelection.finalDestinationBorder
			subobjectLevel = 2
			redrawViews()
			
		)else(																				-- ERROR Vertexes don't have correct border between theme
			lb_border_II_info.text = gBordersSelection.destinationBorderStatus
			pb_btn_border_II_Warning.enabled = True
			pb_btn_border_II_Warning.color = color 255 88 78
		)
		
		format "%\n%\n" gBordersSelection.finalDestinationBorder gBordersSelection.destinationObject
		
		if pb_border_I_Warning.color == (color 66 204 72) and pb_btn_border_II_Warning.color == (color 66 204 72) then (
			btn_stich.enabled = True
			spn_stich_size.enabled = True
		)else(
			btn_stich.enabled = false
			spn_stich_size.enabled = false		
		)
	)
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------	
	on btn_stich pressed do (
		
		if gBordersSelection.sourceObject != gBordersSelection.destinationObject then ( -- check if source and destination object are not a same 
			
			if (selection.count != 0) and (findString selection[1].name "-> TerrainStich_FinalBorder <- ID: ")!= undefined then(	-- because of recalculation
				delete selection[1]
			)
			gStitching.main()
			
		)else(
			messageBox "Select Borders of Two Different Objects"
		)
	)
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------		
	on spn_stich_size changed val do (
		
		if (selection.count > 0) and (selection[1].modifiers[#Subdivide] != undefined) then(
			selection[1].modifiers[#Subdivide].size = val
		)
	) 
			
) -- END of Rollout
--createDialog dlg_terrain_sticher 160 320


---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------	
--																STRUCT TERRAIN STITCHER TOOL
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------	
struct sTerrainStitcher
(
	fn openDialog =
	(
		if gTerrainStitcherUI == undefined then
		(
			gTerrainStitcherUI = createDialog dlg_terrain_sticher modal:false
		)
		else
			destroyDialog dlg_terrain_sticher
	),
  
  fn init =
  (
  )
)
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------	
--																INIT
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------	
if (gTerrainStitcher == undefined) do
(
	gTerrainStitcher = sTerrainStitcher()
	gTerrainStitcher.init()
)
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------	
--																MACROSCRIPT
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------	
-- macroScript TerrainStitcher
-- category:"LS3D Engine" 
-- tooltip:"Terrain Stitcher" 
-- Icon:#("Patches",1)
-- (	
	gTerrainStitcher.openDialog()
-- )