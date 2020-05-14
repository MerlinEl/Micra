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
        public static void SetAccelerators(bool state) {
            if ( state )
                ManagedServices.AppSDK.EnableAccelerators(); // for lostfocus
            else
                ManagedServices.AppSDK.DisableAccelerators(); // for gotfocus
        }
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
    }
}
