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
*@Debug
	index	: 10
*
*/
struct MICRA_ACTIONS_EDITOR	(
	
	--variables

	
	--functions
	fn getSource = getSourceFileName(), --get path of this script
	fn getCategories = (
	
		mcFile.readSettings Micra.ActionsXML "ACTIONS" type:"keys"
	),
	/**
	*@Usage > get action type for different execute metods	
	*/
	fn getActionType action_with_cmd = (
	
		if (findString action_with_cmd "mcFile.fileInVersion" != undefined) then "file" else "function"
	),
	fn getActions category_key = (
	
		mcFile.readSettings Micra.ActionsXML ("ACTIONS/"+category_key) type:"keys"
	),
	fn actionExists category_key action_key = (findItem (getActions category_key) action_key > 0),
	fn categoryExists category_key = (findItem (getCategories()) category_key > 0),
	fn saveCategory category_key = (
	
		mcFile.saveSettings Micra.ActionsXML ("ACTIONS/" + category_key) "" --add-replace node only
	),
	fn delCategory category_key = ( --Actions.xml
	
		mcFile.delSettings Micra.ActionsXML ("ACTIONS/" + category_key) --remove single node
	),
	fn saveButton button_key action_key icon_str = ( --use current Profile_?(1-8).xml
		
		local node_attribs = (mcObject.new()).addMore #(

			mcItem "action" action_key, 
			mcItem "icon" icon_str
		)
		mcFile.saveSettings Micra.UserProfile ("Buttons/" + button_key) node_attribs type:"attribs"
	),
	fn saveButtonByName action_key icon_str = (
	
		--replace button data in current profile
		local all_button_keys = mcFile.readSettings Micra.UserProfile "Buttons" type:"keys"
		if all_button_keys.count == 0 do return false --if buttons are not registred
		local button_key = for key in all_button_keys do ( --find button_key from action 
		
			local action_name = mcFile.readSettings Micra.UserProfile ("Buttons/"+key) type:"action"
			if action_name == action_key do exit with key
		)
		if button_key != OK do saveButton button_key action_key icon_str --override button settings
	),
	fn deleteButton button_key = (
	
		mcFile.delSettings Micra.UserProfile ("Buttons/" + button_key) --remove single node
	),
	fn readActionHelp category_key action_key = (
	
		mcFile.readSettings Micra.ActionsHelpXML ("ACTIONS/"+category_key + "/" + action_key)
	),
	fn saveActionHelp category_key action_key help_text = (
	
		mcFile.saveSettings Micra.ActionsHelpXML ("ACTIONS/"+category_key+"/"+action_key) help_text
	),
	/**
	*@Usage > replace spaces with underscore: Gallery 3D > Gallery_3D
	*/
	fn nameToKey action_name = (mcString.replaceAll action_name " " "_"),
	/**
	*@Usage > convert xml dat to mcObject
		xml_data		: mcXMLNode
		category_key	: String > "Object"
		action_key		: String > "Lock_Object"
		return 			: mcObject > cat:Object name:Lock_Object icon:88 cmd:mcAction.lockObjects true tooltip:Lock Object
	*/
	fn parseActionData xml_data category_key action_key = (

		if classOf xml_data != mcXMLNode do return undefined --parsing failed
		if Micra.debug == 10 do format "mcActionsEditor > parseActionData > xml_data:%\n" (xml_data.toString()) --show xml node
		local mc_obj = mcObject()
		mc_obj.add "cat" category_key
		mc_obj.add "name" action_key
		mc_obj.add "icon" (xml_data.getAttribute "icon")
		mc_obj.add "cmd" (xml_data.getAttribute "cmd")
		mc_obj.add "tooltip" (xml_data.getAttribute "tooltip")
		mc_obj
	),
	/**
	*@Usage > get action from Actions.xml by category and name
		action_key		: String
		return 			: mcObject
	*@Example
		action = mcActionsEditor.readActionData "Object" "Lock_Object"
		action.toString()
		--> "cat:Object name:Lock_Object icon:88 cmd:mcAction.lockObjects true tooltip:Lock Object"
	*/
	fn readActionData action_key = (
	
		if not doesFileExist Micra.ActionsXML do ((format "Missing File! [%]\n" Micra.ActionsXML); return undefined)
		local xml = mcXML Micra.ActionsXML
		if Micra.debug == 10 do format "mcActionsEditor > readActionData  > from xml:%\n" (xml.toString()) --show whole xml
		local xml_data = xml.getNode ("//"+action_key)
		if xml_data != undefined then (
				
			local category_key = xml_data.parent.name
			parseActionData xml_data category_key action_key
			
		) else (
		
			format "Action [ % ] is not registred!" action_key
			undefined
		)
	),
	/**
	*@Usage > check if action exists in Actions.xml file
		category_key	: String
		action_key		: String
		return 			: Boolean
	*@Example
		mcActionsEditor.isActionRegistred "Object" "Lock_Object"
		--> true or false
	*/
	fn isActionRegistred category_key action_key = ((readActionData action_key) != undefined),
	/**
	*@Usage > get action parameters 
		action_with_cmd	: String > "mcFile.fileInVersion Paint_Selection"
		return			: String > "Paint_Selection"
	*/
	fn getActionParams action_with_cmd = (
	
		local first_space = (findString action_with_cmd " ") --find first space
		local params = substring action_with_cmd first_space -1 --get rest (params)
		params = mcString.cutLeftRight params --trim white spaces left right
		params
	),
	/**
	*@Usage > edit file which contains action
		action_key		: String
		return			: Boolean
	*/
	fn showActionSource action_key = (
		
		local action_data = readActionData action_key --mcObject(cat:Animation, name:Reverse_Animation, icon:106, cmd:mcAnimation.reverse 0 10)
		if action_data == undefined do return false
		local action_with_cmd = action_data.get "cmd" 
		local action_type = getActionType action_with_cmd
		if Micra.debug == 10 do format "mcActionsEditor > showActionSource > action type:%\n" action_type
		case action_type of --mcAnimation.reverse || Paint_Selection
		(
			"function": (
				
				local action_end = findString action_with_cmd " " --cut before "fn" parameter > mcAnimation.reverse 0 10 
				if action_end == undefined do action_end = findString action_with_cmd "(" --cut before "(" char > mcAction.capHoles()
				local action = substring action_with_cmd 1 (action_end-1)
				if Micra.debug == 10 do format "mcActionsEditor > showActionSource > action:%\n" action
				ShowSource (execute action) --ShowSource mcAnimation.reverse	
				return true
			)
			"file": (
				
				--format "action_with_cmd:%\n" action_with_cmd
				local fname = getActionParams action_with_cmd --get params as fname
				local current_dir = Micra.RootDir
				local fversion = mcFile.getScriptVersion fname
				local file = current_dir + fname + "_v" + fversion + ".ms"
				if Micra.debug == 10 do format "mcActionsEditor > showActionSource > file:%\n" file
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
	fn runAction action_key = (
	
		if action_key == undefined or action_key == "" do return false
		local action_data = readActionData action_key --mcObject(cat:Animation, name:Reverse_Animation, icon:106, cmd:mcAnimation.reverse 0 10)
		if action_data == undefined do return false
		local action_with_cmd = action_data.get "cmd" 
		if Micra.debug == 10 do format "mcActionsEditor > runAction > action_key:% action_with_cmd:%\n" action_key action_with_cmd
		local action_type = getActionType action_with_cmd
		case action_type of (

			"function": (
			
				try (execute action_with_cmd) catch (
				
					format "mcActionsEditor > executeAction > error okurek!!! [%]\n\terror:%\n" action_with_cmd (getCurrentException())
				)
			)
			"file": (
				--get file name
				local fname = getActionParams action_with_cmd --get params as fname
				if Micra.debug == 10 do format "mcActionsEditor > runAction > params:%\n" fname
				mcFile.fileInVersion fname		
			)
		)
	),
		/**
	*@Usage > add script name and version to Settings.ini, like: Edge_Scale_Align = 0.01
		script_name: String > "Color_Palete_v0.56"
	*/
	fn registerMicraScript script_name = (
	
		local version_pos = (findString script_name "_v")
		if version_pos == undefined do ( --file is without version
			
			format  "Unable to activate file [ % ] without version." script_name
			return false
		)
		local script_version = substring script_name (version_pos+2) -1 
		local script_name = substring script_name 1 (version_pos-1)
		--register script
		local success = mcFile.saveSettings Micra.DefaultSettings ("Version/" + script_name) script_version
		format "mcActionsEditor > registerMicraScript > [%_v%]\tsuccess:%\n" script_name script_version success
	),
	--fn addAction
	/**
	*@Usage
		add button function to Actions.ini
		category_key	: "Object" 
		action_key		: "Reset_Transform"
		icon_str		: "33"
		cmd_str			: "mcAction.reset_transform()"
	*/
	fn saveAction category_key action_key icon_str cmd_str 	= (
	
		local action_name = mcString.replaceAll action_key "_" " " --"Reset Transform"
		mcString.printInBlock "mcActionsEditor > saveAction > \n\tcatalog\t: %\n\taction\t: % \n\tdata\t: %\n" params:#(category_key, action_key, action_data)
		local action_data = (mcObject.new()).addMore #(

			mcItem "icon" icon_str,
			mcItem "cmd" cmd_str,
			mcItem "tooltip" action_name 
		)
		--<Gallery_3D icon="221" cmd="mcFile.fileInVersion Gallery3D" tooltip="Gallery 3D" />
		mcFile.saveSettings Micra.ActionsXML (category_key+"/"+action_key) action_data type:"attribs"
	),
	/**
	*Usage 
		1) Remove Action from Actions.xml (actions list)
		2) Remove Action from All Profiles (1-8) (buttons list)
	*/
	fn removeAction category_key action_key = (
	
		if not (queryBox ("Do you want to delete Action[ "+action_key+" ] ?") title:micra.version) do return OK
		--Deleted button data from all profiles (Profile_1.ini - Profile_8.ini)
		local all_profiles = for i=1 to 8 collect Micra.UserDir + "Profile_" + i as string + ".xml"
		for p in all_profiles do (
		
			local all_button_keys = mcFile.readSettings p "Buttons" type:"keys"
			--format "profile:% button keys:%\n" p all_button_keys.count
			if all_button_keys.count == 0 do continue
			local button_key = for key in all_button_keys do ( --find button_key from action 
			
				local action_name = mcFile.readSettings p ("Buttons/"+key) type:"action"
				if action_name == action_key do exit with key
			)
			if button_key != OK do (
			
				mcFile.delSettings p ("Buttons/"+button_key) --remove button
				format "mcActionsEditor > removeAction > Remove Button [ % ] from:%\n " button_key p
			)
		)
		--Delete action from Action.xml
		mcFile.delSettings Micra.ActionsXML (category_key+"/"+action_key) --remove action
		format "mcActionsEditor > removeAction > Remove Action [ % ] from:%\n " action_key Micra.ActionsXML
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
		--format "mcActionsEditor > getStructPathByName > struct_name:% struct_instance:%\n" struct_name struct_instance
		if (struct_instance != undefined and hasProperty struct_instance "getSource") then (
		
			try (struct_instance.getSource()) catch ( undefined )
			
		) else (undefined)
	),
	/**
	*@Usage > get struct and function for editOrCreateAction
	*@Example
		obj = mcActionsEditor.splitCommand "mcAction.capHoles()"
		obj = mcActionsEditor.splitCommand "mcAction.capHoles #map:true"
		obj = mcActionsEditor.splitCommand "mcCreate.cereateChecker color1:(color 18 40 88) color2:(color 121 183 241)"
		obj = mcActionsEditor.splitCommand "mcFile.fileInVersion Object_Inspector"
		obj.toString()
		obj.values()
		obj.keys()
	*@Return 
		mcObject #(struct_name:"capHoles",  fn_name:"groups", params_str:"map:true") 
	*/
	fn splitCommand action_cmd = (
				
		--format "splitCommand > action_cmd:%\n" action_cmd
		action_cmd = mcString.cutLeftRight action_cmd --remove left right spaces
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
		category_key		Modify
		action_key			Vertex Color
		action_cmd		mcFile.fileInVersion Vertex_Color or mcAction.capHoles()
		icon_index			208
		Return				Customize --> addNewAction --> send output
	*@Actions Methods
		*@Structure
			register existing action	> saveAction category_key action_key	(append data to Actions.ini)
			create new action			> addNewAction category_key action_key	(open script and insert action at struct end)
		*@File
			register existing tool		>
			create new tool				>
	*/
	fn editOrCreateAction category_key action_key action_cmd icon_index = (
		
		--fix action name string
		action_key = mcString.cutLeftRight action_key --remove left right spaces
		
		--get action type
		local action_type = getActionType action_cmd
		case action_type of ( --function or file (mcAction.doSomething() or mcFile.fileInVersion Lode_Tester or mcAction.groups #close)
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
format "editOrCreateAction > action_key:% cmd :%\n\t%" action_key action_cmd (cmd_obj.toString())
				local structure_instance = execute struct_name
				if structure_instance != undefined then ( --register or append
				
					if hasProperty structure_instance fn_name then ( --if function exist register it (Action.ini)
					
						if not (isActionRegistred category_key (nameToKey action_key)) then ( --if not registred
						
							saveAction category_key action_key (icon_index as String) action_cmd
							
						) else ( --if already registred, abort
						
							messageBox ("Action [ "+action_key+" ] is already registred. Type different name.") title:micra.version
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
						saveAction category_key action_key (icon_index as String) action_cmd
					)
					
				) else ( --create new structure file and new function in CORE folder
		
					local script_path = Micra.CoreDir + struct_name + "_v0.01.ms"  --"Vertex_Color_v0.01"
					if not (queryBox ("Do you want to create new structure file?\n[ " + script_path + " ]") title:micra.version) do return OK 
					local template_file = Micra.CoreDir + "_template.txt"
					--copy template in to file
					copyFile template_file script_path
					format "editOrCreateAction > Script [ % ] is created succesfully.\n" script_name
					edit script_path --edit new file
					--insert new function
					local new_fn = "fn " + fn_name
					if fn_params != "" do new_fn += " " + fn_params
					new_fn += " = (\n\t\t\n\t\tInsert Code Here...\n\t)"
					--append function fo current file (in Maxscript Editor)
					mcMsx.insertFunctionAtStructureEnd new_fn 
					--register new action in Actions.xml (All Actions List)
					saveAction category_key action_key (icon_index as String) action_cmd
					--register new Script in Settings.xml "Structures" (load at 3DsMax start)
					local node_attribs = (mcObject.new()).add "val" "on" 
					mcFile.saveSettings Micra.DefaultSettings ("Structures/"+struct_name) node_attribs type:"attribs"
				)
			)
			
			-----------------------------------------------------------------------------------------------------
			/* FILE */
			-----------------------------------------------------------------------------------------------------
			"file": ( --create or register only
			
				--if is already registred break
				local fname = getActionParams action_cmd --get params as fname
				local script_version = mcFile.getScriptVersion fname
				--format "editOrCreateAction > Script :% version:%\n" fname script_version
				if script_version != "" do ( --if script already registred, abort 	

					messageBox ("Script [ "+fname+" ] is already registred. Type different name.") title:micra.version
					edit (Micra.rootDir + fname + "_v" + script_version + ".ms")
					return false
				)
				--if file exists register it
				local script_path = "undefined"
				local script_name = ""
				local root_files = getFiles (Micra.rootDir + "*.ms")
				for f in root_files do (
				
					if findString f fname != undefined do (
					
						script_path = f
						exit --break loop
					)
				)
				if doesFileExist script_path then ( --register existing script
								
					script_name = getFilenameFile script_path --"Vertex_Color_v1.02"
					format "editOrCreateAction > Script [ % ] is registred succesfully.\n" script_name
					
				) else ( --if script not exists crete new one
					
					script_name = fname + "_v0.01" --"Vertex_Color_v0.01"
					script_path = Micra.rootDir + script_name + ".ms"
					local template_file = Micra.rootDir + "CORE\\" + "_template.txt"
					--copy template in to file
					copyFile template_file script_path
					registerMicraScript script_name
					format "editOrCreateAction > Script [ % ] is created succesfully.\n" script_name
					edit script_path
				)
				--register script in Settings.xml
				registerMicraScript script_name 
				--Add new action to Actions.ini >  <Iron_Sight icon="77" cmd="mcAction.pivot_iron_sight()" tooltip="Iron Sight" />
				local action_data = (mcObject.new()).addMore #(

					mcItem "icon" (icon_index as String),
					mcItem "cmd" action_cmd,
					mcItem "tooltip" (mcString.replaceAll action_key "_" " ")
				)
				mcFile.saveSettings Micra.ActionsXML (category_key + "/" + action_key) action_data type:"attribs"
				format "editOrCreateAction > Script [ % ] is aded to category [ % ].\n" script_name category_key
				return true
			)
		)
	)
)	
 --create instance
Global mcActionsEditor = mcStructMan.instanceStructure MICRA_ACTIONS_EDITOR "mcActionsEditor"