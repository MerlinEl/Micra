--------------------------------------------------------------------------------
/* mcFile by Orien 2019 */
--------------------------------------------------------------------------------
/*
*@Used Structures
	Micra
	mcTime
	mcString
*
*@Used Objects

*
*@Example
*	mcFile.getDirTree (Micra.RootDir)
*	print mcFile.all_dirs
*/
struct MICRA_FILE (
	
	all_dirs = #(),
	fn getSource = getSourceFileName(), --get path of this script
	/**
	NOT USED
	@Return
		"Everyone"
		"NT AUTHORITY\SYSTEM"
	*/
	fn getFileOwner f = (
	
		local fileInfo = dotNetObject "System.IO.FileInfo" f
		local fileAccessControl = fileInfo.getAccessControl()
		local NTAccountType = dotNetClass "System.Security.Principal.NTAccount"
		local fileOwner = fileAccessControl.getOwner NTAccountType
		fileOwner.value
	),
	/**
	NOT USED
		local SearchOption = DotNetClass "System.IO.SearchOption"
		local DotNetDirectoryInfo = DotNetObject "System.IO.DirectoryInfo" targetPath
		SetDirectoryAccessControlType DotNetDirectoryInfo
		result = for tfi in (DotNetDirectoryInfo.GetFiles "*.ms" SearchOption.AllDirectories) collect tfi.FullName
	*/
	fn setDirectoryAccessControlType inputDirectoryInfo = (
	
		local tempUserName = (DotNetClass "System.Environment").UserName
		local fileSystemRights = (DotNetClass "System.Security.AccessControl.FileSystemRights").Modify
		local accessControlType = (DotNetClass "System.Security.AccessControl.AccessControlType").Allow
		local fileSystemAccessRule = DotNetObject "System.Security.AccessControl.FileSystemAccessRule" tempUserName fileSystemRights accessControlType 
		local directorySecurity = inputDirectoryInfo .GetAccessControl()
		directorySecurity.AddAccessRule fileSystemAccessRule 
		inputDirectoryInfo .SetAccessControl directorySecurity 
	),
	fn isFilePath _path =  (
		
		_path = pathConfig.normalizePath _path
		getFilenameType _path != ""
	),
	fn isDirectory _path = (
		
		_path = pathConfig.normalizePath _path
		findString  _path  ":\\" != undefined and getFilenameType _path == ""
	),
	fn getLastDir _path = (
		
		_path = pathConfig.normalizePath _path
		pathConfig.stripPathToLeaf _path
	),
	/*
	*@Example
		mcFile.getParentDir "D:\\3DsMax\Micra\\Notepad++\\tools\\MXSPyCOM\\install.ms" 2
			"D:\3DsMax\Micra\Notepad++\tools\"	
		mcFile.getParentDir "D:\\3DsMax\Micra\\Notepad++\\tools\\MXSPyCOM\\install.ms" 8
			"D:\"
		mcFile.getParentDir "D:\\3DsMax\Micra\\Notepad++\\tools\\MXSPyCOM\\install.ms" 1000 dir_name:"Notepad++"
			"D:\ReneBaca\3DsMax\Micra\Notepad++\"
		mcFile.getParentDir "D:\\3DsMax\Micra\\Notepad++\\tools\\MXSPyCOM\\install.ms" 0 dir_name:"ROOT"
			"D:\"
	*/
	fn getParentDir _path steps_index dir_name:undefined = (

		if not (isDirectory _path) and not (isFilePath _path) do return undefined
		local parent_path = pathConfig.normalizePath _path
		if dir_name == "ROOT" do return substring _path 1 3
		while (findString parent_path "\\") != undefined and steps_index > 0  and  (getLastDir parent_path) != dir_name do (
			
			--format "next dir:%\n" (getLastDir parent_path)
			parent_path  = pathConfig.removePathLeaf parent_path
			steps_index -= 1
		)
		--if we get bottom return drive letter
		if (findString parent_path ":") == undefined then parent_path = substring _path 1 3
		--append slash at the end
		if parent_path[parent_path.count] != "\\" then parent_path + "\\" else parent_path
	),
	fn getDirTree dir =
	(
		all_dirs += curr_dirs = getDirectories (dir+"*.*")
		for i in curr_dirs do getDirTree i
	),
	fn filterPath path = 
	(
		local arr   = filterString path "\\/"
		local isDir = path[path.count-3] != "." -- example C:\temp.txt
		local newPath = ""
		for i=1 to arr.count do newPath += arr[i] + ( if isDir or i != arr.count then "/" else "")
		return newPath
	),
	fn copyDirTree indir outdir hidden:true exceptempty:false owerwritereadonly:true existingonly:false silent:true =
	(
		--indir = filterPath2 indir
		--outdir = filterPath2 outdir
		
		trimRight indir
		trimRight outdir
		indir  += "\\"
		outdir += "\\"
		
		local cmd = "XCOPY /I " +
			(if exceptempty       then "/S " else "/E ") + 
			(if hidden            then "/H " else ""  ) + 
			(if owerwritereadonly then "/R " else ""  ) + 
			(if existingonly      then "/U " else ""  ) + 
			(if silent            then "/Y " else " "  ) + 
			--"\""+indir+"\"" + " " + "\""+outdir+"\""
			indir + " " + outdir

		format "cmd:%\n" cmd
		DOSCommand cmd
	),
	fn treeCopy indir outdir move:false = --recursive call
	(
		indir = filterPath indir
		outdir = filterPath outdir

		local files = getFiles (indir+"*.*")
		local dirs = getDirectories (indir+"*.*")
		
		for f in files do ( copyFile f (outdir+filenameFromPath f) )
		for d in dirs do 
		(              
			local filter_path = filterString d "/\\" --changed 6.1.2019
			local new_dir = outdir+filter_path[filter_path.count]
			makedir new_dir
			treeCopy d new_dir
		)
	),
	fn importObjects = (max file import),
	fn exportObjects = (max file export),
	fn exportSelectedObjects = (if selection.count > 0 do max file export selected),
	fn resetMax = (if checkForSave() != false do resetMaxFile #noPrompt),
	fn reloadLastFile = (
	
		try (
			
			actionMan.executeAction 0 "203" --#noPrompt
			
		) catch (
		
			MessageBox "OpenFile last file is Failed" title:Micra.version
		)
	),
	fn saveSelectedObjects = (if selection.count > 0 do max file save selected),
	fn archiveScene = (max file archive), --Pack Scene to Zip
	fn open fpath = (
	
		fpath = filterPath fpath 
		if not doesFileExist fpath do return false
		if isMaxFile fpath do try (loadMaxFile fpath useFileUnits:true quiet:false) catch()
	),
	fn createNewFile file_path file_text:"" = (
	
		local out_file = createFile file_path --create file at given file path
		if file_text.count > 0 do format "%" file_text to:out_file --write data in to file
		close out_file --important to close else file can't be deleted
		OK
	),
	--mcFile.getIniDataFromArray Micra.TempProfileIni "Properties_2" "mcColorPickerDialog" 2
	fn getIniDataFromArray iniFile head key arrNum =
	(
		--input type validation
		if classOf iniFile != string  do return undefined
		if classOf head    != string  do return undefined
		if classOf key     != string  do return undefined
		if classOf arrNum  != integer do return undefined
		
		if not doesFileExist iniFile do return undefined
		if head == "" 
		then 
		(
			return (getIniSetting iniFile)
		)
		if key == "" 
		then
		(
			return (getIniSetting iniFile head)
		)
		if arrNum == 0 
		then
		(
			return (getIniSetting iniFile head key)
		)
		else 
		(
			local data  = execute (getIniSetting iniFile head key)
			--format "ini:%\thead:%\tkey:%\tarrnum:%\n" iniFile head key arrNum
			if classOf data != array do return undefined
			return data[arrNum]
		)
	),
	--mcFile.setIniDataToArray Micra.TempProfileIni "Properties_2" "mcColorPickerDialog" 2 newValue
	fn setIniDataToArray iniFile head key arrNum newValue =
	(
		if classOf iniFile  != string  do return undefined
		if classOf head     != string  do return undefined
		if classOf key      != string  do return undefined
		if classOf arrNum   != integer do return undefined
		--if classOf newValue != string do return undefined
		
		if not doesFileExist iniFile do return undefined
		
		if arrNum != 0 
		then
		(
			local data = execute (getIniSetting iniFile head key)
			if classOf data != array do return undefined
			data[arrNum] =  newValue
			setIniSetting iniFile head key (data as string)
		)
		else
		(
			setIniSetting iniFile head key newValue
		)
	),
	fn saveLoadIniSetings head: key: data: action: =
	(
		if not doesFileExist Micra.UserSettings or  not doesFileExist Micra.DefaultSettings do return false
		if head == unsupplied or key == unsupplied do return false
		case action of
		(
			#load:
			(
				local user_data = getINISetting Micra.UserSettings head key
				if user_data != ""
				then return user_data --user settings
				else return getINISetting Micra.DefaultSettings head key --default settings
			)
			#save:
			(
				if data == unsupplied do return false
				setINISetting Micra.UserSettings head key data
			)
		)
	),
	fn saveIniDialog form_name form_category = (
	
		if not doesFileExist Micra.TempProfileIni do return false
		local data = execute (getIniSetting Micra.TempProfileIni form_category form_name) --pickup form pattern
		if classOf data != Array do data = #(false, [0,0], [0,0], "") --if form is new create default pattern
		local form = execute form_name --get form interface
		if superClassOf form == StructDef do ( --if form is instance class (get form from inside)
		
			form = form.form
		)
		--format "A saving form:% class:%\n" form_name (classOf form)
		case classOf form of (
			
			RolloutClass: (
			
				data[1] = form.isDisplayed
				if form.isDisplayed do (
				
					data[2] = getDialogPos  form
					data[3] = getDialogSize form
				)
			)
			DotnetObject:(
				 
				data[1] = form.visible
				if form.visible do (
				
					data[2] = [form.location.x, form.location.y]
					data[3] = [form.width, form.height]
				)
			)
		)
		setIniSetting Micra.TempProfileIni form_category form_name (data as string)
	),
	/**
	*@Example
		local from_data = mcFile.loadIniDialog form_title "Properties_2" --get saved pos and size
	*@Return data:#(undefined, [402,362], [730,500], "") --open at start, pos, size, title
	*/
	fn loadIniDialog form_name form_category = (

		if not doesFileExist Micra.TempProfileIni or not doesFileExist Micra.DefaultProfileIni do return undefined
		local data = execute (getIniSetting Micra.TempProfileIni form_category form_name) --pickup saved data
		if classOf data != Array do ( --if data not found on temp profile try get them from default profile
		
			data = execute (getIniSetting Micra.DefaultProfileIni form_category form_name) --pickup saved data
		)
		if classOf data != Array do return undefined -- form data not found
		--format "mcFile > loadIniDialog > data:%\n" data
		mcBounds pos:data[2] size:data[3]
	),
	fn backupMicraFile source_file = (
	
		if not doesFileExist source_file do return false
		local date_and_time = mcTime.getTime()
		local fname = getFilenameFile source_file
		local ftype = getFilenameType source_file
		local target_file = Micra.ResourcesDir+"Backup\\" + fname+"_"+date_and_time+ftype
		copyFile  source_file target_file
	),
	fn backupMaxFile =
	(
		local file_path = maxFilePath
		local file_name = maxFileName
		
		local not_saved_scene = getSaveRequired()
		if file_path == "" or not_saved_scene do (messageBox "Save you scene first." title:" Backup:" ;return false)
		
		local backup_dir = file_path + "BK\\" --define backup dir
		local file       = file_path+file_name
		
		--format "Current file: %\n" file
		
		if not doesFileExist backup_dir do makeDir backup_dir

		local max_files = getFiles (backup_dir+"*.max") --get all max files from BK dir
		local backup_files = for f in max_files where findString f "[BK]_" != undefined collect f --get only backup files
		
		local file_versioned
		
		if backup_files.count == 0 --first backup
		then
		(
			file_versioned = backup_dir+"[BK]_0.01_"+file_name
			copyFile file file_versioned
		)
		else
		(
			local last_file    = backup_files[backup_files.count] --get last backup file
			
			--format "Last    file: %\n" last_file 
			
			local last_version = (filterString (filenameFromPath last_file) "_")[2] as float --get last file version
			
			--format "Last version:%\n" last_version
			
			if classOf last_version != float do return false
			
			local new_version = (last_version + .01) as string
			if new_version.count < (last_version as string).count do new_version += "0" --keep always the same patern 00.00
			file_versioned = backup_dir+"[BK]_"+new_version+"_"+file_name
			copyFile file file_versioned
		)
		format "mcFile > Backup File: %\n" file_versioned
	),
	fn getClipboardTxt =
	(
		local clipboardClass = dotNetClass "System.Windows.Forms.Clipboard"
		if clipboardClass.containstext() then clipboardClass.getText() else ""
	),
	fn mergeMaxFiles dir matchObjectNamesToFiles:false =  --mergeMaxFiles "c:\\temp" matchObjectNamesToFiles:true
	(
		local files = getFiles dir+"\\*.max"
		for f in files do 
		(
			mergeMAXFile f #noRedraw #mergeDups #useMergedMtlDups #neverReparent #select -- #promptDups
			local obj  = selection[1]
			if obj != undefined do obj.name = getFilenameFile f
		)
	),
	--load icon from file
	fn getIconFromFile imgFile icNum icSize:24 imgSize:480 = (
	
		local icn = bitmap icSize icSize color:white
		if not doesFileExist imgFile or icNum == undefined or icNum < 1 do return icn
		local imgLib = openBitMap imgFile
		local icnCount = imgSize/icSize
		icNum -= 1
		local X = (mod icNum icnCount)
		local Y = (icNum / icnCount)
		
		local pix_x = X * icSize
		local pix_y = Y * icSize
		
		for i=0 to icSize do
		(
			local pix = getPixels imgLib [pix_x , pix_y + i] icSize 
			setpixels icn [0,i] pix
		)
		close imgLib
		return icn
	)
	/*<end>*/
)
 --create instance
Global mcFile = Micra.instanceStructure MICRA_FILE "mcFile"




/*
https://forums.cgsociety.org/t/create-and-share-a-folder-with-maxscript/1707543/14

 dotnet to fire a commandline process via xcopy or robocopy


DirectorySecurity class
getFileSecurityInfo <file_name> <attribute> testFileAttribute: <bool> 
getFileSecurityInfo (getDir #maxRoot) #write
isDirectoryWriteable (getDir #maxRoot)

fo = (dotNetClass "System.IO.File")
atr=fo.GetAttributes (getDir #maxRoot)
atr.Directory
atr.ReadOnly

System.IO.File  .[static]SetAttributes <System.String>path <System.IO.FileAttributes>fileAttributes
System.IO.File .[static]WriteAllText <System.String>path <System.String>contents

-----------------------------------------------------------------------------------
share_folder_command="net share sharename=\""+folderPath+"\"/UNLIMITED"
	DOScommand share_folder_command
------------------------------------------------------------------------------------

HiddenDosCommand ("net share " + (pathConfig.stripPathToLeaf folderPath) + "=" + "\"" + folderPath + "\"" + " /GRANT:Everyone,FULL")

-----------------------------------------------------------------------------------
net share cshare=c:\shared /GRANT:Everyone,FULL

-----------------------------------------------------------------------------------
temp_file = getDir #maxRoot + "test.ms"
fa = createFile temp_file
close fa
shellLaunch (getDir #maxRoot) ""
deleteFile temp_file
*/
-----------------------------------------------------------------------------------
/*
fn CreateSecurityOpsAssembly =
(
source  = ""
source += "using System;
"
source += "using System.IO;
"
source += "using System.Security.Principal;
"
source += "using System.Security.AccessControl;
"
source += "using System.Management;
"
source += " 
"
source += "namespace SystemSecurity
"
source += "{
"
source += "    public class AccessOps
"
source += "    {
"
source += "        public bool SetFullAccessControl(String path)
"
source += "        {
"
source += "            if (!Directory.Exists(path))
"
source += "            {
"
source += "                DirectoryInfo info = Directory.CreateDirectory(path);
"
source += "                if (!info.Exists) return false;
"
source += "            }
"
source += "            DirectorySecurity sec = Directory.GetAccessControl(path);
"
source += "       
"
source += "            SecurityIdentifier everyone = new SecurityIdentifier(WellKnownSidType.WorldSid, null);
"
source += "            sec.AddAccessRule(new FileSystemAccessRule(everyone, 
"
source += "                FileSystemRights.Modify | FileSystemRights.Synchronize, 
"
source += "                InheritanceFlags.ContainerInherit | InheritanceFlags.ObjectInherit, 
"
source += "                PropagationFlags.None, AccessControlType.Allow));
"
source += "            Directory.SetAccessControl(path, sec);
"
source += "            return Directory.Exists(path);
"
source += "        }
"
source += "        public Object ShareFolderPermission(String SharedFolderPath, String ShareName = \"\", String Description = \"\")
"
source += "        {
"
source += "            if (!Directory.Exists(SharedFolderPath))
"
source += "            {
"
source += "                bool result = SetFullAccessControl(SharedFolderPath);
"
source += "                if (!result) return false;
"
source += "            }
"
source += "            if (Directory.Exists(SharedFolderPath)) try
"
source += "            {
"
source += "                // Calling Win32_Share class to create a shared folder
"
source += "                ManagementClass managementClass = new ManagementClass(\"Win32_Share\");
"
source += "                // Get the parameter for the Create Method for the folder
"
source += "                ManagementBaseObject inParams = managementClass.GetMethodParameters(\"Create\");
"
source += "                // Assigning the values to the parameters
"
source += "                inParams[\"Description\"] = Description;
"
source += "                inParams[\"Name\"] = ShareName;
"
source += "                inParams[\"Path\"] = SharedFolderPath;
"
source += "                inParams[\"Type\"] = 0x0;
"
source += "                inParams[\"MaximumAllowed\"] = null;
"
source += "                inParams[\"Password\"] = null;
"
source += "                inParams[\"Access\"] = null; // Make Everyone has full control access.
"
source += "                // Finally Invoke the Create Method to do the process
"
source += "                ManagementBaseObject outParams = managementClass.InvokeMethod(\"Create\", inParams, null);
"
source += "                // Validation done here to check sharing is done or not
"
source += "                return ((uint)(outParams.Properties[\"ReturnValue\"].Value) != 0);
"
source += "            }
"
source += "            catch (Exception e)
"
source += "            {
"
source += "                return e;
"
source += "            }
"
source += "            return true;
"
source += "        }
"
source += "        public Object GetFullControl(String SharedFolderPath = \"\", String Description = \"\")
"
source += "        {
"
source += "            //user selection
"
source += "            NTAccount ntAccount = new NTAccount(\"Everyone\");
"
source += "            //SID
"
source += "            SecurityIdentifier userSID = (SecurityIdentifier)ntAccount.Translate(typeof(SecurityIdentifier));
"
source += "            byte[] utenteSIDArray = new byte[userSID.BinaryLength];
"
source += "            userSID.GetBinaryForm(utenteSIDArray, 0);
"
source += "            //Trustee
"
source += "            ManagementObject userTrustee = new ManagementClass(new ManagementPath(\"Win32_Trustee\"), null);
"
source += "            userTrustee[\"Name\"] = \"Everyone\";
"
source += "            userTrustee[\"SID\"] = utenteSIDArray;
"
source += "            //ACE
"
source += "            ManagementObject userACE = new ManagementClass(new ManagementPath(\"Win32_Ace\"), null);
"
source += "            userACE[\"AccessMask\"] = 2032127;								 //Full access
"
source += "            userACE[\"AceFlags\"] = AceFlags.ObjectInherit | AceFlags.ContainerInherit;
"
source += "            userACE[\"AceType\"] = AceType.AccessAllowed;
"
source += "            userACE[\"Trustee\"] = userTrustee;
"
source += "            ManagementObject userSecurityDescriptor = new ManagementClass(new ManagementPath(\"Win32_SecurityDescriptor\"), null);
"
source += "            userSecurityDescriptor[\"ControlFlags\"] = 4; //SE_DACL_PRESENT 
"
source += "            userSecurityDescriptor[\"DACL\"] = new object[] { userACE };
"
source += "            //UPGRADE SECURITY PERMISSION
"
source += "            ManagementClass mc = new ManagementClass(\"Win32_Share\");
"
source += "            ManagementObject share;
"
source += "            try
"
source += "            {
"
source += "                share = new ManagementObject(mc.Path + \".Name='\" + SharedFolderPath + \"'\");
"
source += "                share.InvokeMethod(\"SetShareInfo\", new object[] { Int32.MaxValue, Description, userSecurityDescriptor });
"
source += "            }
"
source += "            catch (ManagementException e)
"
source += "            {
"
source += "                return e.ErrorCode;
"
source += "            }
"
source += "            return true;
"
source += "            //This allow me to upgrade the security permission of \"Everyone\" in Windows Vista & 7 and get \"Full Control\"
"
source += "        }
"
source += "    }
"
source += "}
"

	csharpProvider = dotnetobject "Microsoft.CSharp.CSharpCodeProvider"
	compilerParams = dotnetobject "System.CodeDom.Compiler.CompilerParameters"

	compilerParams.ReferencedAssemblies.AddRange #("system.dll", "mscorlib.dll", "system.management.dll")

	compilerParams.GenerateInMemory = on
	compilerResults = csharpProvider.CompileAssemblyFromSource compilerParams #(source)
	
	assembly = compilerResults.CompiledAssembly
	assembly.CreateInstance "SystemSecurity.AccessOps"
)
global SecurityOps = CreateSecurityOpsAssembly()
*/

/*
SecurityOps.SetFullAccessControl @"c:	emp\sec2"
SecurityOps.ShareFolderPermission @"c:	emp\sec2" "my_folder" "Shared"
*/ 






/*
fn RunShellFile ShellFile =
      	(
      			local ShellPath = "C:\\WINDOWS\\system32\\WindowsPowerShell\\v1.0\\powershell.exe"
      			local procInfo = dotnetobject "System.Diagnostics.ProcessStartInfo" ShellPath
      			procInfo.Arguments = "-noprofile -executionpolicy bypass -File " + "\"" + ShellFile + "\""
      			procInfo.CreateNoWindow = on
      			procInfo.useShellExecute = off
      			local DotNetHandle = dotnetclass "System.Diagnostics.Process"
      			local SharingProcess = undefined
      			try 
      			(
      				SharingProcess = DotNetHandle.Start procInfo
      				SharingProcess.StartInfo.WindowStyle=(DotNetClass "System.Diagnostics.ProcessWindowStyle").Hidden
      			)
      			catch 
      			(
      				print "error launching Shell"
      				return false
      			)
      			SharingProcess.WaitForExit()
      			
      			if not ( SharingProcess.ExitCode == 0 ) then 
      			(
      				print "Sharing was not successful, please Share the Folder Manually!"
      				return false
      			)
      			else
      			(
      				print "Successfuly Shared"
      				return true
      			)	
      			SharingProcess.Close()	
      	)
      	
      	fn create_share folderPath =
      	(
      		makeDir folderPath
      		ShellFile=(folderPath +"\\powershell_share.ps1")
      		ShellCommandBuffer = 
      		#(
      			"function Get-GroupName", 
      			"{",
      			"	param ($SID)",
      			"	$objSID = New-Object System.Security.Principal.SecurityIdentifier($sid)",
      			"	$objUser = $objSID.Translate([System.Security.Principal.NTAccount])",
      			"	$objUser.Value",
      			"}",
      			"cmd /c $(" + "\"" + "net share " + (pathConfig.stripPathToLeaf folderPath) + "=" + folderPath + " /UNLIMITED /GRANT:"+ "\"" + "\"" +"$(Get-GroupName -SID 'S-1-1-0')"+ "\"" + "\"" +",FULL" + "\"" + ")",
      			"cmd /c $(" + "\"" + "cacls " + folderPath + " /e /p " + "\"" + "\"" +"$(Get-GroupName -SID 'S-1-1-0')"+ "\"" + "\"" + ":f" + "\"" + ")"
      		)	
      		(dotnetclass "System.IO.File").WriteAllLines ShellFile ShellCommandBuffer
      		RunShellFile ShellFile
      		deleteFile ShellFile
      	)
      
      create_share (sysInfo.tempdir + "test_folder")
*/