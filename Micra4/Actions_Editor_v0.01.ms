--------------------------------------------------------------------------------
/* mcActionsEditor by Orien 2019 */
--------------------------------------------------------------------------------
/*
*@Used Structures
	Micra
	mcObject
	mcString
	mcFile
*
*@Used Objects
	undefined
*
*@Usage
	undefined
*
*@Example	
	undefined
*
*/
struct MICRA_ACTIONS_EDITOR	(
	
	--variables

	
	--functions
	fn getSource = getSourceFileName(), --get path of this script
	/**
	*@Usage
		get action type for different execute metods
	*/
	fn getActionType action_with_cmd = (
	
		if (findString action_with_cmd "Micra.fileInVersion" != undefined) then "file" else "function"
	),
	fn nameToKey action_name = (
	
		mcString.replaceAll action_name " " "_" --replace spaces with underscore: 3D Gallery > 3D_Gallery
	),
	fn parseActionData ini_data category_name action_name = (
	
		ini_data = mcString.trimLeftRight ini_data --remove white space left and right
		ini_data = mcString.replaceAll ini_data ", " "," -- remove white space after comma 	
		local data_array = filterString ini_data "," --split string in to array
		if classof data_array != array do return undefined --conversion failed
		if Micra.debug == 10 do format "mcFile > parseActionData > data_array:%\n" data_array
		local mc_obj = mcObject()
		mc_obj.add "cat" category_name
		mc_obj.add "name" action_name
		mc_obj.add "icon" data_array[1]
		mc_obj.add "cmd" data_array[2]
		mc_obj.add "tooltip" data_array[3]
		mc_obj --{cat:Animation, name:Reverse_Animation, icon:106, cmd:mcAnimation.reverse 0 10}
	),
	/**
	*@Usage
		category_name	: Object
		action_key		: Galery_3D
	*/
	fn getActionData category_name action_key = (
	
		if not doesFileExist Micra.ActionsIni do ((format "Not found! [%]\n" Micra.ActionsIni); return undefined)
		--ini data structure > icon, cmd, toolip
		--106, mcAnimation.reverse 0 10, Reverse Animation
		--221, Micra.fileInVersion 3DGallery, 3D Gallery
		--63, max align, Align
		--32, ShellLaunch C:\WINDOWS\system32\calc.exe , Calculator
		--2 , (if checkForSave() != false do resetMaxFile #noPrompt),Max Reset --#noPrompt
		local ini_data = getIniSetting Micra.ActionsIni category_name action_key 
		if Micra.debug == 10 do format "mcFile > getActionData  > ini_data:%\n" ini_data
		if ini_data != "" then (
				
			parseActionData ini_data category_name action_key
			
		) else (
		
			undefined
		)
	),
	/**
	*@Usage
		category_name	: Object
		action_key		: Galery_3D
	*/
	fn isActionRegistred category_name action_key = (
		
		local data = getActionData category_name action_key
		data != undefined
	),
	/**
	*@Example 
		mcActionsEditor.getIniDataFromAction head i "icon"
		return string or undefined
	*/
	fn getIniDataFromAction category_name action_name type = (
		
		if not doesFileExist Micra.ActionsIni do ((format "Not found! [%]\n" Micra.ActionsIni); return undefined)
		local data = getActionData category_name action_name --{cat:Animation, name:Reverse_Animation, icon:106, cmd:mcAnimation.reverse 0 10}
		if data != undefined then data.get type else undefined
	),
	--search in Micra.ActionsIni by name
	fn getActionByName action_name = (
	
		if not doesFileExist Micra.ActionsIni do ((format "mcFile > getActionByName > Not found! [%]\n" Micra.ActionsIni); return undefined)
		local heads = getIniSetting Micra.ActionsIni
		for category_name in heads do( --INI Heads
			local ini_data = getIniSetting Micra.ActionsIni category_name action_name --INI Key
			if ini_data != "" do (
				
				--{cat:Animation, name:Reverse_Animation, icon:106, cmd:mcAnimation.reverse 0 10}
				return parseActionData ini_data category_name action_name
			)
		)
		return undefined
	),
	fn getActionParams action_with_cmd = (
	
		local first_space = (findString action_with_cmd " ") --find first space in cmd[Micra.fileInVersion Paint_Selection]
		local params = substring action_with_cmd first_space -1 --get rest (params)
		params = mcString.trimLeftRight params --trim white spaces left right
		params
	),
	fn showActionSource action_name = (
		
		local data = getActionByName action_name --{cat:Animation, name:Reverse_Animation, icon:106, cmd:mcAnimation.reverse 0 10}
		if data == undefined do return false
		local action_with_cmd = data.get "cmd" 
		local action_type = getActionType action_with_cmd
		if Micra.debug == 10 do format "mcFile > showActionSource > action type:%\n" action_type
		case action_type of --mcAnimation.reverse || Paint_Selection
		(
			"function": (
				
				local action_end = findString action_with_cmd " " --cut before "fn" parameter > mcAnimation.reverse 0 10 
				if action_end == undefined do action_end = findString action_with_cmd "(" --cut before "(" char > mcAction.capHoles()
				local action = substring action_with_cmd 1 (action_end-1)
				if Micra.debug == 10 do format "mcFile > showActionSource > action:%\n" action
				ShowSource (execute action) --ShowSource mcAnimation.reverse	
				return true
			)
			"file": (
				
				--format "action_with_cmd:%\n" action_with_cmd
				local fname = getActionParams action_with_cmd --get params as fname
				local current_dir = Micra.RootDir
				local fversion = getIniSetting Micra.DefaultSettings "Version" fname
				local file = current_dir + fname + "_v" + fversion + ".ms"
				if Micra.debug == 10 do format "mcFile > showActionSource > file:%\n" file
				edit file
				return true
			)
		)
		return false
	),
	/**
	*@Examples
		mcActionsEditor.runAction "Align"
		mcActionsEditor.runAction "Gallery_3D"
	*/
	fn runAction action_name = (
	
		local data = getActionByName action_name -- mcObject(name:action_name, category:category_name, val:data_array)
		if data == undefined do return false
		local action_with_cmd = data.get "cmd" 
		if Micra.debug == 10 do format "mcFile > runAction > action_name:% action_with_cmd:%\n" action_name action_with_cmd
		local action_type = getActionType action_with_cmd
		case action_type of (

			"function": (
			
				try (execute action_with_cmd) catch (
				
					format "mcFile > executeAction > error okurek!!! [%]\n\terror:%\n" action_with_cmd (getCurrentException())
				)
			)
			"file": (
				--get file name
				local fname = getActionParams action_with_cmd --get params as fname
				if Micra.debug == 10 do format "mcFile > runAction > params:%\n" fname
				Micra.fileInVersion fname		
			)
		)
	),
		/**
	*@Usage
		add script name and version to Settings.ini, like: Edge_Scale_Align = 0.01
		script_file_name: "Edge_Scale_Align"
	*/
	fn registerMicraScript script_file_name = (
	
		local version_pos = (findString script_file_name "_v")
		if version_pos == undefined do ( --copy file with version 0.01
			
			format  "Unable to activate file [ % ] without version." script_file_name
			return false
		)
		local script_version = substring script_file_name (version_pos+2) -1 
		local script_name = substring script_file_name 1 (version_pos-1)
		--register script
		if not doesFileExist Micra.DefaultSettings  do ((format "Not found! [%]\n" Micra.DefaultSettings); return false)
		mcFile.backupFile Micra.DefaultSettings max_cnt:4 --some times get INI damaged , backup it 
		local success = setIniSetting Micra.DefaultSettings "Version" script_name script_version
		format "mcFile > registerMicraScript > [%_v%]\tsuccess:%\n" script_name script_version success
	),
	/**
	*@Usage
		add button function to Actions.ini
		category_name:"Object" 
		action_name:"Reset Transform"
		action_data:"33, mcAction.reset_transform(), Reset Transform"
	*/
	fn registerAction category_name action_name action_data = (
	
		local action_key	= nameToKey action_name
		mcString.printInBlock "mcFile > registerAction > \n\tcatalog\t: %\n\taction\t: % \n\tdata\t: %\n" params:#(category_name, action_key, action_data)
		local success = setIniSetting Micra.ActionsIni category_name action_key action_data
		messageBox ("Action [ "+action_name+" ] was registred success:"+success as string) title:micra.version
	),
	fn unregisterAction category_name action_name = (
	
		local action_key	= nameToKey action_name
		delIniSetting Micra.ActionsIni category_name action_key
	),
	fn removeAction category_name action_name = (
	
		format "mcActionsEditor > removeAction > name:%\n " action_name
		unregisterAction category_name action_name
		--TODO
		--also remove action from micra tool button or create exception to dont load this action in to button
	),
	/**
	@Example
		path = getCommandPath "mcAction"
		struct_name = mcAction, mcAnimation, mcPoly, mcSnap, mcSkin, mcCreate, mcMax, mcShell,....
	@Return
		full file path
	*/
	fn getStructPathByName struct_name = (

		local struct_instance = execute struct_name
		--format "mcFile > getStructPathByName > struct_name:% struct_instance:%\n" struct_name struct_instance
		if (struct_instance != undefined and hasProperty struct_instance "getSource") then (
		
			try (struct_instance.getSource()) catch ( undefined )
			
		) else (undefined)
	),
	/**
	*@Usage
		get struct and function for editOrCreateAction
	*@Example
		obj = mcActionsEditor.splitCommand "mcAction.capHoles()"
		obj = mcActionsEditor.splitCommand "mcAction.capHoles #map:true"
		obj = mcActionsEditor.splitCommand "mcCreate.cereateChecker color1:(color 18 40 88) color2:(color 121 183 241)"
		obj.toString()
		obj.values()
		obj.keys()
	*@Return 
		mcObject #(struct_name:"capHoles",  fn_name:"groups", params_str:"map:true") 
	*/
	fn splitCommand action_cmd = (
				
		--format "splitCommand > action_cmd:%\n" action_cmd
		action_cmd = mcString.trimLeftRight action_cmd --remove left right spaces
		local dot_pos = findString action_cmd "."
		if dot_pos == undefined do return undefined --wrong command format
		local struct_name = substring action_cmd 1 (dot_pos-1) --get structure name > mcAction
		local function_name = (	--get function name > capHoles or capHoles()

			local brace_pos = findString action_cmd "(" --get first brace
			local space_pos = findString action_cmd " " --get first space
			if space_pos != undefined then ( --capHoles #map:true" --with parameters

				substring action_cmd (dot_pos+1) (space_pos-dot_pos-1) 
				
			) else (  --capHoles() --with braces
				
				if brace_pos != undefined then (
				
					substring action_cmd (dot_pos+1) (brace_pos-dot_pos-1) --remove braces
					
				) else (
				
					substring action_cmd (dot_pos+1) -1
				)
			)
		)
		local params_str = ""
		if space_pos != undefined do ( --get parameters
			
			params_str = substring action_cmd (space_pos+1) -1  --#map:true" | color1:(color 18 40 88) color2:(color 121 183 241)	
		)
		local data = mcObject()
		data.addMore #(
			
			mcItem "struct_name" struct_name, 
			mcItem "fn_name" function_name, 
			mcItem "params_str" params_str
		)
	),
	/**
	@Usage	
		category_name		Modify
		action_name			Vertex Color
		action_cmd		Micra.fileInVersion Vertex_Color or mcAction.capHoles()
		icon_index			208
		Return				Customize --> addNewAction --> send output
	*@Actions Methods
		*@Structure
			register existing action	> registerAction category_name action_name	(append data to Actions.ini)
			create new action			> addNewAction category_name action_name	(open script and insert action at struct end)
		*@File
			register existing tool		>
			create new tool				>
	*/
	fn editOrCreateAction category_name action_name action_cmd icon_index = (
		
		--fix action name string
		action_name = mcString.trimLeftRight action_name --remove left right spaces

		--assembly action
		local action_data = icon_index + ", " + action_cmd + ", " + action_name	
		--get action type
		local action_type = getActionType action_cmd
		case action_type of ( --function or file (mcAction.doSomething() or Micra.fileInVersion Lode_Tester or mcAction.groups #close)
			-----------------------------------------------------------------------------------------------------
			/* FUNCTION */
			-----------------------------------------------------------------------------------------------------
			"function": ( --create or register only
			
				--#(struct_name:"mcAction",  fn_name:"groups", params_str:"#close") 
				local cmd_obj = splitCommand action_cmd 
				if cmd_obj == undefined do return false --wrong command
				local struct_name = cmd_obj.get "struct_name"
				local fn_name = cmd_obj.get "fn_name"
				local fn_params = cmd_obj.get "params_str"
format "editOrCreateAction > action_name:% cmd :%\n\t%" action_name action_cmd (cmd_obj.toString())
				local structure_instance = execute struct_name
				if structure_instance != undefined then ( --register or append
				
					if hasProperty structure_instance fn_name then ( --if function exist register it (Action.ini)
					
						if not (isActionRegistred category_name (nameToKey action_name)) then ( --if not registred
						
							registerAction category_name action_name action_data
							
						) else ( --if already registred, abort
						
							messageBox ("Action [ "+action_name+" ] is already registred. Type different name.") title:micra.version
						)
					) else ( --create and register action at existing structure
					
						local success = mcMsx.editStrucrure struct_name --edit structure file (in Maxscript Editor)
						if not success do return false
						--define new function as string
						local new_fn = "fn " + fn_name
						if fn_params != "" do new_fn += " " + fn_params
						new_fn += " = (\n\t\t\n\t\tInsert Code Here...\n\t)"
						--append function fo current file (in Maxscript Editor)
						mcMsx.insertFunctionAtStructureEnd new_fn 
						--register new action
						registerAction category_name action_name action_data
					)
					
				) else ( --create new structure file and new function in CORE folder
				
					local struct_file = Micra.rootDir + struct_name + "\\.ms" 
					if queryBox ("Do you want to create new structure file?\n[ " + struct_file + " ]") title:micra.version do (
					
						--create new file 
						
						--edit new file
						
						--insert new function
						print "function > try to create struct file"
					)
				)
			)
			-----------------------------------------------------------------------------------------------------
			/* FILE */
			-----------------------------------------------------------------------------------------------------
			"file": ( --create or register only
			
				local fname = getActionParams action_cmd --get params as fname
				format "editOrCreateAction > cmd :% fname:%\n" action_cmd fname
			)
		)
	)
)	
 --create instance
Global mcActionsEditor = Micra.instanceStructure MICRA_ACTIONS_EDITOR "mcActionsEditor"


/*
		-----------------------------------------------------------------------------------------------------
		--IF CMD contains [fileInVersion] create new script or register existing
			--REGISTER scipt to Settings.ini [Version]
			--APPEND action  to Actions.ini  [category_name] [action_name]
		-----------------------------------------------------------------------------------------------------
		if findString action_cmd "fileInVersion" != undefined then (
		
			--check if file exists
			local script_path = "undefined"
			local root_files = getFiles (Micra.rootDir + "*.ms")
			for f in root_files do (
			
				if findString f action_key != undefined do (
				
					script_path = f
					exit --break loop
				)
			)
			format "search > script [ % ] exists:% script_path:%\n" action_key (doesFileExist script_path) script_path  
			if doesFileExist script_path then ( --if script file found
			
				--check if script is registred
				local script_version = Micra.getScriptVersion action_key
				if script_version != "" then ( --if already registred, abort 
				
					format "mcFile > appendActionOrCreateScript > Script [ % ] is already registred. Operation aborted.\n" action_key
					return false
				) else ( --register existing script
					
					local script_file_name = filenameFromPath script_path
					format "mcFile > appendActionOrCreateScript > Script [ % ] is registred succesfully.\n" script_file_name
--enable it > registerMicraScript script_file_name
--enable it > setIniSetting Micra.ActionsIni category_name action_key action_data
				)
				
			) else ( --crete new script
			
				local script_file_name = action_key + "_v0.01.ms"
				script_path = Micra.rootDir + script_file_name
				local template_file = Micra.rootDir + "CORE\\" + "_template.txt"
 				--copy template in to file
				copyFile template_file script_path
--enable it > registerMicraScript script_file_name
--enable it > setIniSetting Micra.ActionsIni category_name action_key action_data
				format "mcFile > appendActionOrCreateScript > Script [ % ] is created succesfully.\n" script_file_name
			)
			--open script  
			edit script_path
			return true
*/
