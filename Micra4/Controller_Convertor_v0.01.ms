if controllerConverterDialog != undefined do destroyDialog controllerConverterDialog
rollout controllerConverterDialog "" width:168 height:152
(
	dropdownList ddlController "Controllers:" pos:[14,28] width:142 height:40 items:#("Linear", "Euler XYZ", "TCB") selection:1
	button btnAddController "Convert" pos:[84,76] width:71 height:64
	checkbox chk_pos "Position" pos:[12,78] width:68 height:16
	checkbox chk_rot "Rotation" pos:[12,100] width:68 height:16
	checkbox chk_siz "Scale" pos:[12,124] width:68 height:16
	groupBox grp1 "Controller Convertor:" pos:[4,4] width:160 height:144
	fn getController =
	(
		case ddlController.selection of
		(
			1: linear_rotation ()
			2: euler_XYZ ()
			3: tcb_rotation ()
		)
	)
	on btnAddController pressed do undo "Add Controller" on
	(
		if selection.count > 0 do
		(
			for i in (selection as array) do 
			(
				if chk_siz.checked do i.scale.controller    = getController()
				if chk_pos.checked do i.position.controller = getController()
				if chk_rot.checked do i.rotation.controller = getController()
			)
		)
	)
)
createDialog controllerConverterDialog

