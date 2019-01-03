----------------------
-- DeepIsolate 2 --
---------------------
--    Rene 2012    --

Global mcDeepIsolateDialog
Global mcDeepIsolate
Global mcDeepIsoCallbacks
Global netDrRect
Global netDrSize
Global netDrColor
Global getIconDotNet

--> debug mode
try ( mcDeepIsolateDialog.close()) catch()
mcDeepIsolateDialog = undefined
--<
	
fn mcDeepIsolate lvl:#upper =
(
	fn alowIsolate =
	(
		local sel = selection as array
		if sel.count == 0 do return false
		local vis_obj_names = for i in objects where not i.isHidden collect i.name
		if vis_obj_names.count == sel.count 
			then return false --can't isolate all object :D
			else return true
	)
	
	
	if (mcDeepIsolateDialog == undefined or mcDeepIsolateDialog.isDisposed) and selection.count != 0 and lvl == #upper and alowIsolate()
	then --Create Dialog
	(
		--print "tvorba dialogu"
		-->Components---------------------------------------------------------------------
		local form = dotNetObject "MaxCustomControls.Maxform"
		--<
		struct ICON_COMPONENTS_STRUCT
		(
			--variables
			ToolTip   = dotNetObject "ToolTip",
			lblT        = dotNetObject "label",
			lbl_lvl      = dotNetObject "label",
			btn_min = dotNetObject "button", 
			btn_max = dotNetObject "button", 
			netDMove = false, 
			netDmPos,
			--> Isolate Locals
			objects_by_lvl   = #(),
			current_level = 1,
			last_profile = execute (mcFile.saveLoadIniSetings head:"Interface" key:"lastprofile" action:#load),
			profiles = #("DefaultColor", "UserColor", "ForestColor", "EarthColor", "MoonColor", "SeaColor", "SunColor", "Close"),
			head_str = profiles[last_profile],
			clr_back     = execute (mcFile.saveLoadIniSetings head:head_str key:"backcolor" action:#load),
			clr_fore     = execute (mcFile.saveLoadIniSetings head:head_str key:"forecolor" action:#load),
			clr_sel      = execute (mcFile.saveLoadIniSetings head:head_str key:"selected"  action:#load),
			clr_mark     = execute (mcFile.saveLoadIniSetings head:head_str key:"marked"  action:#load),
			clr_btn      = execute (mcFile.saveLoadIniSetings head:head_str key:"button"   action:#load),
			clr_inact    = execute (mcFile.saveLoadIniSetings head:head_str key:"inactive"  action:#load),
			clr_text     = execute (mcFile.saveLoadIniSetings head:head_str key:"textcolor"  action:#load),
			clr_seltext  = execute (mcFile.saveLoadIniSetings head:head_str key:"seltext"  action:#load),
			form_opacity = execute (mcFile.saveLoadIniSetings head:head_str key:"opacity"  action:#load),
			bar_height      = 14,
			form_bounds     = 2,
			form_offset     = 2, --border line
			btn_size        = 24,
			form_size       =[84, 44],
			debug = 0,
			--<
			-->Isolate Functions
			fn collect_visible_obj_names =
			(
				for i in objects where not i.isHidden collect i.name
			),
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
				mcDeepIsolateDialog.hide() 
			),
			fn hideUnselected vis_obj_names sel =
			(
				local sel_names   = for i in sel collect i.name
				local unsel_names = for n in vis_obj_names where findItem sel_names n == 0 collect n  
				local unsel_obj   = for n in unsel_names collect getNodeByName n
				hide unsel_obj dolayer:true
			),
			fn unhide_objects_by_lvl =
			(
				local old_selection = selection as array
				local hidden_obj_names = objects_by_lvl[current_level]
				local hidden_obj       = #()
				for n in hidden_obj_names do 
				(
					local obj = getNodeByName n
					if obj != undefined do hidden_obj += #(obj)
				)
				unhide hidden_obj dolayer:true
				selectmore hidden_obj
				max zoomext sel 
				select old_selection
			),
			fn isolateByLevel lvl =
			(
				if lvl == undefined do return false
				undo off 
				(
					case lvl of
					(
						#upper: -- deepest isolation
						(
							--print "isoluji"
							local sel               = selection as array
							if sel.count           == 0 do return false
							local vis_obj_names = collect_visible_obj_names()
							--format "vis_obj_names:%\n" vis_obj_names
							if vis_obj_names.count == sel.count do return false --can't isolate all object :D
							objects_by_lvl[current_level] = vis_obj_names -- store object before go to next level
							--go to next level (deep)
							current_level  += 1
							lbl_lvl.text  = current_level as string
							hideUnselected vis_obj_names sel
							max zoomext sel  --max tool zoomextents all
						)
						#lower:
						(
							--print "unisoluji"
							if current_level > 2  -- if bottom not reached
							then
							(
								current_level   -= 1
								lbl_lvl.text   = current_level as string
								unhide_objects_by_lvl()
							)	
							else if mcDeepIsolateDialog.visible do --close dialog , unhide all old obj
							(
								current_level   -= 1
								exit_dialog()
								return OK	
							)
							--print current_level
						)
					)
				)
			)
		)
		--manual Lifetime	
		form.tag = dotNetMXSValue (ICON_COMPONENTS_STRUCT()) 
		
		fn inicializeInterface form mcs =
		(
			--|	--Form move
			fn onLblTMouseMove s a = 
			(
				local form = s.parent
				if form.tag.value.netDMove do --dragForm
				(
					mcFormSnap form form.tag.value.netDmPos
				)
			)
			fn onLblTMouseDown s a = 
			(
				if a.Button == a.Button.left do --enableDrag
				(
					local form = s.parent
					form.cursor.current = netCursors.Hand
					form.tag.value.netDmPos = [form.MousePosition.x, form.MousePosition.y] - [form.left, form.top] 
					form.tag.value.netDMove = true 
				)
			)
			fn onLblTMouseUp s a = 
			(
				local form = s.parent
				form.tag.value.netDMove = false --disableDrag
				if a.Button == a.Button.right then form.hide()
			)
			--||
			--|	--Form actions	
			fn setBackcolor s a = (s.backcolor = netDrColor s.tag.value.clr_btn)
			fn onOpenForm s a = 
			(			
				--print "open form"
				s.tag.value.current_level = 1
				s.tag.value.lbl_lvl.text = "1"
				s.tag.value.isolateByLevel #upper

				callbacks.addScript #filePreOpen "mcDeepIsolateDialog.close()" id:#mcDeepIsoCallbacks
				callbacks.addScript #systemPreNew "mcDeepIsolateDialog.close()" id:#mcDeepIsoCallbacks
				callbacks.addScript #systemPreReset "mcDeepIsolateDialog.close()" id:#mcDeepIsoCallbacks
			
				--#sceneUndo
				--#sceneRedo
			)
			fn onCloseForm s a = 
			(
				callbacks.removeScripts id:#mcDeepIsoCallbacks --Remove any existing callbacks with this ID.
				mcFile.saveIniDialog s "Properties_2" s.name
			)
			fn goUp s a = (s.parent.tag.value.isolateByLevel #lower)
			fn goDown s a = (s.parent.tag.value.isolateByLevel #upper)
			--||

			--<
			form.name = "mcDeepIsolateDialog"
			form.ControlBox  = false --hide main bar
			local fpos = (mcCall.getIniDataFromArray mcTempProfileIni "Properties_2" "mcDeepIsolateDialog" 2)
			if fpos == undefined do fpos = (mcCall.getIniDataFromArray mcDefaultProfileIni "Properties_2" "mcDeepIsolateDialog" 2)
			form.StartPosition = form.StartPosition.Manual
			form.FormBorderStyle = form.FormBorderStyle.none
			form.bounds = netDrRect fpos mcs.form_size
			form.MinimumSize = netDrSize [mcs.btn_size*2, mcs.bar_height]
			--form.MaximumSize = netDrSize [btn_size*10, btn_size*10]
			--form.BackColor = netDrColor blue--clr_back  --wont work
			form.ShowInTaskbar = false
			form.opacity = mcs.form_opacity
			
			
			mcs.lblT.bounds = netDrRect [mcs.form_offset, mcs.form_offset] [mcs.form_size.x - mcs.form_offset*2 , mcs.bar_height]
			mcs.lblT.BackColor = netDrColor mcs.clr_back
			mcs.lblT.ForeColor = netDrColor mcs.clr_text
			mcs.lblT.Text = "Deep Isolate II:"
			
			mcs.lbl_lvl.bounds = netDrRect [mcs.form_size.x/2 - mcs.btn_size/2, mcs.bar_height+mcs.form_offset*2] [mcs.btn_size, mcs.btn_size]
			mcs.lbl_lvl.Text = "1"
			mcs.lbl_lvl.TextAlign = mcs.lbl_lvl.TextAlign.MiddleCenter --(dotnetClass "Drawing.ContentAlignment").MiddleCenter
			mcs.lbl_lvl.BackColor = netDrColor mcs.clr_back
			mcs.lbl_lvl.ForeColor = netDrColor mcs.clr_text
			
			mcs.btn_min.bounds = netDrRect [mcs.form_offset, mcs.bar_height+mcs.form_offset*2] [mcs.btn_size, mcs.btn_size]
			mcs.btn_min.flatstyle = mcs.btn_min.flatstyle.flat
			mcs.btn_min.Image = getIconDotNet 176
			--mcs.btn_min.FlatAppearance.BorderSize = 0
			--mcs.btn_min.BackColor = netDrColor mcs.clr_back
			--mcs.btn_min.Text = "<"
			
			mcs.btn_max.bounds = netDrRect [mcs.form_size.x - mcs.btn_size - mcs.form_offset, mcs.bar_height+mcs.form_offset*2] [mcs.btn_size, mcs.btn_size]
			mcs.btn_max.flatstyle = mcs.btn_max.flatstyle.flat
			mcs.btn_max.Image = getIconDotNet 177
			--mcs.btn_max.FlatAppearance.BorderColor = netDrColor mcs.clr_back
			--mcs.btn_max.BackColor = netDrColor mcs.clr_back
			--mcs.btn_max.Text = ">"
			
			--add handlers
			dotnet.addEventHandler form "Shown" onOpenForm
			dotnet.addEventHandler form "Closed" onCloseForm
			dotnet.addEventHandler form "VisibleChanged" onCloseForm
			dotnet.AddEventHandler form "BackColorChanged" setBackcolor
			--dotNet.addEventHandler form  "MouseMove" drawToForm
			dotNet.addEventHandler mcs.lblT   "MouseMove" onLblTMouseMove
			dotNet.addEventHandler mcs.lblT   "MouseDown" onLblTMouseDown 
			dotNet.addEventHandler mcs.lblT   "MouseUp"   onLblTMouseUp
			
			dotNet.addEventHandler mcs.btn_min   "MouseUp"   goUp
			dotNet.addEventHandler mcs.btn_max   "MouseUp"   goDown
			
			--add controls
			form.controls.addRange #(mcs.lblT, mcs.lbl_lvl, mcs.btn_min, mcs.btn_max)
		)
		inicializeInterface form form.tag.value
		mcDeepIsolateDialog = form
		mcDeepIsolateDialog.showModeless()
		mcDeepIsolateDialog.tag.value.lblT.focus() --remove black border from selected button
		enableAccelerators = true --set focus to viewport
	)
	else if mcDeepIsolateDialog != undefined and not mcDeepIsolateDialog.visible and not mcDeepIsolateDialog.isDisposed and selection.count != 0 and lvl == #upper and alowIsolate()
	then --Show Dialog
	(
		--print "zobrazeni dialogu"
		mcDeepIsolateDialog.showModeless()
		mcDeepIsolateDialog.tag.value.isolateByLevel lvl
		mcDeepIsolateDialog.tag.value.lblT.focus() --remove black border from selected button
		enableAccelerators = true --set focus to viewport
	)
	else if mcDeepIsolateDialog != undefined do --Isolate / Unisolate
	(
		print "manipulace"
		mcDeepIsolateDialog.tag.value.isolateByLevel lvl
	)
)


/*
mcDeepIsolate lvl:#upper
mcDeepIsolate lvl:#lover
*/