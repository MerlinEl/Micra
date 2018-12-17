------------------
------------------
--              --
--  3D Gallery  --
--              --
------------------
------------------
Global mcDgalleryDialog
Global mcTextBoxDialog
Global mcDgalleryRootDir = getINISetting mcUserINI "3DGallery" "Server_Dir" --getFilenamePath (getThisScriptFilename())
Global mcUserINI
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~--
--oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo--

if mcDgalleryDialog != undefined do destroyDialog mcDgalleryDialog

--oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo--
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~--
--format "file path:%\n" (getThisScriptFilename())
if doesFileExist mcUserINI do 
(
rollout mcDgalleryDialog " 3DGallery II:  Models  0/0" width:754 height:608
(
	--> Local
	local helpFile = mcDgalleryRootDir+"\\3DGallery.doc"
	local Current_Dir = "", lastMainCat="", lastSubCat=""
	local colorclass     = dotnetclass "system.drawing.color"
	local cursors = dotNetClass "System.Windows.Forms.Cursors"
	local cursor = dotNetClass "System.Windows.Forms.Cursor"
	local cursor_harrow  = dotNetObject "System.Windows.Forms.Cursor" (mcImgPath+"harrow.ico")
	local cursor_hmove   = dotNetObject "System.Windows.Forms.Cursor" (mcImgPath+"hmove.ico")
	local cursor_hdrag  = dotNetObject "System.Windows.Forms.Cursor" (mcImgPath+"hdrag.ico")
	--local cursor_harrow  = dotNetObject "System.Windows.Forms.Cursor" (mcPath()+"Img\\harrow.ico")
	--local cursor_hmove   = dotNetObject "System.Windows.Forms.Cursor" (mcPath()+"Img\\hmove.ico")
	local singleborder   = (dotNetClass "System.Windows.Forms.BorderStyle").fixedsingle	
	local dnfontlarge    = dotNetObject "System.Drawing.Font" "Verdana" 8.5 ((dotNetClass "System.Drawing.FontStyle").bold)
	local dnMXSlarge     = dotNetObject "System.Drawing.Font" "System" 8.5 ((dotNetClass "System.Drawing.FontStyle").bold)
	local dnfont         = dotNetObject "System.Drawing.Font" "Verdana" 6.5 ((dotNetClass "System.Drawing.FontStyle").bold)		
	local RButton        = (dotNetClass "System.Windows.Forms.MouseButtons").Right
	local LButton        = (dotNetClass "System.Windows.Forms.MouseButtons").Left
	local thumb_size     = [160, 120]
	local selected_thumbs = #()
	local dnobjarray = #()
	local drag_enabled  = false, drag_start_pos, drag_end_pos, drag_offset = 25, DragTool
	--< Local
	-->Interface
	Timer tmr_resize "Timer" pos:[24,24] width:24 height:24 enabled:true interval:100 active:false
	--progressBar progbar "ProgressBar" pos:[64,428] width:555 height:12
	dotNetControl progbar "Windows.Forms.Progressbar" pos:[70,584] width:676 height:12
	--
	dropdownList ddlMainClass "" pos:[252,28] width:180 height:21
	dropdownList ddlSubClass "" pos:[508,28] width:180 height:21
	--bitmap bmpBg1 "Bitmap" pos:[248,24] width:188 height:28 bitmap:(BitMap 1 1 color:(color 244 220 50))
	--bitmap bmpBg2 "Bitmap" pos:[504,24] width:188 height:28 bitmap:(BitMap 1 1 color:(color 50 200 240))
	--
	button btnCreMainCls "" pos:[440,24] width:24 height:28 images:(mcCall.getIcon 161) toolTip:"Create Main Class"
	button btnDelMainCls "" pos:[464,24] width:24 height:28 images:(mcCall.getIcon 150) toolTip:"Delete Main Class"
	button btnCreSubCls "" pos:[696,24] width:24 height:28 images:(mcCall.getIcon 142) toolTip:"Create Sub Class"
	button btnDelSubCls "" pos:[720,24] width:24 height:28 images:(mcCall.getIcon 141) toolTip:"Delete Sub Class"
	button btnAddModel "" pos:[8,48] width:24 height:24 images:(mcCall.getIcon 149) toolTip:"Add  (press <Ctrl> to replace...)"
	button btnMergeModel "" pos:[8,24] width:24 height:24 images:(mcCall.getIcon 147) toolTip:"Merge  (press <Ctrl> to disable automatic rename...)"
	button btnRenModel "" pos:[32,24] width:24 height:24 images:(mcCall.getIcon 144) toolTip:"Rename"
	button btnDelModel "" pos:[32,48] width:24 height:24 images:(mcCall.getIcon 148) toolTip:"Delete"
	checkbutton ckb_plant "" pos:[8,128] width:24 height:24 images:(mcCall.getIcon 145) toolTip:"Planting" enabled:false
	checkbutton ckbPSurf "" pos:[8,104] width:24 height:24 images:(mcCall.getIcon 146) toolTip:"Pick a surface for planting" enabled:false
	checkbutton ckb_cfg "" pos:[8,184] width:24 height:24 images:(mcCall.getIcon 143) toolTip:"3DGallery..." enabled:false
	checkbutton ckb_multi_plant "" pos:[32,128] width:24 height:24 images:(mcCall.getIcon 163) toolTip:"Multiplanting" enabled:false
	checkbutton ckb_plant_dialog "" pos:[32,104] width:24 height:24 images:(mcCall.getIcon 164) toolTip:"Plant Customize..." enabled:false
	button btnHlp "" pos:[32,184] width:24 height:24 images:(mcCall.getIcon 162) toolTip:"Help..." enabled:false
	--
	dotNetControl flp_cat "flowlayoutpanel" pos:[68,58] width:677 height:522	
	dotNetControl tb "System.Windows.Forms.Tabcontrol" pos:[68,24] width:164 height:26
	--
	GroupBox grp_cat "Items:" pos:[64,4] width:686 height:598
	GroupBox grp11 "Tools:" pos:[4,4] width:56 height:76
	GroupBox grp12 "Paint:" pos:[4,84] width:56 height:76
	GroupBox grp13 "SetUp:" pos:[4,164] width:56 height:52
	--
	label lbl7 "Root Dir:" pos:[248,4] width:44 height:16
	label lbl5 "Sub Dir:" pos:[504,4] width:40 height:16
	--imgtag tg_logo "logo01" pos:[4,4] width:64 height:72
	
	--<Interface
-->functions
	fn errorMsg num = 
	(
		local msg = case num of
		(
			1:("Select a model to rename.")
			2:("Select some object to add.")
			3:("Create <Sub clas> catalog.")
			4:("Multiselection cant be renamed.")
			5:()
			6:()
		)
		messageBox msg title:" 3DGallery II... Warning:"
	)
	fn getLastDirFrom path =
	(
		local arr = ( filterString path "\\" )
		return arr[arr.count]
	)
	fn resizeBitmapNET srcBitmap width height useHighQuality:false=
	(
		local destBitmap = (dotNetObject "System.Drawing.Bitmap" width height) --Create new bitmap object
		destBitmap.SetResolution srcBitmap.HorizontalResolution srcBitmap.VerticalResolution
		local theGraphics = (dotNetClass "System.Drawing.Graphics").fromImage destBitmap --Create new Graphics object
		local destRec = (dotnetObject "System.Drawing.rectangle" 0 0 width height) --Set destination image size
		IF useHighQuality DO theGraphics.InterpolationMode = theGraphics.InterpolationMode.HighQualityBicubic
		theGraphics.drawImage srcBitmap destRec --Resize the image
		theGraphics.dispose() --gc
		return destBitmap
	)
	fn resizeInterface size =
	(
		flp_cat.width  = size.x - 77
		flp_cat.height = size.y - 86
		grp_cat.width  = size.x - 68
		grp_cat.height = size.y - 8
		progbar.width  = size.x - 78
		progbar.pos.y  = size.y - 24
	)
	fn centerDialogToMain my_size =
	(
		local dPos  = getDialogPos mcDgalleryDialog
		local dSize = getDialogSize mcDgalleryDialog
		return (dPos + dSize/2 - my_size/2)
	)
	fn saveDialogSettings =
	(
		if mcDgalleryDialog.placement == #minimized or mcDgalleryDialog.placement == #maximized do return false  --thanks for this magicm
		local dSize = [mcDgalleryDialog.width, mcDgalleryDialog.height]
		local dSize = [mcDgalleryDialog.width, mcDgalleryDialog.height]
		setINISetting mcUserINI "3DGallery" "Dialog_Gal_Size" (dSize as string)
		setINISetting mcUserINI "3DGallery" "Dialog_Gal_Pos"  ((getDialogPos mcDgalleryDialog) as string)
	)
	fn selectAll =
	(
		selected_thumbs = #()
		for i=1 to flp_cat.controls.count do 
		(
			local itm = flp_cat.controls.item[i-1]
			selected_thumbs += #(itm)
			itm.forecolor = colorclass.red
		)
		mcDgalleryDialog.title = " 3DGallery II:  Models  "+selected_thumbs.count as string+"/"+ (flp_cat.controls).count as string
	)
	fn clearSelectedItems =
	(
		for i in selected_thumbs do i.forecolor = colorclass.LightSteelBlue
		selected_thumbs = #()
		flp_cat.refresh()
		mcDgalleryDialog.title = " 3DGallery II:  Models  0/0"
	)
	fn removeFromSelection ctrl itmName =
	(
		for i=1 to selected_thumbs.count where selected_thumbs[i].text == itmName do
		(
			deleteItem selected_thumbs i
			exit
		)
		mcDgalleryDialog.title = " 3DGallery II:  Models  "+selected_thumbs.count as string+"/"+ (flp_cat.controls).count as string
		ctrl.forecolor = colorclass.yellow
	)
	fn addToSelection ctrl itmName =
	(
		append selected_thumbs ctrl
		mcDgalleryDialog.title = " 3DGallery II:  Models  "+selected_thumbs.count as string+"/"+ (flp_cat.controls).count as string
		ctrl.forecolor = colorclass.red
	)
	fn textBox =
	(
		try (DestroyDialog mcTextBoxDialog) catch()
		rollout mcTextBoxDialog " Command Box v0.1" width:320 height:36
		(
			-->locals
			local theName = ""
			local bgColor   = ((colorMan.getColor #background)*255)as color
			local winColor  = ((colorMan.getColor #window)*255)as color
			local textColor = ((colorMan.getColor #text)*255)as color
			local colorclass = dotnetclass "system.drawing.color"
			local drawingColor   = dotNetClass "drawing.color"
			dotNetControl edtBox "textbox" pos:[4,4] width:312 height:28
			fn correctSymbolCheck text =
			(
				if text.count == 0 do return false
				local badSymbols = "\/*?"
				for t=1 to text.count do
				(
					for s=1 to badSymbols.count do
					(
						if text[t] == badSymbols[s] do 
						(
							messagebox "Incorrect Name.\nSymbols \ / ?* are not allowed." title:"3DGallery!"
							return false
						)
					)
				)
				return true
			)
			fn textBoxControll a s  = --#KeyPress
			(
				if  (bit.charAsInt s.KeyChar) == 27 then --escape pressed
				(
					theName = ""
					DestroyDialog mcTextBoxDialog
				)
				else if (bit.charAsInt s.KeyChar) == 13 then  --if enter pressed
				( 
					theName = edtBox.text
					if correctSymbolCheck theName then
					(
						local existingNames = (for i in (getFiles (Current_Dir+"*.*")) collect (getFilenameFile i)) --check for duplicate names
						if   (findItem existingNames theName) == 0 --check for duplicate names
						then (DestroyDialog mcTextBoxDialog)
						else (messagebox ("The name:<"+edtBox.text+"> is allready exist.") title:" 3D Gallery:" ; setFocus edtBox)
					)
					else (setFocus edtBox)
				)
			)
			on mcTextBoxDialog open do
			(
				--Current_Dir = getINISetting mcUserINI "3DGallery" "Current_Dir"
				local dnfontlarge = dotNetObject "System.Drawing.Font" "Verdana" 14 ((dotNetClass "System.Drawing.FontStyle").bold)
				edtBox.font = dnfontlarge
				edtBox.BackColor= drawingColor.fromArgb winColor.r winColor.g winColor.b
				--edtBox.ForeColor= drawingColor.fromArgb textColor.r textColor.g textColor.b
				edtBox.ForeColor= colorclass.yellow
				edtBox.AcceptsTab = true
				edtBox.Multiline = true
				edtBox.focus()
			)
			on edtBox keyPress a s do (textBoxControll a s method:#KeyPress)
  			--on edtBox keyUp    a s do (textBoxControll a s method:#KeyUp)
		)
		CreateDialog mcTextBoxDialog pos:(centerDialogToMain [320,36]) style:#(#style_border)  modal:true --escapeEnable:true crashing!!!
		return mcTextBoxDialog.theName
	)
	fn renameModel =
	(
		--get selected item
		if selected_thumbs.count  > 1 do (errorMsg 4 ; return false)
		if selected_thumbs.count != 1 do (errorMsg 1 ; return false)
		
		local ctrl = selected_thumbs[1]

		local subPath = (mcDgalleryRootDir+tb.selectedTab.text+"\\"+lastMainCat+"\\"+lastSubCat+"\\")
		local existingNames = (for i in (getFiles (subPath+"*.*")) collect (getFilenameFile i)) --check for duplicate names
		local textFromBox = textBox()		
		--format "the text:%\n" textFromBox
		if textFromBox == "" do return false 

		--rename files (.max and .jpg)
		local oldfName = selected_thumbs[1].text
		local newfName = textFromBox
		local oldMaxF =(subPath+ oldfName + ".max")
		local oldImgF =(subPath+ oldfName + ".jpg")
		local newMaxF =(subPath+ newfName + ".max")
		local newImgF =(subPath+ newfName + ".jpg")	
		renameFile oldMaxF newMaxF
		renameFile oldImgF newImgF
		
		--submit new name in to ini
		local cat_IniFile   = (mcDgalleryRootDir+tb.selectedTab.text+"\\"+lastMainCat+".ini")
		try delINISetting cat_IniFile lastSubCat oldfName catch ()
		setINISetting cat_IniFile lastSubCat newfName (#(sysInfo.username,localTime) as string) 
	/*
		--rename item label
		ctrl.text = newfName
		removeFromSelection ctrl oldfName
		selected_thumbs = #()
		flp_cat.update()
		flp_cat.refresh()
	*/	
		--reload , resort gallery
		mcDgalleryDialog.loadGallery type:tb.SelectedIndex
		print "Model(s) is renammed."
	)
	fn renderModel img_path =
	(
		--get ini setting for render
		local anti       = execute(getIniSetting mcUserINI "3DGallery" "AntiAliasing" )
		local samp       = execute(getIniSetting mcUserINI "3DGallery" "PixelSampler" )
		local shad       = execute(getIniSetting mcUserINI "3DGallery" "Shadows"     )
		local quei       = execute(getIniSetting mcUserINI "3DGallery" "Quiet"        ) 
		--Render to vbf
		local oldBgColor = backgroundColor
		backgroundColor  = execute (getIniSetting mcUserINI "3DGallery" "Thumb_Color")
		local imgSize    = execute (getIniSetting mcUserINI "3DGallery" "Thumb_Render_Size")
		local img        = bitmap imgSize.x imgSize.y color:backgroundColor
		--render phase
		render outputsize:imgSize antiAliasing:anti enablePixelSampler:samp shadows:shad \
			   quiet:quei renderType:#selection to:img vfb:off -- outputFile:(img_path+".jpg")
		--if path is undefined make render with prewiew
		img.filename = img_path
		save img quiet:on
		backgroundColor  = oldBgColor -- return old bg color
		return img
	)
	fn moveFile thumb_name targetDir ini:true ask:true =
	(
		--format "file:%\ttargetDir:%\n" thumb_name targetDir
		local max_file = Current_Dir+thumb_name+".max"
		local img_file = Current_Dir+thumb_name+".jpg" 
		--format "max_file:%\timg_file:%\n" max_file img_file
		if not doesFileExist max_file or not doesFileExist targetDir do return false
		local max_file_name = filenameFromPath max_file
		local img_file_name = filenameFromPath img_file
		local new_max_file  = targetDir + max_file_name
		local new_img_file  = targetDir + img_file_name
		--ask for deleting dupplicates
		if doesFileExist new_max_file do
		(
			if ask then
			(
				if (queryBox (max_file_name+" already exist.\nDo you want to replace it?") title:" Confirm Move File(s):") 
				then (deleteFile new_max_file; deleteFile new_img_file)
				else (return false)
			)
			else (deleteFile new_max_file; deleteFile new_img_file)
		)
		--write new ini file data
		if ini do 
		(
			local newIniFile = (mcDgalleryRootDir+ddlMainClass.selected+".ini")
			if not doesFileExist newIniFile do return false
			setINISetting newIniFile ddlSubClass.selected thumb_name (#(sysInfo.username,localTime) as string)
		)
		
		copyFile max_file new_max_file
		copyFile img_file new_img_file
		
		local oldIniFile = (mcDgalleryRootDir+tb.selectedTab.text+"\\"+lastMainCat+".ini")
		delINISetting oldIniFile lastSubCat thumb_name -- delete key
		
		deleteFile max_file
		deleteFile img_file
		
		flp_cat.controls.RemoveByKey (getFilenameFile thumb_name)
	)
	fn deleteFromGallery =
	(
		if selected_thumbs.count == 0 do return false
		if not (queryBox "Are you sure you want to delete this model(s)?" title:" Delete Model(s):") do return false
		local cat_IniFile  = mcDgalleryRootDir+tb.selectedTab.text+lastMainCat+".ini"
		local bin_dir      = mcDgalleryRootDir+tb.selectedTab.text+"\\Recycle_Bin\\All\\"
		--move files (.max , .jpg) to local Recycle Bin or delete
		progbar.foreColor = colorclass.red
		for i=1 to selected_thumbs.count do
		(
			local tname  = selected_thumbs[i].text
			moveFile tname bin_dir ini:false ask:false
			progbar.value = 100.*i/selected_thumbs.count 
		)
		progbar.value = 0
		
		selected_thumbs = #()
		flp_cat.update()
		flp_cat.refresh()
		mcDgalleryDialog.title = " 3DGallery II:  Models "+selected_thumbs.count as string+"/"+ (flp_cat.controls).count as string
	    --.IsReadOnly = false
	)
	fn mergeModels =
	(
		if selected_thumbs.count == 0 do return false
		progbar.foreColor = colorclass.LightSteelBlue
		local merged_models = #()
		for i=1 to selected_thumbs.count do --undo "Merge Models" on
		(
			local f = Current_Dir+selected_thumbs[i].text+".max"
			if doesFileExist f do 
			(
				try   (mergeMAXFile f #useSceneMtlDups #mergeDups #select ) 
				catch (messagebox ( "Merging model:<" + selected_thumbs[i].text + "> is failed.\nFile is mising or is corupted." ) title: " Warning!")
				--prevent dupplicate names in scene
				if not keyboard.controlPressed then (for o in selection do o.name = uniqueName (o.name))
			)
			progbar.value = 100.*i/selected_thumbs.count 
			merged_models += selection as array
			max select none
		)
		progbar.value = 0
		--setfocus mcDgalleryDialog.flp_cat
		clearSelectedItems()
		select merged_models
	)
	fn moveSelectedTo =
	(
		if selected_thumbs.count == 0 do return false
		if mcMoveToDialog != undefined do destroyDialog mcMoveToDialog
		rollout mcMoveToDialog " Move To" width:292 height:144
		(
			GroupBox grp01 "" pos:[4,0] width:284 height:140
			bitmap bmpBg1 "Bitmap" pos:[12,28] width:268 height:28 bitmap:(BitMap 1 1 color:(color 244 220 50))
			bitmap bmpBg2 "Bitmap" pos:[12,76] width:268 height:28 bitmap:(BitMap 1 1 color:(color 50 200 240))
			dropdownList ddlMainClass "" pos:[16,32] width:260 height:21
			dropdownList ddlSubClass "" pos:[16,80] width:260 height:21
			label lbl4 "Main class:" pos:[12,12] width:180 height:16
			label lbl5 "Sub class:" pos:[12,60] width:180 height:16
			button btn_cncl "Cancel" pos:[172,112] width:108 height:20
			button btn_move "Move" pos:[12,112] width:108 height:20
			fn loadSubCat2  =
			(
				local subDirs  = sort(getDirectories (mcDgalleryRootDir+tb.selectedTab.text+"\\"+ddlMainClass.selected+"\\*.*"))
				ddlSubClass.items  = for i in subDirs collect (getLastDirFrom i)--cut the last dir from path
			)
			fn loadMainCat2 =
			(
				local mainDirs = sort(getDirectories (mcDgalleryRootDir+tb.selectedTab.text+"\\"+"*.*"))
				if mainDirs.count == 0 do return false
				ddlMainClass.items = for i in mainDirs collect (getLastDirFrom i)--cut the last dir from path
				return true
			)
			fn getDir =
			(
				local m_cl = ddlMainClass.selected
				local s_cl = ddlSubClass.selected
				if m_cl == undefined and s_cl == undefined do return ""
				return (mcDgalleryRootDir+tb.selectedTab.text+"\\"+m_cl+"\\"+s_cl+"\\")
			)
			fn updateIni fName =
			(
				--write new
				local m_cl = ddlMainClass.selected
				local s_cl = ddlSubClass.selected
				local newIniFile   = (mcDgalleryRootDir+tb.selectedTab.text+"\\"+m_cl+".ini")
				--format "newIniFile:%\n" newIniFile
				if not doesFileExist newIniFile do return false
				setINISetting newIniFile s_cl fName (#(sysInfo.username,localTime) as string)
				--delete old
				local m_cl = lastMainCat
				local s_cl = lastSubCat
				local oldIniFile   = (mcDgalleryRootDir+tb.selectedTab.text+"\\"+m_cl+".ini")
				if not doesFileExist oldIniFile do return false
				delINISetting oldIniFile s_cl fName -- delete key
			)
			on mcMoveToDialog open do (if loadMainCat2() do loadSubCat2())
			on btn_cncl pressed  do destroyDialog mcMoveToDialog
			on btn_move pressed  do
			(
				local oldMainCat = lastMainCat
				local oldSubCat = lastSubCat
				local newMainCat = ddlMainClass.selected
				local newSubCat = ddlSubClass.selected
				if oldMainCat+oldSubCat != newMainCat+newSubCat then --prevent to move tags in to same directory
				(
					local targetDir = getDir()
					if doesFileExist targetDir do
					(
						for i in selected_thumbs do
						(
							local iFilePath = i.tag
							local p = getFilenamePath iFilePath
							local n = getFilenameFile iFilePath
							local mFilePath = p+n+".max"
							local iFilePathNew = targetDir+n+".jpg"
							local mFilePathNew = targetDir+n+".max"
							if not doesFileExist mFilePath do continue 
							--check for dupplicates
							if doesFileExist mFilePathNew do
							(
								if (queryBox (n+".max"+" already exist.\nDo you want to replace it?") title:" Confirm Move File(s):") 
								then (deleteFile mFilePathNew; deleteFile iFilePathNew)
								else continue
							)
							--moving files to another folder
							copyFile iFilePath iFilePathNew
							copyFile mFilePath mFilePathNew
							--delete files (.max , .jpg)
							deleteFile iFilePath
							deleteFile mFilePath
							--update ini
							updateIni n
							flp_cat.controls.RemoveByKey i.text
						)
						--refresh
						flp_cat.update()
						flp_cat.refresh()
						destroyDialog mcMoveToDialog
					)
				)
				else (messagebox "Cant move to same directory. Chose another one." title:"  3DGallery!")
			)
			on ddlMainClass selected sel do (loadSubCat2())
		)
		CreateDialog mcMoveToDialog pos:(centerDialogToMain [292,144]) style:#(#style_border)  modal:true
	)
	fn onMouseDown ctrl evnt =
    (
		--format "MouseDown: % [%]\n" ctrl (evnt.button.tostring())
		
		local itmName = ctrl.text
		if evnt.button == RButton then --"Show RC Menu"
		(
			if ctrl.forecolor != colorclass.red do addToSelection ctrl itmName

			rcMenu thumbMenu
			(
				menuItem new_1 "Add To Scene..."
				separator file_menu_1
				menuItem new_5 "Select All.."
				menuItem new_4 "Clear Selection..."
				separator file_menu_2
				menuItem new_2 "Rename ..."
				menuItem new_6 "MoveTo ..."
				menuItem new_3 "Delete..."
				
				on new_1 picked do mergeModels()
				on new_2 picked do renameModel()
				on new_3 picked do deleteFromGallery()
				on new_4 picked do clearSelectedItems() 
				on new_5 picked do selectAll() 
				on new_6 picked do moveSelectedTo() 
			)
			PopupMenu thumbMenu
		)
		else if ctrl.forecolor == colorclass.red 
		then removeFromSelection ctrl itmName
		else addToSelection ctrl itmName
		
		flp_cat.Cursor = cursor_hmove
    )  
    fn onMouseUp ctrl evnt =
    (
       drag_start_pos = undefined
	   drag_end_pos   = undefined
	   if DragTool == undefined do flp_cat.Cursor = cursor_harrow
	   --format "MouseUp: % [%]\n" ctrl (evnt.button.tostring())
    )   
	fn onMouseEnter ctrl evnt =
    (
        --format "MouseEnter % [%]\n" ctrl evnt
		if ctrl.forecolor != colorclass.red do ctrl.forecolor = colorclass.yellow
		if DragTool == undefined do flp_cat.Cursor = cursor_harrow
    )
	fn onMouseLeave ctrl evnt = --drag and drop
    (
	   --format "MouseLeave % [%]\n" ctrl evnt
		if ctrl.forecolor != colorclass.red do ctrl.forecolor = colorclass.LightSteelBlue
		--edt_filter.text = "MouseLeave: " + ctrl.text 
    )
	fn onMouseMove ctrl evnt =
	(
		--format "MouseMove_ButtonFocused: % \n" ctrl.Focused

		--drag tracking == mouse down and mouse leaving thumb area
		if evnt.button == LButton and selected_thumbs.count != 0 do --ctrl.Focused do 
		(
			if drag_start_pos == undefined 
			then drag_start_pos = [evnt.X, evnt.Y]
			else drag_end_pos   = [evnt.X, evnt.Y]
			
			if drag_start_pos != undefined and drag_end_pos != undefined do 
			(
				if distance drag_start_pos drag_end_pos > drag_offset do --drag enabled
				(
					--format "merging:%\n" selected_thumbs
					flp_cat.Cursor = cursor_hdrag
					mergeModels()
				)
			)
		)
		--format "Move!\n\tSender : %\n\tMouse Pos : %\n" ctrl.Text [evnt.X, evnt.Y]
	)
	fn addImageToButton img_path =
	(
		local img_btn = dotnetobject "button"
		img_btn.size = dotnetobject "system.drawing.size" thumb_size.x thumb_size.y --160 120
		--img_btn.backcolor = colorclass.yellow --cadetblue -- tag color
		img_btn.forecolor = colorclass.LightSteelBlue --text color
		img_btn.margin =  dotnetobject "system.windows.forms.padding" 2 -- thumbs distance
		img_btn.flatstyle = (dotNetclass "System.Windows.Forms.FlatStyle").flat
		img_btn.FlatAppearance.BorderSize = 2
		img_btn.font= dnfont
		img_btn.text = getFilenameFile img_path	
		img_btn.name = img_btn.text
		img_btn.tag  = img_path
		img_btn.textalign =  (dotnetclass "System.Drawing.ContentAlignment").BottomCenter
		local img_path = dotNetObject "System.Drawing.Bitmap" img_path
		local img_copy = resizeBitmapNET img_path thumb_size.x thumb_size.y
		img_path.Dispose()
		img_btn.Image = img_copy
		img_btn.AllowDrop = true
		--img_btn.showTooltip -- WIP	
		-- Setup an event handlers for both buttons
		dotnet.addEventHandler img_btn "MouseDown" onMouseDown
		dotnet.addEventHandler img_btn "MouseUp" onMouseUp
		dotnet.addEventHandler img_btn "MouseEnter" onMouseEnter
		dotnet.addEventHandler img_btn "MouseLeave" onMouseLeave
		dotnet.addEventHandler img_btn "MouseMove" onMouseMove
		--mcsystem.show img_path
		--gc()
		return img_btn
	)
	fn loadGallery type:1 = --type = tab controll state
	(
		selected_thumbs = #()
		flp_cat.controls.clear()
		Current_Dir = mcDgalleryRootDir+tb.selectedTab.text+"\\"+lastMainCat+"\\"+lastSubCat+"\\"
		setINISetting mcUserINI "3DGallery" "Current_Dir" Current_Dir 
		--format "Current_Dir:%\n" Current_Dir
		if not doesFileExist Current_Dir do return false
		local Images_Array = getFiles (Current_Dir + "*.jpg")
		--change cursor to wait
		cursor.current = cursors.WaitCursor
		
		case type of -- WIP
		(
			0:(print "Loading... Models")
			1:(print "Loading... Materials" )
			2:(print "Loading...  Textures")
		)
		local clr = colorclass.fromARGB 8 200 248
		progbar.foreColor = clr --colorclass.yellow --orange--White, 
		dnobjarray = #()
		for i=1 to Images_Array.count do
		(
			append dnobjarray (addImageToButton Images_Array[i])
			progbar.value = 100.*i/Images_Array.count 
		)
		flp_cat.controls.addrange dnobjarray
		--flp_cat.controls.addrange dnobjarray
		cursor.current = cursors.Arrow
		progbar.value = 0
		--grp_cat.text = "Items: 0/"+ (flp_cat.controls).count as string
		mcDgalleryDialog.title = " 3DGallery II:  Models "+" 0/"+ (flp_cat.controls).count as string
	)
	fn addTogallery =
	(
		if selection.count == 0 do (errorMsg 2; return false)
		if lastSubCat == undefined do (errorMsg 3 ;return false)
		local name_from_box
		if keyboard.controlPressed 
		then --replace selected thumbnail and model
		(
			local thumb = selected_thumbs[1]
			name_from_box = if thumb == undefined then "" else thumb.name
		)
		else --add new model
		(
			name_from_box = textBox()
		)
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
	)
	fn loadMainCat = --remember main dir where you browse last time
	(
		--collect folders for main cat
		local mainDirs = sort(getDirectories (mcDgalleryRootDir+tb.selectedTab.text+"\\*.*"))
		if mainDirs.count == 0 do return false
		ddlMainClass.items = for i in mainDirs collect (getLastDirFrom i)--get the last dir from path
		--last main cat
		lastMainCat = getINISetting mcUserINI "3DGallery" "lastMainCat"
		if (local num = findItem ddlMainClass.items lastMainCat) != 0 
		then (ddlMainClass.selection = num)
		else (ddlMainClass.selection = 1 ; lastMainCat = ddlMainClass.items[1])
		return true
	)
	fn loadSubCat = --remember sub dir where you browse last time
	(
		--collect folders for sub cat
		local subDirs = sort( getDirectories (mcDgalleryRootDir+tb.selectedTab.text+"\\"+lastMainCat+"\\*.*") )
		if subDirs.count == 0 do return false
		ddlSubClass.items = for i in subDirs collect (getLastDirFrom i)--get the last dir from path
		--last sub cat
		lastSubCat = getINISetting mcUserINI "3DGallery" "lastSubCat"
		if (local num = findItem ddlSubClass.items lastSubCat) != 0 
		then (ddlSubClass.selection = num)
		else (ddlSubClass.selection = 1 ; lastSubCat = ddlSubClass.items[1])
		loadGallery type:tb.SelectedIndex
		return true
	)
	fn tabControll iobj lvl =
	(
		case lvl of
		(
			0:(iobj.title = " 3DGallery II:  Models")
			1:(iobj.title = " 3DGallery II:  Materials")
			2:(iobj.title = " 3DGallery II:  Textures")
		)
	)
	fn inicializeInterface =
	(
		-->resizing interface
		local dia_size = [mcDgalleryDialog.width, mcDgalleryDialog.height]
		resizeInterface dia_size
		
		-->Tabs
		local Tabs_Array = #("Models", "Materials", "Textures")
		for i in Tabs_Array do
 		(
 			tb.TabPages.add i
 		)	
		--<Tabs
		
		-->Progress Bar
		--progbar.style = progbar.style.continuous
		progbar.backColor = colorclass.fromARGB 40 45 66

		--flp_cat.MaximumSize
		--flp_cat.MinimumSize
		flp_cat.AutoSize = true
		flp_cat.autoscroll = true
		flp_cat.padding = dotnetobject "system.windows.forms.padding" 2
		flp_cat.BackColor = colorclass.fromARGB 40 45 66
		
		-->load dropDown lists Main & Sub
		local sub_cat_found = if loadMainCat() then loadSubCat() else false
		--mcSystem.show flp_cat
		return true
	)
	fn createMainClass =
	(
		local existingNames = ddlMainClass.items --check for duplicate names
		local textFromBox = textBox()
		if textFromBox != "" do 
		(
			makeDir (mcDgalleryRootDir+tb.selectedTab.text+"\\"+textFromBox)
			ddlMainClass.items = 
			(
				sort (ddlMainClass.items += #(textFromBox))	
			)
			ddlMainClass.selection = (findItem ddlMainClass.items textFromBox)
			--grp_cat.text = "Items: 0/0"
			lastMainCat = textFromBox
			ddlSubClass.items = #()
			flp_cat.controls.clear() --remove old thumbs
		)
	)
	fn createSubClass =
	(
		local existingNames = ddlSubClass.items --check for duplicate names
		local textFromBox = textBox()
		if textFromBox != "" do 
		(
			makeDir (mcDgalleryRootDir+tb.selectedTab.text+"\\"+lastMainCat+"\\"+textFromBox)
			ddlSubClass.items = 
			(
				sort (ddlSubClass.items += #(textFromBox))	
			)
			ddlSubClass.selection = (findItem ddlSubClass.items textFromBox)
			--grp_cat.text = "Items: 0/0"
			lastSubCat = textFromBox
			flp_cat.controls.clear() --remove old thumbs
		)
	)
	fn deleteMainClass = --you only delete empty folders (security reason)
	(
		if lastMainCat == undefined do (return false)
		local mainPath = (mcDgalleryRootDir+tb.selectedTab.text+"\\"+lastMainCat)
		--check if some folders inside
		local dirs_count = (getDirectories (mainPath+"\\*.*")).count
		if dirs_count > 0 do
		(
			messageBox ( "The catalog:<"+lastMainCat+"> contain:<"+dirs_count as string+"> folder(s).") title: " Can't be deleted!"
			return false
		)
		--deleting ini user file
		local useIniFile = (mcDgalleryRootDir+tb.selectedTab.text+"\\"+lastMainCat+".ini")
		if doesFileExist useIniFile do (deleteFile useIniFile)
		--deleting folder
		DOSCommand ( "rd "+"\""+mainPath+"\"")
		loadGallery type:tb.SelectedIndex
	)
	fn deleteSubClass = --you only delete empty folders
	(
		if lastSubCat == undefined do (return false)
		local subPath = (mcDgalleryRootDir+tb.selectedTab.text+"\\"+lastMainCat+"\\"+lastSubCat)
		--check if max files inside	
		local files_count = (getFiles (subPath+"\\*.max")).count
		if files_count > 0 do 
		(
			messageBox ("The catalog:<"+lastSubCat+"> contain:<"+files_count as string+"> file(s).") title:" Can't be deleted!"
			return false
		)
		--deleting keys
		local useIniFile = (mcDgalleryRootDir+tb.selectedTab.text+"\\"+lastMainCat+".ini")
		if doesFileExist useIniFile do (delINISetting useIniFile lastSubCat)
		--deleting folder
		DOSCommand ( "rd "+"\""+subPath+"\""+" /s /q")
		loadSubCat()
	)
	--<functions

	-->Actions
	on mcDgalleryDialog open              do (if not inicializeInterface() do destroyDialog mcDgalleryDialog)
	on mcDgalleryDialog close             do (saveDialogSettings())
	on tb Selected itm                    do (tabControll mcDgalleryDialog itm.TabPageIndex )
	on mcDgalleryDialog resized size      do (resizeInterface size)
	on mcDgalleryDialog lbuttondblclk pos do (loadGallery type:tb.SelectedIndex)
	on ddlMainClass selected sel          do
	( 
		if sel != 0 do
		(
			setINISetting mcUserINI "3DGallery" "lastMainCat" ddlMainClass.items[sel]
			lastMainCat = ddlMainClass.items[sel]
			loadSubCat()
		)
	)
	on ddlSubClass  selected sel do 
	(
		if sel != 0 do
		(
			setINISetting mcUserINI "3DGallery" "lastSubCat" ddlSubClass.items[sel]
			lastSubCat = ddlSubClass.items[sel]
			loadGallery type:tb.SelectedIndex
		)
	)
	on btnCreMainCls pressed do (createMainClass   () )
	on btnDelMainCls pressed do (deleteMainClass   () )
	on btnCreSubCls  pressed do (createSubClass    () )
	on btnDelSubCls  pressed do (deleteSubClass    () )
	on btnAddModel   pressed do (addToGallery      () )
	on btnMergeModel pressed do (mergeModels       () )
	on btnRenModel   pressed do (renameModel       () )	
	on btnDelModel   pressed do (deleteFromGallery () )
	on btnHlp        pressed do (ShellLaunch helpFile "")
	
)-- end rollout

(
	local DPos  = execute(getINISetting mcUserINI "3DGallery" "Dialog_Gal_Pos" )
	local DSize = execute(getINISetting mcUserINI "3DGallery" "Dialog_Gal_Size")
	if DPos != undefined then
	(
		createDialog mcDgalleryDialog pos:DPos width:DSize.x height:DSize.y style:#(#style_titlebar, 
		#style_sysmenu, #style_minimizebox, #style_maximizebox, #style_sunkenedge, #style_resizing)
	)
	else
	(
		createDialog mcDgalleryDialog style:#(#style_titlebar, 
		#style_sysmenu, #style_minimizebox, #style_maximizebox, #style_sunkenedge, #style_resizing)
	)
) --rollout mcDgalleryDialog 
) --if doesFileExist mcUserINI
/*
		setINISetting useIniFile lastSubCat name_from_box (#(sysInfo.username,localTime) as string)	--save thumb info to ini
	
			local NetKeys = dotNetClass "System.Windows.Forms.Keys"
			if EventArgs.KeyCode == NetKeys.Enter then
			(
				format "Enter!\n"
				EventArgs.SuppressKeyPress = true
			)
		--flp_cat.Refresh() --flp_cat.update() --.SuspendLayout() --.ResetBindings()-- .ResetImeMode()

if mcDgalleryDialog != undefined do destroyDialog mcDgalleryDialog
try (DestroyDialog mcTextBoxDialog) catch()
*/	
	
/*
Many Thanks To:
LoneRobot
MarcoBrunetta
Mike Biddlecombe
/**/