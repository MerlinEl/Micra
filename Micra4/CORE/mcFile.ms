--------------------------------------------------------------------------------
/* mcFile by Orien 2019 */
--------------------------------------------------------------------------------
/*
*@Used Structures
	Micra
	mcTime
*
*@Used Objects

*
*@Example
*	mcFile.getDirTree (Micra.RootDir)
*	print mcFile.all_dirs
*/
struct MICRA_FILE (
	
	all_dirs = #(),
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
		--indir = mcFile.filterPath2 indir
		--outdir = mcFile.filterPath2 outdir
		
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
		indir = mcFile.filterPath indir
		outdir = mcFile.filterPath outdir

		local files = getFiles (indir+"*.*")
		local dirs = getDirectories (indir+"*.*")
		
		for f in files do ( copyFile f (outdir+filenameFromPath f) )
		for d in dirs do 
		(              
			local filter_path = filterString d "\/"
			local new_dir = outdir+filter_path[filter_path.count]
			makedir new_dir
			mcFile.treeCopy d new_dir
		)
	),
	fn import =
	(
		max file import	
	),
	fn open fpath =
	(
		fpath = mcFile.filterPath fpath 
		if not doesFileExist fpath do return false
		if isMaxFile fpath do try (loadMaxFile fpath useFileUnits:true quiet:false) catch()
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
		format "Backup File: %\n" file_versioned
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
	--mcFile.getIniDataFromArray Micra.TempProfileIni "Properties_2" "mcColorPickerDialog" 2
	fn getIniDataFromArray iniFile head key arrNum =
	(
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
)
 --create instance
Global mcFile = Micra.instanceStructure MICRA_FILE "mcFile"