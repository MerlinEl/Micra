(
try(destroyDialog cRollout)catch()
rcMenu CanvasMenu 
	(
	subMenu "File"
		(
		menuItem new_menu "New"
		menuItem open_menu "Open..."
		menuItem save_as "Save As..."
		separator file_menu_1
		menuItem quit_tool "Quit"  
		)
	subMenu "Edit" ( )
	subMenu "Help" 
		( 
		menuItem about_tool "About MicroPaint..." 
		)
	on about_tool picked do messagebox "MicroPaint\nMAXScript Tutorial" title:"About..."
	on quit_tool picked do destroyDialog cRollout
	)

rollout cRollout "MicroPaint"
(
)
createDialog cRollout 200 100 menu:CanvasMenu 
)
