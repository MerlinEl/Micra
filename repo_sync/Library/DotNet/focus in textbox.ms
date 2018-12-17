fn mcGetTextFromBox sendtext: pos: size: =
(
	local clr_back    = execute (mcFile.saveLoadIniSetings head:"InterfaceColor" key:"backcolor" action:#load)
	local clr_seltext = execute (mcFile.saveLoadIniSetings head:"InterfaceColor" key:"seltext"  action:#load)
	local clr_fore    = execute (mcFile.saveLoadIniSetings head:"InterfaceColor" key:"forecolor" action:#load)
	local clr_text    = execute (mcFile.saveLoadIniSetings head:"InterfaceColor" key:"textcolor"  action:#load)
	local f=dotNetObject "form"
	local t=dotNetObject "textBox"
	f.ControlBox  = false --hide main bar
	f.autosize = false
	f.StartPosition = f.StartPosition.Manual
	f.formBorderStyle = f.formBorderStyle.none
	f.BackColor = netDrColor clr_fore --yellow
	f.MinimumSize = netDrSize [40, 12]
	--f.MaximumSize = netDrSize [btn_size*count_limit, btn_size*count_limit]
	f.ShowInTaskbar = false
	--f.modal=true
	f.opacity = 0.8
	t.BackColor= netDrColor clr_back
	t.ForeColor= netDrColor clr_text
	--t.size = netDrSize [f.width - form_offset, btn_size]
	t.BorderStyle = t.BorderStyle.FixedSingle
	--t.AcceptsTab = true
	--t.AcceptsReturn = true
	--t.Multiline = true
	if sendtext == unsupplied do sendtext = ""
	if pos      == unsupplied do pos      = mouse.screenpos
	if size     == unsupplied do size     = [200, 24]
	t.text = sendtext
	f.bounds = netDrRect pos [size.x+4, size.y]
	t.bounds = netDrRect [2, 2] size
	fn onGotFocus s a  = (enableAccelerators = false)
	fn onLostFocus s a = (enableAccelerators = true; s.parent.close())
	fn onRename s a =
	(
		if a.KeyValue == 13  --Enter
		then
		(
			print s.text
			s.parent.close()
		)
		else if a.KeyValue == 27 then -- Ecape
		(
			s.clear()
			print s.text
			s.parent.close()   
		) 
	)
	dotNet.addEventHandler t "KeyUp" onRename
	dotNet.addEventHandler t "GotFocus" onGotFocus
	dotNet.addEventHandler t "LostFocus" onLostFocus
	f.controls.add( t )
	f.show(WindowWrapper) 
	t.focus()
)
a = (mcgetTextFromBox sendtext:"ahoj")