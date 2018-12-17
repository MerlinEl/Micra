	Global mcTextBoxDialog
	Global mcTextBoxText = ""
	fn textBox pos:[0, 0] opaque:1 clr1:black clr2:white =
	(
		try (mcTextBoxDialog.close() ) catch()
		local form = dotNetObject "MaxCustomControls.Maxform"
		form.name = "mcTextBoxDialog"
		form.ControlBox  = false
		form.StartPosition = form.StartPosition.Manual
		form.FormBorderStyle = form.FormBorderStyle.none--SizableToolWindow--
		form.bounds = netDrRect pos [320, 36]
		form.BackColor = netDrColor clr1
		form.ShowInTaskbar = false
		form.opacity = opaque
	
		local edtBox = dotNetObject "textbox"
		edtBox.bounds = netDrRect [4,4] [312, 28]
		local dnfontlarge = dotNetObject "System.Drawing.Font" "Verdana" 14 ((dotNetClass "System.Drawing.FontStyle").bold)
		edtBox.font = dnfontlarge
		edtBox.BackColor= netDrColor clr1
		edtBox.ForeColor= netDrColor yellow
		edtBox.AcceptsTab = true
		edtBox.Multiline = true
		--edtBox.focus()
		fn onOpenForm s a = (mcTextBoxText = "")
		fn textBoxControll s a  =
		(
			print a.KeyValue
			local last_letter = s.text[s.text.count]
			if a.KeyValue == 13 then mcTextBoxDialog.close() --enter
			else if a.KeyValue == 27 then --Escape
			(
				mcTextBoxText = ""
				mcTextBoxDialog.close()
			)
			else if findItem #("/", "\"", "*", "?", "!") last_letter != 0 then
			(
				new_text = ""
				for i=1 to s.text.count-1 do new_text += s.text[i] --remove last letter
				local sta = s.SelectionStart
				local len = s.SelectionLength
                s.Text = new_text
                s.Select sta  len 
				mcTextBoxText = new_text
			)
			else mcTextBoxText = s.Text
		)
		dotnet.addEventHandler form "Shown" onOpenForm
		dotnet.addEventHandler edtBox "KeyUp" textBoxControll 
		form.controls.add edtBox
		mcTextBoxDialog = form
		mcTextBoxDialog.showModeless()
	)
	textBox()