
try (destroyDialog unnamedRollout) catch()
rollout unnamedRollout "Untitled" width:672 height:372
(
	local maxIniFile = (getDir #maxData) + "3dsmax.ini"
	local bgColor   = ((colorMan.getColor #background)*255)as color
	local winColor  = ((colorMan.getColor #window)*255)as color
	local textColor = ((colorMan.getColor #text)*255)as color
	dotNetControl lv_heads "listView" pos:[8,20] width:148 height:320
	dotNetControl lv_keys  "listView" pos:[156,20] width:508 height:320
	GroupBox grp1 "3DsMax [Directories]" pos:[4,4] width:664 height:340
	button btn_close "Close" pos:[600,348] width:68 height:20
	button btn_dir "Dir..." pos:[4,348] width:68 height:20
	fn fillTreeViews = 
	(
		if not doesFileExist maxIniFile do return false
		local heads = GetINISetting maxIniFile "Directories"
		
		local list_heads = #()
		for h in heads do 
		( 
			local h = dotNetObject "ListViewItem" h
			h.tag = key
			
			append list_heads h
		)
		lv_heads.Items.AddRange list_heads -- and then put them there
		lv_heads.items.item[ 0 ].selected = true --select first item
		
		local list_keys = #()
		for h = 0 to lv_heads.items.count-1 do
		(
			local key = GetINISetting maxIniFile "Directories" lv_heads.items.item[ h ].text
			local k = dotNetObject "ListViewItem" key
			k.tag = key
			append list_keys k
		)
		lv_keys.Items.AddRange list_keys -- and then put them there
		lv_keys.items.item[ 0 ].selected = true --select first item

		return true
	)
	fn initInterface =
	(
		lv_heads.BeginUpdate()
		lv_keys.BeginUpdate()
		
			lv_heads.BackColor= netDrColor winColor
			lv_heads.ForeColor= netDrColor textColor
			lv_heads.MultiSelect = false
			lv_heads.HideSelection=false
			lv_heads.LabelWrap = false
			lv_heads.sorting = lv_heads.sorting.ascending
			lv_heads.view = lv_heads.view.Details
			lv_heads.HeaderStyle = lv_heads.HeaderStyle.None
			lv_heads.Columns.add "" 180
			
			lv_keys.BackColor= netDrColor winColor
			lv_keys.ForeColor= netDrColor textColor
			lv_keys.MultiSelect = false
			lv_keys.HideSelection=false
			lv_keys.LabelWrap = false
			--lv_keys.sorting = lv_keys.sorting.ascending
			lv_keys.view = lv_keys.view.Details
			lv_keys.HeaderStyle = lv_keys.HeaderStyle.None
			lv_keys.Columns.add "" 600
			
		lv_heads.EndUpdate()
		lv_heads.Refresh()
		lv_keys.EndUpdate()
		lv_keys.Refresh()
		fillTreeViews()
		--mc2System.show lv_heads
		ok
	)
	on unnamedRollout open do initInterface()
	on lv_heads MouseUp s a do --SelectedIndexChanged s a do
	(
		if s.SelectedItems.count !=0 do
		(
			itm = s.SelectedItems.item[0]
			num = s.SelectedIndices.item[0]
			lv_keys.items.item[ num ].selected = true
			ht = (s.HitTest a.location)
			format "item:%\n" ht.Item.text
			--th.SubItem
		)
	)
	--on lv_heads MouseDoubleClick s a do
	--on lv_heads MouseClick s a do
			--mc2System.show s
	on lv_keys selected sel do
	(
	
	)
	on lv_keys doubleClicked sel do
	(
	
	)
	on btn_close pressed  do (destroyDialog unnamedRollout)
	on btn_dir pressed  do
	(
	
	)
)
createDialog  unnamedRollout style:#(#system_style)





-- Killing the dialog box if it exists
try(destroyDialog KRMU_myRollout); catch()

rollout KRMU_myRollout "my Rollout" width:271 height:199
(
     -- ************* LOCALS **************
     -- ***********************************    

     -- *************** UI ****************
     -- ***********************************
     -- Listview dotNet control 
     dotNetControl myListview "System.Windows.Forms.ListView" pos:[1,0] width:268 height:198 enabled:true
     
     -- *********** FUNCTIONS *************
     -- ***********************************
     
     -- ********** UI HANDLERS ************
     -- ***********************************    
     on KRMU_myRollout open do
     (
         --  Listview Group            
         local listViewGroup1 = dotNetObject "System.Windows.Forms.ListViewGroup" "Group 01" (dotNetClass "System.Windows.Forms.HorizontalAlignment").Left
         
         -- Listview item
         local listViewItem1 = dotNetObject "System.Windows.Forms.ListViewItem" "item 01"
         
         -- Listview setup
         listViewGroup1.header = "Group 01"
         listViewGroup1.name = "Group 01"
         myListview.Groups.addRange #(listViewGroup1) -- Could just use groups.add but this is how c# does it        
         listViewItem1.Group = listViewGroup1        
         myListview.Items.addRange #(listViewItem1) -- Could just use items.add but this is how c# does it
         
         myListview.Name = "myListview"
         myListview.UseCompatibleStateImageBehavior = false
         myListview.View = (dotNetClass "System.Windows.Forms.View").SmallIcon
         
     )
 )

 -- ************** MAIN ***************
 -- ***********************************
 -- create the rollout window and add the  rollout
 CreateDialog KRMU_myRollout

/*
[MAXHistoryList]
[FileList]
[CustomMenus]
[BitmapDirs]

GetINISetting "c:/3dsmax6/3dsmax.ini" "Directories" "Scenes"
setINISetting "c:/3dsmax6/3dsmax.ini" "Directories" "Scenes" "c:/3dsmax/scenes"
delIniSetting <filename_string> <section_string> <key_string> --Deletes the specified key from the supplied section of the given INI file.
delIniSetting <filename_string> <section_string>  --Deletes the section and all keys in the section of the given INI file.

PlaneMap = getOpenFileName caption:"Select Map"  \ 
filename:maxfilepath \
types:"Targa (*.tga)|*.tga|Jpeg (*.jpg)|*.jpg|Tiff (*.tif)|*.tif|All (*.*)|*.*|"


rollout unnamedRollout "Untitled" width:460 height:28
(
	dropDownList ddl "" pos:[4,4] width:344 height:21
	button btn_add "+" pos:[352,4] width:20 height:20
	button btn_del "-" pos:[372,4] width:20 height:20
	button btn_set "set" pos:[396,4] width:40 height:20
	button btn_close "x" pos:[440,4] width:16 height:20
	fn loadList = 
	(
		ddl.items = #
		(
			sysInfo.currentdir,
			"C:\\Kuju-Work\\Silent Hill",
			"C:\\In-Out",
			"C:\\Program Files\\Autodesk\\3ds Max 9"
		)
	)
	on unnamedRollout open do (loadList())
	on ddl1 selected sel do
	(
	
	)
	on btn_add pressed  do
	(
	
	)
	on btn_set pressed  do
	(
		sysInfo.currentdir = ddl.selected
	)
	

)
*/



	dotNetControl listbox "ListView" pos:[8,20] width:864 height:408
	
	
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
		dnNewColumn = listbox.Columns.add ("Enabled:") 60
		dnNewColumn = listbox.Columns.add ("Model Name:") 200
		dnNewColumn = listbox.Columns.add ("Max File Path:") 600
		listbox.refresh()
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
		setINISetting ini_file head key val
		--format "head:%\t key:%\t val:%\n" head key val
	)
	on listbox ItemCheck s a do (if check_enabled do updateIniChecks s a)