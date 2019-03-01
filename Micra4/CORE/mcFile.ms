--------------------------------------------------------------------------------
/* mcFile by Orien 2019 */
--------------------------------------------------------------------------------
/*
*@Used Structures
	Micra
	mcDate
	mcString
	mcXML
*
*@Used Objects
	mcItem
	mcObject
	mcXMLAttrib
*
*@Example
*	mcFile.getDirTree (Micra.RootDir)
*	print mcFile.all_dirs
*/
struct MICRA_FILE (
	
	all_dirs = #(),
	fn getSource = getSourceFileName(), --get path of this script
	/*fn secondsSinceFileWritten fpath = ( --Not Used
	
   		if not doesFileExist fpath then 0
   		else (
   			local f = dotnetClass "system.io.File"
   			local ft = f.GetLastWriteTimeUtc(fpath)
   			local dt = dotNetClass "System.DateTime"
   			dt = dt.UtcNow
  			local t = dt.Ticks - ft.Ticks
   			local sec = ((t / 10000.0 / 1000.0) as string) as integer
   			sec
   		)
   	),*/
	fn secondsSinceFileWritten fpath = (
		if not doesFileExist fpath then 0
		else (
			local now = (dotnetclass "System.DateTime").UtcNow
			local last = (dotnetclass "System.IO.File").GetLastWriteTimeUtc fpath
			(now.Subtract last).Seconds
		)
	),
	/**
	*@Usage
		script_name	: String > 
		return		: String > version "1.02" or empty string ""
	*@Example 
		mcFile.getScriptVersion "Clone2"
	*/
	fn getScriptVersion script_name = (
		
		local xml = mcXML Micra.DefaultSettings
		local xml_node = xml.getNode ("//Version/"+script_name)
		if xml_node == undefined do return ""
		xml_node.getAttribute "val"
	),
	/**
	*@Usage > run a RootDir(file) as application(tool)
		script_name	: String > "Clone2"
	*@Example 
		mcFile.fileInVersion "Clone2"
	*/
	fn fileInVersion script_name = (	
	
		local f_version = getScriptVersion script_name
		if f_version == "" do(
		
			format "mcFile > fileInVersion > File[ % ], is not registred in [  %  ]\n" script_name Micra.DefaultSettings
			return false
		)
		local file = Micra.RootDir + script_name + "_v" + f_version + ".ms" --all apps is in root dir
		if doesFileExist file then (
		
			try (
				fileIn file
				format "mcFile > fileInVersion > Load tool [  %  ]  was success!\n" script_name
			
			) catch (
			
				format "mcFile > fileInVersion > Load tool [  %  ]  was failed!\n\tError:%\n" script_name (getCurrentException())
			)
		) else (
		
			format "mcFile > fileInVersion > Load tool [  %  ]  was failed!\n\tUnable locate file [ % ]\n" script_name file
		)
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
	fn getLastVersion files_array = (

		local last_version = 1
		for f in files_array do ( 
			
			local fname = getFilenameFile f
			local arr = filterString fname "_"
			local v = execute arr[arr.count]
			if last_version < v do last_version = v
		)
		last_version
	),
	/**
	*@Usage
		Create file copy with extension *.bk 
		[ file_name.bk1, file_name.bk2, file_name.bk3,...max_cnt ]
		max_cnt	define how many copies will be created, after max reached, then starts override oldest ones
	*/
	fn backupFile fpath dest_dir:undefined max_cnt:0 = (
	
		if doesFileExist fpath and max_cnt > 0 then (
		
			if dest_dir == undefined do dest_dir = getFilenamePath fpath --get current file dir
			if not doesDirectoryExist dest_dir do (
			
				format "mcFile > backupFile > Wrong destination directory: [ % ]\n" dest_dir
				return false
			)
			local file_name = getFilenameFile fpath
			--gather all backups
			local backup_files = getFiles (dest_dir+"*.bk")
			backup_files = for f in backup_files where findString f file_name != undefined collect f --filter only backups of current file
			--format "mcFile > backupFile > Existing backups count:[ %/% ]\n" backup_files.count max_cnt
			if backup_files.count == 0 then ( --create first backup
--print "first"
				local fpath_bk = dest_dir + file_name +"_1.bk"
				local file_created = copyFile fpath fpath_bk
				--format "mcFile > backupFile > file: [ % ] success:%\n" fpath_bk file_created
				
			) else if  backup_files.count < max_cnt then ( --create next backup
--print "next"	
				local last_version = getLastVersion backup_files
				local fpath_bk = dest_dir + file_name +"_"+(last_version+1) as string+".bk"
				local file_created = copyFile fpath fpath_bk
				--format "mcFile > backupFile > file: [ % ] success:%\n" fpath_bk file_created
	
			) else ( --override oldest backup
--print "override"
				local dates = #()
				for f in backup_files do (
				
					local file_lifetime = secondsSinceFileWritten f
					--format "file:% is old (%) sec\n" (getFilenameFile f) file_lifetime
					dates += #(mcItem key:(getFilenameFile f) val:file_lifetime tag:f)
				) 
				fn compareDates a b =  (  --sort items from lower value to higer
				
					case of (
					
						(a.val < b.val) : -1 
						(a.val > b.val) : 1
						default: 0
					)
				)
				qSort dates compareDates
				--for d in dates do format "mcFile > backupFile > sorted file:% old:%\n" d.key d.val
				local fpath_bk = dates[dates.count].tag --pick file with oldest date
				local file_deleted = deleteFile fpath_bk
				local file_created = copyFile fpath fpath_bk
				format "mcFile > backupFile > delete oldest backup [ % ] success:%\n" fpath_bk file_deleted
				format "mcFile > backupFile > create new backup [ % ] success:%\n" fpath_bk file_created
			)
		) else (
		
			format "mcFile > backupFile > file: [ % ] not found.\n" fpath
		)
	),
	fn backupMicraFile source_file = (
	
		if not doesFileExist source_file do return false
		local date_and_time = mcDate.getTime()
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
	fn attribsToObject arr = ( --return mcObject
	
		if classOf arr != Array do return undefined
		(mcObject.new()).addMore (for a in arr collect mcItem a.key a.val)
	),
	fn objectToAttribs obj = ( --return array of mcXMLAttrib
		
		if superClassOf obj != StructDef do return undefined
		for k in obj.keys() collect (mcXMLAttrib k (obj.get k))
	),
	/**
	*@Created 13.02.2019
	*@Usage > save settings in to xml file
		xml_file	: String	> xml file path
		xml_path	: String	> target xml node > "Settings/Tools" or simple "Tools"
		data		: String	> value to save
		backup		: Int		> backups count
	*@Example
		mcFile.saveSettings xml_file "Version/Customize_Colors" "0.05" backup:4 --add-replace node with parameter > val = "0.05", also create backup first
		mcFile.saveSettings xml_file "Selection" (for i in selection collect i.name) type:"keys" --collect all node names under path "Selection"
		mcFile.saveSettings xml_file "Selection/Sphere050" "" --add-replace node only
		mcFile.saveSettings xml_file "Selection/Sphere005" "78" --add-replace node with parameter > val = "78"
		mcFile.saveSettings xml_file "Selection/Sphere005" "78" type:"cnt" --add-replace node with parameter > cnt = "78"
		node_attribs = (mcObject.new()).addMore #(

			mcItem "action" "Move_To_X", 
			mcItem "icon" "28"
		)
		mcFile.saveSettings Micra.UserProfile "Buttons/btn_B4555" node_attribs type:"attribs"
	*/
	fn saveSettings xml_file xml_path data type:"default" backup:0 = (
		
		local xml = mcXML xml_file
		if not xml.exists() then ( --create xml file
		
			local root_node_name = (filterString xml_path "/")[1] --get first item at path : "Settings/Data/Item"  > "Settings"
			xml.addRootNode root_node_name	
			
		) else if backup > 0 do ( --backup file
		
			backupFile xml_file max_cnt:backup
		)
		case type of (
		
			"val"	: (
				local xml_node = xml.getNode ("//"+xml_path)
				if xml_node == undefined do xml_node = xml.addNode ("//"+xml_path) "" --create empty node
				if classOf data != String do (format "mcFile > saveSettings > Invalid data input, except an String\n"; return false)
				if data.count > 0 do xml_node.setAttribute "val" (data as String)
			)
			"keys"	: (
				data = objectToAttribs data --convert object in to attribute array
				if classOf data != Array do (format "mcFile > saveSettings > Invalid data input, except an  Array\n"; return false)
				for key in data do xml.addNode ("//"+xml_path) key
			)
			"attribs"	: (
			
				local xml_node = xml.getNode ("//"+xml_path)
				if xml_node == undefined do xml_node = xml.addNode ("//"+xml_path) "" --create empty node	
				data = objectToAttribs data --convert object in to attribute array
				if classOf data != Array do (format "mcFile > saveSettings > Invalid data input, except an Array\n"; return false)
				if data.count > 0 do xml_node.setAttributes data
			)
			default	: (
			
				local xml_node = xml.getNode ("//"+xml_path)
				if xml_node == undefined do xml_node = xml.addNode ("//"+xml_path) "" --create empty node	
				if xml_node == undefined do (format "mcFile > saveSettings > Unable create node at:%\n" xml_path; return false)
				if classOf data != String do (format "mcFile > saveSettings > Invalid data input, except an String\n"; return false)
				if data.count > 0 do xml_node.setAttribute (if type == "default" then "val" else type) (data as String)
			)
		)
		if not xml.save() do ((format "mcFile > saveSettings > Unable Save File! [%]\n" xml_file); return false)
		true
	),
	/**
	*@Example
		cat_names = mcFile.readSettings Micra.ActionsXML "ACTIONS" type:"keys"
		all_parameters = mcFile.readSettings Micra.ActionsXML "ACTIONS/Object/Spline_Magnet" type:"attribs"
		all_parameters.print()
		help_txt = mcFile.readSettings Micra.ActionsHelpXML "Pivot/Afect_Pivot_Only"
		pos = mcFile.readSettings Micra.UserProfile "Properties_2/mcCustomizeDialog" type:"pos" --uses default type
		is_active = mcFile.readSettings Micra.UserProfile "Properties_2/mcCustomizeDialog" type:"active" --uses default type
		size = mcFile.readSettings Micra.UserProfile "Properties_2/mcCustomizeDialog" type:"size" --uses default type
	*/
	fn readSettings xml_file xml_path type:"default" = (

		if not doesFileExist xml_file do ((format "mcFile > readSettings > Missing File! [%]\n" xml_file); return "")
		local xml = mcXML xml_file
		local xml_node = xml.getNode ("//"+xml_path)
		if xml_node == undefined do return ""
		case type of (
		
			"keys"	: xml_node.getChildrenNames()
			"attribs"	: (
			
				local xml_attributes = xml_node.getAllAttributes()
				attribsToObject xml_attributes
			)
			default	: xml_node.getAttribute (if type == "default" then "val" else type)
		)
	),
	/**
	*@Example
		mcFile.delSettings xml_file "Selection" type:"keys" --remove all nodes under Selection path
		mcFile.delSettings xml_file "Selection/Sphere005" type:"attr" --remove only atributes
		mcFile.delSettings xml_file "Selection/sphere_01" --remove single node
	*/
	fn delSettings xml_file xml_path type:"default" = (
	
		if not doesFileExist xml_file do ((format "mcFile > delSettings > Missing File! [%]\n" xml_file); return false)
		local xml = mcXML xml_file
		case type of (
		
			"keys"	: xml.delAllNodes ("//"+xml_path)
			"attr"	: xml.delAllAttributes ("//"+xml_path)
			default	: xml.delNode ("//"+xml_path)
		)
		if not xml.save() do ((format "mcFile > delSettings > Unable Save File! [%]\n" xml_file); return false)
		true
	),
	fn swapSettings xml_file xml_path_a xml_path_b = (
	
		if not doesFileExist xml_file do ((format "mcFile > swapSettings > Missing File! [%]\n" xml_file); return false)
		local xml = mcXML xml_file
		xml.swapAttributes xml_path_a xml_path_b
		xml.save()
	),
	/**
	*@Example
		local from_data = mcFile.readDialogSettings "mcModifierDialog" "Properties_2" --get saved pos and size
		> mcObject (
			key:active val:false
			key:pos val:[1244,290]
			key:size val:[328,276]
			key:title val:
		)
		if from_data != undefined do (
		
			local pos = execute (form_settings.get "pos")
			local size = execute (form_settings.get "pos")
			form.bounds = mcDotnet.dRect pos size
		)
	*/
	fn readDialogSettings form_name form_category = (

		--format "xml_path:%\n" (form_category+"/"+form_name)
		local form_settings = readSettings Micra.UserProfile (form_category+"/"+form_name) type:"attribs"
		if form_settings == "" do return undefined
		form_settings
	),
	/**
	*@Example
		mcFile.saveDialogSettings s.name "Properties_2"
	*/
	fn saveDialogSettings form_name form_category = (
		
		if not doesFileExist Micra.UserProfile do return false	
		local form = execute form_name --get form interface
		local form_settings = mcObject()
		if superClassOf form == StructDef do ( --if form is instance class (get form from inside)
		
			form = form.form
		)
		case classOf form of (
			
			RolloutClass: (
			
				form_settings.add "active" (form.isDisplayed as String)
				--if form.isDisplayed do (
				
					form_settings.add "pos" (getDialogPos  form as String)
					form_settings.add "size" (getDialogSize form as String)
				--)
				--format "saving RolloutClass name:% settigs:%\n" form_name (form_settings.toString())
			)
			DotnetObject:(
				 
				form_settings.add "active" form.visible
				--if form.visible do (
				
					form_settings.add "pos" ([form.location.x, form.location.y] as String)
					form_settings.add "size" ([form.width, form.height] as String)
				--)
				--format "saving DotnetObject name:% settigs:%\n" form_name (form_settings.toString())
			)
		)
		mcFile.saveSettings Micra.UserProfile (form_category+"/"+form_name) form_settings type:"attribs"
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
	),
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
	)
	/*<end>*/
)
 --create instance
Global mcFile = mcStructMan.instanceStructure MICRA_FILE "mcFile"




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