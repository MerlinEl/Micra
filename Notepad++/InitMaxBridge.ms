Global mcNotepadBridgeDialog


rollout mcNotepadBridgeDialog "Notepad++ Bridge MXSPyCOM" width:516 height:76
(
	groupBox 'grp1' "Notepad Root Directory:" pos:[4,4] width:508 height:68 align:#left
	editText 'edt_path' "" pos:[8,20] width:436 height:20 align:#left
	button 'btn_browse' ".." pos:[448,20] width:60 height:20 align:#left
	button 'btn_cancel' "Cancel" pos:[12,44] width:116 height:24 align:#left
	button 'btn_accept' "Install" pos:[392,44] width:116 height:24 align:#left
	local XmlDoc = dotNetObject "System.Xml.XmlDocument"
	fn getNotepadPath = (
		
		local notepad_dir = (getFilenamePath  (getThisScriptFilename()))
		edt_path.text = notepad_dir
	)
	fn getUserItems shortcuts_xml = (
		
		if not (doesFileExist shortcuts_xml) do (
			
			format "Notepad++ Bridge MXSPyCOM > Unable to localize file [ % ] \n" shortcuts_xml
			return undefined
		)
		XmlDoc.Load shortcuts_xml
		local root_node = XmlDoc.item "NotepadPlus" --dotNetObject:System.Xml.XmlElement or undefined
		local user_node = root_node.item "UserDefinedCommands"
		user_node.ChildNodes
	)
	fn registerBridge = (
		
		local server_file = edt_path.text + "tools\MXSPyCOM\\initialize_COM_server.ms"
		local max_file = (getDir #userStartupScripts)+ "\\initialize_COM_server.ms"
		if  doesFileExist max_file do return false
		copyFile server_file max_file
	)
	on btn_browse pressed  do (
		
		local  notepad_dir = getSavePath caption:"Select Notepad++ Root Folder:" initialDir:edt_path.text
		if notepad_dir != undefined do
		(
			edt_path.text = notepad_dir + "\\"
		)
	)
	on btn_cancel pressed  do (DestroyDialog mcNotepadBridgeDialog)
	on btn_accept pressed  do (
		
		--Replace or Create Shortcuts MXSPyCOM.exe path
		local notepad_dir = edt_path.text
		local shortcuts_xml = notepad_dir + "shortcuts.xml"
		local user_items = getUserItems shortcuts_xml
		if user_items == undefined do return false --user items not exeists or is empty
		local item_found = undefined
		for i  = 1 to user_items.count-1 do (
			
			local item = user_items. ItemOf i -- dotNetObject:System.Xml.XmlElement
			local attr = item.Attributes
			local item_name = (attr.ItemOf "name").value --get attribute name
			if item_name == "Execute MaxScript" do ( --replace item
				
				item_found	= item
				--format "Found item:% path:%\n"   item_name item.InnerText
				local run_cmd = "\"" + notepad_dir + "tools\MXSPyCOM\MXSPyCOM.exe\" -s \"$(FULL_CURRENT_PATH)\""
				item.InnerText = run_cmd
				exit --end loop
			)
		)
		if  item_found  == undefined do ( --create new entry
			
			--in this notepad version dont need this check (the entry is always there)
		)
		
		--XmlDoc.Save shortcuts_xml
		registerBridge()
		--format "Shortcut was updated. Restart Notepad++ to teake the effect.\n"
		messageBox "Notepad++ Bridge was estabilished succecfully!\nPlease Restart 3DsMax and Notepad++.\nHave a Good Day!"
		DestroyDialog mcNotepadBridgeDialog
	)
	on mcNotepadBridgeDialog open do getNotepadPath()
)
CreateDialog mcNotepadBridgeDialog
