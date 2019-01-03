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
		
		local current_dir = getThisScriptFilename()
		local notepad_dir = mcFile.getParentDir current_dir 1000 dir_name:"Notepad++" 
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
		
		/* Dynamically writes the necessary Registry information to allow
			Simon Felton's MXSCOM bridge to work.
			IF RUNNING THIS SCRIPT ON AN VERSION OF MAX OLDER THAN MAX 10
			THE AVG EXTENSION *MUST* BE INSTALLED
		*/
		local reg_key
		local max_version = ((maxVersion())[1] / 1000) as string
		fn create_reg_key hkey key_name &reg_key key_value_name key_value_type key_value =
		(
			registry.createKey hkey key_name key:&reg_key
			registry.setValue reg_key key_value_name key_value_type key_value
		)
		fn write_sub_key_data reg_key sub_key_name sub_key_type sub_key_value =
		(
			local sub_key
			registry.createKey reg_key sub_key_name key:&sub_key
			registry.setValue sub_key "" sub_key_type sub_key_value
		)
		-- Establish a root key for generalized Max data
		create_reg_key HKEY_CURRENT_USER @"Software\Classes\MAX.Application" &reg_key "" #REG_SZ "OLE Automation MAX Application"
		-- Add the Clsid information
		write_sub_key_data reg_key "Clsid" #REG_SZ "{7FA22CB1-D26F-11d0-B260-00A0240CEEA3}"
		-- Add the CurVer information
		write_sub_key_data reg_key "CurVer" #REG_SZ ("MAX.Application." + max_version)
		-- Establish a new root key for the version of Max being used
		create_reg_key HKEY_CURRENT_USER (@"Software\Classes\MAX.Application." + max_version) &reg_key "" #REG_SZ ("OLE Automation MAX " + max_version + ".0 Application")
		-- Add the Clsid information
		write_sub_key_data reg_key "Clsid" #REG_SZ "{7FA22CB1-D26F-11d0-B260-00A0240CEEA3}"
		-- Make a new root key for the CLSID data
		create_reg_key HKEY_CURRENT_USER @"Software\Classes\CLSID\{7FA22CB1-D26F-11d0-B260-00A0240CEEA3}" &reg_key "" #REG_SZ ("OLE Automation MAX " + max_version + ".0 Application")
		-- Add sub key data
		write_sub_key_data reg_key "ProgID" #REG_SZ ("MAX.Application." + max_version)
		write_sub_key_data reg_key "VersionIndependentProgID" #REG_SZ "MAX.Application"
		-- Register the running of files and executing script code to OLE.
		registerOLEInterface #( filein, execute, edit, encryptscript )
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
		
		XmlDoc.Save shortcuts_xml
		registerBridge()
		--format "Shortcut was updated. Restart Notepad++ to teake the effect.\n"
		messageBox "Notepad++ Bridge was estabilished succecfully!\nPlease Restart 3DsMax and Notepad++.\nHave a Good Day!"
		DestroyDialog mcNotepadBridgeDialog
	)
	on mcNotepadBridgeDialog open do getNotepadPath()
)
CreateDialog mcNotepadBridgeDialog
