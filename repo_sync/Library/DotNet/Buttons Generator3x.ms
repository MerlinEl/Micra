Global mc2DialogCreator
try(destroyDialog mc2DialogCreator)catch()
rollout mc2DialogCreator "Dialog Creator:" width:324 height:260
(
	local button_size = 40, top_offset = 10, diaSize = [324, 260]
	dotNetControl lp "TableLayoutPanel" pos:[0,0] width:diaSize.x height:diaSize.y
	fn netDrSize size     = (dotNetObject "Drawing.Size" size.x size.y)
	fn netDrColor clr     = ((dotNetClass "Drawing.color").fromArgb clr.r clr.g clr.b)
	fn OnButtonClick send arg = 
	(
		format "send:%\targ:%\nbtn_name:%\tbtn_tag:%\n" send arg send.text send.tag
		lp.layoutSettings.RowCount += 1
 		lp.layoutSettings.ColumnCount += 1
		--destroyDialog mc2DialogCreator
	)
	fn manageInterface size =
	(
		lp.width = size.x
		lp.height = size.y - top_offset 
		
		--mc2DialogCreator.width  = (lp.layoutSettings.ColumnCount*button_size)
 		--mc2DialogCreator.height = (lp.layoutSettings.RowCount*button_size   ) + 40
	)
	fn addButton int =
	(
		local btn = (dotNetObject "Button")
		btn.size = netDrSize [button_size, button_size]
		btn.flatstyle = (dotNetclass "FlatStyle").flat
		btn.margin =  dotnetobject "padding" 0
		btn.Text = (int as integer) as string
		dotNet.addEventHandler btn "Click" OnButtonClick -- Setup an event handler for buttons
		btn
	)
	fn generateButtons columns rows =
	(
		lp.controls.clear()
		local cnt = 0
		for x = 0 to rows - 1 do
			for y = 0 to columns - 1 do
				lp.Controls.Add (addButton (cnt +=1)) y x
	)
	fn initializeInterface =
	(
		local columns = diaSize.x  / button_size
		local rows = diaSize.y / button_size
		local buttons_count = rows * columns
		
		lp.layoutSettings.RowCount = rows
 		lp.layoutSettings.ColumnCount = columns
		
		lp.backColor = netDrColor( orange ) --form Back Color
		lp.Padding = dotNetObject "Padding" 2 --panel left up offset
		lp.Top = top_offset
		lp.BorderStyle = (dotNetClass "BorderStyle").None	
		lp.width = diaSize.x
		lp.height = diaSize.y - top_offset 
		lp.AllowDrop = true
		lp.AutoSize = true
		lp.autoscroll = true
		generateButtons columns rows
	)
	on mc2DialogCreator open do initializeInterface()
	on mc2DialogCreator resized size do (manageInterface size)
)
createDialog mc2DialogCreator  style:#(#style_sysmenu)
--#(#style_titlebar, #style_sysmenu, #style_minimizebox, #style_maximizebox, #style_sunkenedge, #style_resizing)
