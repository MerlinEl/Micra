Global sDdsManager
Global sDdsManagerDialog


struct sDdsManager (

	SettingsINI = (LS3DGUP.LS3DGUP.UtilsPath + "\\LS3D_Asset_Builder.ini"),
	app = if (Micra != undefined) then (Micra.AppsDir + "texconv32.exe") else (getFilenamePath  (getSourceFileName()) + "texconv32.exe"),
	pLog = mcProgLog,	
	fn initLog = ( --validate output log window
	
		if SuperClassOf pLog != StructDef do (
		
			struct pLog (fn msg str = (format "%\n" str))
		)
	),
	fn createDDSFile save_dir file_name size_w size_h bg_color = (

		local bmp_path = save_dir + file_name + ".bmp"
		local temp_b = bitmap size_w size_h filename:(bmp_path) color:bg_color
		save temp_b; close temp_b
		local cmd = app + " " + bmp_path + " -ft dds -o " + save_dir
		format "createDDSImage >\n\tcmd:%\n" cmd
		HiddenDOSCommand cmd startpath:save_dir exitCode:&exitcode --donotwait:true 
		if doesFileExist bmp_path do deleteFile bmp_path --remove temporalily image
		exitcode == 0
	),
	fn getCheckedList = (
			
		local folder_names = getINISetting SettingsINI "DDS_Textures_List"
		local checked_list = #()
		for item_name in folder_names do (
				
			local is_checked = (getINISetting SettingsINI "DDS_Textures_List" item_name) == "true"
			if is_checked do append checked_list item_name
		)
		checked_list	
	),
	fn setupPsdDdsList = (
		
		if sDdsManagerDialog != undefined do DestroyDialog sDdsManagerDialog
		rollout sDdsManagerDialog "DDS Assign Setup:" width:172 height:252
		(
			local SettingsINI = ""
			button 'btn_accept' "Accept" pos:[108,220] width:49 height:21 align:#left
			button 'btn_cancel' "Cancel" pos:[12,220] width:48 height:21 align:#left
			dotNetControl 'clb_mods' "CheckedListBox" pos:[12,24] width:144 height:191 align:#left 
			groupBox 'grp6' "Active List:" pos:[4,4] width:164 height:244 align:#left
			fn loadDDSTexturesSettings = (
				
				if clb_mods.Items.count != 0 do clb_mods.Items.Clear()
				local folder_names = getINISetting SettingsINI "DDS_Textures_List"
				for item_name in folder_names do (
					
					local is_checked = (getINISetting SettingsINI "DDS_Textures_List" item_name) == "true"
					clb_mods.Items.Add item_name is_checked
				) 
			)
			fn savePsdFoldersSettings = (

				for i=0 to clb_mods.Items.count-1 do (
					
					local is_checked = (clb_mods.GetItemChecked i) as string
					local item_name = clb_mods.items.item[ i ]
					setINISetting SettingsINI "DDS_Textures_List" item_name is_checked
				)
				DestroyDialog  sDdsManagerDialog
			)
			on sDdsManagerDialog open do (
				
				clb_mods.BackColor = (dotNetClass "System.Drawing.Color").FromArgb 40 40 40
				clb_mods.ForeColor = (dotNetClass "System.Drawing.Color").FromArgb 200 200 200
				clb_mods.BorderStyle = (dotNetClass "BorderStyle").FixedSingle
				clb_mods.HorizontalScrollbar = clb_mods.MultiColumn = false ; clb_mods.CheckOnClick = true
			)
			on btn_accept pressed do savePsdFoldersSettings()
			on btn_cancel pressed do DestroyDialog  sDdsManagerDialog
		)
		CreateDialog sDdsManagerDialog  pos:[mouse.screenpos.x, mouse.screenpos.y - 252 / 2]
		sDdsManagerDialog.SettingsINI = SettingsINI
		sDdsManagerDialog.loadDDSTexturesSettings()
	)
)



/*
dds_man = sDdsManager()
dds_man.createDDSFile @"c:\temp\" "test_file8" 512 240 gray
*/

