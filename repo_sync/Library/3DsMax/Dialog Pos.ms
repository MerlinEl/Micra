if xcxc != undefined then destroyDialog xcxc
-----menu
rcMenu MoveMode
	(
	subMenu "Move"
		(
		menuItem new_1 "On"
		menuItem new_2 "Off"
		)
	on new_1 picked do destroyDialog xcxc
	on new_2 picked do destroyDialog xcxc
	)
-----dialog
rollout xcxc "Untitled" width:162 height:200
(
	button btn1 "Button" pos:[21,14] width:48 height:31
	button btn2 "Button" pos:[21,62] width:48 height:31
	on xcxc open do
	(
	cui.RegisterDialogBar xcxc minSize:[136,600] maxSize:[136,800]
	cui.DockDialogBar xcxc #cui_dock_left
	)
	on xcxc rbuttonup x do
	(PopupMenu MoveMode align:#align_vcentercenter xcxc)
	on btn1 pressed  do
	(PopupMenu MoveMode align:#align_topleft xcxc)
	on btn2 pressed  do
	(PopupMenu MoveMode pos:(getDialogPos xcxc) xcxc)
	on xcxc moved pos do
		(
		print"m"
		--xcxc pos:[10,10]
		)
	--on xcxc mousemove pos do
		--(SetDialogPos xcxc pos)
	--	(print pos as string)
	--on xcxc lbuttondown pos do
		--(print pos as string)
	--	(SetDialogPos xcxc (pos + getviewsize()) )
	on xcxc rbuttondown pos do
		(print pos as string)
	
)
CreateDialog xcxc 136 670



/*
#align_topleft
#align_topcenter
#align_topright
#align_bottomleft
#align_bottomcenter
#align_bottomright
#align_vcenterleft
#align_vcentercenter
#align_vcenterright
*/

/*

cui.DockDialogBar mc2DialogVideoDisplay #cui_dock_left
*/
/*
on mc2DialogVideoDisplay open do
(cui.RegisterDialogBar mc2DialogVideoDisplay minSize:[136,600] maxSize:[136,800] style:#(#cui_dock_bottom))
cui.UnRegisterDialogBar mc2DialogVideoDisplay
*/



