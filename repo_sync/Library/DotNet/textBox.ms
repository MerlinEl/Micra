 rollout test "Test"
 (
 	dotNetControl tb "system.windows.forms.textBox" height:80
 	
 	on test open do
 	(
 		tb.multiLine=true
 		sb=dotNetClass "System.Windows.Forms.ScrollBars"
 		tb.scrollBars=sb.vertical
 		tb.acceptsReturn=true
 		tb.acceptsTab=true
 		tb.wordWrap=true
 		tb.focus()
 	)
 )
 createDialog test





		fn onOpenForm s a = (mcTextBoxText = "")
		fn textBoxControll s a  =
		(
			--mcsystem.show s
			local last_letter = s.text[s.text.count]
			if a.KeyValue == 27 then --Escape
			(
				mcTextBoxDialog.tag = ""
				mcTextBoxDialog.close()
			)
			else if findItem #("/", "\"", "*", "?", "\n", "!") last_letter != 0 do 
			(
				new_text = ""
				for i=1 to s.text.count-1 do new_text += s.text[i] --remove last letter
				--s.text = new_text
				local sta = s.SelectionStart
				local len = s.SelectionLength
                s.Text = new_text
                s.Select sta  len 
				--s.SelectedText = new_text --s.text--[s.text.count]--Char.ToUpper(e.KeyChar)

			)
			--mcTextBoxDialog.Controls.item[0].text
		)
		
		
		dotnet.addEventHandler form "Shown" onOpenForm
		dotnet.addEventHandler edtBox "KeyUp" textBoxControll 





(
	-- Create TextBox
	hTextBox = dotNetObject "System.Windows.Forms.TextBox"
	hTextBox.Location = dotNetObject "System.Drawing.Point" 10 10
	hTextBox.Width = 280
    hTextBox.Height = 280
	hTextBox.Visible = true
	hTextBox.MultiLine = true
	ScrollBars = dotNetClass "System.Windows.Forms.ScrollBars"
	hTextBox.ScrollBars = ScrollBars.Vertical
	hTextBox.AcceptsReturn = true
	hTextBox.AcceptsTab = true
	hTextBox.WordWrap = true
	
	-- Create Form
	hForm = dotNetObject "System.Windows.Forms.Form"
	hForm.Size = dotNetObject "System.Drawing.Size" 310 335
	hForm.Text = ".Net 2.0 Form with TextBox"
	hForm.Controls.Add(hTextBox)
	hForm.TopMost = true
	FormBorderStyle = dotNetClass "System.Windows.Forms.FormBorderStyle"
	hForm.FormBorderStyle = FormBorderStyle.FixedDialog
	hForm.ShowInTaskbar = false
	hForm.MinimizeBox = false
	hForm.MaximizeBox = false
	
	-- Set appropriate Form background color
	maxBackColor = colorMan.getColor #background
	Color = dotNetClass "System.Drawing.Color"
	hForm.BackColor = Color.FromArgb (maxBackColor[1] * 255.0f) (maxBackColor[2] * 255.0f) (maxBackColor[3] * 255.0f)
    
	-- Show application Form
	hApp = dotNetClass "System.Windows.Forms.Application"
	hApp.Run hForm
)


--Also, App.Run() is better than Form.Show() because it initializes well the dialog and 
--the keyboard handling. With Form.Show(), 
--Max intercepts all the keyboard messages when writting in the TextBox...


--tab spacing? maybe use RichTextBox class or Denis C# fn

fn getTabStopClass = 
(
	source = ""
	source += "using System;\n"
	source += "using System.Runtime.InteropServices;\n"
	source += "using System.Windows.Forms;\n"
	source += "class TabStops\n"
	source += "{\n"
	source += "\tprivate const int EM_SETTABSTOPS = 0x00CB;\n"
	source += "\t[DllImport(\"User32.dll\", CharSet = CharSet.Auto)]\n"
	source += "\tpublic static extern IntPtr SendMessage(IntPtr h, int msg, int wParam, int[] lParam);\n"
	source += "	public static void SetTextBoxTabWidth(TextBox textbox, int tabWidth)\n"
	source += "	{\n"
	source += "		int[] stops = new int[] { tabWidth };\n"
	source += "		SendMessage(textbox.Handle, EM_SETTABSTOPS, 1, stops);\n"
	source += "	}\n"
	source += "}\n"

	-- Compile on fly
	csharpProvider = dotnetobject "Microsoft.CSharp.CSharpCodeProvider"
	compilerParams = dotnetobject "System.CodeDom.Compiler.CompilerParameters"
	compilerParams.ReferencedAssemblies.Add("System.dll");
	compilerParams.ReferencedAssemblies.Add("System.Windows.Forms.dll");

	compilerParams.GenerateInMemory = on
	compilerResults = csharpProvider.CompileAssemblyFromSource compilerParams #(source)

	output = compilerResults.CompiledAssembly.CreateInstance "TabStops"
)


	on tb keyPress    arg do (textBoxControll  arg method:#KeyPress)
  	on tb keyUp       arg do (textBoxControll  arg method:#KeyUp)

	fn textBoxControll arg method:#KeyUp = 
	(
		case method of
		(
			#KeyUp:
			(
				if keyboard.shiftPressed and arg.KeyValue == 9 --key shift and tab pressed
				then setFocus tv
				else if arg.KeyValue == 9 
				then if lv.SelectedItems.Count != 0 then setFocus lv else setFocus tv -- tab pressed
				else if (arg.KeyValue == 38 or arg.KeyValue == 40) and lv.SelectedItems.Count != 0 
				then setFocus lv -- arrow up or arrow down pressed
				else searchInListView()
			)
			#KeyPress:
			(
				if (bit.charAsInt arg.KeyChar) == 13 and tb.text.count > 1 and tb.text[tb.text.count] == "/" then --if enter pressed and contain symbol "/" do (create a new file)
				(
					local tb_text = substring tb.text 1 (tb.text.count-1)
					tb.text = ""
					local file_name = current_dir + tb_text + ".ms" --remove symbol "/" and combine a file name
					if queryBox ("Do you wish to create new File?\t" + file_name) title:" Confirm File Creation:" 
					then
					(
						if dupplicateFileIsFound current_dir file_name do
						(
							if queryBox ("This folder already contains a file named\n\n" + file_name + 
							"\n\nWould you like to replace existing file?") title:" Confirm File Replace:" 
							then deleteFile file_name
							else (setFocus tb; return false)
						)
						local f = createFile file_name
						close f
						edit file_name
						fillListView tv.SelectedNode.text
					)
					else setFocus tb
				)
				else if (bit.charAsInt arg.KeyChar) == 13 then --enter pressed
				(
					if current_list_item != undefined and doesFileExist current_list_item.tag do edit current_list_item.tag
				)
				else if (bit.charAsInt arg.KeyChar) == 27 do destroyDialog mcScriptManDialog --escape pressed
			)
		)
	)
