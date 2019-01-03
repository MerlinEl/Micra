--------------------------------------------------------------------------------
/* mcEvents by Orien 2019 */
--------------------------------------------------------------------------------
/*
*@Used Structures
	Micra
*
*@Used Objects

*
*@Example	
	clearListener()

	fn varChanged data = (

		format "MICRA_EVENTS > varChanged > data:%\n"  data
	)

	mcEvents.registerEvent "VariableChanged" mcTemp1Dialog.varChanged

	mcEvents.dispatchEvent "VariableChanged" data:1
	mcEvents.dispatchEvent "VariableChanged" data:456

	mcEvents.unregisterEvent "VariableChanged" varChanged
	mcEvents.unregisterEventSet "VariableChanged"
	mcEvents.unregisterAll()


	local id = mcTime.getUniqueId()
	dotnet.removeAllEventHandlers _timer
*/
--Each Event can have multiple functions under one ID
Struct MICRA_EVENT_SET (
	
	_id,
	_debug = false,
	_function_list = #(),
	fn getFnIndex evt_fn = (
		
		for i = 1 to _function_list.count where _function_list[i]  as String == evt_fn as String do return i
		0
	),
	fn addToSet evt_fn = (
		
		local fn_index = getFnIndex evt_fn 
		format "function index:%\n" fn_index
		if fn_index == 0 then (
			
			append _function_list evt_fn
			if _debug do format "MICRA_EVENT_SET > addToSet > function [%] in to list [%]." evt_fn _function_list
			
		) else (

			if _debug do format "MICRA_EVENT_SET > addToSet > Error: function [%] already exists under set [%]." evt_fn _id
			return false
		)
		true
	),
	fn removeFromSet evt_fn = (
	
		local fn_index = getFnIndex evt_fn 
		if fn_index > 0 then (
			
			mcArray.removeItem _function_list fn_index	
		) else (
		
			if _debug do format "MICRA_EVENT_SET > removeFromSet > Unable to unregister function [%]  which is not exists under event set [%]." evt_fn _id	
			return false
		)
		true
	),
	fn run data = (
		
		for _fn in _function_list do (
				
			try ( --try execute function
			
				if _debug do format "MICRA_EVENT_SET > run > Executed Function:% under ID:%\n" _fn _id
				_fn data
				
			) catch (
				
				format "MICRA_EVENT_SET > run >  unable execute Function:% under ID:%\nError > %\n" _fn _id (getCurrentException())
				--mcEvents.unregisterEvent _id
			)
		)
		OK
	)
)	

--Multiple Events which is fired from different actions
Struct MICRA_EVENTS (
	
		_debug = false,
		_evts_set_list = #(),
		fn getEventSetIndex evt_id = (
		
			for i = 1 to _evts_set_list.count where _evts_set_list[i]._id == evt_id do return i
			0
		),
		fn isRegistred evt_id evt_fn = (
			
			local evt_index = getEventSetIndex evt_id
			if evt_index == 0 do return false
			local fn_index = 	_evts_set_list[evt_index].getFnIndex evt_fn
			fn_index != 0
		),
		fn getEventSet evt_id = (
		
			local evt_index = getEventSetIndex evt_id
			if evt_index > 0 then _evts_set_list[evt_index] else undefined
		),
		fn registerEvent evt_id evt_fn = (
			
			local event_set = getEventSet evt_id
			if event_set != undefined then (
				
				if isRegistred evt_id evt_fn  then ( --do nothing
					
						if _debug do format "MICRA_EVENTS > registerEvent > already registred function:% to id:%\n" evt_fn evt_id	
						return false

				) else ( --append to existing set
				
					if _debug do format "MICRA_EVENTS > registerEvent > append function:% to id:%\n" evt_fn evt_id
					event_set.addToSet evt_fn
				)
			) else ( --create new set by id
				
				if _debug do format "MICRA_EVENTS > registerEvent > create new id:% with function:%\n" evt_id evt_fn
				local new_set = MICRA_EVENT_SET evt_id 
					new_set.addToSet evt_fn
				append _evts_set_list new_set
			)
			true
		),
		fn dispatchEvent  evt_id data:undefined = (
		
			local event_set = getEventSet evt_id 	
			if event_set != undefined then ( --unregister function in set
				
				event_set.run data
			) 
		),
		fn unregisterEvent evt_id evt_fn  = (
			
			local event_set = getEventSet evt_id 	
			if event_set != undefined then ( --unregister function in set
				
				if _debug do format "MICRA_EVENTS > unregisterEvent > set:%\n" evt_id
				event_set.removeFromSet evt_fn
				
			) else  (
				
				if _debug do format "MICRA_EVENTS >  Error: unregisterEvent > Unable find event set:%\n" evt_id
				return false
			)
			true
		),
		fn unregisterEventSet evt_id = (
			
			local evt_index = getEventSetIndex evt_id
			if evt_index > 0 then deleteItem _evts_set_list evt_index
		),
		fn unregisterAll = ( _evts_set_list = #() )
)
 --create instance
Global mcEvents = Micra.instanceStructure MICRA_EVENTS "mcEvents"
