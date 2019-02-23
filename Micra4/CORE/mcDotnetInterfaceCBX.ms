--------------------------------------------------------------------------------
/* mcDotnetInterfaceCBX by Orien 2019 */ --Not Used
--------------------------------------------------------------------------------
/*
*@Used Structures
	mcStructMan
*
*@Used Objects
	dotNetObject "comboBox"
*
*@Usage
	undefined
*
*@Example	
	cbx = mcDotnetInterfaceCBX.new (dotNetObject "comboBox")
	cbx.addItem "New_Item_1"
	cbx.addItem "New_Item_2"
	cbx.addItem "New_Item_3"
	cbx.getItemIndex "New_Item_2"
	cbx.selectItem "New_Item_2"
*
*/
struct MICRA_NEW_STRUCTURE	(
	
	--variables
	_cbx,
	--functions
	fn getSource = getSourceFileName(), --get path of this script
	fn new cbx = (
	
		if classOf cbx != dotNetObject do return undefined
		MICRA_NEW_STRUCTURE cbx
	),
	fn getItemIndex item_str = (
		
		if classOf _cbx != dotNetObject do return false
		for i=0 to _cbx.Items.count do (
		
			local str = _cbx.Items.Item(i)
			if str == item_str do return i
		)
		return -1
	),
	fn insertItem item_index item_obj = (
	
		if classOf _cbx != dotNetObject do return false
		_cbx.Items.Insert item_index item_obj
	),
	fn addItem item_str = (
	
		if classOf _cbx != dotNetObject do return false
		_cbx.Items.Add item_str	 --return pos index
	),
	--  _cbx.Items.AddRange <System.Object[]>items
	fn removeItem item_obj = (
		
		if classOf _cbx != dotNetObject do return false
		_cbx.Items.Remove item_obj
	),
	fn removeItemAt index = (
		
		if classOf _cbx != dotNetObject do return false
		_cbx.Items.RemoveAt index
	),
	--  _cbx.Items.Clear()
	fn selectedItem = (
	
		if classOf _cbx != dotNetObject do return false
		_cbx.selectedItem
	),
	fn selectedText = (
	
		if classOf _cbx != dotNetObject do return false
		_cbx.selectedText
	),
	fn selectedValue = (
		
		if classOf _cbx != dotNetObject do return false
		_cbx.selectedValue
	),
	fn selectedIndex = (
		
		if classOf _cbx != dotNetObject do return false
		_cbx.selectedIndex
	),
	fn selectItem item_str = (
	
		if classOf _cbx != dotNetObject do return false
		local item_index = getItemIndex item_str
		if item_index > -1 do _cbx.SelectedIndex = item_index
	)
	/*<end>*/
)	
 --create instance
Global mcDotnetInterfaceCBX = mcStructMan.instanceStructure MICRA_NEW_STRUCTURE "mcDotnetInterfaceCBX"
