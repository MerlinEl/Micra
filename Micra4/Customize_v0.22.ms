--Customize Micra
Global mcGM
Global mcCustomizeDialog --mcCustomizeDialog

-->Micra Interface
if ::mcCustomizeDialog != undefined do try(mcCustomizeDialog.close())catch()
(
-->Locals-----------------------------------------------------------------
local last_profile = execute (mcFile.saveLoadIniSetings head:"Interface" key:"lastprofile" action:#load)
local profiles = #("DefaultColor", "UserColor", "ForestColor", "EarthColor", "MoonColor", "SeaColor", "SunColor", "Close")
local head_str = profiles[last_profile]
local bar_height      = 14
local form_bounds     = 2
local form_offset     = 4 --border line
local btn_size        = 24
local form_width       = 240
local form_height       = 420
local form_default_width = 224 --? don't know why but this is the default size (maybe form min max?)
local form_edit_width = 400
local cp_width        = 48
local debug = 1
-->Components---------------------------------------------------------------------
--local form = dotNetObject "Form" 
local form = dotNetObject "MaxCustomControls.Maxform"
struct TAB1_COMPONENTS_STRUCT ( created = false, combo_box, list_view, edt_info, lbl_sizer, selected_item = undefined )
struct TAB2_COMPONENTS_STRUCT ( created = false, checkboxes = #() , buttons = #(), labels = #(), titles = #() )
struct TAB3_COMPONENTS_STRUCT ( created = false, about_items = #(), pic_box)
struct MICRA_COMPONENTS_STRUCT
(
	--variables
	lblT    = dotNetObject "label" ,
	ToolTip = dotnetobject "ToolTip",
	btnMin  = dotNetObject  "button",
	tlp_main     = dotNetObject "TableLayoutPanel",
	tlp_edit = dotNetObject "TableLayoutPanel",
	tab     = dotNetObject "TableLayoutPanel",
	tab_buttons = #(),
	tab_1 = TAB1_COMPONENTS_STRUCT(),
	tab_2 = TAB2_COMPONENTS_STRUCT(),
	tab_3 = TAB3_COMPONENTS_STRUCT(),
	netDMove = false, 
	netDmPos,
	edit_mode = false
	--interface
)

form.tag = dotNetMXSValue (MICRA_COMPONENTS_STRUCT()) --store structure here for events use

--|	--Form move
fn onLblTMouseMove s a = 
(
	local form = s.parent
	if form.tag.value.netDMove do --dragForm
	(
		mcDialog.snapForm form form.tag.value.netDmPos
	)
)
fn onLblTMouseDown s a = 
(
	if a.Button == a.Button.left do --enableDrag
	(
		local form = s.parent
		form.cursor.current = netCursors.Hand
		form.tag.value.netDmPos = [form.MousePosition.x, form.MousePosition.y] - [form.left, form.top] 
		form.tag.value.netDMove = true 
	)
)
fn onLblTMouseUp s a = 
(
	local form = s.parent
	form.tag.value.netDMove = false --disableDrag
	if a.Button == a.Button.right then form.hide()
)
--||
--| Edit Mode Functions
fn getInterfaceComponent component_name = (
	
	--format "getInterfaceComponent > %\n" component_name
	if form == undefined do return false
	local toolbar_edit = form.controls.Item("toolbar_edit")
	local mcs = form.tag.value
	return case component_name of (

		"icon_index": toolbar_edit.controls.Item("edt_icon_index")
		"action_cmd": toolbar_edit.controls.Item("cmd_act")
		"catalog_name": toolbar_edit.controls.Item("name_cat")
		"action_name": toolbar_edit.controls.Item("name_act")
		"category_list": mcs.tab_1.combo_box
		--"action": mcs.tab_1.list_view.items.item -- (mcs.tab_1.list_view.SelectedItems.Item(0)).tag
		"help_text": mcs.tab.controls.Item("edt_info")
		"default":undefined
	)
)
fn getEditorData component_name = ( --get data from editor panel

	local item = getInterfaceComponent component_name
	--format "getEditorData > item:% text:%\n" item item.text
	return if item != undefined then item.text else undefined
)
fn setEditorData component_name str = ( --set data to editor panel

	local item = getInterfaceComponent component_name
	if item != undefined do item.text = str
)
fn addNewCatalog = (

	if not doesFileExist Micra.ActionsIni do return false
	local action_category = getEditorData "catalog_name"
	local item_array = getIniSetting Micra.ActionsIni
	local exists = (findItem item_array action_category) != 0
	format "addNewCatalog > name:%  exists:%\n " action_category exists
	if not exists then (
	
		setIniSetting Micra.ActionsIni action_category "del_key" "del_val" --create head and item
		delIniSetting Micra.ActionsIni action_category "del_key" --delete item leave head
		--reload customize
		mcCustomizeDialog.close()
		Micra.fileInVersion "Customize"
	) else (
	
		mcPopUp.msgBox "Category already exists. Operation Aborted."
	)
)
fn delCurrentCatalog = (


	if not doesFileExist Micra.ActionsIni do return false
	local mcs = form.tag.value
	if mcs.tab_1.list_view.items.count > 0 do (
		
		mcPopUp.msgBox "Category must be empty. Operation Aborted."
		return false
	)
	local action_category = getEditorData "catalog_name"
	if hasINISetting Micra.ActionsIni action_category do(
	
		format "delCurrentCatalog > name:%\n " action_category
		delIniSetting Micra.ActionsIni action_category --delete head
		--reload customize
		mcCustomizeDialog.close()
		Micra.fileInVersion "Customize"
	) 
)
fn addNewAction = (

	--get action params 
	local action_category = getEditorData "catalog_name"
	local action_name = getEditorData "action_name"
	local action_cmd = getEditorData "action_cmd"
	local icon_index = getEditorData "icon_index"
	if action_category.count == 0 or action_name.count == 0 or action_cmd.count == 0 or icon_index.count == 0 do return false
	--save action in Action.ini
--Gallery_3D = #(221, "Micra.fileInVersion \"3DGallery\"","3D Gallery")
--Align              = #(63, "max align","Align")
--Align_By_2Edges    = #(198,"mcAction.objectAlignByTwoEdges()", "Align By 2Edges")
	local action_key		= mcString.replaceSpaces action_name "_" 
	local action_data		= icon_index + ", " + action_cmd + ", " + action_name
	/*
		fix double qoutes
		fa=  "Micra.fileInVersion \"3DGallery\""
		ind1 = findString fa "\""
		fa   = replace fa  ind1 1 "\'"
		ind1 = findString fa "\""
		fa   = replace fa  ind1 1 "\'"
		execute fa
	*/
	format "addNewAction > catalog:% action:% action_data:%\n " action_category action_key action_data
	--setIniSetting Micra.ActionsIni action_category action_key action_data --create head and item
)
fn delCurrentAction = (
	
	local action_name = getEditorData "action_name"
	format "delCurrentAction > name:%\n " action_name
)
fn saveAction = (
	
	format "saveAction > todo\n" 
	return false --- TODO
	/*
	local btn = mcGM.getParam "active_button"
	if btn == undefined do return false
	local action_category = btn.name
	local action_name = btn.tag
	if action_category == undefined or action_name == undefined do return false
	--save comment	
	local help_txt = edt_description.text
	setIniSetting Micra.ActionsHelpIni action_category action_name help_txt
	--save icon index
	
	--save function name or filein name
	
	format "saveAction > category:% action:% comment:%\n" action_category action_name help_txt*/
)
fn editAction = (

	local action_name = getEditorData "action_name"
	if action_name == undefined do return false
	mcSystem.showActionSource action_name
)
fn editIcon = (

	local action_category = getEditorData "category_list"
	local action_name = getEditorData "action_name"
	if action_category == undefined or action_name == undefined do return false
	mcGM.setParam "active_icon_index" (mcFile.getIniDataFromArray Micra.ActionsIni action_category action_name 1)
	Micra.fileInVersion "Icon_Maker"
)
fn getItemIndex list item_name = (

	return (for i = 1 to list.items.count where list.items[i] == item_name collect i)[1]
)
fn clearCurrentActionData = (

	setEditorData "help_text" ""
	local mcs  = form.tag.value
	if not mcs.edit_mode do return false
	local action_category =  mcs.tab_1.combo_box.SelectedItem
	if action_category == undefined do return false
	setEditorData "icon_index" 	"0"
	setEditorData "action_cmd" 	"mcAction.doSomething() or Micra.fileInVersion \"Lode_Tester\""
	setEditorData "catalog_name" action_category
	setEditorData "action_name" 	"Action Name"
)
fn fillCurrentActionData form = (
format "fill\n"
	if form == undefined do return false
	local mcs  = form.tag.value
	local action_category =  mcs.tab_1.combo_box.SelectedItem
	if action_category == undefined do return false
	if mcs.tab_1.list_view.SelectedItems.count == 0 do (
	
		clearCurrentActionData()
		return OK
	)
	local action_name = (mcs.tab_1.list_view.SelectedItems.Item(0)).tag
	if debug == 1 do format "fillCurrentActionData > action_cat:% action_name:% edit_mode:%\n" action_category action_name mcs.edit_mode
		
	--load action info
	local help_txt = getIniSetting Micra.ActionsHelpIni action_category action_name
	setEditorData "help_text" help_txt
	
	if not mcs.edit_mode do return OK

	if debug == 1 do format "Reading functions data...\n"

	--load rest action data
	local data = mcSystem.getActionData action_category action_name --{cat:Animation, name:Reverse_Animation, icon:106, cmd:mcAnimation.reverse 0 10}
	if data != undefined do (

		setEditorData "icon_index" 	(data.get "icon"	)
		setEditorData "action_cmd" 	(data.get "cmd"	)
		setEditorData "catalog_name" 	(action_category)
		setEditorData "action_name" 	(action_name	)
	)
)
fn editModeSwitch state = (

	local mcs = form.tag.value
	if state then (
		
		mcs.edit_mode = true
		mcs.btnMin.text = "-"
		fillCurrentActionData form
		mcCustomizeDialog.width = form_edit_width
		
	) else (
	
		mcs.edit_mode = false
		mcs.btnMin.text = "+"
		mcCustomizeDialog.width = form_default_width
		
	)
)
fn onBtnMinMouseUp s a = ( editModeSwitch (s.text == "+")	 )
--||

fn getImageList head keys =
(
	img_list = dotNetObject "ImageList"
	img_list.ImageSize = netDrSize [btn_size, btn_size]
	img_list.ColorDepth = img_list.ColorDepth.Depth24Bit
	img_list.transparentColor = netDrColor black --212 212 212 --gray color
	
	for i in keys do
	(
		local icon_num = mcFile.getIniDataFromArray Micra.ActionsIni head i 1
		img_list.images.add (getIconDotNet icon_num)
	)
	return img_list
)
fn loadCatalogs list_cat = (

	if not doesFileExist Micra.ActionsIni do return false
	if debug == 1 do print "loadCatalogs > loading catalogs..."
	local item_array = getIniSetting Micra.ActionsIni
	list_cat.Items.clear()
	list_cat.Items.AddRange (dotNetArray item_array)
	list_cat.SelectedIndex = 1 --select first
)

fn loadActionList list_cat list_act = (

	if not doesFileExist Micra.ActionsIni or list_act.SelectedIndex == -1 do return false
	if debug == 1 do print "loadActionList > loading actions..."	
	list_cat.BeginUpdate()
	list_cat.items.Clear()
	local item_array = getIniSetting Micra.ActionsIni list_act.SelectedItem
	if item_array.count == 0 do ( --clear data
	
		fillCurrentActionData form
		list_cat.Items.AddRange #() 
		list_cat.EndUpdate()
		list_cat.Refresh()
		return false
	)
	list_cat.SmallImageList = getImageList list_act.SelectedItem item_array
	local list_items = #()
	for i = 1 to item_array.count do 
	( 
		local item_text = mcString.replaceCharInString (copy item_array[i]) "_" " "
		local itm = dotNetObject "ListViewItem" item_text
		itm.tag = item_array[i]
		itm.name = list_act.SelectedItem
		itm.ImageIndex = i-1
		append list_items itm
	)
	list_cat.Items.AddRange list_items 
	list_cat.items.item[ 1 ].selected = true --select first.items.item[ 1 ].selected = true --select first
	list_cat.EndUpdate()
	list_cat.Refresh()
)

--| Action Buttons Mouse Handlers
fn onMousedown s a = --click or drag (s = sender a = arguments)
(
	local btn_a = (s.HitTest a.location).Item
	if btn_a == undefined do return false
	local mcsA = s.parent.parent.tag.value --form tag struct
	
	--format "button pressed:%\n" a.Button
	case a.Button.ToString() of
	(
		"Left": --DragAndDrop 
		(			
			local btn_b
			
			local btn_a_image = (s.SmallImageList.Images.item (btn_a.ImageIndex))

			if btn_a_image != undefined do 
			(
				--format "Customize > onMousedown > Drag Start > s:% a%:\n" s a
				
				-- this actually starts the drag and drop process
				-- simultaneously copy dnd_id to clipboard
				local dnd_id = "Micra Form DragAndDrop" --define dropable place
				s.DoDragDrop (netString dnd_id) netDragDropEffect.copy -- (modal)
				
				--final dragAndDrop sequence
				btn_b = mcGM.getParam "form_drop_data"
				if btn_b != undefined then 
				(
					local mcsB = btn_b.parent.parent.tag.value
					mcsB.ToolTip.SetToolTip btn_b btn_a.text --copy tooltip
					btn_b.Image = btn_a_image --copy image
					btn_b.Tag = btn_a.tag --copy tag
					--save Settings
					local icn_numA = (mcFile.getIniDataFromArray Micra.ActionsIni btn_a.name btn_a.tag 1) as string
					setINISetting Micra.TempProfileIni "Buttons" btn_b.name btn_b.tag
					setINISetting Micra.TempProfileIni "Icons"   btn_b.name icn_numA 
				)
				mcGM.setParam "form_drop_data" undefined
				--format "Customize > onMousedown > Drag End > s:% a%:\n" s a
			)
		)
		"Middle":
		(
		)
		"Right": --RC Menu
		(

		)
	)
)
--|| 
--when category seected
fn onPickedBoxItem s a = (

	if debug == 1 do print "onPickedBoxItem > action category chossen..."
	local form = s.parent.parent
	local mcs  = form.tag.value
	loadActionList mcs.tab_1.list_view s
)
--when action chosen
fn onPickedListItem s a = (if s.parent != undefined do fillCurrentActionData s.parent.parent )
fn getRandomAboutImage =
(
	local images = getFiles (Micra.RootDir+"Img\\*.bmp")
	local abouts = for i in images where findString i "Micra_About" != undefined collect i
	if abouts.count == 0 do return undefined
	local fpath = abouts[random 1 abouts.count]
	local img_file = (dotNetClass "Drawing.Image").FromFile fpath --get the saved image from file as bitmap
	local w=img_file.width
	local h=img_file.height
	local img = (dotNetObject "Drawing.Bitmap" w h) --Create new bitmap object
	local gra  = (dotNetClass "Drawing.Graphics").fromImage img --Create new Graphics object
	local newRect = netDrRect [ 0, 0 ] [ w, h ]  --adjust icon offset X in button 
	gra.DrawImage img_file newRect 0 0 w h (dotNetClass "Drawing.GraphicsUnit").Pixel	
	img_file.dispose()
	return img
)
fn createMicraRunScript sFile =
(
	local f    = createFile sFile
	local data = "\n"
	data += "fn Micra.RootDir=\""+mcFile.filterPath (Micra.RootDir)+"\"\n"--data += "fn Micra.RootDir=\""+Micra.RootDir+"\"\n"
	data += "(\n"
	data += "\tlocal loader = \""+Micra.RootDir+"_Loader.ms\"\n"
	data += "\tif doesFileExist loader then\n"
	data += "\t(\n"
	data += "\t\tfileIn loader\n"
	data += "\t)\n"
	data += "\telse (messagebox (\"Micra4 loader is not found.\") title:\" Micra!\")\n"
	data += ")\n"
	--format "f:%\n" data 
	format data to:f
	close f
)
fn onCheckedCahnges s a =
(
	setINISetting Micra.UserSettings "Settings" s.tag (s.checked as string)
	
	case s.tag of
	(
		"Autorun":
		(
			--local sFile = (GetDir #startupScripts + "\\Micra_Autorun.ms")
			local sFile = (GetDir #userStartupScripts + "\\Micra_Autorun.ms")
			if doesFileExist sFile do deleteFile sFile
			if s.checked do createMicraRunScript sFile
		)
		"ShowFileName":
		(
			if s.checked
			then
			(
				unregisterRedrawViewsCallback mcCall.fileName_in_screen
				registerRedrawViewsCallback mcCall.fileName_in_screen 
			)
			else (unregisterRedrawViewsCallback mcCall.fileName_in_screen )
		)
		"UniversalCounter":
		(
			if s.checked
			then (Micra.fileInVersion "Uni_Poly_Counter")
			else (unregisterRedrawViewsCallback mcPolyCount.Count; mcPolyCount = undefined)
		)
		"UC_ShowSize":
		(
			if s.checked
			then()
			else()
		)
		"UseLargeVertexDots":
		(
			if s.checked
			then (preferences.useLargeVertexDots = true  )
			else (preferences.useLargeVertexDots = false )
		)
	)
	completeRedraw()
)
fn filterPath path = 
(
	local arr   = filterString path "\\/"
	local isDir = path[path.count-3] != "." -- example C:\temp.txt
	local newPath = ""
	for i=1 to arr.count do newPath += arr[i] + ( if isDir or i != arr.count then "/" else "")
	return newPath
)
fn treeCopy indir outdir move:false = --recursive call
(
	indir = filterPath indir
	outdir = filterPath outdir

	local files = getFiles (indir+"*.*")
	local dirs = getDirectories (indir+"*.*")
	
	for f in files do ( copyFile f (outdir+filenameFromPath f) )
	for d in dirs do 
	(              
		local filter_path = filterString d "\/"
		local new_dir = outdir+filter_path[filter_path.count]
		makedir new_dir
		treeCopy d new_dir
	)
)
fn delDirectoryContent dir includefiles:false quiet:true =
(
	dir = filterPath dir
	local files = getFiles (dir+"*.*")
	local dirs = getDirectories (dir+"*.*")

	for f in files do ( deleteFile f )
	for d in dirs do (DOSCommand ("RD \""+d+"\" /s /q") )  --/s  include files /q = qieit
)


fn onTab1ButtonClick s a = (

	--format "onTab1ButtonClick > btn:%\n" s.name
	case s.name of (
	
		"btn_cat_add": addNewCatalog()
		"btn_cat_del": delCurrentCatalog()
		"btn_act_add": addNewAction()
		"cmd_act_add": editAction()
		"btn_act_del": delCurrentAction()
		"btn_icn_edit": editIcon() 
		"btn_settings_save": saveAction()
	)
)
fn onTab2ButtonClick s a =
(
	case s.text of
	(
		"Interface Colors":Micra.fileInVersion "Customize_Colors"
		"Update Micra":
		(
			--get server file
			local server_dir = "r:\\Resources\\Resources_new\\Micra\\"--(getIniSetting Micra.DefaultSettings "Paths" "WorkServer")+"Micra\\"
			local server_file = server_dir + "Micra4.zip"
			local app_7z = "C:\\Windows\\System32\\7za.exe"
			local micra_folder = Micra.RootDir
			--OLD> local update_file = getDir #scripts+"\\Micra4.zip"
			local update_file = getDir #userScripts+"\\Micra4.zip"
			local backup_folder = substring micra_folder 1 (micra_folder.count-1) +"_Backup\\" --remove last slash and add _backup
			
			if not doesFileExist server_dir do (MessageBox "Server is not Accessible, try later..." title:" Micra:"; return false)
			if not doesFileExist server_file do (MessageBox "No updates found...." title:" Micra:"; return false)
			if not doesFileExist app_7z do copyFile (micra_folder+"App\\7za.exe") app_7z
			if not doesFileExist app_7z do return false
/*
			--check date and time
			if doesFileExist update_file then
			(
				if getFileModDate update_file == getFileModDate server_file 
				then (MessageBox "New updates not found...." title:" Micra:"; return false)       
				else deleteFile update_file
			)
*/				
			--download new update from server
			deleteFile update_file
			copyFile server_file update_file
			if not doesFileExist update_file do (MessageBox "Unable Download New Update...Installation Aborted" title:" Micra:"; return false)
			
			--backup old Micra folder to Micra_backup
			if not doesFileExist backup_folder then makeDir backup_folder else delDirectoryContent backup_folder
			if not doesFileExist backup_folder do (MessageBox "Unable Create Micra Backup. Installation Aborted" title:" Micra:"; return false)
			treeCopy micra_folder backup_folder
			local files = getFiles (backup_folder+"*.*")
			if files.count == 0 do  (MessageBox "Unable Create Micra Backup. Installation Aborted" title:" Micra:"; return false)
			
			--empty Micra folder
			delDirectoryContent micra_folder
			
			--extract new update in to empty micra folder
			local cmd = (app_7z + " x \"" +update_file+ "\" -o\""+micra_folder+"\"")
			DOSCommand cmd
			--restore user settings
			local user_folder = micra_folder+"User\\"
			local backup_user_folder =  backup_folder+"User\\"
			renameFile user_folder (substring user_folder 1 (user_folder.count-1)+ "_Default" )
			makeDir user_folder
			treeCopy backup_user_folder user_folder
			--Copy Micra_Macro.mcr to max  -- add version checker 
			if doesFileExist Micra.Macro do deleteFile Micra.Macro
			copyFile (Micra.RootDir+"Micra_Macro.mcr") Micra.Macro
			--format "bk2:%\tuser:%\n" backup_user_folder user_folder
			--restart Max
			MessageBox  "Update has ben Succesfull! Please restart the 3DsMax" title:" Micra:-)"
		)
	)
)
--INTERFACE INIT
fn addTab num mcs = (

	if debug == 1 do format "addTab > tab index:% \n" num
	--Remove All controls from Layout
	mcs.tab.Controls.Clear()
	
	--Fill layout by components of chossen type
	case num of(
		--actions interface
		1: (
		
			--Create Interface Components---------------------------------------------------------------------
			if not mcs.tab_1.created do(
			
				mcs.tab_1.combo_box           = dotNetObject "comboBox"
				mcs.tab_1.combo_box.size      = netDrSize [mcs.tab.width - form_offset, 0]
				mcs.tab_1.combo_box.BackColor = mcDotnet.uiColor #back
				mcs.tab_1.combo_box.Forecolor = mcDotnet.uiColor #text
				mcs.tab_1.combo_box.Sorted    = true
				mcs.tab_1.combo_box.DropDownStyle = mcs.tab_1.combo_box.DropDownStyle.DropDown --DropDownList --DropDown--Simple
				mcs.tab_1.combo_box.FlatStyle = mcs.tab_1.combo_box.FlatStyle.flat
				mcs.tab_1.combo_box.MaxDropDownItems = 22
				mcs.tab_1.combo_box.margin    =  dotnetobject "padding" 2
				
				mcs.tab_1.list_view           = dotNetObject "listView"
				mcs.tab_1.list_view.size      = netDrSize [mcs.tab.width - form_offset, mcs.tab.height - btn_size*4 - bar_height - form_offset*2]
				mcs.tab_1.list_view.BackColor = mcDotnet.uiColor #back
				mcs.tab_1.list_view.Forecolor = mcDotnet.uiColor #text
				mcs.tab_1.list_view.Sorting   = mcs.tab_1.list_view.Sorting.Ascending
				mcs.tab_1.list_view.margin    = dotnetobject "padding" 2
				mcs.tab_1.list_view.MultiSelect = false
				mcs.tab_1.list_view.HideSelection=false
				mcs.tab_1.list_view.LabelEdit = false
				mcs.tab_1.list_view.LabelWrap = false
				mcs.tab_1.list_view.allowDrop = true -- required in order to implement DotNet drag and drop functionality
				mcs.tab_1.list_view.view = mcs.tab_1.list_view.view.Details
				mcs.tab_1.list_view.BorderStyle = mcs.tab_1.list_view.BorderStyle.FixedSingle
				mcs.tab_1.list_view.HeaderStyle = mcs.tab_1.list_view.HeaderStyle.None
				mcs.tab_1.list_view.Columns.add "" 180
				
				mcs.tab_1.edt_info           = dotNetObject "textBox"
				mcs.tab_1.edt_info.name		 = "edt_info"
				mcs.tab_1.edt_info.Multiline = true
				--mcs.tab_1.edt_info.ReadOnly = true --not allow to write
				mcs.tab_1.edt_info.size      = netDrSize [mcs.tab.width - form_offset, btn_size*3 + form_offset/2]
				mcs.tab_1.edt_info.BackColor = mcDotnet.uiColor #back
				mcs.tab_1.edt_info.ForeColor = mcDotnet.uiColor #text
				mcs.tab_1.edt_info.text      = "Info Panel"
				mcs.tab_1.edt_info.margin    =  dotnetobject "padding" 2 
				mcs.tab_1.edt_info.BorderStyle = mcs.tab_1.edt_info.BorderStyle.FixedSingle
				--mcs.tab_1.edt_info.TextAlign = mcs.tab_1.edt_info.TextAlign.MiddleCenter
				--mcs.tab_1.edt_info.text = "Info Panel"
				
				mcs.tab_1.lbl_sizer           = dotNetObject "label"
				mcs.tab_1.lbl_sizer.size      = netDrSize [mcs.tab.width - form_offset, bar_height/2]
				mcs.tab_1.lbl_sizer.BackColor = mcDotnet.uiColor #fore
				mcs.tab_1.lbl_sizer.ForeColor = mcDotnet.uiColor #text
				mcs.tab_1.lbl_sizer.text      = "v"--"Drag here to resize window"
				mcs.tab_1.lbl_sizer.margin    =  dotnetobject "padding" 2 
				mcs.tab_1.lbl_sizer.TextAlign = mcs.tab_1.lbl_sizer.TextAlign.MiddleCenter
				
				dotNet.addEventHandler mcs.tab_1.list_view "ItemSelectionChanged" onPickedListItem --show help text when action selected (also in edit mode fill all properties)
				dotNet.addEventHandler mcs.tab_1.list_view "MouseDown" onMousedown --manage mouse click (left, middle, right, drag and drop)
				dotNet.addEventHandler mcs.tab_1.combo_box "SelectedIndexChanged" onPickedBoxItem --change action category
				
				--Initialize Actions Property Components---------------------------------------------------------------------
				local edit_font = dotnetobject "System.Drawing.Font" "Verdana" 10 (dotnetclass "System.Drawing.FontStyle").bold
				local keys = #(
					mcItem "lbl" "Category:" "lbl_category", mcItem "edt" "" "name_cat", mcItem "btn" "Add Category" "btn_cat_add", mcItem "btn" "Del Category" "btn_cat_del", 
					mcItem "lbl" "Action:" "lbl_act", mcItem "edt" "" "name_act", mcItem "edt" "" "cmd_act", mcItem "btn" "Add Action" "btn_act_add", mcItem "btn" "Edit Action" "cmd_act_add", mcItem "btn" "Del Action" "btn_act_del",
					mcItem "lbl" "Icon:" "lbl_icn_num", mcItem "edt" "" "edt_icon_index", mcItem "btn" "Edit Icon" "btn_icn_edit",
					mcItem "lbl" "Settings:" "btn_settings", mcItem "btn" "Save" "btn_settings_save"
				)

				local components = #()
				for i = 1 to keys.count do (
					
					local item_type = keys[i].key
					local item_text = keys[i].val
					local item_name = keys[i].tag
					local item_size = netDrSize [mcs.tlp_edit.width - form_offset, btn_size] --item.size = netDrSize [mcs.tlp_edit.width/2 - form_offset, btn_size]
					local item = case item_type of (
					
						"btn":(
							format "register button:%\n" item_name
							item_size.height = 26
							item = dotNetObject "button"
							item.BackColor = mcDotnet.uiColor #back
							item.ForeColor = mcDotnet.uiColor #text
							dotNet.addeventhandler item "Click" onTab1ButtonClick
							--dotNet.setLifetimeControl item #dotnet
							item
						)
						"lbl":(
						
							item_size.height = bar_height + 2
							item = dotNetObject "label"
							item.TextAlign = (dotnetClass "system.Drawing.ContentAlignment").MiddleCenter
							item.BackColor = netDrColor (mcUIColors.get #back)
							item.ForeColor = netDrColor (mcUIColors.get #edtfore)
					
							item --case return
						)
						"edt": (
						
							item = dotNetObject "textBox"
							item.BorderStyle = item.BorderStyle.FixedSingle
							item.TextAlign = (dotnetClass "System.Windows.Forms.HorizontalAlignment").Center
							--item.BackColor = netDrColor (color 18 171 226)
							--item.ForeColor = netDrColor white
							item.BackColor = netDrColor (mcUIColors.get #edtback)
							item.ForeColor = netDrColor (mcUIColors.get #edtfore)	
							item.Font = edit_font
							item --case return
						)
					)
					
					item.name = item_name
					item.text = item_text
					item.size = item_size
					item.margin  =  dotnetobject "padding" 2
					components += #(item)
				)
				--add components
				mcs.tlp_edit.Controls.addRange components
				mcs.tab_1.created = true
				if debug == 1 do print "addTab > Actions components created. "
			)
			
			--Add Interface Components To Layout---------------------------------------------------------------------
			if debug == 1 do print "addTab > Actions components aded. "
			mcs.tab.Controls.addRange #(mcs.tab_1.combo_box, mcs.tab_1.list_view, mcs.tab_1.edt_info, mcs.tab_1.lbl_sizer)
			
			--Initialize Interface Components---------------------------------------------------------------------
			loadCatalogs mcs.tab_1.combo_box

			--TODO when is caled from Micra dialog, then open at edit mode
			--if in edit mode extend panel size
			--local action_mode = mcGM.getParam "action_editor_switch"
			--if debug == 1 do format "addTab > action mode:%\n" action_mode
			--if action_mode == "edit" or action_mode == "create" do (
			--	editModeSwitch true
				--in edit mode select action_category and action_item
			--)
		)
		--settings interface
		2: (
		
			editModeSwitch false --restore from edit mode
			--Create Interface Components---------------------------------------------------------------------
			if not mcs.tab_2.created do (
	
				local keys = #("Autorun", "Filename in Screen", "Universal Counter", "UC_ShowSize", "Use Large Vertex Dots")
				local tags = #("Autorun", "ShowFileName", "UniversalCounter", "UC_ShowSize", "UseLargeVertexDots")

				for i = 1 to keys.count do --functionality
				(
					--checkboxes = #() , buttons = #()"Check for Updates"
					local cb = dotNetObject "checkBox"
					cb.text = keys[i]
					cb.tag = tags[i]
					cb.size = netDrSize [mcs.tab.width - form_offset, bar_height]
					cb.margin  =  dotnetobject "padding" 2
					cb.BackColor = mcDotnet.uiColor #back
					cb.ForeColor = mcDotnet.uiColor #text
					dotNet.addEventHandler cb "MouseUp" onCheckedCahnges
					mcs.tab_2.checkboxes += #(cb)
				)
				keys = #( "Interface Colors", "Update Micra")
				for i = 1 to keys.count do --updates
				(
					local b = dotNetObject "button"
					b.text = keys[i]
					b.size = netDrSize [mcs.tab.width - form_offset, btn_size]
					b.margin  =  dotnetobject "padding" 2
					b.BackColor = mcDotnet.uiColor #back
					b.ForeColor = mcDotnet.uiColor #text
					dotNet.addeventhandler b "Click" onTab2ButtonClick
					mcs.tab_2.buttons += #(b)
				)
				
				keys = #("Functionality:", "Visual Style:", "Updates:")
				for i = 1 to keys.count do --titles
				(
					local lbl = dotNetObject "label"
					lbl.text = keys[i]
					--lbl.BorderStyle = lbl.BorderStyle.FixedSingle
					lbl.size = netDrSize [mcs.tab.width - form_offset, bar_height]
					lbl.margin  =  dotnetobject "padding" 2
					lbl.BackColor = mcDotnet.uiColor #text
					lbl.ForeColor = mcDotnet.uiColor #back
					mcs.tab_2.titles += #(lbl)
				)
				mcs.tab_2.created = true
				if debug == 1 do print "addTab > Settings components created. "
			)
			
			--Initialize Interface Components---------------------------------------------------------------------
			for i in mcs.tab_2.checkboxes do 
			(
				state = execute (getIniSetting Micra.UserSettings "Settings" i.tag)
				if state != undefined do i.Checked = state
			)
			
			--Add Interface Components To Layout---------------------------------------------------------------------
			if debug == 1 do print "addTab > Settings components aded. "
			mcs.tab.Controls.addRange (#(mcs.tab_2.titles[1]) + mcs.tab_2.checkboxes + #(mcs.tab_2.titles[2]) + #(mcs.tab_2.buttons[1]) + #(mcs.tab_2.titles[3]) + #(mcs.tab_2.buttons[2]))
		)
		--about interface
		3: ( 
		
			editModeSwitch false --restore from edit mode
			--Create Interface Components---------------------------------------------------------------------
			if not mcs.tab_3.created do (

				Local MicraBorn = "04.05/2006"
				Local LastUpdate = "31.06/2012"

				local titles = #
				(
					"For my Friends...", 
					"*** Micra III ***",  
					"\******** ^-^ ********/", 
					"Thanks to:", 
					"Bobo, Zadr, Dunik, Tom, Alcado, Fero, Leo, Milki, Mr.Oringe, Lubik, Radek, Honzik, DenisT, PEN, Macro Bruneta....",
					"Created by: Merlin El' ©\n"+MicraBorn+" - "+LastUpdate
				)
				for i = 1 to titles.count do
				(
					if i == 3 do --ad a picture
					(
						local pb = dotnetobject "picturebox"
						pb.size = netDrSize [212, 140]
						pb.margin   =  dotnetobject "padding" 2
						pb.Left = mcs.tab.width/2
						--pb.backColor = netDrColor yellow
						pb.BorderStyle = pb.BorderStyle.FixedSingle
						mcs.tab_3.about_items += #(pb)
					)

					local lbl = dotNetObject "label"
					--lbl.AutoSize = true
					lbl.TextAlign = lbl.TextAlign.MiddleCenter
					lbl.width = mcs.tab.width - form_offset*2
					local rows = (((gw.getTextExtent titles[i]).x/140) as integer)
					lbl.height = if rows > 0 then rows*22 else 22
					lbl.margin   =  dotnetobject "padding" 2 
					lbl.MaximumSize.height = mcs.tab.width - form_offset*2
					lbl.ForeColor = mcDotnet.uiColor #text
					lbl.text = titles[i]
					mcs.tab_3.about_items += #(lbl)
				)
				mcs.tab_3.created = true
				if debug == 1 do print "addTab > About components created. "
			)
			
			--Initialize Interface Components---------------------------------------------------------------------
			if debug == 1 do print "addTab > About components aded. "
			mcs.tab_3.about_items[3].BackgroundImage = getRandomAboutImage()
			
			--Add Interface Components To Layout---------------------------------------------------------------------
			mcs.tab.Controls.addRange mcs.tab_3.about_items
		)
	)
)
fn checkTheButton b = (
	
	local mcs = b.parent.parent.tag.value
	b.BackColor = mcDotnet.uiColor #fore
	b.Forecolor = mcDotnet.uiColor #back --green--
	for i in mcs.tab_buttons where not i.Equals b do 
	(
		i.BackColor = undefined 
		i.Forecolor = mcDotnet.uiColor #text
	)
)
fn switchTabTo s a = (
	
	checkTheButton s
	local tab_struct = s.parent.parent.tag.value
	addTab s.tag tab_struct
)
fn addTabButtons mcs = (
	
	local tab_text_array = #("Actions", "Settings", "About")
	for i = 1 to tab_text_array.count do
	(
		local b = dotNetObject "Button"
		b.size  = netDrSize [btn_size*3, btn_size]
		b.FlatStyle = b.FlatStyle.flat
		b.FlatAppearance.BorderColor = mcDotnet.uiColor #back		
		b.Forecolor = mcDotnet.uiColor #text
		b.FlatAppearance.BorderSize = 1
		b.margin =  dotnetobject "padding" 0
		b.name = "btn_"+((i as integer) as string)
		b.text = tab_text_array[i]
		b.tag = i
		mcs.toolTip.SetToolTip b b.text
		dotNet.addEventHandler b "MouseUp" switchTabTo
		mcs.tab_buttons += #(b)
	)
	mcs.tlp_main.controls.addRange (mcs.tab_buttons)
)

fn onFormVisibilityChanged s a = (

	case s.visible of (
	
		true:(
			--print "customize shown"
			
		)
		false:(
		
			--print "customize hide"
			mcFile.saveIniDialog s.name "Properties_2"
			mcGM.setParam "action_editor_switch" undefined
			editModeSwitch false --restore form width to normal
		)
	)
)

fn onFormCreated s a = ( --only when created, not open
	
	--print "customize created"
	switchTabTo s.tag.value.tab_buttons[1] a --activate first tab
	s.BackColor = mcDotnet.uiColor #fore
)

fn inicializeInterface form mcs =
(
	form.name = "mcCustomizeDialog"
	form.ControlBox  = false --hide main bar
	local fpos = (mcFile.getIniDataFromArray Micra.TempProfileIni "Properties_2" "mcCustomizeDialog" 2)
	if fpos == undefined do fpos = (mcFile.getIniDataFromArray Micra.DefaultProfileIni "Properties_2" "mcCustomizeDialog" 2)
	form.StartPosition = form.StartPosition.Manual
	form.bounds = netDrRect fpos [form_width, form_height]
	form.FormBorderStyle = form.FormBorderStyle.none
	form.BackColor = mcDotnet.uiColor #fore --yellow
	form.ShowInTaskbar = false
	form.opacity = mcUIColors.get #opacity
	
	mcs.lblT.bounds = netDrRect [form_offset/2, form_offset/2] [form_width - form_offset*5 , bar_height]
	mcs.lblT.BackColor = mcDotnet.uiColor #back
	mcs.lblT.ForeColor = mcDotnet.uiColor #text
	local version = " v" + (Micra.getScriptVersion "Customize") --add cript version
	mcs.lblT.Text = "Customize:" +(if version != undefined then version else "")
	
	mcs.btnMin.bounds = netDrRect [form_width - 42, form_offset/2] [btn_size, bar_height]
	mcs.btnMin.FlatStyle = mcs.btnMin.FlatStyle.flat
	mcs.btnMin.BackColor = mcDotnet.uiColor #btn --(color 124 196 22)
	mcs.btnMin.ForeColor = netDrColor (mcUIColors.get #text)
	mcs.btnMin.text = "+"
	
	--add default layout panel
	mcs.tlp_main.bounds = netDrRect [form_offset/2, bar_height+form_offset] [form_width - form_offset*5, btn_size]
	mcs.tlp_main.backColor = mcDotnet.uiColor #btn
	mcs.tlp_main.ColumnCount = 3
	
	--add edit layout panel
	mcs.tlp_edit.name = "toolbar_edit"
	mcs.tlp_edit.bounds = netDrRect [form_offset + mcs.tlp_main.width, form_offset/2]  [form_edit_width - mcs.tlp_main.width - form_offset*1.5, form_height - form_offset*5]
	mcs.tlp_edit.backColor = netDrColor #8183b3
	--mcs.tlp_edit.ColumnCount = 2
	
	mcs.tab.bounds = netDrRect [form_offset/2, bar_height*2+form_offset*4] [form_width - form_offset*5, form_height - bar_height - btn_size - form_offset*6]
	mcs.tab.backColor = mcDotnet.uiColor #btn --yellow --

	--add handlers
	dotNet.addEventHandler mcs.lblT   "MouseMove" onLblTMouseMove
	dotNet.addEventHandler mcs.lblT   "MouseDown" onLblTMouseDown 
	dotNet.addEventHandler mcs.lblT   "MouseUp"   onLblTMouseUp
	dotNet.addEventHandler mcs.btnMin "MouseClick"  onBtnMinMouseUp
	dotnet.addEventHandler form "Shown" onFormCreated
	dotnet.addEventHandler form "VisibleChanged" onFormVisibilityChanged
	
	--add controls
	addTabButtons mcs
	form.controls.addRange( #(mcs.btnMin, mcs.lblT, mcs.tlp_main, mcs.tab, mcs.tlp_edit) )
)
inicializeInterface form form.tag.value
mcCustomizeDialog = form
mcDotnet.dShow mcCustomizeDialog
)