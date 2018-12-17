 (
 	tv = dotNetObject "System.Windows.Forms.TableLayoutPanel"
 	
 	tv.layoutSettings.RowCount = 12
 	tv.layoutSettings.ColumnCount = 6
 	tv.BorderStyle = (dotNetClass "System.Windows.Forms.BorderStyle").None
 	--tv.CellBorderStyle = (dotNetClass "System.Windows.Forms.TableLayoutPanelCellBorderSty  le").Single
 	
 	tv.width = tv.layoutSettings.ColumnCount  * 32
 	tv.height = tv.layoutSettings.RowCount* 32
 	
 	for i = 0 to tv.layoutSettings.RowCount - 1 do
 		for j = 0 to tv.layoutSettings.ColumnCount - 1 do
 		(
 			btn = (dotNetObject "System.Windows.Forms.Button")
 			--dotShow 
 			btn.Width = 25
 			btn.Height = 25
 			btn.Text = (i+j) as string
 			tv.Controls.Add btn i j
 		)
 	
 
 	hForm = dotNetObject "System.Windows.Forms.Form"
 	hForm.Size = dotNetObject "System.Drawing.Size" (tv.Width + 10) (tv.Height + 30)
 	hForm.Text = ".Net TableLayoutPanel"
 	hForm.Controls.Add(tv)
 	hForm.TopMost = true
 	FormBorderStyle = dotNetClass "System.Windows.Forms.FormBorderStyle"
 	hForm.FormBorderStyle = FormBorderStyle.FixedDialog
 	hForm.ShowInTaskbar = false
 	hForm.MinimizeBox = false
 	hForm.MaximizeBox = false
 
    
 	-- Show application Form
 	hApp = dotNetClass "System.Windows.Forms.Application"
 	hApp.Run hForm
 )