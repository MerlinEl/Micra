/*************************************************************************************
Chain Rigger
	
Author:Mayec Rancel
http://www.mayec.eu

Script Version:	1.2

created: 2010-05-01
last update: 2010-09-30

Tested for Max Versions: 	max2010 x64.

DESCRIPTION:
This tool creates a simulation rig for a chain (free or constrained) with a few simple steps.
The rig is an optimized one, very stable and fast to simulate, based on a reactor rope.

Known Bugs:

To Do:
	- check if setup is already applied before applying again
	
Improvement Ideas:
	- possibility to create/extend/shrink chain by adding/removing lengths.
*************************************************************************************/

-- SCRIPT NAME & VERSION
scriptName = "Chain Rigger"
scriptVersion = "1.2"

-- default Reactor Rope Parameters
linkMass = 0.001
chainThickness = 0.3
chainFriction = 0.1
chainAirResist = 0.04

-- Init variables
EOCname = "end_of_chain"
chainLinkName = "chain_link*"
chainLinks = #()

-- Initialize links-count dependent variables with defaults
locatorSize = 1
chainMass = 1

fn compareObjNames o1 o2 =
	case of (
		(o1.name < o2.name): -1
		(o1.name > o2.name): 1
		default: 0
	)
	
fn getLinks linkName = (
	chainLinks = execute ("$" +  linkName)
	if chainLinks != undefined then
	(
		chainLinks = chainLinks as array
		qsort chainLinks compareObjNames
	)
	else
		chainLinks = #()
)

getLinks chainLinkName
--chainMass = linkMass * chainLinks.count
	
fn rigChain constraintMode parentMesh: = ()

fn placeEnd locatorSize = (
	-- Calculate where endOfChain knot should go
	links = chainLinks.count
	linkLength = chainLinks[links].pos - chainLinks[links-1].pos
	lastPos = chainLinks[links].pos + linkLength
	
	-- if Chain End locator already exists, delete it
	if (getNodeByName EOCname != undefined) then
		delete (getNodeByName EOCname)
		
	endOfChain = point()
	endOfChain.name = EOCname
	endOfChain.size = locatorSize
	endOfChain.pos = lastPos
	select endOfChain
	max move
	
	completeRedraw()	
)


rollout rollChainRigger (scriptName + " " + scriptVersion) width:204 height:352
(
	
	-- pre-declare updateLinks function
	local updateLinks
	
	edittext  txtLinksName "Link Name:" text:chainLinkName pos:[10,10] width:144 across:2
	
	pickButton btnPickName "pick"  pos:[160,8]
	on btnPickName picked pickedNode do
	(
		newName = (filterString pickedNode.name "1234567890")
		txtLinksName.text = (newName[1] + "*")
		getLinks txtLinksName.text
		updateLinks()
	)
	edittext txtLinksReport readOnly:true pos:[45,40] width:105 height:25 text:( "match: " + (chainLinks.count as string) + " links")
	
	button btnEndLoc "place Chain End" pos:[54,75]
	on btnEndLoc pressed do placeEnd locatorSize
	
	groupBox grpConstraints "Constraints" pos:[6,103] width:192 height:91
	radiobuttons rdoConstraints "" pos:[25,123] width:75 height:62 labels:#("start", "end", "both", "none") default:4
	pickButton btnStart "Pick Start Obj" pos:[95,127] width: 80 enabled: false
	on btnStart picked obj do
		( if obj != undefined do (btnStart.text = obj.name) )
	pickButton btnEnd "Pick End Obj" pos:[95,157] width: 80 enabled: false
	on btnEnd picked obj do
		( if obj != undefined do (btnEnd.text = obj.name) )
	on rdoConstraints changed newSetting do
	(
		case newSetting of
		(
			1: (
				btnStart.enabled = true
				btnEnd.enabled = false
			)
			2: (
				btnStart.enabled = false
				btnEnd.enabled = true
			)
			3: (
				btnStart.enabled = true
				btnEnd.enabled = true
			)
			4: (
				btnStart.enabled = false
				btnEnd.enabled = false
			)
		)
	)

	groupBox grpReactor "Reactor" pos:[6,204] width:192 height:71
	spinner spnLinkMass "link mass" pos:[32,222] width:135 height:16 range:[-999999,999999,linkMass]
	spinner spnChainMass "chain mass" pos:[36,246] width:131 height:16 range:[-999999,999999,chainMass]
	on spnLinkMass changed newValue do
		spnChainMass.value = newValue * chainLinks.count
	on spnChainMass changed newValue do
	(
		if chainLinks.count > 1 do
			spnLinkMass.value = newValue / chainLinks.count
	)

	button btnGo "Rig it!" pos:[63,295] width:78 height:25
	on btnGo pressed do
	(
		getLinks txtLinksName.text
		
		-- ERROR CHECKS
		-- check that all necessary constraint objects have been picked
		if ( (rdoConstraints.state == 1 or rdoConstraints.state == 3) and (btnStart.object == undefined) ) then
			messageBox "You have to pick a Start Constraint Object, or choose Constraints 'none' "
		else if ( (rdoConstraints.state == 2 or rdoConstraints.state == 3) and (btnEnd.object == undefined) ) then
			messageBox "You have to pick an End Constraint Object, or choose Constraints 'none' "
		-- check that there are at least two valid chain links
		else if (chainLinks.count < 2) then
			messageBox ("There are not enough links with name \"" + txtLinksName.text + "\" (need at least 2)")
		
		-- IF NO ERRORS, PROCEED
		else
		(
			-- launch main Chain Rigging function
			( rigChain rdoConstraints.state )
		)
			
	)
	
	button btnAbout "about" pos:[155,327] width:45 height:20
	on btnAbout pressed do
		(
			messagebox (
				"\"" + scriptName + " v" + scriptVersion + "\"\n\n"+
				"This tool creates a simulation rig for a chain (free or constrained) with a few simple steps. The rig is an optimized one, very stable and fast to simulate, based on a reactor rope.\n\n"+
				"Notes:\n"+
				"  - Due to the optimized natures of the rig, it is more suited for certain types of chains (eg, the ball-joint chain in the example scene). For other types (like the usual ring-linked chain), if the rings are loose, the simulation may not have the needed freedom between links. In such cases, a brute-force all-rigid-bodies solution may be needed for a more realistic (although much slower and potentially unstable) simulation.\n"+
				"  - By default, the rigged chain will not collide with the constraining objects. But since it is using reactor, you can add any rigid bodies, constraints or any other entities to your simulation.\n"+
				"  - This tool can rig a chain that has been modeled/placed in a specific position, or it can rig it in a neutral straight shape, and then bring it to a natural position with a simulation runup (and tricks like colliding objects to shape it, if you need a specific shape).\n"+
				"\nVersion: "+scriptVersion as string+"\n\nCreated by Mayec Rancel \nhttp://www.mayec.eu"
			)
		)
	
	
	on txtLinksName changed newName do
	(
		getLinks newName
		updateLinks()
	)
	
	-- if chain links name is not yet valid, disable buttons that depend on links count
	on rollChainRigger open do
	(
		getLinks txtLinksName.text
		updateLinks()
		if chainLinks.count < 2 then
		(
			btnEndLoc.enabled = false
			spnLinkMass.enabled = false
		)
	)
	
	-- This function updates the rollout according to link name
	fn updateLinks = (
		txtLinksReport.text = ( "match: " + (chainLinks.count as string) + " links")
		
		if chainLinks.count > 1 then
		(
			-- calculate a locatorSize appropriate for the links' sizes
			links = chainLinks.count
			linkLength = length (chainLinks[links].pos - chainLinks[links-1].pos)
			locatorSize = linkLength
			-- enable buttons dependent on links' count
			btnEndLoc.enabled = true
			spnLinkMass.value = spnChainMass.value / chainLinks.count
			spnLinkMass.enabled = true
		)
		else
		(
			-- enable buttons dependent on links' count
			btnEndLoc.enabled = false
			spnLinkMass.enabled = false
		)
	)

)


-- FUNCTION: If target is not an Editable_Mesh, make it so
fn sel2editMesh target = (
	if (classOf target != Editable_Mesh) do (
		addModifier target (Edit_Mesh())
	)
)


-- FUNCTION: places locator referenced to "parentObject", using "method". optional: specify a vertex number.
fn placeLocator parentObject method vertNumber = (
	-- Create locator Point Dummy, and name it "locator_#"
	locator=Point()
	locator.name = uniquename "locator"
	-- Change locator's position controller to Position List
	locator.pos.controller = position_List ()
	-- Add Position Script to available Position controller
	locator.pos.available.controller = position_Script ()
	-- Place locator, depending on "method" chosen
	-- Make parenObject an Edit_mesh (if not already one), to allow use of "getVert"
	sel2editMesh parentObject
	-- Assign script to Position_Script controller: takes position from vertex # of parentObject
	cmdstring = "getVert $" + parentObject.name + " " + (vertNumber as string)
	locator.pos.controller[2].setExpression cmdstring
	return locator
)

-- MAIN FUNCTION
fn rigChain constraintMode = (

undo scriptName on
(
	chainLocators = #()	

	-- If an End Of Chain locator has not been created, create it
	if (getNodeByName EOCname == undefined) then
		placeEnd locatorSize
	
	endLocator = getNodeByName EOCname
	
	-- STEP
	-- create a spline with one vertex on each chains pieces' pivot
	-- chainSpline = splineShape pos:[0,0,0]
	chainSpline = splineShape()
	chainSpline.name = "chainSpline"
	addNewSpline chainSpline
	-- add vertices to spline at each chains object 
	for i = 1 to chainLinks.count do (
		addKnot chainSpline 1 #corner #line chainLinks[i].pivot
	)
	--add endOfChain vertex, then delete locator
	addKnot chainSpline 1 #corner #line endLocator.pivot
	delete endLocator
	
	updateShape chainSpline
	chainSpline.optimize = false
	chainSpline.steps = 0
	
	-- STEP
	-- poner rope a spline y configurar reactor
	addModifier chainSpline (reactor_Rope())
	chainSpline.modifiers[1].mass = rollChainRigger.spnChainMass.value
	chainSpline.modifiers[1].thickness = chainThickness
	chainSpline.modifiers[1].friction = chainFriction
	chainSpline.modifiers[1].airResistance = chainAirResist
	chainSpline.modifiers[1].avoidSelfIntersections = true
	chainSpline.modifiers[1].type = 1
	
	-- Constrain to dog's neck
	if ( constraintMode == 1 or constraintMode == 3 ) then
	(
		chainSpline.modifiers[1].addAttachToRigidBodyConstraint()
		chainSpline.modifiers[1].arb_rigidBody = rollChainRigger.btnStart.object
		
		-- FOLLOWING 3 LINES make the vertex selection work. Otherwise it won't (DON'T KNOW WHY!)
		setCommandPanelTaskMode #modify
		getCommandPanelTaskMode()
		forceCompleteRedraw doDisabled:true
		
		chainSpline.modifiers[1].currentVertexSelection = #{1}
	)
	
	
	-- Constrain to stake
	if (constraintMode == 2 or constraintMode == 3 ) then
	(
		chainSpline.modifiers[1].addAttachToRigidBodyConstraint()
		chainSpline.modifiers[1].currentConstraintIndex = 2
		chainSpline.modifiers[1].arb_rigidBody = rollChainRigger.btnEnd.object
		
		-- FOLLOWING 3 LINES make the vertex selection work. Otherwise it won't (DON'T KNOW WHY!)
		setCommandPanelTaskMode #modify
		getCommandPanelTaskMode()
		forceCompleteRedraw doDisabled:true
		
		chainSpline.modifiers[1].currentVertexSelection = #{numKnots chainSpline}
	)
	
	ropeCol = RPCollection()
	ropeCol.pos = chainLinks[1].pos + [0,0,11]
	ropeCol.addRope chainSpline
	
	-- CONSTRAINT RIGID BODIES
	-- if using constraints, add rigid bodies collection
	if ( constraintMode != 4 ) then (
		-- añadir chainFixation a reactor
		RBCol = RBCollection()
		RBCol.pos = chainLinks[1].pos + [5,0,11]
	)
	-- Add dog's neck to RBCollection if option was selected
	if ( constraintMode == 1 or constraintMode == 3 ) then
	(
		RBCol.addRigidBody rollChainRigger.btnStart.object
		RBindex = RBCol.GetNumRigidBodies()
		theRB = RBCol.getRigidObject RBindex
		theRB.unyielding = true
		theRB.disableAllCollisions = true
	)
	-- Add stake to RBCollection if option was selected
	if ( constraintMode == 2 or constraintMode == 3 ) then
	(
		RBCol.addRigidBody rollChainRigger.btnEnd.object
		RBindex = RBCol.GetNumRigidBodies()
		theRB = RBCol.getRigidObject RBindex
		theRB.unyielding = true
		theRB.disableAllCollisions = true
	)

	-- set reactor simulation
	reactor.startFrame = animationRange.start
	reactor.endFrame = animationRange.end
	reactor.substeps = 20
	reactor.collisionTolerance = 0.5

	-- STEP
	-- rivet locators to every vertex of the spline
	for i = 1 to (chainLinks.count + 1) do (
		theLocator = placeLocator chainSpline 4 i
		theLocator.name = "chainLocator" + i as string
		theLocator.size = locatorSize
		append chainLocators theLocator
	) 

	-- STEP
	-- Set constraints on chain link objects
	for i = 1 to chainLinks.count do (
		
		-- constrain link position
		chainLinks[i].pos.controller = Position_Constraint()
		theCont = chainLinks[i].pos.controller
		theCont.appendTarget chainLocators[i] 100

		-- constrain link rotation (except for last link - since there's no locator to lookAt)
--		if i < chainLinks.count then (
			chainLinks[i].rotation.controller = LookAt_Constraint()
			theCont = chainLinks[i].rotation.controller
			theCont.appendTarget chainLocators[i+1] 100
			theCont.target_axisFlip = true
			theCont.lookat_vector_length = 0
			theCont.upnode_ctrl = 0
			theCont.relative = on
--		)
	)
) -- end 'undo on'

	destroyDialog rollChainRigger
)
-- End Main Function

createDialog rollChainRigger