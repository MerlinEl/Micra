 dotnet radiobutton with the appearance set to button can be used like tabs
	 
 
 
 
 
 		btn_brush = dotNetObject "radioButton", 
		btn_line = dotNetObject "radioButton", 
		btn_fill = dotNetObject "radioButton", 
 
 
 		mcs.btn_brush.bounds = netDrRect  [8,420] [52, 26]
		mcs.btn_line.bounds = netDrRect  [68,420] [52, 26]
		mcs.btn_fill.bounds = netDrRect  [128,420] [52, 26]
		mcs.btn_cross.bounds = netDrRect  [188,420] [52, 26]
		mcs.btn_brush.text =  "Brush"
		mcs.btn_line.text = "Line"
		mcs.btn_fill.text = "Fill"
		mcs.btn_cross.text = "Cross"
		mcs.btn_brush.Checked = true
	 
 