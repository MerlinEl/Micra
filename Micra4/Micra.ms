----------------------------------------------------------------------------
--xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx--
                             -- Micra III --
--xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx--
----------------------------------------------------------------------------


Global mc_Dialog_A
Global mc_Dialog_B
Global mc_Dialog_C
Global mc_Dialog_D
Global mc_Dialog_E
Global mc_Dialog_F
Global mc_Dialog_G
Global mc_Dialog_H
Global mc_Dialog_I
Global mc_Dialog_J
Global mcMicraDialog
Global mcDialogEditMode
Global mcColorPaleteDialog
Global mcCreateNetDinamicDialog
Global mcGetNameAndColor
Global mcRenameUpdate
--move in to struct
Global getIconDotNet
Global mcFormSnap



-->Micra Interface
try ( mcMicraDialog.close() ) catch()
(
	-->Locals-----------------------------------------------------------------
	local sec = 60000
	local netDMove = false, netDmPos
	local last_profile = execute (mcFile.saveLoadIniSetings head:"Interface" key:"lastprofile" action:#load)
	local profiles = #("DefaultColor", "UserColor", "ForestColor", "EarthColor", "MoonColor", "SeaColor", "SunColor", "Close")
	local head_str = profiles[last_profile]
	local clr_back     = execute (mcFile.saveLoadIniSetings head:head_str key:"backcolor" action:#load)
	local clr_fore     = execute (mcFile.saveLoadIniSetings head:head_str key:"forecolor" action:#load)
	local clr_sel      = execute (mcFile.saveLoadIniSetings head:head_str key:"selected"  action:#load)
	local clr_mark     = execute (mcFile.saveLoadIniSetings head:head_str key:"marked"  action:#load)
	local clr_btn      = execute (mcFile.saveLoadIniSetings head:head_str key:"button"   action:#load)
	local clr_inact    = execute (mcFile.saveLoadIniSetings head:head_str key:"inactive"  action:#load)
	local clr_text     = execute (mcFile.saveLoadIniSetings head:head_str key:"textcolor"  action:#load)
	local clr_seltext  = execute (mcFile.saveLoadIniSetings head:head_str key:"seltext"  action:#load)
	local form_opacity = execute (mcFile.saveLoadIniSetings head:head_str key:"opacity"  action:#load)
	local bar_height      = 14
	local form_bounds     = 2
	local form_offset     = 4
	local btn_size        = 24
	local form_size       =[148, 66]
	local cp_width        = 48
	local debug = 0

	-->Components---------------------------------------------------------------------
	local form = dotNetObject "MaxCustomControls.Maxform"
	--local form = dotNetObject "Form" 
	struct MICRA_COMPONENTS_STRUCT
	(
		timer         = dotNetObject  "Timer",
		ToolTip       = dotNetObject "ToolTip",
		btnMin        = dotNetObject  "button",
		btn_help      = dotNetObject  "button",
		btn_settings  = dotNetObject  "button",
		
		btn_toolbars  = dotNetObject  "button",
		mnu_toolbars     = dotNetObject "ContextMenuStrip",
		mnu_t_items   = #(),
		
		btn_profile   = dotNetObject  "button",
		mnu_profile   = dotNetObject "ContextMenuStrip",
		mnu_p_items   = #(),
		
		edt_objName   = dotNetObject  "textBox",
		lblT          = dotNetObject  "label" ,
		cp_wirePicker = dotNetObject  "button" ,
		lbl_01        = dotNetObject  "label" ,
		lbl_02        = dotNetObject  "label" ,
		lbl_03        = dotNetObject  "label",
		lbl_bg        = dotNetObject  "label",
		tlp           = dotNetObject "TableLayoutPanel",
		mnu           = dotNetObject "ContextMenuStrip",
		mnu_close     = mnu.Items.Add "Close...",
		mnu_reload    = mnu.Items.Add "Reload...",
		dateTime      = dotNetClass "System.DateTime",
		minimized     = false,
		old_height
	)
	
	form.tag = dotNetMXSValue (MICRA_COMPONENTS_STRUCT()) --manual Lifetime
	fn defNWin = (
		local nw = DotNetObject "NativeWindow"
		nw.AssignHandle (DotNetObject "System.IntPtr" (Windows.GetMaxHWND())) 
		return nw
	)
--| --General Callbacks
	fn isGroup sel =
	(
		local found = false
		for o in selection where isGroupHead o do found = true
		return found
	)
	fn isSelectedOneGroup sel =
	(
		local heads = 0
		local nomem = 0
		for o in sel do
		(
			if     isGroupHead   o do heads += 1
			if not isGroupMember o do nomem += 1
		)
		return heads == 1 and nomem == 1
	)
	fn mcGetNameAndColor =
	(
--print "callbacks get name and color"
		local mcs = mcMicraDialog.tag.value
		local sel = selection as array

		if sel.count == 1 then
		(
			if mcs.edt_objName.readOnly != false do mcs.edt_objName.readOnly = false
				--if mcs.edt_objName.font.bold  != false do mcs.edt_objName.font.bold    = false
			mcs.edt_objName.text         = sel[1].name 
			mcs.cp_wirePicker.backcolor  = netDrColor sel[1].wirecolor
		)
		else if isSelectedOneGroup sel then
		(
			if mcs.edt_objName.readOnly  != false do mcs.edt_objName.readOnly = false
				--if mcs.edt_objName.font.bold    != true   do mcs.edt_objName.font.bold    = true
			mcs.edt_objName.text          = (for o in sel where isGroupHead o collect o.name)[1] 
			mcs.cp_wirePicker.backcolor       = netDrColor sel[1].wirecolor
		)
		else if sel.count > 1 then 
		(
			local selCount = (for i in selection where not isGroupMember i collect i).count
			if mcs.edt_objName.readOnly != true do mcs.edt_objName.readOnly  = true
				--if mcs.edt_objName.font.bold    != false do mcs.edt_objName.font.bold = false
			mcs.edt_objName.text         = (selCount as string)+ " Objects Selected" 
			mcs.cp_wirePicker.backcolor  = netDrColor sel[1].wirecolor
		)
		else
		(
			if mcs.edt_objName.readOnly != true do mcs.edt_objName.readOnly  = true
			--mcs.edt_objName.enabled    = false
				--if mcs.edt_objName.font.bold     != false do mcs.edt_objName.font.bold = false
			mcs.edt_objName.text         = ""
			mcs.cp_wirePicker.backcolor  = netDrColor clr_seltext
		)
	)
	fn mcRenameUpdate = --Updating "EditBox text" when CommandPanel name is changed. EditBox is not focused!
	(
		local mcs = mcMicraDialog.tag.value
		local sel = selection as array
		
		if sel.count == 1
		then (mcs.edt_objName.text = sel[1].name) 
		else if isGroup sel then 
		(
			mcs.edt_objName.text = (for o in sel where isGroupHead o collect o)[1].name
		)
		else (mcs.edt_objName.text = "")

--format "callbacks rename update:%\n"	mcs.edt_objName.text	
--format "focused:%\n" mcs.edt_objName.Focused
	)
	fn objNameChanges s a =
	(
--format "renaming node:%\n" a
		if s.text.count > 0 and s.Focused do
		(
			-- Rename
			local sel = selection as array
			if sel.count == 1
			then sel[1].name = s.text
			else if isGroup sel then (for o in sel where isGroupHead o collect o)[1].name = s.text
		)
	)
	fn onPickerMouseClick s a =
	(
		if classOf mcColorPaleteDialog == dotNetObject and not mcColorPaleteDialog.isDisposed
		then (mcColorPaleteDialog.show())	
		else (mcFileInVersion "Color_Palete")
	)
--||	
	fn onGotFocus = 
	(	
		suspendEditing which:CommandPanel
		enableAccelerators = false
	)
	fn onLostFocus = 
	(
		enableAccelerators = true
		resumeEditing which:CommandPanel
		CompleteRedraw()
	)
	fn loadMicraDialogs =
	(
		if not doesFileExist mcTempProfileIni do return false
		
		local P1_Dialogs = getINISetting mcTempProfileIni "Properties_1" 
		for i in P1_Dialogs where (mcCall.getIniDataFromArray mcTempProfileIni "Properties_1" i 1) == true do
		(
			mcCreateNetDinamicDialog i
		)
	)
	fn onOpenForm s a = 
	(
		--print "micra open"
		loadMicraDialogs()
		callbacks.removeScripts id:#mcGeneralCall
		callbacks.addScript #selectionSetChanged "mcGetNameAndColor() " id:#mcGeneralCall
		callbacks.addScript #nodeRenamed "mcRenameUpdate() " id:#mcGeneralCall
	)
	fn onCloseForm s a = 
	(
		--print "micra closed"
		s.tag.value.timer.stop()
		callbacks.removeScripts id:#mcGeneralCall
		mcFile.saveIniDialog s "Properties_2" s.name
		fileIn (mcPath() + "_Unloader.ms")
	)
	fn changeBackcolor s a = (s.backColor = netDrColor clr_fore)
	fn minMaxForm s a =
	(
		local form = s.parent
		form.tag.value.minimized = not form.tag.value.minimized
		local btnMin = form.tag.value.btnMin
		local tlp    = form.tag.value.tlp
		if form.tag.value.minimized
		then 
		(
			btnMin.text = "+"
			form.tag.value.old_height = form.height 
			form.height = bar_height + form_bounds*2
			tlp.hide()
		)
		else
		(
			btnMin.text = "-"
			form.height = form.tag.value.old_height
			tlp.show()
		)
	)
--|	--Form move
	fn onLblTMouseMove s a = 
	(
		if netDMove do ( mcFormSnap s.parent netDmPos ) --dragForm
	)
	fn onLblTMouseDown s a = 
	(
		if a.Button == a.Button.left do --enableDrag
		(
			s.parent.cursor.current = netCursors.Hand
			netDmPos = [s.parent.MousePosition.x, s.parent.MousePosition.y] - [s.parent.left, s.parent.top] 
			netDMove = true 
		)
	)
	fn onLblTMouseUp s a = 
	(
		netDMove = false --disableDrag
		if a.Button == a.Button.right then 
		(
			local mnu = s.parent.tag.value.mnu
			mnu.tag = s.parent
			mnu.Show (s.PointToScreen a.location)--(netDrPoint a.location))
		)
	)
--||
	fn getDateTime s a =
	(
		local mcs = s.tag.tag.value
		mcs.lblT.text = (" " + mcs.dateTime.now.ToString "ddd. dd MMMM  HH:mm")
		mcs.ToolTip.SetToolTip mcs.lblT (mcs.dateTime.now.ToString "dddd, dd MMMM yyyy HH:mm")
	)
	fn showHideForm s a = 
	(
		local dia = execute s.tag
		if classOf dia == dotNetObject and not dia.isDisposed 
		then ( if dia.visible then dia.hide() else dia.show() )
		else (mcCreateNetDinamicDialog s.tag)
	)
	fn quitMicra s a = ( ((s.GetCurrentParent()).tag).close() ) -->Shut Down Micra
	fn reloadMicra s a =
	(
		((s.GetCurrentParent()).tag).close()
		fileIn (mcPath()+ "_Loader.ms")
	)
	fn saveCurrentProfile =
	(
		--save current pos and size for all visible dialogs to /Profile_Temp.ini
		local dia_str1 = getIniSetting mcTempProfileIni "Properties_1"
		local dia_str2 = getIniSetting mcTempProfileIni "Properties_2"
		--new dotnet fn
		for i in dia_str1 do 
		(
			local form = execute i
			if classOf form == DotnetObject do mcFile.saveIniDialog form "Properties_1" form.name
		)
		--old rollout fn -- remove
		for i in dia_str2 do 
		(
			local dia = execute i
			local active = case classOf dia of
			(
				RolloutClass:(dia != undefined and dia.isDisplayed)
				DotnetObject:(dia != undefined and dia.visible)
			)
			mcCall.saveIniDialog i "Properties_2" active:active
		)

		--write from temp to current profile
		local active_name = "Profile_"+(getIniSetting mcUserINI "Settings" "CurrentProfile") + ".ini"
		local active_file = mcPath() +"User\\"+ active_name
		if doesFileExist active_file do deleteFile active_file
		copyFile mcTempProfileIni active_file 
	)
	fn mamageProfile s a =
	(
		if s.tag == "Save"
		then saveCurrentProfile()
		else if s.tag == "Save As"
		then (mcfileInVersion "Save_Profile_As")
		else
		(
			local keys = for i = 1 to 8 collect (getIniSetting mcUserINI "Profiles" (i as string))
			local numstr = (findItem keys s.tag ) as string
			setIniSetting mcUserINI "Settings" "CurrentProfile" numstr 
			reloadMicra s a
		)
	)
--|
	--fn onMouseDown s a = (s.FlatStyle = s.FlatStyle.Standard)
	--fn onMouseLeave s a = (s.FlatStyle = s.FlatStyle.flat)
	fn onMouseClick s a =
	(

		local msc = s.parent.parent.tag.value
		--s.FlatStyle = s.FlatStyle.flat
		--print (s.PointToClient a.location).x
		--print (s.PointToScreen a.location).x
		case s.name of
		(
			"Help":(mcFileInVersion "Help")
			"Customize":
			(
				if classOf mcDialogEditMode == dotNetObject and not mcDialogEditMode.isDisposed  
				then mcDialogEditMode.show()
				else mcFileInVersion "Customize"
			)
			"Toolbars":
			(
				local mnu = msc.mnu_toolbars
				local keys = getIniSetting mcTempProfileIni "Properties_1"
				if msc.mnu_t_items.count == 0 do
				(
					mnu.BackColor = netDrColor clr_back
					mnu.ForeColor = netDrColor clr_text
					mnu.ShowImageMargin = false
					for i in keys do
					(
						local lbl = mcCall.getIniDataFromArray mcTempProfileIni "Properties_1" i 4
						itm = mnu.Items.Add lbl
						itm.tag = i
						dotnet.addeventhandler itm "Click" showHideForm
						msc.mnu_t_items += #(itm)
					)
				)
				for i = 1 to keys.count do
				(
					local enabled = (mcCall.getIniDataFromArray mcTempProfileIni "Properties_1" keys[i] 1)
					if enabled 
					then 
					(
						msc.mnu_t_items[i].backColor = netDrColor clr_mark
						msc.mnu_t_items[i].forecolor = netDrColor clr_text
					)
					else
					(
						msc.mnu_t_items[i].backColor = netDrColor clr_back
						msc.mnu_t_items[i].forecolor = netDrColor clr_inact
					)
				)
				mnu.Show (s.PointToScreen (netDrPoint a.location))
			)
			"Profiles":
			(
				local mnu = msc.mnu_profile
				mnu.tag = s.parent.parent
				local keys = for i = 1 to 8 collect (getIniSetting mcUserINI "Profiles" (i as string))
				keys += #("Save", "Save As")
				if msc.mnu_p_items.count == 0 do
				(
					mnu.BackColor = netDrColor clr_back
					mnu.ForeColor = netDrColor clr_text
					mnu.ShowImageMargin = false
					for i in keys do
					(
						itm = mnu.Items.Add (i+"...")
						itm.tag = i
						dotnet.addeventhandler itm "Click" mamageProfile
						msc.mnu_p_items += #(itm)
					)
				)
				local cp_num = execute (getIniSetting mcUserINI "Settings" "CurrentProfile")
				for i = 1 to keys.count-2 do
				(
					if i != cp_num 
					then
					(
						msc.mnu_p_items[i].backColor = netDrColor clr_back
						msc.mnu_p_items[i].forecolor = netDrColor clr_text
					)
					else
					(
						msc.mnu_p_items[i].backColor = netDrColor clr_back
						msc.mnu_p_items[i].forecolor = netDrColor green
					)
				)
				mnu.Show (s.PointToScreen (netDrPoint a.location))	
			)
		)
	)
	fn addButtons mcs form =
	(
		local lbl = #(mcs.lbl_01)
		local btn = #(mcs.btn_help, mcs.btn_settings, mcs.btn_toolbars, mcs.btn_profile)
		local tip = #("Help", "Customize", "Toolbars", "Profiles")
		for i in lbl do
		(
			i.size = netDrSize [(gw.getTextExtent "Micra III   ").x, btn_size]
			i.BackColor = netDrColor clr_back
			i.ForeColor = netDrColor clr_text
			i.margin =  dotnetobject "padding" 0
			i.text = "Micra III" 
			i.TextAlign = i.TextAlign.MiddleCenter
		)

		local cnt = 0
		local biconnum = #(153, 154, 155, 156)
		for i in btn do
		(
			i.size  = netDrSize [btn_size, btn_size]
			i.FlatStyle = i.FlatStyle.flat
			i.FlatAppearance.BorderColor = netDrColor clr_back
			i.FlatAppearance.BorderSize = 1
			i.margin =  dotnetobject "padding" 0
			i.name = tip[ cnt += 1 ]
			i.image = getIconDotNet biconnum[ cnt ]
			mcs.ToolTip.SetToolTip i i.name
			dotNet.addEventHandler i "MouseClick" onMouseClick
			--dotNet.addEventHandler i "MouseDown" onMouseDown
			--dotNet.addEventHandler i "MouseLeave" onMouseLeave
		)
		mcs.tlp.controls.addRange (lbl + btn)
	)
--||
	fn inicializeInterface form mcs =
	(
		form.name = "mcMicraDialog"
		form.ControlBox  = false --hide main bar
		local fpos = (mcCall.getIniDataFromArray mcTempProfileIni "Properties_2" "mcMicraDialog" 2)
		if fpos == undefined do fpos = (mcCall.getIniDataFromArray mcDefaultProfileIni "Properties_2" "mcMicraDialog" 2)
		form.StartPosition = form.StartPosition.Manual
		
		form.MinimumSize = netDrSize form_size
		form.MaximumSize = netDrSize form_size
		
		form.bounds = netDrRect fpos form_size
		form.FormBorderStyle = form.FormBorderStyle.none
		form.BackColor = netDrColor clr_fore --yellow
		form.ShowInTaskbar = false
		form.opacity = form_opacity
		
		mcs.ToolTip.IsBalloon = true
		mcs.ToolTip.BackColor = netDrColor clr_back
		mcs.ToolTip.ForeColor = netDrColor clr_text
		mcs.ToolTip.AutoPopDelay = 5000
		mcs.ToolTip.InitialDelay = 400
		mcs.ToolTip.ReshowDelay = 100
		mcs.ToolTip.ShowAlways = true
		
		mcs.mnu.BackColor = netDrColor clr_back
		mcs.mnu.ForeColor = netDrColor clr_text
		mcs.mnu.ShowImageMargin = false
		
		mcs.timer.interval  = sec
		mcs.timer.tag = form
		
		mcs.btnMin.bounds = netDrRect [form_size.x - btn_size - form_offset/2, form_offset/2] [btn_size, bar_height]
		mcs.btnMin.FlatStyle = mcs.btnMin.FlatStyle.flat
		mcs.btnMin.BackColor = netDrColor clr_btn --(color 124 196 22)
		mcs.btnMin.ForeColor = netDrColor (mcUIColors.get #text)
		mcs.btnMin.text = "-"
		
		mcs.edt_objName.bounds = netDrRect [form_offset/2,bar_height+form_offset] [form_size.x - form_offset*2 - btn_size, bar_height]
		mcs.edt_objName.BackColor = netDrColor clr_back
		mcs.edt_objName.ForeColor = netDrColor clr_seltext
		mcs.edt_objName.BorderStyle = mcs.edt_objName.BorderStyle.FixedSingle
		
		mcs.cp_wirePicker.FlatStyle = mcs.cp_wirePicker.FlatStyle.flat
		mcs.cp_wirePicker.FlatAppearance.BorderColor = netDrColor clr_back
		mcs.cp_wirePicker.FlatAppearance.BorderSize = 1
		mcs.cp_wirePicker.bounds  = netDrRect [form_size.x- btn_size- form_offset, bar_height+form_offset] [btn_size+2, 20]
		mcs.cp_wirePicker.backColor = netDrColor clr_seltext

		mcs.lblT.bounds = netDrRect [form_offset/2, form_offset/2] [form_size.x - form_offset, bar_height]
		mcs.lblT.BackColor = netDrColor clr_back
		mcs.lblT.ForeColor = netDrColor clr_text

		mcs.tlp.bounds = netDrRect [form_offset/2, bar_height*2+form_offset*3] [form_size.x - form_offset, btn_size]
		mcs.tlp.backColor = netDrColor clr_btn
		--mcs.tlp.AutoSize = true
		mcs.tlp.ColumnCount = 6
		
		--add handlers
		dotNet.addeventhandler mcs.mnu_close "Click" quitMicra
		dotNet.addeventhandler mcs.mnu_reload "Click" reloadMicra
		dotNet.addEventHandler mcs.lblT   "MouseMove" onLblTMouseMove
		dotNet.addEventHandler mcs.lblT   "MouseDown" onLblTMouseDown 
		dotNet.addEventHandler mcs.lblT   "MouseUp"   onLblTMouseUp
		dotnet.addEventHandler mcs.timer "tick" getDateTime
		dotNet.addEventHandler mcs.btnMin "MouseClick"  minMaxForm
		dotnet.addEventHandler form "Shown" onOpenForm
		dotnet.addEventHandler form "Closed" onCloseForm
		dotnet.AddEventHandler form "BackColorChanged" changeBackcolor --thanks cyfer
		dotNet.addEventHandler mcs.edt_objName "GotFocus" onGotFocus
		dotNet.addEventHandler mcs.edt_objName "LostFocus" onLostFocus
		dotNet.addEventHandler mcs.edt_objName "TextChanged" objNameChanges
		dotNet.addeventhandler mcs.cp_wirePicker "MouseClick" onPickerMouseClick
		
		--add components in to form
		addButtons mcs form
		form.controls.addRange(#(mcs.btnMin, mcs.edt_objName, mcs.cp_wirePicker, mcs.lblT, mcs.tlp))
		mcs.timer.start()
		getDateTime mcs.timer undefined
	)
	inicializeInterface form form.tag.value
	mcMicraDialog = form
	--mcMicraDialog.showModeless()
	--mcMicraDialog.show(WindowWrapper)
	-- Shows the form with the specified owner (MAX) to the user (creatd by lo)
	local nw = defNWin()
	mcMicraDialog.show(nw) 
	nw.ReleaseHandle()
)