	/* GLOBALS */
	Global toggleTopDockedDialog
	Global toggleBottomDockedDialog
	Global toggleLeftDockedDialog
	Global toggleRightDockedDialog

(
	/* LOCALS */
	local max_size = getMAXWindowSize()
	local max_ini = getMaxIniFile()	
	local border_bitmap = bitmap 1 1 color:((colorMan.getColor #activeViewportBorder)*255)
	local orange_bitmap = bitmap 100 100 color:orange
	local green_bitmap = bitmap 100 100 color:green
	/* FUNCTIONS */
	fn destroyRegistredDialog dia=(if dia != undefined do try (cui.UnRegisterDialogBar  dia; destroyDialog  dia) catch())
	
	/* DIALOGS */
	destroyRegistredDialog  toggleRightDockedDialog
	rollout toggleRightDockedDialog "Toggle CommandPanel" width:100 height:100
	(
		--button btn_dock_top ""  height:24 pos:[0,0] color:orange-- bitmap:(bitmap 1 1 color:orange) bmpstyle:#bmp_stretch
		button btn_dock_top ""  height:24 images:#(green_bitmap , green_bitmap , 1, 1, 1, 1, 1) --pos:[0,0]
		on toggleRightDockedDialog lbuttondown pos do
		(
			cui.commandPanelOpen = not cui.commandPanelOpen
		)
		on toggleRightDockedDialog rbuttondown pos do (destroyRegistredDialog  toggleRightDockedDialog)
		on btn_dock_top pressed do
		(
			local order = getIniSetting max_ini "WindowState" "WindowOrder" == "8"
			setIniSetting max_ini "WindowState" "WindowOrder" ( if order then "0" else "8")
			cui.commandPanelOpen = false; cui.commandPanelOpen = true	
		)
	)
	createDialog toggleRightDockedDialog bitmap:(border_bitmap) bmpstyle:#bmp_stretch
	cui.RegisterDialogBar toggleRightDockedDialog minSize:[1,10] maxSize:[10,99999] style:#(#cui_dock_vert, #cui_max_sized)
	cui.DockDialogBar toggleRightDockedDialog #cui_dock_right
	
	destroyRegistredDialog  toggleBottomDockedDialog
	rollout toggleBottomDockedDialog "Toggle TimePanel" width:10 height:10
	(
		on toggleBottomDockedDialog lbuttondown pos do
		(
			local val = timeSlider.isVisible()
			timeSlider.setVisible (not val)
			-- jag dolde nedre raden. Kanske ska man göra en ny variant där bara den nedre döljs.
			--StatusPanel.visible = not val
			trackbar.visible = not val
		)
		on toggleBottomDockedDialog rbuttondown pos do (destroyRegistredDialog toggleBottomDockedDialog)
	)
	createDialog toggleBottomDockedDialog bitmap:(bitmap 1 1 color:((colorMan.getColor #activeViewportBorder)*255)) bmpstyle:#bmp_stretch
	cui.RegisterDialogBar toggleBottomDockedDialog minSize:[10,1] maxSize:[99999,10] style:#(#cui_dock_horz, #cui_max_sized )
	cui.DockDialogBar toggleBottomDockedDialog #cui_dock_bottom
	
	destroyRegistredDialog toggleTopDockedDialog
	rollout toggleTopDockedDialog "Toggle CPPanelButtons" width:10 height:10
	(
		on toggleTopDockedDialog lbuttondown pos do
		(
			if cui.commandPanelOpen then cui.expertModeOn() else cui.expertModeOff()
		)
		on toggleTopDockedDialog rbuttondown pos do (destroyRegistredDialog toggleTopDockedDialog)
	)
	createDialog toggleTopDockedDialog bitmap:(bitmap 1 1 color:((colorMan.getColor #activeViewportBorder)*255)) bmpstyle:#bmp_stretch
	cui.RegisterDialogBar toggleTopDockedDialog minSize:[10,1] maxSize:[99999,10] style:#(#cui_dock_horz,  #cui_max_sized)
	cui.DockDialogBar toggleTopDockedDialog #cui_dock_top
)