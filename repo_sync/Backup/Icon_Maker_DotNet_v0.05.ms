Global mcPredefinedIconForEditor
Global mcIconMakerDialog

try ( mcIconMakerDialog.close() ) catch()

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
	local form_opacity = 1--execute (mcFile.saveLoadIniSetings head:head_str key:"opacity"  action:#load)
	local bar_height      = 14
	local form_bounds     = 2
	local form_offset     = 2 --border line
	local btn_size        = 24
	local form_size       =[746, 516]
	local cp_width        = 48
	local debug = 0
	local tempImgLib_D,  tempImgLib_A, activeIconNum, lastPos = [-1, -1], active_tool = "Brush"
	local transparent_color = color 211 211 211 --((colorMan.getColor #background)*255) as color
	local drawMode = false
	local cursor         = dotNetClass "System.Windows.Forms.cursor"
	local cursor_cross   = dotNetObject "System.Windows.Forms.Cursor" (mcImgPath+"cross.ico")
	local cursor_pipe    = dotNetObject "System.Windows.Forms.Cursor" (mcImgPath+"pipe.ico")
	local cursor_fill    = dotNetObject "System.Windows.Forms.Cursor" (mcImgPath+"fill.ico")
	local cursor_arrow   = dotNetObject "System.Windows.Forms.Cursor" (mcImgPath+"harrow.ico")
	local cursor_grab   = dotNetObject "System.Windows.Forms.Cursor" (mcImgPath+"hmove.ico")
	--<
	
	-->Components---------------------------------------------------------------------
	local form = dotNetObject "MaxCustomControls.Maxform"
	--<
	struct ICON_COMPONENTS_STRUCT
	(
		--variables
		ToolTip   = dotNetObject "ToolTip",
		lblT    = dotNetObject "label" ,
		paint_box = dotNetObject "pictureBox",
		icon_box = dotNetObject "pictureBox",
		tlp     = dotNetObject "TableLayoutPanel",
		btn_render = dotNetObject "button", 
		btn_clear = dotNetObject "button", 
		btn_copy = dotNetObject "button", 
		btn_paste = dotNetObject "button", 
		btn_showImage = dotNetObject "button", 
		btn_showAlpha = dotNetObject "button", 
		btn_cpfront = dotNetObject "button", 
		btn_cpback = dotNetObject "button", 
		btn_swap_picker = dotNetObject "button", 
		btn_reset_picker = dotNetObject "button", 
		btn_add = dotNetObject "button", 
		btn_load = dotNetObject "button", 
		btn_save = dotNetObject "button", 
		btn_reload = dotNetObject "button", 
		btn_brush = dotNetObject "radioButton", 
		btn_line = dotNetObject "radioButton", 
		btn_fill = dotNetObject "radioButton", 
		btn_cross = dotNetObject "radioButton", 
		netDMove = false, 
		netDmPos

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
	fn rbCheck s a = (active_tool = s.text)
	fn pickColor s a =
	(
		local clr = colorPickerDlg (color 100 200 300) "Chose You Color:" alpha:true pos:mouse.screenpos
		if clr != undefined do s.backColor = netDrColor clr
	)
	fn showColorTooltip s a =
	(
		local form = s.parent, mcs = form.tag.value
		--mcs.toolTip.Show (s.BackColor.toString()) s (s.width/2) (s.height/2) 2
		mcs.toolTip.SetToolTip s (s.BackColor.toString())
	)
	fn createNewImage w h clr transparent:false =
	(
		local img = (dotNetObject "Drawing.Bitmap" w h) --Create new bitmap object
		local g  = (dotNetClass "Drawing.Graphics").fromImage img --Create new Graphics object
		local brush = dotNetObject "drawing.SolidBrush" (netDrColor clr)
		g.FillRectangle brush 0 0 w h
		g.dispose()
		if transparent do img.makeTransparent()
		img
	)
	fn getImageFromFile fpath  =
	(
		if not doesFileExist fpath do return false
		local img = (dotNetClass "Drawing.Image").FromFile fpath
		local w = img.width, h = img.height
		local new_img = (dotNetObject "Drawing.Bitmap" w h) --Create new bitmap object
		--new_img.ColorDepth = icon.ColorDepth.Depth24Bit
		local g  = (dotNetClass "Drawing.Graphics").fromImage new_img --Create new Graphics object
		local rect = netDrRect [0, 0] [w, h]
		g.DrawImage img rect --0 0 w h (dotNetClass "Drawing.GraphicsUnit").Pixel	
		img.dispose()
		g.dispose()
		return new_img
	)
	fn resizeImage2 img w h =  --stretch method
	(
		local new_img  = dotNetObject "Drawing.Bitmap" w h  --Create new bitmap object
		local g     = (dotNetClass "Drawing.Graphics").fromImage new_img --Create new Graphics object
		g.InterpolationMode = (dotnetClass "Drawing.Drawing2D.InterpolationMode").NearestNeighbor
		g.pixelOffsetMode = g.pixelOffsetMode.highQuality
		local rect = netDrRect [0, 0] [w, h]
		g.DrawImage img rect
		g.Dispose()
		return new_img
	)
	fn resizeImage img w h =  --redraw method
	(
		local new_img  = dotNetObject "Drawing.Bitmap" w h  --Create new bitmap object
		local brush_size = w/img.width as float
		for x = 0 to w-1 do
		(
			for y = 0 to h-1 do
			(
				--format "pos:%\n" [x, y]
				local p = img.getPixel (x/brush_size) (y/brush_size)
				new_img.SetPixel x y p
			)
		)
		return new_img
	)
	fn getIcon img icnNum transparent:false =
	(
		if icnNum == 0 do return createNewImage 24 24 black
		--local img = (dotNetClass "Drawing.Image").FromFile mcIconI --get the saved image from file as bitmap
		local img_size = [img.width, img.height]
		local icnCount  = (img_size/24)
		icnNum -= 1

		local X = (mod icnNum icnCount.x)
		local Y = (icnNum / icnCount.y) as integer
		local pix_x = X * 24
		local pix_y = Y * 24
		local pos = [pix_x, pix_y]
		
		local new_image = (dotNetObject "Drawing.Bitmap" 24 24) --Create new bitmap object
		--new_image.ColorDepth = new_image.ColorDepth.Depth24Bit
		local g = (dotNetClass "Drawing.Graphics").fromImage new_image --Create new Graphics object
		local newRect = netDrRect [0, 0] [24, 24]  --adjust new_image offset X in button 
		g.DrawImage img newRect pos.x pos.y 24 24 (dotNetClass "Drawing.GraphicsUnit").Pixel	
		--img.dispose()
		if transparent do new_image.MakeTransparent (netDrColor black) --(color 75 75 75)) --gray
		return new_image
	)
	fn setImageToClipboard img =
	(
		local clipboardClass = dotNetClass "Clipboard" --create a Clipboard dotNetClass
		--img.makeTransparent (netDrColor white) 
		clipboardClass.setImage img --copy the image to clipboard
	)
	fn getImageFromClipboard =
	(
		local cd = (dotNetClass "Clipboard").GetDataObject()
		if cd.GetDataPresent (dotNetClass "DataFormats").Bitmap 
		then return cd.GetData (dotNetClass "DataFormats").Bitmap
		else return createNewImage 240 240 transparent_color -- big image
	)
	fn getAlpha img =
	(
		local w = h = img.width
		local new_img = (dotNetObject "Drawing.Bitmap" w h) --Create new bitmap object
		local g  = (dotNetClass "Drawing.Graphics").fromImage new_img --Create new Graphics object
		local brush = dotNetObject "drawing.SolidBrush" (netDrColor white)
		local rect = netDrRect [0, 0] [w, h] 
		g.FillRectangle brush rect 
		g.dispose()
		local clr =  (dotNetClass "Drawing.Color").FromArgb 0 0 0 0--netDrColor transparent_color
		for x = 0 to w-1 do
		(
			for y = 0 to h-1 do
			(
				local p = img.getPixel x y
				if p != clr do new_img.SetPixel x y (netDrColor black)
			)
		)
		return new_img
	)
	fn showDiffuse s a = 
	(
		local form = s.parent, mcs = form.tag.value
		mcs.paint_box.image = resizeImage2 mcs.btn_showImage.image 240 240
	)
	fn showAlpha s a =
	(
		local form = s.parent, mcs = form.tag.value
		mcs.paint_box.image = resizeImage2 mcs.btn_showAlpha.image 240 240
	)
	fn copyIcon s a =
	(
		local form = s.parent, mcs = form.tag.value
		setImageToClipboard mcs.paint_box.image  --copy paint_box icon
		--setImageToClipboard mcs.btn_showImage.image  --copy button icon
	)
	fn pasteIcon s a =
	(
		local form = s.parent, mcs = form.tag.value
		local img = getImageFromClipboard()
		img.MakeTransparent (netDrColor transparent_color)  --186 --211
		--format "color depth:%\n" img.ColorDepth --= icon.ColorDepth.Depth24Bit
		
		mcs.paint_box.image = img
		mcs.btn_showImage.image  = resizeImage2 img 24 24
		mcs.btn_showAlpha.image   = getAlpha mcs.btn_showImage.image
	)
	fn clearIcons s a =
	(
		local form = s.parent, mcs = form.tag.value
		mcs.paint_box.image = createNewImage 240 240 transparent_color transparent:true
		mcs.btn_showImage.image = createNewImage 24 24 transparent_color transparent:true
		mcs.btn_showAlpha.image = createNewImage 24 24 white
	)
	fn loadIconLibrary s a =
	(
		local form = s.parent, mcs = form.tag.value
		tempImgLib_D = getImageFromFile mcIconI
		tempImgLib_A = getImageFromFile mcIconM
		mcs.icon_box.image = tempImgLib_D
	)
	fn saveIconLibrary s a =
	(
		if not queryBox "You are sure to save changes?" title:" Micra III?" do return false		
		local img_format  = dotNetClass "System.Drawing.Imaging.ImageFormat" -- file formats
		tempImgLib_D.save mcIconI img_format.bmp
		tempImgLib_A.save mcIconM img_format.bmp
		--tempImgLib_D.Dispose()
		--tempImgLib_A.Dispose()
	)
	fn getIconCornerFrom pos =
	(
		local rect = pos/24	
		local c = [(floor rect.x)*24,(floor rect.y)*24]
		return c
	)
	fn getIconNumBy pos =
	(
		local pos = pos/24
		pos = [ceil pos.x , floor pos.y]
		pos = (pos.x + (pos.y *20)) as integer
		if pos == 0 do pos = 1
		return pos
	)
	fn getIconPosBy num =
	(
		local y = (ceil (num/20 as float)) as integer
		local x = (num - (y-1)*20) as integer
		--format "icon number:%\tpos:%\n" num [x, y]
		return [x, y]
	)
	fn swapPickerColors s a =
	(
		local form = s.parent, mcs = form.tag.value
		local clr = mcs.btn_cpfront.BackColor
		mcs.btn_cpfront.BackColor = mcs.btn_cpback.BackColor 
		mcs.btn_cpback.BackColor = clr
	)
	fn resetPickerColors s a = 
	(
		local form = s.parent
		local mcs = form.tag.value
		mcs.btn_cpfront.BackColor = netDrColor black
		mcs.btn_cpback.BackColor = netDrColor white
	)
	fn getFormPos s a = --get position in form , for interface adjusting
	(
		format "pos:%\n" [a.x, a.y]
	)
	fn checkGridPos a s tolerance =
	(
		local step = 10
		local x = a.x
		local y = a.y
		local x=x/step as float - x/step
		local y=y/step as float - y/step
		if x < tolerance or y < tolerance then return true else return false
	)
	fn roundPos x y = --draw in canvas 240x240 every 24 24 pixel
	(
		local step = 10
		local new_x =( (x /step)*10) - step/2
		local new_y =( (y /step)*10) - step/2
		--format "location24:%\n" [new_x+10, new_y+10]
		return [new_x+10, new_y+10]
	)
	fn translatePos pos = --calculate pos from 240x240 to 24x24
	(
		local step = 10
		local new_x =(pos.x /step)
		local new_y =(pos.y /step)
		return [new_x, new_y]-0.5
	)
	fn drawPoint s a clr =
	(
		local form = s.parent, mcs = form.tag.value
		local brush_size = 10
		--draw to canvas
		local pos = roundPos a.x a.y 
		if lastPos == pos do return false
		--format "location240:%\n" pos
		lastPos = pos	
		local x = pos.x
		local y = pos.y
		local g = (dotnetclass "Drawing.Graphics").FromImage s.image
		--turn black color to transparent color
		--local net_color = if clr == netDrColor black then netDrColor transparent_color else clr
		local brush = dotNetObject "drawing.SolidBrush" clr --net_color
		--print (brush.color.toString())
		local rect = netDrRect [x-brush_size/2, y-brush_size/2] [brush_size, brush_size] 
		g.FillRectangle brush rect 
		g.dispose()
		--make transparent
		if clr == netDrColor black do s.image.MakeTransparent clr--the black color is transparent
		--update diffuse icon
		local icon_pos = translatePos pos
		mcs.btn_showImage.image.SetPixel icon_pos.x icon_pos.y clr
		--make transparent
		if clr == netDrColor black do mcs.btn_showImage.image.MakeTransparent clr
		--format "location24:%\n" icon_pos
		--update alpha icon
		clr = if (clr == netDrColor black or clr == netDrColor transparent_color) then netDrColor white else netDrColor black
		mcs.btn_showAlpha.image.SetPixel icon_pos.x icon_pos.y clr
		--update canvas
		s.refresh()
		mcs.btn_showImage.refresh()
		mcs.btn_showAlpha.refresh()
	)
	fn fillCanvas s a clr = --using star search technique CW (starting from top), thats mean : we have 8 ways to search around each one pixel
	(
		local form = s.parent, mcs = form.tag.value
		local brush_size = 10
		local w= h = 240
		--get location
		local hit_pos = roundPos a.x a.y  --each pixel is 10x10, and hit is the center
		--get picked color from hit
		local hit_clr = mcs.paint_box.image.getPixel hit_pos.x hit_pos.y 
		
		--search and collect positions for identical colors (every 10 pixels ,because of canvas resolution 240 --> 24)
		local old_hits = #()
		local positive_hits = #(hit_pos)
		local negative_hits = #()
		fn notExcluded data pos = --if next pixel is not in: old_hits, positive_hits, negative_hits
		(
			if findItem data pos != 0 then return false else return true
		)
		fn drawPixel canvas pos clr brush_size = --draw pixel 10*10 in pos
		(
			local g = (dotnetclass "Drawing.Graphics").FromImage canvas.image
			local brush = dotNetObject "drawing.SolidBrush" clr --net_color
			local rect = netDrRect [pos.x-brush_size/2, pos.y-brush_size/2] [brush_size, brush_size] 
			g.FillRectangle brush rect 
			g.dispose()
		)
		--draw first pixel
		drawPixel mcs.paint_box hit_pos clr brush_size
		--if still remain space to search and operation is not brealed with escape
		while positive_hits.count != 0  and not keyboard.escPressed  do 
		(
			local current_pos = positive_hits[1] --first item from array
			local next_pixel
			
			local p1=[current_pos.x                , current_pos.y-brush_size]-- up	
			local p2=[current_pos.x+brush_size, current_pos.y-brush_size]--right up
			local p3=[current_pos.x+brush_size, current_pos.y]--right
			local p4=[current_pos.x+brush_size, current_pos.y+brush_size]--right down
			local p5=[current_pos.x                , current_pos.y+brush_size]--down
			local p6=[current_pos.x-brush_size , current_pos.y+brush_size]--left down
			local p7=[current_pos.x-brush_size , current_pos.y]--left
			local p8=[current_pos.x-brush_size , current_pos.y-brush_size]--left up
			
			--test if next pixel not out of bounds and is not excluded (search in 8 way)
				-- up		
				if current_pos.y-brush_size > 0 and notExcluded (old_hits+positive_hits+negative_hits) p1
						then 
						(
							--format "p1:%\n" p1
							next_pixel = mcs.paint_box.image.getPixel p1.x p1.y
							if next_pixel == hit_clr then  --if color is same as picked color
							(
								positive_hits += #(p1)
								drawPixel mcs.paint_box p1 clr brush_size
							)
							else negative_hits += #(p1)
						)
				--right up
				if current_pos.x+brush_size < w and current_pos.y-brush_size > 0 and notExcluded (old_hits+positive_hits+negative_hits) p2
						then 
						(
							--format "p2:%\n" p2
							next_pixel = mcs.paint_box.image.getPixel p2.x p2.y
							if next_pixel == hit_clr then  --if color is same as picked color
							(
								positive_hits += #(p2)
								drawPixel mcs.paint_box p2 clr brush_size
							)
							else negative_hits += #(p2)
						)
				--right
				if current_pos.x+brush_size < w and notExcluded (old_hits+positive_hits+negative_hits) p3 
						then 
						(
							--format "p3:%\n" p3
							next_pixel = mcs.paint_box.image.getPixel p3.x p3.y
							if next_pixel == hit_clr then  --if color is same as picked color
							(
								positive_hits += #(p3)
								drawPixel mcs.paint_box p3 clr brush_size
							)
							else negative_hits += #(p3)
						)
				--right down
				if current_pos.x+brush_size < w and current_pos.y+brush_size < h and notExcluded (old_hits+positive_hits+negative_hits) p4
						then 
						(
							--format "p4:%\n" p4
							next_pixel = mcs.paint_box.image.getPixel p4.x p4.y
							if next_pixel == hit_clr then  --if color is same as picked color
							(
								positive_hits += #(p4)
								drawPixel mcs.paint_box p4 clr brush_size
							)
							else negative_hits += #(p4)
						)
				--down
				if current_pos.y+brush_size < h and notExcluded (old_hits+positive_hits+negative_hits) p5  
						then 
						(
							--format "p5:%\n" p5
							next_pixel = mcs.paint_box.image.getPixel p5.x p5.y
							if next_pixel == hit_clr then  --if color is same as picked color
							(
								positive_hits += #(p5)
								drawPixel mcs.paint_box p5 clr brush_size
							)
							else negative_hits += #(p5)
						)
				--left down
				if current_pos.x-brush_size > 0 and current_pos.y+brush_size < h and notExcluded (old_hits+positive_hits+negative_hits) p6
						then 
						(
							--format "p6:%\n" p6
							next_pixel = mcs.paint_box.image.getPixel p6.x p6.y
							if next_pixel == hit_clr then  --if color is same as picked color
							(
								positive_hits += #(p6)
								drawPixel mcs.paint_box p6 clr brush_size
							)
							else negative_hits += #(p6)
						)
				--left
				if current_pos.x-brush_size > 0 and notExcluded (old_hits+positive_hits+negative_hits) p7
						then 
						(
							--format "p7:%\n" p7
							next_pixel = mcs.paint_box.image.getPixel p7.x p7.y
							if next_pixel == hit_clr then  --if color is same as picked color
							(
								positive_hits += #(p7)
								drawPixel mcs.paint_box p7 clr brush_size
							)
							else negative_hits += #(p7)
						)
				--left up
				if current_pos.x-brush_size > 0 and current_pos.y-brush_size > 0 and notExcluded (old_hits+positive_hits+negative_hits) p8
						then 
						(
							--format "p8:%\n" p8
							next_pixel = mcs.paint_box.image.getPixel p8.x p8.y
							if next_pixel == hit_clr then  --if color is same as picked color
							(
								positive_hits += #(p8)
								drawPixel mcs.paint_box p8 clr brush_size
							)
							else negative_hits += #(p8)
						)
				
			---remove current hit from active database (positive_hits)
			deleteItem positive_hits 1
			old_hits += #(current_pos)
			
			--format "positive_hits:%\n" positive_hits
		)
		--make transparent
		if clr == netDrColor black do mcs.paint_box.image.MakeTransparent clr--the black color is transparent
		--update diffuse icon
		mcs.btn_showImage.image  = resizeImage2 mcs.paint_box.image 24 24
		--update alpha icon
		mcs.btn_showAlpha.image   = getAlpha mcs.btn_showImage.image
		--refresh all
		mcs.btn_showImage.refresh()
		mcs.btn_showAlpha.refresh()
		mcs.paint_box.refresh()
	)
	fn addIconToLibrary s a = 
	(
		local form = s.parent, mcs = form.tag.value		
		local icd = mcs.btn_showImage.image
		local ica = mcs.btn_showAlpha.image
		--draw icon back to library
		local w =tempImgLib_D.width
		local h =tempImgLib_D.height
		local pos = ((getIconPosBy activeIconNum)*24)-24
		local black_icon = createNewImage 24 24 black
		local white_icon = createNewImage 24 24 white
		--diffuse
		local g = (dotNetClass "Drawing.Graphics").fromImage tempImgLib_D --Create new Graphics object from image library
		g.DrawImage black_icon pos.x pos.y 24 24
		g.DrawImage icd pos.x pos.y 24 24
		g.dispose()
		mcs.icon_box.image = tempImgLib_D
		--alpha
		local g = (dotNetClass "Drawing.Graphics").fromImage tempImgLib_A --Create new Graphics object from image library
		g.DrawImage black_icon pos.x pos.y 24 24
		g.DrawImage ica pos.x pos.y 24 24
		g.dispose()
	)
	fn delIconFromLibrary s a = ()
	fn editIcon s a =
	(
		local form = s.parent, mcs = form.tag.value
		--add diffuse and alpha in to buttons
		mcs.btn_showImage.image = getIcon tempImgLib_D activeIconNum transparent:true
		mcs.btn_showAlpha.image = getIcon tempImgLib_A activeIconNum 
		--add resized icon in to paint box
		mcs.paint_box.image =  resizeImage2 mcs.btn_showImage.image 240 240
	)
	fn maxImageToDotnet img =
	(
		/*
		local w = h = img.width
		local new_img = (dotNetObject "Drawing.Bitmap" w h) --Create new bitmap object
		for x = 0 to w-1 do
		(
			for y = 0 to h-1 do
			(
				local clr = netDrColor (getPixels img [x,y] 1)[1]
				new_img.SetPixel x y clr
			)
		)
		return new_img
		*/
		setclipboardBitmap img
		local clipboardClass = dotNetClass "System.Windows.Forms.Clipboard" --create a Clipboard dotNetClass
		local net_img = clipboardClass.getImage()
		net_img.MakeTransparent (netDrColor backgroundColor) --backgroundColor = render bg color
		return net_img 
	)
	fn renderToCanvas s a =
	(
		print "ren"
		local form = s.parent, mcs = form.tag.value
		local wasCancelled = false
		local w = h = mcs.paint_box.image.width
		local img = 
		(
			local render_type = if keyboard.controlPressed then #selection else #normal
			render outputsize:[24,24] antiAliasing:true enablePixelSampler:false shadows:true \
			quiet:true renderType:render_type vfb:off cancelled:&wasCancelled
		)
		if (not wasCancelled) do 
		(
			
			local net_img = maxImageToDotnet img
			--add diffuse and alpha in to buttons
			mcs.btn_showImage.image = net_img
			mcs.btn_showAlpha.image = getAlpha net_img
			--add resized icon in to paint box
			net_img = resizeImage2 net_img 240 240
			mcs.paint_box.image = net_img
		)
	)
	--fn iconBoxMouseDown s a = (s.cursor = cursor_grab)
	fn markIcon s a zero:false = --s==PictureBox, a==MouseEventArgs
	(
		--s.cursor = cursor_arrow
		local form = s.parent, mcs = form.tag.value
		--get picked icon pos
		local pos = if not zero then [a.location.x, a.location.y] else [0, 0]
		local corner = getIconCornerFrom pos
		--hilight icon
		s.image = tempImgLib_D
		local img = copy tempImgLib_D
		local g = (s.createGraphics()).FromImage img 
		--local g = (dotnetclass "Drawing.Graphics").FromImage img  -- a.image == icon_box.image
		local pen = dotnetobject  "Drawing.Pen" (netDrColor yellow) 2
		local rect = dotnetObject "Drawing.rectangle" corner.x corner.y  24  24
		g.DrawRectangle pen rect
		g.dispose()
		s.image = img
		--manipulate
		if keyboard.shiftPressed do addIconToLibrary()
		if keyboard.altPressed do delIconFromLibrary()
		--get icon from library
		activeIconNum = getIconNumBy pos
		mcs.lblT.Text = "Icon Maker: "+activeIconNum as string+"/400"
	)
	fn getPixelFromCanvas x y img = (return (img.getPixel (x-5) (y+5))) -- set pipe icon offset to left bottom
	fn canvasMouseDown s a = 
	(
		local form = s.parent, mcs = form.tag.value
		local mouse_btn = a.Button.ToString()
		local clr
		drawMode = true
		if keyboard.altPressed 
		then --pick color
		(
			clr = getPixelFromCanvas a.x a.y s.image
			--if color is transparent make it black
			if clr == (dotnetClass "Drawing.Color").FromArgb 0 0 0 0 do clr = netDrColor black 
			case mouse_btn of --LMB, RMB
			(
				"Left": mcs.btn_cpfront.backColor = clr
				"Right":mcs.btn_cpback.backColor = clr
			)
		)
		else --paint
		(
			--get color
			case mouse_btn of --LMB, RMB
			(
				"Left": clr = mcs.btn_cpfront.backColor
				"Right":clr = mcs.btn_cpback.backColor
			)
			--get brush type
			case active_tool of
			(
				"Brush":(drawPoint s a clr)
				"Line":(print 2)
				"Fill":(fillCanvas s a clr)
				"Cross":(print 4)
			)
		)
	)
	fn cursorIsOnCanvas s a = 
	( 
		local form = s.parent, mcs = form.tag.value
		local msp=mouse.screenPos
		local mso = [8,-8] --mouse screen offset
		local mp = msp - [form.location.x, form.location.y] - mso - [s.Location.x, s.Location.y]
		mp.x <= s.width and mp.x > -1 and mp.y <= s.height and mp.y > -1
	) 
	--fn drawToForm s a = ()--(cursor.Current = cursor_arrow)
	fn canvasMouseUp s a = (drawMode = false)
	fn canvasKeyDown s a =(if a.Alt and cursorIsOnCanvas s a then cursor.Current = cursor_pipe else cursor.Current = cursor_cross)
	fn canvasKeyUp s a =(if cursorIsOnCanvas s a do cursor.Current = cursor_cross)
	fn DrawToCanvas s a move:true =
	(
		s.focus()
		local form = s.parent, mcs = form.tag.value
		local mouse_btn = a.Button.ToString()
		local x = a.x
		local y = a.y	
		--mouse icons
		if cursorIsOnCanvas s a 
		then
		(
			if keyboard.altPressed
			then cursor.Current = cursor_pipe
			--else if ckb_brush_f.checked then cursor.Current = cursor_fill
			else cursor.Current = cursor_cross
		)
		--else cursor.Current = cursor_arrow
		
		
		if not keyboard.altPressed and drawMode and x < s.image.width and x > 0 and y < s.image.height and y > 0 then
		(
			--format "location240:%\n" [x, y]
			case mouse_btn of --LMB, RMB, MB
			(
				"Left": 
				(
					--get brush type
					case active_tool of
					(
						"Brush":(drawPoint s a mcs.btn_cpfront.backColor)
						"Line":(print 2)
						"Fill":(fillCanvas s a mcs.btn_cpfront.backColor)
						"Cross":(print 4)
					)
				)
				"Right": 
				(
					--get brush type
					case active_tool of
					(
						"Brush":(drawPoint s a mcs.btn_cpback.backColor)
						"Line":(print 2)
						"Fill":(fillCanvas s a mcs.btn_cpback.backColor)
						"Cross":(print 4)
					)
				)
				"Middle":--undo
				( 

				)
				"XButton1":()
				"XButton2":()
			)
		)
		
		/*

		--format "mousePos:%\n" [x,y]
		
		if isDrawingEnabled then
		(
			local undo_img = bitmap 24 24 color:black

			
			if clr == undefined do return false
			
			case pen_draw_style of
			(
				#standart : 
				(
					case tempButtonSwitch of
					(
						#dif:
						(
							
							if optimizePosCheck x y 0.2 do return false
							
							local g = (dotnetclass "Drawing.Graphics").FromImage paint_box.image
							g.InterpolationMode = (dotnetClass "Drawing.Drawing2D.InterpolationMode").NearestNeighbor
							g.SmoothingMode = (dotnetClass "Drawing.Drawing2D.SmoothingMode").none
							
							local new_pos = roundPos x y
							local rect = dotnetObject "Drawing.rectangle" (new_pos.x) (new_pos.y) 10 10
							local brush = dotnetobject "Drawing.SolidBrush" (netDrColor yellow)
							--mcsystem.show brush
							g.FillRectangle brush rect
							paint_box.image = paint_box.image
							
							--g.DrawImage new_img rect 0 0 24 24 (dotNetClass "Drawing.GraphicsUnit").Pixel
							

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
		*/
	)
	--
	fn onOpenForm s a = (loadIconLibrary s.tag.value.btn_reload a ; markIcon s.tag.value.icon_box a zero:true)
	fn onCloseForm s a = (mcFile.saveIniDialog s "Properties_2" s.name)
	
	fn inicializeInterface form mcs =
	(
		form.name = "mcIconMakerDialog"
		form.ControlBox  = false --hide main bar
		local fpos = (mcCall.getIniDataFromArray mcTempProfileIni "Properties_2" "mcIconMakerDialog" 2)
		if fpos == undefined do fpos = (mcCall.getIniDataFromArray mcDefaultProfileIni "Properties_2" "mcIconMakerDialog" 2)
		form.StartPosition = form.StartPosition.Manual
		form.bounds = netDrRect fpos form_size
		form.FormBorderStyle = form.FormBorderStyle.none
		form.BackColor = netDrColor clr_fore
		form.ShowInTaskbar = false
		form.opacity = form_opacity
		--form.cursor = cursor_arrow
		
		mcs.lblT.bounds = netDrRect [form_offset, form_offset] [form_size.x - form_offset*10 , bar_height]
		mcs.lblT.BackColor = netDrColor clr_back
		mcs.lblT.ForeColor = netDrColor clr_text
		mcs.lblT.Text = "Icon Maker: 1/400"
		
		mcs.icon_box.bounds = netDrRect [240+form_offset*4,  form_offset*2 + bar_height ] [480, 480]
		mcs.icon_box.BackColor = netDrColor black

		mcs.paint_box.bounds = netDrRect [form_offset, form_offset*2 + bar_height ] [244, 244]
		mcs.paint_box.image = createNewImage 240 240 transparent_color transparent:true
		mcs.paint_box.BorderStyle = mcs.paint_box.BorderStyle.Fixed3D
		mcs.paint_box.SizeMode = (dotNetClass "PictureBoxSizeMode").StretchImage
		
		mcs.btn_render.bounds = netDrRect [2,264] [52, 56]
		mcs.btn_copy.bounds = netDrRect [142,264] [52, 26]
		mcs.btn_paste.bounds = netDrRect [142,292] [52, 26]
		mcs.btn_clear.bounds = netDrRect [142+53,292] [52, 26]
		mcs.btn_swap_picker.bounds = netDrRect [2,350] [52, 26]
		mcs.btn_reset_picker.bounds = netDrRect [2,377] [52, 26]
		mcs.btn_add.bounds = netDrRect [142+80,264] [26, 26]
		mcs.btn_load.bounds = netDrRect [142+53,264] [26, 26] 
		mcs.btn_save.bounds = netDrRect  [142,320] [52, 26]
		mcs.btn_reload.bounds = netDrRect  [142+53,320] [52, 26]
		
		mcs.btn_brush.bounds = netDrRect  [8,420] [52, 26]
		mcs.btn_line.bounds = netDrRect  [68,420] [52, 26]
		mcs.btn_fill.bounds = netDrRect  [128,420] [52, 26]
		mcs.btn_cross.bounds = netDrRect  [188,420] [52, 26]
		mcs.btn_brush.text =  "Brush"
		mcs.btn_line.text = "Line"
		mcs.btn_fill.text = "Fill"
		mcs.btn_cross.text = "Cross"
		mcs.btn_brush.Checked = true

		mcs.btn_showImage.bounds = netDrRect [55,264] [26, 26]
		mcs.btn_showImage.flatstyle = mcs.btn_showImage.flatstyle.flat
		mcs.btn_showImage.FlatAppearance.BorderSize = 0
		mcs.btn_showImage.image = createNewImage 24 24 transparent_color transparent:true
		
		mcs.btn_showAlpha.bounds = netDrRect [55,292] [26, 26]
		mcs.btn_showAlpha.flatstyle = mcs.btn_showAlpha.flatstyle.flat
		mcs.btn_showAlpha.FlatAppearance.BorderSize = 0
		mcs.btn_showAlpha.image = createNewImage 24 24 white
		
		mcs.btn_cpfront.bounds = netDrRect [2,323] [26, 26]
		mcs.btn_cpfront.BackColor = netDrColor white
		mcs.btn_cpback.bounds = netDrRect [28,323] [26, 26]
		mcs.btn_cpback.BackColor = netDrColor black
		
		mcs.btn_render.text=  "Render"
		mcs.btn_clear.text = "Clear"
		mcs.btn_copy.text= "Copy"
		mcs.btn_paste.text = "Paste"
		mcs.btn_swap_picker.text = "Swap"
		mcs.btn_reset_picker.text = "Reset"
		mcs.btn_add.text = ">>"
		mcs.btn_load.text = "<<"
		mcs.btn_save.text = "Save"
		mcs.btn_reload.text = "Reload"
		
		mcs.ToolTip.IsBalloon = true
		mcs.ToolTip.BackColor = netDrColor clr_back
		mcs.ToolTip.ForeColor = netDrColor clr_text
		mcs.ToolTip.AutoPopDelay = 5000
		mcs.ToolTip.InitialDelay = 400
		mcs.ToolTip.ReshowDelay = 100
		mcs.ToolTip.ShowAlways = true
		--mcs.ToolTip.UseAnimation = true
		--mcs.ToolTip.UseFading = true

		--add handlers
		dotnet.addEventHandler form "Shown" onOpenForm
		dotnet.addEventHandler form "Closed" onCloseForm
		dotnet.addEventHandler form "VisibleChanged" onCloseForm
		dotNet.addEventHandler form  "MouseUp"   getFormPos
		--dotNet.addEventHandler form  "MouseMove" drawToForm
		dotNet.addEventHandler mcs.lblT   "MouseMove" onLblTMouseMove
		dotNet.addEventHandler mcs.lblT   "MouseDown" onLblTMouseDown 
		dotNet.addEventHandler mcs.lblT   "MouseUp"   onLblTMouseUp
		dotNet.addEventHandler mcs.icon_box   "MouseUp"  markIcon
		--dotNet.addEventHandler mcs.icon_box   "MouseDown"  iconBoxMouseDown
		dotNet.addEventHandler mcs.icon_box   "MouseDoubleClick"  editIcon
		dotNet.addEventHandler mcs.btn_copy   "MouseUp"  copyIcon
		dotNet.addEventHandler mcs.btn_paste   "MouseUp"  pasteIcon
		dotNet.addEventHandler mcs.btn_clear  "MouseUp"  clearIcons
		dotNet.addEventHandler mcs.btn_showImage  "MouseUp"  showDiffuse
		dotNet.addEventHandler mcs.btn_showAlpha  "MouseUp"  showAlpha
		dotNet.addEventHandler mcs.paint_box   "MouseDown" canvasMouseDown 
		dotNet.addEventHandler mcs.paint_box   "MouseUp" canvasMouseUp
		dotNet.addEventHandler mcs.paint_box   "MouseMove" drawToCanvas
		dotNet.addEventHandler mcs.paint_box   "KeyDown" canvasKeyDown
		dotNet.addEventHandler mcs.paint_box   "KeyUp" canvasKeyUp 
		dotNet.addEventHandler mcs.btn_swap_picker  "MouseUp" swapPickerColors
		dotNet.addEventHandler mcs.btn_reset_picker   "MouseUp" resetPickerColors
		dotNet.addEventHandler mcs.btn_save   "MouseUp" saveIconLibrary
		dotNet.addEventHandler mcs.btn_reload   "MouseUp" loadIconLibrary
		dotNet.addEventHandler mcs.btn_load  "MouseUp" editIcon
		dotNet.addEventHandler mcs.btn_add  "MouseUp" addIconToLibrary
		dotNet.addEventHandler mcs.btn_render  "MouseUp" renderToCanvas
		dotNet.addEventHandler mcs.btn_cpfront "MouseEnter" showColorTooltip
		dotNet.addEventHandler mcs.btn_cpback "MouseEnter" showColorTooltip
		dotNet.addEventHandler mcs.btn_cpfront "MouseUp" pickColor
		dotNet.addEventHandler mcs.btn_cpback "MouseUp" pickColor
		dotNet.addEventHandler mcs.btn_brush "MouseUp" rbCheck
		dotNet.addEventHandler mcs.btn_line "MouseUp" rbCheck
		dotNet.addEventHandler mcs.btn_fill "MouseUp" rbCheck
		dotNet.addEventHandler mcs.btn_cross "MouseUp" rbCheck

		--add controls
		form.controls.addRange \
		( 
			#(
				mcs.lblT, mcs.icon_box, mcs.paint_box, mcs.btn_render, mcs.btn_clear, 
				mcs.btn_copy, mcs.btn_paste, mcs.btn_showImage, mcs.btn_showAlpha,
				mcs.btn_cpfront, mcs.btn_cpback, mcs.btn_swap_picker, mcs.btn_reset_picker,
				mcs.btn_add, mcs.btn_load, mcs.btn_save, mcs.btn_reload, mcs.btn_brush, mcs.btn_line, 
				mcs.btn_fill, mcs.btn_cross
			) 
		)
	)
	inicializeInterface form form.tag.value
	mcIconMakerDialog = form
	mcIconMakerDialog.showModeless()
)
