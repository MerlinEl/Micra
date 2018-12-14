Global mcItem
Global mcGM
Global mcObject

/**
*@example
mcItem "a" 23
*/
struct mcItem (
	
	key, val, tag, index	
)

/**
* @example	
	mcO.add "ren" 12 -- OK
	mcO.get "ren" -- 12
	mcO.keys -- #("ren")
	mcO.values -- #(12)
*/
struct mcObject ( --always create instance
	
	keys = #(), values = #(),
	fn add key val = (
	
		local key_index = findItem keys key
		--format "mcObject > add >  key:% val:% replace:%\n" key val (key_index>0)
		if key_index == 0 then ( --add
			
			keys = append keys key
			values =  append values val
		) else ( --replace
		
			values[key_index] = val	
		)
	),
	fn get key = (
		
		local key_index = findItem keys key
		--format "mcObject > get >  key:% index:%\n" key key_index
		return if key_index > 0 then values[key_index] else undefined
	),
	/**
	local mco = mcObject()
	mco.addMore #(

		mcItem "a" 1,
		mcItem "b" 2,
		mcItem "c" 3
	)
	mcGM.setParam "edit_action_data" mco
	local mco2 = mcGM.getParam "edit_action_data"
	mco2.get "c"
	*/
	fn addMore itm_arr = (
	
		for itm in itm_arr do add itm.key itm.val	
	)
)

struct MICRA_GLOBAL_MEMORY	(
	
	_items = mcObject(),	
	/**
	 * @example	local fname = mcGM.getParam "model_path"
	 * @param	key
	 * @return value
	 */
	fn getParam key = (

		return _items.get key	
	),
	
	/**
	 * @example	mcGM.setParam "model_path" "3d/volcano_01.swf" 
	 * @param	key
	 * @param	value
	 */
	fn setParam key val = (
		
		_items.add key	val
	)
)	
mcGM = MICRA_GLOBAL_MEMORY()

