Global mcIconMakerDialog
if ::mcIconMakerDialog != undefined do try(mcIconMakerDialog.Close())catch()
(
	local mcs, dia
	struct dotNetFormStruct (

		-- Default Properties
		form = dotNetObject "MaxCustomControls.Maxform",
		lblT      = dotNetObject "label",
		btnMin  = dotNetObject "button",
		tlp        = dotNetObject "TableLayoutPanel",
		old_height, 
		minimized = false, 
		netDMove = false, 
		netDmPos,
		form_size        = [746, 516],
		bar_height      = 14,
		border_offset  = 2,
		btn_size         = 24,
		debug = 0,
		-- Custom Properties
		cursor    = dotNetClass "System.Windows.Forms.cursor",
		ToolTip   = dotNetObject "ToolTip",
		paint_box = dotNetObject "pictureBox",
		icon_box = dotNetObject "pictureBox",
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
		tempImgLib_D,  tempImgLib_A, activeIconNum, lastPos = [-1, -1], active_tool = "Brush",
		drawLineEnabled = false, drawLineAborted = false, drawLineFirstPoint, drawLineOrigImage, drawLineFirstImage,
		transparent_color = color 211 211 211,
		drawMode = false,
		-- Default Functions
		fn defNWin = (
			local nw = DotNetObject "NativeWindow"
			nw.AssignHandle (DotNetObject "System.IntPtr" (Windows.GetMaxHWND())) 
			return nw
		),
		fn close = (dia.close()),
		fn changeBackcolor = (dia.backColor = netDrColor (mcUIColors.get #fore)),
		fn minMaxForm s a = ( -- s = Button, a = MouseEventArgs
			
			mcs.minimized = not mcs.minimized
			if mcs.minimized then (
				
				mcs.btnMin.text = "+"
				mcs.old_height = dia.height 
				dia.height = mcs.bar_height + mcs.border_offset*2
			) else (
				
				mcs.btnMin.text = "-"
				dia.height = mcs.old_height
			)
		),
		--Move / Snap Dialog
		fn onLblTMouseMove s a = ( --dragForm
			if mcs.netDMove do mcDialog.snapForm dia mcs.netDmPos
		),
		fn onLblTMouseDown s a = (
				
			mcs.cursor.current = netCursors.Hand
			if a.Button == a.Button.left do ( --enable drag
				mcs.netDmPos = [dia.MousePosition.x, dia.MousePosition.y] - [dia.left, dia.top] 
				mcs.netDMove = true 
			)
		),
		fn onLblTMouseUp s a = (
			mcs.netDMove = false --disable drag
			if a.Button == a.Button.right then dia.hide()
		),
		-- Custom  Functions
		fn rbCheck s a = (mcs.active_tool = s.text),
		fn pickColor s a =
		(
			local clr = colorPickerDlg (color 100 200 300) "Chose You Color:" alpha:true pos:mouse.screenpos
			if clr != undefined do s.backColor = netDrColor clr
		),
		fn showColorTooltip s a =
		(
			mcs.toolTip.SetToolTip s (s.BackColor.toString())
		),
		fn createNewImage w h clr transparent:false =
		(
			local img = (dotNetObject "Drawing.Bitmap" w h) --Create new bitmap object
			local g  = (dotNetClass "Drawing.Graphics").fromImage img --Create new Graphics object
			local brush = dotNetObject "drawing.SolidBrush" (netDrColor clr)
			g.FillRectangle brush 0 0 w h
			g.dispose()
			if transparent do img.makeTransparent()
			img
		),
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
		),
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
		),
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
		),
		fn getIcon img icnNum transparent:false =
		(
			if icnNum == 0 do return mcs.createNewImage 24 24 black
			--local img = (dotNetClass "Drawing.Image").FromFile Micra.IconI --get the saved image from file as bitmap
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
		),
		fn setImageToClipboard img =
		(
			local clipboardClass = dotNetClass "Clipboard" --create a Clipboard dotNetClass
			--img.makeTransparent (netDrColor white) 
			clipboardClass.setImage img --copy the image to clipboard
		),
		fn getImageFromClipboard =
		(
			local cd = (dotNetClass "Clipboard").GetDataObject()
			if cd.GetDataPresent (dotNetClass "DataFormats").Bitmap 
			then return cd.GetData (dotNetClass "DataFormats").Bitmap
			else return mcs.createNewImage 24 24 mcs.transparent_color -- big image
		),
		fn getAlpha img =
		(
			local w = h = img.width
			local new_img = (dotNetObject "Drawing.Bitmap" w h) --Create new bitmap object
			local g  = (dotNetClass "Drawing.Graphics").fromImage new_img --Create new Graphics object
			local brush = dotNetObject "drawing.SolidBrush" (netDrColor white)
			local rect = netDrRect [0, 0] [w, h] 
			g.FillRectangle brush rect 
			g.dispose()
			local clr =  (dotNetClass "Drawing.Color").FromArgb 0 0 0 0--netDrColor mcs.transparent_color
			for x = 0 to w-1 do
			(
				for y = 0 to h-1 do
				(
					local p = img.getPixel x y
					if p != clr do new_img.SetPixel x y (netDrColor black)
				)
			)
			return new_img
		),
		fn showDiffuse s a = 
		(
			mcs.paint_box.image = mcs.resizeImage2 mcs.btn_showImage.image 240 240
		),
		fn showAlpha s a =
		(
			mcs.paint_box.image = mcs.resizeImage2 mcs.btn_showAlpha.image 240 240
		),
		fn copyIcon s a =
		(
			mcs.setImageToClipboard mcs.btn_showImage.image  --copy paint_box icon
		),
		fn pasteIcon s a =
		(
			local img = mcs.getImageFromClipboard()
			img.MakeTransparent (netDrColor mcs.transparent_color)  --186 --211
			mcs.paint_box.image = mcs.resizeImage2 img 240 240
			mcs.btn_showImage.image = img
			mcs.btn_showAlpha.image = mcs.getAlpha mcs.btn_showImage.image
		),
		fn clearIcons s a =
		(
			mcs.paint_box.image = mcs.createNewImage 240 240 mcs.transparent_color transparent:true
			mcs.btn_showImage.image = mcs.createNewImage 24 24 mcs.transparent_color transparent:true
			mcs.btn_showAlpha.image = mcs.createNewImage 24 24 white
		),
		fn getIconCorner pos =
		(
			local rect = pos/24	
			local c = [(floor rect.x)*24,(floor rect.y)*24]
			return c
		),
		fn getIconNumber pos =
		(
			local pos = pos/24
			local pos = [ceil pos.x , floor pos.y]
			pos = (pos.x + (pos.y *20)) as integer
			if pos == 0 do pos = 1
			return pos
		),
		fn getIconPos num =
		(
			local y = (ceil (num/20 as float)) as integer
			local x = (num - (y-1)*20) as integer
			--format "icon number:%\tpos:%\n" num [x, y]
			return ([x, y]*24)-24
		),
		fn delIconFromLibrary s a = 
		(	
			local icd = mcs.btn_showImage.image
			local ica = mcs.btn_showAlpha.image
			--draw icon blank
			local w =mcs.tempImgLib_D.width
			local h =mcs.tempImgLib_D.height
			local pos = mcs.getIconPos mcs.activeIconNum
			local black_icon = mcs.createNewImage 24 24 black
			local white_icon = mcs.createNewImage 24 24 white
			--diffuse
			local g = (dotNetClass "Drawing.Graphics").fromImage mcs.tempImgLib_D --Create new Graphics object from image library
			g.DrawImage black_icon pos.x pos.y 24 24
			g.dispose()
			mcs.icon_box.image = mcs.tempImgLib_D
			--alpha
			local g = (dotNetClass "Drawing.Graphics").fromImage mcs.tempImgLib_A --Create new Graphics object from image library
			g.DrawImage black_icon pos.x pos.y 24 24
			g.dispose()
		),
		fn addIconToLibrary s a = 
		(	
			local icd = mcs.btn_showImage.image
			local ica = mcs.btn_showAlpha.image
			--draw icon back to library
			local w =mcs.tempImgLib_D.width
			local h =mcs.tempImgLib_D.height
			local pos = mcs.getIconPos mcs.activeIconNum
			local black_icon = mcs.createNewImage 24 24 black
			local white_icon = mcs.createNewImage 24 24 white
			--diffuse
			local g = (dotNetClass "Drawing.Graphics").fromImage mcs.tempImgLib_D --Create new Graphics object from image library
			g.DrawImage black_icon pos.x pos.y 24 24
			g.DrawImage icd pos.x pos.y 24 24
			g.dispose()
			mcs.icon_box.image = mcs.tempImgLib_D
			--alpha
			local g = (dotNetClass "Drawing.Graphics").fromImage mcs.tempImgLib_A --Create new Graphics object from image library
			g.DrawImage black_icon pos.x pos.y 24 24
			g.DrawImage ica pos.x pos.y 24 24
			g.dispose()
		),
		--fn iconBoxMouseDown s a = (s.cursor = mcCursor.get #grab)
		fn markIcon s a num:unsupplied = --s==PictureBox, a==MouseEventArgs
		(
			--s.cursor = mcCursor.get #arrow
			--get picked icon pos
			local pos = if num == unsupplied then [a.location.x, a.location.y] else if num == 0 then [0, 0] else mcs.getIconPos num
			local corner = mcs.getIconCorner pos
			--hilight icon
			s.image = mcs.tempImgLib_D
			local img = copy mcs.tempImgLib_D
			local g = (s.createGraphics()).FromImage img 
			local pen = dotnetobject  "Drawing.Pen" (netDrColor yellow) 2
			local rect = dotnetObject "Drawing.rectangle" corner.x corner.y  24  24
			g.DrawRectangle pen rect
			g.dispose()
			s.image = img
			--manipulate
			if keyboard.shiftPressed do mcs.addIconToLibrary s a
			if keyboard.altPressed do mcs.delIconFromLibrary s a
			--get icon from library
			mcs.activeIconNum = if num !=  unsupplied then num else mcs.getIconNumber pos
			--format "num:%\tactiveIconNum:%\n" num mcs.activeIconNum	
			mcs.lblT.Text = "Icon Maker: "+mcs.activeIconNum as string+"/400"
			--send event with icon number
			mcEvents.dispatchEvent "ICON_INDEX_PICKED" data:mcs.activeIconNum
		),
		fn loadIconLibrary s a marked:0 =
		(
--local form = if (s.getType()).name == "MaxForm" then s else dia
--local mcs = form.tag.value
			mcs.tempImgLib_D = mcs.getImageFromFile Micra.IconI
			mcs.tempImgLib_A = mcs.getImageFromFile Micra.IconM
			mcs.icon_box.image = mcs.tempImgLib_D
			mcs.markIcon mcs.icon_box a num:marked
		),
		fn saveIconLibrary s a =
		(
			if not queryBox "You are sure to save changes?" title:" Micra III?" do return false		
			local img_format  = dotNetClass "System.Drawing.Imaging.ImageFormat" -- file formats
			mcs.tempImgLib_D.save Micra.IconI img_format.bmp
			mcs.tempImgLib_A.save Micra.IconM img_format.bmp
			--mcs.tempImgLib_D.Dispose()
			--mcs.tempImgLib_A.Dispose()
		),
		fn swapPickerColors s a =
		(
			local clr = mcs.btn_cpfront.BackColor
			mcs.btn_cpfront.BackColor = mcs.btn_cpback.BackColor 
			mcs.btn_cpback.BackColor = clr
		),
		fn resetPickerColors s a = 
		(
			mcs.btn_cpfront.BackColor = netDrColor black
			mcs.btn_cpback.BackColor = netDrColor white
		),
		fn getFormPos s a = (format "pos:%\n" [a.x, a.y] ), --get position in form , for interface adjusting
		fn checkGridPos a s tolerance =
		(
			local step = 10
			local x = a.x
			local y = a.y
			local x=x/step as float - x/step
			local y=y/step as float - y/step
			if x < tolerance or y < tolerance then return true else return false
		),
		fn roundPos x y = --draw in canvas 240x240 every 24 24 pixel
		(
			local step = 10
			local new_x =( (x /step)*10) - step/2
			local new_y =( (y /step)*10) - step/2
			--format "location24:%\n" [new_x+10, new_y+10]
			return [new_x+10, new_y+10]
		),
		fn translatePos pos = --calculate pos from 240x240 to 24x24
		(
			local step = 10
			local new_x =(pos.x /step)
			local new_y =(pos.y /step)
			return [new_x, new_y]-0.5
		),
		fn drawPoint s a clr ghostimage:unsupplied =
		(
			local brush_size = 10
			--draw to canvas
			local pos = mcs.roundPos a.x a.y 
			if lastPos == pos do return false
			--format "location240:%\n" pos
			lastPos = pos	
			local x = pos.x
			local y = pos.y
			local g
			if ghostimage == unsupplied 
			then g = (dotnetclass "Drawing.Graphics").FromImage s.image
			else g = (dotnetclass "Drawing.Graphics").FromImage ghostimage
			--turn black color to transparent color
			--local net_color = if clr == netDrColor black then netDrColor mcs.transparent_color else clr
			local brush = dotNetObject "drawing.SolidBrush" clr --net_color
			--print (brush.color.toString())
			local rect = netDrRect [x-brush_size/2, y-brush_size/2] [brush_size, brush_size] 
			g.FillRectangle brush rect 
			g.dispose()
			--make transparent
			if clr == netDrColor black do s.image.MakeTransparent clr--the black color is transparent
			if ghostimage == unsupplied do
			(
				--update diffuse icon
				local icon_pos = mcs.translatePos pos
				mcs.btn_showImage.image.SetPixel icon_pos.x icon_pos.y clr
				--make transparent
				if clr == netDrColor black do mcs.btn_showImage.image.MakeTransparent clr
				--format "location24:%\n" icon_pos
				--update alpha icon
				clr = if (clr == netDrColor black or clr == netDrColor mcs.transparent_color) then netDrColor white else netDrColor black
				mcs.btn_showAlpha.image.SetPixel icon_pos.x icon_pos.y clr
				--update canvas
			)
			s.refresh()
			mcs.btn_showImage.refresh()
			mcs.btn_showAlpha.refresh()
		),
		fn drawCross s a clr =
		(
			local brush_size = 10
			--draw to canvas
			local pos = mcs.roundPos a.x a.y 
			if mcs.lastPos == pos do return false
			--format "location240:%\n" pos
			mcs.lastPos = pos	
			local x = pos.x
			local y = pos.y
			local g = (dotnetclass "Drawing.Graphics").FromImage s.image
			--turn black color to transparent color
			--local net_color = if clr == netDrColor black then netDrColor mcs.transparent_color else clr
			local brush = dotNetObject "drawing.SolidBrush" clr --net_color
			--print (brush.color.toString())
			local rect = netDrRect [x-(brush_size/2)*3, y-brush_size/2] [brush_size*3, brush_size] 
			g.FillRectangle brush rect 
			local rect = netDrRect [x-brush_size/2, y-(brush_size/2)*3] [brush_size, brush_size*3] 
			g.FillRectangle brush rect 
			g.dispose()
			--make transparent
			if clr == netDrColor black do s.image.MakeTransparent clr--the black color is transparent
			--update diffuse icon
			local icon_pos = mcs.translatePos pos
			mcs.btn_showImage.image.SetPixel icon_pos.x icon_pos.y clr
			--make transparent
			if clr == netDrColor black do mcs.btn_showImage.image.MakeTransparent clr
			--format "location24:%\n" icon_pos
			--update alpha icon
			clr = if (clr == netDrColor black or clr == netDrColor mcs.transparent_color) then netDrColor white else netDrColor black
			mcs.btn_showAlpha.image.SetPixel icon_pos.x icon_pos.y clr
			--update canvas
			s.refresh()
			mcs.btn_showImage.refresh()
			mcs.btn_showAlpha.refresh()
		),
		fn drawLine s a =
		(			
			local brush_size = 10
			local clr = mcs.btn_cpfront.backColor
		
			if mcs.drawLineEnabled then
			(		
				if mcs.drawLineFirstPoint == undefined 
				then --define first point
				(
					mcs.drawLineOrigImage = copy s.image
					mcs.drawLineFirstPoint = [a.x, a.y]
					mcs.drawPoint s a clr
					mcs.drawLineFirstImage = copy s.image
				)
				else --define second point
				(
					s.image = copy mcs.drawLineFirstImage
					mcs.drawPoint s a clr ghostimage:s.image
					--s.refresh()
				)
			)
			else if mcs.drawLineFirstPoint != undefined do --draw line
			(
				local p1 = mcs.roundPos mcs.drawLineFirstPoint.x mcs.drawLineFirstPoint.y
				local p2 = mcs.roundPos a.x a.y 
				
				---replace with optimized version WIP
				
				local g = (dotnetclass "Drawing.Graphics").FromImage s.image
				local pen = dotnetobject  "Drawing.Pen" clr brush_size
				g.DrawLine pen (p1.x-brush_size/2) (p1.y-brush_size/2) (p2.x) (p2.y)--points 
				g.dispose()
				s.refresh()
				mcs.drawLineFirstPoint = undefined
				mcs.drawLineOrigImage = copy s.image
			)
		),
		fn fillCanvas s a clr = --using star search technique CW (starting from top), thats mean : we have 8 ways to search around each one pixel
		(
			local brush_size = 10
			local w= h = 240
			--get location
			local hit_pos = mcs.roundPos a.x a.y  --each pixel is 10x10, and hit is the center
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
			mcs.btn_showImage.image  = mcs.resizeImage2 mcs.paint_box.image 24 24
			--update alpha icon
			mcs.btn_showAlpha.image   = mcs.getAlpha mcs.btn_showImage.image
			--refresh all
			mcs.btn_showImage.refresh()
			mcs.btn_showAlpha.refresh()
			mcs.paint_box.refresh()
		),
		fn editIcon s a =
		(
--local form = if (s.getType()).name == "MaxForm" then s else s.parent
--local mcs = form.tag.value
			--add diffuse and alpha in to buttons
			mcs.btn_showImage.image = mcs.getIcon mcs.tempImgLib_D mcs.activeIconNum transparent:true
			mcs.btn_showAlpha.image = mcs.getIcon mcs.tempImgLib_A mcs.activeIconNum 
			--add resized icon in to paint box
			mcs.paint_box.image =  mcs.resizeImage2 mcs.btn_showImage.image 240 240
		),
		fn maxImageToDotnet img =
		(
			setclipboardBitmap img
			local clipboardClass = dotNetClass "System.Windows.Forms.Clipboard" --create a Clipboard dotNetClass
			local net_img = clipboardClass.getImage()
			net_img.MakeTransparent (netDrColor backgroundColor) --backgroundColor = render bg color
			return net_img 
		),
		fn renderToCanvas s a =
		(
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
				
				local net_img = mcs.maxImageToDotnet img
				--add diffuse and alpha in to buttons
				mcs.btn_showImage.image = net_img
				mcs.btn_showAlpha.image = mcs.getAlpha net_img
				--add resized icon in to paint box
				net_img = mcs.resizeImage2 net_img 240 240
				mcs.paint_box.image = net_img
			)
		),
		fn getPixelFromCanvas x y img = (return (img.getPixel (x-5) (y+5))), -- set pipe icon offset to left bottom
		fn canvasMouseDown s a = 
		(
			local mouse_btn = a.Button.ToString()
			local clr
			mcs.drawMode = true
			if keyboard.altPressed 
			then --pick color
			(
				clr = mcs.getPixelFromCanvas a.x a.y s.image
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
					"Left": 
					(
						local clr = mcs.btn_cpfront.backColor
						case mcs.active_tool of
						(
							"Brush":(mcs.drawPoint s a clr)
							"Line":(mcs.drawLineEnabled = not mcs.drawLineEnabled)
							"Fill":(mcs.fillCanvas s a clr)
							"Cross":(mcs.drawCross s a clr)
						)	
					)
					"Right":
					(
						local clr = mcs.btn_cpback.backColor
						case mcs.active_tool of
						(
							"Brush":(mcs.drawPoint s a clr)
							"Line":
							(
								mcs.drawLineAborted = true
								mcs.drawLineEnabled = false
								s.image = mcs.drawLineOrigImage
								mcs.drawLineFirstPoint = undefined
							)
							"Fill":(mcs.fillCanvas s a clr)
							"Cross":(mcs.drawCross s a clr)
						)	
					)
				)
			)
		),
		fn cursorIsOnCanvas s a = 
		( 
			local msp=mouse.screenPos
			local mso = [8,-8] --mouse screen offset
			local mp = msp - [form.location.x, form.location.y] - mso - [s.Location.x, s.Location.y]
			mp.x <= s.width and mp.x > -1 and mp.y <= s.height and mp.y > -1
		), 
		--fn drawToForm s a = ()--(cursor.Current = mcCursor.get #arrow)
		fn canvasMouseUp s a = (mcs.drawMode = false),
		fn canvasKeyDown s a =(if a.Alt and mcs.cursorIsOnCanvas s a then mcs.cursor.Current = mcCursor.get #pipe else mcs.cursor.Current = mcCursor.get #cross),
		fn canvasKeyUp s a =(if mcs.cursorIsOnCanvas s a do mcs.cursor.Current = mcCursor.get #cross),
		fn DrawToCanvas s a move:true =
		(
			s.focus()
			local mouse_btn = a.Button.ToString()
			local x = a.x
			local y = a.y	
			--mouse icons
			if mcs.cursorIsOnCanvas s a 
			then
			(
				if keyboard.altPressed
				then mcs.cursor.Current = mcCursor.get #pipe
				--else if ckb_brush_f.checked then cursor.Current = mcCursor.get #fill
				else mcs.cursor.Current = mcCursor.get #cross
			)
			--else cursor.Current = mcCursor.get #arrow
			
			
			if not keyboard.altPressed and mcs.drawMode and x < s.image.width and x > 0 and y < s.image.height and y > 0 then
			(
				--format "location240:%\n" [x, y]
				case mouse_btn of --LMB, RMB, MB
				(
					"Left": 
					(
						--get brush type
						local clr = mcs.btn_cpfront.backColor
						case mcs.active_tool of
						(
							"Brush":(mcs.drawPoint s a clr)
							"Line":(mcs.drawLineEnabled = true)
							"Fill":(mcs.fillCanvas s a clr)
							"Cross":(mcs.drawCross s a clr)
						)
					)
					"Right": 
					(
						--get brush type
						local clr = mcs.btn_cpback.backColor
						case mcs.active_tool of
						(
							"Brush":(mcs.drawPoint s a clr )
							"Line":(mcs.drawLineEnabled = false)
							"Fill":(mcs.fillCanvas s a clr)
							"Cross":(mcs.drawCross s a clr)
						)
					)
					"Middle":--undo
					( 

					)
					"XButton1":()
					"XButton2":()
				)
			)
		),
		fn onOpenForm s a = (
			
			local active_icon_index = mcGM.getParam "active_icon_index"
			mcs.loadIconLibrary s a marked:(if active_icon_index != undefined then active_icon_index else 0)
			if active_icon_index != undefined do mcs.editIcon s a
		),
		fn onCloseForm s a = (mcFile.saveDialogSettings s.name "Properties_2"),
		-- SetUp Interface
		fn init = (
			
			-- Init Maxform
			dotNet.loadAssembly "MaxCustomControls.dll"
			
			form.name = "mcIconMakerDialog"
			form.ControlBox  = false --hide main bar
			local fpos = execute (mcFile.readSettings Micra.UserProfile "Properties_2/mcIconMakerDialog" type:"pos")
			if classOf fpos != point2 do (fpos = [0, 0]) --register new fpos on close
			
			form.StartPosition = form.StartPosition.Manual
			form.bounds = netDrRect fpos form_size
			form.FormBorderStyle = form.FormBorderStyle.none
			form.BackColor = netDrColor (mcUIColors.get #fore)
			form.ShowInTaskbar = false
			form.opacity = 1--(mcUIColors.get #opacity)

			--toolbar
			lblT.bounds = netDrRect [border_offset, border_offset] [form_size.x - border_offset*10 , bar_height]
			lblT.BackColor = netDrColor (mcUIColors.get #back)
			lblT.ForeColor = netDrColor (mcUIColors.get #text)
			lblT.Text = "Icon Maker: 1/400"
			
			--min max button
			btnMin.FlatStyle = btnMin.FlatStyle.flat
			btnMin.BackColor = netDrColor (mcUIColors.get #btn) --(color 124 196 22)
			btnMin.ForeColor = netDrColor (mcUIColors.get #text)
			btnMin.text = "-"
			btnMin.Bounds = netDrRect [form_size.x - (btnMin.width /2) - (border_offset*2) - 1 , border_offset] [btn_size, bar_height]
			
			--Componnts Layout
			tlp.Bounds  = netDrRect [border_offset, bar_height + border_offset * 2] [form_size.x - 20, form_size.y - 36]
			tlp.backColor = netDrColor(mcUIColors.get #btn)
		
			--Custom Components
			icon_box.bounds = netDrRect [240+border_offset*4,  border_offset*2 + bar_height ] [480, 480]
			icon_box.BackColor = netDrColor black
			--icon_box.visible = false

			paint_box.bounds = netDrRect [border_offset, border_offset*2 + bar_height ] [244, 244]
			paint_box.BackColor = netDrColor black --(mcUIColors.get #back)
			paint_box.image = createNewImage 240 240 transparent_color transparent:true
			paint_box.BorderStyle = paint_box.BorderStyle.Fixed3D
			paint_box.SizeMode = (dotNetClass "PictureBoxSizeMode").StretchImage
			
			btn_render.bounds = netDrRect [2,264] [52, 56]
			btn_copy.bounds = netDrRect [142,264] [52, 26]
			btn_paste.bounds = netDrRect [142,292] [52, 26]
			btn_clear.bounds = netDrRect [142+53,292] [52, 26]
			btn_swap_picker.bounds = netDrRect [2,350] [52, 26]
			btn_reset_picker.bounds = netDrRect [2,377] [52, 26]
			btn_add.bounds = netDrRect [142+80,264] [26, 26]
			btn_load.bounds = netDrRect [142+53,264] [26, 26] 
			btn_save.bounds = netDrRect  [142,320] [52, 26]
			btn_reload.bounds = netDrRect  [142+53,320] [52, 26]
			
			btn_render.BackColor = netDrColor (mcUIColors.get #btn) 
			btn_render.ForeColor = netDrColor (mcUIColors.get #text) 
			btn_copy.BackColor = netDrColor (mcUIColors.get #btn) 
			btn_copy.ForeColor = netDrColor (mcUIColors.get #text) 
			btn_paste.BackColor = netDrColor (mcUIColors.get #btn) 
			btn_paste.ForeColor = netDrColor (mcUIColors.get #text) 
			btn_clear.BackColor = netDrColor (mcUIColors.get #btn) 
			btn_clear.ForeColor = netDrColor (mcUIColors.get #text) 
			btn_swap_picker.BackColor = netDrColor (mcUIColors.get #btn) 
			btn_swap_picker.ForeColor = netDrColor (mcUIColors.get #text) 
			btn_reset_picker.BackColor = netDrColor (mcUIColors.get #btn) 
			btn_reset_picker.ForeColor = netDrColor (mcUIColors.get #text) 
			btn_add.BackColor = netDrColor (mcUIColors.get #btn) 
			btn_add.ForeColor = netDrColor (mcUIColors.get #text) 
			btn_load.BackColor = netDrColor (mcUIColors.get #btn) 
			btn_load.ForeColor = netDrColor (mcUIColors.get #text) 
			btn_save.BackColor = netDrColor (mcUIColors.get #btn) 
			btn_save.ForeColor = netDrColor (mcUIColors.get #text) 
			btn_reload.BackColor = netDrColor (mcUIColors.get #btn) 
			btn_reload.ForeColor = netDrColor (mcUIColors.get #text) 
			
			btn_brush.bounds = netDrRect  [8,420] [52, 26]
			btn_brush.BackColor = netDrColor (mcUIColors.get #btn) 
			btn_brush.ForeColor = netDrColor (mcUIColors.get #text) 
			btn_brush.text =  "Brush"
			btn_brush.Checked = true
			btn_line.bounds = netDrRect  [68,420] [52, 26]
			btn_line.BackColor = netDrColor (mcUIColors.get #btn) 
			btn_line.ForeColor = netDrColor (mcUIColors.get #text) 
			btn_line.text = "Line"
			btn_fill.bounds = netDrRect  [128,420] [52, 26]
			btn_fill.BackColor = netDrColor (mcUIColors.get #btn) 
			btn_fill.ForeColor = netDrColor (mcUIColors.get #text) 
			btn_fill.text = "Fill"
			btn_cross.bounds = netDrRect  [188,420] [52, 26]
			btn_cross.BackColor = netDrColor (mcUIColors.get #btn) 
			btn_cross.ForeColor = netDrColor (mcUIColors.get #text) 
			btn_cross.text = "Cross"
	
			btn_showImage.bounds = netDrRect [55,264] [26, 26]
			btn_showImage.flatstyle = btn_showImage.flatstyle.flat
			btn_showImage.FlatAppearance.BorderSize = 0
			btn_showImage.image = createNewImage 24 24 transparent_color transparent:true
			
			btn_showAlpha.bounds = netDrRect [55,292] [26, 26]
			btn_showAlpha.flatstyle = btn_showAlpha.flatstyle.flat
			btn_showAlpha.FlatAppearance.BorderSize = 0
			btn_showAlpha.image = createNewImage 24 24 white
			
			btn_cpfront.bounds = netDrRect [2,323] [26, 26]
			btn_cpfront.BackColor = netDrColor white
			btn_cpback.bounds = netDrRect [28,323] [26, 26]
			btn_cpback.BackColor = netDrColor black
			
			btn_render.text=  "Render"
			btn_clear.text = "Clear"
			btn_copy.text= "Copy"
			btn_paste.text = "Paste"
			btn_swap_picker.text = "Swap"
			btn_reset_picker.text = "Reset"
			btn_add.text = ">>"
			btn_load.text = "<<"
			btn_save.text = "Save"
			btn_reload.text = "Reload"
			
			ToolTip.IsBalloon = true
			ToolTip.BackColor = netDrColor (mcUIColors.get #back)
			ToolTip.ForeColor = netDrColor (mcUIColors.get #text)
			ToolTip.AutoPopDelay = 5000
			ToolTip.InitialDelay = 400
			ToolTip.ReshowDelay = 100
			ToolTip.ShowAlways = true
			--ToolTip.UseAnimation = true
			--ToolTip.UseFading = true

			--Default Events
			dotnet.addEventHandler form "Shown" onOpenForm
			dotnet.addEventHandler form "Closed" onCloseForm
			dotNet.addEventHandler btnMin "MouseClick" minMaxForm
			dotNet.addEventHandler lblT   "MouseMove" onLblTMouseMove
			dotNet.addEventHandler lblT   "MouseDown" onLblTMouseDown 
			dotNet.addEventHandler lblT   "MouseUp" onLblTMouseUp
			dotnet.AddEventHandler form "BackColorChanged" changeBackcolor --override backcolorchanged event (without this form color is default)
			
			--Custom Events
			dotnet.addEventHandler form "VisibleChanged" onCloseForm
			--dotNet.addEventHandler form  "MouseUp" getFormPos
			--dotNet.addEventHandler form  "MouseMove" drawToForm
			dotNet.addEventHandler icon_box   "MouseUp"  markIcon
			--dotNet.addEventHandler icon_box   "MouseDown"  iconBoxMouseDown
			dotNet.addEventHandler icon_box   "MouseDoubleClick"  editIcon
			dotNet.addEventHandler btn_copy   "MouseUp"  copyIcon
			dotNet.addEventHandler btn_paste   "MouseUp"  pasteIcon
			dotNet.addEventHandler btn_clear  "MouseUp"  clearIcons
			dotNet.addEventHandler btn_showImage  "MouseUp"  showDiffuse
			dotNet.addEventHandler btn_showAlpha  "MouseUp"  showAlpha
			dotNet.addEventHandler paint_box   "MouseDown" canvasMouseDown 
			dotNet.addEventHandler paint_box   "MouseMove" drawLine 
			dotNet.addEventHandler paint_box   "MouseUp" canvasMouseUp
			dotNet.addEventHandler paint_box   "MouseMove" drawToCanvas
			dotNet.addEventHandler paint_box   "KeyDown" canvasKeyDown
			dotNet.addEventHandler paint_box   "KeyUp" canvasKeyUp 
			dotNet.addEventHandler btn_swap_picker  "MouseUp" swapPickerColors
			dotNet.addEventHandler btn_reset_picker   "MouseUp" resetPickerColors
			dotNet.addEventHandler btn_save   "MouseUp" saveIconLibrary
			dotNet.addEventHandler btn_reload   "MouseUp" loadIconLibrary
			dotNet.addEventHandler btn_load  "MouseUp" editIcon
			dotNet.addEventHandler btn_add  "MouseUp" addIconToLibrary
			dotNet.addEventHandler btn_render  "MouseUp" renderToCanvas
			dotNet.addEventHandler btn_cpfront "MouseEnter" showColorTooltip
			dotNet.addEventHandler btn_cpback "MouseEnter" showColorTooltip
			dotNet.addEventHandler btn_cpfront "MouseUp" pickColor
			dotNet.addEventHandler btn_cpback "MouseUp" pickColor
			dotNet.addEventHandler btn_brush "MouseUp" rbCheck
			dotNet.addEventHandler btn_line "MouseUp" rbCheck
			dotNet.addEventHandler btn_fill "MouseUp" rbCheck
			dotNet.addEventHandler btn_cross "MouseUp" rbCheck
			
			--Add Controls
			form.controls.addRange \
			( 
				#(
					btnMin, lblT, icon_box, paint_box, btn_render, btn_clear, 
					btn_copy, btn_paste, btn_showImage, btn_showAlpha,
					btn_cpfront, btn_cpback, btn_swap_picker, btn_reset_picker,
					btn_add, btn_load, btn_save, btn_reload, btn_brush, btn_line, 
					btn_fill, btn_cross,tlp
				) 
			)
			-- Shows the form with the specified owner (MAX) to the user (creatd by lo)
			local nw = defNWin()
			form.show(nw) 
			nw.ReleaseHandle()
		),
		initIt = init()
	)
	mcIconMakerDialog = dotNetFormStruct()
	mcs = mcIconMakerDialog --structure shortcut (simplest use)
	dia = mcIconMakerDialog.form --form instance
)