Global mcColorPickerDialog
/*
MerlinEl 2018
Accessible Events:
		mcEvents.registerEvent "COLOR_PICKER_ADD_COLOR" setButtonColor
		mcEvents.registerEvent "COLOR_PICKER_MOD_COLOR" changeObjectsWire
*/

if ::mcColorPickerDialog != undefined do try(mcColorPickerDialog.Close())catch()
if doesFileExist (Micra.RootDir+"Img\\ColorBySat.png") and doesFileExist (Micra.RootDir+"Img\\ColorByVal.png")  do (
	local mcs, dia
	struct dotNetFormStruct (

		-- Default Properties
		form = dotNetObject "MaxCustomControls.Maxform",
		lblT   = dotNetObject "label",
		btnMin  = dotNetObject "button",
		btnHelp  = dotNetObject "button",
		tlp        = dotNetObject "TableLayoutPanel", --buttons Background
		HueBitmap = dotNetObject "picturebox",
		oldColorBt = dotNetObject  "label",
		newColorBt = dotNetObject  "label",
		btnAdd  = dotNetObject "button",
		btnReset  = dotNetObject "button",
		btnClose  = dotNetObject "button",
		lbl1 = dotNetObject "label",
		lbl2 = dotNetObject "label",
		lbl3 = dotNetObject "label",
		lbl4 = dotNetObject "label",
		lbl5 = dotNetObject "label",
		lbl6 = dotNetObject "label",
		lbl7 = dotNetObject "label",
		spnR = dotNetObject "NumericUpDown",
		spnG = dotNetObject "NumericUpDown",
		spnB = dotNetObject "NumericUpDown",
		spnH = dotNetObject "NumericUpDown",
		spnS = dotNetObject "NumericUpDown",
		spnV = dotNetObject "NumericUpDown",
		edt_hex = dotNetObject "textbox",
		old_height, 
		oldColor,
		active_image_index = 1,
		minimized = false, 
		netDmPos, --mouse pos on dialog
		form_size        = [344, 292],
		bar_height      = 14,
		border_offset  = 2,
		btn_size         = 24,
		debug = 0,
		-- Custom Properties
		
		-- Custom Functions
		fn sendColor s a = (mcEvents.dispatchEvent "COLOR_PICKER_ADD_COLOR" data:mcs.newColorBt.backColor),
		fn colorChanged net_clr =  (mcEvents.dispatchEvent "COLOR_PICKER_MOD_COLOR" data:net_clr),
		fn updateRGBHSVSpinners col = 
		(
			spnR.value = col.r
			spnG.value = col.g
			spnB.value = col.b
			spnH.value = col.h
			spnS.value = col.s
			spnV.value = col.v 
		),
		fn onChangedRGBHSV s a = (
			
			local newColor = netColorToRGB mcs.newColorBt.backColor
			case s.name of
			(
				"R":newColor.r = s.value
				"G":newColor.g = s.value
				"B":newColor.b = s.value
				"H":newColor.h = s.value
				"S":newColor.s = s.value
				"V":newColor.v = s.value
			)
			mcs.newColorBt.backColor = netDrColor newColor
			mcs.edt_hex.text = mcColor.rgbToHex newColor
			mcs.updateRGBHSVSpinners newColor
			mcs.colorChanged (netDrColor newColor)
		),
		fn onHexChanged s a = (
			
			local hex = s.text
			if hex.count != 6 do return ok
			local clr = mcColor.hexToRGB hex
			mcs.newColorBt.backColor = netDrColor clr	
			mcs.updateRGBHSVSpinners clr
			mcs.colorChanged (netDrColor clr)
		),
		fn setColor net_clr = (
			
			mcs.newColorBt.backColor = mcs.oldColorBt.backColor = net_clr
			mcs.oldColor = net_clr	
		),
		fn setBackColor net_clr = (
			
			mcs.oldColorBt.backColor = net_clr
			mcs.oldColor = net_clr	
		),
		fn resetColor =
		(
			mcs.newColorBt.backColor = mcs.oldColor
			mcs.edt_hex.text = mcColor.rgbToHex (netColorToRGB mcs.oldColor)
			mcs.updateRGBHSVSpinners (netColorToRGB mcs.OldColor)
			mcs.colorChanged mcs.OldColor
		),
		fn isPosInRect pos rect = 
		(					
			return (pos.x>=rect.LT.x and pos.y>=rect.LT.y and pos.x<=rect.RD.x and pos.y<=rect.RD.x)
		),
		fn loadImage = 
		(
			if btswitch.state == 1 
			then openBitmap (Micra.RootDir+"Img\\ColorBySat.png") 
			else openBitmap (Micra.RootDir+"Img\\ColorByVal.png")
		),
		fn getPixelsFromImage s a =
		(
			--format "x:%\ty:%\n" a.x a.y
			if a.x > 255 or a.x < 0 or a.y > 255 or a.y < 0  --if is out of bounds
			then (
				
				s.cursor.current = netCursors.Arrow
			) else (
				s.cursor.current = netCursors.Cross
				
				local clr =  s.Image.GetPixel a.x a.y
				if clr != undefined do
				(
					newColorBt.backColor = clr
					edt_hex.text = mcColor.rgbToHex (netColorToRGB clr)
					updateRGBHSVSpinners (netColorToRGB clr)
					mcs.colorChanged clr
				)
			)
		),
		fn onMouseMove s a =
		(
			case a.button of
			(
				(a.button.left) : (mcs.getPixelsFromImage s a)
			)
		),
		fn onMouseDown s a =
		(
			case a.button of
			(
				(a.button.left) : (mcs.getPixelsFromImage s a)
			)
		),
		fn onMouseUp s a =
		(
			if a.Button == a.Button.right then (
					
				if mcs.active_image_index == 1 then mcs.active_image_index = 2 else mcs.active_image_index = 1
				mcs.HueBitmap.Image = mcs.loadCPImage mcs.active_image_index
					print "swap"
			)
		),
		fn loadCPImage type =
		(
			local fpath = Micra.RootDir + "Img\\" + 
			(
				case type of
				(
					1:"ColorBySat.png"
					2:"ColorByVal.png"
				)
			)
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
		),
		-- Default Functions
		fn visible = (dia.visible),
		fn close = (dia.close()),
		fn onOpenForm s a = (
			
			mcs.HueBitmap.Image = mcs.loadCPImage mcs.active_image_index
			local start_color = mcGM.getParam "color_picker_start_color"
			if start_color == undefined then start_color = netDrColor white
			mcs.oldColor = mcs.newColorBt.backColor = mcs.oldColorBt.backColor = start_color
			mcs.edt_hex.text = mcColor.rgbToHex (netColorToRGB mcs.oldColor)
			mcs.updateRGBHSVSpinners (netColorToRGB mcs.oldColor)
		),
		fn onCloseForm s a = (mcFile.saveDialogSettings s.name "Properties_2"),
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
		fn showHelp = (
			
			::mcPopUp2.show ">< To change image press Mouse RC. >< " delay:2000 --title:"Help:"
		),
		--Move / Snap Dialog
		fn onLblTMouseMove s a = ( if a.Button == a.Button.left do  mcDialog.snapForm dia mcs.netDmPos), --drag form
		fn onLblTMouseDown s a = ( --start drag
				
			dia.cursor.current = netCursors.Hand
			if a.Button == a.Button.left do ( --enable drag
				mcs.netDmPos = [dia.MousePosition.x, dia.MousePosition.y] - [dia.left, dia.top]  
			)
		),
		fn onLblTMouseUp s a = (if a.Button == a.Button.right then mcs.close()), --stop drag or close
		-- Custom  Functions
		
		-- SetUp Interface
		fn init form_name = (
			
			-- Init Maxform
			dotNet.loadAssembly "MaxCustomControls.dll"
			
			form.name = form_name
			form.ControlBox  = false --hide main bar
			local fpos = execute (mcFile.readSettings Micra.UserProfile "Properties_2/mcCustomizeDialog" type:"pos")
			if classOf fpos != Point2 do fpos = [0, 0] --set pos to zero (register nfter dialog close
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
			lblT.Text = "Color Picker v" + (mcFile.getScriptVersion "Color_Picker") --update script title with version
			
			--min max button
			btnMin.FlatStyle = btnMin.FlatStyle.flat
			btnMin.BackColor = netDrColor (mcUIColors.get #btn)
			btnMin.ForeColor = netDrColor (mcUIColors.get #text)
			btnMin.text = "-"
			btnMin.Bounds = netDrRect [form_size.x - (btnMin.width /2) - (border_offset*2) - 1 , border_offset] [btn_size, bar_height]
			
			--help button
			btnHelp.FlatStyle = btnMin.FlatStyle.flat
			btnHelp.BackColor = netDrColor (mcUIColors.get #btn)
			btnHelp.ForeColor = netDrColor (mcUIColors.get #text)
			btnHelp.text = "^"
			btnHelp.TextAlign = btnHelp.TextAlign.TopCenter 
			btnHelp.Bounds = netDrRect [form_size.x - btnHelp.width + 8 , border_offset] [btn_size, bar_height]
			
			
			--Componnts Layout
			tlp.Bounds  = netDrRect [form_size.x - 84, bar_height + border_offset * 2] [66, form_size.y - 100]
			tlp.backColor = netDrColor(mcUIColors.get #btn)
			
			--Custom Components
			HueBitmap.Bounds  = netDrRect [border_offset, bar_height + border_offset * 2] [258, form_size.y]

			lbl1.Bounds  = netDrRect [form_size.x -  82,22] [12, 16]
			lbl1.BackColor = netDrColor (mcUIColors.get #back)
			lbl1.ForeColor = netDrColor (mcUIColors.get #text)
			lbl1.text = "R" 
			
			lbl2.Bounds  = netDrRect [form_size.x -  82,42] [12, 16]
			lbl2.BackColor = netDrColor (mcUIColors.get #back)
			lbl2.ForeColor = netDrColor (mcUIColors.get #text)
			lbl2.text = "G" 
			
			lbl3.Bounds  = netDrRect [form_size.x -  82,62] [12, 16]
			lbl3.BackColor = netDrColor (mcUIColors.get #back)
			lbl3.ForeColor = netDrColor (mcUIColors.get #text)	
			lbl3.text = "B" 	
			
			lbl4.Bounds  = netDrRect [form_size.x -  82,84] [12, 16]
			lbl4.BackColor = netDrColor (mcUIColors.get #back)
			lbl4.ForeColor = netDrColor (mcUIColors.get #text)
			lbl4.text = "H" 			
			
			lbl5.Bounds  = netDrRect [form_size.x - 82,104] [12, 16]
			lbl5.BackColor = netDrColor (mcUIColors.get #back)
			lbl5.ForeColor = netDrColor (mcUIColors.get #text)
			lbl5.text = "S" 
			
			lbl6.Bounds  = netDrRect [form_size.x -  82,124] [12, 16]
			lbl6.BackColor = netDrColor (mcUIColors.get #back)
			lbl6.ForeColor = netDrColor (mcUIColors.get #text)
			lbl6.text = "V" 
			
			spnR.Bounds  = netDrRect [form_size.x - 66,20] [46, 16]
			spnR.BackColor = netDrColor (mcUIColors.get #edtback)
			spnR.ForeColor = netDrColor (mcUIColors.get #edtfore)	
						spnR.Increment=1
			spnR.maximum=255
			spnR.minimum=0
			spnR.value=0
			spnR.name = "R"
		
			spnG.Bounds  = netDrRect [form_size.x - 66,40] [46, 16]
			spnG.BackColor = netDrColor (mcUIColors.get #edtback)
			spnG.ForeColor = netDrColor (mcUIColors.get #edtfore)	
						spnR.Increment=1
			spnG.maximum=255
			spnG.minimum=0
			spnG.value=0
			spnG.name = "G"

			spnB.Bounds  = netDrRect [form_size.x - 66,60] [46, 16]
			spnB.BackColor = netDrColor (mcUIColors.get #edtback)
			spnB.ForeColor = netDrColor (mcUIColors.get #edtfore)	
						spnR.Increment=1
			spnB.maximum=255
			spnB.minimum=0
			spnB.value=0
			spnB.name = "B"

			spnH.Bounds  = netDrRect [form_size.x - 66,82] [46, 16]
			spnH.BackColor = netDrColor (mcUIColors.get #edtback)
			spnH.ForeColor = netDrColor (mcUIColors.get #edtfore)	
						spnR.Increment=1
			spnH.maximum=255
			spnH.minimum=0
			spnH.value=0
			spnH.name = "H"

			spnS.Bounds  = netDrRect [form_size.x - 66,102] [46, 16]
			spnS.BackColor = netDrColor (mcUIColors.get #edtback)
			spnS.ForeColor = netDrColor (mcUIColors.get #edtfore)	
						spnR.Increment=1
			spnS.maximum=255
			spnS.minimum=0
			spnS.value=0
			spnS.name = "S"

			spnV.Bounds  = netDrRect [form_size.x - 66,122] [46, 16]
			spnV.BackColor = netDrColor (mcUIColors.get #edtback)
			spnV.ForeColor = netDrColor (mcUIColors.get #edtfore)	
						spnR.Increment=1
			spnV.maximum=255
			spnV.minimum=0
			spnV.value=0
			spnV.name = "V"
		
			lbl7.Bounds  = netDrRect [form_size.x -  82,147] [12, 16]
			lbl7.BackColor = netDrColor (mcUIColors.get #back)
			lbl7.ForeColor = netDrColor (mcUIColors.get #text)
			lbl7.text = "#" 
			
			edt_hex.Bounds  = netDrRect [form_size.x - 66,145] [46, 16]
			edt_hex.BackColor = netDrColor (mcUIColors.get #edtback)
			edt_hex.ForeColor = netDrColor (mcUIColors.get #edtfore)	
			
			newColorBt.Bounds  = netDrRect [form_size.x - 82,168] [62, 18]
			newColorBt.BackColor = netDrColor (mcUIColors.get #back)
			newColorBt.BorderStyle = newColorBt.BorderStyle.FixedSingle

			oldColorBt.Bounds  = netDrRect [form_size.x - 82,187] [62, 18]
			oldColorBt.BackColor = netDrColor (mcUIColors.get #back)
			oldColorBt.BorderStyle = newColorBt.BorderStyle.FixedSingle
			
			btnReset.FlatStyle = btnReset.FlatStyle.flat
			btnReset.Bounds  = netDrRect [form_size.x - 84,207] [66, 21]
			btnReset.BackColor = netDrColor (mcUIColors.get #back)
			btnReset.ForeColor = netDrColor (mcUIColors.get #text)
			btnReset.text = "Reset" 
			
			btnAdd.FlatStyle = btnAdd.FlatStyle.flat
			btnAdd.Bounds = netDrRect [form_size.x - 84,230] [66, 21]
			btnAdd.BackColor = netDrColor (mcUIColors.get #back)
			btnAdd.ForeColor = netDrColor (mcUIColors.get #text)
			btnAdd.text = "Add"
			
			btnClose.FlatStyle = btnClose.FlatStyle.flat
			btnClose.Bounds  = netDrRect [form_size.x - 84,253] [66, 21]
			btnClose.BackColor = netDrColor (mcUIColors.get #back)
			btnClose.ForeColor = netDrColor (mcUIColors.get #text)
			btnClose.text = "Close" 
			
			-- Default Events
			dotnet.addEventHandler form "Shown" onOpenForm
			dotnet.addEventHandler form "Closed" onCloseForm
			dotNet.addEventHandler btnMin "MouseClick" minMaxForm
			dotNet.addEventHandler btnHelp "MouseUp" showHelp
			dotNet.addEventHandler lblT   "MouseMove" onLblTMouseMove
			dotNet.addEventHandler lblT   "MouseDown" onLblTMouseDown 
			dotNet.addEventHandler lblT   "MouseUp" onLblTMouseUp
			dotnet.AddEventHandler form "BackColorChanged" changeBackcolor --override backcolorchanged event (without this form color is default)
			
			--Custom Events
			dotnet.addEventHandler spnR "MouseUp" onChangedRGBHSV
			dotnet.addEventHandler spnG "MouseUp" onChangedRGBHSV
			dotnet.addEventHandler spnB "MouseUp" onChangedRGBHSV
			dotnet.addEventHandler spnH "MouseUp" onChangedRGBHSV
			dotnet.addEventHandler spnS "MouseUp" onChangedRGBHSV
			dotnet.addEventHandler spnV "MouseUp" onChangedRGBHSV
			
			dotnet.addEventHandler spnR "KeyUp" onChangedRGBHSV
			dotnet.addEventHandler spnG "KeyUp" onChangedRGBHSV
			dotnet.addEventHandler spnB "KeyUp" onChangedRGBHSV
			dotnet.addEventHandler spnH "KeyUp" onChangedRGBHSV
			dotnet.addEventHandler spnS "KeyUp" onChangedRGBHSV
			dotnet.addEventHandler spnV "KeyUp" onChangedRGBHSV
			
			dotnet.addEventHandler btnAdd   "MouseUp" sendColor
			dotnet.addEventHandler btnReset "MouseUp" resetColor
			dotnet.addEventHandler btnClose "MouseUp" close
			
			dotnet.addEventHandler HueBitmap "MouseMove" onMouseMove
			dotnet.addEventHandler HueBitmap "MouseDown" onMouseDown
			dotnet.addEventHandler HueBitmap "MouseUp"  onMouseUp
			dotnet.addEventHandler edt_hex "KeyUp" onHexChanged
			
			--Add Controls
			form.controls.addRange ( #(btnAdd, btnReset, btnClose, oldColorBt, newColorBt, spnR, spnG, spnB, spnH, spnS, spnV, edt_hex, lbl1, lbl2, lbl3, lbl4, lbl5, lbl6, lbl7, tlp,HueBitmap, btnMin, btnHelp, lblT)  )
			mcDotnet.dShow form
			OK
		),
		initIt = init "mcColorPickerDialog"
	)
	mcColorPickerDialog = dotNetFormStruct()
	mcs = mcColorPickerDialog --structure shortcut (simplest use)
	dia = mcColorPickerDialog.form --form instance
)