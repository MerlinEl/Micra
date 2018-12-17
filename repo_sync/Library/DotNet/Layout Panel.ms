	-->Interface Buttons
	local tv = dotNetObject "TableLayoutPanel"
 /*
tv.layoutSettings.RowStyles : <System.Windows.Forms.TableLayoutRowStyleCollection>, read-only
.Margin : <System.Windows.Forms.Padding>
.ForeColor : <System.Drawing.Color>
.AutoSize : <System.Boolean>
.AutoSizeMode : <System.Windows.Forms.AutoSizeMode>
.BackColor : <System.Drawing.Color>
.AccessibleName : <System.String>
 .AccessibleRole : <System.Windows.Forms.AccessibleRole>
*/	
 	
	local button_size = 25
	local buttons_X = form.width  / button_size
 	local buttons_Y = form.height / button_size
	
	format "form.width:%\tform.height:%\n" form.width form.height
	format "buttons_X:%\tbuttons_Y:%\n" buttons_X buttons_Y
	tv.layoutSettings.GrowStyle = (dotnetClass "TableLayoutPanelGrowStyle").AddColumns
	tv.layoutSettings.ColumnCount = buttons_X
	tv.layoutSettings.RowCount = buttons_Y
	--tv.Padding = dotNetObject "Padding" 20 --panel bounds offset
	tv.Top = 8
 	tv.BorderStyle = (dotNetClass "BorderStyle").None	
 	tv.width = form.width
 	tv.height = form.height - 8
	tv.AllowDrop = true
 	--mc2System.show tv.layoutSettings
	for i = 0 to buttons_X - 1 do
	(
 		local btn = (dotNetObject "Button")
		btn.Width = button_size
		btn.Height = button_size
		btn.Text = i as string
		tv.Controls.Add btn (i) 0
	)