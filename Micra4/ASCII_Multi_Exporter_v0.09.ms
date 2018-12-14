--ASCII MULTI EXPORTER 
if ASCIIMultiExportDialog != undefined do destroyDialog ASCIIMultiExportDialog  
rollout ASCIIMultiExportDialog "ASCII Multi Exporter:" width:488 height:156
(
	local iniFile
	dropdownList ddl_dir "Export Path:" pos:[16,16] width:408 height:40
	button btn_dir "Dir..." pos:[428,32] width:48 height:24
	GroupBox grp1 "" pos:[4,4] width:480 height:148
	button btn_export "Export" pos:[172,60] width:304 height:68 toolTip:"Export to User defined Path"
	--button btn_close "X" pos:[564,4] width:12 height:12
	checkbox chk_collisions "Include Collisions" pos:[16,60] width:101 height:16
	checkbox chk_world_center "Center to World" pos:[16,76] width:101 height:16
	progressBar pBar "ProgressBar" pos:[8,132] width:468 height:13
	radioButtons rdo_path "" pos:[16,96] width:153 height:32 labels:#("Export to User defined Path", "Export to Max file Path") default:1 columns:1

	fn checkIniFile =
	(
		iniFile = GetDir #scripts + "\\ASCII_Multi_Exporter.ini "
		if not doesFileExist iniFile do try (createFile iniFile) catch (return false)
		return true
	)
	fn getRecentDirs =
	(
		local keys = getIniSetting iniFile "recent"
		for i in keys collect getIniSetting iniFile "recent" i
	)
	fn selectRecentDir =
	(
		local num = (getIniSetting iniFile "settings" "LastSel") as integer
		if num != 0 do ddl_dir.selection = num
	)
	fn Report sel error:#undefined =
	(
		case error of
		(
			#geofail    : (for i in sel where superclassof i == shape or classof i == Dummy do format "incorrect geometry:%\n" i.name to:listener) 
			#undefined  : (for i in sel do format "exported geometry:%\n" i.name to:listener) 
			#readonly   : 
			(
				for i in sel do
				(
					local f = ddl_dir.items[ddl_dir.selection] +"\\"+i.name+".ASE" 
					if doesFileExist f and getFileAttribute f #readOnly do format "read only file:%\n" f to:listener
				) 
			)
		)
	)
	fn geometryIsCorrect sel=
	(
		for i in sel where not isKindOf i GeometryClass do (Report sel error:#geofail ; return false)
		return true
	)
	fn readOnly sel = 
	(
		for i in sel do
		(
			local f = ddl_dir.items[ddl_dir.selection] + "\\" +i.name+ ".ASE" 
			if doesFileExist f and getFileAttribute f #readOnly do (Report sel error:#readonly  ; return true)
		)
		return false 
	)
	fn asciiExport obj path includeCollision:false =
	(
		max select none
		
		select obj
		
		if includeCollision do selectmore obj.children
		
		--format "Exported Items:%\n" (selection as array).count
		
		local fPath = (path +"\\"+obj.name+".ASE")
		exportFile fPath #noPrompt selectedOnly:true  using:AsciiExp
	)
	fn saveSettings =
	(
		setIniSetting iniFile "settings" "include_collisions" (chk_collisions.checked   as string)
		setIniSetting iniFile "settings" "center_to_world"  (chk_world_center.checked as string)
		setIniSetting iniFile "settings" "export_path_type" (rdo_path.state           as string)
		if ddl_dir.selection != undefined do setIniSetting iniFile "settings" "LastSel" (ddl_dir.selection as string)
	)
	fn loadSettings =
	(
		local saved_state        = getIniSetting iniFile "settings" "export_path_type"
		local include_collisions = getIniSetting iniFile "settings" "include_collisions"
		local center_to_world    = getIniSetting iniFile "settings" "center_to_world"
		
		rdo_path.state = if saved_state != "" then execute saved_state else 1
		if include_collisions != "" do chk_collisions.checked   = execute include_collisions
		if center_to_world    != "" do chk_world_center.checked = execute center_to_world
		
		case rdo_path.state of
		(
			1:
			(
				ddl_dir.items = getRecentDirs()
				selectRecentDir()
			)
			2:
			(
				ddl_dir.items = #(maxfilepath)
			)
		)
	)
	on ASCIIMultiExportDialog open do
	(
		if checkIniFile() 
		then (loadSettings())
		else (destroyDialog ASCIIMultiExportDialog)
	)
	on ASCIIMultiExportDialog close do (saveSettings())
	on btn_dir pressed  do
	(

		local itm = if ddl_dir.items.count != 0 do ddl_dir.items[ddl_dir.selection]
		local dir = if itm == undefined then "C:\\" else itm
		local path  = getSavePath caption:" Chose Dir..." initialDir:dir
		if path != undefined do 
		(
			local dirs = ddl_dir.items
			dirs += #(path)
			ddl_dir.items = dirs
			ddl_dir.selection = findItem dirs path
			--save recent list to ini file
			if doesFileExist iniFile do for i=1 to dirs.count do setIniSetting iniFile "recent" (i as string) dirs[i]
		)
	)
	on ddl_dir selected sel do
	(
		if sel != undefined and doesFileExist iniFile do  setIniSetting iniFile "settings" "LastSel" (sel as string)
	)
	on rdo_path changed state do 
	(
		case state of
		(
			1:(ddl_dir.items = getRecentDirs())
			2:(ddl_dir.items = #(maxfilepath))
		)
	)
	on btn_export pressed  do
	(
		local sel  = selection as array
		local itm = if ddl_dir.items.count != 0 do ddl_dir.items[ddl_dir.selection]
		local path = if itm == undefined then "" else itm

		pBar.color = white
		pBar.value = 0
		
		if sel.count != 0 then
		(
			if doesFileExist path then
			(
				if not readOnly sel then
				(
					if geometryIsCorrect sel 
					then 
					(
						-----------------
						with redraw off
						-----------------
						if chk_collisions.checked 
						then
						(
							local heads = for i in sel where i.parent == undefined collect i 
							for i=1 to heads.count do
							(
								local obj_old_pos
								if chk_world_center.checked do -- temporalily center object to scene and store old pos
								(
									obj_old_pos = heads[i].pos
									heads[i].pos = [0,0,0]
								)
								
								asciiExport heads[i] path includeCollision:true
								pBar.value = 100/heads.count as float * i
								ASCIIMultiExportDialog.title= "ASCII Multi Exporter: "+pBar.value as string+"%"
								
								if chk_world_center.checked do heads[i].pos = obj_old_pos --restore old pos
							)
						)
						else
						(
							for i=1 to sel.count do 
							(
								local obj_old_pos
								if chk_world_center.checked do -- temporalily center object to scene and store old pos
								(
									obj_old_pos = sel[i].pos
									sel[i].pos = [0,0,0]
								)
								
								asciiExport sel[i] path
								pBar.value = 100/sel.count as float * i --(100-((100/sel.count as float)*i))
								ASCIIMultiExportDialog.title= "ASCII Multi Exporter: "+pBar.value as string+"%"
								
								if chk_world_center.checked do sel[i].pos = obj_old_pos --restore old pos
							)
						)
						ASCIIMultiExportDialog.title= "ASCII Multi Exporter"
						pBar.value = 0
						Report sel
						select sel -- select old selection
						-----------------
						-----------------
					)
					else (messageBox "Selected Geometry contain Splines or Groups." title:"Cant Export!")
				)
				else (messageBox "Some files is Read Only." title:"Cant Export!")
			)
			else (messageBox "Output Directory is incorrect." title:"Cant Export!") 
		)
		else (messageBox "Nothing is Selected." title:"Cant Export!")	
	)
	on btn_close pressed  do
	(
		destroyDialog ASCIIMultiExportDialog	
	)
)
createDialog ASCIIMultiExportDialog style:#(#style_toolWindow, #style_sysMenu)
