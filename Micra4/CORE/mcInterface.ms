--------------------------------------------------------------------------------
/* mcInterface by Orien 2019 */
--------------------------------------------------------------------------------
/*
*@Used Structures
	mcStructMan
*
*@Used Objects
	undefined
*
*@Usage
	undefined
*
*@Example	
	undefined
*
*/
struct MICRA_INTERFACE_STRUCTURE	(
	
	--variables

	
	--functions
	fn getSource = getSourceFileName(), --get path of this script
		fn getSource = getSourceFileName(), --get path of this script
	fn super_expert_mode =
	(
		local state = not(timeslider.isVisible()) 
		trackbar.visible = state
		timeSlider.setVisible state
		if state then cui.expertModeOff() else cui.expertModeOn()
		statusPanel.visible = state
/*
		if trackbar.visible and timeSlider.isVisible() then
		(
			timeSlider.setVisible off ; trackbar.visible =off --; statusPanel.visible = off
			cui.expertModeOn()
		)
		else
		(
			timeSlider.setVisible on ; trackbar.visible=on --;statusPanel.visible = on   
			cui.expertModeOff()
		)
*/
	),
	fn loadCustomUiScheme type:#MaxStart =
	(
		local custom_ui = getdir(#UI) + 
		(
			case type of
			(
				#MaxStart:"\\MaxStartUI.ui"
				#Default :"\\DefaultUI.ui"
			)
		)
		if not doesFileExist custom_ui do return false
		EscapeEnable=false -- Disable Esacpe Key
		loadCUIScheme custom_ui
		EscapeEnabled = true -- Enable ESC Key
	),
	fn setCoordsys coord = --#view,#screen,#world,#parent,#local,#Grid,#Gimbal
	(
		local old_tool = toolmode.commandmode
		
		max move
		Toolmode.coordsys coord 
		max rotate
		Toolmode.coordsys coord 
		max scale	
		Toolmode.coordsys coord 
		max select
		Toolmode.coordsys coord 
		
		case old_tool of
		(
			#move   :(max move)
			#rotate :(max rotate)
			#uscale :(max scale)
			#nscale :(max scale)
			#squash :(max scale)
			#select :(max select)
		)
	)
	/*<end>*/
)	
 --create instance
Global mcInterface = mcStructMan.instanceStructure MICRA_INTERFACE_STRUCTURE "mcInterface"
