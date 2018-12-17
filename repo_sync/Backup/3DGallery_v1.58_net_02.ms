------------------
------------------
--                  --
--  3D Gallery --
--                  --
------------------
------------------
Global mcDgalleryDialog
Global mcTextBoxDialog
Global mcDgalleryRootDir = getINISetting mcUserINI "3DGallery" "Server_Dir" --getFilenamePath (getThisScriptFilename())
Global mcUserINI
--    Rene 2012    --
try ( mcDgalleryDialog.close() ) catch()
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
	local form_opacity = 0.8--execute (mcFile.saveLoadIniSetings head:head_str key:"opacity"  action:#load)
	local bar_height      = 14
	local form_bounds     = 2
	local form_offset     = 2 --border line
	local border_size    = 16
	local btn_size        = 24--32
	local form_size       =[754, 608]
	local cp_width        = 48
	local debug = 0
	--<
	
	-->Components---------------------------------------------------------------------
	local form = dotNetObject "MaxCustomControls.Maxform"
	--local form = dotNetObject "Form" 
	--<
	struct ICON_COMPONENTS_STRUCT
	(
		--variables
		ToolTip  = dotNetObject "ToolTip",
		flp_cat  = dotNetObject "flowlayoutpanel",
		progbar = dotNetObject "Progressbar",
		--tb        = dotNetObject "Tabcontrol",
		tb        = dotNetObject "radiobutton",
		lblT      = dotNetObject "label",
		lbl_find  = dotNetObject "label",
		lbl_logo = dotNetObject "label", 
		lbl_tools = dotNetObject "label", 
		lbl_paint = dotNetObject "label", 
		lbl_settings = dotNetObject "label", 
		tlp_tools  = dotNetObject "TableLayoutPanel",
		tlp_paint  = dotNetObject "TableLayoutPanel",
		tlp_settings  = dotNetObject "TableLayoutPanel",
		tools_buttons = #(),
		paint_buttons = #(),
		settings_buttons = #(),
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
	
--|	--Functions

	fn	getImage file_name =
	(
		local img = (dotNetClass "Drawing.Image").FromFile file_name --get the saved image from file as bitmap
		local img_clone = (dotNetObject "Drawing.Bitmap" img.width img.height) --Create new bitmap object
		local gra  = (dotNetClass "Drawing.Graphics").fromImage img_clone --Create new Graphics object
		gra.DrawImage img 0 0 img.width img.height -- (dotNetClass "Drawing.GraphicsUnit").Pixel
		img.dispose()
		gra.dispose()
		return img_clone
	)
	fn onMouseUp s a = (print s.tag)
	fn addTabButtons mcs names:#() images:#()=
	(
		local buttons = #()
		for i = 1 to names.count do
		(
			local b = dotNetObject "Button"
			b.size  = netDrSize [btn_size, btn_size]
			b.FlatStyle = b.FlatStyle.flat
			b.FlatAppearance.BorderColor = netDrColor clr_back		
			b.Forecolor = netDrColor clr_text
			b.FlatAppearance.BorderSize = 0
			b.margin =  dotnetobject "padding" 0
			b.name = "btn_"+((i as integer) as string)
			--b.text = names[i]
			b.image = getIconDotNet images[i]
			b.tag = names[i]
			mcs.toolTip.SetToolTip b b.tag
			dotNet.addEventHandler b "MouseUp" onMouseUp
			buttons += #(b)
		)
		return buttons
	)
--||		
	
--|	--Form actions	
	fn onOpenForm s a = ()
	fn onCloseForm s a = (mcFile.saveIniDialog s "Properties_2" s.name)
	fn changeBackcolor s a = (s.backColor = netDrColor clr_fore)
--||

	
	fn inicializeInterface form mcs =
	(
		form.name = "mcDgalleryDialog"
		form.ControlBox  = false --hide main bar
		local fpos = (mcCall.getIniDataFromArray mcTempProfileIni "Properties_2" "mcDgalleryDialog" 2)
		if fpos == undefined do fpos = (mcCall.getIniDataFromArray mcDefaultProfileIni "Properties_2" "mcDgalleryDialog" 2)
		form.StartPosition = form.StartPosition.Manual
		form.FormBorderStyle = form.FormBorderStyle.Sizable--none--SizableToolWindow--
		--form.dock = form.dock.left
		form.bounds = netDrRect fpos form_size
		form.MinimumSize = netDrSize [btn_size*2, bar_height]
		--form.MaximumSize = netDrSize [btn_size*10, btn_size*10]
		form.BackColor = netDrColor clr_fore
		form.ShowInTaskbar = false
		form.opacity = form_opacity
		
		--logo
		mcs.lbl_logo.bounds = netDrRect [form_offset, bar_height+form_offset*2] [48, 48]
		mcs.lbl_logo.image = getImage (mcPath()+"Img\\3DGallery_Icon.bmp")
		
		--main toolbar
		mcs.lblT.bounds = netDrRect [form_offset, form_offset] [form_size.x - form_offset*2-border_size , bar_height]
		mcs.lblT.BackColor = netDrColor clr_back
		mcs.lblT.ForeColor = netDrColor clr_text
		mcs.lblT.Text = " 3DGallery II:  Models  0/0"
		
		--search bar
		mcs.lbl_find.bounds = netDrRect [form_size.x/2 - btn_size/2, bar_height+form_offset*2+32] [btn_size*2, bar_height]
		mcs.lbl_find.Text = "search:"
		mcs.lbl_find.TextAlign = mcs.lbl_find.TextAlign.MiddleCenter --(dotnetClass "Drawing.ContentAlignment").MiddleCenter
		mcs.lbl_find.BackColor = netDrColor clr_back
		mcs.lbl_find.ForeColor = netDrColor clr_text
		
		--tools
		mcs.lbl_tools.bounds = netDrRect [form_offset, bar_height+form_offset*2+50] [btn_size*2 , bar_height]
		mcs.lbl_tools.BackColor = netDrColor clr_back
		mcs.lbl_tools.ForeColor = netDrColor clr_text
		mcs.lbl_tools.Text = "Tools:"

		mcs.tlp_tools.bounds = netDrRect  [form_offset, bar_height*2+form_offset*2+50] [btn_size*2, btn_size*2]
		mcs.tlp_tools.backColor = netDrColor clr_btn
		mcs.tlp_tools.ColumnCount = 2
		
		local names = #("Add Model", "Delete Model", "Merge to Scene", "Rename Model")
		local images = #(149, 148, 147, 144)
		mcs.tools_buttons = addTabButtons mcs names:names images:images
		mcs.tlp_tools.controls.addRange (mcs.tools_buttons)
		
		--paint
		mcs.lbl_paint.bounds = netDrRect [form_offset, bar_height+form_offset*2+116] [btn_size*2 , bar_height]
		mcs.lbl_paint.BackColor = netDrColor clr_back
		mcs.lbl_paint.ForeColor = netDrColor clr_text
		mcs.lbl_paint.Text = "Paint:"

		mcs.tlp_paint.bounds = netDrRect  [form_offset, bar_height*2+form_offset*2+116] [btn_size*2, btn_size*2]
		mcs.tlp_paint.backColor = netDrColor clr_btn
		mcs.tlp_paint.ColumnCount = 2
		
		local names = #("Pick a surface for planting", "Plant Customize...", "Planting", "Multiplanting")
		local images = #(146, 164, 145, 163)
		mcs.paint_buttons = addTabButtons mcs names:names images:images
		mcs.tlp_paint.controls.addRange (mcs.paint_buttons)
		
		--settings
		mcs.lbl_settings.bounds = netDrRect [form_offset, bar_height+form_offset*2+182] [btn_size*2 , bar_height]
		mcs.lbl_settings.BackColor = netDrColor clr_back
		mcs.lbl_settings.ForeColor = netDrColor clr_text
		mcs.lbl_settings.Text = "Settings:"

		mcs.tlp_settings.bounds = netDrRect  [form_offset, bar_height*2+form_offset*2+182] [btn_size*2, btn_size+352]
		mcs.tlp_settings.backColor = netDrColor clr_btn
		mcs.tlp_settings.ColumnCount = 2
		
		local names = #("Customize...", "Help")
		local images = #(143, 162)
		mcs.settings_buttons = addTabButtons mcs names:names images:images
		mcs.tlp_settings.controls.addRange (mcs.settings_buttons)
		
		--thumbnails
		mcs.flp_cat.bounds = netDrRect [btn_size*2+form_offset*2, bar_height+form_offset*2+50] [684, 510]
		mcs.flp_cat.AutoSize = true
		mcs.flp_cat.autoscroll = true
		mcs.flp_cat.padding = dotnetobject "system.windows.forms.padding" 2
		mcs.flp_cat.BackColor = netDrColor (color 40 45 66)
		
		--tabs
		mcs.tb.bounds = netDrRect [btn_size*2+form_offset*2, 46] [164, 26]
		
		--mcs.tb.BackColor = netDrColor green
		--mcs.tb.ForeColor = netDrColor red
		--mcs.tb.HotTrack = true
		--mcsystem.show mcs.tb
		/*
		local Tabs_Array = #("Models", "Materials", "Textures")
		for i in Tabs_Array do
 		(
 			mcs.tb.TabPages.add i
 		)	
		*/
		--progress bar
		mcs.progbar.bounds = netDrRect [form_offset*2+btn_size*2,579] [684, 12]
		
		--add handlers
		dotnet.addEventHandler form "Shown" onOpenForm
		dotnet.addEventHandler form "Closed" onCloseForm
		dotnet.AddEventHandler form "BackColorChanged" changeBackcolor --thanks cyfer
		dotnet.addEventHandler form "VisibleChanged" onCloseForm
		--dotNet.addEventHandler form  "MouseMove" drawToForm
		dotNet.addEventHandler mcs.lblT   "MouseMove" onLblTMouseMove
		dotNet.addEventHandler mcs.lblT   "MouseDown" onLblTMouseDown 
		dotNet.addEventHandler mcs.lblT   "MouseUp"   onLblTMouseUp
		
		--add controls
		form.controls.addRange \
	  #(
			mcs.lblT, mcs.lbl_find, mcs.lbl_logo, mcs.lbl_tools, mcs.tlp_tools, mcs.lbl_paint, mcs.tlp_paint, mcs.lbl_settings, mcs.tlp_settings,
		    mcs.flp_cat, mcs.tb, mcs.progbar
		)
	)
	inicializeInterface form form.tag.value
	mcDgalleryDialog = form
	--mcDgalleryDialog.show(WindowWrapper)
	mcDgalleryDialog.showModeless()
)