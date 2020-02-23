--if dotnetClass  "LabelRoundCorners2" == undefined do  (
	source = "
	using System;
	using System.Drawing;
	using System.Drawing.Drawing2D;
	using System.Windows.Forms;
	namespace mcDotnetInterface {
		public class LabelRoundCorners2 : Label {

			public Color bgColor { get; set; }
			private int _cornerRadius = 15;
			private int _diminisher = 1;
			private Color _transparentColor = Color.FromArgb(0, 0, 50, 50);
			public LabelRoundCorners2() {

				this.DoubleBuffered = true;
			}
			protected override void OnPaint(PaintEventArgs e) {

				base.OnPaint(e);
				//e.Graphics.Clear(this.BackColor);
				using (GraphicsPath graphicsPath = _getRoundRectangle(this.ClientRectangle)) {
					e.Graphics.SmoothingMode = SmoothingMode.AntiAlias;
					using (SolidBrush solidBrush = new SolidBrush(bgColor))
						e.Graphics.FillPath(solidBrush, graphicsPath);
					using (Pen pen = new Pen(this.ForeColor, 1.0f))
						e.Graphics.DrawPath(pen, graphicsPath);
					TextRenderer.DrawText(e.Graphics, Text, this.Font, this.ClientRectangle, this.ForeColor);
				}
			}
			private GraphicsPath _getRoundRectangle(Rectangle rect) {

				int cr = _cornerRadius;
				int di = _diminisher;
				GraphicsPath path = new GraphicsPath();
				path.AddArc(rect.X, rect.Y, cr, cr, 180, 90);
				path.AddArc(rect.X + rect.Width - cr - di, rect.Y, cr, cr, 270, 90);
				path.AddArc(rect.X + rect.Width - cr - di, rect.Y + rect.Height - cr - di, cr, cr, 0, 90);
				path.AddArc(rect.X, rect.Y + rect.Height - cr - di, cr, cr, 90, 90);
				path.CloseAllFigures();
				return path;
			}
			public int CornerRadius  {
			
				get { return _cornerRadius; } 
				set { _cornerRadius = value; }
			}
			public int Diminisher  {
			
				get { return _diminisher; } 
				set { _diminisher = value; }
			}
			public Color TransparentColor  {
			
				get { return _transparentColor; } 
				set { _transparentColor = value; }
			}
		}
	}"
	mcCSharp.compile source using:#("System", "Forms", "Drawing")
--)


Global testRoll
try( testRoll.close(); testRoll.dispose() )catch()
fn TransparentLabelfn = (

	local form = dotnetobject "System.Windows.Forms.Form"
	local btn_01= dotnetobject "mcDotnetInterface.LabelRoundCorners2"
	local btn_02= dotnetobject  "mcDotnetInterface.LabelRoundCorners2"
	
	local colors = DotNetClass "System.Drawing.Color"
	local transparent_color = colors.fromArgb 0 50 50
	local img = (dotNetClass "System.Drawing.Image")
	local pathImg_Config = img.fromFile(micra.ImagesPath + "DirFile.bmp")
	local pathImg_Config2 = img.fromFile(micra.ImagesPath + "DirRoot.bmp")
	
	fn onButtonMouseUp s a = (
		format "button click:%\n" s.name
		case s.name of (
			
			"btn_config": messagebox("button 1")
			"btn_config2": messagebox("button 2")
			default: print "error"
		)
	)
	
	form.StartPosition = form.StartPosition.Manual
	form.width = 400
	form.height = 200
	form.TopMost = true
	form.Location = dotnetObject "Drawing.Point" 50 300
	form.opacity = 0.8
	formBackColor= transparent_color
	form.backColor=formBackColor
	form.TransparencyKey=formBackColor
	
	btn_01.name="btn_config"
-- 	btn_01.dock=btn_01.dock.Left
	btn_01.size = dotNetObject "Drawing.Size" 100 45
	btn_01.location = dotNetObject "Drawing.Point" 10 10
	btn_01.bgColor = colors.fromArgb 0 255 0
	btn_01.ForeColor = colors.fromArgb 0 0 0
	btn_01.CornerRadius = 20
	btn_01.text= "BTN A"
-- 			btn_01.image = pathImg_Config

	btn_02.name="btn_config2"
-- 	btn_02.dock=btn_02.dock.Right
	btn_02.size = dotNetObject "Drawing.Size" 100 45
	btn_02.location = dotNetObject "Drawing.Point" 120 10
	btn_02.bgColor = colors.fromArgb 0 255 0
	btn_02.ForeColor = colors.fromArgb 0 0 0
	btn_02.CornerRadius = 20
	btn_02.text= "BTN B"
-- 			btn_02.image = pathImg_Config2

	dnToolTip = dotnetobject "tooltip"
	dnToolTip.AutoPopDelay = 5000
	dnToolTip.InitialDelay = 300
	dnToolTip.ReshowDelay = 300
	dnToolTip.ShowAlways = true
	dnToolTip.settooltip btn_01 btn_01.name
	dnToolTip.settooltip btn_02 btn_02.name
	
	form .controls.addRange #(btn_01, btn_02)
	dotNet.addEventHandler btn_01 "MouseUp" onButtonMouseUp
	dotNet.addEventHandler btn_02 "MouseUp" onButtonMouseUp

	form.Show()
	form
)
testRoll = TransparentLabelfn()
