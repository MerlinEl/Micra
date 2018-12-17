	dotNetControl listbox "listbox" pos:[96,40] width:224 height:376
	
			listbox.BackColor= dNColor.fromArgb winColor.r winColor.g winColor.b
			listbox.ForeColor= dNColor.fromArgb textColor.r textColor.g textColor.b
	
	
	fn filePressed arg =
	(
		if listbox.items.count > 1 do (listbox.GetSelected 1) --if item 1 is selected
		print (listbox.SelectedIndex) --nubler of selected item
		print (listbox.SelectedItem) --text of selected item
	)

on listbox SelectedIndexChanged arg do (filePressed arg) --mouseUp, MouseClick, SelectedValueChanged
	
	
	
	
	
