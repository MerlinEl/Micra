------------------
------------------
--                  --
--  3D Gallery --
--                  --
------------------
------------------
Global mcDgalleryDialog
Global mcTextBoxDialog
Global mcTextBoxText = ""
Global mcDgalleryRootDir = getINISetting mcUserINI "3DGallery" "Server_Dir" --getFilenamePath (getThisScriptFilename())
Global mcUserINI
--    Rene 2012    --
try ( mcDgalleryDialog.close() ) catch()
(
	-->Locals-----------------------------------------------------------------
	local last_profile = execute (mcFile.saveLoadIniSetings head:"Interface" key:"lastprofile" action:#load)
	local profiles = #("DefaultColor", "UserColor", "ForestColor", "EarthColor", "MoonColor", "SeaColor", "SunColor", "Close")
	local head_str = profiles[last_profile]
	local clr_back     = execute (mcFile.saveLoadIniSetings head:head_str key:"backcolor" action:#load)
	local clr_fore     = execute (mcFile.saveLoadIniSetings head:head_str key:"forecolor" action:#load)
	local clr_sel      = execute (mcFile.saveLoadIniSetings head:head_str key:"selected"  action:#load)
	local clr_mark     = execute (mcFile.saveLoadIniSetings head:head_str key:"marked"  action:#load)
	local clr_btn      = execute (mcFile.saveLoadIniSetings head:head_str key:"button"   action:#load)
	local clr_inact    = execute (mcFile.saveLoadIniSetings head:head_str key:"inactive"  action:#load)
	local clr_text     = execute (mcFile.saveLoadIniSetings head:head_str key:"textcolor"  action:#load)
	local clr_seltext  = execute (mcFile.saveLoadIniSetings head:head_str key:"seltext"  action:#load)
	local dnfontlarge = dotNetObject "Drawing.Font" "Verdana" 12 ((dotNetClass "System.Drawing.FontStyle").bold)
	local dnfont        = dotNetObject "System.Drawing.Font" "Verdana" 6.5 ((dotNetClass "System.Drawing.FontStyle").bold)	
	local cursors = dotNetClass "System.Windows.Forms.Cursors"
	local cursor = dotNetClass "System.Windows.Forms.Cursor"
	local cursor_harrow  = dotNetObject "System.Windows.Forms.Cursor" (mcImgPath+"harrow.ico")
	local cursor_hmove   = dotNetObject "System.Windows.Forms.Cursor" (mcImgPath+"hmove.ico")
	local cursor_hdrag  = dotNetObject "System.Windows.Forms.Cursor" (mcImgPath+"hdrag.ico")
	local form_opacity = 0.8--execute (mcFile.saveLoadIniSetings head:head_str key:"opacity"  action:#load)
	local bar_height      = 14
	local form_bounds     = 2
	local form_offset     = 2 --border line
	local border_size    = 16
	local btn_size        = 24--32
	local thumb_size = [160, 120]
	local cp_width        = 48
	local debug = 0
	--<
	
	-->Components---------------------------------------------------------------------
	local form = dotNetObject "MaxCustomControls.Maxform"
	--local form = dotNetObject "Form" 
	--<
	struct ICON_COMPONENTS_STRUCT
	(
		--variables
		ToolTip  = dotNetObject "ToolTip",
		flp_cat  = dotNetObject "flowlayoutpanel",
		progbar = dotNetObject "Progressbar",
		mnu_thumb = dotNetObject "ContextMenuStrip", mnu_items =#(),
		--tb        = dotNetObject "Tabcontrol",
		tb_models = dotNetObject "radiobutton",
		tb_textures = dotNetObject "radiobutton",
		tb_materials  = dotNetObject "radiobutton",
		lblT      = dotNetObject "label",
		lbl_find  = dotNetObject "label",
		lbl_logo = dotNetObject "label", 
		lbl_tools = dotNetObject "label", 
		lbl_paint = dotNetObject "label", 
		lbl_settings = dotNetObject "label", 
		lbl_maindir = dotNetObject "label", 
		lbl_subdir = dotNetObject "label", 
		lbl_progress = dotNetObject "label", 
		tlp_tools  = dotNetObject "TableLayoutPanel",
		tlp_paint  = dotNetObject "TableLayoutPanel",
		tlp_settings  = dotNetObject "TableLayoutPanel",
		ddlMainClass = dotNetObject "ComboBox",
		ddlSubClass = dotNetObject "ComboBox",
		search_bar = dotNetObject "TextBox",
		tools_buttons = #(), paint_buttons = #(), settings_buttons = #(), folder_buttons = #(),
		selected_thumbs = #(), all_thumbs = #(),
		helpFile = mcDgalleryRootDir+"\\3DGallery.doc",
		current_dir = "", lastMainCat="", lastSubCat="", gallery_type="Models",
		netDMove = false, netDmPos
	)

	form.tag = dotNetMXSValue (ICON_COMPONENTS_STRUCT()) --manual Lifetime	
	
--|	--Form move
	fn onLblTMouseMove s a = 
	(
		local form = s.parent
		if form.tag.value.netDMove do --dragForm
		(
			mcFormSnap form form.tag.value.netDmPos
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
	
--|	--Functions
	fn errorMsg num insert:"" = 
	(
		local msg = case num of
		(
			1:("Select a model to rename.")
			2:("Select some object to add.")
			3:("Create <Sub clas> catalog.")
			4:("Multiselection cant be renamed.")
			5:("Cant locate repository.")
			6:("Merging model:<" + insert + "> is failed.\nFile is mising or is corupted.")
			7:("Select one object, for replace.")
		)
		messageBox msg title:" 3DGallery II... Warning:"
	)
	fn getDialogCenter my_size =
	(
		local dPos  = [mcDgalleryDialog.location.x, mcDgalleryDialog.location.y] 
		local dSize =  [mcDgalleryDialog.width, mcDgalleryDialog.height]
		return (dPos + dSize/2 - my_size/2)
	)
	fn textBox pos:[0, 0] =
	(
		try (mcTextBoxDialog.close() ) catch()
		local form = dotNetObject "MaxCustomControls.Maxform"
		form.name = "mcTextBoxDialog"
		form.ControlBox  = false
		form.StartPosition = form.StartPosition.Manual
		form.FormBorderStyle = form.FormBorderStyle.none--SizableToolWindow--
		form.bounds = netDrRect pos [320, 30]
		form.BackColor = netDrColor clr_fore
		form.ShowInTaskbar = false
		form.opacity = form_opacity
	
		local edtBox = dotNetObject "textbox"
		edtBox.bounds = netDrRect [4,4] [312, 28]
		local dnfontlarge = dotNetObject "System.Drawing.Font" "Verdana" 14 ((dotNetClass "System.Drawing.FontStyle").bold)
		edtBox.font = dnfontlarge
		edtBox.BackColor= netDrColor clr_back
		edtBox.ForeColor= netDrColor yellow
		edtBox.AcceptsTab = true
		edtBox.Multiline = true
		--edtBox.focus()
		fn onOpenForm s a = (mcTextBoxText = ""; s.BackColor = netDrColor clr_fore)
		--fn changeBackcolor
		fn dupplicatedNamesheck s a =
		(
			/*
			local existingNames = (for i in (getFiles (Current_Dir+"*.*")) collect (getFilenameFile i)) --check for duplicate names
				if   (findItem existingNames theName) == 0 --check for duplicate names
				then (DestroyDialog mcTextBoxDialog)
				else (messagebox ("The name:<"+edtBox.text+"> is allready exist.") title:" 3D Gallery:" ; setFocus edtBox)
			*/
		)
		fn textBoxControll s a  =
		(
			print a.KeyValue
			local last_letter = s.text[s.text.count]
			if a.KeyValue == 13 then mcTextBoxDialog.close() --enter
			else if a.KeyValue == 27 then --Escape
			(
				mcTextBoxText = ""
				mcTextBoxDialog.close()
			)
			else if findItem #("/", "\"", "*", "?", "!") last_letter != 0 then
			(
				new_text = ""
				for i=1 to s.text.count-1 do new_text += s.text[i] --remove last letter
				local sta = s.SelectionStart
				local len = s.SelectionLength
                s.Text = new_text
                s.Select sta  len 
				mcTextBoxText = new_text
			)
			else mcTextBoxText = s.Text
		)
		dotnet.addEventHandler form "Shown" onOpenForm
		dotnet.addEventHandler edtBox "KeyUp" textBoxControll 
		form.controls.add edtBox
		mcTextBoxDialog = form
		mcTextBoxDialog.showModeless()
	)
	fn	getImage file_name =
	(
		local img = (dotNetClass "Drawing.Image").FromFile file_name --get the saved image from file as bitmap
		local img_clone = (dotNetObject "Drawing.Bitmap" img.width img.height) --Create new bitmap object
		local gra  = (dotNetClass "Drawing.Graphics").fromImage img_clone --Create new Graphics object
		gra.DrawImage img 0 0 img.width img.height -- (dotNetClass "Drawing.GraphicsUnit").Pixel
		img.dispose()
		gra.dispose()
		return img_clone
	)
	fn removeFromSelection s itm_name mcs =
	(
		for i=1 to mcs.selected_thumbs.count where mcs.selected_thumbs[i].text == itm_name do
		(
			deleteItem mcs.selected_thumbs i
			exit
		)
		mcs.lbl_progress.text = " " +mcs.selected_thumbs.count as string+"/"+ mcs.flp_cat.controls.count as string
		s.forecolor = netDrColor clr_fore
	)
	fn addToSelection s mcs =
	(
		append mcs.selected_thumbs s
		mcs.lbl_progress.text = " " +mcs.selected_thumbs.count as string+"/"+ mcs.flp_cat.controls.count as string
		s.forecolor = netDrColor red
	)
	fn selectAll mcs = 
	(
		mcs.selected_thumbs = #()
		for i=1 to mcs.flp_cat.controls.count do 
		(
			local itm = mcs.flp_cat.controls.item[i-1]
			mcs.selected_thumbs += #(itm)
			itm.forecolor = netDrColor red
		)
		mcs.lbl_progress.text = " "+mcs.selected_thumbs.count as string+"/"+ mcs.flp_cat.controls.count as string
	)
	fn clearSelectedItems mcs = 
	(
		mcs.selected_thumbs = #()
		for i=1 to mcs.flp_cat.controls.count do mcs.flp_cat.controls.item[i-1].forecolor = netDrColor clr_fore
		mcs.lbl_progress.text = " 0/"+ mcs.flp_cat.controls.count as string
	) 
	
fn renameModel mcs = ()
fn moveSelectedTo mcs =  ()
fn deleteFromGallery mcs = ()
	
	fn addTogallery mcs =
	(
		if selection.count == 0 do (errorMsg 2; return false)
		if mcs.lastSubCat == undefined do (errorMsg 3 ;return false)
		local name_from_box
		if keyboard.controlPressed 
		then  --replace selected thumbnail and model
		(
			if mcs.selected_thumbs.count != 1 then (errorMsg 7; return false)
			local thumb = mcs.selected_thumbs[1]
			name_from_box = thumb.name
		)
		else --add new model
		(
			local form_center = getDialogCenter [320, 30]
			format "form center:%\n" form_center
			name_from_box = textBox pos:form_center  
		)
		format "name from box:%\n" name_from_box
-----		
		/*
		
		if name_from_box == "" do return false
		--render selection 
		--format "current dir:%\n" current_dir
		local img_path = Current_Dir+name_from_box+".jpg"
		local max_path = Current_Dir+name_from_box+".max"
		local useIniFile   = (mcDgalleryRootDir+tb.selectedTab.text+"\\"+lastMainCat+".ini")
		renderModel img_path
		--save selection
		saveNodes selection max_path
		--security lock and user data
		if not doesFileExist useIniFile do
		(
			local f = createFile useIniFile
			close f
		)
		setINISetting useIniFile lastSubCat name_from_box (#(sysInfo.username,localTime) as string) 
		--reload , resort gallery
		loadGallery type:tb.SelectedIndex
		--mcsystem.show flp_cat
		--create a button and load thummbnail
		--flp_cat.controls.add (addImageToButton img_path)
		--flp_cat.Refresh().flp_cat.update().SuspendLayout().ResetBindings().ResetImeMode().Invalidate()
		*/
	)
	fn mergeModels mcs =
	(
		if mcs.selected_thumbs.count == 0 do return false
		mcs.progbar.foreColor = netDrColor clr_fore
		local merged_models = #()
		for i=1 to mcs.selected_thumbs.count do --undo "Merge Models" on
		(
			local f = mcs.Current_Dir+mcs.selected_thumbs[i].text+".max"
			if doesFileExist f do 
			(
				try   (mergeMAXFile f #useSceneMtlDups #mergeDups #select ) 
				catch (errorMsg 6 insert:mcs.selected_thumbs[i].text)
				--prevent dupplicate names in scene
				if not keyboard.controlPressed then (for o in selection do o.name = uniqueName (o.name))
			)
			mcs.progbar.value = 100.*i/mcs.selected_thumbs.count 
			merged_models += selection as array
			max select none
		)
		mcs.progbar.value = 0
		clearSelectedItems mcs
		select merged_models
	)
	fn onToolsMouseUp s a = 
	(
		local mcs = s.parent.parent.tag.value
		case s.tag of
		(
			"Add Model": (addTogallery mcs)
			"Delete Model": ()
			"Merge to Scene": (mergeModels mcs)
			"Rename Model": ()
			"Pick a surface for planting": ()
			"Plant Customize...": ()
			"Planting": ()
			"Multiplanting": ()
			"Customize...": ()
			"Help": ()
		)
	)
	fn generateButtons mcs names:#() images:#()=
	(
		local buttons = #()
		for i = 1 to names.count do
		(
			local b = dotNetObject "Button"
			b.size  = netDrSize [btn_size, btn_size]
			b.FlatStyle = b.FlatStyle.flat
			b.FlatAppearance.BorderColor = netDrColor clr_back		
			b.Forecolor = netDrColor clr_text
			b.FlatAppearance.BorderSize = 0
			b.margin =  dotnetobject "padding" 0
			b.name = "btn_"+((i as integer) as string)
			b.image = getIconDotNet images[i]
			b.tag = names[i]
			mcs.toolTip.SetToolTip b b.tag
			dotNet.addEventHandler b "MouseUp" onToolsMouseUp
			buttons += #(b)
		)
		return buttons
	)

	fn menuActions s a =
	(
		local mcs = s.tag.tag.value
		case s.name of
		(
			"Add To Scene": mergeModels mcs
			"Select All": selectAll mcs
			"Clear Selection": clearSelectedItems mcs
			"Rename": renameModel mcs
			"MoveTo": moveSelectedTo mcs
			"Delete": deleteFromGallery mcs
		)
	)
	fn onMouseDown s a =
    (
		local mcs = s.parent.parent.tag.value
		local itm_name = s.text
		if a.button == a.Button.right then --"Show RC Menu"
		(
			if s.forecolor != netDrColor red do addToSelection s mcs
			mcs.mnu_thumb.Show (s.PointToScreen (netDrPoint a.location))	
		)
		else if s.forecolor == netDrColor red 
		then removeFromSelection s itm_name mcs
		else addToSelection s mcs
    )  
	fn onMouseEnter s a  =(if s.forecolor != netDrColor red do s.forecolor = netDrColor yellow)
	fn onMouseLeave s a =(if s.forecolor != netDrColor red do s.forecolor = netDrColor clr_fore)

	/*
	fn getActiveTab mcs =
	(
		if mcs.tb_models.Checked then return "Models"
		else if mcs.tb_textures.Checked then return "Textures"
		else if mcs.tb_materials.Checked do return "Materials"
	)
	*/
	fn getLastDirFrom path =
	(
		local arr = ( filterString path "\\" )
		return arr[arr.count]
	)
	fn loadImageInMemory img_path =
	(
		local img_file = dotNetObject "Drawing.Bitmap" img_path
		local new_img    = dotNetObject "Drawing.Bitmap" img_file.width img_file.height --Create new bitmap object
		local g  = (dotNetClass "Drawing.Graphics").fromImage new_img --Create new Graphics object
		g.DrawImage img_file 0 0 img_file.width img_file.height
		img_file.Dispose()
		g.dispose()
		return new_img
	)
	fn createThumbnailButton img_path num =
	(
		local img_btn = dotnetobject "button"
		img_btn.size = netDrSize thumb_size --160 120
		--img_btn.backcolor = colorclass.yellow --cadetblue -- tag color
		img_btn.forecolor = netDrColor clr_fore --text color
		img_btn.margin =  dotnetobject "padding" 2 -- thumbs distance
		img_btn.flatstyle = (dotNetclass "FlatStyle").flat
		img_btn.FlatAppearance.BorderSize = 2
		img_btn.font= dnfont
		img_btn.text = getFilenameFile img_path	
		img_btn.name = "thumb_"+num as string
		img_btn.tag  = img_path
		img_btn.textalign =  (dotnetclass "Drawing.ContentAlignment").BottomCenter
		img_btn.backgroundImageLayout = img_btn.backgroundImageLayout.stretch
		img_btn.BackgroundImage = loadImageInMemory img_path
--img_btn.showTooltip -- WIP	
		-- Setup an event handlers for both buttons
		dotnet.addEventHandler img_btn "MouseDown" onMouseDown
		dotnet.addEventHandler img_btn "MouseEnter" onMouseEnter
		dotnet.addEventHandler img_btn "MouseLeave" onMouseLeave
		return img_btn
	)
	fn loadGallery mcs type:"Models" = --type = tab controll state
	(
		mcs.selected_thumbs = #()
		mcs.flp_cat.controls.clear()
		gc()
		mcs.Current_Dir = mcDgalleryRootDir+mcs.gallery_type+"\\"+mcs.lastMainCat+"\\"+mcs.lastSubCat+"\\"
		setINISetting mcUserINI "3DGallery" "Current_Dir" mcs.Current_Dir 
		--format "Current_Dir:%\n" Current_Dir
		if not doesFileExist mcs.Current_Dir do return false
		local Images_Array = getFiles (mcs.Current_Dir + "*.jpg")
		--change cursor to wait
		cursor.current = cursors.WaitCursor
		mcs.progbar.foreColor = netDrColor (color 8 200 248)
		mcs.all_thumbs = #()
		
		case type of -- WIP
		(
			"Models":(print "Loading... Models")
			"Textures":(print "Loading... Materials" )
			"Materials":(print "Loading...  Textures")
		)
		
		for i=1 to Images_Array.count do
		(
			append mcs.all_thumbs (createThumbnailButton Images_Array[i] i)
			mcs.progbar.value = 100.*i/Images_Array.count 
			mcs.lbl_progress.text = " 0/"+ i as string
			mcs.lbl_progress.update()
		)
		mcs.flp_cat.controls.addrange mcs.all_thumbs
		cursor.current = cursors.Arrow
		mcs.progbar.value = 0
	)
	fn loadMainCat mcs = --remember main dir where you browse last time
	(
		local mainDirs = sort (getDirectories (mcDgalleryRootDir+mcs.gallery_type+"\\*.*"))
		if mainDirs.count == 0 do return false
		mcs.ddlMainClass.Items.addRange (for i in mainDirs collect (getLastDirFrom i))--get the last dir from path
		--last main cat
		mcs.lastMainCat = getINISetting mcUserINI "3DGallery" "lastMainCat"
		local num = mcs.ddlMainClass.findString mcs.lastMainCat
		if num  != -1
		then (mcs.ddlMainClass.SelectedIndex = num)
		else (mcs.ddlMainClass.SelectedIndex = 0; mcs.lastMainCat = mcs.ddlMainClass.items.item[0])
		return true
	)
	fn loadSubCat mcs = --remember sub dir where you browse last time
	(
		mcs.ddlSubClass.items.Clear()
		local subDirs = sort( getDirectories (mcDgalleryRootDir+mcs.gallery_type+"\\"+mcs.lastMainCat+"\\*.*") )
		if subDirs.count == 0 do return false
		mcs.ddlSubClass.Items.addRange (for i in subDirs collect (getLastDirFrom i))--get the last dir from path	
		--last sub cat
		mcs.lastSubCat = getINISetting mcUserINI "3DGallery" "lastSubCat"
		local num = mcs.ddlSubClass.findString mcs.lastSubCat
		if num  != -1	
		then (mcs.ddlSubClass.SelectedIndex = num)
		else (mcs.ddlSubClass.SelectedIndex = 0 ; mcs.lastSubCat = mcs.ddlSubClass.items.item[0])
		return true
	)
	fn loadInterface form = 
	(
		local mcs = form.tag.value
		if not doesFileExist mcDgalleryRootDir do (errorMsg 5; return false) -- server dir not found
		mcs.lblT.Text = " << 3DGallery II >> Dir: "+ mcDgalleryRootDir + "..."
		loadMainCat mcs
		mcs.search_bar.focus()
	)
	fn mainClassSelectionChanged s a =
	( 
		--format "main item:%\n" s.SelectedItem
		local mcs = s.parent.tag.value
		if s.SelectedItem != "" do
		(
			setINISetting mcUserINI "3DGallery" "lastMainCat" s.SelectedItem
			mcs.lastMainCat = s.SelectedItem
			loadSubCat mcs
		)
	)
	fn subClassSelectionChanged s a =
	(
		--format "sub item:%\n" s.SelectedItem
		local mcs = s.parent.tag.value
		mcs.search_bar.text = ""
		if sel != 0 do
		(
			setINISetting mcUserINI "3DGallery" "lastSubCat" s.SelectedItem
			mcs.lastSubCat = s.SelectedItem
			loadGallery mcs type:s.SelectedItem
			--mcs.flp_cat.update()
			--mcs.flp_cat.refresh()
		)
	)
	fn findItemByName items str ignoreCase:true = 
  	(
		local tempAry = #()
		local pat = str + "*"
		for i in items do if matchPattern i.text pattern:pat do append tempAry i --made by Akram
		tempAry
	)
	fn filterThumbnails s a =
	(	
		local mcs = s.parent.tag.value
--clear selection or find way how to check if  selected items  is present after filtering
		clearSelectedItems mcs
--clear selection or find way how to check if  selected items  is present after filtering
		local found = findItemByName mcs.all_thumbs s.text
		if found.count != 0 do
		(
			mcs.flp_cat.controls.clear()
			mcs.flp_cat.controls.addrange found
			mcs.lbl_progress.text = " 0/"+ mcs.flp_cat.controls.count as string
		)
	)
--||		
	
--|	--Form actions	
	fn onOpenForm s a = (loadInterface s)
	fn onCloseForm s a = (mcFile.saveIniDialog s "Properties_2" s.name)
	fn changeBackcolor s a = (s.backColor = netDrColor clr_fore)
	fn getFormPos s a = (format "pos:%\n" [a.x, a.y] )--get position in form , for interface adjusting
	fn rezizeInterface s a = 
	(
		local mcs = s.tag.value
		local size =  [s.width, s.height] 
		mcs.lblT.width = s.width - 20
		mcs.progbar.width = s.width - 50 - 40 - 20
		mcs.progbar.location.y = s.height - 29
		mcs.lbl_progress.location.y = s.height - 29
		mcs.tlp_settings.height = s.height - 212 - 20
		mcs.flp_cat.size = netDrSize [s.width - 50 - 20, s.height - 50 - 30 - 20]
	)
	fn onLblDoubleClick s a = 
	(	
		s.parent.location = netDrPoint [0, 0]
		local maxsize = (getMAXWindowSize()-20)
		if maxsize == [s.parent.width, s.parent.height]  --if is fullscreen
		then 
		(
			s.parent.size = netDrSize [748, 608] 
			s.parent.location = netDrPoint (maxsize/2 - [754, 608]/2)
		)
		else 
		(
			s.parent.size = netDrSize maxsize
		)
	)
--||
	
	fn inicializeInterface form mcs =
	(
		form.name = "mcDgalleryDialog"
		form.ControlBox  = false --hide main bar
		local fpos = (mcCall.getIniDataFromArray mcTempProfileIni "Properties_2" "mcDgalleryDialog" 2)
		local fsize = (mcCall.getIniDataFromArray mcTempProfileIni "Properties_2" "mcDgalleryDialog" 3)
		if fpos == undefined do fpos = (mcCall.getIniDataFromArray mcDefaultProfileIni "Properties_2" "mcDgalleryDialog" 2)
		if fsize == undefined do fsize = (mcCall.getIniDataFromArray mcDefaultProfileIni "Properties_2" "mcDgalleryDialog" 3)
		form.StartPosition = form.StartPosition.Manual
		form.FormBorderStyle = form.FormBorderStyle.Sizable--none--SizableToolWindow--
		--form.dock = form.dock.left
		form.bounds = netDrRect fpos fsize
		form.MinimumSize = netDrSize [708, 277]
		--form.MaximumSize = netDrSize [btn_size*10, btn_size*10]
		form.BackColor = netDrColor clr_fore
		form.ShowInTaskbar = false
		form.opacity = form_opacity
		
		--logo
		mcs.lbl_logo.bounds = netDrRect [form_offset, bar_height+form_offset*2] [48, 48]
		mcs.lbl_logo.image = getImage (mcPath()+"Img\\3DGallery_Icon.bmp")
		
		--main toolbar
		mcs.lblT.bounds = netDrRect [form_offset, form_offset] [fsize.x - form_offset*2-border_size , bar_height]
		mcs.lblT.BackColor = netDrColor clr_back
		mcs.lblT.ForeColor = netDrColor clr_text
		mcs.lblT.Text = " 3DGallery II:"
		
		--search bar
		mcs.lbl_find.bounds = netDrRect [278, 46] [btn_size, btn_size]
		mcs.lbl_find.image = getIconDotNet 231
		mcs.search_bar.bounds = netDrRect [306, 47] [200, bar_height]
		mcs.search_bar.BackColor = netDrColor clr_back
		mcs.search_bar.ForeColor = netDrColor yellow
		mcs.search_bar.font = dnfontlarge
		--mcs.search_bar.AcceptsTab = true
		--mcs.search_bar.Multiline = true
		
		--tools
		mcs.lbl_tools.bounds = netDrRect [form_offset, bar_height+form_offset*2+50] [btn_size*2 , bar_height]
		mcs.lbl_tools.BackColor = netDrColor clr_back
		mcs.lbl_tools.ForeColor = netDrColor clr_text
		mcs.lbl_tools.Text = "Tools:"

		mcs.tlp_tools.bounds = netDrRect  [form_offset, bar_height*2+form_offset*2+50] [btn_size*2, btn_size*2]
		mcs.tlp_tools.backColor = netDrColor clr_btn
		mcs.tlp_tools.ColumnCount = 2
		
		mcs.tools_buttons = generateButtons mcs names:#("Add Model", "Delete Model", "Merge to Scene", "Rename Model") images:#(149, 148, 147, 144)
		mcs.tlp_tools.controls.addRange (mcs.tools_buttons)
		
		--paint
		mcs.lbl_paint.bounds = netDrRect [form_offset, bar_height+form_offset*2+116] [btn_size*2 , bar_height]
		mcs.lbl_paint.BackColor = netDrColor clr_back
		mcs.lbl_paint.ForeColor = netDrColor clr_text
		mcs.lbl_paint.Text = "Paint:"

		mcs.tlp_paint.bounds = netDrRect  [form_offset, bar_height*2+form_offset*2+116] [btn_size*2, btn_size*2]
		mcs.tlp_paint.backColor = netDrColor clr_btn
		mcs.tlp_paint.ColumnCount = 2
		
		local names = #("Pick a surface for planting", "Plant Customize...", "Planting", "Multiplanting")
		local images = #(146, 164, 145, 163)
		mcs.paint_buttons = generateButtons mcs names:names images:images
		mcs.tlp_paint.controls.addRange (mcs.paint_buttons)
		
		--settings
		mcs.lbl_settings.bounds = netDrRect [form_offset, bar_height+form_offset*2+182] [btn_size*2 , bar_height]
		mcs.lbl_settings.BackColor = netDrColor clr_back
		mcs.lbl_settings.ForeColor = netDrColor clr_text
		mcs.lbl_settings.Text = "Settings:"

		mcs.tlp_settings.bounds = netDrRect  [form_offset, bar_height*2+form_offset*2+182] [btn_size*2, btn_size+352]
		mcs.tlp_settings.backColor = netDrColor clr_btn
		mcs.tlp_settings.ColumnCount = 2
		
		mcs.settings_buttons = generateButtons mcs names:#("Customize...", "Help") images:#(143, 162)
		mcs.tlp_settings.controls.addRange (mcs.settings_buttons)
		
		--thumbnails
		mcs.flp_cat.bounds = netDrRect [btn_size*2+form_offset*2, 70] [684, 508]
		mcs.flp_cat.AutoSize = false
		mcs.flp_cat.autoscroll = true
		mcs.flp_cat.padding = dotnetobject "padding" 2
		mcs.flp_cat.BackColor = netDrColor (color 40 45 66)
		
		--tabs
		mcs.tb_models.bounds = netDrRect [btn_size*2+form_offset*2, 46] [68, 26]
		--mcs.tb_models.appearance = mcs.tb_models.appearance.button
		mcs.tb_models.BackColor = netDrColor clr_back
		mcs.tb_models.ForeColor = netDrColor clr_text
		mcs.tb_textures.bounds = netDrRect [btn_size*2+form_offset*2+70, 46] [68, 26]
		mcs.tb_textures.BackColor = netDrColor clr_back
		mcs.tb_textures.ForeColor = netDrColor clr_text
		mcs.tb_materials.bounds  = netDrRect [btn_size*2+form_offset*2+140, 46] [68, 26]
		mcs.tb_materials.BackColor = netDrColor clr_back
		mcs.tb_materials.ForeColor = netDrColor clr_text
		mcs.tb_models.text = "Models"
		mcs.tb_textures.text = "Materials"
		mcs.tb_materials.text = "Textures"
		mcs.tb_models.Checked = true
		
		--main class sub class dropdown list
		mcs.lbl_maindir.bounds = netDrRect [btn_size*2+form_offset*2, bar_height+form_offset*2+4] [50, 20]
		mcs.lbl_maindir.Text = "Root Dir:"
		mcs.lbl_maindir.TextAlign = mcs.lbl_find.TextAlign.MiddleCenter
		mcs.lbl_maindir.BackColor = netDrColor clr_back
		mcs.lbl_maindir.ForeColor = netDrColor clr_text
		
		mcs.ddlMainClass.bounds = netDrRect [102, bar_height+form_offset*2+3] [200, 26]
		mcs.ddlMainClass.DropDownStyle = mcs.ddlMainClass.DropDownStyle.DropDownList--, DropDownList, simple
		mcs.ddlMainClass.BackColor = netDrColor clr_back--(color 200 200 120)
		mcs.ddlMainClass.ForeColor = netDrColor clr_text--yellow
		
		mcs.lbl_subdir.bounds = netDrRect [386, bar_height+form_offset*2+4] [50, 20]
		mcs.lbl_subdir.Text = "Sub Dir:"
		mcs.lbl_subdir.TextAlign = mcs.lbl_find.TextAlign.MiddleCenter
		mcs.lbl_subdir.BackColor = netDrColor clr_back
		mcs.lbl_subdir.ForeColor = netDrColor clr_text
		
		mcs.ddlSubClass.bounds = netDrRect [366+70, bar_height+form_offset*2+3] [200, 26]
		mcs.ddlSubClass.DropDownStyle = mcs.ddlMainClass.DropDownStyle.DropDownList
		mcs.ddlSubClass.BackColor = netDrColor  clr_back--(color 200 200 120)
		mcs.ddlSubClass.ForeColor = netDrColor clr_text--yellow

		
		--folder buttons
		mcs.folder_buttons = generateButtons mcs names:#("Create Main Class", "Delete Main Class", "Create Sub Class", "Delete Sub Class") images:#(161, 150, 142, 141)
		mcs.folder_buttons[1].location = netDrPoint [305, 20]
		mcs.folder_buttons[2].location = netDrPoint [332, 20]
		mcs.folder_buttons[3].location = netDrPoint [570+70, 20]
		mcs.folder_buttons[4].location = netDrPoint [594+70, 20]
		
		--progress bar
		mcs.progbar.bounds = netDrRect [form_offset*2+btn_size*2+40,579] [644, 12]
		mcs.lbl_progress.bounds = netDrRect [form_offset*2+btn_size*2,579] [40, 12]
		mcs.lbl_progress.Text = " 0/0"
		mcs.lbl_progress.TextAlign = mcs.lbl_find.TextAlign.MiddleCenter
		mcs.lbl_progress.BackColor = netDrColor clr_back
		mcs.lbl_progress.ForeColor = netDrColor clr_text
		
		--menu thumbs
		mcs.mnu_thumb.BackColor = netDrColor clr_back
		mcs.mnu_thumb.ForeColor = netDrColor clr_text
		mcs.mnu_thumb.ShowImageMargin = false
		--mcs.mnu_thumb.tag = form
		local names = #("Add To Scene","Select All", "Clear Selection", "Rename", "MoveTo", "Delete")
		for n in names do
		(
			local itm = mcs.mnu_thumb.Items.Add (n+"...")
			itm.tag = form
			itm.name = n
			dotnet.addeventhandler itm "Click" menuActions
			mcs.mnu_items += #(itm)
		)
		
		--add handlers
		dotnet.addEventHandler form "Shown" onOpenForm
		dotnet.addEventHandler form "Closed" onCloseForm
		dotnet.AddEventHandler form "BackColorChanged" changeBackcolor --thanks cyfer
		dotnet.addEventHandler form "VisibleChanged" onCloseForm
		dotnet.addEventHandler form "Resize" rezizeInterface
		--dotNet.addEventHandler form  "MouseUp" getFormPos
		--dotNet.addEventHandler form  "MouseMove" drawToForm
		dotNet.addEventHandler mcs.lblT   "MouseMove" onLblTMouseMove
		dotNet.addEventHandler mcs.lblT   "MouseDown" onLblTMouseDown 
		dotNet.addEventHandler mcs.lblT   "MouseUp"   onLblTMouseUp
		dotNet.addEventHandler mcs.lblT   "MouseDoubleClick" onLblDoubleClick
		
		dotNet.addEventHandler mcs.search_bar "TextChanged" filterThumbnails
		
		dotNet.addEventHandler mcs.ddlMainClass  "SelectedIndexChanged" mainClassSelectionChanged
		dotNet.addEventHandler mcs.ddlSubClass  "SelectedIndexChanged" subClassSelectionChanged
		
		--add controls
		form.controls.addRange (\
	  #(
			mcs.lblT, mcs.lbl_find, mcs.lbl_logo, mcs.lbl_tools, mcs.tlp_tools, mcs.lbl_paint, mcs.tlp_paint, mcs.lbl_settings, mcs.tlp_settings,
		    mcs.flp_cat, mcs.tb_models, mcs.tb_textures, mcs.tb_materials, mcs.progbar, mcs.ddlMainClass, mcs.ddlSubClass, mcs.lbl_maindir,
		    mcs.lbl_subdir, mcs.search_bar, mcs.lbl_progress
		) + mcs.folder_buttons )
	)
	inicializeInterface form form.tag.value
	mcDgalleryDialog = form
	--mcDgalleryDialog.show(WindowWrapper)
	mcDgalleryDialog.showModeless()
	
)


/*
	fn renameModel mcs = ()
	fn moveSelectedTo mcs =  ()
	fn deleteFromGallery mcs = ()

settings
thumb_size
transparency
*/

/*
mcsystem
*/