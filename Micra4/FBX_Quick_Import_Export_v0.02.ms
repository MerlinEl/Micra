Global FBXQuickImportExportDialog
if FBXQuickImportExportDialog != undefined do destroyDialog FBXQuickImportExportDialog
rollout FBXQuickImportExportDialog "FBX Quick Import - Export v0.02" width:472 height:112
(
	local SettingsINI = Micra.UserDir + "FBX_Quick_Import_Export.xml"
	GroupBox 'grp1' "Setup:" pos:[4,4] width:464 height:104 align:#left
	label 'lbl3' "Asset Name:" pos:[12,24] width:124 height:17 align:#left
	label 'lbl17' "FBX Import - Export Path:" pos:[12,52] width:124 height:17 align:#left
	edittext 'edt_asset_name' "" pos:[140,24] width:312 height:17 align:#left text:"a"
	edittext 'edt_import' "" pos:[140,51] width:292 height:17 align:#left
	button 'btn_browse_import_dir' "..." pos:[436,48] width:24 height:22 align:#left
	button 'btn_export_fbx' "Export" pos:[8,76] width:68 height:22 align:#left
	button 'btn_import_fbx' "Import" pos:[392,76] width:68 height:22 align:#left
	checkbox 'chk_ignore_links' "Ignore Links" pos:[80,76] width:100 height:20 checked:true align:#left
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
		
-- 		FBXImporterSetParam "Mode" #merge
-- 		FBXImporterSetParam "SmoothingGroups" true
-- 		FBXImporterSetParam "ShowWarnings" false
		
		--get all visible objects
		--local old_visible_obj_handles = for o in objects where (not o.isHidden) collect (o.inode.handle)
		if subobjectlevel != undefined do (subobjectlevel = 0; max create mode)
		max select none

		local asset_name = edt_asset_name.text
		if (asset_name.count == 0) do ((format "Undefined Asset Name! [Micra] \n"); return false)
		local import_path = edt_import.text
		if (import_path.count == 0) do ((format "Undefined Import Path! [Micra] \n"); return false)
		format "import file:%\n" ((import_path+"\\"+asset_name+".FBX"))
		importfile (import_path+"\\"+asset_name+".FBX") #noPrompt using:FBXIMP
		print "FBX IMPORTED"
		
		--rename new imported objs
		if selection.count > 0 do (
		
			for o in selection do o.name = uniqueName "helpobject_"
			max zoomext sel
		)
		
		--select new imported objs
		/*local new_visible_obj_handles = for o in objects where  not o.isHidden collect (o.inode.handle)
		local new_objects = for h in new_visible_obj_handles where (findItem old_visible_obj_handles h) == 0 collect o
		if new_objects.count > 0 do (
			
			for o in new_objects do o.name = uniqueName "helpobject_"
			select new_objects	
		)*/
	)
	fn exportFBX = (
		
		FBXExporterSetParam "SmoothingGroups" false
		FBXExporterSetParam "NormalsPerPoly" false
		FBXExporterSetParam "TangentSpaceExport" false
		FBXExporterSetParam "SmoothMeshExport" false
		FBXExporterSetParam "Preserveinstances" false
		FBXExporterSetParam "SelectionSetExport" false
		FBXExporterSetParam "GeomAsBone" false
		FBXExporterSetParam "ColladaTriangulate" false
		FBXExporterSetParam "PreserveEdgeOrientation" false
		FBXExporterSetParam "Triangulate" false 
		--Animation------------------------------------------------------------------------
		FBXExporterSetParam "Animation" false
		--Cameras------------------------------------------------------------------------
		FBXExporterSetParam "Cameras" false
		--Lights------------------------------------------------------------------------
		FBXExporterSetParam "Lights" false
		--Embed Media--------------------------------------------------------------------
		FBXExporterSetParam "EmbedTextures" false
		--Units----------------------------------------------------------------------------
		--Axis Conversion-----------------------------------------------------------------
		FBXExporterSetParam "AxisConversionMethod" "None" --"None", "Animation", or "Fbx_Root".
		FBXExporterSetParam "UpAxis" "Y" 
		--UI----------------------------------------------------------------
		FBXExporterSetParam "ShowWarnings" true
		FBXExporterSetParam "GenerateLog" false
		--FBX File Format----------------------------------------------------------------
		FBXExporterSetParam "ASCII" false
		FBXExporterSetParam "FileVersion" "FBX201400"
		--
		if selection.count == 0 do  ((format "Nothig Selected! [Micra] \n"); return false)
		local asset_name = edt_asset_name.text
		local export_path = edt_import.text
		if (export_path.count == 0) do ((format "Undefined Export Path! [Micra] \n"); return false)
		print ("export to:" + export_path+"\\"+asset_name+".FBX")
		local sel_clones = #()
		if (chk_ignore_links.checked) do (
			
				with redraw off  (
					
					maxOps.CloneNodes selection  cloneType:#copy newNodes:&sel_clones
					select sel_clones
					for o in sel_clones do o.parent = undefined
				)
		)
		exportFile (export_path+"\\"+asset_name+".FBX") #noPrompt selectedOnly:true using:FBXEXP
		if (chk_ignore_links.checked) do (
			
			delete sel_clones
		)
	)
	on FBXQuickImportExportDialog open do (
		
		if not doesFileExist SettingsINI do return OK --settings file was not created yet
		edt_asset_name.text = mcFile.readSettings SettingsINI "SETTINGS/FBX/AssetName"
		edt_import.text = mcFile.readSettings SettingsINI "SETTINGS/FBX/import"
		setFocus edt_asset_name
	)
	
	on FBXQuickImportExportDialog close do (
		
		if edt_asset_name.text != "" do mcFile.saveSettings SettingsINI "SETTINGS/FBX/AssetName" edt_asset_name.text
		if edt_import.text != "" do mcFile.saveSettings SettingsINI "SETTINGS/FBX/import" edt_import.text
	)
	on btn_browse_import_dir pressed do (getImportDir())
	on btn_browse_export_dir pressed do (getExportDir())
	on btn_export_fbx pressed do (exportFBX())
	on btn_import_fbx pressed do (importFBX())
)
createDialog FBXQuickImportExportDialog

