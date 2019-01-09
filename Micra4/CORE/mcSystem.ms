--------------------------------------------------------------------------------
/* mcSystem by Orien 2019 */
--------------------------------------------------------------------------------
/*
*@Used Structures
	Micra
*
*@Used Objects

*
*/
Global mcSystem
struct mcSystem (

	fn units_type = (
	
		case units.SystemType of
		(
			#Inches:"inc"
			#Feet:"ft"
			#Miles:"mi"
			#Millimeters:"mm"
			#Centimeters:"cm"
			#Meters:"m"
			#Kilometers:"km"
		)
	),
	fn time = 
	(
		Local arr, mTime
		arr = filterString LocalTime "./ :"
		if arr.count < 5 do return "invalid time"
		mTime = arr[4] + ":" + arr[5] + "   " + arr[1] + "." + arr[2] + "." + arr[3]
		return mTime
	),
	fn autosaveSwitch = (
	
		local current_state = autosave.enable
		autosave.enable = not current_state
		messageBox ("Autosave is turned to:" + autosave.enable as string) title:" Micra:"
	),
	fn keyboardSwitch = (
	
		local current_shortcuts = actionMan.getKeyboardFile() 
		local merlin_shortcuts = "D:\ReneBaca\3DsMax\Merlin_UI_2018.kbdx"
		local default_shortcuts = "D:\ReneBaca\3DsMax\DefaultUI.kbdx"
		
		local sortcuts_file = if current_shortcuts == merlin_shortcuts then default_shortcuts else merlin_shortcuts
		actionMan.loadKeyboardFile sortcuts_file
		local state = if sortcuts_file == merlin_shortcuts then "Merlin" else "Default"
		messageBox ("Shortcuts was set to:" + state) title:" Micra:"
	),
	fn editTexturesInPhotoshop = 
	(		
		if not QueryBox "Edit Textures in Photosop?" title:" Micra:" do return false
		fn getDirectXBitmaps mat = 
		(
			local bCount = mat.numberofbitmaps()
			newimages= for i=1 to bCount where ((local b = mat.geteffectbitmap i) != undefined) collect b
		)
		
		local images=#()
		if mateditor.isopen() 
		then
		(
			local mat=medit.getcurmtl()
			if classOf mat == DirectX_9_Shader
			then images= getDirectXBitmaps mat
			else images= getClassInstances Bitmaptexture target:mat -- get all textures from material or multimaterial
		) 
		else
		(
			local sel=selection as array
			if sel.count == 0 do return false
			for o in sel do
			(
				if o.material!=undefined then
				(
					local newimages

					if classOf o.material == DirectX_9_Shader 
					then newimages= getDirectXBitmaps o.material
					else newimages= getclassinstances Bitmaptexture target:o.material

					--collecting unique images to array
					for i in newimages do mcArray.appendIfUnique images i
				)
			)
		)
		local ps=CreateOLEObject"Photoshop.Application"
		ps.Visible=true
		for i in images do
		( 
			if doesFileExist i.filename 
			then ps.open i.filename
			else messageBox ("The file: ["+i.filename+"] is not Exist.") title:"Micra..."
		)
	),
	fn show arg  =
	(
		print "---------------------------------------------------------------------------" 
		format "Info:%\n" arg 
		print "---------------------------------------------------------------------------"
		try (format "ClassOf: %\n"      (classOf        arg)) catch (format "No ClassOf for %\n" arg)
		try (format "SuperClassOf: %\n" (superClassOf   arg)) catch (format "No SuperClassOf for %\n" arg)
		try (format "ShowClass: %\n"   (showClass      arg)) catch (format "No ShowClass for %\n" arg)
		try (format "show:%\n"       (show           arg)) catch (format "No Show for %\n" arg)
 		try (format "PROPERTIES:\n"   (showProperties arg)) catch (format "No Properties for %\n" arg)
 		try (format "METHODS:\n"    (showMethods    arg)) catch (format "No Methods for %\n" arg)
 		try (format "EVENTS:\n"      (showEvents     arg)) catch (format "No Events for %\n" arg)
		try (format "PropNames: %\n" (getPropNames   arg)) catch (format "No PropNames for %\n" arg)
		try (format "Interface: %\n"   (showInterface  arg)) catch (format "No Interface for %\n" arg)
		try (format "Constructors: %\n" (dotNet.showConstructors arg)) catch (format "No Constructors for %\n" arg)
		try (format "GetInterface: %\n" (getInterface arg)) catch (format "No GetInterface for %\n" arg)
	),
	fn getAllDialogsHWND = ( for i in UIAccessor.GetPopupDialogs() collect (UIAccessor.GetWindowText i) ),
	fn closeDialogByTitle window_text =
	(
		local ace = UIAccessor.GetPopupDialogs()
		for i in ace where findString (UIAccessor.GetWindowText i) window_text != undefined do 
		(
			UIAccessor.CloseDialog i
			--UIAccessor.PressButtonByName i "Cancel"
			exit
		)
	),	
	fn getDialogHWND window_text =
	(
		for d in UIAccessor.GetPopupDialogs() where
		findString (UIAccessor.GetWindowText d) window_text != undefined do exit with d
	),
	fn getDialogData window_text =
	(
		for i in UIAccessor.GetPopupDialogs() where 
		findString (UIAccessor.GetWindowText i) window_text != undefined do 
		(
			format "WindowText:%\n" (UIAccessor.GetWindowText i)
			format "WindowClassName:%\n" (UIAccessor.GetWindowClassName i)
			format "WindowResourceID:%\n"(UIAccessor.GetWindowResourceID i)
			format "GetChildWindows:%\n"(UIAccessor.GetChildWindows i)
			format "GetParentWindow:%\n"(UIAccessor.GetParentWindow i)
			format "GetFirstChildWindow:%\n"(UIAccessor.GetFirstChildWindow i)
			format "GetPrevWindow:%\n"(UIAccessor.GetPrevWindow i)
			format "GetNextWindow:%\n"(UIAccessor.GetNextWindow i)
			format "IsWindow:%\n"(UIAccessor.IsWindow i)
			format "GetWindowDllFileName:%\n"(UIAccessor.GetWindowDllFileName i)
			format "GetWindowDllDescription:%\n"(UIAccessor.GetWindowDllDescription i)
			exit
		)
	),
	fn getActionType action_with_cmd = (
	
format "getActionType > action_cmd:%\n" action_cmd
		--mcAnimation.reverse 0 10 
		--Micra.fileInVersion Paint_Selection
		--max align
		--ShellLaunch C:\WINDOWS\system32\calc.exe
		--if checkForSave() != false do resetMaxFile #noPrompt
		local action_type = undefined
		if (findString action_with_cmd "Micra.fileInVersion" != undefined) then action_type = "file"
		if (findString action_with_cmd "ShellLaunch" != undefined		) then action_type = "shell"
		if (findString action_with_cmd "if" != undefined				) then action_type = "complex"
		if (findString action_with_cmd "max" != undefined			) then action_type = "function"
		if action_type == undefined do action_type = "function" --defaul type
		action_type
	),
	fn parseActionData ini_data action_category action_name = (
	
		ini_data = mcString.trimLeftRight ini_data --remove white space left and right
		ini_data = mcString.replaceInString ini_data ", " "," -- remove white space after comma 	
		local data_array = filterString ini_data "," --split string in to array
		if classof data_array != array do return undefined --conversion failed
format "parseActionData > data_array:%\n" data_array
		local mc_obj = mcObject()
		mc_obj.add "cat" action_category
		mc_obj.add "name" action_name
		mc_obj.add "icon" data_array[1]
		mc_obj.add "cmd" data_array[2]
		mc_obj --{cat:Animation, name:Reverse_Animation, icon:106, cmd:mcAnimation.reverse 0 10}
	),
	fn getActionData action_category action_name = (
	
		if not doesFileExist Micra.ActionsIni do ((format "Not found! [%]\n" Micra.ActionsIni); return undefined)
		--icon, cmd, name
		--106, mcAnimation.reverse 0 10, Reverse Animation
		--221, Micra.fileInVersion 3DGallery, 3D Gallery
		--63, max align, Align
		--32, ShellLaunch C:\WINDOWS\system32\calc.exe , Calculator
		--2 , (if checkForSave() != false do resetMaxFile #noPrompt),Max Reset --#noPrompt
		local ini_data = getIniSetting Micra.ActionsIni action_category action_name 
		format "ini_data:%\n" ini_data
		if ini_data != "" then (
				
			mcSystem.parseActionData ini_data action_category action_name
			
		) else (
		
			undefined
		)
	),
	--search in Micra.ActionsIni by name
	fn getActionByName action_name = (
	
		if not doesFileExist Micra.ActionsIni do ((format "Not found! [%]\n" Micra.ActionsIni); return undefined)
		local heads = getIniSetting Micra.ActionsIni
		for action_category in heads do( --INI Heads
			local ini_data = getIniSetting Micra.ActionsIni action_category action_name --INI Key
			if ini_data != "" do (
				
				--{cat:Animation, name:Reverse_Animation, icon:106, cmd:mcAnimation.reverse 0 10}
				return mcSystem.parseActionData ini_data action_category action_name
			)
		)
		return undefined
	),
	fn showActionSource action_name = (
		
		local data = mcSystem.getActionByName action_name --{cat:Animation, name:Reverse_Animation, icon:106, cmd:mcAnimation.reverse 0 10}
		if data == undefined do return false
		local action_with_cmd = data.get "cmd" 
		local action_type = mcSystem.getActionType action_with_cmd
format "mcSystem > showActionSource > action type:%\n" action_type
		case action_type of --mcAnimation.reverse || Paint_Selection
		(
			"function": (
				
				local action_end = findString action_with_cmd " " --cut before "fn" parameter > mcAnimation.reverse 0 10 
				if action_end == undefined do action_end = findString action_with_cmd "(" --cut before "(" char > mcAction.capHoles()
				local action = substring action_with_cmd 1 (action_end-1)
format "show source in struct:%\n" action
				ShowSource (execute action) --ShowSource mcAnimation.reverse					
			)
			"file": (
				
				--format "action_with_cmd:%\n" action_with_cmd
				local fname_start = findString action_with_cmd " " --find first space in cmd[Micra.fileInVersion "Paint_Selection"]
				local fname = substring action_with_cmd fname_start -1
				local current_dir = Micra.RootDir
				local fversion = getIniSetting Micra.DefaultSettings "Version" fname
				local file = current_dir + fname + "_v" + fversion + ".ms"
				format "show source in file:%\n" file
				edit file
			)
		)
	),
	/**
	*@Examples
		mcSystem.runAction "Align"
		mcSystem.runAction "Gallery_3D"
	*/
	fn runAction action_name = (
	
		local data = mcSystem.getActionByName action_name -- mcObject(name:action_name, category:action_category, val:data_array)
		if data == undefined do return false
		local action_with_cmd = data.get "cmd" 
format "runAction > action_name:% action_with_cmd:%\n" action_name action_with_cmd
		local action_type = mcSystem.getActionType action_with_cmd
		case action_type of (

			"function": (
			
				--mcAnimation.reverse
				try (execute action_with_cmd) catch (format "error okurek!!! [%]\nerror:%\n" action (getCurrentException()))			
			)
			"file": (
				
				local space = findString action_with_cmd " " --end of fileInVersion
				local params	= substring action_with_cmd space -1
				params = mcString.trimLeftRight params --remove white spaces front back
				format "run params:%\n" params
				try (Micra.fileInVersion params) catch (format "error okurek!!! [%]\nerror:%\n" action (getCurrentException()))			
			)
			"complex":(
			
				/*
				local cmd_start = findString action_with_cmd " " --find enf of fileInVersion
				local cmd		= substring action_with_cmd 1 cmd_start
				cmd = mcString.trimLeftRight cmd --remove white spaces front back
				local params	= substring action_with_cmd cmd_start -1
				params =  mcString.trimLeftRight params --remove white spaces front back
				cmd = execute cmd --get fileInVersion instance
				format "run cmd:% params:%\n" cmd params
				try (cmd params) catch (format "error okurek!!! [%]\nerror:%\n" action (getCurrentException()))	*/
			)
		)
	),
	fn getSHGameVersion =
	(
		local ifile = "c:/Dev/SilentHill/SHGame/Build-info.txt"
		if not doesFileExist ifile do return false
		local f = openfile ifile
		local first_line = readline f
		local v = (filterString first_line ": ")[2]
		setclipboardText v
		print v
		flush f
		close f
	),
	fn getMaxPos = (
		
		return windows.getWindowPos (windows.getMAXHWND())
	),
	fn getMaxCenter = (
	
		local max_pos = mcSystem.getMaxPos()
		return [max_pos.w/2 + max_pos.x /2, max_pos.h/2 + max_pos.y /2]
	)
)
 --creating instance caused endless loop
--Global mcSystem = Micra.instanceStructure MICRA_SYSTEM "mcSystem"
