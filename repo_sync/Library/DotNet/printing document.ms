(
	-- Load custom assembly with 3ds Max specific controls

	
	local filetoprint = ""
	local printFont = dotnetobject "System.Drawing.Font" "Arial" 10
	local streamReader

	-- Let's create our main form
	hForm = dotNetObject "Form"
	hForm.Size = dotNetObject "System.Drawing.Size" 640 480
	hForm.FormBorderStyle = (dotnetclass "System.Windows.Forms.FormBorderStyle").FixedToolWindow
	hForm.Text = "Printing with dotNet"
	hForm.ShowInTaskbar = False
	
	-- Let's create a textbox to load and display our files
	txtTextBox = dotNetObject "System.Windows.Forms.TextBox"
	txtTextBox.MultiLine = True
	txtTextBox.Size = dotNetObject "System.Drawing.Size" 500 430
	txtTextBox.Location = dotNetObject "System.Drawing.Point" 10 10
	txtTextBox.ScrollBars = (dotNetClass "System.Windows.Forms.ScrollBars").Both
	txtTextBox.WordWrap = False
	
	-- Our Open File Button
	btnOpenFile = dotNetObject "System.Windows.Forms.Button"
	btnOpenFile.Location = dotNetObject "System.Drawing.Point" 520 10
	btnOpenFile.Text = "Open File"
	
		-- Our Print Button
	btnPrint = dotNetObject "System.Windows.Forms.Button"
	btnPrint.Location = dotNetObject "System.Drawing.Point" 520 40
	btnPrint.Text = "Print"
	
	-- Open File Dialog
	frmOpenFileDialog = dotNetObject "System.Windows.Forms.OpenFileDialog"
	frmOpenFileDialog.Filter = "txt files (*.txt)|*.txt|Script Files (*.ms)|*.ms|ini files (*.ini)|*.ini|XML files (*.xml)|*.xml|All files (*.*)|*.*"
	
	-- Functions for Event Handlers
	fn btnOpenFile_Click = 
	(
		dlgResult = dotNetClass "System.Windows.Forms.DialogResult"
		if frmOpenFileDialog.ShowDialog() == dlgResult.OK then
		(
			IOFile = dotNetClass "System.IO.File"
			txtTextBox.Text = IOFile.ReadAllText frmOpenFileDialog.Filename
			filetoprint = frmOpenFileDialog.Filename
		)
	)
	
	function pd_PrintPage  sender ev =
	(
		count = 0
		linesperpage = ev.MarginBounds.Height / printFont.GetHeight(ev.Graphics)
		yPos = 0
		leftMargin = ev.MarginBounds.Left
		topMargin = ev.MarginBounds.Top
		currentline = ""
		brush = dotnetobject  "System.Drawing.Solidbrush"  (dotnetclass "System.Drawing.Color").black
		stringformat = dotnetobject "System.Drawing.StringFormat"
		
		while count < linesperpage do
		(
			currentline = streamReader.ReadLine()

			if currentline == undefined then exit
				
			yPos = topMargin + count * printFont.GetHeight(ev.Graphics)
			ev.Graphics.DrawString currentline printFont brush leftMargin yPos stringformat
			count += 1
		)

		if currentline != undefined then ev.HasMorePages = true else ev.HasMorePages = false
	)
		
	fn btnPrint_Click = 
	(	
		if filetoprint != "" then
		(			
			try
			(
				streamReader = dotnetobject "System.IO.Streamreader" filetoprint			
	
				pd = dotnetobject "System.Drawing.Printing.PrintDocument"
				
				dotnet.addeventhandler pd "PrintPage" pd_PrintPage
				
				pd.Print()
				streamReader.Close()
			)	
			catch
			(
				print (getCurrentException())
			)
		)
	)
	
	-- Add Event Handlers to our buttons
	dotNet.AddEventHandler btnOpenFile "Click" btnOpenFile_Click
	dotNet.AddEventHandler btnPrint "Click" btnPrint_Click
	
	-- Add the controls to the main form
	hForm.Controls.Add(txtTextBox)
	hForm.Controls.Add(btnOpenFile)
	hForm.Controls.Add(btnPrint)
	
	hForm.Show()
)