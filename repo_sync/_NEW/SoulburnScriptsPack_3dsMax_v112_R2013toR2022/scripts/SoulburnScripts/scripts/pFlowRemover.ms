-------------------------------------------------------------------------------
-- pFlowRemover.ms
-- By Neil Blevins (info@neilblevins.com)
-- v 1.00
-- Created On: 04/10/13
-- Modified On: 04/11/13
-- tested using Max 2011
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Required Files:
-- sLib.ms
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Description:
-- Even after deleting a PFlow Source object from your scene, you can 
-- sometimes end up with cruft nodes that are invisible to you, but exist in 
-- your scene, and can be viewed if you try and merge your current scene into 
-- a fresh scene. This scene flushes all of those nodes out of the scene. Also
-- includes some tools for finding and printing out the nodes in case you need 
-- to delete them by hand.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Tutorial:
-- Open a scene with pflow in it. Run the UI version of the script. Hit Do. Pflow
-- and all of its extra nodes have been deleted from the scene.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Known Issues:
-- This deletes all of the standard PFlow nodes, but won't find extra nodes
-- created by pFlow Box 1, 2 or 3. 
-- Also, the script will only delete pflow nodes 100% reliably in a standard 
-- max install. If you have a lot of 3rd party plugins, it is possible, although 
-- highly unlikely, that this script may delete a scene object its not supposed 
-- to. So it may be worth it to check your scene before and after running the 
-- script to make sure everything is still happy.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
(
-- Globals

global pFlowRemover
global pFlowRemoverDefaults
global pFlowRemoverUI

global pFRCloseOpenUI

global pFRDo
global pFRApply
global pFRHelp
global pFRLoadDef
global pFRSaveDef

global pFRDefineUI
global pFRRollout
global pFRFloater

-- Includes

include "$scripts\SoulburnScripts\lib\sLib.ms"

-- Variables

pFRActionValue = 4
pFRPosValue = [400,400]

-- Functions

fn pFlowRemover pFRAction = 
	(
	undo "pFlowRemover" on
		(
		max select none
		todelete = #()
		for i in $* do 
			(
			-- Operators
			if classof i == Birth then append todelete i
			else if classof i == Birth_Paint then append todelete i
			else if classof i == Birth_Script then append todelete i
			else if classof i == Birth_Texture then append todelete i
			else if classof i == Initial_State then append todelete i
			else if classof i == DeleteParticles then append todelete i
			else if classof i == Force then append todelete i
			else if classof i == Group_Operator then append todelete i
			else if classof i == Group_Select then append todelete i
			else if classof i == Keep_Apart then append todelete i

			else if classof i == mapping then append todelete i
			else if classof i == Mapping_Object then append todelete i
			else if classof i == Material_Dynamic then append todelete i
			else if classof i == Material_Frequency then append todelete i
			else if classof i == Material_Static then append todelete i
			else if classof i == Placement_Paint then append todelete i
			else if classof i == Position_Icon then append todelete i
			else if classof i == Position_Object then append todelete i
			else if classof i == rotation then append todelete i			
			else if classof i == ScaleParticles then append todelete i
			else if classof i == Script_Operator then append todelete i
			else if classof i == ShapeLibrary then append todelete i
			else if classof i == Shape_Facing then append todelete i				

			else if classof i == Shape_Instance then append todelete i
			else if classof i == Shape_Mark then append todelete i
			else if classof i == speed then append todelete i
			else if classof i == SpeedByIcon then append todelete i
			else if classof i == Speed_By_Surface then append todelete i
			else if classof i == spin then append todelete i
			else if classof i == Age_Test then append todelete i
			else if classof i == Collision then append todelete i
			else if classof i == Collision_Spawn then append todelete i			
			else if classof i == Find_Target then append todelete i
			else if classof i == Go_To_Rotation then append todelete i
			else if classof i == Lock_Bond then append todelete i
			else if classof i == Scale_Test then append todelete i

			else if classof i == Script_Test then append todelete i
			else if classof i == Send_Out then append todelete i
			else if classof i == Spawn then append todelete i
			else if classof i == Speed_Test then append todelete i
			else if classof i == Split_Amount then append todelete i
			else if classof i == Split_Group then append todelete i
			else if classof i == Split_Selected then append todelete i
			else if classof i == Split_Source then append todelete i
			else if classof i == Cache then append todelete i
			else if classof i == DisplayParticles then append todelete i
			else if classof i == Notes then append todelete i
			else if classof i == RenderParticles then append todelete i
			-- Flow
			else if classof i == PF_Source then append todelete i
			else if classof i == Event then append todelete i
			-- misc
			else if classof i == PFEngine then append todelete i
			else if classof i == ParticleGroup then append todelete i
			-- scene object
			else if classof i == Particle_View then append todelete i
			)
		thingsDeleted = 0
		print ("pFlowRemover found " + (todelete.count as string) + " pFlow related nodes in your scene")
		if pFRAction == 2 then
			(
			print todelete
			)
		if pFRAction == 3 then
			(
			select todelete
			)
		if pFRAction == 4 then
			(
			for o in todelete do 
				(
				try 
					(
					delete o
					thingsDeleted += 1
					)
				catch ()
				)
			print ("pFlowRemover deleted " + (thingsDeleted as string) + " pFlow related nodes in your scene")
			)
		)
	)
	
fn pFlowRemoverDefaults = 
	(
	pFRLoadDef()
	pFlowRemover pFRActionValue
	)
	
fn pFlowRemoverUI = 
	(
	pFRLoadDef()
	pFRCloseOpenUI pFRPosValue
	)

fn pFRCloseOpenUI pos = 
	(
	if pFRFloater != undefined then CloseRolloutFloater pFRFloater
	pFRDefineUI()
	pFRFloater = newRolloutFloater "pFlowRemover v1.00" 310 91 pos.x pos.y
	addRollout pFRRollout pFRFloater
	)

fn pFRDo = 
	(
	pFlowRemover pFRActionValue
	if pFRFloater != undefined then CloseRolloutFloater pFRFloater
	)

fn pFRApply = 
	(
	pFlowRemover pFRActionValue
	)
	
fn pFRHelp = 
	(
	sLibSSPrintHelp "pFlowRemover"
	)
	
fn pFRLoadDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	pFRInputFilename = presetDir + "pFlowRemover.ini"
	if (sLibFileExist pFRInputFilename == true) then
		(
		pFRActionValue = execute (getINISetting pFRInputFilename "pFlowRemover" "pFRActionValue")
		pFRPosValue = execute (getINISetting pFRInputFilename "pFlowRemover" "pFRPosValue")
		
		if pFRActionValue == OK then pFRActionValue = 4
		if pFRPosValue == OK then pFRPosValue = [400,400]
		)
	else
		(
		pFRActionValue = 4
		pFRPosValue = [400,400]
		)
	)
	
fn pFRSaveDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	if (getDirectories presetDir).count == 0 then makeDir presetDir
	pFROutputFilename = presetDir + "pFlowRemover.ini"
	if (sLibFileExist pFROutputFilename == true) then deleteFile pFROutputFilename
	setINISetting pFROutputFilename "pFlowRemover" "pFRActionValue" (pFRActionValue as string)
	setINISetting pFROutputFilename "pFlowRemover" "pFRPosValue" (pFRFloater.pos as string)
	)

-- UI

fn pFRDefineUI = 
	(
	rollout pFRRollout "pFlowRemover"
		(
		label label1 "Action:" pos:[10,10]
		dropdownlist pFRActionDropdown "" items:#("Find All Pflow Nodes In Scene", "Print All Pflow Nodes In Scene", "Select All Pflow Nodes In Scene", "Remove All Pflow Nodes From Scene") selection:pFRActionValue pos:[50,7] width:237
		on pFRActionDropdown selected i do pFRActionValue = i

		button pFRDoButton "Do" width:70 toolTip:"Do It and Close UI" pos:[5,34]
		on pFRDoButton pressed do pFRDo()
		button pFRApplyButton "Apply" width:70 toolTip:"Do It and Keep UI Open" pos:[77,34]
		on pFRApplyButton pressed do pFRApply()
		button pFRHelpButton "Help" width:70 toolTip:"Help" pos:[149,34]
		on pFRHelpButton pressed do pFRHelp()
		button pFRSaveDefButton "SaveDef" width:70 toolTip:"Save Current Settings as Default" pos:[221,34]
		on pFRSaveDefButton pressed do pFRSaveDef()
		)
	)
)
-------------------------------------------------------------------------------