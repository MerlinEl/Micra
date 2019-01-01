----------------------------------------------------------------------------
--xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx--

                             -- Micra VI --
							 
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
Global mcCreateNetDynamicDialog
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
	local bar_height = 14
	local form_bounds  = 2
	local form_offset  = 4
	local btn_size   = 24
	local form_size =[148, 82]
	local cp_width  = 48
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
		old_height,
		border_offset  = 2,
		bar_height      = 14
	)
	
	form.tag = dotNetMXSValue (MICRA_COMPONENTS_STRUCT()) --manual Lifetime
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
			mcs.cp_wirePicker.backcolor  = netDrColor (mcUIColors.get #seltext)
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
	fn onPickerMouseClick s a = (Micra.fileInVersion "Color_Palete")
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
		if not doesFileExist Micra.TempProfileIni do return false
		
		local P1_Dialogs = getINISetting Micra.TempProfileIni "Properties_1" 
		for i in P1_Dialogs where (mcFile.getIniDataFromArray Micra.TempProfileIni "Properties_1" i 1) == true do
		(
			mcCreateNetDynamicDialog i
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
		mcFile.saveIniDialog s.name "Properties_2"
		Micra.Unload self:false --false self, prevent depency loop
	)
	fn changeBackcolor s a = ( 
	
		s.backColor = netDrColor (mcUIColors.get #fore) 
	)
	fn minMaxForm s a =
	(
		local form = s.parent
		local mcs = form.tag.value
		mcs.minimized = not mcs.minimized
		if mcs.minimized then (
			
			mcs.btnMin.text = "+"
			mcs.old_height = form.height 
			mcs.tlp.hide()
			mcs.edt_objName.hide()
			mcs.cp_wirePicker.hide()
			form.height = mcs.bar_height + mcs.border_offset*2
		) else (
			
			mcs.btnMin.text = "-"
			form.height = mcs.old_height
			mcs.tlp.show()
			mcs.edt_objName.show()
			mcs.cp_wirePicker.show()
		)
	)
--|	--Form move
	fn onLblTMouseMove s a = 
	(
		if netDMove do ( mcDialog.snapForm s.parent netDmPos ) --dragForm
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
		else (mcCreateNetDynamicDialog s.tag)
	)
	fn quitMicra s a = ( Micra.unload() ) --> Shut Down Micra
	fn reloadMicra s a =( Micra.Reload() ) --> Restart Micra
	
	--save registred dialogs pos and size to current profile
	fn saveCurrentProfile = (
		--get all registred dialogs
		local dia_names_1 = getIniSetting Micra.TempProfileIni "Properties_1" --get micra dialogs
		local dia_names_2 = getIniSetting Micra.TempProfileIni "Properties_2" --get all other dialogs
		--save all visible dialogs to /Profile_Temp.ini
		for n in dia_names_1 do mcFile.saveIniDialog n "Properties_1"
		for n in dia_names_2 do mcFile.saveIniDialog n "Properties_2"
		--override current profile with temp one
		local current_profile_index = getIniSetting Micra.UserSettings "Settings" "CurrentProfile"
		local active_file = Micra.UserDir + "Profile_"+ current_profile_index + ".ini"
		if doesFileExist active_file do deleteFile active_file
		copyFile Micra.TempProfileIni active_file 
		local current_profile_name = getIniSetting Micra.UserSettings "Profiles" current_profile_index
		format "% > saveCurrentProfile > Profile:[%] has been Saved!\n" Micra.version current_profile_name
	)

	fn manageProfile s a =
	(
		local menu_item_name = s.tag
		case menu_item_name of (	
		
			"Save":saveCurrentProfile()
			"Manage":Micra.fileInVersion "Manage_Profiles"
			default:( --for any other names  - -> load profile by name

				local keys = for i = 1 to 8 collect (getIniSetting Micra.UserSettings "Profiles" (i as string)) --collect all profile names
				local profile_index = (findItem keys menu_item_name ) as string --find profile index by name
				setIniSetting Micra.UserSettings "Settings" "CurrentProfile" profile_index --save desired profile index
				reloadMicra s a
			)
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
			"Help":(Micra.fileInVersion "Help")
			"Customize":
			(
				if classOf mcDialogEditMode == dotNetObject and not mcDialogEditMode.isDisposed  
				then mcDialogEditMode.show()
				else Micra.fileInVersion "Customize"
			)
			"Toolbars":
			(
				local mnu = msc.mnu_toolbars
				local keys = getIniSetting Micra.TempProfileIni "Properties_1"
				if msc.mnu_t_items.count == 0 do
				(
					mnu.BackColor = netDrColor (mcUIColors.get #back)
					mnu.ForeColor = netDrColor (mcUIColors.get #text)
					mnu.ShowImageMargin = false
					for i in keys do
					(
						local lbl = mcFile.getIniDataFromArray Micra.TempProfileIni "Properties_1" i 4
						itm = mnu.Items.Add lbl
						itm.tag = i
						dotnet.addeventhandler itm "Click" showHideForm
						msc.mnu_t_items += #(itm)
					)
				)
				for i = 1 to keys.count do
				(
					local enabled = (mcFile.getIniDataFromArray Micra.TempProfileIni "Properties_1" keys[i] 1)
					if enabled 
					then 
					(
						msc.mnu_t_items[i].backColor = netDrColor (mcUIColors.get #mark)
						msc.mnu_t_items[i].forecolor = netDrColor (mcUIColors.get #text)
					)
					else
					(
						msc.mnu_t_items[i].backColor = netDrColor (mcUIColors.get #back)
						msc.mnu_t_items[i].forecolor = netDrColor (mcUIColors.get #inact)
					)
				)
				mnu.Show (s.PointToScreen (netDrPoint a.location))
			)
			"Profiles":
			(
				local mnu = msc.mnu_profile
				mnu.tag = s.parent.parent
				local profile_names = for i = 1 to 8 collect (getIniSetting Micra.UserSettings "Profiles" (i as string))
				local command_names = #("Save", "Manage")
				local menu_items_names = mcArray.mergeClone profile_names command_names
				--Add menu components for first time
				if msc.mnu_p_items.count == 0 do
				(
					--Add separator at begin
					mnu.Items.Add(dotNetObject "System.Windows.Forms.ToolStripSeparator")
					--setup skin
					mnu.BackColor = netDrColor (mcUIColors.get #back)
					mnu.ForeColor = netDrColor (mcUIColors.get #text)
					mnu.ShowImageMargin = false
					for n in menu_items_names do (
					
						--add separator before "Save" item
						if n == "Save" do mnu.Items.Add(dotNetObject "System.Windows.Forms.ToolStripSeparator")
						--add menu items
						itm = mnu.Items.Add (n+"...")
						itm.tag = n
						dotnet.addeventhandler itm "Click" manageProfile
						msc.mnu_p_items += #(itm)	
					)
					--Add separator at end
					mnu.Items.Add(dotNetObject "System.Windows.Forms.ToolStripSeparator")
				)
				--mark last used profile to green
				local cp_num = execute (getIniSetting Micra.UserSettings "Settings" "CurrentProfile")
				for i = 1 to profile_names.count do (
				
					if i != cp_num then(
					
						msc.mnu_p_items[i].backColor = netDrColor (mcUIColors.get #back)
						msc.mnu_p_items[i].forecolor = netDrColor (mcUIColors.get #text)
					) else (
					
						msc.mnu_p_items[i].backColor = netDrColor (mcUIColors.get #back)
						msc.mnu_p_items[i].forecolor = netDrColor green
					)
				)
				--display menu at pointer
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
			i.BackColor = netDrColor (mcUIColors.get #back)
			i.ForeColor = netDrColor (mcUIColors.get #text)
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
			i.FlatAppearance.BorderColor = netDrColor (mcUIColors.get #back)
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
		
		local fpos = (mcFile.getIniDataFromArray Micra.TempProfileIni "Properties_2" "mcMicraDialog" 2)
		if fpos == undefined do fpos = (mcFile.getIniDataFromArray Micra.DefaultProfileIni "Properties_2" "mcMicraDialog" 2)
		form.StartPosition = form.StartPosition.Manual
		
		form.MinimumSize = netDrSize [form_size.x, mcs.bar_height + mcs.border_offset*2]
		--form.MaximumSize = netDrSize form_size
		
		form.ControlBox  = false --hide main bar
		form.bounds = netDrRect fpos form_size
		form.FormBorderStyle = form.FormBorderStyle.none
		form.BackColor = netDrColor (mcUIColors.get #fore) --yellow
		form.ShowInTaskbar = false
		form.opacity = mcUIColors.get #opacity
		
		mcs.ToolTip.IsBalloon = true
		mcs.ToolTip.BackColor = netDrColor (mcUIColors.get #back)
		mcs.ToolTip.ForeColor = netDrColor (mcUIColors.get #text)
		mcs.ToolTip.AutoPopDelay = 5000
		mcs.ToolTip.InitialDelay = 400
		mcs.ToolTip.ReshowDelay = 100
		mcs.ToolTip.ShowAlways = true
		
		mcs.mnu.BackColor = netDrColor (mcUIColors.get #back)
		mcs.mnu.ForeColor = netDrColor (mcUIColors.get #text)
		mcs.mnu.ShowImageMargin = false
		
		mcs.timer.interval  = sec
		mcs.timer.tag = form
		
		mcs.btnMin.bounds = netDrRect [form_size.x - btn_size - form_offset/2, form_offset/2] [btn_size, bar_height]
		mcs.btnMin.FlatStyle = mcs.btnMin.FlatStyle.flat
		mcs.btnMin.BackColor = netDrColor (mcUIColors.get #btn) --(color 124 196 22)
		mcs.btnMin.ForeColor = netDrColor (mcUIColors.get #text)
		mcs.btnMin.text = "-"
		
		mcs.edt_objName.bounds = netDrRect [form_offset/2,bar_height+form_offset] [form_size.x - form_offset*2 - btn_size, bar_height]
		mcs.edt_objName.BackColor = netDrColor (mcUIColors.get #back)
		mcs.edt_objName.ForeColor = netDrColor (mcUIColors.get #seltext)
		mcs.edt_objName.BorderStyle = mcs.edt_objName.BorderStyle.FixedSingle
		
		mcs.cp_wirePicker.FlatStyle = mcs.cp_wirePicker.FlatStyle.flat
		mcs.cp_wirePicker.FlatAppearance.BorderColor = netDrColor (mcUIColors.get #back)
		mcs.cp_wirePicker.FlatAppearance.BorderSize = 1
		mcs.cp_wirePicker.bounds  = netDrRect [form_size.x- btn_size- form_offset, bar_height+form_offset] [btn_size+2, 20]
		mcs.cp_wirePicker.backColor = netDrColor (mcUIColors.get #seltext)

		mcs.lblT.bounds = netDrRect [form_offset/2, form_offset/2] [form_size.x - form_offset, bar_height]
		mcs.lblT.BackColor = netDrColor (mcUIColors.get #back)
		mcs.lblT.ForeColor = netDrColor (mcUIColors.get #text)

		mcs.tlp.bounds = netDrRect [form_offset/2, bar_height*2+form_offset*3] [form_size.x - form_offset, btn_size]
		mcs.tlp.backColor = netDrColor (mcUIColors.get #btn)
		--mcs.tlp.AutoSize = true
		mcs.tlp.ColumnCount = 6 --bottom icons
		
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
	mcDotnet.dShow mcMicraDialog -- Shows the form with the specified owner (MAX) to the user (creatd by lo)
)