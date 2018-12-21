
Global mcArray
Global mcRect 
Global mcMath
Global mcCube
Global mcCall
Global mcColor
Global mcPoly
Global mcFile
Global mcInfo
Global mcSnap
Global mcDraw
Global mcSystem
Global mcString
Global mcTransform
Global mcDialogSnap
Global mcProgressBarDialog
Global mcSCREENS_DATA
Global mcUIColors
Global mcCursor
Global mcSize

Global mcPopUpDialog
Global mcTeleportTextDialog
Global mcDialog
Global mc_Dialog_A
Global mc_Dialog_B
Global mc_Dialog_C
Global mc_Dialog_D
Global mc_Dialog_E
Global mc_Dialog_F
Global mc_Dialog_G
Global mc_Dialog_H
Global mc_Dialog_I
Global mc_Dialog_J

--------------------------------------------------------------------------------
/* General */
--------------------------------------------------------------------------------
struct mcArray
(
	fn appendIfUnique inArray newElement = 
	(
		local elementExists = false
		for elem = 1 to inArray.count do
		(
	 		if ((inArray[elem] as string) == (newElement as string)) then
	 		elementExists = true
	 	)
	 	if (not elementExists) then
		append inArray newElement
	),
	fn findItem2 array2 val ID =
	(
		local index
		for i=1 to array2.count do
		( 
			if array2[i][ID] == val do index = i
		)
		return index
	),
	fn reverseArray arr = (for i=arr.count to 1 by -1 collect arr[i]),
	fn mergeClone arr1 arr2 = (
		
		local new_arr = #()
		join new_arr arr1
		join new_arr arr2
		return new_arr
	)
	/*
	a = #( #(1,2), #("c","d","e"), #(56,47) ) 
	b = findItem2 a "c" 1
	b = findItem2 a 47 2
	*/
)

struct mcMath (
	fn isInteger num = (mod num 1 == 0),
	--usage:	mcMath.roundToInt 25.45 10
	--receives the number 120 435 it return 120 000 wich is the nearest ten thousand etc..
	fn roundToInt num round = (
		
		return int((num)/round)*round
	),	
	--usage: 	mcMath.roundToDecimals 25.45454 10
	--			mcMath.roundToDecimals 25.44554 100
	--decimals 10(1) 100(2) 1000(3)
	--245.85714 -->  245.867  --number length is shorten to 6 places why ???
	fn roundToDecimals num dec = (
		
		--format "round num:% to:%\n" num dec
		local round_up = false
		local dec_str = num as String --convert num to string
		dec_str = trimLeft dec_str "1234567890" --keep decimals
		dec_str = trimLeft dec_str "." --remove dot
		local round_pos = (dec as String).count --get second place after round pos
		--format "dec_str:% round_pos:%\n" dec_str round_pos
		if dec_str.count >= round_pos do ( 
			
			round_num = execute dec_str[round_pos] --get round nuber 
			--format "round_num:%\n" round_num
			round_up = round_num >= 5
		) 
		local result = int((num as float)*dec)/float(dec) 
		if round_up do result = result + (1 /  dec as float)
		return result
	),
	--round down a number amd convert it to even: 12445 to 12444
	fn roundToEven num = (
		
		return 2 * int( num / 2)
	),
	fn getVectorsAngle v1 v2 = (acos(dot (normalize v1) (normalize v2))),
	fn movePointAlongVector p v val = ( p + (normalize v) * val ),
	fn intersectionLineLine p1 p2 p3 p4 = 
	(
		local a=p2-p1
		local b=p4-p3
		local c=p3-p1
		local cross1 = cross a b
		local cross2 = cross c b
		p1 + ( a*( (dot cross2 cross1)/((length cross1)^2) ) )
	),
	--intersection between a line and a plane
	fn planeLineIntersect plane_pos plane_normal line_point line_vector = 
	(
		local line_vector= normalize line_vector
		local d1=dot (plane_pos-line_point) plane_normal
		local d2=dot line_vector plane_normal
		if abs(d2)<.0000000754 
		then ( if abs(d1)>.0000000754 then 0 else -1 )
		else ( line_point + ( (d1/d2)*line_vector ) )
	),
	fn projectPointOnLine pA pB pC = 
	(
		local vAB=pB-pA
		local vAC=pC-pA
		local d=dot (normalize vAB) (normalize vAC)
		(pA+(vAB*(d*(length vAC/length vAB))))
	),
	fn isPointOnLine pA pB pC tol = 
	(
		local vAB=pB-pA
		local vAC=pC-pA
		local d=1.0-abs(dot (normalize vAB) (normalize vAC))
		if d<=tol then true else false
	),
	function get2DBoundingBox pos_array =
	(
		local bmin, bmax
		for v in pos_array do
		(
			if bmin != undefined then
			(
				bmin.x = amin #(v.x, bmin.x)
				bmin.y = amin #(v.y, bmin.y)
				
				bmax.x = amax #(v.x, bmax.x)
				bmax.y = amax #(v.y, bmax.y)
			)
			else bmin = copy (bmax = v)
		)
		return #(bmin, bmax)
	),
	fn get3DBoundingBox obj type:#world debug:false =
	(
		if classOf obj != Editable_Poly do return false
		local bmin, bmax, verts = obj.verts
		
		for v = 1 to verts.count do
		(
			local p = polyOp.getVert obj v --vert pos
			if type == #local do p *= inverse obj.transform
			
			if bmin != undefined then
			(
				bmin.x = amin #(p.x, bmin.x)
				bmin.y = amin #(p.y, bmin.y)
				bmin.z = amin #(p.z, bmin.z)
				
				bmax.x = amax #(p.x, bmax.x)
				bmax.y = amax #(p.y, bmax.y)
				bmax.z = amax #(p.z, bmax.z)
			)
			else bmin = copy (bmax = p)
		)
		
		if debug do
		(
			local bb = if type == #world then #(bmin, bmax) else #(bmin*obj.transform, bmax*obj.transform)
			format "Poly:%\nBounding Box:%\n" obj bb
			point pos:bb[1]
			point pos:bb[2]
		)
		
		case type of --return min & max
		(
			#world: return #(bmin, bmax) 
			#local: return #(bmin*obj.transform, bmax*obj.transform)
		)
	),
	fn versionUp num = (
		
		local new_version  = num + 0.01 as float
		if mcMath.isInteger new_version then int new_version else new_version
	)
)
struct mcCall
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
		/* Call: mcPop "Ahoj." 3 | mcPopUp "Ahoj" 1.5 */ 
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
	fn getIniDataFromArray iniFile head key arrNum =
	(
		if classOf iniFile != string  do return undefined
		if classOf head    != string  do return undefined
		if classOf key     != string  do return undefined
		if classOf arrNum  != integer do return undefined
		
		if not doesFileExist iniFile do return undefined
		if head == "" 
		then 
		(
			return (getIniSetting iniFile)
		)
		if key == "" 
		then
		(
			return (getIniSetting iniFile head)
		)
		if arrNum == 0 
		then
		(
			return (getIniSetting iniFile head key)
		)
		else 
		(
			local data  = execute (getIniSetting iniFile head key)
			--format "ini:%\thead:%\tkey:%\tarrnum:%\n" iniFile head key arrNum
			if classOf data != array do return undefined
			return data[arrNum]
		)
	),
	fn setIniDataToArray iniFile head key arrNum newValue =
	(
		if classOf iniFile  != string  do return undefined
		if classOf head     != string  do return undefined
		if classOf key      != string  do return undefined
		if classOf arrNum   != integer do return undefined
		--if classOf newValue != string do return undefined
		
		if not doesFileExist iniFile do return undefined
		
		if arrNum != 0 
		then
		(
			local data = execute (getIniSetting iniFile head key)
			if classOf data != array do return undefined
			data[arrNum] =  newValue
			setIniSetting iniFile head key (data as string)
		)
		else
		(
			setIniSetting iniFile head key newValue
		)
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
	fn saveIniDialog dNameStr head  active: title: =
	(
		if not doesFileExist Micra.TempProfileIni do return false
		
		local data  = execute (getIniSetting Micra.TempProfileIni head dNameStr)
		if classOf data != array do data = #(false,[0,0],[0,0],"")
		local dia = execute dNameStr
		
		if active  != unsupplied do data[1] = active
		if title   != unsupplied do data[4] = title
		
		case classOf dia of
		(
			RolloutClass:if dia.isDisplayed do
			(
				data[2] = getDialogPos  dia
				data[3] = getDialogSize dia
			)
			dotNetObject:--if dia.Visible do
			(
				data[2] = [dia.location.x, dia.location.y]
				data[3] = [dia.width, dia.height]
			) 
		)
		setIniSetting Micra.TempProfileIni head dNameStr (data as string)
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

struct mcColor (
	/**
	* @example mcColor.colorToHex (color 60 32 104)
	*/
	fn colorToHex c= ( --thanks to Mark Tsang
		
		if classOf c != Color do return undefined
		ret = "#"
		h = bit.intashex c.r
		if h.count < 2 then
		(
			h = ("0"+h)
		)
		ret+= h

		h = bit.intashex c.g
		if h.count < 2 then
		(
			h = ("0"+h)
		)
		ret+= h

		h = bit.intashex c.b
		if h.count < 2 then
		(
			h = ("0"+h)
		)
		ret+= h
		execute ret
	),
	/**
	* @example	mcColor.hexToColor #3c2068
	*/
	fn hexToColor hex_color= ( --thanks to Mark Tsang
	
		if classOf hex_color != Name do return undefined
		local hex_string = hex_color as string	
		if hex_string.count == 6 then (
			colorArray = #()
			for i = 1 to 6 by 2 do (
				
				local two_chars = subString hex_string i 2
				local cv = (("0X"+two_chars) as integer)
				if cv != undefined then
				(
					append colorArray cv
				)
				else 
				(
					format "invalid hex string supplied\n"
					return undefined
				)
			)
			return color colorArray[1] colorArray[2] colorArray[3]
		)
		return undefined
	),
	
	/* hex to rgb explnation
	cb = "f26d7d"
	colRed = ("0x" + substring cb 1 2) as integer
      colGreen = ("0x" + substring cb 3 2) as integer
       colBlue = ("0x" + substring cb 5 2) as integer
      color colRed colGreen colBlue
	*/
	fn colorAsInt col = --get color (color 255 255 0) return integer 16776960
	(
		((col.r as integer)*256 + (col.g as integer))*256 + (col.b as integer)
	),
	fn intAsColor int = --get integer 16776960 return color (color 255 255 0)
	( 
		(r=int/256^2; g=int/256-r*256; bmp=mod int 256; color r g bmp)
	),
	fn blendColors c1 c2 = ((c1+c2)/2),
	fn randomColor=(color (random 1 255)  (random 1 255) (random 1 255)) 
)

--------------------------------------------------------------------------------
/* Strings */
--------------------------------------------------------------------------------
struct mcString
(
	fn replaceSymbol str str_1 str_2 =
	(
		-->erorr block
		if str   == undefined or classOf str   != String do return ""
		if str_1 == undefined or classOf str_1 != String do return ""
		if str_2 == undefined or classOf str_2 != String do return ""
		-->function
		local str_1Pos = 0
		while str_1Pos != undefined and not keyboard.escPressed do
		( 	
			local str_1Pos = findString str str_1
			if str_1Pos   != undefined do str[str_1Pos] = str_2
		)
		str
	),
	fn replaceCharInString str inchar tochar =
	(
		for i = 1 to str.count where str[i] == inchar do str[i] = tochar
		str
	),
	fn upperLowerCase str type = --replace uper case to lower ad vice versa 
	( 
		local upperCase="ABCDEFGHIJKLMNOPQRSTUVWXYZ" --26
		local lowerCase="abcdefghijklmnopqrstuvwxyz" --26
		local arr = case type of
		(
			#Up:#(lowerCase,upperCase)
			#Down:#(upperCase,lowerCase)
		)
		for n=1 to str.count do
		(
			for s=1 to 26 do (if str[n] == arr[1][s] do str[n] = arr[2][s])
		)
		str 
	), --Call: mcString.upperLowerCase "ABCDE" #down
	fn stringToNum str = (
	
		local eval_str =  execute str --format "str:% eval:%\n" str eval_str
		case classOf eval_str of (
			
			float:eval_str
			integer:eval_str
			default:undefined	
		)
	)
)
--------------------------------------------------------------------------------
/* Snapping */
--------------------------------------------------------------------------------
struct mcSnap
(
	fn getActiveItems =
	(
		local active = #()
		for i = 1 to snapmode.numOSnaps do
		(
			for j = 1 to (snapmode.getOSnapNumItems i) do
			(
				(if snapmode.getOSnapItemActive i j do active += #(snapmode.getOSnapItemName i j))
			)
		)
		return active
	),
	fn isActive str =
	(
		for i = 1 to snapmode.numOSnaps do
		(
			for j = 1 to (snapmode.getOSnapNumItems i) do
			(
				if str == (snapmode.getOSnapItemName i j) and snapmode.getOSnapItemActive i j == true do return true
			)
		)
		return false
	),
	fn setItems boolean = 
	(
		for i = 1 to snapmode.numOSnaps do
		(
			for j = 1 to (snapmode.getOSnapNumItems i) do
			(
				(snapmode.setOSnapItemActive i j boolean)
			)
		)
	),
	fn enabled arr boolean =
	(
		for a in arr do
		(
			for i = 1 to snapmode.numOSnaps do
			(
				for j = 1 to (snapmode.getOSnapNumItems i) do
				(
					if a == (snapmode.getOSnapItemName i j) do (snapmode.setOSnapItemActive i j boolean)
				)
			)
		)
	)
)


--------------------------------------------------------------------------------
/* File */
--------------------------------------------------------------------------------
struct mcFile
(
	all_dirs = #(),
	fn getDirTree dir =
	(
		all_dirs += curr_dirs = getDirectories (dir+"*.*")
		for i in curr_dirs do getDirTree i
	),
	fn filterPath path = 
	(
		local arr   = filterString path "\\/"
		local isDir = path[path.count-3] != "." -- example C:\temp.txt
		local newPath = ""
		for i=1 to arr.count do newPath += arr[i] + ( if isDir or i != arr.count then "/" else "")
		return newPath
	),
	fn copyDirTree indir outdir hidden:true exceptempty:false owerwritereadonly:true existingonly:false silent:true =
	(
		--indir = mcFile.filterPath2 indir
		--outdir = mcFile.filterPath2 outdir
		
		trimRight indir
		trimRight outdir
		indir  += "\\"
		outdir += "\\"
		
		local cmd = "XCOPY /I " +
			(if exceptempty       then "/S " else "/E ") + 
			(if hidden            then "/H " else ""  ) + 
			(if owerwritereadonly then "/R " else ""  ) + 
			(if existingonly      then "/U " else ""  ) + 
			(if silent            then "/Y " else " "  ) + 
			--"\""+indir+"\"" + " " + "\""+outdir+"\""
			indir + " " + outdir

		format "cmd:%\n" cmd
		DOSCommand cmd
	),
	fn treeCopy indir outdir move:false = --recursive call
	(
		indir = mcFile.filterPath indir
		outdir = mcFile.filterPath outdir

		local files = getFiles (indir+"*.*")
		local dirs = getDirectories (indir+"*.*")
		
		for f in files do ( copyFile f (outdir+filenameFromPath f) )
		for d in dirs do 
		(              
			local filter_path = filterString d "\/"
			local new_dir = outdir+filter_path[filter_path.count]
			makedir new_dir
			mcFile.treeCopy d new_dir
		)
	),
	fn import =
	(
		max file import	
	),
	fn open fpath =
	(
		fpath = mcFile.filterPath fpath 
		if not doesFileExist fpath do return false
		if isMaxFile fpath do try (loadMaxFile fpath useFileUnits:true quiet:false) catch()
	),
	fn saveLoadIniSetings head: key: data: action: =
	(
		if not doesFileExist Micra.UserSettings or  not doesFileExist Micra.DefaultSettings do return false
		if head == unsupplied or key == unsupplied do return false
		case action of
		(
			#load:
			(
				local user_data = getINISetting Micra.UserSettings head key
				if user_data != ""
				then return user_data --user settings
				else return getINISetting Micra.DefaultSettings head key --default settings
			)
			#save:
			(
				if data == unsupplied do return false
				setINISetting Micra.UserSettings head key data
			)
		)
	),
	fn saveIniDialog form head key =
	(
		if not doesFileExist Micra.TempProfileIni or classOf form != dotnetObject do return false
		local data  = execute (getIniSetting Micra.TempProfileIni head key)
		if classOf data != array do data = #(false,[0,0],[0,0],"")

		data[1] = form.Visible
		data[2] = [form.location.x, form.location.y]
		data[3] = [form.width, form.height]
		setIniSetting Micra.TempProfileIni head key (data as string)
	),
	fn backupMaxFile =
	(
		local file_path = maxFilePath
		local file_name = maxFileName
		
		local not_saved_scene = getSaveRequired()
		if file_path == "" or not_saved_scene do (messageBox "Save you scene first." title:" Backup:" ;return false)
		
		local backup_dir = file_path + "BK\\" --define backup dir
		local file       = file_path+file_name
		
		--format "Current file: %\n" file
		
		if not doesFileExist backup_dir do makeDir backup_dir

		local max_files = getFiles (backup_dir+"*.max") --get all max files from BK dir
		local backup_files = for f in max_files where findString f "[BK]_" != undefined collect f --get only backup files
		
		local file_versioned
		
		if backup_files.count == 0 --first backup
		then
		(
			file_versioned = backup_dir+"[BK]_0.01_"+file_name
			copyFile file file_versioned
		)
		else
		(
			local last_file    = backup_files[backup_files.count] --get last backup file
			
			--format "Last    file: %\n" last_file 
			
			local last_version = (filterString (filenameFromPath last_file) "_")[2] as float --get last file version
			
			--format "Last version:%\n" last_version
			
			if classOf last_version != float do return false
			
			local new_version = (last_version + .01) as string
			if new_version.count < (last_version as string).count do new_version += "0" --keep always the same patern 00.00
			file_versioned = backup_dir+"[BK]_"+new_version+"_"+file_name
			copyFile file file_versioned
		)
		format "Backup File: %\n" file_versioned
	),
	fn getClipboardTxt =
	(
		local clipboardClass = dotNetClass "System.Windows.Forms.Clipboard"
		if clipboardClass.containstext() then clipboardClass.getText() else ""
	),
	fn mergeMaxFiles dir matchObjectNamesToFiles:false =  --mergeMaxFiles "c:\\temp" matchObjectNamesToFiles:true
	(
		local files = getFiles dir+"\\*.max"
		for f in files do 
		(
			mergeMAXFile f #noRedraw #mergeDups #useMergedMtlDups #neverReparent #select -- #promptDups
			local obj  = selection[1]
			if obj != undefined do obj.name = getFilenameFile f
		)
	)
)
    --local mf = mcFile()
    --mf.getDirTree (Micra.RootDir)
    --print mf.all_dirs

struct mcInfo
(
	fn all obj = 
	(
		show obj	
	),
	
	fn who obj = 
	(
		format "class:% superClass:%\t" (classOf obj) (superClassOf obj)
	),

	/*fn isGeometry obj = 
	(
		superClassOf obj == GeometryClass
	),
	
	fn isShape obj = 
	(
		superClassOf obj == shape
	),*/
	
	fn is arg obj =
	(
		--isKindOf o SplineShape1
		local type = case (classOf obj) of
		(
			Editable_Poly: #poly
			Editable_Mesh: #mesh
			Line: #spline
			BoneGeometry: #bone
			--Edit_Poly:
			--Edit_Mesh:
			--Unwrap_UVW:
			--SplineShape:
			--Edit_Spline:
		)
		if type == undefined do type = case (superClassOf obj) of
		(
			GeometryClass: #geometry	
			shape: #shape
		)
		return type == arg
	) 
)

struct mcPoly
(
	fn isClass arg obj =
	(
		case arg of
		(
			#mod     : getCommandPanelTaskMode() == #modify
			#poly    : classOf obj.baseObject == Editable_Poly
			#modpoly : modPanel.getCurrentObject() == obj.modifiers[#Edit_Poly]
			#inBase  : modPanel.getCurrentObject() == obj.baseobject
			#editable: validModifier obj Edit_Mesh
		)
	),
	fn isPoly obj =
	(
		obj != undefined and classOf obj.baseObject == Editable_Poly or 
		modPanel.getCurrentObject() != undefined and modPanel.getCurrentObject() == obj.modifiers[#Edit_Poly]
	),
	fn isInPoly =
	(
		local mod = Filters.GetModOrObj()
		getCommandPanelTaskMode() == #modify and classOf mod == Editable_Poly or classOf mod == Edit_Poly
	),
	fn isQuads obj faceSel =
	(
		if classOf obj != Editable_Poly and faceSel.count == 0 do return false
		for f in faceSel where (polyOp.getVertsUsingFace obj.baseobject f).numberSet != 4 do return false
		return true
	),
	fn intersectionExists obj =
	(
		local objBase = obj.baseobject
		local edgesBA = #{}
		local intEdges = #{}
		for i in (polyOp.getFaceSelection objBase) do
		(
			local faceEdges = polyOp.getEdgesUsingFace objBase i
			for f in faceEdges do
			(
				if (findItem edgesBA f) == 0 then
				(
					append edgesBA f
				)
				else
				(
					append intEdges f
				)
			)
		)
		intEdges
	),
	fn getEdgesFrom vert =
	(
		local edge = 1
		local step = 1 
		local edges = #{}
		while edge != 0 do 
		(
			edge = (modPanel.getCurrentObject()).GetVertexEdge vert step
			append edges edge 
			step +=1
		)
		
		return edges
	),
	fn getVertsFrom edge =
	(
		local vert = 1
		local step = 1 
		local verts = #{}
		while vert != 0 do 
		(
			vert = (modPanel.getCurrentObject()).GetEdgeVertex edge step
			append verts vert 
			step +=1
		)
		return verts
	),
	fn getEdgeLength obj edge =
	(
		local my_verts = polyOp.getVertsUsingEdge obj edge as array
		return distance (polyOp.getVert obj my_verts[1]) (polyOp.getVert obj my_verts[2])
		
	),
	--function getVectorDistance dx dy=
	--(
	--	return sqrt(dx*dx+dy*dy)
	--),
	fn get what =
	(
		local obj = selection[1]
		if obj == undefined do return #()
		local enabled = 
		(
			mcPoly.isClass #mod obj and (mcPoly.isClass #modPoly obj or mcPoly.isClass #poly obj and mcPoly.isClass #inBase obj)
		)
		local gco = modPanel.getCurrentObject()
		case what of
		(
			--VertSelection
			#vSel:   if enabled then (try (gco.getSelection #Vertex as array) catch #()) else #()
			--EdgeSelection
			#eSel:   if enabled then (try (gco.getSelection #Edge   as array) catch #()) else #()
			--FaceSelection
			#fSel:   if enabled then (try (gco.getSelection #Face   as array) catch #()) else #()
			--VertsUsingEdge
			#vuEdge: if enabled then (try((polyOp.getVertsUsingEdge obj (mcPoly.get #eSel)) as array) catch #()) else #()
			--VertexUsingFace
			#vuFace: if enabled then (try((polyOp.getVertsUsingFace obj (mcPoly.get #fSel)) as array) catch #()) else #()
			--EdgesUsingVert
			#euVert: if enabled then (try((polyOp.getEdgesUsingVert obj (mcPoly.get #vSel)) as array) catch #()) else #()
			--EdgesUsingFace
			#euFace: if enabled then (try((polyOp.getEdgesUsingFace obj (mcPoly.get #fSel)) as array) catch #()) else #()
			--FaceUsingVert
			#fuVert: if enabled then (try((polyOp.getFacesUsingVert obj (mcPoly.get #vSel)) as array) catch #()) else #()
			--FaceUsingEdge
			#fuEdge: if enabled then (try((polyOp.getFacesUsingEdge obj (mcPoly.get #eSel)) as array) catch #()) else #()
			--Selected objects
			#oSel:    selection as array
			--All objects in scene
			#obj:     objects   as array
		)
	),
	fn getHitNode =
	(
		local view_mouse_pos = mouse.pos --get current mouse pos based on active view pos
		local view_size = getViewSize() --get active viewport size
		-- if mouse is out of viewport
		if view_mouse_pos.x < 0 or view_mouse_pos.x > view_size.x or
		view_mouse_pos.y < 0 or view_mouse_pos.y > view_size.y do return undefined
		-- cast ray from mouse point in to scene
		local iray = (mapScreentoWorldRay mouse.pos) --ray <pos> <dir>
		-- get visible nodes on ray path
		local hit_nodes = for n in (intersectRayScene iray) where not n[1].isHidden collect #(n[1], n[2], distance iray.pos n[2].pos)
		if hit_nodes.count == 0 do return undefined -- if nothing found
		-- sort nodes by distance
		fn sortByHitDistance n1 n2 = if n1[3] < n2[3] then -1 else if n1[3] > n2[3] then 1 else 0 
		qsort hit_nodes sortByHitDistance
		return hit_nodes[1][1] --return node or undefined
	),
	fn getHitFace node =
	(
		if classOf node != Editable_Poly do return false
		local meshObj
		hide (meshObj = snapshot obj)
		local theRay=mapScreenToWorldRay mouse.pos
		local hitRay=intersectRayEx meshObj theRay	
		delete meshObj
		return hitRay
	)
)

struct TM (name, pos, rot);
Global OBJ_TM
struct mcTransform
(
	fn getRotation obj = 
	(
		local x = obj.rotation.x_rotation
		local y = obj.rotation.y_rotation
		local z = obj.rotation.z_rotation
		return [x,y,z]
	),
	fn setRotation obj rot = 
	(
		obj.rotation.x_rotation = rot.x
		obj.rotation.y_rotation = rot.y
		obj.rotation.z_rotation = rot.z
	),
	fn copyTM =
	(
		if (selection.count > 0) do OBJ_TM = mcTransform.getTM selection[1]
	),
	fn pasteTM =
	(
		if (OBJ_TM != undefined) do mcTransform.setTM selection[1] OBJ_TM
	),
	fn getTM obj = 
	(
		return TM obj.name obj.pos (mcTransform.getRotation obj)
	),
	fn setTM obj tm = 
	(
		mcTransform.setRotation obj tm.rot
		obj.pos = tm.pos
	),
	fn round val num =
	(
		((val*num) as integer) as float / num
	), 
	fn round3Matrix val num =  
	(
		for i=1 to 3 do val[i]= mcTransform.round val[i] num
		return val
	),
	fn getNodeSize obj =
	(
		obj.min - obj.max
	),
	fn getLocalSize obj type =
	(
	 	/*
		in coordsys local 
		(
			min = obj.min
	 		max = obj.max
		)
		*/
		addModifier Obj (theBend = Bend()) --add a bend to the object
		classof Obj								 --this is a hack causing a fast reevaluation of the stack!
		min = getModContextBBoxMin Obj theBend --get the min. of the modifier's BBox
		max = getModContextBBoxMax Obj theBend --get the max. of the modifier's BBox
		deleteModifier Obj theBend	--delete the modifier
		case type of
		(
			#width:max.x-min.x
			#lenght:max.y-min.y
			#height:max.z-min.z
		)
	)
)

struct mcSystem
(
	fn units_type = 
	(
		case units.SystemType of
		(
			#Inches:"inc"
			#Feet:"ft"
			#Miles:"mi"
			#Millimeters:"mm"
			#Centimeters:"cm"
			#Meters:"m"
			#Kilometers:"km"
		)
	),
	fn time = 
	(
		Local arr, mTime
		arr = filterString LocalTime "./ :"
		if arr.count < 5 do return "invalid time"
		mTime = arr[4] + ":" + arr[5] + "   " + arr[1] + "." + arr[2] + "." + arr[3]
		return mTime
	),
	fn autosaveSwitch = (
	
		local current_state = autosave.enable
		autosave.enable = not current_state
		messageBox ("Autosave is turned to:" + autosave.enable as string) title:" Micra:"
	),
	fn keyboardSwitch = (
	
		local current_shortcuts = actionMan.getKeyboardFile() 
		local merlin_shortcuts = "D:\ReneBaca\3DsMax\Merlin_UI_2018.kbdx"
		local default_shortcuts = "D:\ReneBaca\3DsMax\DefaultUI.kbdx"
		
		local sortcuts_file = if current_shortcuts == merlin_shortcuts then default_shortcuts else merlin_shortcuts
		actionMan.loadKeyboardFile sortcuts_file
		local state = if sortcuts_file == merlin_shortcuts then "Merlin" else "Default"
		messageBox ("Shortcuts was set to:" + state) title:" Micra:"
	),
	fn editTexturesInPhotoshop = 
	(		
		if not QueryBox "Edit Textures in Photosop?" title:" Micra:" do return false
		fn getDirectXBitmaps mat = 
		(
			local bCount = mat.numberofbitmaps()
			newimages= for i=1 to bCount where ((local b = mat.geteffectbitmap i) != undefined) collect b
		)
		
		local images=#()
		if mateditor.isopen() 
		then
		(
			local mat=medit.getcurmtl()
			if classOf mat == DirectX_9_Shader
			then images= getDirectXBitmaps mat
			else images= getClassInstances Bitmaptexture target:mat -- get all textures from material or multimaterial
		) 
		else
		(
			local sel=selection as array
			if sel.count == 0 do return false
			for o in sel do
			(
				if o.material!=undefined then
				(
					local newimages

					if classOf o.material == DirectX_9_Shader 
					then newimages= getDirectXBitmaps o.material
					else newimages= getclassinstances Bitmaptexture target:o.material

					--collecting unique images to array
					for i in newimages do mcArray.appendIfUnique images i
				)
			)
		)
		local ps=CreateOLEObject"Photoshop.Application"
		ps.Visible=true
		for i in images do
		( 
			if doesFileExist i.filename 
			then ps.open i.filename
			else messageBox ("The file: ["+i.filename+"] is not Exist.") title:"Micra..."
		)
	),
	fn show arg  =
	(
		print "---------------------------------------------------------------------------" 
		format "Info:%\n" arg 
		print "---------------------------------------------------------------------------"
		try (format "ClassOf: %\n"      (classOf        arg)) catch (format "No ClassOf for %\n" arg)
		try (format "SuperClassOf: %\n" (superClassOf   arg)) catch (format "No SuperClassOf for %\n" arg)
		try (format "ShowClass: %\n"   (showClass      arg)) catch (format "No ShowClass for %\n" arg)
		try (format "show:%\n"       (show           arg)) catch (format "No Show for %\n" arg)
 		try (format "PROPERTIES:\n"   (showProperties arg)) catch (format "No Properties for %\n" arg)
 		try (format "METHODS:\n"    (showMethods    arg)) catch (format "No Methods for %\n" arg)
 		try (format "EVENTS:\n"      (showEvents     arg)) catch (format "No Events for %\n" arg)
		try (format "PropNames: %\n" (getPropNames   arg)) catch (format "No PropNames for %\n" arg)
		try (format "Interface: %\n"   (showInterface  arg)) catch (format "No Interface for %\n" arg)
		try (format "Constructors: %\n" (dotNet.showConstructors arg)) catch (format "No Constructors for %\n" arg)
		try (format "GetInterface: %\n" (getInterface arg)) catch (format "No GetInterface for %\n" arg)
	),
	fn getAllDialogsHWND = ( for i in UIAccessor.GetPopupDialogs() collect (UIAccessor.GetWindowText i) ),
	fn closeDialogByTitle window_text =
	(
		local ace = UIAccessor.GetPopupDialogs()
		for i in ace where findString (UIAccessor.GetWindowText i) window_text != undefined do 
		(
			UIAccessor.CloseDialog i
			--UIAccessor.PressButtonByName i "Cancel"
			exit
		)
	),	
	fn getDialogHWND window_text =
	(
		for d in UIAccessor.GetPopupDialogs() where
		findString (UIAccessor.GetWindowText d) window_text != undefined do exit with d
	),
	fn getDialogData window_text =
	(
		for i in UIAccessor.GetPopupDialogs() where 
		findString (UIAccessor.GetWindowText i) window_text != undefined do 
		(
			format "WindowText:%\n" (UIAccessor.GetWindowText i)
			format "WindowClassName:%\n" (UIAccessor.GetWindowClassName i)
			format "WindowResourceID:%\n"(UIAccessor.GetWindowResourceID i)
			format "GetChildWindows:%\n"(UIAccessor.GetChildWindows i)
			format "GetParentWindow:%\n"(UIAccessor.GetParentWindow i)
			format "GetFirstChildWindow:%\n"(UIAccessor.GetFirstChildWindow i)
			format "GetPrevWindow:%\n"(UIAccessor.GetPrevWindow i)
			format "GetNextWindow:%\n"(UIAccessor.GetNextWindow i)
			format "IsWindow:%\n"(UIAccessor.IsWindow i)
			format "GetWindowDllFileName:%\n"(UIAccessor.GetWindowDllFileName i)
			format "GetWindowDllDescription:%\n"(UIAccessor.GetWindowDllDescription i)
			exit
		)
	),
	fn getActionData action_category action_name = (
	
		if not doesFileExist Micra.ActionsIni do ((format "Not found! [%]\n" Micra.ActionsIni); return undefined)
		local data = getIniSetting Micra.ActionsIni action_category action_name --#(106, "mcAnimation.reverse 0 10" , "Reverse_Animation")
		if data != "" do (
				
			local data_array = execute data --convert string to array
			if classof data_array != array then exit --conversion failed
			return data_array
		)
		return undefined
	),
	--search in Micra.ActionsIni by name
	fn getActionByName action_name = (
	
		if not doesFileExist Micra.ActionsIni do ((format "Not found! [%]\n" Micra.ActionsIni); return undefined)
		local heads = getIniSetting Micra.ActionsIni
		for action_category in heads do( --INI Heads
			local data = getIniSetting Micra.ActionsIni action_category action_name --INI Key
			if data != "" do (
				
				local data_array = execute data --convert string to array
				if classof data_array != array then exit --conversion failed
				local mc_obj = mcObject()
				mc_obj.add "name" action_name
				mc_obj.add "category" action_category
				mc_obj.add "val" data_array
				return mc_obj -- mcObject(name:action_name, category:action_category, val:data_array)
			)
		)
		return undefined
	),
	fn showActionSource action_name = (
		
		local data = mcSystem.getActionByName action_name -- mcObject(name:action_name, category:action_category, val:data_array)
		if data == undefined do return false
		local action_with_cmd = (data.get "val")[2] --(mcAnimation.reverse 0 10 ||  Micra.fileInVersion \"Paint_Selection\"")[2]
		local action_type = if findString action_with_cmd "Micra.fileInVersion" == undefined then "function" else "file"
		--format "action type:%\n" action_type
		case action_type of --mcAnimation.reverse || Paint_Selection
		(
			"function": 
			(
				local action_end = findString action_with_cmd " " --end with: parameter
				if action_end == undefined do action_end = findString action_with_cmd "(" --end with: ()
				local action = substring action_with_cmd 1 (action_end-1)
				--format "show source:%\n" action
				ShowSource (execute action)										
			)
			"file":
			(
				local fname_start = findString action_with_cmd "\""
				local fname = substring action_with_cmd fname_start -1
				fname = execute fname -- remove quotes
				local current_dir = Micra.RootDir
				local fversion = getIniSetting Micra.DefaultSettings "Version" fname
				local file = current_dir + fname + "_v" + fversion + ".ms"
				--format "open file:%\n" file
				edit file
			)
		)
	),
	fn getSHGameVersion =
	(
		local ifile = "c:/Dev/SilentHill/SHGame/Build-info.txt"
		if not doesFileExist ifile do return false
		local f = openfile ifile
		local first_line = readline f
		local v = (filterString first_line ": ")[2]
		setclipboardText v
		print v
		flush f
		close f
	),
	fn getMaxPos = (
		
		return windows.getWindowPos (windows.getMAXHWND())
	),
	fn getMaxCenter = (
	
		local max_pos = mcSystem.getMaxPos()
		return [max_pos.w/2 + max_pos.x /2, max_pos.h/2 + max_pos.y /2]
	)
)

struct mcDraw
(
	fn isBackface poly_obj the_face =
	(
		local v1 = (mapScreenToWorldRay mouse.pos).dir
		local v2 = (normalize (polyOp.getFaceNormal poly_obj the_face))
		if (dot v1 v2) > -0.1 then return true else return false	
	),
	fn collectFrontEdges poly_obj =
	(
		local fCount = poly_obj.Faces.count
		if fCount == 0 do return undefined
		local frontFaces = for f=1 to fCount where not (mcDraw.isBackface poly_obj f) collect f
		if frontFaces.count == 0 do return undefined
		return (polyOp.getEdgesUsingFace poly_obj frontFaces)
	),
	fn showEdgedFaces =
	(
		local poly_obj  = selection[1]
		if poly_obj == undefined or classOf poly_obj != Editable_Poly do return undefined
		--collect front edges
		local FrontEdges = mcDraw.collectFrontEdges poly_obj
		if FrontEdges == undefined do return undefined 
		gw.setTransform (Matrix3 1)
		gw.setColor #line white
		--draw lines from point
		for i in FrontEdges do 
		(
			local verts  = (polyOp.getVertsUsingEdge poly_obj i) as array
			local p1 = polyOp.getVert poly_obj verts[1]
			local p2 = polyOp.getVert poly_obj verts[2]
			gw.Polyline #(p1,p2) false
		)
		local rect = (Box2 [poly_obj.min.x,poly_obj.min.y] [poly_obj.max.x,poly_obj.max.y])
		gw.enlargeUpdateRect rect--#whole 
		gw.updateScreen()
	)
)



struct mcRect 
(
	mi, ma,                  --min, max 
	fn wi =(abs(ma.x-mi.x)), --width 
	fn he =(abs(mi.y-ma.y)), --height  
	fn si =(ma - mi       )  --size
)
/*
re = rect()
rct = re mi:[0,10] ma:[40,60]
rct.wi()
rct.he()
rct.si()
*/
struct mcCube
(
	mi, ma,                  --min, max
	fn wi =(abs(ma.x-mi.x)), --width
	fn he =(abs(mi.y-ma.y)), --height 
	fn le =(abs(mi.z-ma.z)), --lenhth
	fn si =(ma - mi       )  --size
)

/*
cu = cube2()
cub = cu mi:$.min ma:$.max
cub.mi
cub.he()
cub.si()
*/

fn mcDialogSnap dia pos =	
(		
	if dia == undefined or classOf dia != RolloutClass or pos == undefined do return false
	local sd=mcSCREENS_DATA()
	local current_monitor = sd.active()
	local desktop_size = sd.fullsize()
	desktop_size.y = (sd.size num:current_monitor).y --sysInfo.DesktopSize
	desktop_size -= 6
	local desktop_pos = (sd.pos num:current_monitor) --[0, 0]
	--local desktop_size = sysInfo.DesktopSize - 6
	--local desktop_pos = [4, 4]
	local dialogA_pos = (getDialogPos  dia)-- position from picked dialog 
	local dialogA_size = (getDialogSize dia)-- size from picked dialog
	local rect_desktop   = mcRect mi:desktop_pos ma:desktop_size--min/max from windows size
	local rect_dialogA   = mcRect (p=copy dialogA_pos) (p+dialogA_size+[0,4])--min max from picked dialog
	
	--get bounds rect from picked dialog
	local x = rect_dialogA.mi.x
	local y = rect_dialogA.mi.y
	
	--Zadr???
	local dialogA_newpos = mouse.screenpos - pos
	rect_dialogA.mi.x = dialogA_newpos.x
	rect_dialogA.ma.x = x + dialogA_size.x
	rect_dialogA.mi.y = dialogA_newpos.y
	rect_dialogA.ma.y = y + dialogA_size.y + 4
	
	local sDist = rect_desktop.ma.x / 200-- set snap distance
	
	--get visible Dialog names
	local allDialogs = getINISetting Micra.TempProfileIni "Properties_1" + getINISetting Micra.TempProfileIni "Properties_2"
	local visDialogs = for i in allDialogs where (execute (i+" != undefined")) and (execute ("classOf "+ i +" == RolloutClass")) and (execute(i+".isDisplayed")) collect i

	for i in visDialogs do
	(
		local dialogB_name = (execute i)
		local dialogB_pos  = (getDialogPos  dialogB_name)
		local dialogB_size = (getDialogSize dialogB_name)
		--min max from B (visible) dialogs
		rect_dialogB = mcRect dialogB_pos (dialogB_pos+dialogB_size+[0,4])
		
		--Left
		if rect_dialogA.mi.x < rect_dialogB.ma.x+sDist and rect_dialogA.mi.x > rect_dialogB.ma.x-sDist and 
		rect_dialogA.ma.y > rect_dialogB.mi.y and rect_dialogA.mi.y < rect_dialogB.ma.y
		then rect_dialogA.mi.x = rect_dialogB.ma.x+6
		--Zadr???
		rect_dialogA.ma.x = rect_dialogA.mi.x + dialogA_size.x
		--Right
		if rect_dialogA.ma.x > rect_dialogB.mi.x-sDist and rect_dialogA.ma.x < rect_dialogB.mi.x+sDist and 
		rect_dialogA.ma.y > rect_dialogB.mi.y and rect_dialogA.mi.y < rect_dialogB.ma.y
		then rect_dialogA.mi.x = (rect_dialogB.mi.x-dialogA_size.x)-6
		--Top
		if rect_dialogA.ma.y > rect_dialogB.mi.y-sDist and rect_dialogA.ma.y < rect_dialogB.mi.y+sDist and 
		rect_dialogA.ma.x > rect_dialogB.mi.x and rect_dialogA.mi.x < rect_dialogB.ma.x 
		then rect_dialogA.mi.y = (rect_dialogB.mi.y-dialogA_size.y)-6
		--Zadr???
		rect_dialogA.ma.y = rect_dialogA.mi.y + dialogA_size.y
		--Bottom
		if rect_dialogA.mi.y < rect_dialogB.ma.y+sDist and rect_dialogA.mi.y > rect_dialogB.ma.y-sDist and 
		rect_dialogA.ma.x > rect_dialogB.mi.x and rect_dialogA.mi.x < rect_dialogB.ma.x 
		then rect_dialogA.mi.y = rect_dialogB.ma.y+2
	)

	--if is in Left bound
	if rect_dialogA.mi.x < rect_desktop.mi.x+sDist 
	then x = 0 
	else 
	--if is in Right bound
	if rect_dialogA.mi.x+dialogA_size.x > rect_desktop.ma.x-sDist 
	then x = (rect_desktop.ma.x-dialogA_size.x) 
	else x = rect_dialogA.mi.x		
	--if is in Top bound
	if rect_dialogA.mi.y < rect_desktop.mi.y+sDist 
	then y = 0 
	else 
	--if is in Bottom bound
	if rect_dialogA.mi.y+dialogA_size.y > rect_desktop.ma.y-sDist 
	then y = (rect_desktop.ma.y-dialogA_size.y)
	else y = rect_dialogA.mi.y
	
	--final move action
	if (dialogA_pos.x != x or dialogA_pos.y != y) do setDialogPos dia [x, y]
)

struct mcSCREENS_DATA --NEED INSTANCE
(
	scr = (dotNetClass "System.Windows.Forms.Screen"),	
	fn count = (scr.AllScreens.count),
	fn name num:1 = (scr.AllScreens[num].DeviceName),
	fn size num:1 = 
	(
		if scr.AllScreens.count < num do return false
		[scr.AllScreens[num].Bounds.Width, scr.AllScreens[num].Bounds.Height]
	),
	fn fullSize = 
	(
		local size = [0, 0]
		for s in scr.AllScreens do size += [s.Bounds.Width, s.Bounds.Height]
		return size
	),
	fn active =
	(
		local p = dotnetObject "Drawing.Point" mouse.screenpos.x mouse.screenpos.y
		for i=1 to scr.AllScreens.count where scr.AllScreens[i] == (scr.FromPoint p) do return i
		--(scr.FromPoint p).DeviceName
	),
	fn pos num:1 = 
	(
		if scr.AllScreens.count < num do return false
		[scr.AllScreens[num].Bounds.x, scr.AllScreens[num].Bounds.y]
	)
 )

 --call: mcUIColors.get #back
Struct mcUIColors(
	
	fn get clr = (
		
		local last_profile = execute (mcFile.saveLoadIniSetings head:"Interface" key:"lastprofile" action:#load)
		local profiles = #("DefaultColor", "UserColor", "ForestColor", "EarthColor", "MoonColor", "SeaColor", "SunColor", "Close")
		local head_str = profiles[last_profile]
		case clr of (
			
			#back		: execute (mcFile.saveLoadIniSetings head:head_str key:"backcolor" action:#load)
			#fore			: execute (mcFile.saveLoadIniSetings head:head_str key:"forecolor" action:#load)
			#sel			: execute (mcFile.saveLoadIniSetings head:head_str key:"selected"  action:#load)
			#mark		: execute (mcFile.saveLoadIniSetings head:head_str key:"marked"  action:#load)
			#btn			: execute (mcFile.saveLoadIniSetings head:head_str key:"button"   action:#load)
			#inact		: execute (mcFile.saveLoadIniSetings head:head_str key:"inactive"  action:#load)
			#text			: execute (mcFile.saveLoadIniSetings head:head_str key:"textcolor"  action:#load)
			#seltext		: execute (mcFile.saveLoadIniSetings head:head_str key:"seltext"  action:#load)
			#opacity	:execute (mcFile.saveLoadIniSetings head:head_str key:"opacity"  action:#load)
			#edtback	:execute (mcFile.saveLoadIniSetings head:head_str key:"editback"  action:#load)
			#edtfore	:execute (mcFile.saveLoadIniSetings head:head_str key:"editfore"  action:#load)
		)
	)
)

--call: mcCursor.get #cursor
Struct mcCursor (

	fn get type = (
		return case type of (
			
			#cursor	: dotNetClass "System.Windows.Forms.cursor"
			#cross	:dotNetObject "System.Windows.Forms.Cursor" (Micra.ImgPath+"cross.ico")
			#pipe		: dotNetObject "System.Windows.Forms.Cursor" (Micra.ImgPath+"pipe.ico")
			#fill		: dotNetObject "System.Windows.Forms.Cursor" (Micra.ImgPath+"fill.ico")
			#arrow	: dotNetObject "System.Windows.Forms.Cursor" (Micra.ImgPath+"harrow.ico")
			#grab	: dotNetObject "System.Windows.Forms.Cursor" (Micra.ImgPath+"hmove.ico")	
		)
	)
)
 

Struct mcSize (w, h)
 
/* --3d bounding box
		for v = 1 to verts.count do
		(
			local p = polyOp.getVert obj v --vert pos
			if type == #local do p *= inverse obj.transform
			if maxX != undefined then
			(
				if p.x < minX then minX = p.x
				if p.y < minY then minY = p.y
				if p.z < minZ then minZ = p.z
				
				if p.x > maxX then maxX = p.x
				if p.y > maxY then maxY = p.y
				if p.z > maxZ then maxZ = p.z
			)
			else
			(
				maxX = minX = p.x
				maxY = minY = p.y
				maxZ = minZ = p.z
			)
		)
*/