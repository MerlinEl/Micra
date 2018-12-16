----------------------------------------------------------------------------
--xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx--

                             -- Micra VI --
							 
--xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx--
--                       Created by MerlinEl 2018                         --
----------------------------------------------------------------------------

Global Micra

struct MICRA_STRUCTURE (

	debug				= true,
	version				= "Micra IV",
	username			= substituteString sysInfo.username " " "_", --replace wihitespaces with "_"
	files_list			= #(),
	restart_need		= false,
	RootDir				= getFilenamePath (getSourceFileName()),
	DefaultDir			= RootDir + "Default\\",
	DefaultSettings		= RootDir + "Settings.ini", --store file versions
	UserDir				= RootDir + "User\\" + username + "\\",
	UserSettings		= UserDir + "Settings.ini", --store user profile
	DefaultUserSettings	= DefaultDir + "Settings.ini", --defaul user profile
	EmptyProfileIni		= DefaultDir + "Profile_Empty.ini", --profile without buttons and tollbars 
	TempProfileINI		= DefaultDir + "Profile_Temp.ini", --saved current session
	DefaultProfileIni	= DefaultDir + "Profile_Default.ini", --default profile 
	TempIni				= UserDir + "Temp.ini",
	ImagesPath 			= RootDir + "Img\\", --all images here
	ActionsIni			= RootDir + "Actions.ini",
	ActionsHelpIni		= RootDir + "Actions_Help.ini",
	PluginsDir			= RootDir + "plugins\\", --all plugins here
	Macro				= getDir #userMacros + "\\Micra_Macro.mcr",
	MaxUserSettings 	= (pathConfig.removePathLeaf (GetDir #temp))+ "\\Plugin.UserSettings.ini",
	ImgPath				= RootDir + "Img\\", 
	IconI				= RootDir + "Img\\mcIcons_24_480x480i.bmp",
	IconM				= RootDir + "Img\\mcIcons_24_480x480m.bmp",
	--Set Memory Allocation in MB
	fn increaseMemory mb = (
	
		local hsize = mb*1000000
		if heapSize < hsize do heapSize = hsize
	),
	-->  OLD File in Version
	fn getScriptVersion script_name = (
		
		return (getIniSetting DefaultSettings "Version" script_name)
	),
	fn fileInVersion script_name = (	
	
		local f_version = getScriptVersion script_name
		if f_version == "" do(
		
			format "File[%], is not registred in [%]\n" script_name DefaultSettings
			return false
		)
		local file = RootDir + script_name + "_v" + f_version + ".ms"
		if doesFileExist file do (
		
			try   (fileIn file ; (format "loading%\n" (" ["+script_name+"]... Succesfull!")) ) 
			catch                (format "loading%\n" (" ["+script_name+"]... Failed!"    ))
		)
		--format "ver:%\n" f_Version
	),
	--> Load - Unload micra
	fn unload = (fileIn (RootDir+"_Unloader.ms")), -- Clean and Close
	fn load = (fileIn (RootDir+ "_Loader.ms")), -- Run Loader
	fn run  = (fileIn (RootDir + "Micra.ms")), -- Run Micra
	fn reload soft:true = (
	
		unload()
		load()
	),
	fn restoreToDefault = (
	
		setIniSetting UserSettings "Settings" "CurrentProfile" "8" -- Set start profile to default
		reload()
	),
	fn setProfile index = (
	
		setIniSetting UserSettings "Settings" "CurrentProfile" (index as string) -- Set start profile to default
		reload()
	),
	--> check Micra's system files
	fn initStructureFiles = (
	
		if not doesFileExist DefaultSettings do return #(DefaultSettings)
		local ms_names			= getIniSetting DefaultSettings "Version" 
		local system_ini_names	= getIniSetting DefaultSettings "SystemIni"
		local default_ini_names	= getIniSetting DefaultSettings "UserIniDefault"
		files_list				= #(RootDir+"Micra.ms")

		--> collect ms and mcr
		for i in ms_names  do files_list += #(RootDir+i+"_v"+getIniSetting DefaultSettings "Version" i+".ms") 
		--> collect ini 
		for i in system_ini_names do files_list += #(RootDir+i+".ini")
		--> collect default ini
		for i in default_ini_names do files_list += #(DefaultDir+i+".ini")
		--> return missing files
		return (for f in files_list where not doesFileExist f collect f)
	),
	--> check user files and reconstruct missing
	--force reconstruct: Micra.initUserProfile force:true
	fn initUserProfile force:false = (
		
		if not doesFileExist UserDir do (makeDir UserDir all:true)
		if not doesFileExist UserDir do (
			
			format "Unable to create User Profile:%\n." UserDir
			return false
		)
		--#("Profile_1", "Profile_2", "Profile_3", "Profile_4", "Profile_5", "Profile_6", "Profile_7", "Profile_8", "Settings", "Temp")
		local user_ini_names	= getIniSetting DefaultSettings "UserIni"
		local user_files		= for n in user_ini_names collect (UserDir+n+".ini")
		
		-- Create files #(Profile_1.ini, ..., Profile_8.ini, Settings.ini, Temp.ini)
		for i in user_files where not doesFileExist i or force do (
		
			format "Build User file%\n" i
			if findString i "Profile_1"    != undefined then (copyFile DefaultProfileIni i)
			else if findString i "Profile" != undefined then (copyFile EmptyProfileIni i)
			else if i == UserSettings then (copyFile DefaultUserSettings i)
			else if i == TempIni then (close (createFile i)) --create empty file "Temp.ini"
		)
		return true
	),
	--> Add Micra's macro and set plug-ins directory
	fn initMaxFiles force:false = (
		
		-- Install Micra's Macro 
		if not doesFileExist Macro or force do (
		
			copyFile (RootDir+"Micra_Macro.mcr") Macro
			format "% > Micra_Macro has ben Installed." version
		)
		-- Install Larry Minton's Avguard MAXScript Extensions
		if (getIniSetting MaxUserSettings "Directories" "Micra Plugins") == "" or force do (
		
			setIniSetting MaxUserSettings "Directories" "Micra Plugins" PluginsDir
			format "% > Larry Minton's Avguard MAXScript Extensions has ben Installed." version
			restart_need = true
		)
		return OK
	),
	--> User Profile Switcher
	--Always Override Temp Profile ( Profile_Temp.ini ) with Last used Profile ( Profile_1.ini,  Profile_2.ini, Profile_3.ini, ...)
	--Load saved Settings template
	fn profileSwitch = (
	
		local last_profile_index = getIniSetting UserSettings "Settings" "CurrentProfile"
		local last_profile_name = "Profile_"+ last_profile_index + ".ini"
		local LastProfileINI = UserDir + last_profile_name
		--override temp profile with user one
		if doesFileExist LastProfileINI and doesFileExist TempProfileINI do deleteFile TempProfileINI
		copyFile LastProfileINI TempProfileINI --override temp profile with last user profile
	),
	fn loadAllStructures = (
	
		-->Load Struct
		fileInVersion "Global_Memory"
		fileInVersion "Struct_Action"
		fileInVersion "Struct_Call"
		
		-->Load Functions
		fileInVersion "Deep_Isolate"
		
		-->Load DotNet Components
		fileInVersion "DotNet_Components"
		
		-->Load Dinamic Dialog
		fileInVersion "Dialog_Creator"
		fileInVersion "Dialog_Creator_Net"
		
		-->Load Applications
		fileInVersion "Holder"
		
		-->Load Modifiers and Plugins
		fileInVersion "Modifiers"
		fileInVersion "Morph_Collector"
		fileInVersion "Morph_Tagger"
		--fileInVersion "Morph_Dummy"
		
--> Reload Macroscript , bug in 3DsMax 1012
fileIn Macro 

		--> Start Micra
		unload()--> Unregister Micra's Callbacks
		run() --> Run Micra
	),
	--> Initialize Micra
	fn initialize = (
	
		increaseMemory 30 --Set Memory Allocation to 30MB
		-- Check and loading files
		local error_list = initStructureFiles() 
		if error_list.count > 0 do (
			
			local error_msg = "Some Files(" + error_list.count as string + ") is missing!\nPlease reinstal Micra or contact me.\nmerlin_el@hotmail.com"
			messagebox error_msg title:(" " + version + ":")
			format "% > Missing files(%)\n%" version error_list.count error_list
			return false
		)
		format "% > System files(%) checked succesfully!\n" version files_list.count
		if not initUserProfile() do return false
		initMaxFiles() --add macro and avguard plugins path
		profileSwitch() --replace temp profile with last used profile
		loadAllStructures()
		
/*		
--> Callbacks --TO DO		
if execute (getINISetting UserSettings "Settings" "UniversalCounter") do
(
	--UniversalCounter	
	fileInVersion "Uni_Poly_Counter"
)
if execute (getINISetting UserSettings "Settings" "ShowFileName") do
(
	--Show FileName in Screen
	unregisterRedrawViewsCallback mcCall.fileName_in_screen
	registerRedrawViewsCallback mcCall.fileName_in_screen ; completeredraw()	
)
(
	--Use Large Vertex Dots
	preferences.useLargeVertexDots = execute (getINISetting UserSettings "Settings" "UseLargeVertexDots")
)
*/		
	
		format "% > Inicialization complete.\n" version
		if restart_need do format "Please Restart Max Application to finish % intalation." version
	)
)
Micra = MICRA_STRUCTURE()


/*
clearlistener() --clean listener
gc() --free mem
*/
