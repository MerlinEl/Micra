---TODO finish it
---selected objects are freezed and one Dialog with thumbnail screenshot was created


Global mcHoldSelection
Global mcSelectionHolderCount = 1
(
	--------------------------------------
	
	--Local Variables (Inicializes at Once)
	
	--------------------------------------
	local bar_height      = 14
	local form_bounds     = 2
	local form_offset     = 4
	local btn_size        = 24
	local picture_size    = 128
	local count_limit     = 40
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
	local form_opacity = execute (mcFile.saveLoadIniSetings head:head_str key:"opacity"  action:#load)
	-----------------------------------------
--|
	fn grabImage =
	(
		local img = gw.getViewportDib() 
		local new_img = bitmap picture_size picture_size
		local clipboardClass = dotNetClass "System.Windows.Forms.Clipboard"
		copy img new_img
		setclipboardBitmap new_img
		if clipboardClass.containsimage() 
		then clipboardClass.getImage() 
		else dotNetObject "System.Drawing.Bitmap" picture_size picture_size
	)
	fn getThumbnail =
	(
		--store selection, xray and frozen
		local vis_obj   = for o in Objects where not o.isHidden collect o
		local sel_obj   = #(), unsel_obj = #(), frez_obj  = #()
		for o in vis_obj do 
		(
				 if o.isFrozen   then frez_obj += #(o)
			else if o.isSelected then sel_obj  += #(o) 
			else unsel_obj += #(o)
		)
		max unfreeze all
		--collect non xray objects and make them transparent
		local xray_objs = #()
		for i in (unsel_obj + frez_obj) where not i.xray do
		(
			i.xray = true
			xray_objs += #(i)
		)
		-----------------------
		redrawviews()
		local img = grabImage()
		-----------------------
		--restore selection and xray and frozen objects
		if xray_objs.count != 0 do for i in xray_objs do i.xray = false
		select frez_obj
		max freeze selection
		select sel_obj
		return img
	)
	fn holdSelection s sel = (s.tag.value.objects = sel)
	fn fetchSelection s a = 
	(
		local valid_nodes = for i in s.parent.tag.value.objects where isValidNode i collect i
		select valid_nodes
		max zoomext sel
	)
	fn zoomSelection s a =
	(
		print "double"
	)
--||
--|
	fn resizeInterface form =
	(
		local mcs = form.tag.value
		local table_size = [picture_size, picture_size] * [mcs.columns, mcs.rows]
		local form_size    = table_size + form_offset + [0, bar_height]
		form.size         = netDrSize form_size
		mcs.lblT.Bounds   = netDrRect [form_bounds, form_bounds] [table_size.x - btn_size, bar_height]
		mcs.btnMin.Bounds = netDrRect [table_size.x - btn_size + form_bounds, form_bounds] [btn_size, bar_height]
		mcs.tlp.Bounds    = netDrRect [form_bounds, bar_height + form_bounds] table_size
		mcs.btn.Bounds    = netDrRect [form_bounds, bar_height + form_bounds] table_size
	)
	fn minMaxForm s a form: =
	(
		if form == unsupplied do form = s.parent
		local mcs = form.tag.value
		mcs.minimized = not mcs.minimized

		if mcs.minimized
		then 
		(
			mcs.btnMin.text = "+"
			mcs.old_height = form.height 
			form.height = bar_height + form_bounds*2
			mcs.tlp.hide()
		)
		else
		(
			mcs.btnMin.text = "-"
			form.height = mcs.old_height
			mcs.tlp.show()
		)
	)
	fn onCloseForm s a =
	(
		--print "form closed"
		--format "mcSelectionHolderCount:%\n" mcSelectionHolderCount
		mcSelectionHolderCount -= 1
	)
	fn onOpenForm s a =
	(
		holdSelection s (selection as array)
		--print "form open"
		--format "mcSelectionHolderCount:%\n" mcSelectionHolderCount
		mcSelectionHolderCount += 1
	)
--||
--|	--Form move
	fn onLblTMouseMove s a = 
	(
		local form = s.parent
		if form.tag.value.netDMove do (mcDialog.snapForm form form.tag.value.netDmPos) --dragForm
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
	fn hideForm form = (form.close())
	fn onLblTMouseUp s a = 
	(
		local form = s.parent
		form.tag.value.netDMove = false --disableDrag
		
		case a.button of
		(
			(a.button.right)  : (hideForm form)
			(a.button.left )  : ()
			(a.button.middle) : ()
		)
	)
--||
--|	--Menu
	fn inicializeInterface form  title:"undefined" pos:undefined siz:undefined =
	(
		local mcs = form.tag.value
		--Interface Setup
		form.ControlBox  = false --hide main bar
		form.StartPosition = form.StartPosition.Manual
		form.Location = netDrPoint pos
		form.FormBorderStyle = form.FormBorderStyle.none
		form.BackColor = netDrColor clr_fore --yellow
		form.MinimumSize = netDrSize [btn_size, bar_height]
		form.MaximumSize = netDrSize [btn_size*count_limit, btn_size*count_limit]
		form.ShowInTaskbar = false
		form.opacity = form_opacity

		mcs.lblT.BackColor = netDrColor clr_back --(color 84 132 15)
		mcs.lblT.ForeColor = netDrColor clr_text
		mcs.lblT.text = title

		mcs.btnMin.FlatStyle = mcs.btnMin.FlatStyle.flat
		mcs.btnMin.BackColor = netDrColor clr_btn --(color 124 196 22)
		mcs.btnMin.text = "-"

		mcs.tlp.backColor = netDrColor clr_btn --( green )
		mcs.btn.image = getThumbnail()

		dotNet.addEventHandler mcs.btnMin "MouseClick"   minMaxForm
		dotNet.addEventHandler mcs.lblT   "MouseMove" onLblTMouseMove
		dotNet.addEventHandler mcs.lblT   "MouseDown" onLblTMouseDown 
		dotNet.addEventHandler mcs.lblT   "MouseUp"   onLblTMouseUp --"MouseClick" 
		
		dotnet.addEventHandler form "Closed" onCloseForm
		dotnet.addEventHandler form "Shown" onOpenForm
		
		dotnet.addEventHandler mcs.btn "MouseUp" fetchSelection
		--dotNet.addEventHandler mcs.btn "DoubleClick" zoomSelection
		
		form.controls.addRange(#(mcs.btn, mcs.tlp, mcs.lblT, mcs.btnMin))
	)
	--START BUILDING
	fn mcHoldSelection = 
	(
		try (execute ( dname+".close()" )) catch()
		if selection.count == 0 do return false
		-->Components---------------------------------------------------------------------
		local dname = "mcSelectionHolderDialog" + (mcSelectionHolderCount as string)
		local dtitle = "Selection: " + (mcSelectionHolderCount as string)
		local dpos   = mouse.screenpos
		--format "mouse_pos:%\n" dpos
		local form  = (execute ( dname + "= dotNetObject \"form\" " ) ) --create new form instance
		local cr = [1,1]
		
		struct MICRA_COMPONENTS_STRUCT 
		( 
			ToolTip   = dotNetObject "ToolTip",
			tlp       = dotNetObject "TableLayoutPanel",
			btnMin    = dotNetObject "button",
			lblT      = dotNetObject "label" ,
			lblH      = dotNetObject "label" ,
			lblV      = dotNetObject "label" ,
			btn       = dotNetObject "button",
			columns,
			rows,
			old_height, 
			minimized = false, 
			edit_mode = false, 
			objects=#(), 
			views=#(),
			netDMove = false,
			netDmPos
		)
		
		form.name = dname
		form.tag  = dotNetMXSValue (MICRA_COMPONENTS_STRUCT columns:cr.x rows:cr.y) --Manual Lifetime

		inicializeInterface ( form ) title:dtitle pos:dpos
		resizeInterface     ( form  ) style:#compact
		mcDotnet.dShow form
	)
)