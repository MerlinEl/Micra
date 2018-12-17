/*
rollout unnamedRollout "Untitled" width:236 height:88
(
	??? cust1 "???" pos:[44,8] width:188 height:16
	??? cust2 "???" pos:[44,28] width:188 height:16
	??? cust3 "???" pos:[44,48] width:188 height:16
	label lbl1 "R G B :" pos:[4,8] width:32 height:16
	label lbl2 "CONT:" pos:[4,28] width:36 height:16
	label lbl3 "LIGHT:" pos:[4,48] width:36 height:16
	colorPicker cp1 "ColorPicker" pos:[4,68] width:40 height:16
	colorPicker cp2 "ColorPicker" pos:[40,68] width:44 height:16 color:(color 0 0 155)
	button btn1 "Reset" pos:[88,68] width:48 height:16
	button btn2 "Add" pos:[136,68] width:48 height:16
	button btn3 "Close" pos:[184,68] width:48 height:16
)
*/

--Customize Micra
Global mcQuickColorPickerDialog --mcQuickColorPickerDialog

-->Micra Interface
try ( mcQuickColorPickerDialog.close() ) catch()
(
	-->Locals-----------------------------------------------------------------
	local clr_back     = execute (mcFile.saveLoadIniSetings head:"InterfaceColor" key:"backcolor" action:#load)
	local clr_fore     = execute (mcFile.saveLoadIniSetings head:"InterfaceColor" key:"forecolor" action:#load)
	local clr_btn      = execute (mcFile.saveLoadIniSetings head:"InterfaceColor" key:"button"   action:#load)
	local clr_sel      = execute (mcFile.saveLoadIniSetings head:"InterfaceColor" key:"selected"  action:#load)
	local clr_mark     = execute (mcFile.saveLoadIniSetings head:"InterfaceColor" key:"marked"  action:#load)
	local clr_inact    = execute (mcFile.saveLoadIniSetings head:"InterfaceColor" key:"inactive"  action:#load)
	local clr_text     = execute (mcFile.saveLoadIniSetings head:"InterfaceColor" key:"textcolor"  action:#load)
	local clr_seltext  = execute (mcFile.saveLoadIniSetings head:"InterfaceColor" key:"seltext"  action:#load)
	local form_opacity = execute (mcFile.saveLoadIniSetings head:"InterfaceColor" key:"opacity"  action:#load)
	local bar_height      = 14
	local form_bounds     = 2
	local form_offset     = 4
	local btn_size        = 24
	local form_size       =[203, 90]
	local cp_width        = 48
	local debug = 0
	-->Components---------------------------------------------------------------------
	local form = dotNetObject "Form" 
	struct MICRA_COMPONENTS_STRUCT
	(
		--variables
		lblT   = dotNetObject "label" ,
		
		lblRGB = dotNetObject "label" ,
		lblSAT = dotNetObject "label" ,
		lblBRI = dotNetObject "label" ,
		sldRGB = dotNetObject "label", 
		sldSAT = dotNetObject "label", 
		sldBRI = dotNetObject "label",
		
		tlp    = dotNetObject "TableLayoutPanel",
		tab    = dotNetObject "TableLayoutPanel",
		buttons = #(),
		netDMove = false, 
		netDmPos
		--interface
	)
	
	form.tag = dotNetMXSValue (MICRA_COMPONENTS_STRUCT()) --manual Lifetime	
	
	fn onCloseForm s a = (mcFile.saveIniDialog s "Properties_2" s.name)
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
	fn drawMarker lbl posX =
	(
		local gra = lbl.CreateGraphics()
		gra.clear (netDrColor yellow)
		local fillBrush = dotnetobject "System.Drawing.SolidBrush" (netDrColor clr_fore)
		local fillColor = netDrColor clr_back
		local rect = (dotnetobject "System.Drawing.Rectangle" (posX-4) 0 4 bar_height)
		
		gra.FillRectangle fillBrush rect
		(dotnetclass "ControlPaint").DrawBorder gra rect fillColor (dotnetclass "ButtonBorderStyle").Solid	
	)
	fn onPaintLabels s a =
	(
		local slider_center = 180/2
		local fillBrush = dotnetobject "System.Drawing.SolidBrush" (netDrColor clr_fore)
		local fillColor = netDrColor clr_back
		local rect = (dotnetobject "System.Drawing.Rectangle" (slider_center-4) 0 4 bar_height)
		
		a.graphics.FillRectangle fillBrush rect
		(dotnetclass "ControlPaint").DrawBorder a.graphics rect fillColor (dotnetclass "ButtonBorderStyle").Solid	
	)
	fn onSldMouseDown s a = s.tag = true
	fn onSldMouseUp s a = s.tag = false
	fn onSldMouseMove s a =
	(
		if s.tag and a.x >= 0 and a.x <= 180 do 
		(
			if a.x > 2 do drawMarker s a.x
		)
	)
	fn addSliders form mcs = 
	(
		local txt = #("H:", "S:", "B:")
		local lbl = #(mcs.lblRGB, mcs.lblSAT, mcs.lblBRI)
		local sld = #(mcs.sldRGB, mcs.sldSAT, mcs.sldBRI)
		for i = 1 to txt.count do
		(
			lbl[i].text = txt[i]
			lbl[i].size = netDrSize [15, bar_height]
			lbl[i].margin  =  dotnetobject "padding" 1
			lbl[i].backColor = netDrColor green
			
			sld[i].name = txt[i]
			sld[i].size = netDrSize [180, bar_height]
			sld[i].margin  =  dotnetobject "padding" 1
			sld[i].backColor = netDrColor yellow
			sld[i].tag = false	
			
			dotNet.addEventHandler sld[i] "MouseUp"   onSldMouseUp
			dotNet.addEventHandler sld[i] "MouseDown" onSldMouseDown
			dotNet.addEventHandler sld[i] "MouseMove" onSldMouseMove
			dotNet.addEventHandler sld[i] "Paint" onPaintLabels
		)
		mcs.tlp.controls.addRange ( #(mcs.lblRGB, mcs.sldRGB, mcs.lblSAT, mcs.sldSAT, mcs.lblBRI, mcs.sldBRI) )
	)
	fn onBtnMouseUp s a = 
	(
		local form = s.parent.parent
		local mcs  = form.tag.value
		case s.text of
		(
			"Accept":form.close()
			"Reset" : 
			(
				local sld = #(mcs.sldRGB, mcs.sldSAT, mcs.sldBRI)
				for s in sld do drawMarker s ( ( 180/2)-2 ) 
			)
			"Cancel": form.close()
		)
	)
	fn addButons form mcs = 
	(
		local tab_text_array = #("Accept", "Reset", "Cancel")
		for i = 1 to tab_text_array.count do
		(
			local b = dotNetObject "Button"
			b.size  = netDrSize [66, 20]
			b.FlatStyle = b.FlatStyle.flat
			b.FlatAppearance.BorderColor = netDrColor clr_back		
			b.Forecolor = netDrColor clr_text
			b.FlatAppearance.BorderSize = 1
			b.margin =  dotnetobject "padding" 0
			b.name = "btn_"+((i as integer) as string)
			b.text = tab_text_array[i]
			b.tag = i
			dotNet.addEventHandler b "MouseUp" onBtnMouseUp
			mcs.buttons += #(b)
		)
		mcs.tab.controls.addRange (mcs.buttons)
	)
	fn inicializeInterface form mcs =
	(
		form.name = "mcQuickColorPickerDialog"
		form.ControlBox  = false --hide main bar
		local fpos = (mcCall.getIniDataFromArray mcTempProfileIni "Properties_2" "mcQuickColorPickerDialog" 2)
		if fpos == undefined do fpos = (mcCall.getIniDataFromArray mcDefaultProfileIni "Properties_2" "mcQuickColorPickerDialog" 2)
		form.StartPosition = form.StartPosition.Manual
		form.bounds = netDrRect fpos form_size
		form.FormBorderStyle = form.FormBorderStyle.none
		form.BackColor = netDrColor clr_fore --yellow
		form.ShowInTaskbar = false
		form.opacity = form_opacity
		
		mcs.lblT.bounds = netDrRect [form_offset/2, form_offset/2] [form_size.x - form_offset, bar_height]
		mcs.lblT.BackColor = netDrColor clr_back
		mcs.lblT.ForeColor = netDrColor clr_text
		mcs.lblT.Text = "Color Picker:"
		
		mcs.tlp.bounds = netDrRect [form_offset/2, bar_height+form_offset] [form_size.x - form_offset, bar_height*3+form_bounds*3]
		mcs.tlp.backColor = netDrColor clr_btn
		mcs.tlp.ColumnCount = 2
		mcs.tlp.RowCount = 3
		
		mcs.tab.bounds = netDrRect [form_offset/2, bar_height*4+form_offset*3] [form_size.x - form_offset, 20]
		mcs.tab.backColor = netDrColor clr_btn
		mcs.tab.ColumnCount = 3
		
		dotNet.addEventHandler mcs.lblT   "MouseMove" onLblTMouseMove
		dotNet.addEventHandler mcs.lblT   "MouseDown" onLblTMouseDown 
		dotNet.addEventHandler mcs.lblT   "MouseUp"   onLblTMouseUp
		
		dotnet.addEventHandler form "Closed" onCloseForm
		dotnet.addEventHandler form "VisibleChanged" onCloseForm
		
		addSliders form mcs
		addButons form mcs
		
		form.controls.addRange( #(mcs.lblT, mcs.tlp, mcs.tab ) )
	)
	inicializeInterface form form.tag.value
	mcQuickColorPickerDialog = form
	mcQuickColorPickerDialog.show(WindowWrapper)
)