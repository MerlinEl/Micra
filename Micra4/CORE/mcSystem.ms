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
	fn getActionData action_category action_name = (
	
		if not doesFileExist Micra.ActionsIni do ((format "Not found! [%]\n" Micra.ActionsIni); return undefined)
		local data = getIniSetting Micra.ActionsIni action_category action_name --#(106, "mcAnimation.reverse 0 10" , "Reverse_Animation")
		if data != "" do (
				
			local data_array = execute data --convert string to array
			if classof data_array != array then exit --conversion failed
			return data_array
		)
		return undefined
	),
	--search in Micra.ActionsIni by name
	fn getActionByName action_name = (
	
		if not doesFileExist Micra.ActionsIni do ((format "Not found! [%]\n" Micra.ActionsIni); return undefined)
		local heads = getIniSetting Micra.ActionsIni
		for action_category in heads do( --INI Heads
			local data = getIniSetting Micra.ActionsIni action_category action_name --INI Key
			if data != "" do (
				
				local data_array = execute data --convert string to array
				if classof data_array != array then exit --conversion failed
				local mc_obj = mcObject()
				mc_obj.add "name" action_name
				mc_obj.add "category" action_category
				mc_obj.add "val" data_array
				return mc_obj -- mcObject(name:action_name, category:action_category, val:data_array)
			)
		)
		return undefined
	),
	fn showActionSource action_name = (
		
		local data = mcSystem.getActionByName action_name -- mcObject(name:action_name, category:action_category, val:data_array)
		if data == undefined do return false
		local action_with_cmd = (data.get "val")[2] --(mcAnimation.reverse 0 10 ||  Micra.fileInVersion \"Paint_Selection\"")[2]
		local action_type = if findString action_with_cmd "Micra.fileInVersion" == undefined then "function" else "file"
		--format "action type:%\n" action_type
		case action_type of --mcAnimation.reverse || Paint_Selection
		(
			"function": (
				
				local action_end = findString action_with_cmd " " --end with: parameter
				if action_end == undefined do action_end = findString action_with_cmd "(" --end with: ()
				local action = substring action_with_cmd 1 (action_end-1)
				format "show source in struct:%\n" action
				ShowSource (execute action)										
			)
			"file": (
				
				--format "action_with_cmd:%\n" action_with_cmd
				local fname_start = findString action_with_cmd " " --find first space in cmd[Micra.fileInVersion "Paint_Selection"]
				local fname = substring action_with_cmd fname_start -1
				fname = execute fname -- remove quotes
				local current_dir = Micra.RootDir
				local fversion = getIniSetting Micra.DefaultSettings "Version" fname
				local file = current_dir + fname + "_v" + fversion + ".ms"
				format "show source in file:%\n" file
				edit file
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
	
		local max_pos = getMaxPos()
		return [max_pos.w/2 + max_pos.x /2, max_pos.h/2 + max_pos.y /2]
	)
)
 --creating instance caused endless loop
--Global mcSystem = Micra.instanceStructure MICRA_SYSTEM "mcSystem"
