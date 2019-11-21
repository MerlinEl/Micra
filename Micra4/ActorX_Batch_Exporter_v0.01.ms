
--------------------------------------------------------------------------
---                ActorX Batch Exporter:                               ---
--------------------------------------------------------------------------
Global mcActorXBatchExporterDialog


if mcActorXBatchExporterDialog != undefined do destroyDialog mcActorXBatchExporterDialog
rollout mcActorXBatchExporterDialog "ActorX Batch Exporter:" width:880 height:548
(
	local settings_file, check_enabled = false
	GroupBox grp1 "List:" pos:[4,4] width:872 height:540
	edittext edt_model_name "Model Name   :" pos:[12,436] width:860 height:20
	edittext edt_max_file_path "Max File Path :" pos:[12,460] width:860 height:20
	button btn_add "Add Item" pos:[8,484] width:132 height:28
	dotNetControl listbox "ListView" pos:[8,20] width:864 height:408
	button btn_del "Delete Item" pos:[280,484] width:132 height:28
	button btn_export "EXPORT" pos:[552,484] width:320 height:28
	progressBar pb_export "ProgressBar" pos:[8,520] width:864 height:16
	--button btn_get_sel "< Get Selected" pos:[780,436] width:92 height:20
	--button btn_get_path "< Get From Max" pos:[780,460] width:92 height:20
	button btn_replace "Rplace Item" pos:[144,484] width:132 height:28
	button btn_add_sel "Add Selection" pos:[416,484] width:132 height:28
	fn addItemInList listbox mname fpath enabled =
	(
		local itm = dotNetObject "ListViewItem"
		itm.checked = enabled
		itm.SubItems.add mname
		itm.SubItems.add fpath
		listbox.Items.Add itm
	)
	fn fnInitDotNetView listbox =
	(
		listbox.gridLines  = true
		listbox.fullRowSelect = true
		listbox.MultiSelect = true
		listbox.View  = (dotNetClass "System.Windows.Forms.View").Details
		listbox.ShowItemToolTips  = true
		listbox.HideSelection = false
		listbox.CheckBoxes = true
		--mcSystem.getObjectInfo  listbox
		--mcSystem.getObjectInfo listbox.Container--.ItemContainerStyle --using a Setter for IsSelected
		dnNewColumn = listbox.Columns.add ("Enabled:") 60
		dnNewColumn = listbox.Columns.add ("Model Name:") 200
		dnNewColumn = listbox.Columns.add ("Max File Path:") 600
		listbox.refresh()
	)
	fn collectItemsFromIni=
	(
		if not doesFileExist settings_file do return false
		local ini_heads = getINISetting settings_file
		for h in ini_heads do 
		(
			local ini_keys = getINISetting settings_file h
			for k in ini_keys do
			(
				local val =execute (getINISetting settings_file h k)
				addItemInList listbox h k val
			)
		)
	)
	fn inicializeInterface =
	(
		settings_file = Micra.UserDir+"ActorX_Batch_Exporter.ini"
		if not doesFileExist settings_file do createFile settings_file
		fnInitDotNetView ( listbox )
		collectItemsFromIni ()
		check_enabled = true
	)
	fn addItem=
	(
		local head = edt_model_name.text
		local key = edt_max_file_path.text
		local val = true
		if head == "" or key == "" do return false
		addItemInList listbox head key val
		setINISetting settings_file head key (val as string)
	)
	fn addItemsFromSelection=
	(
		local sel = selection as array
		if sel.count == 0 do return false
		local pth = maxFilePath+maxFileName
		if pth == "" do return false
		edt_max_file_path.text = pth
		for o in sel do
		(
			edt_model_name.text = o.name
			addItem()
		)
	)
	fn delItem=
	(
		local cnt = listbox.SelectedItems.count 
		if cnt > 1 do 
			if not queryBox ("Do you wish to remove "+cnt as string+"items?") title:"Remove?" do return false
		for i=listbox.SelectedItems.count-1 to 0 by -1  do
		(
			local itm = listbox.SelectedItems.item[ i ]
			local head = (itm.SubItems.item 1).text
			local key = (itm.SubItems.item 2).text
			delIniSetting settings_file head key --remove keys
			if (getINISetting settings_file head).count == 0 do delIniSetting settings_file head -- if no other keys to dele ,remove also head
			listbox.items.Remove itm
		)	
		if cnt > 1 do
		(
			local p = GetDialogPos mcActorXBatchExporterDialog
			destroyDialog mcActorXBatchExporterDialog
			createDialog mcActorXBatchExporterDialog pos:p
		)
	)
	fn updateIniChecks s a=
	(
		local itm = s.items.item a.Index
		local head = (itm.SubItems.item 1).text
		local key = (itm.SubItems.item 2).text
		local val = case a.CurrentValue.ToString() of
		(
			"Checked":"false"
			"Unchecked":"true"
		)
		setINISetting settings_file head key val
		--format "head:%\t key:%\t val:%\n" head key val
	)
	fn exportModels=
	(
		AX.setallskintype  1
		AX.setselectedgeometry 1
		AX.setbakesmoothing 1
		pb_export.value = 0
		pb_export.color = orange
		clearListener()
		for i=0 to listbox.items.count-1 do
		(
			local itm = listbox.items.item i
			if itm.checked != false do 
			(
				local model_name = (itm.SubItems.item 1).text
				local max_path =  (itm.SubItems.item 2).text
				loadMaxFile max_path quiet:true
		
				mcActorXBatchExporterDialog.title = "ActorX Batch Exporter: Expotring: " + model_name
				local obj = getNodeByName model_name
				local root = getNodeByName "Root"
			
				if obj != undefined then
				(
					--check also if morph data is presented in last map channel
					--add modifier if is missing
					if obj.modifiers[#Morph_UV_Data] == undefined do addModifier obj (Morph_UV_Data()) before:2
					--reset root dummy pos and rotation and export
					if root != undefined then
					(
						root.pos = [0,0,0]
						root.rotation = quat 0 0 0 0
						select obj
						AX.setoutputpath (getFilenamePath max_path)
						AX.exportmesh model_name --will be owerwriten
						format "model: [ % ] has ben exported to: %\n" model_name (getFilenamePath max_path)
					)
					else format "model: [ % ] errormsg: Expotr Failed! The base bone must be named: [  Root  ]" model_name 
				)
				else format "model: [ % ] errormsg: Name is incorect." model_name 
			)
			pb_export.value = 100.*(i+1) / listbox.items.count
		)
		mcActorXBatchExporterDialog.title = "ActorX Batch Exporter: Done! Check listener for more Information."
		actionMan.executeAction 0 "40472" -- Open the Listener
	)
	fn editItem s a =
	(
		if s.SelectedItems.count == 0 do return false
		local itm = s.SelectedItems.item[0]
		local head = (itm.SubItems.item 1).text
		local key = (itm.SubItems.item 2).text
		edt_model_name.text  =head
		edt_max_file_path.text =key
	)
	fn checkUncheckAllBoxes s=
	(
		if s.items.count == 0 do return false
		local first_enabled = s.items.item[0].checked
		for i=0 to s.items.count-1 do s.items.item[i].checked = not first_enabled
	)
	fn columnPressed s a=
	(
		case a.Column of
		(
			0:(checkUncheckAllBoxes s)
			1:()
			2:()
		)
	)
	fn replaceSelected=
	(
		if listbox.SelectedItems.count == 0 do return false
		local head = edt_model_name.text
		local key = edt_max_file_path.text
		local val = true
		if head == "" or key == "" do return false
			
		local itm = listbox.SelectedItems.item[0]
		local h = (itm.SubItems.item 1).text
		local k = (itm.SubItems.item 2).text
		delIniSetting settings_file h k --remove keys
		if (getINISetting settings_file h).count == 0 do delIniSetting settings_file h -- if no other keys to dele ,remove also head
		
		addItemInList listbox head key val
		setINISetting settings_file head key (val as string)
		listbox.clear()
		fnInitDotNetView ( listbox )
		collectItemsFromIni()
	)
	fn checkControll s a = ( for i=0 to s.items.count-1 do s.items.item[i].checked = s.items.item[i].selected )
	on btn_add pressed do (addItem())
	on btn_add_sel pressed do (addItemsFromSelection())
	on btn_del pressed do (delItem())
	on btn_export pressed do (exportModels())
	on btn_replace pressed do (replaceSelected())
	on listbox SelectedIndexChanged s a do (editItem s a)
	on listbox MouseUp s a do (checkControll s a)
	--on listbox ItemSelectionChanged s a do (checkControll s a)
	on listbox ItemCheck s a do (if check_enabled do updateIniChecks s a)
	on mcActorXBatchExporterDialog open do (inicializeInterface())
	--on btn_get_sel pressed do (if selection.count == 1 do 	edt_model_name.text = selection[1].name)
	--on btn_get_path pressed do (	edt_max_file_path.text = maxFilePath+maxFileName)
	on listbox ColumnClick s a do (columnPressed s a)--s.Columns.items
)
createDialog mcActorXBatchExporterDialog
--C:\Dev\D-Arms\Art\Characters\David\David_absorb_hand\Mesh\david ABSORB hand01.max