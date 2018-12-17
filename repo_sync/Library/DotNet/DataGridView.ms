fn netDrRect pos size = (dotnetObject "Drawing.Rectangle" pos.x pos.y size.x size.y)

try fo.close() catch()
fo = dotnetobject "form"
fo.Height = 100+58+20
fo.Width = 200+10+20

gri= dotnetobject "DataGridView"
gri.Bounds = netDrRect [0, 20]  [200, 100]

gri.ColumnCount = 6
gri.RowCount = 3

gri.GridColor = gri.GridColor.fromARGB 216 71 32
gri.backcolor = gri.GridColor.fromARGB 202 227 32

gri.ColumnHeadersHeight = 4
gri.RowHeadersWidth = 4
gri.AllowUserToResizeColumns = 	false
gri.AllowUserToResizeRows =	false
--gri.RowHeadersVisible = false
--gri.ColumnHeadersVisible = false
gri.AutoResizeColumns()
gri.AutoResizeRows()
fo.controls.add(gri)
fo.show()

/*
--gri.ColumnHeadersHeight = 24
--gri.RowHeadersWidth = 24
cel_style = (dotnetobject "DataGridViewCellStyle")
cel_style.ForeColor = cel_style.ForeColor.fromARGB 32 227 244
cel_style.BackColor = cel_style.ForeColor.fromARGB 32 84 120
gri.ColumnHeadersDefaultCellStyle = cel_style
--mc2system.show gri.Bounds
--mc2system.show gri
--gri.RowsDefaultCellStyle.Padding = 20
--mc2system.show gri.Margin
--gri.Margin = dotnetObject "Padding" 1
--gri.ShowEditingIcon = true
--.EditMode : <System.Windows.Forms.DataGridViewEditMode>
--mc2system.show gri.EditMode--(dotnetObject "DataGridViewEditMode")
*/