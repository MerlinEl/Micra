--ooooooooooooooo--
--                      --
--   3D Gallery    --
--                      --
--ooooooooooooooo--
--------------------------------------
-- STANDALONE version 2018 --
--------------------------------------

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~--
-- Define Global Variables
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~--
Global mcGall
Global mc3DGallDEbug = true
Global mc3DGalleryDialog
Global mcTextBoxDialog
Global mc3DGallerySettingsDialog

Global mc3DGalleryRootDir = (getFilenamePath (getThisScriptFilename())) --set automatic root dir (at script loaction)
( --if custom dir is defined,then pick custom path
	local saved_dir =  mcFile.readSettings Micra.DefaultSettings "Gallery3D/Root_Dir"
	if saved_dir != "" do domc3DGalleryRootDir = saved_dir
)
Global mc3DGallerySettingsDir = mc3DGalleryRootDir + "_settings\\"
Global mc3DGalleryINI = mc3DGallerySettingsDir+"Settings.ini"	
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~--
-- Load Struct File	
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~--	
if mcGall == undefined  or mc3DGallDEbug then (
	local structFile = mc3DGallerySettingsDir+"Structures.ms"
	if doesFileExist structFile do fileIn structFile 
) else (
	print "mcGall  already loaded."
)
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~--
-- Create Dialod
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~--	
if doesFileExist mc3DGalleryINI do (
--
if mc3DGalleryDialog != undefined do destroyDialog mc3DGalleryDialog
--
rollout mc3DGalleryDialog " 3DGallery III: 0/0" width:754 height:608
(
	--> Local
	local gallery_filename = "Gallery3D_v1.61"
	local helpFile = mc3DGallerySettingsDir+"Help.doc" --TODO > make it PDF
	local Current_Dir = "", lastMainCat="", lastSubCat=""
	local cursors = dotNetClass "System.Windows.Forms.Cursors"
	local cursor = dotNetClass "System.Windows.Forms.Cursor"
	local cursor_harrow  = dotNetObject "System.Windows.Forms.Cursor" (mc3DGallerySettingsDir+"harrow.ico")
	local cursor_hmove   = dotNetObject "System.Windows.Forms.Cursor" (mc3DGallerySettingsDir+"hmove.ico")
	local cursor_hdrag  = dotNetObject "System.Windows.Forms.Cursor" (mc3DGallerySettingsDir+"hdrag.ico")
	--local cursor_harrow  = dotNetObject "System.Windows.Forms.Cursor" (mc3DGallerySettingsDir+"harrow.ico")
	--local cursor_hmove   = dotNetObject "System.Windows.Forms.Cursor" (mc3DGallerySettingsDir+"hmove.ico")
	local singleborder   = (dotNetClass "System.Windows.Forms.BorderStyle").fixedsingle	
	local dnfontlarge    = dotNetObject "System.Drawing.Font" "Verdana" 8.5 ((dotNetClass "System.Drawing.FontStyle").bold)
	local dnMXSlarge     = dotNetObject "System.Drawing.Font" "System" 8.5 ((dotNetClass "System.Drawing.FontStyle").bold)
	local dnfont         = dotNetObject "System.Drawing.Font" "Verdana" 6.5 ((dotNetClass "System.Drawing.FontStyle").bold)		
	local RButton        = (dotNetClass "System.Windows.Forms.MouseButtons").Right
	local LButton        = (dotNetClass "System.Windows.Forms.MouseButtons").Left
	local thumb_size     = mcGall.readINISettings "Thumb_Size"
	local selected_thumbs = #()
	local dnobjarray = #()
	local drag_enabled  = false, drag_start_pos, drag_end_pos, drag_offset = 25, DragTool, ground
	local tmr_max_count = 0;
	local timerFunction;
	--< Local
	
	-->Interface
	Timer timerDelay "Timer" pos:[716,16] width:24 height:24 enabled:true interval:100 active:false
	dotNetControl progbar "Windows.Forms.Progressbar" pos:[60,580] width:684 height:12
	--
	dropdownList ddlMainClass "" pos:[60,20] width:184 height:21
	dropdownList ddlSubClass "" pos:[320,20] width:184 height:21
	--
	button btnCreMainCls "" pos:[248,16] width:32 height:32 images:(mcGall.getIcon 11) toolTip:"Create Main Class"
	button btnDelMainCls "" pos:[280,16] width:32 height:32 images:(mcGall.getIcon 12) toolTip:"Delete Main Class"
	button btnCreSubCls "" pos:[508,16] width:32 height:32 images:(mcGall.getIcon 13) toolTip:"Create Sub Class"
	button btnDelSubCls "" pos:[540,16] width:32 height:32 images:(mcGall.getIcon 14) toolTip:"Delete Sub Class"
	button btnAddModel "" pos:[12,72] width:32 height:32 images:(mcGall.getIcon 1) toolTip:"Add Model: \n(press <Ctrl> to replace... <Shift> to preview...)"
	button btnAddScene "" pos:[12,104] width:32 height:32 images:(mcGall.getIcon 2) toolTip:"Add Scene: \n(press <Ctrl> to replace... <Shift> to preview...)"
	button btnHlp "" pos:[12,360] width:32 height:32 images:(mcGall.getIcon 8) toolTip:"Help..." enabled:true
	--
	checkbutton ckb_plant "" pos:[12,200] width:32 height:32 images:(mcGall.getIcon 4) toolTip:"Planting" enabled:true
	checkbutton ckbPSurf "" pos:[12,168] width:32 height:32 images:(mcGall.getIcon 3) toolTip:"Pick a surface for planting"
	checkbutton ckbCFG "" pos:[12,328] width:32 height:32 images:(mcGall.getIcon 7) toolTip:"3DGallery..." enabled:true
	checkbutton ckb_multi_plant "" pos:[12,232] width:32 height:32 images:(mcGall.getIcon 5) toolTip:"Multiplanting" enabled:false
	checkbutton ckb_plant_dialog "" pos:[12,264] width:32 height:32 images:(mcGall.getIcon 6) toolTip:"Plant Customize..." enabled:false
	--
	dotNetControl flp_cat "flowlayoutpanel" pos:[60,52] width:684 height:522
	--
	GroupBox grp_cat "Root Dir:" pos:[56,0] width:692 height:598
	GroupBox grp11 "Store:" pos:[4,56] width:48 height:88
	GroupBox grp12 "Paint:" pos:[4,152] width:48 height:152
	GroupBox grp13 "SetUp:" pos:[4,312] width:48 height:88
	--
	label lbl7 " Sub Dir:" pos:[336,0] width:44 height:16
	ImgTag tg_icn "" pos:[4,4] width:48 height:48 transparent:(color 0 0 0) --black
	--<Interface
	
-->functions
	fn resizeInterface size = (
		flp_cat.width  = size.x - 77
		flp_cat.height = size.y - 86
		grp_cat.width  = size.x - 68
		grp_cat.height = size.y - 8
		progbar.width  = size.x - 78
		progbar.pos.y  = size.y - 24
	)
	fn saveDialogSettings = (
		if mc3DGalleryDialog.placement == #minimized or mc3DGalleryDialog.placement == #maximized do return false  --thanks for this magicm
		local dSize = [mc3DGalleryDialog.width, mc3DGalleryDialog.height]
		local dSize = [mc3DGalleryDialog.width, mc3DGalleryDialog.height]
		mcGall.saveINISettings "Dialog_Gal_Size" (dSize as string)
		mcGall.saveINISettings "Dialog_Gal_Pos" ((getDialogPos mc3DGalleryDialog) as string)
	)
	fn selectAll = (
		selected_thumbs = #()
		for i=1 to flp_cat.controls.count do 
		(
			local itm = flp_cat.controls.item[i-1]
			selected_thumbs += #(itm)
			itm.forecolor = mcGall.dotnetColor red
		)
		mc3DGalleryDialog.title = " 3DGallery II: "+selected_thumbs.count as string+"/"+ (flp_cat.controls).count as string
	)
	fn clearSelectedItems = (
		for i in selected_thumbs do i.forecolor = mcGall.dotnetColor (color 176 196 222) 
		selected_thumbs = #()
		flp_cat.refresh()
		mc3DGalleryDialog.title = " 3DGallery II: 0/0"
	)
	fn removeFromSelection ctrl itmName = (
		for i=1 to selected_thumbs.count where selected_thumbs[i].text == itmName do
		(
			deleteItem selected_thumbs i
			exit
		)
		mc3DGalleryDialog.title = " 3DGallery II: "+selected_thumbs.count as string+"/"+ (flp_cat.controls).count as string
		ctrl.forecolor = mcGall.dotnetColor yellow
	)
	fn addToSelection ctrl itmName = (
		append selected_thumbs ctrl
		mc3DGalleryDialog.title = " 3DGallery II: "+selected_thumbs.count as string+"/"+ (flp_cat.controls).count as string
		ctrl.forecolor = mcGall.dotnetColor red
	)
	fn textBox default_text:"" = (
		
		mcGM.setParam "MC_TEXTBOX_DIALOG_DEFAULT_TEXT" default_text --transfer text in to dialog
		try (DestroyDialog mcTextBoxDialog) catch()
		rollout mcTextBoxDialog " Command Box v0.1" width:320 height:36
		(
			-->locals
			local theName = mcGM.getParam "MC_TEXTBOX_DIALOG_DEFAULT_TEXT" --pickup text from global variable
			local bgColor   = ((colorMan.getColor #background)*255)as color
			local winColor  = ((colorMan.getColor #window)*255)as color
			local textColor = ((colorMan.getColor #text)*255)as color
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
				local dnfontlarge = dotNetObject "System.Drawing.Font" "Verdana" 12 ((dotNetClass "System.Drawing.FontStyle").bold)
				edtBox.font = dnfontlarge
				edtBox.BackColor= mcGall.dotnetColor winColor
				edtBox.ForeColor= mcGall.dotnetColor (color 42 113 124) --textColor
				edtBox.AcceptsTab = true
				edtBox.Multiline = true --for enter to works
				--edtBox.MaxLength = 500
				edtBox.Text = theName
				edtBox.focus()
			)
			on edtBox keyPress a s do (textBoxControll a s method:#KeyPress)
  			--on edtBox keyUp    a s do (textBoxControll a s method:#KeyUp)
		)
		CreateDialog mcTextBoxDialog pos:(mcGall.centerDialogToMain [320,36]) style:#(#style_border)  modal:true --escapeEnable:true crashing!!!
		return mcTextBoxDialog.theName
	)
	fn renameModel = (
		--get selected item
		if selected_thumbs.count  > 1 do (mcGall.errorMsg 4 ; return false)
		if selected_thumbs.count != 1 do (mcGall.errorMsg 1 ; return false)
		
		local ctrl = selected_thumbs[1]

		local subPath = (mc3DGalleryRootDir+lastMainCat+"\\"+lastSubCat+"\\")
		local existingNames = (for i in (getFiles (subPath+"*.*")) collect (getFilenameFile i)) --check for duplicate names
		local textFromBox = textBox default_text:selected_thumbs[1].text		
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
		local cat_IniFile   = (mc3DGalleryRootDir+lastMainCat+".ini")
		
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
		mc3DGalleryDialog.loadGallery()
		print "Model(s) is renammed."
	)
	fn renderScene fpath:undefined render_type:#normal thumb_stamp:#scene = (
		--get ini setting for render
		local selectionOnly = render_type == #selection
		local anti = mcGall.readINISettings "AntiAliasing" 
		local samp = mcGall.readINISettings "PixelSampler" 
		local shad = mcGall.readINISettings "Shadows"
		local quei = mcGall.readINISettings "Quiet"
		--Render to vbf
		local oldBgColor = backgroundColor
		if (selectionOnly) do backgroundColor  = mcGall.readINISettings "Thumb_Color"
		local imgSize    = mcGall.readINISettings "Thumb_Render_Size"
		local img        = bitmap imgSize.x imgSize.y color:backgroundColor
		--render phase
		render outputsize:imgSize antiAliasing:anti enablePixelSampler:samp shadows:shad \
			   quiet:quei renderType:render_type to:img vfb:off -- outputFile:(fpath+".jpg")
	
		--stamp output image
		mcGall.stampBitmap img stamp:thumb_stamp
		--if path is undefined make render with prewiew
		if fpath == undefined then (
	
			mcGall.showBitmap img 
			
		) else (
			img.filename = fpath
			save img quiet:on
		)
		if (selectionOnly) do backgroundColor = oldBgColor -- return old bg color
		return img
	)
	fn openScene = (
		
		if (selected_thumbs.count == 0) do return false
		if (selected_thumbs.count > 1) do (
		
			mcGall.errorMsg 8
			return false
		)
		local max_file = Current_Dir+selected_thumbs[1].text+".max"
		if not doesFileExist max_file do (
		
			local ini_data = execute (mcGall.readIniData selected_thumbs[1].text)
			if (ini_data.count < 4) do return false
			max_file = ini_data[4] --pick link path at 4th place in arra
			if (not doesFileExist max_file) do (
			
				mcGall.errorMsg 9
				return false
			)
			--format "ini data:% max_file:%\n" max_file
		)
		if checkForSave() do loadMaxFile max_file --[useFileUnits:<bool>] [quiet:<bool>] 
		--check if is link or max file name
	)
	fn mergeModels unique:false = (
		if selected_thumbs.count == 0 do return false
		progbar.foreColor = mcGall.dotnetColor (color 176 196 222) 
		local merged_models = #()
		for i=1 to selected_thumbs.count do --undo "Merge Models" on
		(
			local f = Current_Dir+selected_thumbs[i].text+".max"
			if doesFileExist f do 
			(
				try   (mergeMAXFile f #useSceneMtlDups #mergeDups #select ) 
				catch (messagebox ( "Merging model:<" + selected_thumbs[i].text + "> is failed.\nFile is mising or is corupted." ) title: " Warning!")
				--prevent dupplicate names in scene
				if unique then (for o in selection do o.name = uniqueName (o.name))
			)
			progbar.value = 100.*i/selected_thumbs.count 
			merged_models += selection as array
			max select none
		)
		progbar.value = 0
		--setfocus mc3DGalleryDialog.flp_cat
		clearSelectedItems()
		select merged_models
	)
	fn moveSelectedTo = (
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
			
			fn loadMainCat2 =
			(
				if not (mcGall.fillDropDownList ddlMainClass (mc3DGalleryRootDir+"*.*")) do return false
				return true
			)
			fn loadSubCat2  =
			(
				if not (mcGall.fillDropDownList ddlSubClass (mc3DGalleryRootDir+ddlMainClass.selected+"\\*.*")) do return false
				return true
			)
			on mcMoveToDialog open do (if loadMainCat2() do loadSubCat2())
			on btn_cncl pressed  do destroyDialog mcMoveToDialog
			on btn_move pressed  do (
			
				local oldMainCat = lastMainCat
				local oldSubCat = lastSubCat
				local newMainCat = ddlMainClass.selected
				local newSubCat = ddlSubClass.selected
				 --prevent to move tags in to same directory
				if oldMainCat+oldSubCat != newMainCat+newSubCat then (
				
					local targetDir = mcGall.getCurrentDir dia:mcMoveToDialog
					if doesFileExist targetDir do(
					
						mcGall.moveSelectedItems targetDir
						destroyDialog mcMoveToDialog
					)
				)
				else (messagebox "Cant move to same directory. Chose another one." title:"  3DGallery!")
			)
			on ddlMainClass selected sel do (loadSubCat2())
		)
		CreateDialog mcMoveToDialog pos:(mcGall.centerDialogToMain [292,144]) style:#(#style_border)  modal:true
	)
	fn onMouseDown ctrl evnt =
    (
		--format "MouseDown: % [%]\n" ctrl (evnt.button.tostring())
		
		local itmName = ctrl.text
		if evnt.button == RButton then --"Show RC Menu"
		(
			if ctrl.forecolor != (mcGall.dotnetColor red) do addToSelection ctrl itmName

			rcMenu thumbMenu
			(
				menuItem new_1 "Merge..." --"Add To Scene with original names"
				menuItem new_8 "Merge Unique..." --"Add To Scene with unique names"
				menuItem new_7 "Open..." --"Open Scene..."
				separator file_menu_1
				menuItem new_5 "Select All.."
				menuItem new_4 "Clear Selection..."
				separator file_menu_2
				menuItem new_2 "Rename ..."
				menuItem new_6 "MoveTo ..."
				menuItem new_3 "Delete..."
				
				on new_1 picked do mergeModels()
				on new_8 picked do mergeModels unique:true
				on new_2 picked do renameModel()
				on new_3 picked do mcGall.deleteSelectedItems()
				on new_4 picked do clearSelectedItems() 
				on new_5 picked do selectAll() 
				on new_6 picked do moveSelectedTo() 
				on new_7 picked do openScene() 
			)
			PopupMenu thumbMenu
		)
		else if ctrl.forecolor == mcGall.dotnetColor red
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
		if ctrl.forecolor != (mcGall.dotnetColor red) do ctrl.forecolor = mcGall.dotnetColor yellow
		if DragTool == undefined do flp_cat.Cursor = cursor_harrow
    )
	fn onMouseLeave ctrl evnt = --drag and drop
    (
	   --format "MouseLeave % [%]\n" ctrl evnt
		if ctrl.forecolor !=  (mcGall.dotnetColor red) do ctrl.forecolor = mcGall.dotnetColor (color 176 196 222) 
		--edt_filter.text = "MouseLeave: " + ctrl.text 
    )
	fn onMouseMove ctrl evnt = (
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
	fn addImageToButton fpath = (
		local img_btn = dotnetobject "button"
		img_btn.size = dotnetobject "system.drawing.size" thumb_size.x thumb_size.y --160 120
		img_btn.forecolor = mcGall.dotnetColor (color 176 196 222)  --text color
		img_btn.margin =  dotnetobject "system.windows.forms.padding" 2 -- thumbs distance
		img_btn.flatstyle = (dotNetclass "System.Windows.Forms.FlatStyle").flat
		img_btn.FlatAppearance.BorderSize = 2
		img_btn.font= dnfont
		img_btn.text = getFilenameFile fpath	
		img_btn.name = img_btn.text
		img_btn.tag  = fpath
		img_btn.textalign =  (dotnetclass "System.Drawing.ContentAlignment").BottomCenter
		local fpath = dotNetObject "System.Drawing.Bitmap" fpath
		local img_copy = mcGall.resizeBitmapNET fpath thumb_size.x thumb_size.y
		fpath.Dispose()
		img_btn.Image = img_copy
		img_btn.AllowDrop = true
		--img_btn.showTooltip -- WIP	
		-- Setup an event handlers for both buttons
		dotnet.addEventHandler img_btn "MouseDown" onMouseDown
		dotnet.addEventHandler img_btn "MouseUp" onMouseUp
		dotnet.addEventHandler img_btn "MouseEnter" onMouseEnter
		dotnet.addEventHandler img_btn "MouseLeave" onMouseLeave
		dotnet.addEventHandler img_btn "MouseMove" onMouseMove
		--mcsystem.show fpath
		--gc()
		return img_btn
	)
	fn loadGallery = (
		selected_thumbs = #()
		flp_cat.controls.clear()
		Current_Dir = mc3DGalleryRootDir+lastMainCat+"\\"+lastSubCat+"\\"
		mcGall.saveINISettings  "Current_Dir" Current_Dir 
		--format "Current_Dir:%\n" Current_Dir
		if not doesFileExist Current_Dir do return false
		local Images_Array = getFiles (Current_Dir + "*.jpg")
		--change cursor to wait
		cursor.current = cursors.WaitCursor
		--progress bar
		progbar.foreColor = mcGall.dotnetColor (color 8 200 248) 
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
		mc3DGalleryDialog.title = " 3DGallery II: 0/"+ (flp_cat.controls).count as string
	)
	fn addScene = (
	
		if not (mcGall.bothDirsCreated lastMainCat lastSubCat) do (
			mcGall.errorMsg(5);
			return false
		)
		Current_Dir = mc3DGalleryRootDir+lastMainCat+"\\"+lastSubCat+"\\"
		if keyboard.shiftPressed do ( --render preview only
			renderScene()
			return OK
		)
		rollout mc3DGallerySceneDialog "3D Gallery Save Scene:" width:276 height:116(
			
			button btnAccept "Accept" pos:[8,88] width:72 height:20
			button btnCancel "Cancel" pos:[196,88] width:72 height:20
			GroupBox grpScene "Choice" pos:[4,4] width:268 height:108
			radiobuttons rdoCopySwitch "" pos:[28,60] width:222 height:16 labels:#("Copy Scene", "Create Shortcut") default:1 columns:2
			editText edtFileName "" pos:[24,28] width:228 height:24
			fn saveSceneCopy source_path img_path = (
		
				if not (doesFileExist source_path) do (

					messageBox "Scene must be saved. Operation Aborted." title:"3DGallery"
					return false
				)
				if (edtFileName.text.count == 0) do (
				
					mcGall.errorMsg 7
					return false
				)
				local target_path = Current_Dir + edtFileName.text + ".max"
				format "saveSceneCopy from:%  --> to:%\n " source_path target_path
				--copyFile source_path target_path
				if (not (doesFileExist target_path)) or querybox ("filename: "+edtFileName.text+ "\nexists. Overwrite?") then(
					
					copyFile source_path target_path
					--saveMaxFile target_path quiet:true --removed because of changing save location of current scene
				) else (
				
					return false
				)
				--save thumbnail
				renderScene fpath:img_path render_type:#normal thumb_stamp:#scene
				--store INI data
				mcGall.saveIniData edtFileName.text type:#scene
				return true
			)
			fn saveSceneLink source_path img_path = (
			
				--format "saveSceneLink source_path:%\n " source_path
				if not doesFileExist source_path do (
					mcGall.errorMsg 6
					return false
				)	
				--save thumbnail
				renderScene fpath:img_path render_type:#normal thumb_stamp:#link
				--store INI data with Max File path
				mcGall.saveIniData edtFileName.text type:#scene link:source_path
				return true
			)
			on mc3DGallerySceneDialog open do (
				edtFileName.text = getFilenameFile maxFileName
			)
			on rdoCopySwitch changed state do (
			
				case state of(
					1: edtFileName.enabled  = true
					2: (
						edtFileName.enabled  = false
						edtFileName.text = getFilenameFile maxFileName
					)
				)
			)
			on btnCancel pressed do (destroyDialog mc3DGallerySceneDialog)
			on btnAccept pressed do (
			
				local max_path = maxFilepath + maxFileName
				local img_path = Current_Dir + edtFileName.text+".jpg"
				--save max file or shortcut
				local success = case rdoCopySwitch.state of (
					1:(saveSceneCopy max_path img_path)
					2:(saveSceneLink max_path img_path)
				)
				if not success do return false
				--reload , resort gallery
				loadGallery()
				destroyDialog mc3DGallerySceneDialog
			)
		)
		createDialog mc3DGallerySceneDialog style:#(#style_titlebar, #style_sysmenu) modal:true
	)
	fn addModel = (

		if not (mcGall.bothDirsCreated lastMainCat lastSubCat) do (
			mcGall.errorMsg(5);
			return false
		)
		Current_Dir = mc3DGalleryRootDir+lastMainCat+"\\"+lastSubCat+"\\"
	
		if keyboard.shiftPressed do ( --render preview only
			renderScene render_type:#selection thumb_stamp:#model
			return OK
		)
		if selection.count == 0 do (mcGall.errorMsg 2; return false)
		if lastSubCat == undefined do (mcGall.errorMsg 3 ;return false)
		local name_from_box
		--replace selected thumbnail and model
		if keyboard.controlPressed then( 
			local thumb = selected_thumbs[1]
			name_from_box = if thumb == undefined then "" else thumb.name
		--add new model	
		) else (
			name_from_box = textBox()
		)
		if name_from_box == "" do return false
		--store INI data
		mcGall.saveIniData name_from_box type:#model
		--render selection 
		local img_path = Current_Dir+name_from_box+".jpg"
		local max_path = Current_Dir+name_from_box+".max"
		renderScene fpath:img_path render_type:#selection thumb_stamp:#model
		--save selection
		saveNodes selection max_path
		--reload , resort gallery
		loadGallery()
	)
	fn loadMainCat = ( --remember main dir where you browse last time
		--collect folders for main cat
		if not (mcGall.fillDropDownList ddlMainClass (mc3DGalleryRootDir+"*.*")) do return false
		--last main cat
		lastMainCat = mcGall.readINISettings "lastMainCat" asString:true
		if (local num = findItem ddlMainClass.items lastMainCat) != 0 
		then (ddlMainClass.selection = num)
		else (ddlMainClass.selection = 1 ; lastMainCat = ddlMainClass.items[1])
		return true
	)
	fn loadSubCat = 	( --remember sub dir where you browse last time

		--collect folders for sub cat
		if not (mcGall.fillDropDownList ddlSubClass (mc3DGalleryRootDir+lastMainCat+"\\*.*")) do (
			
			selected_thumbs = #()
			ddlSubClass.items = #()
			flp_cat.controls.clear()
			lastSubCat = undefined;
			return false
		)
		--last sub cat
		lastSubCat = mcGall.readINISettings "lastSubCat" asString:true
		if (local num = findItem ddlSubClass.items lastSubCat) != 0 
		then (ddlSubClass.selection = num)
		else (ddlSubClass.selection = 1 ; lastSubCat = ddlSubClass.items[1])
		loadGallery()
		return true
	)
	fn inicializeInterface = (
	
		-->resizing interface
		local dia_size = [mc3DGalleryDialog.width, mc3DGalleryDialog.height]
		resizeInterface dia_size
		
		-->Progress Bar
		--progbar.style = progbar.style.continuous
		progbar.backColor = mcGall.dotnetColor (color 40 45 66)

		--flp_cat.MaximumSize
		--flp_cat.MinimumSize
		flp_cat.AutoSize = true
		flp_cat.autoscroll = true
		flp_cat.padding = dotnetobject "system.windows.forms.padding" 2
		flp_cat.BackColor = mcGall.dotnetColor (color 40 45 66)
		
		-->load dropDown lists Main & Sub
		local sub_cat_found = if loadMainCat() then loadSubCat() else false
		--mcSystem.show flp_cat
		
		mcGall.loadImageTo tg_icn (mc3DGallerySettingsDir+"3DGallery_Icon.bmp")
		return true
	)
	fn createMainClass = (
		local existingNames = ddlMainClass.items --check for duplicate names
		local textFromBox = textBox()
		if textFromBox != "" do 
		(
			makeDir (mc3DGalleryRootDir+textFromBox)
			ddlMainClass.items = 
			(
				sort (ddlMainClass.items += #(textFromBox))	
			)
			ddlMainClass.selection = (findItem ddlMainClass.items textFromBox)
			--grp_cat.text = "Items: 0/0"
			lastMainCat = textFromBox
			lastSubCat = undefined;
			ddlSubClass.items = #()
			flp_cat.controls.clear() --remove old thumbs
		)
	)
	fn createSubClass = (
		local existingNames = ddlSubClass.items --check for duplicate names
		local textFromBox = textBox()
		if textFromBox != "" do 
		(
			makeDir (mc3DGalleryRootDir+lastMainCat+"\\"+textFromBox)
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
		local mainPath = (mc3DGalleryRootDir+lastMainCat)
		--check if some folders inside
		local dirs_count = (getDirectories (mainPath+"\\*.*")).count
		if dirs_count > 0 do
		(
			messageBox ( "The catalog:<"+lastMainCat+"> contain:<"+dirs_count as string+"> folder(s).") title: " Can't be deleted!"
			return false
		)
		--deleting folder
		DOSCommand ( "rd "+"\""+mainPath+"\"")
		loadGallery()
	)
	fn deleteSubClass = --you only delete empty folders
	(
		if lastSubCat == undefined do (return false)
		local subPath = (mc3DGalleryRootDir+lastMainCat+"\\"+lastSubCat)
		--check if max files inside	
		local files_count = (getFiles (subPath+"\\*.max")).count
		if files_count > 0 do 
		(
			messageBox ("The catalog:<"+lastSubCat+"> contain:<"+files_count as string+"> file(s).") title:" Can't be deleted!"
			return false
		)
		--deleting folder
		DOSCommand ( "rd "+"\""+subPath+"\""+" /s /q")
		loadSubCat()
	)
	--<functions

	-->Actions	
	on mc3DGalleryDialog open              do (if not inicializeInterface() do destroyDialog mc3DGalleryDialog)
	on mc3DGalleryDialog close             do (saveDialogSettings())
	on mc3DGalleryDialog resized size      do (resizeInterface size)
	on mc3DGalleryDialog lbuttondblclk pos do (loadGallery())
	on ddlMainClass selected sel          do( 
		
		if sel != 0 do
		(
			mcGall.saveINISettings  "lastMainCat" ddlMainClass.items[sel]
			lastMainCat = ddlMainClass.items[sel]
			loadSubCat()
		)
	)
	on ddlSubClass selected sel do (
		
		if sel != 0 do
		(
			mcGall.saveINISettings  "lastSubCat" ddlSubClass.items[sel]
			lastSubCat = ddlSubClass.items[sel]
			loadGallery()
		)
	)
	on btnCreMainCls pressed do (createMainClass	() )
	on btnDelMainCls pressed do (deleteMainClass	() )
	on btnCreSubCls  pressed do (createSubClass		() )
	on btnDelSubCls  pressed do (deleteSubClass		() )
	on btnAddModel   pressed do (addModel      		() )
	on btnAddScene   pressed do (addScene      		() )
	on btnHlp        pressed do (ShellLaunch helpFile "")
	on ckbPSurf changed state do (
	
		local obj = selection[1]
		if ckbPSurf.checked then(
			if obj != undefined then (
				ground = obj
				max create mode
				max select none
			) else ( 
				ckbPSurf.checked = false
			)
		) else (
			ground = undefined
		)
	)
	on ckbCFG changed state do(
		
		if state then(
			rollout mc3DGallerySettingsDialog "3D Gallery Settings:" width:324 height:468(

			GroupBox grp4 "" pos:[4,4] width:316 height:460
			ImgTag tagAboutImage "Button" pos:[12,20] width:300 height:80 bitmap:(bitmap 1 1 color:yellow)
			ImgTag tagThumbBg "Button" pos:[16,124] width:296 height:164 bitmap:(bitmap 1 1 color:yellow)
			ImgTag tagThSize "Button" pos:[18,126] width:140 height:128 bitmap:(bitmap 1 1 color:green)
			slider sldThSize "Size: [150,120]" pos:[20,288] width:292 height:44 range:[0,10,5] type:#integer ticks:10
			button btnCancel "Cancel" pos:[8,440] width:72 height:20
			button btnAccept "Accept" pos:[244,440] width:72 height:20
			GroupBox grp5 "Render:" pos:[16,336] width:152 height:92
			label lbl1 "AntiAliasing:" pos:[28,360] width:104 height:16
			label lbl2 "PixelSampler:" pos:[28,376] width:104 height:16
			label lbl3 "Shadows:" pos:[28,392] width:104 height:16
			label lbl4 "Quiet:" pos:[28,408] width:104 height:16
			checkbox chkAnti "" pos:[136,360] width:21 height:18
			checkbox chkSamp "" pos:[136,376] width:21 height:18
			checkbox chkShad "" pos:[136,392] width:21 height:18
			checkbox chkQuei "" pos:[136,404] width:21 height:18
			colorPicker cpThumbsBgColor "Background Color:" pos:[172,364] width:136 height:20 color:(color 255 255 0) title:"Choose a color"
			colorPicker cpRenderBgColor "Thumb Color:        " pos:[172,340] width:136 height:20 color:(color 255 255 0) title:"Choose a color"
			GroupBox grp11 "Thumbnail:" pos:[12,108] width:304 height:324
			label lbl_galpath "Gallery path:" pos:[172,392] width:96 height:20 align:#left
			button btn_browse_dir "..." pos:[268,390] width:40 height:20 align:#left
				
				fn saveSettings =(
					mcGall.saveINISettings "Thumb_Size"	([tagThSize.width,tagThSize.height] as string)
					mcGall.saveINISettings "Thumb_Color"	(cpRenderBgColor.color  as string)
					mcGall.saveINISettings "Thumb_BgColor"	(cpThumbsBgColor.color  as string)
					mcGall.saveINISettings "AntiAliasing"	(chkAnti.checked  as string)
					mcGall.saveINISettings "PixelSampler"	(chkSamp.checked  as string)
					mcGall.saveINISettings "Shadows"		(chkShad.checked  as string)
					mcGall.saveINISettings "Quiet"		(chkQuei.checked  as string)
				)
				fn readSettings =(
					local render_color = mcGall.readINISettings "Thumb_Color"
					local thumb_bgcolor = mcGall.readINISettings "Thumb_BgColor"
					local thumb_size = mcGall.readINISettings "Thumb_Size"
					chkAnti.checked  = mcGall.readINISettings "AntiAliasing"
					chkSamp.checked  = mcGall.readINISettings "PixelSampler"
					chkShad.checked  = mcGall.readINISettings "Shadows"
					chkQuei.checked  = mcGall.readINISettings "Quiet"       
					cpRenderBgColor.color  = render_color
					cpThumbsBgColor.color = thumb_bgcolor
					mcGall.loadImageTo tagAboutImage (mc3DGallerySettingsDir+"3DGall_About_01.bmp")
					tagThumbBg.bitmap = bitmap 1 1 color:thumb_bgcolor
					tagThSize.bitmap = bitmap 1 1 color:render_color
					tagThSize.width  = thumb_size.x
					tagThSize.height = thumb_size.y
					sldThSize.value  = (thumb_size.x-100)/10
					sldThSize.text   = ( "Size: " +([thumb_size.x,thumb_size.y] as string))
				)
				fn setGlalleryPath = (
				
					local gallery_dir = getSavePath caption:" Chose Models Directory..." initialDir:micra.RootDir
					if gallery_dir == undefined or not (doesDirectoryExist gallery_dir) do return false
					format "chossen dir:%\n" gallery_dir
					mcFile.saveSettings Micra.UserSettings "Gallery3D/Root_Dir" (gallery_dir+"\\") -- Set start profile to default
					destroyDialog mc3DGalleryDialog
					destroyDialog mc3DGallerySettingsDialog
					fileIn (gallery_dir + "\\" + mc3DGalleryDialog.gallery_filename + ".ms")
				)
				on mc3DGallerySettingsDialog open  do (readSettings())
				on mc3DGallerySettingsDialog close do (mc3DGalleryDialog.ckbCFG.checked = false)
				on btnCancel pressed do (destroyDialog mc3DGallerySettingsDialog)
				on btnAccept pressed do (saveSettings(); mcGall.reloadMainDialog() ; destroyDialog mc3DGallerySettingsDialog)
				on cpRenderBgColor changed col do (tagThSize.bitmap  = bitmap 1 1 color:col)
				on cpThumbsBgColor changed col do (tagThumbBg.bitmap  = bitmap 1 1 color:col)	
				on btn_browse_dir pressed do setGlalleryPath()
				on sldThSize changed val do
				(		
					tagThSize.width  = 100+(10*val)
					tagThSize.height = 80+(8*val)
					sldThSize.text = ( "Size: " +([tagThSize.width,tagThSize.height] as string))
				)
			)	
			createDialog mc3DGallerySettingsDialog style:#(#style_titlebar, #style_sysmenu) --modal:true
		)
		else (destroyDialog mc3DGallerySettingsDialog)
	)
)-- end rollout mc3DGalleryDialog 
--oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo--

local DPos  = mcGall.readINISettings "Dialog_Gal_Pos"
local DSize = mcGall.readINISettings "Dialog_Gal_Size"
createDialog mc3DGalleryDialog pos:DPos width:DSize.x height:DSize.y style:#(#style_titlebar, 
#style_sysmenu, #style_minimizebox, #style_maximizebox, #style_sunkenedge, #style_resizing)
) --if doesFileExist mc3DGalleryINI

/*
tmr_max_count = 1
timerDelay.active = true
fn timerFunction = mcGall.centerRenderWindowDialog()
on timerDelay tick do (


	--format "timer progress tick:% max:%\n" timerDelay.ticks tmr_max_count
	tmr_max_count -= 1
	if tmr_max_count <= 0 do (
		
		timerDelay.active = false
		tmr_max_count = 0
		timerFunction()
		--format "timer stop at :%\n" timerDelay.ticks
	)
)
*/


/*
Many Thanks To:
LoneRobot
MarcoBrunetta
Mike Biddlecombe
/**/