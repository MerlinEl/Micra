rollout popUpDialog "" width:280 height:28
							(
								dotNetControl textBox "textbox" pos:[4,4] width:272 height:20
								on popUpDialog open do 
								(
									textBox.BackColor= dNColor.fromArgb winColor.r winColor.g winColor.b
									textBox.ForeColor= dNColor.fromArgb textColor.r textColor.g textColor.b
									textBox.AcceptsTab = true
									textBox.Multiline = true
									textBox.text = listBox.SelectedItem
									setFocus textBox
								)
								on textBox keyPress arg do 
								(
									if (bit.charAsInt arg.KeyChar) == 27 do destroyDialog popUpDialog -- escape pressed
									if (bit.charAsInt arg.KeyChar) == 13 do --enter pressed
									(
										if textBox.text != "" and doesFileExist current_file and textBox.text != listBox.SelectedItem do 
										(
											local file_path = treeView.SelectedNode.tag
											local file_type = getFilenameType current_file
											
											local new_file = file_path + textBox.text + file_type
											renameFile current_file new_file
											filllistBox treeView.SelectedNode.text
											destroyDialog popUpDialog
										)
									)
								)
							)
							CreateDialog popUpDialog pos:mouse.screenpos style:#(#style_border) modal:true