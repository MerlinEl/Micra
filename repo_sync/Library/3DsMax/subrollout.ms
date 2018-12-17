try destroyDialog mcPassKeeper catch ()
rollout mcPassKeeper "Pass Keeper v0.01" width:276 height:608
(
	local inidata , key_file, dnRol
	
	
	GroupBox grp1 ">>>" pos:[4,4] width:268 height:600
	
	combobox cbx_list "List:" pos:[12,24] width:252 height:16

	button btn_add "Save" pos:[96,270] width:80 height:20
	button btn_new "New" pos:[12,270] width:80 height:20
	button btn_del "Deete" pos:[180,270] width:80 height:20
	button btn_run "Run" pos:[212,16] width:52 height:20
	subRollout sub_rol "Data" pos:[8,296] width:260 height:304
	
	fn loadForm num = --add rolout with items
	(
		
		
		
		
		rollout dnRol "<< Data >>"
		(
			label lbl_web "Web:" pos:[4,8] width:56 height:12
			label lbl_name "Name:" pos:[4,32] width:56 height:12
			label lbl_pass "Pass:" pos:[4,56] width:56 height:12
			
			edittext edt_web "" pos:[60,4] width:166 height:17
			edittext edt_name "" pos:[60,28] width:166 height:17
			edittext edt_pass "" pos:[60,52] width:166 height:17
			
			button btnx_01 "x" pos:[230,4] width:16 height:16
			button btnx_02 "x" pos:[230,28] width:16 height:16
			button btnx_03 "x" pos:[230,52] width:16 height:16
			
 			on btnx_01 pressed do print cbx_list.selected --selection > num selected > text
		)
		
		AddSubRollout sub_rol dnRol rolledUp:off
	)
	
)