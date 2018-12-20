-- -----------------------------------------------------------------------
-- MAXScript r7_select_by_size
-- "r7_select_by_size.ms"
-- -----------------------------------------------------------------------
-- AUTHOR:			Markus Boos
-- COMPANY:			project|gemini
-- CONTACT:			relief7@projectgemini.net
-- COPYRIGHT:		2007-2010. Markus Boos. All Rights Reserved
-- CREATION DATE:	2008-05-02 (YYYY-MM-DD)
-- MAX Version:		9-2009
-- -----------------------------------------------------------------------
-- $LastChangedDate: 2008-11-02 11:07:13 -0500 (Sun, 02 Nov 2008) $
-- $Author: relief7 $
-- $Revision: 89 $
-- -----------------------------------------------------------------------

/*
--------------------------------------------------------------------------
INSTRUCTIONS
--------------------------------------------------------------------------
This script allows you to select objects by their size, by checking
their
	- bounding box size (= bounding box volume) or
	- volume of the mesh (calculation function taken from MAXScript manual)

Run the script via Menu -> MAXScript -> Run Script.

--------------------------------------------------------------------------
VERSION HISTORY
--------------------------------------------------------------------------
Version 0.01		2008-05-02 - Markus Boos - relief7@projectgemini.net
					- initial script created
--------------------------------------------------------------------------
BUGS / KNOWN ISSUES
--------------------------------------------------------------------------
-

--------------------------------------------------------------------------
TODO ITEMS / WISHLIST
--------------------------------------------------------------------------
-
	
*/


(
	-- -------------------------------------------------------------------
	-- CONFIGURATION 
	-- -------------------------------------------------------------------
	
	-- -------------------------------------------------------------------
	-- SETUP 
	-- -------------------------------------------------------------------
	
	clearListener ()	

	-- global rollout floater variable
	global rofTool

	-- program strings
	strVersion = "0.01"
	strDate = "May 02, 2008"
	strToolName = "r7_select_by_size"

	-- ---------------------------------------------------
	-- GLOBAL VARIABLES
	-- ---------------------------------------------------
	
	local fDelta = 0.1
	
	-- ---------------------------------------------------
	-- CUSTOM ATTRIBUTE DEFINITIONS
	-- ---------------------------------------------------

	-- ---------------------------------------------------
	-- FUNCTION DEFINITIONS
	-- ---------------------------------------------------
	
	
	function getVolBBox obj =
	(
		local vMin = obj.min
		local vMax = obj.max
	
		local fX = vMax.x - vMin.x
		local fY = vMax.y - vMin.y
		local fZ = vMax.z - vMin.z
	
		( fX * fY * fZ )
	)
	
	
	-- function was taken from Bobo's tip on how to calculate an object's volume
	-- in the maxscript reference
	function getVolAndCOM obj = 
	( 
		Volume= 0.0 
		Center= [0.0, 0.0, 0.0] 
		
		theMesh = snapshotasmesh obj
		numFaces = theMesh.numfaces 
		
		for i = 1 to numFaces do 
		( 	
			Face= getFace theMesh i 			
			vert2 = getVert theMesh Face.z 		
			vert1 = getVert theMesh Face.y 		
			vert0 = getVert theMesh Face.x 		
			dV = Dot (Cross (vert1 - vert0) (vert2 - vert0)) vert0		
			Volume+= dV 		
			Center+= (vert0 + vert1 + vert2) * dV 	
		) 
		
		delete theMesh
		Volume /= 6 
		Center /= 24 
		Center /= Volume 
		
		#(Volume,Center) 
	)	

	function selectBySize fSize iCompare iMethod bClearSelection bUseExistingSelection =
	(
		-- fSize: value against which to compare volume
		
		-- iCompare: method of comparison
		--		0: =
		--		1: <	(smaller than given size)
		--		2: >	(bigger than given size)
				
		-- iMethod: set size detection method here
		--		0: measure volume of object's mesh
		--		1: measure volume of object's bounding box
		
		-- bClearSelection:
		-- 		false:	add to existing selection
		--		true:	create new selection
			
		try 
		(
			undo "MS:select by size" on
			(				
				local arrObjects = objects
				
				if ( bUseExistingSelection == true ) then
				(
					arrObjects = selection as array
				)
				
				if ( bClearSelection == true ) then
				(
					clearSelection ()
				)
								
				for obj in arrObjects do
				(
					-- calculate volume
					local fVol = 0.0
					
					if ( iMethod == 1 ) then
					(
						fVol = ( getVolAndCOM obj ) [1]
					)
					else if ( iMethod == 2 ) then
					(
						fVol = getVolBBox obj
					)
				
					-- determine if it needs to be selected
	
					-- equal to given value
					if ( iCompare == 1 ) and ( abs ( fVol - fSize ) < fDelta ) then
					(
						selectMore obj
						format "%: % = %\n" obj.name fSize fVol
					)
				
					-- smaller than given value
					if ( iCompare == 2 ) and ( fVol < fSize ) then
					(
						selectMore obj
						format "%: % < %\n" obj.name fVol fSize
					)
	
					-- bigger than given value
					if ( iCompare == 3 ) and ( fVol > fSize ) then
					(
						selectMore obj
						format "%: % > %\n" obj.name fVol fSize
					)	


				)
			)
		) 
		catch 
		(
			format "Error selecting objects by volume.\n"
		) 
	)

	-- ---------------------------------------------------
	-- TOOL DEFINITIONS
	-- ---------------------------------------------------

	Rollout roTool "Select By Size"
	(
		-- ---------------------------------------------------
		-- ROLLOUT Globals
		-- ---------------------------------------------------
		
		-- ---------------------------------------------------
		-- ROLLOUT DEFINITION
		-- ---------------------------------------------------
		GroupBox grpVisibility "Configuration" pos:[4,8] width:280 height:114
		
		radiobuttons rbMethod "Method" labels:#( "Bounding Box", "Mesh Volume" ) default:2 columns:1 pos: [13, 28]
		radiobuttons rbCompare "Comparison" labels:#( "=", "<", ">" ) default:3 columns:1 pos: [123, 28]
		
		label lblSize "Size" pos: [216, 28]
		spinner spSize "" range:[0,10000000,1] scale:1 type:#float fieldwidth:70 pos: [196, 58]
		
		checkbox cbUseExistingSelection "Use selected objects only" checked: false pos: [13, 100]
		
		button btnSelect "Select" pos: [10, 130] width: 100 tooltip: "select objects that match size specified in the configuration"
		button btnSelectMore "Select More" pos: [180, 130] width: 100 tooltip: "select objects that match size specified in the configuration"


		-- ---------------------------------------------------
		-- EVENT HANDLER(S)
		-- ---------------------------------------------------
		on btnSelect pressed do
		(			
			selectBySize spSize.value rbCompare.state rbMethod.state true cbUseExistingSelection.checked
		)
		
		on btnSelectMore pressed do
		(			
			selectBySize spSize.value rbCompare.state rbMethod.state false false
		)
		
		on cbUseExistingSelection changed iState do
		(
			btnSelectMore.enabled = not iState
		)
	)
	
	-- ---------------------------------------------------
	-- ROLLOUT FLOATER
	-- ---------------------------------------------------

	-- try closing the dialog if it already exists
	try ( closeRolloutFloater rofTool ) catch ( )

	rofTool = newRolloutFloater ( strToolName + " " + strVersion )  300 190
	
	addRollout roTool rofTool
	
)
