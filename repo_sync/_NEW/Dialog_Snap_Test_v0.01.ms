Global mcTemplateDialog
if ::mcTemplateDialog != undefined do try(mcTemplateDialog.Close())catch()
(
	local mcs, dia
	struct dotNetFormStruct (

		-- Default Properties
		form = dotNetObject "MaxCustomControls.Maxform",
		lblT      = dotNetObject "label",
		tlp        = dotNetObject "TableLayoutPanel",
		old_height, 
		minimized = false, 
		netDMove = false, 
		netDmPos, --mouse pos on dialog
		form_size        = [200, 100],
		form_pos        = [400, 200],
		bar_height      = 14,
		border_offset  = 2,
		btn_size         = 24,
		debug = 0,
		-- Custom Properties
		
		-- Custom  Functions
		fn netDrColor clr  = ((dotNetClass "Drawing.Color").fromArgb clr.r clr.g clr.b),
		fn roundToInt num round = (return int((num)/round)*round),
		fn netDrRect pos size   = (dotnetObject "Drawing.Rectangle" pos.x pos.y size.x size.y),
		fn netDrPoint pos       = (dotnetObject "Drawing.Point" pos.x pos.y),
		fn snapForm f pos =
		(
			if classOf f != dotNetObject or pos == undefined do return false
			
			local f_newpos = mouse.screenpos - pos
			--round pos to grid size
			f_newpos.x = roundToInt f_newpos.x 10
			f_newpos.y = roundToInt f_newpos.y 10
			--final move action
			f.location = netDrPoint [f_newpos.x, f_newpos.y]
		),
		-- Default Functions
		fn defNWin = (
			local nw = DotNetObject "NativeWindow"
			nw.AssignHandle (DotNetObject "System.IntPtr" (Windows.GetMaxHWND())) 
			return nw
		),
		fn close = (dia.close()),
		--Move / Snap Dialog
		fn onLblTMouseMove s a = ( --dragForm
			if mcs.netDMove do mcs.snapForm dia mcs.netDmPos
		),
		fn onLblTMouseDown s a = (
				
			if a.Button == a.Button.left do ( --enable drag
				mcs.netDmPos = [dia.MousePosition.x, dia.MousePosition.y] - [dia.left, dia.top] 
				mcs.netDMove = true 
			)
		),
		fn onLblTMouseUp s a = (
			mcs.netDMove = false --disable drag
			if a.Button == a.Button.right then dia.hide()
		),

		-- SetUp Interface
		fn init = (
			
			-- Init Maxform
			dotNet.loadAssembly "MaxCustomControls.dll"
			
			form.name = "mcTemplateDialog"
			form.ControlBox  = false --hide main bar
			form.StartPosition = form.StartPosition.Manual
			form.bounds = netDrRect form_pos form_size
			form.FormBorderStyle = form.FormBorderStyle.none
			form.ShowInTaskbar = false
			form.opacity = 0.8
			
			--toolbar
			lblT.bounds = netDrRect [border_offset, border_offset] [form_size.x - border_offset*10 , bar_height]
			lblT.Text = "Template Dialog:"
			
			--Componnts Layout
			tlp.Bounds  = netDrRect [border_offset, bar_height + border_offset * 2] [form_size.x - 20, form_size.y - 36]
			lblT.BackColor = netDrColor (blue)
			lblT.ForeColor = netDrColor (white)
			--Custom Components
			--
			
			-- Default Events
			dotNet.addEventHandler lblT   "MouseMove" onLblTMouseMove
			dotNet.addEventHandler lblT   "MouseDown" onLblTMouseDown 
			dotNet.addEventHandler lblT   "MouseUp" onLblTMouseUp
			
			--Custom Events
			--
			
			--Add Controls
			form.controls.addRange ( #(tlp, lblT)  )

			-- Shows the form with the specified owner (MAX) to the user (creatd by lo)
			local nw = defNWin()
			form.show(nw) 
			nw.ReleaseHandle()
		),
		initIt = init()
	)
	mcTemplateDialog = dotNetFormStruct()
	mcs = mcTemplateDialog --structure shortcut (simplest use)
	dia = mcTemplateDialog.form --form instance
)