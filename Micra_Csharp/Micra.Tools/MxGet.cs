using Autodesk.Max;
using System;
using System.Drawing;
using System.Windows.Forms;

namespace Micra.Tools {
    public class MxGet {

        #region Enums

        public enum MouseEventFlags { //not used yet
            LEFTDOWN = 0x00000002,
            LEFTUP = 0x00000004,
            MIDDLEDOWN = 0x00000020,
            MIDDLEUP = 0x00000040,
            MOVE = 0x00000001,
            ABSOLUTE = 0x00008000,
            RIGHTDOWN = 0x00000008,
            RIGHTUP = 0x00000010
        }

        #endregion

        #region Objects

        public static object FontStyles = Enum.ToObject(typeof(FontStyle), 0);

        #endregion

        #region Methods

        public static Font NewFont(string family, float size, FontStyle style) => new Font(family, size, style);
        public static Size NewSize(int w, int h) => new Size(w, h);
        public static Color NewColor(int r, int g, int b) => Color.FromArgb(r, g, b);
        public static Color ColorFromName(string clr_str) => Color.FromName(clr_str);

        /// <summary>
        /// NativeWindow parentWindow = GetWindowFromHwnd(hwnd);
        /// try {
        ///     myForm.ShowDialog(parentWindow);
        /// }
        /// finally {
        ///     parentWindow.DestroyHandle();
        /// }
        /// </summary>
        /// <param name="hwnd"></param>
        /// <returns></returns>
        public static NativeWindow GetWindowFromHwnd(long hwnd) {
            IntPtr handle = new IntPtr(hwnd);
            NativeWindow window = new NativeWindow();
            window.AssignHandle(handle);
            return window;
        }
        #endregion


        public static IGlobal Global {
            get { return GlobalInterface.Instance; }
        }

        /*public static IInterface Interface {
            get { return Global.COREInterface; }
        }*/

        public static IInterface13 Interface {
            get { return  Global.COREInterface13; }
        }

        public static IPoint3 Point(double x, double y, double z) {

            return Global.Point3.Create(x, y, z);
        }

        /*public class Point {
            private double _x = 0;
            private double _y = 0;
            private double _z = 0;
          *  private IPoint3 p;
            public Point(double x, double y, double z) {
                _x = x;
                _y = y;
                _z = z;
                p = MxGet.Global.Point3.Create(x, y, z);
            }
        }*/
    }
}
