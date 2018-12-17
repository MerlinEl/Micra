try(form.close()) catch()
form = dotnetobject "form"
--form = dotnetobject "Form"
form.size = dotnetobject "System.Drawing.Size" 200 300

addc = dotnetobject "Button"
addc.text = "Add Cell"
addc.Dock = addc.Dock.Top	

delc = dotnetobject "Button"
delc.text = "Remove Cell"
delc.Dock = addc.Dock.Top	
	
addr = dotnetobject "Button"
addr.text = "Add Row"
addr.Dock = addc.Dock.Top	

delr = dotnetobject "Button"
delr.text = "Remove Row"
delr.Dock = addc.Dock.Top	

gv = dotnetobject "DataGridView"
bc = dotNetObject "System.Windows.Forms.DataGridViewButtonColumn"

/* Flat Settings */
bc.DefaultCellStyle.BackColor = bc.DefaultCellStyle.BackColor.Beige 
bc.FlatStyle = bc.FlatStyle.Flat 

fn addcell s a =
(
	gv = s.parent.controls.item[0]
	gv.SuspendLayout()
	gv.columns.add (bc.clone())
	gv.ResumeLayout()
)	
dotNet.addEventHandler addc "Click" addcell
fn delcell s a =
(
	gv = s.parent.controls.item[0]
	gv.SuspendLayout()
	gv.ColumnCount = amax (gv.ColumnCount-1) 1
	gv.ResumeLayout()
)	
dotNet.addEventHandler delc "Click" delcell
fn addrow s a =
(
	gv = s.parent.controls.item[0]
	gv.SuspendLayout()
	s.parent.controls.item[0].RowCount += 1
	gv.ResumeLayout()
)	
dotNet.addEventHandler addr "Click" addrow
fn delrow s a =
(
	gv = s.parent.controls.item[0]
	gv.SuspendLayout()
	gv.RowCount = amax (gv.RowCount-1) 1
	gv.ResumeLayout()
)	
dotNet.addEventHandler delr "Click" delrow

fn CellClick s a = 
(
	cell = s.rows.item[a.rowindex].cells.item[a.columnindex]
	format "button: %\n" cell.value
)
fn updateDridView s a = 
(
	gv.SuspendLayout()
	for r=0 to s.RowCount-1 do for i=0 to s.ColumnCount-1 do
	(
		cell = s.rows.item[r].cells.item[i]
		v = r*s.ColumnCount + i
		if cell.value != v do cell.value = v
	)
	gv.ResumeLayout()
)

gv.ColumnHeadersDefaultCellStyle.Alignment = gv.ColumnHeadersDefaultCellStyle.Alignment.MiddleC  enter
gv.ReadOnly = on
gv.MultiSelect = off
dotNet.addEventHandler gv "ColumnAdded" updateDridView
dotNet.addEventHandler gv "ColumnRemoved" updateDridView
dotNet.addEventHandler gv "RowsAdded" updateDridView
dotNet.addEventHandler gv "RowsRemoved" updateDridView
dotNet.addEventHandler gv "CellClick" CellClick

gv.Dock = gv.Dock.Fill

gv.RowTemplate.Height = 40
gv.AutoSize = on
	
gv.AutoSizeColumnsMode = gv.AutoSizeColumnsMode.Fill
gv.AutoSizeRowsMode = gv.AutoSizeRowsMode.AllCells
gv.RowHeadersWidthSizeMode = gv.RowHeadersWidthSizeMode.EnableResizing
	
gv.columns.add (bc.clone())
gv.columns.add (bc.clone())
gv.RowCount = 2

gv.ColumnHeadersVisible = gv.ShowEditingIcon = gv.RowHeadersVisible = off	
gv.AllowUserToAddRows = gv.AllowUserToDeleteRows = gv.AllowUserToResizeColumns = off
gv.AllowUserToResizeRows = on

form.controls.addrange #(gv, delr, addr, delc, addc)

form.show(WindowWrapper)