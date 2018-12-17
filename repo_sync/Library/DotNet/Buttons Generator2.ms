Global mc2DialogCreator
try(mc2DialogCreator.close())catch()
rollout mc2DialogCreator "Dialog Creator:" width:324 height:260
(
	local button_size = 40, top_offset = 10, diaSize = [324, 260]
	dotNetControl lp "flowlayoutpanel" pos:[0,0] width:diaSize.x height:diaSize.y
	fn netDrSize size     = (dotNetObject "Drawing.Size" size.x size.y)
	fn netDrColor clr     = ((dotNetClass "Drawing.color").fromArgb clr.r clr.g clr.b)
	fn OnButtonClick send arg = 
	(
		format "send:%\targ:%\nbtn_name:%\tbtn_tag:%\n" send arg send.text send.tag
	)
	fn manageInterface size =
	(
		lp.width = size.x
		lp.height = size.y - top_offset 
	)
	fn generateButtons buttons_count =
	(
		lp.controls.clear()
		for i = 1 to buttons_count do
		(
			local btn = (dotNetObject "Button")
			btn.size = netDrSize [button_size, button_size]
			btn.flatstyle = (dotNetclass "FlatStyle").flat
			btn.margin =  dotnetobject "padding" 0
			btn.textalign =  (dotnetclass "Drawing.ContentAlignment").BottomCenter
			btn.Text = (i as integer) as string
			dotNet.addEventHandler btn "Click" OnButtonClick -- Setup an event handler for buttons
			lp.Controls.Add btn
		)
	)
	fn initializeInterface =
	(
		local buttons_X = diaSize.x  / button_size
		local buttons_Y = diaSize.y / button_size
		local buttons_count = buttons_X * buttons_Y
		lp.backColor = netDrColor( orange ) --form Back Color
		lp.Padding = dotNetObject "Padding" 2 --panel left up offset
		lp.Top = top_offset
		lp.BorderStyle = (dotNetClass "BorderStyle").None	
		lp.width = diaSize.x
		lp.height = diaSize.y - top_offset 
		lp.AllowDrop = true
		lp.AutoSize = true
		lp.autoscroll = true
		generateButtons buttons_count
	)
	on mc2DialogCreator open do initializeInterface()
	on mc2DialogCreator resized size do (manageInterface size)
)
createDialog mc2DialogCreator  style:#(#style_titlebar, 
 #style_sysmenu, #style_minimizebox, #style_maximizebox, #style_sunkenedge, #style_resizing)
