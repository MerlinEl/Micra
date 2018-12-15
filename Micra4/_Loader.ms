--------------
--------------
--	        --
--	Loader  --
--	        --
--------------
--------------

-->Global structures and functions
Global mcCall
Global mcPath
Global mcSystem
Global getScriptVersion
Global mcFileInVersion
Global mcFileCheckSum
Global mcProfileSwitch

-->Global variables
Global mcDialogSnappingEnabled

--Set Memory Allocation to 30MB
(
	local hsize = 30*1000000
	if heapSize < hsize do heapSize = hsize
)

-->Startup Functions
if mcPath == undefined do fn mcPath = getFilenamePath (getSourceFileName())
/*
(
	local pArr = filterString sysInfo.currentdir "\\"
	local p    = ""
	for i in pArr do p += i + "\\\\"  
	fn mcPath = p
)
*/

--> Global File Paths
Global mcActionIni          = mcPath() + "Actions.ini"
Global mcActionHelpIni      = mcPath() + "Actions_Help.ini"
Global mcUserINI            = mcPath() + "User\\Settings.ini"
Global mcDefaultINI         = mcPath() + "Settings.ini"
Global mcTempIni            = mcPath() + "User\\Temp.ini"
Global mcIconI              = mcPath() + "Img\\mcIcons_24_480x480i.bmp"
Global mcIconM              = mcPath() + "Img\\mcIcons_24_480x480m.bmp"
Global mcTempProfileIni     = mcPath() + "Profile_Temp.ini"
Global mcDefaultProfileIni  = mcPath() + "Profile_Default.ini"
--OLD> Global mcMacro = GetDir #ui + "MacroScripts\\Micra_Macro.mcr"
Global mcMacro = getDir #userMacros + "\\Micra_Macro.mcr"	


--> Global Dirs Paths
Global mcImgPath = mcPath() + "Img\\"


-->File exist check!!!
fn mcFileCheckSum =
(
	local error_msg = "\t\t\tSome files is missing!\nPlease reinstal Micra III or contact me at\n http://mithrillgate.wgz.cz/diskuze-2"
	if not doesFileExist mcDefaultINI do (messagebox error_msg title:(" Micra III: "+mcDefaultINI); return false)
	local ms_names         = getIniSetting mcDefaultINI "Version" 
	local system_ini_names = getIniSetting mcDefaultINI "SystemIni"
	local user_ini_names   = getIniSetting mcDefaultINI "UserIni"
	local system_files     = #(mcPath()+"Micra.ms")
	local user_files       = #()
	--> collect ms and mcr
	for i in ms_names  do system_files += #(mcPath()+i+"_v"+getIniSetting mcDefaultINI "Version" i+".ms") 
	--> collect ini 
	for i in system_ini_names do system_files += #(mcPath()+i+".ini")
	for i in user_ini_names   do user_files   += #(mcPath()+"User\\"+i+".ini")
	--> check system files
	for i in system_files where not doesFileExist i do (messagebox error_msg title:( " Micra III: " +i); return false)
	-->check user files and reconstruct missing
	if not doesFileExist (mcPath()+"User\\") do makeDir (mcPath()+"User")
	for i in user_files where not doesFileExist i do
	(
		format "Building file structure... %\n" i
		if findString i "Profile_8"    != undefined then (copyFile (mcPath() + "Profile_Default.ini" ) i)
		else if findString i "Profile" != undefined then (copyFile (mcPath() + "Profile_Empty.ini"   ) i)
		else if i == mcUserINI then (copyFile (mcPath() + "Settings_Default.ini") i)
		else if i == mcTempIni     then (close (createFile i))
	)
	format "Micra System files is checked... Succesful!\n"
	if not doesFileExist mcMacro do try (copyFile (mcPath()+"Micra_Macro.mcr") mcMacro) catch ( print "micra macro not found"; return false)
	return true
)

if mcFileCheckSum() do
(
	mcDialogSnappingEnabled = execute (getINISetting mcUserINI "Settings" "DialogSnap") ---remove this
	
	--> User Profile Switcher
	--Always Override Temp Profile ( Profile_Temp.ini ) with Last used Profile ( Profile_1.ini,  Profile_2.ini, Profile_3.ini, ...)
	--Load saved Settings template
	fn mcProfileSwitch =
	(
		local last_profile_index = getIniSetting mcUserINI "Settings" "CurrentProfile"
		format "last profile:%\n" last_profile_index
		local last_profile_name = "Profile_"+ last_profile_index + ".ini"
		local active_file = mcPath() +"User\\"+ last_profile_name
		--override temp profile with user one
		if doesFileExist active_file and doesFileExist mcTempProfileIni do deleteFile mcTempProfileIni
		copyFile active_file mcTempProfileIni
	)
	mcProfileSwitch()
	
	fn getScriptVersion script_name = (
		
		if not doesFileExist mcDefaultINI  do ((format "Not found! [Settings.ini]\n" ); return "")
		return (getIniSetting mcDefaultINI "Version" script_name)
	)
	
	-->  OLD File in Version
	fn mcFileInVersion script_name =
	(	 
		local m_path = mcPath()
		if m_path  == undefined do ((format "Undefined Path! [Micra] \n"); return "")
		local f_version = getScriptVersion script_name
		if f_version == "" do(format "File...%\n" ("["+script_name+"], is not registred in [Settings.ini]"); return false)
		local file      = m_path+script_name+"_v"+f_version+".ms"
		if doesFileExist file do 
		(
			try   (fileIn file ; (format "loading%\n" (" ["+script_name+"]... Succesfull!")) ) 
			catch                (format "loading%\n" (" ["+script_name+"]... Failed!"    ))
		)
		--format "ver:%\n" f_Version
	)
	
	--Loading latest script version (only from ROOT DIR)
	/*fn mcFileInVersion script_name =(	 
		
		local m_path    = mcPath()
		if m_path       == undefined do ((format "Undefined Path! [Micra] \n"); return false)
		if not doesFileExist mcDefaultINI  do ((format "Not found! [Settings.ini]\n" ); return false)
		if (getIniSetting mcDefaultINI "Version" script_name == "") do (format "File...[%] %\n" script_name "is not registred in [Settings.ini]")
		--get all [ms] files from root dir
		local ms_files = getFiles (m_path + "*.ms")
		--filter only files with [fname]
		local filtered_files = for f in ms_files where (matchPattern f pattern:("*"+script_name+"*")) collect f
		--get file with higer version
		local higest_version = 0.0
		local file = ""
		for f in filtered_files do (
			
			local fname = (getFilenameFile f) --ex: Icon_Maker_v0.21
			local vpos = findString fname "_v"
			if (vpos == undefined) do ( -- file is not versioned
				file = f
				exit
			)
			local version = (substring fname (vpos+2) -1) as float
			--format "file:% version:%\n" fname vstr
			if (higest_version < version) do (

				higest_version = version
				file = f
			)
		)
		--format "mcFileInVersion latest:%\n" file
		if doesFileExist file do (
			try   (fileIn file ; (format "loading%\n" (" ["+script_name+"]... Succesfull!")) ) 
			catch                (format "loading%\n" (" ["+script_name+"]... Failed!"    ))
		)
	)*/
	
	-->Load Struct
	mcFileInVersion "Global_Memory"
	mcFileInVersion "Struct_Action"
	mcFileInVersion "Struct_Call"
	
	-->Load Functions
	mcFileInVersion "Deep_Isolate"
	
	-->Load DotNet Components
	mcFileInVersion "DotNet_Components"
	
	-->Load Dinamic Dialog
	mcFileInVersion "Dialog_Creator"
	mcFileInVersion "Dialog_Creator_Net"
	
	-->Load Applications
	mcFileInVersion "Holder"
	
	-->Load Modifiers and Plugins
	mcFileInVersion "Modifiers"
	mcFileInVersion "Morph_Collector"
	mcFileInVersion "Morph_Tagger"
	--mcFileInVersion "Morph_Dummy"
	-->Service Process
	
	
	--> Clean 
	fileIn (mcPath()+"_Unloader.ms") 
	
	--> Run Micra
	fileIn (mcPath()+ "Micra.ms")
	
	
	--> Callbacks		
	if execute (getINISetting mcUserINI "Settings" "UniversalCounter") do
	(
		--UniversalCounter	
		mcfileInVersion "Uni_Poly_Counter"
	)
	if execute (getINISetting mcUserINI "Settings" "ShowFileName") do
	(
		--Show FileName in Screen
		unregisterRedrawViewsCallback mcCall.fileName_in_screen
		registerRedrawViewsCallback mcCall.fileName_in_screen ; completeredraw()	
	)
	(
		--Use Large Vertex Dots
		preferences.useLargeVertexDots = execute (getINISetting mcUserINI "Settings" "UseLargeVertexDots")
	)
	
	-->Install Larry Minton's Avguard MAXScript Extensions

	/* old way (installl to program files)
	local plugins_dir = GetDir #maxroot + "plugins\\"
	if not doesFileExist (plugins_dir + "avg_dlx90.dlx") do
	(
		local avg_extension = mcPath() + "App\\avg_dlx90.dlx"
		copyFile avg_extension (plugins_dir + "avg_dlx90.dlx")
		messagebox "Larry Minton's Avguard MAXScript Extensions has ben Installed.\nPlease Restart Max Application." title:"Micra"
	)*/
	
	--instal plugin in to user profile
	local plugins_dir = pathConfig.removePathLeaf (GetDir #userScripts) + "\\MicraPlugins\\"
	if not doesFileExist (plugins_dir + "avg_dlx90.dlx") do
	(
		if not doesFileExist (plugins_dir) do makeDir plugins_dir all:true --make user [plugins] dir if not exists
		local avg_extension = mcPath() + "App\\avg_dlx90.dlx"
		copyFile avg_extension (plugins_dir + "avg_dlx90.dlx") --copy avg.dll
		--register user [plugins] dir
		local baseDir = pathConfig.removePathLeaf (getDir #temp)
		local iniFile = baseDir + "\\Plugin.UserSettings.ini"
		setIniSetting iniFile "Directories" "Micra Plugins" plugins_dir
		messagebox "Larry Minton's Avguard MAXScript Extensions has ben Installed.\nPlease Restart Max Application." title:"Micra"
	)
	
	--> Reload Macroscript , bug in 3DsMax 1012
	fileIn mcMacro
	
	print "Loader.ms is Done!"
)


--New Micra structure
Global Micra
struct MICRA_STRUCTURE (

	TempProfileIni     = mcPath() + "Profile_Temp.ini",
	DefaultProfileIni  = mcPath() + "Profile_Default.ini",
	UserINI            = mcPath() + "User\\Settings.ini",
	fn reload = (
	
		fileIn (mcPath()+"_Unloader.ms") -- Clean 
		fileIn (mcPath()+ "_Loader.ms")-- Run Loader
	),
	fn restoreToDefault = (
	
		fileIn (mcPath()+"_Unloader.ms") -- Clean 
		setIniSetting UserINI "Settings" "CurrentProfile" "8" -- Set start profile to default
		fileIn (mcPath()+ "_Loader.ms")-- Run Loader
	)
)
Micra = MICRA_STRUCTURE()