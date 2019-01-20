----------------------------------------------------------------------------
--xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx--

                             -- Micra VI --
							 
--xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx--
--                       Created by MerlinEl 2018                         --
----------------------------------------------------------------------------

Global Micra
Global mcTriangleCounter = false --TODO > find another way used: [Micra_Macro.mcr]

struct MICRA_STRUCTURE (

	/**
	@Usage Debug Micra and Tools
	@Legend
		0 : debug disabled
		8 : unbound all froms from 3DsMax, used at Notepad++ execute
	*/
	debug				= 0,
	loaded				= false,
	version				= "Micra IV",
	username			= substituteString sysInfo.username " " "_", --replace wihitespaces with "_"
	files_list			= #(),
	restart_need		= false,
	RootDir				= getFilenamePath (getSourceFileName()), --here is current version of Micra
	CoreDir				= RootDir+"\\CORE\\", --here is all sturctures(classes)
	AutorunDir			= RootDir + "\\Autorun\\", --all plugins goes here, also Micra's autorun file	
	RepositoryDir		= (pathConfig.removePathLeaf RootDir) + "\\", --here is all Micra's versions and other Resources
	ResourcesDir 		= RepositoryDir + "repo_sync\\", --Micra's Shared Resources, Backups, Max Icons, Ms Library, ...
	AppsDir				= RootDir + "App\\",
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
	MaxRootDir			= getDir #maxroot,
	MaxUserDir			= pathConfig.removePathLeaf (getDir #userMacros),
	MaxPluginsDir		= MaxUserDir + "\\MicraPlugins\\", --all plugins goes here, also Micra's autorun file	
	Macro				= MaxUserDir + "\\usermacros\\Micra_Macro.mcr",
	MaxUserSettings		= MaxUserDir + "\\Plugin.UserSettings.ini",
	ImgPath				= RootDir + "Img\\", 
	IconI				= RootDir + "Img\\mcIcons_24_480x480i.bmp",
	IconM				= RootDir + "Img\\mcIcons_24_480x480m.bmp",
	max_custom_controls = undefined,
	--Set Memory Allocation in MB
	fn increaseMemory mb = (
	
		local hsize = mb*1000000
		if heapSize < hsize do heapSize = hsize
	),
	/**
	*@Usage
		import a sturcture(class) from CoreDir(file) as Global
	*@Example 
		Micra.import "mcMsxInterface" --force:true
	*/
	fn import struct_name force:false = (
		
		--check if structure is already loaded
		if execute struct_name != undefined and not force do return OK
		--find structure file and load it as global variable
		local file = CoreDir + struct_name + ".ms"
		if doesFileExist file then (
		
			try (
				fileIn file
				format "% > import > structure [  %  ]  was success!\n" version struct_name
			
			) catch (
			
				format "% > import > structure [  %  ]  was failed!\n\tError:%\n" version struct_name (getCurrentException())
			)
		) else (
		
			format "% > import > structure [  %  ]  was failed!\n\tUnable locate file [ % ]\n" version struct_name file
		)
 	),
	fn importAll = (/*not need yet*/),
		/*
	*	@example
	*	struct test1 (a, b)
	*	Global mcTest = Micra.instanceStructure test1
	*/
	fn instanceStructure struct_object instance_name = (

		local structure_instance
		try (
			structure_instance = struct_object()
			format"% > instance structure > [  %  ] was success!\n" version instance_name
		) catch (

			format"% > instance structure > [  %  ] was failed!\n\tError:%\n" version instance_name (getCurrentException())
		)
		structure_instance
	),
	-->  OLD File in Version
	--return version "1.02" or empty string ""
	fn getScriptVersion script_name = (
		
		getIniSetting DefaultSettings "Version" script_name
	),
	--get script[in root dir] with his version > "E:\Aprog\Orien\Micra\Micra4\Struct_Action_v0.03.ms"
	fn getScriptPath script_name = (
		
		local script_version = getScriptVersion script_name
		rootDir + script_name + "_v" + script_version + ".ms"
	),
	/**
	*@Usage 
		run a RootDir(file) as application(tool)
	*@Example 
		fileInVersion "Deep_Isolate"
	*/
	fn fileInVersion script_name = (	
	
		if classOf script_name != String do (
			
			format "% > fileInVersion > ScriptName[ % ], is not valid.\n" script_name
			return false
		)
		local f_version = getScriptVersion script_name
		if f_version == "" do(
		
			format "% > fileInVersion > File[ % ], is not registred in [  %  ]\n" script_name DefaultSettings
			return false
		)
		local file = RootDir + script_name + "_v" + f_version + ".ms"
		if doesFileExist file then (
		
			try (
				fileIn file
				format "% > fileInVersion > Load tool [  %  ]  was success!\n" version script_name
			
			) catch (
			
				format "% > fileInVersion > Load tool [  %  ]  was failed!\n\tError:%\n" version script_name (getCurrentException())
			)
		) else (
		
			format "% > fileInVersion > Load tool [  %  ]  was failed!\n\tUnable locate file [ % ]\n" version script_name file
		)
	),
	--> Clean and Close Micra
	fn unload self:true = (
	
		--> Close Micra
		if mcMicraDialog != undefined and self then ( --after Micra closed skip tjhis step (prevent endless loop)
		
			format "closing micra main dialog:%\n" mcMicraDialog.name
			mcMicraDialog.close()
		--> Close Other	
		) else (
		
			--> Close Micra's Dialogs
			local dialogs_names	= join (getINISetting TempProfileIni "Properties_1") (getIniSetting TempProfileIni "Properties_2")
			for n in dialogs_names do (
			
				if n == "mcMicraDialog" do continue --close all except Micra dialog (prevent endless loop)
				local d = execute n
				case classOf d of (
				
					dotNetObject:(
							if d.visible do (
					
								format "closing dotnet dialog:% \n" n
								d.close() 
							)
					)
					RolloutClass:(
							if d.isDisplayed do (
							
							format "closing rollout dialog:% \n" n
							destroyDialog d
						)
					)
				)
			)
			
			-->Unload Calbacks
			callbacks.removeScripts id:#mcGeneralCall
	
--TODO check it if need
--if mcPolyCount != undefined do unregisterRedrawViewsCallback mcPolyCount.Count; mcPolyCount = undefined			
--unregisterRedrawViewsCallback mcCall.fileName_in_screen 
--unregisterRedrawViewsCallback mcAction.triangle_counter

-->Unload Variables
mc_Dialog_DragSource = undefined
mc_Dialog_DropTarget = undefined
		
			gc()
			completeredraw()
		)
	), 
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
		local struct_names		= getIniSetting DefaultSettings "Structures" 
		local system_ini_names	= getIniSetting DefaultSettings "SystemIni"
		local default_ini_names	= getIniSetting DefaultSettings "UserIniDefault"
		files_list				= #(RootDir+"Micra.ms")

		--> collect ms and mcr
		for i in ms_names  do files_list += #(RootDir+i+"_v"+getIniSetting DefaultSettings "Version" i+".ms") 
		--> collect struct files
		for i in struct_names do files_list += #(CoreDir+i+".ms") 
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
	--> Add Micra's macro to 3DsMax set plug-ins directory
	fn installMacro force:false = (
		
		if not doesFileExist Macro or force do (
		
			local success = copyFile (RootDir+"Micra_Macro.mcr") Macro --override works only with max closed, or try something else
			format "% > Micra_Macro has ben Installed. %\n." version success
		)
	),
	fn isInstaled = (
	
		getIniSetting MaxUserSettings "Directories" "Micra Autorun" != ""
	),
	fn createMicraRunScript = (
	
		local loader_fpath = MaxPluginsDir+"Micra_Autorun.ms.ms"
		local f = createFile loader_fpath
		local data = "--------------------------------------------------------------------------------\n"
			data += "/* Micra Start by Orien 2019 */\n"
			data += "--------------------------------------------------------------------------------\n"
			data += "(\n"
			data += "\tlocal loader = \""+Micra.RootDir+"_Loader.ms\"\n"
			data += "\tif doesFileExist loader then\n"
			data += "\t(\n"
			data += "\t\tfileIn loader\n"
			data += "\t)\n"
			data += "\telse (messagebox (\"Micra4 loader is not found.\") title:\" Micra!\")\n"
			data += ")\n"
		format data to:f
		close f
		true
	),
	fn installMaxPlugins = (
	
		--Avguard Extensions
		--another way to check (some different function laike LocalTime)	
		if avguardHelp == undefined do (

			copyFile (AppsDir + "Avguard_Extensions\\avg_dlx90.dlx") (MaxPluginsDir + "avg_dlx90.dlx")
		)
		--MXSEditor Global Utility (depends on max version and operating system 32)
		local bit_version = if is64bitApplication() then "64" else "86"
		local max_root_arr = (filterString MaxRootDir " \\")
		local max_version = max_root_arr[max_root_arr.count] --2014, 2015, 2016
		local src_msx_file = AppsDir + "MSX_Editor\\x"+bit_version+"\\Release - Max"+max_version+"\\MXSEditor_x64.gup"
		format "% > installMaxPlugins > 3DsaMax x%bit year:% file:%\n" version bit_version max_version src_msx_file
		copyFile src_msx_file (MaxPluginsDir + "MXSEditor_x64.gup")
	),
	/**
	*@Usage: Add Micra's Plugins path in to 3DsMax (Autorun, Avguard, MSXEditor)
		Micra_Autorun.ms	()
		avg_dlx90.dlx		(Larry Minton's Avguard MAXScript Extensions)
		MXSEditor_x64.gup	()
	*/
	fn setAutorunTo state = (
	
		--Install Micra Autorun
		if state and not (isInstaled()) do (
		
			/*
			--create MicraPlugins directory if not exists
			if not doesFileExist MaxPluginsDir do (makeDir MaxPluginsDir all:true)
			if not doesFileExist MaxPluginsDir do (
				
				format "Unable to create User Directory:%\n." MaxPluginsDir
				return false
			)
			createMicraRunScript() --cterate micra autorun file
			installMaxPlugins() --add some plugins in MaxPluginsDir
			setIniSetting MaxUserSettings "Directories" "Micra Plugins" MaxPluginsDir --append Micra's plugins dir to 3DsMax
			*/
			--Use local dir for autorun
			setIniSetting MaxUserSettings "Directories" "Micra Autorun" AutorunDir --append Micra's Autorun dir to 3DsMax
			setIniSetting UserSettings "Settings" "Autorun" "true" --set autorun true
			format "% > Installation is finished\n." version
			messageBox "Installation was succesfull.\nPlease restart 3DsMax." title:version
			restart_need = true
		)
		--Uninstall Micra Autorun
		if not state and isInstaled() do (
		
			delIniSetting MaxUserSettings "Directories" "Micra Autorun" --remove Micra's plugins dir to 3DsMax
			setIniSetting UserSettings "Settings" "Autorun" "false" --set autorun false
			
			--delete MicraPlugins directory with files
			--TODO ***
			
			format "% > Uninstall is finished\n." version
			messageBox "Uninstallation was succesfull.\nPlease restart 3DsMax." title:version
			unload()
		)
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
	
		if loaded do unload()--> Unregister Micra's Callbacks
		
		-->Load MaxCustomControls.dll (dont know if is need)
		max_custom_controls = dotNet.loadAssembly "MaxCustomControls.dll"
		
		-->Load Core Structures
		local struct_names = getIniSetting DefaultSettings "Structures" 
		for i in struct_names do fileIn (CoreDir+i+".ms") 
		
		--> Load Actions
		fileInVersion "Struct_Action"
		fileInVersion "Actions_Editor"
		
		-->Load DotNet Components
		fileInVersion "DotNet_Components"
		
		-->Load Dinamic Dialog
		fileInVersion "Dialog_Creator_Net"
		
		-->Load Applications
		fileInVersion "Holder"
		fileInVersion "Deep_Isolate"
		
		-->Load Modifiers and Plugins
		fileInVersion "Modifiers"
		fileInVersion "Morph_Collector"
		fileInVersion "Morph_Tagger"
		--fileInVersion "Morph_Dummy"
		
--> Reload Macroscript , bug in 3DsMax 1012
fileIn Macro 

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
			format "% > Missing files(%)\n List:%" version error_list.count error_list
			return false
		)
		format "% > System files(%) checked succesfully!\n" version files_list.count
		if not initUserProfile() do return false
		installMacro() --add micra macro to 3DsMax 
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
