Global mcPredefinedIconForEditor

if mcIconMakerDialog != undefined do destroyDialog mcIconMakerDialog
rollout mcIconMakerDialog "Untitled" width:772 height:520
(
	-->Locals:-----------------------------------------------------------------
	local dMove = false, DmPos --, cDraw = false, corner
	local tempImgLib_I, tempImgLib_M, tempCanvasImage, tempButtonMask, tempButtonDifuse, tempCanvasImage
	local activeIcon, corner, isDrawingEnabled = false, tempButtonSwitch = #dif, bg_color = black --color 75 75 75 --gray
	local pen_draw_style = #standart , ActiveFill = false
	local cursor         = dotNetClass "System.Windows.Forms.cursor"
	local cursor_cross   = dotNetObject "System.Windows.Forms.Cursor" (mcImgPath+"cross.ico")
	local cursor_pipe    = dotNetObject "System.Windows.Forms.Cursor" (mcImgPath+"pipe.ico")
	local cursor_fill    = dotNetObject "System.Windows.Forms.Cursor" (mcImgPath+"fill.ico")
	local undo_array = #(), undo_enabled = true, undo_limit = 40
	--Menu:---------------------------------------------------------------------
	button btn_24_i "" pos:[96,268] width:24 height:24 images:#(bitmap 24 24 color:black, undefined, 1, 1, 1, 1, 1)
	button btn_24_m "" pos:[96,296] width:24 height:24 images:#(bitmap 24 24 color:black, undefined, 1, 1, 1, 1, 1)
	--ActiveXControl lv "MSComctlLib.ListViewCtrl" pos:[16,24] width:240 height:240
	dotNetControl lv "system.windows.forms.pictureBox" pos:[16,24] width:240 height:240
	bitmap bmp_Canvas "Bitmap" pos:[16,24] width:240 height:240 bitmap:(bitmap 240 240 color:black)
	ImgTag tag_icons "Bitmap" pos:[276,24] width:480 height:480 transparent:(gray) bitmap:(bitmap 480 480 color:black)
	GroupBox grp1 "Icon Maker:" pos:[8,4] width:256 height:324
	GroupBox grp2 "Icon Library: 1/100" pos:[268,4] width:496 height:508
	button btn_render "Render" pos:[16,268] width:76 height:52 toolTip:"Pres CTRL to Render Selection"
	button btn_clear "Clear" pos:[204,296] width:52 height:24 toolTip:"Clear Canvas"
	button btn_save "Save" pos:[172,476] width:76 height:24 toolTip:"Save Icons"
	button btn_add ">>" pos:[232,268] width:24 height:24 toolTip:"Add Icon..."
	button btn_load "<<" pos:[204,268] width:24 height:24 toolTip:"Edit Icon..."
	colorPicker cp_front "" pos:[84,348] width:32 height:24 color:(color 255 255 255)
	colorPicker cp_back "" pos:[116,348] width:32 height:24 color:(color 0 0 0)
	button btn_swap_picker "Swap" pos:[88,374] width:62 height:24
	button btn_reset_picker "Reset" pos:[88,400] width:62 height:24
	button btn_exit "*" pos:[752,4] width:12 height:12 toolTip:"Exit"
	checkbutton ckb_brush_s "Sta" pos:[20,356] width:24 height:24 toolTip:"Standart..."
	checkbutton ckb_brush_c "Cro" pos:[20,384] width:24 height:24 toolTip:"Cross..."
	checkbutton ckb_brush_l "Lin" pos:[20,412] width:24 height:24 toolTip:"Line..."
	checkbutton ckb_brush_f "Fil" pos:[20,440] width:24 height:24 toolTip:"Fill..."
	button btn_reload_icon_lib "Reload" pos:[172,448] width:76 height:24
	button btn_showImage "Show Image" pos:[172,352] width:76 height:24
	button btn_showMask "Show Mask" pos:[172,380] width:76 height:24
	GroupBox grp5 "Icon Library:" pos:[160,332] width:104 height:180
	GroupBox grp6 "Paint Tools:" pos:[8,332] width:148 height:180
	button btn_copy "Copy" pos:[148,268] width:52 height:24 toolTip:"Clear Canvas"
	button btn_paste "Paste" pos:[148,296] width:52 height:24 toolTip:"Clear Canvas"
	fn getMask Image bgColor:undefined = --#(black)
	(
		local w   = Image.width
		local h   = Image.height
		local img = bitmap w h
		if bgColor == undefined do bgColor = getpixels Image [0,0] 1
		for i = 0 to 23 do
		(
			local m = #()
			local p = getpixels Image [0,i] w
			for j = 1 to h do
			(
				if p[j].r as integer == bgColor[1].r and p[j].g as integer == bgColor[1].g and p[j].b as integer == bgColor[1].b 
				then (m[j] = [255,255,255])
				else (m[j] = [0,0,0] as color)
			)
			setpixels img [0,i] m
		)
		return img	
	)
	fn editIcon =
	(
		tempCanvasImage     = bitmap 240 240
		tempButtonDifuse    = bitmap 24 24
		copy activeIcon tempButtonDifuse
		copy activeIcon tempCanvasImage 
		bmp_Canvas.bitmap = tempCanvasImage
		tempButtonMask      = getMask activeIcon bgColor:#(black)
		btn_24_m.images   = #(tempButtonMask  , undefined, 1,1,1,1,1)
		btn_24_i.images   = #(tempButtonDifuse, tempButtonMask, 1,1,1,1,1)
	)
	fn addIconToLibrary =
	(
		for y=0 to 24 do 
		(
			 --draw difuse to library
			local pixel_array = getPixels tempButtonDifuse [0,y] 24
			setPixels tempImgLib_I [corner.x, corner.y+y] pixel_array
			 --draw mask   to library
			local pixel_array = getPixels tempButtonMask   [0,y] 24
			setPixels tempImgLib_M [corner.x, corner.y+y] pixel_array
		)
		tag_icons.bitmap = tempImgLib_I
	)
	fn delIconFromLibrary =
	(
		local blank_dif  = bitmap 24 24 color:black
		local blank_mask = bitmap 24 24 color:white
		for y=0 to 24 do 
		(
			--del dif
			local pixel_array = getPixels blank_dif [0,y] 24
			setPixels tempImgLib_I [corner.x, corner.y+y] pixel_array
			--del mask
			local pixel_array = getPixels blank_mask [0,y] 24
			setPixels tempImgLib_M [corner.x, corner.y+y] pixel_array
		)
		tag_icons.bitmap = tempImgLib_I
	)
	fn setBitmapToCanvas img =
	(
		tempButtonMask = getMask img bgColor:#(black)
		btn_24_i.images = #(img, tempButtonMask, 1,1,1,1,1 )
		btn_24_m.images = #(tempButtonMask, undefined, 1,1,1,1,1 )
		copy img tempButtonDifuse
		copy img tempCanvasImage
		bmp_Canvas.bitmap = tempCanvasImage
	)
	fn renderToCanvas =
	(
		local wasCancelled = false
		local img = 
		(
			local render_type = if keyboard.controlPressed then #selection else #normal
			render outputsize:[24,24] antiAliasing:true enablePixelSampler:false shadows:true \
			quiet:true renderType:render_type vfb:off cancelled:&wasCancelled
		)
		if (not wasCancelled) do setBitmapToCanvas img
	)
	fn getIconCornerFrom pos =
	(
		local rect = pos/24	
		local c = [(floor rect.x)*24,(floor rect.y)*24]
		return c
	)
	fn higlightButton icn col =
	(
		icn = copy icn -- prevent to owerwrite
		--draw lines
		for i=0 to 24 do
		(
			setpixels icn [i, 0] #(col) --top
			setpixels icn [i,23] #(col) --bottom
			setpixels icn [0, i] #(col) --left
			setpixels icn [23,i] #(col) --right
		)
		return icn
	)
	fn getIconNumBy pos =
	(
		local pos = pos/24
		pos = [ceil pos.x , floor pos.y]
		pos = (pos.x + (pos.y *20)) as integer
		if pos == 0 do pos = 1
		grp2.text = "Icon Library: "+pos as string+"/400"
	)
	fn getIconPosBy num =
	(
		local y = (ceil (num/20 as float)) as integer
		local x = (num - (y-1)*20) as integer
		--format "icon number:%\tpos:%\n" num [x, y]
		return [x, y]
	)
	fn MarkIcon pos =
	(
		tag_icons.bitmap = tempImgLib_I
		corner = getIconCornerFrom pos
		if keyboard.shiftPressed   do addIconToLibrary()
		if keyboard.altPressed     do delIconFromLibrary()
		local img = bitmap 480 480 color:black
		copy tempImgLib_I img -- prevent to owerwrite
		--get icon from library
		for y=0 to 24 do 
		(
			local pixel_array = getPixels img [corner.x, corner.y+y] 24
			setPixels activeIcon [0,y] pixel_array
		)
		--hilight icon
		local icnH = higlightButton activeIcon green--white
		--redraw icon to library
		for y=0 to 24 do 
		(
			local pixel_array = getPixels icnH [0,y] 24
			setPixels img [corner.x, corner.y+y] pixel_array
		)
		tag_icons.bitmap = img
		getIconNumBy pos	
	)
	fn LoadIconLibrary =
	(
		if not doesFileExist mcIconI or not doesFileExist mcIconM do return false
		tempImgLib_I = openBitmap mcIconI
		tempImgLib_M = openBitmap mcIconM
		tag_icons.bitmap = tempImgLib_I
	)
	fn clearCanvas =
	(
		tempButtonDifuse = bitmap 24 24 color:black
		tempButtonMask   = bitmap 24 24 color:white
		btn_24_i.images = #(tempButtonDifuse, tempButtonMask, 1,1,1,1,1 )
		btn_24_m.images = #(tempButtonMask, undefined, 1,1,1,1,1 )
		copy tempButtonDifuse tempCanvasImage
		bmp_Canvas.bitmap = tempCanvasImage
	)
	fn Inicialize =
	(
		tempButtonDifuse = bitmap 24 24
		tempCanvasImage  = bitmap 240 240
		activeIcon       = bitmap 24 24 color:black
		loadIconLibrary()
		clearCanvas()
		--get external icon select command
		--if mcPredefinedIconForEditor != undefined and classOf (mcPredefinedIconForEditor as integer) == integer
		--then MarkIcon (getIconPosBy (mcPredefinedIconForEditor as integer))
		--else 
		MarkIcon [0,0]
		
		ckb_brush_s.checked = true
	)
	fn SaveIconsToFile =
	(
		if not queryBox "You are sure to save changes?" title:" Micra III?" do return false
		local I = bitmap 480 480
		local M = bitmap 480 480 
		
		local output_dithering = rendDitherTrue
		--prevent image to change during save proces
		rendDitherTrue = false
		
		copy tempImgLib_I I
		copy tempImgLib_M M
		I.filename = mcIconI
		M.filename = mcIconM
		save I
		save M
		
		rendDitherTrue = output_dithering
	)
	---------------------------------------------------
	---------------------------------------------------
	fn crossDraw img PixArr w h pColArr colArr = 
	(
	    local newPixArr = #()
	    local pixArr
	    for p in PixArr do
	    (
	        -- -x
	     --   if p.x-1 >= 0 do
			( 
				pixArr=getpixels img [p.x-1, p.y] 1
				if pixArr.count != 0 and pColArr[1] == pixArr[1] do
		        (
		    		newPixArr+=#([p.x-1,p.y])
		    		setpixels img [p.x-1, p.y] colArr    
		        )
			)
	        -- +x
	       --	if p.x+1 < 24 do
			(
	 			pixArr=getpixels img [p.x+1, p.y] 1
				if pixArr.count != 0 and pColArr[1] == pixArr[1] do
		        (
		    		newPixArr+=#([p.x+1,p.y])
		    		setpixels img [p.x+1, p.y] colArr
				)
			)
	        -- -y
	     --   if p.y-1 >= 0 do
			(
				pixArr=getpixels img [p.x, p.y-1] 1
				if pixArr.count != 0 and pColArr[1] == pixArr[1] do
		        (
		   			newPixArr+=#([p.x,p.y-1])
		    		setpixels img [p.x, p.y-1] colArr
				)
			)
	        -- +y
	     --   if p.y+1 < 24 do
			(
	 			pixArr=getpixels img [p.x, p.y+1] 1
				if pixArr.count != 0 and pColArr[1] == pixArr[1] do
		        (
		   			newPixArr+=#([p.x,p.y+1])
		    		setpixels img [p.x, p.y+1] colArr
		    	)
			)
		)
	    return newPixArr
	)
	fn crossFill img PixArr colArr = 
	(
	    local w   = 20
		local h   = 20
		--format "canvasSize1:%\n" [img.width, img.height]
		local pColArr = getpixels img PixArr[1] 1
		if colArr[1] == pColArr[1] do return img
		
		while PixArr.count != 0 and PixArr.count < 1000 and not keyboard.escPressed do
	    (
	        --format "PixArr.count:%\n" PixArr.count
			PixArr = crossDraw img PixArr w h pColArr colArr
	    )
		return img
	)
	fn updateDrawing type =
	(
		--if type == #dif 
		--then tempButtonMask = getMask tempButtonDifuse bgColor:#(black)
		--else tempButtonDifuse = getProjectedMask tempButtonDifuse tempButtonMask
		btn_24_m.images   = #(tempButtonMask  , undefined, 1,1,1,1,1)
		btn_24_i.images   = #(tempButtonDifuse, tempButtonMask, 1,1,1,1,1)
		
		case type of
		(
			#dif  : ( copy tempButtonDifuse tempCanvasImage )
			#mask : ( copy tempButtonMask   tempCanvasImage )
		)
		bmp_Canvas.bitmap = tempCanvasImage
	)
	fn DrawToCanvas arg move:true =
	(
		local mouse_btn = arg.Button.ToString()
		local x = arg.x
		local y = arg.y
		
		--mouse icons
		if keyboard.altPressed 
		then cursor.Current = cursor_pipe
		else if ckb_brush_f.checked then cursor.Current = cursor_fill
		else cursor.Current = cursor_cross
		--format "mousePos:%\n" [x,y]
		
		if isDrawingEnabled then
		(
			local clr, undo_img = bitmap 24 24 color:black
			case mouse_btn of --LMB, RMB, MB
			(
				"Left": 
				(
					clr = cp_front.color
					if undo_enabled do
					(
						--format "undo array count :%\tundo limit:%\n" undo_array.count undo_limit
						copy tempButtonDifuse undo_img  --copy canvas before changes
						if undo_array.count > undo_limit do deleteItem undo_array 1 --if undo buffer is full then remove old undo
						undo_array += #(undo_img) --add new undo state
						undo_enabled = false
					)
				)
				"Right": 
				(
					clr = cp_back.color
					if undo_enabled do
					(
						--format "undo array count :%\tundo limit:%\n" undo_array.count undo_limit
						copy tempButtonDifuse undo_img --copy canvas before changes
						if undo_array.count > undo_limit do deleteItem undo_array 1 --if undo buffer is full then remove old undo
						undo_array += #(undo_img) --add new undo state
						undo_enabled = false
					)
				)
				"Middle":--undo
				( 
					--print undo_array.count
					if undo_array.count != 0 do
					(
						tempButtonDifuse = undo_array[undo_array.count]
						deleteItem undo_array undo_array.count
						updateDrawing tempButtonSwitch
					)
				)
				"XButton1":()
				"XButton2":()
			)
			
			if clr == undefined do return false
			
			case pen_draw_style of
			(
				#standart : 
				(
					case tempButtonSwitch of
					(
						#dif:
						(
							setPixels tempButtonDifuse [x/10,y/10] #(clr)
							
							--reflexe to oposite alpha or difuse
							clr = if clr == bg_color then white else black
							setPixels tempButtonMask [x/10,y/10] #(clr)
							
							updateDrawing tempButtonSwitch
						)
						#mask:
						(
							setPixels tempButtonMask [x/10,y/10] #(clr)
							
							--reflexe to oposite alpha or difuse
							clr = if clr == bg_color then white else black
							setPixels tempButtonDifuse [x/10,y/10] #(clr)
							
							updateDrawing tempButtonSwitch
						)
					)
				)
				#cross    : 
				(
					case tempButtonSwitch of
					(
						#dif:
						(				
							setPixels tempButtonDifuse [x/10  , y/10+1] #(clr)
							setPixels tempButtonDifuse [x/10-1, y/10  ] #(clr,clr,clr)
							setPixels tempButtonDifuse [x/10  , y/10-1] #(clr)
							
							--reflexe to oposite alpha or difuse
							clr = if clr == bg_color then white else black
							setPixels tempButtonMask [x/10  , y/10+1] #(clr)
							setPixels tempButtonMask [x/10-1, y/10  ] #(clr,clr,clr)
							setPixels tempButtonMask [x/10  , y/10-1] #(clr)
							
							updateDrawing tempButtonSwitch
						)
						#mask:
						(
							setPixels tempButtonMask [x/10  , y/10+1] #(clr)
							setPixels tempButtonMask [x/10-1, y/10  ] #(clr,clr,clr)
							setPixels tempButtonMask [x/10  , y/10-1] #(clr)
							
							--reflexe to oposite alpha or difuse
							clr = if clr == bg_color then white else black
							setPixels tempButtonDifuse [x/10  , y/10+1] #(clr)
							setPixels tempButtonDifuse [x/10-1, y/10  ] #(clr,clr,clr)
							setPixels tempButtonDifuse [x/10  , y/10-1] #(clr)
							
							updateDrawing tempButtonSwitch
						)
					)
				)
				#line     : 
				(
					case tempButtonSwitch of
					(
						#dif:
						(
							setPixels tempButtonDifuse [x/10-1, y/10  ] #(clr,clr,clr)
							
							--reflexe to oposite alpha or difuse
							clr = if clr == bg_color then white else black
							setPixels tempButtonMask [x/10-1, y/10  ] #(clr,clr,clr)
							updateDrawing tempButtonSwitch
						)
						#mask:
						(
							setPixels tempButtonMask [x/10-1, y/10  ] #(clr,clr,clr)
							
							--reflexe to oposite alpha or difuse
							clr = if clr == bg_color then white else black
							setPixels tempButtonDifuse [x/10-1, y/10  ] #(clr,clr,clr)
							
							updateDrawing tempButtonSwitch
						)
					)
				)
				#fill     : 
				(
					if move == true or ActiveFill do return false
					ActiveFill = true
					local pixArray   = #([x,y]/10)
					
					tempButtonDifuse = crossFill tempButtonDifuse pixArray #(clr)
					--reflexe to oposite alpha
					tempButtonMask = getMask tempButtonDifuse bgColor:#(bg_color)
					
					updateDrawing tempButtonSwitch
					
					ActiveFill = false
				) 
			)
		)
		else
		(
			case mouse_btn of
			(
				
				"Left":(cp_front.color = (getPixels tempCanvasImage [x, y] 1)[1])
				"Right":(cp_back.color  = (getPixels tempCanvasImage [x, y] 1)[1] )
				"Middle":()
				"XButton1":()
				"XButton2":()
			)
		)
	)
	fn penSwitch ckb state =
	(
		local ckbArr = #(ckb_brush_s, ckb_brush_c, ckb_brush_l, ckb_brush_f)
		for i in ckbArr where i != ckb do i.state = false
		
		pen_draw_style = case ckb of
		(
			ckb_brush_s : #standart
			ckb_brush_c : #cross
			ckb_brush_l : #line
			ckb_brush_f : #fill
		)
	)
	fn copyImageToClipboard =
	(
		local img = bitmap 24 24 color:black
		copy tempButtonDifuse img
		local clipboardClass = dotNetClass "System.Windows.Forms.Clipboard" --create a Clipboard dotNetClass
		local file_name = GetDir #image + "ImageClipboard.bmp" --define a temp.file name
		img.filename = file_name
		save img
		close img
		local image_class = dotNetClass "System.Drawing.Image" --create an Image dotNetClass
		local dotnet_bitmap = image_class.FromFile file_name --get the saved image from file as bitmap
		clipboardClass.setImage dotnet_bitmap --copy the image to clipboard
		dotnet_bitmap.Dispose() --release the bitmap 
		deleteFile file_name --delete the temp. file
	)
	fn getImageFromClipboard =
	(
		--get image from clipboard
		local clipboardClass = dotNetClass "System.Windows.Forms.Clipboard" --create a Clipboard dotNetClass
		if not clipboardClass.ContainsImage() do return undefined --return true if the clipboard contains image
		local dotnet_bitmap = clipboardClass.getImage()
		local w = dotnet_bitmap.Width
		local h = dotnet_bitmap.Height
		if [w, h] != [24, 24] do (dotnet_bitmap.Dispose(); return false )--release the bitmap
		--rewrite bitmap from clipboard to new bitmap
		local new_bitmap = bitmap w h color:black
		for Y = 0 to (h-1) do
		(
			clr_array = #()
			for X = 0 to (w-1) do
			(
				
				pix = (dotnet_bitmap.GetPixel x y)
				--format "pixel pos:%\n" [x,y]
				clr_array += #(color pix.r pix.g pix.b)
				
			)
			setPixels new_bitmap [ 0, y ] clr_array --fills canvas from left down to left up
		)
		dotnet_bitmap.Dispose() --release the bitmap
		--assing new bitmap to canvas and buttons
		setBitmapToCanvas new_bitmap
	)
	---------------------------------------------------pos.y < 22 or pos.y > 266 or pos.x < 15 or pos.x > 360
	---------------------------------------------------
	on mcIconMakerDialog open              do (Inicialize())
	on mcIconMakerDialog close             do (mcCall.saveIniDialog "mcIconMakerDialog" "Properties_2")
	--on mcIconMakerDialog rbuttonup pos     do (if not isDrawingEnabled do destroyDialog mcIconMakerDialog)-- if not in paint canvas
	on mcIconMakerDialog lbuttondown pos   do (dMove = true; DmPos = pos; if not keyboard.shiftPressed do pushprompt "Pres Shift To Move...")
	on mcIconMakerDialog lbuttonup pos     do (dMove = false; pushprompt "")
	on mcIconMakerDialog mouseMove pos     do (if dMove and keyboard.shiftPressed do (setDialogPos mcIconMakerDialog (mouse.screenpos - DmPos)))
		
	on lv mouseDown arg do (isDrawingEnabled = true; DrawToCanvas arg move:false)
	on lv mouseUp   arg do (isDrawingEnabled = false; undo_enabled = true)
	on lv mouseMove arg do (DrawToCanvas arg)
	
	on btn_render pressed  do renderToCanvas()
	on btn_save   pressed  do saveIconsToFile()
	on btn_clear  pressed  do clearCanvas()

	on btn_load pressed            do (EditIcon()) 
	on btn_add pressed             do (AddIconToLibrary()) 
	on btn_reload_icon_lib pressed do (LoadIconLibrary(); MarkIcon [0,0])
	on tag_icons lbuttonup pos bin do (MarkIcon pos)
	on tag_icons dblclick          do (EditIcon())
	on btn_24_i           pressed  do (bmp_Canvas.bitmap = copy tempButtonDifuse tempCanvasImage; tempButtonSwitch = #dif )
	on btn_24_m           pressed  do (bmp_Canvas.bitmap = copy tempButtonMask   tempCanvasImage; tempButtonSwitch = #mask)
	on btn_showImage      pressed  do (tag_icons.bitmap = tempImgLib_I)
	on btn_showMask       pressed  do (tag_icons.bitmap = tempImgLib_M)
	on btn_exit           pressed  do (DestroyDialog mcIconMakerDialog)
	on ckb_brush_s changed state do penSwitch ckb_brush_s state
	on ckb_brush_c changed state do penSwitch ckb_brush_c state
	on ckb_brush_l changed state do penSwitch ckb_brush_l state
	on ckb_brush_f changed state do penSwitch ckb_brush_f state
	on btn_swap_picker   pressed do 
	(
		local c = cp_front.color
		cp_front.color = cp_back.color
		cp_back.color  = c
	)
	on btn_reset_picker pressed do (cp_front.color = white ; cp_back.color = black)
	on btn_copy pressed do (copyImageToClipboard())
	on btn_paste pressed do (getImageFromClipboard())
	
)
mcCall.createIniDialog "mcIconMakerDialog" "Properties_2"


/*
		fn getAlpha Image w h =
		(
			local img = bitmap Image.width Image.height
			for i = 0 to (w-1) do
			(
				local a = #() --alpha
				local p = getpixels Image [0,i] w --a horizontal pixel ilne
				for j = 1 to h do
				(
					a[j] = [p[j].a, p[j].a, p[j].a] as color
				)
				setpixels img [0,i] a
			)
			return img
		)
*/