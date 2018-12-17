----------------------
-- DeepIsolate 2 --
---------------------
--    Rene 2012    --

Global mcDeepIsolateDialog
Global mcDeepIsolate
Global mcDeepIsoCallbacks


/*
fn mcDeepIsolate2 lvl:#upper =
(
	fn needCreateDialog = (mcDeepIsolateDialog == undefined or not mcDeepIsolateDialog.isDisplayed)
	--try ( mcDeepIsolateDialog.close() ) catch()
)
*/
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
	local form_opacity = 0.5--execute (mcFile.saveLoadIniSetings head:head_str key:"opacity"  action:#load)
	local bar_height      = 14
	local form_bounds     = 2
	local form_offset     = 2 --border line
	local btn_size        = 24
	local form_size       =[84, 44]
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
		lbl_lvl      = dotNetObject "label",
		btn_min = dotNetObject "button", 
		btn_max = dotNetObject "button", 
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
	
--|	--Form actions	
	fn onOpenForm s a = ()
	fn onCloseForm s a = (mcFile.saveIniDialog s "Properties_2" s.name)
--||
	
	fn inicializeInterface form mcs =
	(
		form.name = "mcDeepIsolateDialog"
		form.ControlBox  = false --hide main bar
		local fpos = (mcCall.getIniDataFromArray mcTempProfileIni "Properties_2" "mcDeepIsolateDialog" 2)
		if fpos == undefined do fpos = (mcCall.getIniDataFromArray mcDefaultProfileIni "Properties_2" "mcDeepIsolateDialog" 2)
		form.StartPosition = form.StartPosition.Manual
		form.FormBorderStyle = form.FormBorderStyle.none
		form.bounds = netDrRect fpos form_size
		form.MinimumSize = netDrSize [btn_size*2, bar_height]
		--form.MaximumSize = netDrSize [btn_size*10, btn_size*10]
		form.BackColor = netDrColor clr_fore
		form.ShowInTaskbar = false
		form.opacity = form_opacity
		
		mcs.lblT.bounds = netDrRect [form_offset, form_offset] [form_size.x - form_offset*2 , bar_height]
		mcs.lblT.BackColor = netDrColor clr_back
		mcs.lblT.ForeColor = netDrColor clr_text
		mcs.lblT.Text = "Deep Isolate II:"
		
		mcs.lbl_lvl.bounds = netDrRect [form_size.x/2 - btn_size/2, bar_height+form_offset*2] [btn_size, btn_size]
		mcs.lbl_lvl.Text = "0"
		mcs.lbl_lvl.TextAlign = mcs.lbl_lvl.TextAlign.MiddleCenter --(dotnetClass "Drawing.ContentAlignment").MiddleCenter
		mcs.lbl_lvl.BackColor = netDrColor clr_back
		mcs.lbl_lvl.ForeColor = netDrColor clr_text
		
		mcs.btn_min.bounds = netDrRect [form_offset, bar_height+form_offset*2] [btn_size, btn_size]
		mcs.btn_min.Text = "<"
		
		mcs.btn_max.bounds = netDrRect [form_size.x - btn_size - form_offset, bar_height+form_offset*2] [btn_size, btn_size]
		mcs.btn_max.Text = ">"
		
		--add handlers
		dotnet.addEventHandler form "Shown" onOpenForm
		dotnet.addEventHandler form "Closed" onCloseForm
		dotnet.addEventHandler form "VisibleChanged" onCloseForm
		--dotNet.addEventHandler form  "MouseMove" drawToForm
		dotNet.addEventHandler mcs.lblT   "MouseMove" onLblTMouseMove
		dotNet.addEventHandler mcs.lblT   "MouseDown" onLblTMouseDown 
		dotNet.addEventHandler mcs.lblT   "MouseUp"   onLblTMouseUp
		
		--add controls
		form.controls.addRange #(mcs.lblT, mcs.lbl_lvl, mcs.btn_min, mcs.btn_max)
	)
	inicializeInterface form form.tag.value
	mcDeepIsolateDialog = form
	mcDeepIsolateDialog.showModeless()
)