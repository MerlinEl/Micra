gw.getTextExtent "Bobo, Zadr, Dunik, Tom, Alcado, Fero,"
gw.getTextExtent "Bobo, Zadr, Dunik, Tom, Alcado, Fero, 
				Leo, Milki, Mr.Oringe, Lubik, Radek, 
			DenisT, PEN, Macro Bruneta...."
tSize = (dotnetclass "TextRenderer").MeasureText this.Text this.Font

str = (dotnetObject "System.String" "abcdefgh")
str.Chars 1
str.Length

dcr = (dotnetclass "TextRenderer")
--df =  dotnetObject "Drawing.Font" "str"??
--mcsystem.show df
--dcr.MeasureText "jcykk" (dotnetClass "Drawing.Font")

fam    = (dotnetClass "Drawing.FontFamily").Families
fstyle = (dotnetClass "Drawing.FontStyle").Bold
fgra   = (dotNetClass "Drawing.GraphicsUnit").pixel
--dotnetObject "Drawing.Font" 10 "Arial" fstyle fgra


		rollout mcTextBoxDialog " Command Box v0.1" width:320 height:36
		(
			-->locals
			local dir = getINISetting mcUserINI "3DGallery" "Current_Dir"
			local bgColor   = ((colorMan.getColor #background)*255)as color
			local winColor  = ((colorMan.getColor #window)*255)as color
			local textColor = ((colorMan.getColor #text)*255)as color
			local colorclass = dotnetclass "system.drawing.color"
			local drawingColor   = dotNetClass "drawing.color"
			--<locals
			--edittext edtBox "New Name:" pos:[4,4] width:312 height:16 bold:true
			--lbl "New Name:"
			dotNetControl edtBox "textbox" pos:[4,4] width:312 height:28
			fn textBoxControll a s method:#KeyUp = 
			(
				case method of
				(
					#KeyUp: 
					(
						print a
						print s.KeyValue
						if s.KeyValue == 27 do destroyDialog mcTextBoxDialog
						--if s.KeyValue == 9 do setFocus tv -- tab pressed
						
					)
					#KeyPress:
					(
						if (bit.charAsInt s.KeyChar) == 13 then () --if enter pressed
						
						print "kp"
					)
				)
			)
			on mcTextBoxDialog open do
			(
--mcsystem.show 
--.Cursor
				local dnfontlarge = dotNetObject "System.Drawing.Font" "Verdana" 14 ((dotNetClass "System.Drawing.FontStyle").bold)
				edtBox.font = dnfontlarge
				edtBox.BackColor= drawingColor.fromArgb winColor.r winColor.g winColor.b
				edtBox.ForeColor= drawingColor.fromArgb textColor.r textColor.g textColor.b
				edtBox.AcceptsTab = true
				edtBox.Multiline = true
				edtBox.focus()
			)
			on edtBox keyPress a s do (textBoxControll a s method:#KeyPress)
  			on edtBox keyUp    a s do (textBoxControll a s method:#KeyUp)
		)
		CreateDialog mcTextBoxDialog style:#(#style_border)  modal:true