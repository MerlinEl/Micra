--------------------------------------------------------------------------------
/* mcGM by Orien 2019 */
--------------------------------------------------------------------------------
/*
*@Used Structures
	Micra
*
*@Used Objects

*
*@Example	
	mcGM.setParam "model_path" "C:\\models\\"
	local models_dir = mcGM.getParam "model_path"
*/
struct MICRA_GLOBAL_MEMORY	(
	
	_items = mcObject(),
	fn getSource = getSourceFileName(), --get path of this script	
	/**
	 *@example	
	 *@param	key
	 *@return value
	 */
	fn getParam key = (

		return _items.get key	
	),
	
	/**
	 *@param	key
	 *@param	value
	 */
	fn setParam key val = (
		
		_items.add key	val
	)
	/*<end>*/
)	
 --create instance
Global mcGM = mcStructMan.instanceStructure MICRA_GLOBAL_MEMORY "mcGM"
