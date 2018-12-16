Global mcSaveProfileAsDialog

try ( mcSaveProfileAsDialog.close() ) catch()
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
	local form_size       =[180, 66]
	local cp_width        = 48
	local columns_rows    = [1, 4]
	local debug = 0

	-->Components---------------------------------------------------------------------
	local form = dotNetObject "Form" 
	struct MICRA_COMPONENTS_STRUCT
	(
		lblT = dotNetObject "label" ,
		tlp  = dotNetObject "TableLayoutPanel",
		cbox  = dotNetObject "ComboBox",
		ebox  = dotNetObject "textBox",
		buttons = #()
	)
	
	form.tag = dotNetMXSValue (MICRA_COMPONENTS_STRUCT()) --manual Lifetime
	
	--|	--Form move
	fn onLblTMouseMove s a = 
	(
		if netDMove do ( mcFormSnap s.parent netDmPos ) --dragForm
	)
	fn onLblTMouseDown s a = 
	(
		local form = s.parent
		if a.Button == a.Button.left do --enableDrag
		(
			s.cursor.current = netCursors.Hand
			netDmPos = [form.MousePosition.x, form.MousePosition.y] - [form.left, form.top] 
			netDMove = true 
		)
	)
	fn onLblTMouseUp s a = 
	( 
		local form = s.parent
		netDMove = false  --disableDrag
		if a.Button == a.Button.right then form.close()
	)
--||
	fn onCloseForm s a = (mcFile.saveIniDialog s "Properties_2" s.name)

--| --Rename
	fn incorrectCharsIsFound str =
	(
		local allowed_patern = "abcdefghijklmnopqrstuvwxyz123456789_ "
		for i = 1 to str.count where findString allowed_patern str[i] == undefined do return true
		return false
	)
	fn renameItem form =
	(
		local mcs = form.tag.value
		local txt = mcs.ebox.text
		if txt == "" or incorrectCharsIsFound txt do return false
		local sel_index = mcs.cbox.selectedIndex
		mcs.cbox.items.RemoveAt sel_index
		mcs.cbox.items.Insert sel_index (dotNetObject "System.String" txt)
		mcs.cbox.SelectedIndex = sel_index
	)
	fn onGotFocus s a  = (enableAccelerators = false)
	fn onLostFocus s a = (enableAccelerators = true; s.hide())
	fn onRename s a =
	(
		if a.KeyValue == 13
		then (renameItem s.parent; s.hide()) --Enter
		else if a.KeyValue == 27 then s.hide() -- Ecape
	)
	fn editItemName s a =
	(
		local form = s.parent.parent
		local mcs = form.tag.value
		mcs.ebox.text = mcs.cbox.SelectedItem
		mcs.ebox.show()
		mcs.ebox.BringToFront()
		mcs.ebox.focus()
	)
--||
	fn onMouseUp s a = 
	(
		local form = s.parent.parent
		local mcs = form.tag.value
		case s.text of
		(
			"Accept" :
			(
				--if mcs.ebox.text != mcs.cbox.SelectedItem do renameItem form
				local sel_index = (mcs.cbox.SelectedIndex+1) as string
				local targetFile = Micra.RootDir +"User\\Profile_" + sel_index  + ".ini"
				if doesFileExist targetFile and doesFileExist Micra.TempProfileIni do 
				(
					deleteFile targetFile 
					copyFile Micra.TempProfileIni targetFile
				)
				--set new name to ini
				setIniSetting Micra.UserSettings "Profiles" sel_index mcs.cbox.SelectedItem
				form.close()
			)
			"Rename": editItemName s a
			"Cancel" : form.close() 
		)
	)
	fn addButtons mcs =
	(
		local titles = #("Accept", "Rename", "Cancel")
		for i = 1 to 3 do
		(
			local btn = dotnetObject "Button"
			btn.BackColor = netDrColor clr_back
			btn.ForeColor = netDrColor clr_text
			btn.size  = netDrSize [60, btn_size]
			btn.FlatStyle = btn.FlatStyle.flat
			btn.FlatAppearance.BorderColor = netDrColor clr_back
			btn.FlatAppearance.BorderSize = 1
			btn.margin =  dotnetobject "padding" 0
			btn.text = titles[i]
			btn.name = "btn_" + (i as integer) as string
			
			dotNet.addEventHandler btn "MouseUp" onMouseUp
			mcs.buttons += #( btn )
		)
		mcs.tlp.controls.addRange ( mcs.buttons )
	)
	fn loadCBoxItems mcs =
	(
		local items= for i = 1 to 8 collect getIniSetting Micra.UserSettings "Profiles" (i as string)
		mcs.cbox.Items.AddRange (dotNetArray items)
		mcs.cbox.SelectedIndex = 0
	)
	fn inicializeInterface form mcs =
	(
		form.name = "mcSaveProfileAsDialog"
		form.ControlBox  = false --hide main bar
		local fpos = (mcCall.getIniDataFromArray Micra.TempProfileIni "Properties_2" "mcSaveProfileAsDialog" 2)
		form.StartPosition = form.StartPosition.Manual
		form.bounds = netDrRect fpos form_size
		form.FormBorderStyle = form.FormBorderStyle.none
		form.BackColor = netDrColor clr_fore --yellow
		form.ShowInTaskbar = false
		form.opacity = 0.8
		
		mcs.lblT.bounds = netDrRect [form_offset/2, form_offset/2] [form_size.x - form_offset, bar_height]
		mcs.lblT.BackColor = netDrColor clr_back
		mcs.lblT.ForeColor = netDrColor clr_text
		mcs.lblT.text = "Save As..."
		
		mcs.cbox.DropDownStyle = mcs.cbox.DropDownStyle.DropDownList
		mcs.cbox.bounds = netDrRect [form_offset/2, form_offset + bar_height] [form_size.x - form_offset, bar_height]
		mcs.cbox.BackColor = netDrColor clr_back
		mcs.cbox.ForeColor = netDrColor clr_text
		
		mcs.tlp.backColor = netDrColor clr_btn--clr_fore
		mcs.tlp.bounds = netDrRect [form_offset/2, form_offset*3.4 + bar_height*2] [form_size.x - form_offset, btn_size]
		mcs.tlp.RowCount = 1
		mcs.tlp.ColumnCount = 3
		
		mcs.ebox.BackColor= netDrColor clr_back
		mcs.ebox.ForeColor= netDrColor clr_text
		mcs.ebox.bounds = netDrRect [form_offset/2, form_offset + bar_height] [form_size.x - form_offset, bar_height]
		mcs.ebox.BorderStyle = mcs.ebox.BorderStyle.FixedSingle
		
		loadCBoxItems mcs
		addButtons mcs
		
		dotNet.addEventHandler mcs.ebox "KeyUp" onRename
		dotNet.addEventHandler mcs.ebox "GotFocus" onGotFocus
		dotNet.addEventHandler mcs.ebox "LostFocus" onLostFocus
		
		dotNet.addEventHandler mcs.lblT   "MouseMove" onLblTMouseMove
		dotNet.addEventHandler mcs.lblT   "MouseDown" onLblTMouseDown 
		dotNet.addEventHandler mcs.lblT   "MouseUp"   onLblTMouseUp
		dotNet.addEventHandler form "Closing" onCloseForm
		
		form.controls.addRange #(mcs.lblT, mcs.cbox, mcs.tlp, mcs.ebox)
		mcs.ebox.hide()
	)
	
	inicializeInterface form form.tag.value
	mcSaveProfileAsDialog = form
	mcSaveProfileAsDialog.show(WindowWrapper)
	
	
)