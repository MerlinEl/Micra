--FBX to PSA Batch Converter v0.01 
--by Merlin 11.01.2010

Global FBXtoPSABatchConverterDialog
try (destroyDialog FBXtoPSABatchConverterDialog) catch ()
rollout FBXtoPSABatchConverterDialog " FBX to PSA Batch Converter v0.05" width:396 height:520
(
	--Local Variables
	local iniFile = Micra.UserDir + "FBX_to_PSA_Batch_Converter.ini "
	local bgColor = ((colorMan.getColor #background)*255)as color
	local winColor = ((colorMan.getColor #window)*255)as color
	local textColor = ((colorMan.getColor #text)*255)as color
	local user_name = (filterString (getDir #maxData) "\\")[3]
	local presets_path = "C:\\Documents and Settings\\" + user_name + "\\My Documents\\3dsmax\\fbxpresets\\2009.3\\import\\"
	local mark_anims_enabled = false
	local t = dotNetObject "Timer"
	local tick = 0
	local bone_names  = #
	(
		"ROOT",
		"Hips",
		"Spine", "Spine1", "Spine2", "Spine3", "Spine4",
		"RightShoulder",
		"RightArm", "RightArmRoll",
		"RightForeArm", "RightForeArmRoll",
		"RightHand",
		"RightHandMiddle1", "RightHandMiddle2", "RightHandMiddle3" ,
		"RightHandRing1"  , "RightHandRing2"  , "RightHandRing3"  ,
		"RightHandThumb1", "RightHandThumb2", "RightHandThumb3",
		"RightInHandIndex" , "RightHandIndex1" , "RightHandIndex2" , "RightHandIndex3",
		"RightInHandPinky" , "RightHandPinky1" , "RightHandPinky2" , "RightHandPinky3",
		"RightHandDummy" ,
		"LeftShoulder",
		"LeftArm", "LeftArmRoll",
		"LeftForeArm", "LeftForeArmRoll",
		"LeftHand",
		"LeftHandMiddle1" , "LeftHandMiddle2", "LeftHandMiddle3" ,
		"LeftInHandPinky" , "LeftHandPinky1"  , "LeftHandPinky2" , "LeftHandPinky3",
		"LeftInHandIndex" , "LeftHandIndex1"  , "LeftHandIndex2" , "LeftHandIndex3",
		"LeftHandThumb1", "LeftHandThumb2" , "LeftHandThumb3",
		"LeftHandRing1"  , "LeftHandRing2"   , "LeftHandRing3"  ,
		"Neck",
		"Head",
		"RightUpLeg", "RightUpLegRoll",
		"RightLeg",
		"RightFoot",
		"RightToeBase",
		"LeftUpLeg", "LeftUpLegRoll",
		"LeftLeg",
		"LeftFoot",
		"LeftToeBase"
	)
	GroupBox grp1 "Merlin 11.01.2010" pos:[4,4] width:388 height:512
	button btn_dir_fbx "FBX..." pos:[336,24] width:52 height:20
	dropdownList ddl_dir_fbx "" pos:[8,24] width:324 height:21
	button btn_batch "BATCH" pos:[8,484] width:380 height:28
	dotNetControl lvf "listView" pos:[8,72] width:188 height:356
	button btn_dir_psa "PSA..." pos:[336,48] width:52 height:20
	dropdownList ddl_dir_psa "" pos:[8,48] width:324 height:21
	dotNetControl lva "listView" pos:[200,72] width:188 height:356
	label lbl1 "Skeleton Set: ROOT_" pos:[8,436] width:124 height:16
	edittext edt_Suffix "" pos:[134,434] width:60 height:16 text:"01"
	dropdownList ddl_presets "" pos:[136,456] width:252 height:21
	label lbl2 "Current Preset:" pos:[8,460] width:124 height:16
	--Functions
	fn netDrColor clr = ((dotNetClass "Drawing.Color").fromArgb clr.r clr.g clr.b)
	
	fn checkIniFile =
	(
		if not doesFileExist iniFile do try (createFile iniFile) catch (return false)
		return true
	)

	fn getRecentDirs =
	(
		local fbx_keys = getIniSetting iniFile "RecentFBX"
		local fbx_dirs = for i in fbx_keys collect getIniSetting iniFile "RecentFBX" i
		ddl_dir_fbx.items = fbx_dirs
		if ddl_dir_fbx.items.count != 0 do
		(
			local num = (getIniSetting iniFile "settings" "LastSelFBX") as integer
			if num != 0 do ddl_dir_fbx.selection = num
		)
		
		local psa_keys = getIniSetting iniFile "RecentPSA"
		local psa_dirs = for i in psa_keys collect getIniSetting iniFile "RecentPSA" i
		ddl_dir_psa.items = psa_dirs
		if ddl_dir_psa.items.count != 0 do
		(
			local num = (getIniSetting iniFile "settings" "LastSelPSA") as integer
			if num != 0 do ddl_dir_psa.selection = num
		)
	)
	
	fn fillListViewINI =
  	(
		lva.items.Clear()
		if lvf.SelectedItems.Count == 0 do return false
		
		local sel_item  = lvf.SelectedItems.Item[ 0 ] 
		local fbx_f = sel_item.tag
		--local p = getFilenamePath fbx_f
		--local f = getFilenameFile fbx_f
		--local ini_f = p+f+".ini"
		local ini_f = fbx_f+".ini"

		if not doesFileExist ini_f do return false
		
		local anims = getIniSetting ini_f 
		if anims.count == 0 do return false
		
		local list_items = #()
		for a in anims do 
		( 
			local li = dotNetObject "ListViewItem" a
			li.checked = if (getIniSetting ini_f a "Export") == "0" then false else true
			li.tag = a
			append list_items li 
		)
		lva.Items.AddRange list_items -- and then put them there
		lva.items.item[ 0 ].selected = true --select first item
	)
	
	fn fillListViewFBX =
  	(
		lvf.items.Clear()
		
		local source_path = ddl_dir_fbx.items[ddl_dir_fbx.selection] + "\\"
		local fbx_files = getFiles ( source_path + "*.fbx" )
		if fbx_files.count == 0 do return false
		
		local files_names = #()
		local list_items = #()
		
		for f in fbx_files do 
		( 
			local file_name = getFilenameFile f
			files_names += #(file_name)
			local li = dotNetObject "ListViewItem" file_name
			li.tag = f
			append list_items li 
		)
		lvf.Items.AddRange list_items -- and then put them there
		lvf.items.item[ 0 ].selected = true --select first item
	)
	
	fn fillPresets = 
	(
		local f_array = getfiles (presets_path+"*.fbximportpreset")
		if f_array.count == 0 
		then ddl_presets.items = #("undefined")
		else ddl_presets.items = for f in f_array collect (getFileNameFile f)
	)
	
	fn loadSettings =
	(
		lvf.BeginUpdate()
		lva.BeginUpdate()
		
		lvf.BorderStyle = lvf.BorderStyle.FixedSingle
		lvf.BackColor = netDrColor winColor
		lvf.ForeColor = netDrColor textColor
		lvf.CheckBoxes = true
		lvf.MultiSelect = false
		lvf.HideSelection=false
		lvf.LabelEdit = false
		lvf.LabelWrap = false
		lvf.sorting = lvf.sorting.ascending
		lvf.view = lvf.view.Details
		lvf.HeaderStyle = lvf.HeaderStyle.None
		lvf.Columns.add "" 180
		
		lva.BorderStyle = lva.BorderStyle.FixedSingle
		lva.BackColor = netDrColor winColor
		lva.ForeColor = netDrColor textColor
		lva.CheckBoxes = true
		lva.MultiSelect = false
		lva.HideSelection=false
		lva.LabelEdit = false
		lva.LabelWrap = false
		lva.sorting = lva.sorting.none
		lva.view = lva.view.Details
		lva.HeaderStyle = lva.HeaderStyle.None
		lva.Columns.add "" 180
		
		lvf.EndUpdate()
		lva.EndUpdate()
		lvf.Refresh()		
		lva.Refresh()
		
		getRecentDirs()
		if ddl_dir_fbx.items.count != 0 do 
		(
			fillListViewFBX()
			fillListViewINI()
			fillPresets()
		)
		
		--mark last selected preset
		local current_preset = execute (getIniSetting iniFile "settings" "LastSelPreset")
		if classOf current_preset == integer do ddl_presets.selection = current_preset
	)
	
	fn listViewFBXControll s a method:#MouseUp =
	(
		if lvf.SelectedItems.Count == 0 do return false
		local sel_item  = lvf.SelectedItems.Item[ 0 ] 
		
		if a.Button.ToString() == "Left" do case method of
		(
			#KeyUp:()
			#MouseUp: fillListViewINI()
			#DoubleClick:()
		)
	)
	
	fn listViewINIControll s a method:#MouseUp =
	(
		if a.Button.ToString() == "Left" do case method of
		(
			#MouseDown: mark_anims_enabled = false
			#MouseUp  : mark_anims_enabled = true
		)
	)
	
	fn markAnimItem s a =
	(
		if not mark_anims_enabled do return false
		--print a.Item.index
		local sel_item  = lvf.SelectedItems.Item[ 0 ] 
		local fbx_f = sel_item.tag
		local ini_f = fbx_f+".ini"
		local val = if a.Item.Checked then "1" else "0"
		setIniSetting ini_f a.Item.text "Export" val
	)
	
	fn saveSettings =
	(
		if ddl_dir_fbx.selection != undefined do setIniSetting iniFile "settings" "LastSelFBX" (ddl_dir_fbx.selection as string)
		if ddl_dir_psa.selection != undefined do setIniSetting iniFile "settings" "LastSelPSA" (ddl_dir_psa.selection as string)
		if ddl_presets.selection != undefined do setIniSetting iniFile "settings" "LastSelPreset" (ddl_presets.selection as string)
	)
	
	fn fbxImport file index mode:#noPrompt =
	(
		resetMaxFile #noPrompt
		FrameRate = 25 --set to PAL
		if not doesFileExist file do return false

		local preset_name = ddl_presets.selected		
		if  preset_name == "undefined"
		then -- automatic settings
		(
			FbxImporterSetParam "Mode" "create" -- Add to new scene
			FbxImporterSetParam "Skin" true
			FbxImporterSetParam "SkinModifier"  "skin"
			FbxImporterSetParam "Cameras" false
			FbxImporterSetParam "Lights" false
			FbxImporterSetParam "Animation" true
			FBXImporterSetParam "FillTimeline" true
		)
		else -- user settings
		(
			local preset_file = presets_path + preset_name + ".fbximportpreset"
			format "FBX_Importer_Presset:%\t validated:%\n" preset_name (doesFileExist preset_file)
			FbxImporterSetParam "LoadImportPresetFile" preset_file
		)
		
		FbxImporterSetParam "TakeIndex" index --Animation Take

		importFile file mode using:FBXIMP
		CompleteRedraw()
	)
	
	fn collectBones =
	(
		for n in bone_names where (local b = getNodeByName ( n + "_" + edt_Suffix.text ) ) != undefined collect b
	)
	
	fn renameBones bone_array = --odmaze posledni podtrzitko a cisilko
	(
		for i in bone_array do 
		(
			local old_name = filterstring i.name "_"
			if old_name.count > 1 do
			(
				--format "old_name:%\n" old_name
				local new_name = ""
				for n=1 to (old_name.count-1) do new_name += old_name[n] + (if n < old_name.count-1 then "_" else "")
				--format "new_name:%\n" new_name
				i.name = new_name
			)
		)
	)

	fn addDir type:#fbx =
	(
		local itm
		case type of
		(
			#fbx:itm = if ddl_dir_fbx.items.count != 0 do ddl_dir_fbx.items[ddl_dir_fbx.selection]
			#psa:itm = if ddl_dir_psa.items.count != 0 do ddl_dir_psa.items[ddl_dir_psa.selection]
		)

		local dir = if itm == undefined then maxfilepath else itm
		local path  = getSavePath caption:" Chose Dir..." initialDir:dir
		if path != undefined do 
		(
			local dirs
			case type of
			(
				#fbx:
				(
					dirs = ddl_dir_fbx.items
					dirs += #(path)
					ddl_dir_fbx.items = dirs
					ddl_dir_fbx.selection = findItem dirs path
					fillListViewFBX()
					fillListViewINI()
				)
				#psa:
				(
					dirs = ddl_dir_psa.items
					dirs += #(path)
					ddl_dir_psa.items = dirs
					ddl_dir_psa.selection = findItem dirs path
				)
			)
			--save RecentFBX list to ini file
			if doesFileExist iniFile do for i=1 to dirs.count do 
			(
				case type of
				(
					#fbx:setIniSetting iniFile "RecentFBX" (i as string) dirs[i]
					#psa:setIniSetting iniFile "RecentPSA" (i as string) dirs[i]
				)
			)
		)
	)
	fn batch =
	(
		if ddl_dir_fbx.items.count == 0 do return false
		
		local source_path = ddl_dir_fbx.items[ddl_dir_fbx.selection] + "\\"
		local target_path = ddl_dir_psa.items[ddl_dir_psa.selection] + "\\"
		
		if not doesFileExist source_path or not doesFileExist target_path do return false
		
		--local fbx_files = for i = 1 to lvf.items.count where lvf.items.item[ i - 1 ].checked collect lvf.items.item[ i - 1 ].tag
		--if fbx_files.count == 0 do (messageBox "Files Not Checked..." title:" Micra!" ; return false)
		local fbx_files = for i = 1 to lvf.items.count collect lvf.items.item[ i - 1 ].tag
				
		--File Process
		if checkForSave() != false do -- first time check for unsaved work
		(
			/*
			------------------------------------------ 
			--inicialize FBX importer dialog and Close -- dont works because exporter is lol
			(
				t.interval = 1000
				
				fn closeDialogFBXImporter = --closeDialog "FBX Import"
				(
					print tick
					tick += 1
					if tick > 1 do
					(
						local ace = UIAccessor.GetPopupDialogs()
						for i in ace where findString (UIAccessor.GetWindowText i) "FBX Import" != undefined do 
						(
							--UIAccessor.CloseDialog i
							UIAccessor.PressButtonByName i "Cancel"
							exit
						)
						t.stop()
						print "0"
					)
				)
				print "1"
				dotnet.addEventHandler t "tick" closeDialogFBXImporter
				t.start()
			)
			*/
			ImportFile fbx_files[1]
			--closeDialogByWindowText "FBX Import"-- dont works because exporter is in modal state lol :-D
			--inicialize FBX importer dialog and Close
			-------------------------------------------
			
			for f = 1 to fbx_files.count do --Files loop
			(
				if not lvf.items.item[ f - 1 ].checked do continue
				
				--Manual Break Point 
				if keyboard.escPressed do ( exit ; return false )
				
				--local anims_count = FBXImporterGetParam "TakeCount" fbx_files[f]

				---!!! select fbx file and load anim set !!!
				lvf.Items.Item[ f - 1 ].selected = true
				fillListViewINI()
				
				format "File:%\t anims_count:%\n" (fileNameFromPath fbx_files[f]) lva.items.count
				
				for i = 1 to lva.items.count do --Anims loop
				(
					--Manual Break Point 
					if keyboard.escPressed do ( exit ; return false )
					--Ignore Anim if Not Checked
					if not lva.items.item[ i - 1 ].checked do continue
					
					------------------------------
					-- Importing FBX by Collada --
					------------------------------
					format "Importing Animation:%\tname:%\n" i lva.items.item[ i - 1 ].text
					fbxImport fbx_files[f] i
					
					--Clearing Scene
					max unhide all
					local bone_array = collectBones()
					if bone_array.count == 0 do 
					(
						MessageBox ("Skeleton Set: ROOT_"+edt_Suffix.text+" Not Found!") title:"Micra"
						return false
					)
					select bone_array
					max select invert
					delete selection
					
					--Rename Bones
					renameBones bone_array
					
					max select all
					
					-----------------------------
					-- Exporting PSA by ActorX --
					-----------------------------
					
					AX.setoutputpath target_path
					--Time config
					timeDisplayMode = #frames --set to Frames
					--Get Time Range
					--local start_frame = animationRange.start.frame
					--local end_frame = animationRange.end.frame					
					
					local ini_file = fbx_files[f]+".ini"
					--print ini_file
					if not doesFileExist ini_file do (format "missing ini file:%\n" ini_file; return false)
					local ini_head = lva.items.item[ i - 1 ].text
					--print ini_head
					local start_frame = execute (getIniSetting ini_file ini_head "Start")
					local end_frame   = execute (getIniSetting ini_file ini_head "Stop") 
					
					format "start_frame:%\tend_frame:%\n" start_frame end_frame
					--print (classOf start_frame)
					if classOf start_frame != Integer or classOf end_frame != Integer do (print "frames not found!"; return false)
					sliderTime = start_frame
					
					local anim_sequence_name = ini_head
					--inputSequenceName inStartFrame inEndFrame optionalForcedRate
					AX.digestanim anim_sequence_name start_frame end_frame 25
				)
				
				--Export Animation
				local newAnimFilename = getFilenameFile fbx_files[f]
				AX.exportanimset newAnimFilename --export and clearing digested anim list
			)
		)
	)
	on FBXtoPSABatchConverterDialog open do
	(
		if checkIniFile() then (loadSettings()) else (destroyDialog FBXtoPSABatchConverterDialog)
	)
	on FBXtoPSABatchConverterDialog close do (saveSettings())
	on btn_batch pressed do batch()
	on btn_dir_fbx pressed do addDir type:#fbx
	on btn_dir_psa pressed do addDir type:#psa
	on ddl_dir_fbx selected sel do (fillListViewFBX(); fillListViewINI())
	on lvf MouseUp s a do (listViewFBXControll s a method:#MouseUp)
	on lva MouseUp s a do (listViewINIControll s a method:#MouseUp)
	on lva MouseDown s a do (listViewINIControll s a method:#MouseDown)
	on lva ItemChecked s a do markAnimItem s a
)
createDialog FBXtoPSABatchConverterDialog


/*
start_frame = animationRange.start.frame
end_frame = animationRange.end.frame
anim_sequence_name = "b"
AX.digestanim anim_sequence_name start_frame end_frame 25
*/
