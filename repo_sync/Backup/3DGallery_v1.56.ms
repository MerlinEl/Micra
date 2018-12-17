------------------
------------------
--              --
--  3D Gallery  --
--              --
------------------
------------------
Global mcDGalleryExtr
Global mcDgalleryDialog
Global mcMultiPlanterDialog
Global mcMultiPlanterEnabled
Global mcGallerySettingsDialog
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~--
--oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo--

if mcDgalleryDialog != undefined do destroyDialog mcDgalleryDialog

--oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo--
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~--
rollout mcDgalleryDialog " 3D Gallery v1.0" width:628 height:420
(
	--Locals:--------------------------------------------------------------------
	local fun, dnd, helpFile, spnDist, spnSens, lastPos, activeObj, lastPick, plantType, ground, 
	maualSpinAxis, plantOrientation, plantSnapOffset, singleSize, singleRotation, singlePosition, 
	lockSiz, lockRot, lockPos, rootPath, ObjectListArray , multipack = #(), timer_delay = 0, 
	old_mousepos, new_mousepos, mps, activeMultiObj, PaintMarker, PreserveOverlaps = false, 
	clonesArray = #()
	local colorclass = dotnetclass "system.drawing.color"
	local cursor    = dotNetClass "System.Windows.Forms.cursor"
	local cursor_harrow  = dotNetObject "System.Windows.Forms.Cursor" (mcImgPath+"harrow.ico")
	local cursor_hmove   = dotNetObject "System.Windows.Forms.Cursor" (mcImgPath+"hmove.ico")
	local cursor_hdrag  = dotNetObject "System.Windows.Forms.Cursor" (mcImgPath+"hdrag.ico")
	-----------------------------------------------------------------------------
	GroupBox grpPth "Path:" pos:[64,56] width:560 height:360
	timer tmr_resize "Timer" pos:[4,4 ] width:24 height:24 enabled:true interval:100 active:false
	timer tmr_drag   "Timer" pos:[4,30] width:24 height:24 enabled:true interval:10  active:false
	timer tmr_cursor "Timer" pos:[4,30] width:24 height:24 enabled:true interval:10  active:false
	--
	bitmap bmpBg1 "Bitmap" pos:[72,20] width:268 height:28 bitmap:(BitMap 1 1 color:(color 244 220 50))
	bitmap bmpBg2 "Bitmap" pos:[348,20] width:268 height:28 bitmap:(BitMap 1 1 color:(color 50 200 240))
	dropdownList ddlMainClass "" pos:[76,24] width:260 height:21
	dropdownList ddlSubCalss "" pos:[352,24] width:260 height:21
	--
	button btnCreMainCls "" pos:[8,24] width:24 height:24 images:(mcCall.getIcon 161) toolTip:"Create Main Class"
	button btnDelMainCls "" pos:[32,24] width:24 height:24 images:(mcCall.getIcon 150) toolTip:"Delete Main Class"
	button btnCreSubCls "" pos:[8,48] width:24 height:24 images:(mcCall.getIcon 142) toolTip:"Create Sub Class"
	button btnDelSubCls "" pos:[32,48] width:24 height:24 images:(mcCall.getIcon 141) toolTip:"Delete Sub Class"
	button btnAddModel "" pos:[32,104] width:24 height:24 images:(mcCall.getIcon 149) toolTip:"Add selection to Library  (hold <Ctrl> preview, hold <Shift> name from object)"
	button btnMergeModel "" pos:[8,104] width:24 height:24 images:(mcCall.getIcon 147) toolTip:"Add selection to Scene  (hold <Ctrl> disable automatic rename)"
	button btnRenModel "" pos:[8,128] width:24 height:24 images:(mcCall.getIcon 144) toolTip:"Rename Model"
	button btnDelModel "" pos:[32,128] width:24 height:24 images:(mcCall.getIcon 148) toolTip:"Delete Selected Models (hold <Shift> silent delete>"
	checkbutton ckb_plant "" pos:[8,208] width:24 height:24 images:(mcCall.getIcon 145) toolTip:"Planting"
	checkbutton ckbPSurf "" pos:[8,184] width:24 height:24 images:(mcCall.getIcon 146) toolTip:"Pick a surface for planting"
	checkbutton ckb_cfg "" pos:[8,288] width:24 height:24 images:(mcCall.getIcon 143) toolTip:"3DGallery..."
	checkbutton ckb_multi_plant "" pos:[32,208] width:24 height:24 images:(mcCall.getIcon 163) toolTip:"Multiplanting"
	checkbutton ckb_plant_dialog "" pos:[32,184] width:24 height:24 images:(mcCall.getIcon 164) toolTip:"Plant Customize..."
	checkbutton ckb_dir_plant "" pos:[8,232] width:24 height:24 images:(mcCall.getIcon 145) toolTip:"Directional Planting"
	checkbutton ckb_x_plant "" pos:[32,232] width:24 height:24 images:(mcCall.getIcon 145) toolTip:"X Planting"
	
	button btnHlp "" pos:[32,288] width:24 height:24 images:(mcCall.getIcon 162) toolTip:"Help..."
	dotNetControl progbar "Windows.Forms.Progressbar" pos:[64,428] width:555 height:8
	--
	--
	label lbl4 "Main class:" pos:[72,4] width:180 height:16
	label lbl5 "Sub class:" pos:[348,4] width:180 height:16
	--
	subRollout subRollThumbs "" pos:[72,76] width:544 height:336--[544,14]
	GroupBox grp8 "Catalog:" pos:[4,4] width:56 height:76
	GroupBox grp11 "Models:" pos:[4,84] width:56 height:76
	GroupBox grp12 "Paint:" pos:[4,164] width:56 height:100
	GroupBox grp13 "Setting:" pos:[4,268] width:56 height:52
	-----------------------------------------------------------------------------
	/* Structures */
	struct thumbnail (ImageFilePath, MaxFilePath, LocalDir, FileName)
	struct InterfaceStruct
	(
		-->Variables:------------------------------------------------------------
		lastMainCat,lastSubCat,existingNames,activeSubRoll, selected_tag_active = false,
		hilightThumb, selectedTags=#(), selectedLbls=#(), jpg_files = #(),
		-->Functions:------------------------------------------------------------
		fn getLastDir path =
		(
			local arr = ( filterString path "\\" )
			return arr[arr.count]
		),
		fn centerDialogToMain my_size =
		(
			local dPos  = getDialogPos mcDgalleryDialog
			local dSize = getDialogSize mcDgalleryDialog
			return (dPos + dSize/2 - my_size/2)
		),
		fn compressFile archiveFile filename =
		(
			print "maz archiveFile filename"
		),
		fn uncompressFile archiveFile outputDir =
		(
			print "unmaz archiveFile outputDir"
		),
		fn loadMainCat = --remember main dir where you browse last time
		(
			local mainDirs = sort(getDirectories (rootPath+"*.*"))
			if mainDirs.count == 0 do (ddlMainClass.items = #(); lastMainCat = undefined; return false)
			ddlMainClass.items = for i in mainDirs collect (getLastDir i)--cut the last dir from path
			--last main cat
			lastMainCat = getINISetting mcUserINI "3DGallery" "lastMainCat"
			if (local num = findItem ddlMainClass.items lastMainCat) != 0 
			then (ddlMainClass.selection = num)
			else (ddlMainClass.selection = 1 ; lastMainCat = ddlMainClass.items[1])
			return true
		),
		fn loadSubCat = --remember sub dir where you browse last time
		(
			if lastMainCat == undefined do return false
			local subDirs = sort(getDirectories (rootPath+lastMainCat+"\\*.*"))
			if subDirs.count == 0 do (ddlSubCalss.items = #(); grpPth.text = "Path:Undefined"; lastSubCat = undefined; return false)
			--ddlSubCalss.items = for i in subDirs collect (getLastDir i)--cut the last dir from path
			progbar.foreColor = colorclass.blue
			ddlSubCalss.items = #()
			for i=1 to subDirs.count do 
			(
				ddlSubCalss.items += #(getLastDir subDirs[i])
				progbar.value = 100.*i/subDirs.count 
			)
			progbar.value = 0 
			--last sub cat
			lastSubCat = getINISetting mcUserINI "3DGallery" "lastSubCat"
			if (local num = findItem ddlSubCalss.items lastSubCat) != 0 
			then (ddlSubCalss.selection = num)
			else (ddlSubCalss.selection = 1 ; lastSubCat = ddlSubCalss.items[1])
			--show path from sub cat
			grpPth.text = ("Path:"+rootPath+lastMainCat+"\\"+lastSubCat)
			return true
		),
		fn textBox =
		(
			rollout mcTextBoxDialog " Command Box v0.1" width:444 height:40
			(
				edittext edtBox "New Name:" pos:[12,12] width:312 height:18 bold:true
			 	button btnAcpt "Accept" pos:[332,12] width:48 height:16
			 	button btnCncl "Cancel" pos:[384,12] width:48 height:16
			 	groupBox grpTx "" pos:[4,0] width:436 height:36
				fn filterText text =
				(
					local enterFound = false
					local last_leter = text[text.count] -- get last letter
					--The name cannot contain any of the following characters \/:*?"<>|
					local bad_char = case bit.charAsInt last_leter of
					(
						10: (enterFound = true)--enter
						92: (true) --\
						47: (true) --/
						42: (true) --*
						58: (true) --:
						63: (true) --?
						34: (true) --"
						60: (true) --<
						62: (true) -->
						124:(true) --|
						--32: (true) --:space
						--61: (true) --=
						--33: (true) --!
					)
					--format "letter:%\tchar:%\tbad_char:%\n" last_leter (bit.charAsInt last_leter) bad_char
					if bad_char != undefined do -- if bad character found?
					(
						text = substring text 1 (text.count - 1)-- removes last letter from text
					)
					return #(text, enterFound)
				)
				on mcTextBoxDialog open do (setFocus edtBox)
			 	on mcTextBoxDialog rbuttonup pos do(edtBox.text = "" ;destroyDialog mcTextBoxDialog)
				on btnAcpt pressed do
			 	( 
					local theName = edtBox.text
					if theName != "" do --if textbox conatin text
					(
						if   (findItem existingNames theName) == 0 --check for duplicate names
						then (DestroyDialog mcTextBoxDialog)
						else (messagebox ("The name:<"+theName+"> is allready exist.") title:" 3D Gallery;)" ; setFocus edtBox)
					)
			 	)
				on edtBox changed text do
				(
					if text != "" do --if textbox conatin text
					(
						-- detect if enter pressed
						local filter_data = filterText text
						if filter_data[2] == true 
						then 
						(
							edtBox.text = filter_data[1]
							btnAcpt.pressed()
						)
						else edtBox.text = filter_data[1]
					)
				)
			 	on btnCncl pressed     do (edtBox.text = "" ;destroyDialog mcTextBoxDialog)
			)
			CreateDialog mcTextBoxDialog pos:(centerDialogToMain [444,40]) style:#(#style_border)  modal:true
			return mcTextBoxDialog.edtBox.text
		),
		fn manageInterfaceItems diaSize =
		(
			--mcDgalleryDialog Min Size=[262,392]
			if diaSize.x > 260 do
			(
				grpPth.width        = (diaSize.x - 4 - grpPth.pos.x)
				subRollThumbs.width = (diaSize.x - 8 - subRollThumbs.pos.x)
				progbar.width       = (diaSize.x + 4 - subRollThumbs.pos.x)
			)
			if diaSize.y > 392 do
			(
				grpPth.height        = (diaSize.y - 60 - 14)
				subRollThumbs.height = (diaSize.y - 88 - 14)
				progbar.pos.y        = (diaSize.y - 13)
			)
		),
		fn setBorder tag color =
		(
			local imgSize = execute (getIniSetting mcUserINI "3DGallery" "Thumb_Render_Size")
			local img     = tag.bitmap
			local size    = imgSize - [1,1]
			
			for tb=0 to size.x do --top bottom
			( 
				setpixels img [tb,0] #(color)
				setpixels img [tb,size.y] #(color)
			)
			for lr=0 to size.y do --left right 
			(
				setpixels img [0,lr] #(color)
				setpixels img [size.x,lr] #(color)
			)
			tag.bitmap = img
		),
		fn higlightThumbs tag lbl state = --for this function need assinged struct instance: fun
		(
			case state of 
			(
				#dragend:
				(
					--
					tmr_drag.active = false
					old_mousepos = undefined
					new_mousepos = undefined
					cursor.Current = cursor_harrow
					--
					local selected_tag = findItem fun.selectedTags tag 
					if selected_tag != 0 and not fun.selected_tag_active do --unmark
					(
						local t = fun.selectedTags[selected_tag]
						local fPath = tag.bitmap.filename
						if not doesFileExist fPath do return false -- if thumbnail file is missing
						t.bitmap = openBitMap fPath -- restore tags img
						setBorder tag yellow  --set it hilighted
						deleteItem fun.selectedTags selected_tag
						deleteItem fun.selectedLbls selected_tag
					)
				)
				#hilight:
				(
					cursor.Current = cursor_harrow
					local fPath = tag.bitmap.filename
					if not doesFileExist fPath do return false -- if thumbnail file is missing
					fun.hilightThumb   = fPath
					if findItem fun.selectedTags tag != 0 do return false -- if selected not hilight
					setBorder tag yellow 
				)
				#select: 
				(
					if dnd.drag_enabled do return false
					cursor.Current = cursor_hmove
					tmr_drag.active = true
					local selected_tag = findItem fun.selectedTags tag 
					if selected_tag == 0 
					then --mark
					(
						fun.selected_tag_active = true
						fun.selectedTags += #(tag)
						fun.selectedLbls += #(lbl)
						local fPath = tag.bitmap.filename
						if not doesFileExist fPath do return false -- if thumbnail file is missing
						setBorder tag red 
					)
					else --if tag is marked then realse active tag
					(
						fun.selected_tag_active = false
					)
				)
				#restore:
				(
					if findItem fun.selectedTags tag != 0 do return false -- if selected not clear
					if fun.hilightThumb == undefined do return false -- if thumb has ben deleted
					tag.bitmap = openBitMap fun.hilightThumb
					fun.hilightThumb == undefined
				)
			)
			--format "fun.selectedTags:%\n" fun.selectedTags
		),
		fn getAcrossPos count subRollWidth thumbSize thumbPos offset:[2,2] labelHeight:13 =
		(
			if count == 1 do (thumbPos = offset ; return (thumbPos as string)) -- in first time
			if (local newPos = thumbPos.x + thumbSize.x + offset.x) < (subRollWidth - thumbSize.x) then --new column
			(
				thumbPos.x = newPos
			)
			else --new line
			(
				thumbPos.x  = offset.x
				thumbPos.y += (thumbSize.y + offset.y + labelHeight)
			)
			--format "thumbPos:%\tsubRollWidth:%\n" thumbPos (subRollWidth + thumbSize.x)
			return (thumbPos as string)
		),
		fn filterPath path =
		(
			local p  = filterString path "\\"
			local fp = ""
			for i=1 to (p.count - 1) do (fp += p[i] + "\\\\")
			local pa =  (fp+p[p.count])
			if pa[2] != ":" do pa = ("\\\\\\\\" + pa )
			return pa
		),
		fn deleteSubrollout =
		(
			if activeSubRoll != undefined and classOf activeSubRoll == RolloutClass do (removeSubRollout subRollThumbs activeSubRoll)
		),
		fn createSubrollout = -->DINAMIC ROLLOUT<--
		(	
			deleteSubrollout()--remove old subRollout
			
			if lastMainCat == undefined or lastSubCat == undefined do return false
			
			local thumbSize    = execute (getIniSetting mcUserINI "3DGallery" "Thumb_Size")
			local thumbPos     = [2,2]
			local subRollWidth = subRollThumbs.width
			local thumbBgColor = "(color 120 34 150)"
			jpg_files = getFiles (rootPath+lastMainCat+"\\"+lastSubCat+"\\*.jpg")
			local thumbCount = jpg_files.count --saved models count
			--format "thumbSize:%\t thumbPos:%\t subRollWidth:%\t jpg_files:%\n thumbCount:%\n" thumbSize thumbPos subRollWidth jpg_files thumbCount
		
			--create newRoll string for Subrollout
			local newRoll      = "rollout roll"+ lastSubCat + " \"" + lastSubCat + "\"\n" --width:368 height:1000
			newRoll +="(\n"
			if thumbCount > 0 do
			(
				--local variables
				newRoll += "\tlocal thumbSize    = "+thumbSize as string+"\n"
				--functions
				newRoll += "\tfn getLabelPos tag = ([tag.pos.x,tag.pos.y + tag.height])\n"
				--thumbnails
				for n=1 to thumbCount do
				(
					local nu = n as string --number
					local tagPos  = (getAcrossPos n subRollWidth thumbSize thumbPos offset:[2,2] labelHeight:13)
					local creationDate = getFileCreateDate jpg_files[n]
					local ImageFilePath = filterPath jpg_files[n]
					local lbl = getFilenameFile ImageFilePath
					--Buttons and Labels
					newRoll +="\tImgTag tag_" +nu+ " \"thumb_" +nu+ "\" width:thumbSize.x height:thumbSize.y \ 
						tooltip:" + "\"" + creationDate + "\" bitmap:(openBitMap" + " \"" + ImageFilePath + "\") pos:"+tagPos+" transparent:"+thumbBgColor+" style:#bmp_stretch\n"
					newRoll +="\tlabel  lbl_" +nu+ " \"" +lbl+ "\" pos:(getLabelPos tag_" +nu+ ") width:thumbSize.x height:13 align:#left\n"
					--Actions
					newRoll +="\ton tag_"+nu+" mouseup      do (mcDGalleryExtr.higlightThumbs  tag_"+nu+" lbl_"+nu+" #dragend )\n"
					newRoll +="\ton tag_"+nu+" mousedown do (mcDGalleryExtr.higlightThumbs  tag_"+nu+" lbl_"+nu+" #select )\n"
					newRoll +="\ton tag_"+nu+" mouseover  do (mcDGalleryExtr.higlightThumbs tag_"+nu+" lbl_"+nu+" #hilight)\n"
					newRoll +="\ton tag_"+nu+" mouseout    do (mcDGalleryExtr.higlightThumbs  tag_"+nu+" lbl_"+nu+" #restore)\n"
					newRoll +="\ton tag_"+nu+" rightclick     do (mcDGalleryExtr.showMenu tag_"+nu+" lbl_"+nu+" )\n"
				)
			)
			newRoll +=")\n"
			AddSubRollout subRollThumbs (execute newRoll)
			activeSubRoll = (execute ("roll"+ lastSubCat))
			return true
		),
		fn inicializeVariables =
		(
			spnDist          = execute (getIniSetting mcUserINI "3DGallery" "Plant_Distance"   )
			spnSens          = execute (getIniSetting mcUserINI "3DGallery" "Plant_Sensitivity") 
			maualSpinAxis    = execute (getIniSetting mcUserINI "3dGallery" "Maual_Spin_Axis"  ) 
			plantOrientation = execute (getIniSetting mcUserINI "3dGallery" "Plant_Orientation")
			plantSnapOffset  = execute (getIniSetting mcUserINI "3dGallery" "Plant_Snap_Offset")
			singleSize       = execute (getIniSetting mcUserINI "3dGallery" "Single_Size"      )
			singleRotation   = execute (getIniSetting mcUserINI "3dGallery" "Single_Rotation"  )
			singlePosition   = execute (getIniSetting mcUserINI "3dGallery" "Single_Position"  ) 
			lockSiz          = execute (getIniSetting mcUserINI "3dGallery" "Lock_Size"        )
			lockRot          = execute (getIniSetting mcUserINI "3dGallery" "Lock_Rotation"    )
			lockPos          = execute (getIniSetting mcUserINI "3dGallery" "Lock_Position"    )
			helpFile = mcPath()+"Help\\3DGallery.doc"
		),
		fn inicializeCatalogs =
		(
			--check for models path
			if not doesFileExist mcUserINI do return false
			rootPath = (getINISetting mcUserINI "3DGallery" "rootPath")
			--i not found try to user set
			if not doesFileExist rootPath do
			(
				if mcGallerySetupDialog != undefined do destroyDialog mcGallerySetupDialog
				rollout mcGallerySetupDialog " Inicialize 3DGallery Database:" width:332 height:148
				(
					GroupBox grpDir "Please put you 3DGallery directory..." pos:[8,4] width:316 height:136
					button btnSetDir "Set Dir" pos:[16,108] width:164 height:24
					bitmap bmpPop1 "Bitmap" pos:[16,24] width:300 height:80 fileName:(mcPath()+"Img\\3DGall_About_01.bmp")
					button BtnCancel "Cancel" pos:[252,108] width:64 height:24
					on btnCancel pressed  do (destroyDialog mcGallerySetupDialog; destroyDialog mcDgalleryDialog)
					on btnSetDir pressed  do 
					(
						local galRootPath = (getSavePath caption:"Chose Catalog Directory.")
						if galRootPath != undefined do
						(
							setINISetting mcUserINI "3DGallery" "rootPath" (galRootPath+"\\")
							destroyDialog mcGallerySetupDialog
						)
					)
				)
				createDialog mcGallerySetupDialog style:#(#style_toolwindow) modal:true
			)
			--check again
			rootPath     = (getINISetting mcUserINI "3DGallery" "rootPath")
			--if not found return false
			if not doesFileExist rootPath do return false
			--load main dirs to dll
			if not loadMainCat() do return false
			--load sub dirs to dll
			if not loadSubCat() do return false
			--load thumbnails from files
			createSubrollout()
		),
		fn createMainClass =
		(
			existingNames = ddlMainClass.items --check for duplicate names
			local textFromBox = textBox()
			if textFromBox != "" do 
			(
				makeDir (rootPath+textFromBox)
				ddlMainClass.items = 
				(
					sort (ddlMainClass.items += #(textFromBox))	
				)
				ddlMainClass.selection = (findItem ddlMainClass.items textFromBox)
				grpPth.text = "Path:Undefined"--show path from sub cat
				lastMainCat = textFromBox
				ddlSubCalss.items = #()
				deleteSubrollout()--remove old subRollout
			)
		),
		fn createSubClass =
		(
			existingNames = ddlSubCalss.items --check for duplicate names
			local textFromBox = textBox()
			if textFromBox != "" do 
			(
				makeDir (rootPath+lastMainCat+"\\"+textFromBox)
				ddlSubCalss.items = 
				(
					sort (ddlSubCalss.items += #(textFromBox))	
				)
				ddlSubCalss.selection = (findItem ddlSubCalss.items textFromBox)
				grpPth.text = ("Path:"+rootPath+lastMainCat+"\\"+textFromBox)--show path from sub cat
				lastSubCat = textFromBox
				deleteSubrollout()--remove old subRollout
			)
		),
		fn deleteMainClass = --you only delete empty folders (security reason)
		(
			if lastMainCat == undefined do (return false)
			local mainPath = (rootPath+lastMainCat)
			--check if some folders inside
			local dirs_count = (getDirectories (mainPath+"\\*.*")).count
			if dirs_count > 0 do
			(
				messageBox ( "The catalog:<"+lastMainCat+"> contain:<"+dirs_count as string+"> folder(s).") title: " Can't be deleted!"
 				return false
 			)
			--deleting ini user file
			local useIniFile = (rootPath+"User_"+lastMainCat+".ini")
			if doesFileExist useIniFile do (deleteFile useIniFile)
			--deleting folder
			DOSCommand ( "rd "+"\""+mainPath+"\"")
			inicializeCatalogs()
		),
		fn deleteSubClass = --you only delete empty folders
		(
			if lastSubCat == undefined do (return false)
			local subPath = (rootPath+lastMainCat+"\\"+lastSubCat)
			--check if max files inside	
			local files_count = (getFiles (subPath+"\\*.max")).count
			if files_count > 0 do 
			(
				messageBox ("The catalog:<"+lastSubCat+"> contain:<"+files_count as string+"> file(s).") title:" Can't be deleted!"
 				return false
 			)
			--deleting keys
			local useIniFile = (rootPath+"User_"+lastMainCat+".ini")
			if doesFileExist useIniFile do (delINISetting useIniFile lastSubCat)
			--deleting folder
			DOSCommand ( "rd "+"\""+subPath+"\""+" /s /q")
			fun.loadSubCat()
			fun.createSubrollout()
		),
		fn renderModel filePath:undefined =
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
			       quiet:quei renderType:#selection to:img vfb:off -- outputFile:(filePath+".jpg")
			--if path is undefined make render with prewiew
			if filePath == undefined 
			then (display img)
			else 
			(
				img.filename = filePath
				save img quiet:on
			)
			backgroundColor  = oldBgColor -- return old bg color
			return img
		),
		fn moveToGroup =
		(
			if fun.selectedTags.count == 0 do return false
			if mcMoveToDialog != undefined do destroyDialog mcMoveToDialog
			rollout mcMoveToDialog " Move To" width:292 height:144
			(
				GroupBox grpPth "" pos:[4,0] width:284 height:140
				bitmap bmpBg1 "Bitmap" pos:[12,28] width:268 height:28 bitmap:(BitMap 1 1 color:(color 244 220 50))
				bitmap bmpBg2 "Bitmap" pos:[12,76] width:268 height:28 bitmap:(BitMap 1 1 color:(color 50 200 240))
				dropdownList ddlMainClass "" pos:[16,32] width:260 height:21
				dropdownList ddlSubCalss "" pos:[16,80] width:260 height:21
				label lbl4 "Main class:" pos:[12,12] width:180 height:16
				label lbl5 "Sub class:" pos:[12,60] width:180 height:16
				button btn_cncl "Cancel" pos:[172,112] width:108 height:20
				button btn_move "Move" pos:[12,112] width:108 height:20
				fn loadSubCat2  =
				(
					local subDirs  = sort(getDirectories (rootPath+ddlMainClass.selected+"\\*.*"))
					ddlSubCalss.items  = for i in subDirs collect (getLastDir i)--cut the last dir from path
				)
				fn loadMainCat2 =
				(
					local mainDirs = sort(getDirectories (rootPath+"*.*"))
					if mainDirs.count == 0 do return false
					ddlMainClass.items = for i in mainDirs collect (getLastDir i)--cut the last dir from path
					return true
				)
				fn getDir =
				(
					local m_cl = ddlMainClass.selected
					local s_cl = ddlSubCalss.selected
					if m_cl == undefined and s_cl == undefined do return ""
					return (rootPath+m_cl+"\\"+s_cl+"\\")
				)
				fn updateIni fName =
				(
					--write new
					local m_cl = ddlMainClass.selected
					local s_cl = ddlSubCalss.selected
					local newIniFile   = (rootPath+"User_"+m_cl+".ini")
					if not doesFileExist newIniFile do return false
					setINISetting newIniFile s_cl fName (#(sysInfo.username,localTime) as string)
					--delete old
					local m_cl = fun.lastMainCat
					local s_cl = fun.lastSubCat
					local oldIniFile   = (rootPath+"User_"+m_cl+".ini")
					if not doesFileExist oldIniFile do return false
					delINISetting oldIniFile s_cl fName -- delete key
				)
				on mcMoveToDialog open do (if loadMainCat2() do loadSubCat2())
				on btn_cncl pressed  do destroyDialog mcMoveToDialog
				on btn_move pressed  do
				(
					local oldMainCat = fun.lastMainCat
					local oldSubCat = fun.lastSubCat
					local newMainCat = ddlMainClass.selected
					local newSubCat = ddlSubCalss.selected
					if oldMainCat+oldSubCat != newMainCat+newSubCat then --prevent to move tags in to same directory
					(
						local targetDir = getDir()
						if doesFileExist targetDir do
						(
							for i in fun.selectedTags do
							(
								local iFilePath = i.bitmap.filename
								local p = getFilenamePath iFilePath
								local n = getFilenameFile iFilePath
								local mFilePath = p+n+".max"
								local iFilePathNew = targetDir+n+".jpg"
								local mFilePathNew = targetDir+n+".max"
								if doesFileExist mFilePath do 
								try
								(
									--moving files to another folder
									copyFile iFilePath iFilePathNew
									copyFile mFilePath mFilePathNew
									--delete files (.max , .jpg)
									deleteFile iFilePath
									deleteFile mFilePath
									--update ini
									updateIni n
								)
								catch ()
							)
							--clear variables
							fun.hilightThumb  = undefined
							fun.selectedTags  = #() 
							fun.selectedLbls  = #()
							fun.createSubrollout()--create a buttons and load thummbnails
							destroyDialog mcMoveToDialog
						)
					)
					else (messagebox "Cant move to same directory. Chose another one." title:"  3DGallery!")
				)
				on ddlMainClass selected sel do (loadSubCat2())
			)
			CreateDialog mcMoveToDialog pos:(fun.centerDialogToMain [292,144]) style:#(#style_border)  modal:true
		),
		fn addModel =
		(
			if keyboard.controlPressed  
			then renderModel()
			else
			( 
				if selection.count == 0 do (messageBox "Select some object to add." title:"3DGallery!" ;return false)
				if lastSubCat == undefined do (messageBox "Create <Sub clas> catalog." title:"3DGallery!" ;return false)
				local subPath = (rootPath+lastMainCat+"\\"+lastSubCat+"\\")
				existingNames = (for i in (getFiles (subPath+"*.*")) collect (getFilenameFile i)) --check for duplicate names
				--get name for thumbnail
				local textFromBox
				if keyboard.shiftPressed 
				then textFromBox = selection[1].name
				else textFromBox = textBox()
				if textFromBox == "" do return false
				--render selection 
				renderModel filePath:(subPath+textFromBox+".jpg")
				--save selection
				saveNodes selection (subPath+textFromBox+".max")
				--security lock and user data
				local useIniFile   = (rootPath+"User_"+lastMainCat+".ini")
				if not doesFileExist useIniFile do
				(
					local f = createFile useIniFile
					close f
				)
				-- save some settings for every model
				setINISetting useIniFile lastSubCat textFromBox (#(sysInfo.username,localTime) as string) 
				--clear variables
				hilightThumb  = undefined
				selectedTags  = #() 
				selectedLbls  = #()
				--reload catalog
				createSubrollout()--create a buttons and load thummbnails
			)
		),
		fn deleteModels =
		(		
			if fun.selectedTags.count == 0 do return false
			local deleteSilent = keyboard.shiftPressed
			local useIniFile   = (rootPath+"User_"+lastMainCat+".ini")
			--confirmation question
			if not deleteSilent do
			(
				if not (queryBox ( "You are sure to delete selected model(s)?") title:"Deleting...") do return false
			)
			for i in fun.selectedTags do
			(
				local iFilePath = i.bitmap.filename
				local p = getFilenamePath iFilePath
				local n = getFilenameFile iFilePath
				local mFilePath = p+n+".max"
				if doesFileExist mFilePath do 
				local bin_dir = rootPath + "Recycle Bin\\All\\"
				local bin_ini = rootPath + "User_Recycle_Bin.ini"
				--move files (.max , .jpg) to local Recycle Bin or delete
				if lastMainCat+"\\"+lastSubCat+"\\" != "Recycle_Bin\\All\\" 
				then --if current dir is not recycle bin
				(
					local bin_iFilePath =bin_dir + filenameFromPath iFilePath
					local bin_mFilePath =bin_dir + filenameFromPath mFilePath
					--if in Recycler is the same files, then delete them
					if doesFileExist bin_iFilePath do deleteFile bin_iFilePath
					if doesFileExist bin_mFilePath do deleteFile bin_mFilePath
					--move to Recycle Bin
					copyFile iFilePath bin_iFilePath
					copyFile mFilePath bin_mFilePath
					--add ini data to Recycle_Bin.ini
					if doesFileExist bin_ini do setINISetting bin_ini "All" n (#(sysInfo.username,localTime) as string)
					--remove data from ini
					delINISetting useIniFile lastSubCat  n -- delete key
				)
				else
				(
					--delete data from Recycle_Bin.ini
					if doesFileExist bin_ini do delINISetting bin_ini "All" n
				)
				--delete files
				deleteFile iFilePath
				deleteFile mFilePath
			)
			--clear variables
			hilightThumb  = undefined
			selectedTags  = #() 
			selectedLbls  = #()
			--reload catalog
			createSubrollout()
			
			--local cmd = ("move /Y"+" "+file+" "+(bin_dir + filenameFromPath file))
			--DOSCommand cmd
			/*
			--checkinf file attrib -- assing is (setFileAttribute filePath #readOnly false)
			--password check
			if doesFileExist useIniFile do
			(
				local data     = execute (getINISetting useIniFile lastSubCat ATD.FileName)
				local password = sysInfo.username
				--local password =  (getINISetting mcUserINI "" "password")
				if (password != "" and data != OK and data[1] != password)
				then
				(
					messageBox ("The file:<" + ATD.FileName + "> is protected from erase by: "+ data[1]) title:" Warning!"
					return false
				)
				else (delINISetting useIniFile lastSubCat ATD.FileName)
			)
			--format "lanUser:%\tcurrUser:%\n" data[1] password
			--mcDgalleryDialog.subRollThumbs.rollCaps.tag_1.visible = off
			--print "Model deleted."
			*/
		),
		fn renameModels =
		(
			if fun.selectedTags.count == 0 do return false
		

			--fun.selectedTags = ???
			--fun.selectedLbls = ???
			
			/*
			if selectedLbl == undefined or ATD == undefined do (messageBox "Select a model to rename." title:"3DGallery!" ;return false)
			local subPath = (rootPath+lastMainCat+"\\"+lastSubCat+"\\")
			existingNames = (for i in (getFiles (subPath+"*.*")) collect (getFilenameFile i)) --check for duplicate names
			local textFromBox = textBox()
			if textFromBox == "" do return false 
			--rename files (.max and .jpg)
			local oldfName = ATD.FileName
			local newfName = textFromBox
			local oldMaxF =(subPath+ oldfName + ".max")
			local oldImgF =(subPath+ oldfName + ".jpg")
			local newMaxF =(subPath+ newfName + ".max")
			local newImgF =(subPath+ newfName + ".jpg")	
			renameFile oldMaxF newMaxF
			renameFile oldImgF newImgF
			--rename variable in Active Thumb Data
			local pa = (getFilenamePath ATD.ImageFilePath)
			ATD.ImageFilePath = (pa + textFromBox + ".jpg")
			selectedLbl.caption = textFromBox --label
			--print "Model is renammed."
			*/

		),
		fn deselectAllModels =
		(
			if fun.selectedTags.count == 0 do return false
			for i=1 to fun.selectedTags.count do 
			(
				local tag = fun.selectedTags[i]
				fPath = tag.bitmap.filename
				if not doesFileExist fPath != BitMap do return false -- if thumbnail file is missing
				tag.bitmap = openBitMap fPath -- restore tags img
			)
			fun.selectedTags = #()
			fun.selectedLbls = #()
		),
		fn selectAllModels = 
		( 
			if fun.jpg_files.count == 0 do return false
			fun.selectedTags = #()
			fun.selectedLbls = #()
			for i=1 to fun.jpg_files.count do 
			(
				local tag
				try (tag = execute ("mcDgalleryDialog.subRollThumbs.rollouts[1].tag_"+i as string)) 
				catch (print ("Can't be selected: "+fun.jpg_files[i]))
				if tag == undefined do exit
				fun.selectedTags += #(tag)
				fun.selectedLbls += #(getFilenameFile fun.jpg_files[i])
				setBorder tag red
			)
		),
		fn mergeModels =
		(
			if fun.selectedTags.count == 0 do return false
 			local mergedObjects = #()
			local uniqueNames = not keyboard.controlPressed
			for i in fun.selectedTags do 
			(
				local p = getFilenamePath i.bitmap.filename
				local n = getFilenameFile i.bitmap.filename
				local mFilePath = p+n+".max"
				if doesFileExist mFilePath do print mFilePath
				try   
				(
					mergeMAXFile mFilePath #useSceneMtlDups #mergeDups #select
					if uniqueNames then (for o in selection do o.name = uniqueName (o.name+"_"))
					mergedObjects += selection as array
				) 
				catch 
				(
					messagebox ( "Merging model:<" + mFilePath + "> is failed.\nFile is mising or is corupted." ) title: " Warning!"
				)
			)
			if mergedObjects.count != 0 do select mergedObjects
			--deselect tags
			deselectAllModels()
		),
		fn showMenu tag lbl= --"Show RC Menu"
		(
			--higlightThumbs tag lbl #select
			rcMenu thumbMenu
			(
				menuItem new_1 "Merge To Scene...(hold Ctrl => no Auto Rename...)"
				separator file_menu_1
				menuItem new_2 "Select All..."
				menuItem new_3 "DeselectAll..."
				menuItem new_4 "Rename ..."
				menuItem new_5 "Move To..."
				separator file_menu_2
				menuItem new_6 "Delete...(hold Shift => Silent Delete...)"
				on new_1 picked   do fun.mergeModels()
				on new_2 picked   do fun.selectAllModels()
				on new_3 picked   do fun.deselectAllModels()
				on new_4 picked   do fun.renameModels()
				on new_5 picked   do fun.moveToGroup()
				on new_6 picked   do fun.deleteModels()
			)
			PopupMenu thumbMenu
		),
		fn isOverlapping obj arr = 
		(
			--local rect_a = #([obj.min.x, obj.min.y, obj.max.x], [obj.min.x, obj.min.y, obj.max.y])
			for i in arr do 
			(
				--local rect_b = #([i.min.x  , i.min.y  , i.max.x  ], [i.min.x  , i.min.y  , i.max.y  ])
				local int = intersects obj i 
				--format "int:%\tobj:%\ti:%\n" int obj i
				if int do return true
			)
			return false
		),
		fn createMultipack =
		(
			--delete old multipack
			try delete multipack catch ()
			multipack = #()
			if  ObjectListArray == undefined or ObjectListArray.maxFilePath.count == 0 do return false
			--create multipack, merge it in scene and hide
			pushprompt "Building packet..."
			--progressStart "Building packet..."
			progbar.foreColor = colorclass.blue
			for i=1 to ObjectListArray.maxFilePath.count do
			(
				if doesFileExist ObjectListArray.maxFilePath[i] do 
				(
					local fobj_nam = getMaxFileObjectNames ObjectListArray.maxFilePath[i] --filter this from group childs rene
					mergeMAXFile ObjectListArray.maxFilePath[i] #useSceneMtlDups #mergeDups
					for n in fobj_nam where getNodeByName n != undefined do 
					(
						local node = getNodeByName n
						node.pos = [0,0,-100]
						multipack += #(node)
					)
				)
				progbar.value = 100.*i/ObjectListArray.maxFilePath.count
			)
			progbar.value = 0
			pushprompt "Building packet done."
			--hide multipack
		),
		fn mergeModelsPlant ir =
		(
			if multipack.count == 0 do return false
			--randomize by min max
			--if all items have the same value (percentage)
			local nums = for i in ObjectListArray.Percentage collect i as integer
			sort  nums
			if nums[1] == nums[nums.count]
			then 
			(
				--print "all is the same"
				activeMultiObj = multipack[random 1 multipack.count]
			)
			else
			( 
				local end  = 0
				local data = #()
				for i=1 to ObjectListArray.Percentage.count do
				(
					local num = ObjectListArray.Percentage[i] as integer
					data[i] = #{end+1..num+end}
					end += num	
				)
				--data:#(#{1}, #{2..3}, #{4..6)
				--random value from max num
				local randomVal = random 1 end
				--find obj index from data
				for i=1 to data.count where findItem data[i] randomVal != 0 do 
				(
					activeMultiObj = multipack[i]
					--format "object index:%\n" i
					exit
				)
				--format "data:%\tend:%\trandomVal:%\tactiveMultiObj:%\n" data end randomVal activeMultiObj
			)
			--clone and plant activeMultiObj
			if activeMultiObj == undefined do return false --nobody win
			local p = ir.pos
			if lastPos != undefined then ( p = (lastPos + (normalize (ir.pos - lastPos)) *spnDist) )
			local clone = copy activeMultiObj
			local d = case plantOrientation of
			(
				1: ir.dir
				2: ground.dir
				3: [0,0,1]
			)
			clone.pos = mps.snapByOffset p d --p d
			clone.dir = d 
			lastPos  = ir.pos
			unhide clone
			-->randomize
			mps.randomize singleRotation #rotation obj:clone
			mps.randomize singleSize     #size     obj:clone
			mps.randomize singlePosition #position obj:clone
			
			--check for overlaps
			if PreserveOverlaps and finished == true do 
			(
				--print "next object"
				if isOverlapping clone clonesArray 
				then (delete clone; print ("deleted"+clone.name))
				else (clonesArray += #(clone))
			)
		),
		fn reloadDialog =
		(
			destroyDialog mcDgalleryDialog
			DPos  = execute(getIniSetting mcUserINI "3DGallery" "Dialog_Gal_Pos" )
			DSize = execute(getIniSetting mcUserINI "3DGallery" "Dialog_Gal_Size")
			createDialog mcDgalleryDialog pos:DPos width:DSize.x height:DSize.y style:#(#style_titlebar, 
			#style_sysmenu, #style_minimizebox, #style_maximizebox, #style_sunkenedge, #style_resizing)		
		),
		fn saveDialogSettings =
		(
			if mcDgalleryDialog.placement == #minimized or mcDgalleryDialog.placement == #maximized do return false  --thanks for this magicm
			local dSize = [mcDgalleryDialog.width, mcDgalleryDialog.height]
			setINISetting mcUserINI "3DGallery" "Dialog_Gal_Size" (dSize as string)
			setINISetting mcUserINI "3DGallery" "Dialog_Gal_Pos"  ((getDialogPos mcDgalleryDialog) as string)
		)
	)
	-->Function
	struct MultipaintStruct
	(	
		fn rotate oldViewPoint newViewPoint =
		(
			case maualSpinAxis of
			(
				1:
				(
					if oldViewPoint.y < newViewPoint.y 
					then in coordsys local activeObj.rotation.x_rotation += spnSens
			 		else in coordsys local activeObj.rotation.x_rotation -= spnSens
				)
				2:
				(
					if oldViewPoint.x < newViewPoint.x 
					then in coordsys local activeObj.rotation.y_rotation += spnSens
			 		else in coordsys local activeObj.rotation.y_rotation -= spnSens
				)
				3:
				(
					if oldViewPoint.z < newViewPoint.z 
					then in coordsys local activeObj.rotation.z_rotation += spnSens
			 		else in coordsys local activeObj.rotation.z_rotation -= spnSens
				)
			)
		),
		fn randomize val type obj:activeObj =
		(
			if val == [0,0,0] do return false
			local r= random -val val
			case type of
			(
				#rotation :
				(
					--format "the rotation:%\n" r
					in coordsys local
					(
						obj.rotation.z_rotation += r.z
						obj.rotation.x_rotation += r.x
						obj.rotation.y_rotation += r.y
					)
				)
				#size     :
				(
					--format "the scale:%\n" r
					if lockSiz do r = [r.x, r.x, r.x]
					--in coordsys local
					(
						obj.scale += r /100 as float
					)
				)
				#position :
				(
					--format "the pos:%\n" r
					in coordsys local obj.pos += r
				)
			)
		),
		fn snapByOffset pos dir =
		(
			pos + dir * plantSnapOffset
		),
		fn paint msg ir obj faceNum shift ctrl alt = 
		(
			disableSceneRedraw()
			--format "msg:%\tir:%\tobj:%\tfaceNum:%\tshift:%\tctrl:%\talt:%\n"  msg ir obj faceNum shift ctrl alt
			if ir != undefined do 
			(
				--Create Paint Marker
				if PaintMarker == undefined do
				(
					PaintMarker = circle radius:10 pos:ir.pos wireColor:(color 80 250 80) displayRenderMesh:true name:"PaintMarker" thickness = 2
				)
				PaintMarker.pos = ir.pos
				PaintMarker.dir = ir.dir
				
				--Paint models
				case msg of
				(
					#mouseMove:
					(
						if activeObj != undefined and ctrl then --rotation mode 
						(
							if lastPick == undefined do lastPick = ir.pos
							mps.rotate lastPick ir.pos
						)	
						else if lastPos != undefined then --continue planting in line
						( 
							local d = distance ir.pos lastPos
							if (activeObj != undefined or activeMultiObj != undefined) and d > spnDist do 
							(
								local p = (lastPos + (normalize (ir.pos - lastPos)) *spnDist)
								case plantType of
								(
									#single:
									(
										local clone = copy activeObj
										local d = case plantOrientation of
										(
											1: ir.dir
											2: obj.dir
											3: [0,0,1]
										)
										clone.pos = mps.snapByOffset p d
										clone.dir = d  
										activeObj = clone
										-->randomize
										mps.randomize singleRotation #rotation
										mps.randomize singleSize     #size
										mps.randomize singlePosition #position
									)
									#multi:(fun.mergeModelsPlant ir)
								)
								lastPos=p
							)
						)
						else -- plant new line
						(
							case plantType of
							(
								#single:
								(
									fun.mergeModels()
									activeObj = selection[1]
									if activeObj != undefined do
									(
										local d = case plantOrientation of
										(
											1: ir.dir
											2: obj.dir
											3: [0,0,1]
										)
										activeObj.pos = mps.snapByOffset ir.pos d
										lastPos  = ir.pos
										activeObj.dir = d
										max select none
									)
								)
								#multi:(fun.mergeModelsPlant ir)
							)
						)
					)
					#mousePoint: 
					(
						lastPos = undefined --ending draw a line
						clonesArray = #()
						--format "singleSize:%\tsingleRotation:%\tsinglePosition:%\n" singleSize singleRotation  singlePosition
					)
				)
			)
			enableSceneRedraw()
			if msg != #mouseAbort then #continue else 
			(
				format "deleting multipack:%\n" multipack
				try delete multipack catch ()
				try delete PaintMarker catch ()
				multipack   = #()
				PaintMarker = undefined
			)
		)
	)
	struct DRAG_AND_DROP
	(
		ground, ground_tmp, marker_tmp, drag_enabled = false,
		fn dragAndDrop msg ir obj faceNum shift ctrl alt=
		(	   
			tmr_cursor.active = false --stop cursor timer 
			--cursor.Current = cursor_hdrag --shows cursor in the max interface
			--prevent mousetrack double runs 
			drag_enabled = true
			
			--drag_enabled = true
			--'shift', 'ctrl' and 'alt'
			
			if ir == undefined do
			(
				local view_ray = mapScreenToWorldRay mouse.pos
				--intersection between a line and a plane (grid [0,0,0])
				local projected_point = mcMath.planeLineIntersect [0,0,0] [0,0,1] view_ray.pos view_ray.dir
				ir = ray projected_point [0,0,1]
			)

			case msg of
			(
				#freeMove:
				(
					if IsValidNode marker_tmp then 
					(
						if shift 
						then marker_tmp.dir = ir.dir
						else marker_tmp.dir = [0,0,1]
						marker_tmp.pos = ir.pos
					)
				)
				#mouseMove:
				( 
					--print "mouse move"
					
				)
				#mousePoint:
				(
					--print "mouse up"
					if activeObj == undefined 
					then
					(
						print "merge objs"
						--merge and select models from gallery
						fun.mergeModels() 
						--create temp marker and link object(s) to him
						local sel = selection as array
						local btm = 
						(
							if sel.count == 1
							then sel[1].pos
							else selection.center - [0, 0, selection.max.z/2]
						)
						marker_tmp.pos = btm
						sel.parent = marker_tmp
						--activeObj = marker_tmp
					)
					--else if shift then 
					(
						print "shift and clone"
						--delete marker_tmp
						--activeObj = copy activeObj
					)
					--else exit
				)
				#mouseAbort: 
				(
					exit
				)
			)
			#continue 
		)
	)
	-->Dialog
	on mcDgalleryDialog open do
	(
		mcDGalleryExtr   = InterfaceStruct()
		fun               = InterfaceStruct()
		mps               = MultipaintStruct()
		dnd               = DRAG_AND_DROP()
		fun.manageInterfaceItems (getDialogSize mcDgalleryDialog)
		fun.inicializeVariables()
		fun.inicializeCatalogs()
		mcDgalleryDialog.title = " 3D Gallery " + (getIniSetting mcDefaultINI "Version" "3DGallery")
	)
	on mcDgalleryDialog close             do 
	(
		fun.saveDialogSettings()
		--delete old multipack
		try delete multipack catch ()
		try delete PaintMarker catch ()
		if mcMultiPlanterDialog != undefined do closeRolloutFloater mcMultiPlanterDialog
	)
	on mcDgalleryDialog rbuttonup pos     do (DestroyDialog mcDgalleryDialog)
	on mcDgalleryDialog lbuttondblclk pos do (fun.reloadDialog())
	on mcDgalleryDialog resized size      do (tmr_resize.active = true )
	on tmr_resize tick do --update delay is 100ms
	(
		fun.manageInterfaceItems (getDialogSize mcDgalleryDialog)
		if fun.activeSubRoll != undefined and classOf fun.activeSubRoll == RolloutClass do 
		(
			removeSubRollout subRollThumbs fun.activeSubRoll
			AddSubRollout subRollThumbs fun.activeSubRoll
		)
		tmr_resize.active = false -- turn timer off 
	)
	on tmr_cursor tick do ( cursor.Current = cursor_hdrag )
	on tmr_drag tick do --update delay is 10ms
	(
		if old_mousepos == undefined do (old_mousepos = mouse.screenpos)
		new_mousepos = mouse.screenpos
		
		if (distance old_mousepos new_mousepos) > 8 do -- drag start's when distance from drag start is more than 4pix
		(
			print "drag is start's..."
			--print ("drag distance: "+(distance old_mousepos new_mousepos) as string+"pix")
			tmr_drag.active = false
			tmr_cursor.active = true --shows cursor ower gallery interface
			--define ground
			if not IsValidNode dnd.ground then
			(
				local sel = selection[1]
				if sel != undefined and superClassOf sel == GeometryClass --if surface is selected use his as ground
				then (dnd.ground = sel)
				else
				(
					dnd.ground_tmp = (plane width:10000 length:10000 name:"3DGallery_Tmp_Ground" )
					hide (dnd.ground = dnd.ground_tmp)
				)
			)
			--create marker
			dnd.marker_tmp = dummy name:"3DGallery_DND_Dummy_Tmp"
			
			max create mode
			--max select none

			--stopTool dnd.dragAndDrop
			mouseTrack on:dnd.ground snap:#3D trackCallback:dnd.dragAndDrop
			dnd.drag_enabled = false
			--delete temp ground
			if IsValidNode dnd.ground_tmp do 
			(
				delete dnd.ground_tmp
				dnd.ground_tmp = undefined
			)
			--delete temp dummy marker
			delete dnd.marker_tmp
			--clear variables
			activeObj      = undefined
			old_mousepos   = undefined
			if IsValidNode dnd.ground do select dnd.ground
			print "drag end's..."
		)

	)
	on ddlMainClass selected sel do 
	( 
		setINISetting mcUserINI "3DGallery" "lastMainCat" ddlMainClass.items[sel]
		fun.lastMainCat = ddlMainClass.items[sel]
		fun.loadSubCat()
		fun.createSubrollout()
		--clear variables
		fun.selectedTags  = #()
		fun.selectedLbls  = #()
	)
	on ddlSubCalss  selected sel do 
	(
		setINISetting mcUserINI "3DGallery" "lastSubCat" ddlSubCalss.items[sel]
		fun.lastSubCat = ddlSubCalss.items[sel]
		--show path from sub cat
		grpPth.text = ("Path:"+rootPath+fun.lastMainCat+"\\"+fun.lastSubCat)
		--load thumbnails from files
		fun.createSubrollout()
		--clear variables
		fun.selectedTags  = #()
		fun.selectedLbls  = #()
	)
	on btnCreMainCls pressed  do (fun.createMainClass() )
	on btnDelMainCls pressed  do (fun.deleteMainClass() )
	on btnCreSubCls pressed   do (fun.createSubClass () )
	on btnDelSubCls pressed   do (fun.deleteSubClass () )
	on btnAddModel pressed    do (fun.addModel())
	on btnMergeModel pressed  do (fun.mergeModels     () )
	on btnRenModel pressed    do (fun.renameModels    () )	
	on btnDelModel pressed    do (fun.deleteModels    () )
	on btnHlp pressed         do (ShellLaunch helpFile "")
	on ckbPSurf changed state do 
	(
		local sel = selection[1]
		if ckbPSurf.checked 
		then
		(
			if sel != undefined then (ground = sel ; max select none) else (ckbPSurf.checked = false)
		)
		else 
		(
			ground = undefined
		)
	)
	on ckb_plant changed state do 
	(	
		if state then
		(
			ckb_multi_plant.enabled = false
			plantType = #single
			max create mode
			max select none
			if ground != undefined do mouseTrack on:ground trackCallback:mps.paint
			ckb_plant.checked = false
			ckb_multi_plant.enabled = true
			enableSceneRedraw()
		)
		else
		(
			ckb_plant.checked = true
		)
	)
	on ckb_multi_plant changed state do
	( 
		if state then
		(
			mcMultiPlanterEnabled  = true
			ckb_plant.enabled       = false
			plantType = #multi
			max create mode
			max select none
			fun.createMultipack()
			if ground != undefined do mouseTrack on:ground trackCallback:mps.paint
			mcMultiPlanterEnabled  = false
			ckb_multi_plant.checked = false
			ckb_plant.enabled       = true
			enableSceneRedraw()
		)
		else
		(
			ckb_multi_plant.checked = true
		)
	)
	on ckb_plant_dialog changed state do 
	(
		if state 
		then (mcFileInVersion "Multi_Planter") 
		else (if mcMultiPlanterDialog != undefined do closeRolloutFloater mcMultiPlanterDialog)
	)
	-->configuration
	on ckb_cfg changed state do
	(
		if state then
		(
			rollout mcGallerySettingsDialog "3D Gallery Settings:" width:428 height:296
			(
				GroupBox grp4 "Properies:" pos:[8,4] width:416 height:288
				--button btnDefault "Reset To Default" pos:[16,264] width:100 height:20
				colorPicker cpBgColor "Thumb Background Color:" pos:[20,236] width:186 height:20 color:(color 255 255 0) title:"Choose a color"
				ImgTag tagThSize "Button" pos:[16,22] width:150 height:120 bitmap:(bitmap 1 1 color:yellow) --min [100,80] max [200,160]
				slider sldThSize "Thumb Size: [150,120]" pos:[20,186] width:200 height:44 range:[0,10,5] type:#integer ticks:10
				button BtnCancel "Cancel" pos:[16,264] width:72 height:20
				button btnAccept "Accept" pos:[344,264] width:72 height:20
				button btnChgangeDir "Change Dir" pos:[236,64] width:124 height:24
				GroupBox grp5 "Local Render Settings:" pos:[224,100] width:192 height:156
				label lbl1 "AntiAliasing:" pos:[236,124] width:104 height:16
				label lbl2 "PixelSampler:" pos:[236,140] width:104 height:16
				label lbl3 "Shadows:" pos:[236,156] width:104 height:16
				label lbl4 "Quiet:" pos:[236,172] width:104 height:16
				checkbox chkAnti "" pos:[344,122] width:21 height:18
				checkbox chkSamp "" pos:[344,138] width:21 height:18
				checkbox chkShad "" pos:[344,154] width:21 height:18
				checkbox chkQuei "" pos:[344,170] width:21 height:18

				GroupBox grp13 "System:" pos:[224,16] width:192 height:80
				fn saveSettings =
				(
					setINISetting mcUserINI "3DGallery" "Thumb_Size"   ([tagThSize.width,tagThSize.height] as string)
					setINISetting mcUserINI "3DGallery" "Thumb_Color"  (cpBgColor.color  as string)
					setINISetting mcUserINI "3DGallery" "AntiAliasing" (chkAnti.checked  as string)
					setINISetting mcUserINI "3DGallery" "PixelSampler" (chkSamp.checked  as string)
					setINISetting mcUserINI "3DGallery" "Shadows"      (chkShad.checked  as string)
					setINISetting mcUserINI "3DGallery" "Quiet"        (chkQuei.checked  as string)
				)
				fn readSettings =
				(
					local col = execute(getIniSetting mcUserINI "3DGallery" "Thumb_Color")
					local sze = execute(getIniSetting mcUserINI "3DGallery" "Thumb_Size" )
					chkAnti.checked  = execute(getIniSetting mcUserINI "3DGallery" "AntiAliasing" )
					chkSamp.checked  = execute(getIniSetting mcUserINI "3DGallery" "PixelSampler")
					chkShad.checked  = execute(getIniSetting mcUserINI "3DGallery" "Shadows"      )
					chkQuei.checked  = execute(getIniSetting mcUserINI "3DGallery" "Quiet"        )       
					cpBgColor.color  = col
					tagThSize.bitmap = bitmap 1 1 color:col
					tagThSize.width  = sze.x
					tagThSize.height = sze.y
					sldThSize.value  = (sze.x-100)/10
					sldThSize.text   = ( "Thumb Size: " +([sze.x,sze.y] as string))
				)
				on mcGallerySettingsDialog open  do (readSettings())
				on mcGallerySettingsDialog close do (mcDgalleryDialog.ckb_cfg.checked = false)
				on btnCancel pressed do (destroyDialog mcGallerySettingsDialog)
				on btnAccept pressed do (saveSettings(); fun.reloadDialog(); destroyDialog mcGallerySettingsDialog)
				on cpBgColor changed col do (tagThSize.bitmap  = bitmap 1 1 color:col)
				on sldThSize changed val do
				(		
					tagThSize.width  = 100+(10*val)
					tagThSize.height = 80+(8*val)
					sldThSize.text = ( "Thumb Size: " +([tagThSize.width,tagThSize.height] as string))
				)
				on btnChgangeDir pressed do 
				(
					local galRootPath = (getSavePath caption:"Chose Catalog Directory.")
					if galRootPath != undefined do
					(
						setINISetting mcUserINI "3DGallery" "rootPath" (galRootPath+"\\")
						mcDgalleryDialog.fun.inicializeCatalogs()
						destroyDialog mcGallerySettingsDialog
					)
				)
			)	
			createDialog mcGallerySettingsDialog style:#(#style_titlebar, #style_sysmenu) --modal:true
		)
		else (destroyDialog mcGallerySettingsDialog)
	)
)
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~--
--oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo--
(
	local DPos  = execute(getINISetting mcUserINI "3DGallery" "Dialog_Gal_Pos" )
	local DSize = execute(getINISetting mcUserINI "3DGallery" "Dialog_Gal_Size")		
	createDialog mcDgalleryDialog pos:DPos width:DSize.x height:DSize.y style:#(#style_titlebar, 
	#style_sysmenu, #style_minimizebox, #style_maximizebox, #style_sunkenedge, #style_resizing)
)
--oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo--
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~--



/*

DOSCommand "rd E:\\3DGallery\\Characters\\Jackets"
*/