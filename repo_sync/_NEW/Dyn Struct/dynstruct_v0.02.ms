Global mcBaseForm
if ::mcBaseForm != undefined do try(mcBaseForm.Close())catch()
(
	struct NET_FN (
		
		fn netRect pos size   = (dotnetObject "Drawing.Rectangle" pos.x pos.y size.x size.y),
		fn netColor clr       = ((dotNetClass "Drawing.Color").fromArgb clr.r clr.g clr.b)
	)
	local mcs, dia, net = NET_FN()
	local mcs, dia
	struct DOTNET_FORM_BASE (

		-- Default Properties
		form = dotNetObject "MaxCustomControls.Maxform",
		lblT      = dotNetObject "label",
		tlp        = dotNetObject "TableLayoutPanel",
		form_size,
		form_color,
		debug = 0,

		-- Default Functions
		fn maxHW = (
		
			local hv = DotNetObject "NativeWindow"
			hv.AssignHandle (DotNetObject "System.IntPtr" (Windows.GetMaxHWND())) 
			return hv
		),
		fn close = (dia.close()),
		fn changeBackcolor s a = (s.backColor = net.netColor mcs.form_color),

		-- SetUp Interface
		fn init pos:[400, 350] size:[350, 250] backcolor:yellow title:"Max Form" = (
			
			form_size = size
			form_color = backcolor
			
			form.text = title
			form.StartPosition = form.StartPosition.Manual
			form.bounds = net.netRect pos size
			
			-- Default Events
			dotnet.AddEventHandler form "BackColorChanged" changeBackcolor --override backcolorchanged event (without this form color is default)
			
			local hv = maxHW ()
			form.show(hv) -- Shows the form with the specified owner (MAX) to the user (creatd by lo)
			hv.ReleaseHandle()
			OK
		),
		initIt = init pos:[400, 350] size:[350, 250] title:"My Form 1 v0.01"
	)
	mcBaseForm = DOTNET_FORM_BASE()
	mcs = mcBaseForm --structure shortcut (simplest use)
	dia = mcBaseForm.form --form instance
)



Global mcCompactForm
if ::mcCompactForm != undefined do try(mcCompactForm.Close())catch()
(
	struct NET_FN (
		
		fn netRect pos size   = (dotnetObject "Drawing.Rectangle" pos.x pos.y size.x size.y),
		fn netColor clr       = ((dotNetClass "Drawing.Color").fromArgb clr.r clr.g clr.b),
		fn mcFormSnap form pos = (
			
			local newpos = mouse.screenpos - pos
			local net_pos =  dotnetObject "Drawing.Point" newpos.x newpos.y
			form.location = net_pos
		)
	)
	local mcs, dia, net = NET_FN()
	struct DOTNET_FORM_BASE (

		-- Default Properties
		form = dotNetObject "MaxCustomControls.Maxform",
		lblT      = dotNetObject "label",
		tlp        = dotNetObject "TableLayoutPanel",
		netDmPos, --mouse pos on dialog
		form_size,
		form_color,
		bar_height      = 14,
		border_offset  = 2,
		debug = 0,

		-- Default Functions
		fn maxHW = (
		
			local hv = DotNetObject "NativeWindow"
			hv.AssignHandle (DotNetObject "System.IntPtr" (Windows.GetMaxHWND())) 
			return hv
		),
		fn close = (dia.close()),
		fn changeBackcolor s a = (s.backColor = net.netColor mcs.form_color),
		--Move / Snap Dialog
		fn onLblTMouseMove s a = ( if a.Button == a.Button.left do  net.mcFormSnap dia mcs.netDmPos), --drag form
		fn onLblTMouseDown s a = ( --start drag
				
			dia.cursor.current = netCursors.Hand
			if a.Button == a.Button.left do ( --enable drag
				mcs.netDmPos = [dia.MousePosition.x, dia.MousePosition.y] - [dia.left, dia.top]  
			)
		),
		fn onLblTMouseUp s a = (if a.Button == a.Button.right then mcs.close()), --stop drag or close
		-- Custom  Functions
		
		-- SetUp Interface
		fn init pos:[400, 350] size:[350, 250] backcolor:yellow forecolor:white toolbarcolor:blue title:"Max Form" = (
			
			form_size = size
			form_color = backcolor
			
			form.text = title
			form.ControlBox  = false --hide main bar
			form.ShowInTaskbar = false
			form.StartPosition = form.StartPosition.Manual
			form.bounds = net.netRect pos size
			form.FormBorderStyle = form.FormBorderStyle.none
			form.BackColor = net.netColor backcolor
			form.opacity = 1
			
			--toolbar
			lblT.bounds = net.netRect [border_offset, border_offset] [form_size.x - border_offset*10 , bar_height]
			lblT.BackColor = net.netColor toolbarcolor
			lblT.ForeColor = net.netColor forecolor
			lblT.Text = title
		
			--Componnts Layout
			tlp.Bounds  = net.netRect [border_offset, bar_height + border_offset * 2] [form_size.x - 20, form_size.y - 36]
			tlp.backColor = net.netColor backcolor
			
			-- Default Events
			dotNet.addEventHandler lblT   "MouseMove" onLblTMouseMove
			dotNet.addEventHandler lblT   "MouseDown" onLblTMouseDown 
			dotNet.addEventHandler lblT   "MouseUp" onLblTMouseUp
			dotnet.AddEventHandler form "BackColorChanged" changeBackcolor --override backcolorchanged event (without this form color is default)
			
			--Add Controls
			form.controls.addRange ( #(tlp, lblT)  )
			local hv = maxHW ()
			form.show(hv) -- Shows the form with the specified owner (MAX) to the user (creatd by lo)
			hv.ReleaseHandle()
			OK
		),
		initIt = init pos: [800, 350] size:[350, 250] title:"My Form 2 v0.01"
	)
	mcCompactForm = DOTNET_FORM_BASE()
	mcs = mcCompactForm --structure shortcut (simplest use)
	dia = mcCompactForm.form --form instance
)