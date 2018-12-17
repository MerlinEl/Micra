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
	--<
	struct ICON_COMPONENTS_STRUCT
	(
		--variables
		ToolTip   = dotNetObject "ToolTip",
		lblT        = dotNetObject "label",
		lbl_find      = dotNetObject "label",
		lbl_logo = dotNetObject "label", 
		lbl_tools = dotNetObject "label", 
		lbl_paint = dotNetObject "label", 
		lbl_settings = dotNetObject "label", 
		btn_add = dotNetObject "button", 
		btn_del = dotNetObject "button", 
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
--||		
	
--|	--Form actions	
	fn onOpenForm s a = ()
	fn onCloseForm s a = (mcFile.saveIniDialog s "Properties_2" s.name)
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
		
		mcs.lbl_logo.bounds = netDrRect [form_offset, bar_height+form_offset*2] [48, 48]
		mcs.lbl_logo.image = getImage (mcPath()+"Img\\3DGallery_Icon.bmp")
		
		mcs.lblT.bounds = netDrRect [form_offset, form_offset] [form_size.x - form_offset*2-border_size , bar_height]
		mcs.lblT.BackColor = netDrColor clr_back
		mcs.lblT.ForeColor = netDrColor clr_text
		mcs.lblT.Text = " 3DGallery II:  Models  0/0"
		
		mcs.lbl_find.bounds = netDrRect [form_size.x/2 - btn_size/2, bar_height+form_offset*2] [btn_size*2, btn_size]
		mcs.lbl_find.Text = "search:"
		mcs.lbl_find.TextAlign = mcs.lbl_find.TextAlign.MiddleCenter --(dotnetClass "Drawing.ContentAlignment").MiddleCenter
		mcs.lbl_find.BackColor = netDrColor clr_back
		mcs.lbl_find.ForeColor = netDrColor clr_text
		
		mcs.lbl_tools.bounds = netDrRect [form_offset, bar_height+form_offset*2+50] [btn_size*2 , bar_height]
		mcs.lbl_tools.BackColor = netDrColor clr_back
		mcs.lbl_tools.ForeColor = netDrColor clr_text
		mcs.lbl_tools.Text = "Tools: V"

	--	lbl_paint
	--	lbl_settings
		
		mcs.btn_add.bounds = netDrRect [form_offset, bar_height*2+form_offset*2+52] [btn_size, btn_size]
		mcs.btn_add.Text = "+"
		mcs.btn_add.FlatStyle = mcs.btn_add.FlatStyle.flat
		mcs.btn_add.BackColor = netDrColor clr_back
		mcs.btn_add.FlatAppearance.BorderSize = 0
		mcs.btn_add.image = (getIconDotNet 149)
		
		mcs.btn_del.bounds = netDrRect [form_offset+btn_size, bar_height*2+form_offset*2+52] [btn_size, btn_size]
		mcs.btn_del.Text = "-"
		mcs.btn_del.FlatStyle = mcs.btn_del.FlatStyle.flat
		mcs.btn_del.BackColor = netDrColor clr_back
		mcs.btn_del.FlatAppearance.BorderSize = 0
		mcs.btn_del.image = (getIconDotNet 148)
		
		
		
		mcs.toolTip.SetToolTip mcs.btn_add "Add Model"
		mcs.toolTip.SetToolTip mcs.btn_del "Delete Model"
		
		--add handlers
		dotnet.addEventHandler form "Shown" onOpenForm
		dotnet.addEventHandler form "Closed" onCloseForm
		dotnet.addEventHandler form "VisibleChanged" onCloseForm
		--dotNet.addEventHandler form  "MouseMove" drawToForm
		dotNet.addEventHandler mcs.lblT   "MouseMove" onLblTMouseMove
		dotNet.addEventHandler mcs.lblT   "MouseDown" onLblTMouseDown 
		dotNet.addEventHandler mcs.lblT   "MouseUp"   onLblTMouseUp
		
		--add controls
		form.controls.addRange #(mcs.lblT, mcs.lbl_find, mcs.btn_add, mcs.btn_del, mcs.lbl_logo, mcs.lbl_tools)
	)
	inicializeInterface form form.tag.value
	mcDgalleryDialog = form
	mcDgalleryDialog.showModeless()
)