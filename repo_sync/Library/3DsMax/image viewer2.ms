global DGV_Icons
fn getGIFFiles = if DGV_Icons == undefined or true do
(
	--local path = (getDir #ui) + "Icons\\"
	--local files = getFiles (path + "*.bmp")
	local path = "E:\\Textures\\Wood\\"
  	local files = getFiles (path + "*.jpg")
	DGV_Icons = for f in files collect 
	(
		local bmp = dotNetObject "System.Drawing.Bitmap" f
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
		source += "							py = (cellBounds.Height - ss.Height-1) + cellBounds.Y;\n"
		source += "							break;\n"
		source += "						}\n"
		source += "					case ContentAlignment.MiddleCenter:\n"
		source += "						{\n"
		source += "							tx = (cellBounds.Width - ss.Width) / 2 + px;\n"
		source += "							py = (cellBounds.Height - ss.Height-1) / 2 + cellBounds.Y;\n"
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
		source += "							py = (cellBounds.Height - ss.Height-1) + cellBounds.Y;\n"
		source += "							break;\n"
		source += "						}\n"
		source += "					default:\n"
		source += "						{\n"
		source += "							tx = (cellBounds.Width - ss.Width) / 2 + px;\n"
		source += "							py = (cellBounds.Height - ss.Height-1) + cellBounds.Y;\n"
		source += "							break;\n"
		source += "						}\n"
		source += "				}\n"
		source += "				Rectangle rect = new Rectangle((int)px, (int)py, (int)(cellBounds.Width-1), (int)ss.Height);\n"
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
		
		local compilerParams = dotnetobject "System.CodeDom.Compiler.CompilerParameters"  
		compilerParams.ReferencedAssemblies.AddRange #("System.dll","System.Windows.Forms.dll","System.Drawing.dll");  
		compilerParams.GenerateInMemory = true
		local compilerResults = (dotnetobject "Microsoft.CSharp.CSharpCodeProvider").CompileAssemblyFromSource compilerParams #(source)
		
		if (compilerResults.Errors.Count > 0 ) then
		(
			local errs = stringstream ""
			for i = 0 to (compilerResults.Errors.Count-1) do
			(
				local err = compilerResults.Errors.Item[i]
				format "Error:% Line:% Column:% %\n" err.ErrorNumber err.Line err.Column err.ErrorText to:errs 
			)
			MessageBox (errs as string) title: "Errors encountered while compiling C# code"
			format "%\n" errs
			undefined
		)
		else
		(
			DataGridViewExtensionAssembly = compilerResults.CompiledAssembly
		)
	)
)
CreateDataGridViewExtensionAssembly forceRecompile:on

fn initializeGridView =
(
	global maxCellWidth=150
	global gv = dotnetobject "DataGridView"
	
	local cc = DataGridViewExtensionAssembly.CreateInstance "DataGridViewExtension.Style"
	cc.SetDoubleBuffer gv
	
	local font = gv.font 
	gv.font = dotNetObject "System.Drawing.Font" font.FontFamily font.Size font.style.Bold
	
	global bc = DataGridViewExtensionAssembly.CreateInstance "DataGridViewExtension.ImageTextCellColumn"
	bc.LabelBackColor = (dotnetclass "System.Drawing.Color").FromARGB 255 (dotnetclass "System.Drawing.Color").Lime
	bc.LabelForeColor = (dotnetclass "System.Drawing.Color").FromARGB 255 (dotnetclass "System.Drawing.Color").Black
	bc.LabelAlign = bc.LabelAlign.BottomCenter
  
	local p = dotnetobject "System.Windows.Forms.Padding" 2
	p.Bottom = 16
	bc.DefaultCellStyle.Padding = p
	bc.ImageLayout = bc.ImageLayout.Normal
	bc.DefaultCellStyle.BackColor = bc.DefaultCellStyle.BackColor.Gray 
	bc.DefaultCellStyle.nullValue = undefined
)

fn reAdjustColumns =
(
	local ts=timestamp()
	local mem=heapfree
	if (local newColumnCount = amax (gv.width/maxCellWidth) 1) != gv.ColumnCount do	
	(
		gv.SuspendLayout()		
		while newColumnCount > gv.ColumnCount do gv.columns.add (bc.clone())
		gv.ColumnCount = newColumnCount
		gv.RowCount = ceil (DGV_Icons.count as float/newColumnCount)
		gv.ResumeLayout()
	)
	format "Readjust Columns: Time: %ms, Memory: %kb\n" (timestamp()-ts) ((mem-heapfree)/1000.0)
)

fn CellSelectionChanged s e = 
(
	format "button: %\n" s.selectedCells.item[0].label
)

fn CellFormatting s e =
(
	local c = e.rowindex*s.ColumnCount + e.ColumnIndex + 1
	local cell = s.rows.item[e.rowindex].cells.item[e.columnindex]
	if c <= DGV_Icons.count then
	(
		local bmp = DGV_Icons[c]		
		cell.ImageLayout = if cell.Size.width < bmp.width or cell.Size.height < bmp.height then cell.ImageLayout.Zoom	else cell.ImageLayout.Normal
		cell.ShowLabel = cell.ImageTextCellColumn.ShowLabel
		e.value = bmp
		cell.Description = cell.ToolTipText = bmp.tag
		cell.Label = c as string + " - " + (getfilenamefile bmp.tag)
	)
	else
	(
		e.value = undefined
		cell.Description = cell.ToolTipText = ""
		cell.ShowLabel = off
	)
)

try(destroyDialog denisTImageViewer)catch()
rollout denisTImageViewer "test" 
(
	dotNetControl panel "System.Windows.Forms.Panel" pos:[0,0]
	
	on denisTImageViewer open do
	(
		panel.width = denisTImageViewer.width
		panel.height = denisTImageViewer.height
		initializeGridView()		
		dotNet.addEventHandler gv "CellFormatting" CellFormatting
		dotNet.addEventHandler gv "SelectionChanged" CellSelectionChanged		
		local numCols = panel.width/maxCellWidth
		for k=1 to numCols do gv.columns.add (bc.clone())		
		--gv.ColumnHeadersDefaultCellStyle.Alignment = gv.ColumnHeadersDefaultCellStyle.Alignment.MiddleC  enter
		gv.ColumnHeadersVisible = gv.ShowEditingIcon = gv.RowHeadersVisible = gv.MultiSelect = off	
		gv.AllowUserToaddRows = gv.AllowUserToDeleteRows = gv.AllowUserToResizeColumns = off
		gv.AllowUserToResizeRows = gv.ReadOnly = gv.AutoSize = on
		gv.Dock = gv.Dock.Fill  
		gv.RowTemplate.Height = 128
		gv.AutoSizeColumnsMode = gv.AutoSizeColumnsMode.Fill
		gv.AutoSizeRowsMode = gv.AutoSizeRowsMode.None
		gv.RowHeadersWidthSizeMode = gv.RowHeadersWidthSizeMode.EnableResizing
		gv.RowCount = ((DGV_Icons.count)/numCols)
		gv.GridColor=gv.Gridcolor.black
		panel.controls.add gv
	)
	
	on denisTImageViewer resized val do
	(
		panel.width=val[1]
		panel.height=val[2]
		reAdjustColumns()
	)
)
createDialog denisTImageViewer style:#(#style_titlebar, #style_border, #style_sysmenu,#style_resizing) width:600 height:400