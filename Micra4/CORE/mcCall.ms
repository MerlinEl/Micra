--------------------------------------------------------------------------------
/* mcCall by Orien 2019 */
--------------------------------------------------------------------------------
/*
*@Used Structures
	Micra
*
*@Used Objects

*
*/
struct MICRA_CALL
(
	fn errorMsg block =
	(
		print
		(
			case block of
			(
				001:""
				002:""
				003:""
				004:""
				005:""
				006:""
				007:""
				008:""
				009:""
			)
		)
	),
	fn displayMsg str col =
	(
		if classOf str != string do return false
		
		local viewSize = getviewsize()
		local textSize = gw.getTextExtent str
		local CoordX = (viewSize.x - textSize.x)/2
			
		completeredraw()
		gw.wtext [CoordX,16,0] str color:col
		gw.enlargeUpdateRect #whole
		gw.updateScreen()
	),
	fn fileName_in_screen =
	(
		local viewSize, fName, textSize, View_X
		viewSize = getviewsize()
		fName = " " + (getFilenameFile maxFileName)-- put a space before name ,because max is crashing if first leter is "z"
		textSize = gw.getTextExtent fName
		View_X = (viewSize.x - textSize.x)-5
		gw.hText [View_X,5,1000]  fName  color:(color 120 255 120)--color:(color 255 234 0)
		gw.enlargeUpdateRect #whole 
		gw.updateScreen()
	),
--TODO move this to mcPopup struct
	fn popUp str tim dPos:undefined =
	(
	 	if mcPopUpDialog != undefined then destroyDialog mcPopUpDialog

		Global popStr  = str
		Global popTime = tim
		Global txtSize = gw.getTextExtent popStr
		
		rollout mcPopUpDialog "" width:80 height:44
		(
		 	-->Local
			Local sec = 500
			Local elapsedTime = 0 
			GroupBox grp_1 "" pos:[6,2] width:(txtSize.x+20) height:36
			label lbl_1 "" pos:[16,16] width:(txtSize.x) height:16
			timer popTick "" pos:[12,12] width:24 height:24 interval:sec active:true
		 	on mcPopUpDialog rbuttonup pos do destroyDialog mcPopUpDialog
			on mcPopUpDialog lbuttonup pos do destroyDialog mcPopUpDialog
			on mcPopUpDialog open do 
		 	(  
				mcPopUpDialog.width  = (txtSize.x+32)
				mcPopUpDialog.height = (txtSize.y+32)
				lbl_1.text = popStr
			)
		 	on mcPopUpDialog close do 
		 	( 
		 	 	popStr  = undefined
				popTime = undefined
				txtSize = undefined
			)
		 	on popTick tick  do
		 	(
				elapsedTime += 0.5
				if elapsedTime >= popTime do destroyDialog mcPopUpDialog
		 	)
		)
		if classof dPos == Point2
		then CreateDialog mcPopUpDialog pos:dPos style:#(#style_border)
		else CreateDialog mcPopUpDialog style:#(#style_border)
		--**\ Created by Merlin el' 9.4.2006 12:59:28 /**--
		/* mcCall.popUp "Ahoj" 1.5 */ 
	),
	fn teleportText title:"" =
	(
		if mcTeleportTextDialog != undefined then destroyDialog mcTeleportTextDialog
		rollout mcTeleportTextDialog title width:444 height:40
		(
			local apply = false
			edittext edtBox "12345678910" pos:[12,12] width:312 height:16 bold:true
		 	button btnAcpt "Accept" pos:[332,12] width:48 height:16
		 	button btnCncl "Cancel" pos:[384,12] width:48 height:16
		 	groupBox gr_1 "" pos:[4,0] width:436 height:36
			on mcTeleportTextDialog open    do 
			(
				edtBox.caption = mcTeleportTextDialog.title + ":"
				setFocus edtBox
			)
			on btnAcpt pressed           do 
			(
				if edtBox.text.count > 0 do
				( 
					DestroyDialog mcTeleportTextDialog
					apply = true 
				)
			)
			on btnCncl pressed           do (DestroyDialog mcTeleportTextDialog)
			on edtBox entered text       do (btnAcpt.pressed())
		)
		CreateDialog mcTeleportTextDialog style:#(#style_border) modal:true
		
		return #(mcTeleportTextDialog.apply, mcTeleportTextDialog.edtBox.text)
	),
	fn progeressbar val close:false color:(color 255 200 18) =
	(
		if mcProgressBarDialog == undefined do
		(
			rollout mcProgressBarDialog " Inicialize 3DGallery Database:" width:332 height:132
			(
				GroupBox grp_info "Progress...0%" pos:[8,4] width:316 height:120
				bitmap bmpPop1 "Bitmap" pos:[16,20] width:300 height:80 fileName:(Micra.RootDir+"Img\\3DGall_Loader_01.bmp")
				progressBar pBar "ProgressBar" pos:[16,104] width:300 height:13
				button btn_close "*" pos:[312,4] width:12 height:12
				on btn_close pressed do destroyDialog mcProgressBarDialog
			)
			createDialog mcProgressBarDialog style:#(#style_border) --modal:true
			mcProgressBarDialog.pBar.color = color
		)
		if not mcProgressBarDialog.isDisplayed then
		(
			createDialog mcProgressBarDialog style:#(#style_border) --modal:true
			mcProgressBarDialog.pBar.color = color
		)
		mcProgressBarDialog.pBar.value    = val
		mcProgressBarDialog.grp_info.text = "Progress..."+ ((val as integer) as string) + "%"
		if close do (sleep 0.3; destroyDialog mcProgressBarDialog)
	),
	fn createIniDialog dNameStr prop style:#(#style_border) modal:false resize:false =
	(
		if not doesFileExist Micra.TempProfileIni do return false
		
		-->get data from Micra.TempProfileIni as array
		local data  = execute (getIniSetting Micra.TempProfileIni prop dNameStr)
		--format "data:%\n" data
		if classOf data != array do return false
		local dPos  = data[2]
		local dSize = data[3]
		
		if resize and classOf dSize == Point2 
		then (CreateDialog  (execute dNameStr) dSize.x dSize.y pos:dPos style:style modal:modal)
		else if classOf dPos == Point2
		then (CreateDialog  (execute dNameStr) pos:dPos style:style modal:modal)
		else (CreateDialog  (execute dNameStr) style:style modal:modal)
	),
	fn getIcon icn_num mask:#micra =
	(	
		local icSize, imgSize, img, msk
		case mask of
		(
			#micra:
			(
				icSize=24 
				imgSize=480 
				img=Micra.IconI 
				msk=Micra.IconM
			)
			#empty:
			(
				icSize=24
				imgSize=240 
				img=Micra.RootDir + "Img\\i.bmp" 
				msk=Micra.RootDir + "Img\\m.bmp"
			)
		)
		local blank = #(bitmap icSize icSize, bitmap icSize icSize color:white,1,1,1,1,1)
		if icn_num == undefined do return blank

		if not doesFileExist img or not doesFileExist msk do return blank
		
		local icon = mcDialog.getIconFromFile img icn_num icSize:icSize imgSize:imgSize
		local mask = mcDialog.getIconFromFile msk icn_num icSize:icSize imgSize:imgSize

		return #(icon, mask, 1, 1, 1, 1, 1)
	),
	fn time = 
	(
		local arr = filterString LocalTime "./ :"
		if arr.count < 5 do return "invalid time"
		return (arr[4] + ":" + arr[5] + "  " + arr[1] + "." + arr[2] + "." + arr[3])
	)
)
--create instance
Global mcCall = Micra.instanceStructure MICRA_CALL "mcCall"