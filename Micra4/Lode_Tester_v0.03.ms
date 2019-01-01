Global mcLodeTestDialog

rollout mcLodeTestDialog "Lode Tester:" width:328 height:164
(
	local sets = #(#(), #())
	local active_set = 1
	local switch = 1
	local dMove = false , DmPos
	Timer tmr1 "Timer" pos:[4,4] width:24 height:24 interval:10 active:false
	spinner spn_time "" pos:[8,138] width:64 height:16 range:[100,10000,1000] type:#integer
	checkbutton ckb_test "TEST" pos:[76,136] width:240 height:20
	checkbutton ckb_1 "..." pos:[44,24] width:28 height:24 checked:true
	checkbutton ckb_2 "..." pos:[44,48] width:28 height:24 
	GroupBox grp1 "Lode Tester:" pos:[4,4] width:320 height:156
	label lbl1 "set A:" pos:[8,28] width:32 height:12 
	label lbl2 "set B:" pos:[8,52] width:32 height:12
	button btn_add "Add" pos:[8,80] width:64 height:24
	listbox lbx_set "" pos:[76,24] width:240 height:8
	button btn_rem "Remove" pos:[8,108] width:64 height:24
	fn ckb_switch state ckb =
	(
		if not state 
		then 
		(
			ckb.state = true 
		)
		else
		(
			case ckb of
			(
				ckb_1: (ckb_2.checked = false ; active_set = 1)
				ckb_2: (ckb_1.checked = false ; active_set = 2)
			)
			lbx_set.items = sets[active_set]
		)
		--format "sets_in:%\n" sets
	)
	fn add_obj =
	(
		local sel = selection as array
		local sel_names = for i in sel collect i.name
		if sel.count == 0 do return false

		sets[active_set] += sel_names
		lbx_set.items    += sel_names
		
		hide sel
		clearSelection()
		--format "sets_out:%\n" sets
	)
	fn rem_obj =
	(
		local sel = lbx_set.selected
		local num = lbx_set.selection
		local itm = lbx_set.items
		
		if sel != undefined do 
		(
			--format "active set:%\tnum:%\n" active_set num
			
			--remove local variable
			deleteItem sets[active_set] num
			--remove name from list
			deleteItem itm num
			lbx_set.items = itm
			--unhide node
			local node = getNodeByName sel
			if node != undefined do unhide node
		)
	)
	fn hide_sets num =
	(
		for n in sets[num] where (local nod = getNodeByName n) != undefined do hide nod
	)
	fn unhide_setS num =
	(
		for n in sets[num] where (local nod = getNodeByName n) != undefined do unhide nod
	)
	fn set_switch =
	(
		if sets[1].count != 0 and sets[2].count != 0 do
		(
			case switch of
			(
				1:
				(
					hide_sets 2
					unhide_sets 1
					switch = 2
				)
				2:
				(
					hide_sets 1
					unhide_sets 2
					switch = 1
				)
			)
		)
	)
	on mcLodeTestDialog close do
	(
		mcFile.saveIniDialog "mcLodeTestDialog" "Properties_2"
	)
	on mcLodeTestDialog rbuttonup   pos do(destroyDialog mcLodeTestDialog)
	-->MoveMode
	on mcLodeTestDialog lbuttondown pos do (dMove = true; DmPos = pos; if not keyboard.shiftPressed do pushprompt "Pres Shift To Move...")
	on mcLodeTestDialog lbuttonup   pos do (dMove = false; pushprompt "")
	on mcLodeTestDialog mouseMove   pos do
	(
		if dMove and keyboard.shiftPressed do mcDialog.snapDialog mcLodeTestDialog DmPos
	)
	on tmr1 tick do
	(
		set_switch()
		tmr1.interval = spn_time.value
	)
	on ckb_test changed state do 
	(
		tmr1.active = state
		if not state do (unhide_sets 1; unhide_sets 2)
	)
	on ckb_1 changed state do ckb_switch state ckb_1
	on ckb_2 changed state do ckb_switch state ckb_2
	on btn_add pressed do add_obj()
	on btn_rem pressed do rem_obj()
)
mcCall.createIniDialog "mcLodeTestDialog" "Properties_2"