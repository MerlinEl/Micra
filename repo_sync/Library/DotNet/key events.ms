			print (a.KeyCode.ToString())
			print (a.KeyData.ToString())
			print a.keyValue
			print (a.ToString())



(
	rollout NetTextBoxTest ".NET TestBox Enter" width:200 height:60
	(
		-- .NET Keys enumeration
		local NetKeys = dotNetClass "System.Windows.Forms.Keys"
			
		dotNetControl txtBoxA "System.Windows.Forms.TextBox" pos:[8,8] width:184 height:20
		dotNetControl txtBoxB "System.Windows.Forms.TextBox" pos:[8,32] width:184 height:20
		
		-- Handle KeyDown events of txtBoxA
		on txtBoxA KeyDown EventArgs do
		(
			if EventArgs.KeyCode == NetKeys.Enter then
			(
				format "Enter!\n"
				EventArgs.SuppressKeyPress = true
			)
			else if EventArgs.KeyCode == NetKeys.Tab then
			(
				format "Tab!\n"
				txtBoxB.Focus()
				EventArgs.SuppressKeyPress = true
			)
		)
		
		-- Initialize controls
		on NetTextBoxTest open do
		(
			txtBoxA.MultiLine = true
			txtBoxA.AcceptsTab = true
			txtBoxA.AcceptsReturn = true
			txtBoxA.Text = "Accepts Enter+Tab"
			txtBoxB.Text = "Default behaviour"
		)
	)
	
	createDialog NetTextBoxTest
)