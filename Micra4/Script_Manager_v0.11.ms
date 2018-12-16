  --Micra Manager:--
  
  Global mcScriptManDialog
  
  if mcScriptManDialog != undefined do destroyDialog mcScriptManDialog
 rollout mcScriptManDialog "Script Manager:" width:400 height:624
(
	-->Locals:-----------------------------------------------------------------
	struct FILE_DATA (name , path)
	local root_path = Micra.RootDir
	local backup_path = root_path + "_Backup\\"
	local root_dirs = #
	(
		FILE_DATA "Micra" root_path,
		FILE_DATA "Library" (root_path+"+\\Library\\"),
		FILE_DATA "INI" root_path,
		FILE_DATA "MCR" root_path
	)
	local sub_dirs  = #
	( 
		#(FILE_DATA "" "" ), 
		#(FILE_DATA "3DsMax" (root_path + "+\\Library\\3DsMax\\"), FILE_DATA "DotNet" (root_path + "+\\Library\\DotNet\\") ), 
		#(FILE_DATA "User" (root_path+"User\\"), FILE_DATA "Default" root_path ), 
		#(FILE_DATA "" "" ) 
	)
	local dMove = false , DmPos, label_lditing = false
	local current_dir = root_path, files_array = #(), files_names = #()
	local current_list_item, list_items, drag_file_data , drag_dir, sel_tvnode
	local bgColor   = ((colorMan.getColor #background)*255)as color
	local winColor  = ((colorMan.getColor #window)*255)as color
	local textColor = ((colorMan.getColor #text)*255)as color
	local bg_color = color 75 75 75 --gray
	local drawingColor   = dotNetClass "drawing.color"
	local dragDropEffect = dotNetClass "DragDropEffects"
	local drag_effect    = dotNetclass "System.Windows.Forms.DragDropEffects"
	local tree_node      = dotNetClass "System.Windows.Forms.TreeNode"
	local list_node      = dotNetClass "System.Windows.Forms.ListViewItem"
	local clipboardClass = dotNetClass "System.Windows.Forms.Clipboard" --create a Clipboard dotNetClass
	--Menu:---------------------------------------------------------------------
	GroupBox 'grp_title' "Script Manager:" pos:[4,4] width:392 height:616 align:#left
	dotNetControl 'tv' "treeView" pos:[8,24] width:132 height:388 align:#left
	dotNetControl 'tb' "textbox" pos:[140,24] width:232 height:20 align:#left
	dotNetControl 'lv' "listView" pos:[140,44] width:248 height:368 align:#left
	button 'btn_clear_text' "<" pos:[372,24] width:18 height:20 toolTip:"Clear Text" align:#left
	button 'btn_show' "Show All" pos:[140,460] width:112 height:20 toolTip:"Trace all posible properties of given object" align:#left
	button 'btn_show_source' "Show Source" pos:[140,436] width:112 height:20 toolTip:"Find [source file] of a function" align:#left
	button 'btn_del_from_ini' "Del ini Dialog" pos:[12,512] width:112 height:20 toolTip:"Remove dialog from INI : Class 2" align:#left
	button 'btn_add_to_ini' "Add Ini Dialog" pos:[12,488] width:112 height:20 toolTip:"Add new dialog to INI : Class 2" align:#left
	button 'btn_backup_versions' "Backup Old Versions" pos:[12,560] width:112 height:20 toolTip:"Move old versions to backup folder" align:#left
	button 'btn_backup_micra' "Backup Micra" pos:[12,464] width:112 height:20 toolTip:"Backup Micra" align:#left
	button 'btn_reload_scripts' "Reload Scripts" pos:[12,584] width:112 height:20 toolTip:"Reload scripts in current dir" align:#left
	button 'btn_reload_micra' "Reload Micra" pos:[12,440] width:112 height:20 toolTip:"Reload Micra" align:#left
	GroupBox 'grp3' "Micra:" pos:[8,420] width:124 height:192 align:#left
	GroupBox 'grp5' "Code:" pos:[136,420] width:124 height:192 align:#left
	button 'btn_set_active_version' "Activate File version" pos:[13,536] width:112 height:20 toolTip:"Set selected file to active" align:#left
	GroupBox 'grp6' "..." pos:[264,420] width:124 height:192 align:#left
	struct FILE_COMPARISION -- thanks to Vladimir Zadrazil
	(
		fn findRecord records name = 
		(
			for rec in records do
			(
				if rec.name == name do return rec
			)
			return undefined
		),
		fn stripName file_path =
		(
			local n = getFilenameFile file_path
			local n_arr = filterstring n "_"
			if n_arr.count > 2
			then 
			(
				local str = ""
				for i=1 to n_arr.count where i < n_arr.count do str += n_arr[i]+"_"
				str
			)
			else n_arr[1]+"_"
		),
		fn stripVersion file_path =
		(
			local n = getFilenameFile file_path
			local n_arr = filterstring n "_"
			if n_arr.count > 1 
			then
			(
				local v = n_arr[n_arr.count] --version in the end of array
				--(substring v 2 v.count ) as float 
			)
			else undefined
		),
		fn backupOldVersions =
		(
			local dirA=(Micra.RootDir) 
			local dirB=(dirA+"+/"+"Backup/")
			if not doesFileExist dirA or not doesFileExist dirB do return false --check both folders
			local the_files = getFiles (dirA+"*.ms") -- only one type for now
			
			if the_files.count == 0 do (print "Nothing to backup..."; return false)
			
			--collect names and versions
			struct FILE_RECORD (name,versions=#())
			local records = #()
			for f in the_files do
			(
				local name    = stripName f
				local version = stripVersion f 
				local rec     = findRecord records name

				if (rec == undefined) do
				(
					rec = (FILE_RECORD name:name)
					records += #(rec)
				)
				rec.versions += #(version) --FILL REFERENCE rec IN ARRAY RECORDS
			)

			if records.count == 0 do (print "Nothing to backup..."; return false)
			
			--move old versions to backup folder
			for rec in records do
			(
				for i = 1 to rec.versions.count - 1 do
				(
					local file_pathA = dirA + rec.name + rec.versions[i] + ".ms"
					if doesFileExist file_pathA do
					try
					(
						local file_pathB = dirB + rec.name + rec.versions[i] + ".ms"
						copyFile file_pathA file_pathB
						deleteFile file_pathA
						format "Backup file: %\n" file_pathA --rec --
					)
					catch (format "Backup file: %  failed!\n" file_path)
				)
			)
			print "done"
		)
	)
	fn getIconDotNet w h icnNum icnSize:24 =
	(
		
		img = (dotNetClass "Drawing.Image").FromFile Micra.IconI --get the saved image from file as bitmap
		
		imgSize = [img.width, img.height]
		local icnCount  = (imgSize/icnSize).x
		icnNum -= 1
		local X = (mod icnNum icnCount)
		local Y = (icnNum / icnCount)
		
		local pix_x = X * icnSize
		local pix_y = Y * icnSize
		
		pos = [pix_x, pix_y]

		icon = (dotNetObject "Drawing.Bitmap" w h) --Create new bitmap object
		gra  = (dotNetClass "Drawing.Graphics").fromImage icon --Create new Graphics object
		newRect = dotnetObject "Drawing.rectangle" 0 2  w  h
		gra.DrawImage img newRect pos.x pos.y w h (dotNetClass "Drawing.GraphicsUnit").Pixel	
		img.dispose()
		icon
	)
	fn getIconList =
	(
		local w = h = 24
		local img_list = dotNetObject "ImageList"
		img_list.ImageSize = dotNetObject "Drawing.Size" w h
		img_list.ColorDepth = img_list.ColorDepth.Depth24Bit
		img_list.transparentColor = netDrColor black

		img_list.images.add (getIconDotNet w h 183)
		img_list.images.add (getIconDotNet w h 182)
		img_list.images.add (getIconDotNet w h 181)
		
		return img_list
	)
	fn initInterface =
	(
		lv.BeginUpdate()
		tv.BeginUpdate()
		
		tv.BackColor= drawingColor.fromArgb winColor.r winColor.g winColor.b
			tv.ForeColor= drawingColor.fromArgb textColor.r textColor.g textColor.b
			tv.HideSelection=false -- When this ListView loses the focus, it will still show what's selected
			tv.HotTracking = true 
			tv.allowDrop = true -- required in order to implement DotNet drag and drop functionality
			tv.ImageList = getIconList()
		tb.BackColor= drawingColor.fromArgb winColor.r winColor.g winColor.b
			tb.ForeColor= drawingColor.fromArgb textColor.r textColor.g textColor.b
			tb.AcceptsTab = true
			tb.Multiline = true
		lv.BackColor= drawingColor.fromArgb winColor.r winColor.g winColor.b
			lv.ForeColor= drawingColor.fromArgb textColor.r textColor.g textColor.b
			lv.MultiSelect = false
			lv.HideSelection=false
			lv.LabelEdit = true
			lv.LabelWrap = false
			lv.sorting = lv.sorting.ascending
			lv.allowDrop = true -- required in order to implement DotNet drag and drop functionality
			lv.view = lv.view.Details
			lv.HeaderStyle = lv.HeaderStyle.None
			lv.Columns.add "" 180
			
		lv.EndUpdate()
		lv.Refresh()
		tv.EndUpdate()
		tv.Refresh()
		ok
	)
	fn dotNetArray mxsArray = 
  	(
  		local netArray = dotNetObject "System.String[]" mxsArray.count
  		  for i=1 to mxsArray.count do 
  		  (
  			  local str = dotNetObject "System.String" mxsArray[i]
  			  local indx = dotNetObject "System.Int32" (i-1)
  			  netArray.SetValue str indx
  		  )
  		  netArray
  	)
	fn fillListView dir =
  	(
		lv.items.Clear()
		files_array = case dir of
		(
			"Micra":(getFiles (root_path+"*"))
			"MCR"  :(getFiles (root_path+"*.mcr"))
			
			"INI"   :#()--(getFiles (root_path+"*.ini") + getFiles (root_path+"User\\*.ini"))
			"User"  :(getFiles (root_path+"User\\*.ini"))
			"Default":(getFiles (root_path+"*.ini"))
			
			"Library":#()--(getFiles (root_path + "+\\Library\\3DsMax\\*.ms") + getFiles  (root_path + "+\\Library\\DotNet\\*.ms"))
			"3DsMax":(getFiles (root_path + "+\\Library\\3DsMax\\*.ms"))
			"DotNet":(getFiles  (root_path + "+\\Library\\DotNet\\*.ms"))
		)
		if files_array.count == 0 do return false
		-- Create the items that will go in the list view
		files_names = #()
		list_items = #()
		for f in files_array do 
		( 
			local file_name = getFilenameFile f
			files_names += #(file_name)
			local li = dotNetObject "ListViewItem" file_name
			li.tag = f
			append list_items li 
		)
		lv.Items.AddRange list_items -- and then put them there
		lv.items.item[ 0 ].selected = true --select first item
  	)
	fn fillTreeView = 
	(
		if not doesFileExist root_path do return false
		for a = 1 to root_dirs.count do 
		(
			local d = (dotNetObject "System.Windows.Forms.TreeNode" root_dirs[a].name) 
			d.tag = root_dirs[a].path
			d.ImageIndex = 2
			tv.nodes.add d
			for b = 1 to sub_dirs[a].count where sub_dirs[a][b].name != "" do
			(
				local s = (dotNetObject "System.Windows.Forms.TreeNode" sub_dirs[a][b].name) 
				s.tag = sub_dirs[a][b].path
				s.ImageIndex = 1
				d.nodes.add s
			)
		)
		tv.SelectedNode = tv.Nodes.Item[ 0 ] -- select the first Item
		return true
	)
  	fn searchInListView ignoreCase:true = --made by Akram
  	(
		local list = 
		(
			local tempAry = #()
			local pat = tb.text + "*"
			for i in files_names do
			(
				if matchPattern i pattern:pat do append tempAry i
			)
			tempAry
		)
		
		lv.items.clear()
		
		--format "list:%\n" list
		if list.count == 0 do (current_list_item = undefined; return false)
		
		if tb.text != "" then --get items from list_items in to new_list_array
		(
			local list_names = for i in list_items collect i.text
			local new_list_items = #()
			for i in list do
			(
				new_list_items += #( list_items[ findItem list_names i ] )  
			)
			lv.items.addrange ( new_list_items )
			if lv.items.count != 0 do current_list_item = new_list_items[1]
		)
		else 
		(
			lv.items.addrange list_items
			if lv.items.count != 0 do current_list_item = list_items[1]
		)

		if lv.items.count == 0 do return false
		lv.items.item[ 0 ].selected = true --select first item
  	)
	fn moveFileTo dir_path =
	(
		--format "file_data:%\tdir:%\n" current_list_item.tag dir_path
		local new_file = dir_path + filenameFromPath current_list_item.tag
		if current_list_item.tag == new_file do return false
		if not doesFileExist current_list_item.tag do return false
		copyFile current_list_item.tag new_file
		deleteFile current_list_item.tag
		lv.Items.Remove current_list_item
	)
	fn RenameItemFile itm name =
	(	
		local file_path = getFilenamePath itm.tag
		local file_type = getFilenameType itm.tag
		local new_file = file_path + name + file_type
		renameFile itm.tag new_file
		itm.tag = new_file
	)
	fn backupMicra =
	(
		local state = queryBox ("Do you want to backup current version of Micra?") title:" Micra:" beep:true  
		if not state do return false
		
		--get current time and date
		local t = filterString localtime " /:"
		local date_and_time = if t.count > 4 then t[1]+"_"+t[2]+"_"+t[3]+"_"+t[4]+"_"+t[5]+"h" else ""
		
		--create backup Micra in to zip file (-tzip switch)
		local app_7z = Micra.RootDir+"App\\7za.exe"
		local backup_file = Micra.RootDir+"_Backup\\Micra_"+date_and_time+".zip "
		
		if not doesFileExist app_7z do return false
		
		dosCommand (app_7z +" a -tzip "+ backup_file + Micra.RootDir+"*.* "+ Micra.RootDir+"User "+ Micra.RootDir+"Img "+ Micra.RootDir+"Help "+ Micra.RootDir+"App " )
		
		--commit file in to server
		if (queryBox ("Do you wish to send update in to sever?") title:" Micra:") do
		(
			local server_file = (getIniSetting Micra.DefaultSettings "Paths" "WorkServer")+"\Micra\Micra4.zip"
			--format "server_path:%\tlocal_path:%\n" server_file backup_file
			if doesFileExist server_file do deleteFile server_file
			copyFile backup_file server_file
		)
	)
	fn updateMacros =
	(
		--getFiles (GetDir #ui + "macroscripts\\"+"*.mcr")
		local micra_macro = Micra.RootDir  + "Micra_Macro.mcr"
		local maxMacro = GetDir #ui + "macroscripts\\"+"Micra_Macro.mcr"
		if not doesFileExist Micra.Macro do return false
		--delete old max macro
		if doesFileExist maxMacro do deleteFile maxMacro
		--copy new macro from micra to max
		copyFile micra_macro maxMacro
		--reload max macro
		--macros.load maxMacro
		--fileIn maxMacro
		messagebox ( "Updating Macro:"+maxMacro+"\n Is done! Please restart Max.") title: " Micra"  beep:false
	)
	fn AddRemoveIniDialog dName  cmd = --cmd "add" or "del"
	(
		local state = queryBox ("Do you want to "+cmd+" Dialog") title:"Add Remove Dialog:" beep:true  
		if not state do return false
		if classOf dName != string or dName.count == 0 do return false
		local dialog_ini_names = 
		#(
			Micra.RootDir+"User\\Profile_1.ini",
			Micra.RootDir+"User\\Profile_2.ini",
			Micra.RootDir+"User\\Profile_3.ini",
			Micra.RootDir+"User\\Profile_4.ini",
			Micra.RootDir+"User\\Profile_5.ini",
			Micra.RootDir+"User\\Profile_6.ini",
			Micra.RootDir+"User\\Profile_7.ini",
			Micra.RootDir+"User\\Profile_8.ini",
			Micra.RootDir+"Profile_Default.ini",
			Micra.RootDir+"Profile_Empty.ini",
			Micra.RootDir+"Profile_Temp.ini"
		)
		for fpath in dialog_ini_names do
		(
			format "dialog_ini_file:%\texist:%\tcmd:%\n" fpath (doesFileExist fpath) cmd
			if doesFileExist fpath do (
				
				case cmd of(
					"add": setIniSetting fpath "Properties_2" dName ( "#(true, [100,100], [100,100], \"\")" )
					"del": delIniSetting fpath "Properties_2" dName
				)
			)
		)
	)
	fn dupplicateFileIsFound dir file =
	(
		findItem (getFiles (dir+"*.*")) file != 0
	)
	fn textBoxControll arg method:#KeyUp = 
	(
		case method of
		(
			#KeyUp:
			(
				if keyboard.shiftPressed and arg.KeyValue == 9 --key shift and tab pressed
				then setFocus tv
				else if arg.KeyValue == 9 
				then if lv.SelectedItems.Count != 0 then setFocus lv else setFocus tv -- tab pressed
				else if (arg.KeyValue == 38 or arg.KeyValue == 40) and lv.SelectedItems.Count != 0 
				then setFocus lv -- arrow up or arrow down pressed
				else searchInListView()
			)
			#KeyPress:
			(
				if (bit.charAsInt arg.KeyChar) == 13 and tb.text.count > 1 and tb.text[tb.text.count] == "/" then --if enter pressed and contain symbol "/" do (create a new file)
				(
					local tb_text = substring tb.text 1 (tb.text.count-1)
					tb.text = ""
					local file_name = current_dir + tb_text + ".ms" --remove symbol "/" and combine a file name
					if queryBox ("Do you wish to create new File?\t" + file_name) title:" Confirm File Creation:" 
					then
					(
						if dupplicateFileIsFound current_dir file_name do
						(
							if queryBox ("This folder already contains a file named\n\n" + file_name + 
							"\n\nWould you like to replace existing file?") title:" Confirm File Replace:" 
							then deleteFile file_name
							else (setFocus tb; return false)
						)
						local f = createFile file_name
						close f
						edit file_name
						fillListView tv.SelectedNode.text
					)
					else setFocus tb
				)
				else if (bit.charAsInt arg.KeyChar) == 13 then --enter pressed
				(
					if current_list_item != undefined and doesFileExist current_list_item.tag do edit current_list_item.tag
				)
				else if (bit.charAsInt arg.KeyChar) == 27 do destroyDialog mcScriptManDialog --escape pressed
			)
		)
	)
	fn treeViewControll arg method:#MouseUp =
	(
		case method of
		(
			#KeyUp:
			(
				if arg.KeyValue == 37 or arg.KeyValue == 38 or arg.KeyValue == 39 or arg.KeyValue == 40 then --arrows: left/up/right/down pressed
				(
					local node = tv.SelectedNode
					if node ==  undefined do return false
					fillListView node.text
					current_dir = node.tag
				)
				else if arg.KeyValue == 27 then destroyDialog mcScriptManDialog --escape pressed
				else if arg.KeyValue == 9 then setFocus tb --key tab pressed
			)
			#MouseUp:
			(
				local node = tv.GetNodeAt arg.location
				if node ==  undefined do return false
				sel_tvnode = node
				fillListView node.text
				current_dir = node.tag
				--if tb.text != "" do searchInListView()
				if arg.Button.ToString() == "Right" do
				(
					rcMenu thumbMenu
					(
						menuItem new_1 "ExpandAll..."
						menuItem new_2 "CollapseAll ..."
						menuItem new_3 "Reload ..."
						separator file_menu_1
						menuItem new_4 "Browse Dir..."
						menuItem new_5 "Validate..."
						on new_1 picked do (tv.ExpandAll())
						on new_2 picked do (tv.CollapseAll())
						on new_3 picked do (fillListView tv.SelectedNode.text)
						on new_4 picked do (ShellLaunch current_dir "")
						on new_5 picked do
						(
							print tv.SelectedNode.text
						)
					)
					PopupMenu thumbMenu
				)
			)
		)
	)
	fn listViewControll arg method:#MouseUp =
	(
		
		if lv.SelectedItems.Count == 0 do return false
		current_list_item  = lv.SelectedItems.Item[ 0 ] -- (dotNetObject "Int32" 0)--get first item from selection
		
		case method of
		(
			#KeyUp:
			(
				if arg.KeyValue == 13 or arg.KeyValue == 32 then if not label_lditing do edit current_list_item.tag --keys: enter or spacebar pressed
				else if arg.KeyValue == 38 or arg.KeyValue == 40 then tb.text = current_list_item.text --arrows: up/down pressed
				else if arg.KeyValue == 27 then destroyDialog mcScriptManDialog  --key escape pressed
				else if keyboard.shiftPressed and arg.KeyValue == 9 then  setFocus tb --key shift and tab pressed
				else if arg.KeyValue == 9 or arg.KeyValue == 37 do setFocus tv --key tab or left arrow pressed 
			)
			#MouseUp:
			(
				tb.text = current_list_item.text 
				if arg.Button.ToString() == "Right" do
				(
					rcMenu filesMenu
					(
						menuItem new_1 "Browse Dir..."
						separator file_menu_1
						menuItem new_2 "Delete..."
						on new_1 picked do (ShellLaunch current_dir "")
						on new_2 picked do 
						(
							if doesFileExist current_list_item.tag and queryBox ("You Are Sure To deltete:\n" + current_list_item.tag ) title:"Micra" do
							(
								deleteFile current_list_item.tag 
								--lv.Items.Remove current_list_item
								fillListView tv.SelectedNode.text
								searchInListView()
							)
						)
					)
					PopupMenu filesMenu
				)
			)
			#DoubleClick:(edit current_list_item.tag)
		)
		label_lditing = false
	)
	fn setScriptVersion script_name new_version = (
		
		if not doesFileExist Micra.DefaultSettings  do ((format "Not found! [%]\n" Micra.DefaultSettings); return false)
		return (setIniSetting Micra.DefaultSettings "Version" script_name new_version)
	)
	fn setVersionToActive script_file_name = (
	
		local version_pos = (findString script_file_name "_v")
		if version_pos == undefined do (
			print "Select file which you want to activate"
			return false
		)
		local new_version = substring script_file_name (version_pos+2) -1 
		local script_name = substring script_file_name 1 (version_pos-1)
		local success = setScriptVersion script_name new_version
		format "Activating script:[%] to version:[%]\tsuccess:%\n" script_name new_version success
	)
  	-->Dialog
	on mcScriptManDialog open do
  	(
  		initInterface()
		if fillTreeView() do fillListView tv.SelectedNode.text
		tv.ExpandAll()
  		setFocus tb
  	)
	on mcScriptManDialog close do (mcCall.saveIniDialog "mcScriptManDialog" "Properties_2")
	on mcScriptManDialog rbuttonup pos   do(destroyDialog mcScriptManDialog)
	-->MoveMode
	on mcScriptManDialog lbuttondown pos do (dMove = true; DmPos = pos; if not keyboard.shiftPressed do pushprompt "Pres Shift To Move...")
	on mcScriptManDialog lbuttonup   pos do (dMove = false; pushprompt "")
	on mcScriptManDialog mouseMove   pos do
	(
		if dMove and keyboard.shiftPressed do setDialogPos mcScriptManDialog (mouse.screenpos - DmPos)
	)
	--> Actions
  	on tb keyPress    arg do (textBoxControll  arg method:#KeyPress)
  	on tb keyUp       arg do (textBoxControll  arg method:#KeyUp)
	on tv mouseUp     arg do (treeViewControll arg method:#MouseUp)
	on tv keyUp       arg do (treeViewControll arg method:#KeyUp)
	on lv DoubleClick arg do (listViewControll arg method:#DoubleClick)
	on lv MouseUp     arg do (listViewControll arg method:#MouseUp)
	on lv KeyUp       arg do (listViewControll arg method:#KeyUp)
	on lv BeforeLabelEdit arg do (label_lditing = true)
	on lv AfterLabelEdit arg do if arg.Label != undefined do (RenameItemFile lv.Items.Item[ arg.item ] arg.Label) --if label changed

--| --Drag & Drop effect
	on lv DragOver arg do  --Called repeatedly while draging mouse ower listView 
	(
		arg.effect = if arg.data.GetDataPresent tree_node then 
		(
			local node = arg.data.GetData tree_node
			if node.treeview.equals tv then drag_effect.move else drag_effect.none
		)
		else drag_effect.none
	)
	on lv ItemDrag arg do --Drag Start
	(
		--print "ListView Drag Begin"
		current_list_item = arg.Item
		
		if keyboard.controlPressed 
		then --drag file Copy in All Windows Interfaces
		(
			local intnum = dotnetobject "System.Int32" 0
			local filenamestring= dotnetobject "System.string" current_list_item.tag
			local dropfile = dotnetobject "System.String[]" 1
			dropfile.setvalue filenamestring intnum
			local DataObj = dotnetobject "DataObject" ((dotnetclass "DataFormats").filedrop) dropfile
			lv.dodragdrop Dataobj ((dotnetclass "DragDropEffects").Copy)
		)
		else --move file to current interface
		(
			tv.DoDragDrop arg.item drag_effect.move 
		)
	)
	on tv DragOver send arg do --Called repeatedly while draging mouse ower treeView 
	(
		local mouseDPos = send.PointToClient send.MousePosition
		local node = send.GetNodeAt mouseDPos.x mouseDPos.y
		if node != undefined do 
		(
			send.SelectedNode = node
			drag_dir = node.tag
		)
		
		arg.effect = if arg.data.GetDataPresent list_node then 
		(
			item = arg.data.GetData list_node
			if item.listview.equals lv then drag_effect.move else drag_effect.none
		)
		else drag_effect.none
	)
	on tv DragDrop send arg do --Drag End
	(
		--print "TreeView Drag End"
		if current_list_item != undefined and drag_dir != undefined do
		if queryBox ("Do you wish to move File:\n"+current_list_item.tag+"\nIn Folder:\n"+drag_dir+"?") title:"Micra?" do
		(
			--format "file_data:%\tdir:%\n" current_list_item.tag drag_dir
			moveFileTo drag_dir	
		)
		drag_dir = undefined
		send.SelectedNode = sel_tvnode
	)
--|| --Drag & Drop effect
--| --Action Buttons
	on btn_show pressed do mcSystem.show (execute tb.text)
	on btn_reload_micra pressed do (fileIn (Micra.RootDir+ "_Loader.ms"))
	on btn_reload_scripts pressed do (fillListView tv.SelectedNode.text)
	on btn_show_source  pressed do (try (ShowSource (execute tb.text)) Catch () ; tb.text = "")
	on btn_backup_micra pressed do backupMicra()
	on btn_clear_text pressed do (tb.text = ""; fillListView tv.SelectedNode.text; setFocus tb)
	on btn_backup_versions pressed do 
	(
		clearListener()
		local fc = FILE_COMPARISION() 
		fc.backupOldVersions()
	)
	on btn_add_to_ini pressed do (AddRemoveIniDialog tb.text "add")
	on btn_del_from_ini pressed do (AddRemoveIniDialog tb.text "del") --updateMacros()
	on btn_set_active_version pressed do setVersionToActive tb.text
--|| --Actions Buttons
  )
mcCall.createIniDialog "mcScriptManDialog" "Properties_2"
mcScriptManDialog.grp_title.text = "Script Manager: v" + (Micra.getScriptVersion "Script_Manager") --update script title with version