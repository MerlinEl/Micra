----------------------
-- DeepIsolate 2 --
---------------------
--    Rene 2012    --

Global mcDeepIsolateDialog
Global mcDeepIsolate
Global mcDeepIsoCallbacks
Global netDrRect
Global netDrSize
Global getIconDotNet

--> debug mode
try ( mcDeepIsolateDialog.close()) catch()
mcDeepIsolateDialog = undefined
--<
	
fn mcDeepIsolate lvl:#upper =
(
	--Isolate objects
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
			fn unhide_all_isolated =
			(
				local old_selection = selection as array
				local hidden_obj       = #()
				for l in objects_by_lvl do for n in l do
				(
					local obj = getNodeByName n
					if obj != undefined do hidden_obj += #(obj)
				)
				unhide hidden_obj dolayer:true
				selectmore hidden_obj
				max zoomext sel 
				select old_selection
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
			fn manageObjects type =
			(
				case type of
				(
					#hide :
					(
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
						return true
					)
					#show:
					(
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
							unhide_all_isolated()
							mcDeepIsolateDialog.hide() 
							return OK	
						)
					)
				)
			),
			fn manageGeometry type =
			(
				local obj = selection[1]
				if classOf obj != Editable_Poly do return false
--format "Deep isolate > sel obj:% state:%" obj type
				case type of
				(
					#hide :
					(
						local face_sel = polyOp.getFaceSelection obj
						if face_sel.numberset == 0 do return false
						max select invert
						obj.hide #Face
						polyop.setFaceSelection obj face_sel
					)
					#show:
					(
						--local all_hidden_faces = polyop.getHiddenFaces obj 
						local face_sel = polyOp.getFaceSelection obj
						obj.unhideAll #Face
						polyop.setFaceSelection obj #()
						--completeRedraw()
						max zoomext sel
						polyop.setFaceSelection obj face_sel
					)
				)
				return true
			),
			fn isolateByLevel lvl =
			(
--print "1"
				if lvl == undefined do return false
				undo off 
				(
					case lvl of
					(
						#upper: -- deepest isolation
						(
							--print "isoluji"
							if subobjectlevel != undefined and (subobjectlevel == 4 or subobjectlevel == 5)
							then (if not manageGeometry #hide do return false)
							else  (if not manageObjects #hide do return false)
	
							max zoomext sel  --max tool zoomextents all
						)
						#lower:
						(
							--print "unisoluji"
							if subobjectlevel != undefined and (subobjectlevel == 4 or subobjectlevel == 5)
							then manageGeometry #show
							else manageObjects #show
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
					mcDialog.snapForm form form.tag.value.netDmPos
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
				--print "close form"
				s.tag.value.unhide_all_isolated()
				s.tag.value.objects_by_lvl = #()
				callbacks.removeScripts id:#mcDeepIsoCallbacks --Remove any existing callbacks with this ID.
				mcFile.saveDialogSettings s.name "Properties_2"
			)
			fn goUp s a = (s.parent.tag.value.isolateByLevel #lower)
			fn goDown s a = (s.parent.tag.value.isolateByLevel #upper)
			--||

			--<
			form.name = "mcDeepIsolateDialog"
			form.ControlBox  = false --hide main bar
			local fpos = execute (mcFile.readSettings Micra.UserProfile ("Properties_2/mcDeepIsolateDialog") type:"pos")
			if classOf fpos != Point2 do fpos = [0, 0]
			form.StartPosition = form.StartPosition.Manual
			form.FormBorderStyle = form.FormBorderStyle.none
			form.bounds = netDrRect fpos mcs.form_size
			form.MinimumSize = netDrSize [mcs.btn_size*2, mcs.bar_height]
			--form.MaximumSize = netDrSize [btn_size*10, btn_size*10]
			--form.BackColor = netDrColor blue--clr_back  --wont work
			form.ShowInTaskbar = false
			form.opacity = mcDotnet.uiColor #opacity
			
			
			mcs.lblT.bounds = netDrRect [mcs.form_offset, mcs.form_offset] [mcs.form_size.x - mcs.form_offset*2 , mcs.bar_height]
			mcs.lblT.BackColor = mcDotnet.uiColor #back
			mcs.lblT.ForeColor = mcDotnet.uiColor #text
			mcs.lblT.Text = "Deep Isolate II:"
			
			mcs.lbl_lvl.bounds = netDrRect [mcs.form_size.x/2 - mcs.btn_size/2, mcs.bar_height+mcs.form_offset*2] [mcs.btn_size, mcs.btn_size]
			mcs.lbl_lvl.Text = "1"
			mcs.lbl_lvl.TextAlign = mcs.lbl_lvl.TextAlign.MiddleCenter --(dotnetClass "Drawing.ContentAlignment").MiddleCenter
			mcs.lbl_lvl.BackColor = mcDotnet.uiColor #back
			mcs.lbl_lvl.ForeColor = mcDotnet.uiColor #text
			
			mcs.btn_min.bounds = netDrRect [mcs.form_offset, mcs.bar_height+mcs.form_offset*2] [mcs.btn_size, mcs.btn_size]
			mcs.btn_min.flatstyle = mcs.btn_min.flatstyle.flat
			mcs.btn_min.Image = getIconDotNet 176
			--mcs.btn_min.FlatAppearance.BorderSize = 0
			--mcs.btn_min.BackColor = mcDotnet.uiColor #back
			--mcs.btn_min.Text = "<"
			
			mcs.btn_max.bounds = netDrRect [mcs.form_size.x - mcs.btn_size - mcs.form_offset, mcs.bar_height+mcs.form_offset*2] [mcs.btn_size, mcs.btn_size]
			mcs.btn_max.flatstyle = mcs.btn_max.flatstyle.flat
			mcs.btn_max.Image = getIconDotNet 177
			--mcs.btn_max.FlatAppearance.BorderColor = mcDotnet.uiColor #back
			--mcs.btn_max.BackColor = mcDotnet.uiColor #back
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