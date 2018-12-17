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
rollout xcxc "Untitled" width:162 height:300
(
	button btn1 "Button" pos:[21,14] width:48 height:31
	button btn2 "Button" pos:[21,62] width:48 height:31
	on xcxc rbuttonup x do
	(PopupMenu MoveMode align:#align_vcentercenter xcxc)
	on btn1 pressed  do
	(PopupMenu MoveMode align:#align_topleft xcxc)
	on btn2 pressed  do
	(PopupMenu MoveMode pos:(getDialogPos xcxc) xcxc)
)
CreateDialog xcxc 200 200



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




