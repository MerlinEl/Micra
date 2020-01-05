Global mcMaxToBlenderBridgeDialog
if mcMaxToBlenderBridgeDialog != undefined do destroyDialog mcMaxToBlenderBridgeDialog
rollout mcMaxToBlenderBridgeDialog "[ Max <--> Blender ] BRIDGE v 0.01:" width:392 height:128
(
	GroupBox 'grp1' "App Dir:" pos:[4,4] width:384 height:48 align:#left
	button 'btn_browse_app_dir' "..." pos:[360,24] width:24 height:20 align:#left
	button 'btn_browse_scripts_dir' "..." pos:[360,72] width:24 height:20 align:#left
	button 'btn_cancel' "Cancel" pos:[4,104] width:60 height:20 align:#left
	button 'btn_install' "Install" pos:[328,104] width:60 height:20 align:#left
	edittext 'edt_blender_app_dir' "" pos:[8,24] width:348 height:20 align:#left
	edittext 'edt_blender_scripts_dir' "" pos:[8,72] width:348 height:20 align:#left
	GroupBox 'grp2' "Scripts Startup Dir:" pos:[4,52] width:384 height:48 align:#left
	checkbox 'chk_autorun_bridge' "Autorun Bridge" pos:[132,104] width:128 height:20 align:#left
	fn isBlenderInstaled = (
	
		local app_path = mcFile.readSettings Micra.UserSettings "Settings/BlenderAppPath"
		local scripts_path = mcFile.readSettings Micra.UserSettings "Settings/BlenderScriptsPath"
		doesFileExist app_path and doesFileExist scripts_path
	) 
	fn isValidApplication app_path = (
		
		app_path != undefined and \
		doesFileExist app_path and \
		findString (toLower app_path) "blender.exe" != undefined
	)
	fn isValidScriptPath dir_path = (
		
		dir_path != undefined and \
		doesDirectoryExist dir_path and \
		findString (toLower dir_path) "startup" != undefined
	)
	fn browseBlenderAppDir = (
		
		local path = getOpenFileName caption:" Locate Blender Application..." filename:"*.exe" types:"Executable files: [*.exe]"
		if path != undefined do edt_blender_app_dir.text = path	
	)
	fn browseBlenderScrtipsDir = (
		
		local init_dir = if edt_blender_app_dir.text.count > 0 then getFilenamePath edt_blender_app_dir.text else @"C:\"
		local path = getSavePath caption:" Locate Blender/Scripts/Startup Directory..." initialDir:init_dir
		if path != undefined do edt_blender_scripts_dir.text = path + "\\"
	)
	fn installBlenderData = (
		
		local blender_app_path		= edt_blender_app_dir.text	
		local blender_scripts_path	= edt_blender_scripts_dir.text	
		if (isValidApplication blender_app_path) and (isValidScriptPath blender_scripts_path) then (
			
			--save settings to XML
			mcFile.saveSettings Micra.UserSettings "Settings/BlenderAppPath" blender_app_path
			mcFile.saveSettings Micra.UserSettings "Settings/BlenderScriptsPath" blender_scripts_path
			--copy mcLoader.py in to Blender script start up folder
			local micra_py_loader = micra.CorePyDir + "blender\\mcLoader.py"
			local blender_py_loader = blender_scripts_path + "mcLoader.py"
			if doesFileExist blender_py_loader do deleteFile blender_py_loader
			copyFile micra_py_loader blender_py_loader
			destroyDialog mcMaxToBlenderBridgeDialog	
			
		) else (
				
			messageBox ("Blender paths are invalid.") title:"Warning:"
		)	
	)
	fn initPythonBridge state = (
	
		local autorun_py = if state then "true" else "false" 
		mcFile.saveSettings Micra.UserSettings "Settings/BlenderBridgeAutorun" autorun_py
		if autorun_py == "true" do python.ExecuteFile (micra.CorePyDir + "mcLoader.py")
	)
	fn init = (
	
		edt_blender_app_dir.text = mcFile.readSettings Micra.UserSettings "Settings/BlenderAppPath"
		edt_blender_scripts_dir.text = mcFile.readSettings Micra.UserSettings "Settings/BlenderScriptsPath"
		chk_autorun_bridge.checked = mcFile.readSettings Micra.UserSettings "Settings/BlenderBridgeAutorun" == "true"
	)
	on mcMaxToBlenderBridgeDialog open do (init())
	on btn_browse_app_dir pressed  do (browseBlenderAppDir())
	on btn_browse_scripts_dir pressed  do (browseBlenderScrtipsDir())
	on btn_cancel pressed  do (destroyDialog mcMaxToBlenderBridgeDialog)
	on chk_autorun_bridge changed state do (initPythonBridge state)
	on btn_install pressed  do (installBlenderData())
)
( --local space
	fn maxToBlender = (
	
		--setup Blender paths if need
		if not mcMaxToBlenderBridgeDialog.isBlenderInstaled() or keyboard.shiftPressed do ( 
		
			createDialog mcMaxToBlenderBridgeDialog modal:true
			return OK --after register not progress further (second click will progress)
		)
		--store current obj selection handles
		local sel = selection as array
		local sel_handles = for o in sel collect o.handle
		if sel_handles.count == 0 do return (mcMsgList.warn "not_sel")
		max select none
		--clone selected objects
		local sel_clones = #()
		with redraw off  ( --clone all selected objects without any links
			
			for obj in sel where superClassOf obj == GeometryClass do (
			
				local new_obj = copy obj
				obj.parent = undefined  --unlink from parent
				--not need (each clone is without children)
				--for c in obj.children do c.parent = undefined --unlink all obj children
				new_obj.name = obj.name
				append sel_clones new_obj
			)
			select sel_clones
		)
		clearListener()
		--execute Python Script
		try (
			
			python.ExecuteFile (micra.CorePyDir + "MaxToBlender.py")
			
		) catch (
		
			format "*** % ***\n" (getCurrentException())
		)
		--delete objects clones
		delete sel_clones
		--restore old selection
		select (for h in sel_handles where (
		
			(o = maxOps.getNodeByHandle h) != undefined
			
		) collect o)
	)

	--EXECUTE
	maxToBlender()
)