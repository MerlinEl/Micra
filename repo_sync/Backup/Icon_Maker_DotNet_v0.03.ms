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
	local tempImgLib_D,  tempImgLib_A, activeIconNum, activeIcon_D, activeIcon_A, lastPos = [-1, -1]
	local transparent_color = color 211 211 211 --((colorMan.getColor #background)*255) as color
	local drawMode = false
	local cursor         = dotNetClass "System.Windows.Forms.cursor"
	local cursor_cross   = dotNetObject "System.Windows.Forms.Cursor" (mcImgPath+"cross.ico")
	local cursor_pipe    = dotNetObject "System.Windows.Forms.Cursor" (mcImgPath+"pipe.ico")
	local cursor_fill    = dotNetObject "System.Windows.Forms.Cursor" (mcImgPath+"fill.ico")
	local cursor_hand   = dotNetObject "System.Windows.Forms.Cursor" (mcImgPath+"harrow.ico")
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
		netDMove = false, 
		netDmPos
		--ToolTip = dotnetobject "ToolTip",
		--tab     = dotNetObject "TableLayoutPanel",
		--tab_buttons = #(),
		--interface
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
	--fn drawToForm s a = (s.focus())
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
	fn resizeImage2 img w h =  --redraw method
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
	fn LoadIconLibrary form =
	(
		local mcs = form.tag.value
		tempImgLib_D = getImageFromFile mcIconI
		tempImgLib_A = getImageFromFile mcIconM
		mcs.icon_box.image = tempImgLib_D
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
	fn getPixelFromCanvas x y img = (return (img.getPixel (x-5) (y+5))) -- set pipe icon offset to left bottom
	fn markIcon s a zero:false = --s==PictureBox, a==MouseEventArgs
	(
		local form = s.parent, mcs = form.tag.value
		--get picked icon pos
		local pos = if not zero then [a.location.x, a.location.y] else [0, 0]
		local corner = getIconCornerFrom pos
		--hilight icon
		s.image = getImageFromFile mcIconI
		--local g = a.createGraphics()
		local g = (dotnetclass "Drawing.Graphics").FromImage s.image  -- a.image == icon_box.image
		local pen = dotnetobject  "Drawing.Pen" (netDrColor yellow) 2
		local rect = dotnetObject "Drawing.rectangle" corner.x corner.y  24  24
		g.DrawRectangle pen rect
		--manipulate
		--if keyboard.shiftPressed do addIconToLibrary()
		--if keyboard.altPressed do delIconFromLibrary()
		
		--get icon from library
		activeIconNum = getIconNumBy pos
		mcs.lblT.Text = "Icon Maker: "+activeIconNum as string+"/400"
	)
	fn editIcon s a =
	(
		local form = s.parent, mcs = form.tag.value
		--get active icon from file
		activeIcon_D = getIcon tempImgLib_D activeIconNum transparent:true
		activeIcon_A = getIcon tempImgLib_A activeIconNum 
		--add resized icon in to paint box
		mcs.paint_box.image =  resizeImage2 activeIcon_D 240 240
		--add diffuse and alpha in to buttons
		mcs.btn_showImage.image = activeIcon_D
		mcs.btn_showAlpha.image = activeIcon_A
	)
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
			case mouse_btn of --LMB, RMB
			(
				"Left": clr = mcs.btn_cpfront.backColor
				"Right":clr = mcs.btn_cpback.backColor
			)
			drawPoint s a clr
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
		else cursor.Current = cursor_hand
		
		
		if not keyboard.altPressed and drawMode and x < s.image.width and x > 0 and y < s.image.height and y > 0 then
		(
			--format "location240:%\n" [x, y]
			case mouse_btn of --LMB, RMB, MB
			(
				"Left": 
				(
					--if checkGridPos  a s 0.5 do drawPoint s a clr
					drawPoint s a mcs.btn_cpfront.backColor
					--s.image.SetPixel x y (netDrColor clr)
				)
				"Right": 
				(
					drawPoint s a mcs.btn_cpback.backColor
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
	fn onOpenForm s a = (LoadIconLibrary s; markIcon s.tag.value.icon_box a zero:true)
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
		
		dotNet.addEventHandler mcs.btn_cpfront "MouseEnter" showColorTooltip
		dotNet.addEventHandler mcs.btn_cpback "MouseEnter" showColorTooltip
		--dotNet.addEventHandler mcs.btn_cpfront "MouseUp" getColorPicker
	
		--add controls
		form.controls.addRange \
		( 
			#(
				mcs.lblT, mcs.icon_box, mcs.paint_box, mcs.btn_render, mcs.btn_clear, 
				mcs.btn_copy, mcs.btn_paste, mcs.btn_showImage, mcs.btn_showAlpha,
				mcs.btn_cpfront, mcs.btn_cpback, mcs.btn_swap_picker, mcs.btn_reset_picker
			) 
		)
	)
	inicializeInterface form form.tag.value
	mcIconMakerDialog = form
	mcIconMakerDialog.showModeless()
)
