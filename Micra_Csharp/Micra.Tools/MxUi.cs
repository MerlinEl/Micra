using Orien.NetUi;
using System;
using System.Drawing;
using System.IO;
using System.Windows.Forms;

namespace Micra.Tools {
    class MxUi {
        private static NativeWindow parentWindow;
        public static void SetButonTooltip(Button ctrl, string bodyText, string imgName) {

            McTooltip tltp = new McTooltip {

                MaxSize = new Size(400, 400),
                HeaderText = ctrl.Text,
                BodyText = bodyText,
                BodyTextFont = new Font("Arial", 12, FontStyle.Regular),
                FooterText = "Press F1 for more help.",
                BodyImageStretch = false,
                ExtendedMode = true,
                AutoHide = false//keep visible extended version while mouse is on button
            };
            //C# test get upper dir 2*
            string micraDir = File.Exists(MxGet.MicraRootDir) ? MxGet.MicraRootDir : MxGet.MicraRootDir2;
            string imgPath = micraDir + @"\Img\TooltipIcons\" + imgName + ".png";
            tltp.SetToolTip(ctrl, imgPath);
        }

        public static void ShowForm(Form form) {

            if ( form == null || form.IsDisposed ) return;
            if ( parentWindow == null ) parentWindow = new NativeWindow();
            if ( parentWindow.Handle == IntPtr.Zero ) parentWindow.AssignHandle(MxGet.Interface.MAXHWnd);
            if ( !form.Visible ) form.Show(parentWindow);
            form.WindowState = FormWindowState.Normal;
            form.BringToFront();
        }
    }
}
