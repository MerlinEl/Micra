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
	fn fileNameInScreen = ( --used > Customize_v0.27 > onCheckerChanges
	
		local viewSize, fName, textSize, View_X
		viewSize = getviewsize()
		fName = " " + (getFilenameFile maxFileName)-- put a space before name ,because max is crashing if first leter is "z"
		textSize = gw.getTextExtent fName
		View_X = (viewSize.x - textSize.x)-5
		gw.hText [View_X,5,1000]  fName  color:(color 120 255 120)--color:(color 255 234 0)
		gw.enlargeUpdateRect #whole 
		gw.updateScreen()
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
		
		local icn = mcFile.getIconFromFile img icn_num icSize:icSize imgSize:imgSize
		local mask = mcFile.getIconFromFile msk icn_num icSize:icSize imgSize:imgSize

		return #(icn, mask, 1, 1, 1, 1, 1)
	),
	fn getIconDn icn_num icn_size:24 = (
		
		if icn_num == 0 do return undefined
		local img_lib = (dotNetClass "Drawing.Image").FromFile Micra.IconI --get the saved image from file as bitmap
		local w = h = icn_size
		local img_lib_size = [img_lib.width, img_lib.height]
		local icnCount  = (img_lib_size/icn_size)
		icn_num -= 1
		local X = (mod icn_num icnCount.x)
		local Y = (icn_num / icnCount.y) as integer	
		local pix_x = X * icn_size
		local pix_y = Y * icn_size
		local pos = [pix_x, pix_y]
		local bmp_dn = (dotNetObject "Drawing.Bitmap" w h) --Create new bitmap object
		--bmp_dn.ColorDepth = bmp_dn.ColorDepth.Depth24Bit
		local gra  = (dotNetClass "Drawing.Graphics").fromImage bmp_dn --Create new Graphics object
		local newRect = mcDotnet.dRect [ -1, -1 ] [icn_size, icn_size]  --adjust icon offset X in button 
		gra.DrawImage img_lib newRect pos.x pos.y w h (dotNetClass "Drawing.GraphicsUnit").Pixel	
		img_lib.dispose()
		bmp_dn.MakeTransparent (mcDotnet.dColor black)--(color 75 75 75)) --gray
		bmp_dn
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