--> Not Used
--------------------------------------------------------------------------------
/* mcDisplay by Orien 2019 */
--------------------------------------------------------------------------------
/*
*@Used Structures
	mcStructMan
*
*@Used Objects
	undefined
*
*@Usage
	Show message on screen with defined duration in ms
*
*@Example	
	mcDisplay.show "Select some object." green duration:1000
	mcDisplay.hide()
*
*/
if isStruct mcDisplay do mcDisplay.hide() --unregister before reimport
struct MICRA_DISPLAY_STRUCTURE	(
	
	--variables
	_txt, _col,
	tm = dotnetobject "system.timers.timer",
	--functions
	fn getSource = getSourceFileName(), --get path of this script
	fn draw = (

		local view_size = getviewsize()
		local text_size = gw.getTextExtent _txt
		local pos_x = (view_size.x - text_size.x)/2
		local pos_y = 16
			
		gw.wtext [pos_x, pos_y, 0] _txt color:_col
		gw.enlargeUpdateRect #whole
		gw.updateScreen()
	),
	fn hide = (

		unRegisterRedrawViewsCallback draw
		completeredraw()
	),
	fn terminate = ( --not used (for debug, endles loop error)
	
		mcDisplay.tm.stop()
		mcDisplay.tm.Enabled = false
	),
	fn tmTick s a = (
	
		s.stop()
		s.Enabled = false
		mcDisplay.hide()
    ),
	fn hideAfter ms = (
	
		tm.Interval = ms -- Set the interval 1000ms == 1sec
		-- tm.Enabled = false -- Disable the timer. It will then be enabled with the Start() function.
		-- dotnet.removeEventHandler tm "Elapsed" tmTick
		-- dotnet.addEventHandler tm "Elapsed" tmTick
		tm.start()
	),
	fn show txt col duration:0 screen_pos:#tcenter = (

		if classOf txt != string or classOf col != Color do return false
		_txt = txt; _col = col
		unRegisterRedrawViewsCallback draw
		registerRedrawViewsCallback draw
		completeredraw()
		if duration > 0 do hideAfter duration
	),
	on create do (
	
		tm.Enabled = false -- Disable the timer. It will then be enabled with the Start() function.
		dotnet.addEventHandler tm "Elapsed" tmTick
	)
	/*<end>*/
)	
 --create instance
Global mcDisplay = mcStructMan.instanceStructure MICRA_DISPLAY_STRUCTURE "mcDisplay"
