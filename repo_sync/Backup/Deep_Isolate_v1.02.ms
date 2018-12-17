Global mcDeepIsolateDialog
Global mcDeepIsolate
Global mcDeepIsoCallbacks

fn mcDeepIsolate lvl:#upper =
(
	fn needCreateDialog =
	(
		mcDeepIsolateDialog == undefined or not mcDeepIsolateDialog.isDisplayed
	)
	if needCreateDialog() and selection.count != 0 and lvl != #lower then --Create Dialog
	(
		rollout mcDeepIsolateDialog "" width:92 height:52
		(
			-->Locals:-----------------------------------------------------------------
			local dMove = false , DmPos
			local objects_by_lvl   = #()
			local current_lvl      = 1
			--Menu:---------------------------------------------------------------------
			GroupBox grp1 "Deep Isolate" pos:[4,4] width:84 height:44
			label lbl_lvl "0" pos:[40,24] width:12 height:16
			button btn_min "<" pos:[12,24] width:24 height:16
			button btn_max ">" pos:[56,24] width:24 height:16
			-->Structures
			fn collect_visible_obj_names =
			(
				for i in objects where not i.isHidden collect i.name
			)
			fn exit_dialog =
			(
				local hidden_obj       = #()
				if objects_by_lvl.count != 0 do
				(
					for n in objects_by_lvl[1] do 
					(
						local obj = getNodeByName n
						if obj != undefined do hidden_obj += #(obj)
					)
					unhide hidden_obj dolayer:true
				)
				max tool zoomextents all
				destroyDialog mcDeepIsolateDialog 
			)
			fn hideUnselected vis_obj_names sel =
			(
				local sel_names   = for i in sel collect i.name
				local unsel_names = for n in vis_obj_names where findItem sel_names n == 0 collect n  
				local unsel_obj   = for n in unsel_names collect getNodeByName n
				hide unsel_obj dolayer:true
			)
			fn unhide_objects_by_lvl =
			(
				local hidden_obj_names = objects_by_lvl[current_lvl]
				local hidden_obj       = #()
				for n in hidden_obj_names do 
				(
					local obj = getNodeByName n
					if obj != undefined do hidden_obj += #(obj)
				)
				unhide hidden_obj dolayer:true
			)
			fn isolateByLevel lvl spin:false =
			(
				if lvl == undefined do return false
				undo off 
				(
					case lvl of
					(
						#upper: -- deepest isolation
						(
							local sel               = selection as array
							if sel.count           == 0 do return false
							local vis_obj_names     = collect_visible_obj_names()
							--format "vis_obj_names:%\n" vis_obj_names
							if vis_obj_names.count == sel.count do return false --can't isolate all object :D
							objects_by_lvl[current_lvl] = vis_obj_names -- store object before go to next level
							--go to next level (deep)
							current_lvl   += 1
							lbl_lvl.text  = current_lvl as string
							hideUnselected vis_obj_names sel
						)
						#lower:
						(
							if lbl_lvl.text == "1" do -- if bottom reached close dialog , unhide all old obj
							(
								exit_dialog()
								return OK	
							)
							
							current_lvl   -= 1
							lbl_lvl.text   = current_lvl as string
							
							if lbl_lvl.text == "1" do -- if bottom reached close dialog , unhide all old obj
							(
								exit_dialog()
								return OK	
							)
							unhide_objects_by_lvl()
						)
					)
				)
				max tool zoomextents all
			)
			-->MoveMode
			on mcDeepIsolateDialog lbuttondown pos do (dMove = true; DmPos = pos; if not keyboard.shiftPressed do pushprompt "Pres Shift To Move...")
			on mcDeepIsolateDialog lbuttonup   pos do (dMove = false; pushprompt "")
			on mcDeepIsolateDialog mouseMove   pos do
			(
				if dMove and keyboard.shiftPressed do 
				(
					if mcDialogSnappingEnabled 
					then mcDialogSnap mcDeepIsolateDialog DmPos
					else setDialogPos mcDeepIsolateDialog (mouse.screenpos - DmPos)
				)
			)
			-->Dialog start / end
			on mcDeepIsolateDialog open do
			(
				isolateByLevel #upper

				callbacks.addScript #filePreOpen "destroyDialog mcDeepIsolateDialog " id:#mcDeepIsoCallbacks
				callbacks.addScript #systemPreNew "destroyDialog mcDeepIsolateDialog " id:#mcDeepIsoCallbacks
				callbacks.addScript #systemPreReset "destroyDialog mcDeepIsolateDialog " id:#mcDeepIsoCallbacks
				
				--#sceneUndo
				--#sceneRedo
			)
			on mcDeepIsolateDialog close do
			(
				callbacks.removeScripts id:#mcDeepIsoCallbacks --Remove any existing callbacks with this ID.
				mcCall.saveIniDialog "mcDeepIsolateDialog" "Properties_2"
			)
			-->Actions
			on btn_min pressed  do
			(
				isolateByLevel #lower spin:true
			)
			on btn_max pressed  do
			(
				isolateByLevel #upper spin:true
			)
				
		)--rollout end
		mcCall.createIniDialog "mcDeepIsolateDialog" "Properties_2"
	)--vis end
	else if mcDeepIsolateDialog != undefined do --Send orders to Dialog
	(
		mcDeepIsolateDialog.isolateByLevel lvl
	)
)
/*
mcDeepIsolate lvl:#upper
mcDeepIsolate lvl:#lower
*/