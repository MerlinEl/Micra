 
(
 
dotnet.loadassembly "System.Data"
 
 
 
Color = dotNetClass "System.Drawing.Color"
 
ScrollBars = dotNetClass "System.Windows.Forms.ScrollBars"
 
 
 
-- Create Tabs Container 
 
tabControl1 = dotnetobject "system.windows.forms.TabControl"
 
tabControl1.size = dotnetobject "system.drawing.size" 395 195
 
tabControl1.Location = dotnetobject "System.Drawing.Point" 0 0 
 
 
 
--Create Tabs
 
tabPage1 = dotnetobject "System.Windows.Forms.TabPage"
 
tabPage1.text = "Goodbye World"
 
tabPage2 = dotnetobject "System.Windows.Forms.TabPage"
 
tabPage2.text = "Hello World"
 
tabPage1.backColor = color.fromArgb 200 200 200 
 
tabPage2.backColor = color.fromArgb 200 200 200 
 
 
 
-- Add Some Columns to the Datagrid
 
dt = dotnetobject "system.data.DataTable""Test"
 
Column1 = dotnetobject "System.Data.DataColumn" "id" (dotnetclass "System.Int32")
 
Column2 = dotnetobject "System.Data.DataColumn" "Name" (dotnetclass "System.String")
 
dt.columns.add Column1
 
dt.columns.add Column2
 
 
 
for i=0 to 2 do
 
(
 
row=#(dotnetobject "System.Int32" i,dotnetobject "System.String" (i as string)) 
 
dt.rows.add row
 
)
 
 
 
-- Create Datagrid
 
DGrid1 = dotnetobject "System.Windows.Forms.DataGrid"
 
DGrid1.Location = dotNetObject "System.Drawing.Point" 10 10
 
DGrid1.Width = 365
 
DGrid1.Height = 120
 
DGrid1.Visible = true
 
DGrid1.DataSource = dt 
 
 
 
-- Create TextBox
 
TB1TextBox = dotNetObject "System.Windows.Forms.TextBox"
 
TB1TextBox.Location = dotNetObject "System.Drawing.Point" 10 10
 
TB1TextBox.Width = 365
 
TB1TextBox.Height = 120
 
TB1TextBox.Visible = true
 
TB1TextBox.MultiLine = true
 
TB1TextBox.ScrollBars = ScrollBars.Vertical
 
TB1TextBox.AcceptsReturn = true
 
TB1TextBox.AcceptsTab = true
 
TB1TextBox.WordWrap = true
 
 
 
-- Create Buttons
 
button01 = dotnetobject "System.Windows.Forms.button"
 
button01.text = "goodbye"
 
button01.Location = dotNetObject "System.Drawing.Point" 300 138
 
 
 
-- Create Form
 
TabForm = dotNetObject "System.Windows.Forms.Form"
 
TabForm.Size = dotNetObject "System.Drawing.Size" 400 225
 
TabForm.Text = "Title"
 
TabForm.TopMost = true
 
FormBorderStyle = dotNetClass "System.Windows.Forms.FormBorderStyle"
 
TabForm.FormBorderStyle = FormBorderStyle.FixedDialog
 
TabForm.ShowInTaskbar = false
 
TabForm.MinimizeBox = true
 
TabForm.MaximizeBox = false
 
Tabform.helpbutton = true
 
 
 
-- Add UI elements to Tabs
 
tabpage1.controls.add(TB1textbox)
 
tabpage1.controls.add(button01)
 
tabpage2.controls.add(DGrid1)
 
 
 
-- Add Tabs to Tab Container
 
tabcontrol1.controls.add(tabpage1)
 
tabcontrol1.controls.add(tabpage2)
 
-- Add Tab Container to UI Form
 
TabForm.Controls.Add(tabcontrol1)
 
-- Show application Form
 
--TTApp = dotNetClass "System.Windows.Forms.Application"
 
--TTApp.Run TabForm
TabForm.show()
 
)
