
source = "
using System.Drawing;
using System.Drawing.Drawing2D;
using System.Windows.Forms;
public class LabelRoundCorners : Label {

	public Color _BackColor { get; set; }
	public LabelRoundCorners() {
	
		this.DoubleBuffered = true;
	}
	protected override void OnPaint(PaintEventArgs e) {
	
		base.OnPaint(e);
		using (GraphicsPath graphicsPath = _getRoundRectangle(this.ClientRectangle))
		{
			e.Graphics.SmoothingMode = SmoothingMode.AntiAlias;
			using (SolidBrush solidBrush = new SolidBrush(_BackColor))
				e.Graphics.FillPath(solidBrush, graphicsPath);
			using (Pen pen = new Pen(_BackColor, 1.0f))
				e.Graphics.DrawPath(pen, graphicsPath);
			TextRenderer.DrawText(e.Graphics, Text, this.Font, this.ClientRectangle, this.ForeColor);
		}
	}
	private GraphicsPath _getRoundRectangle(Rectangle rectangle) {
	
		int cornerRadius = 15;
		int diminisher = 1;
		GraphicsPath path = new GraphicsPath();
		path.AddArc(rectangle.X, rectangle.Y, cornerRadius, cornerRadius, 180, 90);
		path.AddArc(rectangle.X + rectangle.Width - cornerRadius - diminisher, rectangle.Y, cornerRadius, cornerRadius, 270, 90);
		path.AddArc(rectangle.X + rectangle.Width - cornerRadius - diminisher, rectangle.Y + rectangle.Height - cornerRadius - diminisher, cornerRadius, cornerRadius, 0, 90);
		path.AddArc(rectangle.X, rectangle.Y + rectangle.Height - cornerRadius - diminisher, cornerRadius, cornerRadius, 90, 90);
		path.CloseAllFigures();
		return path;
	}
}"
mcCSharp.compile source using:#("System", "Forms", "Drawing")


Global testRoll
try( testRoll.close(); testRoll.dispose() )catch()
fn TransparentLabelfn = (

	local form = dotnetobject "System.Windows.Forms.Form"
	local btn_01= dotnetobject "LabelRoundCorners"
	local btn_02= dotnetobject  "LabelRoundCorners"
	
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
	btn_01._BackColor = colors.fromArgb 0 255 0
	btn_01.text= "BTN A"
-- 			btn_01.image = pathImg_Config

	btn_02.name="btn_config2"
-- 	btn_02.dock=btn_02.dock.Right
	btn_02.size = dotNetObject "Drawing.Size" 100 45
	btn_02.location = dotNetObject "Drawing.Point" 120 10
	btn_02._BackColor = colors.fromArgb 0 255 0
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
