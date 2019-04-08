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
	fn getSource = getSourceFileName(), --get path of this script
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
	fn fileNameInScreen =
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
	/**
	*@Usage
		dNameStr	: String
		prop		: String
		style		: Array
		modal		: Boolean 
		resize		: Boolean
	*@Example
		mcCall.createXMLDialog "mcCharPoseDialog" "Properties_2" style:#(#style_resizing)
	*/
	fn createXMLDialog dNameStr prop style:#(#style_border) modal:false resize:false = (
	
		local data = mcFile.readSettings Micra.UserProfile (prop + "/"+ dNameStr) type:"attribs"
		if data == "" do return false
		--data.print()
		local dPos  = execute (data.get "pos")
		local dSize = execute (data.get "size")
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
		
		local icon = mcFile.getIconFromFile img icn_num icSize:icSize imgSize:imgSize
		local mask = mcFile.getIconFromFile msk icn_num icSize:icSize imgSize:imgSize

		return #(icon, mask, 1, 1, 1, 1, 1)
	),
	fn time = 
	(
		local arr = filterString LocalTime "./ :"
		if arr.count < 5 do return "invalid time"
		return (arr[4] + ":" + arr[5] + "  " + arr[1] + "." + arr[2] + "." + arr[3])
	),
	/**
	*#Usage Create maxscript Api  for notepad++ ( current used functions and structures )
	mcCall.generateNotepadApi "D:\\ReneBaca\\Aprog\Notepad-MSX\\autoCompletion"
	*/
	fn generateNotepadApi notepad_api_dir = (
		
		local filePath = notepad_api_dir +  "\\maxscript.xml"
		
		local filteredSS = stringstream ""
		format "<?xml version=\"1.0\" encoding=\"Windows-1252\" ?>\n" to:filteredSS
		format "<NotepadPlus>\n\t<AutoComplete>\n" to:filteredSS
		format "\t\t<Environment ignoreCase=\"yes\" startFunc=\"(\" stopFunc=\")\" paramSeparator=\".\" terminal=\";\" />\n" to:filteredSS
		
		local ss = stringstream ""
		apropos "" to:ss
		seek ss 0
		while not eof ss do (
		
			local l = readLine ss
			if matchPattern l pattern:"*#struct:*" then (
			
				local n = (filterString l " ")[1]
				l = readLine ss
				while matchPattern l pattern:"*public,*" do (
				
					local fu = (trimLeft (filterString l ":")[1] " ")
					format "\t\t<KeyWord name=\"%.%\" />\n" n fu to:filteredSS
					l = readLine ss
				)
			) else if matchPattern l pattern:"*(const *" then (
			
				local fu = (filterString l " ")[1]
				format "\t\t<KeyWord name=\"%\" />\n" fu to:filteredSS
			)
		)
		--close XML header
		format "\t</AutoComplete>\n</NotepadPlus>\n" to:filteredSS
		local fStream = openFile filePath mode:"w+"
		format "%" (filteredSS as string) to:fStream
		close fStream
		
		shellLaunch notepad_api_dir ""
	),
	/***
	*@Usage Create MaxScript .api file for use with the automcomplete feature of the MaxScript editor.
	*@Created by:James Haywood (http://apps.jhaywood.com/blog/)
	*@Mod by: MerlinEl 2019
	*@Example > mcCall.generateMaxApi()
	***/
	fn generateMaxApi = (
	
		local filteredSS = stringstream ""
		local ss = stringstream ""
		local max_root_dir = getDir #maxRoot
		local max_user_dir = pathConfig.removePathLeaf (getDir #userScripts)
		local filePath = if isDirectoryWriteable max_root_dir then (
				
			max_root_dir +  "\\maxscript.api"
			
		) else (
			
			max_user_dir +  "\\maxscript.api" 
		)
		
		apropos "" to:ss
		seek ss 0
		while not eof ss do (
		
			local l = readLine ss
			if matchPattern l pattern:"*#struct:*" then
			(
				local n = (filterString l " ")[1]
				l = readLine ss
				while matchPattern l pattern:"*public,*" do
				(
					format "%.%\n" n (trimLeft (filterString l ":")[1] " ") to:filteredSS
					l = readLine ss
				)
			) else if matchPattern l pattern:"*(const *" then (
			
				format "%\n" (filterString l " ")[1] to:filteredSS
			)
		)

		if  doesFileExist filePath do deleteFile filePath
		--createFile filePath --CAUSING ERROR!
		
		local fStream = openFile filePath mode:"w+"
		format "%" (filteredSS as string) to:fStream
		close fStream

		if isDirectoryWriteable max_root_dir then (
			
			messageBox "Api was created Succesfully." title:Micra.version
				
		) else (
				
			messageBox "Api was created Succesfully.\nPlease move file [  maxscript.api  ] from User to Max Root Dir." title:Micra.version
			shellLaunch max_root_dir ""
			shellLaunch max_user_dir ""
		)
	)
	/*<end>*/
)
--create instance
Global mcCall = mcStructMan.instanceStructure MICRA_CALL "mcCall"