(
----------------------------------------------------------------------------
/* RcMenu */
----------------------------------------------------------------------------
--Right click menu
rcMenu rcmButtonMan
(
	menuItem swap_menu	"Swap"
	menuItem add_menu	"Add"
	menuItem cear_menu	"Clear"
	separator file_menu_1
	menuItem close_menu	"Close"
	
	on swap_menu	picked  do 
	(
		print "Swap:Comming soon"
	)
	on add_menu	picked  do 
	(
		print "Add:Comming soon"
	)
	on cear_menu	picked  do 
	(
		print "Clear:Comming soon"
	)
	on close_menu	picked  do 
	(
		mcCloseDialog()
	)
)
rollout roTest "test"
(
	button btn_1 "C" width:24 height:24 acros:4
	button btn_2 "C" width:24 height:24
	button btn_3 "C" width:24 height:24
	button btn_4 "C" width:24 height:24
	on btn_1 pressed do 
	(
		if keyboard.altPressed then  (popUpMenu rcmButtonMan)
	)
	on btn_2 pressed do 
	(
		if keyboard.altPressed then  (popUpMenu rcmButtonMan)
	)
	on btn_3 pressed do 
	(
		if keyboard.altPressed then  (popUpMenu rcmButtonMan)
	)
	on btn_4 pressed do 
	(
		if keyboard.altPressed then  (popUpMenu rcmButtonMan)
	)
)
createDialog roTest

)