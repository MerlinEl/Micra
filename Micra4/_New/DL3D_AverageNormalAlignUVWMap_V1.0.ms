-------------------------------------------
-- AlignUVWMapGizmoOnAverageNormal V 1.0 --
-------------------------------------------

-- Maxscript for 3D Studio Max 5+
-- Made by David Lanier, 3D Tools Freelance Developer
-- DL3D - Boost your 3D productivity !
-- Please visit www.dl3d.com for more info.

-- This script is free and can be used / modified / distributed freely 
-- but at your own risks.

-- What is this script used for ?
-- This script has 2 goals :
-- 1) It is a tutorial for people learning Maxscript
-- 2) It also help artists save time when setting UVs on meshes or patches.

-- How to use it ?
-- One object and only one should be selected, then select somes faces on this object. 
-- And click on the button on the script UI and it will add a UVWMap modifier to the selected faces of your object 
-- and it will align the gizmo on the average normal of the selected faces.

-- To make you save time to understand whitout too much headache what I am doing in this script , you need to know the following :
-- We get the selected faces array from the selected node.
-- We compute the average normal of the selected faces.
-- From this average normal, we build a pure rotation matrix (no translation and no scale, just a rotation).
-- Then we add a UVWmap modifier to the selected node.
-- Finally this rotation matrix is set into the gizmo transform of the UVWMap.
-- And the magick comes to life, well, of course, if no bug has appeared from here. :-)
-- The heart of this script is the "AddUVWMapAnddoTheStuff" function, at this end of it.

-- We have choosen on purpose not to do the fit operation after the gizmo has been aligned because
-- it will complicates the script with Bounding boxes calculation. It will be done in another 
-- version of this script.

--Our globals
global g_point3_avgnormal 	= [0,0,0]		-- The point2 that is the average of selected faces normals
global g_debugging			= false			-- Are we in debug mode ? Set true if you want to print out messages in the listener
global g_matrix3_avgnormal	= matrix3 1		-- Rotation matrix for orienting the UVWMap gizmo
global g_rlf									-- Rollout floater window


--Function to print values when debugging
-- it only prints out values to the listener if g_debugging is true.
fn debugprint text value =
(
	if g_debugging then 
	(
		print text
		print value
	)
)

--I use my own matrixfromnormal function as the 
--Maxscript or SDK "matrixfromnormal" function never gives the resutls I'm expecting.
-- So, we build a matrix3 that contains a pure rotation from the orientation or the vector called normal
fn DL3DMatrixFromNormal normal = 
(
	-- Get an orthogonal vector to "normal"
	local Point3_orthoToNormal = point3 -normal.y normal.x 0

	-- Deal with degenerate case
	if ( Point3_orthoToNormal.x == 0.0 and Point3_orthoToNormal.y == 0.0 ) then
		Point3_orthoToNormal.x = 1.0;

	--Reset matrix (the identity <matrix3> function doens't seem to wor).
    g_matrix3_avgnormal.row1 = point3 1 0 0
    g_matrix3_avgnormal.row2 = point3 0 1 0
    g_matrix3_avgnormal.row3 = point3 0 0 1
    g_matrix3_avgnormal.row4 = point3 0 0 0

	--Compute orthogonal vector to orthonormalize matrix (= make a rotation 3x3 matrix).
	local point3_orthovec = cross normal Point3_orthoToNormal

	--Build the matrix with these 3 orthogonal and normalized vectors
	g_matrix3_avgnormal.row1 = Point3_orthoToNormal
	g_matrix3_avgnormal.row2 = point3_orthovec
	g_matrix3_avgnormal.row3 = normal
)

-- Add a UVWMap modifier to the selected object taking care of the selected faces
-- and set the matrix3 passed as a parameter as the transform of the gizmo
-- This should orientate the gizmo in the direction of the average normal from sel. faces
fn AddUVWMapModtoSelectionAndSetMatrix3AsGizmoTransform node gizmotransform =
(
	--Create UVWMap modifier
	local MyUVWmap = Uvwmap ()
	
	--Add UVWMap mod to the selected object (taking care of face selection)
	modPanel.addModToSelection (MyUVWmap) ui:on

	-- Set our transform into gizmo
	prerotateZ gizmotransform 180 --This line is added to orientate gizmo with Y up.
	MyUVWmap.gizmo = gizmotransform
)


-- Computes the average of normals from selected faces.
-- Result is set into the global variable "g_point3_avgnormal"
fn computeaverageofnormals mesh =
(	
	-- Get mesh face selection
	local array_selfaces = mesh.selectedFaces
	local numselfaces 	 = array_selfaces.count --Num faces selected
	debugprint "Numselfaces" numselfaces
	
	--Reset average of normals
	g_point3_avgnormal.x = g_point3_avgnormal.y	= g_point3_avgnormal.z 	= 0.0
	debugprint "g_point3_avgnormal" g_point3_avgnormal
	
	--Get all selected faces one at a time
	for array_face in array_selfaces do
	(
		local int_faceidx	= array_face.index
		
		--Add this normal to our global "g_point3_avgnormal"
		g_point3_avgnormal 	+= getfacenormal mesh int_faceidx
		debugprint "g_point3_avgnormal"g_point3_avgnormal
	)
	
	--Divide by the total number of faces to get the average
	g_point3_avgnormal 	/= numselfaces
	debugprint "g_point3_avgnormal" g_point3_avgnormal
)

-- This function checks if everything is ok to run the script on the selected node (if any).
-- It returns true if it's possible, false if not.
fn checkifeverythingisoktorunscriptonthisnode node =
(
	--Check if we can add a UVWmap mod to selection
	if (not validmodifier node Uvwmap ) then
	(
		messagebox("It seems I can't add an UVWMap modifier to the selected object, please double check that.")
		return false
	)
	
	--Check if we are in face, polygon or element selection mode
	if (subObjectLevel != 3 and subObjectLevel != 4 and subObjectLevel != 5) then
	(
		MessageBox("You should be in face, polygon, patch or element selection level !")
		return false
	)

	-- Get mesh from node, pretty easy compared to the SDK equivalent :-)
	local selmesh = node.mesh
	if (selmesh == undefined) then
	(
		MessageBox("Can't get mesh from your selected object !")
		return false
	)

	--check if some faces are selected on the node
	local array_selfaces = selmesh.selectedFaces
	local numselfaces 	 = array_selfaces.count --Num faces selected
	debugprint "Numselfaces" numselfaces

	if (numselfaces == 0) then
	(
		messagebox("Please select some faces on the object !") --Hey are you doing it on purpose to make it crash ? :-)
		return false
	)
	
	return true
)

-- This function is the heart of this script
fn AddUVWMapAnddoTheStuff node =
(
	-- get mesh from node
	local selmesh = node.mesh
	
	--Set the global variable "g_point3_avgnormal" with the average normal of selected faces
	computeaverageofnormals selmesh
	
	--Now build matrix3 from normal to have an orientation
	DL3DMatrixFromNormal g_point3_avgnormal
	debugprint "g_matrix3_avgnormal" g_matrix3_avgnormal
	
	--Add the UVWMap modifier and set the gizmo transform inside
	AddUVWMapModtoSelectionAndSetMatrix3AsGizmoTransform node g_matrix3_avgnormal
)

-- Here we build the Rollout from the UI
rollout unnamedRollout "AlignUVWMapGizmoOnAverageNormal V 1.0" width:245 height:146
(
	--Set UI buttons
	button btnRun "Run" width:193 height:20 toolTip:"Add UVWMap modifier to the selected object and align its gizmo on average normal of selected faces."
	button btnHlp "Help" pos:[58,43] width:87 height:20 toolTip:"Press this button to display the script help." across:2
	button btnAbt "About" pos:[164,43] width:87 height:20 toolTip:"Press this button to display the about box of this script."
	label lab1 "DL3D - Please visit www.dl3d.com for more information" width:258 height:13

	--Set the callback when "Run" button is pressed
	on btnRun pressed do
	(
		try
		(
			-- Get selected nodes
			local curselnodes	= getCurrentSelection()
			--How much are they ?
			local numselnodes 	= curselnodes.count
			if (numselnodes != 1) then
			(
				MessageBox("Please, select one and only one object !")
				return false
			)
			else
			(
				--ok, only one node selected
				local selnode = curselnodes[1]
				
				--Can we run safely the script on this node ?
				local bool_result = checkifeverythingisoktorunscriptonthisnode selnode
				if (bool_result)then
				(
					--It looks like, but we can't be sure at 100 percent... That's why try/catch instructions are useful.
					AddUVWMapAnddoTheStuff selnode
				)
			)
		)
		catch
		(
			MessageBox("An exception has occured !")
		)
	)
	
	--Set the callback when "Help" button is pressed
	on btnHlp pressed do
	(
		messagebox(" How to use it ?\n\nOne object and only one should be selected, then select somes faces on this object.\n\nNow click on the \"Run\" button on the script UI and it will add a UVWMap modifier to the selected faces of your object\nand it will align the gizmo on the average normal of the selected faces.\n\nI hope this helps.\nwww.dl3d.com")
	)
	
	--Set the callback when "About" button is pressed
	on btnAbt pressed do
	(	
		messagebox("Maxscript for 3D Studio Max 5+\nMade by David Lanier, 3D Tools Freelance Developer\n\nBoost your 3D productivity with DL3D !\nhttp://www.dl3d.com\n\nThis script is free and can be used / modified / distributed freely\nbut at your own risks.")
	)
)

--Begginning of the script

-- Go into modify mode
max modify mode --Used to check the subobjectlevel number

-- If the rollout was already created, just close the old rollout 
--This will avoid having several rollout window open at the same time
if (g_rlf != undefined) then closeRolloutFloater g_rlf

-- Create the rollout window
g_rlf  = newrolloutfloater "AlignUVWMapGizmoOnAverageNormal V 1.0" 320 110

--add the rollout control
addrollout unnamedRollout g_rlf
--End of the script