--------------------------------------------------------------------------------
/* mcCSharpUI by Orien 2020 */
--------------------------------------------------------------------------------
/*
*@Used Structures
	mcStructMan
*
*@Used Objects
	undefined
*
*@Usage
	Library of C# codes as String
*
*@Example	
	----------------------------------------------------
	rect_1 = mcCSharp.new "Orien.Math.Rectangle2D"  params:#(10, 122)
	rect_1.Area()
	----------------------------------------------------
	rect_2 = mcCSharp.new "Orien.Math.Rectangle2D"  params:#(100, 400)
	rect_2.Area()
	----------------------------------------------------
	lbl_01 = mcCSharp.new "Orien.DotnetUI.LabelRoundCorners" 
	----------------------------------------------------
*
*/
struct MICRA_CSHARPUI_STRUCTURE	(
	
	--variables
	
	--functions
	fn getSource = getSourceFileName(), --get path of this script
	fn getClass className = (	
		case className of (	
"Orien.Math.Rectangle2D" : (
"
using System;
namespace Orien.Math {
	public class Rectangle2D {
	
		public int length, width;
		// Parameterized Constructor 
		public Rectangle2D(int l, int b) {
			length = l;
			width = b;
		}
		// Method to Calculate Area  of the rectangle 
		public int Area() { 
			return length * width; 
		} 
	}
}
"
)
"Orien.DotnetUI.LabelRoundCorners" : (
"
using System;
using System.Drawing;
using System.Drawing.Drawing2D; //internal
using System.Windows.Forms;
namespace Orien.DotnetUI {
	public class LabelRoundCorners : Label {

		public Color bgColor { get; set; }
		private int _cornerRadius = 15;
		private int _diminisher = 1;
		private Color _transparentColor = Color.FromArgb(0, 0, 50, 50);
		public LabelRoundCorners() {

			this.DoubleBuffered = true;
		}
		protected override void OnPaint(PaintEventArgs e) {

			base.OnPaint(e);
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
}
"	
)
		)
	)
	/*<end>*/
)	
 --create instance
Global mcCSharpUI = mcStructMan.instanceStructure MICRA_CSHARPUI_STRUCTURE "mcCSharpUI"


---------------------------------
--TEMPLATE Class with parameter--
---------------------------------
/* 
"MyNameSpace.MyClassWithArg" : (
"
using System;
namespace MyNameSpace {
	public class MyClassWithArg {
		public string arg;
		public MyClassWithArg(string thisArg) {

			arg = thisArg;
		}
		public string sayArg() {

		   return (\"MyClassWithArg.sayArg has been called.MyClassWithArg.arg = \"+ arg + \".\");
		}
	}
}
"
)	
*/