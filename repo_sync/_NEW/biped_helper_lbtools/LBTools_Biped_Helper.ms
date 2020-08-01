/**************************************************************************************************************************
// This script was authored by Lorne Brooks, Email: lbtools2k@gmail.com
//
//
// REVISION HISTORY:
// Version 2.4 10/05/20:
//						- Added a new baking option for keying a Biped head in order to track an active Look At Target if assigned.
// Version 2.3 28/06/17:
//						- Fixed a bug where paste posture would crash due to missing posture in the collection. It now filters the selection for
//						    biped only parts during the copy posture phase, so that the collection is created properly for pasting.
//						- UI now remembers it's last location, even after Max restart.
// Version 2.2 23/11/16:
//						- Added the ability to copy and paste (with optional opposite) a posture based on a selection of biped parts. The copied
//						  posture is saved as a file for later retrieval. You can also quickly select the copied biped parts if available.
// Version 2.1 19/11/16:
//						- Added a new rollout called Quick Posture, with options to mirror limbs, and straighten or untwist spine links.
// Version 2.0 06/02/16:
//						- Added a new button "Key Selected Biped Parts". Adds keys to all selected biped parts at the current slider time.
// Version 1.9 08/11/15:
//						- Bake Animation Keys now refreshes the UI in the case of the root being a <deleted scene node>.
//						- Trajectories Toggle now force switches to the motion panel before toggling the trajectories mode.
//						- Baking up to next and last modes now allows any part of a limb to be selected, not just the hands or feet.
//						- Added options to enable a single pose to be grabbed then applied without using the Biped collections panel. It saves the pose to a file for storage.
//						- Delete Frame Keys can now remove keys on all Biped parts at the current slider time, by holding Shift or Control when clicking the button.
//						- Added a select Both Hands & Feet button to the Selection/Display/Keys rollout.
//						- Updated PDF guide.
// Version 1.8 06/11/15;
//						- Fixed global variable usage which caused the functions key all and delete all keys to not work (finally).
//						- Changed interface references of IK to be Body/Object space instead, to more accurately reflect their purpose.
//						- Added a Delete Frame Keys button, which deletes all keys on selected Biped parts based on the slider time.
//						- Added new button images, tooltips and rearranged some UI elements.
//						- Improved code for baking animation keys.
//						- Added a PDF guide and button link to the UI (in the About rollout).
//						- The previous dialog version of this tool is no longer supported. "Compact" reference removed.
// Version 1.7 01/07/15;
//						- Converted the dialog interface into a more compact floater with collaspable rollouts.
//						- Added functionality to enable user specified snapshots scene layer.
// Version 1.6 17/12/14;
//						- Fixed global variable usage which caused the functions key all and delete all keys to not work.
// Version 1.5 09/12/14;
//						- While using the Shift or Control method for setting TCB linear or smooth values across the time range, if the
//							Escape key is pressed the operation will now stop.
// Version 1.4 27/10/14;
//						- Email change for help contact.
// Version 1.3 13/10/14;
//						- When selecting from the dropdown list of multiple Bipeds, you can now hold Shift to also select the Biped root
//							or hold Control to select the whole rig.
// Version 1.2 22/09/14;
//						- Fixed the snapshot functionality. Do longer selects anything which means it works for frozen objects in Max 2015.
//							Also, now handles multiple skin meshes in the Mesh Character layer. Only Skin meshes are snapshot.
// Version 1.1 17/09/14;
//						- Added a dropdown list to enable selection of a Biped for the panel to operate on in the case of multiple Bipeds.
// Version 1.0 15/09/14;
//						- First public release.
//
//
// This script is not copyrighted, please feel free to modify or distribute.
//
**************************************************************************************************************************/

global g_LBTools_BH
global g_LBTools_rootPath = getFilenamePath (getSourceFileName()) --get path of this script
struct s_LBTools_bipedHelper
(

/*==================================================================================
// Structure variables
====================================================================================*/

UIheight = 740,
BH_pos,
bhINIfile = g_LBTools_rootPath + "\LBTools_BipedHelper.ini",
f_openBipedUI,
bipedUI_Floater,
Baking_Rollout,
SelectDisplayKeys_Rollout,
QuickPosture_Rollout,
PoseGrabber_Rollout,
LimbSpaces_Rollout,
Reference_Rollout,
About_Rollout,
a_storedSpaces = #(),
a_bips = #(),
bRoot, bPelvis, bSpine, bHead,
bClavicleL, bUpperarmL, bForearmL, bHandL,
bClavicleR, bUpperarmR, bForearmR, bHandR,
bThighL, bCalfL, bFootL,
bThighR, bCalfR, bFootR,
a_armLeft, a_armRight, a_legLeft, a_legRight,
a_bipedHandsFeet = #(),
a_bipedLimbs = #(),
a_bipedAllParts = #(),
imageFile1 = g_LBTools_rootPath + "\BipedHelper_Image1.bmp",
imageFile2 = g_LBTools_rootPath + "\BipedHelper_Image2.bmp",
imageFile3 = g_LBTools_rootPath + "\BipedHelper_Image3.bmp",
imageFile4 = g_LBTools_rootPath + "\BipedHelper_Image4.bmp",
imageFile5 = g_LBTools_rootPath + "\BipedHelper_Image5.bmp",
imageFile6 = g_LBTools_rootPath + "\BipedHelper_Image6.bmp",
imageFile7 = g_LBTools_rootPath + "\BipedHelper_Image7.bmp",
imageFile8 = g_LBTools_rootPath + "\BipedHelper_Image8.bmp",
imageFile9 = g_LBTools_rootPath + "\BipedHelper_Image9.bmp",
imageFile10 = g_LBTools_rootPath + "\BipedHelper_Image10.bmp",
imageFile11 = g_LBTools_rootPath + "\BipedHelper_Image11.bmp",
imageFile12 = g_LBTools_rootPath + "\BipedHelper_Image12.bmp",
imageFile13 = g_LBTools_rootPath + "\BipedHelper_Image13.bmp",
imageFile14 = g_LBTools_rootPath + "\BipedHelper_Image14.bmp",
imageFile15 = g_LBTools_rootPath + "\BipedHelper_Image15.bmp",
imageFile16 = g_LBTools_rootPath + "\BipedHelper_Image16.bmp",
imageFile17 = g_LBTools_rootPath + "\BipedHelper_Image17.bmp",
imageFile18 = g_LBTools_rootPath + "\BipedHelper_Image18.bmp",
imageFile19 = g_LBTools_rootPath + "\BipedHelper_Image19.bmp",
imageFile20 = g_LBTools_rootPath + "\BipedHelper_Image20.bmp",
imageFile21 = g_LBTools_rootPath + "\BipedHelper_Image21.bmp",
imageFile22 = g_LBTools_rootPath + "\BipedHelper_Image22.bmp",
imageFile23 = g_LBTools_rootPath + "\BipedHelper_Image23.bmp",
imageFile24 = g_LBTools_rootPath + "\BipedHelper_Image24.bmp",
imageFile25 = g_LBTools_rootPath + "\BipedHelper_Image25.bmp",
imageFile26 = g_LBTools_rootPath + "\BipedHelper_Image26.bmp",
imageFile27 = g_LBTools_rootPath + "\BipedHelper_Image27.bmp",
imageFile28 = g_LBTools_rootPath + "\BipedHelper_Image28.bmp",
imageFile29 = g_LBTools_rootPath + "\BipedHelper_Image29.bmp",
imageFile30 = g_LBTools_rootPath + "\BipedHelper_Image30.bmp",
imageFile31 = g_LBTools_rootPath + "\BipedHelper_Image31.bmp",
imageFile32 = g_LBTools_rootPath + "\BipedHelper_Image32.bmp",
imageFile33 = g_LBTools_rootPath + "\BipedHelper_Image33.bmp",
imageFile34 = g_LBTools_rootPath + "\BipedHelper_Image34.bmp",
imageFile35 = g_LBTools_rootPath + "\BipedHelper_Image35.bmp",
imageFile36 = g_LBTools_rootPath + "\BipedHelper_Image36.bmp",
imageFile37 = g_LBTools_rootPath + "\BipedHelper_Image37.bmp",

/*==================================================================================
// Structure functions
/*==================================================================================

f_findSkinModifier
f_getAllChildren
f_findHierarchyRoot
f_findHierarchy
f_missingBipedError
f_filterBipedObjs
f_findAllParts
f_initBipedParts
f_collectBipRoots
f_addKeysAll
f_deleteAllFrameKeys
f_processTCBvalues
f_evaluateTCBprocess
f_storeSpaces
f_loadSpaces
f_limbBody
f_limbObject
f_bipedBakeSlidingKeys
f_bipedBakeSlidingKeyNext
f_bipedBakeSlidingKeyLast
f_bipedBakeRoot
f_bipedBakeHead
f_bipedUI

====================================================================================*/

fn f_findSkinModifier obj =
(
	local skinFound = false
	for i = 1 to obj.modifiers.count do
	(
		if classof obj.modifiers[i] == Skin do
		(
			skinFound = true
			exit
		)
	)
	skinFound
),

/*----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/

fn f_getAllChildren obj &a_nodes:#() = --// Recursive function
(
	for c in obj.children do
	(
		append a_nodes c
		f_getAllChildren c a_nodes:a_nodes
	)
	a_nodes
),

/*----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/

fn f_findHierarchyRoot obj = --// Recursive function
(
	if obj != undefined do 
	(
		if isValidnode obj.parent then
		(
			f_findHierarchyRoot obj.parent
		)
		else
		(
			obj
		)
	)
),

/*----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/

fn f_findHierarchy obj =
(
	if obj != undefined do 
	(
		local parentNode = g_LBTools_BH.f_findHierarchyRoot obj
		g_LBTools_BH.f_getAllChildren parentNode a_nodes:#(parentNode)
	)
),

/*----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/

fn f_missingBipedError =
(
	messageBox "Error: A previously picked Biped is missing from the scene - UI updated." title:""
	setIniSetting g_LBTools_BH.bhINIfile "BipedPanel" "CurrentBip" "1"
	g_LBTools_BH.f_openBipedUI()
),

/*----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/

fn f_filterBipedObjs a_objs =
(
	local a_bipedObjs = #()
	for obj in a_objs where (classof obj == Biped_Object) do
	(
		append a_bipedObjs obj
	)
	a_bipedObjs
),

/*----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/

fn f_findAllParts =
(
	g_LBTools_BH.a_bipedAllParts = #()
	local a_bipedObjs = g_LBTools_BH.f_findHierarchy g_LBTools_BH.bRoot
	a_bipedObjs = g_LBTools_BH.f_filterBipedObjs a_bipedObjs
	for obj in a_bipedObjs do
	(
		if NOT (matchpattern obj.name pattern:"*Footsteps") AND NOT (matchpattern obj.name pattern:"*Twist*") AND NOT (matchpattern obj.name pattern:"*Nub") do
		(
			append g_LBTools_BH.a_bipedAllParts obj
		)
	)
	g_LBTools_BH.a_bipedAllParts
),

/*----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/

fn f_initBipedParts =
(
	if isValidNode g_LBTools_BH.bRoot then
	(
		g_LBTools_BH.bPelvis = biped.getNode g_LBTools_BH.bRoot #Pelvis
		g_LBTools_BH.bSpine = biped.getNode g_LBTools_BH.bRoot #Spine link:2
		g_LBTools_BH.bHead = biped.getNode g_LBTools_BH.bRoot #Head
		
		g_LBTools_BH.bClavicleL = biped.getNode g_LBTools_BH.bRoot #lArm link:1
		g_LBTools_BH.bUpperarmL = biped.getNode g_LBTools_BH.bRoot #lArm link:2
		g_LBTools_BH.bForearmL = biped.getNode g_LBTools_BH.bRoot #lArm link:3
		g_LBTools_BH.bHandL = biped.getNode g_LBTools_BH.bRoot #lArm link:4
		
		g_LBTools_BH.bClavicleR = biped.getNode g_LBTools_BH.bRoot #rArm link:1
		g_LBTools_BH.bUpperarmR = biped.getNode g_LBTools_BH.bRoot #rArm link:2
		g_LBTools_BH.bForearmR = biped.getNode g_LBTools_BH.bRoot #rArm link:3
		g_LBTools_BH.bHandR = biped.getNode g_LBTools_BH.bRoot #rArm link:4
		
		g_LBTools_BH.bThighL = biped.getNode g_LBTools_BH.bRoot #lLeg link:1
		g_LBTools_BH.bCalfL = biped.getNode g_LBTools_BH.bRoot #lLeg link:2
		g_LBTools_BH.bFootL = biped.getNode g_LBTools_BH.bRoot #lLeg link:3
		
		g_LBTools_BH.bThighR = biped.getNode g_LBTools_BH.bRoot #rLeg link:1
		g_LBTools_BH.bCalfR = biped.getNode g_LBTools_BH.bRoot #rLeg link:2
		g_LBTools_BH.bFootR = biped.getNode g_LBTools_BH.bRoot #rLeg link:3
		
		g_LBTools_BH.a_armLeft = #(g_LBTools_BH.bClavicleL, g_LBTools_BH.bUpperarmL, g_LBTools_BH.bForearmL, g_LBTools_BH.bHandL)
		g_LBTools_BH.a_armRight = #(g_LBTools_BH.bClavicleR, g_LBTools_BH.bUpperarmR, g_LBTools_BH.bForearmR, g_LBTools_BH.bHandR)
		g_LBTools_BH.a_legLeft = #(g_LBTools_BH.bThighL, g_LBTools_BH.bCalfL, g_LBTools_BH.bFootL)
		g_LBTools_BH.a_legRight = #(g_LBTools_BH.bThighR, g_LBTools_BH.bCalfR, g_LBTools_BH.bFootR)
		
		g_LBTools_BH.a_bipedLimbs = #(g_LBTools_BH.bClavicleL, g_LBTools_BH.bUpperarmL, g_LBTools_BH.bForearmL, g_LBTools_BH.bHandL,
														g_LBTools_BH.bClavicleR, g_LBTools_BH.bUpperarmR, g_LBTools_BH.bForearmR, g_LBTools_BH.bHandR,
														g_LBTools_BH.bThighL, g_LBTools_BH.bCalfL, g_LBTools_BH.bFootL,
														g_LBTools_BH.bThighR, g_LBTools_BH.bCalfR, g_LBTools_BH.bFootR
													)
		
		g_LBTools_BH.a_bipedHandsFeet = #(g_LBTools_BH.bHandL, g_LBTools_BH.bHandR, g_LBTools_BH.bFootL, g_LBTools_BH.bFootR)
		g_LBTools_BH.f_findAllParts()
	)
	else
	(
		g_LBTools_BH.f_missingBipedError()
	)
),

/*----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/

fn f_collectBipRoots =
(
	for b in geometry where (classof b.controller == Vertical_Horizontal_Turn) do
	(
		append g_LBTools_BH.a_bips b
	)
),

/*----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/

fn f_addKeysAll =
(
	try
	(
		biped.addNewKey g_LBTools_BH.bRoot.controller.vertical sliderTime
		biped.addNewKey g_LBTools_BH.bRoot.controller.horizontal sliderTime
		biped.addNewKey g_LBTools_BH.bRoot.controller.turning sliderTime
		biped.addNewKey g_LBTools_BH.bPelvis.controller sliderTime
		biped.addNewKey g_LBTools_BH.bSpine.controller sliderTime
		biped.addNewKey g_LBTools_BH.bHead.controller sliderTime
		biped.addNewKey g_LBTools_BH.bHandL.controller sliderTime
		biped.addNewKey g_LBTools_BH.bHandR.controller sliderTime
		biped.addNewKey g_LBTools_BH.bFootL.controller sliderTime
		biped.addNewKey g_LBTools_BH.bFootR.controller sliderTime
	)catch()
),

/*----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/

fn f_deleteAllFrameKeys =
(
		try(deleteKey g_LBTools_BH.bRoot.controller.vertical.controller (getKeyIndex g_LBTools_BH.bRoot.controller.vertical.controller sliderTime))catch()
		try(deleteKey g_LBTools_BH.bRoot.controller.horizontal.controller (getKeyIndex g_LBTools_BH.bRoot.controller.horizontal.controller sliderTime))catch()
		try(deleteKey g_LBTools_BH.bRoot.controller.turning.controller (getKeyIndex g_LBTools_BH.bRoot.controller.turning.controller sliderTime))catch()
		try(deleteKey g_LBTools_BH.bPelvis.controller (getKeyIndex g_LBTools_BH.bPelvis.controller sliderTime))catch()
		try(deleteKey g_LBTools_BH.bSpine.controller (getKeyIndex g_LBTools_BH.bSpine.controller sliderTime))catch()
		try(deleteKey g_LBTools_BH.bHead.controller (getKeyIndex g_LBTools_BH.bHead.controller sliderTime))catch()
		try(deleteKey g_LBTools_BH.bHandL.controller (getKeyIndex g_LBTools_BH.bHandL.controller sliderTime))catch()
		try(deleteKey g_LBTools_BH.bHandR.controller (getKeyIndex g_LBTools_BH.bHandR.controller sliderTime))catch()
		try(deleteKey g_LBTools_BH.bFootL.controller (getKeyIndex g_LBTools_BH.bFootL.controller sliderTime))catch()
		try(deleteKey g_LBTools_BH.bFootR.controller (getKeyIndex g_LBTools_BH.bFootR.controller sliderTime))catch()
),

/*----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/

mapped fn f_processTCBvalues obj val =
(
	try
	(
		if obj == g_LBTools_BH.bRoot then
		(
			(biped.getKey obj.controller[1].controller (getkeyindex obj.controller[1].controller slidertime)).continuity = val
			(biped.getKey obj.controller[2].controller (getkeyindex obj.controller[2].controller slidertime)).continuity = val
			(biped.getKey obj.controller[3].controller (getkeyindex obj.controller[3].controller slidertime)).continuity = val
		)
		else
		(
			(biped.getKey obj.controller (getkeyindex obj.controller slidertime)).continuity = val
		)
	)catch()
),

/*----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/

fn f_evaluateTCBprocess val =
(
	if selection.count > 0 do
	(
		if keyboard.shiftPressed OR keyboard.controlPressed then
		(
			slidertime = 0
			for t = animationRange.start to animationRange.end while not keyboard.escPressed do
			(
				at time t (g_LBTools_BH.f_processTCBvalues (selection as array) val)
				slidertime += 1
			)
			messagebox "Done processing TCB values on selection." title:""
		)
		else
		(
			g_LBTools_BH.f_processTCBvalues (selection as array) val
		)
	)
),

/*----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/

fn f_storeSpaces =
(
	local a_limb_nodes = #(g_LBTools_BH.bHandL,g_LBTools_BH.bHandR,g_LBTools_BH.bFootL,g_LBTools_BH.bFootR)
	local a_limb_ctrls = #(g_LBTools_BH.bHandL.controller,g_LBTools_BH.bHandR.controller,g_LBTools_BH.bFootL.controller,g_LBTools_BH.bFootR.controller)
	local a_allKeys = #()
	local a_spaces = #(#(), #(), #(), #())

	select a_limb_nodes
	for n = 1 to a_limb_nodes.count while not keyboard.escPressed do
	(
		local keyCount = numKeys a_limb_ctrls[n]
		for i = 1 to keyCount while not keyboard.escPressed do
		(
			a_allKeys[i] = biped.getkey a_limb_ctrls[n] i
			if a_allKeys[i].ikspace == 1 then
			(
				a_spaces[n][i] = 1
			)
			else
			(
				a_spaces[n][i] = 0
			)
		)
		for j = 1 to keyCount while not keyboard.escPressed do
		(
			t = getKeyTime a_limb_ctrls[n] j
			sliderTime = t
			biped.setFreeKey a_limb_nodes[n]
		)
	)
	sliderTime = animationRange.start
	a_spaces
),

/*----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/

fn f_loadSpaces a_spaces =
(
	local a_limb_nodes = #(g_LBTools_BH.bHandL,g_LBTools_BH.bHandR,g_LBTools_BH.bFootL,g_LBTools_BH.bFootR)
	local a_limb_ctrls = #(g_LBTools_BH.bHandL.controller,g_LBTools_BH.bHandR.controller,g_LBTools_BH.bFootL.controller,g_LBTools_BH.bFootR.controller)
	
	select a_limb_nodes
	for n = 1 to a_limb_ctrls.count while not keyboard.escPressed do
	(
		for i = 1 to a_spaces[n].count while not keyboard.escPressed do
		(
			t = getKeyTime a_limb_ctrls[n] i
			sliderTime = t
			if a_spaces[n][i] == 1 do
			(
				biped.setSlidingKey a_limb_nodes[n]
				--(biped.getkey a_limb_ctrls[n] i).continuity = 0 --// Not sure if this is needed, leaving it here
			)
		)
	)
	sliderTime = animationRange.start
),

/*----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/

fn f_limbBody =
(
	if selection.count > 0 do
	(
		for obj in (selection as array) do
		(
			try
			(			
				local keyCount = numKeys obj.controller
				for i = 1 to keyCount while not keyboard.escPressed do
				(
					t = getKeyTime obj.controller i
					sliderTime = t
					biped.setFreeKey obj
				)
				sliderTime = animationRange.start
			) catch()
		)
	)
),

/*----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/

fn f_limbObject =
(
	if selection.count > 0 do
	(
		for obj in (selection as array) do
		(
			try
			(
				local keyCount = numKeys obj.controller
				for i = 1 to keyCount while not keyboard.escPressed do
				(
					t = getKeyTime obj.controller i
					sliderTime = t
					biped.setSlidingKey obj
				)
				sliderTime = animationRange.start
			) catch()
		)
	)
),

/*----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/

fn f_bipedBakeSlidingKeys a_limbs =
(
	for obj in a_limbs while not keyboard.escPressed do 
	(
		select obj
		indexInitial = numKeys obj.controller
		if indexInitial > 1 then
		(
			indexAdded = 0
			for i = 1 to indexInitial while not keyboard.escPressed do
			(
				i = i + indexAdded
				indexCount = indexInitial + indexAdded
				currentKey = biped.getKey obj.controller i
				if i < indexCount do
					(nextKey = biped.getKey obj.controller (i+1))
				if nextKey != undefined do
				(
					if currentKey.ikSpace == 1 and nextKey.ikSpace == 1 do --// Both keys are Object space (sliding)
					(
						t = getKeyTime obj.controller i
						if t < animationRange.start do
						(
							t = animationRange.start - 1
							sliderTime = t
						)
						if i < (indexCount + indexAdded) do --// Set sliding keys until the next sliding key is reached
						(
							nextKeyTime = getKeyTime obj.controller (i+1)
							if nextKeyTime > animationRange.end do
								(nextKeyTime = animationRange.end + 1)
							for h = (t + 1) to (nextKeyTime - 1) while not keyboard.escPressed do
							(
								sliderTime = h
								biped.SetSlidingKey obj
								indexAdded = indexAdded + 1
							)
						)
					)
				)
			)
			bRoot.controller.osObject = undefined
		)
		else
		(
			str_error = "Error: There must be at least two sliding keys on the limb > " + obj.name
			format (str_error + "\n")
			messageBox str_error title:""
		)
	)
	clearSelection()
	sliderTime = animationRange.start
),

/*----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/

fn f_bipedBakeSlidingKeyNext =
(
	local obj = selection[1]

	while (getKeyIndex obj.controller sliderTime) == 0 do
	(
		if sliderTime == animationRange.end then
		(
			exit()
		)
		else
		(
			sliderTime += 1
		)
	)
	if sliderTime < animationRange.end do
	(
		local index = getKeyIndex obj.controller sliderTime
		local initialKey = biped.getKey obj.controller index
		if index < (numKeys obj.controller) then --// Needs at least two keys to work
		(
			local nextKey = biped.getKey obj.controller (index + 1)
			local nextKeyTime = getKeyTime obj.controller (index + 1)
			if nextKeyTime <= animationRange.end then
			(
				if initialKey.ikSpace == 1 AND nextKey.ikSpace == 1 then
				(
					local t = getKeyTime obj.controller index
					sliderTime = t
					for f = (t + 1) to (nextKeyTime - 1) while NOT keyboard.escPressed do
					(
						sliderTime = f
						biped.SetSlidingKey obj
					)
					sliderTime += 1
				)
				else
				(
					sliderTime += 1
				)
			)
			else
			(
				messageBox "Error: The next sliding key must be within the visible time range." title:""
			)
		)
		else
		(
			local str_error = "Error: There must be at least two sliding keys on the limb " + obj.name + " from the slider time."
			format (str_error + "\n")
			messageBox str_error title:""
		)
	)
),

/*----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/

fn f_bipedBakeSlidingKeyLast =
(
	local bool_done = false
	local obj = selection[1]
	
	while bool_done == false do
	(
		while (getKeyIndex obj.controller sliderTime) == 0 do
		(
			if sliderTime == animationRange.end then
			(
				exit()
			)
			else
			(
				sliderTime += 1
			)
		)
		if sliderTime < animationRange.end then
		(
			local index = getKeyIndex obj.controller sliderTime
			local currentKey = biped.getKey obj.controller index
			if index < (numKeys obj.controller) then --// Needs at least two keys to work
			(
				local nextKey = biped.getKey obj.controller (index + 1)
				local nextKeyTime = getKeyTime obj.controller (index + 1)
				if nextKeyTime <= animationRange.end then
				(
					if currentKey.ikSpace == 1 and nextKey.ikSpace == 1 then
					(
						local t = getKeyTime obj.controller index
						sliderTime = t
						for f = (t + 1) to (nextKeyTime - 1) while not keyboard.escPressed do
						(
							sliderTime = f
							biped.SetSlidingKey obj
						)
						sliderTime += 1
						index = getKeyIndex obj.controller sliderTime
						currentKey = biped.getKey obj.controller index
						if index < (numKeys obj.controller) then
						(
							nextKey = biped.getKey obj.controller (index + 1)
							if nextKey.ikSpace == 0 do
							(
								bool_done = true
							)
						)
						else
						(
							exit()
						)
					)
					else
					(
						sliderTime += 1
					)
				)
				else
				(
					messageBox "Error: The next sliding key must be within the visible time range." title:""
					exit()
				)
			)
			else
			(
				local str_error = "Error: There must be at least two sliding keys on the limb " + obj.name + " from the slider time."
				format (str_error + "\n")
				messageBox str_error title:""
				exit()
			)
		)
		else
		(
			bool_done = true
		)
	)
),

/*----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/

fn f_bipedBakeRoot =
(
	sliderTime = animationRange.start
	local bipObj = g_LBTools_BH.bRoot
	select bipObj
	linkCtrl = bipObj.parent
	local followHelper = dummy()
	followHelper.name = "FollowHelper"
	followHelper.parent = linkCtrl
	with animate on
	(
		for t = animationRange.start to animationRange.end do
		(
			at time t
			followHelper.transform = bipObj.transform
		)
		bipObj.parent = undefined
		if classof linkCtrl.controller == Link_Constraint then
		(
			for i = 1 to linkCtrl.controller.getNumTargets() while not keyboard.escPressed do
			(
				if linkCtrl.controller.getNode i != undefined do --// A target object is set (not linked to world space)
				(
					local ct = linkCtrl.controller.getFrameNo i --// Current target time
					if i < linkCtrl.controller.getNumTargets() do --// Is not the last target
					(
						local nt = linkCtrl.controller.getFrameNo (i+1) --// Get the next target time
						if ct >= animationRange.start and nt <= animationRange.end then
						(
							for t = ct to nt while not keyboard.escPressed do
							(
								sliderTime = t
								bipObj.transform = $FollowHelper.transform
							)
						)
						else
						(
							for t = animationRange.start to animationRange.end while not keyboard.escPressed do
							(
								sliderTime = t
								bipObj.transform = $FollowHelper.transform
							)
						)
					)
					if i == linkCtrl.controller.getNumTargets() and sliderTime != animationRange.end do --// Is the last target
					(
						for t = ct to animationRange.end while not keyboard.escPressed do
						(
							sliderTime = t
							bipObj.transform = $FollowHelper.transform
						)					
					)
				)
			)
		)
		else
		(
			for t = animationRange.start to animationRange.end while not keyboard.escPressed do
			(
				sliderTime = t
				bipObj.transform = $FollowHelper.transform
			)
		)
	)
	animate off()
	delete followHelper
),

/*----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/

fn f_bipedBakeHead =
(
	local pt = Point()
	with Animate on
	(
		for t = animationRange.start to animationRange.end do
		(
			at time t (pt.transform = g_LBTools_BH.bHead.transform)
		)

		g_LBTools_BH.bRoot.controller.headObject = undefined
		
		for t = animationRange.start to animationRange.end do
		(
			at time t (g_LBTools_BH.bHead.transform = pt.transform)
		)
	)
	delete pt
),

/*----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/

fn f_bipedUI =
(	
	rollout SelectDisplayKeys_Rollout "Selection / Display / Keys"
	(
		dropDownList ddl_bips "" width:150 across:2 align:#left tooltip:"Choose a Biped root node from the list for the panel to operate on. Hold SHIFT to select the Biped root or CONTROL to select the whole rig."
		button btn_refreshUI "R" width:20 height:20 align:#right offset:[8,0] tooltip:"Refresh the list by searching for all Biped roots in the scene." images:#(imageFile18, undefined, 1, 1, 1, 1, 1)
		group "Selection"
		(
			label lbl_txt1 "Add: Shift/Control - Sub: Alt" align:#center
			--images: #(<image>, <maskImage>, <count_integer>, <enabled_out_image_index>, <enabled_in_image_index>, <disabled_out_image_index>, <disabled_in_image_index>, <invert_boolean>, <colortheme_boolean>)
			button btn_selectAll "Select All" align:#center width:160 height:20 tooltip:"Select all Biped parts" images:#(imageFile1, undefined, 1, 1, 1, 1, 1)
			button btn_selectHead "Select Head" align:#center width:160 height:20 tooltip:"Select the head bone" images:#(imageFile17, undefined, 1, 1, 1, 1, 1)
			button btn_selectSpine "Select Spine" align:#center width:160 height:20 tooltip:"Select the second spine link" images:#(imageFile15, undefined, 1, 1, 1, 1, 1)
			button btn_selectRoot "Select Root" align:#center width:160 height:20 tooltip:"Select the root bone (Bip01 or Bip001)" images:#(imageFile2, undefined, 1, 1, 1, 1, 1)
			button btn_selectLHand "Left Hand" across:2 align:#center width:80 height:20 tooltip:"Select the left hand bone" images:#(imageFile4, undefined, 2, 1, 1, 1, 1)
			button btn_selectRHand "Right Hand" align:#center width:80 height:20 tooltip:"Select the right hand bone" images:#(imageFile4, undefined, 2, 2, 2, 1, 1)
			button btn_selectLFoot "Left Foot" across:2 align:#center width:80 height:20 tooltip:"Select the left foot bone" images:#(imageFile3, undefined, 2, 1, 1, 1, 1)
			button btn_selectRFoot "Right Foot" align:#center width:80 height:20 tooltip:"Select the right foot bone" images:#(imageFile3, undefined, 2, 2, 2, 1, 1)
			button btn_selectHandsFeet "Both Hands & Feet" align:#center width:160 height:20 tooltip:"Select all hand and foot bones" images:#(imageFile32, undefined, 1, 1, 1, 1, 1)
		)
		group "Display"
		(
			button btn_hide "Hide Biped" across:2 align:#center width:82 height:20 tooltip:"Hide all Biped parts" images:#(imageFile5, undefined, 2, 1, 1, 1, 1)
			button btn_unhide "Unhide Biped" align:#center width:82 height:20 tooltip:"Unhide Biped parts except for end nubs and the footsteps node" images:#(imageFile5, undefined, 2, 2, 2, 1, 1)
			button btn_trajToggle "Trajectories Toggle" align:#center width:140 height:20 tooltip:"Toggle trajectories display for selected parts" images:#(imageFile16, undefined, 1, 1, 1, 1, 1)
		)
		group "Keys"
		(
			button btn_keyAll "Key All Biped Parts" width:160 height:20 align:#center tooltip:"Add new keys to ALL Biped parts at the current slider time" images:#(imageFile19, undefined, 1, 1, 1, 1, 1)
			button btn_keySelected "Key Selected Biped Parts" width:160 height:20 align:#center tooltip:"Add new keys to SELECTED Biped parts at the current slider time" images:#(imageFile33, undefined, 1, 1, 1, 1, 1)
			button btn_deleteAllkeys "Delete All Biped Keys" width:160 height:20 align:#center tooltip:"Remove all keys on ALL Biped parts" images:#(imageFile20, undefined, 1, 1, 1, 1, 1)
			button btn_deleteFrameKeys "Delete Frame Keys" width:160 height:20 align:#center tooltip:"Remove keys on SELECTED Biped parts at the current slider time. Alternatively, use SHIFT or CONTROL to remove keys on ALL Biped parts at the current slider time." images:#(imageFile21, undefined, 1, 1, 1, 1, 1)
			label lbl_TCB1 "==== TCB - Continuity ====" align:#center
			label lbl_TCB2 "Apply to full range: Shift/Control" align:#center
			button btn_TCBlinear "TCB Linear" across:2 align:#center width:80 height:20 tooltip:"Set keys at current slider time to 0 Continuity" images:#(imageFile14, undefined, 2, 1, 1, 1, 1)
			button btn_TCBsmooth "TCB Smooth" align:#center width:80 height:20 tooltip:"Set keys at current slider time to 25 Continuity" images:#(imageFile14, undefined, 2, 2, 2, 1, 1)
			button btn_TCB5 "5" across:4 align:#center width:35 height:20 tooltip:"Set keys at current slider time to 5 Continuity" images:#(imageFile22, undefined, 4, 1, 1, 1, 1)
			button btn_TCB10 "10" align:#center width:35 height:20 tooltip:"Set keys at current slider time to 10 Continuity" images:#(imageFile22, undefined, 4, 2, 2, 1, 1)
			button btn_TCB15 "15" align:#center width:35 height:20 tooltip:"Set keys at current slider time to 15 Continuity" images:#(imageFile22, undefined, 4, 3, 3, 1, 1)
			button btn_TCB20 "20" align:#center width:35 height:20 tooltip:"Set keys at current slider time to 20 Continuity" images:#(imageFile22, undefined, 4, 4, 4, 1, 1)
		)	
		
		on SelectDisplayKeys_Rollout open do
		(
			setCommandPanelTaskMode #motion
			local a_bipNames = #()
			for b in g_LBTools_BH.a_bips do
			(
				append a_bipNames b.name
			)
			ddl_bips.items = a_bipNames
			ddl_bips.selection = execute (getIniSetting g_LBTools_BH.bhINIfile "BipedPanel" "CurrentBip")
			if ddl_bips.selection > 0 then
			(
				g_LBTools_BH.bRoot = g_LBTools_BH.a_bips[ddl_bips.selection]
				g_LBTools_BH.f_initBipedParts()
				ddl_bips.height = (ddl_bips.items.count + 1) * 100
			)
			else
			(
				g_LBTools_BH.f_missingBipedError()					
			)
		)

		on SelectDisplayKeys_Rollout moved pos do
		(
			g_LBTools_BH.BH_pos = pos
			setIniSetting g_LBTools_BH.bhINIfile "Floater" "Position" (g_LBTools_BH.BH_pos as string)			
		)
		
		on ddl_bips selected val do
		(
			if isValidNode g_LBTools_BH.a_bips[ddl_bips.selection] then
			(
				if ddl_bips.selected == g_LBTools_BH.a_bips[ddl_bips.selection].name then
				(
					g_LBTools_BH.bRoot = g_LBTools_BH.a_bips[ddl_bips.selection]
					g_LBTools_BH.f_initBipedParts()
					setIniSetting g_LBTools_BH.bhINIfile "BipedPanel" "CurrentBip" (ddl_bips.selection as string)
					setCommandPanelTaskMode #motion
					if keyboard.shiftPressed do
					(
						try(select g_LBTools_BH.bRoot)catch(g_LBTools_BH.f_initBipedParts())
					)
					if keyboard.controlPressed do
					(
						try(select g_LBTools_BH.a_bipedAllParts)catch(g_LBTools_BH.f_initBipedParts())
					)
				)
				else
				(
					g_LBTools_BH.f_missingBipedError()
				)
			)
			else
			(
				g_LBTools_BH.f_missingBipedError()
			)
		)
		
		on btn_refreshUI pressed do
		(
			g_LBTools_BH.f_openBipedUI()
		)

		on btn_selectAll pressed do
		(
			setCommandPanelTaskMode #motion
			try
			(
				select g_LBTools_BH.a_bipedAllParts
			)catch(g_LBTools_BH.f_initBipedParts())
		)
		
		on btn_selectHead pressed do
		(
			setCommandPanelTaskMode #motion
			try
			(
				if keyboard.shiftPressed OR keyboard.controlPressed then
				(
					selectmore g_LBTools_BH.bHead
				)
				else
				(
					if keyboard.altPressed then
					(
						deselect g_LBTools_BH.bHead
					)
					else
					(
						select g_LBTools_BH.bHead
					)
				)
			)catch(g_LBTools_BH.f_initBipedParts())
		)
		
		on btn_selectSpine pressed do
		(
			setCommandPanelTaskMode #motion
			try
			(
				if keyboard.shiftPressed OR keyboard.controlPressed then
				(
					selectmore g_LBTools_BH.bSpine
				)
				else
				(
					if keyboard.altPressed then
					(
						deselect g_LBTools_BH.bSpine
					)
					else
					(
						select g_LBTools_BH.bSpine
					)
				)
			)catch(g_LBTools_BH.f_initBipedParts())
		)
		
		on btn_selectRoot pressed do
		(
			setCommandPanelTaskMode #motion
			try
			(
				if keyboard.shiftPressed OR keyboard.controlPressed then
				(
					selectmore g_LBTools_BH.bRoot
				)
				else
				(
					if keyboard.altPressed then
					(
						deselect g_LBTools_BH.bRoot
					)
					else
					(
						select g_LBTools_BH.bRoot
					)
				)
			)catch(g_LBTools_BH.f_initBipedParts())
		)
		
		on btn_selectLFoot pressed do
		(
			setCommandPanelTaskMode #motion
			try
			(
				if keyboard.shiftPressed OR keyboard.controlPressed then
				(
					selectmore g_LBTools_BH.bFootL
				)
				else
				(
					if keyboard.altPressed then
					(
						deselect g_LBTools_BH.bFootL
					)
					else
					(
						select g_LBTools_BH.bFootL
					)
				)
			)catch(g_LBTools_BH.f_initBipedParts())
		)
	
		on btn_selectRFoot pressed do
		(
			setCommandPanelTaskMode #motion
			try
			(
				if keyboard.shiftPressed OR keyboard.controlPressed then
				(
					selectmore g_LBTools_BH.bFootR
				)
				else
				(
					if keyboard.altPressed then
					(
						deselect g_LBTools_BH.bFootR
					)
					else
					(
						select g_LBTools_BH.bFootR
					)
				)
			)catch(g_LBTools_BH.f_initBipedParts())
		)
		
		on btn_selectLHand pressed do
		(
			setCommandPanelTaskMode #motion
			try
			(
				if keyboard.shiftPressed OR keyboard.controlPressed then
				(
					selectmore g_LBTools_BH.bHandL
				)
				else
				(
					if keyboard.altPressed then
					(
						deselect g_LBTools_BH.bHandL
					)
					else
					(
						select g_LBTools_BH.bHandL
					)
				)
			)catch(g_LBTools_BH.f_initBipedParts())
		)
	
		on btn_selectRHand pressed do
		(
			setCommandPanelTaskMode #motion
			try
			(
				if keyboard.shiftPressed OR keyboard.controlPressed then
				(
					selectmore g_LBTools_BH.bHandR
				)
				else
				(
					if keyboard.altPressed then
					(
						deselect g_LBTools_BH.bHandR
					)
					else
					(
						select g_LBTools_BH.bHandR
					)
				)
			)catch(g_LBTools_BH.f_initBipedParts())
		)
		
		on btn_selectHandsFeet pressed do
		(
			setCommandPanelTaskMode #motion
			try
			(
				if keyboard.shiftPressed OR keyboard.controlPressed then
				(
					selectmore g_LBTools_BH.a_bipedHandsFeet
				)
				else
				(
					if keyboard.altPressed then
					(
						deselect g_LBTools_BH.a_bipedHandsFeet
					)
					else
					(
						select g_LBTools_BH.a_bipedHandsFeet
					)
				)
			)catch(g_LBTools_BH.f_initBipedParts())
		)
		
		on btn_hide pressed do
		(
			try
			(
				local a_bipedObjs = g_LBTools_BH.f_findHierarchy g_LBTools_BH.bRoot
				a_bipedObjs = g_LBTools_BH.f_filterBipedObjs a_bipedObjs
				for h in helpers do
				(
					if matchpattern h.name pattern:"*Nub" do
					(
						append a_bipedObjs h
					)
				)
				hide a_bipedObjs
			)catch(g_LBTools_BH.f_initBipedParts())
		)

		on btn_unhide pressed do
		(
			try
			(
				unhide g_LBTools_BH.a_bipedAllParts
			)catch(g_LBTools_BH.f_initBipedParts())
		)
		
		on btn_trajToggle pressed do
		(
			try
			(
				setCommandPanelTaskMode #motion				
				local bip = g_LBTools_BH.bRoot
				if bip.controller.displaytrajectories then
				(
					bip.controller.displaytrajectories = false
				)
				else
				(
					bip.controller.displaytrajectories = true
				)
			)catch(g_LBTools_BH.f_initBipedParts())
		)
		
		on btn_keyAll pressed do
		(
			try
			(
				if g_LBTools_BH.bRoot.controller.figureMode == false then
				(
					g_LBTools_BH.f_addKeysAll()
				)
				else
				(
					messageBox "Error: Exit figure mode first." title:""
				)
			)catch(g_LBTools_BH.f_initBipedParts())
		)
		
		on btn_keySelected pressed do
		(
			try
			(
				if g_LBTools_BH.bRoot.controller.figureMode == false then
				(
					if selection.count > 0 then
					(
						local a_bipedParts = selection as array
						for b in a_bipedParts do
						(
							if b == g_LBTools_BH.bRoot then
							(
								biped.addNewKey g_LBTools_BH.bRoot.controller.vertical sliderTime
								biped.addNewKey g_LBTools_BH.bRoot.controller.horizontal sliderTime
								biped.addNewKey g_LBTools_BH.bRoot.controller.turning sliderTime
							)
							else
							(
								biped.addNewKey b.controller sliderTime
							)
						)
					)
					else
					(
						messageBox "Error: Select one or more Biped parts first." title:""
					)
				)
				else
				(
					messageBox "Error: Exit figure mode first." title:""
				)
			)catch(g_LBTools_BH.f_initBipedParts())	
		)
		
		on btn_deleteAllkeys pressed do
		(
			try
			(
				if g_LBTools_BH.bRoot.controller.figureMode == false then
				(
					if (queryBox "Continue to delete all Biped animation?" title:"") do
					(
						biped.clearAllAnimation g_LBTools_BH.bRoot.controller
					)
				)
				else
				(
					messageBox "Error: Exit figure mode first." title:""
				)
			)catch(g_LBTools_BH.f_initBipedParts())
		)
			
		on btn_deleteFrameKeys pressed do
		(
			try
			(
				if g_LBTools_BH.bRoot.controller.figureMode == false then
				(
					if keyboard.shiftPressed OR keyboard.controlPressed then
					(
						g_LBTools_BH.f_deleteAllFrameKeys()
					)
					else --// Default method, removes keys only on selected parts
					(
						if selection.count > 0 then
						(
							local a_bipedParts = selection as array
							for b in a_bipedParts do
							(
								deselectKeys b.controller
								selectKeys b.controller sliderTime
								if b == g_LBTools_BH.bRoot then
								(
									deleteKeys b.controller.vertical.controller.keys #selection
									deleteKeys b.controller.horizontal.controller.keys #selection
									deleteKeys b.controller.turning.controller.keys #selection
								)
								else
								(
									deleteKeys b.controller.keys #selection
								)
							)
						)
						else
						(
							messageBox "Error: Select one or more Biped parts first." title:""
						)
					)
				)
				else
				(
					messageBox "Error: Exit figure mode first." title:""
				)
			)catch(g_LBTools_BH.f_initBipedParts())	
		)
		
		on btn_TCBlinear pressed do
		(
			g_LBTools_BH.f_evaluateTCBprocess 0.0
		)

		on btn_TCBsmooth pressed do
		(
			g_LBTools_BH.f_evaluateTCBprocess 25.0
		)
		
		on btn_TCB5 pressed do
		(
			g_LBTools_BH.f_evaluateTCBprocess 5.0
		)
		
		on btn_TCB10 pressed do
		(
			g_LBTools_BH.f_evaluateTCBprocess 10.0
		)
		
		on btn_TCB15 pressed do
		(
			g_LBTools_BH.f_evaluateTCBprocess 15.0
		)
		
		on btn_TCB20 pressed do
		(
			g_LBTools_BH.f_evaluateTCBprocess 20.0
		)
	) --// end rollout
	
	rollout QuickPosture_Rollout "Quick Posture"
	(
		local postureObjsFile = getDir #plugcfg + "\LBTools_BipedHelper_PostureObjs.txt"
		
		group "Posture Grabber"
		(
			button btn_copyPosture "Copy" width:85 height:20 across:2 align:#left offset:[-5,0] images:#(imageFile37, undefined, 3, 1, 1, 1, 1) tooltip:"Copy the biped selection as a saved posture to a file for later pasting"
			button btn_pastePosture "Paste" width:85 height:20 align:#right offset:[5,0] images:#(imageFile37, undefined, 3, 2, 2, 1, 1) tooltip:"Paste the previously saved posture onto the relevant biped parts"
			button f_selectPostureObjs "Select" width:85 height:20 across:2 align:#left offset:[-5,0] images:#(imageFile37, undefined, 3, 3, 3, 1, 1) offset:[-5,0] tooltip:"Select the biped parts from which the posture was copied"
			checkbox chkbx_pasteOpposite "Opposite" align:#right tooltip:"Paste the posture onto the opposite side (usually for limbs)"
		)
		group "Mirror Limbs"
		(
			button btn_mirrorArmL "Mirror L-Arm" width:85 height:20 across:2 offset:[-5,0] align:#left images:#(imageFile34, undefined, 2, 1, 1, 1, 1) tooltip:"Mirror the left arm posture to the right arm (excluding fingers)"
			button btn_mirrorArmR "Mirror R-Arm" width:85 height:20 offset:[5,0] align:#right images:#(imageFile34, undefined, 2, 2, 2, 1, 1) tooltip:"Mirror the right arm posture to the left arm (excluding fingers)"
			button btn_mirrorLegL "Mirror L-Leg" width:85 height:20 offset:[-5,0] across:2 align:#left images:#(imageFile35, undefined, 2, 1, 1, 1, 1) tooltip:"Mirror the left leg posture to the right leg (excluding toes)"
			button btn_mirrorLegR "Mirror R-Leg" width:85 height:20 offset:[5,0] align:#right images:#(imageFile35, undefined, 2, 2, 2, 1, 1) tooltip:"Mirror the right leg posture to the left leg (excluding toes)"
		)
		group "Spine Align"
		(
			button btn_straightenSpine "Straighten" width:85 height:20 offset:[-5,0] across:2 align:#left offset:[-5,0] images:#(imageFile36, undefined, 2, 1, 1, 1, 1) tooltip:"Straightens the spine links to their default orientation"
			button btn_untwistSpine "Untwist" width:85 height:20 offset:[5,0] align:#right offset:[3,0] images:#(imageFile36, undefined, 2, 2, 2, 1, 1) tooltip:"Untwists the spine links to align their orientation"
		)
		
		fn f_mirrorPosture a_bipObjs =
		(
			if isValidNode g_LBTools_BH.bRoot AND NOT isDeleted g_LBTools_BH.bRoot then
			(
				local bRootCtrl = g_LBTools_BH.bRoot.controller
				biped.createCopyCollection bRootCtrl "MirrorTemp"
				local colIndex = biped.numCopyCollections bRootCtrl
				local copyCol = biped.getCopyCollection bRootCtrl colIndex
				biped.copyBipPosture bRootCtrl copyCol a_bipObjs #snapAuto
				local mirroreBH_pose = getCopy copyCol #posture 1
				with Animate on
				(
					biped.pasteBipPosture bRootCtrl mirroreBH_pose true #pstdefault false false false false
				)
				biped.deleteCopyCollection bRootCtrl colIndex
			)
		)
		
		fn f_storePostureObjs a_objs =
		(
			local txtFile = openFile postureObjsFile mode:"w"
			for obj in a_objs do
			(
				format "%\n" obj.name to:txtFile
			)
			close txtFile
		)
		
		fn f_retrievePostureObjs =
		(
			if doesFileExist postureObjsFile do
			(
				local a_objs = #()
				local txtFile = openFile postureObjsFile mode:"r"
				while NOT eof txtFile do
				(
					append a_objs (getNodeByName (readLine txtFile))
				)
				close txtFile
				a_objs
			)
		)
		
		fn f_filterBipedParts a_selObjs =
		(
			local a_bipedParts = #()
			
			for obj in a_selObjs do
			(
				if classof obj == Biped_Object do
				(
					append a_bipedParts obj
				)
			)
			a_bipedParts
		)
		
		on QuickPosture_Rollout open do
		(
			if NOT (doesFileExist postureObjsFile) do
			(
				local txtFile = openFile postureObjsFile mode:"w"
				close txtFile
			)
		)
		
		on btn_copyPosture pressed do
		(
			if selection.count > 0 then
			(
				local a_objs = selection as array
				--// Make sure only Biped parts are selected for copying by filtering out non-Biped parts
				a_objs = f_filterBipedParts a_objs
				if a_objs.count > 0 then
				(
					f_storePostureObjs a_objs
					if isValidNode g_LBTools_BH.bRoot AND NOT isDeleted g_LBTools_BH.bRoot then
					(
						local bRootCtrl = g_LBTools_BH.bRoot.controller
						biped.createCopyCollection bRootCtrl "CopyPosture"
						local colIndex = biped.numCopyCollections bRootCtrl
						local copyCol = biped.getCopyCollection bRootCtrl colIndex
						biped.copyBipPosture bRootCtrl copyCol a_objs #snapAuto
						biped.saveCopyPasteFile bRootCtrl (getDir #plugcfg + "\LBTools_BipedHelper_CopyPosture.cpy")
						biped.deleteCopyCollection bRootCtrl colIndex
					)
				)
				else
				(
					messageBox "Error: No Biped objects were selected." title:""
				)
			)
			else
			(
				messageBox "Error: Select some Biped objects to copy." title:""
			)
		)
		
		on btn_pastePosture pressed do
		(
			if isValidNode g_LBTools_BH.bRoot AND NOT isDeleted g_LBTools_BH.bRoot then
			(
				local postureFile = getDir #plugcfg + "\LBTools_BipedHelper_CopyPosture.cpy"
				if doesFileExist postureFile then
				(
					local bRootCtrl = g_LBTools_BH.bRoot.controller
					biped.loadCopyPasteFile bRootCtrl postureFile
					local colIndex = biped.numCopyCollections bRootCtrl
					local copyCol = biped.getCopyCollection bRootCtrl colIndex
					local copieBH_posture = getCopy copyCol #posture 1
					with Animate on
					(
						biped.pasteBipPosture bRootCtrl copieBH_posture chkbx_pasteOpposite.checked #pstdefault false false false false
					)
					local colIndex = biped.numCopyCollections bRootCtrl
					biped.deleteCopyCollection bRootCtrl colIndex
				)
				else
				(
					messageBox "Error: The pose file does not exist yet. Grab a pose first." title:""
				)
			)
		)
		
		on f_selectPostureObjs pressed do
		(
			local a_objs = f_retrievePostureObjs()
			if a_objs != undefined do
			(
				try (select a_objs)catch(messageBox "Error: Could not select the Biped parts used to copy the posture." title:"")
			)
		)
		
		on btn_mirrorArmL pressed do
		(
			f_mirrorPosture g_LBTools_BH.a_armLeft
		)
		
		on btn_mirrorArmR pressed do
		(
			f_mirrorPosture g_LBTools_BH.a_armRight
		)
		
		on btn_straightenSpine pressed do
		(
			if isValidNode g_LBTools_BH.bRoot AND NOT isDeleted g_LBTools_BH.bRoot then
			(
				with Animate on
				(
					biped.zeroAll g_LBTools_BH.bSpine
				)
				redrawViews()
			)
		)
		
		on btn_untwistSpine pressed do
		(
			if isValidNode g_LBTools_BH.bRoot AND NOT isDeleted g_LBTools_BH.bRoot then
			(
				with Animate on
				(
					biped.zeroTwist g_LBTools_BH.bSpine
				)
				redrawViews()
			)
		)
		
		on btn_mirrorLegL pressed do
		(
			f_mirrorPosture g_LBTools_BH.a_legLeft
		)
		
		on btn_mirrorLegR pressed do
		(
			f_mirrorPosture g_LBTools_BH.a_legRight
		)
	) --// end rollout
	
	rollout PoseGrabber_Rollout "Pose Grabber"
	(
		button btn_grabPose "Grab Frame Pose" width:160 height:20 align:#center tooltip:"Grab (save) a single pose to a file for later pasting using the apply button" images:#(imageFile30, undefined, 1, 1, 1, 1, 1)
		button btn_applyPose "Apply Pose To Frame" width:160 height:20 align:#center tooltip:"Paste a previously grabbed pose at the current slider time" images:#(imageFile31, undefined, 1, 1, 1, 1, 1)
		
		on btn_grabPose pressed do
		(
			if isValidNode g_LBTools_BH.bRoot AND NOT isDeleted g_LBTools_BH.bRoot then
			(
				local bRootCtrl = g_LBTools_BH.bRoot.controller
				biped.createCopyCollection bRootCtrl "PoseGrabber"
				local colIndex = biped.numCopyCollections bRootCtrl
				local copyCol = biped.getCopyCollection bRootCtrl colIndex
				biped.copyBipPose bRootCtrl copyCol #snapAuto
				local grabbeBH_pose = getCopy copyCol #pose 1
				biped.saveCopyPasteFile bRootCtrl (getDir #plugcfg + "\LBTools_BipedHelper_PoseGrabbed.cpy")
				biped.deleteCopyCollection bRootCtrl colIndex
			)
			else
			(
				g_LBTools_BH.f_missingBipedError()			
			)	
		)
		
		on btn_applyPose pressed do
		(
			if isValidNode g_LBTools_BH.bRoot AND NOT isDeleted g_LBTools_BH.bRoot then
			(
				local poseFile = getDir #plugcfg + "\LBTools_BipedHelper_PoseGrabbed.cpy"
				if doesFileExist poseFile then
				(
					local bRootCtrl = g_LBTools_BH.bRoot.controller
					biped.loadCopyPasteFile bRootCtrl poseFile
					local colIndex = biped.numCopyCollections bRootCtrl
					local copyCol = biped.getCopyCollection bRootCtrl colIndex
					local grabbeBH_pose = getCopy copyCol #pose 1
					with Animate on
					(
						--// Requires two paste operations to work properly (Biped oddness)
						biped.pasteBipPose bRootCtrl grabbeBH_pose false #pstdefault true true true false
						biped.pasteBipPose bRootCtrl grabbeBH_pose false #pstdefault true true true false
					)
					local colIndex = biped.numCopyCollections bRootCtrl
					biped.deleteCopyCollection bRootCtrl colIndex
				)
				else
				(
					messageBox "Error: The pose file does not exist yet. Grab a pose first." title:""
				)
			)
			else
			(
				g_LBTools_BH.f_missingBipedError()			
			)	
		)
	) --// end rollout
	
	rollout LimbSpaces_Rollout "Limb Spaces"
	(
		group "Arm Spaces"
		(
			button btn_bothArmsObject "Both Arms Object" align:#center width:170 height:20 tooltip:"Set sliding keys (OBJECT space) for both arms" images:#(imageFile10, undefined, 1, 1, 1, 1, 1)
			button btn_LarmObject "L-Arm Object" align:#center across:2 width:80 height:20 tooltip:"Set a sliding key (OBJECT space) for the left arm" images:#(imageFile6, undefined, 2, 1, 1, 1, 1)
			button btn_RarmObject "R-Arm Object" align:#center width:80 height:20 tooltip:"Set a sliding key (OBJECT space) for the right arm" images:#(imageFile6, undefined, 2, 2, 2, 1, 1)
			button btn_bothArmsBody "Both Arms Body" align:#center width:170 height:20 tooltip:"Set free keys (BODY space) for both arms" images:#(imageFile11, undefined, 1, 1, 1, 1, 1)
			button btn_LarmBody "L-Arm Body" align:#center across:2 width:80 height:20 tooltip:"Set a free key (BODY space) for the left arm" images:#(imageFile7, undefined, 2, 1, 1, 1, 1)
			button btn_RarmBody "R-Arm Body" align:#center width:80 height:20 tooltip:"Set a free key BODY space) for the right arm" images:#(imageFile7, undefined, 2, 2, 2, 1, 1)
		)
		group "Leg Spaces"
		(
			button btn_bothLegsObject "Both Legs Object" align:#center width:170 height:20 tooltip:"Set sliding keys (OBJECT space) for both legs" images:#(imageFile12, undefined, 1, 1, 1, 1, 1)
			button btn_LlegObject "L-Leg Object" align:#center across:2 width:80 height:20 tooltip:"Set a sliding key (OBJECT space) for the left leg" images:#(imageFile8, undefined, 2, 1, 1, 1, 1)
			button btn_RlegObject "R-Leg Object" align:#center width:80 height:20 tooltip:"Set a sliding key (OBJECT space) for the right leg" images:#(imageFile8, undefined, 2, 2, 2, 1, 1)
			button btn_bothLegsBody "Both Legs Body" align:#center width:170 height:20 tooltip:"Set free keys (BODY space) for both legs" images:#(imageFile13, undefined, 1, 1, 1, 1, 1)
			button btn_LlegBody "L-Leg Body" align:#center across:2 width:80 height:20 tooltip:"Set a free key (BODY space) for the left leg" images:#(imageFile9, undefined, 2, 1, 1, 1, 1)
			button btn_RlegBody "R-Leg Body" align:#center width:80 height:20 tooltip:"Set a free key (BODY space) for the right leg" images:#(imageFile9, undefined, 2, 2, 2, 1, 1)
		)
		group "Store and Toggle Spaces"
		(
			button btn_limbObject "Limb Object" across:2 align:#center width:80 height:18 tooltip:"Set all keys for any selected limbs to OBJECT space" images:#(imageFile23, undefined, 2, 1, 1, 1, 1)
			button btn_storeSpaces "Store Spaces" align:#center width:80 height:18 tooltip:"Temporarily store all limb BODY/OBJECT space settings then set all limb keys to use BODY space" images:#(imageFile24, undefined, 2, 2, 2, 1, 1)
			button btn_limbBody "Limb Body" across:2 align:#center width:80 height:18 tooltip:"Set all keys for any selected limbs to BODY space" images:#(imageFile23, undefined, 2, 2, 2, 1, 1)
			button btn_loadSpaces "Load Spaces" align:#center width:80 height:18 tooltip:"Load all limb BODY/OBJECT space settings based on a previous Store Spaces operation" images:#(imageFile24, undefined, 2, 1, 1, 1, 1)
		)
		
		on btn_bothArmsObject pressed do
		(
			try(biped.setSlidingKey g_LBTools_BH.bHandL) catch()
			try(biped.setSlidingKey g_LBTools_BH.bHandR) catch()
		)
			
		on btn_LarmObject pressed do
		(
			try(biped.setSlidingKey g_LBTools_BH.bHandL) catch()
		)
		
		on btn_LarmBody pressed do
		(
			try(biped.setFreeKey g_LBTools_BH.bHandL) catch()
		)
	
		on btn_bothArmsBody pressed do
		(
			try(biped.setFreeKey g_LBTools_BH.bHandL) catch()
			try(biped.setFreeKey g_LBTools_BH.bHandR) catch()
		)
		
		on btn_RarmObject pressed do
		(
			try(biped.setSlidingKey g_LBTools_BH.bHandR) catch()
		)
		
		on btn_RarmBody pressed do
		(
			try(biped.setFreeKey g_LBTools_BH.bHandR) catch()
		)	
		
		on btn_bothLegsObject pressed do
		(
			try(biped.setSlidingKey g_LBTools_BH.bFootL) catch()
			try(biped.setSlidingKey g_LBTools_BH.bFootR) catch()
		)
			
		on btn_LlegObject pressed do
		(
			try(biped.setSlidingKey g_LBTools_BH.bFootL) catch()
		)
		
		on btn_LlegBody pressed do
		(
			try(biped.setFreeKey g_LBTools_BH.bFootL) catch()
		)
	
		on btn_bothLegsBody pressed do
		(
			try(biped.setFreeKey g_LBTools_BH.bFootL) catch()
			try(biped.setFreeKey g_LBTools_BH.bFootR) catch()
		)
		
		on btn_RlegObject pressed do
		(
			try(biped.setSlidingKey g_LBTools_BH.bFootR) catch()
		)
		
		on btn_RlegBody pressed do
		(
			try(biped.setFreeKey g_LBTools_BH.bFootR) catch()
		)
		
		on btn_storeSpaces pressed do
		(
			try
			(
				g_LBTools_BH.a_storedSpaces = g_LBTools_BH.f_storeSpaces()
			)catch(g_LBTools_BH.f_initBipedParts())
		)

		on btn_loadSpaces pressed do
		(
			try
			(
				g_LBTools_BH.f_loadSpaces g_LBTools_BH.a_storedSpaces
			)catch(g_LBTools_BH.f_initBipedParts())
		)	

		on btn_limbBody pressed do
		(
			try
			(
				g_LBTools_BH.f_limbBody()
			)catch(g_LBTools_BH.f_initBipedParts())
		)
		
		on btn_limbObject pressed do
		(
			try
			(
				g_LBTools_BH.f_limbObject()
			)catch(g_LBTools_BH.f_initBipedParts())
		)
	) --// end rollout
	
	rollout Reference_Rollout "Reference"
	(
		group "Snapshot Skinned Meshes"
		(
			label lbl_sceneLayer "Scene layer to snapshot from:" align:#left
			edittext edtxt_sceneLayer "" align:#center tooltip:"Enter the name of the scene layer containing skinned meshes"
			button btn_snapshot "Snap Current Frame" width:150 height:20 align:#center tooltip:"Creates an combined snapshot of all skinned meshes at the current slider time and makes it unobtrusive in the viewport" images:#(imageFile25, undefined, 1, 1, 1, 1, 1)
			button btn_hideSnapshots "Hide/Unhide" width:80 height:20 across:2 align:#center tooltip:"Hides or unhides the SNAPSHOTS scene layer" images:#(imageFile26, undefined, 2, 1, 1, 1, 1)
			button btn_deleteSnapshots "Delete" width:80 height:20 align:#center tooltip:"Deletes the SNAPSHOTS scene layer and its contents" images:#(imageFile26, undefined, 2, 2, 2, 1, 1)
		)		
		
		on Reference_Rollout open do
		(
			local snapshotLayerName = getIniSetting g_LBTools_BH.bhINIfile "SnapshotLayer" "LayerName"
			if snapshotLayerName == "" do
			(
				setIniSetting g_LBTools_BH.bhINIfile "SnapshotLayer" "LayerName" "*** BLANK ***"
				snapshotLayerName = "*** BLANK ***"
			)
			edtxt_sceneLayer.text = snapshotLayerName
		)
		
		on edtxt_sceneLayer changed val do
		(
			setIniSetting g_LBTools_BH.bhINIfile "SnapshotLayer" "LayerName" val
		)
		
		on btn_snapshot pressed do
		(
			local snapshotLayerName = getIniSetting g_LBTools_BH.bhINIfile "SnapshotLayer" "LayerName" 
			local layerMeshChar = layerManager.getLayerFromName snapshotLayerName
			-- // First make sure the scene layer exists
			if layerMeshChar != undefined then
			(
				--// Collect all nodes from the scene layer
				local a_nodes = #()
				layerMeshChar.nodes &a_nodes
				if a_nodes.count > 0 then
				(
					--// Collect only the skin meshes from the scene layer nodes array
					local a_skinNodes = #()
					for n in a_nodes do
					(
						if (g_LBTools_BH.f_findSkinModifier n) do
						(
							append a_skinNodes n
						)
					)
					if a_skinNodes.count > 0 then
					(
						--// Snapshot and attach all the skin mesh copies
						local snapMesh = snapShot a_skinNodes[1]
						for i = 2 to a_skinNodes.count do
						(
							attach snapMesh (snapshot a_skinNodes[i])
						)
						snapMesh.pivot = snapMesh.center
						-- // Create a new layer if this is the first snapshot
						if LayerManager.getLayerFromName "SNAPSHOTS" == undefined do
						(
							LayerManager.newLayerFromName "SNAPSHOTS"
						)
						-- // Add the new snapshot mesh to the snapshots layer, freeze it and set object properties transparency
						local layerSnapshots = LayerManager.getLayerFromName "SNAPSHOTS"
						layerSnapshots.addNode snapMesh
						freeze snapMesh
						snapMesh.backfacecull = on
						snapMesh.showFrozenInGray = off
						-- // Rename the snapshot mesh and add the slider time frame
						snapMesh.name = ("Snapshot :: " + sliderTime as string)
						-- // Assign a material which has a low opacity and grey colour
						snapMesh.material = meditMaterials[19]
						with Animate off
						(
							meditMaterials[19].Diffuse = color 150 150 150
							meditMaterials[19].ambient = color 150 150 150
							meditMaterials[19].opacity = 20
							meditMaterials[19].name = "See Through"
							snapMesh.wirecolor = color 150 150 150
						)
					)
					else
					(
						messageBox "Error: The snapshots scene layer should contain skinned meshes." title:""
					)
				)
				else
				(
					messageBox "Error: No nodes were found the snapshots scene layer." title:""
				)
			)
			else
			(
				messageBox "Error: Snapshots scene layer not found." title:""
			)
		)
		
		on btn_hideSnapshots pressed do
		(
			local layerSnapshots = layerManager.getLayerFromName "SNAPSHOTS"
			if layerSnapshots != undefined do
			(
				if layerSnapshots.isHidden then
				(
					layerSnapshots.isHidden = false
				)
				else
				(
					layerSnapshots.isHidden = true
				)
			)
		)		
		
		on btn_deleteSnapshots pressed do
		(
			local layerSnapshots = layerManager.getLayerFromName "SNAPSHOTS"
			if layerSnapshots != undefined do
			(
				layerSnapshots.nodes &nodesInLayer
				delete nodesInLayer
				layerManager.deleteLayerByName "SNAPSHOTS"
			)
		)
	) --// end rollout
	
	rollout Baking_Rollout "Baking"
	(
		local bool_head = false, bool_root = true, bool_allLimbs = false, bool_both = false, bool_selLimbs = false, bool_nextSlideKey = false, bool_lastSlideKey = false
		local a_limbSel = #() --// Used by the selected limb toggles on the interface
		
		group "Mode Select"
		(
			radiobuttons rbtns_head "" labels:#("Head (to Look At Target)") align:#left default:0 tooltip:#("Bake keys onto the head based on an assigned Look At Target and removes the target object")
			radiobuttons rbtns_rootLimbsBoth labels:#("Root", "All Limbs", "Both") align:#left default:1 offsets:#([0,0],[2,0],[2,0]) tooltip:#("Bake keys on the root bone across the full time range", "Bake keys on all limbs based on Object bindings", "Bake keys on both the root bone and all limbs")
			radiobuttons rbtns_selLimbs labels:#("Selected Limbs:") columns:1 align:#left default:0 tooltip:"Allow specific limb selection for baking keys"
			checkbutton chkbtn_leftHand "L Hand" width:60 height:25 offset:[10,0] across:2 align:#center enabled:false tooltip:"Bake keys on the left hand between sliding keys" images:#(imageFile28, undefined, 6, 1, 5, 3, 3)
			checkbutton chkbtn_rightHand "R Hand" width:60 height:25 offset:[-10,0] align:#center enabled:false tooltip:"Bake keys on the right hand between sliding keys" images:#(imageFile28, undefined, 6, 2, 6, 4, 4)
			checkbutton chkbtn_leftFoot "L Foot" width:60 height:25 offset:[10,0] across:2 align:#center enabled:false tooltip:"Bake keys on the left foot between sliding keys" images:#(imageFile29, undefined, 6, 1, 5, 3, 3)
			checkbutton chkbtn_rightFoot "R Foot" width:60 height:25 offset:[-10,0] align:#center enabled:false tooltip:"Bake keys on the right foot between sliding keys" images:#(imageFile29, undefined, 6, 2, 6, 4, 4)
			label lbl_note1 "On a single selected limb starting" align:#left
			label lbl_note2 "from the slider time..." align:#left
			radiobuttons rbtns_nextSlideKey labels:#("Up to the NEXT sliding key") columns:1 align:#left default:0 tooltip:"Bake keys on a single selected limb from the first sliding key found to the next sliding key found (within range)"
			radiobuttons rbtns_lastSlideKey labels:#("Up to the LAST sliding key") columns:1 align:#left default:0 tooltip:"Bake keys on a single selected limb from the first sliding key found to the last sliding key (within range)"
		)
		group "Process"
		(
			button btn_bakeAnimKeys "Bake Animation Keys" width:160 height:25 align:#center tooltip:"Bake animation keys based on the mode selection above" images:#(imageFile27, undefined, 1, 1, 1, 1, 1)
		)
		
		on rbtns_head changed state do
		(
			if state == 1 do
			(
				bool_head = true
				bool_root = false; bool_allLimbs = false; bool_both = false; rbtns_rootLimbsBoth.state = 0; rbtns_selLimbs.state = 0; bool_selLimbs = false; bool_nextSlideKey = false; rbtns_nextSlideKey.state = 0; rbtns_lastSlideKey.state = 0
				chkbtn_leftHand.enabled = false; chkbtn_rightHand.enabled = false; chkbtn_leftFoot.enabled = false; chkbtn_rightFoot.enabled = false
				chkbtn_leftHand.state = false; chkbtn_rightHand.state = false; chkbtn_leftFoot.state = false; chkbtn_rightFoot.state = false
				a_limbSel = #()
			)
		)
		
		on rbtns_rootLimbsBoth changed state do
		(
			bool_head = false; rbtns_head.state = 0
			case rbtns_rootLimbsBoth.state of
			(
				1:(bool_root = true; bool_allLimbs = false; bool_both = false; bool_selLimbs = false; rbtns_selLimbs.state = 0; bool_nextSlideKey = false; rbtns_nextSlideKey.state = 0; rbtns_lastSlideKey.state = 0
					chkbtn_leftHand.enabled = false; chkbtn_rightHand.enabled = false; chkbtn_leftFoot.enabled = false; chkbtn_rightFoot.enabled = false
					chkbtn_leftHand.state = false; chkbtn_rightHand.state = false; chkbtn_leftFoot.state = false; chkbtn_rightFoot.state = false
					a_limbSel = #())
				2:(bool_root = false; bool_allLimbs = true; bool_both = false; bool_selLimbs = false; rbtns_selLimbs.state = 0; bool_nextSlideKey = false; rbtns_nextSlideKey.state = 0; rbtns_lastSlideKey.state = 0
					chkbtn_leftHand.enabled = false; chkbtn_rightHand.enabled = false; chkbtn_leftFoot.enabled = false; chkbtn_rightFoot.enabled = false
					chkbtn_leftHand.state = false; chkbtn_rightHand.state = false; chkbtn_leftFoot.state = false; chkbtn_rightFoot.state = false
					a_limbSel = #())
				3:(bool_root = false; bool_allLimbs = false; bool_both = true; bool_selLimbs = false; rbtns_selLimbs.state = 0; bool_nextSlideKey = false; rbtns_nextSlideKey.state = 0; rbtns_lastSlideKey.state = 0
					chkbtn_leftHand.enabled = false; chkbtn_rightHand.enabled = false; chkbtn_leftFoot.enabled = false; chkbtn_rightFoot.enabled = false
					chkbtn_leftHand.state = false; chkbtn_rightHand.state = false; chkbtn_leftFoot.state = false; chkbtn_rightFoot.state = false
					a_limbSel = #())
			)
		)
		
		on rbtns_selLimbs changed state do
		(
			if state == 1 do
			(
				bool_head = false; rbtns_head.state = 0
				bool_root = false; bool_allLimbs = false; bool_both = false; rbtns_rootLimbsBoth.state = 0; bool_selLimbs = true; bool_nextSlideKey = false; rbtns_nextSlideKey.state = 0; rbtns_lastSlideKey.state = 0
				chkbtn_leftHand.enabled = true; chkbtn_rightHand.enabled = true; chkbtn_leftFoot.enabled = true; chkbtn_rightFoot.enabled = true
				chkbtn_leftHand.state = false; chkbtn_rightHand.state = false; chkbtn_leftFoot.state = false; chkbtn_rightFoot.state = false
				a_limbSel = #()
			)
		)

		on rbtns_nextSlideKey changed state do
		(
			if state == 1 do
			(
				bool_head = false; rbtns_head.state = 0
				bool_root = false; bool_allLimbs = false; bool_both = false; rbtns_rootLimbsBoth.state = 0; bool_selLimbs = false; rbtns_selLimbs.state = 0; rbtns_lastSlideKey.state = 0; bool_nextSlideKey = true; bool_lastSlideKey = false
				chkbtn_leftHand.enabled = false; chkbtn_rightHand.enabled = false; chkbtn_leftFoot.enabled = false; chkbtn_rightFoot.enabled = false
				chkbtn_leftHand.state = false; chkbtn_rightHand.state = false; chkbtn_leftFoot.state = false; chkbtn_rightFoot.state = false
				a_limbSel = #()
			)
		)

		on rbtns_lastSlideKey changed state do
		(
			if state == 1 do
			(
				bool_head = false; rbtns_head.state = 0
				bool_root = false; bool_allLimbs = false; bool_both = false; rbtns_rootLimbsBoth.state = 0; bool_selLimbs = false; rbtns_selLimbs.state = 0; rbtns_nextSlideKey.state = 0; bool_nextSlideKey = false; bool_lastSlideKey = true;
				chkbtn_leftHand.enabled = false; chkbtn_rightHand.enabled = false; chkbtn_leftFoot.enabled = false; chkbtn_rightFoot.enabled = false
				chkbtn_leftHand.state = false; chkbtn_rightHand.state = false; chkbtn_leftFoot.state = false; chkbtn_rightFoot.state = false
				a_limbSel = #()
			)
		)
		
		on chkbtn_leftHand changed state do
		(
			if state == on do
			(
				append a_limbSel g_LBTools_BH.bHandL
			)
			if state == off do
			(
				local item = findItem a_limbSel g_LBTools_BH.bHandL
				if item != 0 do
				(
					deleteItem a_limbSel item
				)
			)
		)

		on chkbtn_rightHand changed state do
		(
			if state == on do
			(
				append a_limbSel g_LBTools_BH.bHandR
			)
			if state == off do
			(
				local item = findItem a_limbSel g_LBTools_BH.bHandR
				if item != 0 do
				(
					deleteItem a_limbSel item
				)
			)
		)

		on chkbtn_leftFoot changed state do
		(
			if state == on do
			(
				append a_limbSel g_LBTools_BH.bFootL
			)
			if state == off do
			(
				local item = findItem a_limbSel g_LBTools_BH.bFootL
				if item != 0 do
				(
					deleteItem a_limbSel item
				)
			)
		)

		on chkbtn_rightFoot changed state do
		(
			if state == on do
			(
				append a_limbSel g_LBTools_BH.bFootR
			)
			if state == off do
			(
				local item = findItem a_limbSel g_LBTools_BH.bFootR
				if item != 0 do
				(
					deleteItem a_limbSel item
				)
			)
		)

		on btn_bakeAnimKeys pressed do
		(
			if isValidNode g_LBTools_BH.bRoot AND NOT isDeleted g_LBTools_BH.bRoot then
			(
				undo "Biped Bake" on
				(
					if bool_head do
					(
						g_LBTools_BH.f_bipedBakeHead()
					)
					
					if bool_root do
					(
						if isValidNode g_LBTools_BH.bRoot.parent do
						(
							g_LBTools_BH.f_bipedBakeRoot()
						)
					)
					
					if bool_allLimbs do
					(
						g_LBTools_BH.f_bipedBakeSlidingKeys #(g_LBTools_BH.bHandL, g_LBTools_BH.bHandR, g_LBTools_BH.bFootL, g_LBTools_BH.bFootR)
					)
					
					if bool_both do
					(
						if isValidNode g_LBTools_BH.bRoot.parent do
						(
							g_LBTools_BH.a_storedSpaces = g_LBTools_BH.f_storeSpaces()
							g_LBTools_BH.f_bipedBakeRoot()
							g_LBTools_BH.f_loadSpaces g_LBTools_BH.a_storedSpaces
						)
						g_LBTools_BH.f_bipedBakeSlidingKeys #(g_LBTools_BH.bHandL, g_LBTools_BH.bHandR, g_LBTools_BH.bFootL, g_LBTools_BH.bFootR)
					)
					
					if bool_selLimbs do
					(
						if a_limbSel.count != 0 then
						(
							g_LBTools_BH.f_bipedBakeSlidingKeys a_limbSel
						)
						else
						(
							messageBox "Error: Click one or more limb buttons to process."
						)
					)
					
					if bool_nextSlideKey do
					(
						if selection.count == 1 then
						(
							local obj = selection[1]
							if isValidNode obj then
							(
								local index = findItem g_LBTools_BH.a_bipedLimbs obj
								if index != 0 then
								(
									g_LBTools_BH.f_bipedBakeSlidingKeyNext()
								)
								else
								(
									messageBox "Error: Select a single Biped limb with at least two sliding keys after the slider time." title:""
								)
							)
							else
							(
								messageBox "Error: Object selected is not valid." title:""
							)
						)
						else
						(
							messageBox "Error: Select a single Biped limb with at least two sliding keys after the slider time." title:""
						)
					)
					
					if bool_lastSlideKey do
					(
						if selection.count == 1 then
						(
							local obj = selection[1]
							if isValidNode obj then
							(
								local index = findItem g_LBTools_BH.a_bipedLimbs obj
								if index != 0 then
								(
									g_LBTools_BH.f_bipedBakeSlidingKeyLast()
								)
								else
								(
									messageBox "Error: Select a single Biped limb with at least two sliding keys after the slider time." title:""
								)
							)
							else
							(
								messageBox "Error: Object selected is not valid." title:""
							)
						)
						else
						(
							messageBox "Error: Select a single Biped limb with at least two sliding keys after the slider time." title:""
						)
					)
				)
			)
			else
			(
				g_LBTools_BH.f_missingBipedError()			
			)
		)
	) --// end rollout
	
	rollout About_Rollout "About"
	(
		local imagePDF = g_LBTools_rootPath + "\LBTools_PDF_Image.bmp"
		
		label lbl_author "Author - Lorne Brooks"
		hyperLink myEmail "lbtools2k@gmail.com" across:2 align:#center offset:[30,10] color:(color 0 0 255) hovercolor:(color 0 0 190) visitedcolor:(color 190 0 0) align:#center address:"mailto:lbtools2k@gmail.com"
		button btn_pdf "" align:#right offset:[-10,0] images:#(imagePDF, undefined, 1, 1, 1, 1, 1, false) tooltip:"Opens a PDF explaining the tool features."
		label lbl_version "Version 2.4 - 10 May 2020"
		
		on btn_pdf pressed do
		(
			local file_PDF =g_LBTools_rootPath+ "\LBTools_Biped_Helper.pdf"
			shellLaunch file_PDF ""
		)
	) --// end rollout
	
	fn f_openBipedUI =
	(
		g_LBTools_BH.BH_pos = mouse.screenpos + [-75,-15]
		if NOT (doesFileExist g_LBTools_BH.bhINIfile) then
		(
			setIniSetting g_LBTools_BH.bhINIfile "Floater" "Position" (g_LBTools_BH.BH_pos as string)
			setIniSetting g_LBTools_BH.bhINIfile "BipedPanel" "CurrentBip" "1"
			g_LBTools_BH.f_openBipedUI()
		)
		else
		(
			if NOT (hasIniSetting g_LBTools_BH.bhINIfile "Floater" "Position") do
			(
				setIniSetting g_LBTools_BH.bhINIfile "Floater" "Position" (g_LBTools_BH.BH_pos as string)
			)
			g_LBTools_BH.a_bips = #()
			g_LBTools_BH.f_collectBipRoots()
			if g_LBTools_BH.a_bips.count > 0 then
			(
				--// Floater definition
				try(closeRolloutFloater g_LBTools_BH.bipedUI_Floater)catch()
				g_LBTools_BH.bipedUI_Floater = newRolloutFloater "Biped Helper" 205 700
				g_LBTools_BH.BH_pos = execute(getIniSetting g_LBTools_BH.bhINIfile "Floater" "Position")
				g_LBTools_BH.bipedUI_Floater.pos = g_LBTools_BH.BH_pos
				addRollout g_LBTools_BH.SelectDisplayKeys_Rollout g_LBTools_BH.bipedUI_Floater rolledup:false
				addRollout g_LBTools_BH.LimbSpaces_Rollout g_LBTools_BH.bipedUI_Floater rolledup:true
				addRollout g_LBTools_BH.QuickPosture_Rollout g_LBTools_BH.bipedUI_Floater rolledup:true
				addRollout g_LBTools_BH.PoseGrabber_Rollout g_LBTools_BH.bipedUI_Floater rolledup:true
				addRollout g_LBTools_BH.Reference_Rollout g_LBTools_BH.bipedUI_Floater rolledup:true
				addRollout g_LBTools_BH.Baking_Rollout g_LBTools_BH.bipedUI_Floater rolledup:true
				addRollout g_LBTools_BH.About_Rollout g_LBTools_BH.bipedUI_Floater rolledup:true
			)
			else
			(
				messageBox "Error: No Biped's found in the scene. Add a Biped and try again." title:""
				setIniSetting g_LBTools_BH.bhINIfile "BipedPanel" "CurrentBip" "1"
				try(closeRolloutFloater g_LBTools_BH.bipedUI_Floater)catch()
			)
		)
	)
	
	g_LBTools_BH.f_openBipedUI()
) --// end function

) --// end struct

g_LBTools_BH = s_LBTools_bipedHelper()


/*********************************************************************************************************************************************************************/
--// MACRO CALLS FOR UI
/*********************************************************************************************************************************************************************/

/*macroScript bipedHelper
	category:"LB Tools"
	buttontext:"Biped Helper 2.4"
	icon:#("LBTools_BipedHelper",1)
	tooltip:"Biped Helper 2.4"
(*/
	g_LBTools_BH.f_bipedUI()
/*)*/

/*********************************************************************************************************************************************************************/