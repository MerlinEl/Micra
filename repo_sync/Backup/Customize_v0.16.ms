--Customize Micra
Global mcGM
Global mcDialogEditMode --mcDialogEditMode

-->Micra Interface
try ( mcDialogEditMode.close() ) catch()
(
	-->Locals-----------------------------------------------------------------
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
	local form_offset     = 4 --border line
	local btn_size        = 24
	local form_size       =[240, 420]
	local cp_width        = 48
	local debug = 0
	-->Components---------------------------------------------------------------------
	--local form = dotNetObject "Form" 
	local form = dotNetObject "MaxCustomControls.Maxform"
	struct TAB1_COMPONENTS_STRUCT ( combo_box, list_view, lbl_info, lbl_sizer, selected_item = undefined )
	struct TAB2_COMPONENTS_STRUCT ( checkboxes = #() , buttons = #(), labels = #(), titles = #() )
	struct TAB3_COMPONENTS_STRUCT ( about_items = #(), pic_box)
	struct MICRA_COMPONENTS_STRUCT
	(
		--variables
		lblT    = dotNetObject "label" ,
		ToolTip = dotnetobject "ToolTip",
		tlp     = dotNetObject "TableLayoutPanel",
		tab     = dotNetObject "TableLayoutPanel",
		tab_buttons = #(),
		tab_1 = TAB1_COMPONENTS_STRUCT(),
		tab_2 = TAB2_COMPONENTS_STRUCT(),
		tab_3 = TAB3_COMPONENTS_STRUCT(),
		netDMove = false, 
		netDmPos,
		mnu   	   = dotNetObject "ContextMenuStrip",
		mnu_edit_action = mnu.Items.Add "Edit Action...",
		mnu_edit_icon  = mnu.Items.Add "Edit Icon..." , 
		mnu_edit_hint  = mnu.Items.Add "Edit Hint..."
		--interface
	)
	
	form.tag = dotNetMXSValue (MICRA_COMPONENTS_STRUCT()) --manual Lifetime	

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
	fn getImageList head keys =
	(
		img_list = dotNetObject "ImageList"
		img_list.ImageSize = netDrSize [btn_size, btn_size]
		img_list.ColorDepth = img_list.ColorDepth.Depth24Bit
		img_list.transparentColor = netDrColor black --212 212 212 --gray color
		
		for i in keys do
		(
			local icon_num = mcCall.getIniDataFromArray Micra.ActionsIni head i 1
			img_list.images.add (getIconDotNet icon_num)
		)
		return img_list
	)
	fn loadCatalogs box =
	(
		if not doesFileExist Micra.ActionsIni do return false 
		local item_array = getIniSetting Micra.ActionsIni
		box.Items.clear()
		box.Items.AddRange (dotNetArray item_array)
		box.SelectedIndex = 0
	)
	fn loadActionList list box =
	(
		if not doesFileExist Micra.ActionsIni or box.SelectedIndex == -1 do return false
				
		list.BeginUpdate()
		list.items.Clear()
		local item_array = getIniSetting Micra.ActionsIni box.SelectedItem
		list.SmallImageList = getImageList box.SelectedItem item_array
		local list_items = #()
		for i = 1 to item_array.count do 
		( 
			local item_text = mcString.replaceCharInString (copy item_array[i]) "_" " "
			local itm = dotNetObject "ListViewItem" item_text
			itm.tag = item_array[i]
			itm.name = box.SelectedItem
			itm.ImageIndex = i-1
			append list_items itm
		)
		list.Items.AddRange list_items 
		--list.items.item[ 0 ].selected = true --select first item
		list.EndUpdate()
		list.Refresh()
	)

--| Action Buttons Mouse Handlers
	fn editAction = (
		
		local btn = mcGM.getParam "active_button"
		if btn == undefined do return false
		local action_name = btn.tag
		format "Edit Action in btn:%\n" action_name
		mcSystem.showActionSource action_name --#(106, "mcAnimation.reverse 0 10" , "Reverse_Animation")
	)
	fn editIcon = (
		
		local btn = mcGM.getParam "active_button"
		if btn == undefined do return false
		local action_cat = btn.name
		local action_name = btn.tag
		mcGM.setParam "active_icon_index" (mcCall.getIniDataFromArray Micra.ActionsIni action_cat action_name 1)
		Micra.fileInVersion "Icon_Maker"	
	)
	fn editHint = (
		
		local btn = mcGM.getParam "active_button"
		if btn == undefined do return false
		local action_cat = btn.name
		local action_name = btn.tag
		local help_txt = getIniSetting Micra.ActionsHelpIni action_cat action_name
		format "Edit Hint:%\n" help_txt
	)
	fn onMousedown s a = --click or drag (s = sender a = arguments)
	(
		local btn_a = (s.HitTest a.location).Item
		if btn_a == undefined do return false
		local mcsA = s.parent.parent.tag.value --form tag struct
		
		case a.Button.ToString() of
		(
			"Left": --DragAndDrop 
			(			
				local btn_b
				
				local btn_a_image = (s.SmallImageList.Images.item (btn_a.ImageIndex))

				if btn_a_image != undefined do 
				(
					--format "Customize > onMousedown > Drag Start > s:% a%:\n" s a
					
					-- this actually starts the drag and drop process
					-- simultaneously copy dnd_id to clipboard
					local dnd_id = "Micra Form DragAndDrop" --define dropable place
					s.DoDragDrop (netString dnd_id) netDragDropEffect.copy -- (modal)
					
					--final dragAndDrop sequence
					btn_b = mcGM.getParam "form_drop_data"
					if btn_b != undefined then 
					(
						local mcsB = btn_b.parent.parent.tag.value
						mcsB.ToolTip.SetToolTip btn_b btn_a.text --copy tooltip
						btn_b.Image = btn_a_image --copy image
						btn_b.Tag = btn_a.tag --copy tag
						--save Settings
						local icn_numA = (mcCall.getIniDataFromArray Micra.ActionsIni btn_a.name btn_a.tag 1) as string
						setINISetting Micra.TempProfileIni "Buttons" btn_b.name btn_b.tag
						setINISetting Micra.TempProfileIni "Icons"   btn_b.name icn_numA 
					)
					mcGM.setParam "form_drop_data" undefined
					--format "Customize > onMousedown > Drag End > s:% a%:\n" s a
				)
			)
			"Middle":
			(
			)
			"Right": --RC Menu
			(
				mcGM.setParam "active_button" btn_a
				local mcsA = s.parent.parent.tag.value --form tag struct
				mcsA.mnu.Show ( s.PointToScreen a.location ) --show menu
			)
		)
	)
--||
	fn onPickedBoxItem s a =
	(
		local form = s.parent.parent
		local mcs  = form.tag.value
		loadActionList mcs.tab_1.list_view s
	)
	--show help text when action selected
	fn onPickedListItem s a =
	(
		if s.parent == undefined do return false
		local form = s.parent.parent
		local mcs  = form.tag.value
		if a.isSelected do
		(
			local action_cat =  mcs.tab_1.combo_box.SelectedItem
			local action_name = a.Item.tag
			local help_txt = getIniSetting Micra.ActionsHelpIni action_cat action_name
			mcs.tab_1.lbl_info.text = help_txt
		)
	)
	fn getRandomAboutImage =
	(
		local images = getFiles (Micra.RootDir+"Img\\*.bmp")
		local abouts = for i in images where findString i "Micra_About" != undefined collect i
		if abouts.count == 0 do return undefined
		local fpath = abouts[random 1 abouts.count]
		local img_file = (dotNetClass "Drawing.Image").FromFile fpath --get the saved image from file as bitmap
		local w=img_file.width
		local h=img_file.height
		local img = (dotNetObject "Drawing.Bitmap" w h) --Create new bitmap object
		local gra  = (dotNetClass "Drawing.Graphics").fromImage img --Create new Graphics object
		local newRect = netDrRect [ 0, 0 ] [ w, h ]  --adjust icon offset X in button 
		gra.DrawImage img_file newRect 0 0 w h (dotNetClass "Drawing.GraphicsUnit").Pixel	
		img_file.dispose()
		return img
	)
	fn createMicraRunScript sFile =
	(
		local f    = createFile sFile
		local data = "\n"
		data += "fn Micra.RootDir=\""+mcFile.filterPath (Micra.RootDir)+"\"\n"--data += "fn Micra.RootDir=\""+Micra.RootDir+"\"\n"
		data += "(\n"
		data += "\tlocal loader = \""+Micra.RootDir+"_Loader.ms\"\n"
		data += "\tif doesFileExist loader then\n"
		data += "\t(\n"
		data += "\t\tfileIn loader\n"
		data += "\t)\n"
		data += "\telse (messagebox (\"Micra4 loader is not found.\") title:\" Micra!\")\n"
		data += ")\n"
		--format "f:%\n" data 
		format data to:f
		close f
	)
	fn onCheckedCahnges s a =
	(
		setINISetting Micra.UserSettings "Settings" s.tag (s.checked as string)
		
		case s.tag of
		(
			"Autorun":
			(
				--local sFile = (GetDir #startupScripts + "\\Micra_Autorun.ms")
				local sFile = (GetDir #userStartupScripts + "\\Micra_Autorun.ms")
				if doesFileExist sFile do deleteFile sFile
				if s.checked do createMicraRunScript sFile
			)
			"ShowFileName":
			(
				if s.checked
				then
				(
					unregisterRedrawViewsCallback mcCall.fileName_in_screen
					registerRedrawViewsCallback mcCall.fileName_in_screen 
				)
				else (unregisterRedrawViewsCallback mcCall.fileName_in_screen )
			)
			"UniversalCounter":
			(
				if s.checked
				then (Micra.fileInVersion "Uni_Poly_Counter")
				else (unregisterRedrawViewsCallback mcPolyCount.Count; mcPolyCount = undefined)
			)
			"UC_ShowSize":
			(
				if s.checked
				then()
				else()
			)
			"UseLargeVertexDots":
			(
				if s.checked
				then (preferences.useLargeVertexDots = true  )
				else (preferences.useLargeVertexDots = false )
			)
		)
		completeRedraw()
	)
	fn filterPath path = 
	(
		local arr   = filterString path "\\/"
		local isDir = path[path.count-3] != "." -- example C:\temp.txt
		local newPath = ""
		for i=1 to arr.count do newPath += arr[i] + ( if isDir or i != arr.count then "/" else "")
		return newPath
	)
	fn treeCopy indir outdir move:false = --recursive call
	(
		indir = filterPath indir
		outdir = filterPath outdir

		local files = getFiles (indir+"*.*")
		local dirs = getDirectories (indir+"*.*")
		
		for f in files do ( copyFile f (outdir+filenameFromPath f) )
		for d in dirs do 
		(              
			local filter_path = filterString d "\/"
			local new_dir = outdir+filter_path[filter_path.count]
			makedir new_dir
			treeCopy d new_dir
		)
	)
	fn delDirectoryContent dir includefiles:false quiet:true =
	(
		dir = filterPath dir
		local files = getFiles (dir+"*.*")
		local dirs = getDirectories (dir+"*.*")
	
		for f in files do ( deleteFile f )
		for d in dirs do (DOSCommand ("RD \""+d+"\" /s /q") )  --/s  include files /q = qieit
	)
	fn onTab2ButtonClick s a =
	(
		case s.text of
		(
			"Interface Colors":Micra.fileInVersion "Customize_Colors"
			"Update Micra":
			(
				--get server file
				local server_dir = "r:\\Resources\\Resources_new\\Micra\\"--(getIniSetting Micra.DefaultSettings "Paths" "WorkServer")+"Micra\\"
				local server_file = server_dir + "Micra4.zip"
				local app_7z = "C:\\Windows\\System32\\7za.exe"
				local micra_folder = Micra.RootDir
				--OLD> local update_file = getDir #scripts+"\\Micra4.zip"
				local update_file = getDir #userScripts+"\\Micra4.zip"
				local backup_folder = substring micra_folder 1 (micra_folder.count-1) +"_Backup\\" --remove last slash and add _backup
				
				if not doesFileExist server_dir do (MessageBox "Server is not Accessible, try later..." title:" Micra:"; return false)
				if not doesFileExist server_file do (MessageBox "No updates found...." title:" Micra:"; return false)
				if not doesFileExist app_7z do copyFile (micra_folder+"App\\7za.exe") app_7z
				if not doesFileExist app_7z do return false
/*
				--check date and time
				if doesFileExist update_file then
				(
					if getFileModDate update_file == getFileModDate server_file 
					then (MessageBox "New updates not found...." title:" Micra:"; return false)       
					else deleteFile update_file
				)
*/				
				--download new update from server
				deleteFile update_file
				copyFile server_file update_file
				if not doesFileExist update_file do (MessageBox "Unable Download New Update...Installation Aborted" title:" Micra:"; return false)
				
				--backup old Micra folder to Micra_backup
				if not doesFileExist backup_folder then makeDir backup_folder else delDirectoryContent backup_folder
				if not doesFileExist backup_folder do (MessageBox "Unable Create Micra Backup. Installation Aborted" title:" Micra:"; return false)
				treeCopy micra_folder backup_folder
				local files = getFiles (backup_folder+"*.*")
				if files.count == 0 do  (MessageBox "Unable Create Micra Backup. Installation Aborted" title:" Micra:"; return false)
				
				--empty Micra folder
				delDirectoryContent micra_folder
				
				--extract new update in to empty micra folder
				local cmd = (app_7z + " x \"" +update_file+ "\" -o\""+micra_folder+"\"")
				DOSCommand cmd
				--restore user settings
				local user_folder = micra_folder+"User\\"
				local backup_user_folder =  backup_folder+"User\\"
				renameFile user_folder (substring user_folder 1 (user_folder.count-1)+ "_Default" )
				makeDir user_folder
				treeCopy backup_user_folder user_folder
				--Copy Micra_Macro.mcr to max  -- add version checker 
				--OLD> local Micra.Macro = GetDir #ui + "MacroScripts\\Micra_Macro.mcr"
				local Micra.Macro = getDir #userMacros + "\\Micra_Macro.mcr"
				if doesFileExist Micra.Macro do deleteFile Micra.Macro
				copyFile (Micra.RootDir+"Micra_Macro.mcr") Micra.Macro
				--format "bk2:%\tuser:%\n" backup_user_folder user_folder
				--restart Max
				MessageBox  "Update has ben Succesfull! Please restart the 3DsMax" title:" Micra:-)"
			)
		)
	)
	--INTERFACE INIT
	fn addTab num mcs =
	(
		mcs.tab.Controls.Clear()
		case num of
		(
			1: --actions interface
			(
				if mcs.tab_1.combo_box == undefined do
				(
					mcs.tab_1.combo_box           = dotNetObject "comboBox"
					mcs.tab_1.combo_box.size      = netDrSize [mcs.tab.width - form_offset, 0]
					mcs.tab_1.combo_box.BackColor = netDrColor clr_back
					mcs.tab_1.combo_box.Forecolor = netDrColor clr_text
					mcs.tab_1.combo_box.Sorted    = true
					mcs.tab_1.combo_box.DropDownStyle = mcs.tab_1.combo_box.DropDownStyle.DropDown --DropDownList --DropDown--Simple
					mcs.tab_1.combo_box.FlatStyle = mcs.tab_1.combo_box.FlatStyle.flat
					mcs.tab_1.combo_box.MaxDropDownItems = 22
					mcs.tab_1.combo_box.margin    =  dotnetobject "padding" 2
					
					mcs.tab_1.list_view           = dotNetObject "listView"
					mcs.tab_1.list_view.size      = netDrSize [mcs.tab.width - form_offset, mcs.tab.height - btn_size*4 - bar_height - form_offset*2]
					mcs.tab_1.list_view.BackColor = netDrColor clr_back
					mcs.tab_1.list_view.Forecolor = netDrColor clr_text
					mcs.tab_1.list_view.Sorting   = mcs.tab_1.list_view.Sorting.Ascending
					mcs.tab_1.list_view.margin    = dotnetobject "padding" 2
					mcs.tab_1.list_view.MultiSelect = false
					mcs.tab_1.list_view.HideSelection=false
					mcs.tab_1.list_view.LabelEdit = false
					mcs.tab_1.list_view.LabelWrap = false
					mcs.tab_1.list_view.allowDrop = true -- required in order to implement DotNet drag and drop functionality
					mcs.tab_1.list_view.view = mcs.tab_1.list_view.view.Details
					mcs.tab_1.list_view.BorderStyle = mcs.tab_1.list_view.BorderStyle.FixedSingle
					mcs.tab_1.list_view.HeaderStyle = mcs.tab_1.list_view.HeaderStyle.None
					mcs.tab_1.list_view.Columns.add "" 180
					
					mcs.tab_1.lbl_info           = dotNetObject "label"
					mcs.tab_1.lbl_info.size      = netDrSize [mcs.tab.width - form_offset, btn_size*3 + form_offset/2]
					mcs.tab_1.lbl_info.BackColor = netDrColor clr_back
					mcs.tab_1.lbl_info.ForeColor = netDrColor clr_text
					mcs.tab_1.lbl_info.text      = "Info Panel"--"Drag here to resize window"
					mcs.tab_1.lbl_info.margin    =  dotnetobject "padding" 2 
					mcs.tab_1.lbl_info.BorderStyle = mcs.tab_1.lbl_info.BorderStyle.FixedSingle
					--mcs.tab_1.lbl_info.TextAlign = mcs.tab_1.lbl_info.TextAlign.MiddleCenter
					
					mcs.tab_1.lbl_sizer           = dotNetObject "label"
					mcs.tab_1.lbl_sizer.size      = netDrSize [mcs.tab.width - form_offset, bar_height/2]
					mcs.tab_1.lbl_sizer.BackColor = netDrColor clr_fore
					mcs.tab_1.lbl_sizer.ForeColor = netDrColor clr_text
					mcs.tab_1.lbl_sizer.text      = "v"--"Drag here to resize window"
					mcs.tab_1.lbl_sizer.margin    =  dotnetobject "padding" 2 
					mcs.tab_1.lbl_sizer.TextAlign = mcs.tab_1.lbl_sizer.TextAlign.MiddleCenter
					
					dotNet.addEventHandler mcs.tab_1.list_view "ItemSelectionChanged" onPickedListItem --show help text when action selected
					dotNet.addEventHandler mcs.tab_1.list_view "MouseDown" onMousedown --manage moise click (left, middle, right, drag and drop)
					dotNet.addEventHandler mcs.tab_1.combo_box "SelectedIndexChanged" onPickedBoxItem --change action category
				)
				
				mcs.tab.Controls.addRange #(mcs.tab_1.combo_box, mcs.tab_1.list_view, mcs.tab_1.lbl_info, mcs.tab_1.lbl_sizer)
				
				mcs.tab_1.lbl_info.text = "Info Panel"
				
				loadCatalogs mcs.tab_1.combo_box 
				loadActionList mcs.tab_1.list_view mcs.tab_1.combo_box
			)
			2: --settings interface
			(
				if mcs.tab_2.checkboxes.count == 0 do
				(
					local keys = #("Autorun", "Filename in Screen", "Universal Counter", "UC_ShowSize", "Use Large Vertex Dots")
					local tags = #("Autorun", "ShowFileName", "UniversalCounter", "UC_ShowSize", "UseLargeVertexDots")

					for i = 1 to keys.count do --functionality
					(
						--checkboxes = #() , buttons = #()"Check for Updates"
						local cb = dotNetObject "checkBox"
						cb.text = keys[i]
						cb.tag = tags[i]
						cb.size = netDrSize [mcs.tab.width - form_offset, bar_height]
						cb.margin  =  dotnetobject "padding" 2
						cb.BackColor = netDrColor clr_back
						cb.ForeColor = netDrColor clr_text
						dotNet.addEventHandler cb "MouseUp" onCheckedCahnges
						mcs.tab_2.checkboxes += #(cb)
					)
					keys = #( "Interface Colors", "Update Micra")
					for i = 1 to keys.count do --updates
					(
						local b = dotNetObject "button"
						b.text = keys[i]
						b.size = netDrSize [mcs.tab.width - form_offset, btn_size]
						b.margin  =  dotnetobject "padding" 2
						b.BackColor = netDrColor clr_back
						b.ForeColor = netDrColor clr_text
						dotNet.addeventhandler b "Click" onTab2ButtonClick
						mcs.tab_2.buttons += #(b)
					)
					
					keys = #("Functionality:", "Visual Style:", "Updates:")
					for i = 1 to keys.count do --titles
					(
						local lbl = dotNetObject "label"
						lbl.text = keys[i]
						--lbl.BorderStyle = lbl.BorderStyle.FixedSingle
						lbl.size = netDrSize [mcs.tab.width - form_offset, bar_height]
						lbl.margin  =  dotnetobject "padding" 2
						lbl.BackColor = netDrColor clr_text
						lbl.ForeColor = netDrColor clr_back
						mcs.tab_2.titles += #(lbl)
					)
				)
				
				for i in mcs.tab_2.checkboxes do 
				(
					state = execute (getIniSetting Micra.UserSettings "Settings" i.tag)
					if state != undefined do i.Checked = state
				)
				mcs.tab.Controls.addRange (#(mcs.tab_2.titles[1]) + mcs.tab_2.checkboxes + #(mcs.tab_2.titles[2]) + #(mcs.tab_2.buttons[1]) + #(mcs.tab_2.titles[3]) + #(mcs.tab_2.buttons[2]))
			)
			3: --about interface
			(
				if mcs.tab_3.about_items.count == 0 do
				(
					Local MicraBorn = "04.05/2006"
					Local LastUpdate = "31.06/2012"
	
					local titles = #
					(
						"For my Friends...", 
						"*** Micra III ***",  
						"\******** ^-^ ********/", 
						"Thanks to:", 
						"Bobo, Zadr, Dunik, Tom, Alcado, Fero, Leo, Milki, Mr.Oringe, Lubik, Radek, Honzik, DenisT, PEN, Macro Bruneta....",
						"Created by: Merlin El' �\n"+MicraBorn+" - "+LastUpdate
					)
					for i = 1 to titles.count do
					(
						if i == 3 do --ad a picture
						(
							local pb = dotnetobject "picturebox"
							pb.size = netDrSize [212, 140]
							pb.margin   =  dotnetobject "padding" 2
							pb.Left = mcs.tab.width/2
							--pb.backColor = netDrColor yellow
							pb.BorderStyle = pb.BorderStyle.FixedSingle
							mcs.tab_3.about_items += #(pb)
						)

						local lbl = dotNetObject "label"
						--lbl.AutoSize = true
						lbl.TextAlign = lbl.TextAlign.MiddleCenter
						lbl.width = mcs.tab.width - form_offset*2
						local rows = (((gw.getTextExtent titles[i]).x/140) as integer)
						lbl.height = if rows > 0 then rows*22 else 22
						lbl.margin   =  dotnetobject "padding" 2 
						lbl.MaximumSize.height = mcs.tab.width - form_offset*2
						lbl.ForeColor = netDrColor clr_text
						lbl.text = titles[i]
						mcs.tab_3.about_items += #(lbl)
					)
				)
				mcs.tab_3.about_items[3].BackgroundImage = getRandomAboutImage()
				mcs.tab.Controls.addRange mcs.tab_3.about_items
			)
		)
	)
	fn checkTheButton b =
	(
		local mcs = b.parent.parent.tag.value
		b.BackColor = netDrColor clr_fore
		b.Forecolor = netDrColor clr_back --green--
		for i in mcs.tab_buttons where not i.Equals b do 
		(
			i.BackColor = undefined 
			i.Forecolor = netDrColor clr_text
		)
	)
	fn onMouseUp s a =
	(
		checkTheButton s
		addTab s.tag s.parent.parent.tag.value
	)
	fn addTabButtons mcs =
	(
		local tab_text_array = #("Actions", "Settings", "About")
		for i = 1 to tab_text_array.count do
		(
			local b = dotNetObject "Button"
			b.size  = netDrSize [btn_size*3, btn_size]
			b.FlatStyle = b.FlatStyle.flat
			b.FlatAppearance.BorderColor = netDrColor clr_back		
			b.Forecolor = netDrColor clr_text
			b.FlatAppearance.BorderSize = 1
			b.margin =  dotnetobject "padding" 0
			b.name = "btn_"+((i as integer) as string)
			b.text = tab_text_array[i]
			b.tag = i
			mcs.toolTip.SetToolTip b b.text
			dotNet.addEventHandler b "MouseUp" onMouseUp
			mcs.tab_buttons += #(b)
		)
		mcs.tlp.controls.addRange (mcs.tab_buttons)
	)
	fn onOpenForm s a = 
	(
		--activate first tab
		onMouseUp s.tag.value.tab_buttons[1] a
		s.BackColor = netDrColor clr_fore
	)
	fn onCloseForm s a = (mcFile.saveIniDialog s "Properties_2" s.name)
	fn inicializeInterface form mcs =
	(
		form.name = "mcDialogEditMode"
		form.ControlBox  = false --hide main bar
		local fpos = (mcCall.getIniDataFromArray Micra.TempProfileIni "Properties_2" "mcDialogEditMode" 2)
		if fpos == undefined do fpos = (mcCall.getIniDataFromArray Micra.DefaultProfileIni "Properties_2" "mcDialogEditMode" 2)
		form.StartPosition = form.StartPosition.Manual
		form.bounds = netDrRect fpos form_size
		form.FormBorderStyle = form.FormBorderStyle.none
		form.BackColor = netDrColor clr_fore --yellow
		form.ShowInTaskbar = false
		form.opacity = form_opacity
		
		mcs.lblT.bounds = netDrRect [form_offset/2, form_offset/2] [form_size.x - form_offset*5 , bar_height]
		mcs.lblT.BackColor = netDrColor clr_back
		mcs.lblT.ForeColor = netDrColor clr_text
		mcs.lblT.Text = "Customize:"
		
		mcs.tlp.bounds = netDrRect [form_offset/2, bar_height+form_offset] [form_size.x - form_offset*5, btn_size]
		mcs.tlp.backColor = netDrColor clr_btn
		mcs.tlp.ColumnCount = 3
		
		mcs.tab.bounds = netDrRect [form_offset/2, bar_height*2+form_offset*4] [form_size.x - form_offset*5, form_size.y - bar_height - btn_size - form_offset*6]
		mcs.tab.backColor = netDrColor clr_btn --yellow --

		mcs.mnu.BackColor = netDrColor (mcUIColors.get #back)
		mcs.mnu.ForeColor = netDrColor (mcUIColors.get #text)
		mcs.mnu.ShowImageMargin = false

		--add handlers
		dotNet.addEventHandler mcs.lblT   "MouseMove" onLblTMouseMove
		dotNet.addEventHandler mcs.lblT   "MouseDown" onLblTMouseDown 
		dotNet.addEventHandler mcs.lblT   "MouseUp"   onLblTMouseUp
		
		dotnet.addEventHandler form "Shown" onOpenForm
		dotnet.addEventHandler form "Closed" onCloseForm
		dotnet.addEventHandler form "VisibleChanged" onCloseForm
		
		dotNet.addeventhandler mcs.mnu_edit_action "Click" editAction
		dotNet.addeventhandler mcs.mnu_edit_icon  "Click" editIcon
		dotNet.addeventhandler mcs.mnu_edit_hint  "Click" editHint
		
		--add controls
		addTabButtons mcs
		form.controls.addRange( #(mcs.lblT, mcs.tlp, mcs.tab) )
	)
	inicializeInterface form form.tag.value
	mcDialogEditMode = form
	--mcDialogEditMode.show(WindowWrapper)
	mcDialogEditMode.showModeless()
)