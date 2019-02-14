Global mcGall
Global mc3DGalleryRootDir
Global mc3DGallerySettingsDir
Global mc3DGalleryINI

struct dialog_dll (
	RENDER_SETUP_WINDOW = "res3.dll",
	RENDERED_FRAME_WINDOW = "bmm.dll"
)
--@ex p = pos x:10 y:20 z:0
struct pos (x , y, z)
struct mcGall(

	fn errorMsg num = (
		local msg = case num of(
		
			1:"Select a model to rename."
			2:"Select some object to add."
			3:"Create <Sub clas> catalog."
			4:"Multiselection cant be renamed."
			5:"Create  first [Main class] and [Sub class] folders."
			6:"Scene must be saved."
			7:"Type a  name first."
			8:"Select single Thumbnail for Open."
			9:"Lik is broken. Max File not found..."
		)
		messageBox msg title:" 3DGallery II... Warning:"
	),
	--string operations
	fn replaceString str char_find char_replace = (
		
		while ((i=findstring str char_find) != undefined) do (
			str = replace str i 1 char_replace
			print str
		)
		return str
	),
	fn filterPath fpath = (
	
		return mcGall.replaceString fpath "\\" "/"
	),
	--file operations
	fn getLastDirFrom path = (
	
		local arr = filterString path "\\"
		return arr[arr.count]
	),
	fn isHiddenDir path = (
	
		local arr = filterString path "\\"
		return arr[arr.count][1] == "_"
	),
	fn fillDropDownList ddlList path = (
	
		local dirs = sort(getDirectories path)
		if dirs.count == 0 do return false
		--skip directories with underscore "_settings"
		local filtered_dirs = for i in dirs where not mcGall.isHiddenDir i collect (mcGall.getLastDirFrom i)
		ddlList.items = filtered_dirs
		return true
	),
	/*fn getTransparentImage fname tcolor:black = (
	
		if not doesFileExist fname do false
		local img = (dotNetClass "Drawing.Image").FromFile fname --get the saved image from file as bitmap
		local img_clone = (dotNetObject "Drawing.Bitmap" img.width img.height) --Create new bitmap object
		local gra  = (dotNetClass "Drawing.Graphics").fromImage img_clone --Create new Graphics object
		gra.DrawImage img 0 0 img.width img.height -- (dotNetClass "Drawing.GraphicsUnit").Pixel
		img.dispose()
		gra.dispose()
		img_clone.MakeTransparent (netDrColor tcolor)
		return img_clone
	),*/
	fn getIconFromFile imgFile icNum icSize:32 imgSize:320 =(
		local icn = bitmap icSize icSize color:white
		if not doesFileExist imgFile or icNum == undefined or icNum < 1 do return icn
		local imgLib    = openBitMap imgFile
		local icnCount  = imgSize/icSize
		icNum -= 1
		local X = (mod icNum icnCount)
		local Y = (icNum / icnCount)
		
		local pix_x = X * icSize
		local pix_y = Y * icSize
		
		for i=0 to icSize do
		(
			local pix = getPixels imgLib [pix_x , pix_y + i] icSize 
			setpixels icn [0,i] pix
		)
		close imgLib
		return icn
	),
	fn getBitmapIcon icn_num = (
	
		local img_list = mc3DGallerySettingsDir + "Icons32x32i.bmp"
		return mcGall.getIconFromFile img_list icn_num
	),
	fn getIcon icn_num mask:#micra =(	
		local icSize, imgSize, img, msk
		case mask of(
			#micra:
			(
				icSize=32 
				imgSize=320 
				img = mc3DGallerySettingsDir + "Icons32x32i.bmp"
				msk = mc3DGallerySettingsDir + "Icons32x32m.bmp"
				--format "icon path:%" img
			)
			#empty:
			(
				icSize=32
				imgSize=320 
				img=mc3DGalleryRootDir + "i.bmp" 
				msk=mc3DGalleryRootDir + "m.bmp"
			)
		)
		local blank = #(bitmap icSize icSize, bitmap icSize icSize color:white,1,1,1,1,1)
		if icn_num == undefined do return blank

		if not doesFileExist img or not doesFileExist msk do return blank
		
		local icon = mcGall.getIconFromFile img icn_num icSize:icSize imgSize:imgSize
		local mask = mcGall.getIconFromFile msk icn_num icSize:icSize imgSize:imgSize

		return #(icon, mask, 1, 1, 1, 1, 1)
	),
	fn loadImageTo tag fpath = (
		
		if doesFileExist fpath do tag.bitmap = openBitmap fpath	
	),
	--INI Settings
	fn readINISettings key asString:false = ( --default asString is false. This automatically execute loaded string. 
		
		local val_str = (getIniSetting mc3DGalleryINI "3DGallery" key)
		return (if asString then val_str else execute val_str)
	),
	fn saveINISettings key val = (
	
		setINISetting mc3DGalleryINI "3DGallery" key	 val
	),
	fn dotnetColor clr = (
	
		return (dotnetclass "system.drawing.color").fromARGB clr.r clr.g clr.b
	),
	--Dialogs
	fn reloadMainDialog type =(
		destroyDialog mc3DGalleryDialog
		local d_pos  = mcGall.readINISettings "Dialog_Gal_Pos"
		local d_size = mcGall.readINISettings "Dialog_Gal_Size"
		createDialog mc3DGalleryDialog pos:d_pos width:d_size.x height:d_size.y style:#(#style_titlebar, 
		#style_sysmenu, #style_minimizebox, #style_maximizebox, #style_sunkenedge, #style_resizing)		
	),
	--Image
	fn resizeBitmapNET srcBitmap width height useHighQuality:false= (
		local destBitmap = (dotNetObject "System.Drawing.Bitmap" width height) --Create new bitmap object
		destBitmap.SetResolution srcBitmap.HorizontalResolution srcBitmap.VerticalResolution
		local theGraphics = (dotNetClass "System.Drawing.Graphics").fromImage destBitmap --Create new Graphics object
		local destRec = (dotnetObject "System.Drawing.rectangle" 0 0 width height) --Set destination image size
		IF useHighQuality DO theGraphics.InterpolationMode = theGraphics.InterpolationMode.HighQualityBicubic
		theGraphics.drawImage srcBitmap destRec --Resize the image
		theGraphics.dispose() --gc
		return destBitmap
	),
	fn bothDirsCreated main_cat sub_cat = (
		--format "lastMainCat:%  lastSubCat:%\n" main_cat sub_cat
		return (main_cat != undefined and sub_cat != undefined)
	),
	fn stampBitmap img stamp:#scene = (
	
		local icon_num = case stamp of (
		
			#model: 16
			#scene: 15
			#link: 17
		)
		local stamp = mcGall.getBitmapIcon icon_num
		pasteBitmap stamp img [0,0] [0,0]
	),
	fn showBitmap img = (
	
		rollout mc3DGalleryDisplayImage "Render preview:" (
			bitmap BitmapImage bitmap:(bitmap 50 50 color:blue)
		)
		mc3DGalleryDisplayImage.BitmapImage.bitmap = img
		local img_size = [img.width, img.height]
		createDialog mc3DGalleryDisplayImage pos:(mcGall.centerDialogToMain img_size) width:img_size.x height:img_size.y style:#(#style_titlebar, #style_sysmenu)
	),
	--Dialog Functions
	fn mainClassDir dia:mc3DGalleryDialog = (
	
		return dia.ddlMainClass.selected
	),
	fn subClassDir dia:mc3DGalleryDialog = (
	
		return dia.ddlSubClass.selected
	),
	fn getCurrentDir dia:mc3DGalleryDialog = (
	
		local main_class = dia.ddlMainClass.selected
		local sub_class = dia.ddlSubClass.selected
		if main_class == undefined and sub_class == undefined do return ""
		return (mc3DGalleryRootDir+main_class+"\\"+sub_class+"\\")
	),
	fn updateThumbs = (
	
		mc3DGalleryDialog.flp_cat.update()
		mc3DGalleryDialog.flp_cat.refresh()
		local sel_thumbs = mc3DGalleryDialog.selected_thumbs.count as String
		local all_thumbs =(mc3DGalleryDialog.flp_cat.controls).count as String
		mc3DGalleryDialog.title = " 3DGallery II: "+ sel_thumbs +"/"+ all_thumbs
	),
	fn saveIniData item_name type:#model link:"" = (
	
		local main_class = mcGall.mainClassDir()
		local sub_class = mcGall.subClassDir()
		local ini_file = (mc3DGalleryRootDir+main_class+".ini")
		--format "saveIniData ini:%\n" ini_file
		--if not exist create new one
		if not doesFileExist ini_file do (
			local f = createFile ini_file
			close f
		)
		if (link.count > 0) do link = mcGall.filterPath link
		-- save settings
		local val = #(type, sysInfo.username, localTime, link) as string
		--format "saveIniData main:% sub:% val:%\n" sub_class item_name val
		setINISetting ini_file sub_class item_name val
	),
	fn readIniData item_name = (
	
		local main_class = mcGall.mainClassDir()
		local sub_class = mcGall.subClassDir()
		local ini_file = (mc3DGalleryRootDir+main_class+".ini")
		if not doesFileExist ini_file do return ""
		return getINISetting ini_file sub_class item_name
	),
	fn deleteSelectedItems = (
		
		if not (queryBox "Are you sure you want to delete this model(s)?" title:" Delete Model(s):") do return false
		local main_class = mcGall.mainClassDir()
		local sub_class = mcGall.subClassDir()
		for i in mc3DGalleryDialog.selected_thumbs do(
			local thumb_file = i.tag
			local thumb_name = i.text
			local p = getFilenamePath thumb_file
			local n = getFilenameFile thumb_file
			local max_file = p+n+".max"
			local ini_file = mc3DGalleryRootDir+main_class+".ini"
			--format "delete files:\n MAX:%\n THUMB:%\n INI:% key:% val:%\n" max_file thumb_file ini_file sub_class thumb_name
			if doesFileExist max_file do deleteFile max_file
			if doesFileExist thumb_file do deleteFile thumb_file
			if doesFileExist ini_file do delINISetting ini_file sub_class thumb_name -- delete key
			mc3DGalleryDialog.flp_cat.controls.RemoveByKey thumb_name
		)
		mc3DGalleryDialog.selected_thumbs = #()
		mcGall.updateThumbs()
	),
	fn moveSelectedItems target_dir = (
	
		for i in mc3DGalleryDialog.selected_thumbs do(
		
			local thumb_file = i.tag
			local p = getFilenamePath thumb_file
			local n = getFilenameFile thumb_file
			local max_file = p+n+".max"
			local iFilePathNew = target_dir+n+".jpg"
			local mFilePathNew = target_dir+n+".max"
			if not doesFileExist max_file do continue 
			--check for dupplicates
			if doesFileExist mFilePathNew do
			(
				if (queryBox (n+".max"+" already exist.\nDo you want to replace it?") title:" Confirm Move File(s):") 
				then (deleteFile mFilePathNew; deleteFile iFilePathNew)
				else continue
			)
			--moving files to another folder
			copyFile thumb_file iFilePathNew
			copyFile max_file mFilePathNew
			--delete files (.max , .jpg)
			deleteFile thumb_file
			deleteFile max_file
			--update ini
--updateIni n
			mc3DGalleryDialog.flp_cat.controls.RemoveByKey i.text
		)
		--refresh
		mc3DGalleryDialog.selected_thumbs = #()
		mcGall.updateThumbs();
	),
/*fn updateIni fName =
(
	--write new
	local m_cl = ddlMainClass.selected
	local s_cl = ddlSubClass.selected
	local newIniFile   = (mc3DGalleryRootDir+m_cl+".ini")
	--format "newIniFile:%\n" newIniFile
	if not doesFileExist newIniFile do return false
	setINISetting newIniFile s_cl fName (#(sysInfo.username,localTime) as string)
	--delete old
	local m_cl = lastMainCat
	local s_cl = lastSubCat
	local oldIniFile   = (mc3DGalleryRootDir+m_cl+".ini")
	if not doesFileExist oldIniFile do return false
	delINISetting oldIniFile s_cl fName -- delete key
),*/
	fn centerDialogToMain my_size = (
		local dPos  = getDialogPos mc3DGalleryDialog
		local dSize = getDialogSize mc3DGalleryDialog
		return (dPos + dSize/2 - my_size/2)
	),
	fn getDialogHWNDbyName dll_name = (

		local popup_dialogs = UIAccessor.GetPopupDialogs()
		for x in popup_dialogs where (
			local dll_path = UIAccessor.GetWindowDllFileName x
			--format "search:% in path:%\n" dll_name dll_path
			findString dll_path dll_name
		) != undefined do return x
		return undefined
	),
	fn moveDialogByName dia_dll pos = (

		--This gets me the hWnd for the window
		local hWnd = mcGall.getDialogHWndByName dia_dll
		--format "hwnd:%\n" hWnd	
		if hWnd	== undefined do return false
		--Build Assembly script
		fn createAssembly =(
			str="using System;\n"
			str+="using System.Runtime.InteropServices;\n"
			str+="namespace Win32Helper\n"
			str+="{\n"
			str+=" class Win32HelperClass\n"
			str+=" {\n"
			str+=" [DllImport(\"user32.dll\")]\n"
			str+=" [return: MarshalAs(UnmanagedType.Bool)]\n"
			str+=" public static extern bool SetWindowPos(IntPtr hWnd, int hWndInsertAfter, int X, int Y, int cx, int cy, uint uFlags);\n"
			str+=" }\n"
			str+="}\n"

			local csharpProvider = dotnetobject "Microsoft.CSharp.CSharpCodeProvider"
			local compilerParams = dotnetobject "System.CodeDom.Compiler.CompilerParameters"
			compilerParams.ReferencedAssemblies.addRange #("System.dll")
			compilerParams.GenerateInMemory = on
			local compilerResults = csharpProvider.CompileAssemblyFromSource compilerParams #(str)

			for er = 0 to compilerResults.errors.count-1 do print (compilerResults.errors.item[er].tostring())
			return compilerResults.CompiledAssembly.createInstance "Win32Helper.Win32HelperClass"
		)
		--Compile Assembly and move Dialog
		local win32Helper = createAssembly()
		local hWndIntPtr = (dotNetObject "System.IntPtr" hWnd)
		win32Helper.setWindowPos hWndIntPtr 0 pos.x pos.y 0 0 1 
	),
	fn centerRenderWindowDialog = (
		local dia_pos = getDialogPos mc3DGalleryDialog
		dia_pos += 100
		mcGall.moveDialogByName (dialog_dll()).RENDERED_FRAME_WINDOW dia_pos
	)
)