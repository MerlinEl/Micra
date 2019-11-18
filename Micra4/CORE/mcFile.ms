--------------------------------------------------------------------------------
/* mcFile by Orien 2019 */
--------------------------------------------------------------------------------
/*
*@Used Structures
	Micra
	mcDate
	mcString
	mcArray
	mcXML
*
*@Used Objects
	mcItem
	mcObject
	mcXMLAttrib
*
*@Example
*	dir_tree = mcFile.getDirTree Micra.RootDir
*	print dir_tree
*	files_tree = mcFile.getFilesTree Micra.RootDir
*	print files_tree
*/
struct MICRA_FILE (
	
	fn getSource = getSourceFileName(), --get path of this script
	fn filterPath path = --fix path 
	(
		local arr   = filterString path "\\/"
		local isDir = path[path.count-3] != "." -- example C:\temp.txt
		local newPath = ""
		for i=1 to arr.count do newPath += arr[i] + ( if isDir or i != arr.count then "/" else "")
		return newPath
	),
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
	fn isFileOlder src_path trgt_path = (
	
		local src_sec = secondsSinceFileWritten src_path
		local trgt_sec = secondsSinceFileWritten trgt_path
		src_sec < trgt_sec
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
	fn runScript script_name root:true = (

		local base_dir = if root then micra.RootDir else micra.CoreDir
		local script_file = base_dir+script_name+".ms"
		if doesFileExist script_file then (
		
			fileIn script_file
			
		) else (
		
			messageBox ("Script ["+script_file+"] Not Found.") title:"Warning:"
			return false
		)
		true
	),
	/**
	*@Example
		mcFile.initStruct gTerrainGeneratorCollision "LS3D_Terrain_Collisions_Generator" force:true
	*/
	fn initStruct struct_name script_name force:false root:true = (

		if superClassOf struct_name != StructDef or force do (
		
			format "Initialize Structure: [ % ] \n" script_name
			runScript script_name root:root
		)
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
				format "mcFile > fileInVersion > [  %  ]\n" script_name
			
			) catch (
			
				format "mcFile > fileInVersion > [  %  ]  was failed!\n\tError:%\n" script_name (getCurrentException())
			)
		) else (
		
			format "mcFile > fileInVersion >  [  %  ]  was failed!\n\tUnable locate file [ % ]\n" script_name file
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
	fn getDirectoriesRecursive all_dirs current_dir = (
	
		local sub_dirs = getDirectories (current_dir+"*.*")
		join all_dirs sub_dirs
		for d in sub_dirs do getDirectoriesRecursive all_dirs d
	),
	fn getDirTree dir = (
		
		local all_dirs = #()
		getDirectoriesRecursive all_dirs dir	
		all_dirs
	),
	fn getFilesTree dir fname:"*" ext:"*"= (
		
		local all_dirs = getDirTree dir
		local filter = fname + "." + ext
		local all_files = (getFiles (dir+filter))
		for d in all_dirs do join all_files (getFiles (d+filter))
		all_files
	),
	/**
	*@Example
		mcFile.getFilesDuplicates "g:\\CINEMA\\_unsorted_\\"
		mcFile.getFilesDuplicates "g:\\CINEMA\\_unsorted_\\" filter:#("avi", "url", "mp4", "srt", "mkv", "zip", "ass", "ssa")
	*/
	fn getFilesDuplicates dir filter:#() debug:false = (
	
		local all_files = getFilesTree dir
		local file_names = for f in all_files collect filenameFromPath f
		local dups_array = mcArray.findDuplicates file_names
		if debug do for ba in dups_array do (
		
			format "------------------------------------------\n"
			format "dupplicated files at:%\n" ba
			for i in (ba as array) do format "\t% size:%\n" (f = all_files[i]) (getFileSize f)
			format "------------------------------------------\n"
		)
		local dups = #()
		for ba in dups_array do ( --for each dupes set
		
			local dupps_set = (ba as array)
			local first_file_size = getFileSize all_files[dupps_set[1]]
			local fisrt_skip = true
			for i in dupps_set do (
			
				if fisrt_skip do ( --skip first file from each set
				
					fisrt_skip = false
					continue
				)
				local file = all_files[i]
				if filter.count != 0 do ( --skip files which not have right extension

					local ext = getFilenameType file 
					ext = substring ext 2 ext.count --remove dot (.avi)
					if findItem filter ext == 0 do continue
				)
				if first_file_size != getFileSize file do continue --skip files with not same size
				append dups file
			)
		)
		dups
	),
	/**
	*@Usage	Compare two dirs include subdirs. Output files is diference between source and target dir 
	*@Example
		missing_files = getMissingFiles "k:\\Filmy\\" "g:\\CINEMA\\_unsorted_\\" filter:#("avi", "url", "mp4", "srt", "mkv", "zip", "ass", "ssa")
		missing_files = getMissingFiles "k:\\Filmy\\" "g:\\CINEMA\\_unsorted_\\" filter:#("avi")
	*/
	fn getMissingFiles src_dir trgt_dir filter:#() debug:false = (	

		local src_files = getFilesTree src_dir
		local trgt_files = getFilesTree trgt_dir
		if debug do format "src:% trgt:%\n" src_files.count trgt_files.count
		local trgt_fnames = for f in trgt_files collect (filenameFromPath f)
		local missing_files = #()
		for file in src_files do (

			if filter.count != 0 do ( --skip files which not have right extension

				local ext = getFilenameType file 
				ext = substring ext 2 ext.count --remove dot (.avi)
				if findItem filter ext == 0 do continue
			)
			local fname = filenameFromPath file
			if findItem trgt_fnames fname != 0 do continue --found (not missing)
			if debug do format "missing file: [ % ]\n" fname
			append missing_files file
		)
		missing_files
	),
	/**
	*@Usage > delete files and subdirectories from given directory (exclude works only in root dir)
	*@Alert > I recommended to use secure verification:"SomeUniqueFile.txt" to be sure you are in right directory ;-)
	*@Example
		mcFile.deleteDirectoryContent "e:\\Aprog\\Orien\\Micra\\Micra4\\Temp\\extract_files\\" verification:"Actions.xml"
		mcFile.deleteDirectoryContent "e:\\Aprog\\Orien\\Micra\\Micra4\\Temp\\extract_files\\" exclude:#("bin", "Readme.txt") verification:"Actions.xml"
	*/
	fn deleteDirectoryContent dir exclude:#() verification:"any" = (
	
		local sio = dotNetClass "System.IO.Directory"
		if not (sio.Exists dir) do return false
		local all_dirs	= sio.GetDirectories dir
		local dir_files	= sio.GetFiles dir
		--format "verification check...\n"
		if secure != "any" do (
		
			local is_right_directory = false
			for f in dir_files do if filenameFromPath f == verification do is_right_directory = true
			if not is_right_directory do (
			
				format "Verification falied in Directory [ % ]. Deleting Aborted. Be careful -;) \n" dir
				return false
			)
		)
		--format "process to deleting files...\n"
		fn isPathExcluded arr path = (
			
			local indexes = ::mcArray.findWord arr (filenameFromPath path) ignoreCase:true
			--format "arr:% path:% indexes:%\n" arr path indexes
			indexes.count != 0
		)
		for f	in dir_files	where	not (isPathExcluded exclude f) do deleteFile f
		--delete directories
		for d	in all_dirs		where	not (isPathExcluded exclude d) do sio.Delete d true --delete dirs and subdirs
		true
	),
	/**
	*@Usage > Delete a file from all dirs and subdirs
	*@Example
		mcFile.delFileInTree "g:\\CINEMA\\_unsorted_\\" "Thumbs.db"
		mcFile.delFileInTree "g:\\CINEMA\\_unsorted_\\" "readme.txt"
	*/
	fn delFileInTree dir fname_ext confirm:true = (
	
		local far = filterString fname_ext "."
		if confirm do (
			
			if not (queryBox ("You are sure to delete file [ "+fname_ext+" ]  in all subdirs:\n[ "+dir+" ] ?") title:Micra.version) do (
				
				print "delFileInTree > was Aborted."
				return false
			)
		)
		if far.count != 2 do return false
		local all_files = getFilesTree dir fname:far[1] ext:far[2]
		for f in all_files do deleteFile f
		format "Deleted files( % )\n" all_files.count
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
	*@Rules > Is better to use full path to write in xml > rootNode(USER) > "USER/Properties_2/mcCustomizeDialog"
	*@Example
		mcFile.saveSettings Micra.UserSettings "USER/Settings/Test_Key" "0.05" backup:4 --add-replace node with parameter > val = "0.05", also create backup first
		mcFile.saveSettings Micra.UserSettings "USER/Test_Sub2/Test_Key" "" --add-replace node only
		mcFile.saveSettings Micra.UserSettings "USER/Test_Sub/Test_Key" "0.05" --add-replace node with value > val = "78"
		mcFile.saveSettings Micra.UserSettings "USER/Test_Sub3" (for i=1 to 5 collect ("key_"+i as string)) type:"keys" --write multiple keys under a node
		mcFile.saveSettings Micra.UserSettings "USER/Sphere005" "78" type:"cnt" --add-replace node with parameter > cnt = "78"
		node_attribs = (mcObject.new()).addMore #(

			mcItem "action" "Move_To_X", 
			mcItem "icon" "28"
		)
		mcFile.saveSettings Micra.UserSettings "USER/Test_Sub/Test_Key2" node_attribs type:"attribs"
	*/
	fn saveSettings xml_file xml_path data type:"default" backup:0 = (
		
		local xml = mcXML xml_file
		if not xml.exists() then ( --create xml file
		
			local root_node_name = (filterString xml_path "/")[1] --get first item at path : "Settings/Data/Item"  > rootNode(Settings)
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
	*@Usage > Read XML data. 
		xml_file	: String	> xml file path
		xml_path	: String	> target xml node > "Settings/Tools" or simple "Tools"
		type		: String	> attribute(get specific value) or nothing(default get "val") or "keys"(get nodes list uder key)
		return		: String or Array
	*@Rules > Is better to use full path to read from xml > rootNode(USER) > "USER/Properties_2/mcCustomizeDialog"
	*@Example
		pos = mcFile.readSettings Micra.UserProfile "USER/Properties_2/mcCustomizeDialog" type:"pos"
		prop2_dialogs = mcFile.readSettings Micra.UserProfile "USER/Properties_2" type:"keys"
		help_txt = mcFile.readSettings Micra.ActionsHelpXML "ACTIONS/Pivot/Afect_Pivot_Only" --using default type "val"
		all_parameters = mcFile.readSettings Micra.ActionsXML "ACTIONS/Object/Spline_Magnet" type:"attribs"
		all_parameters.print()
		is_active = mcFile.readSettings Micra.UserProfile "USER/Properties_2/mcCustomizeDialog" type:"active"
		size = mcFile.readSettings Micra.UserProfile "USER/Properties_2/mcCustomizeDialog" type:"size"
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
	*@Usage > Delete XML data. 
		xml_file	: String	> xml file path
		xml_path	: String	> target xml node > "Settings/Tools" or simple "Tools"
		type		: String	> attribute(get specific value) or nothing(default get "val") or "keys"(get nodes list uder key)
	*@Rules > Is better to use full path to delete from xml > rootNode(USER) > "USER/Properties_2/mcCustomizeDialog"
	*@Example
		mcFile.delSettings Micra.UserSettings "USER/Test_Sub3" type:"keys" --remove all nodes under Selection path
		mcFile.delSettings Micra.UserSettings "USER/Test_Sub/Test_Key2" type:"attr" --remove only atributes
		mcFile.delSettings Micra.UserSettings "USER/Test_Sub" --remove single node
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