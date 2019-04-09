--------------------------------------------------------------------------------
/* mcZip by Orien 2019 */
--------------------------------------------------------------------------------
/*
*@Used Structures
	mcStructMan
*
*@Used Objects
	undefined
*
*@Usage
	objShell.Run >
		WIN_MODE :
		 0 Hide the window (and activate another window.)
		 1 Activate and display the window. (restore size and position) Specify this flag when displaying a window for the first time.
		 2 Activate & minimize.
		 3 Activate & maximize.
		 4 Restore. The active window remains active.
		 5 Activate & Restore.
		 6 Minimize & activate the next top-level window in the Z order.
		 7 Minimize. The active window remains active.
		 8 Display the window in its current state. The active window remains active.
		 9 Restore & Activate. Specify this flag when restoring a minimized window.
		10 Sets the show-state based on the state of the program that started the application.
		ON_RETURN :
		TRUE, the Run method returns any error code returned by the application.
		not specified or FALSE, this method immediately returns to script execution 
		rather than waiting on the process termination (and returns an error code of 0)
*
*@Example	
	undefined
*
*/
struct MICRA_NEW_STRUCTURE	(
	
	--variables
	
	
	--functions
	fn getSource = getSourceFileName(), --get path of this script
	fn translateExitCode index = (
	
		case index of (
		
			0:	"No error"
			1:	"Warning (Non fatal error(s)). For example, one or more files were locked by some other application, so they were not compressed."
			2:	"Fatal error"
			7:	"Command line error" 
			8:	"Not enough memory for operation" 
			255:"User stopped the process" 
		)
	),
	/**	
	*@Usage
		CMD:
		-i (Include)
		-m (Method)
		-p (Set Password)
		-r (Recurse)
		-sfx (create SFX)
		-si (use StdIn)
		-so (use StdOut)
		-ssw (Compress shared files)
		-t (Type of archive)
		-u (Update)
		-v (Volumes)
		-w (Working Dir)
		-x (Exclude) 
	*@Example
		mcZip.zip (Micra.RootDir+"Temp\\source_files\\") (Micra.RootDir+"Temp\\zip_dir\\Micra4_1.zip") override:true
		--now zip without any folder "bin" or any file "readme.txt"
		mcZip.zip (Micra.RootDir+"Temp\\source_files\\") (Micra.RootDir+"Temp\\zip_dir\\Micra4_1.zip") override:true exclude:#("bin", "readme.txt")
	*/
	fn zip source_dir zip_path filter:"*" win_mode:0 on_return:true override:false exclude:#()= (
	
		if not (doesFileExist source_dir) do return false
		if override and doesFileExist zip_path do deleteFile zip_path
		--local objFSO = CreateOLEObject "Scripting.FileSystemObject"
		local objShell = CreateOLEObject "WScript.Shell"
		local zip_file = Micra.RootDir + "App\\7za.exe"
		if not doesFileExist zip_file do return false
		if exclude.count > 0 do (
		
			for dir_or_file in exclude do filter += " -xr!"+dir_or_file --here is important to have at start filter(*) or other mask(*.dll)
		)
		local cmd = zip_file + " a " + zip_path + " " + source_dir + filter -- -d(Delete), -u(Update) switches at end are not tested
		--format "CMD >\n%\n" cmd
		local exit_code = objShell.Run cmd win_mode on_return  
		format "mcZip > zip file:[ % ] status:%\n" zip_path (translateExitCode(exit_code))
		exit_code == 0 --true(success) false(failed)
	),
	/**
	*@Usage
		CMD:
		-ai (Include archives)
		-an (Disable parsing of archive_name)
		-ao (Overwrite mode)
		-ax (Exclude archives)
		-i (Include)
		-o (Set Output Directory)
		-p (Set Password)
		-r (Recurse)
		-so (use StdOut)
		-t (Type of archive)
		-x (Exclude)
		-y (Assume Yes on all queries) 
	*@Example
		mcZip.unzip (Micra.RootDir+"Temp\\zip_dir\\Micra4_1.zip") (Micra.RootDir+"Temp\\extract_files\\") override:true
	*/
	fn unzip zip_path output_dir win_mode:0 on_return:true override:false = (	

		if not (doesFileExist zip_path) or not (doesFileExist output_dir) do return false
		local objShell = CreateOLEObject "WScript.Shell"
		local zip_file = Micra.RootDir + "App\\7za.exe"
		if not doesFileExist zip_file do return false
		--format "extracting file:\n%\nto directory:\n%\n" zip_path output_dir
		--x(Extract with full paths) r(recursive) o(output dir) y(override all)
		local cmd = zip_file + " x " + zip_path + " -r-o" + output_dir + (if override then " -y" else "")
		--format "CMD >\n%\n" cmd
		local exit_code = objShell.Run cmd win_mode on_return 
		format "Unzip file:[ % ] status:%\n" zip_path (translateExitCode(exit_code))
		exit_code == 0 --true(success) false(failed)
	)
	/*<end>*/
)	
 --create instance
Global mcZip = mcStructMan.instanceStructure MICRA_NEW_STRUCTURE "mcZip"