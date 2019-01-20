--------------------------------------------------------------------------------
/* mcMsxInterfaceMLB by Orien 2019 */
--------------------------------------------------------------------------------
/*
*@Used Structures
	Micra
*
*@Used Objects
	undefined
*
*@Usage
	Manage multilistbox components
*
*@Example	
	Micra.import "mcMsxInterfaceMLB" --force:true
	::mcMsxInterfaceMLB.moveItems lbx_a #up
	::mcMsxInterfaceMLB.moveItems lbx_a #down
*
*/
struct MICRA_MSX_INTERFACE_MULTILISTBOX	(
	
	--variables

	
	--functions
	fn getSource = getSourceFileName(), --get path of this script
	--------------------
	/* MultiListBox */
	--------------------
	fn getItemIndex lbx item_name = (
		
		for i = 1 to lbx.items.count do if lbx.items[i] == item_name do return i
		0
	),
	fn insertItemAt lbx item_name item_index = (
	
		insertItem item_name lbx.items item_index
		lbx.items = lbx.items
	),
	fn removeItemByName lbx item_name = (
	
		local item_index = getItemIndex lbx item_name
		if item_index > 0 do lbx.items = deleteItem lbx.items item_index
	),
	fn isSelected lbx item_name = ((for i in lbx.selection where lbx.items[i] == item_name collect i).count != 0),
	/**
	*@Usage
		move items in MultiListBox up and down
	*@Example
		mcMsxInterfaceMLB.mlbxMoveItems lbx_a #up
	*/
	fn moveItems lbx way = (
	
		local sel = lbx.selection
		if sel.count == 0 do return false
		local new_sel = #{}
		case way of (
		
			#up		: (	--Moves the selected items up one level
			
				local is_first_item_selected = findItem sel 1 --check if first item is at top
				if is_first_item_selected != 0 do deleteItem sel is_first_item_selected --remove top item from selection
				local names_to_move = for i in sel collect lbx.items[i]
				for i = 1 to names_to_move.count do ( --move selected items up
					
					local item_name = names_to_move[i]
					local item_index = (sel as Array)[i]
					removeItemByName lbx item_name
					insertItemAt lbx names_to_move[i] (item_index-1)
					append new_sel (item_index-1)
				)
			)
			#down	: (	--Moves the selected items one level down
			
				local is_last_item_selected = findItem sel sel.count --check if last item is at bottom
				if is_last_item_selected != 0 do deleteItem sel is_last_item_selected --remove bottom item from selection
				local names_to_move = for i in sel collect lbx.items[i]
				for i = names_to_move.count to 1 by -1 do ( --move selected items down
					
					local item_name = names_to_move[i]
					local item_index = (sel as Array)[i]
					removeItemByName lbx item_name
					insertItemAt lbx names_to_move[i] (item_index+1)
					append new_sel (item_index+1)
				)
			)
		)
		lbx.selection =  new_sel
	)
	/*<end>*/
)	
 --create instance
Global mcMsxInterfaceMLB = Micra.instanceStructure MICRA_MSX_INTERFACE_MULTILISTBOX "mcMsxInterfaceMLB"