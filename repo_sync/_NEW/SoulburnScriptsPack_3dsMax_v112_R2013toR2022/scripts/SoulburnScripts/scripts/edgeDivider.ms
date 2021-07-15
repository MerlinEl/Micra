-------------------------------------------------------------------------------
-- edgeDivider.ms
-- By Neil Blevins (info@neilblevins.com)
-- v 1.02
-- Created On: 02/08/09
-- Modified On: 02/27/10
-- tested using Max 2009
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Required Files:
-- sLib.ms
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Description:
-- Splits an Edge you select in an Editable Poly into equal parts.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Tutorial:
-- Select an Editable Poly. Select an edge. Run the UI version of the script.
-- Hit Do. It will split that edge into 2 equal pieces, with a new vertex in 
-- between.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Revision History:
--
-- v 1.01 Now works on multiple edges.
--
-- v 1.02 Now works on Edit Poly modifiers.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
(
-- Globals

global edgeDivider
global edgeDividerDefaults
global edgeDividerUI

global eDCloseOpenUI

global eDDo
global eDApply
global eDHelp
global eDLoadDef
global eDSaveDef

global eDDefineUI
global eDRollout
global eDFloater

-- Includes

include "$scripts\SoulburnScripts\lib\sLib.ms"

-- Variables

eDDivideIntoValue = 2
eDPosValue = [400,400]

-- Functions

fn edgeDivider eDDivideInto = 
	(
	undo "edgeDivider" on
		(
		if selection.count == 1 then
			(
			obj = selection[1]
			if classof (modPanel.getCurrentObject ()) == Editable_Poly then
				(
				selEdges = (getedgeselection obj) as array
				for e in selEdges do
					(
					setedgeselection obj #(e)
					for num = 0 to (eDDivideInto-2) do
						(
						if num != 0 then myEdge = #(polyop.getNumEdges obj)
						else myEdge = (getedgeselection obj) as array
						for i in myEdge do
							(
							polyop.divideEdge obj i (1/((eDDivideInto - num) as float))
							)
						)
					)
				subobjectLevel = 1
				)
			else if classof (modPanel.getCurrentObject ()) == Edit_Poly then
				(
				ep = (modPanel.getCurrentObject())
				selEdges = (ep.GetSelection #Edge) as array
				for e in selEdges do
					(
					ba = #(e) as bitarray
					ba.count = ep.GetNumEdges() -- SetSelection requires that the bitarray it gets is the same size as the number of edges in the object
					ep.SetSelection #Edge ba
					for num = 0 to (eDDivideInto-2) do
						(
						if num != 0 then myEdge = #(ep.getNumEdges())
						else myEdge = (ep.GetSelection #Edge) as array
						for i in myEdge do
							(
							ep.DivideEdge i (1/((eDDivideInto - num) as float))
							ep.commit()
							)
						)
					)
				subobjectLevel = 1
				)
			else (MessageBox "Please select an Editable Poly Object or an Edit Poly Modifier" title:"edgeDivider")			
			)
		else (MessageBox "Please select a single object" title:"edgeDivider")
		)
	)
	
fn edgeDividerDefaults = 
	(
	eDLoadDef()
	edgeDivider eDDivideIntoValue
	)
	
fn edgeDividerUI = 
	(
	eDLoadDef()
	eDCloseOpenUI eDPosValue
	)

fn eDCloseOpenUI pos = 
	(
	if eDFloater != undefined then CloseRolloutFloater eDFloater
	eDDefineUI()
	eDFloater = newRolloutFloater "edgeDivider v1.02" 310 91 pos.x pos.y
	addRollout eDRollout eDFloater
	)

fn eDDo = 
	(
	edgeDivider eDDivideIntoValue
	if eDFloater != undefined then CloseRolloutFloater eDFloater
	)

fn eDApply = 
	(
	edgeDivider eDDivideIntoValue
	)
	
fn eDHelp = 
	(
	sLibSSPrintHelp "edgeDivider"
	)
	
fn eDLoadDef = 
	(
	eDInputFilename = ((getdir #scripts) + "\\SoulburnScripts\\presets\\" + "edgeDivider.ini")
	if (sLibFileExist eDInputFilename == true) then
		(
		eDDivideIntoValue = execute (getINISetting eDInputFilename "edgeDivider" "eDDivideIntoValue")
		eDPosValue = execute (getINISetting eDInputFilename "edgeDivider" "eDPosValue")
		
		if eDDivideIntoValue == OK then eDDivideIntoValue = 2
		if eDPosValue == OK then eDPosValue = [400,400]
		)
	else
		(
		eDDivideIntoValue = 2
		eDPosValue = [400,400]
		)
	)
	
fn eDSaveDef = 
	(
	eDOutputFilename = ((getdir #scripts) + "\\SoulburnScripts\\presets\\" + "edgeDivider.ini")
	if (sLibFileExist eDOutputFilename == true) then deleteFile eDOutputFilename
	setINISetting eDOutputFilename "edgeDivider" "eDDivideIntoValue" (eDDivideIntoValue as string)
	setINISetting eDOutputFilename "edgeDivider" "eDPosValue" (eDFloater.pos as string)
	)

-- UI

fn eDDefineUI = 
	(
	rollout eDRollout "edgeDivider"
		(
		spinner eDDivideIntoSpinner "Divide Into:" range:[2,9999,eDDivideIntoValue] fieldWidth:50 type:#integer align:#left
		on eDDivideIntoSpinner changed val do eDDivideIntoValue = val		

		button eDDoButton "Do" width:70 toolTip:"Do It and Close UI" pos:[5,34]
		on eDDoButton pressed do eDDo()
		button eDApplyButton "Apply" width:70 toolTip:"Do It and Keep UI Open" pos:[77,34]
		on eDApplyButton pressed do eDApply()
		button eDHelpButton "Help" width:70 toolTip:"Help" pos:[149,34]
		on eDHelpButton pressed do eDHelp()
		button eDSaveDefButton "SaveDef" width:70 toolTip:"Save Current Settings as Default" pos:[221,34]
		on eDSaveDefButton pressed do eDSaveDef()
		)
	)
)
-------------------------------------------------------------------------------