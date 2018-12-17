global DGV_Icons
  fn getGIFFiles = if DGV_Icons == undefined or true do
  (
  --	local path = (getDir #ui) + "Icons\\"
  --	local files = getFiles (path + "*.ico")
  
  	--local path = (getDir #ui) + "Ribbon\\Tooltips\\Images\\"
	local path = "E:\\Textures\\Wood\\"
  	local files = getFiles (path + "*.jpg")
  
  --	local path = (getDir #ui) + "Ribbon\\Icons\\Modeling\\"
  --	local files = getFiles (path + "*.bmp")
  	DGV_Icons = for f in files collect 
  	(
  		bmp = dotNetObject "System.Drawing.Bitmap" f
  		bmp.tag = f
  		bmp
  	)
  )
  getGIFFiles()
  
  global DataGridViewExtensionAssembly
  fn CreateDataGridViewExtensionAssembly forceRecompile:on =
  (
  	if forceRecompile or not iskindof ::DataGridViewExtensionAssembly dotnetobject or (::DataGridViewExtensionAssembly.GetType()).name != "Assembly" do
  	(
  
  source = ""
  source += "using System;\n"
  source += "using System.Reflection;\n"
  source += "using System.Runtime.InteropServices;\n"
  source += "using System.Drawing;\n"
  source += "using System.Windows.Forms;\n"
  source += "namespace DataGridViewExtension\n"
  source += "{\n"
  source += "	public class Style\n"
  source += "	{\n"
  source += "		public void SetStyle(Control control, ControlStyles styles, bool newValue)\n"
  source += "		{\n"
  source += "			object[] args = { styles, newValue };\n"
  source += "			typeof(Control).InvokeMember(\"SetStyle\",\n"
  source += "					BindingFlags.NonPublic | BindingFlags.Instance | BindingFlags.InvokeMethod,\n"
  source += "					null, control, args);\n"
  source += "		}\n"
  source += "		public bool SetSelectable(Control control, bool newValue)\n"
  source += "		{\n"
  source += "			SetStyle(control, ControlStyles.Selectable, newValue);\n"
  source += "			return newValue;\n"
  source += "		}\n"
  source += "		public void SetDoubleBuffer(Control control)\n"
  source += "		{\n"
  source += "			SetStyle(control, ControlStyles.DoubleBuffer | ControlStyles.UserPaint | ControlStyles.AllPaintingInWmPaint | ControlStyles.Opaque, true);\n"
  source += "		}\n"
  source += "	}\n"
  source += "	public class ImageTextCellColumn : DataGridViewImageColumn\n"
  source += "	{\n"
  source += "		private Boolean showLabel;\n"
  source += "		private String label;\n"
  source += "		private ContentAlignment labelAlign;\n"
  source += "		private Color labelBackColor;\n"
  source += "		private Color labelForeColor;\n"
  source += "		public ImageTextCellColumn()\n"
  source += "		{\n"
  source += "			this.ShowLabel = true;\n"
  source += "			this.LabelForeColor = Color.White;\n"
  source += "			this.LabelBackColor = Color.FromArgb(100, Color.Black);\n"
  source += "			this.CellTemplate = new ImageTextCell();\n"
  source += "		}\n"
  source += "		public override object Clone()\n"
  source += "		{\n"
  source += "			ImageTextCellColumn c = base.Clone() as ImageTextCellColumn;\n"
  source += "			c.ShowLabel = this.showLabel;\n"
  source += "			c.Label = this.label;\n"
  source += "			c.LabelAlign = this.labelAlign;\n"
  source += "			c.LabelForeColor = this.labelForeColor;\n"
  source += "			c.LabelBackColor = this.labelBackColor;\n"
  source += "			return c;\n"
  source += "		}\n"
  source += "		private ImageTextCell ImageTextCellTemplate\n"
  source += "		{\n"
  source += "			get { return this.CellTemplate as ImageTextCell; }\n"
  source += "		}\n"
  source += "		public Boolean ShowLabel\n"
  source += "		{\n"
  source += "			get { return this.showLabel; }\n"
  source += "			set { this.showLabel = value; }\n"
  source += "		}\n"
  source += "		public String Label\n"
  source += "		{\n"
  source += "			get { return this.label; }\n"
  source += "			set { this.label = value; }\n"
  source += "		}\n"
  source += "		public ContentAlignment LabelAlign\n"
  source += "		{\n"
  source += "			get { return this.labelAlign; }\n"
  source += "			set { this.labelAlign = value; }\n"
  source += "		}\n"
  source += "		public Color LabelForeColor\n"
  source += "		{\n"
  source += "			get { return this.labelForeColor; }\n"
  source += "			set { this.labelForeColor = value; }\n"
  source += "		}\n"
  source += "		public Color LabelBackColor\n"
  source += "		{\n"
  source += "			get { return this.labelBackColor; }\n"
  source += "			set { this.labelBackColor = value; }\n"
  source += "		}\n"
  source += "	}\n"
  source += "	public class ImageTextCell : DataGridViewImageCell\n"
  source += "	{\n"
  source += "		private Boolean showLabel;\n"
  source += "		private String label;\n"
  source += "		private Color labelBackColor;\n"
  source += "		private Color labelForeColor;\n"
  source += "		public ImageTextCell()\n"
  source += "		{\n"
  source += "			this.ShowLabel = true;\n"
  source += "		}\n"
  source += "		public override object Clone()\n"
  source += "		{\n"
  source += "			ImageTextCell c = base.Clone() as ImageTextCell;\n"
  source += "			c.ShowLabel = this.showLabel;\n"
  source += "			c.Label = this.label;\n"
  source += "			c.LabelForeColor = this.labelForeColor;\n"
  source += "			c.LabelBackColor = this.labelBackColor;\n"
  source += "			return c;\n"
  source += "		}\n"
  source += "		public Boolean ShowLabel\n"
  source += "		{\n"
  source += "			get\n"
  source += "			{\n"
  source += "				if (this.OwningColumn == null || this.ImageTextCellColumn == null) { return showLabel; }\n"
  source += "				else return (this.showLabel & this.ImageTextCellColumn.ShowLabel);\n"
  source += "			}\n"
  source += "			set { if (this.showLabel != value) { this.showLabel = value; } }\n"
  source += "		}\n"
  source += "		public String Label\n"
  source += "		{\n"
  source += "			get\n"
  source += "			{\n"
  source += "				if (this.OwningColumn == null || this.ImageTextCellColumn == null) { return label; }\n"
  source += "				else if (this.label != null)\n"
  source += "				{\n"
  source += "					return this.label;\n"
  source += "				}\n"
  source += "				else\n"
  source += "				{\n"
  source += "					return this.ImageTextCellColumn.Label;\n"
  source += "				}\n"
  source += "			}\n"
  source += "			set { if (this.label != value) { this.label = value; } }\n"
  source += "		}\n"
  source += "		public Color LabelForeColor\n"
  source += "		{\n"
  source += "			get\n"
  source += "			{\n"
  source += "				if (this.OwningColumn == null || this.ImageTextCellColumn == null) { return labelForeColor; }\n"
  source += "				else if (this.labelForeColor != Color.Empty)\n"
  source += "				{\n"
  source += "					return this.labelForeColor;\n"
  source += "				}\n"
  source += "				else\n"
  source += "				{\n"
  source += "					return this.ImageTextCellColumn.LabelForeColor;\n"
  source += "				}\n"
  source += "			}\n"
  source += "			set { if (this.labelForeColor != value) { this.labelForeColor = value; } }\n"
  source += "		}\n"
  source += "		public Color LabelBackColor\n"
  source += "		{\n"
  source += "			get\n"
  source += "			{\n"
  source += "				if (this.OwningColumn == null || this.ImageTextCellColumn == null) { return labelBackColor; }\n"
  source += "				else if (this.labelBackColor != Color.Empty)\n"
  source += "				{\n"
  source += "					return this.labelBackColor;\n"
  source += "				}\n"
  source += "				else\n"
  source += "				{\n"
  source += "					return this.ImageTextCellColumn.LabelBackColor;\n"
  source += "				}\n"
  source += "			}\n"
  source += "			set { if (this.labelBackColor != value) { this.labelBackColor = value; } }\n"
  source += "		}\n"
  source += "		protected override void Paint(Graphics graphics, Rectangle clipBounds, Rectangle cellBounds, int rowIndex,\n"
  source += "			DataGridViewElementStates cellState, object value, object formattedValue, string errorText,\n"
  source += "			DataGridViewCellStyle cellStyle, DataGridViewAdvancedBorderStyle advancedBorderStyle, DataGridViewPaintParts paintParts)\n"
  source += "		{\n"
  source += "			// Paint the base content\n"
  source += "			base.Paint(graphics, clipBounds, cellBounds, rowIndex,\n"
  source += "				cellState, value, formattedValue, errorText,\n"
  source += "				cellStyle, advancedBorderStyle, paintParts);\n"
  source += "			if (this.ShowLabel && this.Label != null)\n"
  source += "			{\n"
  source += "				// Draw the image clipped to the cell.\n"
  source += "				System.Drawing.Drawing2D.GraphicsContainer container = graphics.BeginContainer();\n"
  source += "				SizeF ss = TextRenderer.MeasureText(this.Label, cellStyle.Font);\n"
  source += "				ss = SizeF.Add(ss, new SizeF(0, 2));\n"
  source += "				Single px = cellBounds.X;\n"
  source += "				Single tx, py;\n"
  source += "				switch (this.ImageTextCellColumn.LabelAlign)\n"
  source += "				{\n"
  source += "					case ContentAlignment.BottomCenter:\n"
  source += "						{\n"
  source += "							tx = (cellBounds.Width - ss.Width) / 2 + px;\n"
  source += "							py = (cellBounds.Height - ss.Height) + cellBounds.Y;\n"
  source += "							break;\n"
  source += "						}\n"
  source += "					case ContentAlignment.MiddleCenter:\n"
  source += "						{\n"
  source += "							tx = (cellBounds.Width - ss.Width) / 2 + px;\n"
  source += "							py = (cellBounds.Height - ss.Height) / 2 + cellBounds.Y;\n"
  source += "							break;\n"
  source += "						}\n"
  source += "					case ContentAlignment.TopCenter:\n"
  source += "						{\n"
  source += "							tx = (cellBounds.Width - ss.Width) / 2 + px;\n"
  source += "							py = cellBounds.Y;\n"
  source += "							break;\n"
  source += "						}\n"
  source += "					case ContentAlignment.TopLeft:\n"
  source += "						{\n"
  source += "							tx = px;\n"
  source += "							py = cellBounds.Y;\n"
  source += "							break;\n"
  source += "						}\n"
  source += "					case ContentAlignment.BottomRight:\n"
  source += "						{\n"
  source += "							tx = (cellBounds.Width - ss.Width) + px;\n"
  source += "							py = (cellBounds.Height - ss.Height) + cellBounds.Y;\n"
  source += "							break;\n"
  source += "						}\n"
  source += "					default:\n"
  source += "						{\n"
  source += "							tx = (cellBounds.Width - ss.Width) / 2 + px;\n"
  source += "							py = (cellBounds.Height - ss.Height) + cellBounds.Y;\n"
  source += "							break;\n"
  source += "						}\n"
  source += "				}\n"
  source += "				Rectangle rect = new Rectangle((int)px, (int)py, (int)cellBounds.Width, (int)ss.Height);\n"
  source += "				graphics.SetClip(rect);\n"
  source += "				graphics.FillRectangle(new SolidBrush(this.LabelBackColor), rect);\n"
  source += "				graphics.DrawString(this.Label, cellStyle.Font, new SolidBrush(this.LabelForeColor), tx, py);\n"
  source += "				graphics.EndContainer(container);\n"
  source += "			}\n"
  source += "		}\n"
  source += "		public ImageTextCellColumn ImageTextCellColumn\n"
  source += "		{\n"
  source += "			get { return this.OwningColumn as ImageTextCellColumn; }\n"
  source += "		}\n"
  source += "	}\n"
  source += "}\n"
  
  		csharpProvider = dotnetobject "Microsoft.CSharp.CSharpCodeProvider"
  		compilerParams = dotnetobject "System.CodeDom.Compiler.CompilerParameters"
  
  		compilerParams.ReferencedAssemblies.AddRange #("System.dll","System.Windows.Forms.dll","System.Drawing.dll");
  
  		compilerParams.GenerateInMemory = true
  		compilerResults = csharpProvider.CompileAssemblyFromSource compilerParams #(source)
  		
  		if (compilerResults.Errors.Count > 0 ) then
  		(
  			errs = stringstream ""
  			for i = 0 to (compilerResults.Errors.Count-1) do
  			(
  				err = compilerResults.Errors.Item[i]
  				format "Error:% Line:% Column:% %\n" err.ErrorNumber err.Line err.Column err.ErrorText to:errs 
  			)
  			MessageBox (errs as string) title: "Errors encountered while compiling C# code"
  			format "%\n" errs
  			undefined
  		)
  		else
  		(
  			DataGridViewExtensionAssembly = compilerResults.CompiledAssembly
  --			DataGridViewExtensionAssembly.CreateInstance "ImageTextCellColumn"
  		)
  	)
  )
  --global DataGridViewExtension = if DataGridViewExtension == undefined then CreateDataGridViewExtensionAssembly() else DataGridViewExtension
  global DataGridViewExtensionOps = CreateDataGridViewExtensionAssembly forceRecompile:on
  
  try(form.close()) catch()
  --form = dotnetobject "MaxCustomControls.Maxform"
  form = dotNetObject "Form"
  
  form.Text = "DataGridView ImageTextCell"	
  
  form.StartPosition = form.StartPosition.Manual
  form.Location = dotnetobject "System.Drawing.Point" 200 100
  form.Size = dotnetobject "System.Drawing.Size" 800 660
  
  addc = dotnetobject "Button"
  addc.text = "Add Column"
  addc.Dock = addc.Dock.Top	
  
  delc = dotnetobject "Button"
  delc.text = "Remove Column"
  delc.Dock = addc.Dock.Top	
  	
  addr = dotnetobject "Button"
  addr.text = "Add Row"
  addr.Dock = addc.Dock.Top	
  
  delr = dotnetobject "Button"
  delr.text = "Remove Row"
  delr.Dock = addc.Dock.Top	
  
  gv = dotnetobject "DataGridView"
  cc = DataGridViewExtensionAssembly.CreateInstance "DataGridViewExtension.Style"
  cc.SetDoubleBuffer gv
  font = gv.font 
  gv.font = dotNetObject "System.Drawing.Font" font.FontFamily font.Size font.style.Bold
  	
  
  --bc = dotNetObject "System.Windows.Forms.DataGridViewButtonColumn"
  --bc = dotNetObject "System.Windows.Forms.DataGridViewImageColumn"
  bc = DataGridViewExtensionAssembly.CreateInstance "DataGridViewExtension.ImageTextCellColumn"
  bc.LabelBackColor = (dotnetclass "System.Drawing.Color").FromARGB 70 (dotnetclass "System.Drawing.Color").DarkRed
  bc.LabelForeColor = (dotnetclass "System.Drawing.Color").FromARGB 200 (dotnetclass "System.Drawing.Color").Black
  --bc.LabelForeColor = (dotnetclass "System.Drawing.Color").White
  --bc.LabelBackColor = (dotnetclass "System.Drawing.Color").Transparent
  
  --bc.LabelAlign = bc.LabelAlign.BottomRight
  
  p = dotnetobject "System.Windows.Forms.Padding" 2
  p.Bottom = 16
  bc.DefaultCellStyle.Padding = p
  bc.ImageLayout = bc.ImageLayout.Normal
  
  /* Flat Settings */
  bc.DefaultCellStyle.BackColor = bc.DefaultCellStyle.BackColor.Beige 
  --bc.FlatStyle = bc.FlatStyle.Flat 
  
  fn addColumn s e =
  (
  	gv = s.parent.controls.item[0]
  	gv.SuspendLayout()
  	gv.columns.add (bc.clone())
  	gv.ResumeLayout()
  )	
  dotNet.addEventHandler addc "Click" addColumn
  fn removeColumn s e =
  (
  	gv = s.parent.controls.item[0]
  	gv.SuspendLayout()
  	gv.ColumnCount = amax (gv.ColumnCount-1) 1
  	gv.ResumeLayout()
  )	
  dotNet.addEventHandler delc "Click" removeColumn
  fn addRow s e =
  (
  	gv = s.parent.controls.item[0]
  	gv.SuspendLayout()
  	s.parent.controls.item[0].RowCount += 1
  	gv.ResumeLayout()
  )	
  dotNet.addEventHandler addr "Click" addRow
  fn removeRow s e =
  (
  	gv = s.parent.controls.item[0]
  	gv.SuspendLayout()
  	gv.RowCount = amax (gv.RowCount-1) 1
  	gv.ResumeLayout()
  )	
  dotNet.addEventHandler delr "Click" removeRow
  
  fn CellClick s e = 
  (
  	cell = s.rows.item[e.rowindex].cells.item[e.columnindex]
  	format "button: %\n" cell.value
  )
  fn CellFormatting s e =
  (
  	c = e.rowindex*s.ColumnCount + e.ColumnIndex
  	i = mod c DGV_Icons.count
  	bmp = DGV_Icons[i+1]
  	
  	cell = s.rows.item[e.rowindex].cells.item[e.columnindex]
  	cell.ImageLayout = if cell.Size.width < bmp.width or cell.Size.height < bmp.height then cell.ImageLayout.Zoom
  		else cell.ImageLayout.Normal
  	if not cell.ImageTextCellColumn.ShowLabel do cell.ShowLabel = off
  	e.value = bmp
  	cell.Description = bmp.tag
  --	cell.Description = (e.rowindex as string) + " - " + (e.columnindex as string) --+ "\ncell"
  	cell.Label = ((c+1) as integer) as string + " - " + (filenamefrompath cell.Description)
  	cell.ToolTipText = bmp.tag
  )
  fn updateGridView s e = 
  (
  	gv.SuspendLayout()
  	for r=0 to s.RowCount-1 do for i=0 to s.ColumnCount-1 do
  	(
  		cell = s.rows.item[r].cells.item[i]
  		v = r*s.ColumnCount + i
  --		if cell.value != v do cell.value = v
  	)
  	gv.ResumeLayout()
  )
  fn changeGridViewRowHeight gv height = 
  (
  	gv.SuspendLayout()
  	gv.RowTemplate.Height = height
  	for r=0 to gv.RowCount-1 do gv.rows.item[r].Height = height
  	gv.ResumeLayout()
  )
  
  gv.ColumnHeadersDefaultCellStyle.Alignment = gv.ColumnHeadersDefaultCellStyle.Alignment.MiddleC  enter
  gv.ReadOnly = on
  gv.MultiSelect = on
  	
  --dotNet.addEventHandler gv "CellPainting" CellPainting
  
  dotNet.addEventHandler gv "CellFormatting" CellFormatting
  dotNet.addEventHandler gv "ColumnAdded" updateGridView
  dotNet.addEventHandler gv "ColumnRemoved" updateGridView
  dotNet.addEventHandler gv "RowsAdded" updateGridView
  dotNet.addEventHandler gv "RowsRemoved" updateGridView
  dotNet.addEventHandler gv "CellClick" CellClick
  
  gv.Dock = gv.Dock.Fill
  
  gv.RowTemplate.Height = 128
  gv.AutoSize = on
  	
  gv.AutoSizeColumnsMode = gv.AutoSizeColumnsMode.Fill
  --gv.AutoSizeRowsMode = gv.AutoSizeRowsMode.AllCells
  gv.AutoSizeRowsMode = gv.AutoSizeRowsMode.None
  gv.RowHeadersWidthSizeMode = gv.RowHeadersWidthSizeMode.EnableResizing
  	
  for k=1 to 4 do gv.columns.add (bc.clone())
  
  gv.RowCount = 251
  
  gv.ColumnHeadersVisible = gv.ShowEditingIcon = gv.RowHeadersVisible = off	
  gv.AllowUserToaddRows = gv.AllowUserToDeleteRows = gv.AllowUserToResizeColumns = off
  gv.AllowUserToResizeRows = on
  
  form.controls.addrange #(gv, delr, addr, delc, addc)
  
  --form.showmodeless()
  form.show()
  --WindowWrapper = (dotnetobject "WindowWrapper" (windows.getMAXHWND()))
--fooo.show(WindowWrapper)
  
