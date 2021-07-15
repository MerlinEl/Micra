-------------------------------------------------------------------------------
-- geometryBanger.ms
-- By Neil Blevins (info@neilblevins.com)
-- v 1.02
-- Created On: 01/05/14
-- Modified On: 06/25/14
-- tested using Max 2014
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Required Files:
-- sLib.ms
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Description:
-- Chooses a % of vertexes in an object and moves them around randomly. 
-- Good or adding subtle bangs and bumps to your geometry. The advantage this 
-- has over say the Noise modifier is it only affect some verts, which will 
-- give a more realistic result. Object Size Compensation tries to bang 
-- smaller objects less, and large objects more.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Tutorial:
-- Make a teapot, Collapse to Editable Poly. Run the UI version of the script. 
-- Hit Do. Some of the vertexes are now slightly moved around.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Revision History:
--
-- v 1.01 Added Progress Bar. Added ability to turn off undo to fix a max memory 
-- issue. Only affects instanced objects once.
--
-- v 1.02 Now can add the geometry changes to an EditPoly modifier.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Known Issues:
-- Script can fail on really large models if you have undo on (it's some sort 
-- of max memory issue). If you have max crashing issues, try checking undo off 
-- in the geometryBanger UI, and see if that helps (although save your work 
-- first, since you then can't undo). Or another technique is to select only a 
-- few objects at a time, apply the script, then move onto the next group of 
-- objects.
--
-- Produces best results with evenly spaced geometry.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
(
-- Globals

global geometryBanger
global geometryBangerDefaults
global geometryBangerUI

global gBBangTheGeometry

global gBCloseOpenUI

global gBDo
global gBApply
global gBHelp
global gBLoadDef
global gBSaveDef

global gBDefineUI
global gBRollout
global gBFloater

-- Includes

include "$scripts\SoulburnScripts\lib\sLib.ms"

-- Variables

gBActionValue = 1
gBPercentageValue = 20
gBAmountMinValue = 0.1
gBAmountMaxValue = 0.3
gBAmountBiasValue = 0.6
gBObjectSizeCompValue = false
gBUndoOnValue = true
gBPosValue = [400,400]

-- Functions

fn geometryBanger gBAction gBPercentage gBAmountMin gBAmountMax gBAmountBias gBObjectSizeComp gBUndoOn = 
	(
	a = for i in selection collect i
	objs = sLibRemoveUnneededInstancesFromArray a
	setCommandPanelTaskMode #modify
	if gBUndoOn == true then
		(
		undo "geometryBanger" on
			(
			gBBangTheGeometry objs gBAction gBPercentage gBAmountMin gBAmountMax gBAmountBias gBObjectSizeComp
			)		
		)
	else 
		(
		gBBangTheGeometry objs gBAction gBPercentage gBAmountMin gBAmountMax gBAmountBias gBObjectSizeComp
		)
	)
	
fn geometryBangerDefaults = 
	(
	gBLoadDef()
	geometryBanger gBActionValue gBPercentageValue gBAmountMinValue gBAmountMaxValue gBAmountBiasValue gBObjectSizeCompValue gBUndoOnValue
	)
	
fn geometryBangerUI = 
	(
	gBLoadDef()
	gBCloseOpenUI gBPosValue
	)
	
fn gBBangTheGeometry theObjects gBAction gBPercentage gBAmountMin gBAmountMax gBAmountBias gBObjectSizeComp = 
	(
	objectsIgnored = 0
	if gBAmountMin > gBAmountMax then (AmountMinVal = gBAmountMax;AmountMaxVal = gBAmountMin)
	else (AmountMinVal = gBAmountMin;AmountMaxVal = gBAmountMax)
	
	-- Prep Progressbar
	numOfItems = theObjects.count
	currentIteration = 0

	oldsel = for i in $ collect i
	max modify mode
	disableSceneRedraw()
	try
		(
		for obj in theObjects do
			(
			currentIteration += 1
			gbRollout.gBProgbar.value = ((currentIteration as float)/(numOfItems as float))*100
			if gBAction == 1 then
				(
				if (classof obj.baseobject) == Editable_Poly then
					(
					numVerts = polyOp.getNumVerts obj.baseobject
					a = (for i = 1 to numVerts collect i)
					chosenVerts = sLibChooseUniqueValuesByPercentage a gBPercentage
					myvolume = sLibGetCollectionBBoxVolume #(obj)
					for i in chosenVerts do
						(
						myx = (polyop.getvert obj.baseobject i).x
						myy = (polyop.getvert obj.baseobject i).y
						myz = (polyop.getvert obj.baseobject i).z
						if gBObjectSizeComp == true then myvolume = (((sLibGetCollectionBBoxVolume #(obj))/250000) as float) else myvolume = 1.00
						amountx = (myvolume^0.25)*(sLibRandomWithBias (AmountMinVal as float) (AmountMaxVal as float) gBAmountBias)
						amounty = (myvolume^0.25)*(sLibRandomWithBias (AmountMinVal as float) (AmountMaxVal as float) gBAmountBias)
						amountz = (myvolume^0.25)*(sLibRandomWithBias (AmountMinVal as float) (AmountMaxVal as float) gBAmountBias)
						dir = (random 0.00 1.99) as integer
						if dir == 0 then polyop.setvert obj.baseobject i [myx-amountx,myy-amounty,myz-amountz]
						else polyop.setvert obj.baseobject i [myx+amountx,myy+amounty,myz+amountz]
						)
					)
				else objectsIgnored += 1
				)
			else
				(
				if (validModifier obj Edit_Poly) == true then
					(
					-- add edit poly
					select obj
					addmodifier obj (Edit_Poly())
					myMod = obj.modifiers[1]
					myMod.name = "geometryBanger"

					numVerts = myMod.GetNumVertices()
					a = (for i = 1 to numVerts collect i)
					chosenVerts = sLibChooseUniqueValuesByPercentage a gBPercentage
					myvolume = sLibGetCollectionBBoxVolume #(obj)
					for i in chosenVerts do
						(
						myx = (myMod.GetVertex i).x
						myy = (myMod.GetVertex i).y
						myz = (myMod.GetVertex i).z
						if gBObjectSizeComp == true then myvolume = (((sLibGetCollectionBBoxVolume #(obj))/250000) as float) else myvolume = 1.00
						amountx = (myvolume^0.25)*(sLibRandomWithBias (AmountMinVal as float) (AmountMaxVal as float) gBAmountBias)
						amounty = (myvolume^0.25)*(sLibRandomWithBias (AmountMinVal as float) (AmountMaxVal as float) gBAmountBias)
						amountz = (myvolume^0.25)*(sLibRandomWithBias (AmountMinVal as float) (AmountMaxVal as float) gBAmountBias)
						dir = (random 0.00 1.99) as integer
						if dir == 0 then myMod.SetVert #{i} [myx-amountx,myy-amounty,myz-amountz]
						else myMod.SetVert #{i} [myx+amountx,myy+amounty,myz+amountz]
						)
					)
				else objectsIgnored += 1
				)
			)
		if objectsIgnored != 0 then 
			(
			mainText = "This script only works on Editable Poly objects or objects that can have EditPoly modifiers assigned to them. " + (objectsIgnored as string) + " object(s) were ignored by this script"
			MessageBox mainText title:"geometryBanger"
			)
		)
	catch ()
	enableSceneRedraw()
	completeRedraw()
	select oldsel
	gbRollout.gBProgbar.value = 0
	)

fn gBCloseOpenUI pos = 
	(
	if gBFloater != undefined then CloseRolloutFloater gBFloater
	gBDefineUI()
	gBFloater = newRolloutFloater "geometryBanger v1.02" 230 310 pos.x pos.y
	addRollout gBRollout gBFloater
	)

fn gBDo = 
	(
	geometryBanger gBActionValue gBPercentageValue gBAmountMinValue gBAmountMaxValue gBAmountBiasValue gBObjectSizeCompValue gBUndoOnValue
	if gBFloater != undefined then CloseRolloutFloater gBFloater
	)

fn gBApply = 
	(
	geometryBanger gBActionValue gBPercentageValue gBAmountMinValue gBAmountMaxValue gBAmountBiasValue gBObjectSizeCompValue gBUndoOnValue
	)
	
fn gBHelp = 
	(
	sLibSSPrintHelp "geometryBanger"
	)
	
fn gBLoadDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	gBInputFilename = presetDir + "geometryBanger.ini"
	if (sLibFileExist gBInputFilename == true) then
		(
		gBActionValue = execute (getINISetting gBInputFilename "geometryBanger" "gBActionValue")
		gBPercentageValue = execute (getINISetting gBInputFilename "geometryBanger" "gBPercentageValue")
		gBAmountMinValue = execute (getINISetting gBInputFilename "geometryBanger" "gBAmountMinValue")
		gBAmountMaxValue = execute (getINISetting gBInputFilename "geometryBanger" "gBAmountMaxValue")
		gBAmountBiasValue = execute (getINISetting gBInputFilename "geometryBanger" "gBAmountBiasValue")
		gBObjectSizeCompValue = execute (getINISetting gBInputFilename "geometryBanger" "gBObjectSizeCompValue")
		gBUndoOnValue = execute (getINISetting gBInputFilename "geometryBanger" "gBUndoOnValue")
		gBPosValue = execute (getINISetting gBInputFilename "geometryBanger" "gBPosValue")
		
		if gBActionValue == OK then gBActionValue = 1
		if gBPercentageValue == OK then gBPercentageValue = 20
		if gBAmountMinValue == OK then gBAmountMinValue = 0.1
		if gBAmountMaxValue == OK then gBAmountMaxValue = 0.3
		if gBAmountBiasValue == OK then gBAmountBiasValue = 0.6
		if gBObjectSizeCompValue == OK then gBObjectSizeCompValue = false
		if gBUndoOnValue == OK then gBUndoOnValue = true
		if gBPosValue == OK then gBPosValue = [400,400]
		)
	else
		(
		gBActionValue = 1
		gBPercentageValue = 20
		gBAmountMinValue = 0.1
		gBAmountMaxValue = 0.3
		gBAmountBiasValue = 0.6
		gBObjectSizeCompValue = false
		gBUndoOnValue = true
		gBPosValue = [400,400]
		)
	)
	
fn gBSaveDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	if (getDirectories presetDir).count == 0 then makeDir presetDir
	gBOutputFilename = presetDir + "geometryBanger.ini"
	if (sLibFileExist gBOutputFilename == true) then deleteFile gBOutputFilename
	setINISetting gBOutputFilename "geometryBanger" "gBActionValue" (gBActionValue as string)
	setINISetting gBOutputFilename "geometryBanger" "gBPercentageValue" (gBPercentageValue as string)
	setINISetting gBOutputFilename "geometryBanger" "gBAmountMinValue" (gBAmountMinValue as string)
	setINISetting gBOutputFilename "geometryBanger" "gBAmountMaxValue" (gBAmountMaxValue as string)
	setINISetting gBOutputFilename "geometryBanger" "gBAmountBiasValue" (gBAmountBiasValue as string)
	setINISetting gBOutputFilename "geometryBanger" "gBObjectSizeCompValue" (gBObjectSizeCompValue as string)
	setINISetting gBOutputFilename "geometryBanger" "gBUndoOnValue" (gBUndoOnValue as string)
	setINISetting gBOutputFilename "geometryBanger" "gBPosValue" (gBFloater.pos as string)
	)

-- UI

fn gBDefineUI = 
	(
	rollout gBRollout "geometryBanger"
		(
		dropdownlist gBActionDropdown "" items:#("Add To EditablePoly BaseObject", "Add To New EditPoly") selection:gBActionValue width:180 align:#center
		
		group "Amounts"
		(		
		spinner gBPercentageSpinner "% Of Verts To Affect: " range:[0,100,gBPercentageValue] fieldWidth:55 type:#float align:#right
		spinner gBAmountMinSpinner "Min Amount: " range:[0,9999999,gBAmountMinValue] fieldWidth:55 type:#float align:#right
		spinner gBAmountMaxSpinner "Max Amount: " range:[0,9999999,gBAmountMaxValue] fieldWidth:55 type:#float align:#right
		spinner gBAmountBiasSpinner "Amount Bias: " range:[0,1,gBAmountBiasValue] fieldWidth:55 type:#float align:#right
		)
		
		group "Options"
		(				
		checkbox gBObjectSizeCompCheckbox "Object Size Compensation?" checked:gBObjectSizeCompValue align:#right
		checkbox gBUndoOnCheckbox "Undo On?" checked:gBUndoOnValue align:#right
		)
		
		progressbar gBProgbar color:red

		on gBActionDropdown selected i do gBActionValue = i
		on gBPercentageSpinner changed val do gBPercentageValue = val
		on gBAmountMinSpinner changed val do gBAmountMinValue = val
		on gBAmountMaxSpinner changed val do gBAmountMaxValue = val
		on gBAmountBiasSpinner changed val do gBAmountBiasValue = val
		on gBObjectSizeCompCheckbox changed state do gBObjectSizeCompValue = state
		on gBUndoOnCheckbox changed state do gBUndoOnValue = state
	
		button gBDoButton "Do" width:70 toolTip:"Do It and Close UI" pos:[35,228]
		on gBDoButton pressed do gBDo()
		button gBApplyButton "Apply" width:70 toolTip:"Do It and Keep UI Open" pos:[107,228]
		on gBApplyButton pressed do gBApply()
		button gBHelpButton "Help" width:70 toolTip:"Help" pos:[35,254]
		on gBHelpButton pressed do gBHelp()
		button gBSaveDefButton "SaveDef" width:70 toolTip:"Save Current Settings as Default" pos:[107,254]
		on gBSaveDefButton pressed do gBSaveDef()
		)
	)
)
-------------------------------------------------------------------------------