Global mcSaveProfileAsDialog

try ( mcSaveProfileAsDialog.close() ) catch()
(
	-->Locals-----------------------------------------------------------------
	local sec = 60000
	local netDMove = false, netDmPos
	local last_profile = execute (mcFile.readSettings Micra.UserSettings "Interface/lastprofile")
	local profiles = mcFile.readSettings Micra.UserSettings "ColorProfiles"  type:"keys"
	local head_str = profiles[last_profile]
	local bar_height      = 14
	local form_bounds     = 2
	local form_offset     = 4
	local btn_size        = 24
	local form_size       =[300, 66]
	local cp_width        = 48
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
		if netDMove do ( mcDialog.snapForm s.parent netDmPos ) --dragForm
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
	fn onCloseForm s a = (mcFile.saveDialogSettings s.name "Properties_2")

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
	fn onLostFocus s a = (
	
		enableAccelerators = true
		local mcs = s.parent.tag.value
		local sel_index =  (mcs.cbox.SelectedIndex+1) as string
		local new_name = mcs.ebox.text
		--format "rename profile:% to:%\n" sel_index new_name
		mcFile.saveSettings xml_file ("Profiles/menu_"+sel_index) new_name
		s.hide()
	)
	fn onRename s a =
	(
		if a.KeyValue == 13
		then (renameItem s.parent; s.hide()) --Enter
		else if a.KeyValue == 27 then s.hide() -- Ecape
	)
	fn copyProfile mcs = (
	
		--if mcs.ebox.text != mcs.cbox.SelectedItem do renameItem form
				/*local sel_index = (mcs.cbox.SelectedIndex+1) as string
				local targetFile = Micra.RootDir +"User\\Profile_" + sel_index  + ".ini"

				--set new name to ini
--TODO				
				form.close()*/
	)
	fn pasteProfile mcs = (
	
--TODO	
	
	)
	fn editItemName mcs  =
	(
--TODO
		/*mcs.ebox.text = mcs.cbox.SelectedItem
		mcs.ebox.show()
		mcs.ebox.BringToFront()
		mcs.ebox.focus()*/
	)
	fn resetProfileToDefault mcs = (
--TODO	
		/*local reset_profile = queryBox ("You are sure to reset profile:[ "+mcs.cbox.SelectedItem+" ]?") title:"Warning!"
		format "reseting profile:%\n" reset_profile
		if not reset_profile do return false
		local items = mcs.cbox.items
		--replace cbox item with default
		local sel_index = mcs.cbox.SelectedIndex
		mcs.cbox.items.RemoveAt sel_index --remove old item
		mcs.cbox.items.Insert sel_index "Empty"	 --add new item
		mcs.cbox.SelectedIndex = sel_index --reselect item
		sel_index = (sel_index+1) as string*/
	)
--||
	fn onMouseUp s a = 
	(
		local form = s.parent.parent
		local mcs = form.tag.value
		case s.text of (
		
			"Copy"	: copyProfile mcs
			"Paste"	: pasteProfile mcs
			"Rename"	: editItemName mcs
			"Reset"	: resetProfileToDefault mcs
		)
	)
	fn addButtons mcs = (
	
		local titles = #("Copy", "Paste", "Rename", "Reset")
		for t in titles do (
		
			local btn = dotnetObject "Button"
			btn.BackColor = mcDotnet.uiColor #back
			btn.ForeColor = mcDotnet.uiColor #text
			btn.size  = netDrSize [60, btn_size]
			btn.FlatStyle = btn.FlatStyle.flat
			btn.FlatAppearance.BorderColor = mcDotnet.uiColor #back
			btn.FlatAppearance.BorderSize = 1
			btn.margin =  dotnetobject "padding" 0
			btn.text = t
			btn.name = "btn_" + t
			dotNet.addEventHandler btn "MouseUp" onMouseUp
			mcs.buttons += #( btn )
		)
		mcs.tlp.controls.addRange ( mcs.buttons )
	)
	fn loadCBoxItems mcs = (
		
		local items= for i = 1 to 8 collect mcFile.readSettings Micra.UserSettings  ("Profiles/menu_"+i as string)
		mcs.cbox.Items.AddRange (dotNetArray items)
		mcs.cbox.SelectedIndex = 0
	)
	fn inicializeInterface form mcs =
	(
		form.name = "mcSaveProfileAsDialog"
		form.ControlBox  = false --hide main bar
		local fpos = execute (mcFile.readSettings Micra.UserProfile "Properties_2/mcSaveProfileAsDialog" type:"pos")
		form.StartPosition = form.StartPosition.Manual
		form.bounds = netDrRect fpos form_size
		form.FormBorderStyle = form.FormBorderStyle.none
		form.BackColor = mcDotnet.uiColor #fore --yellow
		form.ShowInTaskbar = false
		form.opacity = 0.8
		
		mcs.lblT.bounds = netDrRect [form_offset/2, form_offset/2] [form_size.x - form_offset, bar_height]
		mcs.lblT.BackColor = mcDotnet.uiColor #back
		mcs.lblT.ForeColor = mcDotnet.uiColor #text
		mcs.lblT.text = "Profiles:"
		
		mcs.cbox.DropDownStyle = mcs.cbox.DropDownStyle.DropDownList
		mcs.cbox.bounds = netDrRect [form_offset/2, form_offset + bar_height] [form_size.x - form_offset, bar_height]
		mcs.cbox.BackColor = mcDotnet.uiColor #back
		mcs.cbox.ForeColor = mcDotnet.uiColor #text
		
		mcs.tlp.backColor = mcDotnet.uiColor #btn
		mcs.tlp.bounds = netDrRect [form_offset/2, form_offset*3.4 + bar_height*2] [form_size.x - form_offset, btn_size]
		mcs.tlp.RowCount = 1
		mcs.tlp.ColumnCount = 3
		
		mcs.ebox.BackColor= mcDotnet.uiColor #back
		mcs.ebox.ForeColor= mcDotnet.uiColor #text
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
	mcDotnet.dShow mcSaveProfileAsDialog
)