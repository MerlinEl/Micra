-----------------------
--Color Picker Compact
-----------------------

--Customize Micra
Global mcInterfaceColorDilaog

-->Micra Interface
try ( mcInterfaceColorDilaog.close() ) catch()
(
	-->Locals-----------------------------------------------------------------
	local bar_height      = 14
	local form_bounds     = 2
	local form_offset     = 4
	local btn_size        = 24
	local form_size       =[299, 130]
	local cp_width        = 48
	local debug = 0
	-->Components---------------------------------------------------------------------
	--local form = dotNetObject "Form"
	local form = dotNetObject "MaxCustomControls.Maxform"
	local last_profile = execute (mcFile.saveLoadIniSetings head:"Interface" key:"lastprofile" action:#load)
	local profiles = #("DefaultColor", "UserColor", "ForestColor", "EarthColor", "MoonColor", "SeaColor", "SunColor", "Close") --, "SandColor"
	local head_str = profiles[last_profile]
	--format "last profile:%\thead:%\n" last_profile head_str
	struct COLOR_DATA ( h, s, b, a )
	struct INTERFACE_COLORS
	(
		clr_back     = execute (mcFile.saveLoadIniSetings head:head_str key:"backcolor" action:#load),
		clr_fore     = execute (mcFile.saveLoadIniSetings head:head_str key:"forecolor" action:#load),
		clr_sel      = execute (mcFile.saveLoadIniSetings head:head_str key:"selected"  action:#load),
		clr_mark     = execute (mcFile.saveLoadIniSetings head:head_str key:"marked"  action:#load),
		clr_btn      = execute (mcFile.saveLoadIniSetings head:head_str key:"button"   action:#load),
		clr_inact    = execute (mcFile.saveLoadIniSetings head:head_str key:"inactive"  action:#load),
		clr_text     = execute (mcFile.saveLoadIniSetings head:head_str key:"textcolor"  action:#load),
		clr_seltext  = execute (mcFile.saveLoadIniSetings head:head_str key:"seltext"  action:#load),
		form_opacity = execute (mcFile.saveLoadIniSetings head:head_str key:"opacity"  action:#load)
	)
	struct MICRA_COMPONENTS_STRUCT
	(
		--variables
		lblT   = dotNetObject "label" ,
		lblRGB = dotNetObject "label" ,
		lblSAT = dotNetObject "label" ,
		lblBRI = dotNetObject "label" ,
		lblALP = dotNetObject "label" ,
		sldHUE = dotNetObject "label", 
		sldSAT = dotNetObject "label", 
		sldBRI = dotNetObject "label",
		sldALP = dotNetObject "label",
		HSBA_data = COLOR_DATA(),
		old_color = dotNetObject "button",
		new_color = dotNetObject "button",
		tlp    = dotNetObject "TableLayoutPanel",
		btn    = dotNetObject "TableLayoutPanel",
		combo_box = dotNetObject "comboBox",
		buttons = #(),
		mnu = dotNetObject "ContextMenuStrip",
		mnu_items = #(),
		icolors = INTERFACE_COLORS(),
		netDMove = false, 
		netDmPos,
		ini_keys = #("Background", "Foreground", "Selected", "Marked", "Buttons", "Inactive", "Text", "Selected Text")
	)
	
	form.tag = dotNetMXSValue (MICRA_COMPONENTS_STRUCT()) --manual Lifetime	
	
	fn closeForm s a = ( ((s.GetCurrentParent()).tag).close() )
	fn onCloseForm s a = (mcFile.saveIniDialog s.name "Properties_2")
	fn onOpenForm s a = (s.BackColor = netDrColor s.tag.value.icolors.clr_fore) --yellow
--|	--Form move
	fn onLblTMouseMove s a = 
	(
		local form = s.parent
		if form.tag.value.netDMove do --dragForm
		(
			mcDialog.snapForm form form.tag.value.netDmPos
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
		local mcs = form.tag.value
		mcs.netDMove = false --disableDrag	
		if a.Button == a.Button.right then 
		(
			mcs.mnu.tag = form
			
			for i = 0 to mcs.ini_keys.count-1 do
			(
				if i != last_profile - 1
				then
				(
					mcs.mnu.items.item[i].backColor = netDrColor mcs.icolors.clr_back
					mcs.mnu.items.item[i].forecolor = netDrColor mcs.icolors.clr_inact
				)
				else
				(
					mcs.mnu.items.item[i].backColor = netDrColor mcs.icolors.clr_mark
					mcs.mnu.items.item[i].forecolor = netDrColor mcs.icolors.clr_text
				)
			)
			mcs.mnu.Show (s.PointToScreen a.location)
		)
	)
--||
	fn getHueImage =
	(
		local fpath = Micra.RootDir + "Img\\Picker_Hue.bmp"
		if not doesFileExist fpath do return undefined
		local img_file = (dotNetClass "Drawing.Image").FromFile fpath --get the saved image from file as bitmap
		local w=img_file.width
		local h=img_file.height
		local img = (dotNetObject "Drawing.Bitmap" w h) --Create new bitmap object
		local gra  = (dotNetClass "Drawing.Graphics").fromImage img --Create new Graphics object
		local newRect = netDrRect [ 0, 0 ] [ w, h ]  --adjust icon offset X in button 
		gra.DrawImage img_file newRect 0 0 w h (dotNetClass "Drawing.GraphicsUnit").Pixel	
		img_file.dispose()
		return img
	)
	fn refreshSliders mcs =
	(
		local sld = #(mcs.sldHUE, mcs.sldSAT, mcs.sldBRI)
		for i in sld do i.Refresh()
	)
	fn fillGradient gra clr1 clr2 =
	(
		local system_angle = (dotnetobject "System.Single" 0)
		local clr1 =(netDrColor clr1)
		local clr2 =(netDrColor clr2)
		local rect = (dotnetobject "System.Drawing.Rectangle" 0 0 256 bar_height)
		local brush =dotnetobject "System.Drawing.Drawing2D.LinearGradientBrush" rect clr1 clr2  system_angle
		gra.FillRectangle brush rect
	)
	fn onPickedBoxItem s a =
	(
		local form = s.parent
		if form != undefined do
		(
			local mcs  = form.tag.value
			local clr = case s.SelectedItem of
			(
				"Background":mcs.icolors.clr_back
				"Foreground":mcs.icolors.clr_fore
				"Selected"   :mcs.icolors.clr_sel
				"Marked"    :mcs.icolors.clr_mark
				"Buttons"    :mcs.icolors.clr_btn
				"Inactive"    :mcs.icolors.clr_inact
				"Text"       :mcs.icolors.clr_text
				"Selected Text":mcs.icolors.clr_seltext
			)
			mcs.old_color.backcolor = netDrColor clr
			mcs.new_color.backcolor = mcs.old_color.backcolor
			refreshSliders mcs
		)
	)
	fn fillComboBox list mcs =
	(
		--local keys = getIniSetting Micra.DefaultSettings "UserColor"
		list.Items.AddRange (dotNetArray mcs.ini_keys)
		list.SelectedIndex = 0
	)
	fn onPaintLabels s a =
	(
		local form = s.parent.parent
		local mcs = form.tag.value
		
		--Get color HSB values for sliders position
		local clr = netColorToRGB mcs.new_color.backcolor		
		mcs.icolors.form_opacity  = form.opacity
		local posX = case s.name of
		(
			"H:":mcs.HSBA_data.h = clr.h
			"S:":mcs.HSBA_data.s = clr.s
			"B:":mcs.HSBA_data.b = clr.v
			"A:":mcs.HSBA_data.a = mcs.icolors.form_opacity*255
		)
	
		case s.name of
		(
			"S:": fillGradient a.graphics white clr
			"B:": fillGradient a.graphics black clr
		)
		
		case s.name of
		(
			"H:":mcs.lblRGB.text = "H:"+(posX as integer) as string
			"S:":mcs.lblSAT.text = "S:"+(posX as integer) as string
			"B:":mcs.lblBRI.text = "B:"+(posX as integer) as string
			"A:":mcs.lblALP.text = "A:"+((posX/2.5) as integer) as string
		)

		--format "Slider_%\tRGB:%\tHSBA:%\n" s.name clr mcs.HSBA_data

		--Draw Redraw Markers
		if posX <= 2   then posX += 2
		if posX >= 255 then posX -= 2
		
		local fillBrush = dotnetobject "System.Drawing.SolidBrush" (netDrColor mcs.icolors.clr_fore)
		local fillColor = netDrColor mcs.icolors.clr_back
		local rect = (dotnetobject "System.Drawing.Rectangle" (posX-4) 0 8 bar_height)
		
		--mcSystem.show a.graphics
		a.graphics.FillRectangle fillBrush rect
		(dotnetclass "ControlPaint").DrawBorder a.graphics rect fillColor (dotnetclass "ButtonBorderStyle").Solid	
	)
	fn updateInterfaceColor mcs clr =
	(
		case mcs.combo_box.SelectedItem of
		(
			"Background":
			(
				mcs.icolors.clr_back = clr
				for i in #(mcs.lblRGB, mcs.lblSAT, mcs.lblBRI, mcs.lblALP, mcs.lblT, mcs.combo_box, mcs.mnu) do i.backColor = netDrColor clr
				for i in mcs.buttons do i.FlatAppearance.BorderColor = netDrColor clr
			)
			"Foreground":
			(
				mcs.icolors.clr_fore = clr
				form.BackColor = netDrColor clr 
			)
			"Selected"   :
			(
				mcs.icolors.clr_sel = clr
			)
			"Marked"    :
			(
				mcs.icolors.clr_mark = clr
			) 
			"Buttons"    :
			(
				mcs.icolors.clr_btn = clr
				for i in mcs.buttons do i.backColor = netDrColor clr
			)
			"Inactive"    :
			(
				mcs.icolors.clr_inact = clr
				for i in #( mcs.lblRGB, mcs.lblSAT, mcs.lblBRI, mcs.lblALP) do i.Forecolor = netDrColor clr
			)
			"Text"       :
			(
				mcs.icolors.clr_text = clr
				for i in mcs.buttons + #(mcs.lblT, mcs.combo_box, mcs.mnu) do i.Forecolor = netDrColor clr
			)
			"Selected Text":
			(
				mcs.icolors.clr_seltext = clr
			)
		)
	)
	fn resetColor mcs =
	(
		mcs.new_color.backColor = mcs.old_color.backColor
		local clr = netColorToRGB mcs.old_color.backColor
		mcs.HSBA_data.h = clr.h
		mcs.HSBA_data.s = clr.s
		mcs.HSBA_data.b = clr.v
		refreshSliders mcs
		updateInterfaceColor mcs clr
	)
	fn saveSettings form mcs =
	(
		--save selected profile color changes
		local head_str = profiles[last_profile]
		local keys = #("backcolor", "forecolor", "selected", "marked", "button", "inactive", "textcolor", "seltext")
		local colors = #
		(
			mcs.icolors.clr_back,
			mcs.icolors.clr_fore,
			mcs.icolors.clr_sel,
			mcs.icolors.clr_mark,
			mcs.icolors.clr_btn,
			mcs.icolors.clr_inact,
			mcs.icolors.clr_text,
			mcs.icolors.clr_seltext
		)
		for i = 1  to keys.count do mcFile.saveLoadIniSetings head:head_str key:keys[i] data:(colors[i] as string) action:#save
			
		--save opacity
		mcFile.saveLoadIniSetings head:"Interface" key:"opacity" data:((mcs.icolors.form_opacity as float) as string) action:#save
		--save selected profile
		mcFile.saveLoadIniSetings head:"Interface" key:"lastprofile" data:(last_profile as string) action:#save
		form.close()
		
		--restart Micra
		fileIn (Micra.RootDir+ "_Loader.ms")
	)
	fn loadProfile form =
	(
		
		local mcs = form.tag.value
		head_str = profiles[last_profile]
		mcs.icolors = INTERFACE_COLORS()
		
		--format "num:%\tform:%\thead:%\n" profile_num form head_str

		form.BackColor = netDrColor mcs.icolors.clr_fore
		for i in #(mcs.lblRGB, mcs.lblSAT, mcs.lblBRI, mcs.lblALP, mcs.lblT, mcs.combo_box, mcs.mnu) do i.backColor = netDrColor mcs.icolors.clr_back
		for i in mcs.buttons do i.FlatAppearance.BorderColor = netDrColor mcs.icolors.clr_back
		for i in mcs.buttons+#(mcs.tlp, mcs.btn) do i.backColor = netDrColor mcs.icolors.clr_btn
		for i in #( mcs.lblRGB, mcs.lblSAT, mcs.lblBRI, mcs.lblALP) do i.Forecolor = netDrColor mcs.icolors.clr_inact
		for i in mcs.buttons + #(mcs.lblT, mcs.combo_box, mcs.mnu) do i.Forecolor = netDrColor mcs.icolors.clr_text
		
		local clr = case mcs.combo_box.SelectedItem of
		(
			"Background":mcs.icolors.clr_back
			"Foreground":mcs.icolors.clr_fore
			"Selected"   :mcs.icolors.clr_sel
			"Marked"    :mcs.icolors.clr_mark
			"Buttons"    :mcs.icolors.clr_btn
			"Inactive"    :mcs.icolors.clr_inact
			"Text"       :mcs.icolors.clr_text
			"Selected Text":mcs.icolors.clr_seltext
		)
		mcs.old_color.backColor = netDrColor clr
		resetColor mcs
	)
	fn manageProfile s a =
	(
		local val = case s.tag of
		(
			"DefaultColor":1
			"UserColor"  :2
			"ForestColor" :3
			"EarthColor"  :4
			"MoonColor"  :5
			"SeaColor"    :6
			"SunColor"    :7
		)
		
		--format "items:%\n" (s.GetCurrentParent()).items.count
		
		if s.tag == "Close" 
		then closeForm s a
		else 
		(
			--format "selected item:%\n" val
			last_profile = val
			loadProfile ((s.GetCurrentParent()).tag)
		)
	)
	--fn loadPreset a s = ()
	--fn savePreset a s = ()
	fn onSldMouseDown s a = s.tag = true
	fn onSldMouseUp s a = s.tag = false
	fn onSldMouseMove s a =
	(
		if s.tag and a.x >= 0 and a.x <= 255 do 
		(
			local form = s.parent.parent
			local mcs = form.tag.value
		
			case s.name of
			(
				"H:":mcs.HSBA_data.h = a.x
				"S:":mcs.HSBA_data.s = a.x
				"B:":mcs.HSBA_data.b = a.x
				"A:":mcs.HSBA_data.a = a.x
			)
			
			--format "slider:%\tpos_x:%\tHSBA:%\n" s.name a.x mcs.HSBA_data

			local clr = netColorToRGB mcs.new_color.backcolor
			
			clr.h = floor mcs.HSBA_data.h
			clr.s = floor mcs.HSBA_data.s
			clr.v = floor mcs.HSBA_data.b	
			--add color to new color picker
			mcs.new_color.backcolor = netDrColor clr --(color clr.r clr.g clr.b)
			if s.name == "A:" 
			then if a.x >= 40 and a.x <= 252 do form.opacity = a.x/255.
			else updateInterfaceColor mcs clr 
			
			--refreshSliders mcs		
			s.Refresh()
		)
	)
	fn addSliders form mcs = 
	(
		local txt = #("H:", "S:", "B:", "A:")
		local lbl = #(mcs.lblRGB, mcs.lblSAT, mcs.lblBRI, mcs.lblALP)
		local sld = #(mcs.sldHUE, mcs.sldSAT, mcs.sldBRI, mcs.sldALP)
		for i = 1 to txt.count do
		(
			lbl[i].text = txt[i]
			lbl[i].size = netDrSize [35, bar_height]
			lbl[i].margin  =  dotnetobject "padding" 1
			lbl[i].backColor = netDrColor mcs.icolors.clr_back
			lbl[i].foreColor = netDrColor mcs.icolors.clr_inact
			
			sld[i].name = txt[i]
			sld[i].size = netDrSize [256, bar_height]
			sld[i].margin  =  dotnetobject "padding" 1
			sld[i].backColor = netDrColor white
			sld[i].TextAlign = sld[i].TextAlign.MiddleCenter
			sld[i].tag = false
			
			dotNet.addEventHandler sld[i] "MouseUp"   onSldMouseUp
			dotNet.addEventHandler sld[i] "MouseDown" onSldMouseDown
			dotNet.addEventHandler sld[i] "MouseMove" onSldMouseMove
			dotNet.addEventHandler sld[i] "Paint" onPaintLabels
		)
		
		mcs.sldHUE.BackgroundImage = getHueImage()
		
		mcs.tlp.controls.addRange ( #(mcs.lblRGB, mcs.sldHUE, mcs.lblSAT, mcs.sldSAT, mcs.lblBRI, mcs.sldBRI,mcs.lblALP, mcs.sldALP ) )
	)
	fn onBtnMouseClick s a = 
	(
		local form = s.parent.parent
		local mcs  = form.tag.value
		case s.tag of
		(
			"Reset" :resetColor mcs
			"Accept":saveSettings form mcs
			"Cancel":form.close()
		)
	)
	fn addMenuItems form mcs =
	(
		for i in profiles do
		(
			local itm = mcs.mnu.Items.Add (i+"...")
			itm.tag = i
			dotnet.addeventhandler itm "Click" manageProfile
			mcs.mnu_items += #(itm)
		)
	)
	fn addButons form mcs = 
	(
		--add color pickers
		local clr = execute (mcFile.saveLoadIniSetings head:head_str key:"backcolor" action:#load)
		if classof clr != Color then clr = gray
		
		mcs.old_color.size = netDrSize [46, 18]
		mcs.old_color.margin  =  dotnetobject "padding" 1
		mcs.old_color.backColor = netDrColor clr
		mcs.old_color.FlatStyle = mcs.old_color.FlatStyle.flat
		--mcs.old_color.FlatAppearance.BorderColor = netDrColor mcs.icolors.clr_back
		
		mcs.new_color.size = netDrSize [46, 18]
		mcs.new_color.margin  =  dotnetobject "padding" 1
		mcs.new_color.backColor = mcs.old_color.backColor
		mcs.new_color.FlatStyle = mcs.new_color.FlatStyle.flat
		--mcs.new_color.FlatAppearance.BorderColor = netDrColor mcs.icolors.clr_back
		
		--add buttons
		local btn_text_array = #("Reset", "Accept", "Cancel")
		for i = 1 to btn_text_array.count do
		(
			local b = dotNetObject "Button"
			b.size  = netDrSize [66, 20]
			b.FlatStyle = b.FlatStyle.flat
			b.FlatAppearance.BorderColor = netDrColor mcs.icolors.clr_back	
			b.backColor = netDrColor mcs.icolors.clr_btn
			b.Forecolor = netDrColor mcs.icolors.clr_text
			b.FlatAppearance.BorderSize = 1
			b.margin =  dotnetobject "padding" 0
			b.name = "btn_"+((i as integer) as string)
			b.text = btn_text_array[i]
			b.tag =  btn_text_array[i]
			dotNet.addEventHandler b "MouseClick" onBtnMouseClick
			mcs.buttons += #(b)
		)
		
		mcs.btn.controls.addRange ( #(mcs.new_color, mcs.old_color) + mcs.buttons )
	)
	fn inicializeInterface form mcs =
	(
		form.name = "mcInterfaceColorDilaog"
		form.ControlBox  = false --hide main bar
		local fpos = (mcFile.getIniDataFromArray Micra.TempProfileIni "Properties_2" "mcInterfaceColorDilaog" 2)
		if fpos == undefined do fpos = (mcFile.getIniDataFromArray Micra.DefaultProfileIni "Properties_2" "mcInterfaceColorDilaog" 2)
		form.StartPosition = form.StartPosition.Manual
		form.MinimumSize = netDrSize form_size
		form.bounds = netDrRect fpos form_size
		form.FormBorderStyle = form.FormBorderStyle.none
		form.BackColor = netDrColor mcs.icolors.clr_fore --yellow
		form.ShowInTaskbar = false
		form.opacity = mcs.icolors.form_opacity
		
		mcs.mnu.BackColor = netDrColor mcs.icolors.clr_back
		mcs.mnu.ForeColor = netDrColor mcs.icolors.clr_text
		mcs.mnu.ShowImageMargin = false
		
		mcs.lblT.bounds = netDrRect [form_offset/2, form_offset/2] [form_size.x - form_offset, bar_height]
		mcs.lblT.BackColor = netDrColor mcs.icolors.clr_back
		mcs.lblT.ForeColor = netDrColor mcs.icolors.clr_text
		mcs.lblT.Text = "Customize Interface Colors:"
		
		mcs.tlp.bounds = netDrRect [form_offset/2, bar_height+form_offset] [form_size.x - form_offset, bar_height*4+form_bounds*4]
		mcs.tlp.backColor = netDrColor mcs.icolors.clr_btn
		mcs.tlp.ColumnCount = 2
		mcs.tlp.RowCount = 4
		
		mcs.combo_box.bounds    = netDrRect [form_offset/2, bar_height*5+form_offset*3.5] [form_size.x - form_offset, 20]
		mcs.combo_box.BackColor = netDrColor mcs.icolors.clr_back
		mcs.combo_box.Forecolor = netDrColor mcs.icolors.clr_text
		mcs.combo_box.Sorted    = true
		mcs.combo_box.DropDownStyle = mcs.combo_box.DropDownStyle.DropDownList --DropDown--Simple
		mcs.combo_box.FlatStyle = mcs.combo_box.FlatStyle.flat
		mcs.combo_box.MaxDropDownItems = 22
		
		mcs.btn.bounds = netDrRect [form_offset/2, bar_height*6+form_offset*6] [form_size.x - form_offset, 20]
		mcs.btn.backColor = netDrColor mcs.icolors.clr_btn
		mcs.btn.ColumnCount = 5
		
		dotNet.addEventHandler mcs.lblT   "MouseMove" onLblTMouseMove
		dotNet.addEventHandler mcs.lblT   "MouseDown" onLblTMouseDown 
		dotNet.addEventHandler mcs.lblT   "MouseUp"   onLblTMouseUp
		dotnet.addEventHandler form "Closed" onCloseForm
		dotnet.addEventHandler form "Shown" onOpenForm
		dotnet.addEventHandler form "VisibleChanged" onCloseForm
		dotNet.addEventHandler mcs.combo_box "SelectedIndexChanged" onPickedBoxItem

		fillComboBox mcs.combo_box mcs
		addSliders form mcs
		addButons form mcs
		addMenuItems form mcs

		form.controls.addRange( #(mcs.lblT, mcs.tlp, mcs.combo_box, mcs.btn ) )
	)
	inicializeInterface form form.tag.value
	mcInterfaceColorDilaog = form
	mcDotnet.dShow mcInterfaceColorDilaog
)

/*

local clr = mcs.old_color.backcolor	
format "RGB_B:%\tHSB_B:%\n" (clr.ToString()) [clr.GetHue(), clr.GetSaturation(), clr.GetBrightness()]
*/