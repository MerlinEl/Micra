  --Micra Manager:--
  
  Global mcScriptManDialog
  
  if mcScriptManDialog != undefined do destroyDialog mcScriptManDialog
 rollout mcScriptManDialog "Script Manager:" width:400 height:624
(
	-->Locals:-----------------------------------------------------------------
	struct FILE_DATA (name , path)
	local root_path = Micra.RootDir
	local backup_path = Micra.ResourcesDir + "\\Backup\\"
	local root_dirs = #
	(
		FILE_DATA "Micra" root_path,
		FILE_DATA "Library" (Micra.ResourcesDir+"\\Library\\"),
		FILE_DATA "INI" root_path,
		FILE_DATA "MCR" root_path
	)
	local sub_dirs  = #
	( 
		#(FILE_DATA "Core" (root_path + "CORE\\")),--#(FILE_DATA "" "" ),  empty root dir
		#(FILE_DATA "3DsMax" (Micra.ResourcesDir + "\\Library\\3DsMax\\"), FILE_DATA "DotNet" (Micra.ResourcesDir + "\\Library\\DotNet\\") ), 
		#(FILE_DATA "User" (root_path+"User\\"+ Micra.username + "\\"), FILE_DATA "Default" root_path ), 
		#(FILE_DATA "" "" ) 
	)
	local dMove = false , DmPos, label_lditing = false
	local current_dir = root_path
	local drag_file_data , drag_dir, sel_tvnode
	local list_items = #() --backup collection for search bar (edt_cmd)
	local list_names = #() --backup collection for search bar (edt_cmd)
	local current_list_item --need to be updated on (create new item, delete item , select item, init trees)
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
	dotNetControl 'tv_dirs' "treeView" pos:[8,24] width:132 height:388 align:#left
	dotNetControl 'edt_cmd' "textbox" pos:[140,24] width:232 height:20 align:#left
	dotNetControl 'lv_scripts' "listView" pos:[140,44] width:248 height:368 align:#left
	button 'btn_clear_text' "<" pos:[374,24] width:18 height:20 toolTip:"Clear Text" align:#left
	button 'btn_show' "Show All" pos:[142,460] width:112 height:20 toolTip:"Trace all posible properties of given object" align:#left
	button 'btn_show_source' "Show Source" pos:[142,436] width:112 height:20 toolTip:"Find [source file] of a function" align:#left
	button 'btn_del_from_ini' "Del ini Dialog" pos:[14,512] width:112 height:20 toolTip:"Remove dialog from INI : Class 2" align:#left
	button 'btn_add_to_ini' "Add Ini Dialog" pos:[14,488] width:112 height:20 toolTip:"Add new dialog to INI : Class 2" align:#left
	button 'btn_backup_micra' "Backup Micra" pos:[14,464] width:112 height:20 toolTip:"Backup Micra" align:#left
	button 'btn_create_new_version' "Create New Version" pos:[15,536] width:112 height:20 toolTip:"Create New File Version" align:#left
	button 'btn_set_active_version' "Register Version" pos:[14,560] width:112 height:20 toolTip:"Set selected file to active" align:#left
	button 'btn_backup_versions' "Backup Old Versions" pos:[14,584] width:112 height:20 toolTip:"Move old versions to backup folder" align:#left
	button 'btn_reload_scripts' "Reload Scripts" pos:[270,436] width:112 height:20 toolTip:"Reload scripts in current dir" align:#left
	button 'btn_reload_micra' "Reload Micra" pos:[14,440] width:112 height:20 toolTip:"Reload Micra" align:#left
	GroupBox 'grp3' "Micra:" pos:[8,420] width:124 height:192 align:#left
	GroupBox 'grp5' "Code:" pos:[136,420] width:124 height:192 align:#left
	
	GroupBox 'grp6' "..." pos:[264,420] width:124 height:192 align:#left
	struct FILE_COMPARISION (-- thanks to Vladimir Zadrazil

		fn findRecord sets fname = (
			for item in sets do (
				
				if item.fname == fname do return item
			)
			return undefined
		),
		fn scriptName file_path = (
			
			local fname = getFilenameFile file_path
			local version_pos = (findString fname "_v")
			if version_pos == undefined then undefined else substring fname 1 (version_pos-1)
		),
		fn backupOldVersions = (
		
			local dirA=Micra.RootDir
			local dirB=Micra.ResourcesDir+"Backup\\"
			if not doesFileExist dirA or not doesFileExist dirB do return false --check both folders
			local the_files = getFiles (dirA+"*.ms") --get all *.ms files
			if the_files.count == 0 do (print "Nothing to backup..."; return false)
			--distribute files by name in to sets
			struct FILE_RECORDS (fname, paths=#())
			local sets = #()
			for f in the_files do (
				
				local fname  = scriptName f --get file name
				if fname == undefined do continue -- skip files without version
				local record = findRecord sets fname --if exists pick up item
				if (record != undefined) then ( --append file in existing record
				
					record.paths += #(f)
					
				) else ( --create new record
						 
					record = FILE_RECORDS fname #(f)
					sets += #(record)
				)		
			)
			if sets.count == 0 do (print "Nothing to backup..."; return false)
			--move old versions to backup folder
			for item in sets do ( --for each set
		
				for i = 1 to item.paths.count - 1 do ( --for each file path except last one
		
					local source_file = item.paths[i]
					if not doesFileExist source_file do continue --skip non existing files
					try (
						
						local fname = filenameFromPath item.paths[i]
						local target_file = dirB + fname
						copyFile source_file target_file
						deleteFile source_file
						format "Backup file > \n\tsource:%\n\ttarget:%\n"  source_file target_file
					) catch (
						
						format "Backup file: %  failed!\n" target_file
					)
				)
			)
			print "Backup done!"
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
		lv_scripts.BeginUpdate()
		tv_dirs.BeginUpdate()
		
		tv_dirs.BackColor= drawingColor.fromArgb winColor.r winColor.g winColor.b
			tv_dirs.ForeColor= drawingColor.fromArgb textColor.r textColor.g textColor.b
			tv_dirs.HideSelection=false -- When this ListView loses the focus, it will still show what's selected
			tv_dirs.HotTracking = true 
			tv_dirs.allowDrop = true -- required in order to implement DotNet drag and drop functionality
			tv_dirs.ImageList = getIconList()
		edt_cmd.BackColor= drawingColor.fromArgb winColor.r winColor.g winColor.b
			edt_cmd.ForeColor= drawingColor.fromArgb textColor.r textColor.g textColor.b
			edt_cmd.AcceptsTab = true
			edt_cmd.Multiline = true
		lv_scripts.BackColor= drawingColor.fromArgb winColor.r winColor.g winColor.b
			lv_scripts.ForeColor= drawingColor.fromArgb textColor.r textColor.g textColor.b
			lv_scripts.MultiSelect = false
			lv_scripts.HideSelection=false
			lv_scripts.LabelEdit = true
			lv_scripts.LabelWrap = false
			lv_scripts.sorting = lv_scripts.sorting.ascending
			lv_scripts.allowDrop = true -- required in order to implement DotNet drag and drop functionality
			lv_scripts.view = lv_scripts.view.Details
			lv_scripts.HeaderStyle = lv_scripts.HeaderStyle.None
			lv_scripts.Columns.add "" 180
			
		lv_scripts.EndUpdate()
		lv_scripts.Refresh()
		tv_dirs.EndUpdate()
		tv_dirs.Refresh()
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
		lv_scripts.items.Clear()
		local files_array = case dir of
		(
			"Micra":(getFiles (root_path+"*"))
			"Core" :(getFiles (root_path+"Core\\"+"*.*"))
			"MCR"  :(getFiles (root_path+"*.mcr"))
			
			"INI"   :#()--(getFiles (root_path+"*.ini") + getFiles (root_path+"User\\*.ini"))
			"User"  :(getFiles (root_path+"User\\"+Micra.username+"\\*.ini"))
			"Default":(getFiles (root_path+"*.ini"))
			
			"Library":#()--(getFiles (root_path + "\\Library\\3DsMax\\*.ms") + getFiles  (root_path + "+\\Library\\DotNet\\*.ms"))
			"3DsMax":(getFiles (Micra.ResourcesDir + "\\Library\\3DsMax\\*.ms"))
			"DotNet":(getFiles  (Micra.ResourcesDir + "\\Library\\DotNet\\*.ms"))
		)
		if files_array.count == 0 do return false
		-- Create the items that will go in the list view
		local all_items = #()
		for f in files_array do ( 
			
			local file_name = getFilenameFile f
			local li = dotNetObject "ListViewItem" file_name
			li.tag = f
			append all_items li 
		)
		lv_scripts.Items.AddRange all_items -- and then put them there
		lv_scripts.items.item[ 0 ].selected = true --select first item
  	)
	fn fillTreeView = 
	(
		if not doesFileExist root_path do return false
		for a = 1 to root_dirs.count do 
		(
			local d = (dotNetObject "System.Windows.Forms.TreeNode" root_dirs[a].name) 
			d.tag = root_dirs[a].path
			d.ImageIndex = 2
			tv_dirs.nodes.add d
			for b = 1 to sub_dirs[a].count where sub_dirs[a][b].name != "" do
			(
				local s = (dotNetObject "System.Windows.Forms.TreeNode" sub_dirs[a][b].name) 
				s.tag = sub_dirs[a][b].path
				s.ImageIndex = 1
				d.nodes.add s
			)
		)
		tv_dirs.SelectedNode = tv_dirs.Nodes.Item[ 0 ] -- select the first Item
		return true
	)
	fn reloadScripts = (
	
		fillListView tv_dirs.SelectedNode.text
	)
	--filter items in list by given search string
  	fn searchInListView ignoreCase:true = ( --made by Akram, mod by Orien
		
		--collect all items before filtering. They canbe restored when filter changes
		if list_items.count < lv_scripts.items.count do (
		
			list_items = for i = 0 to lv_scripts.Items.count-1 collect lv_scripts.Items.item[ i ] --recolect list items
			list_names = for i in list_items collect i.text --recolect list names
		)
	
		local list = (
			
			local tempAry = #()
			local pat = edt_cmd.text + "*"
			for n in list_names do
			(
				if matchPattern n pattern:pat do append tempAry n
			)
			tempAry
		)
		
		lv_scripts.items.clear()
		
		--format "list:%\n" list
		if list.count == 0 do (current_list_item = undefined; return false)
		
		if edt_cmd.text != "" then --get items from list_items in to new_list_array
		(
			local new_list_items = #()
			for i in list do
			(
				new_list_items += #( list_items[ findItem list_names i ] )  
			)
			lv_scripts.items.addrange ( new_list_items )
			if lv_scripts.items.count != 0 do current_list_item = new_list_items[1]
				
		) else (
			
			lv_scripts.items.addrange list_items --fill list with all  items
			if lv_scripts.items.count != 0 do current_list_item = list_items[1] --set first item as current
		)

		if lv_scripts.items.count == 0 do return false
		lv_scripts.items.item[ 0 ].selected = true --select first item
  	)
	fn moveFileTo dir_path =
	(
		--format "file_data:%\tdir:%\n" current_list_item.tag dir_path
		local new_file = dir_path + filenameFromPath current_list_item.tag
		if current_list_item.tag == new_file do return false
		if not doesFileExist current_list_item.tag do return false
		copyFile current_list_item.tag new_file
		deleteFile current_list_item.tag
		lv_scripts.Items.Remove current_list_item
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
		local state = queryBox ("Do you want to backup "+Micra.version+" ?") title:" Backup:" beep:true  
		if not state do return false
		local date_and_time = mcTime.getTime()
		--create backup Micra in to zip file (-tzip switch)
		local app_7z = Micra.RootDir+"App\\7za.exe" -- 7zip compiller
		local backup_file = Micra.ResourcesDir+"Backup\\Micra_"+date_and_time+".zip " --Micra backup file
		
		if not doesFileExist app_7z do return false
		local dir_names = #("*.*", "App", "CORE", "Default", "Help", "Img", "Pugins", "User")
		local dir_list = ""; for n in dir_names do dir_list +=  Micra.RootDir+n+" "
		dosCommand (app_7z +" a -tzip "+ backup_file + dir_list)
		
		format "Micra Backup > Done:%\n" backup_file
		--commit file in to server
		/*if (queryBox ("Do you wish to send update in to sever?") title:" Micra:") do
		(
			local server_file = (getIniSetting Micra.DefaultSettings "Paths" "WorkServer")+"\Micra\Micra4.zip"
			--format "server_path:%\tlocal_path:%\n" server_file backup_file
			if doesFileExist server_file do deleteFile server_file
			copyFile backup_file server_file
		)*/
	)
	--update micra macro in max dir
	fn updateMacros =
	(
		--getFiles (GetDir #ui + "macroscripts\\"+"*.mcr")
		local micra_macro = Micra.RootDir  + "Micra_Macro.mcr"
		local max_macro = Micra.Macro
		--delete old max macro
		if doesFileExist max_macro do deleteFile max_macro
		--copy new macro from micra to max
		copyFile micra_macro max_macro
		--reload max macro
		--macros.load maxMacro
		--fileIn maxMacro
		messagebox ( "Updating Macro:"+max_macro+"\n Is done! Please restart Max.") title: " Micra"  beep:false
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
				then setFocus tv_dirs
				else if arg.KeyValue == 9 
				then if lv_scripts.SelectedItems.Count != 0 then setFocus lv_scripts else setFocus tv_dirs -- tab pressed
				else if (arg.KeyValue == 38 or arg.KeyValue == 40) and lv_scripts.SelectedItems.Count != 0 
				then setFocus lv_scripts -- arrow up or arrow down pressed
				else searchInListView()
			)
			#KeyPress:
			(
				if (bit.charAsInt arg.KeyChar) == 13 and edt_cmd.text.count > 1 and edt_cmd.text[edt_cmd.text.count] == "/" then --if enter pressed and contain symbol "/" do (create a new file)
				(
					local tb_text = substring edt_cmd.text 1 (edt_cmd.text.count-1)
					edt_cmd.text = ""
					local file_name = current_dir + tb_text + ".ms" --remove symbol "/" and combine a file name
					if queryBox ("Do you wish to create new File?\t" + file_name) title:" Confirm File Creation:" 
					then
					(
						if dupplicateFileIsFound current_dir file_name do
						(
							if queryBox ("This folder already contains a file named\n\n" + file_name + 
							"\n\nWould you like to replace existing file?") title:" Confirm File Replace:" 
							then deleteFile file_name
							else (setFocus edt_cmd; return false)
						)
						local f = createFile file_name
						close f
						edit file_name
						fillListView tv_dirs.SelectedNode.text
					)
					else setFocus edt_cmd
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
					local node = tv_dirs.SelectedNode
					if node ==  undefined do return false
					fillListView node.text
					current_dir = node.tag
				)
				else if arg.KeyValue == 27 then destroyDialog mcScriptManDialog --escape pressed
				else if arg.KeyValue == 9 then setFocus edt_cmd --key tab pressed
			)
			#MouseUp:
			(
				local node = tv_dirs.GetNodeAt arg.location
				if node ==  undefined do return false
				sel_tvnode = node
				fillListView node.text
				current_dir = node.tag
				--if edt_cmd.text != "" do searchInListView()
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
						on new_1 picked do (tv_dirs.ExpandAll())
						on new_2 picked do (tv_dirs.CollapseAll())
						on new_3 picked do (fillListView tv_dirs.SelectedNode.text)
						on new_4 picked do (ShellLaunch current_dir "")
						on new_5 picked do
						(
							print tv_dirs.SelectedNode.text
						)
					)
					PopupMenu thumbMenu
				)
			)
		)
	)
	fn listViewControll arg method:#MouseUp = (

		if lv_scripts.SelectedItems.Count == 0 do return false
		current_list_item  = lv_scripts.SelectedItems.Item[ 0 ] -- (dotNetObject "Int32" 0) --get first item from selection

		case method of
		(
			#KeyUp:
			(
				if arg.KeyValue == 13 or arg.KeyValue == 32 then if not label_lditing do edit current_list_item.tag --keys: enter or spacebar pressed
				else if arg.KeyValue == 38 or arg.KeyValue == 40 then edt_cmd.text = current_list_item.text --arrows: up/down pressed
				else if arg.KeyValue == 27 then destroyDialog mcScriptManDialog  --key escape pressed
				else if keyboard.shiftPressed and arg.KeyValue == 9 then  setFocus edt_cmd --key shift and tab pressed
				else if arg.KeyValue == 9 or arg.KeyValue == 37 do setFocus tv_dirs --key tab or left arrow pressed 
			)
			#MouseUp:
			(
				edt_cmd.text = current_list_item.text 
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
								local succes = deleteFile current_list_item.tag 
								if succes do (
									
									format "deleteFile > file:% success:%\n" current_list_item.tag succes
									local current_index = current_list_item.index
									lv_scripts.Items.Remove current_list_item
									--select previous item
									local next_index = current_index - 1
									if next_index < 0 do next_index = 0 --prevent negative values
									if lv_scripts.items.count >= next_index do ( 
										
										current_list_item = lv_scripts.Items.item[ next_index ] --set item as current
										current_list_item.selected = true 
										lv_scripts.focus()
									)
								)
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
	fn createNewFileVersion  = (
		
		if current_list_item == undefined do return false
		local script_file_name = current_list_item.text	
		
		local version_pos = (findString script_file_name "_v")
		local current_filename =  Micra.RootDir + script_file_name + ".ms"
		local new_filename = ""
		if version_pos == undefined then ( --file have no version yet
			
			new_filename = Micra.RootDir + script_file_name + "v0.01.ms"
			
		) else ( --rise up current version
			
			local script_version = substring script_file_name (version_pos+2) -1 
			local script_name = substring script_file_name 1 (version_pos-1)	
			local new_version = mcMath.versionUp (mcString.stringToNum script_version)
			local new_fname = script_name + "_v" + new_version as String + ".ms"
			new_filename = Micra.RootDir + new_fname
		)
		local file_created  = copyFile  current_filename new_filename
		if file_created != undefined then (

			local new_item = dotNetObject "ListViewItem" (getFilenameFile new_fname)
			new_item.tag = new_filename
			lv_scripts.beginupdate()
			lv_scripts.Items.Add new_item
			new_item.selected = true --select first item
			lv_scripts.endupdate()
			lv_scripts.Update()
			lv_scripts.focus()
			
			current_list_item = new_item
			--format "selected tv_dirs item:% index:% total:%\n" current_list_item.text current_list_item.index lv_scripts.Items.count
			format "createNewFileVersion  > \n\tsource:%\n\ttarget:%\n"  current_filename new_filename
		)
	)
	fn setVersionToActive  = (
	
		if current_list_item != undefined do mcFile.registerMicraScript current_list_item.text	
	)
  	-->Dialog
	on mcScriptManDialog open do
  	(
  		initInterface()
		if fillTreeView() do fillListView tv_dirs.SelectedNode.text
		tv_dirs.ExpandAll()
  		setFocus edt_cmd
  	)
	on mcScriptManDialog close do (mcFile.saveIniDialog "mcScriptManDialog" "Properties_2")
	on mcScriptManDialog rbuttonup pos   do(destroyDialog mcScriptManDialog)
	-->MoveMode
	on mcScriptManDialog lbuttondown pos do (dMove = true; DmPos = pos; if not keyboard.shiftPressed do pushprompt "Pres Shift To Move...")
	on mcScriptManDialog lbuttonup   pos do (dMove = false; pushprompt "")
	on mcScriptManDialog mouseMove   pos do
	(
		if dMove and keyboard.shiftPressed do setDialogPos mcScriptManDialog (mouse.screenpos - DmPos)
	)
	--> Actions
  	on edt_cmd keyPress    arg do (textBoxControll  arg method:#KeyPress)
  	on edt_cmd keyUp       arg do (textBoxControll  arg method:#KeyUp)
	on tv_dirs mouseUp     arg do (treeViewControll arg method:#MouseUp)
	on tv_dirs keyUp       arg do (treeViewControll arg method:#KeyUp)
	on lv_scripts DoubleClick arg do (listViewControll arg method:#DoubleClick)
	on lv_scripts MouseUp     arg do (listViewControll arg method:#MouseUp)
	on lv_scripts KeyUp       arg do (listViewControll arg method:#KeyUp)
	on lv_scripts BeforeLabelEdit arg do (label_lditing = true)
	on lv_scripts AfterLabelEdit arg do if arg.Label != undefined do (RenameItemFile lv_scripts.Items.Item[ arg.item ] arg.Label) --if label changed

--| --Drag & Drop effect
	on lv_scripts DragOver arg do  --Called repeatedly while draging mouse ower listView 
	(
		arg.effect = if arg.data.GetDataPresent tree_node then 
		(
			local node = arg.data.GetData tree_node
			if node.treeview.equals tv_dirs then drag_effect.move else drag_effect.none
		)
		else drag_effect.none
	)
	on lv_scripts ItemDrag arg do --Drag Start
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
			lv_scripts.dodragdrop Dataobj ((dotnetclass "DragDropEffects").Copy)
		)
		else --move file to current interface
		(
			tv_dirs.DoDragDrop arg.item drag_effect.move 
		)
	)
	on tv_dirs DragOver send arg do --Called repeatedly while draging mouse ower treeView 
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
			if item.listview.equals lv_scripts then drag_effect.move else drag_effect.none
		)
		else drag_effect.none
	)
	on tv_dirs DragDrop send arg do --Drag End
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
	on btn_show pressed do mcSystem.show (execute edt_cmd.text)
	on btn_reload_micra pressed do (fileIn (Micra.RootDir+ "_Loader.ms"))
	on btn_reload_scripts pressed do (reloadScripts())
	on btn_show_source  pressed do (try (ShowSource (execute edt_cmd.text)) Catch () ; edt_cmd.text = "")
	on btn_backup_micra pressed do backupMicra()
	on btn_clear_text pressed do (edt_cmd.text = ""; fillListView tv_dirs.SelectedNode.text; setFocus edt_cmd)
	on btn_backup_versions pressed do 
	(
		clearListener()
		local fc = FILE_COMPARISION() 
		fc.backupOldVersions()
	)
	on btn_add_to_ini pressed do (AddRemoveIniDialog edt_cmd.text "add")
	on btn_del_from_ini pressed do (AddRemoveIniDialog edt_cmd.text "del") --updateMacros()
	on btn_set_active_version pressed do setVersionToActive()
	on btn_create_new_version pressed do createNewFileVersion()
--|| --Actions Buttons
  )
mcCall.createIniDialog "mcScriptManDialog" "Properties_2"
mcScriptManDialog.grp_title.text = "Script Manager: v" + (Micra.getScriptVersion "Script_Manager") --update script title with version
  
  
  /*
  		--loop trough listView items
		for i = 0 to lv_scripts.Items.count-1 do format "(%) itm:%\n" i lv_scripts.Items.item[ i ] 
		--get selected index or item
  		local sel_sindex =	lv_scripts.SelectedIndices.item[ 0 ]
		local sel_item = lv_scripts.SelectedItems.Item[ 0 ] 
		--focus item at top
		lv_scripts.TopItem=new_item
  */