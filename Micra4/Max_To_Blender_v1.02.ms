Global mcMaxToBlenderBridgeDialog
Global mcMaxToBlenderBridgeEnabled
if mcMaxToBlenderBridgeDialog != undefined do destroyDialog mcMaxToBlenderBridgeDialog
rollout mcMaxToBlenderBridgeDialog "[ Max <--> Blender ] BRIDGE v 0.01:" width:392 height:180
(
	GroupBox 'grp1' "App Dir:" pos:[4,4] width:384 height:48 align:#left
	button 'btn_browse_app_dir' "..." pos:[360,24] width:24 height:20 align:#left
	button 'btn_browse_scripts_dir' "..." pos:[360,72] width:24 height:20 align:#left
	button 'btn_cancel' "Cancel" pos:[8,156] width:60 height:20 align:#left
	button 'btn_install' "Install" pos:[328,156] width:60 height:20 align:#left
	edittext 'edt_blender_app_dir' "" pos:[8,24] width:348 height:20 align:#left
	edittext 'edt_blender_scripts_dir' "" pos:[8,72] width:348 height:20 align:#left
	GroupBox 'grp2' "Scripts Startup Dir:" pos:[4,52] width:384 height:48 align:#left
	label 'lbl1' "Max:" pos:[20,124] width:40 height:16 align:#left
	GroupBox 'grp3' "Ports:" pos:[4,104] width:384 height:48 align:#left
	spinner 'spn_port_max' "" pos:[68,124] width:60 height:16 range:[2000,10000,4501] type:#integer align:#left
	label 'lbl2' "Blender:" pos:[272,124] width:40 height:16 align:#left
	spinner 'spn_port_blender' "" pos:[320,124] width:60 height:16 range:[2000,10000,4601] type:#integer align:#left
	fn isBlenderInstaled = (
	
		local app_path = mcFile.readSettings Micra.UserSettings "Settings/BlenderAppPath"
		local scripts_path = mcFile.readSettings Micra.UserSettings "Settings/BlenderScriptsPath"
		doesFileExist app_path and doesFileExist scripts_path
	) 
	fn createLoaderForBlender dir fpath max_port blender_port = (
	
		dir = dir + "\\blender" --without last slash in patth
		dir = mcString.replaceAll dir "\\" "\\\\" --add 4x slashes to join in string
		local str = "import sys\n"
		str += "Micra_Blender_Dir = '"+dir+"'\n"
		str += "MAX_PORT = "+max_port as string+"\n"
		str += "BLENDER_PORT = "+blender_port as string+"\n"
		str += "#~ add Micra Core Python Dir in to system paths( if need )\n"
		str += "def register():\n"
		str += "\tif Micra_Blender_Dir not in sys.path:\n"
		str += "\t\tprint ('Register Micra Python CORE Dir:', Micra_Blender_Dir)\n"
		str += "\t\tsys.path.append(Micra_Blender_Dir)\n"
		str += "\t\t# start Blender Server at Thread\n"
		str += "\t\tprint ('Init Bridge at:', BLENDER_PORT)\n"
		str += "\t\tfrom mcBridge import ServerThread\n"
		str += "\t\tthread = ServerThread(BLENDER_PORT)\n"
		str += "\t\tthread.start()\n"
		str += "\t\t# wait 2 sec and register Script Command\n"
		str += "\t\tfrom mcThread import RegisterScript\n"
		str += "\t\tthread = RegisterScript(Micra_Blender_Dir, 'BlenderToMax.py', 2)\n"
		str += "\t\tthread.start()\n"
		str += "\telse:\n"
		str += "\t\tprint ('Micra Core Python Dir was already Registred.')\n\n"	
		str += "if __name__ == '__main__':\n"
		str += "\tregister()"
		mcFile.createNewFile fpath file_text:str override:true
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
			local blender_py_loader = blender_scripts_path + "mcLoader.py"
			createLoaderForBlender micra.CorePyDir blender_py_loader spn_port_max.value spn_port_blender.value
			destroyDialog mcMaxToBlenderBridgeDialog	
			
		) else (
				
			messageBox ("Blender paths are invalid.") title:"Warning:"
		)	
	)
	fn init = (
	
		edt_blender_app_dir.text = mcFile.readSettings Micra.UserSettings "Settings/BlenderAppPath"
		edt_blender_scripts_dir.text = mcFile.readSettings Micra.UserSettings "Settings/BlenderScriptsPath"
	)
	on mcMaxToBlenderBridgeDialog open do (init())
	on btn_browse_app_dir pressed  do (browseBlenderAppDir())
	on btn_browse_scripts_dir pressed  do (browseBlenderScrtipsDir())
	on btn_cancel pressed  do (destroyDialog mcMaxToBlenderBridgeDialog)
	on btn_install pressed  do (installBlenderData())
)

if classOf python == Interface do ( --if current Max version support Python

	--fn isPythonVariableExist var_str = (
	
		--var_str in vars() or var_str in globals() or 'var_str in vars(__builtins__)
	--)

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
			if mcMaxToBlenderBridgeEnabled != true do (
			
				mcMaxToBlenderBridgeEnabled = true
				python.ExecuteFile (micra.CorePyDir + "mcLoader.py")
			)
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