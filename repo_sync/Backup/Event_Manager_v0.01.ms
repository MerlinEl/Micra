---Event Dispatcher
--Event Catcher

Global mcEvents
if mcEvents != undefined do mcEvents.clearEvents()

Struct MICRA_TIMER (
	
	_id, _fn, _delay, -- input params
	_timer = dotnetobject "System.Windows.Forms.Timer",
	fn start = (
		
		_timer.Interval = _delay 
		dotnet.addEventHandler _timer "Tick" _fn
		_timer.start()
		OK
	),
	fn stop = (
		
		_timer.stop()
		dotnet.removeEventHandler _timer "Tick" _fn
		_timer.dispose()
		OK
	),
	fn match evt_id = (_id == evt_id)
)

Struct MICRA_EVENTS(
	
		_evt_list = #(),
		fn getEventIndex evt_id = (
			
			for i = 1 to _evt_list.count where _evt_list[ i ].match evt_id do return i
			0
		),
		fn isEventRegistred evt_id = (
			
			getEventIndex evt_id > 0
		),
		fn delEvent evt_id evt_fn = (
			
			local evt_index = getEventIndex evt_id
			if evt_index > 0 do (
				
				local evt = _evt_list[evt_index]
				evt.Stop()
				mcArray.removeItem _evt_list evt_index
			)
			OK
		),
		fn addEvent evt_id evt_fn evt_delay:2000 = ( -- default delay every two seconds	
			
			if isEventRegistred evt_id do delEvent evt_id evt_fn
			local new_evt = MICRA_TIMER evt_id evt_fn evt_delay
			append _evt_list new_evt
			new_evt.Start()
			OK
		),
		fn clearEvents = (
			
			for evt in _evt_list do evt.Stop()
			_evt_list = #()
		)
)
mcEvents = MICRA_EVENTS()



fn varChanged s a = (

	format "event tick s:% a:%\n" s a
)
/*
mcEvents.addEvent "VariableChanged" varChanged
mcEvents.delEvent "VariableChanged" varChanged
mcEvents.clearEvents()
dotnet.removeAllEventHandlers _timer
*/