using System;
using System.Runtime.InteropServices;
using System.Text;

namespace Micra.Core {
    class User32 {

        private delegate void TimerProc(IntPtr hWnd, uint nMsg, int nIDEvent, int dwTime);

        /// <summary>
        /// Starts a timer that is called on a regular interval.
        /// </summary>
        /// <param name="msecInterval"></param>
        /// <param name="callback"></param>
        /// <returns>An integer ID of the timer.</returns>
        public static int StartTimer(int msecInterval, Action<int> callback) {
            TimerProc proc = (IntPtr hWnd, uint nMsg, int nIDEvent, int dwTime) => callback(dwTime);
            return SetTimer(IntPtr.Zero, 0, msecInterval, proc);
        }

        /// <summary>
        /// Cancels the identified timer.
        /// </summary>
        /// <param name="nTimer"></param>
        public static void CancelTimer(int nTimer) => KillTimer(IntPtr.Zero, nTimer);

        [DllImport("user32")]
        private static extern int SetTimer(IntPtr hwnd, int nIDEvent, int uElapse, TimerProc CB);
        [DllImport("user32")]
        private static extern int KillTimer(IntPtr hwnd, int nIDEvent);
        [DllImport("user32.dll")]
        public static extern int SendMessage(IntPtr hWnd, int wMsg, IntPtr wParam, IntPtr lParam);
        [DllImport("user32.dll")]
        public static extern IntPtr FindWindow(string lpClassName, String lpWindowName); //not used not tested
        internal delegate bool WindowEnumProc(IntPtr hwnd, IntPtr lparam);
        [DllImport("user32.dll")]
        [return: MarshalAs(UnmanagedType.Bool)]
        internal static extern bool EnumWindows(WindowEnumProc callPtr, IntPtr lParam);
        [DllImport("user32.dll", CharSet = CharSet.Unicode)]
        internal static extern int GetWindowText(IntPtr hWnd, StringBuilder lpString, int nMaxCount);
        [DllImport("user32.dll", CharSet = CharSet.Unicode)]
        internal static extern int GetWindowTextLength(IntPtr hWnd);
    }
}
