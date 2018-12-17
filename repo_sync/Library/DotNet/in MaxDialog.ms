rollout unnamedRollout "Untitled" width:260 height:184
(
	local winColor = ((colorMan.getColor #window)*255)as color
	local textColor = ((colorMan.getColor #text)*255)as color
	local dNColor = (dotNetClass "system.drawing.color")
	--
	dotNetControl textBox "textbox" pos:[16,112] width:232 height:20
	fn printKeys send arg = 
	(
		format "TextChanged  sender:%\targ:%\n" send arg
	)
	on unnamedRollout open do 
	(
		setfocus textBox
		--textBox.Controls.add "TextChanged" edt_search (if (dotnetclass "System.Windows.Forms.Keys").keyCode==13 do print "enter")
		--textBox.Controls.add ("onkeydown", "(event.keyCode==13)?document.getElementById('" + textBox.UniqueID + "').focus():return false")
		textBox.BackColor= dNColor.fromArgb winColor.r winColor.g winColor.b
		textBox.ForeColor= dNColor.fromArgb textColor.r textColor.g textColor.b
		--textBox.Controls.add ("TextChanged" printKeys)
		--mc2System.show (textbox.Controls.GetType())
		 -- .Attributes : <System.Reflection.TypeAttributes>, read-only
		format "containkey?%\n" (textbox.Controls.ContainsKey "enter")
	)
	on textBox TextChanged send arg do
	(
		format "TextChanged  sender:%\targ:%\n" send arg
	)
)
createDialog  unnamedRollout


/*
.<System.Windows.Forms.IContainerControl>GetContainerControl()
.CreateControl()
*/