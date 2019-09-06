Global FBXQuickImportExportDialog
if FBXQuickImportExportDialog != undefined do destroyDialog FBXQuickImportExportDialog
rollout FBXQuickImportExportDialog "FBX Quick Import - Export v1.0" width:764 height:112
(
	local SettingsINI = Micra.UserDir + "FBX_Quick_Import_Export.xml"
	GroupBox 'grp1' "Setup:" pos:[4,4] width:756 height:104 align:#left
	label 'lbl3' "Asset Name:" pos:[12,24] width:96 height:17 align:#left
	label 'lbl17' "FBX Import Path:" pos:[12,52] width:96 height:17 align:#left
	label 'lbl18' "FBX Export Path:" pos:[12,81] width:96 height:17 align:#left
	edittext 'edt_asset_name' "" pos:[108,24] width:244 height:17 align:#left text:"a"
	edittext 'edt_import' "" pos:[108,51] width:544 height:17 align:#left
	edittext 'edt_export' "" pos:[108,80] width:544 height:17 align:#left
	button 'btn_browse_import_dir' "..." pos:[656,48] width:24 height:22 align:#left
	button 'btn_browse_export_dir' "..." pos:[656,76] width:24 height:22 align:#left
	button 'btn_export_fbx' "Export" pos:[684,77] width:68 height:22 align:#left
	button 'btn_import_fbx' "Import" pos:[684,48] width:68 height:22 align:#left
	checkbox 'chk_ignore_links' "Ignore Links" pos:[658,24] width:100 height:20 checked:true align:#left
	fn getExportDir = (
		
		local dir = getSavePath caption:"Add Export FBX Path:" initialDir:@"D:\!2k_games\scotch_dev\exported"
		if (dir == undefined) do return OK
		edt_export.text = dir + @"\"
	)
	fn getImportDir = (
		
		local dir = getSavePath caption:"Add Import FBX Path:" initialDir:@"D:\!2k_games\scotch_dev\exported"
		if (dir == undefined) do return OK
		edt_import.text = dir + @"\"
	)
	fn importFBX = (
		
		local asset_name = edt_asset_name.text
		if (asset_name.count == 0) do ((format "Undefined Asset Name! [Micra] \n"); return false)
		local import_path = edt_import.text
		if (import_path.count == 0) do ((format "Undefined Import Path! [Micra] \n"); return false)
		format "import file:%\n" ((import_path+"\\"+asset_name+".FBX"))
		importfile (import_path+"\\"+asset_name+".FBX") #noPrompt using:FBXIMP
		print "FBX IMPORTED"
	)
	fn exportFBX = (
		
		 if selection.count == 0 do  ((format "Nothig Selected! [Micra] \n"); return false)
		local asset_name = edt_asset_name.text
		local export_path = edt_export.text
		if (export_path.count == 0) do ((format "Undefined Export Path! [Micra] \n"); return false)
		print ("export to:" + export_path+"\\"+asset_name+".FBX")
		local sel_clones = #()
		if (chk_ignore_links.checked) do (
			
				with redraw off  (
					
					maxOps.CloneNodes selection  cloneType:#copy newNodes:&sel_clones
					select sel_clones
				)
		)
		exportFile (export_path+"\\"+asset_name+".FBX") #noPrompt selectedOnly:true using:FBXEXP
		if (chk_ignore_links.checked) do (
			
			delete sel_clones
		)
		print "FBX EXPORTED"
	)
	on FBXQuickImportExportDialog open do (
		
		if not doesFileExist SettingsINI do return OK --settings file was not created yet
		edt_asset_name.text = mcFile.readSettings SettingsINI "SETTINGS/FBX/AssetName"
		edt_import.text = mcFile.readSettings SettingsINI "SETTINGS/FBX/import"
		edt_export.text = mcFile.readSettings SettingsINI "SETTINGS/FBX/export"
		setFocus edt_asset_name
	)
	
	on FBXQuickImportExportDialog close do (
		
		if edt_asset_name.text != "" do mcFile.saveSettings SettingsINI "SETTINGS/FBX/AssetName" edt_asset_name.text
		if edt_import.text != "" do mcFile.saveSettings SettingsINI "SETTINGS/FBX/import" edt_import.text
		if edt_export.text != "" do mcFile.saveSettings SettingsINI "SETTINGS/FBX/export" edt_export.text
	)
	on btn_browse_import_dir pressed do (getImportDir())
	on btn_browse_export_dir pressed do (getExportDir())
	on btn_export_fbx pressed do (exportFBX())
	on btn_import_fbx pressed do (importFBX())
)
createDialog FBXQuickImportExportDialog

