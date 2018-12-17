if micraPluginDialog0001 != undefined do destroyDialog micraPluginDialog0001
rollout micraPluginDialog0001 "Untitled" width:92 height:168(
	
	groupBox grp1 "Micra Plugin" pos:[4,4] width:84 height:160
	button btn_nurms_on "on" pos:[8,64] width:30 height:20
	button btn_nurms_off "off" pos:[52,64] width:30 height:20
	label lbl_nurms "Toggle NURMS" pos:[8,44] width:76 height:16
	button btn_help "?" pos:[72,4] width:16 height:16
	label lbl_sel "Select by name" pos:[8,100] width:76 height:16
	editText edt_sel "" pos:[4,116] width:80 height:20
	button btn_sel "select" pos:[8,140] width:76 height:20
	fn nurmsSubToggleAll boolean =(
		local sel  = selection as array
		local obj = objects as array
		if sel.count != 0 then
		(
			for o in sel where classof o.baseobject == Editable_Poly do o.surfsubdivide = boolean
		)
		else if obj.count != 0 then
		(
			for o in objects where not o.isHidden and classof o.baseobject == Editable_Poly do o.surfsubdivide = boolean
		)
	);
	fn nameExist arr str = (
		
		for n in arr do if n == str do return true;
		return false;
	);
	on btn_nurms_on pressed  do(nurmsSubToggleAll true)
	on btn_nurms_off pressed  do(nurmsSubToggleAll false)
	on btn_sel pressed  do(
			
		local obj = for o in objects where not o.isHidden collect o;
		local same_objects = #()
		local objects_names = #()
		local dupplicate_names = #()
		if edt_sel.text.count == 0 then (

			for o in obj do (
			
				if nameExist objects_names o.name then(
				
					if not nameExist dupplicate_names o.name do append dupplicate_names o.name
	
				) else (
				
					append objects_names o.name
				)
			)
			for o in obj where nameExist dupplicate_names o.name do append same_objects o

		) else (

			for o in obj where o.name == edt_sel.text do append same_objects o
		)
		select same_objects	
	)
	on btn_help pressed do(
		
		local msg = "\nNurms Toggle:\nWorks on selection too. Affect only visible objects.\n"	
				msg +="\nSelectby Name:\nSelect all visible objects with same name.\n" 
		messageBox msg title:"Micra Help:" beep:false 
	)
)
createDialog micraPluginDialog0001