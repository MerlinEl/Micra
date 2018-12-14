Global mcTemplateDialog
if ::mcTemplateDialog != undefined do try(mcTemplateDialog.Close())catch()
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
		netDmPos, --mouse pos on dialog
		form_size        = [746, 516],
		bar_height      = 14,
		border_offset  = 2,
		btn_size         = 24,
		debug = 0,
		-- Custom Properties
		
		-- Default Functions
		fn defNWin = (
			local nw = DotNetObject "NativeWindow"
			nw.AssignHandle (DotNetObject "System.IntPtr" (Windows.GetMaxHWND())) 
			return nw
		),
		fn close = (dia.close()),
		fn onOpenForm s a = (),
		fn onCloseForm s a = (mcFile.saveIniDialog s "Properties_2" s.name),
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
			if mcs.netDMove do mcFormSnap dia mcs.netDmPos
		),
		fn onLblTMouseDown s a = (
				
			dia.cursor.current = netCursors.Hand
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
		
		-- SetUp Interface
		fn init = (
			
			-- Init Maxform
			dotNet.loadAssembly "MaxCustomControls.dll"
			
			form.name = "mcTemplateDialog"
			form.ControlBox  = false --hide main bar
			local fpos = (mcCall.getIniDataFromArray mcTempProfileIni "Properties_2" "mcTemplateDialog" 2) --pick custom fpos
			if fpos == undefined do fpos = (mcCall.getIniDataFromArray mcDefaultProfileIni "Properties_2" "mcTemplateDialog" 2) --pick default fpos
			if fpos == undefined do ( --register new fpos
			
				fpos = [0, 0]
				mcCall.setIniDataToArray mcTempProfileIni "Properties_2" "mcTemplateDialog" 2 fpos 	
				mcCall.setIniDataToArray mcDefaultProfileIni "Properties_2" "mcTemplateDialog" 2 fpos 
			)
			form.StartPosition = form.StartPosition.Manual
			form.bounds = netDrRect fpos form_size
			form.FormBorderStyle = form.FormBorderStyle.none
			form.BackColor = netDrColor (mcUIColors.get #fore)
			form.ShowInTaskbar = false
			form.opacity = 1--(mcUIColors.get #opacity)
			--form.TopMost=true
			
			--toolbar
			lblT.bounds = netDrRect [border_offset, border_offset] [form_size.x - border_offset*10 , bar_height]
			lblT.BackColor = netDrColor (mcUIColors.get #back)
			lblT.ForeColor = netDrColor (mcUIColors.get #text)
			lblT.Text = "Template Dialog:"
			
			--min max button
			btnMin.FlatStyle = btnMin.FlatStyle.flat
			btnMin.BackColor = netDrColor (mcUIColors.get #btn) --(color 124 196 22)
			btnMin.text = "-"
			btnMin.Bounds = netDrRect [form_size.x - (btnMin.width /2) - (border_offset*2) - 1 , border_offset] [btn_size, bar_height]
			
			--Componnts Layout
			tlp.Bounds  = netDrRect [border_offset, bar_height + border_offset * 2] [form_size.x - 20, form_size.y - 36]
			tlp.backColor = netDrColor(mcUIColors.get #btn)
			
			--Custom Components
			--
			
			-- Default Events
			dotnet.addEventHandler form "Shown" onOpenForm
			dotnet.addEventHandler form "Closed" onCloseForm
			dotNet.addEventHandler btnMin "MouseClick" minMaxForm
			dotNet.addEventHandler lblT   "MouseMove" onLblTMouseMove
			dotNet.addEventHandler lblT   "MouseDown" onLblTMouseDown 
			dotNet.addEventHandler lblT   "MouseUp" onLblTMouseUp
			dotnet.AddEventHandler form "BackColorChanged" changeBackcolor --override backcolorchanged event (without this form color is default)
			
			--Custom Events
			--
			
			--Add Controls
			form.controls.addRange ( #(tlp, btnMin, lblT)  )
			--set last position if is stroed at Properties_2
			local dpos   = (mcCall.getIniDataFromArray mcTempProfileIni "Properties_2" "mcIconMakerDialog" 2)
			form.Location = netDrPoint dpos
			-- Shows the form with the specified owner (MAX) to the user (creatd by lo)
			local nw = defNWin()
			form.show(nw) 
			nw.ReleaseHandle()
			--form.showModeless()
			--dotNet.setLifeTimeControl form #dotNet --it�s generally a good idea to let the .NET garbage collector take care of the .NET objects, instead of the Max�s one.
		),
		initIt = init()
	)
	mcTemplateDialog = dotNetFormStruct()
	mcs = mcTemplateDialog --structure shortcut (simplest use)
	dia = mcTemplateDialog.form --form instance
)