----------------------------------------------------------------------------
--xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx--

                             -- Micra VI --
							 
--xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx--
--                       Created by MerlinEl 2018                         --
----------------------------------------------------------------------------

Global Micra
Global McFile
Global mcTriangleCounter = false --> used in: [Micra_Macro.mcr]

struct MICRA_STRUCTURE (

	/**
	@Usage Debug Micra and Tools
	@Legend
		0 : debug disabled
		4 : structures loading
		8 : unbound all froms from 3DsMax, used at Notepad++ execute
	*/
	debug				= 4,
	loaded				= false,
	version				= "Micra IV",
	borndate			= "5/4/2006 12:00:00 AM", --CZ time
	username			= substituteString sysInfo.username " " "_", --replace wihitespaces with "_"
	files_list			= #(),
	restart_need		= false,
	max_custom_controls = undefined,
	callbacksID			= #mcGeneralCallbacks, --micra callbacks ID
	--> Directory structure
	RootDir				= getFilenamePath (getSourceFileName()), --here is current version of Micra
	CoreDir				= RootDir + "CORE\\", --here is all sturctures(classes)
	TempDir				= RootDir + "Temp\\",
	AutorunDir			= RootDir + "Autorun\\", --all plugins goes here, also Micra's autorun file	
	RepositoryDir		= (pathConfig.removePathLeaf RootDir) + "\\", --here is all Micra's versions and other Resources
	ResourcesDir 	= RepositoryDir + "repo_sync\\", --Micra's Shared Resources, Backups, Max Icons, Ms Library, ...
	AppsDir				= RootDir + "App\\",
	ImagesPath 			= RootDir + "Img\\", --all images here
	UserDir				= RootDir + "User\\" + username + "\\",
	MicraMacro 			= RootDir + "Micra_Macro.mcr",
	MaxRootDir			= getDir #maxroot,
	MaxUserDir			= pathConfig.removePathLeaf (getDir #userMacros),
	MaxPluginsDir		= MaxUserDir + "\\MicraPlugins\\", --all plugins goes here, also Micra's autorun file	
	MaxMacro			= MaxUserDir + "\\usermacros\\Micra_Macro.mcr",
	MaxUserSettings		= MaxUserDir + "\\Plugin.UserSettings.ini", --only this wil stay INI
	ImgPath				= RootDir + "Img\\", 
	IconI				= RootDir + "Img\\mcIcons_24_480x480i.bmp",
	IconM				= RootDir + "Img\\mcIcons_24_480x480m.bmp",
	-- > Default Setting
	DefaultSettings		= RootDir + "Settings.xml", --default settings
	DefaultUserSettings	= RootDir + "User\\Default\\Settings.xml", --default settings
	DefaultProfile		= RootDir + "User\\Default\\Profile_Default.xml", --default profile 
	EmptyProfile		= RootDir + "User\\Default\\Profile_Empty.xml", --empty profile 
	ActionsXML			= RootDir + "Actions.xml",
	ActionsHelpXML		= RootDir + "Actions_Help.xml",	
	-- > Udser Settings
	UserSettings		= UserDir + "Settings.xml", --copy of DefaultSettings
	UserProfile			= "", --here is stored user settings (dialogs position and size, button actions) > path is defined at (loadUserProfile())
	--functions
	fn getSource = getSourceFileName(), --get path of this script
	--Set Memory Allocation in MB
	fn increaseMemory mb = (
	
		local hsize = mb*1000000
		if heapSize < hsize do heapSize = hsize
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
			local dialogs_names	= mcFile.readSettings DefaultProfile "Properties_1" type:"keys"
			join dialogs_names (mcFile.readSettings DefaultProfile "Properties_2" type:"keys")
			for n in dialogs_names do (
			
				if n == "mcMicraDialog" do continue --close all except Micra dialog (prevent endless loop)
				local d = execute n
				case classOf d of (
				
					dotNetObject:(
							if d.visible do (
					
								format "closing dotnet dialog:% \n" n
								--Save active for Properties_1 and Properties_2 separate
								--mcFile.saveSettings UserProfile ("Properties_1/"+n) "true" type:"active" --add-replace node with parameter > cnt = "true"
								d.close() 
							)
					)
					RolloutClass:(
							if d.isDisplayed do (
							
							format "closing rollout dialog:% \n" n
							--Save active for Properties_1 and Properties_2 separate
							--mcFile.saveSettings UserProfile ("Properties_1/"+n) "true" type:"active" --add-replace node with parameter > cnt = "true"
							destroyDialog d
						)
					)
				)
			)
			-->Unload Calbacks
				--Micra.ms > onOpenForm (line 187 )
				callbacks.removeScripts id:callbacksID 
				--Customize.ms > onCheckerChanges (line 460) --fix it cause error
				--if mcPolyCount != undefined do unregisterRedrawViewsCallback mcPolyCount.Count		
				--if mcCall != undefined do unregisterRedrawViewsCallback mcCall.fileNameInScreen 
				--if mcAction != undefined do unregisterRedrawViewsCallback mcAction.triangle_counter
			-->Clean Memory
			gc()
			completeredraw()
		)
	), 
	fn load = (fileIn (RootDir+ "_Loader.ms")), -- Run Loader
	fn run  = (
	
		fileIn (RootDir + "Micra.ms")
		--TODO open dialogs(Properties_2) which was opened last time, maybe.....
		--local dialogs_names = mcFile.readSettings UserProfile "Properties_2" type:"keys"
		--for each dialog where active="true" open it too
	), -- Run Micra
	fn reload soft:true = (
	
		unload()
		load()
	),
	fn restoreToDefault = (
	
		mcFile.saveSettings Micra.UserSettings "Settings/CurrentProfile" "8" -- Set start profile to default
		reload()
	),
	fn setProfile index = (
	
		mcFile.saveSettings Micra.UserSettings "Settings/CurrentProfile" (index as string) -- Set start profile to index(1-8)
		reload()
	),
	--Get last used Profile ( Profile_1.xml, ..., Profile_8.xml)
	fn loadUserProfile = (
	
		local last_profile_index = mcFile.readSettings Micra.UserSettings "Settings/CurrentProfile"
		local last_profile_name = "Profile_"+ last_profile_index + ".xml"
		format "% > loadUserProfile > profile( % ) user( % )\n" version last_profile_index username
		UserProfile = UserDir + last_profile_name
	),
	--> check user files and reconstruct missing
	--force reconstruct: Micra.initUserProfile force:true
	fn initUserProfile force:false = (
		
		if not doesFileExist DefaultProfile or not doesFileExist EmptyProfile or not doesFileExist DefaultSettings or not doesFileExist DefaultUserSettings do (
		
			format "Unable to create User Profile. Missing default Templates.\n"
			return false
		)
		if not doesFileExist UserDir do (makeDir UserDir all:true)
		if not doesFileExist UserDir do (format "Unable to create User Profile:%\n." UserDir; return false)
		local profile_names	= mcFile.readSettings DefaultSettings "UserFiles" type:"keys"
		local user_files		= for n in profile_names collect (UserDir+n+".xml")
		-- Create files #(Profile_1.xml, ..., Profile_8.xml, Settings.ini)
		for i in user_files where not doesFileExist i or force do (
		
			format "Build User file%\n" i
			if findString i "Profile_1"    != undefined then (copyFile DefaultProfile i) --copy default profile to user dir (1)
			else if findString i "Profile" != undefined then (copyFile EmptyProfile i) --copy empty profile to user dir (2-8)
			else if i == UserSettings then (copyFile DefaultUserSettings i) --copy micra settings.xml to user dir
		)
		loadUserProfile()
		return true
	),
	--> Copy Micra's macro to 3DsMax dir
	fn installMacro = (
		
		local need_install	= not doesFileExist MaxMacro
		local need_update 	= doesFileExist MaxMacro and mcFile.isFileOlder MaxMacro MicraMacro 
		local result			= "Unchanged"
		if need_install then ( 		--copy macro to max user folder
		
			result = copyFile MicraMacro MaxMacro
		
		) else if need_update do (	--override macro in max user folder
		
			deleteFile MaxMacro
			if not doesFileExist MaxMacro then (
			
				result = copyFile MicraMacro MaxMacro
				
			) else (
		
				format "Unable to override old Macro version.\n\tsource:%\t\n\ttarget:%\n" MicraMacro MaxMacro
			)
		)
		format "% > installMacro > with result:%\n" version result 
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
		
			--Use local dir for autorun
			setIniSetting MaxUserSettings "Directories" "Micra Autorun" AutorunDir --append Micra's Autorun dir to 3DsMax
			
			format "% > Installation is finished\n." version
			messageBox "Installation was succesfull.\nPlease restart 3DsMax." title:version
			restart_need = true
		)
		--Uninstall Micra Autorun
		if not state and isInstaled() do (
		
			delIniSetting MaxUserSettings "Directories" "Micra Autorun" --remove Micra's plugins dir to 3DsMax
			mcFile.saveSettings Micra.UserSettings "Settings/Autorun" "false" --set autorun false
			
			--delete MicraPlugins directory with files
			--TODO ***
			
			format "% > Uninstall is finished\n." version
			messageBox "Uninstallation was succesfull.\nPlease restart 3DsMax." title:version
			unload()
		)
	),
	/**
	*@Example
		Micra.loadStructures force:true
	*/
	fn loadStructures force:false = (
	
		-->Load MaxCustomControls.dll (dont know if is need)
		max_custom_controls = dotNet.loadAssembly "MaxCustomControls.dll"
		local cnt = 0
		-->Load Base Structures (init mcFile structure)
		for i in #("mcStructMan", "mcDate", "mcString", "mcObjects", "mcXML", "mcFile") do (
		
			if debug == 4 do format "% > loadStructures > [ % ]\n" version i
			local struct_instance = execute i
			if struct_instance == undefined or force do fileIn (CoreDir+i+".ms")
			cnt+=1
		)
		-->Load Rest Core Structures using mcFile struct
		local struct_names = mcFile.readSettings DefaultSettings "Structures" type:"keys"
		for i in struct_names do (
		
			if debug == 4 do format "% > loadStructures > [ % ]\n" version i
			local struct_instance = execute i
			if struct_instance == undefined or force do fileIn (CoreDir+i+".ms") 
			cnt+=1
		)
		format "% > loadStructures > total [ % ]\n" version cnt
		
		--> Load Actions
		mcFile.fileInVersion "Struct_Action"
		mcFile.fileInVersion "Actions_Editor"
		
		-->Load DotNet Components
		mcFile.fileInVersion "DotNet_Components"
		
		-->Load Dinamic Dialog
		mcFile.fileInVersion "Dialog_Creator_Net"
		
		-->Load Applications
		--mcFile.fileInVersion "Holder" --render selection as thumbnail for latest reselect (action > mcHoldSelection())
		mcFile.fileInVersion "Deep_Isolate" --multi isolate
		
		-->Load Modifiers and Plugins
		mcFile.fileInVersion "Modifiers"
		--mcFile.fileInVersion "Morph_Collector"
		--mcFile.fileInVersion "Morph_Tagger"
		--mcFile.fileInVersion "Morph_Dummy"
	),
	--> Initialize Micra
	fn initialize = (
	
		increaseMemory 30 -->Set Memory Allocation to 30MB
		if loaded do unload()--> Unregister Micra's Callbacks and close all dialogs
		loadStructures force:true --init system structures (always force or update may crash on unknown functions)
		if not initUserProfile() do return false
		installMacro() --add micra macro to 3DsMax 
		fileIn MaxMacro --> Reload Macroscript , bug in 3DsMax 1012
		run() --> Run Micra
		/*
		clearlistener() --clean listener
		gc() --free mem
		*/
		format "% > Inicialization complete.\n" version
		if restart_need do format "Please Restart Max Application to finish % intalation." version	
	)
)
Micra = MICRA_STRUCTURE()


/*		
--> Callbacks --TO DO		
if execute (getINISetting UserSettings "Settings" "UniversalCounter") do
(
	--UniversalCounter	
	mcFile.fileInVersion "Uni_Poly_Counter"
)
if execute (getINISetting UserSettings "Settings" "ShowFileName") do
(
	--Show FileName in Screen
	unregisterRedrawViewsCallback mcCall.fileNameInScreen
	registerRedrawViewsCallback mcCall.fileNameInScreen ; completeredraw()	
)
(
	--Use Large Vertex Dots
	preferences.useLargeVertexDots = execute (getINISetting UserSettings "Settings" "UseLargeVertexDots")
)

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
		for i in default_ini_names do files_list += #(UserDir + "Default\\" +i+".ini")
		--> return missing files
		return (for f in files_list where not doesFileExist f collect f)
	),
	
			-- Check and loading files
		local error_list = initStructureFiles() 
		if error_list.count > 0 do (
			
			local error_msg = "Some Files(" + error_list.count as string + ") is missing!\nPlease reinstal Micra or contact me.\nmerlin_el@hotmail.com"
			messagebox error_msg title:(" " + version + ":")
			format "% > Missing files(%)\n List:%" version error_list.count error_list
			return false
		)
		format "% > System files(%) checked succesfully!\n" version files_list.count
*/		
	
