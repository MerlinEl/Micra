rollout mcUEToMaxImporter "UE To 3DsMax Importer:" width:620 height:152
(
	--> local variables
	local packages_dir, export_dir, ini_file, package_file
	local configFile = undefined
	local tmp_v  = undefined		-- global variable, helper for DoSetting() (required for execute() ...)
	local g_isLoading = true		-- DoSetting() mode
	
	--> interface
	label lbl1 "Packages:" pos:[12,28] width:68 height:16
	GroupBox grp1 "Paths..." pos:[4,4] width:612 height:144
	dropdownList ddl_packagepath "" pos:[84,24] width:460 height:21
	button btn_ad1 "+" pos:[552,24] width:28 height:20 toolTip:"Add Path"
	button btn_del1 "x" pos:[584,24] width:28 height:20 toolTip:"Remove Path"
	label lbl2 "Temp Export:" pos:[12,56] width:68 height:16
	dropdownList ddl_exportpath "" pos:[84,52] width:460 height:21
	button btn_ad2 "+" pos:[552,52] width:28 height:20 toolTip:"Add Path"
	button btn_del2 "x" pos:[584,52] width:28 height:20 toolTip:"Remove Path"
	label lbl3 "UE Model:" pos:[12,84] width:68 height:16
	dropdownList ddl_modelpath "" pos:[84,80] width:460 height:21
	button btn_ad3 "+" pos:[552,80] width:28 height:20 toolTip:"Add Path"
	button btn_del3 "x" pos:[584,80] width:28 height:20 toolTip:"Remove Path"
	button btn_import "IMPORT" pos:[8,108] width:604 height:36
	--> functions
	fn getClipboardTxt =
	(
		local clipboardClass = dotNetClass "System.Windows.Forms.Clipboard"
		if clipboardClass.containstext() then clipboardClass.getText() else ""
	)
	fn getMeshType p =
	(
		local mesh_type = (filterString p "'")[1]
		case mesh_type of
		(
			"StaticMesh"  :("StaticMesh" )
			"SkeletalMesh":("SkeletalMesh")
		)
	)
	fn correctPathSlashes path =
	(
		local path_array = filterString path "\/"
		format "pa1:%\n" path_array
		new_path  = ""
		for i=1 to path_array.count do 
		if i < path_array.count 
		then new_path += path_array[i]+"\\\\"
		else new_path += path_array[i]
		format "pa2:%\n" new_path
		return new_path
	)
	fn addDir ddl ini_key =
	(
		local path  = getSavePath caption:" Chose Dir..." initialDir:dir
		if path != undefined do 
		(
			local dirs = #(path) + ddl.items
			ddl_dir.items = dirs
			
			delIniSetting ini_file ini_key 
			for i in dirs do setIniSetting ini_file ini_key  i ""
		)	
	)
	fn getModelFromPackage full_model_path package_path package_name model_name =
	(
		print "getting.... Model From Package"
		--rem cesta out + cesta in + balik + nazev modelu = exportuje model
		--umodel -out=Export -path=Packages -export itm_cinema key01_obj_uni_ac

		local umod_file    = mcPath()+"App\\umodel.exe"
		--cesta je jeste jednou zastringovana kvuli mezeram a dlouhym nazvum
		local cmd = "\"" +umod_file + "\"" +" -out="+export_dir +" -path="+package_path +" -export  -all "+ package_name +" "+ model_name + "\n"
		cmd = correctPathSlashes cmd
		DOSCommand cmd
		
		local mesh_type = getMeshType full_model_path
		if mesh_type ==undefined do return ""
		local extension = case mesh_type of
		(
			"StaticMesh"  :".pskx"
			"SkeletalMesh":".psk"
		)
		if extension == undefined do return "" --if unknow format converted
		local fpath = export_dir+"\\"+package_name+"\\"+mesh_type+"\\"+model_name+extension
		return fpath
	)
	fn addNewModel p = --max 10 items in list
	(
		local models_paths = getIniSetting ini_file "models_paths"
		delIniSetting ini_file "models_paths"
		if models_paths.count > 9 do deleteItem models_paths 10
		models_paths = #(p) + models_paths
		for i in models_paths do setIniSetting ini_file "models_paths" i ""
		return models_paths	
	)
	fn checkIniFile =
	(
		ini_file = GetDir #scripts + "\\UE_To_3DsMax_Importer.ini "
		if not doesFileExist ini_file do try 
		(
			local f = createFile ini_file
			close f
			
			setIniSetting ini_file "export_dirs" "C:\\Temp\\UE_Export\\" ""
			setIniSetting ini_file "packages_dirs" "C:\\Dev\\SilentHill\\SHGame\\Content\\Packages\\" ""
			setIniSetting ini_file "packages_dirs" "C:\\Dev\\D-Arms\\Game\\DAGame\\Content\\Packages\\" ""
		) 
		catch (return false)
		return true
	)
	fn loadSettings =
	(
		
		local packages_dirs = getIniSetting ini_file "packages_dirs"
		local export_dirs = getIniSetting ini_file "export_dirs"
		local models_paths = getIniSetting ini_file "models_paths"
		--load data from ini file if exist
		if packages_dirs.count  !=0 do ddl_packagepath.items = packages_dirs
		if export_dirs.count      !=0 do ddl_exportpath.items = export_dirs
		if models_paths.count  !=0 do ddl_modelpath.items = models_paths
		
		--full path = SkeletalMesh'itm_cinema.Meshes.key01_obj_uni_ac'
		full_model_path = getClipboardTxt()
		if getMeshType full_model_path != undefined do 
		(	
			ddl_modelpath.items = addNewModel full_model_path
		)
	)
	--> actions
	on mcUEToMaxImporter open do
	(
		if checkIniFile() 
		then (loadSettings())
		else (destroyDialog mcUEToMaxImporter)
	)
	on btn_ad1 pressed  do
	(
		
		)
		on btn_del1 pressed  do
		(
			if ddl_packagepath.items.count > 1 do 
			(	
				delIniSetting ini_file "packages_dirs" ddl_packagepath.selected
				ddl_packagepath.items = (deleteItem ddl_packagepath.items 1)
			)
		)
		on btn_ad2 pressed  do
		(
		
		)
		on btn_del2 pressed  do
		(
			if ddl_exportpath.items.count > 1 do 
			(	
				delIniSetting ini_file "export_dirs" ddl_exportpath.selected
				ddl_exportpath.items = (deleteItem ddl_exportpath.items 1)
			)
		)
		on btn_ad3 pressed  do 
		(
			--full path = SkeletalMesh'itm_cinema.Meshes.key01_obj_uni_ac'
			local full_model_path = getClipboardTxt()
			if getMeshType full_model_path != undefined do 
			(	
				ddl_modelpath.items = addNewModel full_model_path
			)
		)
		on btn_del3 pressed  do
		(
			if ddl_modelpath.items.count > 0 do 
			(	
				delIniSetting ini_file "models_paths" ddl_modelpath.selected
				ddl_modelpath.items = (deleteItem ddl_modelpath.items 1)
			)
		)
		on btn_import pressed  do
		(
		
		)
)
createDialog mcUEToMaxImporter