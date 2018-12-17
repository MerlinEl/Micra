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
	local form_size       =[742, 516]
	local cp_width        = 48
	local debug = 0
	local tempImgLib_D,  tempImgLib_A, activeIconNum, activeIcon_D, activeIcon_A
	local transparent_color = color 211 211 211 --((colorMan.getColor #background)*255) as color
	--<
	
	-->Components---------------------------------------------------------------------
	local form = dotNetObject "MaxCustomControls.Maxform"
	--<
	struct ICON_COMPONENTS_STRUCT
	(
		--variables
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
	
	fn blankImage w h clr =
	(
		local img = (dotNetObject "Drawing.Bitmap" w h) --Create new bitmap object
		local g  = (dotNetClass "Drawing.Graphics").fromImage img --Create new Graphics object
		local brush = dotNetObject "drawing.SolidBrush" (netDrColor clr)
		g.FillRectangle brush 0 0 w h
		g.dispose()
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
		--g.InterpolationMode = (dotnetClass "Drawing.Drawing2D.InterpolationMode").NearestNeighbor
		local brush_size = w/img.width --as float
		for x = 0 to img.width-1 do
		(
			for y = 0 to img.height-1 do
			(
				--format "pos:%\n" [x, y]
				local brush_color = img.getPixel x y
				if brush_color == undefined do continue
				local brush = dotNetObject "drawing.SolidBrush" brush_color--(netDrColor yellow)
				g.FillRectangle brush (x*brush_size) (y*brush_size) brush_size brush_size
			)
		)
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
		if icnNum == 0 do return blankImage 24 24 black
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
		else return blankImage 240 240 transparent_color -- big image
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
	fn showDiffuse = ()
	fn showAlpha = ()
	fn copyIcon s a =
	(
		local form = s.parent
		local mcs = form.tag.value
		setImageToClipboard mcs.paint_box.image  --copy paint_box icon
		--setImageToClipboard mcs.btn_showImage.image  --copy button icon
	)
	fn pasteIcon s a =
	(
		local form = s.parent
		local mcs = form.tag.value
		local img = getImageFromClipboard()
		img.MakeTransparent (netDrColor transparent_color)  --186 --211
		--format "color depth:%\n" img.ColorDepth --= icon.ColorDepth.Depth24Bit
		
		mcs.paint_box.image = img
		mcs.btn_showImage.image  = resizeImage img 24 24
		mcs.btn_showAlpha.image   = getAlpha mcs.btn_showImage.image
	)
	fn blankImage w h clr =
	(
		local img = (dotNetObject "Drawing.Bitmap" w h) --Create new bitmap object
		local g  = (dotNetClass "Drawing.Graphics").fromImage img --Create new Graphics object
		local brush = dotNetObject "drawing.SolidBrush" (netDrColor clr)
		g.FillRectangle brush 0 0 w h
		img
	)
	fn clearIcons s a =
	(
		local form = s.parent
		local mcs = form.tag.value
		mcs.paint_box.image = blankImage 240 240 transparent_color
		mcs.btn_showImage.image = blankImage 24 24 white
		mcs.btn_showAlpha.image = blankImage 24 24 black
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
	fn markIcon s a zero:false = --s==PictureBox, a==MouseEventArgs
	(
		local form = s.parent
		local mcs = form.tag.value
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
		local form = s.parent
		local mcs = form.tag.value
		--get active icon from file
		activeIcon_D = getIcon tempImgLib_D activeIconNum transparent:true
		activeIcon_A = getIcon tempImgLib_A activeIconNum 
		--add resized icon in to paint box
		mcs.paint_box.image =  resizeImage2 activeIcon_D 240 240
		--add diffuse and alpha in to buttons
		mcs.btn_showImage.image = activeIcon_D
		mcs.btn_showAlpha.image = activeIcon_A
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
		form.BackColor = netDrColor clr_fore --yellow
		form.ShowInTaskbar = false
		form.opacity = form_opacity
		
		mcs.lblT.bounds = netDrRect [form_offset, form_offset] [form_size.x - form_offset*10 , bar_height]
		mcs.lblT.BackColor = netDrColor clr_back
		mcs.lblT.ForeColor = netDrColor clr_text
		mcs.lblT.Text = "Icon Maker: 1/400"
		
		mcs.icon_box.bounds = netDrRect [240+form_offset*2,  form_offset*2 + bar_height ] [480, 480]
		mcs.icon_box.BackColor = netDrColor black

		mcs.paint_box.bounds = netDrRect [form_offset, form_offset*2 + bar_height ] [240, 240]
		mcs.paint_box.image = blankImage 240 240 transparent_color
		--mcs.paint_box.BackColor = netDrColor black--white
		
		--mcs.paint_box.SizeMode = (dotNetClass "PictureBoxSizeMode").StretchImage
		
		mcs.btn_render.bounds = netDrRect [2,260] [76, 52]
		mcs.btn_clear.bounds = netDrRect [104+60,288] [52, 24]
		mcs.btn_copy.bounds = netDrRect [48+60,260] [52, 24]
		mcs.btn_paste.bounds = netDrRect [48+60,288] [52, 24]
		
		mcs.btn_showImage.bounds = netDrRect [72+8,260] [26, 26]
		mcs.btn_showImage.flatstyle = mcs.btn_showImage.flatstyle.flat
		mcs.btn_showImage.FlatAppearance.BorderSize = 0
		mcs.btn_showImage.image = blankImage 24 24 transparent_color
		
		mcs.btn_showAlpha.bounds = netDrRect [72+8,288] [26, 26]
		mcs.btn_showAlpha.flatstyle = mcs.btn_showAlpha.flatstyle.flat
		mcs.btn_showAlpha.FlatAppearance.BorderSize = 0
		mcs.btn_showAlpha.image = blankImage 24 24 white
		
		mcs.btn_render.text=  "Render"
		mcs.btn_clear.text = "Clear"
		mcs.btn_copy.text= "Copy"
		mcs.btn_paste.text = "Paste"
		--mcs.btn_showImage.text = "D"
		--mcs.btn_showAlpha.text = "M"
		
		/*
				mcs.btn_render.= 
		mcs.btn_clear. = 
		mcs.btn_copy.= 
		mcs.btn_paste. = 
		mcs.btn_showImage. =
		mcs.btn_showAlpha. = 
		*/
		
		/*
		mcs.tlp.bounds = netDrRect [form_offset/2, bar_height+form_offset] [form_size.x - form_offset*5, btn_size]
		mcs.tlp.backColor = netDrColor clr_btn
		mcs.tlp.ColumnCount = 3
		
		mcs.tab.bounds = netDrRect [form_offset/2, bar_height*2+form_offset*4] [form_size.x - form_offset*5, form_size.y - bar_height - btn_size - form_offset*6]
		mcs.tab.backColor = netDrColor clr_btn --yellow --
*/
		--add handlers
		dotnet.addEventHandler form "Shown" onOpenForm
		dotnet.addEventHandler form "Closed" onCloseForm
		dotnet.addEventHandler form "VisibleChanged" onCloseForm
		
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
		
		
		

		--add controls
		--addTabButtons mcs
		form.controls.addRange( #(mcs.lblT, mcs.icon_box, mcs.paint_box, mcs.btn_render, mcs.btn_clear, mcs.btn_copy, mcs.btn_paste, mcs.btn_showImage, mcs.btn_showAlpha ) )
		--form.controls.addRange( #(mcs.lblT, mcs.tlp, mcs.tab) )
		
	)
	inicializeInterface form form.tag.value
	mcIconMakerDialog = form
	--mcIconMakerDialog.show(WindowWrapper)
	mcIconMakerDialog.showModeless()
)


/*
 .BackgroundImageLayout : <System.Windows.Forms.ImageLayout>
  .ClientRectangle : <System.Drawing.Rectangle>, read-only
  .ClientSize : <System.Drawing.Size>
  .FlatStyle : <System.Windows.Forms.FlatStyle>
  .MaximumSize : <System.Drawing.Size>
  .MinimumSize : <System.Drawing.Size>
  .Padding : <System.Windows.Forms.Padding>
  .Margin : <System.Windows.Forms.Padding>


  .ImageAlign
mcsystem.show (dotnetClass "Drawing.ContentAlignment").TopLeft
#(#BottomCenter, #BottomLeft, #BottomRight, #MiddleCenter, #MiddleLeft, #MiddleRight, #TopCenter, #TopLeft, #TopRight)


ImageBorderEnabled
ImageDropShadow
doesfileexist mcIconI


*/


/*


  .PixelFormat : <System.Drawing.Imaging.PixelFormat>, read-only
.MakeTransparent()
 .MakeTransparent <System.Drawing.Color>transparentColor
  .SetPixel <System.Int32>x <System.Int32>y <System.Drawing.Color>color
  .RotateFlip <System.Drawing.RotateFlipType>rotateFlipType
  pictureBox.Image = pixels.ToBitmap(image.Width, image.Height);

*/